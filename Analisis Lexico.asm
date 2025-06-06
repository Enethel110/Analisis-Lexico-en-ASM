TITLE PRACTICA6_ANALISIS_LEXICO     
ORG 0100H

; SEGMENTO DE DATOS
.DATA
    ECUACI              DB  32 DUP(0)  ; BUFFER PARA ALMACENAR CARACTERES
    MSGE1               DB  "EXCEDE EL NUMERO DE CARACTERES"; MENSAJES 
    MSGE2               DB  "INGRESE UNA ECUACION ARITMETICA CON DATOS DE 16 BITS CON SIGNO." ;MENSAJE  
    MSGE3               DB  "  1)-MAXIMO 60 CARACTERES."
    MSGE4               DB  "  2)-SOPORTA 5 OPERANDOS y 4 OPERADORES MAXIMO."
    MSGE5               DB  "  3)-INGRESE MAXIMO 5 DIGITOS POR OPERANDO NO MAYOR A 65535."
    MSGE6               DB  "  4)-INGRESE LOS OPERADORES CORECTOS (+,-,*./)."
    MSGE7               DB  "  5)-EL RESULTADO DE LA OPERACION NO DEBE SER MAYOR A 65535.",
    MSGE8               DB  "  6)-EJEMPLO: 5 +3, 1+ 5*2 O 50/2 * 11-500+ 34 O 11111 + 55-89+ 44-6."
    MSGE9               DB  "  -------DEVELOPED BY: CARLOS ENETHEL MENDOZA RESENDIZ------"
    MSGE10              DB  "INGRESE ECUACION: " 
    MSGE11              DB  "EL RESULTADO ES: "
    MSGE12              DB  "ERROR DIVIVION ENTRE CERO."

    
    CONTAR_OPERADORES   DW  0          ; CONTADOR DE OPERADORES GUARDADOS 
    OPERADORES          DB  4 DUP(0)   ; LISTA O VECTOR OPERADORES
    POTENCIA_NUM        DW  0          ; GUARDA EN PONTENCIA EL DIGITO DE ACUERDO A POSICION PARA OBTENER EL NUMERO ENTERO
    NUMEROS             DW  5 DUP(0)   ; LISTA VECTOR DE NUMEROS
                                       
    BANDERA_NEGATIVO    DB  0          ; 1 SI EL NUMERO FUE NEGATIVO
    RESULT_ENTERO       DW  0          ; GUARDAR RESULTADO FINAL  
    RESULT_CHARS        DB  6 DUP('$') ; PARA ALMACENAR LOS DIGITOS COMO TEXTO 
    LIMIT_CARACTERS     DW  61         ; VARIABLE QUE CONTIENE MAXIMO DE CARACTERES        
MSGEND:
 
; SEGMENTO DE CODIGO
.CODE    
; PROCEDIMIENTO PRICIPAÑ DE TAMANO LARGO
MAIN PROC FAR
; -------------------------------------------------------------------------------------------
;           MOSTRAR MENSAJES, LECTURA, ALMACEN, BORRADO Y VALIDACION  DE CARACTERES            ;         ;
; -------------------------------------------------------------------------------------------  
    CALL MENSAJES_PANTALLA
    
    LEA SI, ECUACI
    MOV CX, LIMIT_CARACTERS  ; LIMITE DE CARACTERES
    
