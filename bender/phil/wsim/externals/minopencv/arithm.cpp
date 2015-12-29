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

/* ////////////////////////////////////////////////////////////////////
//
//  Arithmetic and logical operations: +, -, *, /, &, |, ^, ~, abs ...
//
// */

#include <iostream>

#include <opencv2/core_c.h>
#include <opencv2/core.hpp>
#include <opencv2/internal.hpp>
#include <opencv2/mat.hpp>
#define USE_SSE2 false

//extern const uchar g_Saturate8u[];
const uchar g_Saturate8u[] =
{
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,  12,  13,  14,  15,
     16,  17,  18,  19,  20,  21,  22,  23,  24,  25,  26,  27,  28,  29,  30,  31,
     32,  33,  34,  35,  36,  37,  38,  39,  40,  41,  42,  43,  44,  45,  46,  47,
     48,  49,  50,  51,  52,  53,  54,  55,  56,  57,  58,  59,  60,  61,  62,  63,
     64,  65,  66,  67,  68,  69,  70,  71,  72,  73,  74,  75,  76,  77,  78,  79,
     80,  81,  82,  83,  84,  85,  86,  87,  88,  89,  90,  91,  92,  93,  94,  95,
     96,  97,  98,  99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111,
    112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127,
    128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143,
    144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159,
    160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175,
    176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191,
    192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207,
    208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223,
    224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239,
    240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255
};

#define CV_FAST_CAST_8U(t)   (assert(-256 <= (t) && (t) <= 512), g_Saturate8u[(t)+256])
#define CV_MIN_8U(a,b)       ((a) - CV_FAST_CAST_8U((a) - (b)))
#define CV_MAX_8U(a,b)       ((a) + CV_FAST_CAST_8U((b) - (a)))

// -128.f ... 255.f
//extern const float g_8x32fTab[];
const float g_8x32fTab[] =
{
    -128.f, -127.f, -126.f, -125.f, -124.f, -123.f, -122.f, -121.f,
    -120.f, -119.f, -118.f, -117.f, -116.f, -115.f, -114.f, -113.f,
    -112.f, -111.f, -110.f, -109.f, -108.f, -107.f, -106.f, -105.f,
    -104.f, -103.f, -102.f, -101.f, -100.f,  -99.f,  -98.f,  -97.f,
     -96.f,  -95.f,  -94.f,  -93.f,  -92.f,  -91.f,  -90.f,  -89.f,
     -88.f,  -87.f,  -86.f,  -85.f,  -84.f,  -83.f,  -82.f,  -81.f,
     -80.f,  -79.f,  -78.f,  -77.f,  -76.f,  -75.f,  -74.f,  -73.f,
     -72.f,  -71.f,  -70.f,  -69.f,  -68.f,  -67.f,  -66.f,  -65.f,
     -64.f,  -63.f,  -62.f,  -61.f,  -60.f,  -59.f,  -58.f,  -57.f,
     -56.f,  -55.f,  -54.f,  -53.f,  -52.f,  -51.f,  -50.f,  -49.f,
     -48.f,  -47.f,  -46.f,  -45.f,  -44.f,  -43.f,  -42.f,  -41.f,
     -40.f,  -39.f,  -38.f,  -37.f,  -36.f,  -35.f,  -34.f,  -33.f,
     -32.f,  -31.f,  -30.f,  -29.f,  -28.f,  -27.f,  -26.f,  -25.f,
     -24.f,  -23.f,  -22.f,  -21.f,  -20.f,  -19.f,  -18.f,  -17.f,
     -16.f,  -15.f,  -14.f,  -13.f,  -12.f,  -11.f,  -10.f,   -9.f,
      -8.f,   -7.f,   -6.f,   -5.f,   -4.f,   -3.f,   -2.f,   -1.f,
       0.f,    1.f,    2.f,    3.f,    4.f,    5.f,    6.f,    7.f,
       8.f,    9.f,   10.f,   11.f,   12.f,   13.f,   14.f,   15.f,
      16.f,   17.f,   18.f,   19.f,   20.f,   21.f,   22.f,   23.f,
      24.f,   25.f,   26.f,   27.f,   28.f,   29.f,   30.f,   31.f,
      32.f,   33.f,   34.f,   35.f,   36.f,   37.f,   38.f,   39.f,
      40.f,   41.f,   42.f,   43.f,   44.f,   45.f,   46.f,   47.f,
      48.f,   49.f,   50.f,   51.f,   52.f,   53.f,   54.f,   55.f,
      56.f,   57.f,   58.f,   59.f,   60.f,   61.f,   62.f,   63.f,
      64.f,   65.f,   66.f,   67.f,   68.f,   69.f,   70.f,   71.f,
      72.f,   73.f,   74.f,   75.f,   76.f,   77.f,   78.f,   79.f,
      80.f,   81.f,   82.f,   83.f,   84.f,   85.f,   86.f,   87.f,
      88.f,   89.f,   90.f,   91.f,   92.f,   93.f,   94.f,   95.f,
      96.f,   97.f,   98.f,   99.f,  100.f,  101.f,  102.f,  103.f,
     104.f,  105.f,  106.f,  107.f,  108.f,  109.f,  110.f,  111.f,
     112.f,  113.f,  114.f,  115.f,  116.f,  117.f,  118.f,  119.f,
     120.f,  121.f,  122.f,  123.f,  124.f,  125.f,  126.f,  127.f,
     128.f,  129.f,  130.f,  131.f,  132.f,  133.f,  134.f,  135.f,
     136.f,  137.f,  138.f,  139.f,  140.f,  141.f,  142.f,  143.f,
     144.f,  145.f,  146.f,  147.f,  148.f,  149.f,  150.f,  151.f,
     152.f,  153.f,  154.f,  155.f,  156.f,  157.f,  158.f,  159.f,
     160.f,  161.f,  162.f,  163.f,  164.f,  165.f,  166.f,  167.f,
     168.f,  169.f,  170.f,  171.f,  172.f,  173.f,  174.f,  175.f,
     176.f,  177.f,  178.f,  179.f,  180.f,  181.f,  182.f,  183.f,
     184.f,  185.f,  186.f,  187.f,  188.f,  189.f,  190.f,  191.f,
     192.f,  193.f,  194.f,  195.f,  196.f,  197.f,  198.f,  199.f,
     200.f,  201.f,  202.f,  203.f,  204.f,  205.f,  206.f,  207.f,
     208.f,  209.f,  210.f,  211.f,  212.f,  213.f,  214.f,  215.f,
     216.f,  217.f,  218.f,  219.f,  220.f,  221.f,  222.f,  223.f,
     224.f,  225.f,  226.f,  227.f,  228.f,  229.f,  230.f,  231.f,
     232.f,  233.f,  234.f,  235.f,  236.f,  237.f,  238.f,  239.f,
     240.f,  241.f,  242.f,  243.f,  244.f,  245.f,  246.f,  247.f,
     248.f,  249.f,  250.f,  251.f,  252.f,  253.f,  254.f,  255.f
};
#define CV_8TO32F(x)  g_8x32fTab[(x)+128]

