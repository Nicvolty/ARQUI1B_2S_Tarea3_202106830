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

    buffer_salida:
        .quad 0, 10  // buffer para almacenar el numero a imprimir y el un salto de linea   

.section .rodata    
    msg_posicion: // declaracion del mensaje para ir mostrando la posicion del elemento
        .ascii "Posicion %d : %d\n"
        msg_posicion_len = . - msg_posicion   

//.include "bubbleSort.s"
//.include "selectionSort.s"

.text
.global _start

.include "itoa.s"

_start:
    adr x1, msg_arreglo_desordenado  //cargamos la direccion del  mensaje en x1
    mov x2, msg_arreglo_desordenado_len // cargamos el tamaño del mensaje en x2
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
    adr x21, arreglo   //cargar direccion de arreglo en x21

loop_arreglo:
    //logica del loop
    cbz w19, fin_loop  //verificar si ya se recorrio todo el arreglo
    ldr x0, [x21,x20]          // cargar el valor a imprimir desplazandonos por el arreglo los bytes que lleve x20
    adr x1, buffer_salida //cargar direccion de buffer_salida
    add x1, x1, #8 // desplazamos 8 bytes justo en el final de buffer_salida
    // saltamos al logaritmo para hacer un integer a ascii
    bl itoa   
    // x1 y x2 ya traen lo que necesita print
    add x2, x2, #1 // Ajustamos x2 para incluir el '\n' en la impresión
    bl print

    add x20, x20, #8 //sumamos 8 que son los bytes que nos desplazamos entre cada elemento del arreglo
    sub w19, w19, #1 //restamos uno al tamaño para saber cuando llegamos a 0 y ya se itero todos los elementos
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

exit:
    //terminar ejecucion
    mov x0, #0
    mov x8 , #93
    svc #0    