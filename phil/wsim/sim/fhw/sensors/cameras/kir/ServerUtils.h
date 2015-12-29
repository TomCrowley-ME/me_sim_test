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
#ifndef _SERVER_UTILS_H_
#define _SERVER_UTILS_H_

#include <stdint.h>

inline bool isBigEndian();
template <typename T>
T ntoh(const T net);
template <typename T>
T hton(const T host);
template <typename T>
T swapBytes(const T u);

inline bool isBigEndian() {
	union {
		uint32_t i;
		char c[4];
	} testInt = {0x01020304};

	return testInt.c[0] == 1;
}

template <typename T>
T ntoh(const T net) {
	return isBigEndian() ? net : swapBytes<T>(net);
}

template <typename T>
T hton(const T host) {
	return isBigEndian() ? host : swapBytes<T>(host);
}

template <typename T>
T swapBytes(const T u) {
	union {
		T u;
		char bytes[sizeof(T)];
	} source, dest;

	source.u = u;

	for (size_t i = 0; i < sizeof(T); ++i) {
		dest.bytes[i] = source.bytes[sizeof(T) - i - 1];
	}

	return dest.u;
}

#endif
