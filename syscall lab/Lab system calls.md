# Lab system call

## 1 Using gdb(easy)

> 摸摸GDB

### 1.1 如何调试

在实验目录下运行`make qemu-gdb`，并且在一个新的终端中导航至实验目录，运行**`gdb-multiarch`**，并且只能是这个。

但是会遇到一个问题：

```shell
warning: File "/home/ubuntu/program/xv6-labs-2022/.gdbinit" auto-loading has been declined by your `auto-load safe-path' set to "$debugdir:$datadir/auto-load".
To enable execution of this file add
        add-auto-load-safe-path /home/ubuntu/program/xv6-labs-2022/.gdbinit
line to your configuration file "/home/ubuntu/.gdbinit".
To completely disable this security protection add
        set auto-load safe-path /
line to your configuration file "/home/ubuntu/.gdbinit".
For more information about this security protection see the
"Auto-loading safe path" section in the GDB manual.  E.g., run from the shell:
        info "(gdb)Auto-loading safe path"
```

根据提示，只需要在用户文件夹中创建`.gdbinit`文件并输入`set auto-load safe-path /`即可。保存后就可以编译了。

### 1.2 题目相关设问的回答

1. Looking at the backtrace output, which function called `syscall`?

根据backtrace的反馈，`usertrap`函数调用了`systemcall`。

2. What is the value of `p->trapframe->a7` and what does that value represent? (Hint: look `user/initcode.S`, the first user program xv6 starts.)

根据`user/initcode.S(11)`可以确定现在的a7是`SYS_exec`(7)。

3. What was the previous mode that the CPU was in?

打印`sstatus`寄存器中的相关信息，得到`0x22`，二进制`00100010`，SSP（第8位）位值为0。据问题提供的`riscv-privileged-202101203`中第63页的描述`The SPP bit indicates the privilege level at which a hart was executing before entering supervisor mode.When a trap is taken, SPP is set to 0 if the trap originated from user mode, or 1 otherwise.`，0表示从用户态触发了陷阱。

4. Write down the assembly instruction the kernel is panicing at. Which register corresponds to the varialable `num`?

根据出错信息，定位到了汇编的这一行`80001ff4:	00002683          	lw	a3,0(zero) # 0 <_entry-0x80000000>`，并可以得到`num`储存在`a3`寄存上的。

5. Why does the kernel crash? Hint: look at figure 3-3 in the text; is address 0 mapped in the kernel address space? Is that confirmed by the value in `scause` above? 

因为虚拟内存地址0并未与内核地址产生映射。`scause	`的值设为了`0xd`，即13，查询参考文本，`scause`寄存器最高位表示中断类型，剩下的表示异常码。在中断类型为0，异常码为13的情况表示`Load Page Fault`，和实际错误相符。

6. What is the name of the binary that was running when the kernel paniced? What is its process id (`pid`)?

此时运行的是`initcode`，进程号为1（打印p相关信息得到）。

## 2 system call tracing(moderate)

> 修改已有的相关代码，实现系统调用`trace`，该系统调用接受一个参数，通过判断该位是否是1来判断要追踪某个系统调用的使用。

### 2.1 系统调用的过程

在进程触发系统调用的时候，会修改进程信息结构中的`trapframe->a7`，该数值就表示要调用的系统函数的编号。之后运行`/kernel/syscall.h`中的`syscall()`函数，该函数通过在`a7`中保存的调用函数的编号找到在`kernel/sysproc.c`中对应的系统函数，并将系统函数的返回值保存在`trapframe->a0`中。

### 2.2 添加系统调用trace的信息

按照题目给的hint，首先修改`Makefile`。在`user/usys.pl`中添加`entry("trace");`。在`user/user.h`中添加`int trace(int);`。`kernel/syscall.h`中添加`#define SYS_trace 22`。在`kernel/sysproc.c`添加`systrace()`函数，并实现功能。在`kernel/syscall.c`中添加`sys_trace`的函数指针。

### 2.3 实现trace相关功能

为了在当前进程和子进程中记录是否要追踪某些系统函数的调用，我们可以在`struct proc`中添加`int trace_s;`属性，表示要追踪的系统调用函数的码图。

#### 2.3.1 实现sys_trace

> 该函数通过`argint`函数来获取用户态传递的参数：要追踪的系统调用的码图。并获得自己当前进程的`proc`结构体，将我们新建的`trace_s`用码图来赋值。
>
> 根据题目需要，该函数返回值为0。

代码

```C
uint64
sys_trace(void)
{
  int trace_s;

  argint(0, &trace_s);

  myproc()->trace_s = trace_s;

  return 0;
}
```

#### 2.3.2 修改syscall

为了判断是否需要追踪，每调用一次，判断该位是否为1，有就打印追踪信息（提前算好每个系统调用的码图，可以提速0.4s）。

代码：

