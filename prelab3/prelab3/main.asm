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
	JMP		

.org		INT1addr
	JMP		

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

// PORTD como entrada con pull-up habilitado
	LDI		R16, 0x00
	OUT		DDRD, R16		// Setear puerto B como entrada
	LDI		R16, 0xFF
	OUT		PORTD, R16		// Habilitar pull-ups en puerto B

// Configurar puerto C como una salida
	LDI		R16, 0xFF
	OUT		DDRC, R16		// Setear puerto C como salida