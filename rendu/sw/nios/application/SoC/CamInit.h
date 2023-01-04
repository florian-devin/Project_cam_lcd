// Program for camera configuration : Write camera registers using i2c module


#include "CamInit.c"


#define I2C_FREQ              (50000000) /* Clock frequency driving the i2c core: 50 MHz in this example (ADAPT TO YOUR DESIGN) */
#define TRDB_D5M_I2C_ADDRESS  (0xba)

#define TRDB_D5M_0_I2C_0_BASE (0x0000)   /* i2c base address from system.h (ADAPT TO YOUR DESIGN) */


bool trdb_d5m_write(i2c_dev *i2c, uint8_t register_offset, uint16_t data);

bool trdb_d5m_read(i2c_dev *i2c, uint8_t register_offset, uint16_t *data);