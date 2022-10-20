# Lab: Xv6 and Unix utilities

## 1 Boot xv6

导入实验和启动系统

```git
git clone git://g.csail.mit.edu/xv6-labs-2022
cd xv6-labs-2022
git cheakout util
git commit -am 'my solution for util lab exercise 1'
make qemu
```

测试自己的代码的正确性

```shell
make grade #for all test
make GRADEFLAGS='test' grade # test just for test
```

或者

```shell
.\grade-lab-util <test name>
```

## 2 sleep(easy)

> 实现一个sleep程序，可以暂停用户要求的时间。

### 2.1 系统调用sleep

本实验只用实现系统调用。

### 2.2 程序代码

```c
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
```

## 3 pingpong(easy)

> 实现一个程序，完成两个进程之间一个字节的信息交流。
>
> 实现方法：通过管道
>
> 父进程向子进程通过管道发送一个字节的信息后，子进程接受到消息后打印接受消息信息，并向父进程发送一个字节的信息，父进程收到消息之后，打印接受到消息的信息。

### 3.1 系统调用pipe，read，write，getpid，fork

**对于子进程和父进程，他们共享文件描述符，但是相互独立。**

#### 3.1.1 pipe

管道是一个小型的系统缓存，并向进程提供两个文件描述符，一个管道读取描述符一个管道写入描述符。用户只能在管道的一端写入，并在另一端读取。管道以这种方式向进程提供了信息交流的方式。

管道具有以下特点：

- 半双工
- 不可重复读取

基于以上特性，**数据在管道中只能单向传输，而且不能长期存在（读取后就不存在了）。**

#### 3.1.2 获取一个pipe

通过系统调用`pipe`函数，可以申请得到一个pipe。

```c
int p[2];
pipe(p);
```

如果申请成功，pipe[0]储存的读取描述符，而p[1]储存的是写入描述符。

#### 3.1.3 fork

`fork`的作用是创建一个子进程，在父进程中返回子进程的`pid`，而在子进程中返回0；

有关fork的详细细节，可以参考`CSAPP3E`的8.4节。

**由于父子进程共享文件描述符，所以子进程和父进程都需要手动关闭相关的文件描述符**

#### 3.1.4 read & write

详细内容可以参考`CSAPP3E`第10章。

#### 3.1.5 getpid

获得当前进程的pid。

#### 3.2 代码实现

在父进程创建管道，之后会与子进程共享。

由于子进程和父进程几乎并行，所以我们要先等待子进程结束后再继续执行父进程。（否则子进程的管道就没有读的了，要发生阻塞直到对应的文件描述符关闭，而且没有相应的收到信息的输出）

```c
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
```

## 4 primes(hard)

