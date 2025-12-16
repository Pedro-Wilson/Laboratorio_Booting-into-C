#!/bin/bash
# config.sh: Script para instalar e configurar o ambiente de toolchain i386-elf no Linux/WSL.
# Este script constrói o GCC e o Binutils a partir do código fonte para garantir o modo freestanding.

# Abortar em caso de erro
set -e

echo "=============================================="
echo "PASSO 1: INSTALAÇÃO DE DEPENDÊNCIAS DO SISTEMA"
echo "=============================================="

# 1. Instalação de todas as dependências em um único comando
sudo apt update
sudo apt install -y build-essential git curl texinfo bison flex \
    libgmp3-dev libmpc-dev libmpfr-dev \
    qemu-system-i386 xorriso grub-pc-bin

echo "✅ Dependências de Host e Emuladores instalados."

# ====================================================================
# PASSO 2: CONSTRUÇÃO E INSTALAÇÃO DA TOOLCHAIN CRUZADA (i386-elf)
# ====================================================================

# 2.1. Configuração do Ambiente e Download
export TARGET=i386-elf
export PREFIX="/usr/local/i386elfgcc" # Local onde a toolchain será instalada

# Adiciona o diretório binário ao PATH (necessário para que o make o encontre)
export PATH="$PREFIX/bin:$PATH"

# Cria o diretório de instalação com permissões de root
sudo mkdir -p $PREFIX

# Cria o diretório de fontes e navega até ele
mkdir -p $HOME/src_osdev
cd $HOME/src_osdev

# Baixa as fontes
echo "⏳ Baixando fontes do GCC e Binutils..."
curl -L 'https://ftpmirror.gnu.org/binutils/binutils-2.42.tar.xz' -o binutils.tar.xz
curl -L 'https://ftpmirror.gnu.org/gcc/gcc-14.1.0/gcc-14.1.0.tar.xz' -o gcc.tar.xz

# Descompacta e renomeia
tar -xf binutils.tar.xz
tar -xf gcc.tar.xz
mv binutils-2.42 binutils-src
mv gcc-14.1.0 gcc-src

# --- 2.2. Compilação do Binutils (Linker: i386-elf-ld) ---
echo "⏳ Compilando Binutils (fase 1)..."
mkdir build-binutils
cd build-binutils
../binutils-src/configure --target=$TARGET --prefix="$PREFIX" \
    --with-sysroot --disable-nls --disable-werror
make
sudo make install
cd..
echo "✅ Binutils instalado."


# --- 2.3. Compilação e Instalação do GCC (Compilador C: i386-elf-gcc) ---
echo "⏳ Compilando GCC (fase 2 - pode demorar)..."

# CRÍTICO: --without-headers garante o ambiente freestanding
mkdir build-gcc
cd build-gcc
../gcc-src/configure --target=$TARGET --prefix="$PREFIX" \
    --enable-languages=c \
    --without-headers \
    --disable-nls
make all-gcc
sudo make install-gcc
cd..
echo "✅ GCC i386-elf instalado. Toolchain concluída."

# ====================================================================
# PASSO 3: INSTRUÇÕES PARA COMPILAÇÃO
# ====================================================================

echo ""
echo "=============================================="
echo "INSTALAÇÃO CONCLUÍDA!"
echo "Para compilar e executar o kernel, volte para a pasta do projeto (kernel-dev) e execute:"
echo '  $ make'
echo '  $./execute.sh'
echo "=============================================="
