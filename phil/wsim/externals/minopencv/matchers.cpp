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

#include <opencv2/internal.hpp>

namespace cv
{

Mat windowedMatchingMask( const vector<KeyPoint>& keypoints1, const vector<KeyPoint>& keypoints2,
                          float maxDeltaX, float maxDeltaY )
{
    if( keypoints1.empty() || keypoints2.empty() )
        return Mat();

    int n1 = (int)keypoints1.size(), n2 = (int)keypoints2.size();
    Mat mask( n1, n2, CV_8UC1 );
    for( int i = 0; i < n1; i++ )
    {
        for( int j = 0; j < n2; j++ )
        {
            Point2f diff = keypoints2[j].pt - keypoints1[i].pt;
            mask.at<uchar>(i, j) = std::abs(diff.x) < maxDeltaX && std::abs(diff.y) < maxDeltaY;
        }
    }
    return mask;
}

/****************************************************************************************\
*                                      DescriptorMatcher                                 *
\****************************************************************************************/
DescriptorMatcher::DescriptorCollection::DescriptorCollection()
{}

DescriptorMatcher::DescriptorCollection::DescriptorCollection( const DescriptorCollection& collection )
{
    mergedDescriptors = collection.mergedDescriptors.clone();
    copy( collection.startIdxs.begin(), collection.startIdxs.begin(), startIdxs.begin() );
}

DescriptorMatcher::DescriptorCollection::~DescriptorCollection()
{}

void DescriptorMatcher::DescriptorCollection::set( const vector<Mat>& descriptors )
{
    clear();

    size_t imageCount = descriptors.size();
    CV_Assert( imageCount > 0 );

    startIdxs.resize( imageCount );

    int dim = -1;
    int type = -1;
    startIdxs[0] = 0;
    for( size_t i = 1; i < imageCount; i++ )
    {
        int s = 0;
        if( !descriptors[i-1].empty() )
        {
            dim = descriptors[i-1].cols;
            type = descriptors[i-1].type();
            s = descriptors[i-1].rows;
        }
        startIdxs[i] = startIdxs[i-1] + s;
    }
    if( imageCount == 1 )
    {
        if( descriptors[0].empty() ) return;

        dim = descriptors[0].cols;
        type = descriptors[0].type();
    }
    assert( dim > 0 );

    int count = startIdxs[imageCount-1] + descriptors[imageCount-1].rows;

    if( count > 0 )
    {
        mergedDescriptors.create( count, dim, type );
        for( size_t i = 0; i < imageCount; i++ )
        {
            if( !descriptors[i].empty() )
            {
                CV_Assert( descriptors[i].cols == dim && descriptors[i].type() == type );
                Mat m = mergedDescriptors.rowRange( startIdxs[i], startIdxs[i] + descriptors[i].rows );
                descriptors[i].copyTo(m);
            }
        }
    }
}

void DescriptorMatcher::DescriptorCollection::clear()
{
    startIdxs.clear();
    mergedDescriptors.release();
}

const Mat DescriptorMatcher::DescriptorCollection::getDescriptor( int imgIdx, int localDescIdx ) const
{
    CV_Assert( imgIdx < (int)startIdxs.size() );
    int globalIdx = startIdxs[imgIdx] + localDescIdx;
    CV_Assert( globalIdx < (int)size() );

    return getDescriptor( globalIdx );
}

const Mat& DescriptorMatcher::DescriptorCollection::getDescriptors() const
{
    return mergedDescriptors;
}

const Mat DescriptorMatcher::DescriptorCollection::getDescriptor( int globalDescIdx ) const
{
    CV_Assert( globalDescIdx < size() );
    return mergedDescriptors.row( globalDescIdx );
}

void DescriptorMatcher::DescriptorCollection::getLocalIdx( int globalDescIdx, int& imgIdx, int& localDescIdx ) const
{
    CV_Assert( (globalDescIdx>=0) && (globalDescIdx < size()) );
    std::vector<int>::const_iterator img_it = std::upper_bound(startIdxs.begin(), startIdxs.end(), globalDescIdx);
    --img_it;
    imgIdx = (int)(img_it - startIdxs.begin());
    localDescIdx = globalDescIdx - (*img_it);
}

int DescriptorMatcher::DescriptorCollection::size() const
{
    return mergedDescriptors.rows;
}

/*
 * DescriptorMatcher
 */
static void convertMatches( const vector<vector<DMatch> >& knnMatches, vector<DMatch>& matches )
{
    matches.clear();
    matches.reserve( knnMatches.size() );
    for( size_t i = 0; i < knnMatches.size(); i++ )
    {
        CV_Assert( knnMatches[i].size() <= 1 );
        if( !knnMatches[i].empty() )
            matches.push_back( knnMatches[i][0] );
    }
}

DescriptorMatcher::~DescriptorMatcher()
{}

void DescriptorMatcher::add( const vector<Mat>& descriptors )
{
    trainDescCollection.insert( trainDescCollection.end(), descriptors.begin(), descriptors.end() );
}

void DescriptorMatcher::clear()
{
    trainDescCollection.clear();
}

bool DescriptorMatcher::empty() const
{
    return trainDescCollection.empty();
}

void DescriptorMatcher::train()
{}

void DescriptorMatcher::match( const Mat& queryDescriptors, const Mat& trainDescriptors, vector<DMatch>& matches, const Mat& mask ) const
{
    Ptr<DescriptorMatcher> tempMatcher = clone(true);
    tempMatcher->add( vector<Mat>(1, trainDescriptors) );
    tempMatcher->match( queryDescriptors, matches, vector<Mat>(1, mask) );
}

void DescriptorMatcher::knnMatch( const Mat& queryDescriptors, const Mat& trainDescriptors, vector<vector<DMatch> >& matches, int knn,
                                  const Mat& mask, bool compactResult ) const
{
    Ptr<DescriptorMatcher> tempMatcher = clone(true);
    tempMatcher->add( vector<Mat>(1, trainDescriptors) );
    tempMatcher->knnMatch( queryDescriptors, matches, knn, vector<Mat>(1, mask), compactResult );
}

void DescriptorMatcher::radiusMatch( const Mat& queryDescriptors, const Mat& trainDescriptors, vector<vector<DMatch> >& matches, float maxDistance,
                                     const Mat& mask, bool compactResult ) const
{
    Ptr<DescriptorMatcher> tempMatcher = clone(true);
    tempMatcher->add( vector<Mat>(1, trainDescriptors) );
    tempMatcher->radiusMatch( queryDescriptors, matches, maxDistance, vector<Mat>(1, mask), compactResult );
}

void DescriptorMatcher::match( const Mat& queryDescriptors, vector<DMatch>& matches, const vector<Mat>& masks )
{
    vector<vector<DMatch> > knnMatches;
    knnMatch( queryDescriptors, knnMatches, 1, masks, true /*compactResult*/ );
    convertMatches( knnMatches, matches );
}

void DescriptorMatcher::checkMasks( const vector<Mat>& masks, int queryDescriptorsCount ) const
{
    if( isMaskSupported() && !masks.empty() )
    {
        // Check masks
        size_t imageCount = trainDescCollection.size();
        CV_Assert( masks.size() == imageCount );
        for( size_t i = 0; i < imageCount; i++ )
        {
            if( !masks[i].empty() && !trainDescCollection[i].empty() )
            {
                    CV_Assert( masks[i].rows == queryDescriptorsCount &&
                                   masks[i].cols == trainDescCollection[i].rows &&
                                       masks[i].type() == CV_8UC1 );
            }
        }
    }
}

void DescriptorMatcher::knnMatch( const Mat& queryDescriptors, vector<vector<DMatch> >& matches, int knn,
                                  const vector<Mat>& masks, bool compactResult )
{
    matches.clear();
    if( empty() || queryDescriptors.empty() )
        return;

    CV_Assert( knn > 0 );

    checkMasks( masks, queryDescriptors.rows );

    train();
    knnMatchImpl( queryDescriptors, matches, knn, masks, compactResult );
}

void DescriptorMatcher::radiusMatch( const Mat& queryDescriptors, vector<vector<DMatch> >& matches, float maxDistance,
                                     const vector<Mat>& masks, bool compactResult )
{
    matches.clear();
    if( empty() || queryDescriptors.empty() )
        return;

    CV_Assert( maxDistance > std::numeric_limits<float>::epsilon() );

    checkMasks( masks, queryDescriptors.rows );

    train();
    radiusMatchImpl( queryDescriptors, matches, maxDistance, masks, compactResult );
}

bool DescriptorMatcher::isPossibleMatch( const Mat& mask, int queryIdx, int trainIdx )
{
    return mask.empty() || mask.at<uchar>(queryIdx, trainIdx);
}

bool DescriptorMatcher::isMaskedOut( const vector<Mat>& masks, int queryIdx )
{
    size_t outCount = 0;
    for( size_t i = 0; i < masks.size(); i++ )
    {
        if( !masks[i].empty() && (countNonZero(masks[i].row(queryIdx)) == 0) )
            outCount++;
    }

    return !masks.empty() && outCount == masks.size() ;
}


///////////////////////////////////////////////////////////////////////////////////////////////////////

BFMatcher::BFMatcher( int _normType, bool _crossCheck )
{
    normType = _normType;
    crossCheck = _crossCheck;
}

Ptr<DescriptorMatcher> BFMatcher::clone( bool emptyTrainData ) const
{
    BFMatcher* matcher = new BFMatcher(normType, crossCheck);
    if( !emptyTrainData )
    {
        matcher->trainDescCollection.resize(trainDescCollection.size());
        std::transform( trainDescCollection.begin(), trainDescCollection.end(),
                        matcher->trainDescCollection.begin(), clone_op );
    }
    return matcher;
}


void BFMatcher::knnMatchImpl( const Mat& queryDescriptors, vector<vector<DMatch> >& matches, int knn,
                              const vector<Mat>& masks, bool compactResult )
{
    const int IMGIDX_SHIFT = 18;
    const int IMGIDX_ONE = (1 << IMGIDX_SHIFT);

    if( queryDescriptors.empty() || trainDescCollection.empty() )
    {
        matches.clear();
        return;
    }
    CV_Assert( queryDescriptors.type() == trainDescCollection[0].type() );

    matches.reserve(queryDescriptors.rows);

    Mat dist, nidx;

    int iIdx, imgCount = (int)trainDescCollection.size(), update = 0;
    int dtype = normType == NORM_HAMMING || normType == NORM_HAMMING2 ||
        (normType == NORM_L1 && queryDescriptors.type() == CV_8U) ? CV_32S : CV_32F;

    CV_Assert( (int64)imgCount*IMGIDX_ONE < INT_MAX );

    for( iIdx = 0; iIdx < imgCount; iIdx++ )
    {
        CV_Assert( trainDescCollection[iIdx].rows < IMGIDX_ONE );
        batchDistance(queryDescriptors, trainDescCollection[iIdx], dist, dtype, nidx,
                      normType, knn, masks.empty() ? Mat() : masks[iIdx], update, crossCheck);
        update += IMGIDX_ONE;
    }

    if( dtype == CV_32S )
    {
        Mat temp;
        dist.convertTo(temp, CV_32F);
        dist = temp;
    }

    for( int qIdx = 0; qIdx < queryDescriptors.rows; qIdx++ )
    {
        const float* distptr = dist.ptr<float>(qIdx);
        const int* nidxptr = nidx.ptr<int>(qIdx);

        matches.push_back( vector<DMatch>() );
        vector<DMatch>& mq = matches.back();
        mq.reserve(knn);

        for( int k = 0; k < nidx.cols; k++ )
        {
            if( nidxptr[k] < 0 )
                break;
            mq.push_back( DMatch(qIdx, nidxptr[k] & (IMGIDX_ONE - 1),
                          nidxptr[k] >> IMGIDX_SHIFT, distptr[k]) );
        }

        if( mq.empty() && compactResult )
            matches.pop_back();
    }
}


void BFMatcher::radiusMatchImpl( const Mat& queryDescriptors, vector<vector<DMatch> >& matches,
                                 float maxDistance, const vector<Mat>& masks, bool compactResult )
{
    if( queryDescriptors.empty() || trainDescCollection.empty() )
    {
        matches.clear();
        return;
    }
    CV_Assert( queryDescriptors.type() == trainDescCollection[0].type() );

    matches.resize(queryDescriptors.rows);
    Mat dist, distf;

    int iIdx, imgCount = (int)trainDescCollection.size();
    int dtype = normType == NORM_HAMMING ||
        (normType == NORM_L1 && queryDescriptors.type() == CV_8U) ? CV_32S : CV_32F;

    for( iIdx = 0; iIdx < imgCount; iIdx++ )
    {
        batchDistance(queryDescriptors, trainDescCollection[iIdx], dist, dtype, noArray(),
                      normType, 0, masks.empty() ? Mat() : masks[iIdx], 0, false);
        if( dtype == CV_32S )
            dist.convertTo(distf, CV_32F);
        else
            distf = dist;

        for( int qIdx = 0; qIdx < queryDescriptors.rows; qIdx++ )
        {
            const float* distptr = distf.ptr<float>(qIdx);

            vector<DMatch>& mq = matches[qIdx];
            for( int k = 0; k < distf.cols; k++ )
            {
                if( distptr[k] <= maxDistance )
                    mq.push_back( DMatch(qIdx, k, iIdx, distptr[k]) );
            }
        }
    }

    int qIdx0 = 0;
    for( int qIdx = 0; qIdx < queryDescriptors.rows; qIdx++ )
    {
        if( matches[qIdx].empty() && compactResult )
            continue;

        if( qIdx0 < qIdx )
            std::swap(matches[qIdx], matches[qIdx0]);

        std::sort( matches[qIdx0].begin(), matches[qIdx0].end() );
        qIdx0++;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

/*
 * Factory function for DescriptorMatcher creating
 */
Ptr<DescriptorMatcher> DescriptorMatcher::create( const string& descriptorMatcherType )
{
    DescriptorMatcher* dm = 0;
#if 0
    if( !descriptorMatcherType.compare( "FlannBased" ) )
    {
        dm = new FlannBasedMatcher();
    }
    else
#endif
        if( !descriptorMatcherType.compare( "BruteForce" ) ) // L2
    {
        dm = new BFMatcher(NORM_L2);
    }
    else if( !descriptorMatcherType.compare( "BruteForce-SL2" ) ) // Squared L2
    {
        dm = new BFMatcher(NORM_L2SQR);
    }
    else if( !descriptorMatcherType.compare( "BruteForce-L1" ) )
    {
        dm = new BFMatcher(NORM_L1);
    }
    else if( !descriptorMatcherType.compare("BruteForce-Hamming") ||
             !descriptorMatcherType.compare("BruteForce-HammingLUT") )
    {
        dm = new BFMatcher(NORM_HAMMING);
    }
    else if( !descriptorMatcherType.compare("BruteForce-Hamming(2)") )
    {
        dm = new BFMatcher(NORM_HAMMING2);
    }
    else
        CV_Error( CV_StsBadArg, "Unknown matcher name" );

    return dm;
}

}
