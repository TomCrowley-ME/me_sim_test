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
// Copyright (C) 2009, Willow Garage Inc., all rights reserved.
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
//  Geometrical transforms on images and matrices: rotation, zoom etc.
//
// */

#include <opencv2/core_c.h>
#include <opencv2/core.hpp>
#include <opencv2/internal.hpp>
#include <opencv2/imgproc_c.h>
#include <opencv2/imgproc.hpp>
#include <opencv2/mat.hpp>
#include <iostream>
#include <vector>

namespace cv
{

/************** interpolation formulas and tables ***************/

const int INTER_RESIZE_COEF_BITS=11;
const int INTER_RESIZE_COEF_SCALE=1 << INTER_RESIZE_COEF_BITS;

const int INTER_REMAP_COEF_BITS=15;
const int INTER_REMAP_COEF_SCALE=1 << INTER_REMAP_COEF_BITS;

static uchar NNDeltaTab_i[INTER_TAB_SIZE2][2];

static float BilinearTab_f[INTER_TAB_SIZE2][2][2];
static short BilinearTab_i[INTER_TAB_SIZE2][2][2];

#if CV_SSE2
static short BilinearTab_iC4_buf[INTER_TAB_SIZE2+2][2][8];
static short (*BilinearTab_iC4)[2][8] = (short (*)[2][8])alignPtr(BilinearTab_iC4_buf, 16);
#endif

static float BicubicTab_f[INTER_TAB_SIZE2][4][4];
static short BicubicTab_i[INTER_TAB_SIZE2][4][4];

static float Lanczos4Tab_f[INTER_TAB_SIZE2][8][8];
static short Lanczos4Tab_i[INTER_TAB_SIZE2][8][8];

static inline void interpolateLinear( float x, float* coeffs )
{
    coeffs[0] = 1.f - x;
    coeffs[1] = x;
}

static inline void interpolateCubic( float x, float* coeffs )
{
    const float A = -0.75f;

    coeffs[0] = ((A*(x + 1) - 5*A)*(x + 1) + 8*A)*(x + 1) - 4*A;
    coeffs[1] = ((A + 2)*x - (A + 3))*x*x + 1;
    coeffs[2] = ((A + 2)*(1 - x) - (A + 3))*(1 - x)*(1 - x) + 1;
    coeffs[3] = 1.f - coeffs[0] - coeffs[1] - coeffs[2];
}

static inline void interpolateLanczos4( float x, float* coeffs )
{
    static const double s45 = 0.70710678118654752440084436210485;
    static const double cs[][2]=
    {{1, 0}, {-s45, -s45}, {0, 1}, {s45, -s45}, {-1, 0}, {s45, s45}, {0, -1}, {-s45, s45}};

    if( x < FLT_EPSILON )
    {
        for( int i = 0; i < 8; i++ )
            coeffs[i] = 0;
        coeffs[3] = 1;
        return;
    }

    float sum = 0;
    double y0=-(x+3)*CV_PI*0.25, s0 = sin(y0), c0=cos(y0);
    for(int i = 0; i < 8; i++ )
    {
        double y = -(x+3-i)*CV_PI*0.25;
        coeffs[i] = (float)((cs[i][0]*s0 + cs[i][1]*c0)/(y*y));
        sum += coeffs[i];
    }

    sum = 1.f/sum;
    for(int i = 0; i < 8; i++ )
        coeffs[i] *= sum;
}

static void initInterTab1D(int method, float* tab, int tabsz)
{
    float scale = 1.f/tabsz;
    if( method == INTER_LINEAR )
    {
        for( int i = 0; i < tabsz; i++, tab += 2 )
            interpolateLinear( i*scale, tab );
    }
    else if( method == INTER_CUBIC )
    {
        for( int i = 0; i < tabsz; i++, tab += 4 )
            interpolateCubic( i*scale, tab );
    }
    else if( method == INTER_LANCZOS4 )
    {
        for( int i = 0; i < tabsz; i++, tab += 8 )
            interpolateLanczos4( i*scale, tab );
    }
    else
        CV_Error( CV_StsBadArg, "Unknown interpolation method" );
}


static const void* initInterTab2D( int method, bool fixpt )
{
    static bool inittab[INTER_MAX+1] = {false};
    float* tab = 0;
    short* itab = 0;
    int ksize = 0;
    if( method == INTER_LINEAR )
        tab = BilinearTab_f[0][0], itab = BilinearTab_i[0][0], ksize=2;
    else if( method == INTER_CUBIC )
        tab = BicubicTab_f[0][0], itab = BicubicTab_i[0][0], ksize=4;
    else if( method == INTER_LANCZOS4 )
        tab = Lanczos4Tab_f[0][0], itab = Lanczos4Tab_i[0][0], ksize=8;
    else
        CV_Error( CV_StsBadArg, "Unknown/unsupported interpolation type" );

    if( !inittab[method] )
    {
        AutoBuffer<float> _tab(8*INTER_TAB_SIZE);
        int i, j, k1, k2;
        initInterTab1D(method, _tab, INTER_TAB_SIZE);
        for( i = 0; i < INTER_TAB_SIZE; i++ )
            for( j = 0; j < INTER_TAB_SIZE; j++, tab += ksize*ksize, itab += ksize*ksize )
            {
                int isum = 0;
                NNDeltaTab_i[i*INTER_TAB_SIZE+j][0] = j < INTER_TAB_SIZE/2;
                NNDeltaTab_i[i*INTER_TAB_SIZE+j][1] = i < INTER_TAB_SIZE/2;

                for( k1 = 0; k1 < ksize; k1++ )
                {
                    float vy = _tab[i*ksize + k1];
                    for( k2 = 0; k2 < ksize; k2++ )
                    {
                        float v = vy*_tab[j*ksize + k2];
                        tab[k1*ksize + k2] = v;
                        isum += itab[k1*ksize + k2] = saturate_cast<short>(v*INTER_REMAP_COEF_SCALE);
                    }
                }

                if( isum != INTER_REMAP_COEF_SCALE )
                {
                    int diff = isum - INTER_REMAP_COEF_SCALE;
                    int ksize2 = ksize/2, Mk1=ksize2, Mk2=ksize2, mk1=ksize2, mk2=ksize2;
                    for( k1 = ksize2; k1 < ksize2+2; k1++ )
                        for( k2 = ksize2; k2 < ksize2+2; k2++ )
                        {
                            if( itab[k1*ksize+k2] < itab[mk1*ksize+mk2] )
                                mk1 = k1, mk2 = k2;
                            else if( itab[k1*ksize+k2] > itab[Mk1*ksize+Mk2] )
                                Mk1 = k1, Mk2 = k2;
                        }
                    if( diff < 0 )
                        itab[Mk1*ksize + Mk2] = (short)(itab[Mk1*ksize + Mk2] - diff);
                    else
                        itab[mk1*ksize + mk2] = (short)(itab[mk1*ksize + mk2] - diff);
                }
            }
        tab -= INTER_TAB_SIZE2*ksize*ksize;
        itab -= INTER_TAB_SIZE2*ksize*ksize;
#if CV_SSE2
        if( method == INTER_LINEAR )
        {
            for( i = 0; i < INTER_TAB_SIZE2; i++ )
                for( j = 0; j < 4; j++ )
                {
                    BilinearTab_iC4[i][0][j*2] = BilinearTab_i[i][0][0];
                    BilinearTab_iC4[i][0][j*2+1] = BilinearTab_i[i][0][1];
                    BilinearTab_iC4[i][1][j*2] = BilinearTab_i[i][1][0];
                    BilinearTab_iC4[i][1][j*2+1] = BilinearTab_i[i][1][1];
                }
        }
#endif
        inittab[method] = true;
    }
    return fixpt ? (const void*)itab : (const void*)tab;
}

static bool initAllInterTab2D()
{
    return  initInterTab2D( INTER_LINEAR, false ) &&
            initInterTab2D( INTER_LINEAR, true ) &&
            initInterTab2D( INTER_CUBIC, false ) &&
            initInterTab2D( INTER_CUBIC, true ) &&
            initInterTab2D( INTER_LANCZOS4, false ) &&
            initInterTab2D( INTER_LANCZOS4, true );
}

static volatile bool doInitAllInterTab2D = initAllInterTab2D();

template<typename ST, typename DT> struct Cast
{
    typedef ST type1;
    typedef DT rtype;

    DT operator()(ST val) const { return saturate_cast<DT>(val); }
};

template<typename ST, typename DT, int bits> struct FixedPtCast
{
    typedef ST type1;
    typedef DT rtype;
    enum { SHIFT = bits, DELTA = 1 << (bits-1) };

    DT operator()(ST val) const { return saturate_cast<DT>((val + DELTA)>>SHIFT); }
};

/****************************************************************************************\
*                                         Resize                                         *
\****************************************************************************************/

class resizeNNInvoker :
    public ParallelLoopBody
{
public:
    resizeNNInvoker(const Mat& _src, Mat &_dst, int *_x_ofs, int _pix_size4, double _ify) :
        ParallelLoopBody(), src(_src), dst(_dst), x_ofs(_x_ofs), pix_size4(_pix_size4),
        ify(_ify)
    {
    }

    virtual void operator() (const Range& range) const
    {
        Size ssize = src.size(), dsize = dst.size();
        int y, x, pix_size = (int)src.elemSize();

        for( y = range.start; y < range.end; y++ )
        {
            uchar* D = dst.data + dst.step*y;
            int sy = std::min(cvFloor(y*ify), ssize.height-1);
            const uchar* S = src.data + src.step*sy;

            switch( pix_size )
            {
            case 1:
                for( x = 0; x <= dsize.width - 2; x += 2 )
                {
                    uchar t0 = S[x_ofs[x]];
                    uchar t1 = S[x_ofs[x+1]];
                    D[x] = t0;
                    D[x+1] = t1;
                }

                for( ; x < dsize.width; x++ )
                    D[x] = S[x_ofs[x]];
                break;
            case 2:
                for( x = 0; x < dsize.width; x++ )
                    *(ushort*)(D + x*2) = *(ushort*)(S + x_ofs[x]);
                break;
            case 3:
                for( x = 0; x < dsize.width; x++, D += 3 )
                {
                    const uchar* _tS = S + x_ofs[x];
                    D[0] = _tS[0]; D[1] = _tS[1]; D[2] = _tS[2];
                }
                break;
            case 4:
                for( x = 0; x < dsize.width; x++ )
                    *(int*)(D + x*4) = *(int*)(S + x_ofs[x]);
                break;
            case 6:
                for( x = 0; x < dsize.width; x++, D += 6 )
                {
                    const ushort* _tS = (const ushort*)(S + x_ofs[x]);
                    ushort* _tD = (ushort*)D;
                    _tD[0] = _tS[0]; _tD[1] = _tS[1]; _tD[2] = _tS[2];
                }
                break;
            case 8:
                for( x = 0; x < dsize.width; x++, D += 8 )
                {
                    const int* _tS = (const int*)(S + x_ofs[x]);
                    int* _tD = (int*)D;
                    _tD[0] = _tS[0]; _tD[1] = _tS[1];
                }
                break;
            case 12:
                for( x = 0; x < dsize.width; x++, D += 12 )
                {
                    const int* _tS = (const int*)(S + x_ofs[x]);
                    int* _tD = (int*)D;
                    _tD[0] = _tS[0]; _tD[1] = _tS[1]; _tD[2] = _tS[2];
                }
                break;
            default:
                for( x = 0; x < dsize.width; x++, D += pix_size )
                {
                    const int* _tS = (const int*)(S + x_ofs[x]);
                    int* _tD = (int*)D;
                    for( int k = 0; k < pix_size4; k++ )
                        _tD[k] = _tS[k];
                }
            }
        }
    }

private:
    const Mat src;
    Mat dst;
    int* x_ofs, pix_size4;
    double ify;

    resizeNNInvoker(const resizeNNInvoker&);
    resizeNNInvoker& operator=(const resizeNNInvoker&);
};

static void
resizeNN( const Mat& src, Mat& dst, double fx, double fy )
{
    Size ssize = src.size(), dsize = dst.size();
    AutoBuffer<int> _x_ofs(dsize.width);
    int* x_ofs = _x_ofs;
    int pix_size = (int)src.elemSize();
    int pix_size4 = (int)(pix_size / sizeof(int));
    double ifx = 1./fx, ify = 1./fy;
    int x;

    for( x = 0; x < dsize.width; x++ )
    {
        int sx = cvFloor(x*ifx);
        x_ofs[x] = std::min(sx, ssize.width-1)*pix_size;
    }

    Range range(0, dsize.height);
    resizeNNInvoker invoker(src, dst, x_ofs, pix_size4, ify);
    parallel_for_(range, invoker, dst.total()/(double)(1<<16));
}


struct VResizeNoVec
{
    int operator()(const uchar**, uchar*, const uchar*, int ) const { return 0; }
};

struct HResizeNoVec
{
    int operator()(const uchar**, uchar**, int, const int*,
        const uchar*, int, int, int, int, int) const { return 0; }
};

#if CV_SSE2

struct VResizeLinearVec_32s8u
{
    int operator()(const uchar** _src, uchar* dst, const uchar* _beta, int width ) const
    {
        if( !checkHardwareSupport(CV_CPU_SSE2) )
            return 0;

        const int** src = (const int**)_src;
        const short* beta = (const short*)_beta;
        const int *S0 = src[0], *S1 = src[1];
        int x = 0;
        __m128i b0 = _mm_set1_epi16(beta[0]), b1 = _mm_set1_epi16(beta[1]);
        __m128i delta = _mm_set1_epi16(2);

        if( (((size_t)S0|(size_t)S1)&15) == 0 )
            for( ; x <= width - 16; x += 16 )
            {
                __m128i x0, x1, x2, y0, y1, y2;
                x0 = _mm_load_si128((const __m128i*)(S0 + x));
                x1 = _mm_load_si128((const __m128i*)(S0 + x + 4));
                y0 = _mm_load_si128((const __m128i*)(S1 + x));
                y1 = _mm_load_si128((const __m128i*)(S1 + x + 4));
                x0 = _mm_packs_epi32(_mm_srai_epi32(x0, 4), _mm_srai_epi32(x1, 4));
                y0 = _mm_packs_epi32(_mm_srai_epi32(y0, 4), _mm_srai_epi32(y1, 4));

                x1 = _mm_load_si128((const __m128i*)(S0 + x + 8));
                x2 = _mm_load_si128((const __m128i*)(S0 + x + 12));
                y1 = _mm_load_si128((const __m128i*)(S1 + x + 8));
                y2 = _mm_load_si128((const __m128i*)(S1 + x + 12));
                x1 = _mm_packs_epi32(_mm_srai_epi32(x1, 4), _mm_srai_epi32(x2, 4));
                y1 = _mm_packs_epi32(_mm_srai_epi32(y1, 4), _mm_srai_epi32(y2, 4));

                x0 = _mm_adds_epi16(_mm_mulhi_epi16( x0, b0 ), _mm_mulhi_epi16( y0, b1 ));
                x1 = _mm_adds_epi16(_mm_mulhi_epi16( x1, b0 ), _mm_mulhi_epi16( y1, b1 ));

                x0 = _mm_srai_epi16(_mm_adds_epi16(x0, delta), 2);
                x1 = _mm_srai_epi16(_mm_adds_epi16(x1, delta), 2);
                _mm_storeu_si128( (__m128i*)(dst + x), _mm_packus_epi16(x0, x1));
            }
        else
            for( ; x <= width - 16; x += 16 )
            {
                __m128i x0, x1, x2, y0, y1, y2;
                x0 = _mm_loadu_si128((const __m128i*)(S0 + x));
                x1 = _mm_loadu_si128((const __m128i*)(S0 + x + 4));
                y0 = _mm_loadu_si128((const __m128i*)(S1 + x));
                y1 = _mm_loadu_si128((const __m128i*)(S1 + x + 4));
                x0 = _mm_packs_epi32(_mm_srai_epi32(x0, 4), _mm_srai_epi32(x1, 4));
                y0 = _mm_packs_epi32(_mm_srai_epi32(y0, 4), _mm_srai_epi32(y1, 4));

                x1 = _mm_loadu_si128((const __m128i*)(S0 + x + 8));
                x2 = _mm_loadu_si128((const __m128i*)(S0 + x + 12));
                y1 = _mm_loadu_si128((const __m128i*)(S1 + x + 8));
                y2 = _mm_loadu_si128((const __m128i*)(S1 + x + 12));
                x1 = _mm_packs_epi32(_mm_srai_epi32(x1, 4), _mm_srai_epi32(x2, 4));
                y1 = _mm_packs_epi32(_mm_srai_epi32(y1, 4), _mm_srai_epi32(y2, 4));

                x0 = _mm_adds_epi16(_mm_mulhi_epi16( x0, b0 ), _mm_mulhi_epi16( y0, b1 ));
                x1 = _mm_adds_epi16(_mm_mulhi_epi16( x1, b0 ), _mm_mulhi_epi16( y1, b1 ));

                x0 = _mm_srai_epi16(_mm_adds_epi16(x0, delta), 2);
                x1 = _mm_srai_epi16(_mm_adds_epi16(x1, delta), 2);
                _mm_storeu_si128( (__m128i*)(dst + x), _mm_packus_epi16(x0, x1));
            }

        for( ; x < width - 4; x += 4 )
        {
            __m128i x0, y0;
            x0 = _mm_srai_epi32(_mm_loadu_si128((const __m128i*)(S0 + x)), 4);
            y0 = _mm_srai_epi32(_mm_loadu_si128((const __m128i*)(S1 + x)), 4);
            x0 = _mm_packs_epi32(x0, x0);
            y0 = _mm_packs_epi32(y0, y0);
            x0 = _mm_adds_epi16(_mm_mulhi_epi16(x0, b0), _mm_mulhi_epi16(y0, b1));
            x0 = _mm_srai_epi16(_mm_adds_epi16(x0, delta), 2);
            x0 = _mm_packus_epi16(x0, x0);
            *(int*)(dst + x) = _mm_cvtsi128_si32(x0);
        }

        return x;
    }
};


template<int shiftval> struct VResizeLinearVec_32f16
{
    int operator()(const uchar** _src, uchar* _dst, const uchar* _beta, int width ) const
    {
        if( !checkHardwareSupport(CV_CPU_SSE2) )
            return 0;

        const float** src = (const float**)_src;
        const float* beta = (const float*)_beta;
        const float *S0 = src[0], *S1 = src[1];
        ushort* dst = (ushort*)_dst;
        int x = 0;

        __m128 b0 = _mm_set1_ps(beta[0]), b1 = _mm_set1_ps(beta[1]);
        __m128i preshift = _mm_set1_epi32(shiftval);
        __m128i postshift = _mm_set1_epi16((short)shiftval);

        if( (((size_t)S0|(size_t)S1)&15) == 0 )
            for( ; x <= width - 16; x += 16 )
            {
                __m128 x0, x1, y0, y1;
                __m128i t0, t1, t2;
                x0 = _mm_load_ps(S0 + x);
                x1 = _mm_load_ps(S0 + x + 4);
                y0 = _mm_load_ps(S1 + x);
                y1 = _mm_load_ps(S1 + x + 4);

                x0 = _mm_add_ps(_mm_mul_ps(x0, b0), _mm_mul_ps(y0, b1));
                x1 = _mm_add_ps(_mm_mul_ps(x1, b0), _mm_mul_ps(y1, b1));
                t0 = _mm_add_epi32(_mm_cvtps_epi32(x0), preshift);
                t2 = _mm_add_epi32(_mm_cvtps_epi32(x1), preshift);
                t0 = _mm_add_epi16(_mm_packs_epi32(t0, t2), postshift);

                x0 = _mm_load_ps(S0 + x + 8);
                x1 = _mm_load_ps(S0 + x + 12);
                y0 = _mm_load_ps(S1 + x + 8);
                y1 = _mm_load_ps(S1 + x + 12);

                x0 = _mm_add_ps(_mm_mul_ps(x0, b0), _mm_mul_ps(y0, b1));
                x1 = _mm_add_ps(_mm_mul_ps(x1, b0), _mm_mul_ps(y1, b1));
                t1 = _mm_add_epi32(_mm_cvtps_epi32(x0), preshift);
                t2 = _mm_add_epi32(_mm_cvtps_epi32(x1), preshift);
                t1 = _mm_add_epi16(_mm_packs_epi32(t1, t2), postshift);

                _mm_storeu_si128( (__m128i*)(dst + x), t0);
                _mm_storeu_si128( (__m128i*)(dst + x + 8), t1);
            }
        else
            for( ; x <= width - 16; x += 16 )
            {
                __m128 x0, x1, y0, y1;
                __m128i t0, t1, t2;
                x0 = _mm_loadu_ps(S0 + x);
                x1 = _mm_loadu_ps(S0 + x + 4);
                y0 = _mm_loadu_ps(S1 + x);
                y1 = _mm_loadu_ps(S1 + x + 4);

                x0 = _mm_add_ps(_mm_mul_ps(x0, b0), _mm_mul_ps(y0, b1));
                x1 = _mm_add_ps(_mm_mul_ps(x1, b0), _mm_mul_ps(y1, b1));
                t0 = _mm_add_epi32(_mm_cvtps_epi32(x0), preshift);
                t2 = _mm_add_epi32(_mm_cvtps_epi32(x1), preshift);
                t0 = _mm_add_epi16(_mm_packs_epi32(t0, t2), postshift);

                x0 = _mm_loadu_ps(S0 + x + 8);
                x1 = _mm_loadu_ps(S0 + x + 12);
                y0 = _mm_loadu_ps(S1 + x + 8);
                y1 = _mm_loadu_ps(S1 + x + 12);

                x0 = _mm_add_ps(_mm_mul_ps(x0, b0), _mm_mul_ps(y0, b1));
                x1 = _mm_add_ps(_mm_mul_ps(x1, b0), _mm_mul_ps(y1, b1));
                t1 = _mm_add_epi32(_mm_cvtps_epi32(x0), preshift);
                t2 = _mm_add_epi32(_mm_cvtps_epi32(x1), preshift);
                t1 = _mm_add_epi16(_mm_packs_epi32(t1, t2), postshift);

                _mm_storeu_si128( (__m128i*)(dst + x), t0);
                _mm_storeu_si128( (__m128i*)(dst + x + 8), t1);
            }

        for( ; x < width - 4; x += 4 )
        {
            __m128 x0, y0;
            __m128i t0;
            x0 = _mm_loadu_ps(S0 + x);
            y0 = _mm_loadu_ps(S1 + x);

            x0 = _mm_add_ps(_mm_mul_ps(x0, b0), _mm_mul_ps(y0, b1));
            t0 = _mm_add_epi32(_mm_cvtps_epi32(x0), preshift);
            t0 = _mm_add_epi16(_mm_packs_epi32(t0, t0), postshift);
            _mm_storel_epi64( (__m128i*)(dst + x), t0);
        }

        return x;
    }
};

typedef VResizeLinearVec_32f16<SHRT_MIN> VResizeLinearVec_32f16u;
typedef VResizeLinearVec_32f16<0> VResizeLinearVec_32f16s;

struct VResizeLinearVec_32f
{
    int operator()(const uchar** _src, uchar* _dst, const uchar* _beta, int width ) const
    {
        if( !checkHardwareSupport(CV_CPU_SSE) )
            return 0;

        const float** src = (const float**)_src;
        const float* beta = (const float*)_beta;
        const float *S0 = src[0], *S1 = src[1];
        float* dst = (float*)_dst;
        int x = 0;

        __m128 b0 = _mm_set1_ps(beta[0]), b1 = _mm_set1_ps(beta[1]);

        if( (((size_t)S0|(size_t)S1)&15) == 0 )
            for( ; x <= width - 8; x += 8 )
            {
                __m128 x0, x1, y0, y1;
                x0 = _mm_load_ps(S0 + x);
                x1 = _mm_load_ps(S0 + x + 4);
                y0 = _mm_load_ps(S1 + x);
                y1 = _mm_load_ps(S1 + x + 4);

                x0 = _mm_add_ps(_mm_mul_ps(x0, b0), _mm_mul_ps(y0, b1));
                x1 = _mm_add_ps(_mm_mul_ps(x1, b0), _mm_mul_ps(y1, b1));

                _mm_storeu_ps( dst + x, x0);
                _mm_storeu_ps( dst + x + 4, x1);
            }
        else
            for( ; x <= width - 8; x += 8 )
            {
                __m128 x0, x1, y0, y1;
                x0 = _mm_loadu_ps(S0 + x);
                x1 = _mm_loadu_ps(S0 + x + 4);
                y0 = _mm_loadu_ps(S1 + x);
                y1 = _mm_loadu_ps(S1 + x + 4);

                x0 = _mm_add_ps(_mm_mul_ps(x0, b0), _mm_mul_ps(y0, b1));
                x1 = _mm_add_ps(_mm_mul_ps(x1, b0), _mm_mul_ps(y1, b1));

                _mm_storeu_ps( dst + x, x0);
                _mm_storeu_ps( dst + x + 4, x1);
            }

        return x;
    }
};


struct VResizeCubicVec_32s8u
{
    int operator()(const uchar** _src, uchar* dst, const uchar* _beta, int width ) const
    {
        if( !checkHardwareSupport(CV_CPU_SSE2) )
            return 0;

        const int** src = (const int**)_src;
        const short* beta = (const short*)_beta;
        const int *S0 = src[0], *S1 = src[1], *S2 = src[2], *S3 = src[3];
        int x = 0;
        float scale = 1.f/(INTER_RESIZE_COEF_SCALE*INTER_RESIZE_COEF_SCALE);
        __m128 b0 = _mm_set1_ps(beta[0]*scale), b1 = _mm_set1_ps(beta[1]*scale),
            b2 = _mm_set1_ps(beta[2]*scale), b3 = _mm_set1_ps(beta[3]*scale);

        if( (((size_t)S0|(size_t)S1|(size_t)S2|(size_t)S3)&15) == 0 )
            for( ; x <= width - 8; x += 8 )
            {
                __m128i x0, x1, y0, y1;
                __m128 s0, s1, f0, f1;
                x0 = _mm_load_si128((const __m128i*)(S0 + x));
                x1 = _mm_load_si128((const __m128i*)(S0 + x + 4));
                y0 = _mm_load_si128((const __m128i*)(S1 + x));
                y1 = _mm_load_si128((const __m128i*)(S1 + x + 4));

                s0 = _mm_mul_ps(_mm_cvtepi32_ps(x0), b0);
                s1 = _mm_mul_ps(_mm_cvtepi32_ps(x1), b0);
                f0 = _mm_mul_ps(_mm_cvtepi32_ps(y0), b1);
                f1 = _mm_mul_ps(_mm_cvtepi32_ps(y1), b1);
                s0 = _mm_add_ps(s0, f0);
                s1 = _mm_add_ps(s1, f1);

                x0 = _mm_load_si128((const __m128i*)(S2 + x));
                x1 = _mm_load_si128((const __m128i*)(S2 + x + 4));
                y0 = _mm_load_si128((const __m128i*)(S3 + x));
                y1 = _mm_load_si128((const __m128i*)(S3 + x + 4));

                f0 = _mm_mul_ps(_mm_cvtepi32_ps(x0), b2);
                f1 = _mm_mul_ps(_mm_cvtepi32_ps(x1), b2);
                s0 = _mm_add_ps(s0, f0);
                s1 = _mm_add_ps(s1, f1);
                f0 = _mm_mul_ps(_mm_cvtepi32_ps(y0), b3);
                f1 = _mm_mul_ps(_mm_cvtepi32_ps(y1), b3);
                s0 = _mm_add_ps(s0, f0);
                s1 = _mm_add_ps(s1, f1);

                x0 = _mm_cvtps_epi32(s0);
                x1 = _mm_cvtps_epi32(s1);

                x0 = _mm_packs_epi32(x0, x1);
                _mm_storel_epi64( (__m128i*)(dst + x), _mm_packus_epi16(x0, x0));
            }
        else
            for( ; x <= width - 8; x += 8 )
            {
                __m128i x0, x1, y0, y1;
                __m128 s0, s1, f0, f1;
                x0 = _mm_loadu_si128((const __m128i*)(S0 + x));
                x1 = _mm_loadu_si128((const __m128i*)(S0 + x + 4));
                y0 = _mm_loadu_si128((const __m128i*)(S1 + x));
                y1 = _mm_loadu_si128((const __m128i*)(S1 + x + 4));

                s0 = _mm_mul_ps(_mm_cvtepi32_ps(x0), b0);
                s1 = _mm_mul_ps(_mm_cvtepi32_ps(x1), b0);
                f0 = _mm_mul_ps(_mm_cvtepi32_ps(y0), b1);
                f1 = _mm_mul_ps(_mm_cvtepi32_ps(y1), b1);
                s0 = _mm_add_ps(s0, f0);
                s1 = _mm_add_ps(s1, f1);

                x0 = _mm_loadu_si128((const __m128i*)(S2 + x));
                x1 = _mm_loadu_si128((const __m128i*)(S2 + x + 4));
                y0 = _mm_loadu_si128((const __m128i*)(S3 + x));
                y1 = _mm_loadu_si128((const __m128i*)(S3 + x + 4));

                f0 = _mm_mul_ps(_mm_cvtepi32_ps(x0), b2);
                f1 = _mm_mul_ps(_mm_cvtepi32_ps(x1), b2);
                s0 = _mm_add_ps(s0, f0);
                s1 = _mm_add_ps(s1, f1);
                f0 = _mm_mul_ps(_mm_cvtepi32_ps(y0), b3);
                f1 = _mm_mul_ps(_mm_cvtepi32_ps(y1), b3);
                s0 = _mm_add_ps(s0, f0);
                s1 = _mm_add_ps(s1, f1);

                x0 = _mm_cvtps_epi32(s0);
                x1 = _mm_cvtps_epi32(s1);

                x0 = _mm_packs_epi32(x0, x1);
                _mm_storel_epi64( (__m128i*)(dst + x), _mm_packus_epi16(x0, x0));
            }

        return x;
    }
};


template<int shiftval> struct VResizeCubicVec_32f16
{
    int operator()(const uchar** _src, uchar* _dst, const uchar* _beta, int width ) const
    {
        if( !checkHardwareSupport(CV_CPU_SSE2) )
            return 0;

        const float** src = (const float**)_src;
        const float* beta = (const float*)_beta;
        const float *S0 = src[0], *S1 = src[1], *S2 = src[2], *S3 = src[3];
        ushort* dst = (ushort*)_dst;
        int x = 0;
        __m128 b0 = _mm_set1_ps(beta[0]), b1 = _mm_set1_ps(beta[1]),
            b2 = _mm_set1_ps(beta[2]), b3 = _mm_set1_ps(beta[3]);
        __m128i preshift = _mm_set1_epi32(shiftval);
        __m128i postshift = _mm_set1_epi16((short)shiftval);

        for( ; x <= width - 8; x += 8 )
        {
            __m128 x0, x1, y0, y1, s0, s1;
            __m128i t0, t1;
            x0 = _mm_loadu_ps(S0 + x);
            x1 = _mm_loadu_ps(S0 + x + 4);
            y0 = _mm_loadu_ps(S1 + x);
            y1 = _mm_loadu_ps(S1 + x + 4);

            s0 = _mm_mul_ps(x0, b0);
            s1 = _mm_mul_ps(x1, b0);
            y0 = _mm_mul_ps(y0, b1);
            y1 = _mm_mul_ps(y1, b1);
            s0 = _mm_add_ps(s0, y0);
            s1 = _mm_add_ps(s1, y1);

            x0 = _mm_loadu_ps(S2 + x);
            x1 = _mm_loadu_ps(S2 + x + 4);
            y0 = _mm_loadu_ps(S3 + x);
            y1 = _mm_loadu_ps(S3 + x + 4);

            x0 = _mm_mul_ps(x0, b2);
            x1 = _mm_mul_ps(x1, b2);
            y0 = _mm_mul_ps(y0, b3);
            y1 = _mm_mul_ps(y1, b3);
            s0 = _mm_add_ps(s0, x0);
            s1 = _mm_add_ps(s1, x1);
            s0 = _mm_add_ps(s0, y0);
            s1 = _mm_add_ps(s1, y1);

            t0 = _mm_add_epi32(_mm_cvtps_epi32(s0), preshift);
            t1 = _mm_add_epi32(_mm_cvtps_epi32(s1), preshift);

            t0 = _mm_add_epi16(_mm_packs_epi32(t0, t1), postshift);
            _mm_storeu_si128( (__m128i*)(dst + x), t0);
        }

        return x;
    }
};

typedef VResizeCubicVec_32f16<SHRT_MIN> VResizeCubicVec_32f16u;
typedef VResizeCubicVec_32f16<0> VResizeCubicVec_32f16s;

struct VResizeCubicVec_32f
{
    int operator()(const uchar** _src, uchar* _dst, const uchar* _beta, int width ) const
    {
        if( !checkHardwareSupport(CV_CPU_SSE) )
            return 0;

        const float** src = (const float**)_src;
        const float* beta = (const float*)_beta;
        const float *S0 = src[0], *S1 = src[1], *S2 = src[2], *S3 = src[3];
        float* dst = (float*)_dst;
        int x = 0;
        __m128 b0 = _mm_set1_ps(beta[0]), b1 = _mm_set1_ps(beta[1]),
            b2 = _mm_set1_ps(beta[2]), b3 = _mm_set1_ps(beta[3]);

        for( ; x <= width - 8; x += 8 )
        {
            __m128 x0, x1, y0, y1, s0, s1;
            x0 = _mm_loadu_ps(S0 + x);
            x1 = _mm_loadu_ps(S0 + x + 4);
            y0 = _mm_loadu_ps(S1 + x);
            y1 = _mm_loadu_ps(S1 + x + 4);

            s0 = _mm_mul_ps(x0, b0);
            s1 = _mm_mul_ps(x1, b0);
            y0 = _mm_mul_ps(y0, b1);
            y1 = _mm_mul_ps(y1, b1);
            s0 = _mm_add_ps(s0, y0);
            s1 = _mm_add_ps(s1, y1);

            x0 = _mm_loadu_ps(S2 + x);
            x1 = _mm_loadu_ps(S2 + x + 4);
            y0 = _mm_loadu_ps(S3 + x);
            y1 = _mm_loadu_ps(S3 + x + 4);

            x0 = _mm_mul_ps(x0, b2);
            x1 = _mm_mul_ps(x1, b2);
            y0 = _mm_mul_ps(y0, b3);
            y1 = _mm_mul_ps(y1, b3);
            s0 = _mm_add_ps(s0, x0);
            s1 = _mm_add_ps(s1, x1);
            s0 = _mm_add_ps(s0, y0);
            s1 = _mm_add_ps(s1, y1);

            _mm_storeu_ps( dst + x, s0);
            _mm_storeu_ps( dst + x + 4, s1);
        }

        return x;
    }
};

#else

typedef VResizeNoVec VResizeLinearVec_32s8u;
typedef VResizeNoVec VResizeLinearVec_32f16u;
typedef VResizeNoVec VResizeLinearVec_32f16s;
typedef VResizeNoVec VResizeLinearVec_32f;

typedef VResizeNoVec VResizeCubicVec_32s8u;
typedef VResizeNoVec VResizeCubicVec_32f16u;
typedef VResizeNoVec VResizeCubicVec_32f16s;
typedef VResizeNoVec VResizeCubicVec_32f;

#endif

typedef HResizeNoVec HResizeLinearVec_8u32s;
typedef HResizeNoVec HResizeLinearVec_16u32f;
typedef HResizeNoVec HResizeLinearVec_16s32f;
typedef HResizeNoVec HResizeLinearVec_32f;
typedef HResizeNoVec HResizeLinearVec_64f;


template<typename T, typename WT, typename AT, int ONE, class VecOp>
struct HResizeLinear
{
    typedef T value_type;
    typedef WT buf_type;
    typedef AT alpha_type;

