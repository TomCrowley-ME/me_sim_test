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
// Copyright (C) 2009-2010, Willow Garage Inc., all rights reserved.
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
//  Mat basic operations: Copy, Set
//
// */

#include <opencv2/core_c.h>
#include <opencv2/core.hpp>
#include <opencv2/internal.hpp>
#include <opencv2/mat.hpp>

#include <iostream>

namespace cv
{

class MatOp_Identity : public MatOp
{
public:
    MatOp_Identity() {}
    virtual ~MatOp_Identity() {}

    bool elementWise(const MatExpr& /*expr*/) const { return true; }
    void assign(const MatExpr& expr, Mat& m, int type=-1) const;

    static void makeExpr(MatExpr& res, const Mat& m);
};

static MatOp_Identity g_MatOp_Identity;

class MatOp_AddEx : public MatOp
{
public:
    MatOp_AddEx() {}
    virtual ~MatOp_AddEx() {}

    bool elementWise(const MatExpr& /*expr*/) const { return true; }
    void assign(const MatExpr& expr, Mat& m, int type=-1) const;
    static void makeExpr(MatExpr& res, const Mat& a, const Mat& b, double alpha, double beta, const Scalar& s=Scalar());
};

static MatOp_AddEx g_MatOp_AddEx;

class MatOp_GEMM : public MatOp
{
public:
    MatOp_GEMM() {}
    virtual ~MatOp_GEMM() {}

    bool elementWise(const MatExpr& /*expr*/) const { return false; }
    void assign(const MatExpr& expr, Mat& m, int type=-1) const;
    static void makeExpr(MatExpr& res, int flags, const Mat& a, const Mat& b,
                         double alpha=1, const Mat& c=Mat(), double beta=1);
};

static MatOp_GEMM g_MatOp_GEMM;

class MatOp_Invert : public MatOp
{
public:
    MatOp_Invert() {}
    virtual ~MatOp_Invert() {}

    bool elementWise(const MatExpr& /*expr*/) const { return false; }
    void assign(const MatExpr& expr, Mat& m, int type=-1) const;

    void matmul(const MatExpr& expr1, const MatExpr& expr2, MatExpr& res) const;

    static void makeExpr(MatExpr& res, int method, const Mat& m);
};

static MatOp_Invert g_MatOp_Invert;


class MatOp_T : public MatOp
{
public:
    MatOp_T() {}
    virtual ~MatOp_T() {}

    bool elementWise(const MatExpr& /*expr*/) const { return false; }
    void assign(const MatExpr& expr, Mat& m, int type=-1) const;

    void multiply(const MatExpr& e1, double s, MatExpr& res) const;
    void transpose(const MatExpr& expr, MatExpr& res) const;

    static void makeExpr(MatExpr& res, const Mat& a, double alpha=1);
};

static MatOp_T g_MatOp_T;


class MatOp_Solve : public MatOp
{
public:
    MatOp_Solve() {}
    virtual ~MatOp_Solve() {}

    bool elementWise(const MatExpr& /*expr*/) const { return false; }
    void assign(const MatExpr& expr, Mat& m, int type=-1) const;

    static void makeExpr(MatExpr& res, int method, const Mat& a, const Mat& b);
};

static MatOp_Solve g_MatOp_Solve;

class MatOp_Initializer : public MatOp
{
public:
    MatOp_Initializer() {}
    virtual ~MatOp_Initializer() {}

    bool elementWise(const MatExpr& /*expr*/) const { return false; }
    void assign(const MatExpr& expr, Mat& m, int type=-1) const;

