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
#ifndef _SFUN_ORB_WRAPPER_H_
#define _SFUN_ORB_WRAPPER_H_

#define KFD_IMAGE_BUFFER_SIZE 307200
#define KFD_INPUT_PORT_3_SIZE 2
#define KFD_OUTPUT_PORT_1_SIZE 32
#define KFD_OUTPUT_PORT_2_SIZE 32

#ifdef __cplusplus
extern "C"
{
#endif

void initialize_orb(int p1, void** work1);
void outputs_orb(unsigned char u1[KFD_IMAGE_BUFFER_SIZE], /* First Image */
             unsigned char u2[KFD_IMAGE_BUFFER_SIZE],     /* Second Image */
             double u3[KFD_INPUT_PORT_3_SIZE],            /* Size of the images */
             double y1[KFD_OUTPUT_PORT_1_SIZE],           /* Output keypoints. */
             double y2[KFD_OUTPUT_PORT_1_SIZE],           /* Output keypoints */
             void** work1);
void terminate_orb(void** work1);

#ifdef __cplusplus
}
#endif

#endif /* _SFUN_ORB_WRAPPER_H_ */
