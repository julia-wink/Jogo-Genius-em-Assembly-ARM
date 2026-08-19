.global main


.equ END_BOTOES, 0xFF200050    		@ Endereço dos botões

.equ PIXEL_BUF_CTRL, 0xFF203020
.equ FRONT_BUFFER, 0xC8000000
.equ BACK_BUFFER,  0xC0000000

.equ VERDE_ON, 0x0fa7
.equ VERDE_OFF, 0x09c2

.equ AZUL_ON, 0x24df
.equ AZUL_OFF, 0x11cb

.equ AMARELO_ON, 0xc701
.equ AMARELO_OFF, 0x31e1

.equ VERMELHO_ON, 0xf965
.equ VERMELHO_OFF, 0x58a2

.equ PRETO, 0x0000

.equ ENDERECO_TIMER,  0xFFFEC600
.equ TEMPO_DELAY, 	  0x001e8480 @ tempo x frquencia (200mhz) / (prescaler+1) // mas no simulador fica ruim mds
.equ ENDERECO_TIMER2, 0xFF202020


.data
sequencia_teste:
	.word 0b1000, 0b0100, 0b0010, 0b0001
	
current_buffer:
    .word BACK_BUFFER

estado_anterior:
    .word 0    	@ Guarda o último estado lido para detectar mudança

sequencia:
    .word 0,0,0,0,0,0,0,0,0,0

ultimo_valor_gerado:
    .word 0

.text
main:
    bl seed @ inicializa o gerador de números aleatórios 2'000 (timer :) eu que fiz gostou?)
	@atualiza a tela com todos os leds desligados :
	bl configurar_double_buffer
   	mov r0, #0
   	bl ligar_leds

    
	BL gera_sequencia @ retorno em r0
	LDR r6, =sequencia
	MOV r6, r0 @ endereço da seq
	MOV r7, #0 @itereador loop, rodada atual
	
loop:
	MOV r0, r6
	MOV r1, r7
	BL mostra_sequencia

	MOV r0, r6
	MOV r1, r7
	BL valida_entrada

	ADD r7,r7, #1 @iterador ++
	CMP r7, #10 @se n for igual a 10 o loop continua
	BNE loop
fim:
	B fim

@ r0: sequencia, r1: i_atual
valida_entrada:
	@valida sequencia até a rodada atual
	PUSH {r4-r7, lr} @apenas os reg que vão ser alterados
	MOV r4, #0
	
	MOV r6, r0
	MOV r7, r1 

