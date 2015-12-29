#ifndef _TPS65217C_H_
#define _TPS65217C_H_

#define TPS65217C_NAME "tps65217c"
#define TPS65217C_PASSWORD (0x0B)
#define TPS65217C_DEFDCDC1 (0x0E)
#define TPS65217C_DEFDCDC2 (0x0F)
#define TPS65217C_DEFDCDC3 (0x10)
#define TPS65217C_DEFSLEW  (0x11)

#define TPS65217C_GO        (0x80)
#define TPS65217C_PWXOR     (0x7D)
#define TPS65217C_MPU_MVMAX (1490)
#define TPS65217C_MPU_MVMIN (1090)
#define TPS65217C_MV_ERR    (0xff)

STATUS tps65217c_write(UINT8 addr, UINT8 value);
STATUS tps65217c_read(UINT8 addr, UINT8* value);
STATUS tps65217c_set_mpu_mv(UINT32 mv);

#endif /*_TPS65217C_H_*/
