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
#ifndef _SFUN_TCP_WRAPPER_
#define _SFUN_TCP_WRAPPER_

#define KIR_INPUT_PORT_1_SIZE 3
#define KIR_INPUT_PORT_2_SIZE 4
#define KIR_INPUT_PORT_3_SIZE 2
#define KIR_INPUT_PORT_4_SIZE 2
#define KIR_INPUT_PORT_6_SIZE 3
#define KIR_INPUT_PORT_7_SIZE 4
#define KIR_IMAGE_BUFFER_SIZE 307200

#ifdef __cplusplus
extern "C"
{
#endif

void initialize_tcp(int p1, int p2, int p3, int p4, int p5, void** work1);
void outputs_tcp(double u1[KIR_INPUT_PORT_1_SIZE],      /* Position [x y z] in km */
             double u2[KIR_INPUT_PORT_2_SIZE],          /* Orientation [x y z w] */
             double u3[KIR_INPUT_PORT_3_SIZE],          /* Size [width height] in pixels */
             double u4[KIR_INPUT_PORT_4_SIZE],          /* Intrinsics [focal_length pixel_size] in meters */
             int u5,                                    /* Flag. If TRUE request only altitude, else send image too */
             double u6[KIR_INPUT_PORT_6_SIZE],          /* Camera relative position [x y z] */
             double u7[KIR_INPUT_PORT_7_SIZE],          /* Camera relative orientaiotn [x y z w] */
             double *y1,                                /* Altitude reported from MEME */
             unsigned char y2[KIR_IMAGE_BUFFER_SIZE],   /* Output image */
             unsigned char *y3,                     /* 1 for valid image, 0 otherwise */
             void** work1);                         /* Work pointer */
void terminate_tcp(void** work1);

#ifdef __cplusplus
}
#endif

#endif