    void operator()(const T** src, WT** dst, int count,
                    const int* xofs, const AT* alpha,
                    int swidth, int dwidth, int cn, int xmin, int xmax ) const
    {
        int dx, k;
        VecOp vecOp;

        int dx0 = vecOp((const uchar**)src, (uchar**)dst, count,
            xofs, (const uchar*)alpha, swidth, dwidth, cn, xmin, xmax );

        for( k = 0; k <= count - 2; k++ )
        {
            const T *S0 = src[k], *S1 = src[k+1];
            WT *D0 = dst[k], *D1 = dst[k+1];
            for( dx = dx0; dx < xmax; dx++ )
            {
                int sx = xofs[dx];
                WT a0 = alpha[dx*2], a1 = alpha[dx*2+1];
                WT t0 = S0[sx]*a0 + S0[sx + cn]*a1;
                WT t1 = S1[sx]*a0 + S1[sx + cn]*a1;
                D0[dx] = t0; D1[dx] = t1;
            }

            for( ; dx < dwidth; dx++ )
            {
                int sx = xofs[dx];
                D0[dx] = WT(S0[sx]*ONE); D1[dx] = WT(S1[sx]*ONE);
            }
        }

        for( ; k < count; k++ )
        {
            const T *S = src[k];
            WT *D = dst[k];
            for( dx = 0; dx < xmax; dx++ )
            {
                int sx = xofs[dx];
                D[dx] = S[sx]*alpha[dx*2] + S[sx+cn]*alpha[dx*2+1];
            }

            for( ; dx < dwidth; dx++ )
                D[dx] = WT(S[xofs[dx]]*ONE);
        }
    }
};


template<typename T, typename WT, typename AT, class CastOp, class VecOp>
struct VResizeLinear
{
    typedef T value_type;
    typedef WT buf_type;
    typedef AT alpha_type;

