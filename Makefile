# ====================================================================
# Configuração da Toolchain e Alvos
# ====================================================================

# O alvo de arquitetura para a toolchain. Garante código de 32 bits.
TARGET = i386-elf 

# Prefixo da toolchain. Usamos nomes explícitos para garantir que o shell encontre o binário.
# A ferramenta deve estar no seu PATH: /usr/local/i386elfgcc/bin
CC = i386-elf-gcc
AS = i386-elf-as
LD = i386-elf-ld

# Flags de Compilação
CFLAGS = -ffreestanding -nostdlib -m32 -g -Wall -Wextra -O0 
# -ffreestanding e -nostdlib: Essenciais para não depender da biblioteca C do Host OS. [1, 2]
# -m32: Força a geração de código de 32 bits.
# -g e -O0: Adicionam símbolos de debug e desativam otimizações para facilitar o debug inicial. [2, 3]
AFLAGS = --32 -g

# Arquivos de entrada e saída
SRC_ASM = src/boot.s
SRC_C = src/kernel.c
OBJECTS = $(SRC_ASM:.s=.o) $(SRC_C:.c=.o)
LINKER_SCRIPT = linker.ld
KERNEL_ELF = kernel.elf

# ====================================================================
# Regras de Build
# ====================================================================

# Regra principal: compila tudo e gera o binário ELF final
.PHONY: all
all: $(KERNEL_ELF)

# Regra de linkeditação: Combina os objetos usando o script do linker
$(KERNEL_ELF): $(OBJECTS) $(LINKER_SCRIPT)
	@echo "📎 Linking $(KERNEL_ELF)..."
	$(LD) -n -o $@ -T $(LINKER_SCRIPT) $(filter-out $(LINKER_SCRIPT), $^)
# A função 'filter-out' remove o linker.ld da lista de objetos ($^). [2]



# Regra para compilar o código Assembly
%.o: %.s
	@echo "🔨 Compiling $< (Assembly)..."
	$(AS) $(AFLAGS) $< -o $@

# Regra para compilar o código C
%.o: %.c
	@echo "🔨 Compiling $< (C)..."
	$(CC) $(CFLAGS) -c $< -o $@

# ====================================================================
# Regras de Limpeza
# ====================================================================
.PHONY: clean
clean:
	@echo "🗉️ Cleaning up..."
	rm -f $(OBJECTS) $(KERNEL_ELF) kernel.iso isodir/boot/kernel.elf
	rm -rf isodir
	@echo "Limpeza completa."