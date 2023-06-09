// Run in Linux
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <getopt.h>
#include <stdbool.h>
#include <string.h>
#include <dirent.h>

#define BUFLEN 2048

#define USAGE "Usage: cp [OPTION] SOURCE DIST\n" \
              "-r copy directories recursively\n"  

bool recursion_mode;

int srcid = 1;
int disid = 2;

char srcbuf[BUFLEN];
char disbuf[BUFLEN];
char buf[BUFLEN];

char *parse_filename(char *pathname) {
  char *ptr = pathname + strlen(pathname);

  while (ptr >= pathname && *ptr != '/') {
    ptr--;
  }

  return ptr + 1;
}

bool cp() {
  struct stat src;
  struct stat dis;

  char *srcendptr = srcbuf + strlen(srcbuf);
  char *disendptr = disbuf + strlen(disbuf);

  if (stat(srcbuf, &src) != 0) {
    fprintf(stdout, "cp: cannot stat \'%s\': No such file or directory\n", srcbuf);
    return false;
  }

  if (!recursion_mode && S_ISDIR(src.st_mode)) {
    fprintf(stdout, "cp: -r not specified; omitting directory \'%s\'\n", srcbuf);
    return false;
  }

  if (S_ISREG(src.st_mode)) {
    if (stat(disbuf, &dis) == 0 && S_ISDIR(dis.st_mode)) {
      *disendptr = '/';

      char *srcname = parse_filename(srcbuf);

      if (disendptr + 1 - disbuf + strlen(srcname) > BUFLEN) {
        fprintf(stdout, "cp: file path length is too long\n");
        return false;
      }
      
      strncpy(disendptr + 1, srcname, strlen(srcname));
      *(disendptr + strlen(srcname) + 1) = '\0';

      return cp();
    }

    FILE *srcfd = fopen(srcbuf, "r");
    FILE *disfd = fopen(disbuf, "w");

    while (true) {
      size_t readlen;
      
      readlen = fread(buf, 1, BUFLEN, srcfd);

      if (readlen == 0) {
        break;
      }

      fwrite(buf, 1, readlen, disfd);
    }

    fclose(srcfd);
    fclose(disfd);

    return true;
  }

  if (S_ISDIR(src.st_mode)) {
    DIR *srcdir;
    struct dirent *entry;

    srcdir = opendir(srcbuf);

    while ((entry = readdir(srcdir)) != NULL) {
      if (strcmp(".", entry->d_name) == 0 || strcmp("..", entry->d_name) == 0) {
        continue;
      }

      mkdir(disbuf, S_IRWXU);

      *disendptr = '/';
      *srcendptr = '/';

      if (srcendptr + 1 - srcbuf + strlen(entry->d_name) > BUFLEN) {
        fprintf(stdout, "cp: file path length is too long\n");
        return false;
      }

      if (disendptr + 1 - disbuf + strlen(entry->d_name) > BUFLEN) {
        fprintf(stdout, "cp: file path length is too long\n");
        return false;
      }
      
      strncpy(srcendptr + 1, entry->d_name, strlen(entry->d_name));
      *(srcendptr + strlen(entry->d_name) + 1) = '\0';
      strncpy(disendptr + 1, entry->d_name, strlen(entry->d_name));
      *(disendptr + strlen(entry->d_name) + 1) = '\0';

      if (!cp()) {
        return false;
      }
    }

    closedir(srcdir);

    return true;
  }
  
  return false;
}

int main(int argc, char *argv[]) {
  if (argc != 3 && argc != 4) {
    fprintf(stdout, USAGE);
    return 1;
  }

  int op;

  while ((op = getopt(argc, argv, "r")) != -1) {
    switch (op) {
      case 'r':
        recursion_mode = true;
        srcid = 2;
        disid = 3;
        break;
      default:
        fprintf(stdout, USAGE);
        return 1;
    }
  }

  if (strlen(argv[srcid]) > BUFLEN) {
    fprintf(stdout, "cp: source file path is too long\n");
    return 1;
  }

  if (strlen(argv[disid]) > BUFLEN) {
    fprintf(stdout, "cp: distination file path is too long\n");
    return 1;
  }

  strncpy(srcbuf, argv[srcid], strlen(argv[srcid]));
  strncpy(disbuf, argv[disid], strlen(argv[disid]));

  if (!cp()) {
    return 1;
  }

  return 0;
}