    void operator()(const WT** src, T* dst, const AT* beta, int width ) const
    {
        WT b0 = beta[0], b1 = beta[1];
        const WT *S0 = src[0], *S1 = src[1];
        CastOp castOp;
        VecOp vecOp;

        int x = vecOp((const uchar**)src, (uchar*)dst, (const uchar*)beta, width);
        #if CV_ENABLE_UNROLLED
        for( ; x <= width - 4; x += 4 )
        {
            WT t0, t1;
            t0 = S0[x]*b0 + S1[x]*b1;
            t1 = S0[x+1]*b0 + S1[x+1]*b1;
            dst[x] = castOp(t0); dst[x+1] = castOp(t1);
            t0 = S0[x+2]*b0 + S1[x+2]*b1;
            t1 = S0[x+3]*b0 + S1[x+3]*b1;
            dst[x+2] = castOp(t0); dst[x+3] = castOp(t1);
        }
        #endif
        for( ; x < width; x++ )
            dst[x] = castOp(S0[x]*b0 + S1[x]*b1);
    }
};

template<>
struct VResizeLinear<uchar, int, short, FixedPtCast<int, uchar, INTER_RESIZE_COEF_BITS*2>, VResizeLinearVec_32s8u>
{
    typedef uchar value_type;
    typedef int buf_type;
    typedef short alpha_type;

    void operator()(const buf_type** src, value_type* dst, const alpha_type* beta, int width ) const
    {
        alpha_type b0 = beta[0], b1 = beta[1];
        const buf_type *S0 = src[0], *S1 = src[1];
        VResizeLinearVec_32s8u vecOp;

        int x = vecOp((const uchar**)src, (uchar*)dst, (const uchar*)beta, width);
        #if CV_ENABLE_UNROLLED
        for( ; x <= width - 4; x += 4 )
        {
            dst[x+0] = uchar(( ((b0 * (S0[x+0] >> 4)) >> 16) + ((b1 * (S1[x+0] >> 4)) >> 16) + 2)>>2);
            dst[x+1] = uchar(( ((b0 * (S0[x+1] >> 4)) >> 16) + ((b1 * (S1[x+1] >> 4)) >> 16) + 2)>>2);
            dst[x+2] = uchar(( ((b0 * (S0[x+2] >> 4)) >> 16) + ((b1 * (S1[x+2] >> 4)) >> 16) + 2)>>2);
            dst[x+3] = uchar(( ((b0 * (S0[x+3] >> 4)) >> 16) + ((b1 * (S1[x+3] >> 4)) >> 16) + 2)>>2);
        }
        #endif
        for( ; x < width; x++ )
            dst[x] = uchar(( ((b0 * (S0[x] >> 4)) >> 16) + ((b1 * (S1[x] >> 4)) >> 16) + 2)>>2);
    }
};

static inline int clip(int x, int a, int b)
{
    return x >= a ? (x < b ? x : b-1) : a;
}

static const int MAX_ESIZE=16;

template <typename HResize, typename VResize>
class resizeGeneric_Invoker :
    public ParallelLoopBody
{
public:
    typedef typename HResize::value_type T;
    typedef typename HResize::buf_type WT;
    typedef typename HResize::alpha_type AT;

    resizeGeneric_Invoker(const Mat& _src, Mat &_dst, const int *_xofs, const int *_yofs,
        const AT* _alpha, const AT* __beta, const Size& _ssize, const Size &_dsize,
        int _ksize, int _xmin, int _xmax) :
        ParallelLoopBody(), src(_src), dst(_dst), xofs(_xofs), yofs(_yofs),
        alpha(_alpha), _beta(__beta), ssize(_ssize), dsize(_dsize),
        ksize(_ksize), xmin(_xmin), xmax(_xmax)
    {
    }

    virtual void operator() (const Range& range) const
    {
        int dy, cn = src.channels();
        HResize hresize;
        VResize vresize;

        int bufstep = (int)alignSize(dsize.width, 16);
        AutoBuffer<WT> _buffer(bufstep*ksize);
        const T* srows[MAX_ESIZE]={0};
        WT* rows[MAX_ESIZE]={0};
        int prev_sy[MAX_ESIZE];

        for(int k = 0; k < ksize; k++ )
        {
            prev_sy[k] = -1;
            rows[k] = (WT*)_buffer + bufstep*k;
        }

        const AT* beta = _beta + ksize * range.start;

        for( dy = range.start; dy < range.end; dy++, beta += ksize )
        {
            int sy0 = yofs[dy], k0=ksize, k1=0, ksize2 = ksize/2;

            for(int k = 0; k < ksize; k++ )
            {
                int sy = clip(sy0 - ksize2 + 1 + k, 0, ssize.height);
                for( k1 = std::max(k1, k); k1 < ksize; k1++ )
                {
                    if( sy == prev_sy[k1] ) // if the sy-th row has been computed already, reuse it.
                    {
                        if( k1 > k )
                            memcpy( rows[k], rows[k1], bufstep*sizeof(rows[0][0]) );
                        break;
                    }
                }
                if( k1 == ksize )
                    k0 = std::min(k0, k); // remember the first row that needs to be computed
                srows[k] = (T*)(src.data + src.step*sy);
                prev_sy[k] = sy;
            }

            if( k0 < ksize )
                hresize( (const T**)(srows + k0), (WT**)(rows + k0), ksize - k0, xofs, (const AT*)(alpha),
                        ssize.width, dsize.width, cn, xmin, xmax );
            vresize( (const WT**)rows, (T*)(dst.data + dst.step*dy), beta, dsize.width );
        }
    }

private:
    Mat src;
    Mat dst;
    const int* xofs, *yofs;
    const AT* alpha, *_beta;
    Size ssize, dsize;
    int ksize, xmin, xmax;
};

template<class HResize, class VResize>
static void resizeGeneric_( const Mat& src, Mat& dst,
                            const int* xofs, const void* _alpha,
                            const int* yofs, const void* _beta,
                            int xmin, int xmax, int ksize )
{
    typedef typename HResize::value_type T;
    typedef typename HResize::buf_type WT;
    typedef typename HResize::alpha_type AT;

    const AT* beta = (const AT*)_beta;
    Size ssize = src.size(), dsize = dst.size();
    int cn = src.channels();
    ssize.width *= cn;
    dsize.width *= cn;
    xmin *= cn;
    xmax *= cn;
    // image resize is a separable operation. In case of not too strong

    Range range(0, dsize.height);
    resizeGeneric_Invoker<HResize, VResize> invoker(src, dst, xofs, yofs, (const AT*)_alpha, beta,
        ssize, dsize, ksize, xmin, xmax);
    parallel_for_(range, invoker, dst.total()/(double)(1<<16));
}


struct DecimateAlpha
{
    int si, di;
    float alpha;
};


typedef void (*ResizeFunc)( const Mat& src, Mat& dst,
                            const int* xofs, const void* alpha,
                            const int* yofs, const void* beta,
                            int xmin, int xmax, int ksize );

typedef void (*ResizeAreaFastFunc)( const Mat& src, Mat& dst,
                                    const int* ofs, const int *xofs,
                                    int scale_x, int scale_y );

typedef void (*ResizeAreaFunc)( const Mat& src, Mat& dst,
                                const DecimateAlpha* xtab, int xtab_size,
                                const DecimateAlpha* ytab, int ytab_size,
                                const int* yofs);


static int computeResizeAreaTab( int ssize, int dsize, int cn, double scale, DecimateAlpha* tab )
{
    int k = 0;
    for(int dx = 0; dx < dsize; dx++ )
    {
        double fsx1 = dx * scale;
        double fsx2 = fsx1 + scale;
        double cellWidth = min(scale, ssize - fsx1);

        int sx1 = cvCeil(fsx1), sx2 = cvFloor(fsx2);

        sx2 = std::min(sx2, ssize - 1);
        sx1 = std::min(sx1, sx2);

        if( sx1 - fsx1 > 1e-3 )
        {
            assert( k < ssize*2 );
            tab[k].di = dx * cn;
            tab[k].si = (sx1 - 1) * cn;
            tab[k++].alpha = (float)((sx1 - fsx1) / cellWidth);
        }

        for(int sx = sx1; sx < sx2; sx++ )
        {
            assert( k < ssize*2 );
            tab[k].di = dx * cn;
            tab[k].si = sx * cn;
            tab[k++].alpha = float(1.0 / cellWidth);
        }

        if( fsx2 - sx2 > 1e-3 )
        {
            assert( k < ssize*2 );
            tab[k].di = dx * cn;
            tab[k].si = sx2 * cn;
            tab[k++].alpha = (float)(min(min(fsx2 - sx2, 1.), cellWidth) / cellWidth);
        }
    }
    return k;
}


}