namespace cv
{

struct NOP {};

template<class Op, class Op64>
void vBinOp64f(const double* src1, size_t step1, const double* src2, size_t step2,
               double* dst, size_t step, Size sz)
{
#if CV_SSE2
    Op64 op64;
#endif
    Op op;

    for( ; sz.height--; src1 += step1/sizeof(src1[0]),
        src2 += step2/sizeof(src2[0]),
        dst += step/sizeof(dst[0]) )
    {
        int x = 0;

    #if CV_SSE2
        if( USE_SSE2 && (((size_t)src1|(size_t)src2|(size_t)dst)&15) == 0 )
            for( ; x <= sz.width - 4; x += 4 )
            {
                __m128d r0 = _mm_load_pd(src1 + x);
                __m128d r1 = _mm_load_pd(src1 + x + 2);
                r0 = op64(r0,_mm_load_pd(src2 + x));
                r1 = op64(r1,_mm_load_pd(src2 + x + 2));
                _mm_store_pd(dst + x, r0);
                _mm_store_pd(dst + x + 2, r1);
            }
        else
    #endif
        for( ; x <= sz.width - 4; x += 4 )
        {
            double v0 = op(src1[x], src2[x]);
            double v1 = op(src1[x+1], src2[x+1]);
            dst[x] = v0; dst[x+1] = v1;
            v0 = op(src1[x+2], src2[x+2]);
            v1 = op(src1[x+3], src2[x+3]);
            dst[x+2] = v0; dst[x+3] = v1;
        }

        for( ; x < sz.width; x++ )
            dst[x] = op(src1[x], src2[x]);
    }
}

#if CV_SSE2

struct _VAdd8u { __m128i operator()(const __m128i& a, const __m128i& b) const { return _mm_adds_epu8(a,b); }};
struct _VSub8u { __m128i operator()(const __m128i& a, const __m128i& b) const { return _mm_subs_epu8(a,b); }};
struct _VMin8u { __m128i operator()(const __m128i& a, const __m128i& b) const { return _mm_min_epu8(a,b); }};
struct _VMax8u { __m128i operator()(const __m128i& a, const __m128i& b) const { return _mm_max_epu8(a,b); }};
struct _VAbsDiff8u
{
    __m128i operator()(const __m128i& a, const __m128i& b) const
    { return _mm_add_epi8(_mm_subs_epu8(a,b),_mm_subs_epu8(b,a)); }
};

struct _VAdd8s { __m128i operator()(const __m128i& a, const __m128i& b) const { return _mm_adds_epi8(a,b); }};
struct _VSub8s { __m128i operator()(const __m128i& a, const __m128i& b) const { return _mm_subs_epi8(a,b); }};
struct _VMin8s
{
    __m128i operator()(const __m128i& a, const __m128i& b) const
    {
        __m128i m = _mm_cmpgt_epi8(a, b);
        return _mm_xor_si128(a, _mm_and_si128(_mm_xor_si128(a, b), m));
    }
};
struct _VMax8s
{
    __m128i operator()(const __m128i& a, const __m128i& b) const
    {
        __m128i m = _mm_cmpgt_epi8(b, a);
        return _mm_xor_si128(a, _mm_and_si128(_mm_xor_si128(a, b), m));
    }
};
struct _VAbsDiff8s
{
    __m128i operator()(const __m128i& a, const __m128i& b) const
    {
        __m128i d = _mm_subs_epi8(a, b);
        __m128i m = _mm_cmpgt_epi8(b, a);
        return _mm_subs_epi8(_mm_xor_si128(d, m), m);
    }
};

struct _VAdd16u { __m128i operator()(const __m128i& a, const __m128i& b) const { return _mm_adds_epu16(a,b); }};
struct _VSub16u { __m128i operator()(const __m128i& a, const __m128i& b) const { return _mm_subs_epu16(a,b); }};
struct _VMin16u
{
    __m128i operator()(const __m128i& a, const __m128i& b) const
    { return _mm_subs_epu16(a,_mm_subs_epu16(a,b)); }
};
struct _VMax16u
{
    __m128i operator()(const __m128i& a, const __m128i& b) const
    { return _mm_adds_epu16(_mm_subs_epu16(a,b),b); }
};
struct _VAbsDiff16u
{
    __m128i operator()(const __m128i& a, const __m128i& b) const
    { return _mm_add_epi16(_mm_subs_epu16(a,b),_mm_subs_epu16(b,a)); }
};

struct _VAdd16s { __m128i operator()(const __m128i& a, const __m128i& b) const { return _mm_adds_epi16(a,b); }};
struct _VSub16s { __m128i operator()(const __m128i& a, const __m128i& b) const { return _mm_subs_epi16(a,b); }};
struct _VMin16s { __m128i operator()(const __m128i& a, const __m128i& b) const { return _mm_min_epi16(a,b); }};
struct _VMax16s { __m128i operator()(const __m128i& a, const __m128i& b) const { return _mm_max_epi16(a,b); }};
struct _VAbsDiff16s
{
    __m128i operator()(const __m128i& a, const __m128i& b) const
    {
        __m128i M = _mm_max_epi16(a,b), m = _mm_min_epi16(a,b);
        return _mm_subs_epi16(M, m);
    }
};

struct _VAdd32s { __m128i operator()(const __m128i& a, const __m128i& b) const { return _mm_add_epi32(a,b); }};
struct _VSub32s { __m128i operator()(const __m128i& a, const __m128i& b) const { return _mm_sub_epi32(a,b); }};
struct _VMin32s
{
    __m128i operator()(const __m128i& a, const __m128i& b) const
    {
        __m128i m = _mm_cmpgt_epi32(a, b);
        return _mm_xor_si128(a, _mm_and_si128(_mm_xor_si128(a, b), m));
    }
};
struct _VMax32s
{
    __m128i operator()(const __m128i& a, const __m128i& b) const
    {
        __m128i m = _mm_cmpgt_epi32(b, a);
        return _mm_xor_si128(a, _mm_and_si128(_mm_xor_si128(a, b), m));
    }
};
struct _VAbsDiff32s
{
    __m128i operator()(const __m128i& a, const __m128i& b) const
    {
        __m128i d = _mm_sub_epi32(a, b);
        __m128i m = _mm_cmpgt_epi32(b, a);
        return _mm_sub_epi32(_mm_xor_si128(d, m), m);
    }
};

struct _VAdd32f { __m128 operator()(const __m128& a, const __m128& b) const { return _mm_add_ps(a,b); }};
struct _VSub32f { __m128 operator()(const __m128& a, const __m128& b) const { return _mm_sub_ps(a,b); }};
struct _VMin32f { __m128 operator()(const __m128& a, const __m128& b) const { return _mm_min_ps(a,b); }};
struct _VMax32f { __m128 operator()(const __m128& a, const __m128& b) const { return _mm_max_ps(a,b); }};
static unsigned int CV_DECL_ALIGNED(16) v32f_absmask[] = { 0x7fffffff, 0x7fffffff, 0x7fffffff, 0x7fffffff };
struct _VAbsDiff32f
{
    __m128 operator()(const __m128& a, const __m128& b) const
    {
        return _mm_and_ps(_mm_sub_ps(a,b), *(const __m128*)v32f_absmask);
    }
};

struct _VAdd64f { __m128d operator()(const __m128d& a, const __m128d& b) const { return _mm_add_pd(a,b); }};
struct _VSub64f { __m128d operator()(const __m128d& a, const __m128d& b) const { return _mm_sub_pd(a,b); }};
struct _VMin64f { __m128d operator()(const __m128d& a, const __m128d& b) const { return _mm_min_pd(a,b); }};
struct _VMax64f { __m128d operator()(const __m128d& a, const __m128d& b) const { return _mm_max_pd(a,b); }};

static unsigned int CV_DECL_ALIGNED(16) v64f_absmask[] = { 0xffffffff, 0x7fffffff, 0xffffffff, 0x7fffffff };
struct _VAbsDiff64f
{
    __m128d operator()(const __m128d& a, const __m128d& b) const
    {
        return _mm_and_pd(_mm_sub_pd(a,b), *(const __m128d*)v64f_absmask);
    }
};

struct _VAnd8u { __m128i operator()(const __m128i& a, const __m128i& b) const { return _mm_and_si128(a,b); }};
struct _VOr8u  { __m128i operator()(const __m128i& a, const __m128i& b) const { return _mm_or_si128(a,b); }};
struct _VXor8u { __m128i operator()(const __m128i& a, const __m128i& b) const { return _mm_xor_si128(a,b); }};
struct _VNot8u { __m128i operator()(const __m128i& a, const __m128i&) const { return _mm_xor_si128(_mm_set1_epi32(-1),a); }};

#endif

#if CV_SSE2
#define IF_SIMD(op) op
#else
#define IF_SIMD(op) NOP
#endif

template<> inline uchar OpAdd<uchar>::operator ()(uchar a, uchar b) const
{ return CV_FAST_CAST_8U(a + b); }
template<> inline uchar OpSub<uchar>::operator ()(uchar a, uchar b) const
{ return CV_FAST_CAST_8U(a - b); }

template<typename T> struct OpAbsDiff
{
    typedef T type1;
    typedef T type2;
    typedef T rtype;
    T operator()(T a, T b) const { return (T)std::abs(a - b); }
};

template<> inline short OpAbsDiff<short>::operator ()(short a, short b) const
{ return saturate_cast<short>(std::abs(a - b)); }

template<> inline schar OpAbsDiff<schar>::operator ()(schar a, schar b) const
{ return saturate_cast<schar>(std::abs(a - b)); }

template<typename T, typename WT=T> struct OpAbsDiffS
{
    typedef T type1;
    typedef WT type2;
    typedef T rtype;
    T operator()(T a, WT b) const { return saturate_cast<T>(std::abs(a - b)); }
};

template<typename T> struct OpAnd
{
    typedef T type1;
    typedef T type2;
    typedef T rtype;
    T operator()( T a, T b ) const { return a & b; }
};

template<typename T> struct OpOr
{
    typedef T type1;
    typedef T type2;
    typedef T rtype;
    T operator()( T a, T b ) const { return a | b; }
};

template<typename T> struct OpXor
{
    typedef T type1;
    typedef T type2;
    typedef T rtype;
    T operator()( T a, T b ) const { return a ^ b; }
};

template<typename T> struct OpNot
{
    typedef T type1;
    typedef T type2;
    typedef T rtype;
    T operator()( T a, T ) const { return ~a; }
};

static inline void fixSteps(Size sz, size_t elemSize, size_t& step1, size_t& step2, size_t& step)
{
    if( sz.height == 1 )
        step1 = step2 = step = sz.width*elemSize;
}

static void add64f( const double* src1, size_t step1,
                    const double* src2, size_t step2,
                    double* dst, size_t step, Size sz, void* )
{
    vBinOp64f<OpAdd<double>, IF_SIMD(_VAdd64f)>(src1, step1, src2, step2, dst, step, sz);
}

static void sub64f( const double* src1, size_t step1,
                    const double* src2, size_t step2,
                    double* dst, size_t step, Size sz, void* )
{
    vBinOp64f<OpSub<double>, IF_SIMD(_VSub64f)>(src1, step1, src2, step2, dst, step, sz);
}

/****************************************************************************************\
*                                   logical operations                                   *
\****************************************************************************************/

void convertAndUnrollScalar( const Mat& sc, int buftype, uchar* scbuf, size_t blocksize )
{
    int scn = (int)sc.total(), cn = CV_MAT_CN(buftype);
    size_t esz = CV_ELEM_SIZE(buftype);
    getConvertFunc(sc.depth(), buftype)(sc.data, 0, 0, 0, scbuf, 0, Size(std::min(cn, scn), 1), 0);
    // unroll the scalar
    if( scn < cn )
    {
        CV_Assert( scn == 1 );
        size_t esz1 = CV_ELEM_SIZE1(buftype);
        for( size_t i = esz1; i < esz; i++ )
            scbuf[i] = scbuf[i - esz1];
    }
    for( size_t i = esz; i < blocksize*esz; i++ )
        scbuf[i] = scbuf[i - esz];
}

}