; BUCLE DE LECTURA DE TECLAS
LECTURA:  
    DEC CX 
    JZ  EXCEDIO
    MOV AH, 0H
    INT 16H          ; LEER CARACTER DEL TECLADO
     
    CMP AL, 0DH      ; VERIFICAR SI ES ENTER
    JE SEGIR 
    CMP AL, 08H      ; VERIFICAR SI ES BACKSPACE
    JE BORRAR        ; IR A BORRAR CARACTER EN PANTALLA
    CMP AL, ' '
    JE SEGIR         ; SI ES ESPACIO, VA A SEGIR
    CMP AL, '+'
    JE SEGIR         ; SI ES '+', VA A SEGIR
    CMP AL, '-'
    JE SEGIR         ; SI ES '-', VA A SEGIR
    CMP AL, '*'
    JE SEGIR         ; SI ES '*', VA A SEGIR
    CMP AL, '/'
    JE SEGIR         ; SI ES '/', VA A SEGIR
    CMP AL, '0'
    JL CHAR_NO_VALID ; SI ES MENOR A '0', VA A CHAR_NO_VALID
    CMP AL, '9'
    JLE SEGIR        ; SI ESTE ENTRE '0' Y '9', VA A SEGIR
    
    CHAR_NO_VALID:   ; SE INCREMENTAN LOS CARACTERES DISPONIBLES
    INC CX 
    JMP LECTURA      ; SE VA DE NUEVO A LECTURA
    
    SEGIR: 
    MOV [SI], AL     ; MOVEMOS EL CARACTER AL VECTOR DE ECUACION EN LA POSICION SI
    INC SI           ; INCREMENTAMOS SI
    CMP AL, 0DH      ; VERIFICAR SI ES ENTER
    JE FINCAD        ; SI LO ES VAMOS A FIN DE CADENA
    MOV AH, 0EH
    INT 10H          ; MOSTRAR EL CARACTER EN LA PANTALLA
    CMP AL, 08H      ; VERIFICAR SI ES BACKSPACE
    JNE LECTURA
   
; PROCESO DE BORRAR CARACTERES
BORRAR:
    MOV BX,LIMIT_CARACTERS
    DEC BX 
    CMP CX,BX
    JNE  SEGUIR_PROC
    INC CX 
    MOV DL, 22       ; POSICION X DE LA PANTALLA
    MOV DH, 10       ; POSICION Y DE LA PANTALLA
    CALL POSICIONAR_CURSOR
    JMP LECTURA   
    
    SEGUIR_PROC:
    MOV AH, 0EH
    INT 10H          ; MOSTRAR EL CARACTER EN LA PANTALLA
    DEC SI           ; DECREMENTAMOS LA POSI SI
    INC CX 
    INC CX 
    PUSH CX 
    MOV AH, 0EH
    MOV AL, 20H
    INT 10H 

    MOV AH, 03H       ; FUNCION 0X03: OBTENER LA POSICIÓN DEL CURSOR
    MOV BH, 0         ; PAGINA DE PANTALLA (0 PARA LA PRIMERA PAGINA)
    INT 10H           ; LLAMAR A LA INTERRUPCION 0X10

    MOV AH, 02H
    SUB DL,  1
    INT 10H      
    
    POP CX
    JMP LECTURA
FINCAD: 
    MOV AH, 0EH
    MOV AL, 0AH
    INT 10H           ; SALTO DE LINEA
    MOV AL, 0DH
    INT 10H           ; RETORNO DE CARRO
    
    CALL VALI_CACARACTERES 
    CALL EVALUAR_EXPRESION 
    MOV BL, BANDERA_NEGATIVO ; CARGAMOS EL VALOR DE 'RESULT' EN AX
    CMP BL, -1               ; COMPARAMOS CON -1
    JE  FINPRO               ; SI ES IGUAL, SALTA A FINPRO
    CALL IMPRIMIR_RESULTADO 
    
  FINPRO:  
    MOV AH, 0         ; FINALIZAR PROGRAMA
    INT 20H

; SI EL NUMERO DE CARACTERES EXCEDE, MUESTRA EL MENSAJE DE ERROR
EXCEDIO:                    
    MOV AL, 1
    MOV BH, 0
    MOV BL, 0BH       ; COLOR DE TEXTO
    MOV CX, MSGE2 - MSGE1 
    MOV DL, 17        ; POSICION X DE LA PANTALLA
    MOV DH, 18        ; POSICION Y DE LA PANTALLA
    MOV BP, OFFSET MSGE1
    MOV AH, 13H
    INT 10H 
    JMP FINPRO  
