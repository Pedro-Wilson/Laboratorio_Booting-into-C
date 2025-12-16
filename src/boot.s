# Arquivo: src/boot.s (Sintaxe AT&T/GAS 100% Corrigida e Verificada)

.global _start          # Define _start como o ponto de entrada (label global)
.extern kmain           # Define kmain (função C) como um símbolo externo

# Seção do Cabeçalho Multiboot
.section .multiboot     # CORREÇÃO: ESPAÇO OBRIGATÓRIO AQUI (Linha 7)
.align 4

# Constantes do Multiboot (v1)
MULTIBOOT_MAGIC = 0x1BADB002
MULTIBOOT_FLAGS = 0x3   # Bit 0: Alinhamento de módulos; Bit 1: Requer info de memória 

.long MULTIBOOT_MAGIC
.long MULTIBOOT_FLAGS
# Checksum: (Magic + Flags + Checksum) deve ser zero.
.long -(MULTIBOOT_MAGIC + MULTIBOOT_FLAGS) 

# Seção de Código (Onde o GRUB pula)
.section .text          # CORREÇÃO: ESPAÇO OBRIGATÓRIO AQUI (Linha 20)
.align 4
.global _start
_start:
    # 1. Configurar o Stack Pointer (Pilha)
    # A pilha aponta para o topo da área reservada em.bss.
    movl $stack_top, %esp

    # 2. Passar argumentos do Multiboot para o C (Convenção CDECL)
    # EAX = Magic Number; EBX = Ponteiro para Multiboot Info Struct [1, 2]
    # Empilhamos na ordem inversa para a função C: kmain(eax, ebx)
    pushl %ebx  # Argumento 2
    pushl %eax  # Argumento 1

    # 3. Chamar a função principal em C
    call kmain 

    # 4. Loop infinito se o kernel retornar
.Lhalt:
    cli         # Desabilita interrupções
    hlt         # Aguarda interrupção (trava a CPU)
    jmp .Lhalt  # CORREÇÃO: ESPAÇO OBRIGATÓRIO AQUI (Linha 41)
    
# Definição da Pilha (no segmento BSS, dados não inicializados)
.section .bss           # CORREÇÃO: ESPAÇO OBRIGATÓRIO AQUI (Linha 44)
.align 4
stack_bottom:
.skip 16384 # Reserva 16KB de espaço para a pilha temporária
stack_top: