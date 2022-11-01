# Lab traps

**提前学习RISC-V的ISA**，https://6191.mit.edu/_static/fall22/resources/references/6004_isa_reference.pdf

## 1 RISC-V assembly (easy)

> 阅读`user/call.asm`，回答下列问题。

1. Which registers contain arguments to functions? For example, which register holds 13 in main's call to `printf`?

`main`函数调用`printf`函数时就将三个参数保存在了`a0, a1, a2`中，其中13（第3个参数）保存在了`a2`寄存器中。

```assembly
void main(void) {
  1c:   1141                    addi    sp,sp,-16
  1e:   e406                    sd      ra,8(sp)
  20:   e022                    sd      s0,0(sp)
  22:   0800                    addi    s0,sp,16
  printf("%d %d\n", f(8)+1, 13);
  24:   4635                    li      a2,13
  26:   45b1                    li      a1,12
  28:   00000517                auipc   a0,0x0
  2c:   7c850513                addi    a0,a0,1992 # 7f0 <malloc+0xe8>
  30:   00000097                auipc   ra,0x0
  34:   61a080e7                jalr    1562(ra) # 64a <printf>
  exit(0);
  38:   4501                    li      a0,0
  3a:   00000097                auipc   ra,0x0
  3e:   298080e7                jalr    664(ra) # 2d2 <exit>
```

2. Where is the call to function `f` in the assembly code for main? Where is the call to `g`? (Hint: the compiler may inline functions.)

`main`中在调用`printf`函数的时候，传递参数时调用了`f`函数，同时`f`函数在返回的时候调用了`g`函数。

```assembly
int f(int x) {
   e:	1141                	addi	sp,sp,-16
  10:	e422                	sd	s0,8(sp)
  12:	0800                	addi	s0,sp,16
  return g(x);
}
```

3. At what address is the function `printf` located?

`000000000000064a <printf>:`

4. What value is in the register `ra` just after the `jalr` to `printf` in `main`?

根据`RISC-V ISA`的`jalr`指令的作用，会将下一条指令的地址保存在寄存器`ra`里，所以`ra`的值是`0x38`。

5. Run the following code.

   ```
   	unsigned int i = 0x00646c72;
   	printf("H%x Wo%s", 57616, &i);
         
   ```

   What is the output? 

HE110 World， 57616的十六进制数值`0xE110`，r对应的hex是72，l对应的十六进制数是6c，d对应的HEX是64.

6. In the following code, what is going to be printed after `'y='`? (note: the answer is not a specific value.) Why does this happen?

   ```
   	printf("x=%d y=%d", 3);
   ```

y输出了1（没有实际意义），原因第二个%d在参数列表中没有对应的参数与之对应。

## 2 Backtrace (moderate)

> 编写一个程序，追踪函数调用轨迹。
>
> 程序栈：
>
> ```
>                    .
>                    .
>                    .
>       +-> +-----------------+   |
>       |   | return address  |   |
>       |   |   previous fp ------+
>       |   | saved registers |
>       |   | local variables |
>       |   |       ...       |
>       |   +-----------------+ <-+
>       |   | return address  |   |
>       +------ previous fp   |   |
>           | saved registers |   |
>           | local variables |   |
>           |       ...       |   |
>       +-> +-----------------+   |
>       |   | return address  |   |
>       |   |   previous fp ------+
>       |   | saved registers |
>       |   | local variables |
>       |   |       ...       | 
>       |   +-----------------+ <-+
>       |   | return address  |   |
>       +------ previous fp   |   |
>           | saved registers |   |
>           | local variables |   |
>           |       ...       |   |
>   $fp --> +-----------------+   |
>           | return address  |   |
>           |   previous fp ------+
>           | saved registers |
>   $sp --> | local variables |
>           +-----------------+
> ```

### 2.1 理解这个程序栈

fp寄存器，保存着当前栈帧的起始位置，sp寄存器，保存这当前你进程当前的栈指针。栈帧指针fp的偏移(-8)的位置存放的是当前栈帧的返回地址，偏移（-16）存放的是上一个栈帧的起始位置。利用（-16）的偏移的位置的值，就可以追踪到上一个栈帧。

### 2.2 如何判断追踪的终点

利用hints里的这一条，内核为每个进程栈分配了一个对齐的页，所以所有的栈帧都应该在同一个栈，通过`PGROUNDDOWN`宏就可以知道当前栈帧地址所在的页。比较当前栈帧和下一个栈帧的地址所在的页面的起始位置是不是相同，就可以判断栈帧追踪是不是达到了终点。

