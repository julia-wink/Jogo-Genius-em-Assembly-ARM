# Jogo Genius em Assembly ARM

Projeto desenvolvido em grupo para a disciplina de **Arquitetura de Computadores**, utilizando **Assembly ARM** e o simulador **CPUlator**, com o sistema **ARMv7 DE1-SoC**.

O projeto consiste na implementação de um jogo inspirado no **Genius (Simon Says)**, no qual o jogador deve reproduzir uma sequência de cores apresentada pelo sistema.

## 🎮 Funcionamento

O jogo gera uma sequência de 10 cores e apresenta cada uma delas na tela. Em seguida, o jogador deve pressionar os botões correspondentes na mesma ordem em que as cores foram apresentadas.

As quatro cores utilizadas são:

| Cor | Botão | Bit |
|---|---|---:|
| 🟢 Verde | Botão 3 | 3 |
| 🔴 Vermelho | Botão 2 | 2 |
| 🔵 Azul | Botão 1 | 1 |
| 🟡 Amarelo | Botão 0 | 0 |

Caso o jogador pressione um botão incorreto ou pressione mais de um botão simultaneamente, o jogo é encerrado.

## ⚙️ Tecnologias e conceitos

- Assembly ARM (ARMv7)
- CPUlator
- Sistema ARMv7 DE1-SoC
- Manipulação de memória e registradores
- Entrada e saída por memória mapeada
- Timers
- Geração de números pseudoaleatórios
- Polling de dispositivos de entrada
- Manipulação de bits
- Frame Buffer / Pixel Buffer
- Double Buffering
- Renderização de pixels em Assembly

## 🖥️ Dispositivos simulados

O projeto utiliza recursos da placa DE1-SoC simulados pelo CPUlator, principalmente:

- Push buttons para entrada do jogador;
- Pixel Buffer para a saída gráfica;
- Timer para controle de tempo;
- Memória utilizada pelos buffers de vídeo.

O acesso aos periféricos é realizado por meio de endereços de memória mapeada.

## 🧠 Principais partes do código

### Geração da sequência

A função `gera_sequencia` gera uma sequência de 10 valores utilizando o timer como fonte para a geração dos números.

A função `gerar_numero` utiliza operações de manipulação de bits para produzir valores correspondentes aos quatro botões, evitando que o mesmo valor seja gerado consecutivamente.

### Leitura dos botões

A função `le_botao_pressionado` realiza a leitura dos botões por **polling** e utiliza `detecta_mudanca` para identificar alterações no estado dos botões.

A função `valida_botao` verifica se apenas um botão está pressionado.

### Exibição da sequência

A função `mostra_sequencia` percorre a sequência gerada e utiliza `ligar_leds` para desenhar as cores correspondentes na tela.

### Renderização gráfica

A função `paint_pixel` escreve diretamente no Pixel Buffer para alterar os pixels da tela.

O projeto utiliza **Double Buffering**, alternando entre um front buffer e um back buffer para atualizar a tela de forma mais adequada durante a execução.

### Controle de tempo

A função `delay` utiliza um timer para controlar o intervalo de exibição entre as cores.

## ▶️ Como executar

O projeto foi desenvolvido para o ambiente **CPUlator ARMv7 DE1-SoC**.

1. Acesse o CPUlator:
   https://cpulator.01xz.net/?sys=arm-de1soc

2. Selecione o sistema **ARMv7 DE1-SoC**.

3. Abra o arquivo `main.s` no editor do simulador.

4. Compile e carregue o programa utilizando **Compile and Load**.

5. Execute o programa e utilize os botões simulados para reproduzir a sequência de cores.

> **Observação:** o projeto depende dos endereços de memória e dos dispositivos disponíveis no sistema ARMv7 DE1-SoC. Portanto, ele não foi desenvolvido para execução em um computador comum sem o ambiente de simulação ou hardware compatível.


**Integrantes:**

- Julia C. Winkler
- Pedro P. Gatto
- Thiago H. Minervino
- Vinícius de O. Teles


