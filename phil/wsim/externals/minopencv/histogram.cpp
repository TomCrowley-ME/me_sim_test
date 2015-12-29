/*M///////////////////////////////////////////////////////////////////////////////////////
//
//  IMPORTANT: READ BEFORE DOWNLOADING, COPYING, INSTALLING OR USING.
//
//  By downloading, copying, installing or using the software you agree to this license.
//  If you do not agree to this license, do not download, install,
//  copy or use the software.
//
//
//            Intel License Agreement
//        For Open Source Computer Vision Library
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
#include <opencv2/mat.hpp>

CV_IMPL void cvEqualizeHist( const CvArr* srcarr, CvArr* dstarr )
{
    CvMat sstub, *src = cvGetMat(srcarr, &sstub);
    CvMat dstub, *dst = cvGetMat(dstarr, &dstub);

    CV_Assert( CV_ARE_SIZES_EQ(src, dst) && CV_ARE_TYPES_EQ(src, dst) &&
               CV_MAT_TYPE(src->type) == CV_8UC1 );
    CvSize size = cvGetMatSize(src);
    if( CV_IS_MAT_CONT(src->type & dst->type) )
    {
        size.width *= size.height;
        size.height = 1;
    }
    int x, y;
    const int hist_sz = 256;
    int hist[hist_sz];
    memset(hist, 0, sizeof(hist));

    for( y = 0; y < size.height; y++ )
    {
        const uchar* sptr = src->data.ptr + src->step*y;
        for( x = 0; x < size.width; x++ )
            hist[sptr[x]]++;
    }

    float scale = 255.f/(size.width*size.height);
    int sum = 0;
    uchar lut[hist_sz+1];

    for( int i = 0; i < hist_sz; i++ )
    {
        sum += hist[i];
        int val = cvRound(sum*scale);
        lut[i] = CV_CAST_8U(val);
    }

    lut[0] = 0;
    for( y = 0; y < size.height; y++ )
    {
        const uchar* sptr = src->data.ptr + src->step*y;
        uchar* dptr = dst->data.ptr + dst->step*y;
        for( x = 0; x < size.width; x++ )
            dptr[x] = lut[sptr[x]];
    }
}

namespace cv {

void equalizeHist( InputArray _src, OutputArray _dst )
{
    Mat src = _src.getMat();
    _dst.create( src.size(), src.type() );
    Mat dst = _dst.getMat();
    CvMat _csrc = src, _cdst = dst;
    cvEqualizeHist( &_csrc, &_cdst );
}

}

/* End of file. */

