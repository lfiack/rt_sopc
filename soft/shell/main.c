#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>

#include <serial/cprintf/cprintf.h>
#include <serial/uart/uart.h>

#include <hardware/omsp_system/omsp_system.h>
#include <shell/shell/shell.h>

// read uint16 separated by spaces (' ') in a buffer.
// buf is the input buffer
// returns a pointer on the next value to extract.
// the uint16 is stored in the ret pointer.
// ok is 0 in case of an error, else 1
char * read_uint16(uint16_t * ret, char * buf, int * ok) {
	int i = 0;
	int hex = 0;

	*ret = 0;
	*ok = 0;

	while(buf[i] != 0)
	{
		if (buf[i] == 'x')
			hex = 1;
		else if (buf[i] == ' ') {
			*ok = 1;
			return &buf[i+1];
		}
		else {
			if (hex) {
				if (buf[i] >= '0' && buf[i] <= '9') {
					*ret *= 16;
					*ret += (buf[i] - '0');
				}
				else if (buf[i] >= 'a' && buf[i] <= 'f') {
					*ret *= 16;
					*ret += (buf[i] + 10 - 'a');
				}
				else if (buf[i] >= 'A' && buf[i] <= 'F') {
					*ret *= 16;
					*ret += (buf[i] + 10 - 'A');
				}
				else {
					cprintf("%c is not a number\r\n", buf[i]);
					return NULL;
				}
			}
			else {
				if (buf[i] >= '0' && buf[i] <= '9') {
					*ret *= 10;
					*ret += (buf[i] - '0');
				}
				else {
					cprintf("%c is not a number\r\n", buf[i]);
					return NULL;
				}
			}
		}
		i++;
	}

	*ok = 1;
	return NULL;
}

// Write a value in a given register
int sh_register(char * buf) {
	uint16_t reg;
	uint16_t val;
	int ok;

	unsigned int * p;

	if (buf[1] != ' ' || buf[2] == 0) {
		cprintf("correct usage:\r\n");
		cprintf("\t%c REGISTER VALUE\r\n", buf[0]);
		return -1;
	}

	buf = &buf[2];
	buf = read_uint16(&reg, buf, &ok);
	if (ok == 0) {
		cprintf("Something went terribly wrong\r\n");
		return -1;
	}
	buf = read_uint16(&val, buf, &ok);
	if (ok == 0) {
		cprintf("Something went terribly wrong\r\n");
		return -1;
	}

	cprintf("r=%d v=%d\r\n", reg, val);

	p = (unsigned int *)reg;
	*p = val;

	return 0;
}

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
	shell_init();
	shell_add('r', sh_register);

	while ((P1IN & 0x01) == 0);

    P3OUT  = 0x00;                      // Switch off LED

    cprintf("\r\n====== openMSP430 in action ======\r\n");   //say hello
    cprintf("\r\nSimple Line Editor Ready\r\n");
	cprintf("\r\nBAUD=%d\r\n", (CPU_FREQ_MHZ/115200)-1);

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

		shell_exec('r', buf);
	}
}