; ---------------------------------------------------------------------
;            IMPRIMIR MENSAJES EN PANTALLA                             ;
; ---------------------------------------------------------------------    
MENSAJES_PANTALLA PROC
    MOV AL, 1
    MOV BH, 0
    MOV BL, 00001110B   
    MOV CX, MSGE3 - MSGE2 
    MOV DL, 0
    MOV DH, 0 
    MOV BP, OFFSET MSGE2
    MOV AH, 13H
    INT 10H     
    MOV BL, 00001010B   
    MOV CX, MSGE4 - MSGE3 
    MOV DH, 1
    MOV DL, 5
    MOV BP, OFFSET MSGE3
    MOV AH, 13H
    INT 10H
    MOV CX, MSGE5 - MSGE4 
    MOV DH, 2
    MOV BP, OFFSET MSGE4
    MOV AH, 13H
    INT 10H 
    MOV CX, MSGE6 - MSGE5 
    MOV DH, 3
    MOV BP, OFFSET MSGE5
    MOV AH, 13H
    INT 10H  
    MOV CX, MSGE7 - MSGE6 
    MOV DH, 4
    MOV BP, OFFSET MSGE6
    MOV AH, 13H
    INT 10H
    MOV CX, MSGE8 - MSGE7
    MOV DH, 5
    MOV BP, OFFSET MSGE7
    MOV AH, 13H
    INT 10H
    MOV CX, MSGE9 - MSGE8
    MOV DH, 6
    MOV BP, OFFSET MSGE8
    MOV AH, 13H
    INT 10H  
    MOV BL, 07H 
    MOV CX, MSGE10 - MSGE9 
    MOV DH, 23
    MOV DL, 10
    MOV BP, OFFSET MSGE9
    MOV AH, 13H
    INT 10H  
    MOV BL, 09H 
    MOV CX, MSGE11 - MSGE10
    MOV DH, 10
    MOV DL, 4
    MOV BP, OFFSET MSGE10
    MOV AH, 13H
    INT 10H   
    MOV BL, 0CH 
    MOV CX, MSGE12 - MSGE11
    MOV DH, 12
    MOV DL, 4
    MOV BP, OFFSET MSGE11
    MOV AH, 13H
    INT 10H  
    
    MOV DL, 22       ; POSICION X DE LA PANTALLA
    MOV DH, 10       ; POSICION Y DE LA PANTALLA
    CALL POSICIONAR_CURSOR
    RET
 ENDP 
; ----------------------------------------------------------------------
;           POSICIONAR EN X,Y EL CURSOR PARA IMPRIMIR MENSAJES          ;
; ---------------------------------------------------------------------- 
 POSICIONAR_CURSOR PROC
    MOV AH, 02H
    MOV BH, 0
    INT 10H
    RET  
 ENDP    
 
; -------------------------------------------------------------------------------
;                      LEER VARIABLE ECUACION VALIDAR OPERADORES Y OPERANDOS     ;                  ;
; -------------------------------------------------------------------------------
VALI_CACARACTERES PROC
        MOV POTENCIA_NUM, 0
        LEA SI, ECUACI ; CARGAR LA DIRECCION DE LA CADENA ECUACION EN SI   
    LEER:
        MOV AL, [SI]   ; CARGAR EL CARACTER ACTUAL DE ECUACI EN AL
        INC SI         ; AVANZAR AL SIGUIENTE CARACTER
    
        ; VERIFICAR SI ES EL FIN DE LA CADENA (SI EL CARACTER ES NULL)
        CMP AL, 0DH    ; SI AL ES 0 (FIN DE CADENA)
        JE FIN_CA      ; SI ES FIN DE CADENA, SALIR DEL CICLO
    
        ; VERIFICAR SI AL ES UN NIMERO (CARACTER '0' A '9')
        CMP AL, '0'
        JL NO_NUMERO   ; SI EL CARACTER ES MENOR QUE '0', NO ES NUMERO
        CMP AL, '9'
        JG NO_NUMERO   ; SI EL CARACTER ES MAYOR QUE '9', NO ES NUMERO
    
        SUB AL, '0'    ; CONVETIMOS A NUMERO EL CARACTER ASCII
       
        MOV BL, AL     ; CARGAR EL NUMERO (1..5)
        MOV BH, 0      ; LIMPIAR PARTE ALTA DEL REGISTRO BX
        XOR AX, AX     ; AX = 0
        CALL CONVER_A_NUM
        
        JMP LEER       ; CONTINUAR CON EL SIGUIENTE CARACTER
    
    NO_NUMERO:
        CMP AL, ' '     ; COMPARAMOS EL VALOR DE AL CON UN ESPACIO
        JE LEER        ; SI LO ES LEEMOS DE NUEVO
         
        PUSH SI  
        CALL GUARDAR_NUM   
        MOV [POTENCIA_NUM], 0
        CALL SEPARA_OPERADORES
        POP SI
        
        ;SI ENCONTRAMOS UN OPERADOR, LO IGNORAMOS
        JMP LEER
    
    FIN_CA: 
        CALL GUARDAR_NUM   
        MOV [POTENCIA_NUM], 0
        RET      
