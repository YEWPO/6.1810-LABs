# Lab: mmap

> 难度：**hard**
>
> 由于本实验需要在其他程序代码中使用例如：`struct file, MAP_SHARE`等宏或者是结构体，**当出现相关报错时**，*请严格以以下顺序添加头文件至相关代码中*，**一定要按顺序**，原因请了解*链接*。
>
> ```c
> #include "fs.h"
> #include "sleeplock.h"
> #include "fcntl.h"
> #include "file.h"
> ```
>
> **整个实验采用的虚拟内存分配机制是：懒分配**，采用这种方式可以提高分配效率，并且可以映射一个实际大小大于物理空间的文件。

## 1 mmap & munmap

在`C programmmer's manual`中对`mmap & munmap`的描述如下：

```
mmap() creates a new mapping in the virtual address space of the calling process.  The starting address for the new mapping is specified in addr.  The length argument specifies
       the length of the mapping (which must be greater than 0).

       If addr is NULL, then the kernel chooses the (page-aligned) address at which to create the mapping; this is the most portable method of creating a new mapping.  If addr is  not
       NULL,  then the kernel takes it as a hint about where to place the mapping; on Linux, the kernel will pick a nearby page boundary (but always above or equal to the value speci‐
       fied by /proc/sys/vm/mmap_min_addr) and attempt to create the mapping there.  If another mapping already exists there, the kernel picks a new address that may or may not depend
       on the hint.  The address of the new mapping is returned as the result of the call.

       The contents of a file mapping (as opposed to an anonymous mapping; see MAP_ANONYMOUS below), are initialized using length bytes starting at offset offset in the file (or other
       object) referred to by the file descriptor fd.  offset must be a multiple of the page size as returned by sysconf(_SC_PAGE_SIZE).

       After the mmap() call has returned, the file descriptor, fd, can be closed immediately without invalidating the mapping.

       The prot argument describes the desired memory protection of the mapping (and must not conflict with the open mode of the file).  It is either PROT_NONE or the  bitwise  OR  of
       one or more of the following flags:

       PROT_EXEC  Pages may be executed.

       PROT_READ  Pages may be read.

       PROT_WRITE Pages may be written.

       PROT_NONE  Pages may not be accessed.

       The  flags  argument determines whether updates to the mapping are visible to other processes mapping the same region, and whether updates are carried through to the underlying
       file.  This behavior is determined by including exactly one of the following values in flags:

       MAP_SHARED
      Share this mapping.  Updates to the mapping are visible to other processes mapping the same region, and (in the case of file-backed mappings) are carried through to  the
              underlying file.  (To precisely control when updates are carried through to the underlying file requires the use of msync(2).)

       MAP_SHARED_VALIDATE (since Linux 4.15)
       This  flag  provides  the  same  behavior  as  MAP_SHARED  except  that  MAP_SHARED  mappings  ignore unknown flags in flags.  By contrast, when creating a mapping using
       MAP_SHARED_VALIDATE, the kernel verifies all passed flags are known and fails the mapping with the error EOPNOTSUPP for unknown flags.  This mapping  type  is  also  required to be able to use some mapping flags (e.g., MAP_SYNC).
       MAP_PRIVATE
       Create  a  private copy-on-write mapping.  Updates to the mapping are not visible to other processes mapping the same file, and are not carried through to the underlying file.  It is unspecified whether changes made to the file after the mmap() call are visible in the mapped region.

   Both MAP_SHARED and MAP_PRIVATE are described in POSIX.1-2001 and POSIX.1-2008.  MAP_SHARED_VALIDATE is a Linux extension.
   
   Memory mapped by mmap() is preserved across fork(2), with the same attributes.

       A file is mapped in multiples of the page size.  For a file that is not a multiple of the page size, the remaining memory is zeroed when mapped, and writes to that  region  are
       not  written  out  to the file.  The effect of changing the size of the underlying file of a mapping on the pages that correspond to added or removed regions of the file is un‐
       specified.

   munmap()
       The munmap() system call deletes the mappings for the specified address range, and causes further references to addresses within the range to  generate  invalid  memory  refer‐
       ences.  The region is also automatically unmapped when the process is terminated.  On the other hand, closing the file descriptor does not unmap the region.

       The  address  addr  must be a multiple of the page size (but length need not be).  All pages containing a part of the indicated range are unmapped, and subsequent references to
       these pages will generate SIGSEGV.  It is not an error if the indicated range does not contain any mapped pages.
```