/****************************************************************************************\
*                                      add/subtract                                      *
\****************************************************************************************/

namespace cv
{

static int actualScalarDepth(const double* data, int len)
{
    int i = 0, minval = INT_MAX, maxval = INT_MIN;
    for(; i < len; ++i)
    {
        int ival = cvRound(data[i]);
        if( ival != data[i] )
            break;
        minval = MIN(minval, ival);
        maxval = MAX(maxval, ival);
    }
    return i < len ? CV_64F :
        minval >= 0 && maxval <= (int)UCHAR_MAX ? CV_8U :
        minval >= (int)SCHAR_MIN && maxval <= (int)SCHAR_MAX ? CV_8S :
        minval >= 0 && maxval <= (int)USHRT_MAX ? CV_16U :
        minval >= (int)SHRT_MIN && maxval <= (int)SHRT_MAX ? CV_16S :
        CV_32S;
}

static void arithm_op(InputArray _src1, InputArray _src2, OutputArray _dst,
               InputArray _mask, int dtype, BinaryFunc* tab, bool muldiv=false, void* usrdata=0)
{
    int kind1 = _src1.kind(), kind2 = _src2.kind();
    Mat src1 = _src1.getMat(), src2 = _src2.getMat();
    bool haveMask = !_mask.empty();
    bool reallocate = false;

    if( (kind1 == kind2 || src1.channels() == 1) && src1.dims <= 2 && src2.dims <= 2 &&
        src1.size() == src2.size() && src1.type() == src2.type() &&
        !haveMask && ((!_dst.fixedType() && (dtype < 0 || CV_MAT_DEPTH(dtype) == src1.depth())) ||
                       (_dst.fixedType() && _dst.type() == _src1.type())) )
    {
        _dst.create(src1.size(), src1.type());
        Mat dst = _dst.getMat();
        Size sz = getContinuousSize(src1, src2, dst, src1.channels());
        tab[src1.depth()](src1.data, src1.step, src2.data, src2.step, dst.data, dst.step, sz, usrdata);
        return;
    }

    bool haveScalar = false, swapped12 = false;
    int depth2 = src2.depth();
    if( src1.size != src2.size || src1.channels() != src2.channels() ||
        ((kind1 == _InputArray::MATX || kind2 == _InputArray::MATX) &&
         src1.cols == 1 && src2.rows == 4) )
    {
        if( checkScalar(src1, src2.type(), kind1, kind2) )
        {
            // src1 is a scalar; swap it with src2
            swap(src1, src2);
            swapped12 = true;
        }
        else if( !checkScalar(src2, src1.type(), kind2, kind1) )
            CV_Error( CV_StsUnmatchedSizes,
                     "The operation is neither 'array op array' (where arrays have the same size and the same number of channels), "
                     "nor 'array op scalar', nor 'scalar op array'" );
        haveScalar = true;
        CV_Assert(src2.type() == CV_64F && (src2.rows == 4 || src2.rows == 1));

        if (!muldiv)
        {
            depth2 = actualScalarDepth(src2.ptr<double>(), src1.channels());
            if( depth2 == CV_64F && (src1.depth() < CV_32S || src1.depth() == CV_32F) )
                depth2 = CV_32F;
        }
        else
            depth2 = CV_64F;
    }

    int cn = src1.channels(), depth1 = src1.depth(), wtype;
    BinaryFunc cvtsrc1 = 0, cvtsrc2 = 0, cvtdst = 0;

    if( dtype < 0 )
    {
        if( _dst.fixedType() )
            dtype = _dst.type();
        else
        {
            if( !haveScalar && src1.type() != src2.type() )
                CV_Error(CV_StsBadArg,
                     "When the input arrays in add/subtract/multiply/divide functions have different types, "
                     "the output array type must be explicitly specified");
            dtype = src1.type();
        }
    }
    dtype = CV_MAT_DEPTH(dtype);

    if( depth1 == depth2 && dtype == depth1 )
        wtype = dtype;
    else if( !muldiv )
    {
        wtype = depth1 <= CV_8S && depth2 <= CV_8S ? CV_16S :
                depth1 <= CV_32S && depth2 <= CV_32S ? CV_32S : std::max(depth1, depth2);
        wtype = std::max(wtype, dtype);

        // when the result of addition should be converted to an integer type,
        // and just one of the input arrays is floating-point, it makes sense to convert that input to integer type before the operation,
        // instead of converting the other input to floating-point and then converting the operation result back to integers.
        if( dtype < CV_32F && (depth1 < CV_32F || depth2 < CV_32F) )
            wtype = CV_32S;
    }
    else
    {
        wtype = std::max(depth1, std::max(depth2, CV_32F));
        wtype = std::max(wtype, dtype);
    }

    cvtsrc1 = depth1 == wtype ? 0 : getConvertFunc(depth1, wtype);
    cvtsrc2 = depth2 == depth1 ? cvtsrc1 : depth2 == wtype ? 0 : getConvertFunc(depth2, wtype);
    cvtdst = dtype == wtype ? 0 : getConvertFunc(wtype, dtype);

    dtype = CV_MAKETYPE(dtype, cn);
    wtype = CV_MAKETYPE(wtype, cn);

    size_t esz1 = src1.elemSize(), esz2 = src2.elemSize();
    size_t dsz = CV_ELEM_SIZE(dtype), wsz = CV_ELEM_SIZE(wtype);
    size_t blocksize0 = (size_t)(BLOCK_SIZE + wsz-1)/wsz;
    BinaryFunc copymask = 0;
    Mat mask;

    if( haveMask )
    {
        mask = _mask.getMat();
        CV_Assert( (mask.type() == CV_8UC1 || mask.type() == CV_8SC1) );
        CV_Assert( mask.size == src1.size );
        copymask = getCopyMaskFunc(dsz);
        Mat tdst = _dst.getMat();
        reallocate = tdst.size != src1.size || tdst.type() != dtype;
    }

    AutoBuffer<uchar> _buf;
    uchar *buf, *maskbuf = 0, *buf1 = 0, *buf2 = 0, *wbuf = 0;
    size_t bufesz = (cvtsrc1 ? wsz : 0) + (cvtsrc2 || haveScalar ? wsz : 0) + (cvtdst ? wsz : 0) + (haveMask ? dsz : 0);

    _dst.create(src1.dims, src1.size, dtype);
    Mat dst = _dst.getMat();

    if( haveMask && reallocate )
        dst = Scalar::all(0);

    BinaryFunc func = tab[CV_MAT_DEPTH(wtype)];

    if( !haveScalar )
    {
        const Mat* arrays[] = { &src1, &src2, &dst, &mask, 0 };
        uchar* ptrs[4];

        NAryMatIterator it(arrays, ptrs);
        size_t total = it.size, blocksize = total;

        if( haveMask || cvtsrc1 || cvtsrc2 || cvtdst )
            blocksize = std::min(blocksize, blocksize0);

        _buf.allocate(bufesz*blocksize + 64);
        buf = _buf;
        if( cvtsrc1 )
            buf1 = buf, buf = alignPtr(buf + blocksize*wsz, 16);
        if( cvtsrc2 )
            buf2 = buf, buf = alignPtr(buf + blocksize*wsz, 16);
        wbuf = maskbuf = buf;
        if( cvtdst )
            buf = alignPtr(buf + blocksize*wsz, 16);
        if( haveMask )
            maskbuf = buf;

        for( size_t i = 0; i < it.nplanes; i++, ++it )
        {
            for( size_t j = 0; j < total; j += blocksize )
            {
                int bsz = (int)MIN(total - j, blocksize);
                Size bszn(bsz*cn, 1);
                const uchar *sptr1 = ptrs[0], *sptr2 = ptrs[1];
                uchar* dptr = ptrs[2];
                if( cvtsrc1 )
                {
                    cvtsrc1( sptr1, 0, 0, 0, buf1, 0, bszn, 0 );
                    sptr1 = buf1;
                }
                if( ptrs[0] == ptrs[1] )
                    sptr2 = sptr1;
                else if( cvtsrc2 )
                {
                    cvtsrc2( sptr2, 0, 0, 0, buf2, 0, bszn, 0 );
                    sptr2 = buf2;
                }

                if( !haveMask && !cvtdst )
                    func( sptr1, 0, sptr2, 0, dptr, 0, bszn, usrdata );
                else
                {
                    func( sptr1, 0, sptr2, 0, wbuf, 0, bszn, usrdata );
                    if( !haveMask )
                        cvtdst( wbuf, 0, 0, 0, dptr, 0, bszn, 0 );
                    else if( !cvtdst )
                    {
                        copymask( wbuf, 0, ptrs[3], 0, dptr, 0, Size(bsz, 1), &dsz );
                        ptrs[3] += bsz;
                    }
                    else
                    {
                        cvtdst( wbuf, 0, 0, 0, maskbuf, 0, bszn, 0 );
                        copymask( maskbuf, 0, ptrs[3], 0, dptr, 0, Size(bsz, 1), &dsz );
                        ptrs[3] += bsz;
                    }
                }
                ptrs[0] += bsz*esz1; ptrs[1] += bsz*esz2; ptrs[2] += bsz*dsz;
            }
        }
    }
    else
    {
        const Mat* arrays[] = { &src1, &dst, &mask, 0 };
        uchar* ptrs[3];

        NAryMatIterator it(arrays, ptrs);
        size_t total = it.size, blocksize = std::min(total, blocksize0);

        _buf.allocate(bufesz*blocksize + 64);
        buf = _buf;
        if( cvtsrc1 )
            buf1 = buf, buf = alignPtr(buf + blocksize*wsz, 16);
        buf2 = buf; buf = alignPtr(buf + blocksize*wsz, 16);
        wbuf = maskbuf = buf;
        if( cvtdst )
            buf = alignPtr(buf + blocksize*wsz, 16);
        if( haveMask )
            maskbuf = buf;

        convertAndUnrollScalar( src2, wtype, buf2, blocksize);

        for( size_t i = 0; i < it.nplanes; i++, ++it )
        {
            for( size_t j = 0; j < total; j += blocksize )
            {
                int bsz = (int)MIN(total - j, blocksize);
                Size bszn(bsz*cn, 1);
                const uchar *sptr1 = ptrs[0];
                const uchar* sptr2 = buf2;
                uchar* dptr = ptrs[1];

                if( cvtsrc1 )
                {
                    cvtsrc1( sptr1, 0, 0, 0, buf1, 0, bszn, 0 );
                    sptr1 = buf1;
                }

                if( swapped12 )
                    std::swap(sptr1, sptr2);

                if( !haveMask && !cvtdst )
                    func( sptr1, 0, sptr2, 0, dptr, 0, bszn, usrdata );
                else
                {
                    func( sptr1, 0, sptr2, 0, wbuf, 0, bszn, usrdata );
                    if( !haveMask )
                        cvtdst( wbuf, 0, 0, 0, dptr, 0, bszn, 0 );
                    else if( !cvtdst )
                    {
                        copymask( wbuf, 0, ptrs[2], 0, dptr, 0, Size(bsz, 1), &dsz );
                        ptrs[2] += bsz;
                    }
                    else
                    {
                        cvtdst( wbuf, 0, 0, 0, maskbuf, 0, bszn, 0 );
                        copymask( maskbuf, 0, ptrs[2], 0, dptr, 0, Size(bsz, 1), &dsz );
                        ptrs[2] += bsz;
                    }
                }
                ptrs[0] += bsz*esz1; ptrs[1] += bsz*dsz;
            }
        }
    }
}

static BinaryFunc addTab[] =
{
#if 0
    (BinaryFunc)GET_OPTIMIZED(add8u), (BinaryFunc)GET_OPTIMIZED(add8s),
    (BinaryFunc)GET_OPTIMIZED(add16u), (BinaryFunc)GET_OPTIMIZED(add16s),
    (BinaryFunc)GET_OPTIMIZED(add32s),
    (BinaryFunc)GET_OPTIMIZED(add32f), (BinaryFunc)add64f,
    0
#else
    0, 0,
    0, 0,
    0,
    0, (BinaryFunc)add64f,
    0
#endif
};

static BinaryFunc subTab[] =
{
    0, 0,
    0, 0,
    0,
    0, (BinaryFunc)sub64f,
    0
};

}