VALI_CACARACTERES ENDP 

; -----------------------------------------------------------------
;        SEPARAR OPERADORES Y GUARDARLOS EN LISTA O VECTOR         ;
; -----------------------------------------------------------------
SEPARA_OPERADORES PROC
        MOV BX, 0
        MOV BX, [CONTAR_OPERADORES]  ; BL = POSICIÓN ACTUAL
        LEA SI, OPERADORES           ; SI APUNTA AL INICIO DEL BUFFER
                  
        ADD SI, BX                   ; SUMAMOS LA POSICIÓN DEL CONTADOR
        MOV [SI],AL                  ; GUARDAR EL OPERADOR EN LA POSICION CORRECTA
                                     ; AL CONTIENE EL OPERADOR A GUARDAR            
        INC [CONTAR_OPERADORES]      ; INCREMENTAR EL CONTADOR
        RET 
 ENDP
  
; ----------------------------------------------------------------------------
;           CONVERTIR CARACTERES DE NUMEROS '1','2' A NUMERO ENTERO   '12'    ;
; ----------------------------------------------------------------------------
CONVER_A_NUM PROC
    MOV CX, 1         ; CONTADOR DE 5 NUMEROS
CONVERTIR:
    MOV AX,[POTENCIA_NUM]
    MOV DX, AX        ; AX = AX * 10
    MOV AX, 10  
    MUL DX            ; AX = AX * 10 (RESULTADO EN AX)
    MOV [POTENCIA_NUM], AX
    
    ADD AX, BX        ; AX = AX + BL (AGREGAR EL DIGITO)
    MOV [POTENCIA_NUM], AX
    
    LOOP CONVERTIR
  
    FIN:
    RET
CONVER_A_NUM ENDP 

; --------------------------------------------------------------------------
;           GUARDAR NUMEROS ENTEROS EN UN VECTOR O LISTA OPERADORES         ;
; --------------------------------------------------------------------------
GUARDAR_NUM PROC
    ; BX = INDICE DE LA POSICION A GUARDAR (BASADO EN CONTAR_OPERADORES)
    MOV BX, [CONTAR_OPERADORES]
    SHL BX, 1              ; MULTIPLICAMOS POR 2 PORQUE CADA PALABRA (DW) SON 2 BYTES

    ; SI APUNTA AL INICIO DEL ARREGLO NUMEROS
    LEA SI, NUMEROS
    ADD SI, BX             ; CALCULAMOS LA POSICION EXACTA DENTRO DEL ARREGLO

    ; BX = VALOR A GUARDAR (DESDE POTENCIA_NUM)
    MOV BX, [POTENCIA_NUM]
    MOV [SI], BX           ; GUARDAMOS EL VALOR EN LA POSICION CORRECTA

    RET
GUARDAR_NUM ENDP

; ----------------------------------------------------------------------------
;                      EVALUAR EXPRECIONES ANALISIS LEXICO                    ;
; ----------------------------------------------------------------------------
EVALUAR_EXPRESION PROC
    ; ------------------------------------------
    ; PRIMERA PASADA: OPERADORES A BUSCAR: *, /
    ; ------------------------------------------
    XOR SI, SI             ; LIMPIAR SI
    MOV CX, 4              ; MAXIMO 4 OPERADORES

PRIMER_PASO:
    CMP SI, CX
    JAE SEGUNDA_PASO       ; TERMINA LA PRIMERA PASADA

    MOV AL, [OPERADORES + SI]
    CMP AL, '*'
    JE HACER_MUL
    CMP AL, '/'
    JE HACER_DIV
    JMP SALTAR1

