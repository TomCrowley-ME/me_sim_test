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

/* ////////////////////////////////////////////////////////////////////
//
//  CvMat, CvMatND, CvSparceMat and IplImage support functions
//  (creation, deletion, copying, retrieving and setting elements etc.)
//
// */

#include <opencv2/core_c.h>
#include <opencv2/core.hpp>
#include <opencv2/internal.hpp>
#include <opencv2/mat.hpp>

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

/****************************************************************************************\
*                               CvMat creation and basic operations                      *
\****************************************************************************************/

// Creates CvMat and underlying data
CV_IMPL CvMat*
cvCreateMat( int height, int width, int type )
{
    CvMat* arr = cvCreateMatHeader( height, width, type );
    cvCreateData( arr );

    return arr;
}

static void icvCheckHuge( CvMat* arr )
{
    if( (int64)arr->step*arr->rows > INT_MAX )
        arr->type &= ~CV_MAT_CONT_FLAG;
}

// Creates CvMat header only
CV_IMPL CvMat*
cvCreateMatHeader( int rows, int cols, int type )
{
    type = CV_MAT_TYPE(type);

    if( rows < 0 || cols <= 0 )
        CV_Error( CV_StsBadSize, "Non-positive width or height" );

    int min_step = CV_ELEM_SIZE(type)*cols;
    if( min_step <= 0 )
        CV_Error( CV_StsUnsupportedFormat, "Invalid matrix type" );

    CvMat* arr = (CvMat*)cvAlloc( sizeof(*arr));

    arr->step = min_step;
    arr->type = CV_MAT_MAGIC_VAL | type | CV_MAT_CONT_FLAG;
    arr->rows = rows;
    arr->cols = cols;
    arr->data.ptr = 0;
    arr->refcount = 0;
    arr->hdr_refcount = 1;

    icvCheckHuge( arr );
    return arr;
}


// Deallocates the CvMat structure and underlying data
CV_IMPL void
cvReleaseMat( CvMat** array )
{
    if( !array )
        CV_Error( CV_HeaderIsNull, "" );

    if( *array )
    {
        CvMat* arr = *array;
#if 0
        if( !CV_IS_MAT_HDR_Z(arr) && !CV_IS_MATND_HDR(arr) )
            CV_Error( CV_StsBadFlag, "" );
#endif
        *array = 0;

        cvDecRefData( arr );
        cvFree( &arr );
    }
}

// Creates a copy of matrix
CV_IMPL CvMat*
cvCloneMat( const CvMat* src )
{
    if( !CV_IS_MAT_HDR( src ))
        CV_Error( CV_StsBadArg, "Bad CvMat header" );

    CvMat* dst = cvCreateMatHeader( src->rows, src->cols, src->type );

    if( src->data.ptr )
    {
        cvCreateData( dst );
        cvCopy( src, dst );
    }

    return dst;
}

/****************************************************************************************\
*                          Common for multiple array types operations                    *
\****************************************************************************************/

// Allocates underlying array data
CV_IMPL void
cvCreateData( CvArr* arr )
{
    if( CV_IS_MAT_HDR_Z( arr ))
    {
        size_t step, total_size;
        CvMat* mat = (CvMat*)arr;
        step = mat->step;

        if( mat->rows == 0 || mat->cols == 0 )
            return;

        if( mat->data.ptr != 0 )
            CV_Error( CV_StsError, "Data is already allocated" );

        if( step == 0 )
            step = CV_ELEM_SIZE(mat->type)*mat->cols;

        int64 _total_size = (int64)step*mat->rows + sizeof(int) + CV_MALLOC_ALIGN;
        total_size = (size_t)_total_size;
        if(_total_size != (int64)total_size)
            CV_Error(CV_StsNoMem, "Too big buffer is allocated" );
        mat->refcount = (int*)cvAlloc( (size_t)total_size );
        mat->data.ptr = (uchar*)cvAlignPtr( mat->refcount + 1, CV_MALLOC_ALIGN );
        *mat->refcount = 1;
    }
    else
        CV_Error( CV_StsBadArg, "unrecognized or unsupported array type" );
}


