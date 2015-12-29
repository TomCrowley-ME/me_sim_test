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

#include <opencv2/core.hpp>
#include <opencv2/core_c.h>
#include <opencv2/internal.hpp>
#include <opencv2/mat.hpp>

#define ICV_FREE_PTR(storage)  \
    ((schar*)(storage)->top + (storage)->block_size - (storage)->free_space)

#define ICV_ALIGNED_SEQ_BLOCK_SIZE  \
    (int)cvAlign(sizeof(CvSeqBlock), CV_STRUCT_ALIGN)

CV_INLINE int
cvAlignLeft( int size, int align )
{
    return size & -align;
}

#define CV_GET_LAST_ELEM( seq, block ) \
    ((block)->data + ((block)->count - 1)*((seq)->elem_size))

#define CV_SWAP_ELEMS(a,b,elem_size)  \
{                                     \
    int k;                            \
    for( k = 0; k < elem_size; k++ )  \
    {                                 \
        char t0 = (a)[k];             \
        char t1 = (b)[k];             \
        (a)[k] = t1;                  \
        (b)[k] = t0;                  \
    }                                 \
}

#define ICV_SHIFT_TAB_MAX 32
static const schar icvPower2ShiftTab[] =
{
    0, 1, -1, 2, -1, -1, -1, 3, -1, -1, -1, -1, -1, -1, -1, 4,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 5
};

/****************************************************************************************\
*            Functions for manipulating memory storage - list of memory blocks           *
\****************************************************************************************/

/* Initialize allocated storage: */
static void
icvInitMemStorage( CvMemStorage* storage, int block_size )
{
    if( !storage )
        CV_Error( CV_StsNullPtr, "" );

    if( block_size <= 0 )
        block_size = CV_STORAGE_BLOCK_SIZE;

    block_size = cvAlign( block_size, CV_STRUCT_ALIGN );
    assert( sizeof(CvMemBlock) % CV_STRUCT_ALIGN == 0 );

    memset( storage, 0, sizeof( *storage ));
    storage->signature = CV_STORAGE_MAGIC_VAL;
    storage->block_size = block_size;
}


/* Create root memory storage: */
CV_IMPL CvMemStorage*
cvCreateMemStorage( int block_size )
{
    CvMemStorage* storage = (CvMemStorage *)cvAlloc( sizeof( CvMemStorage ));
    icvInitMemStorage( storage, block_size );
    return storage;
}


/* Create child memory storage: */
CV_IMPL CvMemStorage *
cvCreateChildMemStorage( CvMemStorage * parent )
{
    if( !parent )
        CV_Error( CV_StsNullPtr, "" );

    CvMemStorage* storage = cvCreateMemStorage(parent->block_size);
    storage->parent = parent;

    return storage;
}


/* Release all blocks of the storage (or return them to parent, if any): */
static void
icvDestroyMemStorage( CvMemStorage* storage )
{
    int k = 0;

    CvMemBlock *block;
    CvMemBlock *dst_top = 0;

    if( !storage )
        CV_Error( CV_StsNullPtr, "" );

    if( storage->parent )
        dst_top = storage->parent->top;

    for( block = storage->bottom; block != 0; k++ )
    {
        CvMemBlock *temp = block;

        block = block->next;
        if( storage->parent )
        {
            if( dst_top )
            {
                temp->prev = dst_top;
                temp->next = dst_top->next;
                if( temp->next )
                    temp->next->prev = temp;
                dst_top = dst_top->next = temp;
            }
            else
            {
                dst_top = storage->parent->bottom = storage->parent->top = temp;
                temp->prev = temp->next = 0;
                storage->free_space = storage->block_size - sizeof( *temp );
            }
        }
        else
        {
            cvFree( &temp );
        }
    }

    storage->top = storage->bottom = 0;
    storage->free_space = 0;
}


/* Release memory storage: */
CV_IMPL void
cvReleaseMemStorage( CvMemStorage** storage )
{
    if( !storage )
        CV_Error( CV_StsNullPtr, "" );

    CvMemStorage* st = *storage;
    *storage = 0;
    if( st )
    {
        icvDestroyMemStorage( st );
        cvFree( &st );
    }
}


/* Clears memory storage (return blocks to the parent, if any): */
CV_IMPL void
cvClearMemStorage( CvMemStorage * storage )
{
    if( !storage )
        CV_Error( CV_StsNullPtr, "" );

    if( storage->parent )
        icvDestroyMemStorage( storage );
    else
    {
        storage->top = storage->bottom;
        storage->free_space = storage->bottom ? storage->block_size - sizeof(CvMemBlock) : 0;
    }
}


// Sort the sequence using user-specified comparison function.
// The semantics is similar to qsort() function.
// The code is based on BSD system qsort():
//    * Copyright (c) 1992, 1993
//    *  The Regents of the University of California.  All rights reserved.
//    *
//    * Redistribution and use in source and binary forms, with or without
//    * modification, are permitted provided that the following conditions
//    * are met:
//    * 1. Redistributions of source code must retain the above copyright
//    *    notice, this list of conditions and the following disclaimer.
//    * 2. Redistributions in binary form must reproduce the above copyright
//    *    notice, this list of conditions and the following disclaimer in the
//    *    documentation and/or other materials provided with the distribution.
//    * 3. All advertising materials mentioning features or use of this software
//    *    must display the following acknowledgement:
//    *  This product includes software developed by the University of
//    *  California, Berkeley and its contributors.
//    * 4. Neither the name of the University nor the names of its contributors
//    *    may be used to endorse or promote products derived from this software
//    *    without specific prior written permission.
//    *
//    * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
//    * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//    * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//    * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
//    * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//    * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
//    * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
//    * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
//    * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
//    * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
//    * SUCH DAMAGE.

typedef struct CvSeqReaderPos
{
    CvSeqBlock* block;
    schar* ptr;
    schar* block_min;
    schar* block_max;
}
CvSeqReaderPos;

#define CV_SAVE_READER_POS( reader, pos )   \
{                                           \
    (pos).block = (reader).block;           \
    (pos).ptr = (reader).ptr;               \
    (pos).block_min = (reader).block_min;   \
    (pos).block_max = (reader).block_max;   \
}

#define CV_RESTORE_READER_POS( reader, pos )\
{                                           \
    (reader).block = (pos).block;           \
    (reader).ptr = (pos).ptr;               \
    (reader).block_min = (pos).block_min;   \
    (reader).block_max = (pos).block_max;   \
}


typedef struct CvPTreeNode
{
    struct CvPTreeNode* parent;
    schar* element;
    int rank;
}
CvPTreeNode;

/* End of file. */
