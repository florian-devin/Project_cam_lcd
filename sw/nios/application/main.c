// Main program for Lab4

///////////////////////// INCLUDE
#include <stdio.h>
#include <inttypes.h>
#include "io.h"
#include "system.h"
#include "CamInit.h"
///////////////////////// END INCLUDE


int main() 
{
    Init_Cam(void);
    IOWR_32DIRECT(IP_PWM_0_BASE, 0x00,0x0); // camAddr
    IOWR_32DIRECT(IP_PWM_0_BASE, 0x01,240*320/2); // camLength
    IOWR_8DIRECT(IP_PWM_0_BASE, 0x03,0x1); // Camstart
    IOWR_8DIRECT(IP_PWM_0_BASE, 0x04,0x1); // Camsnapshot

}