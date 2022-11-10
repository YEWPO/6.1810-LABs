# Lab Multithreading

> 实际运用多线程

## 1 Uthread: switching between threads (moderate)

> 在Xv6里实现线程调度

### 1.1 struct thread

在该实验中，已经定义好了线程结构体：

```C
struct thread {
  char       stack[STACK_SIZE]; /* the thread's stack */
  int        state;             /* FREE, RUNNING, RUNNABLE */
};
```

stack为该线程运行时的栈，而status表示该线程的状态，`FREE, RUNNING, RUNABLE`。

**该实验希望你在该stack上运行该线程**

### 1.2 create thread

创建一个新的线程结构体，将该线程的状态设置为free；

### 1.3 Switch thread

如同进程一样，线程也有自己的状态，在切换之前，我们要保存上一个线程的转态，然后将进程转态切换至下一个线程状态。

#### 1.3.1 save registers

我们需要保留`ra`寄存器，`ra`作为了函数返回时的目标指令地址，我们需要保存ra。

在是否需要保存这个寄存器的时候，我想了这些问题：

- 保存该寄存器的操作是在`thread_schedule`函数中进行的，即使保存了ra寄存器，到时候函数返回时还是回到了该函数，好像没有起作用呀？

但是线程的栈用的是自己的栈，切换线程也会切换栈，所以即使回到这个函数上继续执行，在栈上保存的函数返回地址就会引导该函数回到我们希望线程执行的函数中。

- 线程开始时如何设置ra。

第一个线程函数会在第一次调用`thread_schedule`函数时进行线程切换的时候就返回到ra保存的地址上。所以，我们在创建进程的时候，就将线程保存的ra寄存器值设置为函数的起始地址。

综上，保存ra寄存器是有必要的。

#### 1.3.2 save callee registers

首先看看`callee register`和`caller register`的英文描述

```
Caller-saved registers (AKA volatile registers, or call-clobbered) are used to hold temporary quantities that need not be preserved across calls.
```

调用者保留寄存器存放的暂时的值，这些值不会在调用之间传递，意思会被破坏，所以`caller-saved registers`我们可以不保存。

```\
Callee-saved registers (AKA non-volatile registers, or call-preserved) are used to hold long-lived values that should be preserved across calls.
```

被调用者保留寄存器是被调用保护的，他会在调用之间保存，并且长时间的存在。所以，我们要保留这些寄存器。

为了保留这些寄存器，我们定义一个`pthread_context`结构体，并且在线程结构体中声明一个。

```c
struct thread_context {
  uint64 ra;
  uint64 sp;
  uint64 s0;
  uint64 s1;
  uint64 s2;
  uint64 s3;
  uint64 s4;
  uint64 s5;
  uint64 s6;
  uint64 s7;
  uint64 s8;
  uint64 s9;
  uint64 s10;
  uint64 s11;
};
```

#### 1.3.4 switch.S

在汇编级别上，我们实现对寄存器的保留。

```assembly
.text

# thread_switch(struct thread_context *old, struct thread_context *new);

.globl thread_switch
thread_switch:
    sd ra, 0(a0)
    sd sp, 8(a0)
    sd s0, 16(a0)
    sd s1, 24(a0)
    sd s2, 32(a0)
    sd s3, 40(a0)
    sd s4, 48(a0)
    sd s5, 56(a0)
    sd s6, 64(a0)
    sd s7, 72(a0)
    sd s8, 80(a0)
    sd s9, 88(a0)
    sd s10, 96(a0)
    sd s11, 104(a0)

    ld ra, 0(a1)
    ld sp, 8(a1)
    ld s0, 16(a1)
    ld s1, 24(a1)
    ld s2, 32(a1)
    ld s3, 40(a1)
    ld s4, 48(a1)
    ld s5, 56(a1)
    ld s6, 64(a1)
    ld s7, 72(a1)
    ld s8, 80(a1)
    ld s9, 88(a1)
    ld s10, 96(a1)
    ld s11, 104(a1)

    ret # return ra;
```

