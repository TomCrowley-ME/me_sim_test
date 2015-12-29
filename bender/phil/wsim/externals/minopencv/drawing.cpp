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
#include <opencv2/mat.hpp>

namespace cv
{

enum { XY_SHIFT = 16, XY_ONE = 1 << XY_SHIFT, DRAWING_STORAGE_BLOCK = (1<<12) - 256 };

static void
PolyLine( Mat& img, const Point* v, int npts, bool closed,
          const void* color, int thickness, int line_type, int shift );

static void
FillConvexPoly( Mat& img, const Point* v, int npts,
                const void* color, int line_type, int shift );

/****************************************************************************************\
*                                   Lines                                                *
\****************************************************************************************/

bool clipLine( Size img_size, Point& pt1, Point& pt2 )
{
    int64 x1, y1, x2, y2;
    int c1, c2;
    int64 right = img_size.width-1, bottom = img_size.height-1;

    if( img_size.width <= 0 || img_size.height <= 0 )
        return false;

    x1 = pt1.x; y1 = pt1.y; x2 = pt2.x; y2 = pt2.y;
    c1 = (x1 < 0) + (x1 > right) * 2 + (y1 < 0) * 4 + (y1 > bottom) * 8;
    c2 = (x2 < 0) + (x2 > right) * 2 + (y2 < 0) * 4 + (y2 > bottom) * 8;

    if( (c1 & c2) == 0 && (c1 | c2) != 0 )
    {
        int64 a;
        if( c1 & 12 )
        {
            a = c1 < 8 ? 0 : bottom;
            x1 +=  (a - y1) * (x2 - x1) / (y2 - y1);
            y1 = a;
            c1 = (x1 < 0) + (x1 > right) * 2;
        }
        if( c2 & 12 )
        {
            a = c2 < 8 ? 0 : bottom;
            x2 += (a - y2) * (x2 - x1) / (y2 - y1);
            y2 = a;
            c2 = (x2 < 0) + (x2 > right) * 2;
        }
        if( (c1 & c2) == 0 && (c1 | c2) != 0 )
        {
            if( c1 )
            {
                a = c1 == 1 ? 0 : right;
                y1 += (a - x1) * (y2 - y1) / (x2 - x1);
                x1 = a;
                c1 = 0;
            }
            if( c2 )
            {
                a = c2 == 1 ? 0 : right;
                y2 += (a - x2) * (y2 - y1) / (x2 - x1);
                x2 = a;
                c2 = 0;
            }
        }

        assert( (c1 & c2) != 0 || (x1 | y1 | x2 | y2) >= 0 );

        pt1.x = (int)x1;
        pt1.y = (int)y1;
        pt2.x = (int)x2;
        pt2.y = (int)y2;
    }

    return (c1 | c2) == 0;
}

bool clipLine( Rect img_rect, Point& pt1, Point& pt2 )
{
    Point tl = img_rect.tl();
    pt1 -= tl; pt2 -= tl;
    bool inside = clipLine(img_rect.size(), pt1, pt2);
    pt1 += tl; pt2 += tl;

    return inside;
}

/*
   Initializes line iterator.
   Returns number of points on the line or negative number if error.
*/
LineIterator::LineIterator(const Mat& img, Point pt1, Point pt2,
                           int connectivity, bool left_to_right)
{
    count = -1;

    CV_Assert( connectivity == 8 || connectivity == 4 );

    if( (unsigned)pt1.x >= (unsigned)(img.cols) ||
        (unsigned)pt2.x >= (unsigned)(img.cols) ||
        (unsigned)pt1.y >= (unsigned)(img.rows) ||
        (unsigned)pt2.y >= (unsigned)(img.rows) )
    {
        if( !clipLine( img.size(), pt1, pt2 ) )
        {
            ptr = img.data;
            err = plusDelta = minusDelta = plusStep = minusStep = count = 0;
            return;
        }
    }

    int bt_pix0 = (int)img.elemSize(), bt_pix = bt_pix0;
    size_t istep = img.step;

    int dx = pt2.x - pt1.x;
    int dy = pt2.y - pt1.y;
    int s = dx < 0 ? -1 : 0;

    if( left_to_right )
    {
        dx = (dx ^ s) - s;
        dy = (dy ^ s) - s;
        pt1.x ^= (pt1.x ^ pt2.x) & s;
        pt1.y ^= (pt1.y ^ pt2.y) & s;
    }
    else
    {
        dx = (dx ^ s) - s;
        bt_pix = (bt_pix ^ s) - s;
    }

    ptr = (uchar*)(img.data + pt1.y * istep + pt1.x * bt_pix0);

    s = dy < 0 ? -1 : 0;
    dy = (dy ^ s) - s;
    istep = (istep ^ s) - s;

    s = dy > dx ? -1 : 0;

    /* conditional swaps */
    dx ^= dy & s;
    dy ^= dx & s;
    dx ^= dy & s;

    bt_pix ^= istep & s;
    istep ^= bt_pix & s;
    bt_pix ^= istep & s;

    if( connectivity == 8 )
    {
        assert( dx >= 0 && dy >= 0 );

        err = dx - (dy + dy);
        plusDelta = dx + dx;
        minusDelta = -(dy + dy);
        plusStep = (int)istep;
        minusStep = bt_pix;
        count = dx + 1;
    }
    else /* connectivity == 4 */
    {
        assert( dx >= 0 && dy >= 0 );

        err = 0;
        plusDelta = (dx + dx) + (dy + dy);
        minusDelta = -(dy + dy);
        plusStep = (int)istep - bt_pix;
        minusStep = bt_pix;
        count = dx + dy + 1;
    }

    this->ptr0 = img.data;
    this->step = (int)img.step;
    this->elemSize = bt_pix0;
}

static void
Line( Mat& img, Point pt1, Point pt2,
      const void* _color, int connectivity = 8 )
{
    if( connectivity == 0 )
        connectivity = 8;
    if( connectivity == 1 )
        connectivity = 4;

    LineIterator iterator(img, pt1, pt2, connectivity, true);
    int i, count = iterator.count;
    int pix_size = (int)img.elemSize();
    const uchar* color = (const uchar*)_color;

    for( i = 0; i < count; i++, ++iterator )
    {
        uchar* ptr = *iterator;
        if( pix_size == 1 )
            ptr[0] = color[0];
        else if( pix_size == 3 )
        {
            ptr[0] = color[0];
            ptr[1] = color[1];
            ptr[2] = color[2];
        }
        else
            memcpy( *iterator, color, pix_size );
    }
}

static void
Line2( Mat& img, Point pt1, Point pt2, const void* color )
{
    int dx, dy;
    int ecount;
    int ax, ay;
    int i, j, x, y;
    int x_step, y_step;
    int cb = ((uchar*)color)[0];
    int cg = ((uchar*)color)[1];
    int cr = ((uchar*)color)[2];
    int pix_size = (int)img.elemSize();
    uchar *ptr = img.data, *tptr;
    size_t step = img.step;
    Size size = img.size(), sizeScaled(size.width*XY_ONE, size.height*XY_ONE);

    //assert( img && (nch == 1 || nch == 3) && img.depth() == CV_8U );

    if( !clipLine( sizeScaled, pt1, pt2 ))
        return;

    dx = pt2.x - pt1.x;
    dy = pt2.y - pt1.y;

    j = dx < 0 ? -1 : 0;
    ax = (dx ^ j) - j;
    i = dy < 0 ? -1 : 0;
    ay = (dy ^ i) - i;

    if( ax > ay )
    {
        dx = ax;
        dy = (dy ^ j) - j;
        pt1.x ^= pt2.x & j;
        pt2.x ^= pt1.x & j;
        pt1.x ^= pt2.x & j;
        pt1.y ^= pt2.y & j;
        pt2.y ^= pt1.y & j;
        pt1.y ^= pt2.y & j;

        x_step = XY_ONE;
        y_step = (int) (((int64) dy << XY_SHIFT) / (ax | 1));
        ecount = (pt2.x - pt1.x) >> XY_SHIFT;
    }
    else
    {
        dy = ay;
        dx = (dx ^ i) - i;
        pt1.x ^= pt2.x & i;
        pt2.x ^= pt1.x & i;
        pt1.x ^= pt2.x & i;
        pt1.y ^= pt2.y & i;
        pt2.y ^= pt1.y & i;
        pt1.y ^= pt2.y & i;

        x_step = (int) (((int64) dx << XY_SHIFT) / (ay | 1));
        y_step = XY_ONE;
        ecount = (pt2.y - pt1.y) >> XY_SHIFT;
    }

    pt1.x += (XY_ONE >> 1);
    pt1.y += (XY_ONE >> 1);

    if( pix_size == 3 )
    {
        #define  ICV_PUT_POINT(_x,_y)   \
        x = (_x); y = (_y);             \
        if( 0 <= x && x < size.width && \
            0 <= y && y < size.height ) \
        {                               \
            tptr = ptr + y*step + x*3;  \
            tptr[0] = (uchar)cb;        \
            tptr[1] = (uchar)cg;        \
            tptr[2] = (uchar)cr;        \
        }

        ICV_PUT_POINT((pt2.x + (XY_ONE >> 1)) >> XY_SHIFT,
                      (pt2.y + (XY_ONE >> 1)) >> XY_SHIFT);

        if( ax > ay )
        {
            pt1.x >>= XY_SHIFT;

            while( ecount >= 0 )
            {
                ICV_PUT_POINT(pt1.x, pt1.y >> XY_SHIFT);
                pt1.x++;
                pt1.y += y_step;
                ecount--;
            }
        }
        else
        {
            pt1.y >>= XY_SHIFT;

            while( ecount >= 0 )
            {
                ICV_PUT_POINT(pt1.x >> XY_SHIFT, pt1.y);
                pt1.x += x_step;
                pt1.y++;
                ecount--;
            }
        }

        #undef ICV_PUT_POINT
    }
    else if( pix_size == 1 )
    {
        #define  ICV_PUT_POINT(_x,_y) \
        x = (_x); y = (_y);           \
        if( 0 <= x && x < size.width && \
            0 <= y && y < size.height ) \
        {                           \
            tptr = ptr + y*step + x;\
            tptr[0] = (uchar)cb;    \
        }

        ICV_PUT_POINT((pt2.x + (XY_ONE >> 1)) >> XY_SHIFT,
                      (pt2.y + (XY_ONE >> 1)) >> XY_SHIFT);

        if( ax > ay )
        {
            pt1.x >>= XY_SHIFT;

            while( ecount >= 0 )
            {
                ICV_PUT_POINT(pt1.x, pt1.y >> XY_SHIFT);
                pt1.x++;
                pt1.y += y_step;
                ecount--;
            }
        }
        else
        {
            pt1.y >>= XY_SHIFT;

            while( ecount >= 0 )
            {
                ICV_PUT_POINT(pt1.x >> XY_SHIFT, pt1.y);
                pt1.x += x_step;
                pt1.y++;
                ecount--;
            }
        }

        #undef ICV_PUT_POINT
    }
    else
    {
        #define  ICV_PUT_POINT(_x,_y)   \
        x = (_x); y = (_y);             \
        if( 0 <= x && x < size.width && \
            0 <= y && y < size.height ) \
        {                               \
            tptr = ptr + y*step + x*pix_size;\
            for( j = 0; j < pix_size; j++ ) \
                tptr[j] = ((uchar*)color)[j]; \
        }

        ICV_PUT_POINT((pt2.x + (XY_ONE >> 1)) >> XY_SHIFT,
                      (pt2.y + (XY_ONE >> 1)) >> XY_SHIFT);

        if( ax > ay )
        {
            pt1.x >>= XY_SHIFT;

            while( ecount >= 0 )
            {
                ICV_PUT_POINT(pt1.x, pt1.y >> XY_SHIFT);
                pt1.x++;
                pt1.y += y_step;
                ecount--;
            }
        }
        else
        {
            pt1.y >>= XY_SHIFT;

            while( ecount >= 0 )
            {
                ICV_PUT_POINT(pt1.x >> XY_SHIFT, pt1.y);
                pt1.x += x_step;
                pt1.y++;
                ecount--;
            }
        }

        #undef ICV_PUT_POINT
    }
}


/****************************************************************************************\
*                   Antialiazed Elliptic Arcs via Antialiazed Lines                      *
\****************************************************************************************/

static const float SinTable[] =
    { 0.0000000f, 0.0174524f, 0.0348995f, 0.0523360f, 0.0697565f, 0.0871557f,
    0.1045285f, 0.1218693f, 0.1391731f, 0.1564345f, 0.1736482f, 0.1908090f,
    0.2079117f, 0.2249511f, 0.2419219f, 0.2588190f, 0.2756374f, 0.2923717f,
    0.3090170f, 0.3255682f, 0.3420201f, 0.3583679f, 0.3746066f, 0.3907311f,
    0.4067366f, 0.4226183f, 0.4383711f, 0.4539905f, 0.4694716f, 0.4848096f,
    0.5000000f, 0.5150381f, 0.5299193f, 0.5446390f, 0.5591929f, 0.5735764f,
    0.5877853f, 0.6018150f, 0.6156615f, 0.6293204f, 0.6427876f, 0.6560590f,
    0.6691306f, 0.6819984f, 0.6946584f, 0.7071068f, 0.7193398f, 0.7313537f,
    0.7431448f, 0.7547096f, 0.7660444f, 0.7771460f, 0.7880108f, 0.7986355f,
    0.8090170f, 0.8191520f, 0.8290376f, 0.8386706f, 0.8480481f, 0.8571673f,
    0.8660254f, 0.8746197f, 0.8829476f, 0.8910065f, 0.8987940f, 0.9063078f,
    0.9135455f, 0.9205049f, 0.9271839f, 0.9335804f, 0.9396926f, 0.9455186f,
    0.9510565f, 0.9563048f, 0.9612617f, 0.9659258f, 0.9702957f, 0.9743701f,
    0.9781476f, 0.9816272f, 0.9848078f, 0.9876883f, 0.9902681f, 0.9925462f,
    0.9945219f, 0.9961947f, 0.9975641f, 0.9986295f, 0.9993908f, 0.9998477f,
    1.0000000f, 0.9998477f, 0.9993908f, 0.9986295f, 0.9975641f, 0.9961947f,
    0.9945219f, 0.9925462f, 0.9902681f, 0.9876883f, 0.9848078f, 0.9816272f,
    0.9781476f, 0.9743701f, 0.9702957f, 0.9659258f, 0.9612617f, 0.9563048f,
    0.9510565f, 0.9455186f, 0.9396926f, 0.9335804f, 0.9271839f, 0.9205049f,
    0.9135455f, 0.9063078f, 0.8987940f, 0.8910065f, 0.8829476f, 0.8746197f,
    0.8660254f, 0.8571673f, 0.8480481f, 0.8386706f, 0.8290376f, 0.8191520f,
    0.8090170f, 0.7986355f, 0.7880108f, 0.7771460f, 0.7660444f, 0.7547096f,
    0.7431448f, 0.7313537f, 0.7193398f, 0.7071068f, 0.6946584f, 0.6819984f,
    0.6691306f, 0.6560590f, 0.6427876f, 0.6293204f, 0.6156615f, 0.6018150f,
    0.5877853f, 0.5735764f, 0.5591929f, 0.5446390f, 0.5299193f, 0.5150381f,
    0.5000000f, 0.4848096f, 0.4694716f, 0.4539905f, 0.4383711f, 0.4226183f,
    0.4067366f, 0.3907311f, 0.3746066f, 0.3583679f, 0.3420201f, 0.3255682f,
    0.3090170f, 0.2923717f, 0.2756374f, 0.2588190f, 0.2419219f, 0.2249511f,
    0.2079117f, 0.1908090f, 0.1736482f, 0.1564345f, 0.1391731f, 0.1218693f,
    0.1045285f, 0.0871557f, 0.0697565f, 0.0523360f, 0.0348995f, 0.0174524f,
    0.0000000f, -0.0174524f, -0.0348995f, -0.0523360f, -0.0697565f, -0.0871557f,
    -0.1045285f, -0.1218693f, -0.1391731f, -0.1564345f, -0.1736482f, -0.1908090f,
    -0.2079117f, -0.2249511f, -0.2419219f, -0.2588190f, -0.2756374f, -0.2923717f,
    -0.3090170f, -0.3255682f, -0.3420201f, -0.3583679f, -0.3746066f, -0.3907311f,
    -0.4067366f, -0.4226183f, -0.4383711f, -0.4539905f, -0.4694716f, -0.4848096f,
    -0.5000000f, -0.5150381f, -0.5299193f, -0.5446390f, -0.5591929f, -0.5735764f,
    -0.5877853f, -0.6018150f, -0.6156615f, -0.6293204f, -0.6427876f, -0.6560590f,
    -0.6691306f, -0.6819984f, -0.6946584f, -0.7071068f, -0.7193398f, -0.7313537f,
    -0.7431448f, -0.7547096f, -0.7660444f, -0.7771460f, -0.7880108f, -0.7986355f,
    -0.8090170f, -0.8191520f, -0.8290376f, -0.8386706f, -0.8480481f, -0.8571673f,
    -0.8660254f, -0.8746197f, -0.8829476f, -0.8910065f, -0.8987940f, -0.9063078f,
    -0.9135455f, -0.9205049f, -0.9271839f, -0.9335804f, -0.9396926f, -0.9455186f,
    -0.9510565f, -0.9563048f, -0.9612617f, -0.9659258f, -0.9702957f, -0.9743701f,
    -0.9781476f, -0.9816272f, -0.9848078f, -0.9876883f, -0.9902681f, -0.9925462f,
    -0.9945219f, -0.9961947f, -0.9975641f, -0.9986295f, -0.9993908f, -0.9998477f,
    -1.0000000f, -0.9998477f, -0.9993908f, -0.9986295f, -0.9975641f, -0.9961947f,
    -0.9945219f, -0.9925462f, -0.9902681f, -0.9876883f, -0.9848078f, -0.9816272f,
    -0.9781476f, -0.9743701f, -0.9702957f, -0.9659258f, -0.9612617f, -0.9563048f,
    -0.9510565f, -0.9455186f, -0.9396926f, -0.9335804f, -0.9271839f, -0.9205049f,
    -0.9135455f, -0.9063078f, -0.8987940f, -0.8910065f, -0.8829476f, -0.8746197f,
    -0.8660254f, -0.8571673f, -0.8480481f, -0.8386706f, -0.8290376f, -0.8191520f,
    -0.8090170f, -0.7986355f, -0.7880108f, -0.7771460f, -0.7660444f, -0.7547096f,
    -0.7431448f, -0.7313537f, -0.7193398f, -0.7071068f, -0.6946584f, -0.6819984f,
    -0.6691306f, -0.6560590f, -0.6427876f, -0.6293204f, -0.6156615f, -0.6018150f,
    -0.5877853f, -0.5735764f, -0.5591929f, -0.5446390f, -0.5299193f, -0.5150381f,
    -0.5000000f, -0.4848096f, -0.4694716f, -0.4539905f, -0.4383711f, -0.4226183f,
    -0.4067366f, -0.3907311f, -0.3746066f, -0.3583679f, -0.3420201f, -0.3255682f,
    -0.3090170f, -0.2923717f, -0.2756374f, -0.2588190f, -0.2419219f, -0.2249511f,
    -0.2079117f, -0.1908090f, -0.1736482f, -0.1564345f, -0.1391731f, -0.1218693f,
    -0.1045285f, -0.0871557f, -0.0697565f, -0.0523360f, -0.0348995f, -0.0174524f,
    -0.0000000f, 0.0174524f, 0.0348995f, 0.0523360f, 0.0697565f, 0.0871557f,
    0.1045285f, 0.1218693f, 0.1391731f, 0.1564345f, 0.1736482f, 0.1908090f,
    0.2079117f, 0.2249511f, 0.2419219f, 0.2588190f, 0.2756374f, 0.2923717f,
    0.3090170f, 0.3255682f, 0.3420201f, 0.3583679f, 0.3746066f, 0.3907311f,
    0.4067366f, 0.4226183f, 0.4383711f, 0.4539905f, 0.4694716f, 0.4848096f,
    0.5000000f, 0.5150381f, 0.5299193f, 0.5446390f, 0.5591929f, 0.5735764f,
    0.5877853f, 0.6018150f, 0.6156615f, 0.6293204f, 0.6427876f, 0.6560590f,
    0.6691306f, 0.6819984f, 0.6946584f, 0.7071068f, 0.7193398f, 0.7313537f,
    0.7431448f, 0.7547096f, 0.7660444f, 0.7771460f, 0.7880108f, 0.7986355f,
    0.8090170f, 0.8191520f, 0.8290376f, 0.8386706f, 0.8480481f, 0.8571673f,
    0.8660254f, 0.8746197f, 0.8829476f, 0.8910065f, 0.8987940f, 0.9063078f,
    0.9135455f, 0.9205049f, 0.9271839f, 0.9335804f, 0.9396926f, 0.9455186f,
    0.9510565f, 0.9563048f, 0.9612617f, 0.9659258f, 0.9702957f, 0.9743701f,
    0.9781476f, 0.9816272f, 0.9848078f, 0.9876883f, 0.9902681f, 0.9925462f,
    0.9945219f, 0.9961947f, 0.9975641f, 0.9986295f, 0.9993908f, 0.9998477f,
    1.0000000f
};


static void
sincos( int angle, float& cosval, float& sinval )
{
    angle += (angle < 0 ? 360 : 0);
    sinval = SinTable[angle];
    cosval = SinTable[450 - angle];
}

/*
   constructs polygon that represents elliptic arc.
*/
void ellipse2Poly( Point center, Size axes, int angle,
                   int arc_start, int arc_end,
                   int delta, vector<Point>& pts )
{
    float alpha, beta;
    double size_a = axes.width, size_b = axes.height;
    double cx = center.x, cy = center.y;
    Point prevPt(INT_MIN,INT_MIN);
    int i;

    while( angle < 0 )
        angle += 360;
    while( angle > 360 )
        angle -= 360;

    if( arc_start > arc_end )
    {
        i = arc_start;
        arc_start = arc_end;
        arc_end = i;
    }
    while( arc_start < 0 )
    {
        arc_start += 360;
        arc_end += 360;
    }
    while( arc_end > 360 )
    {
        arc_end -= 360;
        arc_start -= 360;
    }
    if( arc_end - arc_start > 360 )
    {
        arc_start = 0;
        arc_end = 360;
    }
    sincos( angle, alpha, beta );
    pts.resize(0);

    for( i = arc_start; i < arc_end + delta; i += delta )
    {
        double x, y;
        angle = i;
        if( angle > arc_end )
            angle = arc_end;
        if( angle < 0 )
            angle += 360;

        x = size_a * SinTable[450-angle];
        y = size_b * SinTable[angle];
        Point pt;
        pt.x = cvRound( cx + x * alpha - y * beta );
        pt.y = cvRound( cy + x * beta + y * alpha );
        if( pt != prevPt )
            pts.push_back(pt);
    }

    if( pts.size() < 2 )
        pts.push_back(pts[0]);
}


static void
EllipseEx( Mat& img, Point center, Size axes,
           int angle, int arc_start, int arc_end,
           const void* color, int thickness, int line_type )
{
    axes.width = std::abs(axes.width), axes.height = std::abs(axes.height);
    int delta = (std::max(axes.width,axes.height)+(XY_ONE>>1))>>XY_SHIFT;
    delta = delta < 3 ? 90 : delta < 10 ? 30 : delta < 15 ? 18 : 5;

    vector<Point> v;
    ellipse2Poly( center, axes, angle, arc_start, arc_end, delta, v );

    if( thickness >= 0 )
        PolyLine( img, &v[0], (int)v.size(), false, color, thickness, line_type, XY_SHIFT );
    else if( arc_end - arc_start >= 360 )
        FillConvexPoly( img, &v[0], (int)v.size(), color, line_type, XY_SHIFT );
    else
    {
#if 0
        v.push_back(center);
        vector<PolyEdge> edges;
        CollectPolyEdges( img,  &v[0], (int)v.size(), edges, color, line_type, XY_SHIFT );
        FillEdgeCollection( img, edges, color );
#else
        CV_Assert(0);
#endif
    }
}


/****************************************************************************************\
*                                Polygons filling                                        *
\****************************************************************************************/

/* helper macros: filling horizontal row */
#define ICV_HLINE( ptr, xl, xr, color, pix_size )            \
{                                                            \
    uchar* hline_ptr = (uchar*)(ptr) + (xl)*(pix_size);      \
    uchar* hline_max_ptr = (uchar*)(ptr) + (xr)*(pix_size);  \
                                                             \
    for( ; hline_ptr <= hline_max_ptr; hline_ptr += (pix_size))\
    {                                                        \
        int hline_j;                                         \
        for( hline_j = 0; hline_j < (pix_size); hline_j++ )  \
        {                                                    \
            hline_ptr[hline_j] = ((uchar*)color)[hline_j];   \
        }                                                    \
    }                                                        \
}


/* filling convex polygon. v - array of vertices, ntps - number of points */
static void
FillConvexPoly( Mat& img, const Point* v, int npts, const void* color, int line_type, int shift )
{
    struct
    {
        int idx, di;
        int x, dx, ye;
    }
    edge[2];

    int delta = shift ? 1 << (shift - 1) : 0;
    int i, y, imin = 0, left = 0, right = 1, x1, x2;
    int edges = npts;
    int xmin, xmax, ymin, ymax;
    uchar* ptr = img.data;
    Size size = img.size();
    int pix_size = (int)img.elemSize();
    Point p0;
    int delta1, delta2;

    if( line_type < CV_AA )
        delta1 = delta2 = XY_ONE >> 1;
    else
        delta1 = XY_ONE - 1, delta2 = 0;

    p0 = v[npts - 1];
    p0.x <<= XY_SHIFT - shift;
    p0.y <<= XY_SHIFT - shift;

    assert( 0 <= shift && shift <= XY_SHIFT );
    xmin = xmax = v[0].x;
    ymin = ymax = v[0].y;

    for( i = 0; i < npts; i++ )
    {
        Point p = v[i];
        if( p.y < ymin )
        {
            ymin = p.y;
            imin = i;
        }

        ymax = std::max( ymax, p.y );
        xmax = std::max( xmax, p.x );
        xmin = MIN( xmin, p.x );

        p.x <<= XY_SHIFT - shift;
        p.y <<= XY_SHIFT - shift;

        if( line_type <= 8 )
        {
            if( shift == 0 )
            {
                Point pt0, pt1;
                pt0.x = p0.x >> XY_SHIFT;
                pt0.y = p0.y >> XY_SHIFT;
                pt1.x = p.x >> XY_SHIFT;
                pt1.y = p.y >> XY_SHIFT;
                Line( img, pt0, pt1, color, line_type );
            }
            else
                Line2( img, p0, p, color );
        }
        else
        {
#if 0
            LineAA( img, p0, p, color );
#else
            CV_Assert(0);
#endif
        }
        p0 = p;
    }

    xmin = (xmin + delta) >> shift;
    xmax = (xmax + delta) >> shift;
    ymin = (ymin + delta) >> shift;
    ymax = (ymax + delta) >> shift;

    if( npts < 3 || xmax < 0 || ymax < 0 || xmin >= size.width || ymin >= size.height )
        return;

    ymax = MIN( ymax, size.height - 1 );
    edge[0].idx = edge[1].idx = imin;

    edge[0].ye = edge[1].ye = y = ymin;
    edge[0].di = 1;
    edge[1].di = npts - 1;

    ptr += img.step*y;

    do
    {
        if( line_type < CV_AA || y < ymax || y == ymin )
        {
            for( i = 0; i < 2; i++ )
            {
                if( y >= edge[i].ye )
                {
                    int idx = edge[i].idx, di = edge[i].di;
                    int xs = 0, xe, ye, ty = 0;

                    for(;;)
                    {
                        ty = (v[idx].y + delta) >> shift;
                        if( ty > y || edges == 0 )
                            break;
                        xs = v[idx].x;
                        idx += di;
                        idx -= ((idx < npts) - 1) & npts;   /* idx -= idx >= npts ? npts : 0 */
                        edges--;
                    }

                    ye = ty;
                    xs <<= XY_SHIFT - shift;
                    xe = v[idx].x << (XY_SHIFT - shift);

                    /* no more edges */
                    if( y >= ye )
                        return;

                    edge[i].ye = ye;
                    edge[i].dx = ((xe - xs)*2 + (ye - y)) / (2 * (ye - y));
                    edge[i].x = xs;
                    edge[i].idx = idx;
                }
            }
        }

        if( edge[left].x > edge[right].x )
        {
            left ^= 1;
            right ^= 1;
        }

        x1 = edge[left].x;
        x2 = edge[right].x;

        if( y >= 0 )
        {
            int xx1 = (x1 + delta1) >> XY_SHIFT;
            int xx2 = (x2 + delta2) >> XY_SHIFT;

            if( xx2 >= 0 && xx1 < size.width )
            {
                if( xx1 < 0 )
                    xx1 = 0;
                if( xx2 >= size.width )
                    xx2 = size.width - 1;
                ICV_HLINE( ptr, xx1, xx2, color, pix_size );
            }
        }

        x1 += edge[left].dx;
        x2 += edge[right].dx;

        edge[left].x = x1;
        edge[right].x = x2;
        ptr += img.step;
    }
    while( ++y <= ymax );
}

/* draws simple or filled circle */
static void
Circle( Mat& img, Point center, int radius, const void* color, int fill )
{
    Size size = img.size();
    size_t step = img.step;
    int pix_size = (int)img.elemSize();
    uchar* ptr = img.data;
    int err = 0, dx = radius, dy = 0, plus = 1, minus = (radius << 1) - 1;
    int inside = center.x >= radius && center.x < size.width - radius &&
        center.y >= radius && center.y < size.height - radius;

    #define ICV_PUT_POINT( ptr, x )     \
        memcpy( ptr + (x)*pix_size, color, pix_size );

    while( dx >= dy )
    {
        int mask;
        int y11 = center.y - dy, y12 = center.y + dy, y21 = center.y - dx, y22 = center.y + dx;
        int x11 = center.x - dx, x12 = center.x + dx, x21 = center.x - dy, x22 = center.x + dy;

        if( inside )
        {
            uchar *tptr0 = ptr + y11 * step;
            uchar *tptr1 = ptr + y12 * step;

            if( !fill )
            {
                ICV_PUT_POINT( tptr0, x11 );
                ICV_PUT_POINT( tptr1, x11 );
                ICV_PUT_POINT( tptr0, x12 );
                ICV_PUT_POINT( tptr1, x12 );
            }
            else
            {
                ICV_HLINE( tptr0, x11, x12, color, pix_size );
                ICV_HLINE( tptr1, x11, x12, color, pix_size );
            }

            tptr0 = ptr + y21 * step;
            tptr1 = ptr + y22 * step;

            if( !fill )
            {
                ICV_PUT_POINT( tptr0, x21 );
                ICV_PUT_POINT( tptr1, x21 );
                ICV_PUT_POINT( tptr0, x22 );
                ICV_PUT_POINT( tptr1, x22 );
            }
            else
            {
                ICV_HLINE( tptr0, x21, x22, color, pix_size );
                ICV_HLINE( tptr1, x21, x22, color, pix_size );
            }
        }
        else if( x11 < size.width && x12 >= 0 && y21 < size.height && y22 >= 0 )
        {
            if( fill )
            {
                x11 = std::max( x11, 0 );
                x12 = MIN( x12, size.width - 1 );
            }

            if( (unsigned)y11 < (unsigned)size.height )
            {
                uchar *tptr = ptr + y11 * step;

                if( !fill )
                {
                    if( x11 >= 0 )
                        ICV_PUT_POINT( tptr, x11 );
                    if( x12 < size.width )
                        ICV_PUT_POINT( tptr, x12 );
                }
                else
                    ICV_HLINE( tptr, x11, x12, color, pix_size );
            }

            if( (unsigned)y12 < (unsigned)size.height )
            {
                uchar *tptr = ptr + y12 * step;

                if( !fill )
                {
                    if( x11 >= 0 )
                        ICV_PUT_POINT( tptr, x11 );
                    if( x12 < size.width )
                        ICV_PUT_POINT( tptr, x12 );
                }
                else
                    ICV_HLINE( tptr, x11, x12, color, pix_size );
            }

            if( x21 < size.width && x22 >= 0 )
            {
                if( fill )
                {
                    x21 = std::max( x21, 0 );
                    x22 = MIN( x22, size.width - 1 );
                }

                if( (unsigned)y21 < (unsigned)size.height )
                {
                    uchar *tptr = ptr + y21 * step;

                    if( !fill )
                    {
                        if( x21 >= 0 )
                            ICV_PUT_POINT( tptr, x21 );
                        if( x22 < size.width )
                            ICV_PUT_POINT( tptr, x22 );
                    }
                    else
                        ICV_HLINE( tptr, x21, x22, color, pix_size );
                }

                if( (unsigned)y22 < (unsigned)size.height )
                {
                    uchar *tptr = ptr + y22 * step;

                    if( !fill )
                    {
                        if( x21 >= 0 )
                            ICV_PUT_POINT( tptr, x21 );
                        if( x22 < size.width )
                            ICV_PUT_POINT( tptr, x22 );
                    }
                    else
                        ICV_HLINE( tptr, x21, x22, color, pix_size );
                }
            }
        }
        dy++;
        err += plus;
        plus += 2;

        mask = (err <= 0) - 1;

        err -= minus & mask;
        dx += mask;
        minus -= mask & 2;
    }

    #undef  ICV_PUT_POINT
}


static void
ThickLine( Mat& img, Point p0, Point p1, const void* color,
           int thickness, int line_type, int flags, int shift )
{
    static const double INV_XY_ONE = 1./XY_ONE;

    p0.x <<= XY_SHIFT - shift;
    p0.y <<= XY_SHIFT - shift;
    p1.x <<= XY_SHIFT - shift;
    p1.y <<= XY_SHIFT - shift;

    if( thickness <= 1 )
    {
        if( line_type < CV_AA )
        {
            if( line_type == 1 || line_type == 4 || shift == 0 )
            {
                p0.x = (p0.x + (XY_ONE>>1)) >> XY_SHIFT;
                p0.y = (p0.y + (XY_ONE>>1)) >> XY_SHIFT;
                p1.x = (p1.x + (XY_ONE>>1)) >> XY_SHIFT;
                p1.y = (p1.y + (XY_ONE>>1)) >> XY_SHIFT;
                Line( img, p0, p1, color, line_type );
            }
            else
                Line2( img, p0, p1, color );
        }
        else
        {
#if 0
            LineAA( img, p0, p1, color );
#else
            CV_Assert(0);
#endif
        }
    }
    else
    {
        Point pt[4], dp = Point(0,0);
        double dx = (p0.x - p1.x)*INV_XY_ONE, dy = (p1.y - p0.y)*INV_XY_ONE;
        double r = dx * dx + dy * dy;
        int i, oddThickness = thickness & 1;
        thickness <<= XY_SHIFT - 1;

        if( fabs(r) > DBL_EPSILON )
        {
            r = (thickness + oddThickness*XY_ONE*0.5)/std::sqrt(r);
            dp.x = cvRound( dy * r );
            dp.y = cvRound( dx * r );

            pt[0].x = p0.x + dp.x;
            pt[0].y = p0.y + dp.y;
            pt[1].x = p0.x - dp.x;
            pt[1].y = p0.y - dp.y;
            pt[2].x = p1.x - dp.x;
            pt[2].y = p1.y - dp.y;
            pt[3].x = p1.x + dp.x;
            pt[3].y = p1.y + dp.y;

            FillConvexPoly( img, pt, 4, color, line_type, XY_SHIFT );
        }

        for( i = 0; i < 2; i++ )
        {
            if( flags & (i+1) )
            {
                if( line_type < CV_AA )
                {
                    Point center;
                    center.x = (p0.x + (XY_ONE>>1)) >> XY_SHIFT;
                    center.y = (p0.y + (XY_ONE>>1)) >> XY_SHIFT;
                    Circle( img, center, (thickness + (XY_ONE>>1)) >> XY_SHIFT, color, 1 );
                }
                else
                {
                    EllipseEx( img, p0, cvSize(thickness, thickness),
                               0, 0, 360, color, -1, line_type );
                }
            }
            p0 = p1;
        }
    }
}


static void
PolyLine( Mat& img, const Point* v, int count, bool is_closed,
          const void* color, int thickness,
          int line_type, int shift )
{
    if( !v || count <= 0 )
        return;

    int i = is_closed ? count - 1 : 0;
    int flags = 2 + !is_closed;
    Point p0;
    CV_Assert( 0 <= shift && shift <= XY_SHIFT && thickness >= 0 );

    p0 = v[i];
    for( i = !is_closed; i < count; i++ )
    {
        Point p = v[i];
        ThickLine( img, p0, p, color, thickness, line_type, flags, shift );
        p0 = p;
        flags = 2;
    }
}

/****************************************************************************************\
*                              External functions                                        *
\****************************************************************************************/

void line( Mat& img, Point pt1, Point pt2, const Scalar& color,
           int thickness, int line_type, int shift )
{
    if( line_type == CV_AA && img.depth() != CV_8U )
        line_type = 8;

    CV_Assert( 0 <= thickness && thickness <= 255 );
    CV_Assert( 0 <= shift && shift <= XY_SHIFT );

    double buf[4];
    scalarToRawData( color, buf, img.type(), 0 );
    ThickLine( img, pt1, pt2, buf, thickness, line_type, 3, shift );
}


void circle( Mat& img, Point center, int radius,
             const Scalar& color, int thickness, int line_type, int shift )
{
    if( line_type == CV_AA && img.depth() != CV_8U )
        line_type = 8;

    CV_Assert( radius >= 0 && thickness <= 255 &&
        0 <= shift && shift <= XY_SHIFT );

    double buf[4];
    scalarToRawData(color, buf, img.type(), 0);

    if( thickness > 1 || line_type >= CV_AA )
    {
        center.x <<= XY_SHIFT - shift;
        center.y <<= XY_SHIFT - shift;
        radius <<= XY_SHIFT - shift;
        EllipseEx( img, center, Size(radius, radius),
                   0, 0, 360, buf, thickness, line_type );
    }
    else
        Circle( img, center, radius, buf, thickness < 0 );
}

}

/* End of file. */
