/*M///////////////////////////////////////////////////////////////////////////////////////
//
//  IMPORTANT: READ BEFORE DOWNLOADING, COPYING, INSTALLING OR USING.
//
//  By downloading, copying, installing or using the software you agree to this license.
//  If you do not agree to this license, do not download, install,
//  copy or use the software.
//
//
//                           License Agreement
//                For Open Source Computer Vision Library
//
// Copyright (C) 2000-2008, Intel Corporation, all rights reserved.
// Copyright (C) 2009-2011, Willow Garage Inc., all rights reserved.
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
//   * The name of the copyright holders may not be used to endorse or promote products
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
#include <opencv2/mat.hpp>

namespace cv
{

static const int MAX_BLOCK_SIZE = 1024;
typedef void (*MathFunc)(const void* src, void* dst, int len);

static const float atan2_p1 = 0.9997878412794807f*(float)(180/CV_PI);
static const float atan2_p3 = -0.3258083974640975f*(float)(180/CV_PI);
static const float atan2_p5 = 0.1555786518463281f*(float)(180/CV_PI);
static const float atan2_p7 = -0.04432655554792128f*(float)(180/CV_PI);

float fastAtan2( float y, float x )
{
    float ax = std::abs(x), ay = std::abs(y);
    float a, c, c2;
    if( ax >= ay )
    {
        c = ay/(ax + (float)DBL_EPSILON);
        c2 = c*c;
        a = (((atan2_p7*c2 + atan2_p5)*c2 + atan2_p3)*c2 + atan2_p1)*c;
    }
    else
    {
        c = ax/(ay + (float)DBL_EPSILON);
        c2 = c*c;
        a = 90.f - (((atan2_p7*c2 + atan2_p5)*c2 + atan2_p3)*c2 + atan2_p1)*c;
    }
    if( x < 0 )
        a = 180.f - a;
    if( y < 0 )
        a = 360.f - a;
    return a;
}

static void FastAtan2_32f(const float *Y, const float *X, float *angle, int len, bool angleInDegrees=true )
{
    int i = 0;
    float scale = angleInDegrees ? 1 : (float)(CV_PI/180);

#if CV_SSE2
    if( USE_SSE2 )
    {
        Cv32suf iabsmask; iabsmask.i = 0x7fffffff;
        __m128 eps = _mm_set1_ps((float)DBL_EPSILON), absmask = _mm_set1_ps(iabsmask.f);
        __m128 _90 = _mm_set1_ps(90.f), _180 = _mm_set1_ps(180.f), _360 = _mm_set1_ps(360.f);
        __m128 z = _mm_setzero_ps(), scale4 = _mm_set1_ps(scale);
        __m128 p1 = _mm_set1_ps(atan2_p1), p3 = _mm_set1_ps(atan2_p3);
        __m128 p5 = _mm_set1_ps(atan2_p5), p7 = _mm_set1_ps(atan2_p7);

        for( ; i <= len - 4; i += 4 )
        {
            __m128 x = _mm_loadu_ps(X + i), y = _mm_loadu_ps(Y + i);
            __m128 ax = _mm_and_ps(x, absmask), ay = _mm_and_ps(y, absmask);
            __m128 mask = _mm_cmplt_ps(ax, ay);
            __m128 tmin = _mm_min_ps(ax, ay), tmax = _mm_max_ps(ax, ay);
            __m128 c = _mm_div_ps(tmin, _mm_add_ps(tmax, eps));
            __m128 c2 = _mm_mul_ps(c, c);
            __m128 a = _mm_mul_ps(c2, p7);
            a = _mm_mul_ps(_mm_add_ps(a, p5), c2);
            a = _mm_mul_ps(_mm_add_ps(a, p3), c2);
            a = _mm_mul_ps(_mm_add_ps(a, p1), c);

            __m128 b = _mm_sub_ps(_90, a);
            a = _mm_xor_ps(a, _mm_and_ps(_mm_xor_ps(a, b), mask));

            b = _mm_sub_ps(_180, a);
            mask = _mm_cmplt_ps(x, z);
            a = _mm_xor_ps(a, _mm_and_ps(_mm_xor_ps(a, b), mask));

            b = _mm_sub_ps(_360, a);
            mask = _mm_cmplt_ps(y, z);
            a = _mm_xor_ps(a, _mm_and_ps(_mm_xor_ps(a, b), mask));

            a = _mm_mul_ps(a, scale4);
            _mm_storeu_ps(angle + i, a);
        }
    }
#endif

    for( ; i < len; i++ )
    {
        float x = X[i], y = Y[i];
        float ax = std::abs(x), ay = std::abs(y);
        float a, c, c2;
        if( ax >= ay )
        {
            c = ay/(ax + (float)DBL_EPSILON);
            c2 = c*c;
            a = (((atan2_p7*c2 + atan2_p5)*c2 + atan2_p3)*c2 + atan2_p1)*c;
        }
        else
        {
            c = ax/(ay + (float)DBL_EPSILON);
            c2 = c*c;
            a = 90.f - (((atan2_p7*c2 + atan2_p5)*c2 + atan2_p3)*c2 + atan2_p1)*c;
        }
        if( x < 0 )
            a = 180.f - a;
        if( y < 0 )
            a = 360.f - a;
        angle[i] = (float)(a*scale);
    }
}

void fastAtan2(const float* y, const float* x, float* dst, int n, bool angleInDegrees)
{
    FastAtan2_32f(y, x, dst, n, angleInDegrees);
}

}


/*
  Finds real roots of cubic, quadratic or linear equation.
  The original code has been taken from Ken Turkowski web page
  (http://www.worldserver.com/turk/opensource/) and adopted for OpenCV.
  Here is the copyright notice.

  -----------------------------------------------------------------------
  Copyright (C) 1978-1999 Ken Turkowski. <turk@computer.org>

    All rights reserved.

    Warranty Information
      Even though I have reviewed this software, I make no warranty
      or representation, either express or implied, with respect to this
      software, its quality, accuracy, merchantability, or fitness for a
      particular purpose.  As a result, this software is provided "as is,"
      and you, its user, are assuming the entire risk as to its quality
      and accuracy.

    This code may be used and freely distributed as long as it includes
    this copyright notice and the above warranty information.
  -----------------------------------------------------------------------
*/