void cv::add( InputArray src1, InputArray src2, OutputArray dst,
          InputArray mask, int dtype )
{
    arithm_op(src1, src2, dst, mask, dtype, addTab );
}

void cv::subtract( InputArray src1, InputArray src2, OutputArray dst,
               InputArray mask, int dtype )
{
    arithm_op(src1, src2, dst, mask, dtype, subTab );
}

/****************************************************************************************\
*                                    multiply/divide                                     *
\****************************************************************************************/

namespace cv
{

template<typename T, typename WT> static void
mul_( const T* src1, size_t step1, const T* src2, size_t step2,
      T* dst, size_t step, Size size, WT scale )
{
    step1 /= sizeof(src1[0]);
    step2 /= sizeof(src2[0]);
    step /= sizeof(dst[0]);

    if( scale == (WT)1. )
    {
        for( ; size.height--; src1 += step1, src2 += step2, dst += step )
        {
            int i=0;
            #if CV_ENABLE_UNROLLED
            for(; i <= size.width - 4; i += 4 )
            {
                T t0;
                T t1;
                t0 = saturate_cast<T>(src1[i  ] * src2[i  ]);
                t1 = saturate_cast<T>(src1[i+1] * src2[i+1]);
                dst[i  ] = t0;
                dst[i+1] = t1;

                t0 = saturate_cast<T>(src1[i+2] * src2[i+2]);
                t1 = saturate_cast<T>(src1[i+3] * src2[i+3]);
                dst[i+2] = t0;
                dst[i+3] = t1;
            }
            #endif
            for( ; i < size.width; i++ )
                dst[i] = saturate_cast<T>(src1[i] * src2[i]);
        }
    }
    else
    {
        for( ; size.height--; src1 += step1, src2 += step2, dst += step )
        {
            int i = 0;
            #if CV_ENABLE_UNROLLED
            for(; i <= size.width - 4; i += 4 )
            {
                T t0 = saturate_cast<T>(scale*(WT)src1[i]*src2[i]);
                T t1 = saturate_cast<T>(scale*(WT)src1[i+1]*src2[i+1]);
                dst[i] = t0; dst[i+1] = t1;

                t0 = saturate_cast<T>(scale*(WT)src1[i+2]*src2[i+2]);
                t1 = saturate_cast<T>(scale*(WT)src1[i+3]*src2[i+3]);
                dst[i+2] = t0; dst[i+3] = t1;
            }
            #endif
            for( ; i < size.width; i++ )
                dst[i] = saturate_cast<T>(scale*(WT)src1[i]*src2[i]);
        }
    }
}

template<typename T> static void
div_( const T* src1, size_t step1, const T* src2, size_t step2,
      T* dst, size_t step, Size size, double scale )
{
    step1 /= sizeof(src1[0]);
    step2 /= sizeof(src2[0]);
    step /= sizeof(dst[0]);

    for( ; size.height--; src1 += step1, src2 += step2, dst += step )
    {
        int i = 0;
        #if CV_ENABLE_UNROLLED
        for( ; i <= size.width - 4; i += 4 )
        {
            if( src2[i] != 0 && src2[i+1] != 0 && src2[i+2] != 0 && src2[i+3] != 0 )
            {
                double a = (double)src2[i] * src2[i+1];
                double b = (double)src2[i+2] * src2[i+3];
                double d = scale/(a * b);
                b *= d;
                a *= d;

                T z0 = saturate_cast<T>(src2[i+1] * ((double)src1[i] * b));
                T z1 = saturate_cast<T>(src2[i] * ((double)src1[i+1] * b));
                T z2 = saturate_cast<T>(src2[i+3] * ((double)src1[i+2] * a));
                T z3 = saturate_cast<T>(src2[i+2] * ((double)src1[i+3] * a));

                dst[i] = z0; dst[i+1] = z1;
                dst[i+2] = z2; dst[i+3] = z3;
            }
            else
            {
                T z0 = src2[i] != 0 ? saturate_cast<T>(src1[i]*scale/src2[i]) : 0;
                T z1 = src2[i+1] != 0 ? saturate_cast<T>(src1[i+1]*scale/src2[i+1]) : 0;
                T z2 = src2[i+2] != 0 ? saturate_cast<T>(src1[i+2]*scale/src2[i+2]) : 0;
                T z3 = src2[i+3] != 0 ? saturate_cast<T>(src1[i+3]*scale/src2[i+3]) : 0;

                dst[i] = z0; dst[i+1] = z1;
                dst[i+2] = z2; dst[i+3] = z3;
            }
        }
        #endif
        for( ; i < size.width; i++ )
            dst[i] = src2[i] != 0 ? saturate_cast<T>(src1[i]*scale/src2[i]) : 0;
    }
}

template<typename T> static void
recip_( const T*, size_t, const T* src2, size_t step2,
        T* dst, size_t step, Size size, double scale )
{
    step2 /= sizeof(src2[0]);
    step /= sizeof(dst[0]);

    for( ; size.height--; src2 += step2, dst += step )
    {
        int i = 0;
        #if CV_ENABLE_UNROLLED
        for( ; i <= size.width - 4; i += 4 )
        {
            if( src2[i] != 0 && src2[i+1] != 0 && src2[i+2] != 0 && src2[i+3] != 0 )
            {
                double a = (double)src2[i] * src2[i+1];
                double b = (double)src2[i+2] * src2[i+3];
                double d = scale/(a * b);
                b *= d;
                a *= d;

                T z0 = saturate_cast<T>(src2[i+1] * b);
                T z1 = saturate_cast<T>(src2[i] * b);
                T z2 = saturate_cast<T>(src2[i+3] * a);
                T z3 = saturate_cast<T>(src2[i+2] * a);

                dst[i] = z0; dst[i+1] = z1;
                dst[i+2] = z2; dst[i+3] = z3;
            }
            else
            {
                T z0 = src2[i] != 0 ? saturate_cast<T>(scale/src2[i]) : 0;
                T z1 = src2[i+1] != 0 ? saturate_cast<T>(scale/src2[i+1]) : 0;
                T z2 = src2[i+2] != 0 ? saturate_cast<T>(scale/src2[i+2]) : 0;
                T z3 = src2[i+3] != 0 ? saturate_cast<T>(scale/src2[i+3]) : 0;

                dst[i] = z0; dst[i+1] = z1;
                dst[i+2] = z2; dst[i+3] = z3;
            }
        }
        #endif
        for( ; i < size.width; i++ )
            dst[i] = src2[i] != 0 ? saturate_cast<T>(scale/src2[i]) : 0;
    }
}


static void mul8u( const uchar* src1, size_t step1, const uchar* src2, size_t step2,
                   uchar* dst, size_t step, Size sz, void* scale)
{
    mul_(src1, step1, src2, step2, dst, step, sz, (float)*(const double*)scale);
}

static void mul8s( const schar* src1, size_t step1, const schar* src2, size_t step2,
                   schar* dst, size_t step, Size sz, void* scale)
{
    mul_(src1, step1, src2, step2, dst, step, sz, (float)*(const double*)scale);
}

static void mul16u( const ushort* src1, size_t step1, const ushort* src2, size_t step2,
                    ushort* dst, size_t step, Size sz, void* scale)
{
    mul_(src1, step1, src2, step2, dst, step, sz, (float)*(const double*)scale);
}

static void mul16s( const short* src1, size_t step1, const short* src2, size_t step2,
                    short* dst, size_t step, Size sz, void* scale)
{
    mul_(src1, step1, src2, step2, dst, step, sz, (float)*(const double*)scale);
}

static void mul32s( const int* src1, size_t step1, const int* src2, size_t step2,
                    int* dst, size_t step, Size sz, void* scale)
{
    mul_(src1, step1, src2, step2, dst, step, sz, *(const double*)scale);
}

static void mul32f( const float* src1, size_t step1, const float* src2, size_t step2,
                    float* dst, size_t step, Size sz, void* scale)
{
    mul_(src1, step1, src2, step2, dst, step, sz, (float)*(const double*)scale);
}

static void mul64f( const double* src1, size_t step1, const double* src2, size_t step2,
                    double* dst, size_t step, Size sz, void* scale)
{
    mul_(src1, step1, src2, step2, dst, step, sz, *(const double*)scale);
}

static void div8u( const uchar* src1, size_t step1, const uchar* src2, size_t step2,
                   uchar* dst, size_t step, Size sz, void* scale)
{
    if( src1 )
        div_(src1, step1, src2, step2, dst, step, sz, *(const double*)scale);
    else
        recip_(src1, step1, src2, step2, dst, step, sz, *(const double*)scale);
}

static void div8s( const schar* src1, size_t step1, const schar* src2, size_t step2,
                  schar* dst, size_t step, Size sz, void* scale)
{
    div_(src1, step1, src2, step2, dst, step, sz, *(const double*)scale);
}

static void div16u( const ushort* src1, size_t step1, const ushort* src2, size_t step2,
                    ushort* dst, size_t step, Size sz, void* scale)
{
    div_(src1, step1, src2, step2, dst, step, sz, *(const double*)scale);
}

static void div16s( const short* src1, size_t step1, const short* src2, size_t step2,
                    short* dst, size_t step, Size sz, void* scale)
{
    div_(src1, step1, src2, step2, dst, step, sz, *(const double*)scale);
}

static void div32s( const int* src1, size_t step1, const int* src2, size_t step2,
                    int* dst, size_t step, Size sz, void* scale)
{
    div_(src1, step1, src2, step2, dst, step, sz, *(const double*)scale);
}

static void div32f( const float* src1, size_t step1, const float* src2, size_t step2,
                    float* dst, size_t step, Size sz, void* scale)
{
    div_(src1, step1, src2, step2, dst, step, sz, *(const double*)scale);
}

static void div64f( const double* src1, size_t step1, const double* src2, size_t step2,
                    double* dst, size_t step, Size sz, void* scale)
{
    div_(src1, step1, src2, step2, dst, step, sz, *(const double*)scale);
}

static void recip8u( const uchar* src1, size_t step1, const uchar* src2, size_t step2,
                  uchar* dst, size_t step, Size sz, void* scale)
{
    recip_(src1, step1, src2, step2, dst, step, sz, *(const double*)scale);
}

static void recip8s( const schar* src1, size_t step1, const schar* src2, size_t step2,
                  schar* dst, size_t step, Size sz, void* scale)
{
    recip_(src1, step1, src2, step2, dst, step, sz, *(const double*)scale);
}

static void recip16u( const ushort* src1, size_t step1, const ushort* src2, size_t step2,
                   ushort* dst, size_t step, Size sz, void* scale)
{
    recip_(src1, step1, src2, step2, dst, step, sz, *(const double*)scale);
}

static void recip16s( const short* src1, size_t step1, const short* src2, size_t step2,
                   short* dst, size_t step, Size sz, void* scale)
{
    recip_(src1, step1, src2, step2, dst, step, sz, *(const double*)scale);
}

static void recip32s( const int* src1, size_t step1, const int* src2, size_t step2,
                   int* dst, size_t step, Size sz, void* scale)
{
    recip_(src1, step1, src2, step2, dst, step, sz, *(const double*)scale);
}

static void recip32f( const float* src1, size_t step1, const float* src2, size_t step2,
                   float* dst, size_t step, Size sz, void* scale)
{
    recip_(src1, step1, src2, step2, dst, step, sz, *(const double*)scale);
}

static void recip64f( const double* src1, size_t step1, const double* src2, size_t step2,
                   double* dst, size_t step, Size sz, void* scale)
{
    recip_(src1, step1, src2, step2, dst, step, sz, *(const double*)scale);
}


static BinaryFunc mulTab[] =
{
    (BinaryFunc)mul8u, (BinaryFunc)mul8s, (BinaryFunc)mul16u,
    (BinaryFunc)mul16s, (BinaryFunc)mul32s, (BinaryFunc)mul32f,
    (BinaryFunc)mul64f, 0
};

static BinaryFunc divTab[] =
{
    (BinaryFunc)div8u, (BinaryFunc)div8s, (BinaryFunc)div16u,
    (BinaryFunc)div16s, (BinaryFunc)div32s, (BinaryFunc)div32f,
    (BinaryFunc)div64f, 0
};

static BinaryFunc recipTab[] =
{
    (BinaryFunc)recip8u, (BinaryFunc)recip8s, (BinaryFunc)recip16u,
    (BinaryFunc)recip16s, (BinaryFunc)recip32s, (BinaryFunc)recip32f,
    (BinaryFunc)recip64f, 0
};


}

