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
#ifndef _HMG_OBJ_
#define _HMG_OBJ_

#include <opencv2/calib3d.hpp>
#include <opencv2/mat.hpp>
#include <opencv2/core.hpp>

class hmg_obj {
public:
	hmg_obj(double reprojThresh_ = 1.0);
	~hmg_obj();

	int run(std::vector<std::pair<double, double> > &pair1,
			std::vector<std::pair<double, double> > &pair2,
			double H[3][3],
            std::vector<int> &inliers);
private:
    double reprojThresh;
};

#endif