valida_entrada_loop:

	CMP r4, r7
	BGT valida_entrada_fim

	BL le_botao_pressionado

	CMP r0, #0
	BEQ valida_entrada_loop 

	LDR r5, [r6, r4, LSL #2] @r5 guarda valor seq

	@Compara valor do botão com o da sequencia
	CMP r0, r5
	BNE game_over @se nao forem iguais
	
	ADD r4, r4, #1
	B valida_entrada_loop

valida_entrada_fim:
	@retorna para a main:
	POP {r4-r7, lr}
	BX lr

mostra_sequencia:
	PUSH {r4-r7, lr}
	MOV r4, #0
	
	MOV r6, r0
	MOV r7, r1

mostra_sequencia_loop:
	CMP r4, r7
	BGT mostra_sequencia_fim
	
	LDR r5, [r6, r4, LSL #2] @pega valor na posição
	MOV r0, r5 @argumento para ligar_led
	BL ligar_leds
	BL delay  @ implementar função para dar tempo da cor na tela
	mov r0, #0
	BL ligar_leds @desliga led antes de mostrar a outra cor
	
	@controle loop:
	ADD r4, r4, #1
	B mostra_sequencia_loop

mostra_sequencia_fim:

	@retorna para a main:
	POP {r4-r7, lr}
	BX lr



le_botao_pressionado:
    PUSH {r4-r11, lr}

    le_botao_pressionado_loop:
    @ Lê o estado físico dos botões
    BL le_botao             @ Retorna o valor lido em r0
    MOV r4, r0              @ Salva o valor lido em r4 para não perder

    @ Verifica se houve mudança (se o usuário apertou ou soltou algo)
    MOV r0, r4              @ Passa o valor lido como argumento para r0
    BL detecta_mudanca      @ Retorna 1 em r0 se houve mudança, 0 se não

	CMP r0, #0
    BEQ le_botao_pressionado_loop        @ Se não mudou nada, continua lendo (polling)


	mov r6, r4

    @ Se mudou, verifica se o que está pressionado é VÁLIDO (apenas 1 botão)
    MOV r0, r4              @ Passa o valor atual para validação
    BL valida_botao         @ Retorna 1 em r0 se apenas um botão estiver ativo

    CMP r0, #-1
    BEQ game_over           @ Se r0 for -1 (2+ botões pressionados), game over

    mov r0, r6
    bl ligar_leds

	mov r0, r6
    POP {r4-r11, lr}
    bx lr

le_botao:
    PUSH {r4-r11, lr}

    LDR r0, =END_BOTOES
    LDR r0, [r0]            @ Lê o valor atual dos botões

    POP {r4-r11, lr}        @ Retorna o valor lido em r0
    bx lr

detecta_mudanca:
    PUSH {r4-r11, lr}

    MOV r4, r0              @ r4 = estado atual
    LDR r5, =estado_anterior
    LDR r6, [r5]            @ r6 = estado anterior

    CMP r4, r6
    BEQ sem_mudanca           @ Se atual == anterior, não houve mudança

    STR r4, [r5]            @ Se mudou, atualiza o estado anterior para a próxima vez
    MOV r0, #1              @ Retorna 1 (houve mudança)

    POP {r4-r11, lr}
    bx lr

    sem_mudanca:
	MOV r0, #0              @ Retorna 0 (sem mudança)
	POP {r4-r11, lr}
	bx lr

valida_botao:
    PUSH {r4-r11, lr}

	MOV r4, r0              @ r4 = valor lido dos botões
    MOV r0, #-1              @ Assume que é inválido por padrão

    CMP r4, #0
    MOVEQ r0, #0
    BEQ valida_botao_fim

    CMP r4, #0x01
    MOVEQ r0, #1            @ Botão 0 pressionado sozinho

    CMPNE r4, #0x02
    MOVEQ r0, #1            @ Botão 1 pressionado sozinho

    CMPNE r4, #0x04
    MOVEQ r0, #1            @ Botão 2 pressionado sozinho

    CMPNE r4, #0x08
    MOVEQ r0, #1            @ Botão 3 pressionado sozinho


    valida_botao_fim:
    POP {r4-r11, lr}
    bx lr

game_over:
    mov r0, #0
    bl ligar_leds
    mov r0, #0b1111
    bl ligar_leds

    mov r0, #0
    bl ligar_leds
    mov r0, #0b1111
    bl ligar_leds

    mov r0, #0
    bl ligar_leds
    mov r0, #0b1111
    bl ligar_leds

    B .


/* r0: x, r1: y, r2: cor */
paint_pixel:
  push {r4-r6, lr}

  /*
    calculando posição do pixel no frame buffer
    r4 = FRAME_BUFFER + (y * 1024) + (x * 2)
  */
  ldr r4, =current_buffer
  ldr r4, [r4]

  mov r5, r1
  lsl r5, r5, #10         /* r5 = y * 1024 */
  add r4, r4, r5          /* r4 += r5 */

  mov r5, r0
  lsl r5, r5, #1          /* r5 = x * 2 */
  add r4, r4, r5          /* r4 += r5 */

  strh r2, [r4]           /* *r4 = cor */

  pop {r4-r6, lr}
  bx lr

/*
    pinta o pixel se ele estiver dentro do range
    r0: x, r1: y, r2: cor, r3: start, r4: end,
*/
paint_pixel_in:
    push {r4-r6, lr}

    cmp r0, r3
    blt paint_pixel_in_skip
    cmp r0, r4
    bgt paint_pixel_in_skip

    bl paint_pixel
    mov r0, #1
    b paint_pixel_in_return

    paint_pixel_in_skip:
    mov r0, #0
    paint_pixel_in_return:
    pop {r4-r6, lr}
    bx lr

/*
    troca o front com o back e atualiza o current_buffer
*/
swap_buffers:
    push {r4-r11, lr}

    ldr r4, =PIXEL_BUF_CTRL

    mov r5, #1
    str r5, [r4]

    /* espera o vsync antes de trocar */
    swap_buffers_espera:
    ldr r5, [r4, #12]
    tst r5, #1
    bne swap_buffers_espera

    /* troca o front com o back e atualiza o current_buffer */
    ldr r4, =current_buffer
    ldr r5, [r4]

    ldr r0, =BACK_BUFFER
    cmp r5, r0

    ldreq r5, =FRONT_BUFFER
    ldrne r5, =BACK_BUFFER

    str r5, [r4]
    pop {r4-r11, lr}
    bx lr

/*
    liga os leds na posição especificada pelos bits.
    r0: bits

    verde -> bit 3
    vermelho -> bit 2
    azul -> bit 1
    amarelo -> bit 0

    para ligar mais de um led, é só passar mais de um bit ativo (1) em r0
*/
ligar_leds:
    push {r4-r11, lr}

    mov r9, r0

    /* r1: y */
    mov r1, #0

    /* a tela tem  320x240 pixels */
    ligar_leds_y_loop:
    cmp r1, #240
    beq ligar_leds_return

    /* r0: x */
    mov r0, #0
    ligar_leds_x_loop:
    cmp r0, #320
    beq ligar_leds_next_row


    cmp r1, #30
    blt ligar_leds_black
    cmp r1, #210
    bgt ligar_leds_black

    /*
        pinta a cor dependendo da coordenada (verde, vermelho, azul, amarelo)
        os retângulos serão centralizados espaçados com 12 pixels, então 65 pixels por retângulo.

        TST testa se o bit está ligado ou não
    */
    mov r7, r0
    tst r9, #(1<<3)
    ldreq r2, =VERDE_OFF
    ldrne r2, =VERDE_ON
    mov r3, #12
    mov r4, #77
    bl paint_pixel_in
    cmp r0, #1
    mov r0, r7
    beq ligar_leds_skip

    mov r7, r0
    tst r9, #(1<<2)
    ldreq r2, =VERMELHO_OFF
    ldrne r2, =VERMELHO_ON
    mov r3, #89
    mov r4, #154
    bl paint_pixel_in
    cmp r0, #1
    mov r0, r7
    beq ligar_leds_skip

    mov r7, r0
    tst r9, #(1<<1)
    ldreq r2, =AZUL_OFF
    ldrne r2, =AZUL_ON
    mov r3, #166
    mov r4, #231
    bl paint_pixel_in
    cmp r0, #1
    mov r0, r7
    beq ligar_leds_skip

    mov r7, r0
    tst r9, #(1<<0)
    ldreq r2, =AMARELO_OFF
    ldrne r2, =AMARELO_ON
    mov r3, #243
    mov r4, #308
    bl paint_pixel_in
    cmp r0, #1
    mov r0, r7
    beq ligar_leds_skip


    ligar_leds_black:
    ldr r2, =PRETO
    bl paint_pixel

    ligar_leds_skip:

    /* x += 1 */
    add r0, r0, #1
    b ligar_leds_x_loop

    ligar_leds_next_row:
    /* y += 1 */
    add r1, r1, #1
    b ligar_leds_y_loop

    ligar_leds_return:

    bl swap_buffers

    pop {r4-r11, lr}
    bx lr


configurar_double_buffer:
    ldr r0, =PIXEL_BUF_CTRL

    ldr r1, =FRONT_BUFFER
    str r1, [r0, #4]

    mov r1, #1
    str r1, [r0]

    configurar_double_buffer_espera:
    ldr r1, [r0, #12]
    tst r1, #1
    bne configurar_double_buffer_espera

    ldr r1, =BACK_BUFFER
    str r1, [r0, #4]

    bx lr


seed:
    PUSH {r4-r11, lr}
    LDR r0, =ENDERECO_TIMER2
    MOV r1, #0xFFFF
    STR r1, [r0, #8]
    STR r1, [r0, #12]

    MOV r1, #6 
    STR r1, [r0, #4]

    POP {r4-r11, lr}
    BX lr 

gera_sequencia:
    PUSH {r4-r11, lr}

    LDR r4, =sequencia
    MOV r5, #0
    
    gerar_sequencia_loop:
        BL gerar_numero
        STR r0, [r4, r5, LSL #2] @ armazena o número gerado na sequência
        ADD r5, r5, #1
        CMP r5, #10
        BLT gerar_sequencia_loop

    LDR r0, =sequencia @ retorna o endereço da sequência gerada

    POP {r4-r11, lr}
    BX lr 
        

@ Retorna um número aleatório em R0 (valores entre 1 e 4 para os botões)
gerar_numero:
    PUSH {r4-r11, lr}

    LDR r4, =ENDERECO_TIMER2
    
    gerar_numero_loop:
    MOV r5, #0
    STR r5, [r4, #16]       @ captura snapshot

    LDRH r6, [r4, #16]      @ low
    LDRH r7, [r4, #20]      @ high

    ORR r0, r6, r7, LSL #16 @ junta high e low para formar o número completo

    EOR r0, r0, r0, LSL #13
    EOR r0, r0, r0, LSR #17
    EOR r0, r0, r0, LSL #5

    AND r0, r0, #3            @ limita o numero entre0 e 3
    LDR r8, =ultimo_valor_gerado
    LDR r9, [r8] @ r9 = último valor gerado

    CMP r0, r9 @ se o número gerado for igual ao último, gera outro
    BEQ gerar_numero_loop 

	MOV r9, #1
	LSL r0, r9, r0
    STR r0, [r8]

    POP {r4-r11, lr}
    BX lr

delay:
	PUSH {r4-r6, lr} @ salva o estado da pilha antes de iniciar o loop de espera
	LDR r4, =ENDERECO_TIMER @ r4 é o endereço do timer
	LDR r5, =TEMPO_DELAY 
	STR r5, [r4] @ Carrega em r4 o valor de r5 (r4 é o endereço do timer)
	
	MOV r6, #0x0000C701 @carrega valor para habilitar timer e  setar o prescaler
	STR r6, [r4, #8] @ copia para o endereço para habilitar o timer
	
    espera:
        LDR r1, [r4, #12]  @ Le a flag de interrupção
        TST r1, #1
        BEQ espera

    MOV r1, #1
    STR r1, [r4, #12]  @ limpa flag

	POP {r4-r6, lr} @ recebe a referencia novamente
	BX lr
	