// Deallocates array's data
CV_IMPL void
cvReleaseData( CvArr* arr )
{
    if( CV_IS_MAT_HDR( arr ))// || CV_IS_MATND_HDR( arr ))
    {
        CvMat* mat = (CvMat*)arr;
        cvDecRefData( mat );
    }
    else
        CV_Error( CV_StsBadArg, "unrecognized or unsupported array type" );
}


// Selects sub-array (no data is copied)
CV_IMPL  CvMat*
cvGetSubRect( const CvArr* arr, CvMat* submat, CvRect rect )
{
    CvMat* res = 0;
    CvMat stub, *mat = (CvMat*)arr;

    if( !CV_IS_MAT( mat ))
        mat = cvGetMat( mat, &stub );

    if( !submat )
        CV_Error( CV_StsNullPtr, "" );

    if( (rect.x|rect.y|rect.width|rect.height) < 0 )
        CV_Error( CV_StsBadSize, "" );

    if( rect.x + rect.width > mat->cols ||
        rect.y + rect.height > mat->rows )
        CV_Error( CV_StsBadSize, "" );

    {
    /*
    int* refcount = mat->refcount;

    if( refcount )
        ++*refcount;

    cvDecRefData( submat );
    */
    submat->data.ptr = mat->data.ptr + (size_t)rect.y*mat->step +
                       rect.x*CV_ELEM_SIZE(mat->type);
    submat->step = mat->step;
    submat->type = (mat->type & (rect.width < mat->cols ? ~CV_MAT_CONT_FLAG : -1)) |
                   (rect.height <= 1 ? CV_MAT_CONT_FLAG : 0);
    submat->rows = rect.height;
    submat->cols = rect.width;
    submat->refcount = 0;
    res = submat;
    }

    return res;
}

// Selects array's row span.
CV_IMPL  CvMat*
cvGetRows( const CvArr* arr, CvMat* submat,
           int start_row, int end_row, int delta_row )
{
    CvMat* res = 0;
    CvMat stub, *mat = (CvMat*)arr;

    if( !CV_IS_MAT( mat ))
        mat = cvGetMat( mat, &stub );

    if( !submat )
        CV_Error( CV_StsNullPtr, "" );

    if( (unsigned)start_row >= (unsigned)mat->rows ||
        (unsigned)end_row > (unsigned)mat->rows || delta_row <= 0 )
        CV_Error( CV_StsOutOfRange, "" );

    {
    /*
    int* refcount = mat->refcount;

    if( refcount )
        ++*refcount;

    cvDecRefData( submat );
    */
    if( delta_row == 1 )
    {
        submat->rows = end_row - start_row;
        submat->step = mat->step;
    }
    else
    {
        submat->rows = (end_row - start_row + delta_row - 1)/delta_row;
        submat->step = mat->step * delta_row;
    }

    submat->cols = mat->cols;
    submat->step &= submat->rows > 1 ? -1 : 0;
    submat->data.ptr = mat->data.ptr + (size_t)start_row*mat->step;
    submat->type = (mat->type | (submat->rows == 1 ? CV_MAT_CONT_FLAG : 0)) &
                   (delta_row != 1 && submat->rows > 1 ? ~CV_MAT_CONT_FLAG : -1);
    submat->refcount = 0;
    submat->hdr_refcount = 0;
    res = submat;
    }

    return res;
}


