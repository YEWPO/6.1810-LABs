#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"

char *fmtname(char *path) {
    static char buf[DIRSIZ + 1];
    char *p;

    for (p = path + strlen(path); p >= path && *p != '/'; p--);
    p++;

    if (strlen(p) >= DIRSIZ) {
        return p;
    }

    memmove(buf, p, strlen(p));
    memset(buf + strlen(p), 0, DIRSIZ - strlen(p));

    return buf;
}

void search(char *path, const char *file) {

    if (strcmp(fmtname(path), "..") == 0) {
        return;
    }

    char buf[512], *p;
    int fd;
    struct dirent de;
    struct stat st;

    if ((fd  = open(path, 0)) < 0) {
        fprintf(2, "find: cannot open %s\n", path);
        exit(1);
    }

    if (fstat(fd, &st) < 0) {
        fprintf(2, "find: cannot stat %s\n", path);
        close(fd);
        exit(1);
    }

    switch (st.type) {
        case T_FILE:
            if (strcmp(file, fmtname(path)) == 0) {
                fprintf(1, "%s\n", path);
            }
            break;
        case T_DEVICE:
            if (strcmp(file, fmtname(path)) == 0) {
                fprintf(1, "%s\n", path);
            }
            break;
        case T_DIR:
            if (strlen(path) + 1 + DIRSIZ + 1 > sizeof(buf)) {
                fprintf(2, "find: path too long\n");
                close(fd);
                exit(1);
            }

            strcpy(buf, path);

            p = buf + strlen(buf);

            *p++ = '/';

            while (read(fd, &de, sizeof(de)) == sizeof(de)) {
                if (de.inum == 0) {
                    continue;
                }

                memmove(p, de.name, DIRSIZ);
                p[DIRSIZ] = 0;

                struct stat prest;

                if (stat(buf, &prest) < 0) {
                    fprintf(2, "find: cannot stat %s\n", p);
                    continue;
                }

                if (st.ino == prest.ino) {
                    continue;
                }

                search(buf, file);
            }

            break;
        default:
            break;
    }

    close(fd);
}

int main(int argc, char *argv[]) {

    if (argc < 2 || argc > 3) {
        fprintf(2, "Usage: find <filename>\n");
        exit(1);
    }

    search(argv[1], argv[2]);

    exit(0);
}