//////////////////////////////////////////////////////////////////////////////////////////

void cv::resize( InputArray _src, OutputArray _dst, Size dsize,
                 double inv_scale_x, double inv_scale_y, int interpolation )
{
    static ResizeFunc linear_tab[] =
    {
        resizeGeneric_<
            HResizeLinear<uchar, int, short,
                INTER_RESIZE_COEF_SCALE,
                HResizeLinearVec_8u32s>,
            VResizeLinear<uchar, int, short,
                FixedPtCast<int, uchar, INTER_RESIZE_COEF_BITS*2>,
                VResizeLinearVec_32s8u> >,
        0,
        resizeGeneric_<
            HResizeLinear<ushort, float, float, 1,
                HResizeLinearVec_16u32f>,
            VResizeLinear<ushort, float, float, Cast<float, ushort>,
                VResizeLinearVec_32f16u> >,
        resizeGeneric_<
            HResizeLinear<short, float, float, 1,
                HResizeLinearVec_16s32f>,
            VResizeLinear<short, float, float, Cast<float, short>,
                VResizeLinearVec_32f16s> >,
        0,
        resizeGeneric_<
            HResizeLinear<float, float, float, 1,
                HResizeLinearVec_32f>,
            VResizeLinear<float, float, float, Cast<float, float>,
                VResizeLinearVec_32f> >,
        resizeGeneric_<
            HResizeLinear<double, double, float, 1,
                HResizeNoVec>,
            VResizeLinear<double, double, float, Cast<double, double>,
                VResizeNoVec> >,
        0
    };

    Mat src = _src.getMat();
    Size ssize = src.size();

    CV_Assert( ssize.area() > 0 );
    CV_Assert( dsize.area() || (inv_scale_x > 0 && inv_scale_y > 0) );
    if( !dsize.area() )
    {
        dsize = Size(saturate_cast<int>(src.cols*inv_scale_x),
            saturate_cast<int>(src.rows*inv_scale_y));
        CV_Assert( dsize.area() );
    }
    else
    {
        inv_scale_x = (double)dsize.width/src.cols;
        inv_scale_y = (double)dsize.height/src.rows;
    }
    _dst.create(dsize, src.type());
    Mat dst = _dst.getMat();

    int depth = src.depth(), cn = src.channels();
    double scale_x = 1./inv_scale_x, scale_y = 1./inv_scale_y;
    int k, sx, sy, dx, dy;

    if( interpolation == INTER_NEAREST )
    {
        resizeNN( src, dst, inv_scale_x, inv_scale_y );
        return;
    }

    {
        int iscale_x = saturate_cast<int>(scale_x);
        int iscale_y = saturate_cast<int>(scale_y);

        bool is_area_fast = std::abs(scale_x - iscale_x) < DBL_EPSILON &&
                std::abs(scale_y - iscale_y) < DBL_EPSILON;

        // in case of scale_x && scale_y is equal to 2
        // INTER_AREA (fast) also is equal to INTER_LINEAR
        if( interpolation == INTER_LINEAR && is_area_fast && iscale_x == 2 && iscale_y == 2 )
        {
            interpolation = INTER_AREA;
        }

        // true "area" interpolation is only implemented for the case (scale_x <= 1 && scale_y <= 1).
        // In other cases it is emulated using some variant of bilinear interpolation
        if( interpolation == INTER_AREA && scale_x >= 1 && scale_y >= 1 )
        {
            if( is_area_fast )
            {
                int area = iscale_x*iscale_y;
                size_t srcstep = src.step / src.elemSize1();
                AutoBuffer<int> _ofs(area + dsize.width*cn);
                int* ofs = _ofs;
                int* xofs = ofs + area;
#if 0
                ResizeAreaFastFunc func = areafast_tab[depth];
#else
                ResizeAreaFastFunc func = 0;
#endif
                CV_Assert( func != 0 );

                for( sy = 0, k = 0; sy < iscale_y; sy++ )
                    for( sx = 0; sx < iscale_x; sx++ )
                        ofs[k++] = (int)(sy*srcstep + sx*cn);

                for( dx = 0; dx < dsize.width; dx++ )
                {
                    int j = dx * cn;
                    sx = iscale_x * j;
                    for( k = 0; k < cn; k++ )
                        xofs[j + k] = sx + k;
                }

                func( src, dst, ofs, xofs, iscale_x, iscale_y );
                return;
            }

#if 0
            ResizeAreaFunc func = area_tab[depth];
#else
            ResizeAreaFunc func = 0;
#endif
            CV_Assert( func != 0 && cn <= 4 );

            AutoBuffer<DecimateAlpha> _xytab((ssize.width + ssize.height)*2);
            DecimateAlpha* xtab = _xytab, *ytab = xtab + ssize.width*2;

            int xtab_size = computeResizeAreaTab(ssize.width, dsize.width, cn, scale_x, xtab);
            int ytab_size = computeResizeAreaTab(ssize.height, dsize.height, 1, scale_y, ytab);

            AutoBuffer<int> _tabofs(dsize.height + 1);
            int* tabofs = _tabofs;
            for( k = 0, dy = 0; k < ytab_size; k++ )
            {
                if( k == 0 || ytab[k].di != ytab[k-1].di )
                {
                    assert( ytab[k].di == dy );
                    tabofs[dy++] = k;
                }
            }
            tabofs[dy] = ytab_size;

            func( src, dst, xtab, xtab_size, ytab, ytab_size, tabofs );
            return;
        }
    }

    int xmin = 0, xmax = dsize.width, width = dsize.width*cn;
    bool area_mode = interpolation == INTER_AREA;
    bool fixpt = depth == CV_8U;
    float fx, fy;
    ResizeFunc func=0;
    int ksize=0, ksize2;
#if 0
    if( interpolation == INTER_CUBIC )
        ksize = 4, func = cubic_tab[depth];
    else if( interpolation == INTER_LANCZOS4 )
        ksize = 8, func = lanczos4_tab[depth];
    else
#endif
        if( interpolation == INTER_LINEAR || interpolation == INTER_AREA )
        ksize = 2, func = linear_tab[depth];
    else
        CV_Error( CV_StsBadArg, "Unknown interpolation method" );
    ksize2 = ksize/2;

    CV_Assert( func != 0 );

    AutoBuffer<uchar> _buffer((width + dsize.height)*(sizeof(int) + sizeof(float)*ksize));
    int* xofs = (int*)(uchar*)_buffer;
    int* yofs = xofs + width;
    float* alpha = (float*)(yofs + dsize.height);
    short* ialpha = (short*)alpha;
    float* beta = alpha + width*ksize;
    short* ibeta = ialpha + width*ksize;
    float cbuf[MAX_ESIZE];

    for( dx = 0; dx < dsize.width; dx++ )
    {
        if( !area_mode )
        {
            fx = (float)((dx+0.5)*scale_x - 0.5);
            sx = cvFloor(fx);
            fx -= sx;
        }
        else
        {
            sx = cvFloor(dx*scale_x);
            fx = (float)((dx+1) - (sx+1)*inv_scale_x);
            fx = fx <= 0 ? 0.f : fx - cvFloor(fx);
        }

        if( sx < ksize2-1 )
        {
            xmin = dx+1;
            if( sx < 0 )
                fx = 0, sx = 0;
        }

        if( sx + ksize2 >= ssize.width )
        {
            xmax = std::min( xmax, dx );
            if( sx >= ssize.width-1 )
                fx = 0, sx = ssize.width-1;
        }

        for( k = 0, sx *= cn; k < cn; k++ )
            xofs[dx*cn + k] = sx + k;

        if( interpolation == INTER_CUBIC )
            interpolateCubic( fx, cbuf );
        else if( interpolation == INTER_LANCZOS4 )
            interpolateLanczos4( fx, cbuf );
        else
        {
            cbuf[0] = 1.f - fx;
            cbuf[1] = fx;
        }
        if( fixpt )
        {
            for( k = 0; k < ksize; k++ )
                ialpha[dx*cn*ksize + k] = saturate_cast<short>(cbuf[k]*INTER_RESIZE_COEF_SCALE);
            for( ; k < cn*ksize; k++ )
                ialpha[dx*cn*ksize + k] = ialpha[dx*cn*ksize + k - ksize];
        }
        else
        {
            for( k = 0; k < ksize; k++ )
                alpha[dx*cn*ksize + k] = cbuf[k];
            for( ; k < cn*ksize; k++ )
                alpha[dx*cn*ksize + k] = alpha[dx*cn*ksize + k - ksize];
        }
    }

    for( dy = 0; dy < dsize.height; dy++ )
    {
        if( !area_mode )
        {
            fy = (float)((dy+0.5)*scale_y - 0.5);
            sy = cvFloor(fy);
            fy -= sy;
        }
        else
        {
            sy = cvFloor(dy*scale_y);
            fy = (float)((dy+1) - (sy+1)*inv_scale_y);
            fy = fy <= 0 ? 0.f : fy - cvFloor(fy);
        }

        yofs[dy] = sy;
        if( interpolation == INTER_CUBIC )
            interpolateCubic( fy, cbuf );
        else if( interpolation == INTER_LANCZOS4 )
            interpolateLanczos4( fy, cbuf );
        else
        {
            cbuf[0] = 1.f - fy;
            cbuf[1] = fy;
        }

        if( fixpt )
        {
            for( k = 0; k < ksize; k++ )
                ibeta[dy*ksize + k] = saturate_cast<short>(cbuf[k]*INTER_RESIZE_COEF_SCALE);
        }
        else
        {
            for( k = 0; k < ksize; k++ )
                beta[dy*ksize + k] = cbuf[k];
        }
    }

    func( src, dst, xofs, fixpt ? (void*)ialpha : (void*)alpha, yofs,
          fixpt ? (void*)ibeta : (void*)beta, xmin, xmax, ksize );
}

/****************************************************************************************\
*                       General warping (affine, perspective, remap)                     *
\****************************************************************************************/

