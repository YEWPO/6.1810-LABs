#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int p[2];
int count = 0;
int num = 35;

void forkPrime() {
    count++;

    if (count > num) {
        close(p[0]);
        close(1);
        exit(0);
    }


    int fd0 = p[0];

    pipe(p);

    if (fork() == 0) {
        close(fd0);
        close(p[1]);
        
        forkPrime();
    }

    close(p[0]);

    int prime = 0;
    int value = 0;

    while (read(fd0, &value, 4)) {
        if (!prime) {
            prime = value;
            fprintf(1, "prime %d\n", prime);
        }

        if (value % prime != 0) {
            write(p[1], &value, 4);
        }
    }

    close(fd0);
    close(p[1]);
    close(1);

    wait(0);

    exit(0);
}

int main(int argc, char *argv[]) {
    close(0);
    close(2);

    pipe(p);

    if (fork() == 0) {
        close(p[1]);
        forkPrime();
    }

    close(p[0]);

    for (int i = 2; i <= num; ++i) {
        write(p[1], &i, 4);
    }

    close(p[1]);
    close(1);

    wait(0);

    exit(0);
}