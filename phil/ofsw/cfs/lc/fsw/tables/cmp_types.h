/**************************************************************************
* Copyright 2010 - 2015 Moon Express, Inc.
* All Rights Reserved.
*
* PROPRIETARY DATA NOTICE:
* The data herein include Proprietary Data and are restricted under the
* Data Rights provisions of Lunar CATALYST Space Act Agreement
* No. SAAM ID# 18251 and Reimbursable Space Act Agreement No.SAA2-402930.
* All information contained herein is and remains proprietary to and the
* property of Moon Express, Inc. Dissemination of this information or
* reproduction of this material is strictly forbidden unless prior
* written permission is obtained from Moon Express, Inc.
**************************************************************************/
/*
 * cmp_types.h
 *
 *  Created on: May 9, 2014
 *      Author: tklaus
 */

#ifndef CMP_TYPES_H_
#define CMP_TYPES_H_

/* mode */

#define MODE__STARTUP      1
#define MODE__SAFE         2
#define MODE__POINTING     3
#define MODE__DELTAV       4
#define MODE__DEORBIT      5
#define MODE__BRAKING      6
#define MODE__LANDING      7
#define MODE__SURFACE      8
#define MODE__SAFESURFACE  9

/* submode */

#define SUBMODE__NONE              1
#define SUBMODE__ACTIVE            2
#define SUBMODE__COAST             3
#define SUBMODE__LANDING_HOLD      4
#define SUBMODE__LANDING_TARGETING 5
#define SUBMODE__LANDING_TERMINAL  6

#define REFERENCE_FRAME__INERTIAL     1
#define REFERENCE_FRAME__TOPOCENTRIC  2

#endif /* CMP_TYPES_H_ */