namespace cv
{

struct RemapNoVec
{
    int operator()( const Mat&, void*, const short*, const ushort*,
                    const void*, int ) const { return 0; }
};

#if CV_SSE2

struct RemapVec_8u
{
    int operator()( const Mat& _src, void* _dst, const short* XY,
                    const ushort* FXY, const void* _wtab, int width ) const
    {
        int cn = _src.channels();

        if( (cn != 1 && cn != 3 && cn != 4) || !checkHardwareSupport(CV_CPU_SSE2) )
            return 0;

        const uchar *S0 = _src.data, *S1 = _src.data + _src.step;
        const short* wtab = cn == 1 ? (const short*)_wtab : &BilinearTab_iC4[0][0][0];
        uchar* D = (uchar*)_dst;
        int x = 0, sstep = (int)_src.step;
        __m128i delta = _mm_set1_epi32(INTER_REMAP_COEF_SCALE/2);
        __m128i xy2ofs = _mm_set1_epi32(cn + (sstep << 16));
        __m128i z = _mm_setzero_si128();
        int CV_DECL_ALIGNED(16) iofs0[4], iofs1[4];

        if( cn == 1 )
        {
            for( ; x <= width - 8; x += 8 )
            {
                __m128i xy0 = _mm_loadu_si128( (const __m128i*)(XY + x*2));
                __m128i xy1 = _mm_loadu_si128( (const __m128i*)(XY + x*2 + 8));
                __m128i v0, v1, v2, v3, a0, a1, b0, b1;
                unsigned i0, i1;

                xy0 = _mm_madd_epi16( xy0, xy2ofs );
                xy1 = _mm_madd_epi16( xy1, xy2ofs );
                _mm_store_si128( (__m128i*)iofs0, xy0 );
                _mm_store_si128( (__m128i*)iofs1, xy1 );

                i0 = *(ushort*)(S0 + iofs0[0]) + (*(ushort*)(S0 + iofs0[1]) << 16);
                i1 = *(ushort*)(S0 + iofs0[2]) + (*(ushort*)(S0 + iofs0[3]) << 16);
                v0 = _mm_unpacklo_epi32(_mm_cvtsi32_si128(i0), _mm_cvtsi32_si128(i1));
                i0 = *(ushort*)(S1 + iofs0[0]) + (*(ushort*)(S1 + iofs0[1]) << 16);
                i1 = *(ushort*)(S1 + iofs0[2]) + (*(ushort*)(S1 + iofs0[3]) << 16);
                v1 = _mm_unpacklo_epi32(_mm_cvtsi32_si128(i0), _mm_cvtsi32_si128(i1));
                v0 = _mm_unpacklo_epi8(v0, z);
                v1 = _mm_unpacklo_epi8(v1, z);

                a0 = _mm_unpacklo_epi32(_mm_loadl_epi64((__m128i*)(wtab+FXY[x]*4)),
                                        _mm_loadl_epi64((__m128i*)(wtab+FXY[x+1]*4)));
                a1 = _mm_unpacklo_epi32(_mm_loadl_epi64((__m128i*)(wtab+FXY[x+2]*4)),
                                        _mm_loadl_epi64((__m128i*)(wtab+FXY[x+3]*4)));
                b0 = _mm_unpacklo_epi64(a0, a1);
                b1 = _mm_unpackhi_epi64(a0, a1);
                v0 = _mm_madd_epi16(v0, b0);
                v1 = _mm_madd_epi16(v1, b1);
                v0 = _mm_add_epi32(_mm_add_epi32(v0, v1), delta);

                i0 = *(ushort*)(S0 + iofs1[0]) + (*(ushort*)(S0 + iofs1[1]) << 16);
                i1 = *(ushort*)(S0 + iofs1[2]) + (*(ushort*)(S0 + iofs1[3]) << 16);
                v2 = _mm_unpacklo_epi32(_mm_cvtsi32_si128(i0), _mm_cvtsi32_si128(i1));
                i0 = *(ushort*)(S1 + iofs1[0]) + (*(ushort*)(S1 + iofs1[1]) << 16);
                i1 = *(ushort*)(S1 + iofs1[2]) + (*(ushort*)(S1 + iofs1[3]) << 16);
                v3 = _mm_unpacklo_epi32(_mm_cvtsi32_si128(i0), _mm_cvtsi32_si128(i1));
                v2 = _mm_unpacklo_epi8(v2, z);
                v3 = _mm_unpacklo_epi8(v3, z);

                a0 = _mm_unpacklo_epi32(_mm_loadl_epi64((__m128i*)(wtab+FXY[x+4]*4)),
                                        _mm_loadl_epi64((__m128i*)(wtab+FXY[x+5]*4)));
                a1 = _mm_unpacklo_epi32(_mm_loadl_epi64((__m128i*)(wtab+FXY[x+6]*4)),
                                        _mm_loadl_epi64((__m128i*)(wtab+FXY[x+7]*4)));
                b0 = _mm_unpacklo_epi64(a0, a1);
                b1 = _mm_unpackhi_epi64(a0, a1);
                v2 = _mm_madd_epi16(v2, b0);
                v3 = _mm_madd_epi16(v3, b1);
                v2 = _mm_add_epi32(_mm_add_epi32(v2, v3), delta);

                v0 = _mm_srai_epi32(v0, INTER_REMAP_COEF_BITS);
                v2 = _mm_srai_epi32(v2, INTER_REMAP_COEF_BITS);
                v0 = _mm_packus_epi16(_mm_packs_epi32(v0, v2), z);
                _mm_storel_epi64( (__m128i*)(D + x), v0 );
            }
        }
        else if( cn == 3 )
        {
            for( ; x <= width - 5; x += 4, D += 12 )
            {
                __m128i xy0 = _mm_loadu_si128( (const __m128i*)(XY + x*2));
                __m128i u0, v0, u1, v1;

                xy0 = _mm_madd_epi16( xy0, xy2ofs );
                _mm_store_si128( (__m128i*)iofs0, xy0 );
                const __m128i *w0, *w1;
                w0 = (const __m128i*)(wtab + FXY[x]*16);
                w1 = (const __m128i*)(wtab + FXY[x+1]*16);

                u0 = _mm_unpacklo_epi8(_mm_cvtsi32_si128(*(int*)(S0 + iofs0[0])),
                                       _mm_cvtsi32_si128(*(int*)(S0 + iofs0[0] + 3)));
                v0 = _mm_unpacklo_epi8(_mm_cvtsi32_si128(*(int*)(S1 + iofs0[0])),
                                       _mm_cvtsi32_si128(*(int*)(S1 + iofs0[0] + 3)));
                u1 = _mm_unpacklo_epi8(_mm_cvtsi32_si128(*(int*)(S0 + iofs0[1])),
                                       _mm_cvtsi32_si128(*(int*)(S0 + iofs0[1] + 3)));
                v1 = _mm_unpacklo_epi8(_mm_cvtsi32_si128(*(int*)(S1 + iofs0[1])),
                                       _mm_cvtsi32_si128(*(int*)(S1 + iofs0[1] + 3)));
                u0 = _mm_unpacklo_epi8(u0, z);
                v0 = _mm_unpacklo_epi8(v0, z);
                u1 = _mm_unpacklo_epi8(u1, z);
                v1 = _mm_unpacklo_epi8(v1, z);
                u0 = _mm_add_epi32(_mm_madd_epi16(u0, w0[0]), _mm_madd_epi16(v0, w0[1]));
                u1 = _mm_add_epi32(_mm_madd_epi16(u1, w1[0]), _mm_madd_epi16(v1, w1[1]));
                u0 = _mm_srai_epi32(_mm_add_epi32(u0, delta), INTER_REMAP_COEF_BITS);
                u1 = _mm_srai_epi32(_mm_add_epi32(u1, delta), INTER_REMAP_COEF_BITS);
                u0 = _mm_slli_si128(u0, 4);
                u0 = _mm_packs_epi32(u0, u1);
                u0 = _mm_packus_epi16(u0, u0);
                _mm_storel_epi64((__m128i*)D, _mm_srli_si128(u0,1));

                w0 = (const __m128i*)(wtab + FXY[x+2]*16);
                w1 = (const __m128i*)(wtab + FXY[x+3]*16);

                u0 = _mm_unpacklo_epi8(_mm_cvtsi32_si128(*(int*)(S0 + iofs0[2])),
                                       _mm_cvtsi32_si128(*(int*)(S0 + iofs0[2] + 3)));
                v0 = _mm_unpacklo_epi8(_mm_cvtsi32_si128(*(int*)(S1 + iofs0[2])),
                                       _mm_cvtsi32_si128(*(int*)(S1 + iofs0[2] + 3)));
                u1 = _mm_unpacklo_epi8(_mm_cvtsi32_si128(*(int*)(S0 + iofs0[3])),
                                       _mm_cvtsi32_si128(*(int*)(S0 + iofs0[3] + 3)));
                v1 = _mm_unpacklo_epi8(_mm_cvtsi32_si128(*(int*)(S1 + iofs0[3])),
                                       _mm_cvtsi32_si128(*(int*)(S1 + iofs0[3] + 3)));
                u0 = _mm_unpacklo_epi8(u0, z);
                v0 = _mm_unpacklo_epi8(v0, z);
                u1 = _mm_unpacklo_epi8(u1, z);
                v1 = _mm_unpacklo_epi8(v1, z);
                u0 = _mm_add_epi32(_mm_madd_epi16(u0, w0[0]), _mm_madd_epi16(v0, w0[1]));
                u1 = _mm_add_epi32(_mm_madd_epi16(u1, w1[0]), _mm_madd_epi16(v1, w1[1]));
                u0 = _mm_srai_epi32(_mm_add_epi32(u0, delta), INTER_REMAP_COEF_BITS);
                u1 = _mm_srai_epi32(_mm_add_epi32(u1, delta), INTER_REMAP_COEF_BITS);
                u0 = _mm_slli_si128(u0, 4);
                u0 = _mm_packs_epi32(u0, u1);
                u0 = _mm_packus_epi16(u0, u0);
                _mm_storel_epi64((__m128i*)(D + 6), _mm_srli_si128(u0,1));
            }
        }
        else if( cn == 4 )
        {
            for( ; x <= width - 4; x += 4, D += 16 )
            {
                __m128i xy0 = _mm_loadu_si128( (const __m128i*)(XY + x*2));
                __m128i u0, v0, u1, v1;

                xy0 = _mm_madd_epi16( xy0, xy2ofs );
                _mm_store_si128( (__m128i*)iofs0, xy0 );
                const __m128i *w0, *w1;
                w0 = (const __m128i*)(wtab + FXY[x]*16);
                w1 = (const __m128i*)(wtab + FXY[x+1]*16);

                u0 = _mm_unpacklo_epi8(_mm_cvtsi32_si128(*(int*)(S0 + iofs0[0])),
                                       _mm_cvtsi32_si128(*(int*)(S0 + iofs0[0] + 4)));
                v0 = _mm_unpacklo_epi8(_mm_cvtsi32_si128(*(int*)(S1 + iofs0[0])),
                                       _mm_cvtsi32_si128(*(int*)(S1 + iofs0[0] + 4)));
                u1 = _mm_unpacklo_epi8(_mm_cvtsi32_si128(*(int*)(S0 + iofs0[1])),
                                       _mm_cvtsi32_si128(*(int*)(S0 + iofs0[1] + 4)));
                v1 = _mm_unpacklo_epi8(_mm_cvtsi32_si128(*(int*)(S1 + iofs0[1])),
                                       _mm_cvtsi32_si128(*(int*)(S1 + iofs0[1] + 4)));
                u0 = _mm_unpacklo_epi8(u0, z);
                v0 = _mm_unpacklo_epi8(v0, z);
                u1 = _mm_unpacklo_epi8(u1, z);
                v1 = _mm_unpacklo_epi8(v1, z);
                u0 = _mm_add_epi32(_mm_madd_epi16(u0, w0[0]), _mm_madd_epi16(v0, w0[1]));
                u1 = _mm_add_epi32(_mm_madd_epi16(u1, w1[0]), _mm_madd_epi16(v1, w1[1]));
                u0 = _mm_srai_epi32(_mm_add_epi32(u0, delta), INTER_REMAP_COEF_BITS);
                u1 = _mm_srai_epi32(_mm_add_epi32(u1, delta), INTER_REMAP_COEF_BITS);
                u0 = _mm_packs_epi32(u0, u1);
                u0 = _mm_packus_epi16(u0, u0);
                _mm_storel_epi64((__m128i*)D, u0);

                w0 = (const __m128i*)(wtab + FXY[x+2]*16);
                w1 = (const __m128i*)(wtab + FXY[x+3]*16);

                u0 = _mm_unpacklo_epi8(_mm_cvtsi32_si128(*(int*)(S0 + iofs0[2])),
                                       _mm_cvtsi32_si128(*(int*)(S0 + iofs0[2] + 4)));
                v0 = _mm_unpacklo_epi8(_mm_cvtsi32_si128(*(int*)(S1 + iofs0[2])),
                                       _mm_cvtsi32_si128(*(int*)(S1 + iofs0[2] + 4)));
                u1 = _mm_unpacklo_epi8(_mm_cvtsi32_si128(*(int*)(S0 + iofs0[3])),
                                       _mm_cvtsi32_si128(*(int*)(S0 + iofs0[3] + 4)));
                v1 = _mm_unpacklo_epi8(_mm_cvtsi32_si128(*(int*)(S1 + iofs0[3])),
                                       _mm_cvtsi32_si128(*(int*)(S1 + iofs0[3] + 4)));
                u0 = _mm_unpacklo_epi8(u0, z);
                v0 = _mm_unpacklo_epi8(v0, z);
                u1 = _mm_unpacklo_epi8(u1, z);
                v1 = _mm_unpacklo_epi8(v1, z);
                u0 = _mm_add_epi32(_mm_madd_epi16(u0, w0[0]), _mm_madd_epi16(v0, w0[1]));
                u1 = _mm_add_epi32(_mm_madd_epi16(u1, w1[0]), _mm_madd_epi16(v1, w1[1]));
                u0 = _mm_srai_epi32(_mm_add_epi32(u0, delta), INTER_REMAP_COEF_BITS);
                u1 = _mm_srai_epi32(_mm_add_epi32(u1, delta), INTER_REMAP_COEF_BITS);
                u0 = _mm_packs_epi32(u0, u1);
                u0 = _mm_packus_epi16(u0, u0);
                _mm_storel_epi64((__m128i*)(D + 8), u0);
            }
        }

        return x;
    }
};

#else

typedef RemapNoVec RemapVec_8u;

#endif

template<class CastOp, class VecOp, typename AT>
static void remapBilinear( const Mat& _src, Mat& _dst, const Mat& _xy,
                           const Mat& _fxy, const void* _wtab,
                           int borderType, const Scalar& _borderValue )
{
    typedef typename CastOp::rtype T;
    typedef typename CastOp::type1 WT;
    Size ssize = _src.size(), dsize = _dst.size();
    int cn = _src.channels();
    const AT* wtab = (const AT*)_wtab;
    const T* S0 = (const T*)_src.data;
    size_t sstep = _src.step/sizeof(S0[0]);
    Scalar_<T> cval(saturate_cast<T>(_borderValue[0]),
        saturate_cast<T>(_borderValue[1]),
        saturate_cast<T>(_borderValue[2]),
        saturate_cast<T>(_borderValue[3]));
    int dx, dy;
    CastOp castOp;
    VecOp vecOp;

    unsigned width1 = std::max(ssize.width-1, 0), height1 = std::max(ssize.height-1, 0);
    CV_Assert( cn <= 4 && ssize.area() > 0 );
#if CV_SSE2
    if( _src.type() == CV_8UC3 )
        width1 = std::max(ssize.width-2, 0);
#endif

    for( dy = 0; dy < dsize.height; dy++ )
    {
        T* D = (T*)(_dst.data + _dst.step*dy);
        const short* XY = (const short*)(_xy.data + _xy.step*dy);
        const ushort* FXY = (const ushort*)(_fxy.data + _fxy.step*dy);
        int X0 = 0;
        bool prevInlier = false;

        for( dx = 0; dx <= dsize.width; dx++ )
        {
            bool curInlier = dx < dsize.width ?
                (unsigned)XY[dx*2] < width1 &&
                (unsigned)XY[dx*2+1] < height1 : !prevInlier;
            if( curInlier == prevInlier )
                continue;

            int X1 = dx;
            dx = X0;
            X0 = X1;
            prevInlier = curInlier;

            if( !curInlier )
            {
                int len = vecOp( _src, D, XY + dx*2, FXY + dx, wtab, X1 - dx );
                D += len*cn;
                dx += len;

                if( cn == 1 )
                {
                    for( ; dx < X1; dx++, D++ )
                    {
                        int sx = XY[dx*2], sy = XY[dx*2+1];
                        const AT* w = wtab + FXY[dx]*4;
                        const T* S = S0 + sy*sstep + sx;
                        *D = castOp(WT(S[0]*w[0] + S[1]*w[1] + S[sstep]*w[2] + S[sstep+1]*w[3]));
                    }
                }
                else if( cn == 2 )
                    for( ; dx < X1; dx++, D += 2 )
                    {
                        int sx = XY[dx*2], sy = XY[dx*2+1];
                        const AT* w = wtab + FXY[dx]*4;
                        const T* S = S0 + sy*sstep + sx*2;
                        WT t0 = S[0]*w[0] + S[2]*w[1] + S[sstep]*w[2] + S[sstep+2]*w[3];
                        WT t1 = S[1]*w[0] + S[3]*w[1] + S[sstep+1]*w[2] + S[sstep+3]*w[3];
                        D[0] = castOp(t0); D[1] = castOp(t1);
                    }
                else if( cn == 3 )
                    for( ; dx < X1; dx++, D += 3 )
                    {
                        int sx = XY[dx*2], sy = XY[dx*2+1];
                        const AT* w = wtab + FXY[dx]*4;
                        const T* S = S0 + sy*sstep + sx*3;
                        WT t0 = S[0]*w[0] + S[3]*w[1] + S[sstep]*w[2] + S[sstep+3]*w[3];
                        WT t1 = S[1]*w[0] + S[4]*w[1] + S[sstep+1]*w[2] + S[sstep+4]*w[3];
                        WT t2 = S[2]*w[0] + S[5]*w[1] + S[sstep+2]*w[2] + S[sstep+5]*w[3];
                        D[0] = castOp(t0); D[1] = castOp(t1); D[2] = castOp(t2);
                    }
                else
                    for( ; dx < X1; dx++, D += 4 )
                    {
                        int sx = XY[dx*2], sy = XY[dx*2+1];
                        const AT* w = wtab + FXY[dx]*4;
                        const T* S = S0 + sy*sstep + sx*4;
                        WT t0 = S[0]*w[0] + S[4]*w[1] + S[sstep]*w[2] + S[sstep+4]*w[3];
                        WT t1 = S[1]*w[0] + S[5]*w[1] + S[sstep+1]*w[2] + S[sstep+5]*w[3];
                        D[0] = castOp(t0); D[1] = castOp(t1);
                        t0 = S[2]*w[0] + S[6]*w[1] + S[sstep+2]*w[2] + S[sstep+6]*w[3];
                        t1 = S[3]*w[0] + S[7]*w[1] + S[sstep+3]*w[2] + S[sstep+7]*w[3];
                        D[2] = castOp(t0); D[3] = castOp(t1);
                    }
            }
            else
            {
                if( borderType == BORDER_TRANSPARENT && cn != 3 )
                {
                    D += (X1 - dx)*cn;
                    dx = X1;
                    continue;
                }

                if( cn == 1 )
                    for( ; dx < X1; dx++, D++ )
                    {
                        int sx = XY[dx*2], sy = XY[dx*2+1];
                        if( borderType == BORDER_CONSTANT &&
                            (sx >= ssize.width || sx+1 < 0 ||
                             sy >= ssize.height || sy+1 < 0) )
                        {
                            D[0] = cval[0];
                        }
                        else
                        {
                            int sx0, sx1, sy0, sy1;
                            T v0, v1, v2, v3;
                            const AT* w = wtab + FXY[dx]*4;
                            if( borderType == BORDER_REPLICATE )
                            {
                                sx0 = clip(sx, 0, ssize.width);
                                sx1 = clip(sx+1, 0, ssize.width);
                                sy0 = clip(sy, 0, ssize.height);
                                sy1 = clip(sy+1, 0, ssize.height);
                                v0 = S0[sy0*sstep + sx0];
                                v1 = S0[sy0*sstep + sx1];
                                v2 = S0[sy1*sstep + sx0];
                                v3 = S0[sy1*sstep + sx1];
                            }
                            else
                            {
                                sx0 = borderInterpolate(sx, ssize.width, borderType);
                                sx1 = borderInterpolate(sx+1, ssize.width, borderType);
                                sy0 = borderInterpolate(sy, ssize.height, borderType);
                                sy1 = borderInterpolate(sy+1, ssize.height, borderType);
                                v0 = sx0 >= 0 && sy0 >= 0 ? S0[sy0*sstep + sx0] : cval[0];
                                v1 = sx1 >= 0 && sy0 >= 0 ? S0[sy0*sstep + sx1] : cval[0];
                                v2 = sx0 >= 0 && sy1 >= 0 ? S0[sy1*sstep + sx0] : cval[0];
                                v3 = sx1 >= 0 && sy1 >= 0 ? S0[sy1*sstep + sx1] : cval[0];
                            }
                            D[0] = castOp(WT(v0*w[0] + v1*w[1] + v2*w[2] + v3*w[3]));
                        }
                    }
                else
                    for( ; dx < X1; dx++, D += cn )
                    {
                        int sx = XY[dx*2], sy = XY[dx*2+1], k;
                        if( borderType == BORDER_CONSTANT &&
                            (sx >= ssize.width || sx+1 < 0 ||
                             sy >= ssize.height || sy+1 < 0) )
                        {
                            for( k = 0; k < cn; k++ )
                                D[k] = cval[k];
                        }
                        else
                        {
                            int sx0, sx1, sy0, sy1;
                            const T *v0, *v1, *v2, *v3;
                            const AT* w = wtab + FXY[dx]*4;
                            if( borderType == BORDER_REPLICATE )
                            {
                                sx0 = clip(sx, 0, ssize.width);
                                sx1 = clip(sx+1, 0, ssize.width);
                                sy0 = clip(sy, 0, ssize.height);
                                sy1 = clip(sy+1, 0, ssize.height);
                                v0 = S0 + sy0*sstep + sx0*cn;
                                v1 = S0 + sy0*sstep + sx1*cn;
                                v2 = S0 + sy1*sstep + sx0*cn;
                                v3 = S0 + sy1*sstep + sx1*cn;
                            }
                            else if( borderType == BORDER_TRANSPARENT &&
                                ((unsigned)sx >= (unsigned)(ssize.width-1) ||
                                (unsigned)sy >= (unsigned)(ssize.height-1)))
                                continue;
                            else
                            {
                                sx0 = borderInterpolate(sx, ssize.width, borderType);
                                sx1 = borderInterpolate(sx+1, ssize.width, borderType);
                                sy0 = borderInterpolate(sy, ssize.height, borderType);
                                sy1 = borderInterpolate(sy+1, ssize.height, borderType);
                                v0 = sx0 >= 0 && sy0 >= 0 ? S0 + sy0*sstep + sx0*cn : &cval[0];
                                v1 = sx1 >= 0 && sy0 >= 0 ? S0 + sy0*sstep + sx1*cn : &cval[0];
                                v2 = sx0 >= 0 && sy1 >= 0 ? S0 + sy1*sstep + sx0*cn : &cval[0];
                                v3 = sx1 >= 0 && sy1 >= 0 ? S0 + sy1*sstep + sx1*cn : &cval[0];
                            }
                            for( k = 0; k < cn; k++ )
                                D[k] = castOp(WT(v0[k]*w[0] + v1[k]*w[1] + v2[k]*w[2] + v3[k]*w[3]));
                        }
                    }
            }
        }
    }
}


typedef void (*RemapNNFunc)(const Mat& _src, Mat& _dst, const Mat& _xy,
                            int borderType, const Scalar& _borderValue );

typedef void (*RemapFunc)(const Mat& _src, Mat& _dst, const Mat& _xy,
                          const Mat& _fxy, const void* _wtab,
                          int borderType, const Scalar& _borderValue);

class RemapInvoker :
    public ParallelLoopBody
{
public:
    RemapInvoker(const Mat& _src, Mat& _dst, const Mat *_m1,
                 const Mat *_m2, int _interpolation, int _borderType, const Scalar &_borderValue,
                 int _planar_input, RemapNNFunc _nnfunc, RemapFunc _ifunc, const void *_ctab) :
        ParallelLoopBody(), src(&_src), dst(&_dst), m1(_m1), m2(_m2),
        interpolation(_interpolation), borderType(_borderType), borderValue(_borderValue),
        planar_input(_planar_input), nnfunc(_nnfunc), ifunc(_ifunc), ctab(_ctab)
    {
    }

    virtual void operator() (const Range& range) const
    {
        int x, y, x1, y1;
        const int buf_size = 1 << 14;
        int brows0 = std::min(128, dst->rows), map_depth = m1->depth();
        int bcols0 = std::min(buf_size/brows0, dst->cols);
        brows0 = std::min(buf_size/bcols0, dst->rows);
    #if CV_SSE2
        bool useSIMD = checkHardwareSupport(CV_CPU_SSE2);
    #endif

        Mat _bufxy(brows0, bcols0, CV_16SC2), _bufa;
        if( !nnfunc )
            _bufa.create(brows0, bcols0, CV_16UC1);

        for( y = range.start; y < range.end; y += brows0 )
        {
            for( x = 0; x < dst->cols; x += bcols0 )
            {
                int brows = std::min(brows0, range.end - y);
                int bcols = std::min(bcols0, dst->cols - x);
                Mat dpart(*dst, Rect(x, y, bcols, brows));
                Mat bufxy(_bufxy, Rect(0, 0, bcols, brows));

                if( nnfunc )
                {
                    if( m1->type() == CV_16SC2 && !m2->data ) // the data is already in the right format
                        bufxy = (*m1)(Rect(x, y, bcols, brows));
                    else if( map_depth != CV_32F )
                    {
                        for( y1 = 0; y1 < brows; y1++ )
                        {
                            short* XY = (short*)(bufxy.data + bufxy.step*y1);
                            const short* sXY = (const short*)(m1->data + m1->step*(y+y1)) + x*2;
                            const ushort* sA = (const ushort*)(m2->data + m2->step*(y+y1)) + x;

                            for( x1 = 0; x1 < bcols; x1++ )
                            {
                                int a = sA[x1] & (INTER_TAB_SIZE2-1);
                                XY[x1*2] = sXY[x1*2] + NNDeltaTab_i[a][0];
                                XY[x1*2+1] = sXY[x1*2+1] + NNDeltaTab_i[a][1];
                            }
                        }
                    }
                    else if( !planar_input )
                        (*m1)(Rect(x, y, bcols, brows)).convertTo(bufxy, bufxy.depth());
                    else
                    {
                        for( y1 = 0; y1 < brows; y1++ )
                        {
                            short* XY = (short*)(bufxy.data + bufxy.step*y1);
                            const float* sX = (const float*)(m1->data + m1->step*(y+y1)) + x;
                            const float* sY = (const float*)(m2->data + m2->step*(y+y1)) + x;
                            x1 = 0;

                        #if CV_SSE2
                            if( useSIMD )
                            {
                                for( ; x1 <= bcols - 8; x1 += 8 )
                                {
                                    __m128 fx0 = _mm_loadu_ps(sX + x1);
                                    __m128 fx1 = _mm_loadu_ps(sX + x1 + 4);
                                    __m128 fy0 = _mm_loadu_ps(sY + x1);
                                    __m128 fy1 = _mm_loadu_ps(sY + x1 + 4);
                                    __m128i ix0 = _mm_cvtps_epi32(fx0);
                                    __m128i ix1 = _mm_cvtps_epi32(fx1);
                                    __m128i iy0 = _mm_cvtps_epi32(fy0);
                                    __m128i iy1 = _mm_cvtps_epi32(fy1);
                                    ix0 = _mm_packs_epi32(ix0, ix1);
                                    iy0 = _mm_packs_epi32(iy0, iy1);
                                    ix1 = _mm_unpacklo_epi16(ix0, iy0);
                                    iy1 = _mm_unpackhi_epi16(ix0, iy0);
                                    _mm_storeu_si128((__m128i*)(XY + x1*2), ix1);
                                    _mm_storeu_si128((__m128i*)(XY + x1*2 + 8), iy1);
                                }
                            }
                        #endif

                            for( ; x1 < bcols; x1++ )
                            {
                                XY[x1*2] = saturate_cast<short>(sX[x1]);
                                XY[x1*2+1] = saturate_cast<short>(sY[x1]);
                            }
                        }
                    }
                    nnfunc( *src, dpart, bufxy, borderType, borderValue );
                    continue;
                }

                Mat bufa(_bufa, Rect(0, 0, bcols, brows));
                for( y1 = 0; y1 < brows; y1++ )
                {
                    short* XY = (short*)(bufxy.data + bufxy.step*y1);
                    ushort* A = (ushort*)(bufa.data + bufa.step*y1);

                    if( m1->type() == CV_16SC2 && (m2->type() == CV_16UC1 || m2->type() == CV_16SC1) )
                    {
                        bufxy = (*m1)(Rect(x, y, bcols, brows));
                        bufa = (*m2)(Rect(x, y, bcols, brows));
                    }
                    else if( planar_input )
                    {
                        const float* sX = (const float*)(m1->data + m1->step*(y+y1)) + x;
                        const float* sY = (const float*)(m2->data + m2->step*(y+y1)) + x;

                        x1 = 0;
                    #if CV_SSE2
                        if( useSIMD )
                        {
                            __m128 scale = _mm_set1_ps((float)INTER_TAB_SIZE);
                            __m128i mask = _mm_set1_epi32(INTER_TAB_SIZE-1);
                            for( ; x1 <= bcols - 8; x1 += 8 )
                            {
                                __m128 fx0 = _mm_loadu_ps(sX + x1);
                                __m128 fx1 = _mm_loadu_ps(sX + x1 + 4);
                                __m128 fy0 = _mm_loadu_ps(sY + x1);
                                __m128 fy1 = _mm_loadu_ps(sY + x1 + 4);
                                __m128i ix0 = _mm_cvtps_epi32(_mm_mul_ps(fx0, scale));
                                __m128i ix1 = _mm_cvtps_epi32(_mm_mul_ps(fx1, scale));
                                __m128i iy0 = _mm_cvtps_epi32(_mm_mul_ps(fy0, scale));
                                __m128i iy1 = _mm_cvtps_epi32(_mm_mul_ps(fy1, scale));
                                __m128i mx0 = _mm_and_si128(ix0, mask);
                                __m128i mx1 = _mm_and_si128(ix1, mask);
                                __m128i my0 = _mm_and_si128(iy0, mask);
                                __m128i my1 = _mm_and_si128(iy1, mask);
                                mx0 = _mm_packs_epi32(mx0, mx1);
                                my0 = _mm_packs_epi32(my0, my1);
                                my0 = _mm_slli_epi16(my0, INTER_BITS);
                                mx0 = _mm_or_si128(mx0, my0);
                                _mm_storeu_si128((__m128i*)(A + x1), mx0);
                                ix0 = _mm_srai_epi32(ix0, INTER_BITS);
                                ix1 = _mm_srai_epi32(ix1, INTER_BITS);
                                iy0 = _mm_srai_epi32(iy0, INTER_BITS);
                                iy1 = _mm_srai_epi32(iy1, INTER_BITS);
                                ix0 = _mm_packs_epi32(ix0, ix1);
                                iy0 = _mm_packs_epi32(iy0, iy1);
                                ix1 = _mm_unpacklo_epi16(ix0, iy0);
                                iy1 = _mm_unpackhi_epi16(ix0, iy0);
                                _mm_storeu_si128((__m128i*)(XY + x1*2), ix1);
                                _mm_storeu_si128((__m128i*)(XY + x1*2 + 8), iy1);
                            }
                        }
                    #endif

                        for( ; x1 < bcols; x1++ )
                        {
                            int sx = cvRound(sX[x1]*INTER_TAB_SIZE);
                            int sy = cvRound(sY[x1]*INTER_TAB_SIZE);
                            int v = (sy & (INTER_TAB_SIZE-1))*INTER_TAB_SIZE + (sx & (INTER_TAB_SIZE-1));
                            XY[x1*2] = (short)(sx >> INTER_BITS);
                            XY[x1*2+1] = (short)(sy >> INTER_BITS);
                            A[x1] = (ushort)v;
                        }
                    }
                    else
                    {
                        const float* sXY = (const float*)(m1->data + m1->step*(y+y1)) + x*2;

                        for( x1 = 0; x1 < bcols; x1++ )
                        {
                            int sx = cvRound(sXY[x1*2]*INTER_TAB_SIZE);
                            int sy = cvRound(sXY[x1*2+1]*INTER_TAB_SIZE);
                            int v = (sy & (INTER_TAB_SIZE-1))*INTER_TAB_SIZE + (sx & (INTER_TAB_SIZE-1));
                            XY[x1*2] = (short)(sx >> INTER_BITS);
                            XY[x1*2+1] = (short)(sy >> INTER_BITS);
                            A[x1] = (ushort)v;
                        }
                    }
                }
                ifunc(*src, dpart, bufxy, bufa, ctab, borderType, borderValue);
            }
        }
    }

private:
    const Mat* src;
    Mat* dst;
    const Mat *m1, *m2;
    int interpolation, borderType;
    Scalar borderValue;
    int planar_input;
    RemapNNFunc nnfunc;
    RemapFunc ifunc;
    const void *ctab;
};

}

