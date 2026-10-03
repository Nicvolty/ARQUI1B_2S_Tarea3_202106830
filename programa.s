.data
    msg_arreglo_desordenado:   // declaracion del mensaje de arreglo desordenado
        .ascii "------Arreglo Desordenado----\n"
        msg_arreglo_desordenado_len = . - msg_arreglo_desordenado

    msg_arreglo_ordenado:   // declaracion del mensaje de arreglo ordenado
        .ascii "------Arreglo Ordenado----\n"
        msg_arreglo_ordenado_len = . - msg_arreglo_ordenado

    msg_delimitador:  // declaracion del delimitador para separar la estructura del mensaje y resultado que se imprimio        
        .ascii "-----------------------------\n"
        msg_delimitador_len = . - msg_delimitador

    arreglo:
        .quad 500,32,45,22,10,105,255,63,8,9 // declaracion del arreglo de 10 elementos
    tamanio:
        .word 10 //establecemos el tamaño

    msg_pos_prefix:
        .ascii "Posicion "
        msg_pos_prefix_len = . - msg_pos_prefix

    msg_pos_separador:
        .ascii " : "
        msg_pos_separador_len = . - msg_pos_separador

    msg_newline:
        .ascii "\n"
        msg_newline_len = . - msg_newline

    .align 3
    // Buffer para construir la linea completa posicion 1 : 500\n
    buffer_linea:
        .space 64          

/*.section .rodata    
    msg_posicion: // declaracion del mensaje para ir mostrando la posicion del elemento
        .ascii "Posicion %d : %d\n"
        msg_posicion_len = . - msg_posicion   
*/

//.include "selectionSort.s"

.text
.global _start

.include "itoa.s"
.include "bubbleSort.s"

_start:
    adr x1, msg_arreglo_desordenado  //cargamos la direccion del  mensaje en x1
    mov x2, msg_arreglo_desordenado_len // cargamos el tamaño del mensaje en x2
    bl print // llamamos a la etiqueta print

    bl imprimir_arreglo

    adr x1, msg_delimitador // cargamos la direccion del mensaje delimitador en x1
    mov x2, msg_delimitador_len // tamaño del mensaje delimitador en x2
    bl print

    // x21 ya lleva la direccion del arreglo
    adr x21, arreglo
    adr x19, tamanio
    ldr w19, [x19] // cargamos de nuevo w19 ya que en imprimir_arreglo se hizo 0 
    bl bubbleStart
    // agregamos salto de linea para imprimir el arreglo ordenado
    adr x1, msg_newline
    mov x2, msg_newline_len
    bl print

    //imprimir arreglo ordenado
    adr x1, msg_arreglo_ordenado  //cargamos la direccion del  mensaje en x1
    mov x2, msg_arreglo_ordenado_len // cargamos el tamaño del mensaje en x2
    bl print // llamamos a la etiqueta print

    bl imprimir_arreglo

    adr x1, msg_delimitador // cargamos la direccion del mensaje delimitador en x1
    mov x2, msg_delimitador_len // tamaño del mensaje delimitador en x2
    bl print
    
    b exit

imprimir_arreglo:
   // Guardamos la dirección de retorno (x30) y registros en la pila
    stp x29, x30, [sp, #-16]!
    //imprimir el arreglo
    adr x19, tamanio
    ldr w19, [x19] // tamaño del arreglo guardado en w19 o x19
    mov x20, #0 // desplazador para ir iterando entre cada numero del arreglo
    mov x22, #0 // indice de la posicion para el mensaje posicion n : numero \n
    adr x21, arreglo   //cargar direccion de arreglo en x21

loop_arreglo:
    //logica del loop
    cbz w19, fin_loop  //verificar si ya se recorrio todo el arreglo

    // copiar "Posicion " en buffer_linea
    adr x0, buffer_linea        // Destino en buffer
    adr x1, msg_pos_prefix      // Origen del texto
    mov x2, msg_pos_prefix_len  // Longitud (9 bytes)
    // copiar texto recibe x1 (origen) y x2(tamaño) 
    // copiar texto retorna en x0 lo copiado
    bl copiar_texto             // x0 queda al final de lo copiado

    //convertir indice x22 a ascii y agregarlo al buffer_linea
    mov x23, x0                 // Guardamos la posición inicial donde estamos
    add x1, x0, #8              
    mov x0, x22                 // Número a convertir = índice actual
    bl itoa                     // Retorna x1 = inicio del índice en ASCII, x2 = largo

    // Copiamos los dígitos del índice al destino final de la línea
    mov x0, x23
    bl copiar_texto             // Copia el índice convertido

    // copiar separador ":" en buffer_linea
    adr x1, msg_pos_separador
    mov x2, msg_pos_separador_len
    bl copiar_texto

    // Convertir y copiar el numero del arreglo
    mov x23, x0                 // Guardar posición actual
    add x1, x0, #16             // Dar 16 bytes a itoa para escribir hacia atrás
    ldr x0, [x21, x20]          // Cargar el número real del arreglo 
    bl itoa                     // x1 = inicio del número, x2 = largo dígitos

    mov x0, x23                 // Restaurar posición de destino
    bl copiar_texto             // Copiar los dígitos del número

    // Copiar el SALTO DE LÍNEA "\n" 
    adr x1, msg_newline
    mov x2, msg_newline_len
    bl copiar_texto
    
    // IMPRIMIR LA LÍNEA COMPLETA CON PRINT
    adr x1, buffer_linea        // Inicio de la cadena armada
    sub x2, x0, x1              // Largo total = Puntero final (x0) - Puntero inicial (x1)
    bl print

    add x20, x20, #8            //sumamos 8 que son los bytes que nos desplazamos entre cada elemento del arreglo
    add x22, x22, #1            // Siguiente posición (0 -> 1 -> 2...)
    sub w19, w19, #1            //restamos uno al tamaño para saber cuando llegamos a 0 y ya se itero todos los elementos
    b loop_arreglo

fin_loop:
    // restaurar registros y regresar
    ldp x29, x30 , [sp], #16 
    ret

print:
    // write (stdout, direccion, tamaño) = (x0,x1,x2)
    // x1 = direccion de lo que se va a imprimir
    // x2 = tamaño de lo que se va a imprimir
    mov x0, #1 
    mov x8, #64 //syscall de escritura 
    svc 0 //ejecutamos la syscall
    ret //regresamos a donde fue llamada   

copiar_texto:
    // x1 = direccion origen de donde copia el texto
    // x0 = direccion destino donde se copiara el texto
    // x2 = tamaño del origen
    cbz x2, fin_copiar  // verificar si x2 es cero y ya se copio toda la cadena en x0
loop_copiar:
    ldrb w3, [x1], #1   // Lee 1 byte de x1 e incrementa x1
    strb w3, [x0], #1   // Escribe 1 byte en x0 e incrementa x0
    subs x2, x2, #1
    b.ne loop_copiar
fin_copiar:
    ret

exit:
    //terminar ejecucion
    mov x0, #0
    mov x8 , #93
    svc #0    