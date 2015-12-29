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
#include "sfun_hmg_wrapper.h"
#include "hmg_obj.h"
#include <vector>
#include <utility>

using namespace std;

#ifdef __cplusplus
extern "C"
{
#endif

void initialize_hmg(double p1, void** work1)
{
    *work1 = (void *) new hmg_obj(p1);
}

void outputs_hmg(double u1[HMG_INPUT_PORT_1_SIZE],
             double u2[HMG_INPUT_PORT_2_SIZE],
             double y1[HMG_OUTPUT_PORT_1_SIZE],
             unsigned char y2[HMG_OUTPUT_PORT_2_SIZE],
             void** work1)
{
    vector<pair<double, double> > pair1;
    for (int i = 0; i < HMG_INPUT_PORT_1_SIZE/2; ++i)
    {
        if (u1[i] == -1 && u1[i+HMG_INPUT_PORT_1_SIZE/2] == -1)
        {
            continue;
        }
        pair1.push_back(make_pair(u1[i], u1[i + HMG_INPUT_PORT_1_SIZE/2]));
    }
    vector<pair<double, double> > pair2;
    for (int i = 0; i < HMG_INPUT_PORT_2_SIZE/2; ++i)
    {
        if (u2[i] == -1 && u2[i+HMG_INPUT_PORT_2_SIZE/2] == -1)
        {
            continue;
        }
        pair2.push_back(make_pair(u2[i], u2[i + HMG_INPUT_PORT_2_SIZE/2]));
    }

    double H[3][3] = {0};
    vector<int> inliers;

    hmg_obj *obj = (hmg_obj*) *work1;

    if ((pair1.size() != pair2.size()) ||
        (pair1.size() < 4) ||
        (pair2.size() < 4))
    {
        inliers.resize(HMG_INPUT_PORT_1_SIZE);
        fill(inliers.begin(), inliers.end(), 0);
    }
    else
    {
        obj->run(pair1, pair2, H, inliers);
    }

    y1[0] = H[0][0];
    y1[1] = H[1][0];
    y1[2] = H[2][0];
    y1[3] = H[0][1];
    y1[4] = H[1][1];
    y1[5] = H[2][1];
    y1[6] = H[0][2];
    y1[7] = H[1][2];
    y1[8] = H[2][2];

    for (int i = 0; i < inliers.size(); ++i)
    {
        y2[i] = inliers[i];
    }

}

void terminate_hmg(void** work1)
{
    hmg_obj* obj = (hmg_obj*) *work1;
    delete obj;
}

#ifdef __cplusplus
}
#endif
