/* Define o formato de saída como ELF de 32 bits (i386) */
OUTPUT_FORMAT("elf32-i386")
/* Define o ponto de entrada da execução (a função em Assembly) */
ENTRY(_start)

SECTIONS
{
    /* Define o Endereço de Carga (LMA) do kernel como 1 Megabyte.
       Isto é crucial porque o GRUB carrega o kernel para este endereço. */
  . = 0x100000;

    /* Seção obrigatória que contém o Multiboot Header.
       Deve ser a primeira seção e estar alinhada. */
  .multiboot ALIGN(4):
    {
        *(.multiboot)
    }

    /* Seção.text (código executável) */
  .text :
    {
        *(.text)
    }

    /* Seção.data (dados inicializados) e.bss (dados não inicializados) */
  .data :
    {
        *(.data)
    }

  .bss :
    {
        *(.bss)
    }
}