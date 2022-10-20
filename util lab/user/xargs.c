#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/param.h"

int argptr;
char *args[MAXARG];
char buf[512 * MAXARG];

void getargs() {
    char *p = buf;
    char ch;
    int count = 0;

    while (p && read(0, &ch, 1)) {
        if (ch == '\n') {
            count++;
            *p++ = '\0';
        } else {
            *p++ = ch;
        }
    }

    *p = '\0';

    if (read(0, &ch, 1)) {
        fprintf(2, "xargs: args too long\n");
        exit(1);
    }

    if (count > MAXARG) {
        fprintf(2, "xargs: args too long\n");
        exit(1);
    }

    p = buf;
    
    while (count--) {
        args[argptr++] = p;
        p += strlen(p);
        p++;
    }
}

int main(int argc, char *argv[]) {

    for (int i = 1; i < argc; ++i) {
        args[argptr++] = argv[i];
    }

    getargs();

    if (fork() == 0) {
        if (exec(argv[1], args) < 0) {
            fprintf(2, "xargs: exec %s fail\n", argv[1]);
            exit(1);
        }
    }

    wait(0);

    exit(0);
}