// Selects array's column span.
CV_IMPL  CvMat*
cvGetCols( const CvArr* arr, CvMat* submat, int start_col, int end_col )
{
    CvMat* res = 0;
    CvMat stub, *mat = (CvMat*)arr;
    int cols;

    if( !CV_IS_MAT( mat ))
        mat = cvGetMat( mat, &stub );

    if( !submat )
        CV_Error( CV_StsNullPtr, "" );

    cols = mat->cols;
    if( (unsigned)start_col >= (unsigned)cols ||
        (unsigned)end_col > (unsigned)cols )
        CV_Error( CV_StsOutOfRange, "" );

    {
    /*
    int* refcount = mat->refcount;

    if( refcount )
        ++*refcount;

    cvDecRefData( submat );
    */
    submat->rows = mat->rows;
    submat->cols = end_col - start_col;
    submat->step = mat->step;
    submat->data.ptr = mat->data.ptr + (size_t)start_col*CV_ELEM_SIZE(mat->type);
    submat->type = mat->type & (submat->rows > 1 && submat->cols < cols ? ~CV_MAT_CONT_FLAG : -1);
    submat->refcount = 0;
    submat->hdr_refcount = 0;
    res = submat;
    }

    return res;
}


/****************************************************************************************\
*                             Conversion to CvMat or IplImage                            *
\****************************************************************************************/

// convert array (CvMat or IplImage) to CvMat
CV_IMPL CvMat*
cvGetMat( const CvArr* array, CvMat* mat,
          int* pCOI, int allowND )
{
    CvMat* result = 0;
    CvMat* src = (CvMat*)array;
    int coi = 0;

    if( !mat || !src )
        CV_Error( CV_StsNullPtr, "NULL array pointer is passed" );

    if( CV_IS_MAT_HDR(src))
    {
        if( !src->data.ptr )
            CV_Error( CV_StsNullPtr, "The matrix has NULL data pointer" );

        result = (CvMat*)src;
    }
    else
        CV_Error( CV_StsBadFlag, "Unrecognized or unsupported array type" );

    if( pCOI )
        *pCOI = coi;

    return result;
}


CV_IMPL CvMat*
cvReshape( const CvArr* array, CvMat* header,
           int new_cn, int new_rows )
{
    CvMat* result = 0;
    CvMat *mat = (CvMat*)array;
    int total_width, new_width;

    if( !header )
        CV_Error( CV_StsNullPtr, "" );

    if( !CV_IS_MAT( mat ))
    {
        int coi = 0;
        mat = cvGetMat( mat, header, &coi, 1 );
        if( coi )
            CV_Error( CV_BadCOI, "COI is not supported" );
    }

    if( new_cn == 0 )
        new_cn = CV_MAT_CN(mat->type);
    else if( (unsigned)(new_cn - 1) > 3 )
        CV_Error( CV_BadNumChannels, "" );

    if( mat != header )
    {
        int hdr_refcount = header->hdr_refcount;
        *header = *mat;
        header->refcount = 0;
        header->hdr_refcount = hdr_refcount;
    }

    total_width = mat->cols * CV_MAT_CN( mat->type );

    if( (new_cn > total_width || total_width % new_cn != 0) && new_rows == 0 )
        new_rows = mat->rows * total_width / new_cn;

    if( new_rows == 0 || new_rows == mat->rows )
    {
        header->rows = mat->rows;
        header->step = mat->step;
    }
    else
    {
        int total_size = total_width * mat->rows;
        if( !CV_IS_MAT_CONT( mat->type ))
            CV_Error( CV_BadStep,
            "The matrix is not continuous, thus its number of rows can not be changed" );

        if( (unsigned)new_rows > (unsigned)total_size )
            CV_Error( CV_StsOutOfRange, "Bad new number of rows" );

        total_width = total_size / new_rows;

        if( total_width * new_rows != total_size )
            CV_Error( CV_StsBadArg, "The total number of matrix elements "
                                    "is not divisible by the new number of rows" );

        header->rows = new_rows;
        header->step = total_width * CV_ELEM_SIZE1(mat->type);
    }

    new_width = total_width / new_cn;

    if( new_width * new_cn != total_width )
        CV_Error( CV_BadNumChannels,
        "The total width is not divisible by the new number of channels" );

    header->cols = new_width;
    header->type = (mat->type  & ~CV_MAT_TYPE_MASK) | CV_MAKETYPE(mat->type, new_cn);

    result = header;
    return  result;
}

namespace cv
{

template<> void Ptr<CvMat>::delete_obj()
{ cvReleaseMat(&obj); }

}

/* End of file. */