void cv::remap( InputArray _src, OutputArray _dst,
                InputArray _map1, InputArray _map2,
                int interpolation, int borderType, const Scalar& borderValue )
{
#if 0
    static RemapNNFunc nn_tab[] =
    {
        remapNearest<uchar>, remapNearest<schar>, remapNearest<ushort>, remapNearest<short>,
        remapNearest<int>, remapNearest<float>, remapNearest<double>, 0
    };
#endif
    static RemapFunc linear_tab[] =
    {
        remapBilinear<FixedPtCast<int, uchar, INTER_REMAP_COEF_BITS>, RemapVec_8u, short>, 0,
        remapBilinear<Cast<float, ushort>, RemapNoVec, float>,
        remapBilinear<Cast<float, short>, RemapNoVec, float>, 0,
        remapBilinear<Cast<float, float>, RemapNoVec, float>,
        remapBilinear<Cast<double, double>, RemapNoVec, float>, 0
    };
#if 0
    static RemapFunc cubic_tab[] =
    {
        remapBicubic<FixedPtCast<int, uchar, INTER_REMAP_COEF_BITS>, short, INTER_REMAP_COEF_SCALE>, 0,
        remapBicubic<Cast<float, ushort>, float, 1>,
        remapBicubic<Cast<float, short>, float, 1>, 0,
        remapBicubic<Cast<float, float>, float, 1>,
        remapBicubic<Cast<double, double>, float, 1>, 0
    };

    static RemapFunc lanczos4_tab[] =
    {
        remapLanczos4<FixedPtCast<int, uchar, INTER_REMAP_COEF_BITS>, short, INTER_REMAP_COEF_SCALE>, 0,
        remapLanczos4<Cast<float, ushort>, float, 1>,
        remapLanczos4<Cast<float, short>, float, 1>, 0,
        remapLanczos4<Cast<float, float>, float, 1>,
        remapLanczos4<Cast<double, double>, float, 1>, 0
    };
#endif
    Mat src = _src.getMat(), map1 = _map1.getMat(), map2 = _map2.getMat();

    CV_Assert( map1.size().area() > 0 );
    CV_Assert( !map2.data || (map2.size() == map1.size()));

    _dst.create( map1.size(), src.type() );
    Mat dst = _dst.getMat();
    if( dst.data == src.data )
        src = src.clone();

    int depth = src.depth();
    RemapNNFunc nnfunc = 0;
    RemapFunc ifunc = 0;
    const void* ctab = 0;
    bool fixpt = depth == CV_8U;
    bool planar_input = false;
#if 0
    if( interpolation == INTER_NEAREST )
    {
        nnfunc = nn_tab[depth];
        CV_Assert( nnfunc != 0 );
    }
    else
#endif
    {
        if( interpolation == INTER_AREA )
            interpolation = INTER_LINEAR;

        if( interpolation == INTER_LINEAR )
            ifunc = linear_tab[depth];
#if 0
        else
            if( interpolation == INTER_CUBIC )
            ifunc = cubic_tab[depth];
        else if( interpolation == INTER_LANCZOS4 )
            ifunc = lanczos4_tab[depth];
#endif
        else
            CV_Error( CV_StsBadArg, "Unknown interpolation method" );
        CV_Assert( ifunc != 0 );
        ctab = initInterTab2D( interpolation, fixpt );
    }

    const Mat *m1 = &map1, *m2 = &map2;

    if( (map1.type() == CV_16SC2 && (map2.type() == CV_16UC1 || map2.type() == CV_16SC1 || !map2.data)) ||
        (map2.type() == CV_16SC2 && (map1.type() == CV_16UC1 || map1.type() == CV_16SC1 || !map1.data)) )
    {
        if( map1.type() != CV_16SC2 )
            std::swap(m1, m2);
    }
    else
    {
        CV_Assert( ((map1.type() == CV_32FC2 || map1.type() == CV_16SC2) && !map2.data) ||
            (map1.type() == CV_32FC1 && map2.type() == CV_32FC1) );
        planar_input = map1.channels() == 1;
    }

    RemapInvoker invoker(src, dst, m1, m2, interpolation,
                         borderType, borderValue, planar_input, nnfunc, ifunc,
                         ctab);
    parallel_for_(Range(0, dst.rows), invoker, dst.total()/(double)(1<<16));
}


