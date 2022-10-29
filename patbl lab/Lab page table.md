# Lab: page tables

## 1 speed up system calls (easy)

> 修改内核代码，实现对系统调用`getpid()`的性能加速。
>
> 题目提供的思路：在用户的虚拟内存上映射一个物理内存空间，该物理空间内容对用户程序仅能只读。将`pid`信息储存在该空间中，用户进程直接从该空间中读取。

### 1.1 分析hints

#### 1.1.1 前三条hints

前三条hints总结一句话，**分析`mappages`的功能。**`mappages`函数原型在`kernel/vm.c`中，该函数的注释如下：

```C
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
```

通过注释，函数将用户的页表中里建立虚拟地址va开始的连续大小为size的空间映射到物理内存地址Pa开始的连续大小为size的物理内存上，并将这部分空间的权限设置为perm。

#### 1.1.2 后两条hints

提醒您不要忘记分配和释放了！！但是这个提示有一点点的突兀，没深入理解前不知道在讲啥？

### 1.2 学习proc_pagetable(struct proc *p)

作为hints的第一条，这一条的实际价值在此时就成为了学习`proc_pagetable`对`mappages`函数的使用示例。我来描述一下下列例子。

```C
if(mappages(pagetable, TRAPFRAME, PGSIZE,
              (uint64)(p->trapframe), PTE_R | PTE_W) < 0){
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    uvmfree(pagetable, 0);
    return 0;
}
```

这个map的使用，就是在pagetable这个页表中建立从虚拟地址`TRAPFRAME`（已经在memlayout.h中声明）到物理内存地址`p->trapframe`的大小为`PGSIZE`的映射，且权限为`PTE_R | PTE_W`，表示用户可读可写。

**如果映射失败了，下面两步的操作分析也非常重要，后面的BUG就要用到这一点分析**

首先是`uvmumap`函数，查看函数原型的解释，该函数是解除在pagetable中的关于虚拟地址`TRAmpoline`的映射关系。影响的页面大小为1个PGSIZE，最后一个参数是表示要不要释放掉对应的物理内存，该位置于0的原因是，释放物理内存的操作在`uvmfree`函数中打包完成了。**这个函数有一个使用条件，就是要解除的映射关系要一定存在，那这个释放的`TRAMPOLINE`映射关系，是在创建`TRAPFRAME`映射之前就已经创建了，所以该映射一定存在，在此时也得解除这个映射关系。**

那`uvmfree`函数的功能就是清除pagetable这个页表里的信息。

------

分析到这一步的时候，你应该会想，虚拟地址`USYSCALL`已经告诉你了，但是物理内存地址捏？？？？

### 1.3 分配一个物理内存

当然也不能随便指定一个地址进行分配是吧，此时联想到`sys_trace`实验，自己在`proc`结构体中定义了一个`trace_s`来表示要追踪的syscall的码图。此时，我们可以创建一个指针表示用户态和内核态贡献的`usyscall`空间的起始地址。

此时，最后两条hints就有意义了，就是要分配这个空间和初始化这个空间，当进程结束的时候也就要释放这个空间。

在`kernel/kalloc.c`中的`kalloc()`可以实现物理内存的分配，每次分配大小，一个pgsize。

模仿已有代码，分配这个空间，并在该空间的起始位置赋值pid。

```C
if ((p->sharepage = (uint64)kalloc()) == 0) {
    freeproc(p);
    release(&p->lock);
    return 0;
}

((struct usyscall *)p->sharepage)->pid = p->pid;
```

### 1.4 建立映射关系

有了物理地址后，映射关系就好建立了。

```c
if (mappages(pagetable, USYSCALL, PGSIZE,
             p->sharepage, PTE_R | PTE_U) < 0) {
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    uvmunmap(pagetable, TRAPFRAME, 1, 0);
    uvmfree(pagetable, 0);
}
```

**如果映射失败了，一定要解除之前建立好的映射关系**

### 1.5 释放内存

模仿`freeproc`函数，释放自己定义的内存指针空间。

```C
if (p->sharepage) {
    kfree((void *)p->sharepage);
}
p->sharepage = 0;
```

### 1.6 先自信地完成这个小实验

希望越大失望越大，运行修改的内核代码后，发现系统启动不了了QAQ。

