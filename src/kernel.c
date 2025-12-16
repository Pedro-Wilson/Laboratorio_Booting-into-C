#include <stdint.h>
#include <stddef.h>

// Definimos o endereço base da memória VGA
#define VGA_ADDRESS 0xB8000
#define VGA_WIDTH 80
#define VGA_HEIGHT 25
#define WHITE_ON_BLACK 0x07 // Cor Cinza Claro sobre Fundo Preto

// Acessamos o buffer VGA como um array de ponteiros de 16 bits
volatile uint16_t* vga_buffer = (volatile uint16_t*) VGA_ADDRESS;

// Função utilitária para escrever um caractere com cor em uma posição específica
void vga_putentryat(char c, uint8_t color, size_t x, size_t y)
{
    // Calcula o offset (deslocamento) na memória de vídeo
    const size_t index = y * VGA_WIDTH + x; 
    
    // O valor do caractere é combinado com o byte de cor (high byte)
    vga_buffer[index] = (uint16_t)c | (uint16_t)color << 8; 
}

// Função para limpar a tela
void vga_clear_screen(uint8_t color)
{
    for (size_t y = 0; y < VGA_HEIGHT; y++) {
        for (size_t x = 0; x < VGA_WIDTH; x++) {
            vga_putentryat(' ', color, x, y);
        }
    }
}

// A função principal do kernel
void kmain(uint32_t magic, uint32_t multiboot_info_ptr) 
{
    // Limpa a tela antes de imprimir
    vga_clear_screen(WHITE_ON_BLACK);

    // Linha 1: -------------------------
    for (size_t x = 28; x < 52; x++) {
        vga_putentryat('-', WHITE_ON_BLACK, x, 11);
        vga_putentryat('-', WHITE_ON_BLACK, x, 14);
    }
    vga_putentryat('|', WHITE_ON_BLACK, 27, 12);
    vga_putentryat('|', WHITE_ON_BLACK, 52, 12);
    vga_putentryat('|', WHITE_ON_BLACK, 27, 13);
    vga_putentryat('|', WHITE_ON_BLACK, 52, 13);
    
    // Escreve a mensagem central
    const char *message = "Hello from C kernel";
    const size_t start_col = 30; // Coluna de início para centralizar
    
    for (size_t i = 0; message[i]!= '\0'; i++) {
        // Linha 12 (13ª linha)
        vga_putentryat(message[i], 0x0F, start_col + i, 12); 
    }
    
    // Escreve a mensagem adicional na linha 13
    const char *message2 = "Ready for input...";
    const size_t start_col2 = 30; 
    
    for (size_t i = 0; message2[i]!= '\0'; i++) {
        // Linha 13 (14ª linha)
        vga_putentryat(message2[i], 0x0A, start_col2 + i, 13); // Cor verde
    }
    
    while(1) {
        // Loop infinito para manter o kernel em execução
    }
}