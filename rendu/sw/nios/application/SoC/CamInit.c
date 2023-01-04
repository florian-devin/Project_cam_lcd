// Program for camera configuration : Write camera registers using i2c module

#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include "i2c.h"

bool trdb_d5m_write(i2c_dev *i2c, uint8_t register_offset, uint16_t data) {
    uint8_t byte_data[2] = {(data >> 8) & 0xff, data & 0xff};

    int success = i2c_write_array(i2c, TRDB_D5M_I2C_ADDRESS, register_offset, byte_data, sizeof(byte_data));

    if (success != I2C_SUCCESS) {
        return false;
    } else {
        return true;
    }
}

bool trdb_d5m_read(i2c_dev *i2c, uint8_t register_offset, uint16_t *data) {
    uint8_t byte_data[2] = {0, 0};

    int success = i2c_read_array(i2c, TRDB_D5M_I2C_ADDRESS, register_offset, byte_data, sizeof(byte_data));

    if (success != I2C_SUCCESS) {
        return false;
    } else {
        *data = ((uint16_t) byte_data[0] << 8) + byte_data[1];
        return true;
    }
}


int Init_Cam(void) {

    i2c_dev i2c = i2c_inst((void *) TRDB_D5M_0_I2C_0_BASE);
    i2c_init(&i2c, I2C_FREQ);
    bool success = true;
    success &= trdb_d5m_write(&i2c, 0x1 , 54);
    success &= trdb_d5m_write(&i2c, 0x2 , 16);
    success &= trdb_d5m_write(&i2c, 0x3 , 1919);
    success &= trdb_d5m_write(&i2c, 0x4 , 2559);
    success &= trdb_d5m_write(&i2c, 0x22, 3);
    success &= trdb_d5m_write(&i2c, 0x23, 3);
    success &= trdb_d5m_write(&i2c, 0x62, 1);
    success &= trdb_d5m_write(&i2c, 0x20, 0);
    success &= trdb_d5m_write(&i2c, 0x4B, 0);


    // PLL config
    success &= trdb_d5m_write(&i2c, 0x10, 0x51);//PLL power up
    success &= trdb_d5m_write(&i2c, 0x11, 0x1605);//PLL n = 4 m = 16
    success &= trdb_d5m_write(&i2c, 0x12, 0x10);//PLL p1 = 16
    for (int i = 0; i < 1000000; i++);
    success &= trdb_d5m_write(&i2c, 0x10, 0x53); //use pll
    for (int i = 0; i < 1000000; i++);

    if (success) {
        return EXIT_SUCCESS;
    } else {
        return EXIT_FAILURE;
    }
    
}
