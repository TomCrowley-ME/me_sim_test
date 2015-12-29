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
#include <opencv2/operations.hpp>

namespace cv
{

using std::pair;

template<typename _KeyTp, typename _ValueTp> struct sorted_vector
{
    sorted_vector() {}
    void clear() { vec.clear(); }
    size_t size() const { return vec.size(); }
    _ValueTp& operator [](size_t idx) { return vec[idx]; }
    const _ValueTp& operator [](size_t idx) const { return vec[idx]; }

    void add(const _KeyTp& k, const _ValueTp& val)
    {
        pair<_KeyTp, _ValueTp> p(k, val);
        vec.push_back(p);
        size_t i = vec.size()-1;
        for( ; i > 0 && vec[i].first < vec[i-1].first; i-- )
            std::swap(vec[i-1], vec[i]);
        CV_Assert( i == 0 || vec[i].first != vec[i-1].first );
    }

    bool find(const _KeyTp& key, _ValueTp& value) const
    {
        size_t a = 0, b = vec.size();
        while( b > a )
        {
            size_t c = (a + b)/2;
            if( vec[c].first < key )
                a = c+1;
            else
                b = c;
        }

        if( a < vec.size() && vec[a].first == key )
        {
            value = vec[a].second;
            return true;
        }
        return false;
    }

    void get_keys(vector<_KeyTp>& keys) const
    {
        size_t i = 0, n = vec.size();
        keys.resize(n);

        for( i = 0; i < n; i++ )
            keys[i] = vec[i].first;
    }

    vector<pair<_KeyTp, _ValueTp> > vec;
};


template<typename _ValueTp> inline const _ValueTp* findstr(const sorted_vector<string, _ValueTp>& vec,
                                                           const char* key)
{
    if( !key )
        return 0;

    size_t a = 0, b = vec.vec.size();
    while( b > a )
    {
        size_t c = (a + b)/2;
        if( strcmp(vec.vec[c].first.c_str(), key) < 0 )
            a = c+1;
        else
            b = c;
    }

    if( ( a < vec.vec.size() ) && ( strcmp(vec.vec[a].first.c_str(), key) == 0 ))
        return &vec.vec[a].second;
    return 0;
}


Param::Param()
{
    type = 0;
    offset = 0;
    readonly = false;
    getter = 0;
    setter = 0;
}


Param::Param(int _type, bool _readonly, int _offset,
             Algorithm::Getter _getter, Algorithm::Setter _setter,
             const string& _help)
{
    type = _type;
    readonly = _readonly;
    offset = _offset;
    getter = _getter;
    setter = _setter;
    help = _help;
}


struct CV_EXPORTS AlgorithmInfoData
{
    sorted_vector<string, Param> params;
    string _name;
};


static sorted_vector<string, Algorithm::Constructor>& alglist()
{
    static sorted_vector<string, Algorithm::Constructor> alglist_var;
    return alglist_var;
}

void Algorithm::getList(vector<string>& algorithms)
{
    alglist().get_keys(algorithms);
}

Ptr<Algorithm> Algorithm::_create(const string& name)
{
    Algorithm::Constructor c = 0;
    if( !alglist().find(name, c) )
        return Ptr<Algorithm>();
    return c();
}

Algorithm::Algorithm()
{
}

Algorithm::~Algorithm()
{
}

void Algorithm::set(const char* parameter, double value)
{
#if 0
    info()->set(this, parameter, ParamType<double>::type, &value);
#else
    CV_Assert(0);
#endif
}

void Algorithm::set(const char* parameter, bool value)
{
#if 0
    info()->set(this, parameter, ParamType<bool>::type, &value);
#else
    CV_Assert(0);
#endif
}

union GetSetParam
{
    int (Algorithm::*get_int)() const;
    bool (Algorithm::*get_bool)() const;
    double (Algorithm::*get_double)() const;
    string (Algorithm::*get_string)() const;
    Mat (Algorithm::*get_mat)() const;
    vector<Mat> (Algorithm::*get_mat_vector)() const;
    Ptr<Algorithm> (Algorithm::*get_algo)() const;

    void (Algorithm::*set_int)(int);
    void (Algorithm::*set_bool)(bool);
    void (Algorithm::*set_double)(double);
    void (Algorithm::*set_string)(const string&);
    void (Algorithm::*set_mat)(const Mat&);
    void (Algorithm::*set_mat_vector)(const vector<Mat>&);
    void (Algorithm::*set_algo)(const Ptr<Algorithm>&);
};

static string getNameOfType(int argType);

static string getNameOfType(int argType)
{
    switch(argType)
    {
        case Param::INT: return "integer";
        case Param::SHORT: return "short";
        case Param::BOOLEAN: return "boolean";
        case Param::REAL: return "double";
        case Param::STRING: return "string";
        case Param::MAT: return "cv::Mat";
        case Param::MAT_VECTOR: return "std::vector<cv::Mat>";
        case Param::ALGORITHM: return "algorithm";
        default: CV_Error(CV_StsBadArg, "Wrong argument type");
    }
    return "";
}
static string getErrorMessageForWrongArgumentInSetter(string algoName, string paramName, int paramType, int argType);
static string getErrorMessageForWrongArgumentInSetter(string algoName, string paramName, int paramType, int argType)
{
    string message = string("Argument error: the setter")
        + " method was called for the parameter '" + paramName + "' of the algorithm '" + algoName
        +"', the parameter has " + getNameOfType(paramType) + " type, ";

    if (paramType == Param::INT || paramType == Param::BOOLEAN || paramType == Param::REAL)
    {
        message += "so it should be set by integer, boolean, or double value, ";
    }
    else if (paramType == Param::SHORT)
    {
        message += "so it should be set by integer value, ";
    }
    message += "but the setter was called with " + getNameOfType(argType) + " value";

    return message;
}

static string getErrorMessageForWrongArgumentInGetter(string algoName, string paramName, int paramType, int argType);
static string getErrorMessageForWrongArgumentInGetter(string algoName, string paramName, int paramType, int argType)
{
    string message = string("Argument error: the getter")
        + " method was called for the parameter '" + paramName + "' of the algorithm '" + algoName
        +"', the parameter has " + getNameOfType(paramType) + " type, ";

    if (paramType == Param::BOOLEAN)
    {
        message += "so it should be get as integer, boolean, or double value, ";
    }
    else if (paramType == Param::INT)
    {
        message += "so it should be get as integer or double value, ";
    }
    else if (paramType == Param::SHORT)
    {
        message += "so it should be get as integer value, ";
    }
    message += "but the getter was called to get a " + getNameOfType(argType) + " value";

    return message;
}

}

/* End of file. */
