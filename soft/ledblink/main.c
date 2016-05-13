#include <stdint.h>

#include "omsp_system.h"

static void __inline__ brief_pause(register unsigned int n)
{
	__asm__ __volatile__ (
		"1: \n"
		" dec	%[n] \n"
		" jne	1b \n"
		: [n] "+r"(n)
	);
}

interrupt (TIMERA1_VECTOR) /*enablenested*/ INT_Timer_overflow(void)
{
	static uint8_t blink = 0;
	static uint16_t cnt = 0;

	if (cnt > 30)
	{
		// I'm pretty sure this is self-explanatory
  		P3OUT = P1IN * blink;
  		blink = !blink;
		cnt = 0;
	}
	cnt++;

	// Clear Interrupt
	TACTL &= ~TAIFG;
}

int main(void)
{
	// Port 1 as Input (Switches)
	P1DIR = 0x00;
	// Port 3 as Output (LEDs)
	P3DIR = 0xFF;

	// Disable the Watchdog
	WDTCTL = WDTPW | WDTHOLD;

//	brief_pause(100);

	// Clock source SMCLK (cause why not?) ; Input devider /8 ; Up mode (count from 0 to TACCR0) ; Enable Interrupts
	TACTL |= TASSEL1 | ID1 | ID0 | MC0 | TAIE;
	TACCR0 = 50000;

	// Enable interrupts
	eint();

	while(1);
}