HACER_MUL:
    MOV BX, SI
    SHL BX, 1              ; BX = SI * 2 (PORQUE NUMEROS SON DW)

    MOV AX, [NUMEROS + BX]
    MOV DX, [NUMEROS + BX + 2]
    MUL DX                 ; AX * DX ? RESULTADO EN DX:AX (SE ASUME QUE CABE EN AX)
    MOV [NUMEROS + BX], AX

    ; DESPLAZA NUMEROS Y OPERADORES A LA IZQUIERDA DESDE LA POSICIÓN SI
    CALL DESPLAZAR_IZQUIERDA
    DEC CX
    DEC SI
    JMP SALTAR1

HACER_DIV:
    MOV BX, SI
    SHL BX, 1              ; BX = SI * 2
    MOV AX, [NUMEROS + BX]
    MOV DX, [NUMEROS + BX + 2]
    CMP DX, 0
    JE DIVISION_POR_CERO

    XOR DX, DX
    DIV WORD PTR [NUMEROS + BX + 2]   ; AX / [NUMERO]
    MOV [NUMEROS + BX], AX

    ; DESPLAZA NUMEROS Y OPERADORES A LA IZQUIERDA
    CALL DESPLAZAR_IZQUIERDA
    DEC CX
    DEC SI
    JMP SALTAR1

SALTAR1:
    INC SI
    JMP PRIMER_PASO

; -----------------------------------------
; SEGUNDA PASADA: OPERADORES A BUSCAR: +, -
; -----------------------------------------
SEGUNDA_PASO:
    XOR SI, SI
    MOV CX, 4

    MOV AX, [NUMEROS]      ; RESULTADO PARCIAL
    MOV BX, 2              ; DESPLAZAMIENTO PARA EL SIGUIENTE NUMERO

SEGUNDO_BUCLE:
    CMP SI, CX
    JAE GUARDAR_RESULTADO

    MOV DL, [OPERADORES + SI]
    CMP DL, '+'
    JE HACER_SUMA
    CMP DL, '-'
    JE HACER_RESTA
    JMP SIGUIENTE_OP

HACER_SUMA:
    ADD AX, [NUMEROS + BX]
    JMP SIGUIENTE_OP

HACER_RESTA:
    SUB AX, [NUMEROS + BX]
    JMP SIGUIENTE_OP

SIGUIENTE_OP:
    ADD BX, 2              ; SIGUIENTE NUMERO
    INC SI
    JMP SEGUNDO_BUCLE

GUARDAR_RESULTADO:
    MOV [RESULT_ENTERO], AX
    RET

DIVISION_POR_CERO:
    MOV AL, 1
    MOV BH, 0
    MOV BL, 0BH   
    MOV CX, CONTAR_OPERADORES - MSGE12 
    MOV DL, 17        ; POSICION X DE LA PANTALLA
    MOV DH, 18        ; POSICION Y DE LA PANTALLA
    MOV BP, OFFSET MSGE12
    MOV AH, 13H
    INT 10H     
    MOV [BANDERA_NEGATIVO], -1   ; GUARDAMOS -1 COMO ERROR REUTILIZAMOS LA BANDERA NEGATIVO
    RET
EVALUAR_EXPRESION ENDP

; ----------------------------------------------------------------------------
;           DEZPLAZA HACIA LA IZQUIERDA EL RESTO DE LOS ELEMENTOS             ;
; ----------------------------------------------------------------------------
DESPLAZAR_IZQUIERDA PROC
    PUSH CX
    PUSH SI
    PUSH DI
    PUSH BX
    PUSH AX

    MOV DI, SI
    SHL DI, 1                      ; DI = SI * 2 (DESPLAZAMIENTO EN BYTES)
    ADD DI, 2                      ; APUNTA A NUMEROS[SI+1]

BUCLE_DESPLAZAR_NUMEROS:
    MOV AX, [NUMEROS + DI + 2]     ; CARGA EL SIGUIENTE NUMERO (NUMEROS[SI+2])
    MOV [NUMEROS + DI], AX         ; LO MUEVE A LA POSICION ANTERIOR (NUMEROS[SI+1])
    ADD DI, 2
    CMP DI, 8                      ; HASTA EL FINAL (NUMEROS TIENE 5 ELEMENTOS ? 4 DESPLAZAMIENTOS)
    JBE BUCLE_DESPLAZAR_NUMEROS

    MOV DI, SI