```C
static char *syscallnames[] = {
[SYS_fork]    "fork",
[SYS_exit]    "exit",
[SYS_wait]    "wait",
[SYS_pipe]    "pipe",
[SYS_read]    "read",
[SYS_kill]    "kill",
[SYS_exec]    "exec",
[SYS_fstat]   "fstat",
[SYS_chdir]   "chdir",
[SYS_dup]     "dup",
[SYS_getpid]  "getpid",
[SYS_sbrk]    "sbrk",
[SYS_sleep]   "sleep",
[SYS_uptime]  "uptime",
[SYS_open]    "open",
[SYS_write]   "write",
[SYS_mknod]   "mknod",
[SYS_unlink]  "unlink",
[SYS_link]    "link",
[SYS_mkdir]   "mkdir",
[SYS_close]   "close",
[SYS_trace]   "trace",
};

static int syscallmasks[] = {
[SYS_fork]    1 << SYS_fork,
[SYS_exit]    1 << SYS_exit,
[SYS_wait]    1 << SYS_wait,
[SYS_pipe]    1 << SYS_pipe,
[SYS_read]    1 << SYS_read,
[SYS_kill]    1 << SYS_kill,
[SYS_exec]    1 << SYS_exec,
[SYS_fstat]   1 << SYS_fstat,
[SYS_chdir]   1 << SYS_chdir,
[SYS_dup]     1 << SYS_dup,
[SYS_getpid]  1 << SYS_getpid,
[SYS_sbrk]    1 << SYS_sbrk,
[SYS_sleep]   1 << SYS_sleep,
[SYS_uptime]  1 << SYS_uptime,
[SYS_open]    1 << SYS_open,
[SYS_write]   1 << SYS_write,
[SYS_mknod]   1 << SYS_mknod,
[SYS_unlink]  1 << SYS_unlink,
[SYS_link]    1 << SYS_link,
[SYS_mkdir]   1 << SYS_mkdir,
[SYS_close]   1 << SYS_close,
[SYS_trace]   1 << SYS_trace,
};

void
syscall(void)
{
  int num;
  struct proc *p = myproc();

  num = p->trapframe->a7;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();

    if (p->trace_s & syscallmasks[num]) {
      printf("%d: syscall %s -> %d\n", p->pid, syscallnames[num], p->trapframe->a0);
    }
  } else {
    printf("%d %s: unknown sys call %d\n",
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
  }
}
```

#### 2.3.3 修改kernel/proc.c

为了能追踪子进程中的系统调用，要在fork函数中复制`trace_s`信息。

```C
np->trace_s = p->trace_s;
```

### 2.4 完成对trace系统调用的添加

通过测试，除了检测子进程的系统调用追踪用了42秒以外，其他测试通过。（感觉是按照步骤要求来写了，但是就是要用42秒，也不知道能不能优化，仅仅做了一个小优化，在判断是不是要追踪的系统调用哪里）

## 3 Sysinfo(moderate)

> 添加系统调用`sysinfo`，该调用向用户返回当前系统的可用空间和正在使用的进程数。

### 3.1 添加sysinfo的系统调用

该过程如同`2 trace`。

只要注意题目给的hint的中的：

```
To declare the prototype for sysinfo() in user/user.h you need predeclare the existence of struct sysinfo:

    struct sysinfo;
    int sysinfo(struct sysinfo *);
```

### 3.2 实现sysinfo系统调用功能

#### 3.2.1 sysinfo结构体

```C
struct sysinfo {
  uint64 freemem;   // amount of free memory (bytes)
  uint64 nproc;     // number of process
};
```

#### 3.2.2 获得空闲内存的大小

在`kernel/kalloc.c`中定义了一个叫`kmem`的链表，该链表连接了每一个空闲页，每个空闲页的大小`PGSIZE(4096)`。通过遍历这个链表，获得空闲页面的个数，就可以获得空闲页的大小。

```C
uint64
freesize(void)
{
  uint64 count = 0;

  struct run *r;

  r = kmem.freelist;

  while (r) {
    count += PGSIZE;
    r = r->next;
  }

  return count;
}
```

#### 3.2.3 获得系统正在使用的进程的个数

在`kernel/proc.c`中定义了一个`proc`进程数组，每一个是一个`proc`结构体，`proc.stat`保存了该进程的装太。通过遍历这个数组，统计进程状态为`UNUSED`的个数。

```C
uint64
procused(void)
{
  uint64 count = 0;

  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    if (p->state != UNUSED) {
        count++;
    }
  }

  return count;
}
```

#### 3.2.4 在`kernel/defs.h`中声明这两个函数

**extermely important here**

### 3.3 sys_sysinfo()

首先通过自己写的函数获得两个信息，用`copyout()`函数将该信息复制到用户内存上。

#### 3.3.1 copyout

本人用`vscode`根本看不到该函数的源代码，本人理解是，传递四个参数，第一个参数为用户虚拟内存页表位置，第二个参数是要复制到的用户的内存位置，第三个参数是要复制的内容的起始内存位置，第4个参数为要复制的内容的大小。

#### 3.3.2 实现代码

```C
uint64
sys_sysinfo(void) {

  uint64 addr;

  argaddr(0, &addr);

  struct sysinfo info;

  info.freemem = freesize();
  info.nproc = procused();

  if (copyout(myproc()->pagetable, addr, (char *)&info, sizeof(info)) < 0) {
    return -1;
  }

  return 0;
}
```

至此，这个实验也完成了。

## 4 END

整个实验完成。测试结果如下。

```\
```

