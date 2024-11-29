.global _start
_start:
	
	// Inicialización de registros
	MOV R1, #0        // R1 contiene el valor Fibonacci actual (F(n-2))
	MOV R2, #1        // R2 contiene el siguiente valor Fibonacci (F(n-1))
	MOV R3, #0        // R3 será nuestro índice de iteración (i)
	MOV R4, R4        // R4 contiene el número objetivo n
	MOV R5, #0        // R5 para el valor temporal de Fibonacci (F(n))
	CMP R4, #0
	BEQ BFUNCT        // Si n == 0, saltar al final (F(0) = 0)

    // IF STATEMENT para casos base n == 1 y n == 2
    CMP R4, #1
    BEQ OUTPUT_R1     // Si n == 1, el resultado es F(1) = 0
    CMP R4, #2
    BEQ OUTPUT_R2     // Si n == 2, el resultado es F(2) = 1

    // Iteración para n > 2
    FOR_LOOP:
        CMP R3, R4    // Comparar índice actual (R3) con n
        BEQ END_LOOP  // Si hemos alcanzado n, salir del bucle

        ADD R5, R1, R2 // Calcular Fibonacci: F(i) = F(i-1) + F(i-2)
        MOV R1, R2     // Actualizar R1: F(i-2) = F(i-1)
        MOV R2, R5     // Actualizar R2: F(i-1) = F(i)
        ADD R3, R3, #1 // Incrementar índice: i = i + 1
        B FOR_LOOP     // Volver al inicio del bucle

// Manejo de resultados
OUTPUT_R1:
    MOV R0, R1    // Guardar resultado en R0 para F(1)
    B BFUNCT

OUTPUT_R2:
    MOV R0, R2    // Guardar resultado en R0 para F(2)
    B BFUNCT

END_LOOP:
    MOV R0, R5    // Guardar resultado en R0 para F(n)

// Finalización
BFUNCT:
    // Aquí puedes manejar la salida o detener el programa
    END