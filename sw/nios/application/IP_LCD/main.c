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

/* Defines register name associated to address offset 
 *
 */
enum address_mapping{
    regFIFOStatus           = 0x00,
    regLCDControllerCtrl    = 0x04,
    regMemStartAddress      = 0x08,
    regMemBufferLength      = 0x0C,
    regCfgCmd               = 0x10,
    regCfgParam             = 0x14

}; /* address_mapping */





int main()
{
	volatile uint16_t iwait = 0;
	volatile uint32_t IO_regFIFOstatus	    = 0;	
	volatile uint32_t IO_regStartAddress 	= 0;
	volatile uint32_t IO_regBufferLength	= 0;

	IO_regFIFOstatus	= IORD_32DIRECT(/*!MODULE!*/, regFIFOStatus);					/* Read regFIFOStatus */
	IO_regStartAddress 	= IORD_32DIRECT(/*!MODULE!*/, regMemStartAddress);				/* Read regMemStartAddress */
	IO_regBufferLength	= IORD_32DIRECT(/*!MODULE!*/, regMemBufferLength);			/* Read regMemBufferLength */

    //reset timings at the beginning ? 
	// just insert wait loop

	for(i=0 ; i<5000 ; i++);	// hard wait, waiting on reset end for LCD and CAM

    IOWR_32DIRECT(/*!MODULE!*/, regCfgCmd, 0x0011); //Exit Sleep
	IOWR_32DIRECT(/*!MODULE!*/, regCfgCmd, 0x00CF); // Power Control B
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0000); // Always 0x00
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0081); // 
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0X00c0);
	IOWR_32DIRECT(/*!MODULE!*/, regCfgCmd, 0x00ED); // Power on sequence control
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0064); // Soft Start Keep 1 frame
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0003); // 
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0X0012);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0X0081);
	IOWR_32DIRECT(/*!MODULE!*/, regCfgCmd, 0x00E8); // Driver timing control A
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0085);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0001);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0078);	//0x78 or 0x79
	IOWR_32DIRECT(/*!MODULE!*/, regCfgCmd, 0x00CB); // Power control A
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0039);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x002C);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0000);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0034);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0002);
	IOWR_32DIRECT(/*!MODULE!*/, regCfgCmd, 0x00F7); // Pump ratio control
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0020);
	IOWR_32DIRECT(/*!MODULE!*/, regCfgCmd, 0x00EA); // Driver timing control B
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0000);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0000);
	IOWR_32DIRECT(/*!MODULE!*/, regCfgCmd, 0x00B1); // Frame Control (In Normal Mode)
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0000);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x001b);
	IOWR_32DIRECT(/*!MODULE!*/, regCfgCmd, 0x00B6); // Display Function Control 
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x000A);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x00A2);
	IOWR_32DIRECT(/*!MODULE!*/, regCfgCmd, 0x00C0); //Power control 1
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0005); //VRH[5:0]
	IOWR_32DIRECT(/*!MODULE!*/, regCfgCmd, 0x00C1); //Power control 2
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0011); //SAP[2:0];BT[3:0]
	IOWR_32DIRECT(/*!MODULE!*/, regCfgCmd, 0x00C5); //VCM control 1
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0045); //3F
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0045); //3C
	IOWR_32DIRECT(/*!MODULE!*/, regCfgCmd, 0x00C7); //VCM control 2
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0X00a2);
	IOWR_32DIRECT(/*!MODULE!*/, regCfgCmd, 0x0036); // Memory Access Control
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0008);// BGR order
	IOWR_32DIRECT(/*!MODULE!*/, regCfgCmd, 0x00F2); // Enable 3G
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0000); // 3Gamma Function Disable
	IOWR_32DIRECT(/*!MODULE!*/, regCfgCmd, 0x0026); // Gamma Set
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0001); // Gamma curve selected
	IOWR_32DIRECT(/*!MODULE!*/, regCfgCmd, 0x00E0); // Positive Gamma Correction, Set Gamma
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x000F);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0026);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0024);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x000b);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x000E);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0008);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x004b);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0X00a8);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x003b);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x000a);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0014);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0006);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0010);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0009);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0000);
	IOWR_32DIRECT(/*!MODULE!*/, regCfgCmd, 0X00E1); //Negative Gamma Correction, Set Gamma
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0000);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x001c);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0020);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0004);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0010);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0008);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0034);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0047);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0044);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0005);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x000b);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0009);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x002f);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0036);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x000f);
	IOWR_32DIRECT(/*!MODULE!*/, regCfgCmd, 0x002A); // Column Address Set
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0000);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0000);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0000);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x00ef);
	IOWR_32DIRECT(/*!MODULE!*/, regCfgCmd, 0x002B); // Page Address Set 
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0000);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0000);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0001);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x003f);
	IOWR_32DIRECT(/*!MODULE!*/, regCfgCmd, 0x003A); // COLMOD: Pixel Format Set 
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0055);
	IOWR_32DIRECT(/*!MODULE!*/, regCfgCmd, 0x00f6); // Interface Control 
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0001);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0030);
		IOWR_32DIRECT(/*!MODULE!*/, regCfgParam, 0x0000);
	IOWR_32DIRECT(/*!MODULE!*/, regCfgCmd, 0x0029); //display on
	
    
    IOWR_32DIRECT(/*!MODULE!*/, regCfgCmd, 0x002c); // 0x2C Go to write memory 

	while(1);
	 
	return 0;
}
