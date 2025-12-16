## 🔬 Laboratório de Booting em C

Um laboratório prático para aprender e desenvolver o processo de **inicialização (booting) de um sistema**, focando na transição do código Assembly do *bootloader* para a execução do código de alto nível em C.

Este projeto é um mergulho na programação de **baixo nível**, abordando a arquitetura de computadores e os fundamentos dos sistemas operacionais.

---

### 🌟 Visão Geral

O objetivo principal deste laboratório é criar um ambiente mínimo onde a CPU, após o Power-On Self-Test (POST) da BIOS/UEFI, consiga executar um código customizado escrito em C.

Isto exige a criação de:

1.  **Bootloader (Assembly):** O código inicial que reside no setor de boot (Vetor de Interrupção 0x19), responsável por carregar os dados necessários para a memória.
2.  **Kernel/Payload (C):** O código de destino final, que assume o controle e executa tarefas de inicialização de alto nível.



### ⚙️ Componentes Chave

| Componente | Linguagem | Responsabilidade Principal |
| :--- | :--- | :--- |
| **Bootloader** | Assembly (x86) | Configurar a CPU, alternar modos (Real Mode $\rightarrow$ Protected Mode), carregar o *payload* C para a memória e transferir o controle. |
| **Payload C** | C | Inicializar variáveis de sistema, configurar a pilha, e executar o código C principal (por exemplo, exibir uma mensagem na tela). |
| **Makefile** | (Scripts) | Orquestrar a compilação cruzada (cross-compilation), a ligação (*linking*) e a criação da imagem de disco bootável (`.img`). |

### 🛠️ Como Construir e Testar

#### 1. Pré-requisitos

Para compilar o *bootloader* em Assembly e o código C de forma cruzada, você precisará das seguintes ferramentas:

* **GNU GCC:** Compilador C.
* **NASM:** Assembler para o código Assembly.
* **LD:** Linker (ligador).
* **QEMU:** Emulador de máquina para testar a imagem de disco sem hardware real.

#### 2. Compilação e Montagem

Execute o `Makefile` na raiz do projeto. Ele se encarregará de compilar, *linkar* e empacotar o código:
Leia o Config.md

```bash
make all
```

3. Execução

Após a compilação bem-sucedida, você pode testar a imagem bootável gerada usando o QEMU:
```bash
make run
```
O QEMU irá carregar a imagem, e o bootloader deverá ser executado, carregando e transferindo o controle para o seu código 
