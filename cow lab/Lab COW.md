# Lab Copy-on-Write

> 在实验初期的操作系统中，当一个进程想要创建一个子进程时，会将父进程的资源完完全全的复制一份，然后这些复制的资源不一定都会使用，导致内存的空间利用率降低。
>
> 本实验的目的是，让我们修改一些内核代码，使进程创建子进程的时候采用写时复制（copy on write）策略，这个策略允许父进程和子进程最初共享相同的页面来工作，这些共享页面被标记为写时复制，这意味着如果任何一个进程写入共享页面（如果这个页面之前是允许被写的情况下），那么就创建共享页面的副本。
>
> 下图为创建进程时，两个进程共享页面。
>
> ![1609221978-71449](https://raw.githubusercontent.com/YEWPO/picgoPictures/main/1609221978-71449.png?token=AVUO26PH66MBXROJ64VPM5LDMXFYS)
>
> 如果进程A想要读写页面Z，进程A就会得到一个Z页面的副本，然后在这个副本上写入。如果B也要写入Z页面的话，也会得到一个Z页面的副本（不同于A进程的副本）。
>
> ![1609222774-71449](https://raw.githubusercontent.com/YEWPO/picgoPictures/main/1609222774-71449.png?token=AVUO26KAPHEM3FRS5KRITMDDMXFVA)

这个实验比较复杂，我将这个实验分成4个部分实现，按照个人认为的难易（也不一定是难易，也算是实验的耦合）程度，按先后顺序分成下面4步。

- 实现引用计数（`kernel/kalloc.c`）
- 实现`copy-on-write`（`kernel/vm.c: uvmcopy()`）
- 实现对`scuase`为15(`store/AMO page fault`)的陷阱处理（`kernel/trap.c: usertrap()`）
- 对`kernel/vm.c: copyout()`的处理，以适应cow机制。

## 1 引用计数

引入cow机制之后，就会发现一个物理页面不再是只被一个进程使用了，也可能多个进程共享这个页面。为了统计有多少个进程在使用这个页面，以及如果这个页面引用计数为0的时候释放这个空间，将其添加至空闲链表。引用计数的引入在这里就很重要了，对于整个实验来讲，这一部分相对独立。

### 1.1 如何计数

在宏定义中定义了物理地址的最大值`PHYSTOP`，物理地址顶端，还是物理地址停止之处？（这得看是phy-stop 还是 phys-top）。每个物理页面的大小是PGSIZE = 4096。我们可以定义一个数组来储存这个页面被引用的次数，数组的大小为`PHYSTOP / PGSIZE`。

```C
//--------kernel/vm.c----------
uint refcount[PHYPGNUM];

//-------kernel/mmelayout.h------
#define PHYPGNUM (PHYSTOP / PGSIZE)
```

### 1.2 初始化

创建物理内存的时候会对这些物理内存进行初始化`kinit`，对每个页面调用一次`kfree`，如果我们要在`kfree`函数中对引用计数减一，并在减一之后判断是否要要释放的话，这时我们要将初始计数置为1，以便在`kfree`中减一后释放。

```C
void
freerange(void *pa_start, void *pa_end)
{
  char *p;
  p = (char*)PGROUNDUP((uint64)pa_start);
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE) {
    refcount[(uint64)p / PGSIZE] = 1; // set 1 for kfree dec 1
    kfree(p);
  }
}
```

### 1.3 分配

当分配空间的时候`kalloc`，我们将这个页面的计数置为1,（这个空间一定会用进程要的，不然分配他做什么）。

```C
void *
kalloc(void)
{
  struct run *r;

  acquire(&kmem.lock);
  r = kmem.freelist;
  if(r) {
    kmem.freelist = r->next;
    refcount[(uint64)r / PGSIZE] = 1; // set to 1
  }
  release(&kmem.lock);

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
  return (void*)r;
}
```

**NEED A LOCK**，不一定只有一个进程在访问这个函数，避免竞争。（初始化没有用锁是因为，只会有`init`进程才能初始化内存）。下列函数同样。

### 1.4 释放（计数减一）

当有进程不需要某个页面的时候，一般会先解除页表中的页面映射，然后调用`uvmfree`，然后就会调用`kfree`辣。笔者最开始认为`uvmunmap`函数也是必须要经过的函数，所以在这个函数里对计数减一，系统能跑证明这个有一定道理，并通过了`cowtest`测试，内核测试失败了，但也不一定是这个的原因，所以大家可以尝试，但是`kfree`函数是一定会经过的，网上普遍观点，所以我的第三版代码主要针对的是这个的问题。

但是后来想一想，`uvmunmap`是不是只针对用户页表的，内核就不用这个了？

综上，当调用`kfree`的时候，我们对计数减一，如果计数为0，我们才进行后续的释放空间的操作，否则我们就返回。

```C
void
kfree(void *pa)
{
    .....
    acquire(&kmem.lock);
    refcount[(uint64)pa / PGSIZE]--;
    if (refcount[(uint64)pa / PGSIZE] > 0) {
        release(&kmem.lock);
        return;
    }
    release(&kmem.lock);
    .....
}
```

### 1.5 计数累加

当我们fork一个进程的时候，我们会将子进程的页表页面映射到父进程的物理页面，该页面的引用次数增加，我们要调用计数增加函数，来增加这个页面的引用。

```C
void
refinc(void *pa)
{
  if ((uint64)pa % PGSIZE != 0) {
    panic("refinc");
  }

  acquire(&kmem.lock);
  refcount[(uint64)pa / PGSIZE]++;
  release(&kmem.lock);
}
```

## 2 Copy-on-Write

### 2.1 删除分配内存部分

cow机制已不需要分配内存，直到需要写的时候。我们要把原来分配内存的部分给删除掉。

### 2.2 标记只读

按照cow机制的描述，所有页面要标记位只读。

### 2.3 添加COW位

如果该页面**之前**被标记位可写的时候，擦除可写位，标记C位（表示这个页面使用COW机制）。我们可以在`RSW`（管理软件保留位）中设置一个C位。

![image-20221105120656664](https://raw.githubusercontent.com/YEWPO/picgoPictures/main/image-20221105120656664.png?token=AVUO26J4YFTEWIY5XY5IJQDDMXQZY)

```C
//------------kernel/risv.h------------------
#define PTE_C (1L << 8)
```

修改标记的方法不在此处赘述。（位运算）

### 2.4 修改PTE

对于父进程的PTE，我们可以用位运算修改flags位即可，没有必要调用解除映射和映射函数。

对于子进程的PTE，我们就需要用`mappages`函数进行映射了，映射完了之后不要忘记**增加这个物理页面的引用计数**。

### 2.5 修改后的代码

```C
int
uvmcopy(pagetable_t old, pagetable_t new, uint64 sz)
{
  pte_t *pte;
  uint64 pa, i;
  uint flags;

  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walk(old, i, 0)) == 0)
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);

      //--------------------------- change start ------------------------------
    if (flags & PTE_W) { // mask C tag , unmask W tag
      flags &= ~PTE_W;
      flags |= PTE_C;
    }

    flags |= PTE_R;  // make it read only

    *pte = PA2PTE(pa) | flags; // chage father process's flags

    mappages(new, i, PGSIZE, pa, flags);// map child's pages to the father process's physical pages
    refinc((void *)pa); // add count to physics page, important here!!!
      
      //---------------------- chage end -----------------------------------
  }
  return 0;
    
    // delete the err part for that we do not need to alloc a physical page here.
}
```

## 3 scause(kernel/trap.c)

当我们写好上述两部分代码后，我们尝试运行这个系统，会发现产生了`scause = oxf`的fault，查询scause表，0xf 的情况表示`store/AMO page fault`。

![image-20221105122032103](https://raw.githubusercontent.com/YEWPO/picgoPictures/main/image-20221105122032103.png?token=AVUO26NCYOJBBHQKIFPQ4ZDDMXSMY)

为什么会产生这种情况呢？原因是我们将进程的页面都标记为了只读，而进程有写的操作，很明显，这个操作是不被允许的，所以产生了这个错误，同时也可能会产生`scause = 0x2`的错误，出现了非法指令。

出现了`0xf`的错误不一定是不能写，也有可能这个页面会在要写入时进行复制操作，所以我们要在`trap.c`里处理这个错误。

我们不妨封装一个`cowpagefault(pagetable_t pagetable, void * va)`函数，传递两个参数，一个页表，一个虚拟地址，用来判断这个虚拟地址会不会触发cow机制。

### 3.1 触发COW机制检查

如果`scause == 0xf`，触发cow机制检查：

```C
if (r_scause() == 0xf) {
    if (cowpagefault(p->pagetable, r_stval()) != 0) {
        setkilled(p);
    }
}
```

如果这个虚拟地址不满足cow机制，则我们杀死这个进程。（比如，这个页面只读，无效，或者用户态不能访问）

### 3.2 检查PTE

通过`walk`函数在这个页表中找到这个虚拟地址va的PTE，并检查这个PTE是否存在，是否有效，是否用户可以访问，如果以上都不满足，则不满足cow机制。如果以上均满足，则检查是否有`PTE_C`位，如果该标记位设立，则满足cow机制。

### 3.3 分配并映射

首先，我们分配一个页面，如果分配失败，表示物理内存已经满了，则返回错误，同样导致杀死进程。如果分配成功，则将原来的物理页面的内容用`memmove`函数复制到新的物理页面上，**同时，使原来的物理页面的引用次数减一(kfree)**。修改PTE，使之映射到新的物理页面上。（此步骤也只需要修改PTE就好，没有必要调用相关PTE函数）。

### 3.4 代码实现

```C
int
cowpagefault(pagetable_t pagetable, uint64 va)
{
  pte_t *pte = walk(pagetable, va, 0);

  if (pte == 0) {
    return -1;
  }

  if ((*pte & PTE_V) == 0 || (*pte & PTE_U) == 0) {
    return -1;
  }

  if ((*pte & PTE_C) == 0) {
    return -1;
  }

  uint flags;
  uint64 pa0, pa1;

  flags = PTE_FLAGS(*pte);
  flags &= ~PTE_C;
  flags |= PTE_W;
  pa0 = PTE2PA(*pte);
  if ((pa1 = (uint64)kalloc()) == 0) {
    return -1;
  }

  memmove((void *)pa1, (void *)pa0, PGSIZE);

  kfree((void *)pa0);

  *pte = PA2PTE(pa1) | flags;

  return 0;
}
```

上述完成之后，应该可以通过两个simple测试，和三个three测试，但是file测试会失败，因为我们没有修改`copyout`函数使之适应cow机制。

## 4 copyout

之前的`copyout`函数直接将物理页面直接写到了用户的物理页面，没有考虑该页面是不是可写的。在这里，我们添加两条对虚拟地址的处理。

### 4.1 PTE检查

通过`walk`函数查找这个虚拟地址的PTE，首先检查这个PTE是否存在，如果不存在则返回错误。

如果该PTE没有写标记，我们检查满不满足cow机制，如果不满足，返回错误。

### 4.2 代码

```C
while (len > 0) {
    va0 = PGROUNDDOWN(dstva);
    
    // add code below
    pte_t  *pte = walk(pagetable, va0, 0);

    if (pte == 0) {
      return -1;
    }

    if ((*pte & PTE_W) == 0) {
      if (cowpagefault(pagetable, va0) != 0) {
        return -1;
      }
    }
    
    ......
}
```

到这一步，基本实现了cow机制，**别忘记将新写的函数在`kernel/defs.h`中声明**，编译运行`cowtest`，应该可以通过所有测试。

## 5 遗留问题

非常激动地通过了`cowtest`，但是遗憾`usertests`在`copyout`上就错了，产生了`scause = 0x2`的错误，并触发了panic(“walk”)，检查`walk`函数，发现虚拟地址超过了虚拟地址的最大值。（总有人想触碰虚拟地址的底线）

那么我们要在`copyout`中对虚拟地址进行检查，是否越界。在4.2的基础上添加以下代码：

```C
if (va0 >= MAXVA) {
    return -1;
}
```

此时测试`usertests`，哎呀，又寄在了`MAXVAplus`测试上，错误原因也是`painc("walk")`，通过自己在上个实验写的`backtrace`检查，发现错误是在`cowpagefault`中引起的，因为`cowpagefault`也没检查虚拟地址是否越界。在3.4的代码基础上加上以下代码：

```C
int
cowpagefault(pagetable_t pagetable, uint64 va)
{
  if (va >= MAXVA) {
    return -1;
  }
    ......
}
```

至此，也就通过了所有`usertests`，实验结束。

## 6 END

这个实验的代码，我写了三个版本，这个通过版本（借鉴了网上的普遍的思路）和我的思路有三点不同：（主语：我的代码）

- 没有对`cow`的缺页错误进行封装处理
- 对物理内存的引用计数没有考虑进程内核部分(KERNELBASE之下)，认为这些部分是不能修改的，只有系统进程结束时才释放空间。而且自己实现了引用计数增加，和引用计数减少的函数，并认为所有的释放内存的操作都会经过`uvmunmap`函数，所以在这个函数中使用了引用减少函数，而在`kfree`函数中仅考虑引用计数是否为0即可
- 没有处理虚拟地址不合法的情况

所以上述描述的不同地方，使我的代码仅通过了sample，three的两个测试点，第三个`kalloc`失败。如果我修改测试程序，让子进程多多`wait(0)`一下，就可以通过`cowtest`的所有测试，虽然不是很理解这个错误原因。但是`usertests`的`copyout`的测试就崩溃了，不知道是不是因为没有处理非法的虚拟地址。

下列是本题解描述的代码的测试结果。

```
== Test running cowtest == 
$ make qemu-gdb
(20.9s) 
== Test   simple == 
  simple: OK 
== Test   three == 
  three: OK 
== Test   file == 
  file: OK 
== Test usertests == 
$ make qemu-gdb
(166.3s) 
== Test   usertests: copyin == 
  usertests: copyin: OK 
== Test   usertests: copyout == 
  usertests: copyout: OK 
== Test   usertests: all tests == 
  usertests: all tests: OK 
== Test time == 
time: OK 
Score: 110/110
```

## 7 前两版错误原因分析

按照`6 END`中的三个解释，我再分成四个：

### 7.1 没有对cowpage错误封装

这个对实验的正确性影响不大

### 7.2 没有对KERNELBASE之下的空间进行引用计数

通过后面的测试，可以不对KERNELBASE地址之下进行引用计数，因为这些部分不和内核或者用户进程有关。

![image-20221107105130680](https://raw.githubusercontent.com/YEWPO/yewpoblogonlinePic/main/image-20221107105130680.png)

### 7.3 没在kfree里自减

**vital**

这个好像对实验的正确性影响巨大。我自己认为，任何空间释放，都会经过`uvmunmap`这一步，然而，事实并非如此，要理解具体经过了那些函数，可能要彻底理解这个操作系统的内核了。经过我多次尝试，只能在kfree里对引用计数自减，如果引用计数为0，则对该空间进行释放。

### 7.4 没有处理非法地址

这个没有处理是可以通过`cowtest`测试的，但是，不能通过`usertests`测试。因为存在访问了非法的虚拟地址。所以这个错误会影响内核的正确性。

