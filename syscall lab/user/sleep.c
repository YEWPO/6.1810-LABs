#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
    if (argc < 2 || argc > 2) {
        fprintf(2, "Usage: sleep time\n");
        exit(1);
    }

    for (int i = 0; i < strlen(argv[1]); ++i) {
        if (argv[1][i] < '0' || argv[1][i] > '9') {
            fprintf(2, "Usage: sleep time\n");
            exit(1);
        }
    }

    sleep(atoi(argv[1]));

    exit(0);
}