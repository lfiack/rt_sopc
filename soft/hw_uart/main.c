#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>

#include <serial/cprintf/cprintf.h>
#include <serial/uart/uart.h>

#include <hardware/omsp_system/omsp_system.h>

//--------------------------------------------------//
// Main function with init an an endless loop that  //
// is synced with the interrupts trough the         //
// lowpower mode.                                   //
//--------------------------------------------------//
int main(void) {
    int reading = 0;
    int pos = 0;
    char buf[40];
    int led = 0;

    WDTCTL = WDTPW | WDTHOLD;           // Init watchdog timer

    P3DIR  = 0xff;
    P3OUT  = 0xff;                      // Light LED during init

	P1DIR = 0x00;

	uart_init(115200);

	while ((P1IN & 0x01) == 0);

    P3OUT  = 0x00;                      // Switch off LED

    cprintf("\r\n====== openMSP430 in action ======\r\n");   //say hello
    cprintf("\r\nSimple Line Editor Ready\r\n");
	cprintf("\r\nBAUD=%d\r\n", (CPU_FREQ_HZ/115200)-1);

    eint();                             // Enable interrupts

    while (1) {                         //main loop, never ends...

        cprintf("> ");                   //show prompt
        reading = 1;
        while (reading) {               //loop and read characters

            LPM0;                       //sync, wakeup by irq

		    led++;                      // Some lighting...
		    if (led==9) {
		      led = 0;
		    }
		    P3OUT = (0x01 << led);

			if (uart_available()) {
				char c = uart_read();
				switch (c) {
					//process RETURN key
					case '\r':
						//case '\n':
						cprintf("\r\n");    //finish line
						buf[pos++] = 0;     //to use cprintf...
						cprintf(":%s\r\n", buf);
						reading = 0;        //exit read loop
						pos = 0;            //reset buffer
						break;
						//backspace
					case '\b':
						if (pos > 0) {      //is there a char to delete?
							pos--;          //remove it in buffer
							cprintf("\b \b");
						}
						break;
						//other characters
					default:
						//only store characters if buffer has space
						if (pos < sizeof(buf)) {
							cprintf("%c", c);     //echo
							buf[pos++] = c; //store
						}
				}
			}
		}
	}
}
