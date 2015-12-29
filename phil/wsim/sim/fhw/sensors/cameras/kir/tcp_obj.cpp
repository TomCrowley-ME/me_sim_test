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
#include "tcp_obj.h"
#include "ServerUtils.h"
#include <sstream>
#include <errno.h>
#include <fstream>
#include <cmath>

using namespace std;

tcp_obj::tcp_obj(int ip[4], int port) :
    rp(NULL),
    recvBufferLen(0),
    sendBufferLen(0)
{
    memset(&hints, 0, sizeof(addrinfo));
    hints.ai_family =       AF_UNSPEC;
    hints.ai_socktype =     SOCK_STREAM;
    hints.ai_flags =        AI_PASSIVE;
    hints.ai_protocol =     0;
    hints.ai_addrlen =      0;
    hints.ai_canonname =    NULL;
    hints.ai_addr =         NULL;
    hints.ai_next =         NULL;

    std::stringstream ss_ip, ss_port;
    ss_ip << ip[0] << "." << ip[1] << "." << ip[2] << "." << ip[3];
    ss_port << port;

    _ip = ss_ip.str();
    _port = ss_port.str();

    //connectToServer();
}

tcp_obj::~tcp_obj() {
    #ifdef _WIN32
    closesocket(sockfd);
    WSACleanup();
    #else
    close(sockfd);
    #endif
}

int tcp_obj::requestImage(const double pos[3],
                          const double orientation[4],
                          double size[2],
                          double intrinsics[2],
                          int altitude,
                          const double childPos[3],
                          const double childOrientation[4])
{
    cout << "\nImage request at (" <<
            pos[0] << "," << pos[1] << "," << pos[2] << ") : <" <<
            orientation[0] << "," << orientation[1] << "," << orientation[2] << "," << orientation[3] << ">" <<
            " (" << childPos[0] << "," << childPos[1] << "," << childPos[2] << ") : <" <<
            childOrientation[0] << "," << childOrientation[1] << "," << childOrientation[2] << "," << childOrientation[3] << ">" <<
            " of size " << size[0] << "x" << size[1] << endl;

    if (connectToServer())
    {
        return 1;
    }

    width = (int) size[0];
    height = (int) size[1];
    _altitude = altitude;

    double fov = atan2((height / 2) * intrinsics[1], intrinsics[0]);

    socklen_t sin_size = sizeof(serveraddr);
    memset(&serveraddr, 0, sizeof(serveraddr));

    sendBufferPtr = sendBuffer;
    sendBufferLen = 0;
    double      doubleBuffer;
    int32_t     intBuffer;

    for (int i = 0; i < 2; ++i) {
        intBuffer = hton<int32_t>((int32_t) size[i]);
        memmove(sendBufferPtr, &intBuffer, sizeof(int32_t));
        sendBufferPtr += sizeof(int32_t);
        sendBufferLen += sizeof(int32_t);
    }

    intBuffer = hton<int32_t>((int32_t) altitude);
    memmove(sendBufferPtr, &intBuffer, sizeof(int32_t));
    sendBufferPtr += sizeof(int32_t);
    sendBufferLen += sizeof(int32_t);

    doubleBuffer = hton<double>(fov);
    memmove(sendBufferPtr, &doubleBuffer, sizeof(double));
    sendBufferPtr += sizeof(double);
    sendBufferLen += sizeof(double);

    for (int i = 0; i < 3; ++i) {
        doubleBuffer = hton<double>(pos[i]);
        memmove(sendBufferPtr, &doubleBuffer, sizeof(double));
        sendBufferPtr += sizeof(double);
        sendBufferLen += sizeof(double);
    }
    for (int i = 0; i < 4; ++i) {
        doubleBuffer = hton<double>(orientation[i]);
        memmove(sendBufferPtr, &doubleBuffer, sizeof(double));
        sendBufferPtr += sizeof(double);
        sendBufferLen += sizeof(double);
    }

    for (int i = 0; i < 3; ++i) {
        doubleBuffer = hton<double>(childPos[i]);
        memmove(sendBufferPtr, &doubleBuffer, sizeof(double));
        sendBufferPtr += sizeof(double);
        sendBufferLen += sizeof(double);
    }
    for (int i = 0; i < 4; ++i) {
        doubleBuffer = hton<double>(childOrientation[i]);
        memmove(sendBufferPtr, &doubleBuffer, sizeof(double));
        sendBufferPtr += sizeof(double);
        sendBufferLen += sizeof(double);
    }

    int bytes_sent = send(sockfd, sendBuffer, sendBufferLen, 0);

    return 0;
}