void cv::convertMaps( InputArray _map1, InputArray _map2,
                      OutputArray _dstmap1, OutputArray _dstmap2,
                      int dstm1type, bool nninterpolate )
{
    Mat map1 = _map1.getMat(), map2 = _map2.getMat(), dstmap1, dstmap2;
    Size size = map1.size();
    const Mat *m1 = &map1, *m2 = &map2;
    int m1type = m1->type(), m2type = m2->type();

    CV_Assert( (m1type == CV_16SC2 && (nninterpolate || m2type == CV_16UC1 || m2type == CV_16SC1)) ||
               (m2type == CV_16SC2 && (nninterpolate || m1type == CV_16UC1 || m1type == CV_16SC1)) ||
               (m1type == CV_32FC1 && m2type == CV_32FC1) ||
               (m1type == CV_32FC2 && !m2->data) );

    if( m2type == CV_16SC2 )
    {
        std::swap( m1, m2 );
        std::swap( m1type, m2type );
    }

    if( dstm1type <= 0 )
        dstm1type = m1type == CV_16SC2 ? CV_32FC2 : CV_16SC2;
    CV_Assert( dstm1type == CV_16SC2 || dstm1type == CV_32FC1 || dstm1type == CV_32FC2 );
    _dstmap1.create( size, dstm1type );
    dstmap1 = _dstmap1.getMat();

    if( !nninterpolate && dstm1type != CV_32FC2 )
    {
        _dstmap2.create( size, dstm1type == CV_16SC2 ? CV_16UC1 : CV_32FC1 );
        dstmap2 = _dstmap2.getMat();
    }
    else
        _dstmap2.release();

    if( m1type == dstm1type || (nninterpolate &&
        ((m1type == CV_16SC2 && dstm1type == CV_32FC2) ||
        (m1type == CV_32FC2 && dstm1type == CV_16SC2))) )
    {
        m1->convertTo( dstmap1, dstmap1.type() );
        if( dstmap2.data && dstmap2.type() == m2->type() )
            m2->copyTo( dstmap2 );
        return;
    }

    if( m1type == CV_32FC1 && dstm1type == CV_32FC2 )
    {
        Mat vdata[] = { *m1, *m2 };
        merge( vdata, 2, dstmap1 );
        return;
    }

    if( m1type == CV_32FC2 && dstm1type == CV_32FC1 )
    {
        Mat mv[] = { dstmap1, dstmap2 };
        split( *m1, mv );
        return;
    }

    if( m1->isContinuous() && (!m2->data || m2->isContinuous()) &&
        dstmap1.isContinuous() && (!dstmap2.data || dstmap2.isContinuous()) )
    {
        size.width *= size.height;
        size.height = 1;
    }

    const float scale = 1.f/INTER_TAB_SIZE;
    int x, y;
    for( y = 0; y < size.height; y++ )
    {
        const float* src1f = (const float*)(m1->data + m1->step*y);
        const float* src2f = (const float*)(m2->data + m2->step*y);
        const short* src1 = (const short*)src1f;
        const ushort* src2 = (const ushort*)src2f;

        float* dst1f = (float*)(dstmap1.data + dstmap1.step*y);
        float* dst2f = (float*)(dstmap2.data + dstmap2.step*y);
        short* dst1 = (short*)dst1f;
        ushort* dst2 = (ushort*)dst2f;

        if( m1type == CV_32FC1 && dstm1type == CV_16SC2 )
        {
            if( nninterpolate )
                for( x = 0; x < size.width; x++ )
                {
                    dst1[x*2] = saturate_cast<short>(src1f[x]);
                    dst1[x*2+1] = saturate_cast<short>(src2f[x]);
                }
            else
                for( x = 0; x < size.width; x++ )
                {
                    int ix = saturate_cast<int>(src1f[x]*INTER_TAB_SIZE);
                    int iy = saturate_cast<int>(src2f[x]*INTER_TAB_SIZE);
                    dst1[x*2] = (short)(ix >> INTER_BITS);
                    dst1[x*2+1] = (short)(iy >> INTER_BITS);
                    dst2[x] = (ushort)((iy & (INTER_TAB_SIZE-1))*INTER_TAB_SIZE + (ix & (INTER_TAB_SIZE-1)));
                }
        }
        else if( m1type == CV_32FC2 && dstm1type == CV_16SC2 )
        {
            if( nninterpolate )
                for( x = 0; x < size.width; x++ )
                {
                    dst1[x*2] = saturate_cast<short>(src1f[x*2]);
                    dst1[x*2+1] = saturate_cast<short>(src1f[x*2+1]);
                }
            else
                for( x = 0; x < size.width; x++ )
                {
                    int ix = saturate_cast<int>(src1f[x*2]*INTER_TAB_SIZE);
                    int iy = saturate_cast<int>(src1f[x*2+1]*INTER_TAB_SIZE);
                    dst1[x*2] = (short)(ix >> INTER_BITS);
                    dst1[x*2+1] = (short)(iy >> INTER_BITS);
                    dst2[x] = (ushort)((iy & (INTER_TAB_SIZE-1))*INTER_TAB_SIZE + (ix & (INTER_TAB_SIZE-1)));
                }
        }
        else if( m1type == CV_16SC2 && dstm1type == CV_32FC1 )
        {
            for( x = 0; x < size.width; x++ )
            {
                int fxy = src2 ? src2[x] : 0;
                dst1f[x] = src1[x*2] + (fxy & (INTER_TAB_SIZE-1))*scale;
                dst2f[x] = src1[x*2+1] + (fxy >> INTER_BITS)*scale;
            }
        }
        else if( m1type == CV_16SC2 && dstm1type == CV_32FC2 )
        {
            for( x = 0; x < size.width; x++ )
            {
                int fxy = src2 ? src2[x] : 0;
                dst1f[x*2] = src1[x*2] + (fxy & (INTER_TAB_SIZE-1))*scale;
                dst1f[x*2+1] = src1[x*2+1] + (fxy >> INTER_BITS)*scale;
            }
        }
        else
            CV_Error( CV_StsNotImplemented, "Unsupported combination of input/output matrices" );
    }
}


namespace cv
{

class warpAffineInvoker :
    public ParallelLoopBody
{
public:
    warpAffineInvoker(const Mat &_src, Mat &_dst, int _interpolation, int _borderType,
                      const Scalar &_borderValue, int *_adelta, int *_bdelta, double *_M) :
        ParallelLoopBody(), src(_src), dst(_dst), interpolation(_interpolation),
        borderType(_borderType), borderValue(_borderValue), adelta(_adelta), bdelta(_bdelta),
        M(_M)
    {
    }

    virtual void operator() (const Range& range) const
    {
        const int BLOCK_SZ = 64;
        short XY[BLOCK_SZ*BLOCK_SZ*2], A[BLOCK_SZ*BLOCK_SZ];
        const int AB_BITS = MAX(10, (int)INTER_BITS);
        const int AB_SCALE = 1 << AB_BITS;
        int round_delta = interpolation == INTER_NEAREST ? AB_SCALE/2 : AB_SCALE/INTER_TAB_SIZE/2, x, y, x1, y1;
    #if CV_SSE2
        bool useSIMD = checkHardwareSupport(CV_CPU_SSE2);
    #endif

        int bh0 = std::min(BLOCK_SZ/2, dst.rows);
        int bw0 = std::min(BLOCK_SZ*BLOCK_SZ/bh0, dst.cols);
        bh0 = std::min(BLOCK_SZ*BLOCK_SZ/bw0, dst.rows);

        for( y = range.start; y < range.end; y += bh0 )
        {
            for( x = 0; x < dst.cols; x += bw0 )
            {
                int bw = std::min( bw0, dst.cols - x);
                int bh = std::min( bh0, range.end - y);

                Mat _XY(bh, bw, CV_16SC2, XY), matA;
                Mat dpart(dst, Rect(x, y, bw, bh));

                for( y1 = 0; y1 < bh; y1++ )
                {
                    short* xy = XY + y1*bw*2;
                    int X0 = saturate_cast<int>((M[1]*(y + y1) + M[2])*AB_SCALE) + round_delta;
                    int Y0 = saturate_cast<int>((M[4]*(y + y1) + M[5])*AB_SCALE) + round_delta;

                    if( interpolation == INTER_NEAREST )
                        for( x1 = 0; x1 < bw; x1++ )
                        {
                            int X = (X0 + adelta[x+x1]) >> AB_BITS;
                            int Y = (Y0 + bdelta[x+x1]) >> AB_BITS;
                            xy[x1*2] = saturate_cast<short>(X);
                            xy[x1*2+1] = saturate_cast<short>(Y);
                        }
                    else
                    {
                        short* alpha = A + y1*bw;
                        x1 = 0;
                    #if CV_SSE2
                        if( useSIMD )
                        {
                            __m128i fxy_mask = _mm_set1_epi32(INTER_TAB_SIZE - 1);
                            __m128i XX = _mm_set1_epi32(X0), YY = _mm_set1_epi32(Y0);
                            for( ; x1 <= bw - 8; x1 += 8 )
                            {
                                __m128i tx0, tx1, ty0, ty1;
                                tx0 = _mm_add_epi32(_mm_loadu_si128((const __m128i*)(adelta + x + x1)), XX);
                                ty0 = _mm_add_epi32(_mm_loadu_si128((const __m128i*)(bdelta + x + x1)), YY);
                                tx1 = _mm_add_epi32(_mm_loadu_si128((const __m128i*)(adelta + x + x1 + 4)), XX);
                                ty1 = _mm_add_epi32(_mm_loadu_si128((const __m128i*)(bdelta + x + x1 + 4)), YY);

                                tx0 = _mm_srai_epi32(tx0, AB_BITS - INTER_BITS);
                                ty0 = _mm_srai_epi32(ty0, AB_BITS - INTER_BITS);
                                tx1 = _mm_srai_epi32(tx1, AB_BITS - INTER_BITS);
                                ty1 = _mm_srai_epi32(ty1, AB_BITS - INTER_BITS);

                                __m128i fx_ = _mm_packs_epi32(_mm_and_si128(tx0, fxy_mask),
                                                            _mm_and_si128(tx1, fxy_mask));
                                __m128i fy_ = _mm_packs_epi32(_mm_and_si128(ty0, fxy_mask),
                                                            _mm_and_si128(ty1, fxy_mask));
                                tx0 = _mm_packs_epi32(_mm_srai_epi32(tx0, INTER_BITS),
                                                            _mm_srai_epi32(tx1, INTER_BITS));
                                ty0 = _mm_packs_epi32(_mm_srai_epi32(ty0, INTER_BITS),
                                                    _mm_srai_epi32(ty1, INTER_BITS));
                                fx_ = _mm_adds_epi16(fx_, _mm_slli_epi16(fy_, INTER_BITS));

                                _mm_storeu_si128((__m128i*)(xy + x1*2), _mm_unpacklo_epi16(tx0, ty0));
                                _mm_storeu_si128((__m128i*)(xy + x1*2 + 8), _mm_unpackhi_epi16(tx0, ty0));
                                _mm_storeu_si128((__m128i*)(alpha + x1), fx_);
                            }
                        }
                    #endif
                        for( ; x1 < bw; x1++ )
                        {
                            int X = (X0 + adelta[x+x1]) >> (AB_BITS - INTER_BITS);
                            int Y = (Y0 + bdelta[x+x1]) >> (AB_BITS - INTER_BITS);
                            xy[x1*2] = saturate_cast<short>(X >> INTER_BITS);
                            xy[x1*2+1] = saturate_cast<short>(Y >> INTER_BITS);
                            alpha[x1] = (short)((Y & (INTER_TAB_SIZE-1))*INTER_TAB_SIZE +
                                    (X & (INTER_TAB_SIZE-1)));
                        }
                    }
                }

                if( interpolation == INTER_NEAREST )
                    remap( src, dpart, _XY, Mat(), interpolation, borderType, borderValue );
                else
                {
                    Mat _matA(bh, bw, CV_16U, A);
                    remap( src, dpart, _XY, _matA, interpolation, borderType, borderValue );
                }
            }
        }
    }

private:
    Mat src;
    Mat dst;
    int interpolation, borderType;
    Scalar borderValue;
    int *adelta, *bdelta;
    double *M;
};

}


