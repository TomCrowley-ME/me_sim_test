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
#include "sfun_tcp_wrapper.h"
#include "tcp_obj.h"
#include <iostream>
#ifdef _WIN32
#include <io.h>
#else
#include <unistd.h>
#endif

using namespace std;

#ifdef __cplusplus
extern "C"
{
#endif

void initialize_tcp(int p1,
                int p2,
                int p3,
                int p4,
                int p5,
                void** work1)
{
    int ip[4];
    ip[0] = p1;
    ip[1] = p2;
    ip[2] = p3;
    ip[3] = p4;

    *work1  = (void*)new tcp_obj(ip, p5);
}

void outputs_tcp(double u1[KIR_INPUT_PORT_1_SIZE],
             double u2[KIR_INPUT_PORT_2_SIZE],
             double u3[KIR_INPUT_PORT_3_SIZE],
             double u4[KIR_INPUT_PORT_4_SIZE],
             int u5,
             double u6[KIR_INPUT_PORT_6_SIZE],
             double u7[KIR_INPUT_PORT_7_SIZE],
             double *y1,
             unsigned char y2[KIR_IMAGE_BUFFER_SIZE],
             unsigned char *y3,
             void** work1)
{
    tcp_obj *obj = (tcp_obj*) *work1;
    *y3 = 1;
    for (int i = 0; i < KIR_IMAGE_BUFFER_SIZE; ++i)
    {
        y2[i] = 0;
    }

    double orientation[KIR_INPUT_PORT_2_SIZE];
    memmove(orientation, u2, KIR_INPUT_PORT_2_SIZE * sizeof(double));
    double swap = orientation[KIR_INPUT_PORT_2_SIZE-1];
    for (int i = KIR_INPUT_PORT_2_SIZE; i > 0; i--)
    {
        orientation[i] = orientation[i-1];
    }
    orientation[0] = swap;

    double childOrientation[KIR_INPUT_PORT_7_SIZE];
    memmove(childOrientation, u7, KIR_INPUT_PORT_7_SIZE * sizeof(double));
    swap = childOrientation[KIR_INPUT_PORT_7_SIZE-1];
    for (int i = KIR_INPUT_PORT_7_SIZE; i > 0; i--)
    {
        childOrientation[i] = childOrientation[i-1];
    }
    childOrientation[0] = swap;

    if (obj->requestImage(u1, orientation, u3, u4, u5, u6, childOrientation))
    {
        cout << "Request image failed" << endl;
    }
    else
    {
        std::vector<unsigned char> image;
        double altitude;

        if (obj->recvData(altitude, image) == -1)
        {
            cout << "Receive Image request failed" << endl;
            perror("Recv");
            *y3 = 0;
        }

        cout << "Altitude: " << altitude << endl;

        *y1 = altitude;
        for (int i = 0; i < image.size(); ++i)
        {
            y2[i] = image[i];
        }
    }
}

void terminate_tcp(void** work1)
{
    tcp_obj* obj = (tcp_obj*) *work1;
    delete obj;
}

#ifdef __cplusplus
}
#endif