### 1.4 init sp

在创建线程的时候，将sp赋值为stack的地址。

**its buggy**

### 1.5 run & debug

运行该程序，然后发现把100次的C线程运行完了，以为正确，然后发现a，b线程根本没跑完。但是怎么回事呢？

为了方便我们调试，我们设置`CPUS=1`的参数。

调试后发现，当C线程执行完循环的第一步的操作之后，线程A和B的status被修改了。

然后调试发现，当线程在运行的时候，运行的时候栈的内容并没有真正的保存在线程所在的栈中。

#### 1.5.1 没有在自己的栈里跑的原因

众所周知，程序的栈指针是向负方向增长的，压栈是做弹操作，弹栈是加操作。所以，出问题的地方在这里：

线程初始化的时候，指针初始化的位置在线程栈的开头、又因为在C语言中，访问数组元素是地址增加的行为，和栈指针行为恰好相反，所以栈指针在做减法的时候就访问到了其他线程结构体中的元素了。0.0

#### 1.5.2 修改

将栈指针初始化为数组的末尾。

### 1.6 finish

运行程序，能得到正确的结果。

## 2 Using threads (moderate)

> 添加线程锁，防止多线程访问共享变量竞争

当多个线程要修改同一个链表的时候，就会产生竞争，为了解决这个竞争，为每个哈希桶准备一个锁，当发生写或者是读操作时，使该线程拥有这个锁，当操作结束的时候，释放这个锁，以便其他线程可以使用这个哈希桶。

```C
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <assert.h>
#include <pthread.h>
#include <sys/time.h>

#define NBUCKET 5
#define NKEYS 100000

struct entry {
  int key;
  int value;
  struct entry *next;
};
struct entry *table[NBUCKET];
int keys[NKEYS];
int nthread = 1;

pthread_mutex_t lock[NBUCKET];

double
now()
{
 struct timeval tv;
 gettimeofday(&tv, 0);
 return tv.tv_sec + tv.tv_usec / 1000000.0;
}

static void
insert(int key, int value, struct entry **p, struct entry *n)
{
  struct entry *e = malloc(sizeof(struct entry));
  e->key = key;
  e->value = value;
  e->next = n;
  *p = e;
}

static
void put(int key, int value)
{
  int i = key % NBUCKET;

  pthread_mutex_lock(&lock[i]);

  // is the key already present?
  struct entry *e = 0;
  for (e = table[i]; e != 0; e = e->next) {
    if (e->key == key)
      break;
  }
  if(e){
    // update the existing key.
    e->value = value;
  } else {
    // the new is new.
    insert(key, value, &table[i], table[i]);
  }

  pthread_mutex_unlock(&lock[i]);
}

static struct entry*
get(int key)
{
  int i = key % NBUCKET;

  pthread_mutex_lock(&lock[i]);

  struct entry *e = 0;
  for (e = table[i]; e != 0; e = e->next) {
    if (e->key == key) break;
  }

  pthread_mutex_unlock(&lock[i]);

  return e;
}

static void *
put_thread(void *xa)
{
  int n = (int) (long) xa; // thread number
  int b = NKEYS/nthread;

  for (int i = 0; i < b; i++) {
    put(keys[b*n + i], n);
  }

  return NULL;
}

static void *
get_thread(void *xa)
{
  int n = (int) (long) xa; // thread number
  int missing = 0;

  for (int i = 0; i < NKEYS; i++) {
    struct entry *e = get(keys[i]);
    if (e == 0) missing++;
  }
  printf("%d: %d keys missing\n", n, missing);
  return NULL;
}

int
main(int argc, char *argv[])
{
  pthread_t *tha;
  void *value;
  double t1, t0;


  if (argc < 2) {
    fprintf(stderr, "Usage: %s nthreads\n", argv[0]);
    exit(-1);
  }
  nthread = atoi(argv[1]);
  tha = malloc(sizeof(pthread_t) * nthread);
  srandom(0);
  assert(NKEYS % nthread == 0);
  for (int i = 0; i < NKEYS; i++) {
    keys[i] = random();
  }

  //initalize lock;
  for (int i = 0; i < NBUCKET; ++i) {
      pthread_mutex_init(&lock[i], NULL);
  }

  //
  // first the puts
  //
  t0 = now();
  for(int i = 0; i < nthread; i++) {
    assert(pthread_create(&tha[i], NULL, put_thread, (void *) (long) i) == 0);
  }
  for(int i = 0; i < nthread; i++) {
    assert(pthread_join(tha[i], &value) == 0);
  }
  t1 = now();

  printf("%d puts, %.3f seconds, %.0f puts/second\n",
         NKEYS, t1 - t0, NKEYS / (t1 - t0));

  //
  // now the gets
  //
  t0 = now();
  for(int i = 0; i < nthread; i++) {
    assert(pthread_create(&tha[i], NULL, get_thread, (void *) (long) i) == 0);
  }
  for(int i = 0; i < nthread; i++) {
    assert(pthread_join(tha[i], &value) == 0);
  }
  t1 = now();

  printf("%d gets, %.3f seconds, %.0f gets/second\n",
         NKEYS*nthread, t1 - t0, (NKEYS*nthread) / (t1 - t0));
}
```