void cv::warpAffine( InputArray _src, OutputArray _dst,
                     InputArray _M0, Size dsize,
                     int flags, int borderType, const Scalar& borderValue )
{
    Mat src = _src.getMat(), M0 = _M0.getMat();
    _dst.create( dsize.area() == 0 ? src.size() : dsize, src.type() );
    Mat dst = _dst.getMat();
    CV_Assert( src.cols > 0 && src.rows > 0 );
    if( dst.data == src.data )
        src = src.clone();

    double M[6];
    Mat matM(2, 3, CV_64F, M);
    int interpolation = flags & INTER_MAX;
    if( interpolation == INTER_AREA )
        interpolation = INTER_LINEAR;

    CV_Assert( (M0.type() == CV_32F || M0.type() == CV_64F) && M0.rows == 2 && M0.cols == 3 );
    M0.convertTo(matM, matM.type());

    if( !(flags & WARP_INVERSE_MAP) )
    {
        double D = M[0]*M[4] - M[1]*M[3];
        D = D != 0 ? 1./D : 0;
        double A11 = M[4]*D, A22=M[0]*D;
        M[0] = A11; M[1] *= -D;
        M[3] *= -D; M[4] = A22;
        double b1 = -M[0]*M[2] - M[1]*M[5];
        double b2 = -M[3]*M[2] - M[4]*M[5];
        M[2] = b1; M[5] = b2;
    }

    int x;
    AutoBuffer<int> _abdelta(dst.cols*2);
    int* adelta = &_abdelta[0], *bdelta = adelta + dst.cols;
    const int AB_BITS = MAX(10, (int)INTER_BITS);
    const int AB_SCALE = 1 << AB_BITS;

    for( x = 0; x < dst.cols; x++ )
    {
        adelta[x] = saturate_cast<int>(M[0]*x*AB_SCALE);
        bdelta[x] = saturate_cast<int>(M[3]*x*AB_SCALE);
    }

    Range range(0, dst.rows);
    warpAffineInvoker invoker(src, dst, interpolation, borderType,
                              borderValue, adelta, bdelta, M);
    parallel_for_(range, invoker, dst.total()/(double)(1<<16));
}


namespace cv
{

class warpPerspectiveInvoker :
    public ParallelLoopBody
{
public:

    warpPerspectiveInvoker(const Mat &_src, Mat &_dst, double *_M, int _interpolation,
                           int _borderType, const Scalar &_borderValue) :
        ParallelLoopBody(), src(_src), dst(_dst), M(_M), interpolation(_interpolation),
        borderType(_borderType), borderValue(_borderValue)
    {
    }

    virtual void operator() (const Range& range) const
    {
        const int BLOCK_SZ = 32;
        short XY[BLOCK_SZ*BLOCK_SZ*2], A[BLOCK_SZ*BLOCK_SZ];
        int x, y, x1, y1, width = dst.cols, height = dst.rows;

        int bh0 = std::min(BLOCK_SZ/2, height);
        int bw0 = std::min(BLOCK_SZ*BLOCK_SZ/bh0, width);
        bh0 = std::min(BLOCK_SZ*BLOCK_SZ/bw0, height);

        for( y = range.start; y < range.end; y += bh0 )
        {
            for( x = 0; x < width; x += bw0 )
            {
                int bw = std::min( bw0, width - x);
                int bh = std::min( bh0, range.end - y); // height

                Mat _XY(bh, bw, CV_16SC2, XY), matA;
                Mat dpart(dst, Rect(x, y, bw, bh));

                for( y1 = 0; y1 < bh; y1++ )
                {
                    short* xy = XY + y1*bw*2;
                    double X0 = M[0]*x + M[1]*(y + y1) + M[2];
                    double Y0 = M[3]*x + M[4]*(y + y1) + M[5];
                    double W0 = M[6]*x + M[7]*(y + y1) + M[8];

                    if( interpolation == INTER_NEAREST )
                        for( x1 = 0; x1 < bw; x1++ )
                        {
                            double W = W0 + M[6]*x1;
                            W = W ? 1./W : 0;
                            double fX = std::max((double)INT_MIN, std::min((double)INT_MAX, (X0 + M[0]*x1)*W));
                            double fY = std::max((double)INT_MIN, std::min((double)INT_MAX, (Y0 + M[3]*x1)*W));
                            int X = saturate_cast<int>(fX);
                            int Y = saturate_cast<int>(fY);

                            xy[x1*2] = saturate_cast<short>(X);
                            xy[x1*2+1] = saturate_cast<short>(Y);
                        }
                    else
                    {
                        short* alpha = A + y1*bw;
                        for( x1 = 0; x1 < bw; x1++ )
                        {
                            double W = W0 + M[6]*x1;
                            W = W ? INTER_TAB_SIZE/W : 0;
                            double fX = std::max((double)INT_MIN, std::min((double)INT_MAX, (X0 + M[0]*x1)*W));
                            double fY = std::max((double)INT_MIN, std::min((double)INT_MAX, (Y0 + M[3]*x1)*W));
                            int X = saturate_cast<int>(fX);
                            int Y = saturate_cast<int>(fY);

                            xy[x1*2] = saturate_cast<short>(X >> INTER_BITS);
                            xy[x1*2+1] = saturate_cast<short>(Y >> INTER_BITS);
                            alpha[x1] = (short)((Y & (INTER_TAB_SIZE-1))*INTER_TAB_SIZE +
                                                (X & (INTER_TAB_SIZE-1)));
                        }
                    }
                }

                if( interpolation == INTER_NEAREST )
                    remap( src, dpart, _XY, Mat(), interpolation, borderType, borderValue );
                else
                {
                    Mat _matA(bh, bw, CV_16U, A);
                    remap( src, dpart, _XY, _matA, interpolation, borderType, borderValue );
                }
            }
        }
    }

private:
    Mat src;
    Mat dst;
    double* M;
    int interpolation, borderType;
    Scalar borderValue;
};

}

void cv::warpPerspective( InputArray _src, OutputArray _dst, InputArray _M0,
                          Size dsize, int flags, int borderType, const Scalar& borderValue )
{
    Mat src = _src.getMat(), M0 = _M0.getMat();
    _dst.create( dsize.area() == 0 ? src.size() : dsize, src.type() );
    Mat dst = _dst.getMat();

    CV_Assert( src.cols > 0 && src.rows > 0 );
    if( dst.data == src.data )
        src = src.clone();

    double M[9];
    Mat matM(3, 3, CV_64F, M);
    int interpolation = flags & INTER_MAX;
    if( interpolation == INTER_AREA )
        interpolation = INTER_LINEAR;

    CV_Assert( (M0.type() == CV_32F || M0.type() == CV_64F) && M0.rows == 3 && M0.cols == 3 );
    M0.convertTo(matM, matM.type());

    if( !(flags & WARP_INVERSE_MAP) )
         invert(matM, matM);

    Range range(0, dst.rows);
    warpPerspectiveInvoker invoker(src, dst, M, interpolation, borderType, borderValue);
    parallel_for_(range, invoker, dst.total()/(double)(1<<16));
}


cv::Mat cv::getRotationMatrix2D( Point2f center, double angle, double scale )
{
    angle *= CV_PI/180;
    double alpha = cos(angle)*scale;
    double beta = sin(angle)*scale;

    Mat M(2, 3, CV_64F);
    double* m = (double*)M.data;

    m[0] = alpha;
    m[1] = beta;
    m[2] = (1-alpha)*center.x - beta*center.y;
    m[3] = -beta;
    m[4] = alpha;
    m[5] = beta*center.x + (1-alpha)*center.y;

    return M;
}

/* Calculates coefficients of perspective transformation
 * which maps (xi,yi) to (ui,vi), (i=1,2,3,4):
 *
 *      c00*xi + c01*yi + c02
 * ui = ---------------------
 *      c20*xi + c21*yi + c22
 *
 *      c10*xi + c11*yi + c12
 * vi = ---------------------
 *      c20*xi + c21*yi + c22
 *
 * Coefficients are calculated by solving linear system:
 * / x0 y0  1  0  0  0 -x0*u0 -y0*u0 \ /c00\ /u0\
 * | x1 y1  1  0  0  0 -x1*u1 -y1*u1 | |c01| |u1|
 * | x2 y2  1  0  0  0 -x2*u2 -y2*u2 | |c02| |u2|
 * | x3 y3  1  0  0  0 -x3*u3 -y3*u3 |.|c10|=|u3|,
 * |  0  0  0 x0 y0  1 -x0*v0 -y0*v0 | |c11| |v0|
 * |  0  0  0 x1 y1  1 -x1*v1 -y1*v1 | |c12| |v1|
 * |  0  0  0 x2 y2  1 -x2*v2 -y2*v2 | |c20| |v2|
 * \  0  0  0 x3 y3  1 -x3*v3 -y3*v3 / \c21/ \v3/
 *
 * where:
 *   cij - matrix coefficients, c22 = 1
 */
cv::Mat cv::getPerspectiveTransform( const Point2f src[], const Point2f dst[] )
{
    Mat M(3, 3, CV_64F), X(8, 1, CV_64F, M.data);
    double a[8][8], b[8];
    Mat A(8, 8, CV_64F, a), B(8, 1, CV_64F, b);

    for( int i = 0; i < 4; ++i )
    {
        a[i][0] = a[i+4][3] = src[i].x;
        a[i][1] = a[i+4][4] = src[i].y;
        a[i][2] = a[i+4][5] = 1;
        a[i][3] = a[i][4] = a[i][5] =
        a[i+4][0] = a[i+4][1] = a[i+4][2] = 0;
        a[i][6] = -src[i].x*dst[i].x;
        a[i][7] = -src[i].y*dst[i].x;
        a[i+4][6] = -src[i].x*dst[i].y;
        a[i+4][7] = -src[i].y*dst[i].y;
        b[i] = dst[i].x;
        b[i+4] = dst[i].y;
    }

    solve( A, B, X, DECOMP_SVD );
    ((double*)M.data)[8] = 1.;

    return M;
}

/* Calculates coefficients of affine transformation
 * which maps (xi,yi) to (ui,vi), (i=1,2,3):
 *
 * ui = c00*xi + c01*yi + c02
 *
 * vi = c10*xi + c11*yi + c12
 *
 * Coefficients are calculated by solving linear system:
 * / x0 y0  1  0  0  0 \ /c00\ /u0\
 * | x1 y1  1  0  0  0 | |c01| |u1|
 * | x2 y2  1  0  0  0 | |c02| |u2|
 * |  0  0  0 x0 y0  1 | |c10| |v0|
 * |  0  0  0 x1 y1  1 | |c11| |v1|
 * \  0  0  0 x2 y2  1 / |c12| |v2|
 *
 * where:
 *   cij - matrix coefficients
 */

cv::Mat cv::getAffineTransform( const Point2f src[], const Point2f dst[] )
{
    Mat M(2, 3, CV_64F), X(6, 1, CV_64F, M.data);
    double a[6*6], b[6];
    Mat A(6, 6, CV_64F, a), B(6, 1, CV_64F, b);

    for( int i = 0; i < 3; i++ )
    {
        int j = i*12;
        int k = i*12+6;
        a[j] = a[k+3] = src[i].x;
        a[j+1] = a[k+4] = src[i].y;
        a[j+2] = a[k+5] = 1;
        a[j+3] = a[j+4] = a[j+5] = 0;
        a[k] = a[k+1] = a[k+2] = 0;
        b[i*2] = dst[i].x;
        b[i*2+1] = dst[i].y;
    }

    solve( A, B, X );
    return M;
}

void cv::invertAffineTransform(InputArray _matM, OutputArray __iM)
{
    Mat matM = _matM.getMat();
    CV_Assert(matM.rows == 2 && matM.cols == 3);
    __iM.create(2, 3, matM.type());
    Mat _iM = __iM.getMat();

    if( matM.type() == CV_32F )
    {
        const float* M = (const float*)matM.data;
        float* iM = (float*)_iM.data;
        int step = (int)(matM.step/sizeof(M[0])), istep = (int)(_iM.step/sizeof(iM[0]));

        double D = M[0]*M[step+1] - M[1]*M[step];
        D = D != 0 ? 1./D : 0;
        double A11 = M[step+1]*D, A22 = M[0]*D, A12 = -M[1]*D, A21 = -M[step]*D;
        double b1 = -A11*M[2] - A12*M[step+2];
        double b2 = -A21*M[2] - A22*M[step+2];

        iM[0] = (float)A11; iM[1] = (float)A12; iM[2] = (float)b1;
        iM[istep] = (float)A21; iM[istep+1] = (float)A22; iM[istep+2] = (float)b2;
    }
    else if( matM.type() == CV_64F )
    {
        const double* M = (const double*)matM.data;
        double* iM = (double*)_iM.data;
        int step = (int)(matM.step/sizeof(M[0])), istep = (int)(_iM.step/sizeof(iM[0]));

        double D = M[0]*M[step+1] - M[1]*M[step];
        D = D != 0 ? 1./D : 0;
        double A11 = M[step+1]*D, A22 = M[0]*D, A12 = -M[1]*D, A21 = -M[step]*D;
        double b1 = -A11*M[2] - A12*M[step+2];
        double b2 = -A21*M[2] - A22*M[step+2];

        iM[0] = A11; iM[1] = A12; iM[2] = b1;
        iM[istep] = A21; iM[istep+1] = A22; iM[istep+2] = b2;
    }
    else
        CV_Error( CV_StsUnsupportedFormat, "" );
}

cv::Mat cv::getPerspectiveTransform(InputArray _src, InputArray _dst)
{
    Mat src = _src.getMat(), dst = _dst.getMat();
    CV_Assert(src.checkVector(2, CV_32F) == 4 && dst.checkVector(2, CV_32F) == 4);
    return getPerspectiveTransform((const Point2f*)src.data, (const Point2f*)dst.data);
}

cv::Mat cv::getAffineTransform(InputArray _src, InputArray _dst)
{
    Mat src = _src.getMat(), dst = _dst.getMat();
    CV_Assert(src.checkVector(2, CV_32F) == 3 && dst.checkVector(2, CV_32F) == 3);
    return getAffineTransform((const Point2f*)src.data, (const Point2f*)dst.data);
}

/* End of file. */