```
xv6 kernel is booting

hart 2 starting
hart 1 starting
panic: freewalk: leaf
```

寄

### 1.7 DEBUG

通过手动生成调试信息，发现既不是分配空间的问题，也不是映射关系的问题，可能是释放的问题。找找这个报错信息来源，发现是在`kernel/vm.c`的`freewalk`函数中，错误条件如下：

```C
if(pte & PTE_V){
    panic("freewalk: leaf");
}
```

意思是在释放这个页表的时候，存在有效的映射关系。这时候想想，也只有自己写的映射关系没有解除了。

在看看`freeproc`函数，发现这个函数调用了`proc_freepagetable`函数，再看看这个函数：

```C
void
proc_freepagetable(pagetable_t pagetable, uint64 sz)
{
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
  uvmfree(pagetable, sz);
}
```

果然，没有解除自己建立的`USYSCALL`的映射关系。添加这一行：

```C
uvmunmap(pagetable, USYSCALL, 1, 0);
```

再测试一下：OK！！！

### 1.8 Which other xv6 system call(s) could be made faster using this shared page? Explain how.

```
Candidate are:
    getpid()
    uptime()
    fstate()?
```

这些函数只需要获得信息即可，不需要修改信息，所以将这些信息放在共享内存中直接拿取即可。

## 2 Print a page table (easy)

> 编写一个函数实现打印页表信息

根据提示，修改`exec.c`代码，模仿`freewalk`函数，将其中的释放改写成打印相关信息即可，并在`kernel/defs.h`中声明这个函数。只用处理打印“..”即可。

### 2.1 代码实现

```C
void
vmprint(pagetable_t pagetable) {
    static int deep = 1;

    for(int i = 0; i < 512; i++){
        pte_t pte = pagetable[i];

        if (pte & PTE_V) {
            for (int j = 1; j < deep; ++j) {
                printf(".. ");
            }
        }

        if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
            printf("..%d: pte %p pa %p\n", i, pte, PTE2PA(pte));
            uint64 child = PTE2PA(pte);
            deep++;
            vmprint((pagetable_t)child);
            deep--;
        } else if(pte & PTE_V){
            printf("..%d: pte %p pa %p\n", i, pte, PTE2PA(pte));
        }
    }
}
```

### 2.2 题目问题

Explain the output of `vmprint` in terms of Fig 3-4 from the text. What does page 0 contain? What is in page 2? When running in user mode, could the process read/write the memory mapped by page 1? What does the third to last page contain?

------

通过对`exec`函数的分析，首先从内存中加载程序到第一个页表中，所以page 0 包含一个进程需要的信息；然后，`exec`函数在紧接着的页表中分配两页，page 1 是守护页面，page 2 是进程栈页面，该栈里存放程序运行时的变量。因为page 1是守护页面，用户不能访问。倒数三页分别是跳板页面，转储页面和用户和内存的共享页面。

```
ph.vaddr: 0x0000000000000000 ph.memsz: 0x0000000000001000
ph.vaddr: 0x0000000000001000 ph.memsz: 0x0000000000000030
page table 0x0000000087f6b000
..0: pte 0x0000000021fd9c01 pa 0x0000000087f67000
.. ..0: pte 0x0000000021fd9801 pa 0x0000000087f66000
.. .. ..0: pte 0x0000000021fda01b pa 0x0000000087f68000
.. .. ..1: pte 0x0000000021fd9417 pa 0x0000000087f65000
.. .. ..2: pte 0x0000000021fd9007 pa 0x0000000087f64000
.. .. ..3: pte 0x0000000021fd8c17 pa 0x0000000087f63000
..255: pte 0x0000000021fda801 pa 0x0000000087f6a000
.. ..511: pte 0x0000000021fda401 pa 0x0000000087f69000
.. .. ..509: pte 0x0000000021fdcc13 pa 0x0000000087f73000
.. .. ..510: pte 0x0000000021fdd007 pa 0x0000000087f74000
.. .. ..511: pte 0x0000000020001c0b pa 0x0000000080007000
init: starting sh
ph.vaddr: 0x0000000000000000 ph.memsz: 0x0000000000002000
ph.vaddr: 0x0000000000002000 ph.memsz: 0x0000000000000098
```

