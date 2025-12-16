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
# FUNÇÕES DE LOG
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
# CONFIGURAÇÕES
# ============================================================

KERNEL_ELF=kernel.elf
ISO_NAME=kernel.iso
ISO_DIR=isodir

# ============================================================
# PASSO 0: VERIFICAÇÕES
# ============================================================

step "Verificações iniciais"

command -v i386-elf-gcc >/dev/null
command -v grub-mkrescue >/dev/null
command -v qemu-system-i386 >/dev/null

if [[ ! -f Makefile ]]; then
    echo "[ERRO] Makefile não encontrado no diretório atual."
    exit 1
fi

success
confirmar

# ============================================================
# PASSO 1: BUILD DO KERNEL
# ============================================================

step "Compilação do kernel (make)"

make

success
confirmar

# ============================================================
# PASSO 2: PREPARAÇÃO DO ISO
# ============================================================

step "Preparação da estrutura do ISO"

rm -rf "$ISO_DIR"
mkdir -p "$ISO_DIR/boot/grub"

if [[ ! -f "$KERNEL_ELF" ]]; then
    echo "[ERRO] $KERNEL_ELF não encontrado após o build."
    exit 1
fi

cp "$KERNEL_ELF" "$ISO_DIR/boot/"

cat > "$ISO_DIR/boot/grub/grub.cfg" << EOF
menuentry "--> Meu Kernel: Hello World! :)" {
    multiboot /boot/kernel.elf
}
EOF

success
confirmar

# ============================================================
# PASSO 3: GERAÇÃO DO ISO
# ============================================================

step "Geração do ISO bootável (GRUB)"

grub-mkrescue -o "$ISO_NAME" "$ISO_DIR" >/dev/null

success
confirmar

# ============================================================
# PASSO 4: EXECUÇÃO NO QEMU
# ============================================================

step "Execução do kernel no QEMU"

qemu-system-i386 \
    -cdrom "$ISO_NAME" \
    -boot d \
    -serial stdio

success

# ============================================================
# FINALIZAÇÃO
# ============================================================

echo
echo "============================================================"
echo -e "\033[1;32m[SUCCESSO]\033[0m Execução finalizada!"
echo "ISO gerado: $ISO_NAME"
echo "============================================================"
