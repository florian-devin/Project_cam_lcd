// Main program for Lab4

///////////////////////// INCLUDE
#include <stdio.h>
#include <inttypes.h>
#include "io.h"
#include "system.h"
#include "CamInit.h"
///////////////////////// END INCLUDE


#define START_ADDRESS (HPS_0_BRIDGES_BASE)		// Beginning of data address in memory
#define BUFFER_LENGTH (0X00000200)		// Number of pixels in image set to 48
#define CAM_ADDRESS (0x000EAEEAA)	// Address of the camera


int main()
{
	volatile uint16_t i = 0;
	
	 /* Defines register name associated to address offset
	 *
	 */
	enum address_mapping{
		regFIFOStatus           = 0x00,
		regMemStartAddress      = 0x04,
		regMemBufferLength      = 0x08,
		regCfgCmd               = 0x0C,
		regCfgParam             = 0x10,
		regMemWritten           = 0x14,
		regCAMaddress            = 0x18

    //reset timings at the beginning ?
	// just insert wait loop

	IOWR_32DIRECT(IP_LCD_0_BASE, regMemStartAddress, START_ADDRESS); //Exit Sleep
	IOWR_32DIRECT(IP_LCD_0_BASE, regMemBufferLength, BUFFER_LENGTH); //Exit Sleep
	IOWR_32DIRECT(IP_LCD_0_BASE, regCAMaddress, CAM_ADDRESS);

	for(i=0 ; i<5000 ; i++);	// hard wait, waiting on reset end for LCD and CAM

    IOWR_32DIRECT(IP_LCD_0_BASE, regCfgCmd, 0x0011); //Exit Sleep
	IOWR_32DIRECT(IP_LCD_0_BASE, regCfgCmd, 0x00CF); // Power Control B
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0000); // Always 0x00
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0081); //
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0X00c0);
	IOWR_32DIRECT(IP_LCD_0_BASE, regCfgCmd, 0x00ED); // Power on sequence control
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0064); // Soft Start Keep 1 frame
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0003); //
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0X0012);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0X0081);
	IOWR_32DIRECT(IP_LCD_0_BASE, regCfgCmd, 0x00E8); // Driver timing control A
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0085);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0001);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0078);	//0x78 or 0x79
	IOWR_32DIRECT(IP_LCD_0_BASE, regCfgCmd, 0x00CB); // Power control A
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0039);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x002C);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0000);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0034);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0002);
	IOWR_32DIRECT(IP_LCD_0_BASE, regCfgCmd, 0x00F7); // Pump ratio control
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0020);
	IOWR_32DIRECT(IP_LCD_0_BASE, regCfgCmd, 0x00EA); // Driver timing control B
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0000);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0000);
	IOWR_32DIRECT(IP_LCD_0_BASE, regCfgCmd, 0x00B1); // Frame Control (In Normal Mode)
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0000);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x001b);
	IOWR_32DIRECT(IP_LCD_0_BASE, regCfgCmd, 0x00B6); // Display Function Control
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x000A);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x00A2);
	IOWR_32DIRECT(IP_LCD_0_BASE, regCfgCmd, 0x00C0); //Power control 1
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0005); //VRH[5:0]
	IOWR_32DIRECT(IP_LCD_0_BASE, regCfgCmd, 0x00C1); //Power control 2
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0011); //SAP[2:0];BT[3:0]
	IOWR_32DIRECT(IP_LCD_0_BASE, regCfgCmd, 0x00C5); //VCM control 1
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0045); //3F
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0045); //3C
	IOWR_32DIRECT(IP_LCD_0_BASE, regCfgCmd, 0x00C7); //VCM control 2
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0X00a2);
	IOWR_32DIRECT(IP_LCD_0_BASE, regCfgCmd, 0x0036); // Memory Access Control
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0008);// BGR order
	IOWR_32DIRECT(IP_LCD_0_BASE, regCfgCmd, 0x00F2); // Enable 3G
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0000); // 3Gamma Function Disable
	IOWR_32DIRECT(IP_LCD_0_BASE, regCfgCmd, 0x0026); // Gamma Set
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0001); // Gamma curve selected
	IOWR_32DIRECT(IP_LCD_0_BASE, regCfgCmd, 0x00E0); // Positive Gamma Correction, Set Gamma
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x000F);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0026);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0024);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x000b);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x000E);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0008);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x004b);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0X00a8);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x003b);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x000a);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0014);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0006);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0010);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0009);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0000);
	IOWR_32DIRECT(IP_LCD_0_BASE, regCfgCmd, 0X00E1); //Negative Gamma Correction, Set Gamma
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0000);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x001c);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0020);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0004);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0010);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0008);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0034);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0047);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0044);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0005);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x000b);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0009);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x002f);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0036);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x000f);
	IOWR_32DIRECT(IP_LCD_0_BASE, regCfgCmd, 0x002A); // Column Address Set
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0000);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0000);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0000);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x00ef);
	IOWR_32DIRECT(IP_LCD_0_BASE, regCfgCmd, 0x002B); // Page Address Set
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0000);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0000);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0001);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x003f);
	IOWR_32DIRECT(IP_LCD_0_BASE, regCfgCmd, 0x003A); // COLMOD: Pixel Format Set
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0055);
	IOWR_32DIRECT(IP_LCD_0_BASE, regCfgCmd, 0x00f6); // Interface Control
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0001);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0030);
		IOWR_32DIRECT(IP_LCD_0_BASE, regCfgParam, 0x0000);
	IOWR_32DIRECT(IP_LCD_0_BASE, regCfgCmd, 0x0029); //display on

    IOWR_32DIRECT(IP_LCD_0_BASE, regCfgCmd, 0x002c); // 0x2C Go to write memory

    
    Init_Cam(void);
    IOWR_32DIRECT(IP_CAM_TOP_0_BASE, 0x06,IP_LCD_0_BASE + 0x18); // camLCDaddr
    IOWR_32DIRECT(IP_CAM_TOP_0_BASE, 0x00,0x0); // camAddr
    IOWR_32DIRECT(IP_CAM_TOP_0_BASE, 0x01,240*320/2); // camLength
    IOWR_8DIRECT(IP_CAM_TOP_0_BASE, 0x03,0x1); // Camstart
    IOWR_8DIRECT(IP_CAM_TOP_0_BASE, 0x04,0x1); // Camsnapshot

}
