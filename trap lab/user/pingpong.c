#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
    if (argc > 1) {
        fprintf(2, "Usage: pingpong\n");
        exit(0);
    }


    int p[2];

    pipe(p);

    char buf[2];
    buf[0] = ' ';
    buf[1] = '\0';

    write(p[1], buf, 1);

    if (fork() == 0) {

        read(p[0], buf, 1);

        fprintf(1, "%d: received ping\n", getpid());

        write(p[1], buf, 1);

        close(p[0]);
        close(p[1]);

        exit(0);
    }

    wait(0);

    read(p[0], buf, 1);

    fprintf(1, "%d: received pong\n", getpid());

    close(p[0]);
    close(p[1]);

    exit(0);
}