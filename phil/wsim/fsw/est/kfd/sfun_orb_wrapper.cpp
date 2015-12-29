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
#include "sfun_orb_wrapper.h"
#include "orb_obj.h"

using namespace std;

#ifdef __cplusplus
extern "C"
{
#endif

void initialize_orb(int p1, void** work1)
{
    *work1 = (void *) new orb_obj(p1);
}

void outputs_orb(unsigned char u1[KFD_IMAGE_BUFFER_SIZE],
             unsigned char u2[KFD_IMAGE_BUFFER_SIZE],
             double u3[KFD_INPUT_PORT_3_SIZE],
             double y1[KFD_OUTPUT_PORT_1_SIZE],
             double y2[KFD_OUTPUT_PORT_2_SIZE],
             void** work1)
{
    int width = u3[0];
    int height = u3[1];
    for (int i = 0; i < KFD_OUTPUT_PORT_1_SIZE; ++i)
    {
        y1[i] = -1;
        y2[i] = -1;
    }

    double* image1 = new double[height*width];
    double* image2 = new double[height*width];
    for (int i = 0; i < height * width; ++i)
    {
        image1[i] = u1[i];
        image2[i] = u2[i];
    }

    std::vector<std::pair<double, double> > features1, features2;
    orb_obj *obj = (orb_obj*) *work1;
    obj->run(height, width, image1, image2, features1, features2);

    for (int i = 0; i < features1.size(); ++i)
    {
        y1[i] =       features1[i].first;
        y1[i+KFD_OUTPUT_PORT_1_SIZE / 2] =     features1[i].second;
    }
    for (int i = 0; i < features2.size(); ++i)
    {
        y2[i] =       features2[i].first;
        y2[i+KFD_OUTPUT_PORT_2_SIZE / 2] =     features2[i].second;
    }

    delete image1;
    delete image2;
}

void terminate_orb(void** work1)
{
    orb_obj* obj = (orb_obj*) *work1;
    delete obj;
}

#ifdef __cplusplus
}
#endif