根据手册描述，`mmap`有6个参数。第一个参数`addr`，表示希望映射的虚拟地址的起点，如果为0，表示希望系统调用分配一个可用空间；第2个参数`length`，表示希望分配的虚拟空间的字节大小；第三个参数`prot`，表示该虚拟空间希望拥有的操作权限（在本实验中，仅涉及`PROT_READ, PROT_WRITE or both`）；第4个参数`flag`，表示希望分配的虚拟空间的分配规则（在本实验中，仅涉及`MAP_SHARED, MAP_PRIVITE`）；第5个参数`fd`，表示一个文件描述符；第6个参数`offset`，表示希望映射的文件的起始位置偏移量（在本实验中，偏移量默认为0，表示从文件的起始位置开始映射）。

下面对两个`flag`参数的解释：

- MAP_SHARED：表示该映射的空间是共享的，如果该映射的空间中的数据发生变化，则当在解除映射的时候应当写回文件（使用`filewrite`函数）。当有两个进程同时映射这个文件的时候，可以为其分配不同物理空间。
- MAP_PRIVATE：表示这个映射的空间是私有的，**如果该空间的数据发生了变化，最后也不会写回文件，同时该空间的权限也不受限于原文件的使用权限**。

如果`mmap`分配成功，则返回这个空间的起始地址，如果失败，则返回-1。

对于`munmap`，该系统调用有两个参数。第一个参数`addr`，表示需要解除映射的虚拟地址的起始地址。第2个参数`length`，表示希望解除映射的空间的字节长度。如果解除映射成功，则返回0，失败返回-1。

## 2 添加系统调用

在用户层面，修改`user.pl & user.h`，增加两个系统调用的函数声明和两个系统调用的入口点。具体添加方法，参考`syscall`实验。

在内核层面，修改`syscall.c`，增加声明和入口点；修改`sysproc.c`，添加两个系统调用函数。初始返回值为-1，表示调用失败。具体添加方法，参考`syscall`实验。

**为了方便后面测试和调试，可以将`trap`实验中的`backtrace`部分添加至本实验。方便自己在程序出错时，追踪函数调用过程**。（附加使用：`$ addr2line -e kernel/kernel`）。

## 3 设计VMA结构

由于`mmap`要分配可用的虚拟内存空间，而且希望能够知道那些空间是可以用的。那我们可以设计一个`VMA`结构体，来保存已经分配的虚拟地址空间。在`6.s081 lecture 17`中，介绍了一些关于`vma`的设计。

### 3.1 VMA基本属性值

- addr：分配的虚拟空间的起始位置
- length：分配的虚拟空间的字节长度
- file：映射的文件
- prot：映射的空间权限
- flag：映射的规则

### 3.2 动态分配VMA

每次分配虚拟内存空间时，检查所有已经分配好的虚拟空间，以找到一个未被使用的虚拟内存空间。这个方式分配的虚拟地址不是固定的，随着分配次数的增加，会产生大量的外部碎片，维护难度比较大，所以我自己没有采用这个方式实现。

### 3.3 静态分配VMA

在分配一个新的进程的时候，我们就预分配16个可用的VMA空间，分配大小如下（实际上，测试代码最多也只是映射了大小为`4PGSIZE`的页面）。当有`mmap`需要分配一个虚拟内存空间的时候，我们查询这16个VMA块，找到一个未被使用，而且大小合适的。这种方式容易产生内部碎片，但是维护难度极低。所以我使用这个方式。