BUCLE_DESPLAZAR_OPERADORES:
    MOV AL, [OPERADORES + DI + 1]  ; CARGA EL SIGUIENTE OPERADOR
    MOV [OPERADORES + DI], AL      ; LO MUEVE A LA POSICION ANTERIOR
    INC DI
    CMP DI, 3                      ; HASTA EL FINAL (OPERADORES TIENE 4 ELEMENTOS ? 3 DESPLAZAMIENTOS)
    JBE BUCLE_DESPLAZAR_OPERADORES

    POP AX
    POP BX
    POP DI
    POP SI
    POP CX
    RET
DESPLAZAR_IZQUIERDA ENDP 

; ----------------------------------------------------------------------------
;           IMPRIME EL RESULTADO FINAL DE LA OPERACION EN PANTALLA            ;
; ----------------------------------------------------------------------------
IMPRIMIR_RESULTADO PROC  
    ; VERIFICAR SI ES NEGATIVO
    CMP AX, 0
    JL ES_NEGATIVO

    ; SI ES POSITIVO O CERO, CONTINUAR
    JMP CONVERTIRNUM

ES_NEGATIVO:
    NEG AX                     ; CONVERTIMOS A VALOR ABSOLUTO
    MOV BANDERA_NEGATIVO, 1    ; MARCAMOS QUE FUE NEGATIVO

CONVERTIRNUM:
    MOV CX, 0
    LEA SI, RESULT_CHARS+5     ; EMPEZAMOS A LLENAR DESDE EL FINAL DEL BUFFER

CONVERTIR_LOOP:
    XOR DX, DX
    MOV BX, 10
    DIV BX                     ; AX / 10 ? AX=RESULTADO, DX=RESIDUO

    ADD DL, '0'                ; CONVERTIMOS RESIDUO (DIGITO) A ASCII
    DEC SI
    MOV [SI], DL               ; GUARDAMOS EL DIGITO EN BUFFER
    INC CX
    CMP AX, 0  
    JNE CONVERTIR_LOOP

    ; MOSTRAR SIGNO SOLO SI FUE NEGATIVO
    CMP BANDERA_NEGATIVO, 1
    JNE IMPRIMIR_DIGITOS
      
    ;POSICIONAMOS 
    MOV AH, 02H        ; FUNCION PARA MOVER EL CURSOR
    MOV BH, 0          ; PAGINA DE VIDEO  0
    MOV DL, 22         ; COLUMNA (X) DONDE COLOCAR EL CURSOR (0-79)
    MOV DH, 12         ; FILA (Y) DONDE COLOCAR EL CURSOR (0-24)
    INT 10H

    MOV AH, 09H        ; FUNCION PARA ESCRIBIR CARACTER CON ATRIBUTO
    MOV AL, '-'        ; EL CARACTER A IMPRIMIR
    MOV BH, 0          ; PAGINA DE VIDEO
    MOV BL, 0EH        ; AMARILLO SOBRE FONDO NEGRO
    MOV CX, 1          ; NUMERO DE VECES QUE SE IMPRIMIRA
    INT 10H


IMPRIMIR_DIGITOS:
   
MOSTRAR_LOOP:
    MOV BL, 0EH
    MOV DL, 23         ; POSICION X DE LA PANTALLA
    MOV DH, 12         ; POSICION Y DE LA PANTALLA
    CALL IMPRIMIR_TEXTO_COLOR
    LOOP MOSTRAR_LOOP
    RET  
ENDP     

; ---------------------------------------------------------------------
;            PROCEDIMIENTO PARA IMPRIMIR CARACTERES EN PANTALLA        ;
; ---------------------------------------------------------------------    
 IMPRIMIR_TEXTO_COLOR PROC
    SIG_CARACTER:
        LODSB
        CMP AL, '$'
        JE FINALIZADO
    
        CALL POSICIONAR_CURSOR   ; MOVER CURSOR A LA POSICIÓN ACTUAL
    
        ; IMPRIMIR EL CARACTER CON COLOR
        MOV AH, 09H
        MOV BH, 0
        MOV CX, 1
        INT 10H
    
        INC DL                   ; AVANZAR COLUMNA
        JMP SIG_CARACTER
    
    FINALIZADO:
        RET
 ENDP  

END MAIN