测试，然后通过

## 3 barrier (moderate)

> 实际运用`thread_cond_t`，实现条件锁，当所有线程都运行该条件点的时候，重新激活所有线程。

查询`pthread_cond`文档，获得下面两个函数的用法：

- pthread_cond_wait：该函数会阻塞条件变量，并释放该线程拥有的锁，以便其他线程可以使用。如果要恢复，必须要线程来唤醒他。
- pthread_cond_signal或pthread_cond_broadcast：两个函数的作用都是解除被wait阻塞的线程（条件锁相同），并且恢复该线程拥有的锁。区别是，signal只是释放一个或者多个线程，而broadcast会释放全部线程。

了解了这两个函数的额作用之后，代码也非常好写，逻辑过程就不再赘述了，关键代码如下：

```c
static void
barrier()
{
  pthread_mutex_lock(&bstate.barrier_mutex);
  bstate.nthread++;
  if (bstate.nthread == nthread) {
      bstate.round++;
      bstate.nthread = 0;
      pthread_cond_broadcast(&bstate.barrier_cond);
  } else {
      pthread_cond_wait(&bstate.barrier_cond, &bstate.barrier_mutex);
  }
  pthread_mutex_unlock(&bstate.barrier_mutex);
}
```

测试通过。

## 4 END

时隔多天断断续续完成了这个实验，测试结果如下：

```
== Test uthread ==
$ make qemu-gdb
uthread: OK (4.7s)
== Test answers-thread.txt == answers-thread.txt: OK
== Test ph_safe == make[1]: Entering directory '/home/ubuntu/program/xv6-labs-2022'
gcc -o ph -g -O2 -DSOL_THREAD -DLAB_THREAD notxv6/ph.c -pthread
make[1]: Leaving directory '/home/ubuntu/program/xv6-labs-2022'
ph_safe: OK (16.2s)
== Test ph_fast == make[1]: Entering directory '/home/ubuntu/program/xv6-labs-2022'
make[1]: 'ph' is up to date.
make[1]: Leaving directory '/home/ubuntu/program/xv6-labs-2022'
ph_fast: OK (37.4s)
== Test barrier == make[1]: Entering directory '/home/ubuntu/program/xv6-labs-2022'
gcc -o barrier -g -O2 -DSOL_THREAD -DLAB_THREAD notxv6/barrier.c -pthread
make[1]: Leaving directory '/home/ubuntu/program/xv6-labs-2022'
barrier: OK (3.0s)
== Test time ==
time: OK
Score: 60/60
```