![figure 1](https://raw.githubusercontent.com/YEWPO/yewpoblogonlinePic/main/image-20221128153248485.png)

每一个块都有自己的大小，和自己的起始位置，所在这里，我们在`3.1`属性的基础上在添加了两个属性：

- pos：该虚拟空间的起始地址。其实每次`mmap`返回的地址一定是该块的pos值。
- size：表示该虚拟空间的默认大小，实际的分配大小可以小于等于该大小。

设计的结构体如下：

```C
struct vma {
  struct file *file;
  uint64 addr;
  uint64 pos;
  uint length;
  uint size;
  int prot;
  int flag;
};
```

并在`struct proc`中添加16个`vma`块（NVMA已在`kernel/parma.h`中定义，为16）：

```C
struct vma vma[NVMA];
```

### 3.4 初始化VMA

#### 3.4.1 用户可用的虚拟空间

首先了解一下[xv6 book](https://pdos.csail.mit.edu/6.828/2022/xv6/book-riscv-rev3.pdf)的用户进程的虚拟地址的分配：

![figure 2](https://raw.githubusercontent.com/YEWPO/yewpoblogonlinePic/main/image-20221128154730305.png)

可以得出，`trapfram`之下有一段可以使用的虚拟内存空间，我们不妨进行以下设计：

![figure 3](https://raw.githubusercontent.com/YEWPO/yewpoblogonlinePic/main/image-20221128155105155.png)

`VMA`具体分配如本文章的`figure 1`所示。

#### 3.4.2 预分配

我们定义`va`表示一个块的顶地址，比如初始时为`trapframe`的下端`VAMAX - 2 * PGSIZE`，当分配一个块的时候，将`va`的值减去要分配的块的大小，即得到了一个快的起始地址；并将该块的`size`属性修改为对应的大小。

初始化的代码如下（添加至`kernel/proc.c: allocproc()`）：

```c
...
  uint64 va = MAXVA - 2 * PGSIZE;
  for (int i = 0; i < 6; ++i) {
    va -= 2 * PGSIZE;
    p->vma[i].size = 2 * PGSIZE;
    p->vma[i].pos = va;
  }

  for (int i = 6; i < 10; ++i) {
    va -= 4 * PGSIZE;
    p->vma[i].size = 4 * PGSIZE;
    p->vma[i].pos = va;
  }

  for (int i = 10; i < 13; ++i) {
    va -= 8 * PGSIZE;
    p->vma[i].size = 8 * PGSIZE;
    p->vma[i].pos = va;
  }

  for (int i = 13; i < 15; ++i) {
    va -= 16 * PGSIZE;
    p->vma[i].size = 16 * PGSIZE;
    p->vma[i].pos = va;
  }

  for (int i = 15; i < 16; ++i) {
    va -= 32 * PGSIZE;
    p->vma[i].size = 32 * PGSIZE;
    p->vma[i].pos = va;
  }    
...
```

## 4 实现`sys_mmap`

> `sys_mmap`的实现相对比较简单和容易理解，大致实现过程如下：

### 4.1 获得系统调用参数

通过一系列`arg***`函数得到`mmap`的六个参数。具体做法也可以参考`syscall`实验。

### 4.2 检查权限

不同的映射规则所映射的页面权限可以不大一样。对于本实验来说，`NAP_SHARED`的映射页面的权限必须和原文件一样，如果不一样，则应该返回错误；对于`MAP_PRIVATE`来说，因为映射页面的数据不用写回，且对于其他进程不可见，所以该映射的页面可以和原文件的权限不一样。

### 4.3 搜索可用VMA

遍历整个VMA表，找到一个未被使用，且大小最为接近的VMA块。**如果分配成功，则增加对该文件的引用次数（`filedup`函数）**。

### 4.4 代码

```C
uint64
sys_mmap(void)
{
  uint64 addr;
  uint length;
  int prot;
  int flag;
  int fd;
  uint offset;

  argaddr(0, &addr);
  argint(1, (int*)&length);
  argint(2, &prot);
  argint(3, &flag);
  argint(4, &fd);
  argint(5, (int*)&offset);

  struct proc *p = myproc();
  struct file *file = p->ofile[fd];

  if (prot & PROT_READ) {
    if (!file->readable) {
      return -1;
    }
  }

  if (prot & PROT_WRITE) {
    if (!file->writable && flag != MAP_PRIVATE) {
      return -1;
    }
  }

  for (int i = 0; i < NVMA; ++i) {
    if (!p->vma[i].length && p->vma[i].size >= length) {
      p->vma[i].file = file;
      p->vma[i].addr = p->vma[i].pos;
      p->vma[i].length = length;
      p->vma[i].prot = prot;
      p->vma[i].flag = flag;
      filedup(file);
      return p->vma[i].addr;
    }
  }

  return -1;
}
```

## 5 系统异常`scause: 0xd`

当实现完上述代码之后，运行`mmaptest`测试，会得到`scause = 0xd`的错误。通过查询`risc-v`手册可得，`0xd`的错误表示`Load Page Fault`。产生这个错误的原因是分配虚拟内存时并没有对物理页面进行映射，所以读取页面是时会发生错误。

为了解决这个错误，我们引入了`vma page fault`的页面错误处理。

## 6 VMA page fault

当有页面错误时，会进入`usertrap`函数。（具体参考`trap`实验）通过判断`r_scause()`的值为`0xd`来截获这个错误。并进入自己设计的`vmapagefault()`函数中。具体可以仿照`cow`实验。

### 6.1 处理机制

- 检查虚拟地址是否在已经分配的`VMA`中。如果不在其中，则该错误不是`vma page fault`，返回错误码-1。
- 分配物理页面，如果分配错误，则返回错误码-1。**分配成功之后记得给该页面清零（memset），如果不清零，后果请自己尝试。（hint：`kernel/kalloc.c: kalloc()`RTFSC）**
- 读取文件数据到物理内存中。如果读取失败，释放物理内存，并返回错误码-1。（读取数据使用`readi`函数，该函数在`kernel/fs.c`中，具体用法，请`RTFSC`）。**使用该函数之前，要对`inode`节点上锁，读取完成之后要下锁。下锁请使用`iunlock`**，不要使用`iunlockput`，因为不涉及修改操作。
- 添加映射规则。使用`mappages`函数完成虚拟地址`va`到物理地址`pa`之间的映射。**除了要添加`prot`标记以外，还需标记`PTE_U`，表示用户可以访问这个页面**。如果映射错误，释放物理空间，返回错误码-1。
- 对于以上的所有错误，返回错误码之后杀死进程。

### 6.2 代码

`kernel/trap.c`中实现以下部分：

```C
int
vmapagefault(struct proc *p, uint64 va)
{
  int index;
  for (index = 0; index < NVMA; ++index) {
    if (p->vma[index].addr <= va && va < p->vma[index].addr + p->vma[index].length) {
      break;
    }
  }

  if (index >= 16) {
    printf("not vma\n");
    return -1;
  }

  uint64 pa;

  if ((pa = (uint64)kalloc()) == 0) {
    printf("kalloc failed\n");
    return -1;
  }

  memset((void*)pa, 0, PGSIZE);

  ilock(p->vma[index].file->ip);
  if (readi(p->vma[index].file->ip, 0, pa, va - p->vma[index].pos, PGSIZE) < 0) {
    kfree((void*)pa);
    iunlock(p->vma[index].file->ip);
    printf("readi failed\n");
    return -1;
  }
  iunlock(p->vma[index].file->ip);

  int perm = PTE_U | (p->vma[index].prot << 1);

  if (mappages(p->pagetable, va, PGSIZE, pa, perm) < 0) {
    kfree((void*)pa);
    printf("mapapges failed\n");
    return -1;
  }

  return 0;
}
```

实现了以上部分后，`mmaptest`可以测试到`munmap`，并因为错误结束测试。

## 7 实现`sys_munmap`

> `sys_munmap`实现会比`sys_mmap`稍显复杂一点，但也不算复杂，唯一要解决的问题是，不是所有页面都需要解除和**物理页面**的映射。

大致的实现过程如下：

### 7.1 获得系统调用参数

获取方式和`4.1`类似。

### 7.2 是否为VMA？

遍历整个VMA表，检查需要释放虚拟空间的起始地址是否属于`vma`，并获得`VMA`块的下标。如果不是`VMA`块，则返回错误码-1。

### 7.3 检查合法性

如果要释放的空间的范围超过了`VMA`块的范围，则返回错误码-1。

### 7.4 写回文件

如果该空间的映射规则是`MAP_SHARED`，则将该虚拟内存空间中的数据写回文件。写回文件使用`filewrite`函数，该函数的具体使用方法请`RTFSC`。

### 7.5 解除和物理内存之间的映射

检查释放的空间里的所有页面，获得每个页面的`pte`，检查该PTE是否有效。如果有效，则解除该页面和物理页面之间的映射关系。**并不可以直接解除整个页面的物理内存映射，因为可能某些页面的映射并不存在。**

### 7.6 修改VMA块属性

由于本实验解除的映射的块都是自下而上解除映射，所以，修改方式比较简单，并没有考虑比较复杂的情况。

对于属性地址`addr`，直接将该地址加上解除映射的大小。

对于属性映射大小`length`，直接将该值减去解除映射的大小。

如果已经解除完了整个块的映射，则**解除对文件的引用**，解除引用使用`fileclose()`函数。

### 7.7 代码

```C
uint64
sys_munmap(void)
{
  uint64 addr;
  uint length;

  argaddr(0, &addr);
  argint(1, (int*)&length);

  struct proc *p = myproc();

  int index;
  for (index = 0; index < NVMA; ++index) {
    if (p->vma[index].addr <= addr && addr < p->vma[index].addr + p->vma[index].length) {
      break;
    }
  }

  if (index >= 16) {
    return -1;
  }

  if (length > p->vma[index].length) {
    return -1;
  }

  if (p->vma[index].flag == MAP_SHARED) {
    filewrite(p->vma[index].file, addr, length);
  }

  uint64 va;
  for (va = addr; va < addr + length; va += PGSIZE) {
    pte_t *pte = walk(p->pagetable, va, 0);

    if (*pte & PTE_V) {
      uvmunmap(p->pagetable, va, 1, 0);
    }
  }

  p->vma[index].addr = addr + length;
  p->vma[index].length -= length;

  if (p->vma[index].length == 0) {
    fileclose(p->vma[index].file);
  }

  return 0;
}
```

实现以上代码之后，可通过`fork`之前的`mmaptest`测试。

## 8 完善`fork & exit`

### 8.1 fork

当一个进程新建一个子进程的时候，需要对`VMA`表进行复制（原因参考`1`中的手册内容），**如果有文件映射，则应该用`filedup`增加对该文件的引用**。

代码如下（`kernel/proc.c: fork()`）:

```C
fork()
{
    ...
  for (i = 0; i < NVMA; ++i) {
    np->vma[i] = p->vma[i];
    if (np->vma[i].length) {
      filedup(np->vma[i].file);
    }
  }
    ...
}
```

### 8.2 exit

当一个进程结束的时候，应当解除未及时解除映射的VMA，**并减少相关文件的引用**，过程类似`7.5`。

代码如下（`kernel/proc.c: exit()`）:

```C
exit()
{
    ...
    for (int i = 0; i < NVMA; ++i) {
    if (p->vma[i].length) {
      if (p->vma[i].flag == MAP_SHARED) {
        filewrite(p->vma[i].file, p->vma[i].addr, p->vma[i].length);
      }

      uint64 va;
      for (va = p->vma[i].addr; va < p->vma[i].addr + p->vma[i].length; va += PGSIZE) {
        pte_t *pte = walk(p->pagetable, va, 0);
        if (*pte & PTE_V) {
          uvmunmap(p->pagetable, va, 1, 0);
        }
      }

      fileclose(p->vma[i].file);
      p->vma[i].length = 0;
    }
  }
  ...
}
```

## 9 END

经过一天的努力，重构了一次代码，测试结果如下，至此，也完成了整个`6.1810 operation system course lab fall 2022`：

```
== Test   mmaptest: mmap f ==
  mmaptest: mmap f: OK
== Test   mmaptest: mmap private ==
  mmaptest: mmap private: OK
== Test   mmaptest: mmap read-only ==
  mmaptest: mmap read-only: OK
== Test   mmaptest: mmap read/write ==
  mmaptest: mmap read/write: OK
== Test   mmaptest: mmap dirty ==
  mmaptest: mmap dirty: OK
== Test   mmaptest: not-mapped unmap ==
  mmaptest: not-mapped unmap: OK
== Test   mmaptest: two files ==
  mmaptest: two files: OK
== Test   mmaptest: fork_test ==
  mmaptest: fork_test: OK
== Test usertests ==
$ make qemu-gdb
usertests: OK (222.1s)
== Test time ==
time: OK
Score: 140/140
```

