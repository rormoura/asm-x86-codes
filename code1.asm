;AP2
org 0x7C00
bits 16
jmp start

string times 50 db 0 

start:
    xor ax, ax;zerando ax e registradores de segmento
    mov ds, ax
    mov es, ax
    mov ss, ax

    ;Configurando a ivt
    push ds;colocando ds na pilha por prevenção
    mov di, 0x100; 40h vezes 4 = 100h = 256 em decimal
    mov word[di], interruption ;Offset
    mov word[di+2], 0 ;cs pode ser 0

    pop ds ;Devolver ds anterior

    mov di, string;di é usado em stosb
    call gets;função que armazena a string digitada na memória
    push string;colocando o endereço da string na pilha
    int 0x40;chamando a interrupção

end:
    jmp $ ; halt

getchar:
    mov ah, 0x00;função que armazena em al o caractere digitado
    int 16h
    ret

putchar:;coloca o caractere 
    mov ah, 0x0e;teletype output
    int 10h
    ret

endl:;equivalente a '\n'
    mov al, 0x0a;LF char
    call putchar
    mov al, 0x0d;CR char
    call putchar
    ret

delchar:
    mov al, 0x08;backspace
    call putchar
    
    mov al, ''
    call putchar

    mov al, 0x08
    call putchar
    ret

gets:
    xor cx, cx

    .loop1:
        call  getchar
        cmp al, 0x08
        je .backspace
        cmp al, 0x0d;para quando enter é apertado
        je .done
        cmp cl, 50;tamanho máximo
        je .loop1
        stosb
        inc cl
        call putchar
        jmp .loop1

        .backspace:;se backspace foi digitado
            cmp cl, 0
            je .loop1;se cl é zero, chegou no limite esquerdo
            dec di;retornando uma posição
            dec cl
            ;mov byte[di], 0
            call delchar
            jmp .loop1

    .done:
        mov al, 0
        stosb;caractere de sentinela
        call endl
        ret

interruption:
    pusha;empilhando os 8 GPRs, ou seja, 8 * 2 bytes = 16 bytes
    mov bp, sp;usando o bp como ponteiro
    mov si, [bp+22];22 bytes: 2 do FLAGS + 2 do IP + 2 do CS + 16 bytes do pusha
    .loop:
        lodsb
        or al, al;se al = 0, então "or al, al" seta a flag de zero
        jz .done;se zf == 1, jump para .done
        mov ah, 0x0E;teletype output
        int 0x10
        jmp .loop;vai para .loop
    .done:
        popa;desempilhando os 8 GPRs
        iret;interruption return

; assinatura de boot
times 510-($-$$) db 0
dw 0xAA55