    static void makeExpr(MatExpr& res, int method, Size sz, int type, double alpha=1);
};

static MatOp_Initializer g_MatOp_Initializer;

static inline bool isIdentity(const MatExpr& e) { return e.op == &g_MatOp_Identity; }
static inline bool isAddEx(const MatExpr& e) { return e.op == &g_MatOp_AddEx; }
static inline bool isScaled(const MatExpr& e) { return isAddEx(e) && (!e.b.data || e.beta == 0) && e.s == Scalar(); }
static inline bool isT(const MatExpr& e) { return e.op == &g_MatOp_T; }
static inline bool isInv(const MatExpr& e) { return e.op == &g_MatOp_Invert; }
static inline bool isSolve(const MatExpr& e) { return e.op == &g_MatOp_Solve; }
static inline bool isGEMM(const MatExpr& e) { return e.op == &g_MatOp_GEMM; }
static inline bool isMatProd(const MatExpr& e) { return e.op == &g_MatOp_GEMM && (!e.c.data || e.beta == 0); }
static inline bool isInitializer(const MatExpr& e) { return e.op == &g_MatOp_Initializer; }

/////////////////////////////////////////////////////////////////////////////////////////////////////

bool MatOp::elementWise(const MatExpr& /*expr*/) const
{
    return false;
}


void MatOp::diag(const MatExpr& expr, int d, MatExpr& e) const
{
    if( elementWise(expr) )
    {
        e = MatExpr(expr.op, expr.flags, Mat(), Mat(), Mat(),
                    expr.alpha, expr.beta, expr.s);
        if(expr.a.data)
            e.a = expr.a.diag(d);
        if(expr.b.data)
            e.b = expr.b.diag(d);
        if(expr.c.data)
            e.c = expr.c.diag(d);
    }
    else
    {
        Mat m;
        expr.op->assign(expr, m);
        e = MatExpr(&g_MatOp_Identity, 0, m.diag(d), Mat(), Mat());
    }
}



void MatOp::add(const MatExpr& e1, const MatExpr& e2, MatExpr& res) const
{
    if( this == e2.op )
    {
        double alpha = 1, beta = 1;
        Scalar s;
        Mat m1, m2;
        if( isAddEx(e1) && (!e1.b.data || e1.beta == 0) )
        {
            m1 = e1.a;
            alpha = e1.alpha;
            s = e1.s;
        }
        else
            e1.op->assign(e1, m1);

        if( isAddEx(e2) && (!e2.b.data || e2.beta == 0) )
        {
            m2 = e2.a;
            beta = e2.alpha;
            s += e2.s;
        }
        else
            e2.op->assign(e2, m2);
        MatOp_AddEx::makeExpr(res, m1, m2, alpha, beta, s);
    }
    else
        e2.op->add(e1, e2, res);
}


void MatOp::add(const MatExpr& expr1, const Scalar& s, MatExpr& res) const
{
    Mat m1;
    expr1.op->assign(expr1, m1);
    MatOp_AddEx::makeExpr(res, m1, Mat(), 1, 0, s);
}


void MatOp::matmul(const MatExpr& e1, const MatExpr& e2, MatExpr& res) const
{
    if( this == e2.op )
    {
        double scale = 1;
        int flags = 0;
        Mat m1, m2;

        if( isT(e1) )
        {
            flags = CV_GEMM_A_T;
            scale = e1.alpha;
            m1 = e1.a;
        }
        else if( isScaled(e1) )
        {
            scale = e1.alpha;
            m1 = e1.a;
        }
        else
            e1.op->assign(e1, m1);

        if( isT(e2) )
        {
            flags |= CV_GEMM_B_T;
            scale *= e2.alpha;
            m2 = e2.a;
        }
        else if( isScaled(e2) )
        {
            scale *= e2.alpha;
            m2 = e2.a;
        }
        else
            e2.op->assign(e2, m2);

        MatOp_GEMM::makeExpr(res, flags, m1, m2, scale);
    }
    else
        e2.op->matmul(e1, e2, res);
}

//////////////////////////////////////////////////////////////////////////////////////////////////

MatExpr::MatExpr(const Mat& m) : op(&g_MatOp_Identity), flags(0), a(m), b(Mat()), c(Mat()), alpha(1), beta(0), s(Scalar())
{
}

MatExpr operator + (const Mat& a, const Mat& b)
{
    MatExpr e;
    MatOp_AddEx::makeExpr(e, a, b, 1, 1);
    return e;
}

MatExpr operator + (const Mat& a, const Scalar& s)
{
    MatExpr e;
    MatOp_AddEx::makeExpr(e, a, Mat(), 1, 0, s);
    return e;
}

MatExpr operator + (const Scalar& s, const Mat& a)
{
    MatExpr e;
    MatOp_AddEx::makeExpr(e, a, Mat(), 1, 0, s);
    return e;
}

MatExpr operator + (const MatExpr& e, const Mat& m)
{
    MatExpr en;
    e.op->add(e, MatExpr(m), en);
    return en;
}

MatExpr operator + (const Mat& m, const MatExpr& e)
{
    MatExpr en;
    e.op->add(e, MatExpr(m), en);
    return en;
}

MatExpr operator + (const MatExpr& e, const Scalar& s)
{
    MatExpr en;
    e.op->add(e, s, en);
    return en;
}

MatExpr operator + (const Scalar& s, const MatExpr& e)
{
    MatExpr en;
    e.op->add(e, s, en);
    return en;
}

MatExpr operator + (const MatExpr& e1, const MatExpr& e2)
{
    MatExpr en;
    e1.op->add(e1, e2, en);
    return en;
}

MatExpr operator - (const Mat& a, const Mat& b)
{
    MatExpr e;
    MatOp_AddEx::makeExpr(e, a, b, 1, -1);
    return e;
}

MatExpr operator - (const Mat& a, const Scalar& s)
{
    MatExpr e;
    MatOp_AddEx::makeExpr(e, a, Mat(), 1, 0, -s);
    return e;
}

MatExpr operator - (const Scalar& s, const Mat& a)
{
    MatExpr e;
    MatOp_AddEx::makeExpr(e, a, Mat(), -1, 0, s);
    return e;
}


MatExpr operator - (const MatExpr& e, const Scalar& s)
{
    MatExpr en;
    e.op->add(e, -s, en);
    return en;
}

MatExpr operator * (const Mat& a, const Mat& b)
{
    MatExpr e;
    MatOp_GEMM::makeExpr(e, 0, a, b);
    return e;
}


MatExpr operator * (double s, const Mat& a)
{
    MatExpr e;
    MatOp_AddEx::makeExpr(e, a, Mat(), s, 0);
    return e;
}

MatExpr operator * (const MatExpr& e, const Mat& m)
{
    MatExpr en;
    e.op->matmul(e, MatExpr(m), en);
    return en;
}

MatExpr operator / (const Mat& a, double s)
{
    MatExpr e;
    MatOp_AddEx::makeExpr(e, a, Mat(), 1./s, 0);
    return e;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

void MatOp_Identity::assign(const MatExpr& e, Mat& m, int _type) const
{
    if( _type == -1 || _type == e.a.type() )
        m = e.a;
    else
    {
        CV_Assert( CV_MAT_CN(_type) == e.a.channels() );
        e.a.convertTo(m, _type);
    }
}

inline void MatOp_Identity::makeExpr(MatExpr& res, const Mat& m)
{
    res = MatExpr(&g_MatOp_Identity, 0, m, Mat(), Mat(), 1, 0);
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

void MatOp_AddEx::assign(const MatExpr& e, Mat& m, int _type) const
{
    Mat temp, &dst = _type == -1 || e.a.type() == _type ? m : temp;
    if( e.b.data )
    {
        if( e.s == Scalar() || !e.s.isReal() )
        {
            if( e.alpha == 1 )
            {
                if( e.beta == 1 )
                    cv::add(e.a, e.b, dst);
                else if( e.beta == -1 )
                    cv::subtract(e.a, e.b, dst);
                else
                    cv::scaleAdd(e.b, e.beta, e.a, dst);
            }
            else if( e.beta == 1 )
            {
                if( e.alpha == -1 )
                    cv::subtract(e.b, e.a, dst);
                else
                    cv::scaleAdd(e.a, e.alpha, e.b, dst);
            }
            else
                cv::addWeighted(e.a, e.alpha, e.b, e.beta, 0, dst);

            if( !e.s.isReal() )
                cv::add(dst, e.s, dst);
        }
        else
            cv::addWeighted(e.a, e.alpha, e.b, e.beta, e.s[0], dst);
    }
    else if( e.s.isReal() && (dst.data != m.data || fabs(e.alpha) != 1))
    {
        e.a.convertTo(m, _type, e.alpha, e.s[0]);
        return;
    }
    else if( e.alpha == 1 )
        cv::add(e.a, e.s, dst);
    else if( e.alpha == -1 )
        cv::subtract(e.s, e.a, dst);
    else
    {
        e.a.convertTo(dst, e.a.type(), e.alpha);
        cv::add(dst, e.s, dst);
    }

    if( dst.data != m.data )
        dst.convertTo(m, m.type());
}


inline void MatOp_AddEx::makeExpr(MatExpr& res, const Mat& a, const Mat& b, double alpha, double beta, const Scalar& s)
{
    res = MatExpr(&g_MatOp_AddEx, 0, a, b, Mat(), alpha, beta, s);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void MatOp_T::assign(const MatExpr& e, Mat& m, int _type) const
{
    Mat temp, &dst = _type == -1 || _type == e.a.type() ? m : temp;

    cv::transpose(e.a, dst);

    if( dst.data != m.data || e.alpha != 1 )
        dst.convertTo(m, _type, e.alpha);
}

void MatOp_T::multiply(const MatExpr& e, double s, MatExpr& res) const
{
    res = e;
    res.alpha *= s;
}

void MatOp_T::transpose(const MatExpr& e, MatExpr& res) const
{
    if( e.alpha == 1 )
        MatOp_Identity::makeExpr(res, e.a);
    else
        MatOp_AddEx::makeExpr(res, e.a, Mat(), e.alpha, 0);
}

inline void MatOp_T::makeExpr(MatExpr& res, const Mat& a, double alpha)
{
    res = MatExpr(&g_MatOp_T, 0, a, Mat(), Mat(), alpha, 0);
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

void MatOp_GEMM::assign(const MatExpr& e, Mat& m, int _type) const
{
    Mat temp, &dst = _type == -1 || _type == e.a.type() ? m : temp;

    cv::gemm(e.a, e.b, e.alpha, e.c, e.beta, dst, e.flags);
    if( dst.data != m.data )
        dst.convertTo(m, _type);
}
inline void MatOp_GEMM::makeExpr(MatExpr& res, int flags, const Mat& a, const Mat& b,
                                 double alpha, const Mat& c, double beta)
{
    res = MatExpr(&g_MatOp_GEMM, flags, a, b, c, alpha, beta);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

void MatOp_Invert::assign(const MatExpr& e, Mat& m, int _type) const
{
    Mat temp, &dst = _type == -1 || _type == e.a.type() ? m : temp;

    cv::invert(e.a, dst, e.flags);
    if( dst.data != m.data )
        dst.convertTo(m, _type);
}

void MatOp_Invert::matmul(const MatExpr& e1, const MatExpr& e2, MatExpr& res) const
{
    if( isInv(e1) && isIdentity(e2) )
        MatOp_Solve::makeExpr(res, e1.flags, e1.a, e2.a);
    else if( this == e2.op )
        MatOp::matmul(e1, e2, res);
    else
        e2.op->matmul(e1, e2, res);
}

inline void MatOp_Invert::makeExpr(MatExpr& res, int method, const Mat& m)
{
    res = MatExpr(&g_MatOp_Invert, method, m, Mat(), Mat(), 1, 0);
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

void MatOp_Solve::assign(const MatExpr& e, Mat& m, int _type) const
{
    Mat temp, &dst = _type == -1 || _type == e.a.type() ? m : temp;

    cv::solve(e.a, e.b, dst, e.flags);
    if( dst.data != m.data )
        dst.convertTo(m, _type);
}

inline void MatOp_Solve::makeExpr(MatExpr& res, int method, const Mat& a, const Mat& b)
{
    res = MatExpr(&g_MatOp_Solve, method, a, b, Mat(), 1, 1);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////

void MatOp_Initializer::assign(const MatExpr& e, Mat& m, int _type) const
{
    if( _type == -1 )
        _type = e.a.type();
    m.create(e.a.size(), _type);
    if( e.flags == 'I' )
        setIdentity(m, Scalar(e.alpha));
    else if( e.flags == '0' )
        m = Scalar();
    else if( e.flags == '1' )
        m = Scalar(e.alpha);
    else
        CV_Error(CV_StsError, "Invalid matrix initializer type");
}

inline void MatOp_Initializer::makeExpr(MatExpr& res, int method, Size sz, int type, double alpha)
{
    res = MatExpr(&g_MatOp_Initializer, method, Mat(sz, type, (void*)0), Mat(), Mat(), alpha, 0);
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////

MatExpr Mat::t() const
{
    MatExpr e;
    MatOp_T::makeExpr(e, *this);
    return e;
}

MatExpr Mat::inv(int method) const
{
    MatExpr e;
    MatOp_Invert::makeExpr(e, method, *this);
    return e;
}

MatExpr Mat::zeros(int rows, int cols, int type)
{
    MatExpr e;
    MatOp_Initializer::makeExpr(e, '0', Size(cols, rows), type);
    return e;
}

MatExpr Mat::zeros(Size size, int type)
{
    MatExpr e;
    MatOp_Initializer::makeExpr(e, '0', size, type);
    return e;
}

MatExpr Mat::ones(int rows, int cols, int type)
{
    MatExpr e;
    MatOp_Initializer::makeExpr(e, '1', Size(cols, rows), type);
    return e;
}

MatExpr Mat::ones(Size size, int type)
{
    MatExpr e;
    MatOp_Initializer::makeExpr(e, '1', size, type);
    return e;
}

MatExpr Mat::eye(int rows, int cols, int type)
{
    MatExpr e;
    MatOp_Initializer::makeExpr(e, 'I', Size(cols, rows), type);
    return e;
}

MatExpr Mat::eye(Size size, int type)
{
    MatExpr e;
    MatOp_Initializer::makeExpr(e, 'I', size, type);
    return e;
}

}

/* End of file. */