void cv::multiply(InputArray src1, InputArray src2,
                  OutputArray dst, double scale, int dtype)
{
    arithm_op(src1, src2, dst, noArray(), dtype, mulTab, true, &scale);
}

void cv::divide(InputArray src1, InputArray src2,
                OutputArray dst, double scale, int dtype)
{
    arithm_op(src1, src2, dst, noArray(), dtype, divTab, true, &scale);
}

void cv::divide(double scale, InputArray src2,
                OutputArray dst, int dtype)
{
    arithm_op(src2, src2, dst, noArray(), dtype, recipTab, true, &scale);
}

/****************************************************************************************\
*                                      addWeighted                                       *
\****************************************************************************************/
#if 1
namespace cv
{

template<typename T, typename WT> static void
addWeighted_( const T* src1, size_t step1, const T* src2, size_t step2,
              T* dst, size_t step, Size size, void* _scalars )
{
    const double* scalars = (const double*)_scalars;
    WT alpha = (WT)scalars[0], beta = (WT)scalars[1], gamma = (WT)scalars[2];
    step1 /= sizeof(src1[0]);
    step2 /= sizeof(src2[0]);
    step /= sizeof(dst[0]);

    for( ; size.height--; src1 += step1, src2 += step2, dst += step )
    {
        int x = 0;
        #if CV_ENABLE_UNROLLED
        for( ; x <= size.width - 4; x += 4 )
        {
            T t0 = saturate_cast<T>(src1[x]*alpha + src2[x]*beta + gamma);
            T t1 = saturate_cast<T>(src1[x+1]*alpha + src2[x+1]*beta + gamma);
            dst[x] = t0; dst[x+1] = t1;

            t0 = saturate_cast<T>(src1[x+2]*alpha + src2[x+2]*beta + gamma);
            t1 = saturate_cast<T>(src1[x+3]*alpha + src2[x+3]*beta + gamma);
            dst[x+2] = t0; dst[x+3] = t1;
        }
        #endif
        for( ; x < size.width; x++ )
            dst[x] = saturate_cast<T>(src1[x]*alpha + src2[x]*beta + gamma);
    }
}


static void
addWeighted8u( const uchar* src1, size_t step1,
               const uchar* src2, size_t step2,
               uchar* dst, size_t step, Size size,
               void* _scalars )
{
    const double* scalars = (const double*)_scalars;
    float alpha = (float)scalars[0], beta = (float)scalars[1], gamma = (float)scalars[2];

    for( ; size.height--; src1 += step1, src2 += step2, dst += step )
    {
        int x = 0;

#if CV_SSE2
        if( USE_SSE2 )
        {
            __m128 a4 = _mm_set1_ps(alpha), b4 = _mm_set1_ps(beta), g4 = _mm_set1_ps(gamma);
            __m128i z = _mm_setzero_si128();

            for( ; x <= size.width - 8; x += 8 )
            {
                __m128i u = _mm_unpacklo_epi8(_mm_loadl_epi64((const __m128i*)(src1 + x)), z);
                __m128i v = _mm_unpacklo_epi8(_mm_loadl_epi64((const __m128i*)(src2 + x)), z);

                __m128 u0 = _mm_cvtepi32_ps(_mm_unpacklo_epi16(u, z));
                __m128 u1 = _mm_cvtepi32_ps(_mm_unpackhi_epi16(u, z));
                __m128 v0 = _mm_cvtepi32_ps(_mm_unpacklo_epi16(v, z));
                __m128 v1 = _mm_cvtepi32_ps(_mm_unpackhi_epi16(v, z));

                u0 = _mm_add_ps(_mm_mul_ps(u0, a4), _mm_mul_ps(v0, b4));
                u1 = _mm_add_ps(_mm_mul_ps(u1, a4), _mm_mul_ps(v1, b4));
                u0 = _mm_add_ps(u0, g4); u1 = _mm_add_ps(u1, g4);

                u = _mm_packs_epi32(_mm_cvtps_epi32(u0), _mm_cvtps_epi32(u1));
                u = _mm_packus_epi16(u, u);

                _mm_storel_epi64((__m128i*)(dst + x), u);
            }
        }
#endif
        #if CV_ENABLE_UNROLLED
        for( ; x <= size.width - 4; x += 4 )
        {
            float t0, t1;
            t0 = CV_8TO32F(src1[x])*alpha + CV_8TO32F(src2[x])*beta + gamma;
            t1 = CV_8TO32F(src1[x+1])*alpha + CV_8TO32F(src2[x+1])*beta + gamma;

            dst[x] = saturate_cast<uchar>(t0);
            dst[x+1] = saturate_cast<uchar>(t1);

            t0 = CV_8TO32F(src1[x+2])*alpha + CV_8TO32F(src2[x+2])*beta + gamma;
            t1 = CV_8TO32F(src1[x+3])*alpha + CV_8TO32F(src2[x+3])*beta + gamma;

            dst[x+2] = saturate_cast<uchar>(t0);
            dst[x+3] = saturate_cast<uchar>(t1);
        }
        #endif

        for( ; x < size.width; x++ )
        {
            float t0 = CV_8TO32F(src1[x])*alpha + CV_8TO32F(src2[x])*beta + gamma;
            dst[x] = saturate_cast<uchar>(t0);
        }
    }
}

static void addWeighted8s( const schar* src1, size_t step1, const schar* src2, size_t step2,
                           schar* dst, size_t step, Size sz, void* scalars )
{
    addWeighted_<schar, float>(src1, step1, src2, step2, dst, step, sz, scalars);
}

static void addWeighted16u( const ushort* src1, size_t step1, const ushort* src2, size_t step2,
                            ushort* dst, size_t step, Size sz, void* scalars )
{
    addWeighted_<ushort, float>(src1, step1, src2, step2, dst, step, sz, scalars);
}

static void addWeighted16s( const short* src1, size_t step1, const short* src2, size_t step2,
                            short* dst, size_t step, Size sz, void* scalars )
{
    addWeighted_<short, float>(src1, step1, src2, step2, dst, step, sz, scalars);
}

static void addWeighted32s( const int* src1, size_t step1, const int* src2, size_t step2,
                            int* dst, size_t step, Size sz, void* scalars )
{
    addWeighted_<int, double>(src1, step1, src2, step2, dst, step, sz, scalars);
}

static void addWeighted32f( const float* src1, size_t step1, const float* src2, size_t step2,
                            float* dst, size_t step, Size sz, void* scalars )
{
    addWeighted_<float, double>(src1, step1, src2, step2, dst, step, sz, scalars);
}

static void addWeighted64f( const double* src1, size_t step1, const double* src2, size_t step2,
                            double* dst, size_t step, Size sz, void* scalars )
{
    addWeighted_<double, double>(src1, step1, src2, step2, dst, step, sz, scalars);
}

static BinaryFunc addWeightedTab[] =
{
    (BinaryFunc)GET_OPTIMIZED(addWeighted8u), (BinaryFunc)GET_OPTIMIZED(addWeighted8s), (BinaryFunc)GET_OPTIMIZED(addWeighted16u),
    (BinaryFunc)GET_OPTIMIZED(addWeighted16s), (BinaryFunc)GET_OPTIMIZED(addWeighted32s), (BinaryFunc)addWeighted32f,
    (BinaryFunc)addWeighted64f, 0
};

}

