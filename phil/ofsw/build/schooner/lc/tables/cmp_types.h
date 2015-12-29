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
