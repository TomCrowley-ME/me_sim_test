/*M///////////////////////////////////////////////////////////////////////////////////////
//
//  IMPORTANT: READ BEFORE DOWNLOADING, COPYING, INSTALLING OR USING.
//
//  By downloading, copying, installing or using the software you agree to this license.
//  If you do not agree to this license, do not download, install,
//  copy or use the software.
//
//
//                        Intel License Agreement
//                For Open Source Computer Vision Library
//
// Copyright (C) 2000, Intel Corporation, all rights reserved.
// Third party copyrights are property of their respective owners.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
//   * Redistribution's of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//
//   * Redistribution's in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//
//   * The name of Intel Corporation may not be used to endorse or promote products
//     derived from this software without specific prior written permission.
//
// This software is provided by the copyright holders and contributors "as is" and
// any express or implied warranties, including, but not limited to, the implied
// warranties of merchantability and fitness for a particular purpose are disclaimed.
// In no event shall the Intel Corporation or contributors be liable for any direct,
// indirect, incidental, special, exemplary, or consequential damages
// (including, but not limited to, procurement of substitute goods or services;
// loss of use, data, or profits; or business interruption) however caused
// and on any theory of liability, whether in contract, strict liability,
// or tort (including negligence or otherwise) arising in any way out of
// the use of this software, even if advised of the possibility of such damage.
//
//M*/

#include <opencv2/core_c.h>
#include <opencv2/core.hpp>
#include <opencv2/internal.hpp>
#include <opencv2/imgproc_c.h>
#include <opencv2/imgproc.hpp>
#include <opencv2/mat.hpp>
#include <opencv2/features2d.hpp>

using namespace std;

namespace cv
{

/*
 *  FeatureDetector
 */

FeatureDetector::~FeatureDetector()
{}

void FeatureDetector::detect( const Mat& image, vector<KeyPoint>& keypoints, const Mat& mask ) const
{
    keypoints.clear();

    if( image.empty() )
        return;

    CV_Assert( mask.empty() || (mask.type() == CV_8UC1 && mask.size() == image.size()) );

    detectImpl( image, keypoints, mask );
}

void FeatureDetector::detect(const vector<Mat>& imageCollection, vector<vector<KeyPoint> >& pointCollection, const vector<Mat>& masks ) const
{
    pointCollection.resize( imageCollection.size() );
    for( size_t i = 0; i < imageCollection.size(); i++ )
        detect( imageCollection[i], pointCollection[i], masks.empty() ? Mat() : masks[i] );
}

/*void FeatureDetector::read( const FileNode& )
{}

void FeatureDetector::write( FileStorage& ) const
{}*/

bool FeatureDetector::empty() const
{
    return false;
}

void FeatureDetector::removeInvalidPoints( const Mat& mask, vector<KeyPoint>& keypoints )
{
    KeyPointsFilter::runByPixelsMask( keypoints, mask );
}

Ptr<FeatureDetector> FeatureDetector::create( const string& detectorType )
{
#if 0
    if( detectorType.find("Grid") == 0 )
    {
        return new GridAdaptedFeatureDetector(FeatureDetector::create(
                                detectorType.substr(strlen("Grid"))));
    }

    if( detectorType.find("Pyramid") == 0 )
    {
        return new PyramidAdaptedFeatureDetector(FeatureDetector::create(
                                detectorType.substr(strlen("Pyramid"))));
    }

    if( detectorType.find("Dynamic") == 0 )
    {
        return new DynamicAdaptedFeatureDetector(AdjusterAdapter::create(
                                detectorType.substr(strlen("Dynamic"))));
    }
#endif

    if( detectorType.compare( "HARRIS" ) == 0 )
    {
        Ptr<FeatureDetector> fd = FeatureDetector::create("GFTT");
        fd->set("useHarrisDetector", true);
        return fd;
    }

    return Algorithm::create<FeatureDetector>("Feature2D." + detectorType);
}

}