void cv::addWeighted( InputArray src1, double alpha, InputArray src2,
                      double beta, double gamma, OutputArray dst, int dtype )
{
    double scalars[] = {alpha, beta, gamma};
    arithm_op(src1, src2, dst, noArray(), dtype, addWeightedTab, true, scalars);
}
#endif


/****************************************************************************************\
*                                          compare                                       *
\****************************************************************************************/

namespace cv
{

template<typename T> static void
cmp_(const T* src1, size_t step1, const T* src2, size_t step2,
     uchar* dst, size_t step, Size size, int code)
{
    step1 /= sizeof(src1[0]);
    step2 /= sizeof(src2[0]);
    if( code == CMP_GE || code == CMP_LT )
    {
        std::swap(src1, src2);
        std::swap(step1, step2);
        code = code == CMP_GE ? CMP_LE : CMP_GT;
    }

    if( code == CMP_GT || code == CMP_LE )
    {
        int m = code == CMP_GT ? 0 : 255;
        for( ; size.height--; src1 += step1, src2 += step2, dst += step )
        {
            int x = 0;
            #if CV_ENABLE_UNROLLED
            for( ; x <= size.width - 4; x += 4 )
            {
                int t0, t1;
                t0 = -(src1[x] > src2[x]) ^ m;
                t1 = -(src1[x+1] > src2[x+1]) ^ m;
                dst[x] = (uchar)t0; dst[x+1] = (uchar)t1;
                t0 = -(src1[x+2] > src2[x+2]) ^ m;
                t1 = -(src1[x+3] > src2[x+3]) ^ m;
                dst[x+2] = (uchar)t0; dst[x+3] = (uchar)t1;
            }
            #endif
            for( ; x < size.width; x++ )
                dst[x] = (uchar)(-(src1[x] > src2[x]) ^ m);
               }
    }
    else if( code == CMP_EQ || code == CMP_NE )
    {
        int m = code == CMP_EQ ? 0 : 255;
        for( ; size.height--; src1 += step1, src2 += step2, dst += step )
        {
            int x = 0;
            #if CV_ENABLE_UNROLLED
            for( ; x <= size.width - 4; x += 4 )
            {
                int t0, t1;
                t0 = -(src1[x] == src2[x]) ^ m;
                t1 = -(src1[x+1] == src2[x+1]) ^ m;
                dst[x] = (uchar)t0; dst[x+1] = (uchar)t1;
                t0 = -(src1[x+2] == src2[x+2]) ^ m;
                t1 = -(src1[x+3] == src2[x+3]) ^ m;
                dst[x+2] = (uchar)t0; dst[x+3] = (uchar)t1;
            }
            #endif
            for( ; x < size.width; x++ )
                dst[x] = (uchar)(-(src1[x] == src2[x]) ^ m);
        }
    }
}


static void cmp8u(const uchar* src1, size_t step1, const uchar* src2, size_t step2,
                  uchar* dst, size_t step, Size size, void* _cmpop)
{
  //vz optimized  cmp_(src1, step1, src2, step2, dst, step, size, *(int*)_cmpop);
    int code = *(int*)_cmpop;
    step1 /= sizeof(src1[0]);
    step2 /= sizeof(src2[0]);
    if( code == CMP_GE || code == CMP_LT )
    {
        std::swap(src1, src2);
        std::swap(step1, step2);
        code = code == CMP_GE ? CMP_LE : CMP_GT;
    }

    if( code == CMP_GT || code == CMP_LE )
    {
        int m = code == CMP_GT ? 0 : 255;
        for( ; size.height--; src1 += step1, src2 += step2, dst += step )
        {
            int x =0;
            #if CV_SSE2
            if( USE_SSE2 ){
                __m128i m128 = code == CMP_GT ? _mm_setzero_si128() : _mm_set1_epi8 (-1);
                __m128i c128 = _mm_set1_epi8 (-128);
                for( ; x <= size.width - 16; x += 16 )
                {
                    __m128i r00 = _mm_loadu_si128((const __m128i*)(src1 + x));
                    __m128i r10 = _mm_loadu_si128((const __m128i*)(src2 + x));
                    // no simd for 8u comparison, that's why we need the trick
                    r00 = _mm_sub_epi8(r00,c128);
                    r10 = _mm_sub_epi8(r10,c128);

                    r00 =_mm_xor_si128(_mm_cmpgt_epi8(r00, r10), m128);
                    _mm_storeu_si128((__m128i*)(dst + x),r00);

                }
            }
           #endif

            for( ; x < size.width; x++ ){
                dst[x] = (uchar)(-(src1[x] > src2[x]) ^ m);
            }
        }
    }
    else if( code == CMP_EQ || code == CMP_NE )
    {
        int m = code == CMP_EQ ? 0 : 255;
        for( ; size.height--; src1 += step1, src2 += step2, dst += step )
        {
            int x = 0;
            #if CV_SSE2
            if( USE_SSE2 ){
                __m128i m128 =  code == CMP_EQ ? _mm_setzero_si128() : _mm_set1_epi8 (-1);
                for( ; x <= size.width - 16; x += 16 )
                {
                    __m128i r00 = _mm_loadu_si128((const __m128i*)(src1 + x));
                    __m128i r10 = _mm_loadu_si128((const __m128i*)(src2 + x));
                    r00 = _mm_xor_si128 ( _mm_cmpeq_epi8 (r00, r10), m128);
                    _mm_storeu_si128((__m128i*)(dst + x), r00);
                }
            }
           #endif
           for( ; x < size.width; x++ )
                dst[x] = (uchar)(-(src1[x] == src2[x]) ^ m);
        }
    }
}

static void cmp8s(const schar* src1, size_t step1, const schar* src2, size_t step2,
                  uchar* dst, size_t step, Size size, void* _cmpop)
{
    cmp_(src1, step1, src2, step2, dst, step, size, *(int*)_cmpop);
}

static void cmp16u(const ushort* src1, size_t step1, const ushort* src2, size_t step2,
                  uchar* dst, size_t step, Size size, void* _cmpop)
{
    cmp_(src1, step1, src2, step2, dst, step, size, *(int*)_cmpop);
}

static void cmp16s(const short* src1, size_t step1, const short* src2, size_t step2,
                  uchar* dst, size_t step, Size size, void* _cmpop)
{
   //vz optimized cmp_(src1, step1, src2, step2, dst, step, size, *(int*)_cmpop);

    int code = *(int*)_cmpop;
    step1 /= sizeof(src1[0]);
    step2 /= sizeof(src2[0]);
    if( code == CMP_GE || code == CMP_LT )
    {
        std::swap(src1, src2);
        std::swap(step1, step2);
        code = code == CMP_GE ? CMP_LE : CMP_GT;
    }

    if( code == CMP_GT || code == CMP_LE )
    {
        int m = code == CMP_GT ? 0 : 255;
        for( ; size.height--; src1 += step1, src2 += step2, dst += step )
        {
            int x =0;
            #if CV_SSE2
            if( USE_SSE2){//
                __m128i m128 =  code == CMP_GT ? _mm_setzero_si128() : _mm_set1_epi16 (-1);
                for( ; x <= size.width - 16; x += 16 )
                {
                    __m128i r00 = _mm_loadu_si128((const __m128i*)(src1 + x));
                    __m128i r10 = _mm_loadu_si128((const __m128i*)(src2 + x));
                    r00 = _mm_xor_si128 ( _mm_cmpgt_epi16 (r00, r10), m128);
                    __m128i r01 = _mm_loadu_si128((const __m128i*)(src1 + x + 8));
                    __m128i r11 = _mm_loadu_si128((const __m128i*)(src2 + x + 8));
                    r01 = _mm_xor_si128 ( _mm_cmpgt_epi16 (r01, r11), m128);
                    r11 = _mm_packs_epi16(r00, r01);
                    _mm_storeu_si128((__m128i*)(dst + x), r11);
                }
                if( x <= size.width-8)
                {
                    __m128i r00 = _mm_loadu_si128((const __m128i*)(src1 + x));
                    __m128i r10 = _mm_loadu_si128((const __m128i*)(src2 + x));
                    r00 = _mm_xor_si128 ( _mm_cmpgt_epi16 (r00, r10), m128);
                    r10 = _mm_packs_epi16(r00, r00);
                    _mm_storel_epi64((__m128i*)(dst + x), r10);

                    x += 8;
                }
            }
           #endif

            for( ; x < size.width; x++ ){
                 dst[x] = (uchar)(-(src1[x] > src2[x]) ^ m);
            }
        }
    }
    else if( code == CMP_EQ || code == CMP_NE )
    {
        int m = code == CMP_EQ ? 0 : 255;
        for( ; size.height--; src1 += step1, src2 += step2, dst += step )
        {
            int x = 0;
            #if CV_SSE2
            if( USE_SSE2 ){
                __m128i m128 =  code == CMP_EQ ? _mm_setzero_si128() : _mm_set1_epi16 (-1);
                for( ; x <= size.width - 16; x += 16 )
                {
                    __m128i r00 = _mm_loadu_si128((const __m128i*)(src1 + x));
                    __m128i r10 = _mm_loadu_si128((const __m128i*)(src2 + x));
                    r00 = _mm_xor_si128 ( _mm_cmpeq_epi16 (r00, r10), m128);
                    __m128i r01 = _mm_loadu_si128((const __m128i*)(src1 + x + 8));
                    __m128i r11 = _mm_loadu_si128((const __m128i*)(src2 + x + 8));
                    r01 = _mm_xor_si128 ( _mm_cmpeq_epi16 (r01, r11), m128);
                    r11 = _mm_packs_epi16(r00, r01);
                    _mm_storeu_si128((__m128i*)(dst + x), r11);
                }
                if( x <= size.width - 8)
                {
                    __m128i r00 = _mm_loadu_si128((const __m128i*)(src1 + x));
                    __m128i r10 = _mm_loadu_si128((const __m128i*)(src2 + x));
                    r00 = _mm_xor_si128 ( _mm_cmpeq_epi16 (r00, r10), m128);
                    r10 = _mm_packs_epi16(r00, r00);
                    _mm_storel_epi64((__m128i*)(dst + x), r10);

                    x += 8;
                }
            }
           #endif
           for( ; x < size.width; x++ )
                dst[x] = (uchar)(-(src1[x] == src2[x]) ^ m);
        }
    }
}

static void cmp32s(const int* src1, size_t step1, const int* src2, size_t step2,
                   uchar* dst, size_t step, Size size, void* _cmpop)
{
    cmp_(src1, step1, src2, step2, dst, step, size, *(int*)_cmpop);
}

static void cmp32f(const float* src1, size_t step1, const float* src2, size_t step2,
                  uchar* dst, size_t step, Size size, void* _cmpop)
{
    cmp_(src1, step1, src2, step2, dst, step, size, *(int*)_cmpop);
}

static void cmp64f(const double* src1, size_t step1, const double* src2, size_t step2,
                  uchar* dst, size_t step, Size size, void* _cmpop)
{
    cmp_(src1, step1, src2, step2, dst, step, size, *(int*)_cmpop);
}

static BinaryFunc cmpTab[] =
{
    (BinaryFunc)GET_OPTIMIZED(cmp8u), (BinaryFunc)GET_OPTIMIZED(cmp8s),
    (BinaryFunc)GET_OPTIMIZED(cmp16u), (BinaryFunc)GET_OPTIMIZED(cmp16s),
    (BinaryFunc)GET_OPTIMIZED(cmp32s),
    (BinaryFunc)GET_OPTIMIZED(cmp32f), (BinaryFunc)cmp64f,
    0
};


static double getMinVal(int depth)
{
    static const double tab[] = {0, -128, 0, -32768, INT_MIN, -FLT_MAX, -DBL_MAX, 0};
    return tab[depth];
}

static double getMaxVal(int depth)
{
    static const double tab[] = {255, 127, 65535, 32767, INT_MAX, FLT_MAX, DBL_MAX, 0};
    return tab[depth];
}

}

CV_IMPL void cvDiv( const CvArr* srcarr1, const CvArr* srcarr2,
                    CvArr* dstarr, double scale )
{
    cv::Mat src2 = cv::cvarrToMat(srcarr2),
        dst = cv::cvarrToMat(dstarr), mask;
    CV_Assert( src2.size == dst.size && src2.channels() == dst.channels() );

    if( srcarr1 )
        cv::divide( cv::cvarrToMat(srcarr1), src2, dst, scale, dst.type() );
    else
        cv::divide( scale, src2, dst, dst.type() );
}

/* End of file. */
