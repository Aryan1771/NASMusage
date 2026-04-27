#define WIN32_LEAN_AND_MEAN

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <winsock2.h>
#include <ws2tcpip.h>

#include "../include/net_asm.h"

#define DEFAULT_HOST "example.com"
#define DEFAULT_PORT "80"
#define RECV_BUFFER_SIZE 4096

static void print_usage(const char *program_name) {
    printf("Usage: %s [host] [port] [path]\n", program_name);
    printf("Example: %s example.com 80 /\n", program_name);
}

static int connect_tcp(const char *host, const char *port, SOCKET *out_socket) {
    struct addrinfo hints;
    struct addrinfo *results = NULL;
    struct addrinfo *current = NULL;
    SOCKET sock = INVALID_SOCKET;
    int status;

    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_protocol = IPPROTO_TCP;

    status = getaddrinfo(host, port, &hints, &results);
    if (status != 0) {
        fprintf(stderr, "getaddrinfo failed: %d\n", status);
        return 1;
    }

    for (current = results; current != NULL; current = current->ai_next) {
        sock = socket(current->ai_family, current->ai_socktype, current->ai_protocol);
        if (sock == INVALID_SOCKET) {
            continue;
        }

        if (connect(sock, current->ai_addr, (int)current->ai_addrlen) == 0) {
            *out_socket = sock;
            freeaddrinfo(results);
            return 0;
        }

        closesocket(sock);
        sock = INVALID_SOCKET;
    }

    freeaddrinfo(results);
    fprintf(stderr, "Could not connect to %s:%s\n", host, port);
    return 1;
}

static int send_http_head(SOCKET sock, const char *host, const char *path) {
    char request[1024];
    int request_length;
    int sent;

    request_length = snprintf(
        request,
        sizeof(request),
        "HEAD %s HTTP/1.1\r\n"
        "Host: %s\r\n"
        "User-Agent: NASMusage-tcp-probe/1.0\r\n"
        "Connection: close\r\n"
        "\r\n",
        path,
        host
    );

    if (request_length < 0 || request_length >= (int)sizeof(request)) {
        fprintf(stderr, "Request is too large.\n");
        return 1;
    }

    sent = send(sock, request, request_length, 0);
    if (sent == SOCKET_ERROR) {
        fprintf(stderr, "send failed: %d\n", WSAGetLastError());
        return 1;
    }

    return 0;
}

static int receive_response(SOCKET sock, char *buffer, size_t buffer_size, int *out_length) {
    int received;

    received = recv(sock, buffer, (int)buffer_size - 1, 0);
    if (received == SOCKET_ERROR) {
        fprintf(stderr, "recv failed: %d\n", WSAGetLastError());
        return 1;
    }

    buffer[received] = '\0';
    *out_length = received;
    return 0;
}

int main(int argc, char **argv) {
    const char *host = DEFAULT_HOST;
    const char *port = DEFAULT_PORT;
    const char *path = "/";
    WSADATA wsa_data;
    SOCKET sock = INVALID_SOCKET;
    char response[RECV_BUFFER_SIZE];
    int response_length = 0;
    uint32_t checksum;
    size_t newline_count;
    int exit_code = 1;

    if (argc > 4) {
        print_usage(argv[0]);
        return 1;
    }

    if (argc >= 2) {
        host = argv[1];
    }
    if (argc >= 3) {
        port = argv[2];
    }
    if (argc >= 4) {
        path = argv[3];
    }

    if (WSAStartup(MAKEWORD(2, 2), &wsa_data) != 0) {
        fprintf(stderr, "WSAStartup failed.\n");
        return 1;
    }

    printf("Connecting to %s:%s...\n", host, port);

    if (connect_tcp(host, port, &sock) != 0) {
        goto cleanup;
    }

    if (send_http_head(sock, host, path) != 0) {
        goto cleanup;
    }

    if (receive_response(sock, response, sizeof(response), &response_length) != 0) {
        goto cleanup;
    }

    checksum = asm_checksum32((const uint8_t *)response, (size_t)response_length);
    newline_count = asm_count_byte((const uint8_t *)response, (size_t)response_length, '\n');
    asm_uppercase_ascii(response, (size_t)response_length);

    printf("\nReceived %d bytes\n", response_length);
    printf("Assembly checksum32: 0x%08X\n", checksum);
    printf("Assembly newline count: %zu\n\n", newline_count);
    printf("Uppercased response preview:\n");
    printf("----------------------------------------\n");
    printf("%.*s\n", response_length, response);
    printf("----------------------------------------\n");

    exit_code = 0;

cleanup:
    if (sock != INVALID_SOCKET) {
        closesocket(sock);
    }
    WSACleanup();
    return exit_code;
}
