// wheatfox epoll test 2025.2.2
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <sys/epoll.h>

#define BUF_SIZE 1024

FILE* file;

void handler(int fd, int epoll_type, void *param) {
    if (epoll_type & EPOLLIN) {
        printf("EPOLLIN detected on fd %d\n", fd);        
        char buf[BUF_SIZE];
        ssize_t bytes = read(fd, buf, sizeof(buf) - 1);
        if (bytes > 0) {
            buf[bytes] = 0;
        } else if (bytes == 0) {
            printf("EOF detected, closing fd %d\n", fd);            
            close(fd);
        } else {
            perror("read");            
        }
        printf("Read %ld bytes from fd %d: %s\n", bytes, fd, buf);        
    }
    if (epoll_type & EPOLLHUP) {
        printf("EPOLLHUP detected on fd %d\n", fd);        
        close(fd);
    }
    if (epoll_type & EPOLLERR) {
        printf("EPOLLERR detected on fd %d\n", fd);        
        close(fd);
    }
}

void epoll_loop(int epoll_fd) {
    struct epoll_event events[10];
    while (1) {
        int n = epoll_wait(epoll_fd, events, 10, -1);
        if (n == -1) {
            perror("epoll_wait");            
            exit(EXIT_FAILURE);
        }
        for (int i = 0; i < n; i++) {
            handler(events[i].data.fd, events[i].events, NULL);
        }
    }
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s /dev/pts/X\n", argv[0]);
        return EXIT_FAILURE;
    }
    const char *pts_dev = argv[1];
    printf("Listening on pts device number %s\n", pts_dev);    
    int pts_fd = open(pts_dev, O_RDONLY | O_NONBLOCK);
    if (pts_fd == -1) {
        perror("open pts");               
        return EXIT_FAILURE;
    }
    int epoll_fd = epoll_create1(0);
    if (epoll_fd == -1) {
        perror("epoll_create1");
        close(pts_fd);               
        return EXIT_FAILURE;
    }
    struct epoll_event e;
    e.events = EPOLLIN | EPOLLHUP | EPOLLERR;
    e.data.fd = pts_fd;

    if (epoll_ctl(epoll_fd, EPOLL_CTL_ADD, pts_fd, &e) == -1) {
        perror("epoll_ctl");               
        close(pts_fd);
        close(epoll_fd);
        return EXIT_FAILURE;
    }
    printf("Waiting for input...\n");    
    epoll_loop(epoll_fd);

    close(pts_fd);
    close(epoll_fd);      
    return EXIT_SUCCESS;
}

// loongarch64-unknown-linux-gnu-gcc epoll.c -o epoll -static