int tcp_obj::recvData(double &outAltitude, vector<unsigned char> &image) {
    image.clear();

    int expected = (_altitude) ? sizeof(double) : width * height + sizeof(double);
    int totalExpected = expected;
    int bytesReceived = 0;
    int n = 0;
    int timeoutCounter = 0;

    cout << "Expecting " << ((_altitude) ? "only altitude" : "altitude and image") << endl;
    cout << "Expecting " << expected << " bytes" << endl;

    while (bytesReceived < totalExpected) {
        #if _WIN32
        n = recv(sockfd, recvBuffer+bytesReceived, expected, 0);
        #else
        n = recv(sockfd, recvBuffer+bytesReceived, expected, MSG_WAITALL);
        #endif
        if (n == -1) {
            #if _WIN32
            cout << "recv failed " << WSAGetLastError() << endl;
            #else
            perror("n==-1");
            cout << "recv failed" << endl;
            #endif
            closeSocket();
            return -1;
        } else if (n == 0) {
            perror("n==0");
            cout << "No data received." << endl;
            closeSocket();
            return -1;
        }
        bytesReceived += n;
        expected -= n;
    }

    cout << "Success: " << bytesReceived << "bytes received" << endl;

    closeSocket();

    char *ptr = recvBuffer;
    memmove(&outAltitude, ptr, sizeof(double));
    outAltitude = ntoh<double>(outAltitude);
    ptr += sizeof(double);

    if (_altitude)
    {
        return bytesReceived;
    }

    for (int i = 0; i < width * height; ++i) {
        image.push_back( *ptr);
        ptr++;
    }

    // Generate image
#define SAVE_IMAGE
#ifdef SAVE_IMAGE
    fstream fs;
    fs.open("kir.pgm", fstream::out);
    fs << "P5" << endl;
    fs << width << " " << height << endl;
    fs << 255 << endl;
    fs.write(recvBuffer + sizeof(double), width * height);
    fs.close();
#endif

    return bytesReceived;
}

int tcp_obj::connectToServer() {
    int err;
    #ifdef _WIN32
    sockfd = INVALID_SOCKET;

    WSADATA wsaData;
    err = WSAStartup(MAKEWORD(2,2), &wsaData);
    if (err != NO_ERROR)
    {
        printf("WSAStartup failed: %d.\n", err);
        return 1;
    }
    #endif

    cout << "Attempting connection at " << _ip << " on port " << _port << endl;

    err = getaddrinfo(_ip.c_str(), _port.c_str(), &hints, &result);

    if (err < 0) {
        cout << "Getaddrinfo failed.\n";
        perror("Getaddrinfo");
    }

    rp = NULL;

    for (rp = result; rp != NULL; rp = rp->ai_next) {
#ifdef _WIN32
        sockfd = socket(rp->ai_family, rp->ai_socktype, rp->ai_protocol);
        if (sockfd == INVALID_SOCKET)
        {
            cout << "Error at socket(): " << WSAGetLastError() << endl;
            continue;
        }
#else
        if ((sockfd = (int) socket(rp->ai_family, rp->ai_socktype, rp->ai_protocol)) == -1) {
            cout << "Socket creation failed.\n";
            perror("Socket creation failed");
            continue;
        }
#endif

        if (connect(sockfd, rp->ai_addr, (int) rp->ai_addrlen)) {
#ifdef _WIN32
            cout << "Socket connection failed. " << WSAGetLastError() << endl;
#else
            cout << "Socket connection failed.\n";
#endif
            closeSocket();
            continue;
        }
 #ifdef _WIN32
        char optval = 1;
        if (setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &optval, sizeof(optval))) {
            cout << "setsockopt failed. " << WSAGetLastError() << endl;
            closeSocket();
            continue;
        }
 #else
        int optval = 1;
        if (setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &optval, (socklen_t) sizeof(optval))) {
            cout << "setsockopt failed.\n";
            closeSocket();
            continue;
        }
 #endif

        break;
    }

    freeaddrinfo(result);

    return 0;
}

void tcp_obj::closeSocket() {
#ifdef _WIN32
    char* buf = new char[10];
    int err = recv(sockfd, buf, 10, MSG_PEEK);
    if (err >= 0)       // Bytes received. Must be removed.
    {
        err = shutdown(sockfd, SD_BOTH);
        if (err)
        {
            cout << "Shutdown failed. " << WSAGetLastError() << endl;
            WSACleanup();
        }
        closesocket(sockfd);
    }
#else
    if (close(sockfd))
    {
        cerr << "Close failed." << endl;
        perror("Close failed");
    }
#endif
}
