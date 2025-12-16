#!/usr/bin/env bash

# ============================================================
# CONTROLE DE ERROS
# ============================================================

set -eE

CURRENT_STEP="Inicialização"

trap 'erro_handler $LINENO "$BASH_COMMAND"' ERR

erro_handler() {
    echo
    echo "============================================================"
    echo -e "\033[1;31m[ERRO]\033[0m Falha durante o passo:"
    echo -e " ➜ \033[1;33m$CURRENT_STEP\033[0m"
    echo
    echo "Linha: $1"
    echo "Comando: $2"
    echo "============================================================"
    exit 1
}

# ============================================================
# FUNÇÕES DE LOG E CONTROLE
# ============================================================

step() {
    CURRENT_STEP="$1"
    echo
    echo "============================================================"
    echo -e "\033[1;34m[PASSO]\033[0m $CURRENT_STEP"
    echo "============================================================"
}

success() {
    echo -e "\033[1;32m[OK]\033[0m $CURRENT_STEP concluído com sucesso."
}

confirmar() {
    echo
    read -rp "➡️  Pressione ENTER para continuar ou Ctrl+C para abortar..."
}

info() {
    echo -e "\033[1;36m[INFO]\033[0m $1"
}

# ============================================================
# CONFIGURAÇÕES GERAIS
# ============================================================

TARGET=i386-elf
PREFIX=/usr/local/i386elfgcc
SRC_DIR=$HOME/src_osdev
BINUTILS_VERSION=2.42
GCC_VERSION=14.1.0

# ============================================================
# VERIFICAÇÕES INICIAIS
# ============================================================

step "Verificações iniciais"

if [[ $EUID -eq 0 ]]; then
    echo "[ERRO] Não execute este script como root."
    exit 1
fi

success
confirmar

# ============================================================
# PASSO 1: DEPENDÊNCIAS DO SISTEMA
# ============================================================

step "Instalação de dependências do sistema"

sudo apt update
sudo apt install -y \
    build-essential \
    git \
    curl \
    texinfo \
    bison \
    flex \
    libgmp3-dev \
    libmpc-dev \
    libmpfr-dev \
    qemu-system-i386 \
    xorriso \
    grub-pc-bin

success
confirmar

# ============================================================
# PASSO 2: PREPARAÇÃO DE DIRETÓRIOS
# ============================================================

step "Preparação dos diretórios da toolchain"

sudo mkdir -p "$PREFIX"
sudo chown -R "$USER:$USER" "$PREFIX"

mkdir -p "$SRC_DIR"
cd "$SRC_DIR"

success
confirmar

# ============================================================
# PASSO 3: DOWNLOAD DOS SOURCES
# ============================================================

step "Download do Binutils e GCC"

if [[ ! -f binutils.tar.xz ]]; then
    curl -L "https://ftpmirror.gnu.org/binutils/binutils-$BINUTILS_VERSION.tar.xz" -o binutils.tar.xz
fi

if [[ ! -f gcc.tar.xz ]]; then
    curl -L "https://ftpmirror.gnu.org/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.xz" -o gcc.tar.xz
fi

success
confirmar

# ============================================================
# PASSO 4: EXTRAÇÃO DOS SOURCES
# ============================================================

step "Extração dos arquivos fonte"

rm -rf binutils-src gcc-src build-binutils build-gcc

tar -xf binutils.tar.xz
tar -xf gcc.tar.xz

mv binutils-$BINUTILS_VERSION binutils-src
mv gcc-$GCC_VERSION gcc-src

success
confirmar

# ============================================================
# PASSO 5: BUILD BINUTILS
# ============================================================

step "Compilação do Binutils"

mkdir build-binutils
cd build-binutils

../binutils-src/configure \
    --target=$TARGET \
    --prefix="$PREFIX" \
    --with-sysroot \
    --disable-nls \
    --disable-werror

make -j"$(nproc)"
make install

cd ..

success
confirmar

# ============================================================
# PASSO 6: BUILD GCC
# ============================================================

step "Compilação do GCC (C freestanding)"

mkdir build-gcc
cd build-gcc

../gcc-src/configure \
    --target=$TARGET \
    --prefix="$PREFIX" \
    --enable-languages=c \
    --without-headers \
    --disable-nls

make all-gcc -j"$(nproc)"
make install-gcc

cd ..

success
confirmar

# ============================================================
# PASSO 7: CONFIGURAÇÃO DO PATH
# ============================================================

step "Configuração permanente do PATH"

if ! grep -q "$PREFIX/bin" ~/.bashrc; then
    {
        echo ""
        echo "# Toolchain i386-elf (OSDev)"
        echo "export PATH=\"$PREFIX/bin:\$PATH\""
    } >> ~/.bashrc
fi

export PATH="$PREFIX/bin:$PATH"

success
confirmar

# ============================================================
# PASSO 8: TESTES FINAIS
# ============================================================

step "Testes da toolchain"

command -v i386-elf-gcc >/dev/null
command -v i386-elf-ld  >/dev/null

success

# ============================================================
# FINALIZAÇÃO
# ============================================================

echo
echo "============================================================"
echo -e "\033[1;32m[SUCCESSO]\033[0m Ambiente configurado completamente!"
echo "Reinicie o terminal ou execute: source ~/.bashrc"
echo "Pronto para desenvolvimento bare metal 🚀"
echo "============================================================"