int cv::solveCubic( InputArray _coeffs, OutputArray _roots )
{
    const int n0 = 3;
    Mat coeffs = _coeffs.getMat();
    int ctype = coeffs.type();

    CV_Assert( ctype == CV_32F || ctype == CV_64F );
    CV_Assert( (coeffs.size() == Size(n0, 1) ||
                coeffs.size() == Size(n0+1, 1) ||
                coeffs.size() == Size(1, n0) ||
                coeffs.size() == Size(1, n0+1)) );

    _roots.create(n0, 1, ctype, -1, true, DEPTH_MASK_FLT);
    Mat roots = _roots.getMat();

    int i = -1, n = 0;
    double a0 = 1., a1, a2, a3;
    double x0 = 0., x1 = 0., x2 = 0.;
    int ncoeffs = coeffs.rows + coeffs.cols - 1;

    if( ctype == CV_32FC1 )
    {
        if( ncoeffs == 4 )
            a0 = coeffs.at<float>(++i);

        a1 = coeffs.at<float>(i+1);
        a2 = coeffs.at<float>(i+2);
        a3 = coeffs.at<float>(i+3);
    }
    else
    {
        if( ncoeffs == 4 )
            a0 = coeffs.at<double>(++i);

        a1 = coeffs.at<double>(i+1);
        a2 = coeffs.at<double>(i+2);
        a3 = coeffs.at<double>(i+3);
    }

    if( a0 == 0 )
    {
        if( a1 == 0 )
        {
            if( a2 == 0 )
                n = a3 == 0 ? -1 : 0;
            else
            {
                // linear equation
                x0 = -a3/a2;
                n = 1;
            }
        }
        else
        {
            // quadratic equation
            double d = a2*a2 - 4*a1*a3;
            if( d >= 0 )
            {
                d = sqrt(d);
                double q1 = (-a2 + d) * 0.5;
                double q2 = (a2 + d) * -0.5;
                if( fabs(q1) > fabs(q2) )
                {
                    x0 = q1 / a1;
                    x1 = a3 / q1;
                }
                else
                {
                    x0 = q2 / a1;
                    x1 = a3 / q2;
                }
                n = d > 0 ? 2 : 1;
            }
        }
    }
    else
    {
        a0 = 1./a0;
        a1 *= a0;
        a2 *= a0;
        a3 *= a0;

        double Q = (a1 * a1 - 3 * a2) * (1./9);
        double R = (2 * a1 * a1 * a1 - 9 * a1 * a2 + 27 * a3) * (1./54);
        double Qcubed = Q * Q * Q;
        double d = Qcubed - R * R;

        if( d >= 0 )
        {
            double theta = acos(R / sqrt(Qcubed));
            double sqrtQ = sqrt(Q);
            double t0 = -2 * sqrtQ;
            double t1 = theta * (1./3);
            double t2 = a1 * (1./3);
            x0 = t0 * cos(t1) - t2;
            x1 = t0 * cos(t1 + (2.*CV_PI/3)) - t2;
            x2 = t0 * cos(t1 + (4.*CV_PI/3)) - t2;
            n = 3;
        }
        else
        {
            double e;
            d = sqrt(-d);
            e = pow(d + fabs(R), 0.333333333333);
            if( R > 0 )
                e = -e;
            x0 = (e + Q / e) - a1 * (1./3);
            n = 1;
        }
    }

    if( roots.type() == CV_32FC1 )
    {
        roots.at<float>(0) = (float)x0;
        roots.at<float>(1) = (float)x1;
        roots.at<float>(2) = (float)x2;
    }
    else
    {
        roots.at<double>(0) = x0;
        roots.at<double>(1) = x1;
        roots.at<double>(2) = x2;
    }

    return n;
}

CV_IMPL int
cvSolveCubic( const CvMat* coeffs, CvMat* roots )
{
    cv::Mat _coeffs = cv::cvarrToMat(coeffs), _roots = cv::cvarrToMat(roots), _roots0 = _roots;
    int nroots = cv::solveCubic(_coeffs, _roots);
    CV_Assert( _roots.data == _roots0.data ); // check that the array of roots was not reallocated
    return nroots;
}

/* End of file. */
