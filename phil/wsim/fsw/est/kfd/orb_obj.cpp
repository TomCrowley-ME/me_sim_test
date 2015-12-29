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
#include "orb_obj.h"
#include <iostream>
#include <fstream>

using namespace std;

orb_obj::orb_obj(int points) :
    _numPoints(points)
{

}

orb_obj::~orb_obj() {

}

void orb_obj::run(int height, int width, double imageData1[], double imageData2[],
					vector<pair<double, double> > &matchedPoints1,
					vector<pair<double, double> > &matchedPoints2) {
	// Convert data into Mat format
    cout << "Entered ORB Feature Matcher" << endl;
	cv::Mat image1 = cv::Mat(height, width, CV_8UC1);
	for (int i = 0; i < height * width; ++i) {
		int row = i / width;
		int col = i % width;
		if (imageData1[i] <= 255) {
			image1.at<char>(row, col) = imageData1[i];
		}
	}

	cv::Mat image2 = cv::Mat(height, width, CV_8UC1);
	for (int i = 0; i < height * width; ++i) {
		int row = i / width;
		int col = i % width;
		if (imageData2[i] <= 255) {
			image2.at<char>(row, col) = imageData2[i];
		}
	}

    if (image1.empty() || image2.empty())
    {
        cerr << "Image is empty! Exiting ORB" << endl;
        return;
    }

#ifdef SAVE_IMAGE
    fstream fs;
    fs.open("image1.pgm", fstream::out);
    fs << "P5" << endl;
    fs << width << " " << height << endl;
    fs << 255 << endl;
    fs.write((char*) image1.ptr(), width * height);
    fs.close();
    fs.open("image2.pgm", fstream::out);
    fs << "P5" << endl;
    fs << width << " " << height << endl;
    fs << 255 << endl;
    fs.write((char*) image2.ptr(), width * height);
    fs.close();
#endif

	// Preprocess the images
	cv::equalizeHist(image1, image1);
	cv::equalizeHist(image2, image2);
	cv::GaussianBlur(image1, image1, cv::Size(5,5), 1.2);
	cv::GaussianBlur(image2, image2, cv::Size(5,5), 1.2);

	// Feature Extraction
	cv::OrbFeatureDetector orb(_numPoints);
	vector<cv::KeyPoint> keypoints1, keypoints2;
	orb.detect(image1, keypoints1);
	orb.detect(image2, keypoints2);

	if (keypoints1.size() == 0 || keypoints2.size() == 0) {
		cout << "No keypoints detected! Exiting." << endl;
		return;
	}

    cout << "Keypoints in Image 1: " << keypoints1.size() << "\n"
         << "Keypoints in Image 2: " << keypoints2.size() << endl;

	// Create descriptors
	cv::OrbDescriptorExtractor orbDesc;
	cv::Mat descriptors1, descriptors2;
	orbDesc.compute(image1, keypoints1, descriptors1);
	orbDesc.compute(image2, keypoints2, descriptors2);

	// Feature matching
	cv::BruteForceMatcher<cv::HammingLUT> matcher;
	vector<vector<cv::DMatch> > matches12, matches21;
	matcher.knnMatch(descriptors1, descriptors2, matches12, 2);
	matcher.knnMatch(descriptors2, descriptors1, matches21, 2);

	// Match filtering
	ratioTest(matches12);
	ratioTest(matches21);
	vector<cv::DMatch> symMatches;
	symmetryTest(matches12, matches21, symMatches);
	vector<cv::DMatch> tempMatches;
	ransacTest(symMatches, keypoints1, keypoints2, tempMatches);

    cout << "matches: " << symMatches.size() << endl;

	// Copy matches into output arrays
	for (int i = 0; i < symMatches.size() && i < 20; ++i) {
		double x = keypoints1[symMatches[i].queryIdx].pt.x;
		double y = keypoints1[symMatches[i].queryIdx].pt.y;
		matchedPoints1.push_back(make_pair(x,y));
		x = keypoints2[symMatches[i].trainIdx].pt.x;
		y = keypoints2[symMatches[i].trainIdx].pt.y;
		matchedPoints2.push_back(make_pair(x,y));
	}

//#define SHOW_POINTS
#ifdef SHOW_POINTS
    for (int i = 0; i < matchedPoints1.size(); ++i)
    {
        cout << matchedPoints1[i].first << " " << matchedPoints1[i].second << endl;
    }
    cout << endl;
    for (int i = 0; i < matchedPoints2.size(); ++i)
    {
        cout << matchedPoints2[i].first << " " << matchedPoints2[i].second << endl;
    }
    cout << endl;
#endif
}

void orb_obj::ratioTest(vector<vector<cv::DMatch> > &matches) {
	for (vector<vector<cv::DMatch> >::iterator matchIterator = matches.begin(); matchIterator != matches.end(); ++matchIterator) {
		if (matchIterator->size() > 1) {
			if ((*matchIterator)[0].distance / (*matchIterator)[1].distance > 0.65) {
				matchIterator->clear();
			}
		} else {
			matchIterator->clear();
		}
	}
}

void orb_obj::symmetryTest(const vector<vector<cv::DMatch> > &matches1,
						   const vector<vector<cv::DMatch> > &matches2,
						   vector<cv::DMatch> &symMatches) {
	symMatches.clear();
	for (vector<vector<cv::DMatch> >::const_iterator matchIterator1 = matches1.begin(); matchIterator1 != matches1.end(); ++matchIterator1) {
		if (matchIterator1->size() < 2)
			continue;
		for (vector<vector<cv::DMatch> >::const_iterator matchIterator2 = matches2.begin(); matchIterator2 != matches2.end(); ++matchIterator2) {
			if (matchIterator2->size() < 2)
				continue;
			if ((*matchIterator1)[0].queryIdx == (*matchIterator2)[0].trainIdx && (*matchIterator2)[0].queryIdx == (*matchIterator1)[0].trainIdx) {
				symMatches.push_back(cv::DMatch((*matchIterator1)[0].queryIdx, (*matchIterator1)[0].trainIdx, (*matchIterator1)[0].distance));
				break;
			}
		}
	}
}

void orb_obj::ransacTest(const vector<cv::DMatch> &matches,
						 const vector<cv::KeyPoint> &keypoints1,
						 const vector<cv::KeyPoint> &keypoints2,
						 vector<cv::DMatch> &outMatches) {
	vector<cv::Point2f> points1, points2;
	for (vector<cv::DMatch>::const_iterator it = matches.begin(); it != matches.end(); ++it) {
		float x = keypoints1[it->queryIdx].pt.x;
		float y = keypoints2[it->queryIdx].pt.y;
		points1.push_back(cv::Point2f(x,y));
		x = keypoints2[it->trainIdx].pt.x;
		y = keypoints2[it->trainIdx].pt.y;
		points2.push_back(cv::Point2f(x,y));
	}

	vector<uchar> inliers(points1.size(), 0);
	if (points1.size() == 0 || points2.size() == 0) {
		return;
	}
	//cv::findFundamentalMat(cv::Mat(points1), cv::Mat(points2), inliers, cv::FM_RANSAC, 1, 0.99);

	vector<uchar>::const_iterator itIn = inliers.begin();
	vector<cv::DMatch>::const_iterator itM = matches.begin();

	for ( ; itIn != inliers.end(); ++itIn, ++itM) {
		if (*itIn) {
			outMatches.push_back(*itM);
		}
	}
}



