#include <vxWorks.h>
#include <logLib.h>
#include <../src/hwif/h/i2c/vxbAm38xxI2c.h>
#include <stdio.h>
#include "tps65217c.h"

LOCAL UINT8 tps65217c_encode_voltage(UINT32 mv);


STATUS tps65217c_write(UINT8 addr, UINT8 value) {
    UINT8 protection_lvl = 0;
    UINT8 password = addr ^ TPS65217C_PWXOR;

    /* Determine protection level by looking at the range the register lies in */
    if (addr == 0x0D || addr > 0x15) {
        protection_lvl = 1;
    } else if (addr > 0x0D && addr <= 0x15) {
        protection_lvl = 2;
    }

    if (protection_lvl > 0) {
        /* If protection level is 1 or 2, we need to write a password to the PASSWORD register first */
        vxbI2cByNameWrite(TPS65217C_NAME, 0, TPS65217C_PASSWORD, &password, 1);
    }

    vxbI2cByNameWrite(TPS65217C_NAME, 0, addr, &value, 1);

    if (protection_lvl > 1) {
        /* If protection level is 2, we need to repeat the first two writes */
        vxbI2cByNameWrite(TPS65217C_NAME, 0, TPS65217C_PASSWORD, &password, 1);
        vxbI2cByNameWrite(TPS65217C_NAME, 0, addr, &value, 1);
    }

    return OK;
}

STATUS tps65217c_read(UINT8 addr, UINT8* value) {
    return vxbI2cByNameRead(TPS65217C_NAME, 0, addr, value, 1);
}

STATUS tps65217c_set_mpu_mv(UINT32 mv) {
    UINT8 encoded_voltage;
    UINT8 defslew = 0;

    /* Make sure we're not about to fry the MPU */
    if (mv < TPS65217C_MPU_MVMIN || mv > TPS65217C_MPU_MVMAX) {
        return ERROR;
    }

    /* Encode the voltage for the DCDC2 register */
    encoded_voltage = tps65217c_encode_voltage(mv);

    if (encoded_voltage == TPS65217C_MV_ERR) {
        return ERROR;
    }

    /* Set the DCDC2 register to the new voltage */
    tps65217c_write(TPS65217C_DEFDCDC2, encoded_voltage);

    /* Commit the voltage change with a GO */
    tps65217c_read(TPS65217C_DEFSLEW, &defslew);
    tps65217c_write(TPS65217C_DEFSLEW, defslew | TPS65217C_GO);

    return OK;
}

LOCAL UINT8 tps65217c_encode_voltage(UINT32 mv) {
    /* From TPS65217C datasheet voltage tables -- requested voltages are rounded up to ensure
     * requested voltage is met */
    if (mv < 900 || mv > 3300) {
        return TPS65217C_MV_ERR;
    } else if (mv <= 1500) {
        return (UINT8)((mv - 900 + 25 - 1) / 25);
    } else if (mv <= 2900) {
        return (UINT8)(0x18 + (mv - 1500 + 50 - 1) / 50);
    } else {
        return (UINT8)(0x34 + (mv - 2900 + 100 - 1) / 100);
    }
}
