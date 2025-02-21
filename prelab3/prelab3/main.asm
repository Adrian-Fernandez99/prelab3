/*

prelab3.asm

Created: 2/21/2025 9:42:02 AM
Author : Adrián Fernández

Descripción:
	Se realiza un contador binario de 4 bits
	que se presentan en cuatro leds externas.
	Se deben utilizar interrupciones de tipo
	On-change.
*/
.include "M328PDEF.inc"		// Include definitions specific to ATMega328P

// Definiciones de registro, constantes y variables
.cseg
.org		0x0000
	JMP		START

.org		INT0addr
	JMP		INCREMENTO

.org		INT1addr
	JMP		DECREMENTO

// Configuración de la pila
START:
	LDI		R16, LOW(RAMEND)
	OUT		SPL, R16
	LDI		R16, HIGH(RAMEND)
	OUT		SPH, R16

// Configuración del MCU
SETUP:
	// Desavilitamos interrupciones mientras seteamos todo
	CLI

	// Configurar Prescaler "Principal"
	LDI		R16, (1 << CLKPCE)
	STS		CLKPR, R16		// Habilitar cambio de PRESCALER
	LDI		R16, 0x04
	STS		CLKPR, R16		// Configurar Prescaler a 16 F_cpu = 1MHz

	// Deshabilitar serial (esto apaga los demas LEDs del Arduino)
	LDI		R16, 0x00
	STS		UCSR0B, R16

	// Habilitamos interrupcionees para el INT0 e INT1
	LDI		R16, (1 << INT1) | (1 << INT0)
	OUT		EIMSK, R16

	// Habilitamos interrupcionees para cualquier cambio logico
	LDI		R16, (1 << ISC10) | (1 << ISC00)
	STS		EICRA, R16

	// PORTD como entrada con pull-up habilitado
	LDI		R16, 0x00
	OUT		DDRD, R16		// Setear puerto D como entrada
	LDI		R16, 0xFF
	OUT		PORTD, R16		// Habilitar pull-ups en puerto D

	// Configurar puerto C como una salida
	LDI		R16, 0xFF
	OUT		DDRC, R16		// Setear puerto C como salida

	// Realizar variables
	LDI		R16, 0x00		// Registro del contador
	LDI		R17, 0x00		// Registro de lectura de botones

	// Activamos las interrupciones
	SEI

// Main loop
MAIN_LOOP:
	OUT		PORTC, R16		// Se loopea la salida del puerto
	JMP		MAIN_LOOP

// NON-Interrupt subroutines

// Interrupt routines
INCREMENTO:
	IN		R17, PIND		// Se ingresa la configuración del PIND
	CPI		R17, 0xFB		// Se compara para ver si el botón está presionado
	BRNE	FINAL2			// Si no esta preionado termina la interrupción
	INC		R16				// Si está presionado incrementa
	SBRC	R16, 4			// Si genera overflow reinicia contador
	LDI		R16, 0x00
	FINAL:
	RETI					// Regreso de la interrupción

DECREMENTO:
	IN		R17, PIND		// Se ingresa la configuración del PIND
	CPI		R17, 0xF7		// Se compara para ver si el botón está presionado
	BRNE	FINAL2			// Si no esta preionado termina la interrupción
	DEC		R16				// Si está presionado decrementa
	SBRC	R16, 4			// Si genera underflow reinicia contador
	LDI		R16, 0x0F
	FINAL2: 
	RETI					// Regreso de la interrupción