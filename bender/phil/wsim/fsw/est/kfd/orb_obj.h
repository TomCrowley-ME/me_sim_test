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
#ifndef _ORB_OBJ_
#define _ORB_OBJ_

#include <opencv2/features2d.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/legacy.hpp>
#include <opencv2/calib3d.hpp>
#include <opencv2/mat.hpp>
#include <utility>

class orb_obj {
public:
	orb_obj(int points = 50);
	~orb_obj();

	void run(int height, int width, double imageData1[], double imageData2[],
			 std::vector<std::pair<double, double> > &matches1,
			 std::vector<std::pair<double, double> > &matches2);

	void ratioTest(std::vector<std::vector<cv::DMatch> > &matches);

	void symmetryTest(const std::vector<std::vector<cv::DMatch> > &matches1,
					  const std::vector<std::vector<cv::DMatch> > &matches2,
					  std::vector<cv::DMatch> &symMatches);

	void ransacTest(const std::vector<cv::DMatch> &matches,
					const std::vector<cv::KeyPoint> &keypoints1,
					const std::vector<cv::KeyPoint> &keypoints2,
					std::vector<cv::DMatch> &outMatches);

    int _numPoints;
};

#endif