## 3 Detect which pages have been accessed (hard)

> 编写系统调佣函数`pgacess`，来追踪那些页面被使用过。
>
> pgacess调佣传递三个参数，第一个参数是要查询的页表的起始虚拟地址；第2个参数是要查询的页面的个数；第3个参数是用户空间的码图地址，该码图表示页面被使用的情况。

### 3.1 获得这三个参数

这三个参数分别存放在`trapframe`中的`a0，a1, a2`三个位置上，三个参数也分别使用`argaddr, argint, argaddr`函数得到。

```C
uint64 va;
int sz;
uint64 user_bitmask_addr;

argaddr(0, &va);
argint(1, &sz);
argaddr(2, &user_bitmask_addr);
```

由于表示的范围有限，所以我们要对查询的页面数有限制。因为int的数位有32位，所以我们限制最大的查询大小为32。

```C
if (sz > 32) {
    return -1;
}
```

### 3.2 分析walk函数

> walk函数的作用是通过虚拟地址，找到对应的页表中的额PTE。

xv6系统采用的是三级页表，虚拟地址中[38:30]是一级页表指针`satp`，或者理解为页表中对应的PTE的编号（从0到511），[29:21]是二级页表指针，[20:12]是三级页表指针。

```C
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
  if(va >= MAXVA)
    panic("walk");

  for(int level = 2; level > 0; level--) {
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
}
```

这个函数先传递一个进程的根页表，并由一级页表指针的指向获得一个PTE，即获得一个到下级页表的映射关系，此时页表更新为下级页表，在该页表用二级页表指针获取到下一级页表的映射关系。再重复一遍这个过程，就可以得到映射到物理内存的一个映射关系PTE，并且返回他的指针。

### 3.3 获取PTE_A位

在参考教材得到，PTE的flag的第7位（偏移6）为PTE_A，表示该PTE是否被使用过。我们在`kernel/risc.v`中声明这一位。

```C
#define PTE_A (1L << 6)
```

在代码中，用&位运算就可以提取出这一位，用^位运算就可以将这一位设置为0，如果这一位有值的话。

### 3.4 设置bitmask

从va开始，遍历大小为sz的页表，如果PTE的PTE_A位为1，则在bitmask中的改查询页表编号为置1，并将PTE_A置0，表示这个状态我们已经查询过了。

```C
for (int i = 0; i < sz; ++i) {
    pte_t * pte = walk(p->pagetable, va, 0);

    if ((*pte) & PTE_A) {
        bitmask |= (1 << i);
        (*pte) ^= PTE_A;
    }

    va += PGSIZE;
}
```

### 3.5 函数实现

最后将bitmask用`copyout`函数复制到用户空间上即可。

```C
int
sys_pgaccess(void)
{
  uint64 va;
  int sz;
  uint64 user_bitmask_addr;
  int bitmask = 0;
  struct proc * p = myproc();

  argaddr(0, &va);
  argint(1, &sz);
  argaddr(2, &user_bitmask_addr);

  if (sz > 32) {
      return -1;
  }

  for (int i = 0; i < sz; ++i) {
      pte_t * pte = walk(p->pagetable, va, 0);

      if ((*pte) & PTE_A) {
          bitmask |= (1 << i);
          (*pte) ^= PTE_A;
      }

      va += PGSIZE;
  }

  if (copyout(p->pagetable, user_bitmask_addr, (char *)&bitmask, sizeof(bitmask)) < 0) {
      return -1;
  }

  return 0;
}
```

编译测试，然后通过。

## 4 END

实验结束，测试的结果如下。

```
== Test pgtbltest == 
$ make qemu-gdb
(3.8s) 
== Test   pgtbltest: ugetpid == 
  pgtbltest: ugetpid: OK 
== Test   pgtbltest: pgaccess == 
  pgtbltest: pgaccess: OK 
== Test pte printout == 
$ make qemu-gdb
pte printout: OK (1.2s) 
== Test answers-pgtbl.txt == answers-pgtbl.txt: OK 
== Test usertests == 
$ make qemu-gdb
(208.4s) 
== Test   usertests: all tests == 
  usertests: all tests: OK
== Test time == 
time: OK 
Score: 46/46
```

