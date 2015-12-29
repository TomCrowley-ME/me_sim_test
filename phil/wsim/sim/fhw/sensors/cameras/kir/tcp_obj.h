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
#ifndef _TCP_OBJ_H_
#define _TCP_OBJ_H_

#ifdef _WIN32
#include <winsock2.h>
#include <io.h>
#include <ws2tcpip.h>
#pragma comment(lib, "Ws2_32.lib")
#else
#include <unistd.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <netdb.h>
#endif
#include <stdio.h>
#include <cstring>
#include <iostream>
#include <vector>

#define BUFFER_SIZE 1166400

/**
 * @brief The tcp_obj that acts as a client to an image generation server.
 * Object called by an sfunction to request an image and receive one.
 */
class tcp_obj {
public:
	/**
	  * @brief Constructor
	  * ip address is stored as a int array. For example, given address 1.2.3.4:
	  * ip[0] = 1;
	  * ip[1] = 2;
	  * ip[2] = 3;
      * ip[3] = 4;
	  */
	tcp_obj(int ip[4], int port);
	~tcp_obj();

	int requestImage(const double pos[3],
                     const double orientation[4],
                     double size[2],
                     double intrinsics[2],
                     int altitude,
                     const double childPos[3],
                     const double childOrientation[4]);
    int recvData(double &outAltitude, std::vector<unsigned char> &image);

//private:
	int connectToServer();
	void closeSocket();

    #if _WIN32
    SOCKET sockfd;
    #else
	int sockfd;
    #endif

	addrinfo hints;
	addrinfo *result, *rp;
    sockaddr_in serveraddr;

	char recvBuffer[BUFFER_SIZE];
    char sendBuffer[BUFFER_SIZE];

    char *recvBufferPtr;
    char *sendBufferPtr;

    int recvBufferLen;
    int sendBufferLen;

    int width;
    int height;
    int _altitude;

	std::string _ip;
	std::string _port;
};

#endif