### 2.3 根据hints添加相应的函数

这一部分看看hints跟着做就好。

### 2.4 代码实现

```C
void
backtrace(void) {
    printf("backtrace:\n");

    uint64 fp = r_fp();

    while (1) {
        printf("%p\n", *((uint64 *)(fp - 8)));
        uint64 prefp = *((uint64 *)(fp - 16));

        if (PGROUNDDOWN(fp) != PGROUNDDOWN(prefp)) {
            break;
        }

        fp = prefp;
    }
}
```

**要处理好整型和指针之间的区别**

按照题目描述，为了方便后面的调试，我们可以将这个写好的函数，在`panic`函数中调用，以追踪错误信息。

## 3 Alarm (hard)

> 实现一个程序计时器，在一定周期之后执行某一项任务后返回当前程序。

### 3.1 部署sigalarm和sigreturn两个系统调用

仿照`lab syscall`中声明系统调用的方法，声明这两个系统调用函数。

### 3.2 分析trap的过程

1. 用户提出系统调用，并提供系统调用号。
1. 汇编调用`ecall`进入内核态。
1. 进入`usertrap`函数。
1. 如果是用户提出的系统调用中断，则进入相应的syscall函数，用户返回的地址为进入地址加4。
1. 如果是时钟周期中断，则占时跳过，并不使用CPU的资源。
1. 中断处理完之后，回到用户态。

### 3.3 sigalarm

sigalarm请求在一定数量的时钟中断之后执行用户提供的代码，而不是从中断地址继续执行。局部变量`which_dev`表示该调用的类型，如果值为2，则该中断类型是时钟周期的中断。如果是时钟周期的中断，我么怎么知道过了多少个时钟周期，以及用户要求的多少时钟周期过后执行用户代码，以及用户代码地址呢。为了储存这些信息，我们在进程结构体`struct proc`中设置这些信息。

```C
int alarm_interval;
void (*user_handler)();
int ticks_pass;
```

调用`syscall`的时候，我们从用户态获得周期间隔数，和用户代码地址。

```C
uint64
sys_sigalarm(void)
{
    int interval;
    uint64 uhandler;

    argint(0, &interval);
    argaddr(1, &uhandler);

    struct proc *p = myproc();

    p->alarm_interval = interval;
    p->user_handler = (void (*)())uhandler;
    p->ticks_pass = 0;

    return 0;
}
```

当`usertrap`函数获得了时钟中断之后，如果该进程有中断间隔要求，则在tickspass上加一，如果tickspass数等于中断间隔要求，则将`p->trapframe`域中的`epc`（表示返回用户态的程序计数器）设置为用户要求的代码地址，**这个地址可能为0，所以我们不能使用用户代码地址来判断用户是否有周期任务请求**，然后将tickspass置为0，重新开始计数。

这样实现后可以通过该任务的测试0。

```C
if (p->alarm_interval) {
    p->ticks_pass++;
    if (p->ticks_pass == p->alarm_interval) {
        p->ticks_pass = 0;
        p->trapframe->epc = (uint64)p->user_handler;
    }
}
```

### 3.4 处理sigalarm用户态结束恢复进程

> 题目提供了一种思路，进入到用户代码，并将用户代码运行结束之后必须调用`sigreturn`系统调用。我们可以在`sigreturn`处理恢复用户进程。
>
> trapframe保存进入内核态后的用户态的寄存器信息。

#### 3.4.1 需要保存的寄存器

