/**************************************************************************
* Copyright 2010 - 2015 Moon Express, Inc.
* All Rights Reserved.
*
* PROPRIETARY DATA NOTICE:
* The data herein include Proprietary Data and are restricted under the
* Data Rights provisions of Lunar CATALYST Space Act Agreement
* No. SAAM ID# 18251 and Reimbursable Space Act Agreement No.SAA2-402930.
* All information contained herein is and remains proprietary to and the
* property of Moon Express, Inc. Dissemination of this information or
* reproduction of this material is strictly forbidden unless prior
* written permission is obtained from Moon Express, Inc.
**************************************************************************/
#ifndef _SFUN_HMG_WRAPPER_H_
#define _SFUN_HMG_WRAPPER_H_

#define HMG_INPUT_PORT_1_SIZE 32
#define HMG_INPUT_PORT_2_SIZE 32
#define HMG_OUTPUT_PORT_1_SIZE 9
#define HMG_OUTPUT_PORT_2_SIZE 16

#ifdef __cplusplus
extern "C"
{
#endif

void initialize_hmg(double p1, void** work1);
void outputs_hmg(double u1[HMG_INPUT_PORT_1_SIZE],
             double u2[HMG_INPUT_PORT_2_SIZE],
             double y1[HMG_OUTPUT_PORT_1_SIZE],
             unsigned char y2[HMG_OUTPUT_PORT_2_SIZE],
             void** work1);
void terminate_hmg(void** work1);

#ifdef __cplusplus
}
#endif

#endif /* _SFUN_HMG_WRAPPER_H_ */
