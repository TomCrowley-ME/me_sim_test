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
#include "hmg_obj.h"
#include <iostream>

using namespace std;

hmg_obj::hmg_obj(double reprojThresh_) :
    reprojThresh(reprojThresh_)
{

}

hmg_obj::~hmg_obj() {

}

int hmg_obj::run(vector<pair<double, double> > &pair1, vector<pair<double, double> > &pair2, double H[3][3], vector<int> &inliers) {
	vector<cv::Point2f> points1;
	for (int i = 0; i < pair1.size(); ++i) {
		points1.push_back(cv::Point2f(pair1[i].first, pair1[i].second));
	}

	vector<cv::Point2f> points2;
	for (int i = 0; i < pair2.size(); ++i) {
		points2.push_back(cv::Point2f(pair2[i].first, pair2[i].second));
	}

    cv::Mat mask;
	cv::Mat homography = cv::findHomography(points1, points2, CV_RANSAC, reprojThresh, mask);

	H[0][0] = homography.at<double>(0,0);
	H[0][1] = homography.at<double>(0,1);
	H[0][2] = homography.at<double>(0,2);
	H[1][0] = homography.at<double>(1,0);
	H[1][1] = homography.at<double>(1,1);
	H[1][2] = homography.at<double>(1,2);
	H[2][0] = homography.at<double>(2,0);
	H[2][1] = homography.at<double>(2,1);
	H[2][2] = homography.at<double>(2,2);

    int maskSize = max(mask.rows, mask.cols);

    for (int i = 0; i < maskSize; ++i) {
        inliers.push_back((int) mask.at<char>(i));
    }

    return 0;

}