![registers](http://43.139.35.156/upload/2022/11/image-20221101150634287.png)

从`RISC-V ISA`参考文档中得到，除了`t0, t1, t2, ... , t6`是占时寄存器外，其他寄存器都有实际的用途（笔者保险起见，都把这些寄存器的信息都另存起来了），而且进程结构体中有`context`变量，保存的是该进程被暂停之后的寄存器信息，以便之后重新运行之后重新恢复进程状态。可以模仿，设置一个`usercontext`变量，来保存调用用户代码之前，保存在此之前用户态寄存器的状态。

```C
struct usercontext {
    uint64 ra;
    uint64 sp;
    uint64 gp;
    uint64 tp;
    uint64 epc;


    /*  96 */ uint64 s0;
    /* 104 */ uint64 s1;
    /* 112 */ uint64 a0;
    /* 120 */ uint64 a1;
    /* 128 */ uint64 a2;
    /* 136 */ uint64 a3;
    /* 144 */ uint64 a4;
    /* 152 */ uint64 a5;
    /* 160 */ uint64 a6;
    /* 168 */ uint64 a7;
    /* 176 */ uint64 s2;
    /* 184 */ uint64 s3;
    /* 192 */ uint64 s4;
    /* 200 */ uint64 s5;
    /* 208 */ uint64 s6;
    /* 216 */ uint64 s7;
    /* 224 */ uint64 s8;
    /* 232 */ uint64 s9;
    /* 240 */ uint64 s10;
    /* 248 */ uint64 s11;
};
```

#### 3.4.2 保存寄存器状态

当时钟中断数达到了用户提出要求的中断数之后，在调用用户进程代码之前，我们保存寄存器信息，代码如下：

```C
if (which_dev == 2) {
    if (p->alarm_interval) {
        p->ticks_pass++;
        if (p->ticks_pass == p->alarm_interval) {

            p->usercontext.epc = p->trapframe->epc;
            p->usercontext.ra = p->trapframe->ra;
            p->usercontext.sp = p->trapframe->sp;
            p->usercontext.gp = p->trapframe->gp;
            p->usercontext.tp = p->trapframe->tp;
            p->usercontext.s0 = p->trapframe->s0;
            p->usercontext.s1 = p->trapframe->s1;
            p->usercontext.a0 = p->trapframe->a0;
            p->usercontext.a1 = p->trapframe->a1;
            p->usercontext.a2 = p->trapframe->a2;
            p->usercontext.a3 = p->trapframe->a3;
            p->usercontext.a4 = p->trapframe->a4;
            p->usercontext.a5 = p->trapframe->a5;
            p->usercontext.a6 = p->trapframe->a6;
            p->usercontext.a7 = p->trapframe->a7;
            p->usercontext.s2 = p->trapframe->s2;
            p->usercontext.s3 = p->trapframe->s3;
            p->usercontext.s4 = p->trapframe->s4;
            p->usercontext.s5 = p->trapframe->s5;
            p->usercontext.s6 = p->trapframe->s6;
            p->usercontext.s7 = p->trapframe->s7;
            p->usercontext.s8 = p->trapframe->s8;
            p->usercontext.s9 = p->trapframe->s9;
            p->usercontext.s10 = p->trapframe->s10;
            p->usercontext.s11 = p->trapframe->s11;

            p->ticks_pass = 0;
            p->trapframe->epc = (uint64)p->user_handler;
        }
    }
}
```

#### 3.4.3 恢复寄存器状态

执行完用户态的代码之后，会调用系统函数`sigreturn`，进入该函数后，我们恢复寄存器。之后会在`usertrap`函数返回到用户态。

```C
uint64
sys_sigreturn()
{
    struct proc *p = myproc();

    p->trapframe->ra = p->usercontext.ra;
    p->trapframe->sp = p->usercontext.sp;
    p->trapframe->gp = p->usercontext.gp;
    p->trapframe->tp = p->usercontext.tp;
    p->trapframe->s0 = p->usercontext.s0;
    p->trapframe->s1 = p->usercontext.s1;
    p->trapframe->a0 = p->usercontext.a0;
    p->trapframe->a1 = p->usercontext.a1;
    p->trapframe->a2 = p->usercontext.a2;
    p->trapframe->a3 = p->usercontext.a3;
    p->trapframe->a4 = p->usercontext.a4;
    p->trapframe->a5 = p->usercontext.a5;
    p->trapframe->a6 = p->usercontext.a6;
    p->trapframe->a7 = p->usercontext.a7;
    p->trapframe->s2 = p->usercontext.s2;
    p->trapframe->s3 = p->usercontext.s3;
    p->trapframe->s4 = p->usercontext.s4;
    p->trapframe->s5 = p->usercontext.s5;
    p->trapframe->s6 = p->usercontext.s6;
    p->trapframe->s7 = p->usercontext.s7;
    p->trapframe->s8 = p->usercontext.s8;
    p->trapframe->s9 = p->usercontext.s9;
    p->trapframe->s10 = p->usercontext.s10;
    p->trapframe->s11 = p->usercontext.s11;
    p->trapframe->epc = p->usercontext.epc;

    return 0;
}
```

此时测试，就会通过测试1。

#### 3.4.4 避免重复调用

存在下列情况，用户请求每隔2个时钟周期调用处理程序，而处理程序需要三个时钟周期，此时存在系统调用没有结束的情况下，又一次调用了用户程序，存在重复调用的情况。

为了解决这个情况，我们在进程结构体中增加一个变量，表示是否正在执行用户代码调用。不妨设该变量为`alarmstatus`。当时钟周期数达到用户要求的周期数之后，我们设置这个标记位，当用户调用了`sigreturn`函数时，我们将该变量设置为0。

当该变量值为0的时候，我们才可以进入用户的代码，否则，跳过这个周期。

``` C
------trap,c: usertrap--------
if (.... && p->alarmstatus == 0) {
    ...
    p->alarmstatus = 1;
}

------syscall.c/sys_sigreturn-------
void
    sys_sigreturn()
{
    ...
        p->alarmstatus = 0;
}
```

此时，通过测试2。

#### 3.4.5 保护a0寄存器

a0寄存器作为函数返回值所使用的寄存器，在调用syscall的时候，syscall的返回值就会覆盖到a0寄存器，导致之前用户态的a0寄存器的值被破坏。为了解决这个问题，我们可以将用户态之前的a0值作为`sigreturn`的返回值。

此时整个`sigreturn`的代码如下：

```c
uint64
sys_sigreturn()
{
    struct proc *p = myproc();

    p->trapframe->ra = p->usercontext.ra;
    p->trapframe->sp = p->usercontext.sp;
    p->trapframe->gp = p->usercontext.gp;
    p->trapframe->tp = p->usercontext.tp;
    p->trapframe->s0 = p->usercontext.s0;
    p->trapframe->s1 = p->usercontext.s1;
    p->trapframe->a0 = p->usercontext.a0;
    p->trapframe->a1 = p->usercontext.a1;
    p->trapframe->a2 = p->usercontext.a2;
    p->trapframe->a3 = p->usercontext.a3;
    p->trapframe->a4 = p->usercontext.a4;
    p->trapframe->a5 = p->usercontext.a5;
    p->trapframe->a6 = p->usercontext.a6;
    p->trapframe->a7 = p->usercontext.a7;
    p->trapframe->s2 = p->usercontext.s2;
    p->trapframe->s3 = p->usercontext.s3;
    p->trapframe->s4 = p->usercontext.s4;
    p->trapframe->s5 = p->usercontext.s5;
    p->trapframe->s6 = p->usercontext.s6;
    p->trapframe->s7 = p->usercontext.s7;
    p->trapframe->s8 = p->usercontext.s8;
    p->trapframe->s9 = p->usercontext.s9;
    p->trapframe->s10 = p->usercontext.s10;
    p->trapframe->s11 = p->usercontext.s11;
    p->trapframe->epc = p->usercontext.epc;

    p->alarmstatus = 0;

    return p->usercontext.a0;
}
```

此时测试，通过了所有测试。

### 3.5 考虑对声明的变量的分配和释放

在这个实验中，我们定义了`alarm_interval`/`userhandler`/`usercontext`/`alarmstatus`/`ticks_pass`，进程创建初期要全部置0，进程结束也全部归零。

```C
---allocproc---
{
    ....
  memset(&p->usercontext, 0, sizeof(p->usercontext));
  p->alarm_interval = 0;
  p->user_handler = 0;
  p->ticks_pass = 0;
  p->alarmstatus = 0;
    ....
}

---freeproc---
{
    ....
  p->alarm_interval = 0;
  p->user_handler = 0;
  p->ticks_pass = 0;
  p->alarmstatus = 0;
    ....
}
```

## 4 END

实验完成，测试结果如下：

```
== Test answers-traps.txt == answers-traps.txt: OK 
== Test backtrace test == 
$ make qemu-gdb
backtrace test: OK (4.0s) 
== Test running alarmtest == 
$ make qemu-gdb
(6.2s) 
== Test   alarmtest: test0 == 
  alarmtest: test0: OK 
== Test   alarmtest: test1 == 
  alarmtest: test1: OK 
== Test   alarmtest: test2 == 
  alarmtest: test2: OK 
== Test   alarmtest: test3 == 
  alarmtest: test3: OK 
== Test usertests == 
$ make qemu-gdb
usertests: OK (204.3s) 
== Test time == 
time: OK 
Score: 95/95
```

