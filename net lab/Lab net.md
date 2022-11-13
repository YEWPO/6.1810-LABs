# Lab net

> 实现网卡驱动程序中的接受和发送部分
>
> 本实验的难度：hard，hard的原因主要是很大一部分时间用于读手册去了。

## 1 reading

> 本实验说明中要求阅读一下三份材料
>
> - 课程教材`xv6 book`第5章，有关设备中断，并介绍了`xv6`d的`uart`部分
> - 网络了解`IP, UDP, ARP`的相关知识，IP， UDP不用多说，ARP（address resolution protocol）是介于链路层和网络层的一个协议，利用本地缓存或者是广播查找目的ip的MAC地址。
> - 比较枯燥的[E1000 Software Developer’s Manual](https://pdos.csail.mit.edu/6.828/2022/readings/8254x_GBe_SDM.pdf)，中的`第2章，3.2节，3.3节，3.4节，4.1节（不包括子节），第13章，第14章`。
>   - 第2章是对于e1000的整体概述
>   - 3.2节是对`receive descriptor`以及`receive descriptor ring struct`的详细介绍
>   - 3.3节是对`transmit descriptor`的详细介绍
>   - 3.4节是对`transmit descriptor ring struct`的详细介绍
>   - 4.1节是对`PCI registers`的详细介绍
>   - 13章是对于`e1000 registers`的详细介绍
>   - 14章描述如何对设备初始化和重置，实验说明中表示阅读这一章有助于理解`e1000_init()`函数。

为了实现这个实验，还需要充分阅读实验说明和**hints**，你可能会发现按照hints的描述写代码就可以完成本实验了。

### 1.1 xv6 book

阅读第5章可能对本实验用处不到，但是有助于听该课程的网课。

### 1.2 e1000 Software Developer’s Manual

我比较详细的阅读完了实验要求的第3章的内容，该部分对实验代码的理解非常大，尤其是代码中的宏。其他要求部分可以略读。

#### 1.2.1 receive descriptor(RDESC)

该结构的属性图如下

![image-20221113144114248](https://raw.githubusercontent.com/YEWPO/yewpoblogonlinePic/main/image-20221113144114248.png)

##### 1.2.1.1 buffer address

该属性描述了RAM中的一个地址，并且希望该设备使用DMA（DIRECT MEMORY ACCESS）机制，将接受到的数据包直接储存在该物理地址所在的位置上，一遍后续程序对其处理。

##### 1.2.1.2 length

该属性描述了接收到的数据包的内容长度。

##### 1.2.1.3 packet checksum（PCS）

数据包校验位，具体细节请查看手册，对于本实验用处不大。

##### 1.2.1.4 status

status具体位图如下：

![image-20221113144846041](https://raw.githubusercontent.com/YEWPO/yewpoblogonlinePic/main/image-20221113144846041.png)

PIF(pass in filter), IPCS(IP checksum), TCPCS(TCP/UDP checksum), RSV(RERSERVE保留位)，IXSM（ignore checksu)这些位对本实验作用不大，通过这些英文描述大致理解即可。

------

EOP（end of packet）该位一般在数据包最后一个描述符中设置，表示这是一个数据包的结束描述符。

DD（descriptor done）该位由硬件设置，表示这个描述符已经被硬件处理完成。

##### 1.2.1.5 error

该部分描述了一些错误，对于本实验影响不大，细节请查看手册。

##### 1.2.1.6 special

该部分位图如下：

![image-20221113145644352](https://raw.githubusercontent.com/YEWPO/yewpoblogonlinePic/main/image-20221113145644352.png)

PRI描述了用户的权限

CFI描述了VLAN的形式标准

VLAN描述了LAN ID

#### 1.2.2 receive descriptor queue structure(RX-RING)

##### 1.2.2.1 结构图

![image-20221113150148077](https://raw.githubusercontent.com/YEWPO/yewpoblogonlinePic/main/image-20221113150148077.png)

##### 1.2.2.2 相应的设备寄存器

- receive descriptor base address(RDBAL & RDBAH)：描述了这个环结构的起始地址。（因为有64位，所以分成了低位寄存器（L），和高位寄存器（H））
- receive descriptor length(RDLEN)：描述了这个环所分配的字节长度。
- receive descriptor head(RDH)：描述了设备能处理的部分的起始位置。
- receive descriptor tail(RDT)：描述了设备能处理的部分的末尾位置的下一个位置。（本实验程序并没有按照这个要求设置这个寄存器，**实验程序中，将该寄存器理解为：描述了设备能处理的部分的末尾位置**）

#### 1.2.3 transmit descriptor(TDESC)

该结构的属性图如下：（legacy）

![image-20221113151139919](https://raw.githubusercontent.com/YEWPO/yewpoblogonlinePic/main/image-20221113151139919.png)

##### 1.2.3.1 buffer address

该属性描述了希望设备处理并传输的数据包所在RAM地址。

##### 1.2.3.2 length

该属性描述了希望设备处理并传输的数据包的长度

##### 1.2.3.3 CSO（checksum offset）

校验位偏移量，对本实验无影响

##### 1.2.3.4 CMD

命令属性

相应位如下：

![image-20221113151740874](https://raw.githubusercontent.com/YEWPO/yewpoblogonlinePic/main/image-20221113151740874.png)

对于本实验，我们只需要理解RS和EOP两位。

RS（report status）：该位被设置以后，希望设备能及时反馈该描述符的状态。

EOP（end of packet）：该位被设置以后，表示该描述符是整个数据包的最后一个描述符。

其他位的详情请查看手册。

##### 1.2.3.5 STA

位图如下

![image-20221113153034533](https://raw.githubusercontent.com/YEWPO/yewpoblogonlinePic/main/image-20221113153034533.png)

RSV为保留位

LC,EC分别表示单冲突和多冲突（该实验不需要这两位）

DD同RDESC，表示设备已经处理好该描述符。

##### 1.2.3.6 RSV

保留位

##### 1.2.3.7 CSS

checksum start field校验位其实位置

##### 1.2.3.8 special

类似于RDESC的special，具体请查看手册，本实验无需该属性。

#### 1.2.4 transmit descriptor ring structure(TX-RING)

##### 1.2.4.1 结构图

![image-20221113153715848](https://raw.githubusercontent.com/YEWPO/yewpoblogonlinePic/main/image-20221113153715848.png)

##### 1.2.4.2 相应的寄存器

- transmit descriptor base address(TDBAL & TDBAH)：描述了该环的起始地址。
- transmit descriptor length(TDLEN)：描述了分配给该环的物理内存的字节长度，必须128位对齐。
- transmit descriptor head(TDH)：待设备处理的描述符的起始位置。
- transmit descriptor tail(TDT)：待设备处理的描述符的末尾位置的下一个位置。

以上就是这个参考材料对本实验非常关键的部分。

### 1.3 lab material & hints

该部分将该设备的工作原理从比较容易理解的方向进行介绍，hints基本手把手教你如何写出代码。阅读的主要问题就是英语水平不够。0.0

具体将在下面两个实现环节描述。

## 2 e1000_transmit(struct mbuf *m)

> 实现发送

实验代码为我们准备了两个环：`rx_ring, tx_ring`长度为16，且对应准备了`message buffer(mbuf)`；结构体都有在头文件中描述。

### 2.1 理解TX环

在环中头指针和尾指针包围的空间里表示带设备处理并且发送的描述符，而阴影部分是我们可以添加新的描述符的地方，所以我们应该在阴影部分处理。

### 2.2 实现过程

1. 我们通过TDT寄存器获得阴影部分的一个可以处理的位置（可能这个位置不是阴影位置，比如满环的情况）
2. 通过判断描述符的STA中的DD位来判断这个描述符可不可以用。如果没有设置，表示这个描述符设备没有处理完，然后返回错误码。
3. 如果DD被设置，表示该描述符已经被设备处理完了，则mbuf空间可以被释放，所以我们调用`mbuffree`函数释放这个空间。如果mbuf不存在，我们就不管他。
4. 将mbuf的addr指针指向新的要传输的mbuf的信息头（mbuf中的head属性），并将该描述符的length设置为该mbuf的length，再设置该描述符CMD属性中的RS和EOP位，表示需要设备及时反馈处理信息并且告知该描述符为一个数据包结束的描述符。
5. 将该mbuf地址保存在`rx_mbuf`中，以便后面对该空间进行释放。
6. 更新TDT寄存器指向当前位置。

### 2.3 锁问题

有可能多个进程同时要发送信息，所以这个函数需要一个锁。

### 2.4 代码

```C
int
e1000_transmit(struct mbuf *m)
{
  //
  // Your code here.
  //
  // the mbuf contains an ethernet frame; program it into
  // the TX descriptor ring so that the e1000 sends it. Stash
  // a pointer so that it can be freed after sending.
  //

  acquire(&e1000_lock);
  int index = regs[E1000_TDT];

  if (!(tx_ring[index].status & E1000_TXD_STAT_DD)) {
    release(&e1000_lock);
    return -1;
  }

  if (tx_mbufs[index]) {
    mbuffree(tx_mbufs[index]);
    tx_mbufs[index] = 0;
  }

  tx_ring[index].addr = (uint64)m->head;
  tx_ring[index].length = m->len;
  tx_ring[index].cmd = E1000_TXD_CMD_RS | E1000_TXD_CMD_EOP;
  tx_mbufs[index] = m;

  regs[E1000_TDT] = (index + 1) % TX_RING_SIZE;
  release(&e1000_lock);
  return 0;
}
```

## 3 e1000_recv()

> 实现接受，**该函数要检查所有接受到的数据包**，不同于transmit只处理一个包。

### 3.1 理解RX环

在头指针和尾指针（不同于手册的尾指针，见`1.2.2.2`）包围的区域，表示设备可以处理的部分。该处理理解为，将新收到的信息描述符写在该描述符上，所以这一部分区域应该是空的描述符，可以参考`e1000_init()`函数对该部分的分配。而阴影反而不是空闲的描述符，这些描述符是我们可以处理的，已经接受到的描述符。

### 3.2 实现过程

1. 通过RDT获得一个可以处理的描述符位置。（**因为该尾指针不同于手册中的尾指针，所以我们得到RDT后要加一再取长度的余数才是我们可能可以处理的描述符的位置**）为了能够处理所有可以处理的数据包，所以我们用一个死循环。
2. 通过检查描述符的STA中的DD为是否设置，我们可以判断该描述符是否可用，如果不可用就结束接受。
3. 如果这个描述符可用，我们把mbuf中length更新为接受到的描述符中的length，并将这个mbuf传递给网络栈（net_rx()）。
4. 分配新的mbuf（mbufalloc()）给这个描述符以便新的信息进入，并清除STA域。
5. 更新RDT，重复1

### 3.3 锁问题

设备处理是一个一个处理的，接受中断也是周期产生，所以不存在竞争问题。

### 3.4 代码

```C
static void
e1000_recv(void)
{
  //
  // Your code here.
  //
  // Check for packets that have arrived from the e1000
  // Create and deliver an mbuf for each packet (using net_rx()).
  //

  for (;;) {
    int index = regs[E1000_RDT];
    index = (index + 1) % RX_RING_SIZE;

    if (!(rx_ring[index].status & E1000_RXD_STAT_DD)) {
      break;
    }

    rx_mbufs[index]->len = rx_ring[index].length;
    net_rx(rx_mbufs[index]);

    rx_mbufs[index] = mbufalloc(0);
    rx_ring[index].addr = (uint64)rx_mbufs[index]->head;
    rx_ring[index].status = 0x00;

    regs[E1000_RDT] = index;
  }
}
```

## 4 END

自己按照hints实现了发送，但是因为英语水平不足，没能成功将接受部分的hints翻译成可运行代码，运行后没有地方下手进行调试，这一部分参考了一下博客才发现我有理解错误。

测试结果如下：

```
== Test running nettests ==
$ make qemu-gdb
(4.3s)
== Test   nettest: ping ==
  nettest: ping: OK
== Test   nettest: single process ==
  nettest: single process: OK
== Test   nettest: multi-process ==
  nettest: multi-process: OK
== Test   nettest: DNS ==
  nettest: DNS: OK
== Test time ==
time: OK
Score: 100/100
```