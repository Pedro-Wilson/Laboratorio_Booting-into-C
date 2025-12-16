# Define o local onde a toolchain foi instalada
export PREFIX="/usr/local/i386elfgcc"

# Adiciona o diretório da toolchain ao PATH
export PATH="$PREFIX/bin:$PATH"

# Agora, execute o make
make

# Cria a estrutura de diretórios para o ISO
mkdir -p isodir/boot/grub

# Copia o kernel ELF compilado
cp kernel.elf isodir/boot/

# Cria o arquivo de configuração do GRUB
echo 'menuentry "Meu Kernel i386 Multiboot" {
    multiboot /boot/kernel.elf
}' > isodir/boot/grub/grub.cfg

# Gera a imagem ISO bootável
grub-mkrescue -o kernel.iso isodir

# Executa a imagem ISO no QEMU 32 bits
qemu-system-i386 -cdrom kernel.iso -boot d -serial stdio
