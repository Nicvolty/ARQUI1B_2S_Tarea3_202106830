// x21 = direccion del arreglo  w19 = tamaño del arreglo (10 en este caso)

bubbleStart:
    /*bubble sort lleva dos for. entonces
    w22 va a ser el contador i y w23 va a ser el contador j*/
    mov w22, #1  // se empieza en uno para no hacer el "i < tamanio -1" sino solo "i < tamanio"

loop_i:
    cmp w22, w19 // if w22 = 10 se termina el bucle
    b.eq fin_loop_i
    //nos vamos al for interno
    sub w24, w19, w22 // w24 = la comparacion de hasta donde debe iterar j.
    mov w23, #0  // se empieza en uno para no hacer el "j < tamanio - i - 1"  sino solo "j < tamanio - i"
    mov x20, #0 // desplazador de bytes para ir iterando cada elemento del array

loop_j:
    cmp w23, w24
    b.eq fin_loop_j // se termino las iteraciones del for interno
    ldr x0, [x21,x20] // x0 = elemento en index j (ej. lista[j])
    add x2, x20, #8  // x2 = segundo desplazador 8 bytes adelante de x20 para hacer la comparacion de elementos
    ldr x1, [x21, x2] //  x1 = elemento en index j+1 (ej. lista[j+1])
    //comparamos ambos elementos
    cmp x0, x1
    b.gt swap

siguiente_iteracion_loop_j:
    add w23, w23, #1    // j++
    add x20, x20 , #8   // incrementar desplazador   
    b loop_j 

swap:
    str x1, [x21,x20]  //poner x1 en la posicion de x0  ( lista[j] = lista[j+1])
    str x0, [x21,x2]    //poner x0 en la posicion de x1 ( lista[j+1] = lista[j])
    b siguiente_iteracion_loop_j

fin_loop_j:
    add w22, w22, #1    //incrementar w22. i++
    b loop_i

fin_loop_i:
    ret        