/*
 * "Hello World" example.
 *
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example
 * designs. It runs with or without the MicroC/OS-II RTOS and requires a STDOUT
 * device in your system's hardware.
 * The memory footprint of this hosted application is ~69 kbytes by default
 * using the standard reference design.
 *
 * For a reduced footprint version of this template, and an explanation of how
 * to reduce the memory footprint for a given application, see the
 * "small_hello_world" template.
 *
 * 
 * "Hello_world" is a template used to create a new application
 * Control of RGB LEDs with custom slave programmable interface
 *	autors: Guillaume MELAS; Maxence Vouaillat
 */

#include <stdio.h>
#include <inttypes.h>
#include "system.h"
#include "io.h"
#include "frame.h"



int main()
{
	volatile uint32_t cnt = 0;
	char* filename = "/mnt/host/image.ppm"
	FILE *foutput = fopen(filename, "w");
	
	if (!foutput) {
		printf("Error: could not open \"%s\" for writing\n", filename);
		return false;
	}

	/* Use fprintf function to write to file through file pointer */
	
	fprintf(foutput, "");		// clear file

	fclose(foutput);

	



	FILE *foutput2 = fopen(filename, "a");
	
	if (!foutput2) {
		printf("Error: could not open \"%s\" for writing\n", filename);
		return false;
	}

	/* Use fprintf function to write to file through file pointer */
	for(cnt = 0 ; cnt < frameREDsize ; cnt++)
	{

		fprintf(foutput2, frameRED[cnt]);		// clear file

	}	
	
	fclose(foutput2);

	while(1);
	 
	return 0;
}