> 阅读 `Bell Lab and CSP Thread`材料，用进程间的通信完成材料中质数筛选的实验
>
> 该程序的思路的流程图;
>
> ![primes](https://swtch.com/~rsc/thread/sieve.gif)
>
> 向每个质数分配一个子进程，用pipe管道向下一个子进程传输不是自己的倍数的数。

### 4.1 写入管道阻塞

#### 4.1.1 产生原因

因为管道提供的缓存大小有限（很小），当输入到管道中的数据的大小达到管道的最大的容量的时候，写入就会阻塞。

#### 4.1.2 解决方案

为了解决这个问题，需要先创建子进程开始从管道中读取，父进程在此之后提供输入。

#### 4.1.3 新的问题

由于每个进程都要先创建子进程，所以进程会一直创建下去，然后就崩溃了，0.0

### 4.2 无限子进程

#### 4.2.1 产生原因

见4.1.3

#### 4.2.2 解决方法

- 能否提供一个标记值？

该方法的问题：父进程创建一个子进程的时候，子进程会复制父进程的变量的副本（子进程是父进程的复制品），然而父进程一开始就会创建子进程，即使后面父进程的检查发现了问题打上了这个标记，子进程也不知道，因为变量之间相互独立。

- 无奈本题特殊解（我太菜了）

由于是筛质数，所以进程数有限，当进程数超过要判断的数的总数之后，就可以不用在产生新的进程了。（特殊解罢了，一旦要判断数的总数增加，这个程序产生的无用的进程就更多了，。。）

### 4.3 创建进程

由于子进程很多，不太可能写条件嵌套吧？

**用递归函数来创建子子进程**

形如：

```c
void forkandfork() {
    if (fork() == 0) {
        forkandfork();
    }
    
    exit(0);
}
```

### 4.4 进程间的沟通

进程间的沟通参考`3 pingpong`

**实现**

```c
while (read(fd0, &value, 32)) {
    if (!prime) {
        prime = value;
        fprintf(1, "prime %d\n", prime);
    }

    if (value % prime != 0) {
        write(p[1], &value, 32);
    }
}
```

### 4.5 代码实现

```C
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int p[2];
int flag = 1;
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

    while (read(fd0, &value, 32)) {
        if (!prime) {
            prime = value;
            fprintf(1, "prime %d\n", prime);
        }

        if (value % prime != 0) {
            write(p[1], &value, 32);
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
        write(p[1], &i, 32);
    }

    close(p[1]);
    close(1);

    wait(0);

    exit(0);
}
```

## 5 find(moderate)

> 编写一个程序，实现在指定文件夹以及子文件夹中搜索要查找到的文件。

### 5.1 阅读ls.c

ls.c 源码

```C
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"

char*
fmtname(char *path)
{
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
    ;
  p++;

  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
    return p;
  memmove(buf, p, strlen(p));
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  return buf;
}

void
ls(char *path)
{
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;

  if((fd = open(path, 0)) < 0){
    fprintf(2, "ls: cannot open %s\n", path);
    return;
  }

  if(fstat(fd, &st) < 0){
    fprintf(2, "ls: cannot stat %s\n", path);
    close(fd);
    return;
  }

  switch(st.type){
  case T_FILE:
    printf("%s %d %d %l\n", fmtname(path), st.type, st.ino, st.size);
    break;

  case T_DIR:
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
      printf("ls: path too long\n");
      break;
    }
    strcpy(buf, path);
    p = buf+strlen(buf);
    *p++ = '/';
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
      if(de.inum == 0)
        continue;
      memmove(p, de.name, DIRSIZ);
      p[DIRSIZ] = 0;
      if(stat(buf, &st) < 0){
        printf("ls: cannot stat %s\n", buf);
        continue;
      }
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
    }
    break;
  }
  close(fd);
}

int
main(int argc, char *argv[])
{
  int i;

  if(argc < 2){
    ls(".");
    exit(0);
  }
  for(i=1; i<argc; i++)
    ls(argv[i]);
  exit(0);
}

```

#### 5.1.1 fmtname函数

该函数的作用是：提取路径中的文件名。

对于`memset(buf + strlen(p), ' ', DIRSIZ - strlen(p))`的理解，此处用`‘ ’`对末尾数组的初始化并不是错误的，这样初始化的目的是为了ls在打印的时候列对齐。（不知道这个目的的意义有多大。。。

#### 5.1.2 ls 函数

很明显，该函数的目的就是打印当前目录下的内容

##### 5.1.2.1 目录类型

按照xv6的参考文档，目录可以分成三种类型：

- 文件
- 设备文件
- 目录

三种形式都可以打开，并且我们可以用`fstat`函数获得该目录的信息。信息储存在`struct stat`中。该结构体的`type`属性表示了该目录的类型：

- T_FILE 文件类型
- T_DEVICE 设备文件类型
- T_DIR 目录类型

##### 5.1.2.2 实现的思路

打开该目录，保存对应的文件描述符。并用`fstat`获得该文件描述符中的信息。如果该目录的类型是文件，或者是设备文件，就直接打印文件名。如果该目录类型是目录，则该文件里描述了该目录中的文件信息。每个文件信息可以用`struct dirent`来表示。

**struct dirent**

```C
struct dirent {
    int inum;
    char *name;
};
```

inum表示inode number；目录进入节点编号，**如果inode的节点编号为0，则表示该文件不存在可以跳过**。name就是表示文件名了。读取到该信息之后，就把文件名拼接到路径名上。再用`stat`函数获得该文件的信息，并打印出文件名，文件类型，文件的节点编号，文件的大小。

### 5.2 仿写ls.c

如果说文件系统是一棵树，那么我认为每个文件和设备文件都是叶子节点，每个文件夹目录就是一个内节点。

#### 5.2.1 仿写fmtname函数

唯一要注意的一点是，最后的memset的初始化的值是0，因为我们此时的目的不在是列表对齐了，而是纯纯的一个文件名！！

#### 5.2.2 仿写ls函数

首先，我们也必须知道当前的目录路径是什么类型，所以也需要对目录进行打开并且获得他的文件描述符中的相关信息。如果该目录路径是一个文件或者是一个设备文件，我们就获得他的文件名和要查找的文件名进行比较，如果匹配，就输出当前的路径。不匹配，则继续。

如果该目录路径类型是一个文件夹，则我们要查找该文件夹中的所有文件，从该目录文件里每次读取一个`struct dirent`，如果读取内容有效，拼接文件名到当前目录路径上，然后继续搜素。

#### 5.2.3 防止死循环

由于每个文件中都有`.`文件夹和`..`文件夹，分别表示当前文件夹和父文件夹。搜素并不需要访问父文件夹，所以`..`文件我们可以直接跳过，然后对于`.`文件夹，我们就不嫩直接跳过了（因为程序开始就是`.`文件夹，跳过就不用搜索辣:）。

为了解决这个问题，我们保存当前目录路径的iNode编号，以及即将要查找的文件路径的iNode编号，如果相同，则我们就不用再继续搜索这个文件夹。

#### 5.2.4 仿写出来的find函数

```c
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
```

至此整体代码就基本实现了。

### 5.3 代码实现

```C
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
```

## 6 xargs(moderate)

> 编写一个程序，实现linux xargs基础功能。
>
> xargs通常和管道使用，例如
>
> ```shell
> echo bye too | xargs echo hello
> ```
>
> 首先管道的左边执行`echo bye too`此时会从标准输出流中输出`bye too`。而管道右侧执行`xargs`程序，该程序从管道的左侧的输出读取信息（从该程序的标准输入流中读取），作为即将要运行的`echo`程序的扩展参数。
>
> 即整个命令行相当于执行了`echo hello bye too`，所以打印出了`hello bye too`。

### 6.1 实现方式

#### 6.1.1 读取左侧的参数

定义一个全局变量buf来保存读取到的信息流。按照题目描述的要求，每一行就是一个参数，所以只要读到换行符，我们就将该换行符保存为`‘\0’`，表示一个字符串（即参数）的结束，并累计参数计数器。

#### 6.1.2 整合程序参数

新声明一个args字符指针数组，保存每个参数的起始地址。首先将命令行中本有的参数保存在args中，在从buf中读取累计的参数个数的参数的起始地址。

```C
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
```

整个程序的难点就在这里了。

#### 6.1.3 新建子进程

用fork和exec运行程序即可。

### 6.2 代码实现

```C
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
```

## 7 END

整个lab就写完了，测试结果如下。

```
== Test sleep, no arguments == 
$ make qemu-gdb
sleep, no arguments: OK (4.9s) 
== Test sleep, returns == 
$ make qemu-gdb
sleep, returns: OK (0.9s) 
== Test sleep, makes syscall == 
$ make qemu-gdb
sleep, makes syscall: OK (0.9s) 
== Test pingpong == 
$ make qemu-gdb
pingpong: OK (0.9s) 
== Test primes == 
$ make qemu-gdb
primes: OK (1.0s) 
== Test find, in current directory == 
$ make qemu-gdb
find, in current directory: OK (1.2s) 
== Test find, recursive == 
$ make qemu-gdb
find, recursive: OK (1.1s) 
== Test xargs == 
$ make qemu-gdb
xargs: OK (1.3s) 
== Test time == 
time: OK 
Score: 100/100
```

