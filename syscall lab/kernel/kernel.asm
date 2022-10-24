
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	a8013103          	ld	sp,-1408(sp) # 80008a80 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	037050ef          	jal	ra,8000584c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    8000001c:	1101                	addi	sp,sp,-32
    8000001e:	ec06                	sd	ra,24(sp)
    80000020:	e822                	sd	s0,16(sp)
    80000022:	e426                	sd	s1,8(sp)
    80000024:	e04a                	sd	s2,0(sp)
    80000026:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000028:	03451793          	slli	a5,a0,0x34
    8000002c:	ebb9                	bnez	a5,80000082 <kfree+0x66>
    8000002e:	84aa                	mv	s1,a0
    80000030:	00022797          	auipc	a5,0x22
    80000034:	11078793          	addi	a5,a5,272 # 80022140 <end>
    80000038:	04f56563          	bltu	a0,a5,80000082 <kfree+0x66>
    8000003c:	47c5                	li	a5,17
    8000003e:	07ee                	slli	a5,a5,0x1b
    80000040:	04f57163          	bgeu	a0,a5,80000082 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000044:	6605                	lui	a2,0x1
    80000046:	4585                	li	a1,1
    80000048:	00000097          	auipc	ra,0x0
    8000004c:	154080e7          	jalr	340(ra) # 8000019c <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000050:	00009917          	auipc	s2,0x9
    80000054:	a8090913          	addi	s2,s2,-1408 # 80008ad0 <kmem>
    80000058:	854a                	mv	a0,s2
    8000005a:	00006097          	auipc	ra,0x6
    8000005e:	1f2080e7          	jalr	498(ra) # 8000624c <acquire>
  r->next = kmem.freelist;
    80000062:	01893783          	ld	a5,24(s2)
    80000066:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000068:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    8000006c:	854a                	mv	a0,s2
    8000006e:	00006097          	auipc	ra,0x6
    80000072:	292080e7          	jalr	658(ra) # 80006300 <release>
}
    80000076:	60e2                	ld	ra,24(sp)
    80000078:	6442                	ld	s0,16(sp)
    8000007a:	64a2                	ld	s1,8(sp)
    8000007c:	6902                	ld	s2,0(sp)
    8000007e:	6105                	addi	sp,sp,32
    80000080:	8082                	ret
    panic("kfree");
    80000082:	00008517          	auipc	a0,0x8
    80000086:	f8e50513          	addi	a0,a0,-114 # 80008010 <etext+0x10>
    8000008a:	00006097          	auipc	ra,0x6
    8000008e:	c78080e7          	jalr	-904(ra) # 80005d02 <panic>

0000000080000092 <freerange>:
{
    80000092:	7179                	addi	sp,sp,-48
    80000094:	f406                	sd	ra,40(sp)
    80000096:	f022                	sd	s0,32(sp)
    80000098:	ec26                	sd	s1,24(sp)
    8000009a:	e84a                	sd	s2,16(sp)
    8000009c:	e44e                	sd	s3,8(sp)
    8000009e:	e052                	sd	s4,0(sp)
    800000a0:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    800000a2:	6785                	lui	a5,0x1
    800000a4:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    800000a8:	94aa                	add	s1,s1,a0
    800000aa:	757d                	lui	a0,0xfffff
    800000ac:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800000ae:	94be                	add	s1,s1,a5
    800000b0:	0095ee63          	bltu	a1,s1,800000cc <freerange+0x3a>
    800000b4:	892e                	mv	s2,a1
    kfree(p);
    800000b6:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800000b8:	6985                	lui	s3,0x1
    kfree(p);
    800000ba:	01448533          	add	a0,s1,s4
    800000be:	00000097          	auipc	ra,0x0
    800000c2:	f5e080e7          	jalr	-162(ra) # 8000001c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800000c6:	94ce                	add	s1,s1,s3
    800000c8:	fe9979e3          	bgeu	s2,s1,800000ba <freerange+0x28>
}
    800000cc:	70a2                	ld	ra,40(sp)
    800000ce:	7402                	ld	s0,32(sp)
    800000d0:	64e2                	ld	s1,24(sp)
    800000d2:	6942                	ld	s2,16(sp)
    800000d4:	69a2                	ld	s3,8(sp)
    800000d6:	6a02                	ld	s4,0(sp)
    800000d8:	6145                	addi	sp,sp,48
    800000da:	8082                	ret

00000000800000dc <kinit>:
{
    800000dc:	1141                	addi	sp,sp,-16
    800000de:	e406                	sd	ra,8(sp)
    800000e0:	e022                	sd	s0,0(sp)
    800000e2:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    800000e4:	00008597          	auipc	a1,0x8
    800000e8:	f3458593          	addi	a1,a1,-204 # 80008018 <etext+0x18>
    800000ec:	00009517          	auipc	a0,0x9
    800000f0:	9e450513          	addi	a0,a0,-1564 # 80008ad0 <kmem>
    800000f4:	00006097          	auipc	ra,0x6
    800000f8:	0c8080e7          	jalr	200(ra) # 800061bc <initlock>
  freerange(end, (void*)PHYSTOP);
    800000fc:	45c5                	li	a1,17
    800000fe:	05ee                	slli	a1,a1,0x1b
    80000100:	00022517          	auipc	a0,0x22
    80000104:	04050513          	addi	a0,a0,64 # 80022140 <end>
    80000108:	00000097          	auipc	ra,0x0
    8000010c:	f8a080e7          	jalr	-118(ra) # 80000092 <freerange>
}
    80000110:	60a2                	ld	ra,8(sp)
    80000112:	6402                	ld	s0,0(sp)
    80000114:	0141                	addi	sp,sp,16
    80000116:	8082                	ret

0000000080000118 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000118:	1101                	addi	sp,sp,-32
    8000011a:	ec06                	sd	ra,24(sp)
    8000011c:	e822                	sd	s0,16(sp)
    8000011e:	e426                	sd	s1,8(sp)
    80000120:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000122:	00009497          	auipc	s1,0x9
    80000126:	9ae48493          	addi	s1,s1,-1618 # 80008ad0 <kmem>
    8000012a:	8526                	mv	a0,s1
    8000012c:	00006097          	auipc	ra,0x6
    80000130:	120080e7          	jalr	288(ra) # 8000624c <acquire>
  r = kmem.freelist;
    80000134:	6c84                	ld	s1,24(s1)
  if(r)
    80000136:	c885                	beqz	s1,80000166 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000138:	609c                	ld	a5,0(s1)
    8000013a:	00009517          	auipc	a0,0x9
    8000013e:	99650513          	addi	a0,a0,-1642 # 80008ad0 <kmem>
    80000142:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000144:	00006097          	auipc	ra,0x6
    80000148:	1bc080e7          	jalr	444(ra) # 80006300 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    8000014c:	6605                	lui	a2,0x1
    8000014e:	4595                	li	a1,5
    80000150:	8526                	mv	a0,s1
    80000152:	00000097          	auipc	ra,0x0
    80000156:	04a080e7          	jalr	74(ra) # 8000019c <memset>
  return (void*)r;
}
    8000015a:	8526                	mv	a0,s1
    8000015c:	60e2                	ld	ra,24(sp)
    8000015e:	6442                	ld	s0,16(sp)
    80000160:	64a2                	ld	s1,8(sp)
    80000162:	6105                	addi	sp,sp,32
    80000164:	8082                	ret
  release(&kmem.lock);
    80000166:	00009517          	auipc	a0,0x9
    8000016a:	96a50513          	addi	a0,a0,-1686 # 80008ad0 <kmem>
    8000016e:	00006097          	auipc	ra,0x6
    80000172:	192080e7          	jalr	402(ra) # 80006300 <release>
  if(r)
    80000176:	b7d5                	j	8000015a <kalloc+0x42>

0000000080000178 <freesize>:

uint64
freesize(void)
{
    80000178:	1141                	addi	sp,sp,-16
    8000017a:	e422                	sd	s0,8(sp)
    8000017c:	0800                	addi	s0,sp,16
  uint64 count = 0;

  struct run *r;

  r = kmem.freelist;
    8000017e:	00009797          	auipc	a5,0x9
    80000182:	96a7b783          	ld	a5,-1686(a5) # 80008ae8 <kmem+0x18>

  while (r) {
    80000186:	cb89                	beqz	a5,80000198 <freesize+0x20>
  uint64 count = 0;
    80000188:	4501                	li	a0,0
    count += PGSIZE;
    8000018a:	6705                	lui	a4,0x1
    8000018c:	953a                	add	a0,a0,a4
    r = r->next;
    8000018e:	639c                	ld	a5,0(a5)
  while (r) {
    80000190:	fff5                	bnez	a5,8000018c <freesize+0x14>
  }

  return count;
    80000192:	6422                	ld	s0,8(sp)
    80000194:	0141                	addi	sp,sp,16
    80000196:	8082                	ret
  uint64 count = 0;
    80000198:	4501                	li	a0,0
  return count;
    8000019a:	bfe5                	j	80000192 <freesize+0x1a>

000000008000019c <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    8000019c:	1141                	addi	sp,sp,-16
    8000019e:	e422                	sd	s0,8(sp)
    800001a0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    800001a2:	ce09                	beqz	a2,800001bc <memset+0x20>
    800001a4:	87aa                	mv	a5,a0
    800001a6:	fff6071b          	addiw	a4,a2,-1
    800001aa:	1702                	slli	a4,a4,0x20
    800001ac:	9301                	srli	a4,a4,0x20
    800001ae:	0705                	addi	a4,a4,1
    800001b0:	972a                	add	a4,a4,a0
    cdst[i] = c;
    800001b2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    800001b6:	0785                	addi	a5,a5,1
    800001b8:	fee79de3          	bne	a5,a4,800001b2 <memset+0x16>
  }
  return dst;
}
    800001bc:	6422                	ld	s0,8(sp)
    800001be:	0141                	addi	sp,sp,16
    800001c0:	8082                	ret

00000000800001c2 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    800001c2:	1141                	addi	sp,sp,-16
    800001c4:	e422                	sd	s0,8(sp)
    800001c6:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    800001c8:	ca05                	beqz	a2,800001f8 <memcmp+0x36>
    800001ca:	fff6069b          	addiw	a3,a2,-1
    800001ce:	1682                	slli	a3,a3,0x20
    800001d0:	9281                	srli	a3,a3,0x20
    800001d2:	0685                	addi	a3,a3,1
    800001d4:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    800001d6:	00054783          	lbu	a5,0(a0)
    800001da:	0005c703          	lbu	a4,0(a1)
    800001de:	00e79863          	bne	a5,a4,800001ee <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    800001e2:	0505                	addi	a0,a0,1
    800001e4:	0585                	addi	a1,a1,1
  while(n-- > 0){
    800001e6:	fed518e3          	bne	a0,a3,800001d6 <memcmp+0x14>
  }

  return 0;
    800001ea:	4501                	li	a0,0
    800001ec:	a019                	j	800001f2 <memcmp+0x30>
      return *s1 - *s2;
    800001ee:	40e7853b          	subw	a0,a5,a4
}
    800001f2:	6422                	ld	s0,8(sp)
    800001f4:	0141                	addi	sp,sp,16
    800001f6:	8082                	ret
  return 0;
    800001f8:	4501                	li	a0,0
    800001fa:	bfe5                	j	800001f2 <memcmp+0x30>

00000000800001fc <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    800001fc:	1141                	addi	sp,sp,-16
    800001fe:	e422                	sd	s0,8(sp)
    80000200:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000202:	ca0d                	beqz	a2,80000234 <memmove+0x38>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000204:	00a5f963          	bgeu	a1,a0,80000216 <memmove+0x1a>
    80000208:	02061693          	slli	a3,a2,0x20
    8000020c:	9281                	srli	a3,a3,0x20
    8000020e:	00d58733          	add	a4,a1,a3
    80000212:	02e56463          	bltu	a0,a4,8000023a <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000216:	fff6079b          	addiw	a5,a2,-1
    8000021a:	1782                	slli	a5,a5,0x20
    8000021c:	9381                	srli	a5,a5,0x20
    8000021e:	0785                	addi	a5,a5,1
    80000220:	97ae                	add	a5,a5,a1
    80000222:	872a                	mv	a4,a0
      *d++ = *s++;
    80000224:	0585                	addi	a1,a1,1
    80000226:	0705                	addi	a4,a4,1
    80000228:	fff5c683          	lbu	a3,-1(a1)
    8000022c:	fed70fa3          	sb	a3,-1(a4) # fff <_entry-0x7ffff001>
    while(n-- > 0)
    80000230:	fef59ae3          	bne	a1,a5,80000224 <memmove+0x28>

  return dst;
}
    80000234:	6422                	ld	s0,8(sp)
    80000236:	0141                	addi	sp,sp,16
    80000238:	8082                	ret
    d += n;
    8000023a:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    8000023c:	fff6079b          	addiw	a5,a2,-1
    80000240:	1782                	slli	a5,a5,0x20
    80000242:	9381                	srli	a5,a5,0x20
    80000244:	fff7c793          	not	a5,a5
    80000248:	97ba                	add	a5,a5,a4
      *--d = *--s;
    8000024a:	177d                	addi	a4,a4,-1
    8000024c:	16fd                	addi	a3,a3,-1
    8000024e:	00074603          	lbu	a2,0(a4)
    80000252:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000256:	fef71ae3          	bne	a4,a5,8000024a <memmove+0x4e>
    8000025a:	bfe9                	j	80000234 <memmove+0x38>

000000008000025c <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    8000025c:	1141                	addi	sp,sp,-16
    8000025e:	e406                	sd	ra,8(sp)
    80000260:	e022                	sd	s0,0(sp)
    80000262:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000264:	00000097          	auipc	ra,0x0
    80000268:	f98080e7          	jalr	-104(ra) # 800001fc <memmove>
}
    8000026c:	60a2                	ld	ra,8(sp)
    8000026e:	6402                	ld	s0,0(sp)
    80000270:	0141                	addi	sp,sp,16
    80000272:	8082                	ret

0000000080000274 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000274:	1141                	addi	sp,sp,-16
    80000276:	e422                	sd	s0,8(sp)
    80000278:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    8000027a:	ce11                	beqz	a2,80000296 <strncmp+0x22>
    8000027c:	00054783          	lbu	a5,0(a0)
    80000280:	cf89                	beqz	a5,8000029a <strncmp+0x26>
    80000282:	0005c703          	lbu	a4,0(a1)
    80000286:	00f71a63          	bne	a4,a5,8000029a <strncmp+0x26>
    n--, p++, q++;
    8000028a:	367d                	addiw	a2,a2,-1
    8000028c:	0505                	addi	a0,a0,1
    8000028e:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000290:	f675                	bnez	a2,8000027c <strncmp+0x8>
  if(n == 0)
    return 0;
    80000292:	4501                	li	a0,0
    80000294:	a809                	j	800002a6 <strncmp+0x32>
    80000296:	4501                	li	a0,0
    80000298:	a039                	j	800002a6 <strncmp+0x32>
  if(n == 0)
    8000029a:	ca09                	beqz	a2,800002ac <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    8000029c:	00054503          	lbu	a0,0(a0)
    800002a0:	0005c783          	lbu	a5,0(a1)
    800002a4:	9d1d                	subw	a0,a0,a5
}
    800002a6:	6422                	ld	s0,8(sp)
    800002a8:	0141                	addi	sp,sp,16
    800002aa:	8082                	ret
    return 0;
    800002ac:	4501                	li	a0,0
    800002ae:	bfe5                	j	800002a6 <strncmp+0x32>

00000000800002b0 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    800002b0:	1141                	addi	sp,sp,-16
    800002b2:	e422                	sd	s0,8(sp)
    800002b4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    800002b6:	872a                	mv	a4,a0
    800002b8:	8832                	mv	a6,a2
    800002ba:	367d                	addiw	a2,a2,-1
    800002bc:	01005963          	blez	a6,800002ce <strncpy+0x1e>
    800002c0:	0705                	addi	a4,a4,1
    800002c2:	0005c783          	lbu	a5,0(a1)
    800002c6:	fef70fa3          	sb	a5,-1(a4)
    800002ca:	0585                	addi	a1,a1,1
    800002cc:	f7f5                	bnez	a5,800002b8 <strncpy+0x8>
    ;
  while(n-- > 0)
    800002ce:	00c05d63          	blez	a2,800002e8 <strncpy+0x38>
    800002d2:	86ba                	mv	a3,a4
    *s++ = 0;
    800002d4:	0685                	addi	a3,a3,1
    800002d6:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    800002da:	fff6c793          	not	a5,a3
    800002de:	9fb9                	addw	a5,a5,a4
    800002e0:	010787bb          	addw	a5,a5,a6
    800002e4:	fef048e3          	bgtz	a5,800002d4 <strncpy+0x24>
  return os;
}
    800002e8:	6422                	ld	s0,8(sp)
    800002ea:	0141                	addi	sp,sp,16
    800002ec:	8082                	ret

00000000800002ee <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    800002ee:	1141                	addi	sp,sp,-16
    800002f0:	e422                	sd	s0,8(sp)
    800002f2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    800002f4:	02c05363          	blez	a2,8000031a <safestrcpy+0x2c>
    800002f8:	fff6069b          	addiw	a3,a2,-1
    800002fc:	1682                	slli	a3,a3,0x20
    800002fe:	9281                	srli	a3,a3,0x20
    80000300:	96ae                	add	a3,a3,a1
    80000302:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000304:	00d58963          	beq	a1,a3,80000316 <safestrcpy+0x28>
    80000308:	0585                	addi	a1,a1,1
    8000030a:	0785                	addi	a5,a5,1
    8000030c:	fff5c703          	lbu	a4,-1(a1)
    80000310:	fee78fa3          	sb	a4,-1(a5)
    80000314:	fb65                	bnez	a4,80000304 <safestrcpy+0x16>
    ;
  *s = 0;
    80000316:	00078023          	sb	zero,0(a5)
  return os;
}
    8000031a:	6422                	ld	s0,8(sp)
    8000031c:	0141                	addi	sp,sp,16
    8000031e:	8082                	ret

0000000080000320 <strlen>:

int
strlen(const char *s)
{
    80000320:	1141                	addi	sp,sp,-16
    80000322:	e422                	sd	s0,8(sp)
    80000324:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000326:	00054783          	lbu	a5,0(a0)
    8000032a:	cf91                	beqz	a5,80000346 <strlen+0x26>
    8000032c:	0505                	addi	a0,a0,1
    8000032e:	87aa                	mv	a5,a0
    80000330:	4685                	li	a3,1
    80000332:	9e89                	subw	a3,a3,a0
    80000334:	00f6853b          	addw	a0,a3,a5
    80000338:	0785                	addi	a5,a5,1
    8000033a:	fff7c703          	lbu	a4,-1(a5)
    8000033e:	fb7d                	bnez	a4,80000334 <strlen+0x14>
    ;
  return n;
}
    80000340:	6422                	ld	s0,8(sp)
    80000342:	0141                	addi	sp,sp,16
    80000344:	8082                	ret
  for(n = 0; s[n]; n++)
    80000346:	4501                	li	a0,0
    80000348:	bfe5                	j	80000340 <strlen+0x20>

000000008000034a <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    8000034a:	1141                	addi	sp,sp,-16
    8000034c:	e406                	sd	ra,8(sp)
    8000034e:	e022                	sd	s0,0(sp)
    80000350:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000352:	00001097          	auipc	ra,0x1
    80000356:	afe080e7          	jalr	-1282(ra) # 80000e50 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    8000035a:	00008717          	auipc	a4,0x8
    8000035e:	74670713          	addi	a4,a4,1862 # 80008aa0 <started>
  if(cpuid() == 0){
    80000362:	c139                	beqz	a0,800003a8 <main+0x5e>
    while(started == 0)
    80000364:	431c                	lw	a5,0(a4)
    80000366:	2781                	sext.w	a5,a5
    80000368:	dff5                	beqz	a5,80000364 <main+0x1a>
      ;
    __sync_synchronize();
    8000036a:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    8000036e:	00001097          	auipc	ra,0x1
    80000372:	ae2080e7          	jalr	-1310(ra) # 80000e50 <cpuid>
    80000376:	85aa                	mv	a1,a0
    80000378:	00008517          	auipc	a0,0x8
    8000037c:	cc050513          	addi	a0,a0,-832 # 80008038 <etext+0x38>
    80000380:	00006097          	auipc	ra,0x6
    80000384:	9cc080e7          	jalr	-1588(ra) # 80005d4c <printf>
    kvminithart();    // turn on paging
    80000388:	00000097          	auipc	ra,0x0
    8000038c:	0d8080e7          	jalr	216(ra) # 80000460 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000390:	00001097          	auipc	ra,0x1
    80000394:	7ba080e7          	jalr	1978(ra) # 80001b4a <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000398:	00005097          	auipc	ra,0x5
    8000039c:	e08080e7          	jalr	-504(ra) # 800051a0 <plicinithart>
  }

  scheduler();        
    800003a0:	00001097          	auipc	ra,0x1
    800003a4:	fd6080e7          	jalr	-42(ra) # 80001376 <scheduler>
    consoleinit();
    800003a8:	00006097          	auipc	ra,0x6
    800003ac:	86c080e7          	jalr	-1940(ra) # 80005c14 <consoleinit>
    printfinit();
    800003b0:	00006097          	auipc	ra,0x6
    800003b4:	b82080e7          	jalr	-1150(ra) # 80005f32 <printfinit>
    printf("\n");
    800003b8:	00008517          	auipc	a0,0x8
    800003bc:	c9050513          	addi	a0,a0,-880 # 80008048 <etext+0x48>
    800003c0:	00006097          	auipc	ra,0x6
    800003c4:	98c080e7          	jalr	-1652(ra) # 80005d4c <printf>
    printf("xv6 kernel is booting\n");
    800003c8:	00008517          	auipc	a0,0x8
    800003cc:	c5850513          	addi	a0,a0,-936 # 80008020 <etext+0x20>
    800003d0:	00006097          	auipc	ra,0x6
    800003d4:	97c080e7          	jalr	-1668(ra) # 80005d4c <printf>
    printf("\n");
    800003d8:	00008517          	auipc	a0,0x8
    800003dc:	c7050513          	addi	a0,a0,-912 # 80008048 <etext+0x48>
    800003e0:	00006097          	auipc	ra,0x6
    800003e4:	96c080e7          	jalr	-1684(ra) # 80005d4c <printf>
    kinit();         // physical page allocator
    800003e8:	00000097          	auipc	ra,0x0
    800003ec:	cf4080e7          	jalr	-780(ra) # 800000dc <kinit>
    kvminit();       // create kernel page table
    800003f0:	00000097          	auipc	ra,0x0
    800003f4:	326080e7          	jalr	806(ra) # 80000716 <kvminit>
    kvminithart();   // turn on paging
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	068080e7          	jalr	104(ra) # 80000460 <kvminithart>
    procinit();      // process table
    80000400:	00001097          	auipc	ra,0x1
    80000404:	99c080e7          	jalr	-1636(ra) # 80000d9c <procinit>
    trapinit();      // trap vectors
    80000408:	00001097          	auipc	ra,0x1
    8000040c:	71a080e7          	jalr	1818(ra) # 80001b22 <trapinit>
    trapinithart();  // install kernel trap vector
    80000410:	00001097          	auipc	ra,0x1
    80000414:	73a080e7          	jalr	1850(ra) # 80001b4a <trapinithart>
    plicinit();      // set up interrupt controller
    80000418:	00005097          	auipc	ra,0x5
    8000041c:	d72080e7          	jalr	-654(ra) # 8000518a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000420:	00005097          	auipc	ra,0x5
    80000424:	d80080e7          	jalr	-640(ra) # 800051a0 <plicinithart>
    binit();         // buffer cache
    80000428:	00002097          	auipc	ra,0x2
    8000042c:	f38080e7          	jalr	-200(ra) # 80002360 <binit>
    iinit();         // inode table
    80000430:	00002097          	auipc	ra,0x2
    80000434:	5dc080e7          	jalr	1500(ra) # 80002a0c <iinit>
    fileinit();      // file table
    80000438:	00003097          	auipc	ra,0x3
    8000043c:	57a080e7          	jalr	1402(ra) # 800039b2 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000440:	00005097          	auipc	ra,0x5
    80000444:	e68080e7          	jalr	-408(ra) # 800052a8 <virtio_disk_init>
    userinit();      // first user process
    80000448:	00001097          	auipc	ra,0x1
    8000044c:	d0c080e7          	jalr	-756(ra) # 80001154 <userinit>
    __sync_synchronize();
    80000450:	0ff0000f          	fence
    started = 1;
    80000454:	4785                	li	a5,1
    80000456:	00008717          	auipc	a4,0x8
    8000045a:	64f72523          	sw	a5,1610(a4) # 80008aa0 <started>
    8000045e:	b789                	j	800003a0 <main+0x56>

0000000080000460 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000460:	1141                	addi	sp,sp,-16
    80000462:	e422                	sd	s0,8(sp)
    80000464:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000466:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    8000046a:	00008797          	auipc	a5,0x8
    8000046e:	63e7b783          	ld	a5,1598(a5) # 80008aa8 <kernel_pagetable>
    80000472:	83b1                	srli	a5,a5,0xc
    80000474:	577d                	li	a4,-1
    80000476:	177e                	slli	a4,a4,0x3f
    80000478:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    8000047a:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    8000047e:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000482:	6422                	ld	s0,8(sp)
    80000484:	0141                	addi	sp,sp,16
    80000486:	8082                	ret

0000000080000488 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000488:	7139                	addi	sp,sp,-64
    8000048a:	fc06                	sd	ra,56(sp)
    8000048c:	f822                	sd	s0,48(sp)
    8000048e:	f426                	sd	s1,40(sp)
    80000490:	f04a                	sd	s2,32(sp)
    80000492:	ec4e                	sd	s3,24(sp)
    80000494:	e852                	sd	s4,16(sp)
    80000496:	e456                	sd	s5,8(sp)
    80000498:	e05a                	sd	s6,0(sp)
    8000049a:	0080                	addi	s0,sp,64
    8000049c:	84aa                	mv	s1,a0
    8000049e:	89ae                	mv	s3,a1
    800004a0:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    800004a2:	57fd                	li	a5,-1
    800004a4:	83e9                	srli	a5,a5,0x1a
    800004a6:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    800004a8:	4b31                	li	s6,12
  if(va >= MAXVA)
    800004aa:	04b7f263          	bgeu	a5,a1,800004ee <walk+0x66>
    panic("walk");
    800004ae:	00008517          	auipc	a0,0x8
    800004b2:	ba250513          	addi	a0,a0,-1118 # 80008050 <etext+0x50>
    800004b6:	00006097          	auipc	ra,0x6
    800004ba:	84c080e7          	jalr	-1972(ra) # 80005d02 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800004be:	060a8663          	beqz	s5,8000052a <walk+0xa2>
    800004c2:	00000097          	auipc	ra,0x0
    800004c6:	c56080e7          	jalr	-938(ra) # 80000118 <kalloc>
    800004ca:	84aa                	mv	s1,a0
    800004cc:	c529                	beqz	a0,80000516 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    800004ce:	6605                	lui	a2,0x1
    800004d0:	4581                	li	a1,0
    800004d2:	00000097          	auipc	ra,0x0
    800004d6:	cca080e7          	jalr	-822(ra) # 8000019c <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800004da:	00c4d793          	srli	a5,s1,0xc
    800004de:	07aa                	slli	a5,a5,0xa
    800004e0:	0017e793          	ori	a5,a5,1
    800004e4:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    800004e8:	3a5d                	addiw	s4,s4,-9
    800004ea:	036a0063          	beq	s4,s6,8000050a <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    800004ee:	0149d933          	srl	s2,s3,s4
    800004f2:	1ff97913          	andi	s2,s2,511
    800004f6:	090e                	slli	s2,s2,0x3
    800004f8:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800004fa:	00093483          	ld	s1,0(s2)
    800004fe:	0014f793          	andi	a5,s1,1
    80000502:	dfd5                	beqz	a5,800004be <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000504:	80a9                	srli	s1,s1,0xa
    80000506:	04b2                	slli	s1,s1,0xc
    80000508:	b7c5                	j	800004e8 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000050a:	00c9d513          	srli	a0,s3,0xc
    8000050e:	1ff57513          	andi	a0,a0,511
    80000512:	050e                	slli	a0,a0,0x3
    80000514:	9526                	add	a0,a0,s1
}
    80000516:	70e2                	ld	ra,56(sp)
    80000518:	7442                	ld	s0,48(sp)
    8000051a:	74a2                	ld	s1,40(sp)
    8000051c:	7902                	ld	s2,32(sp)
    8000051e:	69e2                	ld	s3,24(sp)
    80000520:	6a42                	ld	s4,16(sp)
    80000522:	6aa2                	ld	s5,8(sp)
    80000524:	6b02                	ld	s6,0(sp)
    80000526:	6121                	addi	sp,sp,64
    80000528:	8082                	ret
        return 0;
    8000052a:	4501                	li	a0,0
    8000052c:	b7ed                	j	80000516 <walk+0x8e>

000000008000052e <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000052e:	57fd                	li	a5,-1
    80000530:	83e9                	srli	a5,a5,0x1a
    80000532:	00b7f463          	bgeu	a5,a1,8000053a <walkaddr+0xc>
    return 0;
    80000536:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000538:	8082                	ret
{
    8000053a:	1141                	addi	sp,sp,-16
    8000053c:	e406                	sd	ra,8(sp)
    8000053e:	e022                	sd	s0,0(sp)
    80000540:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000542:	4601                	li	a2,0
    80000544:	00000097          	auipc	ra,0x0
    80000548:	f44080e7          	jalr	-188(ra) # 80000488 <walk>
  if(pte == 0)
    8000054c:	c105                	beqz	a0,8000056c <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000054e:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000550:	0117f693          	andi	a3,a5,17
    80000554:	4745                	li	a4,17
    return 0;
    80000556:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000558:	00e68663          	beq	a3,a4,80000564 <walkaddr+0x36>
}
    8000055c:	60a2                	ld	ra,8(sp)
    8000055e:	6402                	ld	s0,0(sp)
    80000560:	0141                	addi	sp,sp,16
    80000562:	8082                	ret
  pa = PTE2PA(*pte);
    80000564:	00a7d513          	srli	a0,a5,0xa
    80000568:	0532                	slli	a0,a0,0xc
  return pa;
    8000056a:	bfcd                	j	8000055c <walkaddr+0x2e>
    return 0;
    8000056c:	4501                	li	a0,0
    8000056e:	b7fd                	j	8000055c <walkaddr+0x2e>

0000000080000570 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80000570:	715d                	addi	sp,sp,-80
    80000572:	e486                	sd	ra,72(sp)
    80000574:	e0a2                	sd	s0,64(sp)
    80000576:	fc26                	sd	s1,56(sp)
    80000578:	f84a                	sd	s2,48(sp)
    8000057a:	f44e                	sd	s3,40(sp)
    8000057c:	f052                	sd	s4,32(sp)
    8000057e:	ec56                	sd	s5,24(sp)
    80000580:	e85a                	sd	s6,16(sp)
    80000582:	e45e                	sd	s7,8(sp)
    80000584:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    80000586:	c205                	beqz	a2,800005a6 <mappages+0x36>
    80000588:	8aaa                	mv	s5,a0
    8000058a:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    8000058c:	77fd                	lui	a5,0xfffff
    8000058e:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    80000592:	15fd                	addi	a1,a1,-1
    80000594:	00c589b3          	add	s3,a1,a2
    80000598:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    8000059c:	8952                	mv	s2,s4
    8000059e:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800005a2:	6b85                	lui	s7,0x1
    800005a4:	a015                	j	800005c8 <mappages+0x58>
    panic("mappages: size");
    800005a6:	00008517          	auipc	a0,0x8
    800005aa:	ab250513          	addi	a0,a0,-1358 # 80008058 <etext+0x58>
    800005ae:	00005097          	auipc	ra,0x5
    800005b2:	754080e7          	jalr	1876(ra) # 80005d02 <panic>
      panic("mappages: remap");
    800005b6:	00008517          	auipc	a0,0x8
    800005ba:	ab250513          	addi	a0,a0,-1358 # 80008068 <etext+0x68>
    800005be:	00005097          	auipc	ra,0x5
    800005c2:	744080e7          	jalr	1860(ra) # 80005d02 <panic>
    a += PGSIZE;
    800005c6:	995e                	add	s2,s2,s7
  for(;;){
    800005c8:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800005cc:	4605                	li	a2,1
    800005ce:	85ca                	mv	a1,s2
    800005d0:	8556                	mv	a0,s5
    800005d2:	00000097          	auipc	ra,0x0
    800005d6:	eb6080e7          	jalr	-330(ra) # 80000488 <walk>
    800005da:	cd19                	beqz	a0,800005f8 <mappages+0x88>
    if(*pte & PTE_V)
    800005dc:	611c                	ld	a5,0(a0)
    800005de:	8b85                	andi	a5,a5,1
    800005e0:	fbf9                	bnez	a5,800005b6 <mappages+0x46>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800005e2:	80b1                	srli	s1,s1,0xc
    800005e4:	04aa                	slli	s1,s1,0xa
    800005e6:	0164e4b3          	or	s1,s1,s6
    800005ea:	0014e493          	ori	s1,s1,1
    800005ee:	e104                	sd	s1,0(a0)
    if(a == last)
    800005f0:	fd391be3          	bne	s2,s3,800005c6 <mappages+0x56>
    pa += PGSIZE;
  }
  return 0;
    800005f4:	4501                	li	a0,0
    800005f6:	a011                	j	800005fa <mappages+0x8a>
      return -1;
    800005f8:	557d                	li	a0,-1
}
    800005fa:	60a6                	ld	ra,72(sp)
    800005fc:	6406                	ld	s0,64(sp)
    800005fe:	74e2                	ld	s1,56(sp)
    80000600:	7942                	ld	s2,48(sp)
    80000602:	79a2                	ld	s3,40(sp)
    80000604:	7a02                	ld	s4,32(sp)
    80000606:	6ae2                	ld	s5,24(sp)
    80000608:	6b42                	ld	s6,16(sp)
    8000060a:	6ba2                	ld	s7,8(sp)
    8000060c:	6161                	addi	sp,sp,80
    8000060e:	8082                	ret

0000000080000610 <kvmmap>:
{
    80000610:	1141                	addi	sp,sp,-16
    80000612:	e406                	sd	ra,8(sp)
    80000614:	e022                	sd	s0,0(sp)
    80000616:	0800                	addi	s0,sp,16
    80000618:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000061a:	86b2                	mv	a3,a2
    8000061c:	863e                	mv	a2,a5
    8000061e:	00000097          	auipc	ra,0x0
    80000622:	f52080e7          	jalr	-174(ra) # 80000570 <mappages>
    80000626:	e509                	bnez	a0,80000630 <kvmmap+0x20>
}
    80000628:	60a2                	ld	ra,8(sp)
    8000062a:	6402                	ld	s0,0(sp)
    8000062c:	0141                	addi	sp,sp,16
    8000062e:	8082                	ret
    panic("kvmmap");
    80000630:	00008517          	auipc	a0,0x8
    80000634:	a4850513          	addi	a0,a0,-1464 # 80008078 <etext+0x78>
    80000638:	00005097          	auipc	ra,0x5
    8000063c:	6ca080e7          	jalr	1738(ra) # 80005d02 <panic>

0000000080000640 <kvmmake>:
{
    80000640:	1101                	addi	sp,sp,-32
    80000642:	ec06                	sd	ra,24(sp)
    80000644:	e822                	sd	s0,16(sp)
    80000646:	e426                	sd	s1,8(sp)
    80000648:	e04a                	sd	s2,0(sp)
    8000064a:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000064c:	00000097          	auipc	ra,0x0
    80000650:	acc080e7          	jalr	-1332(ra) # 80000118 <kalloc>
    80000654:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80000656:	6605                	lui	a2,0x1
    80000658:	4581                	li	a1,0
    8000065a:	00000097          	auipc	ra,0x0
    8000065e:	b42080e7          	jalr	-1214(ra) # 8000019c <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80000662:	4719                	li	a4,6
    80000664:	6685                	lui	a3,0x1
    80000666:	10000637          	lui	a2,0x10000
    8000066a:	100005b7          	lui	a1,0x10000
    8000066e:	8526                	mv	a0,s1
    80000670:	00000097          	auipc	ra,0x0
    80000674:	fa0080e7          	jalr	-96(ra) # 80000610 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80000678:	4719                	li	a4,6
    8000067a:	6685                	lui	a3,0x1
    8000067c:	10001637          	lui	a2,0x10001
    80000680:	100015b7          	lui	a1,0x10001
    80000684:	8526                	mv	a0,s1
    80000686:	00000097          	auipc	ra,0x0
    8000068a:	f8a080e7          	jalr	-118(ra) # 80000610 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000068e:	4719                	li	a4,6
    80000690:	004006b7          	lui	a3,0x400
    80000694:	0c000637          	lui	a2,0xc000
    80000698:	0c0005b7          	lui	a1,0xc000
    8000069c:	8526                	mv	a0,s1
    8000069e:	00000097          	auipc	ra,0x0
    800006a2:	f72080e7          	jalr	-142(ra) # 80000610 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800006a6:	00008917          	auipc	s2,0x8
    800006aa:	95a90913          	addi	s2,s2,-1702 # 80008000 <etext>
    800006ae:	4729                	li	a4,10
    800006b0:	80008697          	auipc	a3,0x80008
    800006b4:	95068693          	addi	a3,a3,-1712 # 8000 <_entry-0x7fff8000>
    800006b8:	4605                	li	a2,1
    800006ba:	067e                	slli	a2,a2,0x1f
    800006bc:	85b2                	mv	a1,a2
    800006be:	8526                	mv	a0,s1
    800006c0:	00000097          	auipc	ra,0x0
    800006c4:	f50080e7          	jalr	-176(ra) # 80000610 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800006c8:	4719                	li	a4,6
    800006ca:	46c5                	li	a3,17
    800006cc:	06ee                	slli	a3,a3,0x1b
    800006ce:	412686b3          	sub	a3,a3,s2
    800006d2:	864a                	mv	a2,s2
    800006d4:	85ca                	mv	a1,s2
    800006d6:	8526                	mv	a0,s1
    800006d8:	00000097          	auipc	ra,0x0
    800006dc:	f38080e7          	jalr	-200(ra) # 80000610 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800006e0:	4729                	li	a4,10
    800006e2:	6685                	lui	a3,0x1
    800006e4:	00007617          	auipc	a2,0x7
    800006e8:	91c60613          	addi	a2,a2,-1764 # 80007000 <_trampoline>
    800006ec:	040005b7          	lui	a1,0x4000
    800006f0:	15fd                	addi	a1,a1,-1
    800006f2:	05b2                	slli	a1,a1,0xc
    800006f4:	8526                	mv	a0,s1
    800006f6:	00000097          	auipc	ra,0x0
    800006fa:	f1a080e7          	jalr	-230(ra) # 80000610 <kvmmap>
  proc_mapstacks(kpgtbl);
    800006fe:	8526                	mv	a0,s1
    80000700:	00000097          	auipc	ra,0x0
    80000704:	606080e7          	jalr	1542(ra) # 80000d06 <proc_mapstacks>
}
    80000708:	8526                	mv	a0,s1
    8000070a:	60e2                	ld	ra,24(sp)
    8000070c:	6442                	ld	s0,16(sp)
    8000070e:	64a2                	ld	s1,8(sp)
    80000710:	6902                	ld	s2,0(sp)
    80000712:	6105                	addi	sp,sp,32
    80000714:	8082                	ret

0000000080000716 <kvminit>:
{
    80000716:	1141                	addi	sp,sp,-16
    80000718:	e406                	sd	ra,8(sp)
    8000071a:	e022                	sd	s0,0(sp)
    8000071c:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000071e:	00000097          	auipc	ra,0x0
    80000722:	f22080e7          	jalr	-222(ra) # 80000640 <kvmmake>
    80000726:	00008797          	auipc	a5,0x8
    8000072a:	38a7b123          	sd	a0,898(a5) # 80008aa8 <kernel_pagetable>
}
    8000072e:	60a2                	ld	ra,8(sp)
    80000730:	6402                	ld	s0,0(sp)
    80000732:	0141                	addi	sp,sp,16
    80000734:	8082                	ret

0000000080000736 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80000736:	715d                	addi	sp,sp,-80
    80000738:	e486                	sd	ra,72(sp)
    8000073a:	e0a2                	sd	s0,64(sp)
    8000073c:	fc26                	sd	s1,56(sp)
    8000073e:	f84a                	sd	s2,48(sp)
    80000740:	f44e                	sd	s3,40(sp)
    80000742:	f052                	sd	s4,32(sp)
    80000744:	ec56                	sd	s5,24(sp)
    80000746:	e85a                	sd	s6,16(sp)
    80000748:	e45e                	sd	s7,8(sp)
    8000074a:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000074c:	03459793          	slli	a5,a1,0x34
    80000750:	e795                	bnez	a5,8000077c <uvmunmap+0x46>
    80000752:	8a2a                	mv	s4,a0
    80000754:	892e                	mv	s2,a1
    80000756:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80000758:	0632                	slli	a2,a2,0xc
    8000075a:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000075e:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80000760:	6b05                	lui	s6,0x1
    80000762:	0735e863          	bltu	a1,s3,800007d2 <uvmunmap+0x9c>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80000766:	60a6                	ld	ra,72(sp)
    80000768:	6406                	ld	s0,64(sp)
    8000076a:	74e2                	ld	s1,56(sp)
    8000076c:	7942                	ld	s2,48(sp)
    8000076e:	79a2                	ld	s3,40(sp)
    80000770:	7a02                	ld	s4,32(sp)
    80000772:	6ae2                	ld	s5,24(sp)
    80000774:	6b42                	ld	s6,16(sp)
    80000776:	6ba2                	ld	s7,8(sp)
    80000778:	6161                	addi	sp,sp,80
    8000077a:	8082                	ret
    panic("uvmunmap: not aligned");
    8000077c:	00008517          	auipc	a0,0x8
    80000780:	90450513          	addi	a0,a0,-1788 # 80008080 <etext+0x80>
    80000784:	00005097          	auipc	ra,0x5
    80000788:	57e080e7          	jalr	1406(ra) # 80005d02 <panic>
      panic("uvmunmap: walk");
    8000078c:	00008517          	auipc	a0,0x8
    80000790:	90c50513          	addi	a0,a0,-1780 # 80008098 <etext+0x98>
    80000794:	00005097          	auipc	ra,0x5
    80000798:	56e080e7          	jalr	1390(ra) # 80005d02 <panic>
      panic("uvmunmap: not mapped");
    8000079c:	00008517          	auipc	a0,0x8
    800007a0:	90c50513          	addi	a0,a0,-1780 # 800080a8 <etext+0xa8>
    800007a4:	00005097          	auipc	ra,0x5
    800007a8:	55e080e7          	jalr	1374(ra) # 80005d02 <panic>
      panic("uvmunmap: not a leaf");
    800007ac:	00008517          	auipc	a0,0x8
    800007b0:	91450513          	addi	a0,a0,-1772 # 800080c0 <etext+0xc0>
    800007b4:	00005097          	auipc	ra,0x5
    800007b8:	54e080e7          	jalr	1358(ra) # 80005d02 <panic>
      uint64 pa = PTE2PA(*pte);
    800007bc:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800007be:	0532                	slli	a0,a0,0xc
    800007c0:	00000097          	auipc	ra,0x0
    800007c4:	85c080e7          	jalr	-1956(ra) # 8000001c <kfree>
    *pte = 0;
    800007c8:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800007cc:	995a                	add	s2,s2,s6
    800007ce:	f9397ce3          	bgeu	s2,s3,80000766 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800007d2:	4601                	li	a2,0
    800007d4:	85ca                	mv	a1,s2
    800007d6:	8552                	mv	a0,s4
    800007d8:	00000097          	auipc	ra,0x0
    800007dc:	cb0080e7          	jalr	-848(ra) # 80000488 <walk>
    800007e0:	84aa                	mv	s1,a0
    800007e2:	d54d                	beqz	a0,8000078c <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800007e4:	6108                	ld	a0,0(a0)
    800007e6:	00157793          	andi	a5,a0,1
    800007ea:	dbcd                	beqz	a5,8000079c <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    800007ec:	3ff57793          	andi	a5,a0,1023
    800007f0:	fb778ee3          	beq	a5,s7,800007ac <uvmunmap+0x76>
    if(do_free){
    800007f4:	fc0a8ae3          	beqz	s5,800007c8 <uvmunmap+0x92>
    800007f8:	b7d1                	j	800007bc <uvmunmap+0x86>

00000000800007fa <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800007fa:	1101                	addi	sp,sp,-32
    800007fc:	ec06                	sd	ra,24(sp)
    800007fe:	e822                	sd	s0,16(sp)
    80000800:	e426                	sd	s1,8(sp)
    80000802:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80000804:	00000097          	auipc	ra,0x0
    80000808:	914080e7          	jalr	-1772(ra) # 80000118 <kalloc>
    8000080c:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000080e:	c519                	beqz	a0,8000081c <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80000810:	6605                	lui	a2,0x1
    80000812:	4581                	li	a1,0
    80000814:	00000097          	auipc	ra,0x0
    80000818:	988080e7          	jalr	-1656(ra) # 8000019c <memset>
  return pagetable;
}
    8000081c:	8526                	mv	a0,s1
    8000081e:	60e2                	ld	ra,24(sp)
    80000820:	6442                	ld	s0,16(sp)
    80000822:	64a2                	ld	s1,8(sp)
    80000824:	6105                	addi	sp,sp,32
    80000826:	8082                	ret

0000000080000828 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80000828:	7179                	addi	sp,sp,-48
    8000082a:	f406                	sd	ra,40(sp)
    8000082c:	f022                	sd	s0,32(sp)
    8000082e:	ec26                	sd	s1,24(sp)
    80000830:	e84a                	sd	s2,16(sp)
    80000832:	e44e                	sd	s3,8(sp)
    80000834:	e052                	sd	s4,0(sp)
    80000836:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80000838:	6785                	lui	a5,0x1
    8000083a:	04f67863          	bgeu	a2,a5,8000088a <uvmfirst+0x62>
    8000083e:	8a2a                	mv	s4,a0
    80000840:	89ae                	mv	s3,a1
    80000842:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80000844:	00000097          	auipc	ra,0x0
    80000848:	8d4080e7          	jalr	-1836(ra) # 80000118 <kalloc>
    8000084c:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000084e:	6605                	lui	a2,0x1
    80000850:	4581                	li	a1,0
    80000852:	00000097          	auipc	ra,0x0
    80000856:	94a080e7          	jalr	-1718(ra) # 8000019c <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000085a:	4779                	li	a4,30
    8000085c:	86ca                	mv	a3,s2
    8000085e:	6605                	lui	a2,0x1
    80000860:	4581                	li	a1,0
    80000862:	8552                	mv	a0,s4
    80000864:	00000097          	auipc	ra,0x0
    80000868:	d0c080e7          	jalr	-756(ra) # 80000570 <mappages>
  memmove(mem, src, sz);
    8000086c:	8626                	mv	a2,s1
    8000086e:	85ce                	mv	a1,s3
    80000870:	854a                	mv	a0,s2
    80000872:	00000097          	auipc	ra,0x0
    80000876:	98a080e7          	jalr	-1654(ra) # 800001fc <memmove>
}
    8000087a:	70a2                	ld	ra,40(sp)
    8000087c:	7402                	ld	s0,32(sp)
    8000087e:	64e2                	ld	s1,24(sp)
    80000880:	6942                	ld	s2,16(sp)
    80000882:	69a2                	ld	s3,8(sp)
    80000884:	6a02                	ld	s4,0(sp)
    80000886:	6145                	addi	sp,sp,48
    80000888:	8082                	ret
    panic("uvmfirst: more than a page");
    8000088a:	00008517          	auipc	a0,0x8
    8000088e:	84e50513          	addi	a0,a0,-1970 # 800080d8 <etext+0xd8>
    80000892:	00005097          	auipc	ra,0x5
    80000896:	470080e7          	jalr	1136(ra) # 80005d02 <panic>

000000008000089a <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000089a:	1101                	addi	sp,sp,-32
    8000089c:	ec06                	sd	ra,24(sp)
    8000089e:	e822                	sd	s0,16(sp)
    800008a0:	e426                	sd	s1,8(sp)
    800008a2:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800008a4:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800008a6:	00b67d63          	bgeu	a2,a1,800008c0 <uvmdealloc+0x26>
    800008aa:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800008ac:	6785                	lui	a5,0x1
    800008ae:	17fd                	addi	a5,a5,-1
    800008b0:	00f60733          	add	a4,a2,a5
    800008b4:	767d                	lui	a2,0xfffff
    800008b6:	8f71                	and	a4,a4,a2
    800008b8:	97ae                	add	a5,a5,a1
    800008ba:	8ff1                	and	a5,a5,a2
    800008bc:	00f76863          	bltu	a4,a5,800008cc <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800008c0:	8526                	mv	a0,s1
    800008c2:	60e2                	ld	ra,24(sp)
    800008c4:	6442                	ld	s0,16(sp)
    800008c6:	64a2                	ld	s1,8(sp)
    800008c8:	6105                	addi	sp,sp,32
    800008ca:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800008cc:	8f99                	sub	a5,a5,a4
    800008ce:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800008d0:	4685                	li	a3,1
    800008d2:	0007861b          	sext.w	a2,a5
    800008d6:	85ba                	mv	a1,a4
    800008d8:	00000097          	auipc	ra,0x0
    800008dc:	e5e080e7          	jalr	-418(ra) # 80000736 <uvmunmap>
    800008e0:	b7c5                	j	800008c0 <uvmdealloc+0x26>

00000000800008e2 <uvmalloc>:
  if(newsz < oldsz)
    800008e2:	0ab66563          	bltu	a2,a1,8000098c <uvmalloc+0xaa>
{
    800008e6:	7139                	addi	sp,sp,-64
    800008e8:	fc06                	sd	ra,56(sp)
    800008ea:	f822                	sd	s0,48(sp)
    800008ec:	f426                	sd	s1,40(sp)
    800008ee:	f04a                	sd	s2,32(sp)
    800008f0:	ec4e                	sd	s3,24(sp)
    800008f2:	e852                	sd	s4,16(sp)
    800008f4:	e456                	sd	s5,8(sp)
    800008f6:	e05a                	sd	s6,0(sp)
    800008f8:	0080                	addi	s0,sp,64
    800008fa:	8aaa                	mv	s5,a0
    800008fc:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800008fe:	6985                	lui	s3,0x1
    80000900:	19fd                	addi	s3,s3,-1
    80000902:	95ce                	add	a1,a1,s3
    80000904:	79fd                	lui	s3,0xfffff
    80000906:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000090a:	08c9f363          	bgeu	s3,a2,80000990 <uvmalloc+0xae>
    8000090e:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80000910:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80000914:	00000097          	auipc	ra,0x0
    80000918:	804080e7          	jalr	-2044(ra) # 80000118 <kalloc>
    8000091c:	84aa                	mv	s1,a0
    if(mem == 0){
    8000091e:	c51d                	beqz	a0,8000094c <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    80000920:	6605                	lui	a2,0x1
    80000922:	4581                	li	a1,0
    80000924:	00000097          	auipc	ra,0x0
    80000928:	878080e7          	jalr	-1928(ra) # 8000019c <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000092c:	875a                	mv	a4,s6
    8000092e:	86a6                	mv	a3,s1
    80000930:	6605                	lui	a2,0x1
    80000932:	85ca                	mv	a1,s2
    80000934:	8556                	mv	a0,s5
    80000936:	00000097          	auipc	ra,0x0
    8000093a:	c3a080e7          	jalr	-966(ra) # 80000570 <mappages>
    8000093e:	e90d                	bnez	a0,80000970 <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80000940:	6785                	lui	a5,0x1
    80000942:	993e                	add	s2,s2,a5
    80000944:	fd4968e3          	bltu	s2,s4,80000914 <uvmalloc+0x32>
  return newsz;
    80000948:	8552                	mv	a0,s4
    8000094a:	a809                	j	8000095c <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    8000094c:	864e                	mv	a2,s3
    8000094e:	85ca                	mv	a1,s2
    80000950:	8556                	mv	a0,s5
    80000952:	00000097          	auipc	ra,0x0
    80000956:	f48080e7          	jalr	-184(ra) # 8000089a <uvmdealloc>
      return 0;
    8000095a:	4501                	li	a0,0
}
    8000095c:	70e2                	ld	ra,56(sp)
    8000095e:	7442                	ld	s0,48(sp)
    80000960:	74a2                	ld	s1,40(sp)
    80000962:	7902                	ld	s2,32(sp)
    80000964:	69e2                	ld	s3,24(sp)
    80000966:	6a42                	ld	s4,16(sp)
    80000968:	6aa2                	ld	s5,8(sp)
    8000096a:	6b02                	ld	s6,0(sp)
    8000096c:	6121                	addi	sp,sp,64
    8000096e:	8082                	ret
      kfree(mem);
    80000970:	8526                	mv	a0,s1
    80000972:	fffff097          	auipc	ra,0xfffff
    80000976:	6aa080e7          	jalr	1706(ra) # 8000001c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000097a:	864e                	mv	a2,s3
    8000097c:	85ca                	mv	a1,s2
    8000097e:	8556                	mv	a0,s5
    80000980:	00000097          	auipc	ra,0x0
    80000984:	f1a080e7          	jalr	-230(ra) # 8000089a <uvmdealloc>
      return 0;
    80000988:	4501                	li	a0,0
    8000098a:	bfc9                	j	8000095c <uvmalloc+0x7a>
    return oldsz;
    8000098c:	852e                	mv	a0,a1
}
    8000098e:	8082                	ret
  return newsz;
    80000990:	8532                	mv	a0,a2
    80000992:	b7e9                	j	8000095c <uvmalloc+0x7a>

0000000080000994 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80000994:	7179                	addi	sp,sp,-48
    80000996:	f406                	sd	ra,40(sp)
    80000998:	f022                	sd	s0,32(sp)
    8000099a:	ec26                	sd	s1,24(sp)
    8000099c:	e84a                	sd	s2,16(sp)
    8000099e:	e44e                	sd	s3,8(sp)
    800009a0:	e052                	sd	s4,0(sp)
    800009a2:	1800                	addi	s0,sp,48
    800009a4:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800009a6:	84aa                	mv	s1,a0
    800009a8:	6905                	lui	s2,0x1
    800009aa:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800009ac:	4985                	li	s3,1
    800009ae:	a821                	j	800009c6 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800009b0:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800009b2:	0532                	slli	a0,a0,0xc
    800009b4:	00000097          	auipc	ra,0x0
    800009b8:	fe0080e7          	jalr	-32(ra) # 80000994 <freewalk>
      pagetable[i] = 0;
    800009bc:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800009c0:	04a1                	addi	s1,s1,8
    800009c2:	03248163          	beq	s1,s2,800009e4 <freewalk+0x50>
    pte_t pte = pagetable[i];
    800009c6:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800009c8:	00f57793          	andi	a5,a0,15
    800009cc:	ff3782e3          	beq	a5,s3,800009b0 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800009d0:	8905                	andi	a0,a0,1
    800009d2:	d57d                	beqz	a0,800009c0 <freewalk+0x2c>
      panic("freewalk: leaf");
    800009d4:	00007517          	auipc	a0,0x7
    800009d8:	72450513          	addi	a0,a0,1828 # 800080f8 <etext+0xf8>
    800009dc:	00005097          	auipc	ra,0x5
    800009e0:	326080e7          	jalr	806(ra) # 80005d02 <panic>
    }
  }
  kfree((void*)pagetable);
    800009e4:	8552                	mv	a0,s4
    800009e6:	fffff097          	auipc	ra,0xfffff
    800009ea:	636080e7          	jalr	1590(ra) # 8000001c <kfree>
}
    800009ee:	70a2                	ld	ra,40(sp)
    800009f0:	7402                	ld	s0,32(sp)
    800009f2:	64e2                	ld	s1,24(sp)
    800009f4:	6942                	ld	s2,16(sp)
    800009f6:	69a2                	ld	s3,8(sp)
    800009f8:	6a02                	ld	s4,0(sp)
    800009fa:	6145                	addi	sp,sp,48
    800009fc:	8082                	ret

00000000800009fe <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800009fe:	1101                	addi	sp,sp,-32
    80000a00:	ec06                	sd	ra,24(sp)
    80000a02:	e822                	sd	s0,16(sp)
    80000a04:	e426                	sd	s1,8(sp)
    80000a06:	1000                	addi	s0,sp,32
    80000a08:	84aa                	mv	s1,a0
  if(sz > 0)
    80000a0a:	e999                	bnez	a1,80000a20 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80000a0c:	8526                	mv	a0,s1
    80000a0e:	00000097          	auipc	ra,0x0
    80000a12:	f86080e7          	jalr	-122(ra) # 80000994 <freewalk>
}
    80000a16:	60e2                	ld	ra,24(sp)
    80000a18:	6442                	ld	s0,16(sp)
    80000a1a:	64a2                	ld	s1,8(sp)
    80000a1c:	6105                	addi	sp,sp,32
    80000a1e:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80000a20:	6605                	lui	a2,0x1
    80000a22:	167d                	addi	a2,a2,-1
    80000a24:	962e                	add	a2,a2,a1
    80000a26:	4685                	li	a3,1
    80000a28:	8231                	srli	a2,a2,0xc
    80000a2a:	4581                	li	a1,0
    80000a2c:	00000097          	auipc	ra,0x0
    80000a30:	d0a080e7          	jalr	-758(ra) # 80000736 <uvmunmap>
    80000a34:	bfe1                	j	80000a0c <uvmfree+0xe>

0000000080000a36 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80000a36:	c679                	beqz	a2,80000b04 <uvmcopy+0xce>
{
    80000a38:	715d                	addi	sp,sp,-80
    80000a3a:	e486                	sd	ra,72(sp)
    80000a3c:	e0a2                	sd	s0,64(sp)
    80000a3e:	fc26                	sd	s1,56(sp)
    80000a40:	f84a                	sd	s2,48(sp)
    80000a42:	f44e                	sd	s3,40(sp)
    80000a44:	f052                	sd	s4,32(sp)
    80000a46:	ec56                	sd	s5,24(sp)
    80000a48:	e85a                	sd	s6,16(sp)
    80000a4a:	e45e                	sd	s7,8(sp)
    80000a4c:	0880                	addi	s0,sp,80
    80000a4e:	8b2a                	mv	s6,a0
    80000a50:	8aae                	mv	s5,a1
    80000a52:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80000a54:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80000a56:	4601                	li	a2,0
    80000a58:	85ce                	mv	a1,s3
    80000a5a:	855a                	mv	a0,s6
    80000a5c:	00000097          	auipc	ra,0x0
    80000a60:	a2c080e7          	jalr	-1492(ra) # 80000488 <walk>
    80000a64:	c531                	beqz	a0,80000ab0 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80000a66:	6118                	ld	a4,0(a0)
    80000a68:	00177793          	andi	a5,a4,1
    80000a6c:	cbb1                	beqz	a5,80000ac0 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80000a6e:	00a75593          	srli	a1,a4,0xa
    80000a72:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80000a76:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80000a7a:	fffff097          	auipc	ra,0xfffff
    80000a7e:	69e080e7          	jalr	1694(ra) # 80000118 <kalloc>
    80000a82:	892a                	mv	s2,a0
    80000a84:	c939                	beqz	a0,80000ada <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80000a86:	6605                	lui	a2,0x1
    80000a88:	85de                	mv	a1,s7
    80000a8a:	fffff097          	auipc	ra,0xfffff
    80000a8e:	772080e7          	jalr	1906(ra) # 800001fc <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80000a92:	8726                	mv	a4,s1
    80000a94:	86ca                	mv	a3,s2
    80000a96:	6605                	lui	a2,0x1
    80000a98:	85ce                	mv	a1,s3
    80000a9a:	8556                	mv	a0,s5
    80000a9c:	00000097          	auipc	ra,0x0
    80000aa0:	ad4080e7          	jalr	-1324(ra) # 80000570 <mappages>
    80000aa4:	e515                	bnez	a0,80000ad0 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    80000aa6:	6785                	lui	a5,0x1
    80000aa8:	99be                	add	s3,s3,a5
    80000aaa:	fb49e6e3          	bltu	s3,s4,80000a56 <uvmcopy+0x20>
    80000aae:	a081                	j	80000aee <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    80000ab0:	00007517          	auipc	a0,0x7
    80000ab4:	65850513          	addi	a0,a0,1624 # 80008108 <etext+0x108>
    80000ab8:	00005097          	auipc	ra,0x5
    80000abc:	24a080e7          	jalr	586(ra) # 80005d02 <panic>
      panic("uvmcopy: page not present");
    80000ac0:	00007517          	auipc	a0,0x7
    80000ac4:	66850513          	addi	a0,a0,1640 # 80008128 <etext+0x128>
    80000ac8:	00005097          	auipc	ra,0x5
    80000acc:	23a080e7          	jalr	570(ra) # 80005d02 <panic>
      kfree(mem);
    80000ad0:	854a                	mv	a0,s2
    80000ad2:	fffff097          	auipc	ra,0xfffff
    80000ad6:	54a080e7          	jalr	1354(ra) # 8000001c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80000ada:	4685                	li	a3,1
    80000adc:	00c9d613          	srli	a2,s3,0xc
    80000ae0:	4581                	li	a1,0
    80000ae2:	8556                	mv	a0,s5
    80000ae4:	00000097          	auipc	ra,0x0
    80000ae8:	c52080e7          	jalr	-942(ra) # 80000736 <uvmunmap>
  return -1;
    80000aec:	557d                	li	a0,-1
}
    80000aee:	60a6                	ld	ra,72(sp)
    80000af0:	6406                	ld	s0,64(sp)
    80000af2:	74e2                	ld	s1,56(sp)
    80000af4:	7942                	ld	s2,48(sp)
    80000af6:	79a2                	ld	s3,40(sp)
    80000af8:	7a02                	ld	s4,32(sp)
    80000afa:	6ae2                	ld	s5,24(sp)
    80000afc:	6b42                	ld	s6,16(sp)
    80000afe:	6ba2                	ld	s7,8(sp)
    80000b00:	6161                	addi	sp,sp,80
    80000b02:	8082                	ret
  return 0;
    80000b04:	4501                	li	a0,0
}
    80000b06:	8082                	ret

0000000080000b08 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80000b08:	1141                	addi	sp,sp,-16
    80000b0a:	e406                	sd	ra,8(sp)
    80000b0c:	e022                	sd	s0,0(sp)
    80000b0e:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80000b10:	4601                	li	a2,0
    80000b12:	00000097          	auipc	ra,0x0
    80000b16:	976080e7          	jalr	-1674(ra) # 80000488 <walk>
  if(pte == 0)
    80000b1a:	c901                	beqz	a0,80000b2a <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80000b1c:	611c                	ld	a5,0(a0)
    80000b1e:	9bbd                	andi	a5,a5,-17
    80000b20:	e11c                	sd	a5,0(a0)
}
    80000b22:	60a2                	ld	ra,8(sp)
    80000b24:	6402                	ld	s0,0(sp)
    80000b26:	0141                	addi	sp,sp,16
    80000b28:	8082                	ret
    panic("uvmclear");
    80000b2a:	00007517          	auipc	a0,0x7
    80000b2e:	61e50513          	addi	a0,a0,1566 # 80008148 <etext+0x148>
    80000b32:	00005097          	auipc	ra,0x5
    80000b36:	1d0080e7          	jalr	464(ra) # 80005d02 <panic>

0000000080000b3a <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80000b3a:	c6bd                	beqz	a3,80000ba8 <copyout+0x6e>
{
    80000b3c:	715d                	addi	sp,sp,-80
    80000b3e:	e486                	sd	ra,72(sp)
    80000b40:	e0a2                	sd	s0,64(sp)
    80000b42:	fc26                	sd	s1,56(sp)
    80000b44:	f84a                	sd	s2,48(sp)
    80000b46:	f44e                	sd	s3,40(sp)
    80000b48:	f052                	sd	s4,32(sp)
    80000b4a:	ec56                	sd	s5,24(sp)
    80000b4c:	e85a                	sd	s6,16(sp)
    80000b4e:	e45e                	sd	s7,8(sp)
    80000b50:	e062                	sd	s8,0(sp)
    80000b52:	0880                	addi	s0,sp,80
    80000b54:	8b2a                	mv	s6,a0
    80000b56:	8c2e                	mv	s8,a1
    80000b58:	8a32                	mv	s4,a2
    80000b5a:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80000b5c:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80000b5e:	6a85                	lui	s5,0x1
    80000b60:	a015                	j	80000b84 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80000b62:	9562                	add	a0,a0,s8
    80000b64:	0004861b          	sext.w	a2,s1
    80000b68:	85d2                	mv	a1,s4
    80000b6a:	41250533          	sub	a0,a0,s2
    80000b6e:	fffff097          	auipc	ra,0xfffff
    80000b72:	68e080e7          	jalr	1678(ra) # 800001fc <memmove>

    len -= n;
    80000b76:	409989b3          	sub	s3,s3,s1
    src += n;
    80000b7a:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80000b7c:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80000b80:	02098263          	beqz	s3,80000ba4 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80000b84:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80000b88:	85ca                	mv	a1,s2
    80000b8a:	855a                	mv	a0,s6
    80000b8c:	00000097          	auipc	ra,0x0
    80000b90:	9a2080e7          	jalr	-1630(ra) # 8000052e <walkaddr>
    if(pa0 == 0)
    80000b94:	cd01                	beqz	a0,80000bac <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80000b96:	418904b3          	sub	s1,s2,s8
    80000b9a:	94d6                	add	s1,s1,s5
    if(n > len)
    80000b9c:	fc99f3e3          	bgeu	s3,s1,80000b62 <copyout+0x28>
    80000ba0:	84ce                	mv	s1,s3
    80000ba2:	b7c1                	j	80000b62 <copyout+0x28>
  }
  return 0;
    80000ba4:	4501                	li	a0,0
    80000ba6:	a021                	j	80000bae <copyout+0x74>
    80000ba8:	4501                	li	a0,0
}
    80000baa:	8082                	ret
      return -1;
    80000bac:	557d                	li	a0,-1
}
    80000bae:	60a6                	ld	ra,72(sp)
    80000bb0:	6406                	ld	s0,64(sp)
    80000bb2:	74e2                	ld	s1,56(sp)
    80000bb4:	7942                	ld	s2,48(sp)
    80000bb6:	79a2                	ld	s3,40(sp)
    80000bb8:	7a02                	ld	s4,32(sp)
    80000bba:	6ae2                	ld	s5,24(sp)
    80000bbc:	6b42                	ld	s6,16(sp)
    80000bbe:	6ba2                	ld	s7,8(sp)
    80000bc0:	6c02                	ld	s8,0(sp)
    80000bc2:	6161                	addi	sp,sp,80
    80000bc4:	8082                	ret

0000000080000bc6 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80000bc6:	c6bd                	beqz	a3,80000c34 <copyin+0x6e>
{
    80000bc8:	715d                	addi	sp,sp,-80
    80000bca:	e486                	sd	ra,72(sp)
    80000bcc:	e0a2                	sd	s0,64(sp)
    80000bce:	fc26                	sd	s1,56(sp)
    80000bd0:	f84a                	sd	s2,48(sp)
    80000bd2:	f44e                	sd	s3,40(sp)
    80000bd4:	f052                	sd	s4,32(sp)
    80000bd6:	ec56                	sd	s5,24(sp)
    80000bd8:	e85a                	sd	s6,16(sp)
    80000bda:	e45e                	sd	s7,8(sp)
    80000bdc:	e062                	sd	s8,0(sp)
    80000bde:	0880                	addi	s0,sp,80
    80000be0:	8b2a                	mv	s6,a0
    80000be2:	8a2e                	mv	s4,a1
    80000be4:	8c32                	mv	s8,a2
    80000be6:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80000be8:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000bea:	6a85                	lui	s5,0x1
    80000bec:	a015                	j	80000c10 <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80000bee:	9562                	add	a0,a0,s8
    80000bf0:	0004861b          	sext.w	a2,s1
    80000bf4:	412505b3          	sub	a1,a0,s2
    80000bf8:	8552                	mv	a0,s4
    80000bfa:	fffff097          	auipc	ra,0xfffff
    80000bfe:	602080e7          	jalr	1538(ra) # 800001fc <memmove>

    len -= n;
    80000c02:	409989b3          	sub	s3,s3,s1
    dst += n;
    80000c06:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80000c08:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80000c0c:	02098263          	beqz	s3,80000c30 <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    80000c10:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80000c14:	85ca                	mv	a1,s2
    80000c16:	855a                	mv	a0,s6
    80000c18:	00000097          	auipc	ra,0x0
    80000c1c:	916080e7          	jalr	-1770(ra) # 8000052e <walkaddr>
    if(pa0 == 0)
    80000c20:	cd01                	beqz	a0,80000c38 <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    80000c22:	418904b3          	sub	s1,s2,s8
    80000c26:	94d6                	add	s1,s1,s5
    if(n > len)
    80000c28:	fc99f3e3          	bgeu	s3,s1,80000bee <copyin+0x28>
    80000c2c:	84ce                	mv	s1,s3
    80000c2e:	b7c1                	j	80000bee <copyin+0x28>
  }
  return 0;
    80000c30:	4501                	li	a0,0
    80000c32:	a021                	j	80000c3a <copyin+0x74>
    80000c34:	4501                	li	a0,0
}
    80000c36:	8082                	ret
      return -1;
    80000c38:	557d                	li	a0,-1
}
    80000c3a:	60a6                	ld	ra,72(sp)
    80000c3c:	6406                	ld	s0,64(sp)
    80000c3e:	74e2                	ld	s1,56(sp)
    80000c40:	7942                	ld	s2,48(sp)
    80000c42:	79a2                	ld	s3,40(sp)
    80000c44:	7a02                	ld	s4,32(sp)
    80000c46:	6ae2                	ld	s5,24(sp)
    80000c48:	6b42                	ld	s6,16(sp)
    80000c4a:	6ba2                	ld	s7,8(sp)
    80000c4c:	6c02                	ld	s8,0(sp)
    80000c4e:	6161                	addi	sp,sp,80
    80000c50:	8082                	ret

0000000080000c52 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80000c52:	c6c5                	beqz	a3,80000cfa <copyinstr+0xa8>
{
    80000c54:	715d                	addi	sp,sp,-80
    80000c56:	e486                	sd	ra,72(sp)
    80000c58:	e0a2                	sd	s0,64(sp)
    80000c5a:	fc26                	sd	s1,56(sp)
    80000c5c:	f84a                	sd	s2,48(sp)
    80000c5e:	f44e                	sd	s3,40(sp)
    80000c60:	f052                	sd	s4,32(sp)
    80000c62:	ec56                	sd	s5,24(sp)
    80000c64:	e85a                	sd	s6,16(sp)
    80000c66:	e45e                	sd	s7,8(sp)
    80000c68:	0880                	addi	s0,sp,80
    80000c6a:	8a2a                	mv	s4,a0
    80000c6c:	8b2e                	mv	s6,a1
    80000c6e:	8bb2                	mv	s7,a2
    80000c70:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80000c72:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000c74:	6985                	lui	s3,0x1
    80000c76:	a035                	j	80000ca2 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80000c78:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80000c7c:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80000c7e:	0017b793          	seqz	a5,a5
    80000c82:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80000c86:	60a6                	ld	ra,72(sp)
    80000c88:	6406                	ld	s0,64(sp)
    80000c8a:	74e2                	ld	s1,56(sp)
    80000c8c:	7942                	ld	s2,48(sp)
    80000c8e:	79a2                	ld	s3,40(sp)
    80000c90:	7a02                	ld	s4,32(sp)
    80000c92:	6ae2                	ld	s5,24(sp)
    80000c94:	6b42                	ld	s6,16(sp)
    80000c96:	6ba2                	ld	s7,8(sp)
    80000c98:	6161                	addi	sp,sp,80
    80000c9a:	8082                	ret
    srcva = va0 + PGSIZE;
    80000c9c:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80000ca0:	c8a9                	beqz	s1,80000cf2 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    80000ca2:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80000ca6:	85ca                	mv	a1,s2
    80000ca8:	8552                	mv	a0,s4
    80000caa:	00000097          	auipc	ra,0x0
    80000cae:	884080e7          	jalr	-1916(ra) # 8000052e <walkaddr>
    if(pa0 == 0)
    80000cb2:	c131                	beqz	a0,80000cf6 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80000cb4:	41790833          	sub	a6,s2,s7
    80000cb8:	984e                	add	a6,a6,s3
    if(n > max)
    80000cba:	0104f363          	bgeu	s1,a6,80000cc0 <copyinstr+0x6e>
    80000cbe:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80000cc0:	955e                	add	a0,a0,s7
    80000cc2:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80000cc6:	fc080be3          	beqz	a6,80000c9c <copyinstr+0x4a>
    80000cca:	985a                	add	a6,a6,s6
    80000ccc:	87da                	mv	a5,s6
      if(*p == '\0'){
    80000cce:	41650633          	sub	a2,a0,s6
    80000cd2:	14fd                	addi	s1,s1,-1
    80000cd4:	9b26                	add	s6,s6,s1
    80000cd6:	00f60733          	add	a4,a2,a5
    80000cda:	00074703          	lbu	a4,0(a4)
    80000cde:	df49                	beqz	a4,80000c78 <copyinstr+0x26>
        *dst = *p;
    80000ce0:	00e78023          	sb	a4,0(a5)
      --max;
    80000ce4:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80000ce8:	0785                	addi	a5,a5,1
    while(n > 0){
    80000cea:	ff0796e3          	bne	a5,a6,80000cd6 <copyinstr+0x84>
      dst++;
    80000cee:	8b42                	mv	s6,a6
    80000cf0:	b775                	j	80000c9c <copyinstr+0x4a>
    80000cf2:	4781                	li	a5,0
    80000cf4:	b769                	j	80000c7e <copyinstr+0x2c>
      return -1;
    80000cf6:	557d                	li	a0,-1
    80000cf8:	b779                	j	80000c86 <copyinstr+0x34>
  int got_null = 0;
    80000cfa:	4781                	li	a5,0
  if(got_null){
    80000cfc:	0017b793          	seqz	a5,a5
    80000d00:	40f00533          	neg	a0,a5
}
    80000d04:	8082                	ret

0000000080000d06 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80000d06:	7139                	addi	sp,sp,-64
    80000d08:	fc06                	sd	ra,56(sp)
    80000d0a:	f822                	sd	s0,48(sp)
    80000d0c:	f426                	sd	s1,40(sp)
    80000d0e:	f04a                	sd	s2,32(sp)
    80000d10:	ec4e                	sd	s3,24(sp)
    80000d12:	e852                	sd	s4,16(sp)
    80000d14:	e456                	sd	s5,8(sp)
    80000d16:	e05a                	sd	s6,0(sp)
    80000d18:	0080                	addi	s0,sp,64
    80000d1a:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80000d1c:	00008497          	auipc	s1,0x8
    80000d20:	20448493          	addi	s1,s1,516 # 80008f20 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80000d24:	8b26                	mv	s6,s1
    80000d26:	00007a97          	auipc	s5,0x7
    80000d2a:	2daa8a93          	addi	s5,s5,730 # 80008000 <etext>
    80000d2e:	04000937          	lui	s2,0x4000
    80000d32:	197d                	addi	s2,s2,-1
    80000d34:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000d36:	0000ea17          	auipc	s4,0xe
    80000d3a:	deaa0a13          	addi	s4,s4,-534 # 8000eb20 <tickslock>
    char *pa = kalloc();
    80000d3e:	fffff097          	auipc	ra,0xfffff
    80000d42:	3da080e7          	jalr	986(ra) # 80000118 <kalloc>
    80000d46:	862a                	mv	a2,a0
    if(pa == 0)
    80000d48:	c131                	beqz	a0,80000d8c <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80000d4a:	416485b3          	sub	a1,s1,s6
    80000d4e:	8591                	srai	a1,a1,0x4
    80000d50:	000ab783          	ld	a5,0(s5)
    80000d54:	02f585b3          	mul	a1,a1,a5
    80000d58:	2585                	addiw	a1,a1,1
    80000d5a:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80000d5e:	4719                	li	a4,6
    80000d60:	6685                	lui	a3,0x1
    80000d62:	40b905b3          	sub	a1,s2,a1
    80000d66:	854e                	mv	a0,s3
    80000d68:	00000097          	auipc	ra,0x0
    80000d6c:	8a8080e7          	jalr	-1880(ra) # 80000610 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000d70:	17048493          	addi	s1,s1,368
    80000d74:	fd4495e3          	bne	s1,s4,80000d3e <proc_mapstacks+0x38>
  }
}
    80000d78:	70e2                	ld	ra,56(sp)
    80000d7a:	7442                	ld	s0,48(sp)
    80000d7c:	74a2                	ld	s1,40(sp)
    80000d7e:	7902                	ld	s2,32(sp)
    80000d80:	69e2                	ld	s3,24(sp)
    80000d82:	6a42                	ld	s4,16(sp)
    80000d84:	6aa2                	ld	s5,8(sp)
    80000d86:	6b02                	ld	s6,0(sp)
    80000d88:	6121                	addi	sp,sp,64
    80000d8a:	8082                	ret
      panic("kalloc");
    80000d8c:	00007517          	auipc	a0,0x7
    80000d90:	3cc50513          	addi	a0,a0,972 # 80008158 <etext+0x158>
    80000d94:	00005097          	auipc	ra,0x5
    80000d98:	f6e080e7          	jalr	-146(ra) # 80005d02 <panic>

0000000080000d9c <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80000d9c:	7139                	addi	sp,sp,-64
    80000d9e:	fc06                	sd	ra,56(sp)
    80000da0:	f822                	sd	s0,48(sp)
    80000da2:	f426                	sd	s1,40(sp)
    80000da4:	f04a                	sd	s2,32(sp)
    80000da6:	ec4e                	sd	s3,24(sp)
    80000da8:	e852                	sd	s4,16(sp)
    80000daa:	e456                	sd	s5,8(sp)
    80000dac:	e05a                	sd	s6,0(sp)
    80000dae:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80000db0:	00007597          	auipc	a1,0x7
    80000db4:	3b058593          	addi	a1,a1,944 # 80008160 <etext+0x160>
    80000db8:	00008517          	auipc	a0,0x8
    80000dbc:	d3850513          	addi	a0,a0,-712 # 80008af0 <pid_lock>
    80000dc0:	00005097          	auipc	ra,0x5
    80000dc4:	3fc080e7          	jalr	1020(ra) # 800061bc <initlock>
  initlock(&wait_lock, "wait_lock");
    80000dc8:	00007597          	auipc	a1,0x7
    80000dcc:	3a058593          	addi	a1,a1,928 # 80008168 <etext+0x168>
    80000dd0:	00008517          	auipc	a0,0x8
    80000dd4:	d3850513          	addi	a0,a0,-712 # 80008b08 <wait_lock>
    80000dd8:	00005097          	auipc	ra,0x5
    80000ddc:	3e4080e7          	jalr	996(ra) # 800061bc <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000de0:	00008497          	auipc	s1,0x8
    80000de4:	14048493          	addi	s1,s1,320 # 80008f20 <proc>
      initlock(&p->lock, "proc");
    80000de8:	00007b17          	auipc	s6,0x7
    80000dec:	390b0b13          	addi	s6,s6,912 # 80008178 <etext+0x178>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80000df0:	8aa6                	mv	s5,s1
    80000df2:	00007a17          	auipc	s4,0x7
    80000df6:	20ea0a13          	addi	s4,s4,526 # 80008000 <etext>
    80000dfa:	04000937          	lui	s2,0x4000
    80000dfe:	197d                	addi	s2,s2,-1
    80000e00:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000e02:	0000e997          	auipc	s3,0xe
    80000e06:	d1e98993          	addi	s3,s3,-738 # 8000eb20 <tickslock>
      initlock(&p->lock, "proc");
    80000e0a:	85da                	mv	a1,s6
    80000e0c:	8526                	mv	a0,s1
    80000e0e:	00005097          	auipc	ra,0x5
    80000e12:	3ae080e7          	jalr	942(ra) # 800061bc <initlock>
      p->state = UNUSED;
    80000e16:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80000e1a:	415487b3          	sub	a5,s1,s5
    80000e1e:	8791                	srai	a5,a5,0x4
    80000e20:	000a3703          	ld	a4,0(s4)
    80000e24:	02e787b3          	mul	a5,a5,a4
    80000e28:	2785                	addiw	a5,a5,1
    80000e2a:	00d7979b          	slliw	a5,a5,0xd
    80000e2e:	40f907b3          	sub	a5,s2,a5
    80000e32:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80000e34:	17048493          	addi	s1,s1,368
    80000e38:	fd3499e3          	bne	s1,s3,80000e0a <procinit+0x6e>
  }
}
    80000e3c:	70e2                	ld	ra,56(sp)
    80000e3e:	7442                	ld	s0,48(sp)
    80000e40:	74a2                	ld	s1,40(sp)
    80000e42:	7902                	ld	s2,32(sp)
    80000e44:	69e2                	ld	s3,24(sp)
    80000e46:	6a42                	ld	s4,16(sp)
    80000e48:	6aa2                	ld	s5,8(sp)
    80000e4a:	6b02                	ld	s6,0(sp)
    80000e4c:	6121                	addi	sp,sp,64
    80000e4e:	8082                	ret

0000000080000e50 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80000e50:	1141                	addi	sp,sp,-16
    80000e52:	e422                	sd	s0,8(sp)
    80000e54:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80000e56:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80000e58:	2501                	sext.w	a0,a0
    80000e5a:	6422                	ld	s0,8(sp)
    80000e5c:	0141                	addi	sp,sp,16
    80000e5e:	8082                	ret

0000000080000e60 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80000e60:	1141                	addi	sp,sp,-16
    80000e62:	e422                	sd	s0,8(sp)
    80000e64:	0800                	addi	s0,sp,16
    80000e66:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80000e68:	2781                	sext.w	a5,a5
    80000e6a:	079e                	slli	a5,a5,0x7
  return c;
}
    80000e6c:	00008517          	auipc	a0,0x8
    80000e70:	cb450513          	addi	a0,a0,-844 # 80008b20 <cpus>
    80000e74:	953e                	add	a0,a0,a5
    80000e76:	6422                	ld	s0,8(sp)
    80000e78:	0141                	addi	sp,sp,16
    80000e7a:	8082                	ret

0000000080000e7c <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80000e7c:	1101                	addi	sp,sp,-32
    80000e7e:	ec06                	sd	ra,24(sp)
    80000e80:	e822                	sd	s0,16(sp)
    80000e82:	e426                	sd	s1,8(sp)
    80000e84:	1000                	addi	s0,sp,32
  push_off();
    80000e86:	00005097          	auipc	ra,0x5
    80000e8a:	37a080e7          	jalr	890(ra) # 80006200 <push_off>
    80000e8e:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80000e90:	2781                	sext.w	a5,a5
    80000e92:	079e                	slli	a5,a5,0x7
    80000e94:	00008717          	auipc	a4,0x8
    80000e98:	c5c70713          	addi	a4,a4,-932 # 80008af0 <pid_lock>
    80000e9c:	97ba                	add	a5,a5,a4
    80000e9e:	7b84                	ld	s1,48(a5)
  pop_off();
    80000ea0:	00005097          	auipc	ra,0x5
    80000ea4:	400080e7          	jalr	1024(ra) # 800062a0 <pop_off>
  return p;
}
    80000ea8:	8526                	mv	a0,s1
    80000eaa:	60e2                	ld	ra,24(sp)
    80000eac:	6442                	ld	s0,16(sp)
    80000eae:	64a2                	ld	s1,8(sp)
    80000eb0:	6105                	addi	sp,sp,32
    80000eb2:	8082                	ret

0000000080000eb4 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80000eb4:	1141                	addi	sp,sp,-16
    80000eb6:	e406                	sd	ra,8(sp)
    80000eb8:	e022                	sd	s0,0(sp)
    80000eba:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80000ebc:	00000097          	auipc	ra,0x0
    80000ec0:	fc0080e7          	jalr	-64(ra) # 80000e7c <myproc>
    80000ec4:	00005097          	auipc	ra,0x5
    80000ec8:	43c080e7          	jalr	1084(ra) # 80006300 <release>

  if (first) {
    80000ecc:	00008797          	auipc	a5,0x8
    80000ed0:	b647a783          	lw	a5,-1180(a5) # 80008a30 <first.1683>
    80000ed4:	eb89                	bnez	a5,80000ee6 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80000ed6:	00001097          	auipc	ra,0x1
    80000eda:	c8c080e7          	jalr	-884(ra) # 80001b62 <usertrapret>
}
    80000ede:	60a2                	ld	ra,8(sp)
    80000ee0:	6402                	ld	s0,0(sp)
    80000ee2:	0141                	addi	sp,sp,16
    80000ee4:	8082                	ret
    first = 0;
    80000ee6:	00008797          	auipc	a5,0x8
    80000eea:	b407a523          	sw	zero,-1206(a5) # 80008a30 <first.1683>
    fsinit(ROOTDEV);
    80000eee:	4505                	li	a0,1
    80000ef0:	00002097          	auipc	ra,0x2
    80000ef4:	a9c080e7          	jalr	-1380(ra) # 8000298c <fsinit>
    80000ef8:	bff9                	j	80000ed6 <forkret+0x22>

0000000080000efa <allocpid>:
{
    80000efa:	1101                	addi	sp,sp,-32
    80000efc:	ec06                	sd	ra,24(sp)
    80000efe:	e822                	sd	s0,16(sp)
    80000f00:	e426                	sd	s1,8(sp)
    80000f02:	e04a                	sd	s2,0(sp)
    80000f04:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80000f06:	00008917          	auipc	s2,0x8
    80000f0a:	bea90913          	addi	s2,s2,-1046 # 80008af0 <pid_lock>
    80000f0e:	854a                	mv	a0,s2
    80000f10:	00005097          	auipc	ra,0x5
    80000f14:	33c080e7          	jalr	828(ra) # 8000624c <acquire>
  pid = nextpid;
    80000f18:	00008797          	auipc	a5,0x8
    80000f1c:	b1c78793          	addi	a5,a5,-1252 # 80008a34 <nextpid>
    80000f20:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80000f22:	0014871b          	addiw	a4,s1,1
    80000f26:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80000f28:	854a                	mv	a0,s2
    80000f2a:	00005097          	auipc	ra,0x5
    80000f2e:	3d6080e7          	jalr	982(ra) # 80006300 <release>
}
    80000f32:	8526                	mv	a0,s1
    80000f34:	60e2                	ld	ra,24(sp)
    80000f36:	6442                	ld	s0,16(sp)
    80000f38:	64a2                	ld	s1,8(sp)
    80000f3a:	6902                	ld	s2,0(sp)
    80000f3c:	6105                	addi	sp,sp,32
    80000f3e:	8082                	ret

0000000080000f40 <proc_pagetable>:
{
    80000f40:	1101                	addi	sp,sp,-32
    80000f42:	ec06                	sd	ra,24(sp)
    80000f44:	e822                	sd	s0,16(sp)
    80000f46:	e426                	sd	s1,8(sp)
    80000f48:	e04a                	sd	s2,0(sp)
    80000f4a:	1000                	addi	s0,sp,32
    80000f4c:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80000f4e:	00000097          	auipc	ra,0x0
    80000f52:	8ac080e7          	jalr	-1876(ra) # 800007fa <uvmcreate>
    80000f56:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80000f58:	c121                	beqz	a0,80000f98 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80000f5a:	4729                	li	a4,10
    80000f5c:	00006697          	auipc	a3,0x6
    80000f60:	0a468693          	addi	a3,a3,164 # 80007000 <_trampoline>
    80000f64:	6605                	lui	a2,0x1
    80000f66:	040005b7          	lui	a1,0x4000
    80000f6a:	15fd                	addi	a1,a1,-1
    80000f6c:	05b2                	slli	a1,a1,0xc
    80000f6e:	fffff097          	auipc	ra,0xfffff
    80000f72:	602080e7          	jalr	1538(ra) # 80000570 <mappages>
    80000f76:	02054863          	bltz	a0,80000fa6 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80000f7a:	4719                	li	a4,6
    80000f7c:	05893683          	ld	a3,88(s2)
    80000f80:	6605                	lui	a2,0x1
    80000f82:	020005b7          	lui	a1,0x2000
    80000f86:	15fd                	addi	a1,a1,-1
    80000f88:	05b6                	slli	a1,a1,0xd
    80000f8a:	8526                	mv	a0,s1
    80000f8c:	fffff097          	auipc	ra,0xfffff
    80000f90:	5e4080e7          	jalr	1508(ra) # 80000570 <mappages>
    80000f94:	02054163          	bltz	a0,80000fb6 <proc_pagetable+0x76>
}
    80000f98:	8526                	mv	a0,s1
    80000f9a:	60e2                	ld	ra,24(sp)
    80000f9c:	6442                	ld	s0,16(sp)
    80000f9e:	64a2                	ld	s1,8(sp)
    80000fa0:	6902                	ld	s2,0(sp)
    80000fa2:	6105                	addi	sp,sp,32
    80000fa4:	8082                	ret
    uvmfree(pagetable, 0);
    80000fa6:	4581                	li	a1,0
    80000fa8:	8526                	mv	a0,s1
    80000faa:	00000097          	auipc	ra,0x0
    80000fae:	a54080e7          	jalr	-1452(ra) # 800009fe <uvmfree>
    return 0;
    80000fb2:	4481                	li	s1,0
    80000fb4:	b7d5                	j	80000f98 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80000fb6:	4681                	li	a3,0
    80000fb8:	4605                	li	a2,1
    80000fba:	040005b7          	lui	a1,0x4000
    80000fbe:	15fd                	addi	a1,a1,-1
    80000fc0:	05b2                	slli	a1,a1,0xc
    80000fc2:	8526                	mv	a0,s1
    80000fc4:	fffff097          	auipc	ra,0xfffff
    80000fc8:	772080e7          	jalr	1906(ra) # 80000736 <uvmunmap>
    uvmfree(pagetable, 0);
    80000fcc:	4581                	li	a1,0
    80000fce:	8526                	mv	a0,s1
    80000fd0:	00000097          	auipc	ra,0x0
    80000fd4:	a2e080e7          	jalr	-1490(ra) # 800009fe <uvmfree>
    return 0;
    80000fd8:	4481                	li	s1,0
    80000fda:	bf7d                	j	80000f98 <proc_pagetable+0x58>

0000000080000fdc <proc_freepagetable>:
{
    80000fdc:	1101                	addi	sp,sp,-32
    80000fde:	ec06                	sd	ra,24(sp)
    80000fe0:	e822                	sd	s0,16(sp)
    80000fe2:	e426                	sd	s1,8(sp)
    80000fe4:	e04a                	sd	s2,0(sp)
    80000fe6:	1000                	addi	s0,sp,32
    80000fe8:	84aa                	mv	s1,a0
    80000fea:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80000fec:	4681                	li	a3,0
    80000fee:	4605                	li	a2,1
    80000ff0:	040005b7          	lui	a1,0x4000
    80000ff4:	15fd                	addi	a1,a1,-1
    80000ff6:	05b2                	slli	a1,a1,0xc
    80000ff8:	fffff097          	auipc	ra,0xfffff
    80000ffc:	73e080e7          	jalr	1854(ra) # 80000736 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001000:	4681                	li	a3,0
    80001002:	4605                	li	a2,1
    80001004:	020005b7          	lui	a1,0x2000
    80001008:	15fd                	addi	a1,a1,-1
    8000100a:	05b6                	slli	a1,a1,0xd
    8000100c:	8526                	mv	a0,s1
    8000100e:	fffff097          	auipc	ra,0xfffff
    80001012:	728080e7          	jalr	1832(ra) # 80000736 <uvmunmap>
  uvmfree(pagetable, sz);
    80001016:	85ca                	mv	a1,s2
    80001018:	8526                	mv	a0,s1
    8000101a:	00000097          	auipc	ra,0x0
    8000101e:	9e4080e7          	jalr	-1564(ra) # 800009fe <uvmfree>
}
    80001022:	60e2                	ld	ra,24(sp)
    80001024:	6442                	ld	s0,16(sp)
    80001026:	64a2                	ld	s1,8(sp)
    80001028:	6902                	ld	s2,0(sp)
    8000102a:	6105                	addi	sp,sp,32
    8000102c:	8082                	ret

000000008000102e <freeproc>:
{
    8000102e:	1101                	addi	sp,sp,-32
    80001030:	ec06                	sd	ra,24(sp)
    80001032:	e822                	sd	s0,16(sp)
    80001034:	e426                	sd	s1,8(sp)
    80001036:	1000                	addi	s0,sp,32
    80001038:	84aa                	mv	s1,a0
  if(p->trapframe)
    8000103a:	6d28                	ld	a0,88(a0)
    8000103c:	c509                	beqz	a0,80001046 <freeproc+0x18>
    kfree((void*)p->trapframe);
    8000103e:	fffff097          	auipc	ra,0xfffff
    80001042:	fde080e7          	jalr	-34(ra) # 8000001c <kfree>
  p->trapframe = 0;
    80001046:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    8000104a:	68a8                	ld	a0,80(s1)
    8000104c:	c511                	beqz	a0,80001058 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    8000104e:	64ac                	ld	a1,72(s1)
    80001050:	00000097          	auipc	ra,0x0
    80001054:	f8c080e7          	jalr	-116(ra) # 80000fdc <proc_freepagetable>
  p->pagetable = 0;
    80001058:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    8000105c:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001060:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001064:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001068:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    8000106c:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001070:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001074:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001078:	0004ac23          	sw	zero,24(s1)
}
    8000107c:	60e2                	ld	ra,24(sp)
    8000107e:	6442                	ld	s0,16(sp)
    80001080:	64a2                	ld	s1,8(sp)
    80001082:	6105                	addi	sp,sp,32
    80001084:	8082                	ret

0000000080001086 <allocproc>:
{
    80001086:	1101                	addi	sp,sp,-32
    80001088:	ec06                	sd	ra,24(sp)
    8000108a:	e822                	sd	s0,16(sp)
    8000108c:	e426                	sd	s1,8(sp)
    8000108e:	e04a                	sd	s2,0(sp)
    80001090:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001092:	00008497          	auipc	s1,0x8
    80001096:	e8e48493          	addi	s1,s1,-370 # 80008f20 <proc>
    8000109a:	0000e917          	auipc	s2,0xe
    8000109e:	a8690913          	addi	s2,s2,-1402 # 8000eb20 <tickslock>
    acquire(&p->lock);
    800010a2:	8526                	mv	a0,s1
    800010a4:	00005097          	auipc	ra,0x5
    800010a8:	1a8080e7          	jalr	424(ra) # 8000624c <acquire>
    if(p->state == UNUSED) {
    800010ac:	4c9c                	lw	a5,24(s1)
    800010ae:	cf81                	beqz	a5,800010c6 <allocproc+0x40>
      release(&p->lock);
    800010b0:	8526                	mv	a0,s1
    800010b2:	00005097          	auipc	ra,0x5
    800010b6:	24e080e7          	jalr	590(ra) # 80006300 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800010ba:	17048493          	addi	s1,s1,368
    800010be:	ff2492e3          	bne	s1,s2,800010a2 <allocproc+0x1c>
  return 0;
    800010c2:	4481                	li	s1,0
    800010c4:	a889                	j	80001116 <allocproc+0x90>
  p->pid = allocpid();
    800010c6:	00000097          	auipc	ra,0x0
    800010ca:	e34080e7          	jalr	-460(ra) # 80000efa <allocpid>
    800010ce:	d888                	sw	a0,48(s1)
  p->state = USED;
    800010d0:	4785                	li	a5,1
    800010d2:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    800010d4:	fffff097          	auipc	ra,0xfffff
    800010d8:	044080e7          	jalr	68(ra) # 80000118 <kalloc>
    800010dc:	892a                	mv	s2,a0
    800010de:	eca8                	sd	a0,88(s1)
    800010e0:	c131                	beqz	a0,80001124 <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    800010e2:	8526                	mv	a0,s1
    800010e4:	00000097          	auipc	ra,0x0
    800010e8:	e5c080e7          	jalr	-420(ra) # 80000f40 <proc_pagetable>
    800010ec:	892a                	mv	s2,a0
    800010ee:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    800010f0:	c531                	beqz	a0,8000113c <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    800010f2:	07000613          	li	a2,112
    800010f6:	4581                	li	a1,0
    800010f8:	06048513          	addi	a0,s1,96
    800010fc:	fffff097          	auipc	ra,0xfffff
    80001100:	0a0080e7          	jalr	160(ra) # 8000019c <memset>
  p->context.ra = (uint64)forkret;
    80001104:	00000797          	auipc	a5,0x0
    80001108:	db078793          	addi	a5,a5,-592 # 80000eb4 <forkret>
    8000110c:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    8000110e:	60bc                	ld	a5,64(s1)
    80001110:	6705                	lui	a4,0x1
    80001112:	97ba                	add	a5,a5,a4
    80001114:	f4bc                	sd	a5,104(s1)
}
    80001116:	8526                	mv	a0,s1
    80001118:	60e2                	ld	ra,24(sp)
    8000111a:	6442                	ld	s0,16(sp)
    8000111c:	64a2                	ld	s1,8(sp)
    8000111e:	6902                	ld	s2,0(sp)
    80001120:	6105                	addi	sp,sp,32
    80001122:	8082                	ret
    freeproc(p);
    80001124:	8526                	mv	a0,s1
    80001126:	00000097          	auipc	ra,0x0
    8000112a:	f08080e7          	jalr	-248(ra) # 8000102e <freeproc>
    release(&p->lock);
    8000112e:	8526                	mv	a0,s1
    80001130:	00005097          	auipc	ra,0x5
    80001134:	1d0080e7          	jalr	464(ra) # 80006300 <release>
    return 0;
    80001138:	84ca                	mv	s1,s2
    8000113a:	bff1                	j	80001116 <allocproc+0x90>
    freeproc(p);
    8000113c:	8526                	mv	a0,s1
    8000113e:	00000097          	auipc	ra,0x0
    80001142:	ef0080e7          	jalr	-272(ra) # 8000102e <freeproc>
    release(&p->lock);
    80001146:	8526                	mv	a0,s1
    80001148:	00005097          	auipc	ra,0x5
    8000114c:	1b8080e7          	jalr	440(ra) # 80006300 <release>
    return 0;
    80001150:	84ca                	mv	s1,s2
    80001152:	b7d1                	j	80001116 <allocproc+0x90>

0000000080001154 <userinit>:
{
    80001154:	1101                	addi	sp,sp,-32
    80001156:	ec06                	sd	ra,24(sp)
    80001158:	e822                	sd	s0,16(sp)
    8000115a:	e426                	sd	s1,8(sp)
    8000115c:	1000                	addi	s0,sp,32
  p = allocproc();
    8000115e:	00000097          	auipc	ra,0x0
    80001162:	f28080e7          	jalr	-216(ra) # 80001086 <allocproc>
    80001166:	84aa                	mv	s1,a0
  initproc = p;
    80001168:	00008797          	auipc	a5,0x8
    8000116c:	94a7b423          	sd	a0,-1720(a5) # 80008ab0 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001170:	03400613          	li	a2,52
    80001174:	00008597          	auipc	a1,0x8
    80001178:	8cc58593          	addi	a1,a1,-1844 # 80008a40 <initcode>
    8000117c:	6928                	ld	a0,80(a0)
    8000117e:	fffff097          	auipc	ra,0xfffff
    80001182:	6aa080e7          	jalr	1706(ra) # 80000828 <uvmfirst>
  p->sz = PGSIZE;
    80001186:	6785                	lui	a5,0x1
    80001188:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    8000118a:	6cb8                	ld	a4,88(s1)
    8000118c:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001190:	6cb8                	ld	a4,88(s1)
    80001192:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001194:	4641                	li	a2,16
    80001196:	00007597          	auipc	a1,0x7
    8000119a:	fea58593          	addi	a1,a1,-22 # 80008180 <etext+0x180>
    8000119e:	15848513          	addi	a0,s1,344
    800011a2:	fffff097          	auipc	ra,0xfffff
    800011a6:	14c080e7          	jalr	332(ra) # 800002ee <safestrcpy>
  p->cwd = namei("/");
    800011aa:	00007517          	auipc	a0,0x7
    800011ae:	fe650513          	addi	a0,a0,-26 # 80008190 <etext+0x190>
    800011b2:	00002097          	auipc	ra,0x2
    800011b6:	1fc080e7          	jalr	508(ra) # 800033ae <namei>
    800011ba:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    800011be:	478d                	li	a5,3
    800011c0:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    800011c2:	8526                	mv	a0,s1
    800011c4:	00005097          	auipc	ra,0x5
    800011c8:	13c080e7          	jalr	316(ra) # 80006300 <release>
}
    800011cc:	60e2                	ld	ra,24(sp)
    800011ce:	6442                	ld	s0,16(sp)
    800011d0:	64a2                	ld	s1,8(sp)
    800011d2:	6105                	addi	sp,sp,32
    800011d4:	8082                	ret

00000000800011d6 <growproc>:
{
    800011d6:	1101                	addi	sp,sp,-32
    800011d8:	ec06                	sd	ra,24(sp)
    800011da:	e822                	sd	s0,16(sp)
    800011dc:	e426                	sd	s1,8(sp)
    800011de:	e04a                	sd	s2,0(sp)
    800011e0:	1000                	addi	s0,sp,32
    800011e2:	892a                	mv	s2,a0
  struct proc *p = myproc();
    800011e4:	00000097          	auipc	ra,0x0
    800011e8:	c98080e7          	jalr	-872(ra) # 80000e7c <myproc>
    800011ec:	84aa                	mv	s1,a0
  sz = p->sz;
    800011ee:	652c                	ld	a1,72(a0)
  if(n > 0){
    800011f0:	01204c63          	bgtz	s2,80001208 <growproc+0x32>
  } else if(n < 0){
    800011f4:	02094663          	bltz	s2,80001220 <growproc+0x4a>
  p->sz = sz;
    800011f8:	e4ac                	sd	a1,72(s1)
  return 0;
    800011fa:	4501                	li	a0,0
}
    800011fc:	60e2                	ld	ra,24(sp)
    800011fe:	6442                	ld	s0,16(sp)
    80001200:	64a2                	ld	s1,8(sp)
    80001202:	6902                	ld	s2,0(sp)
    80001204:	6105                	addi	sp,sp,32
    80001206:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001208:	4691                	li	a3,4
    8000120a:	00b90633          	add	a2,s2,a1
    8000120e:	6928                	ld	a0,80(a0)
    80001210:	fffff097          	auipc	ra,0xfffff
    80001214:	6d2080e7          	jalr	1746(ra) # 800008e2 <uvmalloc>
    80001218:	85aa                	mv	a1,a0
    8000121a:	fd79                	bnez	a0,800011f8 <growproc+0x22>
      return -1;
    8000121c:	557d                	li	a0,-1
    8000121e:	bff9                	j	800011fc <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001220:	00b90633          	add	a2,s2,a1
    80001224:	6928                	ld	a0,80(a0)
    80001226:	fffff097          	auipc	ra,0xfffff
    8000122a:	674080e7          	jalr	1652(ra) # 8000089a <uvmdealloc>
    8000122e:	85aa                	mv	a1,a0
    80001230:	b7e1                	j	800011f8 <growproc+0x22>

0000000080001232 <fork>:
{
    80001232:	7179                	addi	sp,sp,-48
    80001234:	f406                	sd	ra,40(sp)
    80001236:	f022                	sd	s0,32(sp)
    80001238:	ec26                	sd	s1,24(sp)
    8000123a:	e84a                	sd	s2,16(sp)
    8000123c:	e44e                	sd	s3,8(sp)
    8000123e:	e052                	sd	s4,0(sp)
    80001240:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001242:	00000097          	auipc	ra,0x0
    80001246:	c3a080e7          	jalr	-966(ra) # 80000e7c <myproc>
    8000124a:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    8000124c:	00000097          	auipc	ra,0x0
    80001250:	e3a080e7          	jalr	-454(ra) # 80001086 <allocproc>
    80001254:	10050f63          	beqz	a0,80001372 <fork+0x140>
    80001258:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    8000125a:	04893603          	ld	a2,72(s2)
    8000125e:	692c                	ld	a1,80(a0)
    80001260:	05093503          	ld	a0,80(s2)
    80001264:	fffff097          	auipc	ra,0xfffff
    80001268:	7d2080e7          	jalr	2002(ra) # 80000a36 <uvmcopy>
    8000126c:	04054a63          	bltz	a0,800012c0 <fork+0x8e>
  np->sz = p->sz;
    80001270:	04893783          	ld	a5,72(s2)
    80001274:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001278:	05893683          	ld	a3,88(s2)
    8000127c:	87b6                	mv	a5,a3
    8000127e:	0589b703          	ld	a4,88(s3)
    80001282:	12068693          	addi	a3,a3,288
    80001286:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    8000128a:	6788                	ld	a0,8(a5)
    8000128c:	6b8c                	ld	a1,16(a5)
    8000128e:	6f90                	ld	a2,24(a5)
    80001290:	01073023          	sd	a6,0(a4)
    80001294:	e708                	sd	a0,8(a4)
    80001296:	eb0c                	sd	a1,16(a4)
    80001298:	ef10                	sd	a2,24(a4)
    8000129a:	02078793          	addi	a5,a5,32
    8000129e:	02070713          	addi	a4,a4,32
    800012a2:	fed792e3          	bne	a5,a3,80001286 <fork+0x54>
  np->trace_s = p->trace_s;
    800012a6:	16892783          	lw	a5,360(s2)
    800012aa:	16f9a423          	sw	a5,360(s3)
  np->trapframe->a0 = 0;
    800012ae:	0589b783          	ld	a5,88(s3)
    800012b2:	0607b823          	sd	zero,112(a5)
    800012b6:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    800012ba:	15000a13          	li	s4,336
    800012be:	a03d                	j	800012ec <fork+0xba>
    freeproc(np);
    800012c0:	854e                	mv	a0,s3
    800012c2:	00000097          	auipc	ra,0x0
    800012c6:	d6c080e7          	jalr	-660(ra) # 8000102e <freeproc>
    release(&np->lock);
    800012ca:	854e                	mv	a0,s3
    800012cc:	00005097          	auipc	ra,0x5
    800012d0:	034080e7          	jalr	52(ra) # 80006300 <release>
    return -1;
    800012d4:	5a7d                	li	s4,-1
    800012d6:	a069                	j	80001360 <fork+0x12e>
      np->ofile[i] = filedup(p->ofile[i]);
    800012d8:	00002097          	auipc	ra,0x2
    800012dc:	76c080e7          	jalr	1900(ra) # 80003a44 <filedup>
    800012e0:	009987b3          	add	a5,s3,s1
    800012e4:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    800012e6:	04a1                	addi	s1,s1,8
    800012e8:	01448763          	beq	s1,s4,800012f6 <fork+0xc4>
    if(p->ofile[i])
    800012ec:	009907b3          	add	a5,s2,s1
    800012f0:	6388                	ld	a0,0(a5)
    800012f2:	f17d                	bnez	a0,800012d8 <fork+0xa6>
    800012f4:	bfcd                	j	800012e6 <fork+0xb4>
  np->cwd = idup(p->cwd);
    800012f6:	15093503          	ld	a0,336(s2)
    800012fa:	00002097          	auipc	ra,0x2
    800012fe:	8d0080e7          	jalr	-1840(ra) # 80002bca <idup>
    80001302:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001306:	4641                	li	a2,16
    80001308:	15890593          	addi	a1,s2,344
    8000130c:	15898513          	addi	a0,s3,344
    80001310:	fffff097          	auipc	ra,0xfffff
    80001314:	fde080e7          	jalr	-34(ra) # 800002ee <safestrcpy>
  pid = np->pid;
    80001318:	0309aa03          	lw	s4,48(s3)
  release(&np->lock);
    8000131c:	854e                	mv	a0,s3
    8000131e:	00005097          	auipc	ra,0x5
    80001322:	fe2080e7          	jalr	-30(ra) # 80006300 <release>
  acquire(&wait_lock);
    80001326:	00007497          	auipc	s1,0x7
    8000132a:	7e248493          	addi	s1,s1,2018 # 80008b08 <wait_lock>
    8000132e:	8526                	mv	a0,s1
    80001330:	00005097          	auipc	ra,0x5
    80001334:	f1c080e7          	jalr	-228(ra) # 8000624c <acquire>
  np->parent = p;
    80001338:	0329bc23          	sd	s2,56(s3)
  release(&wait_lock);
    8000133c:	8526                	mv	a0,s1
    8000133e:	00005097          	auipc	ra,0x5
    80001342:	fc2080e7          	jalr	-62(ra) # 80006300 <release>
  acquire(&np->lock);
    80001346:	854e                	mv	a0,s3
    80001348:	00005097          	auipc	ra,0x5
    8000134c:	f04080e7          	jalr	-252(ra) # 8000624c <acquire>
  np->state = RUNNABLE;
    80001350:	478d                	li	a5,3
    80001352:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001356:	854e                	mv	a0,s3
    80001358:	00005097          	auipc	ra,0x5
    8000135c:	fa8080e7          	jalr	-88(ra) # 80006300 <release>
}
    80001360:	8552                	mv	a0,s4
    80001362:	70a2                	ld	ra,40(sp)
    80001364:	7402                	ld	s0,32(sp)
    80001366:	64e2                	ld	s1,24(sp)
    80001368:	6942                	ld	s2,16(sp)
    8000136a:	69a2                	ld	s3,8(sp)
    8000136c:	6a02                	ld	s4,0(sp)
    8000136e:	6145                	addi	sp,sp,48
    80001370:	8082                	ret
    return -1;
    80001372:	5a7d                	li	s4,-1
    80001374:	b7f5                	j	80001360 <fork+0x12e>

0000000080001376 <scheduler>:
{
    80001376:	7139                	addi	sp,sp,-64
    80001378:	fc06                	sd	ra,56(sp)
    8000137a:	f822                	sd	s0,48(sp)
    8000137c:	f426                	sd	s1,40(sp)
    8000137e:	f04a                	sd	s2,32(sp)
    80001380:	ec4e                	sd	s3,24(sp)
    80001382:	e852                	sd	s4,16(sp)
    80001384:	e456                	sd	s5,8(sp)
    80001386:	e05a                	sd	s6,0(sp)
    80001388:	0080                	addi	s0,sp,64
    8000138a:	8792                	mv	a5,tp
  int id = r_tp();
    8000138c:	2781                	sext.w	a5,a5
  c->proc = 0;
    8000138e:	00779a93          	slli	s5,a5,0x7
    80001392:	00007717          	auipc	a4,0x7
    80001396:	75e70713          	addi	a4,a4,1886 # 80008af0 <pid_lock>
    8000139a:	9756                	add	a4,a4,s5
    8000139c:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    800013a0:	00007717          	auipc	a4,0x7
    800013a4:	78870713          	addi	a4,a4,1928 # 80008b28 <cpus+0x8>
    800013a8:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    800013aa:	498d                	li	s3,3
        p->state = RUNNING;
    800013ac:	4b11                	li	s6,4
        c->proc = p;
    800013ae:	079e                	slli	a5,a5,0x7
    800013b0:	00007a17          	auipc	s4,0x7
    800013b4:	740a0a13          	addi	s4,s4,1856 # 80008af0 <pid_lock>
    800013b8:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    800013ba:	0000d917          	auipc	s2,0xd
    800013be:	76690913          	addi	s2,s2,1894 # 8000eb20 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800013c2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800013c6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800013ca:	10079073          	csrw	sstatus,a5
    800013ce:	00008497          	auipc	s1,0x8
    800013d2:	b5248493          	addi	s1,s1,-1198 # 80008f20 <proc>
    800013d6:	a03d                	j	80001404 <scheduler+0x8e>
        p->state = RUNNING;
    800013d8:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    800013dc:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    800013e0:	06048593          	addi	a1,s1,96
    800013e4:	8556                	mv	a0,s5
    800013e6:	00000097          	auipc	ra,0x0
    800013ea:	6d2080e7          	jalr	1746(ra) # 80001ab8 <swtch>
        c->proc = 0;
    800013ee:	020a3823          	sd	zero,48(s4)
      release(&p->lock);
    800013f2:	8526                	mv	a0,s1
    800013f4:	00005097          	auipc	ra,0x5
    800013f8:	f0c080e7          	jalr	-244(ra) # 80006300 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800013fc:	17048493          	addi	s1,s1,368
    80001400:	fd2481e3          	beq	s1,s2,800013c2 <scheduler+0x4c>
      acquire(&p->lock);
    80001404:	8526                	mv	a0,s1
    80001406:	00005097          	auipc	ra,0x5
    8000140a:	e46080e7          	jalr	-442(ra) # 8000624c <acquire>
      if(p->state == RUNNABLE) {
    8000140e:	4c9c                	lw	a5,24(s1)
    80001410:	ff3791e3          	bne	a5,s3,800013f2 <scheduler+0x7c>
    80001414:	b7d1                	j	800013d8 <scheduler+0x62>

0000000080001416 <sched>:
{
    80001416:	7179                	addi	sp,sp,-48
    80001418:	f406                	sd	ra,40(sp)
    8000141a:	f022                	sd	s0,32(sp)
    8000141c:	ec26                	sd	s1,24(sp)
    8000141e:	e84a                	sd	s2,16(sp)
    80001420:	e44e                	sd	s3,8(sp)
    80001422:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001424:	00000097          	auipc	ra,0x0
    80001428:	a58080e7          	jalr	-1448(ra) # 80000e7c <myproc>
    8000142c:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000142e:	00005097          	auipc	ra,0x5
    80001432:	da4080e7          	jalr	-604(ra) # 800061d2 <holding>
    80001436:	c93d                	beqz	a0,800014ac <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001438:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000143a:	2781                	sext.w	a5,a5
    8000143c:	079e                	slli	a5,a5,0x7
    8000143e:	00007717          	auipc	a4,0x7
    80001442:	6b270713          	addi	a4,a4,1714 # 80008af0 <pid_lock>
    80001446:	97ba                	add	a5,a5,a4
    80001448:	0a87a703          	lw	a4,168(a5)
    8000144c:	4785                	li	a5,1
    8000144e:	06f71763          	bne	a4,a5,800014bc <sched+0xa6>
  if(p->state == RUNNING)
    80001452:	4c98                	lw	a4,24(s1)
    80001454:	4791                	li	a5,4
    80001456:	06f70b63          	beq	a4,a5,800014cc <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000145a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000145e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001460:	efb5                	bnez	a5,800014dc <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001462:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001464:	00007917          	auipc	s2,0x7
    80001468:	68c90913          	addi	s2,s2,1676 # 80008af0 <pid_lock>
    8000146c:	2781                	sext.w	a5,a5
    8000146e:	079e                	slli	a5,a5,0x7
    80001470:	97ca                	add	a5,a5,s2
    80001472:	0ac7a983          	lw	s3,172(a5)
    80001476:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001478:	2781                	sext.w	a5,a5
    8000147a:	079e                	slli	a5,a5,0x7
    8000147c:	00007597          	auipc	a1,0x7
    80001480:	6ac58593          	addi	a1,a1,1708 # 80008b28 <cpus+0x8>
    80001484:	95be                	add	a1,a1,a5
    80001486:	06048513          	addi	a0,s1,96
    8000148a:	00000097          	auipc	ra,0x0
    8000148e:	62e080e7          	jalr	1582(ra) # 80001ab8 <swtch>
    80001492:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001494:	2781                	sext.w	a5,a5
    80001496:	079e                	slli	a5,a5,0x7
    80001498:	97ca                	add	a5,a5,s2
    8000149a:	0b37a623          	sw	s3,172(a5)
}
    8000149e:	70a2                	ld	ra,40(sp)
    800014a0:	7402                	ld	s0,32(sp)
    800014a2:	64e2                	ld	s1,24(sp)
    800014a4:	6942                	ld	s2,16(sp)
    800014a6:	69a2                	ld	s3,8(sp)
    800014a8:	6145                	addi	sp,sp,48
    800014aa:	8082                	ret
    panic("sched p->lock");
    800014ac:	00007517          	auipc	a0,0x7
    800014b0:	cec50513          	addi	a0,a0,-788 # 80008198 <etext+0x198>
    800014b4:	00005097          	auipc	ra,0x5
    800014b8:	84e080e7          	jalr	-1970(ra) # 80005d02 <panic>
    panic("sched locks");
    800014bc:	00007517          	auipc	a0,0x7
    800014c0:	cec50513          	addi	a0,a0,-788 # 800081a8 <etext+0x1a8>
    800014c4:	00005097          	auipc	ra,0x5
    800014c8:	83e080e7          	jalr	-1986(ra) # 80005d02 <panic>
    panic("sched running");
    800014cc:	00007517          	auipc	a0,0x7
    800014d0:	cec50513          	addi	a0,a0,-788 # 800081b8 <etext+0x1b8>
    800014d4:	00005097          	auipc	ra,0x5
    800014d8:	82e080e7          	jalr	-2002(ra) # 80005d02 <panic>
    panic("sched interruptible");
    800014dc:	00007517          	auipc	a0,0x7
    800014e0:	cec50513          	addi	a0,a0,-788 # 800081c8 <etext+0x1c8>
    800014e4:	00005097          	auipc	ra,0x5
    800014e8:	81e080e7          	jalr	-2018(ra) # 80005d02 <panic>

00000000800014ec <yield>:
{
    800014ec:	1101                	addi	sp,sp,-32
    800014ee:	ec06                	sd	ra,24(sp)
    800014f0:	e822                	sd	s0,16(sp)
    800014f2:	e426                	sd	s1,8(sp)
    800014f4:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800014f6:	00000097          	auipc	ra,0x0
    800014fa:	986080e7          	jalr	-1658(ra) # 80000e7c <myproc>
    800014fe:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001500:	00005097          	auipc	ra,0x5
    80001504:	d4c080e7          	jalr	-692(ra) # 8000624c <acquire>
  p->state = RUNNABLE;
    80001508:	478d                	li	a5,3
    8000150a:	cc9c                	sw	a5,24(s1)
  sched();
    8000150c:	00000097          	auipc	ra,0x0
    80001510:	f0a080e7          	jalr	-246(ra) # 80001416 <sched>
  release(&p->lock);
    80001514:	8526                	mv	a0,s1
    80001516:	00005097          	auipc	ra,0x5
    8000151a:	dea080e7          	jalr	-534(ra) # 80006300 <release>
}
    8000151e:	60e2                	ld	ra,24(sp)
    80001520:	6442                	ld	s0,16(sp)
    80001522:	64a2                	ld	s1,8(sp)
    80001524:	6105                	addi	sp,sp,32
    80001526:	8082                	ret

0000000080001528 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001528:	7179                	addi	sp,sp,-48
    8000152a:	f406                	sd	ra,40(sp)
    8000152c:	f022                	sd	s0,32(sp)
    8000152e:	ec26                	sd	s1,24(sp)
    80001530:	e84a                	sd	s2,16(sp)
    80001532:	e44e                	sd	s3,8(sp)
    80001534:	1800                	addi	s0,sp,48
    80001536:	89aa                	mv	s3,a0
    80001538:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000153a:	00000097          	auipc	ra,0x0
    8000153e:	942080e7          	jalr	-1726(ra) # 80000e7c <myproc>
    80001542:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001544:	00005097          	auipc	ra,0x5
    80001548:	d08080e7          	jalr	-760(ra) # 8000624c <acquire>
  release(lk);
    8000154c:	854a                	mv	a0,s2
    8000154e:	00005097          	auipc	ra,0x5
    80001552:	db2080e7          	jalr	-590(ra) # 80006300 <release>

  // Go to sleep.
  p->chan = chan;
    80001556:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000155a:	4789                	li	a5,2
    8000155c:	cc9c                	sw	a5,24(s1)

  sched();
    8000155e:	00000097          	auipc	ra,0x0
    80001562:	eb8080e7          	jalr	-328(ra) # 80001416 <sched>

  // Tidy up.
  p->chan = 0;
    80001566:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000156a:	8526                	mv	a0,s1
    8000156c:	00005097          	auipc	ra,0x5
    80001570:	d94080e7          	jalr	-620(ra) # 80006300 <release>
  acquire(lk);
    80001574:	854a                	mv	a0,s2
    80001576:	00005097          	auipc	ra,0x5
    8000157a:	cd6080e7          	jalr	-810(ra) # 8000624c <acquire>
}
    8000157e:	70a2                	ld	ra,40(sp)
    80001580:	7402                	ld	s0,32(sp)
    80001582:	64e2                	ld	s1,24(sp)
    80001584:	6942                	ld	s2,16(sp)
    80001586:	69a2                	ld	s3,8(sp)
    80001588:	6145                	addi	sp,sp,48
    8000158a:	8082                	ret

000000008000158c <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    8000158c:	7139                	addi	sp,sp,-64
    8000158e:	fc06                	sd	ra,56(sp)
    80001590:	f822                	sd	s0,48(sp)
    80001592:	f426                	sd	s1,40(sp)
    80001594:	f04a                	sd	s2,32(sp)
    80001596:	ec4e                	sd	s3,24(sp)
    80001598:	e852                	sd	s4,16(sp)
    8000159a:	e456                	sd	s5,8(sp)
    8000159c:	0080                	addi	s0,sp,64
    8000159e:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800015a0:	00008497          	auipc	s1,0x8
    800015a4:	98048493          	addi	s1,s1,-1664 # 80008f20 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800015a8:	4989                	li	s3,2
        p->state = RUNNABLE;
    800015aa:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800015ac:	0000d917          	auipc	s2,0xd
    800015b0:	57490913          	addi	s2,s2,1396 # 8000eb20 <tickslock>
    800015b4:	a821                	j	800015cc <wakeup+0x40>
        p->state = RUNNABLE;
    800015b6:	0154ac23          	sw	s5,24(s1)
      }
      release(&p->lock);
    800015ba:	8526                	mv	a0,s1
    800015bc:	00005097          	auipc	ra,0x5
    800015c0:	d44080e7          	jalr	-700(ra) # 80006300 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800015c4:	17048493          	addi	s1,s1,368
    800015c8:	03248463          	beq	s1,s2,800015f0 <wakeup+0x64>
    if(p != myproc()){
    800015cc:	00000097          	auipc	ra,0x0
    800015d0:	8b0080e7          	jalr	-1872(ra) # 80000e7c <myproc>
    800015d4:	fea488e3          	beq	s1,a0,800015c4 <wakeup+0x38>
      acquire(&p->lock);
    800015d8:	8526                	mv	a0,s1
    800015da:	00005097          	auipc	ra,0x5
    800015de:	c72080e7          	jalr	-910(ra) # 8000624c <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800015e2:	4c9c                	lw	a5,24(s1)
    800015e4:	fd379be3          	bne	a5,s3,800015ba <wakeup+0x2e>
    800015e8:	709c                	ld	a5,32(s1)
    800015ea:	fd4798e3          	bne	a5,s4,800015ba <wakeup+0x2e>
    800015ee:	b7e1                	j	800015b6 <wakeup+0x2a>
    }
  }
}
    800015f0:	70e2                	ld	ra,56(sp)
    800015f2:	7442                	ld	s0,48(sp)
    800015f4:	74a2                	ld	s1,40(sp)
    800015f6:	7902                	ld	s2,32(sp)
    800015f8:	69e2                	ld	s3,24(sp)
    800015fa:	6a42                	ld	s4,16(sp)
    800015fc:	6aa2                	ld	s5,8(sp)
    800015fe:	6121                	addi	sp,sp,64
    80001600:	8082                	ret

0000000080001602 <reparent>:
{
    80001602:	7179                	addi	sp,sp,-48
    80001604:	f406                	sd	ra,40(sp)
    80001606:	f022                	sd	s0,32(sp)
    80001608:	ec26                	sd	s1,24(sp)
    8000160a:	e84a                	sd	s2,16(sp)
    8000160c:	e44e                	sd	s3,8(sp)
    8000160e:	e052                	sd	s4,0(sp)
    80001610:	1800                	addi	s0,sp,48
    80001612:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001614:	00008497          	auipc	s1,0x8
    80001618:	90c48493          	addi	s1,s1,-1780 # 80008f20 <proc>
      pp->parent = initproc;
    8000161c:	00007a17          	auipc	s4,0x7
    80001620:	494a0a13          	addi	s4,s4,1172 # 80008ab0 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001624:	0000d997          	auipc	s3,0xd
    80001628:	4fc98993          	addi	s3,s3,1276 # 8000eb20 <tickslock>
    8000162c:	a029                	j	80001636 <reparent+0x34>
    8000162e:	17048493          	addi	s1,s1,368
    80001632:	01348d63          	beq	s1,s3,8000164c <reparent+0x4a>
    if(pp->parent == p){
    80001636:	7c9c                	ld	a5,56(s1)
    80001638:	ff279be3          	bne	a5,s2,8000162e <reparent+0x2c>
      pp->parent = initproc;
    8000163c:	000a3503          	ld	a0,0(s4)
    80001640:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001642:	00000097          	auipc	ra,0x0
    80001646:	f4a080e7          	jalr	-182(ra) # 8000158c <wakeup>
    8000164a:	b7d5                	j	8000162e <reparent+0x2c>
}
    8000164c:	70a2                	ld	ra,40(sp)
    8000164e:	7402                	ld	s0,32(sp)
    80001650:	64e2                	ld	s1,24(sp)
    80001652:	6942                	ld	s2,16(sp)
    80001654:	69a2                	ld	s3,8(sp)
    80001656:	6a02                	ld	s4,0(sp)
    80001658:	6145                	addi	sp,sp,48
    8000165a:	8082                	ret

000000008000165c <exit>:
{
    8000165c:	7179                	addi	sp,sp,-48
    8000165e:	f406                	sd	ra,40(sp)
    80001660:	f022                	sd	s0,32(sp)
    80001662:	ec26                	sd	s1,24(sp)
    80001664:	e84a                	sd	s2,16(sp)
    80001666:	e44e                	sd	s3,8(sp)
    80001668:	e052                	sd	s4,0(sp)
    8000166a:	1800                	addi	s0,sp,48
    8000166c:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000166e:	00000097          	auipc	ra,0x0
    80001672:	80e080e7          	jalr	-2034(ra) # 80000e7c <myproc>
    80001676:	89aa                	mv	s3,a0
  if(p == initproc)
    80001678:	00007797          	auipc	a5,0x7
    8000167c:	4387b783          	ld	a5,1080(a5) # 80008ab0 <initproc>
    80001680:	0d050493          	addi	s1,a0,208
    80001684:	15050913          	addi	s2,a0,336
    80001688:	02a79363          	bne	a5,a0,800016ae <exit+0x52>
    panic("init exiting");
    8000168c:	00007517          	auipc	a0,0x7
    80001690:	b5450513          	addi	a0,a0,-1196 # 800081e0 <etext+0x1e0>
    80001694:	00004097          	auipc	ra,0x4
    80001698:	66e080e7          	jalr	1646(ra) # 80005d02 <panic>
      fileclose(f);
    8000169c:	00002097          	auipc	ra,0x2
    800016a0:	3fa080e7          	jalr	1018(ra) # 80003a96 <fileclose>
      p->ofile[fd] = 0;
    800016a4:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800016a8:	04a1                	addi	s1,s1,8
    800016aa:	01248563          	beq	s1,s2,800016b4 <exit+0x58>
    if(p->ofile[fd]){
    800016ae:	6088                	ld	a0,0(s1)
    800016b0:	f575                	bnez	a0,8000169c <exit+0x40>
    800016b2:	bfdd                	j	800016a8 <exit+0x4c>
  begin_op();
    800016b4:	00002097          	auipc	ra,0x2
    800016b8:	f16080e7          	jalr	-234(ra) # 800035ca <begin_op>
  iput(p->cwd);
    800016bc:	1509b503          	ld	a0,336(s3)
    800016c0:	00001097          	auipc	ra,0x1
    800016c4:	702080e7          	jalr	1794(ra) # 80002dc2 <iput>
  end_op();
    800016c8:	00002097          	auipc	ra,0x2
    800016cc:	f82080e7          	jalr	-126(ra) # 8000364a <end_op>
  p->cwd = 0;
    800016d0:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800016d4:	00007497          	auipc	s1,0x7
    800016d8:	43448493          	addi	s1,s1,1076 # 80008b08 <wait_lock>
    800016dc:	8526                	mv	a0,s1
    800016de:	00005097          	auipc	ra,0x5
    800016e2:	b6e080e7          	jalr	-1170(ra) # 8000624c <acquire>
  reparent(p);
    800016e6:	854e                	mv	a0,s3
    800016e8:	00000097          	auipc	ra,0x0
    800016ec:	f1a080e7          	jalr	-230(ra) # 80001602 <reparent>
  wakeup(p->parent);
    800016f0:	0389b503          	ld	a0,56(s3)
    800016f4:	00000097          	auipc	ra,0x0
    800016f8:	e98080e7          	jalr	-360(ra) # 8000158c <wakeup>
  acquire(&p->lock);
    800016fc:	854e                	mv	a0,s3
    800016fe:	00005097          	auipc	ra,0x5
    80001702:	b4e080e7          	jalr	-1202(ra) # 8000624c <acquire>
  p->xstate = status;
    80001706:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000170a:	4795                	li	a5,5
    8000170c:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80001710:	8526                	mv	a0,s1
    80001712:	00005097          	auipc	ra,0x5
    80001716:	bee080e7          	jalr	-1042(ra) # 80006300 <release>
  sched();
    8000171a:	00000097          	auipc	ra,0x0
    8000171e:	cfc080e7          	jalr	-772(ra) # 80001416 <sched>
  panic("zombie exit");
    80001722:	00007517          	auipc	a0,0x7
    80001726:	ace50513          	addi	a0,a0,-1330 # 800081f0 <etext+0x1f0>
    8000172a:	00004097          	auipc	ra,0x4
    8000172e:	5d8080e7          	jalr	1496(ra) # 80005d02 <panic>

0000000080001732 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80001732:	7179                	addi	sp,sp,-48
    80001734:	f406                	sd	ra,40(sp)
    80001736:	f022                	sd	s0,32(sp)
    80001738:	ec26                	sd	s1,24(sp)
    8000173a:	e84a                	sd	s2,16(sp)
    8000173c:	e44e                	sd	s3,8(sp)
    8000173e:	1800                	addi	s0,sp,48
    80001740:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80001742:	00007497          	auipc	s1,0x7
    80001746:	7de48493          	addi	s1,s1,2014 # 80008f20 <proc>
    8000174a:	0000d997          	auipc	s3,0xd
    8000174e:	3d698993          	addi	s3,s3,982 # 8000eb20 <tickslock>
    acquire(&p->lock);
    80001752:	8526                	mv	a0,s1
    80001754:	00005097          	auipc	ra,0x5
    80001758:	af8080e7          	jalr	-1288(ra) # 8000624c <acquire>
    if(p->pid == pid){
    8000175c:	589c                	lw	a5,48(s1)
    8000175e:	01278d63          	beq	a5,s2,80001778 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80001762:	8526                	mv	a0,s1
    80001764:	00005097          	auipc	ra,0x5
    80001768:	b9c080e7          	jalr	-1124(ra) # 80006300 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000176c:	17048493          	addi	s1,s1,368
    80001770:	ff3491e3          	bne	s1,s3,80001752 <kill+0x20>
  }
  return -1;
    80001774:	557d                	li	a0,-1
    80001776:	a829                	j	80001790 <kill+0x5e>
      p->killed = 1;
    80001778:	4785                	li	a5,1
    8000177a:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000177c:	4c98                	lw	a4,24(s1)
    8000177e:	4789                	li	a5,2
    80001780:	00f70f63          	beq	a4,a5,8000179e <kill+0x6c>
      release(&p->lock);
    80001784:	8526                	mv	a0,s1
    80001786:	00005097          	auipc	ra,0x5
    8000178a:	b7a080e7          	jalr	-1158(ra) # 80006300 <release>
      return 0;
    8000178e:	4501                	li	a0,0
}
    80001790:	70a2                	ld	ra,40(sp)
    80001792:	7402                	ld	s0,32(sp)
    80001794:	64e2                	ld	s1,24(sp)
    80001796:	6942                	ld	s2,16(sp)
    80001798:	69a2                	ld	s3,8(sp)
    8000179a:	6145                	addi	sp,sp,48
    8000179c:	8082                	ret
        p->state = RUNNABLE;
    8000179e:	478d                	li	a5,3
    800017a0:	cc9c                	sw	a5,24(s1)
    800017a2:	b7cd                	j	80001784 <kill+0x52>

00000000800017a4 <setkilled>:

void
setkilled(struct proc *p)
{
    800017a4:	1101                	addi	sp,sp,-32
    800017a6:	ec06                	sd	ra,24(sp)
    800017a8:	e822                	sd	s0,16(sp)
    800017aa:	e426                	sd	s1,8(sp)
    800017ac:	1000                	addi	s0,sp,32
    800017ae:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800017b0:	00005097          	auipc	ra,0x5
    800017b4:	a9c080e7          	jalr	-1380(ra) # 8000624c <acquire>
  p->killed = 1;
    800017b8:	4785                	li	a5,1
    800017ba:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800017bc:	8526                	mv	a0,s1
    800017be:	00005097          	auipc	ra,0x5
    800017c2:	b42080e7          	jalr	-1214(ra) # 80006300 <release>
}
    800017c6:	60e2                	ld	ra,24(sp)
    800017c8:	6442                	ld	s0,16(sp)
    800017ca:	64a2                	ld	s1,8(sp)
    800017cc:	6105                	addi	sp,sp,32
    800017ce:	8082                	ret

00000000800017d0 <killed>:

int
killed(struct proc *p)
{
    800017d0:	1101                	addi	sp,sp,-32
    800017d2:	ec06                	sd	ra,24(sp)
    800017d4:	e822                	sd	s0,16(sp)
    800017d6:	e426                	sd	s1,8(sp)
    800017d8:	e04a                	sd	s2,0(sp)
    800017da:	1000                	addi	s0,sp,32
    800017dc:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800017de:	00005097          	auipc	ra,0x5
    800017e2:	a6e080e7          	jalr	-1426(ra) # 8000624c <acquire>
  k = p->killed;
    800017e6:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800017ea:	8526                	mv	a0,s1
    800017ec:	00005097          	auipc	ra,0x5
    800017f0:	b14080e7          	jalr	-1260(ra) # 80006300 <release>
  return k;
}
    800017f4:	854a                	mv	a0,s2
    800017f6:	60e2                	ld	ra,24(sp)
    800017f8:	6442                	ld	s0,16(sp)
    800017fa:	64a2                	ld	s1,8(sp)
    800017fc:	6902                	ld	s2,0(sp)
    800017fe:	6105                	addi	sp,sp,32
    80001800:	8082                	ret

0000000080001802 <wait>:
{
    80001802:	715d                	addi	sp,sp,-80
    80001804:	e486                	sd	ra,72(sp)
    80001806:	e0a2                	sd	s0,64(sp)
    80001808:	fc26                	sd	s1,56(sp)
    8000180a:	f84a                	sd	s2,48(sp)
    8000180c:	f44e                	sd	s3,40(sp)
    8000180e:	f052                	sd	s4,32(sp)
    80001810:	ec56                	sd	s5,24(sp)
    80001812:	e85a                	sd	s6,16(sp)
    80001814:	e45e                	sd	s7,8(sp)
    80001816:	e062                	sd	s8,0(sp)
    80001818:	0880                	addi	s0,sp,80
    8000181a:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000181c:	fffff097          	auipc	ra,0xfffff
    80001820:	660080e7          	jalr	1632(ra) # 80000e7c <myproc>
    80001824:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80001826:	00007517          	auipc	a0,0x7
    8000182a:	2e250513          	addi	a0,a0,738 # 80008b08 <wait_lock>
    8000182e:	00005097          	auipc	ra,0x5
    80001832:	a1e080e7          	jalr	-1506(ra) # 8000624c <acquire>
    havekids = 0;
    80001836:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80001838:	4a15                	li	s4,5
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000183a:	0000d997          	auipc	s3,0xd
    8000183e:	2e698993          	addi	s3,s3,742 # 8000eb20 <tickslock>
        havekids = 1;
    80001842:	4a85                	li	s5,1
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80001844:	00007c17          	auipc	s8,0x7
    80001848:	2c4c0c13          	addi	s8,s8,708 # 80008b08 <wait_lock>
    havekids = 0;
    8000184c:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000184e:	00007497          	auipc	s1,0x7
    80001852:	6d248493          	addi	s1,s1,1746 # 80008f20 <proc>
    80001856:	a0bd                	j	800018c4 <wait+0xc2>
          pid = pp->pid;
    80001858:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000185c:	000b0e63          	beqz	s6,80001878 <wait+0x76>
    80001860:	4691                	li	a3,4
    80001862:	02c48613          	addi	a2,s1,44
    80001866:	85da                	mv	a1,s6
    80001868:	05093503          	ld	a0,80(s2)
    8000186c:	fffff097          	auipc	ra,0xfffff
    80001870:	2ce080e7          	jalr	718(ra) # 80000b3a <copyout>
    80001874:	02054563          	bltz	a0,8000189e <wait+0x9c>
          freeproc(pp);
    80001878:	8526                	mv	a0,s1
    8000187a:	fffff097          	auipc	ra,0xfffff
    8000187e:	7b4080e7          	jalr	1972(ra) # 8000102e <freeproc>
          release(&pp->lock);
    80001882:	8526                	mv	a0,s1
    80001884:	00005097          	auipc	ra,0x5
    80001888:	a7c080e7          	jalr	-1412(ra) # 80006300 <release>
          release(&wait_lock);
    8000188c:	00007517          	auipc	a0,0x7
    80001890:	27c50513          	addi	a0,a0,636 # 80008b08 <wait_lock>
    80001894:	00005097          	auipc	ra,0x5
    80001898:	a6c080e7          	jalr	-1428(ra) # 80006300 <release>
          return pid;
    8000189c:	a0b5                	j	80001908 <wait+0x106>
            release(&pp->lock);
    8000189e:	8526                	mv	a0,s1
    800018a0:	00005097          	auipc	ra,0x5
    800018a4:	a60080e7          	jalr	-1440(ra) # 80006300 <release>
            release(&wait_lock);
    800018a8:	00007517          	auipc	a0,0x7
    800018ac:	26050513          	addi	a0,a0,608 # 80008b08 <wait_lock>
    800018b0:	00005097          	auipc	ra,0x5
    800018b4:	a50080e7          	jalr	-1456(ra) # 80006300 <release>
            return -1;
    800018b8:	59fd                	li	s3,-1
    800018ba:	a0b9                	j	80001908 <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800018bc:	17048493          	addi	s1,s1,368
    800018c0:	03348463          	beq	s1,s3,800018e8 <wait+0xe6>
      if(pp->parent == p){
    800018c4:	7c9c                	ld	a5,56(s1)
    800018c6:	ff279be3          	bne	a5,s2,800018bc <wait+0xba>
        acquire(&pp->lock);
    800018ca:	8526                	mv	a0,s1
    800018cc:	00005097          	auipc	ra,0x5
    800018d0:	980080e7          	jalr	-1664(ra) # 8000624c <acquire>
        if(pp->state == ZOMBIE){
    800018d4:	4c9c                	lw	a5,24(s1)
    800018d6:	f94781e3          	beq	a5,s4,80001858 <wait+0x56>
        release(&pp->lock);
    800018da:	8526                	mv	a0,s1
    800018dc:	00005097          	auipc	ra,0x5
    800018e0:	a24080e7          	jalr	-1500(ra) # 80006300 <release>
        havekids = 1;
    800018e4:	8756                	mv	a4,s5
    800018e6:	bfd9                	j	800018bc <wait+0xba>
    if(!havekids || killed(p)){
    800018e8:	c719                	beqz	a4,800018f6 <wait+0xf4>
    800018ea:	854a                	mv	a0,s2
    800018ec:	00000097          	auipc	ra,0x0
    800018f0:	ee4080e7          	jalr	-284(ra) # 800017d0 <killed>
    800018f4:	c51d                	beqz	a0,80001922 <wait+0x120>
      release(&wait_lock);
    800018f6:	00007517          	auipc	a0,0x7
    800018fa:	21250513          	addi	a0,a0,530 # 80008b08 <wait_lock>
    800018fe:	00005097          	auipc	ra,0x5
    80001902:	a02080e7          	jalr	-1534(ra) # 80006300 <release>
      return -1;
    80001906:	59fd                	li	s3,-1
}
    80001908:	854e                	mv	a0,s3
    8000190a:	60a6                	ld	ra,72(sp)
    8000190c:	6406                	ld	s0,64(sp)
    8000190e:	74e2                	ld	s1,56(sp)
    80001910:	7942                	ld	s2,48(sp)
    80001912:	79a2                	ld	s3,40(sp)
    80001914:	7a02                	ld	s4,32(sp)
    80001916:	6ae2                	ld	s5,24(sp)
    80001918:	6b42                	ld	s6,16(sp)
    8000191a:	6ba2                	ld	s7,8(sp)
    8000191c:	6c02                	ld	s8,0(sp)
    8000191e:	6161                	addi	sp,sp,80
    80001920:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80001922:	85e2                	mv	a1,s8
    80001924:	854a                	mv	a0,s2
    80001926:	00000097          	auipc	ra,0x0
    8000192a:	c02080e7          	jalr	-1022(ra) # 80001528 <sleep>
    havekids = 0;
    8000192e:	bf39                	j	8000184c <wait+0x4a>

0000000080001930 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80001930:	7179                	addi	sp,sp,-48
    80001932:	f406                	sd	ra,40(sp)
    80001934:	f022                	sd	s0,32(sp)
    80001936:	ec26                	sd	s1,24(sp)
    80001938:	e84a                	sd	s2,16(sp)
    8000193a:	e44e                	sd	s3,8(sp)
    8000193c:	e052                	sd	s4,0(sp)
    8000193e:	1800                	addi	s0,sp,48
    80001940:	84aa                	mv	s1,a0
    80001942:	892e                	mv	s2,a1
    80001944:	89b2                	mv	s3,a2
    80001946:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80001948:	fffff097          	auipc	ra,0xfffff
    8000194c:	534080e7          	jalr	1332(ra) # 80000e7c <myproc>
  if(user_dst){
    80001950:	c08d                	beqz	s1,80001972 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80001952:	86d2                	mv	a3,s4
    80001954:	864e                	mv	a2,s3
    80001956:	85ca                	mv	a1,s2
    80001958:	6928                	ld	a0,80(a0)
    8000195a:	fffff097          	auipc	ra,0xfffff
    8000195e:	1e0080e7          	jalr	480(ra) # 80000b3a <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80001962:	70a2                	ld	ra,40(sp)
    80001964:	7402                	ld	s0,32(sp)
    80001966:	64e2                	ld	s1,24(sp)
    80001968:	6942                	ld	s2,16(sp)
    8000196a:	69a2                	ld	s3,8(sp)
    8000196c:	6a02                	ld	s4,0(sp)
    8000196e:	6145                	addi	sp,sp,48
    80001970:	8082                	ret
    memmove((char *)dst, src, len);
    80001972:	000a061b          	sext.w	a2,s4
    80001976:	85ce                	mv	a1,s3
    80001978:	854a                	mv	a0,s2
    8000197a:	fffff097          	auipc	ra,0xfffff
    8000197e:	882080e7          	jalr	-1918(ra) # 800001fc <memmove>
    return 0;
    80001982:	8526                	mv	a0,s1
    80001984:	bff9                	j	80001962 <either_copyout+0x32>

0000000080001986 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80001986:	7179                	addi	sp,sp,-48
    80001988:	f406                	sd	ra,40(sp)
    8000198a:	f022                	sd	s0,32(sp)
    8000198c:	ec26                	sd	s1,24(sp)
    8000198e:	e84a                	sd	s2,16(sp)
    80001990:	e44e                	sd	s3,8(sp)
    80001992:	e052                	sd	s4,0(sp)
    80001994:	1800                	addi	s0,sp,48
    80001996:	892a                	mv	s2,a0
    80001998:	84ae                	mv	s1,a1
    8000199a:	89b2                	mv	s3,a2
    8000199c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000199e:	fffff097          	auipc	ra,0xfffff
    800019a2:	4de080e7          	jalr	1246(ra) # 80000e7c <myproc>
  if(user_src){
    800019a6:	c08d                	beqz	s1,800019c8 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800019a8:	86d2                	mv	a3,s4
    800019aa:	864e                	mv	a2,s3
    800019ac:	85ca                	mv	a1,s2
    800019ae:	6928                	ld	a0,80(a0)
    800019b0:	fffff097          	auipc	ra,0xfffff
    800019b4:	216080e7          	jalr	534(ra) # 80000bc6 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800019b8:	70a2                	ld	ra,40(sp)
    800019ba:	7402                	ld	s0,32(sp)
    800019bc:	64e2                	ld	s1,24(sp)
    800019be:	6942                	ld	s2,16(sp)
    800019c0:	69a2                	ld	s3,8(sp)
    800019c2:	6a02                	ld	s4,0(sp)
    800019c4:	6145                	addi	sp,sp,48
    800019c6:	8082                	ret
    memmove(dst, (char*)src, len);
    800019c8:	000a061b          	sext.w	a2,s4
    800019cc:	85ce                	mv	a1,s3
    800019ce:	854a                	mv	a0,s2
    800019d0:	fffff097          	auipc	ra,0xfffff
    800019d4:	82c080e7          	jalr	-2004(ra) # 800001fc <memmove>
    return 0;
    800019d8:	8526                	mv	a0,s1
    800019da:	bff9                	j	800019b8 <either_copyin+0x32>

00000000800019dc <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800019dc:	715d                	addi	sp,sp,-80
    800019de:	e486                	sd	ra,72(sp)
    800019e0:	e0a2                	sd	s0,64(sp)
    800019e2:	fc26                	sd	s1,56(sp)
    800019e4:	f84a                	sd	s2,48(sp)
    800019e6:	f44e                	sd	s3,40(sp)
    800019e8:	f052                	sd	s4,32(sp)
    800019ea:	ec56                	sd	s5,24(sp)
    800019ec:	e85a                	sd	s6,16(sp)
    800019ee:	e45e                	sd	s7,8(sp)
    800019f0:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800019f2:	00006517          	auipc	a0,0x6
    800019f6:	65650513          	addi	a0,a0,1622 # 80008048 <etext+0x48>
    800019fa:	00004097          	auipc	ra,0x4
    800019fe:	352080e7          	jalr	850(ra) # 80005d4c <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001a02:	00007497          	auipc	s1,0x7
    80001a06:	67648493          	addi	s1,s1,1654 # 80009078 <proc+0x158>
    80001a0a:	0000d917          	auipc	s2,0xd
    80001a0e:	26e90913          	addi	s2,s2,622 # 8000ec78 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001a12:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80001a14:	00006997          	auipc	s3,0x6
    80001a18:	7ec98993          	addi	s3,s3,2028 # 80008200 <etext+0x200>
    printf("%d %s %s", p->pid, state, p->name);
    80001a1c:	00006a97          	auipc	s5,0x6
    80001a20:	7eca8a93          	addi	s5,s5,2028 # 80008208 <etext+0x208>
    printf("\n");
    80001a24:	00006a17          	auipc	s4,0x6
    80001a28:	624a0a13          	addi	s4,s4,1572 # 80008048 <etext+0x48>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001a2c:	00007b97          	auipc	s7,0x7
    80001a30:	81cb8b93          	addi	s7,s7,-2020 # 80008248 <states.1727>
    80001a34:	a00d                	j	80001a56 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80001a36:	ed86a583          	lw	a1,-296(a3)
    80001a3a:	8556                	mv	a0,s5
    80001a3c:	00004097          	auipc	ra,0x4
    80001a40:	310080e7          	jalr	784(ra) # 80005d4c <printf>
    printf("\n");
    80001a44:	8552                	mv	a0,s4
    80001a46:	00004097          	auipc	ra,0x4
    80001a4a:	306080e7          	jalr	774(ra) # 80005d4c <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001a4e:	17048493          	addi	s1,s1,368
    80001a52:	03248163          	beq	s1,s2,80001a74 <procdump+0x98>
    if(p->state == UNUSED)
    80001a56:	86a6                	mv	a3,s1
    80001a58:	ec04a783          	lw	a5,-320(s1)
    80001a5c:	dbed                	beqz	a5,80001a4e <procdump+0x72>
      state = "???";
    80001a5e:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001a60:	fcfb6be3          	bltu	s6,a5,80001a36 <procdump+0x5a>
    80001a64:	1782                	slli	a5,a5,0x20
    80001a66:	9381                	srli	a5,a5,0x20
    80001a68:	078e                	slli	a5,a5,0x3
    80001a6a:	97de                	add	a5,a5,s7
    80001a6c:	6390                	ld	a2,0(a5)
    80001a6e:	f661                	bnez	a2,80001a36 <procdump+0x5a>
      state = "???";
    80001a70:	864e                	mv	a2,s3
    80001a72:	b7d1                	j	80001a36 <procdump+0x5a>
  }
}
    80001a74:	60a6                	ld	ra,72(sp)
    80001a76:	6406                	ld	s0,64(sp)
    80001a78:	74e2                	ld	s1,56(sp)
    80001a7a:	7942                	ld	s2,48(sp)
    80001a7c:	79a2                	ld	s3,40(sp)
    80001a7e:	7a02                	ld	s4,32(sp)
    80001a80:	6ae2                	ld	s5,24(sp)
    80001a82:	6b42                	ld	s6,16(sp)
    80001a84:	6ba2                	ld	s7,8(sp)
    80001a86:	6161                	addi	sp,sp,80
    80001a88:	8082                	ret

0000000080001a8a <procused>:
//print the number of 
//processes that these status
//aren't unused
uint64
procused(void)
{
    80001a8a:	1141                	addi	sp,sp,-16
    80001a8c:	e422                	sd	s0,8(sp)
    80001a8e:	0800                	addi	s0,sp,16
  uint64 count = 0;

  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80001a90:	00007797          	auipc	a5,0x7
    80001a94:	49078793          	addi	a5,a5,1168 # 80008f20 <proc>
  uint64 count = 0;
    80001a98:	4501                	li	a0,0
  for (p = proc; p < &proc[NPROC]; p++) {
    80001a9a:	0000d697          	auipc	a3,0xd
    80001a9e:	08668693          	addi	a3,a3,134 # 8000eb20 <tickslock>
    if (p->state != UNUSED) {
    80001aa2:	4f98                	lw	a4,24(a5)
        count++;
    80001aa4:	00e03733          	snez	a4,a4
    80001aa8:	953a                	add	a0,a0,a4
  for (p = proc; p < &proc[NPROC]; p++) {
    80001aaa:	17078793          	addi	a5,a5,368
    80001aae:	fed79ae3          	bne	a5,a3,80001aa2 <procused+0x18>
    }
  }

  return count;
    80001ab2:	6422                	ld	s0,8(sp)
    80001ab4:	0141                	addi	sp,sp,16
    80001ab6:	8082                	ret

0000000080001ab8 <swtch>:
    80001ab8:	00153023          	sd	ra,0(a0)
    80001abc:	00253423          	sd	sp,8(a0)
    80001ac0:	e900                	sd	s0,16(a0)
    80001ac2:	ed04                	sd	s1,24(a0)
    80001ac4:	03253023          	sd	s2,32(a0)
    80001ac8:	03353423          	sd	s3,40(a0)
    80001acc:	03453823          	sd	s4,48(a0)
    80001ad0:	03553c23          	sd	s5,56(a0)
    80001ad4:	05653023          	sd	s6,64(a0)
    80001ad8:	05753423          	sd	s7,72(a0)
    80001adc:	05853823          	sd	s8,80(a0)
    80001ae0:	05953c23          	sd	s9,88(a0)
    80001ae4:	07a53023          	sd	s10,96(a0)
    80001ae8:	07b53423          	sd	s11,104(a0)
    80001aec:	0005b083          	ld	ra,0(a1)
    80001af0:	0085b103          	ld	sp,8(a1)
    80001af4:	6980                	ld	s0,16(a1)
    80001af6:	6d84                	ld	s1,24(a1)
    80001af8:	0205b903          	ld	s2,32(a1)
    80001afc:	0285b983          	ld	s3,40(a1)
    80001b00:	0305ba03          	ld	s4,48(a1)
    80001b04:	0385ba83          	ld	s5,56(a1)
    80001b08:	0405bb03          	ld	s6,64(a1)
    80001b0c:	0485bb83          	ld	s7,72(a1)
    80001b10:	0505bc03          	ld	s8,80(a1)
    80001b14:	0585bc83          	ld	s9,88(a1)
    80001b18:	0605bd03          	ld	s10,96(a1)
    80001b1c:	0685bd83          	ld	s11,104(a1)
    80001b20:	8082                	ret

0000000080001b22 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80001b22:	1141                	addi	sp,sp,-16
    80001b24:	e406                	sd	ra,8(sp)
    80001b26:	e022                	sd	s0,0(sp)
    80001b28:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80001b2a:	00006597          	auipc	a1,0x6
    80001b2e:	74e58593          	addi	a1,a1,1870 # 80008278 <states.1727+0x30>
    80001b32:	0000d517          	auipc	a0,0xd
    80001b36:	fee50513          	addi	a0,a0,-18 # 8000eb20 <tickslock>
    80001b3a:	00004097          	auipc	ra,0x4
    80001b3e:	682080e7          	jalr	1666(ra) # 800061bc <initlock>
}
    80001b42:	60a2                	ld	ra,8(sp)
    80001b44:	6402                	ld	s0,0(sp)
    80001b46:	0141                	addi	sp,sp,16
    80001b48:	8082                	ret

0000000080001b4a <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80001b4a:	1141                	addi	sp,sp,-16
    80001b4c:	e422                	sd	s0,8(sp)
    80001b4e:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001b50:	00003797          	auipc	a5,0x3
    80001b54:	58078793          	addi	a5,a5,1408 # 800050d0 <kernelvec>
    80001b58:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80001b5c:	6422                	ld	s0,8(sp)
    80001b5e:	0141                	addi	sp,sp,16
    80001b60:	8082                	ret

0000000080001b62 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80001b62:	1141                	addi	sp,sp,-16
    80001b64:	e406                	sd	ra,8(sp)
    80001b66:	e022                	sd	s0,0(sp)
    80001b68:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80001b6a:	fffff097          	auipc	ra,0xfffff
    80001b6e:	312080e7          	jalr	786(ra) # 80000e7c <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001b72:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001b76:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001b78:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80001b7c:	00005617          	auipc	a2,0x5
    80001b80:	48460613          	addi	a2,a2,1156 # 80007000 <_trampoline>
    80001b84:	00005697          	auipc	a3,0x5
    80001b88:	47c68693          	addi	a3,a3,1148 # 80007000 <_trampoline>
    80001b8c:	8e91                	sub	a3,a3,a2
    80001b8e:	040007b7          	lui	a5,0x4000
    80001b92:	17fd                	addi	a5,a5,-1
    80001b94:	07b2                	slli	a5,a5,0xc
    80001b96:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001b98:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80001b9c:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80001b9e:	180026f3          	csrr	a3,satp
    80001ba2:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80001ba4:	6d38                	ld	a4,88(a0)
    80001ba6:	6134                	ld	a3,64(a0)
    80001ba8:	6585                	lui	a1,0x1
    80001baa:	96ae                	add	a3,a3,a1
    80001bac:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80001bae:	6d38                	ld	a4,88(a0)
    80001bb0:	00000697          	auipc	a3,0x0
    80001bb4:	13068693          	addi	a3,a3,304 # 80001ce0 <usertrap>
    80001bb8:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80001bba:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80001bbc:	8692                	mv	a3,tp
    80001bbe:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001bc0:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80001bc4:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80001bc8:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001bcc:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80001bd0:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001bd2:	6f18                	ld	a4,24(a4)
    80001bd4:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80001bd8:	6928                	ld	a0,80(a0)
    80001bda:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001bdc:	00005717          	auipc	a4,0x5
    80001be0:	4c070713          	addi	a4,a4,1216 # 8000709c <userret>
    80001be4:	8f11                	sub	a4,a4,a2
    80001be6:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001be8:	577d                	li	a4,-1
    80001bea:	177e                	slli	a4,a4,0x3f
    80001bec:	8d59                	or	a0,a0,a4
    80001bee:	9782                	jalr	a5
}
    80001bf0:	60a2                	ld	ra,8(sp)
    80001bf2:	6402                	ld	s0,0(sp)
    80001bf4:	0141                	addi	sp,sp,16
    80001bf6:	8082                	ret

0000000080001bf8 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80001bf8:	1101                	addi	sp,sp,-32
    80001bfa:	ec06                	sd	ra,24(sp)
    80001bfc:	e822                	sd	s0,16(sp)
    80001bfe:	e426                	sd	s1,8(sp)
    80001c00:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80001c02:	0000d497          	auipc	s1,0xd
    80001c06:	f1e48493          	addi	s1,s1,-226 # 8000eb20 <tickslock>
    80001c0a:	8526                	mv	a0,s1
    80001c0c:	00004097          	auipc	ra,0x4
    80001c10:	640080e7          	jalr	1600(ra) # 8000624c <acquire>
  ticks++;
    80001c14:	00007517          	auipc	a0,0x7
    80001c18:	ea450513          	addi	a0,a0,-348 # 80008ab8 <ticks>
    80001c1c:	411c                	lw	a5,0(a0)
    80001c1e:	2785                	addiw	a5,a5,1
    80001c20:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80001c22:	00000097          	auipc	ra,0x0
    80001c26:	96a080e7          	jalr	-1686(ra) # 8000158c <wakeup>
  release(&tickslock);
    80001c2a:	8526                	mv	a0,s1
    80001c2c:	00004097          	auipc	ra,0x4
    80001c30:	6d4080e7          	jalr	1748(ra) # 80006300 <release>
}
    80001c34:	60e2                	ld	ra,24(sp)
    80001c36:	6442                	ld	s0,16(sp)
    80001c38:	64a2                	ld	s1,8(sp)
    80001c3a:	6105                	addi	sp,sp,32
    80001c3c:	8082                	ret

0000000080001c3e <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80001c3e:	1101                	addi	sp,sp,-32
    80001c40:	ec06                	sd	ra,24(sp)
    80001c42:	e822                	sd	s0,16(sp)
    80001c44:	e426                	sd	s1,8(sp)
    80001c46:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001c48:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80001c4c:	00074d63          	bltz	a4,80001c66 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80001c50:	57fd                	li	a5,-1
    80001c52:	17fe                	slli	a5,a5,0x3f
    80001c54:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80001c56:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80001c58:	06f70363          	beq	a4,a5,80001cbe <devintr+0x80>
  }
}
    80001c5c:	60e2                	ld	ra,24(sp)
    80001c5e:	6442                	ld	s0,16(sp)
    80001c60:	64a2                	ld	s1,8(sp)
    80001c62:	6105                	addi	sp,sp,32
    80001c64:	8082                	ret
     (scause & 0xff) == 9){
    80001c66:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80001c6a:	46a5                	li	a3,9
    80001c6c:	fed792e3          	bne	a5,a3,80001c50 <devintr+0x12>
    int irq = plic_claim();
    80001c70:	00003097          	auipc	ra,0x3
    80001c74:	568080e7          	jalr	1384(ra) # 800051d8 <plic_claim>
    80001c78:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80001c7a:	47a9                	li	a5,10
    80001c7c:	02f50763          	beq	a0,a5,80001caa <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80001c80:	4785                	li	a5,1
    80001c82:	02f50963          	beq	a0,a5,80001cb4 <devintr+0x76>
    return 1;
    80001c86:	4505                	li	a0,1
    } else if(irq){
    80001c88:	d8f1                	beqz	s1,80001c5c <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80001c8a:	85a6                	mv	a1,s1
    80001c8c:	00006517          	auipc	a0,0x6
    80001c90:	5f450513          	addi	a0,a0,1524 # 80008280 <states.1727+0x38>
    80001c94:	00004097          	auipc	ra,0x4
    80001c98:	0b8080e7          	jalr	184(ra) # 80005d4c <printf>
      plic_complete(irq);
    80001c9c:	8526                	mv	a0,s1
    80001c9e:	00003097          	auipc	ra,0x3
    80001ca2:	55e080e7          	jalr	1374(ra) # 800051fc <plic_complete>
    return 1;
    80001ca6:	4505                	li	a0,1
    80001ca8:	bf55                	j	80001c5c <devintr+0x1e>
      uartintr();
    80001caa:	00004097          	auipc	ra,0x4
    80001cae:	4c2080e7          	jalr	1218(ra) # 8000616c <uartintr>
    80001cb2:	b7ed                	j	80001c9c <devintr+0x5e>
      virtio_disk_intr();
    80001cb4:	00004097          	auipc	ra,0x4
    80001cb8:	a72080e7          	jalr	-1422(ra) # 80005726 <virtio_disk_intr>
    80001cbc:	b7c5                	j	80001c9c <devintr+0x5e>
    if(cpuid() == 0){
    80001cbe:	fffff097          	auipc	ra,0xfffff
    80001cc2:	192080e7          	jalr	402(ra) # 80000e50 <cpuid>
    80001cc6:	c901                	beqz	a0,80001cd6 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80001cc8:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80001ccc:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80001cce:	14479073          	csrw	sip,a5
    return 2;
    80001cd2:	4509                	li	a0,2
    80001cd4:	b761                	j	80001c5c <devintr+0x1e>
      clockintr();
    80001cd6:	00000097          	auipc	ra,0x0
    80001cda:	f22080e7          	jalr	-222(ra) # 80001bf8 <clockintr>
    80001cde:	b7ed                	j	80001cc8 <devintr+0x8a>

0000000080001ce0 <usertrap>:
{
    80001ce0:	1101                	addi	sp,sp,-32
    80001ce2:	ec06                	sd	ra,24(sp)
    80001ce4:	e822                	sd	s0,16(sp)
    80001ce6:	e426                	sd	s1,8(sp)
    80001ce8:	e04a                	sd	s2,0(sp)
    80001cea:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001cec:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80001cf0:	1007f793          	andi	a5,a5,256
    80001cf4:	e3b1                	bnez	a5,80001d38 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001cf6:	00003797          	auipc	a5,0x3
    80001cfa:	3da78793          	addi	a5,a5,986 # 800050d0 <kernelvec>
    80001cfe:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80001d02:	fffff097          	auipc	ra,0xfffff
    80001d06:	17a080e7          	jalr	378(ra) # 80000e7c <myproc>
    80001d0a:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80001d0c:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001d0e:	14102773          	csrr	a4,sepc
    80001d12:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001d14:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80001d18:	47a1                	li	a5,8
    80001d1a:	02f70763          	beq	a4,a5,80001d48 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80001d1e:	00000097          	auipc	ra,0x0
    80001d22:	f20080e7          	jalr	-224(ra) # 80001c3e <devintr>
    80001d26:	892a                	mv	s2,a0
    80001d28:	c151                	beqz	a0,80001dac <usertrap+0xcc>
  if(killed(p))
    80001d2a:	8526                	mv	a0,s1
    80001d2c:	00000097          	auipc	ra,0x0
    80001d30:	aa4080e7          	jalr	-1372(ra) # 800017d0 <killed>
    80001d34:	c929                	beqz	a0,80001d86 <usertrap+0xa6>
    80001d36:	a099                	j	80001d7c <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80001d38:	00006517          	auipc	a0,0x6
    80001d3c:	56850513          	addi	a0,a0,1384 # 800082a0 <states.1727+0x58>
    80001d40:	00004097          	auipc	ra,0x4
    80001d44:	fc2080e7          	jalr	-62(ra) # 80005d02 <panic>
    if(killed(p))
    80001d48:	00000097          	auipc	ra,0x0
    80001d4c:	a88080e7          	jalr	-1400(ra) # 800017d0 <killed>
    80001d50:	e921                	bnez	a0,80001da0 <usertrap+0xc0>
    p->trapframe->epc += 4;
    80001d52:	6cb8                	ld	a4,88(s1)
    80001d54:	6f1c                	ld	a5,24(a4)
    80001d56:	0791                	addi	a5,a5,4
    80001d58:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d5a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001d5e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001d62:	10079073          	csrw	sstatus,a5
    syscall();
    80001d66:	00000097          	auipc	ra,0x0
    80001d6a:	2d4080e7          	jalr	724(ra) # 8000203a <syscall>
  if(killed(p))
    80001d6e:	8526                	mv	a0,s1
    80001d70:	00000097          	auipc	ra,0x0
    80001d74:	a60080e7          	jalr	-1440(ra) # 800017d0 <killed>
    80001d78:	c911                	beqz	a0,80001d8c <usertrap+0xac>
    80001d7a:	4901                	li	s2,0
    exit(-1);
    80001d7c:	557d                	li	a0,-1
    80001d7e:	00000097          	auipc	ra,0x0
    80001d82:	8de080e7          	jalr	-1826(ra) # 8000165c <exit>
  if(which_dev == 2)
    80001d86:	4789                	li	a5,2
    80001d88:	04f90f63          	beq	s2,a5,80001de6 <usertrap+0x106>
  usertrapret();
    80001d8c:	00000097          	auipc	ra,0x0
    80001d90:	dd6080e7          	jalr	-554(ra) # 80001b62 <usertrapret>
}
    80001d94:	60e2                	ld	ra,24(sp)
    80001d96:	6442                	ld	s0,16(sp)
    80001d98:	64a2                	ld	s1,8(sp)
    80001d9a:	6902                	ld	s2,0(sp)
    80001d9c:	6105                	addi	sp,sp,32
    80001d9e:	8082                	ret
      exit(-1);
    80001da0:	557d                	li	a0,-1
    80001da2:	00000097          	auipc	ra,0x0
    80001da6:	8ba080e7          	jalr	-1862(ra) # 8000165c <exit>
    80001daa:	b765                	j	80001d52 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001dac:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80001db0:	5890                	lw	a2,48(s1)
    80001db2:	00006517          	auipc	a0,0x6
    80001db6:	50e50513          	addi	a0,a0,1294 # 800082c0 <states.1727+0x78>
    80001dba:	00004097          	auipc	ra,0x4
    80001dbe:	f92080e7          	jalr	-110(ra) # 80005d4c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001dc2:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001dc6:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80001dca:	00006517          	auipc	a0,0x6
    80001dce:	52650513          	addi	a0,a0,1318 # 800082f0 <states.1727+0xa8>
    80001dd2:	00004097          	auipc	ra,0x4
    80001dd6:	f7a080e7          	jalr	-134(ra) # 80005d4c <printf>
    setkilled(p);
    80001dda:	8526                	mv	a0,s1
    80001ddc:	00000097          	auipc	ra,0x0
    80001de0:	9c8080e7          	jalr	-1592(ra) # 800017a4 <setkilled>
    80001de4:	b769                	j	80001d6e <usertrap+0x8e>
    yield();
    80001de6:	fffff097          	auipc	ra,0xfffff
    80001dea:	706080e7          	jalr	1798(ra) # 800014ec <yield>
    80001dee:	bf79                	j	80001d8c <usertrap+0xac>

0000000080001df0 <kerneltrap>:
{
    80001df0:	7179                	addi	sp,sp,-48
    80001df2:	f406                	sd	ra,40(sp)
    80001df4:	f022                	sd	s0,32(sp)
    80001df6:	ec26                	sd	s1,24(sp)
    80001df8:	e84a                	sd	s2,16(sp)
    80001dfa:	e44e                	sd	s3,8(sp)
    80001dfc:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001dfe:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e02:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001e06:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80001e0a:	1004f793          	andi	a5,s1,256
    80001e0e:	cb85                	beqz	a5,80001e3e <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e10:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e14:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80001e16:	ef85                	bnez	a5,80001e4e <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80001e18:	00000097          	auipc	ra,0x0
    80001e1c:	e26080e7          	jalr	-474(ra) # 80001c3e <devintr>
    80001e20:	cd1d                	beqz	a0,80001e5e <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80001e22:	4789                	li	a5,2
    80001e24:	06f50a63          	beq	a0,a5,80001e98 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001e28:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e2c:	10049073          	csrw	sstatus,s1
}
    80001e30:	70a2                	ld	ra,40(sp)
    80001e32:	7402                	ld	s0,32(sp)
    80001e34:	64e2                	ld	s1,24(sp)
    80001e36:	6942                	ld	s2,16(sp)
    80001e38:	69a2                	ld	s3,8(sp)
    80001e3a:	6145                	addi	sp,sp,48
    80001e3c:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80001e3e:	00006517          	auipc	a0,0x6
    80001e42:	4d250513          	addi	a0,a0,1234 # 80008310 <states.1727+0xc8>
    80001e46:	00004097          	auipc	ra,0x4
    80001e4a:	ebc080e7          	jalr	-324(ra) # 80005d02 <panic>
    panic("kerneltrap: interrupts enabled");
    80001e4e:	00006517          	auipc	a0,0x6
    80001e52:	4ea50513          	addi	a0,a0,1258 # 80008338 <states.1727+0xf0>
    80001e56:	00004097          	auipc	ra,0x4
    80001e5a:	eac080e7          	jalr	-340(ra) # 80005d02 <panic>
    printf("scause %p\n", scause);
    80001e5e:	85ce                	mv	a1,s3
    80001e60:	00006517          	auipc	a0,0x6
    80001e64:	4f850513          	addi	a0,a0,1272 # 80008358 <states.1727+0x110>
    80001e68:	00004097          	auipc	ra,0x4
    80001e6c:	ee4080e7          	jalr	-284(ra) # 80005d4c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001e70:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001e74:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80001e78:	00006517          	auipc	a0,0x6
    80001e7c:	4f050513          	addi	a0,a0,1264 # 80008368 <states.1727+0x120>
    80001e80:	00004097          	auipc	ra,0x4
    80001e84:	ecc080e7          	jalr	-308(ra) # 80005d4c <printf>
    panic("kerneltrap");
    80001e88:	00006517          	auipc	a0,0x6
    80001e8c:	4f850513          	addi	a0,a0,1272 # 80008380 <states.1727+0x138>
    80001e90:	00004097          	auipc	ra,0x4
    80001e94:	e72080e7          	jalr	-398(ra) # 80005d02 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80001e98:	fffff097          	auipc	ra,0xfffff
    80001e9c:	fe4080e7          	jalr	-28(ra) # 80000e7c <myproc>
    80001ea0:	d541                	beqz	a0,80001e28 <kerneltrap+0x38>
    80001ea2:	fffff097          	auipc	ra,0xfffff
    80001ea6:	fda080e7          	jalr	-38(ra) # 80000e7c <myproc>
    80001eaa:	4d18                	lw	a4,24(a0)
    80001eac:	4791                	li	a5,4
    80001eae:	f6f71de3          	bne	a4,a5,80001e28 <kerneltrap+0x38>
    yield();
    80001eb2:	fffff097          	auipc	ra,0xfffff
    80001eb6:	63a080e7          	jalr	1594(ra) # 800014ec <yield>
    80001eba:	b7bd                	j	80001e28 <kerneltrap+0x38>

0000000080001ebc <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80001ebc:	1101                	addi	sp,sp,-32
    80001ebe:	ec06                	sd	ra,24(sp)
    80001ec0:	e822                	sd	s0,16(sp)
    80001ec2:	e426                	sd	s1,8(sp)
    80001ec4:	1000                	addi	s0,sp,32
    80001ec6:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001ec8:	fffff097          	auipc	ra,0xfffff
    80001ecc:	fb4080e7          	jalr	-76(ra) # 80000e7c <myproc>
  switch (n) {
    80001ed0:	4795                	li	a5,5
    80001ed2:	0497e163          	bltu	a5,s1,80001f14 <argraw+0x58>
    80001ed6:	048a                	slli	s1,s1,0x2
    80001ed8:	00006717          	auipc	a4,0x6
    80001edc:	5a870713          	addi	a4,a4,1448 # 80008480 <states.1727+0x238>
    80001ee0:	94ba                	add	s1,s1,a4
    80001ee2:	409c                	lw	a5,0(s1)
    80001ee4:	97ba                	add	a5,a5,a4
    80001ee6:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80001ee8:	6d3c                	ld	a5,88(a0)
    80001eea:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80001eec:	60e2                	ld	ra,24(sp)
    80001eee:	6442                	ld	s0,16(sp)
    80001ef0:	64a2                	ld	s1,8(sp)
    80001ef2:	6105                	addi	sp,sp,32
    80001ef4:	8082                	ret
    return p->trapframe->a1;
    80001ef6:	6d3c                	ld	a5,88(a0)
    80001ef8:	7fa8                	ld	a0,120(a5)
    80001efa:	bfcd                	j	80001eec <argraw+0x30>
    return p->trapframe->a2;
    80001efc:	6d3c                	ld	a5,88(a0)
    80001efe:	63c8                	ld	a0,128(a5)
    80001f00:	b7f5                	j	80001eec <argraw+0x30>
    return p->trapframe->a3;
    80001f02:	6d3c                	ld	a5,88(a0)
    80001f04:	67c8                	ld	a0,136(a5)
    80001f06:	b7dd                	j	80001eec <argraw+0x30>
    return p->trapframe->a4;
    80001f08:	6d3c                	ld	a5,88(a0)
    80001f0a:	6bc8                	ld	a0,144(a5)
    80001f0c:	b7c5                	j	80001eec <argraw+0x30>
    return p->trapframe->a5;
    80001f0e:	6d3c                	ld	a5,88(a0)
    80001f10:	6fc8                	ld	a0,152(a5)
    80001f12:	bfe9                	j	80001eec <argraw+0x30>
  panic("argraw");
    80001f14:	00006517          	auipc	a0,0x6
    80001f18:	47c50513          	addi	a0,a0,1148 # 80008390 <states.1727+0x148>
    80001f1c:	00004097          	auipc	ra,0x4
    80001f20:	de6080e7          	jalr	-538(ra) # 80005d02 <panic>

0000000080001f24 <fetchaddr>:
{
    80001f24:	1101                	addi	sp,sp,-32
    80001f26:	ec06                	sd	ra,24(sp)
    80001f28:	e822                	sd	s0,16(sp)
    80001f2a:	e426                	sd	s1,8(sp)
    80001f2c:	e04a                	sd	s2,0(sp)
    80001f2e:	1000                	addi	s0,sp,32
    80001f30:	84aa                	mv	s1,a0
    80001f32:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001f34:	fffff097          	auipc	ra,0xfffff
    80001f38:	f48080e7          	jalr	-184(ra) # 80000e7c <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80001f3c:	653c                	ld	a5,72(a0)
    80001f3e:	02f4f863          	bgeu	s1,a5,80001f6e <fetchaddr+0x4a>
    80001f42:	00848713          	addi	a4,s1,8
    80001f46:	02e7e663          	bltu	a5,a4,80001f72 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80001f4a:	46a1                	li	a3,8
    80001f4c:	8626                	mv	a2,s1
    80001f4e:	85ca                	mv	a1,s2
    80001f50:	6928                	ld	a0,80(a0)
    80001f52:	fffff097          	auipc	ra,0xfffff
    80001f56:	c74080e7          	jalr	-908(ra) # 80000bc6 <copyin>
    80001f5a:	00a03533          	snez	a0,a0
    80001f5e:	40a00533          	neg	a0,a0
}
    80001f62:	60e2                	ld	ra,24(sp)
    80001f64:	6442                	ld	s0,16(sp)
    80001f66:	64a2                	ld	s1,8(sp)
    80001f68:	6902                	ld	s2,0(sp)
    80001f6a:	6105                	addi	sp,sp,32
    80001f6c:	8082                	ret
    return -1;
    80001f6e:	557d                	li	a0,-1
    80001f70:	bfcd                	j	80001f62 <fetchaddr+0x3e>
    80001f72:	557d                	li	a0,-1
    80001f74:	b7fd                	j	80001f62 <fetchaddr+0x3e>

0000000080001f76 <fetchstr>:
{
    80001f76:	7179                	addi	sp,sp,-48
    80001f78:	f406                	sd	ra,40(sp)
    80001f7a:	f022                	sd	s0,32(sp)
    80001f7c:	ec26                	sd	s1,24(sp)
    80001f7e:	e84a                	sd	s2,16(sp)
    80001f80:	e44e                	sd	s3,8(sp)
    80001f82:	1800                	addi	s0,sp,48
    80001f84:	892a                	mv	s2,a0
    80001f86:	84ae                	mv	s1,a1
    80001f88:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80001f8a:	fffff097          	auipc	ra,0xfffff
    80001f8e:	ef2080e7          	jalr	-270(ra) # 80000e7c <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80001f92:	86ce                	mv	a3,s3
    80001f94:	864a                	mv	a2,s2
    80001f96:	85a6                	mv	a1,s1
    80001f98:	6928                	ld	a0,80(a0)
    80001f9a:	fffff097          	auipc	ra,0xfffff
    80001f9e:	cb8080e7          	jalr	-840(ra) # 80000c52 <copyinstr>
    80001fa2:	00054e63          	bltz	a0,80001fbe <fetchstr+0x48>
  return strlen(buf);
    80001fa6:	8526                	mv	a0,s1
    80001fa8:	ffffe097          	auipc	ra,0xffffe
    80001fac:	378080e7          	jalr	888(ra) # 80000320 <strlen>
}
    80001fb0:	70a2                	ld	ra,40(sp)
    80001fb2:	7402                	ld	s0,32(sp)
    80001fb4:	64e2                	ld	s1,24(sp)
    80001fb6:	6942                	ld	s2,16(sp)
    80001fb8:	69a2                	ld	s3,8(sp)
    80001fba:	6145                	addi	sp,sp,48
    80001fbc:	8082                	ret
    return -1;
    80001fbe:	557d                	li	a0,-1
    80001fc0:	bfc5                	j	80001fb0 <fetchstr+0x3a>

0000000080001fc2 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80001fc2:	1101                	addi	sp,sp,-32
    80001fc4:	ec06                	sd	ra,24(sp)
    80001fc6:	e822                	sd	s0,16(sp)
    80001fc8:	e426                	sd	s1,8(sp)
    80001fca:	1000                	addi	s0,sp,32
    80001fcc:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001fce:	00000097          	auipc	ra,0x0
    80001fd2:	eee080e7          	jalr	-274(ra) # 80001ebc <argraw>
    80001fd6:	c088                	sw	a0,0(s1)
}
    80001fd8:	60e2                	ld	ra,24(sp)
    80001fda:	6442                	ld	s0,16(sp)
    80001fdc:	64a2                	ld	s1,8(sp)
    80001fde:	6105                	addi	sp,sp,32
    80001fe0:	8082                	ret

0000000080001fe2 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80001fe2:	1101                	addi	sp,sp,-32
    80001fe4:	ec06                	sd	ra,24(sp)
    80001fe6:	e822                	sd	s0,16(sp)
    80001fe8:	e426                	sd	s1,8(sp)
    80001fea:	1000                	addi	s0,sp,32
    80001fec:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001fee:	00000097          	auipc	ra,0x0
    80001ff2:	ece080e7          	jalr	-306(ra) # 80001ebc <argraw>
    80001ff6:	e088                	sd	a0,0(s1)
}
    80001ff8:	60e2                	ld	ra,24(sp)
    80001ffa:	6442                	ld	s0,16(sp)
    80001ffc:	64a2                	ld	s1,8(sp)
    80001ffe:	6105                	addi	sp,sp,32
    80002000:	8082                	ret

0000000080002002 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002002:	7179                	addi	sp,sp,-48
    80002004:	f406                	sd	ra,40(sp)
    80002006:	f022                	sd	s0,32(sp)
    80002008:	ec26                	sd	s1,24(sp)
    8000200a:	e84a                	sd	s2,16(sp)
    8000200c:	1800                	addi	s0,sp,48
    8000200e:	84ae                	mv	s1,a1
    80002010:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002012:	fd840593          	addi	a1,s0,-40
    80002016:	00000097          	auipc	ra,0x0
    8000201a:	fcc080e7          	jalr	-52(ra) # 80001fe2 <argaddr>
  return fetchstr(addr, buf, max);
    8000201e:	864a                	mv	a2,s2
    80002020:	85a6                	mv	a1,s1
    80002022:	fd843503          	ld	a0,-40(s0)
    80002026:	00000097          	auipc	ra,0x0
    8000202a:	f50080e7          	jalr	-176(ra) # 80001f76 <fetchstr>
}
    8000202e:	70a2                	ld	ra,40(sp)
    80002030:	7402                	ld	s0,32(sp)
    80002032:	64e2                	ld	s1,24(sp)
    80002034:	6942                	ld	s2,16(sp)
    80002036:	6145                	addi	sp,sp,48
    80002038:	8082                	ret

000000008000203a <syscall>:
[SYS_sysinfo] 1 << SYS_sysinfo,
};

void
syscall(void)
{
    8000203a:	7179                	addi	sp,sp,-48
    8000203c:	f406                	sd	ra,40(sp)
    8000203e:	f022                	sd	s0,32(sp)
    80002040:	ec26                	sd	s1,24(sp)
    80002042:	e84a                	sd	s2,16(sp)
    80002044:	e44e                	sd	s3,8(sp)
    80002046:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80002048:	fffff097          	auipc	ra,0xfffff
    8000204c:	e34080e7          	jalr	-460(ra) # 80000e7c <myproc>
    80002050:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002052:	05853903          	ld	s2,88(a0)
    80002056:	0a893783          	ld	a5,168(s2)
    8000205a:	0007899b          	sext.w	s3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000205e:	37fd                	addiw	a5,a5,-1
    80002060:	4759                	li	a4,22
    80002062:	06f76063          	bltu	a4,a5,800020c2 <syscall+0x88>
    80002066:	00399713          	slli	a4,s3,0x3
    8000206a:	00006797          	auipc	a5,0x6
    8000206e:	42e78793          	addi	a5,a5,1070 # 80008498 <syscalls>
    80002072:	97ba                	add	a5,a5,a4
    80002074:	639c                	ld	a5,0(a5)
    80002076:	c7b1                	beqz	a5,800020c2 <syscall+0x88>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002078:	9782                	jalr	a5
    8000207a:	06a93823          	sd	a0,112(s2)

    if (p->trace_s & syscallmasks[num]) {
    8000207e:	00299793          	slli	a5,s3,0x2
    80002082:	00006717          	auipc	a4,0x6
    80002086:	41670713          	addi	a4,a4,1046 # 80008498 <syscalls>
    8000208a:	973e                	add	a4,a4,a5
    8000208c:	1684a783          	lw	a5,360(s1)
    80002090:	0c072703          	lw	a4,192(a4)
    80002094:	8ff9                	and	a5,a5,a4
    80002096:	2781                	sext.w	a5,a5
    80002098:	c7a1                	beqz	a5,800020e0 <syscall+0xa6>
      printf("%d: syscall %s -> %d\n", p->pid, syscallnames[num], p->trapframe->a0);
    8000209a:	6cb8                	ld	a4,88(s1)
    8000209c:	098e                	slli	s3,s3,0x3
    8000209e:	00006797          	auipc	a5,0x6
    800020a2:	3fa78793          	addi	a5,a5,1018 # 80008498 <syscalls>
    800020a6:	99be                	add	s3,s3,a5
    800020a8:	7b34                	ld	a3,112(a4)
    800020aa:	1209b603          	ld	a2,288(s3)
    800020ae:	588c                	lw	a1,48(s1)
    800020b0:	00006517          	auipc	a0,0x6
    800020b4:	2e850513          	addi	a0,a0,744 # 80008398 <states.1727+0x150>
    800020b8:	00004097          	auipc	ra,0x4
    800020bc:	c94080e7          	jalr	-876(ra) # 80005d4c <printf>
    800020c0:	a005                	j	800020e0 <syscall+0xa6>
    }
  } else {
    printf("%d %s: unknown sys call %d\n",
    800020c2:	86ce                	mv	a3,s3
    800020c4:	15848613          	addi	a2,s1,344
    800020c8:	588c                	lw	a1,48(s1)
    800020ca:	00006517          	auipc	a0,0x6
    800020ce:	2e650513          	addi	a0,a0,742 # 800083b0 <states.1727+0x168>
    800020d2:	00004097          	auipc	ra,0x4
    800020d6:	c7a080e7          	jalr	-902(ra) # 80005d4c <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800020da:	6cbc                	ld	a5,88(s1)
    800020dc:	577d                	li	a4,-1
    800020de:	fbb8                	sd	a4,112(a5)
  }
}
    800020e0:	70a2                	ld	ra,40(sp)
    800020e2:	7402                	ld	s0,32(sp)
    800020e4:	64e2                	ld	s1,24(sp)
    800020e6:	6942                	ld	s2,16(sp)
    800020e8:	69a2                	ld	s3,8(sp)
    800020ea:	6145                	addi	sp,sp,48
    800020ec:	8082                	ret

00000000800020ee <sys_exit>:
#include "proc.h"
#include "sysinfo.h"

uint64
sys_exit(void)
{
    800020ee:	1101                	addi	sp,sp,-32
    800020f0:	ec06                	sd	ra,24(sp)
    800020f2:	e822                	sd	s0,16(sp)
    800020f4:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800020f6:	fec40593          	addi	a1,s0,-20
    800020fa:	4501                	li	a0,0
    800020fc:	00000097          	auipc	ra,0x0
    80002100:	ec6080e7          	jalr	-314(ra) # 80001fc2 <argint>
  exit(n);
    80002104:	fec42503          	lw	a0,-20(s0)
    80002108:	fffff097          	auipc	ra,0xfffff
    8000210c:	554080e7          	jalr	1364(ra) # 8000165c <exit>
  return 0;  // not reached
}
    80002110:	4501                	li	a0,0
    80002112:	60e2                	ld	ra,24(sp)
    80002114:	6442                	ld	s0,16(sp)
    80002116:	6105                	addi	sp,sp,32
    80002118:	8082                	ret

000000008000211a <sys_getpid>:

uint64
sys_getpid(void)
{
    8000211a:	1141                	addi	sp,sp,-16
    8000211c:	e406                	sd	ra,8(sp)
    8000211e:	e022                	sd	s0,0(sp)
    80002120:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002122:	fffff097          	auipc	ra,0xfffff
    80002126:	d5a080e7          	jalr	-678(ra) # 80000e7c <myproc>
}
    8000212a:	5908                	lw	a0,48(a0)
    8000212c:	60a2                	ld	ra,8(sp)
    8000212e:	6402                	ld	s0,0(sp)
    80002130:	0141                	addi	sp,sp,16
    80002132:	8082                	ret

0000000080002134 <sys_fork>:

uint64
sys_fork(void)
{
    80002134:	1141                	addi	sp,sp,-16
    80002136:	e406                	sd	ra,8(sp)
    80002138:	e022                	sd	s0,0(sp)
    8000213a:	0800                	addi	s0,sp,16
  return fork();
    8000213c:	fffff097          	auipc	ra,0xfffff
    80002140:	0f6080e7          	jalr	246(ra) # 80001232 <fork>
}
    80002144:	60a2                	ld	ra,8(sp)
    80002146:	6402                	ld	s0,0(sp)
    80002148:	0141                	addi	sp,sp,16
    8000214a:	8082                	ret

000000008000214c <sys_wait>:

uint64
sys_wait(void)
{
    8000214c:	1101                	addi	sp,sp,-32
    8000214e:	ec06                	sd	ra,24(sp)
    80002150:	e822                	sd	s0,16(sp)
    80002152:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002154:	fe840593          	addi	a1,s0,-24
    80002158:	4501                	li	a0,0
    8000215a:	00000097          	auipc	ra,0x0
    8000215e:	e88080e7          	jalr	-376(ra) # 80001fe2 <argaddr>
  return wait(p);
    80002162:	fe843503          	ld	a0,-24(s0)
    80002166:	fffff097          	auipc	ra,0xfffff
    8000216a:	69c080e7          	jalr	1692(ra) # 80001802 <wait>
}
    8000216e:	60e2                	ld	ra,24(sp)
    80002170:	6442                	ld	s0,16(sp)
    80002172:	6105                	addi	sp,sp,32
    80002174:	8082                	ret

0000000080002176 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002176:	7179                	addi	sp,sp,-48
    80002178:	f406                	sd	ra,40(sp)
    8000217a:	f022                	sd	s0,32(sp)
    8000217c:	ec26                	sd	s1,24(sp)
    8000217e:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002180:	fdc40593          	addi	a1,s0,-36
    80002184:	4501                	li	a0,0
    80002186:	00000097          	auipc	ra,0x0
    8000218a:	e3c080e7          	jalr	-452(ra) # 80001fc2 <argint>
  addr = myproc()->sz;
    8000218e:	fffff097          	auipc	ra,0xfffff
    80002192:	cee080e7          	jalr	-786(ra) # 80000e7c <myproc>
    80002196:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002198:	fdc42503          	lw	a0,-36(s0)
    8000219c:	fffff097          	auipc	ra,0xfffff
    800021a0:	03a080e7          	jalr	58(ra) # 800011d6 <growproc>
    800021a4:	00054863          	bltz	a0,800021b4 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    800021a8:	8526                	mv	a0,s1
    800021aa:	70a2                	ld	ra,40(sp)
    800021ac:	7402                	ld	s0,32(sp)
    800021ae:	64e2                	ld	s1,24(sp)
    800021b0:	6145                	addi	sp,sp,48
    800021b2:	8082                	ret
    return -1;
    800021b4:	54fd                	li	s1,-1
    800021b6:	bfcd                	j	800021a8 <sys_sbrk+0x32>

00000000800021b8 <sys_sleep>:

uint64
sys_sleep(void)
{
    800021b8:	7139                	addi	sp,sp,-64
    800021ba:	fc06                	sd	ra,56(sp)
    800021bc:	f822                	sd	s0,48(sp)
    800021be:	f426                	sd	s1,40(sp)
    800021c0:	f04a                	sd	s2,32(sp)
    800021c2:	ec4e                	sd	s3,24(sp)
    800021c4:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800021c6:	fcc40593          	addi	a1,s0,-52
    800021ca:	4501                	li	a0,0
    800021cc:	00000097          	auipc	ra,0x0
    800021d0:	df6080e7          	jalr	-522(ra) # 80001fc2 <argint>
  if(n < 0)
    800021d4:	fcc42783          	lw	a5,-52(s0)
    800021d8:	0607cf63          	bltz	a5,80002256 <sys_sleep+0x9e>
    n = 0;
  acquire(&tickslock);
    800021dc:	0000d517          	auipc	a0,0xd
    800021e0:	94450513          	addi	a0,a0,-1724 # 8000eb20 <tickslock>
    800021e4:	00004097          	auipc	ra,0x4
    800021e8:	068080e7          	jalr	104(ra) # 8000624c <acquire>
  ticks0 = ticks;
    800021ec:	00007917          	auipc	s2,0x7
    800021f0:	8cc92903          	lw	s2,-1844(s2) # 80008ab8 <ticks>
  while(ticks - ticks0 < n){
    800021f4:	fcc42783          	lw	a5,-52(s0)
    800021f8:	cf9d                	beqz	a5,80002236 <sys_sleep+0x7e>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800021fa:	0000d997          	auipc	s3,0xd
    800021fe:	92698993          	addi	s3,s3,-1754 # 8000eb20 <tickslock>
    80002202:	00007497          	auipc	s1,0x7
    80002206:	8b648493          	addi	s1,s1,-1866 # 80008ab8 <ticks>
    if(killed(myproc())){
    8000220a:	fffff097          	auipc	ra,0xfffff
    8000220e:	c72080e7          	jalr	-910(ra) # 80000e7c <myproc>
    80002212:	fffff097          	auipc	ra,0xfffff
    80002216:	5be080e7          	jalr	1470(ra) # 800017d0 <killed>
    8000221a:	e129                	bnez	a0,8000225c <sys_sleep+0xa4>
    sleep(&ticks, &tickslock);
    8000221c:	85ce                	mv	a1,s3
    8000221e:	8526                	mv	a0,s1
    80002220:	fffff097          	auipc	ra,0xfffff
    80002224:	308080e7          	jalr	776(ra) # 80001528 <sleep>
  while(ticks - ticks0 < n){
    80002228:	409c                	lw	a5,0(s1)
    8000222a:	412787bb          	subw	a5,a5,s2
    8000222e:	fcc42703          	lw	a4,-52(s0)
    80002232:	fce7ece3          	bltu	a5,a4,8000220a <sys_sleep+0x52>
  }
  release(&tickslock);
    80002236:	0000d517          	auipc	a0,0xd
    8000223a:	8ea50513          	addi	a0,a0,-1814 # 8000eb20 <tickslock>
    8000223e:	00004097          	auipc	ra,0x4
    80002242:	0c2080e7          	jalr	194(ra) # 80006300 <release>
  return 0;
    80002246:	4501                	li	a0,0
}
    80002248:	70e2                	ld	ra,56(sp)
    8000224a:	7442                	ld	s0,48(sp)
    8000224c:	74a2                	ld	s1,40(sp)
    8000224e:	7902                	ld	s2,32(sp)
    80002250:	69e2                	ld	s3,24(sp)
    80002252:	6121                	addi	sp,sp,64
    80002254:	8082                	ret
    n = 0;
    80002256:	fc042623          	sw	zero,-52(s0)
    8000225a:	b749                	j	800021dc <sys_sleep+0x24>
      release(&tickslock);
    8000225c:	0000d517          	auipc	a0,0xd
    80002260:	8c450513          	addi	a0,a0,-1852 # 8000eb20 <tickslock>
    80002264:	00004097          	auipc	ra,0x4
    80002268:	09c080e7          	jalr	156(ra) # 80006300 <release>
      return -1;
    8000226c:	557d                	li	a0,-1
    8000226e:	bfe9                	j	80002248 <sys_sleep+0x90>

0000000080002270 <sys_kill>:

uint64
sys_kill(void)
{
    80002270:	1101                	addi	sp,sp,-32
    80002272:	ec06                	sd	ra,24(sp)
    80002274:	e822                	sd	s0,16(sp)
    80002276:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002278:	fec40593          	addi	a1,s0,-20
    8000227c:	4501                	li	a0,0
    8000227e:	00000097          	auipc	ra,0x0
    80002282:	d44080e7          	jalr	-700(ra) # 80001fc2 <argint>
  return kill(pid);
    80002286:	fec42503          	lw	a0,-20(s0)
    8000228a:	fffff097          	auipc	ra,0xfffff
    8000228e:	4a8080e7          	jalr	1192(ra) # 80001732 <kill>
}
    80002292:	60e2                	ld	ra,24(sp)
    80002294:	6442                	ld	s0,16(sp)
    80002296:	6105                	addi	sp,sp,32
    80002298:	8082                	ret

000000008000229a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000229a:	1101                	addi	sp,sp,-32
    8000229c:	ec06                	sd	ra,24(sp)
    8000229e:	e822                	sd	s0,16(sp)
    800022a0:	e426                	sd	s1,8(sp)
    800022a2:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800022a4:	0000d517          	auipc	a0,0xd
    800022a8:	87c50513          	addi	a0,a0,-1924 # 8000eb20 <tickslock>
    800022ac:	00004097          	auipc	ra,0x4
    800022b0:	fa0080e7          	jalr	-96(ra) # 8000624c <acquire>
  xticks = ticks;
    800022b4:	00007497          	auipc	s1,0x7
    800022b8:	8044a483          	lw	s1,-2044(s1) # 80008ab8 <ticks>
  release(&tickslock);
    800022bc:	0000d517          	auipc	a0,0xd
    800022c0:	86450513          	addi	a0,a0,-1948 # 8000eb20 <tickslock>
    800022c4:	00004097          	auipc	ra,0x4
    800022c8:	03c080e7          	jalr	60(ra) # 80006300 <release>
  return xticks;
}
    800022cc:	02049513          	slli	a0,s1,0x20
    800022d0:	9101                	srli	a0,a0,0x20
    800022d2:	60e2                	ld	ra,24(sp)
    800022d4:	6442                	ld	s0,16(sp)
    800022d6:	64a2                	ld	s1,8(sp)
    800022d8:	6105                	addi	sp,sp,32
    800022da:	8082                	ret

00000000800022dc <sys_trace>:

uint64
sys_trace(void)
{
    800022dc:	1101                	addi	sp,sp,-32
    800022de:	ec06                	sd	ra,24(sp)
    800022e0:	e822                	sd	s0,16(sp)
    800022e2:	1000                	addi	s0,sp,32
  int trace_s;

  argint(0, &trace_s);
    800022e4:	fec40593          	addi	a1,s0,-20
    800022e8:	4501                	li	a0,0
    800022ea:	00000097          	auipc	ra,0x0
    800022ee:	cd8080e7          	jalr	-808(ra) # 80001fc2 <argint>

  myproc()->trace_s = trace_s;
    800022f2:	fffff097          	auipc	ra,0xfffff
    800022f6:	b8a080e7          	jalr	-1142(ra) # 80000e7c <myproc>
    800022fa:	fec42783          	lw	a5,-20(s0)
    800022fe:	16f52423          	sw	a5,360(a0)

  return 0;
}
    80002302:	4501                	li	a0,0
    80002304:	60e2                	ld	ra,24(sp)
    80002306:	6442                	ld	s0,16(sp)
    80002308:	6105                	addi	sp,sp,32
    8000230a:	8082                	ret

000000008000230c <sys_sysinfo>:

uint64
sys_sysinfo(void) {
    8000230c:	7179                	addi	sp,sp,-48
    8000230e:	f406                	sd	ra,40(sp)
    80002310:	f022                	sd	s0,32(sp)
    80002312:	1800                	addi	s0,sp,48

  uint64 addr;

  argaddr(0, &addr);
    80002314:	fe840593          	addi	a1,s0,-24
    80002318:	4501                	li	a0,0
    8000231a:	00000097          	auipc	ra,0x0
    8000231e:	cc8080e7          	jalr	-824(ra) # 80001fe2 <argaddr>

  struct sysinfo info;

  info.freemem = freesize();
    80002322:	ffffe097          	auipc	ra,0xffffe
    80002326:	e56080e7          	jalr	-426(ra) # 80000178 <freesize>
    8000232a:	fca43c23          	sd	a0,-40(s0)
  info.nproc = procused();
    8000232e:	fffff097          	auipc	ra,0xfffff
    80002332:	75c080e7          	jalr	1884(ra) # 80001a8a <procused>
    80002336:	fea43023          	sd	a0,-32(s0)

  if (copyout(myproc()->pagetable, addr, (char *)&info, sizeof(info)) < 0) {
    8000233a:	fffff097          	auipc	ra,0xfffff
    8000233e:	b42080e7          	jalr	-1214(ra) # 80000e7c <myproc>
    80002342:	46c1                	li	a3,16
    80002344:	fd840613          	addi	a2,s0,-40
    80002348:	fe843583          	ld	a1,-24(s0)
    8000234c:	6928                	ld	a0,80(a0)
    8000234e:	ffffe097          	auipc	ra,0xffffe
    80002352:	7ec080e7          	jalr	2028(ra) # 80000b3a <copyout>
    return -1;
  }

  return 0;
    80002356:	957d                	srai	a0,a0,0x3f
    80002358:	70a2                	ld	ra,40(sp)
    8000235a:	7402                	ld	s0,32(sp)
    8000235c:	6145                	addi	sp,sp,48
    8000235e:	8082                	ret

0000000080002360 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002360:	7179                	addi	sp,sp,-48
    80002362:	f406                	sd	ra,40(sp)
    80002364:	f022                	sd	s0,32(sp)
    80002366:	ec26                	sd	s1,24(sp)
    80002368:	e84a                	sd	s2,16(sp)
    8000236a:	e44e                	sd	s3,8(sp)
    8000236c:	e052                	sd	s4,0(sp)
    8000236e:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002370:	00006597          	auipc	a1,0x6
    80002374:	30858593          	addi	a1,a1,776 # 80008678 <syscallnames+0xc0>
    80002378:	0000c517          	auipc	a0,0xc
    8000237c:	7c050513          	addi	a0,a0,1984 # 8000eb38 <bcache>
    80002380:	00004097          	auipc	ra,0x4
    80002384:	e3c080e7          	jalr	-452(ra) # 800061bc <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002388:	00014797          	auipc	a5,0x14
    8000238c:	7b078793          	addi	a5,a5,1968 # 80016b38 <bcache+0x8000>
    80002390:	00015717          	auipc	a4,0x15
    80002394:	a1070713          	addi	a4,a4,-1520 # 80016da0 <bcache+0x8268>
    80002398:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000239c:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800023a0:	0000c497          	auipc	s1,0xc
    800023a4:	7b048493          	addi	s1,s1,1968 # 8000eb50 <bcache+0x18>
    b->next = bcache.head.next;
    800023a8:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800023aa:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800023ac:	00006a17          	auipc	s4,0x6
    800023b0:	2d4a0a13          	addi	s4,s4,724 # 80008680 <syscallnames+0xc8>
    b->next = bcache.head.next;
    800023b4:	2b893783          	ld	a5,696(s2)
    800023b8:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800023ba:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800023be:	85d2                	mv	a1,s4
    800023c0:	01048513          	addi	a0,s1,16
    800023c4:	00001097          	auipc	ra,0x1
    800023c8:	4c4080e7          	jalr	1220(ra) # 80003888 <initsleeplock>
    bcache.head.next->prev = b;
    800023cc:	2b893783          	ld	a5,696(s2)
    800023d0:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800023d2:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800023d6:	45848493          	addi	s1,s1,1112
    800023da:	fd349de3          	bne	s1,s3,800023b4 <binit+0x54>
  }
}
    800023de:	70a2                	ld	ra,40(sp)
    800023e0:	7402                	ld	s0,32(sp)
    800023e2:	64e2                	ld	s1,24(sp)
    800023e4:	6942                	ld	s2,16(sp)
    800023e6:	69a2                	ld	s3,8(sp)
    800023e8:	6a02                	ld	s4,0(sp)
    800023ea:	6145                	addi	sp,sp,48
    800023ec:	8082                	ret

00000000800023ee <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800023ee:	7179                	addi	sp,sp,-48
    800023f0:	f406                	sd	ra,40(sp)
    800023f2:	f022                	sd	s0,32(sp)
    800023f4:	ec26                	sd	s1,24(sp)
    800023f6:	e84a                	sd	s2,16(sp)
    800023f8:	e44e                	sd	s3,8(sp)
    800023fa:	1800                	addi	s0,sp,48
    800023fc:	89aa                	mv	s3,a0
    800023fe:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80002400:	0000c517          	auipc	a0,0xc
    80002404:	73850513          	addi	a0,a0,1848 # 8000eb38 <bcache>
    80002408:	00004097          	auipc	ra,0x4
    8000240c:	e44080e7          	jalr	-444(ra) # 8000624c <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002410:	00015497          	auipc	s1,0x15
    80002414:	9e04b483          	ld	s1,-1568(s1) # 80016df0 <bcache+0x82b8>
    80002418:	00015797          	auipc	a5,0x15
    8000241c:	98878793          	addi	a5,a5,-1656 # 80016da0 <bcache+0x8268>
    80002420:	02f48f63          	beq	s1,a5,8000245e <bread+0x70>
    80002424:	873e                	mv	a4,a5
    80002426:	a021                	j	8000242e <bread+0x40>
    80002428:	68a4                	ld	s1,80(s1)
    8000242a:	02e48a63          	beq	s1,a4,8000245e <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    8000242e:	449c                	lw	a5,8(s1)
    80002430:	ff379ce3          	bne	a5,s3,80002428 <bread+0x3a>
    80002434:	44dc                	lw	a5,12(s1)
    80002436:	ff2799e3          	bne	a5,s2,80002428 <bread+0x3a>
      b->refcnt++;
    8000243a:	40bc                	lw	a5,64(s1)
    8000243c:	2785                	addiw	a5,a5,1
    8000243e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002440:	0000c517          	auipc	a0,0xc
    80002444:	6f850513          	addi	a0,a0,1784 # 8000eb38 <bcache>
    80002448:	00004097          	auipc	ra,0x4
    8000244c:	eb8080e7          	jalr	-328(ra) # 80006300 <release>
      acquiresleep(&b->lock);
    80002450:	01048513          	addi	a0,s1,16
    80002454:	00001097          	auipc	ra,0x1
    80002458:	46e080e7          	jalr	1134(ra) # 800038c2 <acquiresleep>
      return b;
    8000245c:	a8b9                	j	800024ba <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000245e:	00015497          	auipc	s1,0x15
    80002462:	98a4b483          	ld	s1,-1654(s1) # 80016de8 <bcache+0x82b0>
    80002466:	00015797          	auipc	a5,0x15
    8000246a:	93a78793          	addi	a5,a5,-1734 # 80016da0 <bcache+0x8268>
    8000246e:	00f48863          	beq	s1,a5,8000247e <bread+0x90>
    80002472:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002474:	40bc                	lw	a5,64(s1)
    80002476:	cf81                	beqz	a5,8000248e <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002478:	64a4                	ld	s1,72(s1)
    8000247a:	fee49de3          	bne	s1,a4,80002474 <bread+0x86>
  panic("bget: no buffers");
    8000247e:	00006517          	auipc	a0,0x6
    80002482:	20a50513          	addi	a0,a0,522 # 80008688 <syscallnames+0xd0>
    80002486:	00004097          	auipc	ra,0x4
    8000248a:	87c080e7          	jalr	-1924(ra) # 80005d02 <panic>
      b->dev = dev;
    8000248e:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    80002492:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80002496:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000249a:	4785                	li	a5,1
    8000249c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000249e:	0000c517          	auipc	a0,0xc
    800024a2:	69a50513          	addi	a0,a0,1690 # 8000eb38 <bcache>
    800024a6:	00004097          	auipc	ra,0x4
    800024aa:	e5a080e7          	jalr	-422(ra) # 80006300 <release>
      acquiresleep(&b->lock);
    800024ae:	01048513          	addi	a0,s1,16
    800024b2:	00001097          	auipc	ra,0x1
    800024b6:	410080e7          	jalr	1040(ra) # 800038c2 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800024ba:	409c                	lw	a5,0(s1)
    800024bc:	cb89                	beqz	a5,800024ce <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800024be:	8526                	mv	a0,s1
    800024c0:	70a2                	ld	ra,40(sp)
    800024c2:	7402                	ld	s0,32(sp)
    800024c4:	64e2                	ld	s1,24(sp)
    800024c6:	6942                	ld	s2,16(sp)
    800024c8:	69a2                	ld	s3,8(sp)
    800024ca:	6145                	addi	sp,sp,48
    800024cc:	8082                	ret
    virtio_disk_rw(b, 0);
    800024ce:	4581                	li	a1,0
    800024d0:	8526                	mv	a0,s1
    800024d2:	00003097          	auipc	ra,0x3
    800024d6:	fc6080e7          	jalr	-58(ra) # 80005498 <virtio_disk_rw>
    b->valid = 1;
    800024da:	4785                	li	a5,1
    800024dc:	c09c                	sw	a5,0(s1)
  return b;
    800024de:	b7c5                	j	800024be <bread+0xd0>

00000000800024e0 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800024e0:	1101                	addi	sp,sp,-32
    800024e2:	ec06                	sd	ra,24(sp)
    800024e4:	e822                	sd	s0,16(sp)
    800024e6:	e426                	sd	s1,8(sp)
    800024e8:	1000                	addi	s0,sp,32
    800024ea:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800024ec:	0541                	addi	a0,a0,16
    800024ee:	00001097          	auipc	ra,0x1
    800024f2:	46e080e7          	jalr	1134(ra) # 8000395c <holdingsleep>
    800024f6:	cd01                	beqz	a0,8000250e <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800024f8:	4585                	li	a1,1
    800024fa:	8526                	mv	a0,s1
    800024fc:	00003097          	auipc	ra,0x3
    80002500:	f9c080e7          	jalr	-100(ra) # 80005498 <virtio_disk_rw>
}
    80002504:	60e2                	ld	ra,24(sp)
    80002506:	6442                	ld	s0,16(sp)
    80002508:	64a2                	ld	s1,8(sp)
    8000250a:	6105                	addi	sp,sp,32
    8000250c:	8082                	ret
    panic("bwrite");
    8000250e:	00006517          	auipc	a0,0x6
    80002512:	19250513          	addi	a0,a0,402 # 800086a0 <syscallnames+0xe8>
    80002516:	00003097          	auipc	ra,0x3
    8000251a:	7ec080e7          	jalr	2028(ra) # 80005d02 <panic>

000000008000251e <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000251e:	1101                	addi	sp,sp,-32
    80002520:	ec06                	sd	ra,24(sp)
    80002522:	e822                	sd	s0,16(sp)
    80002524:	e426                	sd	s1,8(sp)
    80002526:	e04a                	sd	s2,0(sp)
    80002528:	1000                	addi	s0,sp,32
    8000252a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000252c:	01050913          	addi	s2,a0,16
    80002530:	854a                	mv	a0,s2
    80002532:	00001097          	auipc	ra,0x1
    80002536:	42a080e7          	jalr	1066(ra) # 8000395c <holdingsleep>
    8000253a:	c92d                	beqz	a0,800025ac <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000253c:	854a                	mv	a0,s2
    8000253e:	00001097          	auipc	ra,0x1
    80002542:	3da080e7          	jalr	986(ra) # 80003918 <releasesleep>

  acquire(&bcache.lock);
    80002546:	0000c517          	auipc	a0,0xc
    8000254a:	5f250513          	addi	a0,a0,1522 # 8000eb38 <bcache>
    8000254e:	00004097          	auipc	ra,0x4
    80002552:	cfe080e7          	jalr	-770(ra) # 8000624c <acquire>
  b->refcnt--;
    80002556:	40bc                	lw	a5,64(s1)
    80002558:	37fd                	addiw	a5,a5,-1
    8000255a:	0007871b          	sext.w	a4,a5
    8000255e:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002560:	eb05                	bnez	a4,80002590 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002562:	68bc                	ld	a5,80(s1)
    80002564:	64b8                	ld	a4,72(s1)
    80002566:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002568:	64bc                	ld	a5,72(s1)
    8000256a:	68b8                	ld	a4,80(s1)
    8000256c:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000256e:	00014797          	auipc	a5,0x14
    80002572:	5ca78793          	addi	a5,a5,1482 # 80016b38 <bcache+0x8000>
    80002576:	2b87b703          	ld	a4,696(a5)
    8000257a:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000257c:	00015717          	auipc	a4,0x15
    80002580:	82470713          	addi	a4,a4,-2012 # 80016da0 <bcache+0x8268>
    80002584:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002586:	2b87b703          	ld	a4,696(a5)
    8000258a:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000258c:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002590:	0000c517          	auipc	a0,0xc
    80002594:	5a850513          	addi	a0,a0,1448 # 8000eb38 <bcache>
    80002598:	00004097          	auipc	ra,0x4
    8000259c:	d68080e7          	jalr	-664(ra) # 80006300 <release>
}
    800025a0:	60e2                	ld	ra,24(sp)
    800025a2:	6442                	ld	s0,16(sp)
    800025a4:	64a2                	ld	s1,8(sp)
    800025a6:	6902                	ld	s2,0(sp)
    800025a8:	6105                	addi	sp,sp,32
    800025aa:	8082                	ret
    panic("brelse");
    800025ac:	00006517          	auipc	a0,0x6
    800025b0:	0fc50513          	addi	a0,a0,252 # 800086a8 <syscallnames+0xf0>
    800025b4:	00003097          	auipc	ra,0x3
    800025b8:	74e080e7          	jalr	1870(ra) # 80005d02 <panic>

00000000800025bc <bpin>:

void
bpin(struct buf *b) {
    800025bc:	1101                	addi	sp,sp,-32
    800025be:	ec06                	sd	ra,24(sp)
    800025c0:	e822                	sd	s0,16(sp)
    800025c2:	e426                	sd	s1,8(sp)
    800025c4:	1000                	addi	s0,sp,32
    800025c6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800025c8:	0000c517          	auipc	a0,0xc
    800025cc:	57050513          	addi	a0,a0,1392 # 8000eb38 <bcache>
    800025d0:	00004097          	auipc	ra,0x4
    800025d4:	c7c080e7          	jalr	-900(ra) # 8000624c <acquire>
  b->refcnt++;
    800025d8:	40bc                	lw	a5,64(s1)
    800025da:	2785                	addiw	a5,a5,1
    800025dc:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800025de:	0000c517          	auipc	a0,0xc
    800025e2:	55a50513          	addi	a0,a0,1370 # 8000eb38 <bcache>
    800025e6:	00004097          	auipc	ra,0x4
    800025ea:	d1a080e7          	jalr	-742(ra) # 80006300 <release>
}
    800025ee:	60e2                	ld	ra,24(sp)
    800025f0:	6442                	ld	s0,16(sp)
    800025f2:	64a2                	ld	s1,8(sp)
    800025f4:	6105                	addi	sp,sp,32
    800025f6:	8082                	ret

00000000800025f8 <bunpin>:

void
bunpin(struct buf *b) {
    800025f8:	1101                	addi	sp,sp,-32
    800025fa:	ec06                	sd	ra,24(sp)
    800025fc:	e822                	sd	s0,16(sp)
    800025fe:	e426                	sd	s1,8(sp)
    80002600:	1000                	addi	s0,sp,32
    80002602:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002604:	0000c517          	auipc	a0,0xc
    80002608:	53450513          	addi	a0,a0,1332 # 8000eb38 <bcache>
    8000260c:	00004097          	auipc	ra,0x4
    80002610:	c40080e7          	jalr	-960(ra) # 8000624c <acquire>
  b->refcnt--;
    80002614:	40bc                	lw	a5,64(s1)
    80002616:	37fd                	addiw	a5,a5,-1
    80002618:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000261a:	0000c517          	auipc	a0,0xc
    8000261e:	51e50513          	addi	a0,a0,1310 # 8000eb38 <bcache>
    80002622:	00004097          	auipc	ra,0x4
    80002626:	cde080e7          	jalr	-802(ra) # 80006300 <release>
}
    8000262a:	60e2                	ld	ra,24(sp)
    8000262c:	6442                	ld	s0,16(sp)
    8000262e:	64a2                	ld	s1,8(sp)
    80002630:	6105                	addi	sp,sp,32
    80002632:	8082                	ret

0000000080002634 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002634:	1101                	addi	sp,sp,-32
    80002636:	ec06                	sd	ra,24(sp)
    80002638:	e822                	sd	s0,16(sp)
    8000263a:	e426                	sd	s1,8(sp)
    8000263c:	e04a                	sd	s2,0(sp)
    8000263e:	1000                	addi	s0,sp,32
    80002640:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002642:	00d5d59b          	srliw	a1,a1,0xd
    80002646:	00015797          	auipc	a5,0x15
    8000264a:	bce7a783          	lw	a5,-1074(a5) # 80017214 <sb+0x1c>
    8000264e:	9dbd                	addw	a1,a1,a5
    80002650:	00000097          	auipc	ra,0x0
    80002654:	d9e080e7          	jalr	-610(ra) # 800023ee <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002658:	0074f713          	andi	a4,s1,7
    8000265c:	4785                	li	a5,1
    8000265e:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002662:	14ce                	slli	s1,s1,0x33
    80002664:	90d9                	srli	s1,s1,0x36
    80002666:	00950733          	add	a4,a0,s1
    8000266a:	05874703          	lbu	a4,88(a4)
    8000266e:	00e7f6b3          	and	a3,a5,a4
    80002672:	c69d                	beqz	a3,800026a0 <bfree+0x6c>
    80002674:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002676:	94aa                	add	s1,s1,a0
    80002678:	fff7c793          	not	a5,a5
    8000267c:	8ff9                	and	a5,a5,a4
    8000267e:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80002682:	00001097          	auipc	ra,0x1
    80002686:	120080e7          	jalr	288(ra) # 800037a2 <log_write>
  brelse(bp);
    8000268a:	854a                	mv	a0,s2
    8000268c:	00000097          	auipc	ra,0x0
    80002690:	e92080e7          	jalr	-366(ra) # 8000251e <brelse>
}
    80002694:	60e2                	ld	ra,24(sp)
    80002696:	6442                	ld	s0,16(sp)
    80002698:	64a2                	ld	s1,8(sp)
    8000269a:	6902                	ld	s2,0(sp)
    8000269c:	6105                	addi	sp,sp,32
    8000269e:	8082                	ret
    panic("freeing free block");
    800026a0:	00006517          	auipc	a0,0x6
    800026a4:	01050513          	addi	a0,a0,16 # 800086b0 <syscallnames+0xf8>
    800026a8:	00003097          	auipc	ra,0x3
    800026ac:	65a080e7          	jalr	1626(ra) # 80005d02 <panic>

00000000800026b0 <balloc>:
{
    800026b0:	711d                	addi	sp,sp,-96
    800026b2:	ec86                	sd	ra,88(sp)
    800026b4:	e8a2                	sd	s0,80(sp)
    800026b6:	e4a6                	sd	s1,72(sp)
    800026b8:	e0ca                	sd	s2,64(sp)
    800026ba:	fc4e                	sd	s3,56(sp)
    800026bc:	f852                	sd	s4,48(sp)
    800026be:	f456                	sd	s5,40(sp)
    800026c0:	f05a                	sd	s6,32(sp)
    800026c2:	ec5e                	sd	s7,24(sp)
    800026c4:	e862                	sd	s8,16(sp)
    800026c6:	e466                	sd	s9,8(sp)
    800026c8:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800026ca:	00015797          	auipc	a5,0x15
    800026ce:	b327a783          	lw	a5,-1230(a5) # 800171fc <sb+0x4>
    800026d2:	10078163          	beqz	a5,800027d4 <balloc+0x124>
    800026d6:	8baa                	mv	s7,a0
    800026d8:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800026da:	00015b17          	auipc	s6,0x15
    800026de:	b1eb0b13          	addi	s6,s6,-1250 # 800171f8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800026e2:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800026e4:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800026e6:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800026e8:	6c89                	lui	s9,0x2
    800026ea:	a061                	j	80002772 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    800026ec:	974a                	add	a4,a4,s2
    800026ee:	8fd5                	or	a5,a5,a3
    800026f0:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800026f4:	854a                	mv	a0,s2
    800026f6:	00001097          	auipc	ra,0x1
    800026fa:	0ac080e7          	jalr	172(ra) # 800037a2 <log_write>
        brelse(bp);
    800026fe:	854a                	mv	a0,s2
    80002700:	00000097          	auipc	ra,0x0
    80002704:	e1e080e7          	jalr	-482(ra) # 8000251e <brelse>
  bp = bread(dev, bno);
    80002708:	85a6                	mv	a1,s1
    8000270a:	855e                	mv	a0,s7
    8000270c:	00000097          	auipc	ra,0x0
    80002710:	ce2080e7          	jalr	-798(ra) # 800023ee <bread>
    80002714:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002716:	40000613          	li	a2,1024
    8000271a:	4581                	li	a1,0
    8000271c:	05850513          	addi	a0,a0,88
    80002720:	ffffe097          	auipc	ra,0xffffe
    80002724:	a7c080e7          	jalr	-1412(ra) # 8000019c <memset>
  log_write(bp);
    80002728:	854a                	mv	a0,s2
    8000272a:	00001097          	auipc	ra,0x1
    8000272e:	078080e7          	jalr	120(ra) # 800037a2 <log_write>
  brelse(bp);
    80002732:	854a                	mv	a0,s2
    80002734:	00000097          	auipc	ra,0x0
    80002738:	dea080e7          	jalr	-534(ra) # 8000251e <brelse>
}
    8000273c:	8526                	mv	a0,s1
    8000273e:	60e6                	ld	ra,88(sp)
    80002740:	6446                	ld	s0,80(sp)
    80002742:	64a6                	ld	s1,72(sp)
    80002744:	6906                	ld	s2,64(sp)
    80002746:	79e2                	ld	s3,56(sp)
    80002748:	7a42                	ld	s4,48(sp)
    8000274a:	7aa2                	ld	s5,40(sp)
    8000274c:	7b02                	ld	s6,32(sp)
    8000274e:	6be2                	ld	s7,24(sp)
    80002750:	6c42                	ld	s8,16(sp)
    80002752:	6ca2                	ld	s9,8(sp)
    80002754:	6125                	addi	sp,sp,96
    80002756:	8082                	ret
    brelse(bp);
    80002758:	854a                	mv	a0,s2
    8000275a:	00000097          	auipc	ra,0x0
    8000275e:	dc4080e7          	jalr	-572(ra) # 8000251e <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002762:	015c87bb          	addw	a5,s9,s5
    80002766:	00078a9b          	sext.w	s5,a5
    8000276a:	004b2703          	lw	a4,4(s6)
    8000276e:	06eaf363          	bgeu	s5,a4,800027d4 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    80002772:	41fad79b          	sraiw	a5,s5,0x1f
    80002776:	0137d79b          	srliw	a5,a5,0x13
    8000277a:	015787bb          	addw	a5,a5,s5
    8000277e:	40d7d79b          	sraiw	a5,a5,0xd
    80002782:	01cb2583          	lw	a1,28(s6)
    80002786:	9dbd                	addw	a1,a1,a5
    80002788:	855e                	mv	a0,s7
    8000278a:	00000097          	auipc	ra,0x0
    8000278e:	c64080e7          	jalr	-924(ra) # 800023ee <bread>
    80002792:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002794:	004b2503          	lw	a0,4(s6)
    80002798:	000a849b          	sext.w	s1,s5
    8000279c:	8662                	mv	a2,s8
    8000279e:	faa4fde3          	bgeu	s1,a0,80002758 <balloc+0xa8>
      m = 1 << (bi % 8);
    800027a2:	41f6579b          	sraiw	a5,a2,0x1f
    800027a6:	01d7d69b          	srliw	a3,a5,0x1d
    800027aa:	00c6873b          	addw	a4,a3,a2
    800027ae:	00777793          	andi	a5,a4,7
    800027b2:	9f95                	subw	a5,a5,a3
    800027b4:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800027b8:	4037571b          	sraiw	a4,a4,0x3
    800027bc:	00e906b3          	add	a3,s2,a4
    800027c0:	0586c683          	lbu	a3,88(a3)
    800027c4:	00d7f5b3          	and	a1,a5,a3
    800027c8:	d195                	beqz	a1,800026ec <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800027ca:	2605                	addiw	a2,a2,1
    800027cc:	2485                	addiw	s1,s1,1
    800027ce:	fd4618e3          	bne	a2,s4,8000279e <balloc+0xee>
    800027d2:	b759                	j	80002758 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    800027d4:	00006517          	auipc	a0,0x6
    800027d8:	ef450513          	addi	a0,a0,-268 # 800086c8 <syscallnames+0x110>
    800027dc:	00003097          	auipc	ra,0x3
    800027e0:	570080e7          	jalr	1392(ra) # 80005d4c <printf>
  return 0;
    800027e4:	4481                	li	s1,0
    800027e6:	bf99                	j	8000273c <balloc+0x8c>

00000000800027e8 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800027e8:	7179                	addi	sp,sp,-48
    800027ea:	f406                	sd	ra,40(sp)
    800027ec:	f022                	sd	s0,32(sp)
    800027ee:	ec26                	sd	s1,24(sp)
    800027f0:	e84a                	sd	s2,16(sp)
    800027f2:	e44e                	sd	s3,8(sp)
    800027f4:	e052                	sd	s4,0(sp)
    800027f6:	1800                	addi	s0,sp,48
    800027f8:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800027fa:	47ad                	li	a5,11
    800027fc:	02b7e763          	bltu	a5,a1,8000282a <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    80002800:	02059493          	slli	s1,a1,0x20
    80002804:	9081                	srli	s1,s1,0x20
    80002806:	048a                	slli	s1,s1,0x2
    80002808:	94aa                	add	s1,s1,a0
    8000280a:	0504a903          	lw	s2,80(s1)
    8000280e:	06091e63          	bnez	s2,8000288a <bmap+0xa2>
      addr = balloc(ip->dev);
    80002812:	4108                	lw	a0,0(a0)
    80002814:	00000097          	auipc	ra,0x0
    80002818:	e9c080e7          	jalr	-356(ra) # 800026b0 <balloc>
    8000281c:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002820:	06090563          	beqz	s2,8000288a <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    80002824:	0524a823          	sw	s2,80(s1)
    80002828:	a08d                	j	8000288a <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000282a:	ff45849b          	addiw	s1,a1,-12
    8000282e:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80002832:	0ff00793          	li	a5,255
    80002836:	08e7e563          	bltu	a5,a4,800028c0 <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000283a:	08052903          	lw	s2,128(a0)
    8000283e:	00091d63          	bnez	s2,80002858 <bmap+0x70>
      addr = balloc(ip->dev);
    80002842:	4108                	lw	a0,0(a0)
    80002844:	00000097          	auipc	ra,0x0
    80002848:	e6c080e7          	jalr	-404(ra) # 800026b0 <balloc>
    8000284c:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002850:	02090d63          	beqz	s2,8000288a <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002854:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80002858:	85ca                	mv	a1,s2
    8000285a:	0009a503          	lw	a0,0(s3)
    8000285e:	00000097          	auipc	ra,0x0
    80002862:	b90080e7          	jalr	-1136(ra) # 800023ee <bread>
    80002866:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002868:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000286c:	02049593          	slli	a1,s1,0x20
    80002870:	9181                	srli	a1,a1,0x20
    80002872:	058a                	slli	a1,a1,0x2
    80002874:	00b784b3          	add	s1,a5,a1
    80002878:	0004a903          	lw	s2,0(s1)
    8000287c:	02090063          	beqz	s2,8000289c <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002880:	8552                	mv	a0,s4
    80002882:	00000097          	auipc	ra,0x0
    80002886:	c9c080e7          	jalr	-868(ra) # 8000251e <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000288a:	854a                	mv	a0,s2
    8000288c:	70a2                	ld	ra,40(sp)
    8000288e:	7402                	ld	s0,32(sp)
    80002890:	64e2                	ld	s1,24(sp)
    80002892:	6942                	ld	s2,16(sp)
    80002894:	69a2                	ld	s3,8(sp)
    80002896:	6a02                	ld	s4,0(sp)
    80002898:	6145                	addi	sp,sp,48
    8000289a:	8082                	ret
      addr = balloc(ip->dev);
    8000289c:	0009a503          	lw	a0,0(s3)
    800028a0:	00000097          	auipc	ra,0x0
    800028a4:	e10080e7          	jalr	-496(ra) # 800026b0 <balloc>
    800028a8:	0005091b          	sext.w	s2,a0
      if(addr){
    800028ac:	fc090ae3          	beqz	s2,80002880 <bmap+0x98>
        a[bn] = addr;
    800028b0:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800028b4:	8552                	mv	a0,s4
    800028b6:	00001097          	auipc	ra,0x1
    800028ba:	eec080e7          	jalr	-276(ra) # 800037a2 <log_write>
    800028be:	b7c9                	j	80002880 <bmap+0x98>
  panic("bmap: out of range");
    800028c0:	00006517          	auipc	a0,0x6
    800028c4:	e2050513          	addi	a0,a0,-480 # 800086e0 <syscallnames+0x128>
    800028c8:	00003097          	auipc	ra,0x3
    800028cc:	43a080e7          	jalr	1082(ra) # 80005d02 <panic>

00000000800028d0 <iget>:
{
    800028d0:	7179                	addi	sp,sp,-48
    800028d2:	f406                	sd	ra,40(sp)
    800028d4:	f022                	sd	s0,32(sp)
    800028d6:	ec26                	sd	s1,24(sp)
    800028d8:	e84a                	sd	s2,16(sp)
    800028da:	e44e                	sd	s3,8(sp)
    800028dc:	e052                	sd	s4,0(sp)
    800028de:	1800                	addi	s0,sp,48
    800028e0:	89aa                	mv	s3,a0
    800028e2:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800028e4:	00015517          	auipc	a0,0x15
    800028e8:	93450513          	addi	a0,a0,-1740 # 80017218 <itable>
    800028ec:	00004097          	auipc	ra,0x4
    800028f0:	960080e7          	jalr	-1696(ra) # 8000624c <acquire>
  empty = 0;
    800028f4:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800028f6:	00015497          	auipc	s1,0x15
    800028fa:	93a48493          	addi	s1,s1,-1734 # 80017230 <itable+0x18>
    800028fe:	00016697          	auipc	a3,0x16
    80002902:	3c268693          	addi	a3,a3,962 # 80018cc0 <log>
    80002906:	a039                	j	80002914 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002908:	02090b63          	beqz	s2,8000293e <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000290c:	08848493          	addi	s1,s1,136
    80002910:	02d48a63          	beq	s1,a3,80002944 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80002914:	449c                	lw	a5,8(s1)
    80002916:	fef059e3          	blez	a5,80002908 <iget+0x38>
    8000291a:	4098                	lw	a4,0(s1)
    8000291c:	ff3716e3          	bne	a4,s3,80002908 <iget+0x38>
    80002920:	40d8                	lw	a4,4(s1)
    80002922:	ff4713e3          	bne	a4,s4,80002908 <iget+0x38>
      ip->ref++;
    80002926:	2785                	addiw	a5,a5,1
    80002928:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000292a:	00015517          	auipc	a0,0x15
    8000292e:	8ee50513          	addi	a0,a0,-1810 # 80017218 <itable>
    80002932:	00004097          	auipc	ra,0x4
    80002936:	9ce080e7          	jalr	-1586(ra) # 80006300 <release>
      return ip;
    8000293a:	8926                	mv	s2,s1
    8000293c:	a03d                	j	8000296a <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000293e:	f7f9                	bnez	a5,8000290c <iget+0x3c>
    80002940:	8926                	mv	s2,s1
    80002942:	b7e9                	j	8000290c <iget+0x3c>
  if(empty == 0)
    80002944:	02090c63          	beqz	s2,8000297c <iget+0xac>
  ip->dev = dev;
    80002948:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000294c:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80002950:	4785                	li	a5,1
    80002952:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80002956:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000295a:	00015517          	auipc	a0,0x15
    8000295e:	8be50513          	addi	a0,a0,-1858 # 80017218 <itable>
    80002962:	00004097          	auipc	ra,0x4
    80002966:	99e080e7          	jalr	-1634(ra) # 80006300 <release>
}
    8000296a:	854a                	mv	a0,s2
    8000296c:	70a2                	ld	ra,40(sp)
    8000296e:	7402                	ld	s0,32(sp)
    80002970:	64e2                	ld	s1,24(sp)
    80002972:	6942                	ld	s2,16(sp)
    80002974:	69a2                	ld	s3,8(sp)
    80002976:	6a02                	ld	s4,0(sp)
    80002978:	6145                	addi	sp,sp,48
    8000297a:	8082                	ret
    panic("iget: no inodes");
    8000297c:	00006517          	auipc	a0,0x6
    80002980:	d7c50513          	addi	a0,a0,-644 # 800086f8 <syscallnames+0x140>
    80002984:	00003097          	auipc	ra,0x3
    80002988:	37e080e7          	jalr	894(ra) # 80005d02 <panic>

000000008000298c <fsinit>:
fsinit(int dev) {
    8000298c:	7179                	addi	sp,sp,-48
    8000298e:	f406                	sd	ra,40(sp)
    80002990:	f022                	sd	s0,32(sp)
    80002992:	ec26                	sd	s1,24(sp)
    80002994:	e84a                	sd	s2,16(sp)
    80002996:	e44e                	sd	s3,8(sp)
    80002998:	1800                	addi	s0,sp,48
    8000299a:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000299c:	4585                	li	a1,1
    8000299e:	00000097          	auipc	ra,0x0
    800029a2:	a50080e7          	jalr	-1456(ra) # 800023ee <bread>
    800029a6:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800029a8:	00015997          	auipc	s3,0x15
    800029ac:	85098993          	addi	s3,s3,-1968 # 800171f8 <sb>
    800029b0:	02000613          	li	a2,32
    800029b4:	05850593          	addi	a1,a0,88
    800029b8:	854e                	mv	a0,s3
    800029ba:	ffffe097          	auipc	ra,0xffffe
    800029be:	842080e7          	jalr	-1982(ra) # 800001fc <memmove>
  brelse(bp);
    800029c2:	8526                	mv	a0,s1
    800029c4:	00000097          	auipc	ra,0x0
    800029c8:	b5a080e7          	jalr	-1190(ra) # 8000251e <brelse>
  if(sb.magic != FSMAGIC)
    800029cc:	0009a703          	lw	a4,0(s3)
    800029d0:	102037b7          	lui	a5,0x10203
    800029d4:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800029d8:	02f71263          	bne	a4,a5,800029fc <fsinit+0x70>
  initlog(dev, &sb);
    800029dc:	00015597          	auipc	a1,0x15
    800029e0:	81c58593          	addi	a1,a1,-2020 # 800171f8 <sb>
    800029e4:	854a                	mv	a0,s2
    800029e6:	00001097          	auipc	ra,0x1
    800029ea:	b40080e7          	jalr	-1216(ra) # 80003526 <initlog>
}
    800029ee:	70a2                	ld	ra,40(sp)
    800029f0:	7402                	ld	s0,32(sp)
    800029f2:	64e2                	ld	s1,24(sp)
    800029f4:	6942                	ld	s2,16(sp)
    800029f6:	69a2                	ld	s3,8(sp)
    800029f8:	6145                	addi	sp,sp,48
    800029fa:	8082                	ret
    panic("invalid file system");
    800029fc:	00006517          	auipc	a0,0x6
    80002a00:	d0c50513          	addi	a0,a0,-756 # 80008708 <syscallnames+0x150>
    80002a04:	00003097          	auipc	ra,0x3
    80002a08:	2fe080e7          	jalr	766(ra) # 80005d02 <panic>

0000000080002a0c <iinit>:
{
    80002a0c:	7179                	addi	sp,sp,-48
    80002a0e:	f406                	sd	ra,40(sp)
    80002a10:	f022                	sd	s0,32(sp)
    80002a12:	ec26                	sd	s1,24(sp)
    80002a14:	e84a                	sd	s2,16(sp)
    80002a16:	e44e                	sd	s3,8(sp)
    80002a18:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80002a1a:	00006597          	auipc	a1,0x6
    80002a1e:	d0658593          	addi	a1,a1,-762 # 80008720 <syscallnames+0x168>
    80002a22:	00014517          	auipc	a0,0x14
    80002a26:	7f650513          	addi	a0,a0,2038 # 80017218 <itable>
    80002a2a:	00003097          	auipc	ra,0x3
    80002a2e:	792080e7          	jalr	1938(ra) # 800061bc <initlock>
  for(i = 0; i < NINODE; i++) {
    80002a32:	00015497          	auipc	s1,0x15
    80002a36:	80e48493          	addi	s1,s1,-2034 # 80017240 <itable+0x28>
    80002a3a:	00016997          	auipc	s3,0x16
    80002a3e:	29698993          	addi	s3,s3,662 # 80018cd0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80002a42:	00006917          	auipc	s2,0x6
    80002a46:	ce690913          	addi	s2,s2,-794 # 80008728 <syscallnames+0x170>
    80002a4a:	85ca                	mv	a1,s2
    80002a4c:	8526                	mv	a0,s1
    80002a4e:	00001097          	auipc	ra,0x1
    80002a52:	e3a080e7          	jalr	-454(ra) # 80003888 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80002a56:	08848493          	addi	s1,s1,136
    80002a5a:	ff3498e3          	bne	s1,s3,80002a4a <iinit+0x3e>
}
    80002a5e:	70a2                	ld	ra,40(sp)
    80002a60:	7402                	ld	s0,32(sp)
    80002a62:	64e2                	ld	s1,24(sp)
    80002a64:	6942                	ld	s2,16(sp)
    80002a66:	69a2                	ld	s3,8(sp)
    80002a68:	6145                	addi	sp,sp,48
    80002a6a:	8082                	ret

0000000080002a6c <ialloc>:
{
    80002a6c:	715d                	addi	sp,sp,-80
    80002a6e:	e486                	sd	ra,72(sp)
    80002a70:	e0a2                	sd	s0,64(sp)
    80002a72:	fc26                	sd	s1,56(sp)
    80002a74:	f84a                	sd	s2,48(sp)
    80002a76:	f44e                	sd	s3,40(sp)
    80002a78:	f052                	sd	s4,32(sp)
    80002a7a:	ec56                	sd	s5,24(sp)
    80002a7c:	e85a                	sd	s6,16(sp)
    80002a7e:	e45e                	sd	s7,8(sp)
    80002a80:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80002a82:	00014717          	auipc	a4,0x14
    80002a86:	78272703          	lw	a4,1922(a4) # 80017204 <sb+0xc>
    80002a8a:	4785                	li	a5,1
    80002a8c:	04e7fa63          	bgeu	a5,a4,80002ae0 <ialloc+0x74>
    80002a90:	8aaa                	mv	s5,a0
    80002a92:	8bae                	mv	s7,a1
    80002a94:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80002a96:	00014a17          	auipc	s4,0x14
    80002a9a:	762a0a13          	addi	s4,s4,1890 # 800171f8 <sb>
    80002a9e:	00048b1b          	sext.w	s6,s1
    80002aa2:	0044d593          	srli	a1,s1,0x4
    80002aa6:	018a2783          	lw	a5,24(s4)
    80002aaa:	9dbd                	addw	a1,a1,a5
    80002aac:	8556                	mv	a0,s5
    80002aae:	00000097          	auipc	ra,0x0
    80002ab2:	940080e7          	jalr	-1728(ra) # 800023ee <bread>
    80002ab6:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80002ab8:	05850993          	addi	s3,a0,88
    80002abc:	00f4f793          	andi	a5,s1,15
    80002ac0:	079a                	slli	a5,a5,0x6
    80002ac2:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80002ac4:	00099783          	lh	a5,0(s3)
    80002ac8:	c3a1                	beqz	a5,80002b08 <ialloc+0x9c>
    brelse(bp);
    80002aca:	00000097          	auipc	ra,0x0
    80002ace:	a54080e7          	jalr	-1452(ra) # 8000251e <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80002ad2:	0485                	addi	s1,s1,1
    80002ad4:	00ca2703          	lw	a4,12(s4)
    80002ad8:	0004879b          	sext.w	a5,s1
    80002adc:	fce7e1e3          	bltu	a5,a4,80002a9e <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80002ae0:	00006517          	auipc	a0,0x6
    80002ae4:	c5050513          	addi	a0,a0,-944 # 80008730 <syscallnames+0x178>
    80002ae8:	00003097          	auipc	ra,0x3
    80002aec:	264080e7          	jalr	612(ra) # 80005d4c <printf>
  return 0;
    80002af0:	4501                	li	a0,0
}
    80002af2:	60a6                	ld	ra,72(sp)
    80002af4:	6406                	ld	s0,64(sp)
    80002af6:	74e2                	ld	s1,56(sp)
    80002af8:	7942                	ld	s2,48(sp)
    80002afa:	79a2                	ld	s3,40(sp)
    80002afc:	7a02                	ld	s4,32(sp)
    80002afe:	6ae2                	ld	s5,24(sp)
    80002b00:	6b42                	ld	s6,16(sp)
    80002b02:	6ba2                	ld	s7,8(sp)
    80002b04:	6161                	addi	sp,sp,80
    80002b06:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80002b08:	04000613          	li	a2,64
    80002b0c:	4581                	li	a1,0
    80002b0e:	854e                	mv	a0,s3
    80002b10:	ffffd097          	auipc	ra,0xffffd
    80002b14:	68c080e7          	jalr	1676(ra) # 8000019c <memset>
      dip->type = type;
    80002b18:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80002b1c:	854a                	mv	a0,s2
    80002b1e:	00001097          	auipc	ra,0x1
    80002b22:	c84080e7          	jalr	-892(ra) # 800037a2 <log_write>
      brelse(bp);
    80002b26:	854a                	mv	a0,s2
    80002b28:	00000097          	auipc	ra,0x0
    80002b2c:	9f6080e7          	jalr	-1546(ra) # 8000251e <brelse>
      return iget(dev, inum);
    80002b30:	85da                	mv	a1,s6
    80002b32:	8556                	mv	a0,s5
    80002b34:	00000097          	auipc	ra,0x0
    80002b38:	d9c080e7          	jalr	-612(ra) # 800028d0 <iget>
    80002b3c:	bf5d                	j	80002af2 <ialloc+0x86>

0000000080002b3e <iupdate>:
{
    80002b3e:	1101                	addi	sp,sp,-32
    80002b40:	ec06                	sd	ra,24(sp)
    80002b42:	e822                	sd	s0,16(sp)
    80002b44:	e426                	sd	s1,8(sp)
    80002b46:	e04a                	sd	s2,0(sp)
    80002b48:	1000                	addi	s0,sp,32
    80002b4a:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002b4c:	415c                	lw	a5,4(a0)
    80002b4e:	0047d79b          	srliw	a5,a5,0x4
    80002b52:	00014597          	auipc	a1,0x14
    80002b56:	6be5a583          	lw	a1,1726(a1) # 80017210 <sb+0x18>
    80002b5a:	9dbd                	addw	a1,a1,a5
    80002b5c:	4108                	lw	a0,0(a0)
    80002b5e:	00000097          	auipc	ra,0x0
    80002b62:	890080e7          	jalr	-1904(ra) # 800023ee <bread>
    80002b66:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002b68:	05850793          	addi	a5,a0,88
    80002b6c:	40c8                	lw	a0,4(s1)
    80002b6e:	893d                	andi	a0,a0,15
    80002b70:	051a                	slli	a0,a0,0x6
    80002b72:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80002b74:	04449703          	lh	a4,68(s1)
    80002b78:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80002b7c:	04649703          	lh	a4,70(s1)
    80002b80:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80002b84:	04849703          	lh	a4,72(s1)
    80002b88:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80002b8c:	04a49703          	lh	a4,74(s1)
    80002b90:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80002b94:	44f8                	lw	a4,76(s1)
    80002b96:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80002b98:	03400613          	li	a2,52
    80002b9c:	05048593          	addi	a1,s1,80
    80002ba0:	0531                	addi	a0,a0,12
    80002ba2:	ffffd097          	auipc	ra,0xffffd
    80002ba6:	65a080e7          	jalr	1626(ra) # 800001fc <memmove>
  log_write(bp);
    80002baa:	854a                	mv	a0,s2
    80002bac:	00001097          	auipc	ra,0x1
    80002bb0:	bf6080e7          	jalr	-1034(ra) # 800037a2 <log_write>
  brelse(bp);
    80002bb4:	854a                	mv	a0,s2
    80002bb6:	00000097          	auipc	ra,0x0
    80002bba:	968080e7          	jalr	-1688(ra) # 8000251e <brelse>
}
    80002bbe:	60e2                	ld	ra,24(sp)
    80002bc0:	6442                	ld	s0,16(sp)
    80002bc2:	64a2                	ld	s1,8(sp)
    80002bc4:	6902                	ld	s2,0(sp)
    80002bc6:	6105                	addi	sp,sp,32
    80002bc8:	8082                	ret

0000000080002bca <idup>:
{
    80002bca:	1101                	addi	sp,sp,-32
    80002bcc:	ec06                	sd	ra,24(sp)
    80002bce:	e822                	sd	s0,16(sp)
    80002bd0:	e426                	sd	s1,8(sp)
    80002bd2:	1000                	addi	s0,sp,32
    80002bd4:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002bd6:	00014517          	auipc	a0,0x14
    80002bda:	64250513          	addi	a0,a0,1602 # 80017218 <itable>
    80002bde:	00003097          	auipc	ra,0x3
    80002be2:	66e080e7          	jalr	1646(ra) # 8000624c <acquire>
  ip->ref++;
    80002be6:	449c                	lw	a5,8(s1)
    80002be8:	2785                	addiw	a5,a5,1
    80002bea:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002bec:	00014517          	auipc	a0,0x14
    80002bf0:	62c50513          	addi	a0,a0,1580 # 80017218 <itable>
    80002bf4:	00003097          	auipc	ra,0x3
    80002bf8:	70c080e7          	jalr	1804(ra) # 80006300 <release>
}
    80002bfc:	8526                	mv	a0,s1
    80002bfe:	60e2                	ld	ra,24(sp)
    80002c00:	6442                	ld	s0,16(sp)
    80002c02:	64a2                	ld	s1,8(sp)
    80002c04:	6105                	addi	sp,sp,32
    80002c06:	8082                	ret

0000000080002c08 <ilock>:
{
    80002c08:	1101                	addi	sp,sp,-32
    80002c0a:	ec06                	sd	ra,24(sp)
    80002c0c:	e822                	sd	s0,16(sp)
    80002c0e:	e426                	sd	s1,8(sp)
    80002c10:	e04a                	sd	s2,0(sp)
    80002c12:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80002c14:	c115                	beqz	a0,80002c38 <ilock+0x30>
    80002c16:	84aa                	mv	s1,a0
    80002c18:	451c                	lw	a5,8(a0)
    80002c1a:	00f05f63          	blez	a5,80002c38 <ilock+0x30>
  acquiresleep(&ip->lock);
    80002c1e:	0541                	addi	a0,a0,16
    80002c20:	00001097          	auipc	ra,0x1
    80002c24:	ca2080e7          	jalr	-862(ra) # 800038c2 <acquiresleep>
  if(ip->valid == 0){
    80002c28:	40bc                	lw	a5,64(s1)
    80002c2a:	cf99                	beqz	a5,80002c48 <ilock+0x40>
}
    80002c2c:	60e2                	ld	ra,24(sp)
    80002c2e:	6442                	ld	s0,16(sp)
    80002c30:	64a2                	ld	s1,8(sp)
    80002c32:	6902                	ld	s2,0(sp)
    80002c34:	6105                	addi	sp,sp,32
    80002c36:	8082                	ret
    panic("ilock");
    80002c38:	00006517          	auipc	a0,0x6
    80002c3c:	b1050513          	addi	a0,a0,-1264 # 80008748 <syscallnames+0x190>
    80002c40:	00003097          	auipc	ra,0x3
    80002c44:	0c2080e7          	jalr	194(ra) # 80005d02 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002c48:	40dc                	lw	a5,4(s1)
    80002c4a:	0047d79b          	srliw	a5,a5,0x4
    80002c4e:	00014597          	auipc	a1,0x14
    80002c52:	5c25a583          	lw	a1,1474(a1) # 80017210 <sb+0x18>
    80002c56:	9dbd                	addw	a1,a1,a5
    80002c58:	4088                	lw	a0,0(s1)
    80002c5a:	fffff097          	auipc	ra,0xfffff
    80002c5e:	794080e7          	jalr	1940(ra) # 800023ee <bread>
    80002c62:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002c64:	05850593          	addi	a1,a0,88
    80002c68:	40dc                	lw	a5,4(s1)
    80002c6a:	8bbd                	andi	a5,a5,15
    80002c6c:	079a                	slli	a5,a5,0x6
    80002c6e:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80002c70:	00059783          	lh	a5,0(a1)
    80002c74:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80002c78:	00259783          	lh	a5,2(a1)
    80002c7c:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80002c80:	00459783          	lh	a5,4(a1)
    80002c84:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80002c88:	00659783          	lh	a5,6(a1)
    80002c8c:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80002c90:	459c                	lw	a5,8(a1)
    80002c92:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80002c94:	03400613          	li	a2,52
    80002c98:	05b1                	addi	a1,a1,12
    80002c9a:	05048513          	addi	a0,s1,80
    80002c9e:	ffffd097          	auipc	ra,0xffffd
    80002ca2:	55e080e7          	jalr	1374(ra) # 800001fc <memmove>
    brelse(bp);
    80002ca6:	854a                	mv	a0,s2
    80002ca8:	00000097          	auipc	ra,0x0
    80002cac:	876080e7          	jalr	-1930(ra) # 8000251e <brelse>
    ip->valid = 1;
    80002cb0:	4785                	li	a5,1
    80002cb2:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80002cb4:	04449783          	lh	a5,68(s1)
    80002cb8:	fbb5                	bnez	a5,80002c2c <ilock+0x24>
      panic("ilock: no type");
    80002cba:	00006517          	auipc	a0,0x6
    80002cbe:	a9650513          	addi	a0,a0,-1386 # 80008750 <syscallnames+0x198>
    80002cc2:	00003097          	auipc	ra,0x3
    80002cc6:	040080e7          	jalr	64(ra) # 80005d02 <panic>

0000000080002cca <iunlock>:
{
    80002cca:	1101                	addi	sp,sp,-32
    80002ccc:	ec06                	sd	ra,24(sp)
    80002cce:	e822                	sd	s0,16(sp)
    80002cd0:	e426                	sd	s1,8(sp)
    80002cd2:	e04a                	sd	s2,0(sp)
    80002cd4:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80002cd6:	c905                	beqz	a0,80002d06 <iunlock+0x3c>
    80002cd8:	84aa                	mv	s1,a0
    80002cda:	01050913          	addi	s2,a0,16
    80002cde:	854a                	mv	a0,s2
    80002ce0:	00001097          	auipc	ra,0x1
    80002ce4:	c7c080e7          	jalr	-900(ra) # 8000395c <holdingsleep>
    80002ce8:	cd19                	beqz	a0,80002d06 <iunlock+0x3c>
    80002cea:	449c                	lw	a5,8(s1)
    80002cec:	00f05d63          	blez	a5,80002d06 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80002cf0:	854a                	mv	a0,s2
    80002cf2:	00001097          	auipc	ra,0x1
    80002cf6:	c26080e7          	jalr	-986(ra) # 80003918 <releasesleep>
}
    80002cfa:	60e2                	ld	ra,24(sp)
    80002cfc:	6442                	ld	s0,16(sp)
    80002cfe:	64a2                	ld	s1,8(sp)
    80002d00:	6902                	ld	s2,0(sp)
    80002d02:	6105                	addi	sp,sp,32
    80002d04:	8082                	ret
    panic("iunlock");
    80002d06:	00006517          	auipc	a0,0x6
    80002d0a:	a5a50513          	addi	a0,a0,-1446 # 80008760 <syscallnames+0x1a8>
    80002d0e:	00003097          	auipc	ra,0x3
    80002d12:	ff4080e7          	jalr	-12(ra) # 80005d02 <panic>

0000000080002d16 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80002d16:	7179                	addi	sp,sp,-48
    80002d18:	f406                	sd	ra,40(sp)
    80002d1a:	f022                	sd	s0,32(sp)
    80002d1c:	ec26                	sd	s1,24(sp)
    80002d1e:	e84a                	sd	s2,16(sp)
    80002d20:	e44e                	sd	s3,8(sp)
    80002d22:	e052                	sd	s4,0(sp)
    80002d24:	1800                	addi	s0,sp,48
    80002d26:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80002d28:	05050493          	addi	s1,a0,80
    80002d2c:	08050913          	addi	s2,a0,128
    80002d30:	a021                	j	80002d38 <itrunc+0x22>
    80002d32:	0491                	addi	s1,s1,4
    80002d34:	01248d63          	beq	s1,s2,80002d4e <itrunc+0x38>
    if(ip->addrs[i]){
    80002d38:	408c                	lw	a1,0(s1)
    80002d3a:	dde5                	beqz	a1,80002d32 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80002d3c:	0009a503          	lw	a0,0(s3)
    80002d40:	00000097          	auipc	ra,0x0
    80002d44:	8f4080e7          	jalr	-1804(ra) # 80002634 <bfree>
      ip->addrs[i] = 0;
    80002d48:	0004a023          	sw	zero,0(s1)
    80002d4c:	b7dd                	j	80002d32 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80002d4e:	0809a583          	lw	a1,128(s3)
    80002d52:	e185                	bnez	a1,80002d72 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80002d54:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80002d58:	854e                	mv	a0,s3
    80002d5a:	00000097          	auipc	ra,0x0
    80002d5e:	de4080e7          	jalr	-540(ra) # 80002b3e <iupdate>
}
    80002d62:	70a2                	ld	ra,40(sp)
    80002d64:	7402                	ld	s0,32(sp)
    80002d66:	64e2                	ld	s1,24(sp)
    80002d68:	6942                	ld	s2,16(sp)
    80002d6a:	69a2                	ld	s3,8(sp)
    80002d6c:	6a02                	ld	s4,0(sp)
    80002d6e:	6145                	addi	sp,sp,48
    80002d70:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80002d72:	0009a503          	lw	a0,0(s3)
    80002d76:	fffff097          	auipc	ra,0xfffff
    80002d7a:	678080e7          	jalr	1656(ra) # 800023ee <bread>
    80002d7e:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80002d80:	05850493          	addi	s1,a0,88
    80002d84:	45850913          	addi	s2,a0,1112
    80002d88:	a811                	j	80002d9c <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80002d8a:	0009a503          	lw	a0,0(s3)
    80002d8e:	00000097          	auipc	ra,0x0
    80002d92:	8a6080e7          	jalr	-1882(ra) # 80002634 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80002d96:	0491                	addi	s1,s1,4
    80002d98:	01248563          	beq	s1,s2,80002da2 <itrunc+0x8c>
      if(a[j])
    80002d9c:	408c                	lw	a1,0(s1)
    80002d9e:	dde5                	beqz	a1,80002d96 <itrunc+0x80>
    80002da0:	b7ed                	j	80002d8a <itrunc+0x74>
    brelse(bp);
    80002da2:	8552                	mv	a0,s4
    80002da4:	fffff097          	auipc	ra,0xfffff
    80002da8:	77a080e7          	jalr	1914(ra) # 8000251e <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80002dac:	0809a583          	lw	a1,128(s3)
    80002db0:	0009a503          	lw	a0,0(s3)
    80002db4:	00000097          	auipc	ra,0x0
    80002db8:	880080e7          	jalr	-1920(ra) # 80002634 <bfree>
    ip->addrs[NDIRECT] = 0;
    80002dbc:	0809a023          	sw	zero,128(s3)
    80002dc0:	bf51                	j	80002d54 <itrunc+0x3e>

0000000080002dc2 <iput>:
{
    80002dc2:	1101                	addi	sp,sp,-32
    80002dc4:	ec06                	sd	ra,24(sp)
    80002dc6:	e822                	sd	s0,16(sp)
    80002dc8:	e426                	sd	s1,8(sp)
    80002dca:	e04a                	sd	s2,0(sp)
    80002dcc:	1000                	addi	s0,sp,32
    80002dce:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002dd0:	00014517          	auipc	a0,0x14
    80002dd4:	44850513          	addi	a0,a0,1096 # 80017218 <itable>
    80002dd8:	00003097          	auipc	ra,0x3
    80002ddc:	474080e7          	jalr	1140(ra) # 8000624c <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002de0:	4498                	lw	a4,8(s1)
    80002de2:	4785                	li	a5,1
    80002de4:	02f70363          	beq	a4,a5,80002e0a <iput+0x48>
  ip->ref--;
    80002de8:	449c                	lw	a5,8(s1)
    80002dea:	37fd                	addiw	a5,a5,-1
    80002dec:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002dee:	00014517          	auipc	a0,0x14
    80002df2:	42a50513          	addi	a0,a0,1066 # 80017218 <itable>
    80002df6:	00003097          	auipc	ra,0x3
    80002dfa:	50a080e7          	jalr	1290(ra) # 80006300 <release>
}
    80002dfe:	60e2                	ld	ra,24(sp)
    80002e00:	6442                	ld	s0,16(sp)
    80002e02:	64a2                	ld	s1,8(sp)
    80002e04:	6902                	ld	s2,0(sp)
    80002e06:	6105                	addi	sp,sp,32
    80002e08:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002e0a:	40bc                	lw	a5,64(s1)
    80002e0c:	dff1                	beqz	a5,80002de8 <iput+0x26>
    80002e0e:	04a49783          	lh	a5,74(s1)
    80002e12:	fbf9                	bnez	a5,80002de8 <iput+0x26>
    acquiresleep(&ip->lock);
    80002e14:	01048913          	addi	s2,s1,16
    80002e18:	854a                	mv	a0,s2
    80002e1a:	00001097          	auipc	ra,0x1
    80002e1e:	aa8080e7          	jalr	-1368(ra) # 800038c2 <acquiresleep>
    release(&itable.lock);
    80002e22:	00014517          	auipc	a0,0x14
    80002e26:	3f650513          	addi	a0,a0,1014 # 80017218 <itable>
    80002e2a:	00003097          	auipc	ra,0x3
    80002e2e:	4d6080e7          	jalr	1238(ra) # 80006300 <release>
    itrunc(ip);
    80002e32:	8526                	mv	a0,s1
    80002e34:	00000097          	auipc	ra,0x0
    80002e38:	ee2080e7          	jalr	-286(ra) # 80002d16 <itrunc>
    ip->type = 0;
    80002e3c:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80002e40:	8526                	mv	a0,s1
    80002e42:	00000097          	auipc	ra,0x0
    80002e46:	cfc080e7          	jalr	-772(ra) # 80002b3e <iupdate>
    ip->valid = 0;
    80002e4a:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80002e4e:	854a                	mv	a0,s2
    80002e50:	00001097          	auipc	ra,0x1
    80002e54:	ac8080e7          	jalr	-1336(ra) # 80003918 <releasesleep>
    acquire(&itable.lock);
    80002e58:	00014517          	auipc	a0,0x14
    80002e5c:	3c050513          	addi	a0,a0,960 # 80017218 <itable>
    80002e60:	00003097          	auipc	ra,0x3
    80002e64:	3ec080e7          	jalr	1004(ra) # 8000624c <acquire>
    80002e68:	b741                	j	80002de8 <iput+0x26>

0000000080002e6a <iunlockput>:
{
    80002e6a:	1101                	addi	sp,sp,-32
    80002e6c:	ec06                	sd	ra,24(sp)
    80002e6e:	e822                	sd	s0,16(sp)
    80002e70:	e426                	sd	s1,8(sp)
    80002e72:	1000                	addi	s0,sp,32
    80002e74:	84aa                	mv	s1,a0
  iunlock(ip);
    80002e76:	00000097          	auipc	ra,0x0
    80002e7a:	e54080e7          	jalr	-428(ra) # 80002cca <iunlock>
  iput(ip);
    80002e7e:	8526                	mv	a0,s1
    80002e80:	00000097          	auipc	ra,0x0
    80002e84:	f42080e7          	jalr	-190(ra) # 80002dc2 <iput>
}
    80002e88:	60e2                	ld	ra,24(sp)
    80002e8a:	6442                	ld	s0,16(sp)
    80002e8c:	64a2                	ld	s1,8(sp)
    80002e8e:	6105                	addi	sp,sp,32
    80002e90:	8082                	ret

0000000080002e92 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80002e92:	1141                	addi	sp,sp,-16
    80002e94:	e422                	sd	s0,8(sp)
    80002e96:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80002e98:	411c                	lw	a5,0(a0)
    80002e9a:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80002e9c:	415c                	lw	a5,4(a0)
    80002e9e:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80002ea0:	04451783          	lh	a5,68(a0)
    80002ea4:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80002ea8:	04a51783          	lh	a5,74(a0)
    80002eac:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80002eb0:	04c56783          	lwu	a5,76(a0)
    80002eb4:	e99c                	sd	a5,16(a1)
}
    80002eb6:	6422                	ld	s0,8(sp)
    80002eb8:	0141                	addi	sp,sp,16
    80002eba:	8082                	ret

0000000080002ebc <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002ebc:	457c                	lw	a5,76(a0)
    80002ebe:	0ed7e963          	bltu	a5,a3,80002fb0 <readi+0xf4>
{
    80002ec2:	7159                	addi	sp,sp,-112
    80002ec4:	f486                	sd	ra,104(sp)
    80002ec6:	f0a2                	sd	s0,96(sp)
    80002ec8:	eca6                	sd	s1,88(sp)
    80002eca:	e8ca                	sd	s2,80(sp)
    80002ecc:	e4ce                	sd	s3,72(sp)
    80002ece:	e0d2                	sd	s4,64(sp)
    80002ed0:	fc56                	sd	s5,56(sp)
    80002ed2:	f85a                	sd	s6,48(sp)
    80002ed4:	f45e                	sd	s7,40(sp)
    80002ed6:	f062                	sd	s8,32(sp)
    80002ed8:	ec66                	sd	s9,24(sp)
    80002eda:	e86a                	sd	s10,16(sp)
    80002edc:	e46e                	sd	s11,8(sp)
    80002ede:	1880                	addi	s0,sp,112
    80002ee0:	8b2a                	mv	s6,a0
    80002ee2:	8bae                	mv	s7,a1
    80002ee4:	8a32                	mv	s4,a2
    80002ee6:	84b6                	mv	s1,a3
    80002ee8:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80002eea:	9f35                	addw	a4,a4,a3
    return 0;
    80002eec:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80002eee:	0ad76063          	bltu	a4,a3,80002f8e <readi+0xd2>
  if(off + n > ip->size)
    80002ef2:	00e7f463          	bgeu	a5,a4,80002efa <readi+0x3e>
    n = ip->size - off;
    80002ef6:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002efa:	0a0a8963          	beqz	s5,80002fac <readi+0xf0>
    80002efe:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002f00:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80002f04:	5c7d                	li	s8,-1
    80002f06:	a82d                	j	80002f40 <readi+0x84>
    80002f08:	020d1d93          	slli	s11,s10,0x20
    80002f0c:	020ddd93          	srli	s11,s11,0x20
    80002f10:	05890613          	addi	a2,s2,88
    80002f14:	86ee                	mv	a3,s11
    80002f16:	963a                	add	a2,a2,a4
    80002f18:	85d2                	mv	a1,s4
    80002f1a:	855e                	mv	a0,s7
    80002f1c:	fffff097          	auipc	ra,0xfffff
    80002f20:	a14080e7          	jalr	-1516(ra) # 80001930 <either_copyout>
    80002f24:	05850d63          	beq	a0,s8,80002f7e <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80002f28:	854a                	mv	a0,s2
    80002f2a:	fffff097          	auipc	ra,0xfffff
    80002f2e:	5f4080e7          	jalr	1524(ra) # 8000251e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002f32:	013d09bb          	addw	s3,s10,s3
    80002f36:	009d04bb          	addw	s1,s10,s1
    80002f3a:	9a6e                	add	s4,s4,s11
    80002f3c:	0559f763          	bgeu	s3,s5,80002f8a <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80002f40:	00a4d59b          	srliw	a1,s1,0xa
    80002f44:	855a                	mv	a0,s6
    80002f46:	00000097          	auipc	ra,0x0
    80002f4a:	8a2080e7          	jalr	-1886(ra) # 800027e8 <bmap>
    80002f4e:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002f52:	cd85                	beqz	a1,80002f8a <readi+0xce>
    bp = bread(ip->dev, addr);
    80002f54:	000b2503          	lw	a0,0(s6)
    80002f58:	fffff097          	auipc	ra,0xfffff
    80002f5c:	496080e7          	jalr	1174(ra) # 800023ee <bread>
    80002f60:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002f62:	3ff4f713          	andi	a4,s1,1023
    80002f66:	40ec87bb          	subw	a5,s9,a4
    80002f6a:	413a86bb          	subw	a3,s5,s3
    80002f6e:	8d3e                	mv	s10,a5
    80002f70:	2781                	sext.w	a5,a5
    80002f72:	0006861b          	sext.w	a2,a3
    80002f76:	f8f679e3          	bgeu	a2,a5,80002f08 <readi+0x4c>
    80002f7a:	8d36                	mv	s10,a3
    80002f7c:	b771                	j	80002f08 <readi+0x4c>
      brelse(bp);
    80002f7e:	854a                	mv	a0,s2
    80002f80:	fffff097          	auipc	ra,0xfffff
    80002f84:	59e080e7          	jalr	1438(ra) # 8000251e <brelse>
      tot = -1;
    80002f88:	59fd                	li	s3,-1
  }
  return tot;
    80002f8a:	0009851b          	sext.w	a0,s3
}
    80002f8e:	70a6                	ld	ra,104(sp)
    80002f90:	7406                	ld	s0,96(sp)
    80002f92:	64e6                	ld	s1,88(sp)
    80002f94:	6946                	ld	s2,80(sp)
    80002f96:	69a6                	ld	s3,72(sp)
    80002f98:	6a06                	ld	s4,64(sp)
    80002f9a:	7ae2                	ld	s5,56(sp)
    80002f9c:	7b42                	ld	s6,48(sp)
    80002f9e:	7ba2                	ld	s7,40(sp)
    80002fa0:	7c02                	ld	s8,32(sp)
    80002fa2:	6ce2                	ld	s9,24(sp)
    80002fa4:	6d42                	ld	s10,16(sp)
    80002fa6:	6da2                	ld	s11,8(sp)
    80002fa8:	6165                	addi	sp,sp,112
    80002faa:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002fac:	89d6                	mv	s3,s5
    80002fae:	bff1                	j	80002f8a <readi+0xce>
    return 0;
    80002fb0:	4501                	li	a0,0
}
    80002fb2:	8082                	ret

0000000080002fb4 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002fb4:	457c                	lw	a5,76(a0)
    80002fb6:	10d7e863          	bltu	a5,a3,800030c6 <writei+0x112>
{
    80002fba:	7159                	addi	sp,sp,-112
    80002fbc:	f486                	sd	ra,104(sp)
    80002fbe:	f0a2                	sd	s0,96(sp)
    80002fc0:	eca6                	sd	s1,88(sp)
    80002fc2:	e8ca                	sd	s2,80(sp)
    80002fc4:	e4ce                	sd	s3,72(sp)
    80002fc6:	e0d2                	sd	s4,64(sp)
    80002fc8:	fc56                	sd	s5,56(sp)
    80002fca:	f85a                	sd	s6,48(sp)
    80002fcc:	f45e                	sd	s7,40(sp)
    80002fce:	f062                	sd	s8,32(sp)
    80002fd0:	ec66                	sd	s9,24(sp)
    80002fd2:	e86a                	sd	s10,16(sp)
    80002fd4:	e46e                	sd	s11,8(sp)
    80002fd6:	1880                	addi	s0,sp,112
    80002fd8:	8aaa                	mv	s5,a0
    80002fda:	8bae                	mv	s7,a1
    80002fdc:	8a32                	mv	s4,a2
    80002fde:	8936                	mv	s2,a3
    80002fe0:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80002fe2:	00e687bb          	addw	a5,a3,a4
    80002fe6:	0ed7e263          	bltu	a5,a3,800030ca <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80002fea:	00043737          	lui	a4,0x43
    80002fee:	0ef76063          	bltu	a4,a5,800030ce <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002ff2:	0c0b0863          	beqz	s6,800030c2 <writei+0x10e>
    80002ff6:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002ff8:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80002ffc:	5c7d                	li	s8,-1
    80002ffe:	a091                	j	80003042 <writei+0x8e>
    80003000:	020d1d93          	slli	s11,s10,0x20
    80003004:	020ddd93          	srli	s11,s11,0x20
    80003008:	05848513          	addi	a0,s1,88
    8000300c:	86ee                	mv	a3,s11
    8000300e:	8652                	mv	a2,s4
    80003010:	85de                	mv	a1,s7
    80003012:	953a                	add	a0,a0,a4
    80003014:	fffff097          	auipc	ra,0xfffff
    80003018:	972080e7          	jalr	-1678(ra) # 80001986 <either_copyin>
    8000301c:	07850263          	beq	a0,s8,80003080 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003020:	8526                	mv	a0,s1
    80003022:	00000097          	auipc	ra,0x0
    80003026:	780080e7          	jalr	1920(ra) # 800037a2 <log_write>
    brelse(bp);
    8000302a:	8526                	mv	a0,s1
    8000302c:	fffff097          	auipc	ra,0xfffff
    80003030:	4f2080e7          	jalr	1266(ra) # 8000251e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003034:	013d09bb          	addw	s3,s10,s3
    80003038:	012d093b          	addw	s2,s10,s2
    8000303c:	9a6e                	add	s4,s4,s11
    8000303e:	0569f663          	bgeu	s3,s6,8000308a <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003042:	00a9559b          	srliw	a1,s2,0xa
    80003046:	8556                	mv	a0,s5
    80003048:	fffff097          	auipc	ra,0xfffff
    8000304c:	7a0080e7          	jalr	1952(ra) # 800027e8 <bmap>
    80003050:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003054:	c99d                	beqz	a1,8000308a <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003056:	000aa503          	lw	a0,0(s5)
    8000305a:	fffff097          	auipc	ra,0xfffff
    8000305e:	394080e7          	jalr	916(ra) # 800023ee <bread>
    80003062:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003064:	3ff97713          	andi	a4,s2,1023
    80003068:	40ec87bb          	subw	a5,s9,a4
    8000306c:	413b06bb          	subw	a3,s6,s3
    80003070:	8d3e                	mv	s10,a5
    80003072:	2781                	sext.w	a5,a5
    80003074:	0006861b          	sext.w	a2,a3
    80003078:	f8f674e3          	bgeu	a2,a5,80003000 <writei+0x4c>
    8000307c:	8d36                	mv	s10,a3
    8000307e:	b749                	j	80003000 <writei+0x4c>
      brelse(bp);
    80003080:	8526                	mv	a0,s1
    80003082:	fffff097          	auipc	ra,0xfffff
    80003086:	49c080e7          	jalr	1180(ra) # 8000251e <brelse>
  }

  if(off > ip->size)
    8000308a:	04caa783          	lw	a5,76(s5)
    8000308e:	0127f463          	bgeu	a5,s2,80003096 <writei+0xe2>
    ip->size = off;
    80003092:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003096:	8556                	mv	a0,s5
    80003098:	00000097          	auipc	ra,0x0
    8000309c:	aa6080e7          	jalr	-1370(ra) # 80002b3e <iupdate>

  return tot;
    800030a0:	0009851b          	sext.w	a0,s3
}
    800030a4:	70a6                	ld	ra,104(sp)
    800030a6:	7406                	ld	s0,96(sp)
    800030a8:	64e6                	ld	s1,88(sp)
    800030aa:	6946                	ld	s2,80(sp)
    800030ac:	69a6                	ld	s3,72(sp)
    800030ae:	6a06                	ld	s4,64(sp)
    800030b0:	7ae2                	ld	s5,56(sp)
    800030b2:	7b42                	ld	s6,48(sp)
    800030b4:	7ba2                	ld	s7,40(sp)
    800030b6:	7c02                	ld	s8,32(sp)
    800030b8:	6ce2                	ld	s9,24(sp)
    800030ba:	6d42                	ld	s10,16(sp)
    800030bc:	6da2                	ld	s11,8(sp)
    800030be:	6165                	addi	sp,sp,112
    800030c0:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800030c2:	89da                	mv	s3,s6
    800030c4:	bfc9                	j	80003096 <writei+0xe2>
    return -1;
    800030c6:	557d                	li	a0,-1
}
    800030c8:	8082                	ret
    return -1;
    800030ca:	557d                	li	a0,-1
    800030cc:	bfe1                	j	800030a4 <writei+0xf0>
    return -1;
    800030ce:	557d                	li	a0,-1
    800030d0:	bfd1                	j	800030a4 <writei+0xf0>

00000000800030d2 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800030d2:	1141                	addi	sp,sp,-16
    800030d4:	e406                	sd	ra,8(sp)
    800030d6:	e022                	sd	s0,0(sp)
    800030d8:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800030da:	4639                	li	a2,14
    800030dc:	ffffd097          	auipc	ra,0xffffd
    800030e0:	198080e7          	jalr	408(ra) # 80000274 <strncmp>
}
    800030e4:	60a2                	ld	ra,8(sp)
    800030e6:	6402                	ld	s0,0(sp)
    800030e8:	0141                	addi	sp,sp,16
    800030ea:	8082                	ret

00000000800030ec <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800030ec:	7139                	addi	sp,sp,-64
    800030ee:	fc06                	sd	ra,56(sp)
    800030f0:	f822                	sd	s0,48(sp)
    800030f2:	f426                	sd	s1,40(sp)
    800030f4:	f04a                	sd	s2,32(sp)
    800030f6:	ec4e                	sd	s3,24(sp)
    800030f8:	e852                	sd	s4,16(sp)
    800030fa:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800030fc:	04451703          	lh	a4,68(a0)
    80003100:	4785                	li	a5,1
    80003102:	00f71a63          	bne	a4,a5,80003116 <dirlookup+0x2a>
    80003106:	892a                	mv	s2,a0
    80003108:	89ae                	mv	s3,a1
    8000310a:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000310c:	457c                	lw	a5,76(a0)
    8000310e:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003110:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003112:	e79d                	bnez	a5,80003140 <dirlookup+0x54>
    80003114:	a8a5                	j	8000318c <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003116:	00005517          	auipc	a0,0x5
    8000311a:	65250513          	addi	a0,a0,1618 # 80008768 <syscallnames+0x1b0>
    8000311e:	00003097          	auipc	ra,0x3
    80003122:	be4080e7          	jalr	-1052(ra) # 80005d02 <panic>
      panic("dirlookup read");
    80003126:	00005517          	auipc	a0,0x5
    8000312a:	65a50513          	addi	a0,a0,1626 # 80008780 <syscallnames+0x1c8>
    8000312e:	00003097          	auipc	ra,0x3
    80003132:	bd4080e7          	jalr	-1068(ra) # 80005d02 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003136:	24c1                	addiw	s1,s1,16
    80003138:	04c92783          	lw	a5,76(s2)
    8000313c:	04f4f763          	bgeu	s1,a5,8000318a <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003140:	4741                	li	a4,16
    80003142:	86a6                	mv	a3,s1
    80003144:	fc040613          	addi	a2,s0,-64
    80003148:	4581                	li	a1,0
    8000314a:	854a                	mv	a0,s2
    8000314c:	00000097          	auipc	ra,0x0
    80003150:	d70080e7          	jalr	-656(ra) # 80002ebc <readi>
    80003154:	47c1                	li	a5,16
    80003156:	fcf518e3          	bne	a0,a5,80003126 <dirlookup+0x3a>
    if(de.inum == 0)
    8000315a:	fc045783          	lhu	a5,-64(s0)
    8000315e:	dfe1                	beqz	a5,80003136 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003160:	fc240593          	addi	a1,s0,-62
    80003164:	854e                	mv	a0,s3
    80003166:	00000097          	auipc	ra,0x0
    8000316a:	f6c080e7          	jalr	-148(ra) # 800030d2 <namecmp>
    8000316e:	f561                	bnez	a0,80003136 <dirlookup+0x4a>
      if(poff)
    80003170:	000a0463          	beqz	s4,80003178 <dirlookup+0x8c>
        *poff = off;
    80003174:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003178:	fc045583          	lhu	a1,-64(s0)
    8000317c:	00092503          	lw	a0,0(s2)
    80003180:	fffff097          	auipc	ra,0xfffff
    80003184:	750080e7          	jalr	1872(ra) # 800028d0 <iget>
    80003188:	a011                	j	8000318c <dirlookup+0xa0>
  return 0;
    8000318a:	4501                	li	a0,0
}
    8000318c:	70e2                	ld	ra,56(sp)
    8000318e:	7442                	ld	s0,48(sp)
    80003190:	74a2                	ld	s1,40(sp)
    80003192:	7902                	ld	s2,32(sp)
    80003194:	69e2                	ld	s3,24(sp)
    80003196:	6a42                	ld	s4,16(sp)
    80003198:	6121                	addi	sp,sp,64
    8000319a:	8082                	ret

000000008000319c <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000319c:	711d                	addi	sp,sp,-96
    8000319e:	ec86                	sd	ra,88(sp)
    800031a0:	e8a2                	sd	s0,80(sp)
    800031a2:	e4a6                	sd	s1,72(sp)
    800031a4:	e0ca                	sd	s2,64(sp)
    800031a6:	fc4e                	sd	s3,56(sp)
    800031a8:	f852                	sd	s4,48(sp)
    800031aa:	f456                	sd	s5,40(sp)
    800031ac:	f05a                	sd	s6,32(sp)
    800031ae:	ec5e                	sd	s7,24(sp)
    800031b0:	e862                	sd	s8,16(sp)
    800031b2:	e466                	sd	s9,8(sp)
    800031b4:	1080                	addi	s0,sp,96
    800031b6:	84aa                	mv	s1,a0
    800031b8:	8b2e                	mv	s6,a1
    800031ba:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800031bc:	00054703          	lbu	a4,0(a0)
    800031c0:	02f00793          	li	a5,47
    800031c4:	02f70363          	beq	a4,a5,800031ea <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800031c8:	ffffe097          	auipc	ra,0xffffe
    800031cc:	cb4080e7          	jalr	-844(ra) # 80000e7c <myproc>
    800031d0:	15053503          	ld	a0,336(a0)
    800031d4:	00000097          	auipc	ra,0x0
    800031d8:	9f6080e7          	jalr	-1546(ra) # 80002bca <idup>
    800031dc:	89aa                	mv	s3,a0
  while(*path == '/')
    800031de:	02f00913          	li	s2,47
  len = path - s;
    800031e2:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    800031e4:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800031e6:	4c05                	li	s8,1
    800031e8:	a865                	j	800032a0 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    800031ea:	4585                	li	a1,1
    800031ec:	4505                	li	a0,1
    800031ee:	fffff097          	auipc	ra,0xfffff
    800031f2:	6e2080e7          	jalr	1762(ra) # 800028d0 <iget>
    800031f6:	89aa                	mv	s3,a0
    800031f8:	b7dd                	j	800031de <namex+0x42>
      iunlockput(ip);
    800031fa:	854e                	mv	a0,s3
    800031fc:	00000097          	auipc	ra,0x0
    80003200:	c6e080e7          	jalr	-914(ra) # 80002e6a <iunlockput>
      return 0;
    80003204:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003206:	854e                	mv	a0,s3
    80003208:	60e6                	ld	ra,88(sp)
    8000320a:	6446                	ld	s0,80(sp)
    8000320c:	64a6                	ld	s1,72(sp)
    8000320e:	6906                	ld	s2,64(sp)
    80003210:	79e2                	ld	s3,56(sp)
    80003212:	7a42                	ld	s4,48(sp)
    80003214:	7aa2                	ld	s5,40(sp)
    80003216:	7b02                	ld	s6,32(sp)
    80003218:	6be2                	ld	s7,24(sp)
    8000321a:	6c42                	ld	s8,16(sp)
    8000321c:	6ca2                	ld	s9,8(sp)
    8000321e:	6125                	addi	sp,sp,96
    80003220:	8082                	ret
      iunlock(ip);
    80003222:	854e                	mv	a0,s3
    80003224:	00000097          	auipc	ra,0x0
    80003228:	aa6080e7          	jalr	-1370(ra) # 80002cca <iunlock>
      return ip;
    8000322c:	bfe9                	j	80003206 <namex+0x6a>
      iunlockput(ip);
    8000322e:	854e                	mv	a0,s3
    80003230:	00000097          	auipc	ra,0x0
    80003234:	c3a080e7          	jalr	-966(ra) # 80002e6a <iunlockput>
      return 0;
    80003238:	89d2                	mv	s3,s4
    8000323a:	b7f1                	j	80003206 <namex+0x6a>
  len = path - s;
    8000323c:	40b48633          	sub	a2,s1,a1
    80003240:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003244:	094cd463          	bge	s9,s4,800032cc <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003248:	4639                	li	a2,14
    8000324a:	8556                	mv	a0,s5
    8000324c:	ffffd097          	auipc	ra,0xffffd
    80003250:	fb0080e7          	jalr	-80(ra) # 800001fc <memmove>
  while(*path == '/')
    80003254:	0004c783          	lbu	a5,0(s1)
    80003258:	01279763          	bne	a5,s2,80003266 <namex+0xca>
    path++;
    8000325c:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000325e:	0004c783          	lbu	a5,0(s1)
    80003262:	ff278de3          	beq	a5,s2,8000325c <namex+0xc0>
    ilock(ip);
    80003266:	854e                	mv	a0,s3
    80003268:	00000097          	auipc	ra,0x0
    8000326c:	9a0080e7          	jalr	-1632(ra) # 80002c08 <ilock>
    if(ip->type != T_DIR){
    80003270:	04499783          	lh	a5,68(s3)
    80003274:	f98793e3          	bne	a5,s8,800031fa <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003278:	000b0563          	beqz	s6,80003282 <namex+0xe6>
    8000327c:	0004c783          	lbu	a5,0(s1)
    80003280:	d3cd                	beqz	a5,80003222 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003282:	865e                	mv	a2,s7
    80003284:	85d6                	mv	a1,s5
    80003286:	854e                	mv	a0,s3
    80003288:	00000097          	auipc	ra,0x0
    8000328c:	e64080e7          	jalr	-412(ra) # 800030ec <dirlookup>
    80003290:	8a2a                	mv	s4,a0
    80003292:	dd51                	beqz	a0,8000322e <namex+0x92>
    iunlockput(ip);
    80003294:	854e                	mv	a0,s3
    80003296:	00000097          	auipc	ra,0x0
    8000329a:	bd4080e7          	jalr	-1068(ra) # 80002e6a <iunlockput>
    ip = next;
    8000329e:	89d2                	mv	s3,s4
  while(*path == '/')
    800032a0:	0004c783          	lbu	a5,0(s1)
    800032a4:	05279763          	bne	a5,s2,800032f2 <namex+0x156>
    path++;
    800032a8:	0485                	addi	s1,s1,1
  while(*path == '/')
    800032aa:	0004c783          	lbu	a5,0(s1)
    800032ae:	ff278de3          	beq	a5,s2,800032a8 <namex+0x10c>
  if(*path == 0)
    800032b2:	c79d                	beqz	a5,800032e0 <namex+0x144>
    path++;
    800032b4:	85a6                	mv	a1,s1
  len = path - s;
    800032b6:	8a5e                	mv	s4,s7
    800032b8:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    800032ba:	01278963          	beq	a5,s2,800032cc <namex+0x130>
    800032be:	dfbd                	beqz	a5,8000323c <namex+0xa0>
    path++;
    800032c0:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    800032c2:	0004c783          	lbu	a5,0(s1)
    800032c6:	ff279ce3          	bne	a5,s2,800032be <namex+0x122>
    800032ca:	bf8d                	j	8000323c <namex+0xa0>
    memmove(name, s, len);
    800032cc:	2601                	sext.w	a2,a2
    800032ce:	8556                	mv	a0,s5
    800032d0:	ffffd097          	auipc	ra,0xffffd
    800032d4:	f2c080e7          	jalr	-212(ra) # 800001fc <memmove>
    name[len] = 0;
    800032d8:	9a56                	add	s4,s4,s5
    800032da:	000a0023          	sb	zero,0(s4)
    800032de:	bf9d                	j	80003254 <namex+0xb8>
  if(nameiparent){
    800032e0:	f20b03e3          	beqz	s6,80003206 <namex+0x6a>
    iput(ip);
    800032e4:	854e                	mv	a0,s3
    800032e6:	00000097          	auipc	ra,0x0
    800032ea:	adc080e7          	jalr	-1316(ra) # 80002dc2 <iput>
    return 0;
    800032ee:	4981                	li	s3,0
    800032f0:	bf19                	j	80003206 <namex+0x6a>
  if(*path == 0)
    800032f2:	d7fd                	beqz	a5,800032e0 <namex+0x144>
  while(*path != '/' && *path != 0)
    800032f4:	0004c783          	lbu	a5,0(s1)
    800032f8:	85a6                	mv	a1,s1
    800032fa:	b7d1                	j	800032be <namex+0x122>

00000000800032fc <dirlink>:
{
    800032fc:	7139                	addi	sp,sp,-64
    800032fe:	fc06                	sd	ra,56(sp)
    80003300:	f822                	sd	s0,48(sp)
    80003302:	f426                	sd	s1,40(sp)
    80003304:	f04a                	sd	s2,32(sp)
    80003306:	ec4e                	sd	s3,24(sp)
    80003308:	e852                	sd	s4,16(sp)
    8000330a:	0080                	addi	s0,sp,64
    8000330c:	892a                	mv	s2,a0
    8000330e:	8a2e                	mv	s4,a1
    80003310:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003312:	4601                	li	a2,0
    80003314:	00000097          	auipc	ra,0x0
    80003318:	dd8080e7          	jalr	-552(ra) # 800030ec <dirlookup>
    8000331c:	e93d                	bnez	a0,80003392 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000331e:	04c92483          	lw	s1,76(s2)
    80003322:	c49d                	beqz	s1,80003350 <dirlink+0x54>
    80003324:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003326:	4741                	li	a4,16
    80003328:	86a6                	mv	a3,s1
    8000332a:	fc040613          	addi	a2,s0,-64
    8000332e:	4581                	li	a1,0
    80003330:	854a                	mv	a0,s2
    80003332:	00000097          	auipc	ra,0x0
    80003336:	b8a080e7          	jalr	-1142(ra) # 80002ebc <readi>
    8000333a:	47c1                	li	a5,16
    8000333c:	06f51163          	bne	a0,a5,8000339e <dirlink+0xa2>
    if(de.inum == 0)
    80003340:	fc045783          	lhu	a5,-64(s0)
    80003344:	c791                	beqz	a5,80003350 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003346:	24c1                	addiw	s1,s1,16
    80003348:	04c92783          	lw	a5,76(s2)
    8000334c:	fcf4ede3          	bltu	s1,a5,80003326 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003350:	4639                	li	a2,14
    80003352:	85d2                	mv	a1,s4
    80003354:	fc240513          	addi	a0,s0,-62
    80003358:	ffffd097          	auipc	ra,0xffffd
    8000335c:	f58080e7          	jalr	-168(ra) # 800002b0 <strncpy>
  de.inum = inum;
    80003360:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003364:	4741                	li	a4,16
    80003366:	86a6                	mv	a3,s1
    80003368:	fc040613          	addi	a2,s0,-64
    8000336c:	4581                	li	a1,0
    8000336e:	854a                	mv	a0,s2
    80003370:	00000097          	auipc	ra,0x0
    80003374:	c44080e7          	jalr	-956(ra) # 80002fb4 <writei>
    80003378:	1541                	addi	a0,a0,-16
    8000337a:	00a03533          	snez	a0,a0
    8000337e:	40a00533          	neg	a0,a0
}
    80003382:	70e2                	ld	ra,56(sp)
    80003384:	7442                	ld	s0,48(sp)
    80003386:	74a2                	ld	s1,40(sp)
    80003388:	7902                	ld	s2,32(sp)
    8000338a:	69e2                	ld	s3,24(sp)
    8000338c:	6a42                	ld	s4,16(sp)
    8000338e:	6121                	addi	sp,sp,64
    80003390:	8082                	ret
    iput(ip);
    80003392:	00000097          	auipc	ra,0x0
    80003396:	a30080e7          	jalr	-1488(ra) # 80002dc2 <iput>
    return -1;
    8000339a:	557d                	li	a0,-1
    8000339c:	b7dd                	j	80003382 <dirlink+0x86>
      panic("dirlink read");
    8000339e:	00005517          	auipc	a0,0x5
    800033a2:	3f250513          	addi	a0,a0,1010 # 80008790 <syscallnames+0x1d8>
    800033a6:	00003097          	auipc	ra,0x3
    800033aa:	95c080e7          	jalr	-1700(ra) # 80005d02 <panic>

00000000800033ae <namei>:

struct inode*
namei(char *path)
{
    800033ae:	1101                	addi	sp,sp,-32
    800033b0:	ec06                	sd	ra,24(sp)
    800033b2:	e822                	sd	s0,16(sp)
    800033b4:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800033b6:	fe040613          	addi	a2,s0,-32
    800033ba:	4581                	li	a1,0
    800033bc:	00000097          	auipc	ra,0x0
    800033c0:	de0080e7          	jalr	-544(ra) # 8000319c <namex>
}
    800033c4:	60e2                	ld	ra,24(sp)
    800033c6:	6442                	ld	s0,16(sp)
    800033c8:	6105                	addi	sp,sp,32
    800033ca:	8082                	ret

00000000800033cc <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800033cc:	1141                	addi	sp,sp,-16
    800033ce:	e406                	sd	ra,8(sp)
    800033d0:	e022                	sd	s0,0(sp)
    800033d2:	0800                	addi	s0,sp,16
    800033d4:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800033d6:	4585                	li	a1,1
    800033d8:	00000097          	auipc	ra,0x0
    800033dc:	dc4080e7          	jalr	-572(ra) # 8000319c <namex>
}
    800033e0:	60a2                	ld	ra,8(sp)
    800033e2:	6402                	ld	s0,0(sp)
    800033e4:	0141                	addi	sp,sp,16
    800033e6:	8082                	ret

00000000800033e8 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800033e8:	1101                	addi	sp,sp,-32
    800033ea:	ec06                	sd	ra,24(sp)
    800033ec:	e822                	sd	s0,16(sp)
    800033ee:	e426                	sd	s1,8(sp)
    800033f0:	e04a                	sd	s2,0(sp)
    800033f2:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800033f4:	00016917          	auipc	s2,0x16
    800033f8:	8cc90913          	addi	s2,s2,-1844 # 80018cc0 <log>
    800033fc:	01892583          	lw	a1,24(s2)
    80003400:	02892503          	lw	a0,40(s2)
    80003404:	fffff097          	auipc	ra,0xfffff
    80003408:	fea080e7          	jalr	-22(ra) # 800023ee <bread>
    8000340c:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000340e:	02c92683          	lw	a3,44(s2)
    80003412:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003414:	02d05763          	blez	a3,80003442 <write_head+0x5a>
    80003418:	00016797          	auipc	a5,0x16
    8000341c:	8d878793          	addi	a5,a5,-1832 # 80018cf0 <log+0x30>
    80003420:	05c50713          	addi	a4,a0,92
    80003424:	36fd                	addiw	a3,a3,-1
    80003426:	1682                	slli	a3,a3,0x20
    80003428:	9281                	srli	a3,a3,0x20
    8000342a:	068a                	slli	a3,a3,0x2
    8000342c:	00016617          	auipc	a2,0x16
    80003430:	8c860613          	addi	a2,a2,-1848 # 80018cf4 <log+0x34>
    80003434:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003436:	4390                	lw	a2,0(a5)
    80003438:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000343a:	0791                	addi	a5,a5,4
    8000343c:	0711                	addi	a4,a4,4
    8000343e:	fed79ce3          	bne	a5,a3,80003436 <write_head+0x4e>
  }
  bwrite(buf);
    80003442:	8526                	mv	a0,s1
    80003444:	fffff097          	auipc	ra,0xfffff
    80003448:	09c080e7          	jalr	156(ra) # 800024e0 <bwrite>
  brelse(buf);
    8000344c:	8526                	mv	a0,s1
    8000344e:	fffff097          	auipc	ra,0xfffff
    80003452:	0d0080e7          	jalr	208(ra) # 8000251e <brelse>
}
    80003456:	60e2                	ld	ra,24(sp)
    80003458:	6442                	ld	s0,16(sp)
    8000345a:	64a2                	ld	s1,8(sp)
    8000345c:	6902                	ld	s2,0(sp)
    8000345e:	6105                	addi	sp,sp,32
    80003460:	8082                	ret

0000000080003462 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003462:	00016797          	auipc	a5,0x16
    80003466:	88a7a783          	lw	a5,-1910(a5) # 80018cec <log+0x2c>
    8000346a:	0af05d63          	blez	a5,80003524 <install_trans+0xc2>
{
    8000346e:	7139                	addi	sp,sp,-64
    80003470:	fc06                	sd	ra,56(sp)
    80003472:	f822                	sd	s0,48(sp)
    80003474:	f426                	sd	s1,40(sp)
    80003476:	f04a                	sd	s2,32(sp)
    80003478:	ec4e                	sd	s3,24(sp)
    8000347a:	e852                	sd	s4,16(sp)
    8000347c:	e456                	sd	s5,8(sp)
    8000347e:	e05a                	sd	s6,0(sp)
    80003480:	0080                	addi	s0,sp,64
    80003482:	8b2a                	mv	s6,a0
    80003484:	00016a97          	auipc	s5,0x16
    80003488:	86ca8a93          	addi	s5,s5,-1940 # 80018cf0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000348c:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000348e:	00016997          	auipc	s3,0x16
    80003492:	83298993          	addi	s3,s3,-1998 # 80018cc0 <log>
    80003496:	a035                	j	800034c2 <install_trans+0x60>
      bunpin(dbuf);
    80003498:	8526                	mv	a0,s1
    8000349a:	fffff097          	auipc	ra,0xfffff
    8000349e:	15e080e7          	jalr	350(ra) # 800025f8 <bunpin>
    brelse(lbuf);
    800034a2:	854a                	mv	a0,s2
    800034a4:	fffff097          	auipc	ra,0xfffff
    800034a8:	07a080e7          	jalr	122(ra) # 8000251e <brelse>
    brelse(dbuf);
    800034ac:	8526                	mv	a0,s1
    800034ae:	fffff097          	auipc	ra,0xfffff
    800034b2:	070080e7          	jalr	112(ra) # 8000251e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800034b6:	2a05                	addiw	s4,s4,1
    800034b8:	0a91                	addi	s5,s5,4
    800034ba:	02c9a783          	lw	a5,44(s3)
    800034be:	04fa5963          	bge	s4,a5,80003510 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800034c2:	0189a583          	lw	a1,24(s3)
    800034c6:	014585bb          	addw	a1,a1,s4
    800034ca:	2585                	addiw	a1,a1,1
    800034cc:	0289a503          	lw	a0,40(s3)
    800034d0:	fffff097          	auipc	ra,0xfffff
    800034d4:	f1e080e7          	jalr	-226(ra) # 800023ee <bread>
    800034d8:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800034da:	000aa583          	lw	a1,0(s5)
    800034de:	0289a503          	lw	a0,40(s3)
    800034e2:	fffff097          	auipc	ra,0xfffff
    800034e6:	f0c080e7          	jalr	-244(ra) # 800023ee <bread>
    800034ea:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800034ec:	40000613          	li	a2,1024
    800034f0:	05890593          	addi	a1,s2,88
    800034f4:	05850513          	addi	a0,a0,88
    800034f8:	ffffd097          	auipc	ra,0xffffd
    800034fc:	d04080e7          	jalr	-764(ra) # 800001fc <memmove>
    bwrite(dbuf);  // write dst to disk
    80003500:	8526                	mv	a0,s1
    80003502:	fffff097          	auipc	ra,0xfffff
    80003506:	fde080e7          	jalr	-34(ra) # 800024e0 <bwrite>
    if(recovering == 0)
    8000350a:	f80b1ce3          	bnez	s6,800034a2 <install_trans+0x40>
    8000350e:	b769                	j	80003498 <install_trans+0x36>
}
    80003510:	70e2                	ld	ra,56(sp)
    80003512:	7442                	ld	s0,48(sp)
    80003514:	74a2                	ld	s1,40(sp)
    80003516:	7902                	ld	s2,32(sp)
    80003518:	69e2                	ld	s3,24(sp)
    8000351a:	6a42                	ld	s4,16(sp)
    8000351c:	6aa2                	ld	s5,8(sp)
    8000351e:	6b02                	ld	s6,0(sp)
    80003520:	6121                	addi	sp,sp,64
    80003522:	8082                	ret
    80003524:	8082                	ret

0000000080003526 <initlog>:
{
    80003526:	7179                	addi	sp,sp,-48
    80003528:	f406                	sd	ra,40(sp)
    8000352a:	f022                	sd	s0,32(sp)
    8000352c:	ec26                	sd	s1,24(sp)
    8000352e:	e84a                	sd	s2,16(sp)
    80003530:	e44e                	sd	s3,8(sp)
    80003532:	1800                	addi	s0,sp,48
    80003534:	892a                	mv	s2,a0
    80003536:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003538:	00015497          	auipc	s1,0x15
    8000353c:	78848493          	addi	s1,s1,1928 # 80018cc0 <log>
    80003540:	00005597          	auipc	a1,0x5
    80003544:	26058593          	addi	a1,a1,608 # 800087a0 <syscallnames+0x1e8>
    80003548:	8526                	mv	a0,s1
    8000354a:	00003097          	auipc	ra,0x3
    8000354e:	c72080e7          	jalr	-910(ra) # 800061bc <initlock>
  log.start = sb->logstart;
    80003552:	0149a583          	lw	a1,20(s3)
    80003556:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003558:	0109a783          	lw	a5,16(s3)
    8000355c:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000355e:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003562:	854a                	mv	a0,s2
    80003564:	fffff097          	auipc	ra,0xfffff
    80003568:	e8a080e7          	jalr	-374(ra) # 800023ee <bread>
  log.lh.n = lh->n;
    8000356c:	4d3c                	lw	a5,88(a0)
    8000356e:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003570:	02f05563          	blez	a5,8000359a <initlog+0x74>
    80003574:	05c50713          	addi	a4,a0,92
    80003578:	00015697          	auipc	a3,0x15
    8000357c:	77868693          	addi	a3,a3,1912 # 80018cf0 <log+0x30>
    80003580:	37fd                	addiw	a5,a5,-1
    80003582:	1782                	slli	a5,a5,0x20
    80003584:	9381                	srli	a5,a5,0x20
    80003586:	078a                	slli	a5,a5,0x2
    80003588:	06050613          	addi	a2,a0,96
    8000358c:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    8000358e:	4310                	lw	a2,0(a4)
    80003590:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    80003592:	0711                	addi	a4,a4,4
    80003594:	0691                	addi	a3,a3,4
    80003596:	fef71ce3          	bne	a4,a5,8000358e <initlog+0x68>
  brelse(buf);
    8000359a:	fffff097          	auipc	ra,0xfffff
    8000359e:	f84080e7          	jalr	-124(ra) # 8000251e <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800035a2:	4505                	li	a0,1
    800035a4:	00000097          	auipc	ra,0x0
    800035a8:	ebe080e7          	jalr	-322(ra) # 80003462 <install_trans>
  log.lh.n = 0;
    800035ac:	00015797          	auipc	a5,0x15
    800035b0:	7407a023          	sw	zero,1856(a5) # 80018cec <log+0x2c>
  write_head(); // clear the log
    800035b4:	00000097          	auipc	ra,0x0
    800035b8:	e34080e7          	jalr	-460(ra) # 800033e8 <write_head>
}
    800035bc:	70a2                	ld	ra,40(sp)
    800035be:	7402                	ld	s0,32(sp)
    800035c0:	64e2                	ld	s1,24(sp)
    800035c2:	6942                	ld	s2,16(sp)
    800035c4:	69a2                	ld	s3,8(sp)
    800035c6:	6145                	addi	sp,sp,48
    800035c8:	8082                	ret

00000000800035ca <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800035ca:	1101                	addi	sp,sp,-32
    800035cc:	ec06                	sd	ra,24(sp)
    800035ce:	e822                	sd	s0,16(sp)
    800035d0:	e426                	sd	s1,8(sp)
    800035d2:	e04a                	sd	s2,0(sp)
    800035d4:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800035d6:	00015517          	auipc	a0,0x15
    800035da:	6ea50513          	addi	a0,a0,1770 # 80018cc0 <log>
    800035de:	00003097          	auipc	ra,0x3
    800035e2:	c6e080e7          	jalr	-914(ra) # 8000624c <acquire>
  while(1){
    if(log.committing){
    800035e6:	00015497          	auipc	s1,0x15
    800035ea:	6da48493          	addi	s1,s1,1754 # 80018cc0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800035ee:	4979                	li	s2,30
    800035f0:	a039                	j	800035fe <begin_op+0x34>
      sleep(&log, &log.lock);
    800035f2:	85a6                	mv	a1,s1
    800035f4:	8526                	mv	a0,s1
    800035f6:	ffffe097          	auipc	ra,0xffffe
    800035fa:	f32080e7          	jalr	-206(ra) # 80001528 <sleep>
    if(log.committing){
    800035fe:	50dc                	lw	a5,36(s1)
    80003600:	fbed                	bnez	a5,800035f2 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003602:	509c                	lw	a5,32(s1)
    80003604:	0017871b          	addiw	a4,a5,1
    80003608:	0007069b          	sext.w	a3,a4
    8000360c:	0027179b          	slliw	a5,a4,0x2
    80003610:	9fb9                	addw	a5,a5,a4
    80003612:	0017979b          	slliw	a5,a5,0x1
    80003616:	54d8                	lw	a4,44(s1)
    80003618:	9fb9                	addw	a5,a5,a4
    8000361a:	00f95963          	bge	s2,a5,8000362c <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000361e:	85a6                	mv	a1,s1
    80003620:	8526                	mv	a0,s1
    80003622:	ffffe097          	auipc	ra,0xffffe
    80003626:	f06080e7          	jalr	-250(ra) # 80001528 <sleep>
    8000362a:	bfd1                	j	800035fe <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000362c:	00015517          	auipc	a0,0x15
    80003630:	69450513          	addi	a0,a0,1684 # 80018cc0 <log>
    80003634:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80003636:	00003097          	auipc	ra,0x3
    8000363a:	cca080e7          	jalr	-822(ra) # 80006300 <release>
      break;
    }
  }
}
    8000363e:	60e2                	ld	ra,24(sp)
    80003640:	6442                	ld	s0,16(sp)
    80003642:	64a2                	ld	s1,8(sp)
    80003644:	6902                	ld	s2,0(sp)
    80003646:	6105                	addi	sp,sp,32
    80003648:	8082                	ret

000000008000364a <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000364a:	7139                	addi	sp,sp,-64
    8000364c:	fc06                	sd	ra,56(sp)
    8000364e:	f822                	sd	s0,48(sp)
    80003650:	f426                	sd	s1,40(sp)
    80003652:	f04a                	sd	s2,32(sp)
    80003654:	ec4e                	sd	s3,24(sp)
    80003656:	e852                	sd	s4,16(sp)
    80003658:	e456                	sd	s5,8(sp)
    8000365a:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000365c:	00015497          	auipc	s1,0x15
    80003660:	66448493          	addi	s1,s1,1636 # 80018cc0 <log>
    80003664:	8526                	mv	a0,s1
    80003666:	00003097          	auipc	ra,0x3
    8000366a:	be6080e7          	jalr	-1050(ra) # 8000624c <acquire>
  log.outstanding -= 1;
    8000366e:	509c                	lw	a5,32(s1)
    80003670:	37fd                	addiw	a5,a5,-1
    80003672:	0007891b          	sext.w	s2,a5
    80003676:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80003678:	50dc                	lw	a5,36(s1)
    8000367a:	efb9                	bnez	a5,800036d8 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000367c:	06091663          	bnez	s2,800036e8 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    80003680:	00015497          	auipc	s1,0x15
    80003684:	64048493          	addi	s1,s1,1600 # 80018cc0 <log>
    80003688:	4785                	li	a5,1
    8000368a:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000368c:	8526                	mv	a0,s1
    8000368e:	00003097          	auipc	ra,0x3
    80003692:	c72080e7          	jalr	-910(ra) # 80006300 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003696:	54dc                	lw	a5,44(s1)
    80003698:	06f04763          	bgtz	a5,80003706 <end_op+0xbc>
    acquire(&log.lock);
    8000369c:	00015497          	auipc	s1,0x15
    800036a0:	62448493          	addi	s1,s1,1572 # 80018cc0 <log>
    800036a4:	8526                	mv	a0,s1
    800036a6:	00003097          	auipc	ra,0x3
    800036aa:	ba6080e7          	jalr	-1114(ra) # 8000624c <acquire>
    log.committing = 0;
    800036ae:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800036b2:	8526                	mv	a0,s1
    800036b4:	ffffe097          	auipc	ra,0xffffe
    800036b8:	ed8080e7          	jalr	-296(ra) # 8000158c <wakeup>
    release(&log.lock);
    800036bc:	8526                	mv	a0,s1
    800036be:	00003097          	auipc	ra,0x3
    800036c2:	c42080e7          	jalr	-958(ra) # 80006300 <release>
}
    800036c6:	70e2                	ld	ra,56(sp)
    800036c8:	7442                	ld	s0,48(sp)
    800036ca:	74a2                	ld	s1,40(sp)
    800036cc:	7902                	ld	s2,32(sp)
    800036ce:	69e2                	ld	s3,24(sp)
    800036d0:	6a42                	ld	s4,16(sp)
    800036d2:	6aa2                	ld	s5,8(sp)
    800036d4:	6121                	addi	sp,sp,64
    800036d6:	8082                	ret
    panic("log.committing");
    800036d8:	00005517          	auipc	a0,0x5
    800036dc:	0d050513          	addi	a0,a0,208 # 800087a8 <syscallnames+0x1f0>
    800036e0:	00002097          	auipc	ra,0x2
    800036e4:	622080e7          	jalr	1570(ra) # 80005d02 <panic>
    wakeup(&log);
    800036e8:	00015497          	auipc	s1,0x15
    800036ec:	5d848493          	addi	s1,s1,1496 # 80018cc0 <log>
    800036f0:	8526                	mv	a0,s1
    800036f2:	ffffe097          	auipc	ra,0xffffe
    800036f6:	e9a080e7          	jalr	-358(ra) # 8000158c <wakeup>
  release(&log.lock);
    800036fa:	8526                	mv	a0,s1
    800036fc:	00003097          	auipc	ra,0x3
    80003700:	c04080e7          	jalr	-1020(ra) # 80006300 <release>
  if(do_commit){
    80003704:	b7c9                	j	800036c6 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003706:	00015a97          	auipc	s5,0x15
    8000370a:	5eaa8a93          	addi	s5,s5,1514 # 80018cf0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000370e:	00015a17          	auipc	s4,0x15
    80003712:	5b2a0a13          	addi	s4,s4,1458 # 80018cc0 <log>
    80003716:	018a2583          	lw	a1,24(s4)
    8000371a:	012585bb          	addw	a1,a1,s2
    8000371e:	2585                	addiw	a1,a1,1
    80003720:	028a2503          	lw	a0,40(s4)
    80003724:	fffff097          	auipc	ra,0xfffff
    80003728:	cca080e7          	jalr	-822(ra) # 800023ee <bread>
    8000372c:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000372e:	000aa583          	lw	a1,0(s5)
    80003732:	028a2503          	lw	a0,40(s4)
    80003736:	fffff097          	auipc	ra,0xfffff
    8000373a:	cb8080e7          	jalr	-840(ra) # 800023ee <bread>
    8000373e:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003740:	40000613          	li	a2,1024
    80003744:	05850593          	addi	a1,a0,88
    80003748:	05848513          	addi	a0,s1,88
    8000374c:	ffffd097          	auipc	ra,0xffffd
    80003750:	ab0080e7          	jalr	-1360(ra) # 800001fc <memmove>
    bwrite(to);  // write the log
    80003754:	8526                	mv	a0,s1
    80003756:	fffff097          	auipc	ra,0xfffff
    8000375a:	d8a080e7          	jalr	-630(ra) # 800024e0 <bwrite>
    brelse(from);
    8000375e:	854e                	mv	a0,s3
    80003760:	fffff097          	auipc	ra,0xfffff
    80003764:	dbe080e7          	jalr	-578(ra) # 8000251e <brelse>
    brelse(to);
    80003768:	8526                	mv	a0,s1
    8000376a:	fffff097          	auipc	ra,0xfffff
    8000376e:	db4080e7          	jalr	-588(ra) # 8000251e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003772:	2905                	addiw	s2,s2,1
    80003774:	0a91                	addi	s5,s5,4
    80003776:	02ca2783          	lw	a5,44(s4)
    8000377a:	f8f94ee3          	blt	s2,a5,80003716 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000377e:	00000097          	auipc	ra,0x0
    80003782:	c6a080e7          	jalr	-918(ra) # 800033e8 <write_head>
    install_trans(0); // Now install writes to home locations
    80003786:	4501                	li	a0,0
    80003788:	00000097          	auipc	ra,0x0
    8000378c:	cda080e7          	jalr	-806(ra) # 80003462 <install_trans>
    log.lh.n = 0;
    80003790:	00015797          	auipc	a5,0x15
    80003794:	5407ae23          	sw	zero,1372(a5) # 80018cec <log+0x2c>
    write_head();    // Erase the transaction from the log
    80003798:	00000097          	auipc	ra,0x0
    8000379c:	c50080e7          	jalr	-944(ra) # 800033e8 <write_head>
    800037a0:	bdf5                	j	8000369c <end_op+0x52>

00000000800037a2 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800037a2:	1101                	addi	sp,sp,-32
    800037a4:	ec06                	sd	ra,24(sp)
    800037a6:	e822                	sd	s0,16(sp)
    800037a8:	e426                	sd	s1,8(sp)
    800037aa:	e04a                	sd	s2,0(sp)
    800037ac:	1000                	addi	s0,sp,32
    800037ae:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800037b0:	00015917          	auipc	s2,0x15
    800037b4:	51090913          	addi	s2,s2,1296 # 80018cc0 <log>
    800037b8:	854a                	mv	a0,s2
    800037ba:	00003097          	auipc	ra,0x3
    800037be:	a92080e7          	jalr	-1390(ra) # 8000624c <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800037c2:	02c92603          	lw	a2,44(s2)
    800037c6:	47f5                	li	a5,29
    800037c8:	06c7c563          	blt	a5,a2,80003832 <log_write+0x90>
    800037cc:	00015797          	auipc	a5,0x15
    800037d0:	5107a783          	lw	a5,1296(a5) # 80018cdc <log+0x1c>
    800037d4:	37fd                	addiw	a5,a5,-1
    800037d6:	04f65e63          	bge	a2,a5,80003832 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800037da:	00015797          	auipc	a5,0x15
    800037de:	5067a783          	lw	a5,1286(a5) # 80018ce0 <log+0x20>
    800037e2:	06f05063          	blez	a5,80003842 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800037e6:	4781                	li	a5,0
    800037e8:	06c05563          	blez	a2,80003852 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800037ec:	44cc                	lw	a1,12(s1)
    800037ee:	00015717          	auipc	a4,0x15
    800037f2:	50270713          	addi	a4,a4,1282 # 80018cf0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800037f6:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800037f8:	4314                	lw	a3,0(a4)
    800037fa:	04b68c63          	beq	a3,a1,80003852 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800037fe:	2785                	addiw	a5,a5,1
    80003800:	0711                	addi	a4,a4,4
    80003802:	fef61be3          	bne	a2,a5,800037f8 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003806:	0621                	addi	a2,a2,8
    80003808:	060a                	slli	a2,a2,0x2
    8000380a:	00015797          	auipc	a5,0x15
    8000380e:	4b678793          	addi	a5,a5,1206 # 80018cc0 <log>
    80003812:	963e                	add	a2,a2,a5
    80003814:	44dc                	lw	a5,12(s1)
    80003816:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003818:	8526                	mv	a0,s1
    8000381a:	fffff097          	auipc	ra,0xfffff
    8000381e:	da2080e7          	jalr	-606(ra) # 800025bc <bpin>
    log.lh.n++;
    80003822:	00015717          	auipc	a4,0x15
    80003826:	49e70713          	addi	a4,a4,1182 # 80018cc0 <log>
    8000382a:	575c                	lw	a5,44(a4)
    8000382c:	2785                	addiw	a5,a5,1
    8000382e:	d75c                	sw	a5,44(a4)
    80003830:	a835                	j	8000386c <log_write+0xca>
    panic("too big a transaction");
    80003832:	00005517          	auipc	a0,0x5
    80003836:	f8650513          	addi	a0,a0,-122 # 800087b8 <syscallnames+0x200>
    8000383a:	00002097          	auipc	ra,0x2
    8000383e:	4c8080e7          	jalr	1224(ra) # 80005d02 <panic>
    panic("log_write outside of trans");
    80003842:	00005517          	auipc	a0,0x5
    80003846:	f8e50513          	addi	a0,a0,-114 # 800087d0 <syscallnames+0x218>
    8000384a:	00002097          	auipc	ra,0x2
    8000384e:	4b8080e7          	jalr	1208(ra) # 80005d02 <panic>
  log.lh.block[i] = b->blockno;
    80003852:	00878713          	addi	a4,a5,8
    80003856:	00271693          	slli	a3,a4,0x2
    8000385a:	00015717          	auipc	a4,0x15
    8000385e:	46670713          	addi	a4,a4,1126 # 80018cc0 <log>
    80003862:	9736                	add	a4,a4,a3
    80003864:	44d4                	lw	a3,12(s1)
    80003866:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003868:	faf608e3          	beq	a2,a5,80003818 <log_write+0x76>
  }
  release(&log.lock);
    8000386c:	00015517          	auipc	a0,0x15
    80003870:	45450513          	addi	a0,a0,1108 # 80018cc0 <log>
    80003874:	00003097          	auipc	ra,0x3
    80003878:	a8c080e7          	jalr	-1396(ra) # 80006300 <release>
}
    8000387c:	60e2                	ld	ra,24(sp)
    8000387e:	6442                	ld	s0,16(sp)
    80003880:	64a2                	ld	s1,8(sp)
    80003882:	6902                	ld	s2,0(sp)
    80003884:	6105                	addi	sp,sp,32
    80003886:	8082                	ret

0000000080003888 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003888:	1101                	addi	sp,sp,-32
    8000388a:	ec06                	sd	ra,24(sp)
    8000388c:	e822                	sd	s0,16(sp)
    8000388e:	e426                	sd	s1,8(sp)
    80003890:	e04a                	sd	s2,0(sp)
    80003892:	1000                	addi	s0,sp,32
    80003894:	84aa                	mv	s1,a0
    80003896:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003898:	00005597          	auipc	a1,0x5
    8000389c:	f5858593          	addi	a1,a1,-168 # 800087f0 <syscallnames+0x238>
    800038a0:	0521                	addi	a0,a0,8
    800038a2:	00003097          	auipc	ra,0x3
    800038a6:	91a080e7          	jalr	-1766(ra) # 800061bc <initlock>
  lk->name = name;
    800038aa:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800038ae:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800038b2:	0204a423          	sw	zero,40(s1)
}
    800038b6:	60e2                	ld	ra,24(sp)
    800038b8:	6442                	ld	s0,16(sp)
    800038ba:	64a2                	ld	s1,8(sp)
    800038bc:	6902                	ld	s2,0(sp)
    800038be:	6105                	addi	sp,sp,32
    800038c0:	8082                	ret

00000000800038c2 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800038c2:	1101                	addi	sp,sp,-32
    800038c4:	ec06                	sd	ra,24(sp)
    800038c6:	e822                	sd	s0,16(sp)
    800038c8:	e426                	sd	s1,8(sp)
    800038ca:	e04a                	sd	s2,0(sp)
    800038cc:	1000                	addi	s0,sp,32
    800038ce:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800038d0:	00850913          	addi	s2,a0,8
    800038d4:	854a                	mv	a0,s2
    800038d6:	00003097          	auipc	ra,0x3
    800038da:	976080e7          	jalr	-1674(ra) # 8000624c <acquire>
  while (lk->locked) {
    800038de:	409c                	lw	a5,0(s1)
    800038e0:	cb89                	beqz	a5,800038f2 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800038e2:	85ca                	mv	a1,s2
    800038e4:	8526                	mv	a0,s1
    800038e6:	ffffe097          	auipc	ra,0xffffe
    800038ea:	c42080e7          	jalr	-958(ra) # 80001528 <sleep>
  while (lk->locked) {
    800038ee:	409c                	lw	a5,0(s1)
    800038f0:	fbed                	bnez	a5,800038e2 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800038f2:	4785                	li	a5,1
    800038f4:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800038f6:	ffffd097          	auipc	ra,0xffffd
    800038fa:	586080e7          	jalr	1414(ra) # 80000e7c <myproc>
    800038fe:	591c                	lw	a5,48(a0)
    80003900:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003902:	854a                	mv	a0,s2
    80003904:	00003097          	auipc	ra,0x3
    80003908:	9fc080e7          	jalr	-1540(ra) # 80006300 <release>
}
    8000390c:	60e2                	ld	ra,24(sp)
    8000390e:	6442                	ld	s0,16(sp)
    80003910:	64a2                	ld	s1,8(sp)
    80003912:	6902                	ld	s2,0(sp)
    80003914:	6105                	addi	sp,sp,32
    80003916:	8082                	ret

0000000080003918 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003918:	1101                	addi	sp,sp,-32
    8000391a:	ec06                	sd	ra,24(sp)
    8000391c:	e822                	sd	s0,16(sp)
    8000391e:	e426                	sd	s1,8(sp)
    80003920:	e04a                	sd	s2,0(sp)
    80003922:	1000                	addi	s0,sp,32
    80003924:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003926:	00850913          	addi	s2,a0,8
    8000392a:	854a                	mv	a0,s2
    8000392c:	00003097          	auipc	ra,0x3
    80003930:	920080e7          	jalr	-1760(ra) # 8000624c <acquire>
  lk->locked = 0;
    80003934:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003938:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000393c:	8526                	mv	a0,s1
    8000393e:	ffffe097          	auipc	ra,0xffffe
    80003942:	c4e080e7          	jalr	-946(ra) # 8000158c <wakeup>
  release(&lk->lk);
    80003946:	854a                	mv	a0,s2
    80003948:	00003097          	auipc	ra,0x3
    8000394c:	9b8080e7          	jalr	-1608(ra) # 80006300 <release>
}
    80003950:	60e2                	ld	ra,24(sp)
    80003952:	6442                	ld	s0,16(sp)
    80003954:	64a2                	ld	s1,8(sp)
    80003956:	6902                	ld	s2,0(sp)
    80003958:	6105                	addi	sp,sp,32
    8000395a:	8082                	ret

000000008000395c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000395c:	7179                	addi	sp,sp,-48
    8000395e:	f406                	sd	ra,40(sp)
    80003960:	f022                	sd	s0,32(sp)
    80003962:	ec26                	sd	s1,24(sp)
    80003964:	e84a                	sd	s2,16(sp)
    80003966:	e44e                	sd	s3,8(sp)
    80003968:	1800                	addi	s0,sp,48
    8000396a:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000396c:	00850913          	addi	s2,a0,8
    80003970:	854a                	mv	a0,s2
    80003972:	00003097          	auipc	ra,0x3
    80003976:	8da080e7          	jalr	-1830(ra) # 8000624c <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000397a:	409c                	lw	a5,0(s1)
    8000397c:	ef99                	bnez	a5,8000399a <holdingsleep+0x3e>
    8000397e:	4481                	li	s1,0
  release(&lk->lk);
    80003980:	854a                	mv	a0,s2
    80003982:	00003097          	auipc	ra,0x3
    80003986:	97e080e7          	jalr	-1666(ra) # 80006300 <release>
  return r;
}
    8000398a:	8526                	mv	a0,s1
    8000398c:	70a2                	ld	ra,40(sp)
    8000398e:	7402                	ld	s0,32(sp)
    80003990:	64e2                	ld	s1,24(sp)
    80003992:	6942                	ld	s2,16(sp)
    80003994:	69a2                	ld	s3,8(sp)
    80003996:	6145                	addi	sp,sp,48
    80003998:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000399a:	0284a983          	lw	s3,40(s1)
    8000399e:	ffffd097          	auipc	ra,0xffffd
    800039a2:	4de080e7          	jalr	1246(ra) # 80000e7c <myproc>
    800039a6:	5904                	lw	s1,48(a0)
    800039a8:	413484b3          	sub	s1,s1,s3
    800039ac:	0014b493          	seqz	s1,s1
    800039b0:	bfc1                	j	80003980 <holdingsleep+0x24>

00000000800039b2 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800039b2:	1141                	addi	sp,sp,-16
    800039b4:	e406                	sd	ra,8(sp)
    800039b6:	e022                	sd	s0,0(sp)
    800039b8:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800039ba:	00005597          	auipc	a1,0x5
    800039be:	e4658593          	addi	a1,a1,-442 # 80008800 <syscallnames+0x248>
    800039c2:	00015517          	auipc	a0,0x15
    800039c6:	44650513          	addi	a0,a0,1094 # 80018e08 <ftable>
    800039ca:	00002097          	auipc	ra,0x2
    800039ce:	7f2080e7          	jalr	2034(ra) # 800061bc <initlock>
}
    800039d2:	60a2                	ld	ra,8(sp)
    800039d4:	6402                	ld	s0,0(sp)
    800039d6:	0141                	addi	sp,sp,16
    800039d8:	8082                	ret

00000000800039da <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800039da:	1101                	addi	sp,sp,-32
    800039dc:	ec06                	sd	ra,24(sp)
    800039de:	e822                	sd	s0,16(sp)
    800039e0:	e426                	sd	s1,8(sp)
    800039e2:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800039e4:	00015517          	auipc	a0,0x15
    800039e8:	42450513          	addi	a0,a0,1060 # 80018e08 <ftable>
    800039ec:	00003097          	auipc	ra,0x3
    800039f0:	860080e7          	jalr	-1952(ra) # 8000624c <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800039f4:	00015497          	auipc	s1,0x15
    800039f8:	42c48493          	addi	s1,s1,1068 # 80018e20 <ftable+0x18>
    800039fc:	00016717          	auipc	a4,0x16
    80003a00:	3c470713          	addi	a4,a4,964 # 80019dc0 <disk>
    if(f->ref == 0){
    80003a04:	40dc                	lw	a5,4(s1)
    80003a06:	cf99                	beqz	a5,80003a24 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003a08:	02848493          	addi	s1,s1,40
    80003a0c:	fee49ce3          	bne	s1,a4,80003a04 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003a10:	00015517          	auipc	a0,0x15
    80003a14:	3f850513          	addi	a0,a0,1016 # 80018e08 <ftable>
    80003a18:	00003097          	auipc	ra,0x3
    80003a1c:	8e8080e7          	jalr	-1816(ra) # 80006300 <release>
  return 0;
    80003a20:	4481                	li	s1,0
    80003a22:	a819                	j	80003a38 <filealloc+0x5e>
      f->ref = 1;
    80003a24:	4785                	li	a5,1
    80003a26:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003a28:	00015517          	auipc	a0,0x15
    80003a2c:	3e050513          	addi	a0,a0,992 # 80018e08 <ftable>
    80003a30:	00003097          	auipc	ra,0x3
    80003a34:	8d0080e7          	jalr	-1840(ra) # 80006300 <release>
}
    80003a38:	8526                	mv	a0,s1
    80003a3a:	60e2                	ld	ra,24(sp)
    80003a3c:	6442                	ld	s0,16(sp)
    80003a3e:	64a2                	ld	s1,8(sp)
    80003a40:	6105                	addi	sp,sp,32
    80003a42:	8082                	ret

0000000080003a44 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003a44:	1101                	addi	sp,sp,-32
    80003a46:	ec06                	sd	ra,24(sp)
    80003a48:	e822                	sd	s0,16(sp)
    80003a4a:	e426                	sd	s1,8(sp)
    80003a4c:	1000                	addi	s0,sp,32
    80003a4e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003a50:	00015517          	auipc	a0,0x15
    80003a54:	3b850513          	addi	a0,a0,952 # 80018e08 <ftable>
    80003a58:	00002097          	auipc	ra,0x2
    80003a5c:	7f4080e7          	jalr	2036(ra) # 8000624c <acquire>
  if(f->ref < 1)
    80003a60:	40dc                	lw	a5,4(s1)
    80003a62:	02f05263          	blez	a5,80003a86 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80003a66:	2785                	addiw	a5,a5,1
    80003a68:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003a6a:	00015517          	auipc	a0,0x15
    80003a6e:	39e50513          	addi	a0,a0,926 # 80018e08 <ftable>
    80003a72:	00003097          	auipc	ra,0x3
    80003a76:	88e080e7          	jalr	-1906(ra) # 80006300 <release>
  return f;
}
    80003a7a:	8526                	mv	a0,s1
    80003a7c:	60e2                	ld	ra,24(sp)
    80003a7e:	6442                	ld	s0,16(sp)
    80003a80:	64a2                	ld	s1,8(sp)
    80003a82:	6105                	addi	sp,sp,32
    80003a84:	8082                	ret
    panic("filedup");
    80003a86:	00005517          	auipc	a0,0x5
    80003a8a:	d8250513          	addi	a0,a0,-638 # 80008808 <syscallnames+0x250>
    80003a8e:	00002097          	auipc	ra,0x2
    80003a92:	274080e7          	jalr	628(ra) # 80005d02 <panic>

0000000080003a96 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003a96:	7139                	addi	sp,sp,-64
    80003a98:	fc06                	sd	ra,56(sp)
    80003a9a:	f822                	sd	s0,48(sp)
    80003a9c:	f426                	sd	s1,40(sp)
    80003a9e:	f04a                	sd	s2,32(sp)
    80003aa0:	ec4e                	sd	s3,24(sp)
    80003aa2:	e852                	sd	s4,16(sp)
    80003aa4:	e456                	sd	s5,8(sp)
    80003aa6:	0080                	addi	s0,sp,64
    80003aa8:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003aaa:	00015517          	auipc	a0,0x15
    80003aae:	35e50513          	addi	a0,a0,862 # 80018e08 <ftable>
    80003ab2:	00002097          	auipc	ra,0x2
    80003ab6:	79a080e7          	jalr	1946(ra) # 8000624c <acquire>
  if(f->ref < 1)
    80003aba:	40dc                	lw	a5,4(s1)
    80003abc:	06f05163          	blez	a5,80003b1e <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80003ac0:	37fd                	addiw	a5,a5,-1
    80003ac2:	0007871b          	sext.w	a4,a5
    80003ac6:	c0dc                	sw	a5,4(s1)
    80003ac8:	06e04363          	bgtz	a4,80003b2e <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80003acc:	0004a903          	lw	s2,0(s1)
    80003ad0:	0094ca83          	lbu	s5,9(s1)
    80003ad4:	0104ba03          	ld	s4,16(s1)
    80003ad8:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80003adc:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80003ae0:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80003ae4:	00015517          	auipc	a0,0x15
    80003ae8:	32450513          	addi	a0,a0,804 # 80018e08 <ftable>
    80003aec:	00003097          	auipc	ra,0x3
    80003af0:	814080e7          	jalr	-2028(ra) # 80006300 <release>

  if(ff.type == FD_PIPE){
    80003af4:	4785                	li	a5,1
    80003af6:	04f90d63          	beq	s2,a5,80003b50 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80003afa:	3979                	addiw	s2,s2,-2
    80003afc:	4785                	li	a5,1
    80003afe:	0527e063          	bltu	a5,s2,80003b3e <fileclose+0xa8>
    begin_op();
    80003b02:	00000097          	auipc	ra,0x0
    80003b06:	ac8080e7          	jalr	-1336(ra) # 800035ca <begin_op>
    iput(ff.ip);
    80003b0a:	854e                	mv	a0,s3
    80003b0c:	fffff097          	auipc	ra,0xfffff
    80003b10:	2b6080e7          	jalr	694(ra) # 80002dc2 <iput>
    end_op();
    80003b14:	00000097          	auipc	ra,0x0
    80003b18:	b36080e7          	jalr	-1226(ra) # 8000364a <end_op>
    80003b1c:	a00d                	j	80003b3e <fileclose+0xa8>
    panic("fileclose");
    80003b1e:	00005517          	auipc	a0,0x5
    80003b22:	cf250513          	addi	a0,a0,-782 # 80008810 <syscallnames+0x258>
    80003b26:	00002097          	auipc	ra,0x2
    80003b2a:	1dc080e7          	jalr	476(ra) # 80005d02 <panic>
    release(&ftable.lock);
    80003b2e:	00015517          	auipc	a0,0x15
    80003b32:	2da50513          	addi	a0,a0,730 # 80018e08 <ftable>
    80003b36:	00002097          	auipc	ra,0x2
    80003b3a:	7ca080e7          	jalr	1994(ra) # 80006300 <release>
  }
}
    80003b3e:	70e2                	ld	ra,56(sp)
    80003b40:	7442                	ld	s0,48(sp)
    80003b42:	74a2                	ld	s1,40(sp)
    80003b44:	7902                	ld	s2,32(sp)
    80003b46:	69e2                	ld	s3,24(sp)
    80003b48:	6a42                	ld	s4,16(sp)
    80003b4a:	6aa2                	ld	s5,8(sp)
    80003b4c:	6121                	addi	sp,sp,64
    80003b4e:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80003b50:	85d6                	mv	a1,s5
    80003b52:	8552                	mv	a0,s4
    80003b54:	00000097          	auipc	ra,0x0
    80003b58:	34c080e7          	jalr	844(ra) # 80003ea0 <pipeclose>
    80003b5c:	b7cd                	j	80003b3e <fileclose+0xa8>

0000000080003b5e <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80003b5e:	715d                	addi	sp,sp,-80
    80003b60:	e486                	sd	ra,72(sp)
    80003b62:	e0a2                	sd	s0,64(sp)
    80003b64:	fc26                	sd	s1,56(sp)
    80003b66:	f84a                	sd	s2,48(sp)
    80003b68:	f44e                	sd	s3,40(sp)
    80003b6a:	0880                	addi	s0,sp,80
    80003b6c:	84aa                	mv	s1,a0
    80003b6e:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80003b70:	ffffd097          	auipc	ra,0xffffd
    80003b74:	30c080e7          	jalr	780(ra) # 80000e7c <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80003b78:	409c                	lw	a5,0(s1)
    80003b7a:	37f9                	addiw	a5,a5,-2
    80003b7c:	4705                	li	a4,1
    80003b7e:	04f76763          	bltu	a4,a5,80003bcc <filestat+0x6e>
    80003b82:	892a                	mv	s2,a0
    ilock(f->ip);
    80003b84:	6c88                	ld	a0,24(s1)
    80003b86:	fffff097          	auipc	ra,0xfffff
    80003b8a:	082080e7          	jalr	130(ra) # 80002c08 <ilock>
    stati(f->ip, &st);
    80003b8e:	fb840593          	addi	a1,s0,-72
    80003b92:	6c88                	ld	a0,24(s1)
    80003b94:	fffff097          	auipc	ra,0xfffff
    80003b98:	2fe080e7          	jalr	766(ra) # 80002e92 <stati>
    iunlock(f->ip);
    80003b9c:	6c88                	ld	a0,24(s1)
    80003b9e:	fffff097          	auipc	ra,0xfffff
    80003ba2:	12c080e7          	jalr	300(ra) # 80002cca <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80003ba6:	46e1                	li	a3,24
    80003ba8:	fb840613          	addi	a2,s0,-72
    80003bac:	85ce                	mv	a1,s3
    80003bae:	05093503          	ld	a0,80(s2)
    80003bb2:	ffffd097          	auipc	ra,0xffffd
    80003bb6:	f88080e7          	jalr	-120(ra) # 80000b3a <copyout>
    80003bba:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80003bbe:	60a6                	ld	ra,72(sp)
    80003bc0:	6406                	ld	s0,64(sp)
    80003bc2:	74e2                	ld	s1,56(sp)
    80003bc4:	7942                	ld	s2,48(sp)
    80003bc6:	79a2                	ld	s3,40(sp)
    80003bc8:	6161                	addi	sp,sp,80
    80003bca:	8082                	ret
  return -1;
    80003bcc:	557d                	li	a0,-1
    80003bce:	bfc5                	j	80003bbe <filestat+0x60>

0000000080003bd0 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80003bd0:	7179                	addi	sp,sp,-48
    80003bd2:	f406                	sd	ra,40(sp)
    80003bd4:	f022                	sd	s0,32(sp)
    80003bd6:	ec26                	sd	s1,24(sp)
    80003bd8:	e84a                	sd	s2,16(sp)
    80003bda:	e44e                	sd	s3,8(sp)
    80003bdc:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80003bde:	00854783          	lbu	a5,8(a0)
    80003be2:	c3d5                	beqz	a5,80003c86 <fileread+0xb6>
    80003be4:	84aa                	mv	s1,a0
    80003be6:	89ae                	mv	s3,a1
    80003be8:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80003bea:	411c                	lw	a5,0(a0)
    80003bec:	4705                	li	a4,1
    80003bee:	04e78963          	beq	a5,a4,80003c40 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003bf2:	470d                	li	a4,3
    80003bf4:	04e78d63          	beq	a5,a4,80003c4e <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80003bf8:	4709                	li	a4,2
    80003bfa:	06e79e63          	bne	a5,a4,80003c76 <fileread+0xa6>
    ilock(f->ip);
    80003bfe:	6d08                	ld	a0,24(a0)
    80003c00:	fffff097          	auipc	ra,0xfffff
    80003c04:	008080e7          	jalr	8(ra) # 80002c08 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80003c08:	874a                	mv	a4,s2
    80003c0a:	5094                	lw	a3,32(s1)
    80003c0c:	864e                	mv	a2,s3
    80003c0e:	4585                	li	a1,1
    80003c10:	6c88                	ld	a0,24(s1)
    80003c12:	fffff097          	auipc	ra,0xfffff
    80003c16:	2aa080e7          	jalr	682(ra) # 80002ebc <readi>
    80003c1a:	892a                	mv	s2,a0
    80003c1c:	00a05563          	blez	a0,80003c26 <fileread+0x56>
      f->off += r;
    80003c20:	509c                	lw	a5,32(s1)
    80003c22:	9fa9                	addw	a5,a5,a0
    80003c24:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80003c26:	6c88                	ld	a0,24(s1)
    80003c28:	fffff097          	auipc	ra,0xfffff
    80003c2c:	0a2080e7          	jalr	162(ra) # 80002cca <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80003c30:	854a                	mv	a0,s2
    80003c32:	70a2                	ld	ra,40(sp)
    80003c34:	7402                	ld	s0,32(sp)
    80003c36:	64e2                	ld	s1,24(sp)
    80003c38:	6942                	ld	s2,16(sp)
    80003c3a:	69a2                	ld	s3,8(sp)
    80003c3c:	6145                	addi	sp,sp,48
    80003c3e:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80003c40:	6908                	ld	a0,16(a0)
    80003c42:	00000097          	auipc	ra,0x0
    80003c46:	3ce080e7          	jalr	974(ra) # 80004010 <piperead>
    80003c4a:	892a                	mv	s2,a0
    80003c4c:	b7d5                	j	80003c30 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80003c4e:	02451783          	lh	a5,36(a0)
    80003c52:	03079693          	slli	a3,a5,0x30
    80003c56:	92c1                	srli	a3,a3,0x30
    80003c58:	4725                	li	a4,9
    80003c5a:	02d76863          	bltu	a4,a3,80003c8a <fileread+0xba>
    80003c5e:	0792                	slli	a5,a5,0x4
    80003c60:	00015717          	auipc	a4,0x15
    80003c64:	10870713          	addi	a4,a4,264 # 80018d68 <devsw>
    80003c68:	97ba                	add	a5,a5,a4
    80003c6a:	639c                	ld	a5,0(a5)
    80003c6c:	c38d                	beqz	a5,80003c8e <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80003c6e:	4505                	li	a0,1
    80003c70:	9782                	jalr	a5
    80003c72:	892a                	mv	s2,a0
    80003c74:	bf75                	j	80003c30 <fileread+0x60>
    panic("fileread");
    80003c76:	00005517          	auipc	a0,0x5
    80003c7a:	baa50513          	addi	a0,a0,-1110 # 80008820 <syscallnames+0x268>
    80003c7e:	00002097          	auipc	ra,0x2
    80003c82:	084080e7          	jalr	132(ra) # 80005d02 <panic>
    return -1;
    80003c86:	597d                	li	s2,-1
    80003c88:	b765                	j	80003c30 <fileread+0x60>
      return -1;
    80003c8a:	597d                	li	s2,-1
    80003c8c:	b755                	j	80003c30 <fileread+0x60>
    80003c8e:	597d                	li	s2,-1
    80003c90:	b745                	j	80003c30 <fileread+0x60>

0000000080003c92 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80003c92:	715d                	addi	sp,sp,-80
    80003c94:	e486                	sd	ra,72(sp)
    80003c96:	e0a2                	sd	s0,64(sp)
    80003c98:	fc26                	sd	s1,56(sp)
    80003c9a:	f84a                	sd	s2,48(sp)
    80003c9c:	f44e                	sd	s3,40(sp)
    80003c9e:	f052                	sd	s4,32(sp)
    80003ca0:	ec56                	sd	s5,24(sp)
    80003ca2:	e85a                	sd	s6,16(sp)
    80003ca4:	e45e                	sd	s7,8(sp)
    80003ca6:	e062                	sd	s8,0(sp)
    80003ca8:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80003caa:	00954783          	lbu	a5,9(a0)
    80003cae:	10078663          	beqz	a5,80003dba <filewrite+0x128>
    80003cb2:	892a                	mv	s2,a0
    80003cb4:	8aae                	mv	s5,a1
    80003cb6:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80003cb8:	411c                	lw	a5,0(a0)
    80003cba:	4705                	li	a4,1
    80003cbc:	02e78263          	beq	a5,a4,80003ce0 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003cc0:	470d                	li	a4,3
    80003cc2:	02e78663          	beq	a5,a4,80003cee <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80003cc6:	4709                	li	a4,2
    80003cc8:	0ee79163          	bne	a5,a4,80003daa <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80003ccc:	0ac05d63          	blez	a2,80003d86 <filewrite+0xf4>
    int i = 0;
    80003cd0:	4981                	li	s3,0
    80003cd2:	6b05                	lui	s6,0x1
    80003cd4:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80003cd8:	6b85                	lui	s7,0x1
    80003cda:	c00b8b9b          	addiw	s7,s7,-1024
    80003cde:	a861                	j	80003d76 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80003ce0:	6908                	ld	a0,16(a0)
    80003ce2:	00000097          	auipc	ra,0x0
    80003ce6:	22e080e7          	jalr	558(ra) # 80003f10 <pipewrite>
    80003cea:	8a2a                	mv	s4,a0
    80003cec:	a045                	j	80003d8c <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80003cee:	02451783          	lh	a5,36(a0)
    80003cf2:	03079693          	slli	a3,a5,0x30
    80003cf6:	92c1                	srli	a3,a3,0x30
    80003cf8:	4725                	li	a4,9
    80003cfa:	0cd76263          	bltu	a4,a3,80003dbe <filewrite+0x12c>
    80003cfe:	0792                	slli	a5,a5,0x4
    80003d00:	00015717          	auipc	a4,0x15
    80003d04:	06870713          	addi	a4,a4,104 # 80018d68 <devsw>
    80003d08:	97ba                	add	a5,a5,a4
    80003d0a:	679c                	ld	a5,8(a5)
    80003d0c:	cbdd                	beqz	a5,80003dc2 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80003d0e:	4505                	li	a0,1
    80003d10:	9782                	jalr	a5
    80003d12:	8a2a                	mv	s4,a0
    80003d14:	a8a5                	j	80003d8c <filewrite+0xfa>
    80003d16:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80003d1a:	00000097          	auipc	ra,0x0
    80003d1e:	8b0080e7          	jalr	-1872(ra) # 800035ca <begin_op>
      ilock(f->ip);
    80003d22:	01893503          	ld	a0,24(s2)
    80003d26:	fffff097          	auipc	ra,0xfffff
    80003d2a:	ee2080e7          	jalr	-286(ra) # 80002c08 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80003d2e:	8762                	mv	a4,s8
    80003d30:	02092683          	lw	a3,32(s2)
    80003d34:	01598633          	add	a2,s3,s5
    80003d38:	4585                	li	a1,1
    80003d3a:	01893503          	ld	a0,24(s2)
    80003d3e:	fffff097          	auipc	ra,0xfffff
    80003d42:	276080e7          	jalr	630(ra) # 80002fb4 <writei>
    80003d46:	84aa                	mv	s1,a0
    80003d48:	00a05763          	blez	a0,80003d56 <filewrite+0xc4>
        f->off += r;
    80003d4c:	02092783          	lw	a5,32(s2)
    80003d50:	9fa9                	addw	a5,a5,a0
    80003d52:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80003d56:	01893503          	ld	a0,24(s2)
    80003d5a:	fffff097          	auipc	ra,0xfffff
    80003d5e:	f70080e7          	jalr	-144(ra) # 80002cca <iunlock>
      end_op();
    80003d62:	00000097          	auipc	ra,0x0
    80003d66:	8e8080e7          	jalr	-1816(ra) # 8000364a <end_op>

      if(r != n1){
    80003d6a:	009c1f63          	bne	s8,s1,80003d88 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80003d6e:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80003d72:	0149db63          	bge	s3,s4,80003d88 <filewrite+0xf6>
      int n1 = n - i;
    80003d76:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80003d7a:	84be                	mv	s1,a5
    80003d7c:	2781                	sext.w	a5,a5
    80003d7e:	f8fb5ce3          	bge	s6,a5,80003d16 <filewrite+0x84>
    80003d82:	84de                	mv	s1,s7
    80003d84:	bf49                	j	80003d16 <filewrite+0x84>
    int i = 0;
    80003d86:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80003d88:	013a1f63          	bne	s4,s3,80003da6 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80003d8c:	8552                	mv	a0,s4
    80003d8e:	60a6                	ld	ra,72(sp)
    80003d90:	6406                	ld	s0,64(sp)
    80003d92:	74e2                	ld	s1,56(sp)
    80003d94:	7942                	ld	s2,48(sp)
    80003d96:	79a2                	ld	s3,40(sp)
    80003d98:	7a02                	ld	s4,32(sp)
    80003d9a:	6ae2                	ld	s5,24(sp)
    80003d9c:	6b42                	ld	s6,16(sp)
    80003d9e:	6ba2                	ld	s7,8(sp)
    80003da0:	6c02                	ld	s8,0(sp)
    80003da2:	6161                	addi	sp,sp,80
    80003da4:	8082                	ret
    ret = (i == n ? n : -1);
    80003da6:	5a7d                	li	s4,-1
    80003da8:	b7d5                	j	80003d8c <filewrite+0xfa>
    panic("filewrite");
    80003daa:	00005517          	auipc	a0,0x5
    80003dae:	a8650513          	addi	a0,a0,-1402 # 80008830 <syscallnames+0x278>
    80003db2:	00002097          	auipc	ra,0x2
    80003db6:	f50080e7          	jalr	-176(ra) # 80005d02 <panic>
    return -1;
    80003dba:	5a7d                	li	s4,-1
    80003dbc:	bfc1                	j	80003d8c <filewrite+0xfa>
      return -1;
    80003dbe:	5a7d                	li	s4,-1
    80003dc0:	b7f1                	j	80003d8c <filewrite+0xfa>
    80003dc2:	5a7d                	li	s4,-1
    80003dc4:	b7e1                	j	80003d8c <filewrite+0xfa>

0000000080003dc6 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80003dc6:	7179                	addi	sp,sp,-48
    80003dc8:	f406                	sd	ra,40(sp)
    80003dca:	f022                	sd	s0,32(sp)
    80003dcc:	ec26                	sd	s1,24(sp)
    80003dce:	e84a                	sd	s2,16(sp)
    80003dd0:	e44e                	sd	s3,8(sp)
    80003dd2:	e052                	sd	s4,0(sp)
    80003dd4:	1800                	addi	s0,sp,48
    80003dd6:	84aa                	mv	s1,a0
    80003dd8:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80003dda:	0005b023          	sd	zero,0(a1)
    80003dde:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80003de2:	00000097          	auipc	ra,0x0
    80003de6:	bf8080e7          	jalr	-1032(ra) # 800039da <filealloc>
    80003dea:	e088                	sd	a0,0(s1)
    80003dec:	c551                	beqz	a0,80003e78 <pipealloc+0xb2>
    80003dee:	00000097          	auipc	ra,0x0
    80003df2:	bec080e7          	jalr	-1044(ra) # 800039da <filealloc>
    80003df6:	00aa3023          	sd	a0,0(s4)
    80003dfa:	c92d                	beqz	a0,80003e6c <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80003dfc:	ffffc097          	auipc	ra,0xffffc
    80003e00:	31c080e7          	jalr	796(ra) # 80000118 <kalloc>
    80003e04:	892a                	mv	s2,a0
    80003e06:	c125                	beqz	a0,80003e66 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80003e08:	4985                	li	s3,1
    80003e0a:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80003e0e:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80003e12:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80003e16:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80003e1a:	00004597          	auipc	a1,0x4
    80003e1e:	5ce58593          	addi	a1,a1,1486 # 800083e8 <states.1727+0x1a0>
    80003e22:	00002097          	auipc	ra,0x2
    80003e26:	39a080e7          	jalr	922(ra) # 800061bc <initlock>
  (*f0)->type = FD_PIPE;
    80003e2a:	609c                	ld	a5,0(s1)
    80003e2c:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80003e30:	609c                	ld	a5,0(s1)
    80003e32:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80003e36:	609c                	ld	a5,0(s1)
    80003e38:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80003e3c:	609c                	ld	a5,0(s1)
    80003e3e:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80003e42:	000a3783          	ld	a5,0(s4)
    80003e46:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80003e4a:	000a3783          	ld	a5,0(s4)
    80003e4e:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80003e52:	000a3783          	ld	a5,0(s4)
    80003e56:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80003e5a:	000a3783          	ld	a5,0(s4)
    80003e5e:	0127b823          	sd	s2,16(a5)
  return 0;
    80003e62:	4501                	li	a0,0
    80003e64:	a025                	j	80003e8c <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80003e66:	6088                	ld	a0,0(s1)
    80003e68:	e501                	bnez	a0,80003e70 <pipealloc+0xaa>
    80003e6a:	a039                	j	80003e78 <pipealloc+0xb2>
    80003e6c:	6088                	ld	a0,0(s1)
    80003e6e:	c51d                	beqz	a0,80003e9c <pipealloc+0xd6>
    fileclose(*f0);
    80003e70:	00000097          	auipc	ra,0x0
    80003e74:	c26080e7          	jalr	-986(ra) # 80003a96 <fileclose>
  if(*f1)
    80003e78:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80003e7c:	557d                	li	a0,-1
  if(*f1)
    80003e7e:	c799                	beqz	a5,80003e8c <pipealloc+0xc6>
    fileclose(*f1);
    80003e80:	853e                	mv	a0,a5
    80003e82:	00000097          	auipc	ra,0x0
    80003e86:	c14080e7          	jalr	-1004(ra) # 80003a96 <fileclose>
  return -1;
    80003e8a:	557d                	li	a0,-1
}
    80003e8c:	70a2                	ld	ra,40(sp)
    80003e8e:	7402                	ld	s0,32(sp)
    80003e90:	64e2                	ld	s1,24(sp)
    80003e92:	6942                	ld	s2,16(sp)
    80003e94:	69a2                	ld	s3,8(sp)
    80003e96:	6a02                	ld	s4,0(sp)
    80003e98:	6145                	addi	sp,sp,48
    80003e9a:	8082                	ret
  return -1;
    80003e9c:	557d                	li	a0,-1
    80003e9e:	b7fd                	j	80003e8c <pipealloc+0xc6>

0000000080003ea0 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80003ea0:	1101                	addi	sp,sp,-32
    80003ea2:	ec06                	sd	ra,24(sp)
    80003ea4:	e822                	sd	s0,16(sp)
    80003ea6:	e426                	sd	s1,8(sp)
    80003ea8:	e04a                	sd	s2,0(sp)
    80003eaa:	1000                	addi	s0,sp,32
    80003eac:	84aa                	mv	s1,a0
    80003eae:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80003eb0:	00002097          	auipc	ra,0x2
    80003eb4:	39c080e7          	jalr	924(ra) # 8000624c <acquire>
  if(writable){
    80003eb8:	02090d63          	beqz	s2,80003ef2 <pipeclose+0x52>
    pi->writeopen = 0;
    80003ebc:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80003ec0:	21848513          	addi	a0,s1,536
    80003ec4:	ffffd097          	auipc	ra,0xffffd
    80003ec8:	6c8080e7          	jalr	1736(ra) # 8000158c <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80003ecc:	2204b783          	ld	a5,544(s1)
    80003ed0:	eb95                	bnez	a5,80003f04 <pipeclose+0x64>
    release(&pi->lock);
    80003ed2:	8526                	mv	a0,s1
    80003ed4:	00002097          	auipc	ra,0x2
    80003ed8:	42c080e7          	jalr	1068(ra) # 80006300 <release>
    kfree((char*)pi);
    80003edc:	8526                	mv	a0,s1
    80003ede:	ffffc097          	auipc	ra,0xffffc
    80003ee2:	13e080e7          	jalr	318(ra) # 8000001c <kfree>
  } else
    release(&pi->lock);
}
    80003ee6:	60e2                	ld	ra,24(sp)
    80003ee8:	6442                	ld	s0,16(sp)
    80003eea:	64a2                	ld	s1,8(sp)
    80003eec:	6902                	ld	s2,0(sp)
    80003eee:	6105                	addi	sp,sp,32
    80003ef0:	8082                	ret
    pi->readopen = 0;
    80003ef2:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80003ef6:	21c48513          	addi	a0,s1,540
    80003efa:	ffffd097          	auipc	ra,0xffffd
    80003efe:	692080e7          	jalr	1682(ra) # 8000158c <wakeup>
    80003f02:	b7e9                	j	80003ecc <pipeclose+0x2c>
    release(&pi->lock);
    80003f04:	8526                	mv	a0,s1
    80003f06:	00002097          	auipc	ra,0x2
    80003f0a:	3fa080e7          	jalr	1018(ra) # 80006300 <release>
}
    80003f0e:	bfe1                	j	80003ee6 <pipeclose+0x46>

0000000080003f10 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80003f10:	7159                	addi	sp,sp,-112
    80003f12:	f486                	sd	ra,104(sp)
    80003f14:	f0a2                	sd	s0,96(sp)
    80003f16:	eca6                	sd	s1,88(sp)
    80003f18:	e8ca                	sd	s2,80(sp)
    80003f1a:	e4ce                	sd	s3,72(sp)
    80003f1c:	e0d2                	sd	s4,64(sp)
    80003f1e:	fc56                	sd	s5,56(sp)
    80003f20:	f85a                	sd	s6,48(sp)
    80003f22:	f45e                	sd	s7,40(sp)
    80003f24:	f062                	sd	s8,32(sp)
    80003f26:	ec66                	sd	s9,24(sp)
    80003f28:	1880                	addi	s0,sp,112
    80003f2a:	84aa                	mv	s1,a0
    80003f2c:	8aae                	mv	s5,a1
    80003f2e:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80003f30:	ffffd097          	auipc	ra,0xffffd
    80003f34:	f4c080e7          	jalr	-180(ra) # 80000e7c <myproc>
    80003f38:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80003f3a:	8526                	mv	a0,s1
    80003f3c:	00002097          	auipc	ra,0x2
    80003f40:	310080e7          	jalr	784(ra) # 8000624c <acquire>
  while(i < n){
    80003f44:	0d405463          	blez	s4,8000400c <pipewrite+0xfc>
    80003f48:	8ba6                	mv	s7,s1
  int i = 0;
    80003f4a:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003f4c:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80003f4e:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80003f52:	21c48c13          	addi	s8,s1,540
    80003f56:	a08d                	j	80003fb8 <pipewrite+0xa8>
      release(&pi->lock);
    80003f58:	8526                	mv	a0,s1
    80003f5a:	00002097          	auipc	ra,0x2
    80003f5e:	3a6080e7          	jalr	934(ra) # 80006300 <release>
      return -1;
    80003f62:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80003f64:	854a                	mv	a0,s2
    80003f66:	70a6                	ld	ra,104(sp)
    80003f68:	7406                	ld	s0,96(sp)
    80003f6a:	64e6                	ld	s1,88(sp)
    80003f6c:	6946                	ld	s2,80(sp)
    80003f6e:	69a6                	ld	s3,72(sp)
    80003f70:	6a06                	ld	s4,64(sp)
    80003f72:	7ae2                	ld	s5,56(sp)
    80003f74:	7b42                	ld	s6,48(sp)
    80003f76:	7ba2                	ld	s7,40(sp)
    80003f78:	7c02                	ld	s8,32(sp)
    80003f7a:	6ce2                	ld	s9,24(sp)
    80003f7c:	6165                	addi	sp,sp,112
    80003f7e:	8082                	ret
      wakeup(&pi->nread);
    80003f80:	8566                	mv	a0,s9
    80003f82:	ffffd097          	auipc	ra,0xffffd
    80003f86:	60a080e7          	jalr	1546(ra) # 8000158c <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80003f8a:	85de                	mv	a1,s7
    80003f8c:	8562                	mv	a0,s8
    80003f8e:	ffffd097          	auipc	ra,0xffffd
    80003f92:	59a080e7          	jalr	1434(ra) # 80001528 <sleep>
    80003f96:	a839                	j	80003fb4 <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80003f98:	21c4a783          	lw	a5,540(s1)
    80003f9c:	0017871b          	addiw	a4,a5,1
    80003fa0:	20e4ae23          	sw	a4,540(s1)
    80003fa4:	1ff7f793          	andi	a5,a5,511
    80003fa8:	97a6                	add	a5,a5,s1
    80003faa:	f9f44703          	lbu	a4,-97(s0)
    80003fae:	00e78c23          	sb	a4,24(a5)
      i++;
    80003fb2:	2905                	addiw	s2,s2,1
  while(i < n){
    80003fb4:	05495063          	bge	s2,s4,80003ff4 <pipewrite+0xe4>
    if(pi->readopen == 0 || killed(pr)){
    80003fb8:	2204a783          	lw	a5,544(s1)
    80003fbc:	dfd1                	beqz	a5,80003f58 <pipewrite+0x48>
    80003fbe:	854e                	mv	a0,s3
    80003fc0:	ffffe097          	auipc	ra,0xffffe
    80003fc4:	810080e7          	jalr	-2032(ra) # 800017d0 <killed>
    80003fc8:	f941                	bnez	a0,80003f58 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80003fca:	2184a783          	lw	a5,536(s1)
    80003fce:	21c4a703          	lw	a4,540(s1)
    80003fd2:	2007879b          	addiw	a5,a5,512
    80003fd6:	faf705e3          	beq	a4,a5,80003f80 <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003fda:	4685                	li	a3,1
    80003fdc:	01590633          	add	a2,s2,s5
    80003fe0:	f9f40593          	addi	a1,s0,-97
    80003fe4:	0509b503          	ld	a0,80(s3)
    80003fe8:	ffffd097          	auipc	ra,0xffffd
    80003fec:	bde080e7          	jalr	-1058(ra) # 80000bc6 <copyin>
    80003ff0:	fb6514e3          	bne	a0,s6,80003f98 <pipewrite+0x88>
  wakeup(&pi->nread);
    80003ff4:	21848513          	addi	a0,s1,536
    80003ff8:	ffffd097          	auipc	ra,0xffffd
    80003ffc:	594080e7          	jalr	1428(ra) # 8000158c <wakeup>
  release(&pi->lock);
    80004000:	8526                	mv	a0,s1
    80004002:	00002097          	auipc	ra,0x2
    80004006:	2fe080e7          	jalr	766(ra) # 80006300 <release>
  return i;
    8000400a:	bfa9                	j	80003f64 <pipewrite+0x54>
  int i = 0;
    8000400c:	4901                	li	s2,0
    8000400e:	b7dd                	j	80003ff4 <pipewrite+0xe4>

0000000080004010 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004010:	715d                	addi	sp,sp,-80
    80004012:	e486                	sd	ra,72(sp)
    80004014:	e0a2                	sd	s0,64(sp)
    80004016:	fc26                	sd	s1,56(sp)
    80004018:	f84a                	sd	s2,48(sp)
    8000401a:	f44e                	sd	s3,40(sp)
    8000401c:	f052                	sd	s4,32(sp)
    8000401e:	ec56                	sd	s5,24(sp)
    80004020:	e85a                	sd	s6,16(sp)
    80004022:	0880                	addi	s0,sp,80
    80004024:	84aa                	mv	s1,a0
    80004026:	892e                	mv	s2,a1
    80004028:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000402a:	ffffd097          	auipc	ra,0xffffd
    8000402e:	e52080e7          	jalr	-430(ra) # 80000e7c <myproc>
    80004032:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004034:	8b26                	mv	s6,s1
    80004036:	8526                	mv	a0,s1
    80004038:	00002097          	auipc	ra,0x2
    8000403c:	214080e7          	jalr	532(ra) # 8000624c <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004040:	2184a703          	lw	a4,536(s1)
    80004044:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004048:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000404c:	02f71763          	bne	a4,a5,8000407a <piperead+0x6a>
    80004050:	2244a783          	lw	a5,548(s1)
    80004054:	c39d                	beqz	a5,8000407a <piperead+0x6a>
    if(killed(pr)){
    80004056:	8552                	mv	a0,s4
    80004058:	ffffd097          	auipc	ra,0xffffd
    8000405c:	778080e7          	jalr	1912(ra) # 800017d0 <killed>
    80004060:	e941                	bnez	a0,800040f0 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004062:	85da                	mv	a1,s6
    80004064:	854e                	mv	a0,s3
    80004066:	ffffd097          	auipc	ra,0xffffd
    8000406a:	4c2080e7          	jalr	1218(ra) # 80001528 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000406e:	2184a703          	lw	a4,536(s1)
    80004072:	21c4a783          	lw	a5,540(s1)
    80004076:	fcf70de3          	beq	a4,a5,80004050 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000407a:	09505263          	blez	s5,800040fe <piperead+0xee>
    8000407e:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004080:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80004082:	2184a783          	lw	a5,536(s1)
    80004086:	21c4a703          	lw	a4,540(s1)
    8000408a:	02f70d63          	beq	a4,a5,800040c4 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000408e:	0017871b          	addiw	a4,a5,1
    80004092:	20e4ac23          	sw	a4,536(s1)
    80004096:	1ff7f793          	andi	a5,a5,511
    8000409a:	97a6                	add	a5,a5,s1
    8000409c:	0187c783          	lbu	a5,24(a5)
    800040a0:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800040a4:	4685                	li	a3,1
    800040a6:	fbf40613          	addi	a2,s0,-65
    800040aa:	85ca                	mv	a1,s2
    800040ac:	050a3503          	ld	a0,80(s4)
    800040b0:	ffffd097          	auipc	ra,0xffffd
    800040b4:	a8a080e7          	jalr	-1398(ra) # 80000b3a <copyout>
    800040b8:	01650663          	beq	a0,s6,800040c4 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800040bc:	2985                	addiw	s3,s3,1
    800040be:	0905                	addi	s2,s2,1
    800040c0:	fd3a91e3          	bne	s5,s3,80004082 <piperead+0x72>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800040c4:	21c48513          	addi	a0,s1,540
    800040c8:	ffffd097          	auipc	ra,0xffffd
    800040cc:	4c4080e7          	jalr	1220(ra) # 8000158c <wakeup>
  release(&pi->lock);
    800040d0:	8526                	mv	a0,s1
    800040d2:	00002097          	auipc	ra,0x2
    800040d6:	22e080e7          	jalr	558(ra) # 80006300 <release>
  return i;
}
    800040da:	854e                	mv	a0,s3
    800040dc:	60a6                	ld	ra,72(sp)
    800040de:	6406                	ld	s0,64(sp)
    800040e0:	74e2                	ld	s1,56(sp)
    800040e2:	7942                	ld	s2,48(sp)
    800040e4:	79a2                	ld	s3,40(sp)
    800040e6:	7a02                	ld	s4,32(sp)
    800040e8:	6ae2                	ld	s5,24(sp)
    800040ea:	6b42                	ld	s6,16(sp)
    800040ec:	6161                	addi	sp,sp,80
    800040ee:	8082                	ret
      release(&pi->lock);
    800040f0:	8526                	mv	a0,s1
    800040f2:	00002097          	auipc	ra,0x2
    800040f6:	20e080e7          	jalr	526(ra) # 80006300 <release>
      return -1;
    800040fa:	59fd                	li	s3,-1
    800040fc:	bff9                	j	800040da <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800040fe:	4981                	li	s3,0
    80004100:	b7d1                	j	800040c4 <piperead+0xb4>

0000000080004102 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004102:	1141                	addi	sp,sp,-16
    80004104:	e422                	sd	s0,8(sp)
    80004106:	0800                	addi	s0,sp,16
    80004108:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000410a:	8905                	andi	a0,a0,1
    8000410c:	c111                	beqz	a0,80004110 <flags2perm+0xe>
      perm = PTE_X;
    8000410e:	4521                	li	a0,8
    if(flags & 0x2)
    80004110:	8b89                	andi	a5,a5,2
    80004112:	c399                	beqz	a5,80004118 <flags2perm+0x16>
      perm |= PTE_W;
    80004114:	00456513          	ori	a0,a0,4
    return perm;
}
    80004118:	6422                	ld	s0,8(sp)
    8000411a:	0141                	addi	sp,sp,16
    8000411c:	8082                	ret

000000008000411e <exec>:

int
exec(char *path, char **argv)
{
    8000411e:	df010113          	addi	sp,sp,-528
    80004122:	20113423          	sd	ra,520(sp)
    80004126:	20813023          	sd	s0,512(sp)
    8000412a:	ffa6                	sd	s1,504(sp)
    8000412c:	fbca                	sd	s2,496(sp)
    8000412e:	f7ce                	sd	s3,488(sp)
    80004130:	f3d2                	sd	s4,480(sp)
    80004132:	efd6                	sd	s5,472(sp)
    80004134:	ebda                	sd	s6,464(sp)
    80004136:	e7de                	sd	s7,456(sp)
    80004138:	e3e2                	sd	s8,448(sp)
    8000413a:	ff66                	sd	s9,440(sp)
    8000413c:	fb6a                	sd	s10,432(sp)
    8000413e:	f76e                	sd	s11,424(sp)
    80004140:	0c00                	addi	s0,sp,528
    80004142:	84aa                	mv	s1,a0
    80004144:	dea43c23          	sd	a0,-520(s0)
    80004148:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000414c:	ffffd097          	auipc	ra,0xffffd
    80004150:	d30080e7          	jalr	-720(ra) # 80000e7c <myproc>
    80004154:	892a                	mv	s2,a0

  begin_op();
    80004156:	fffff097          	auipc	ra,0xfffff
    8000415a:	474080e7          	jalr	1140(ra) # 800035ca <begin_op>

  if((ip = namei(path)) == 0){
    8000415e:	8526                	mv	a0,s1
    80004160:	fffff097          	auipc	ra,0xfffff
    80004164:	24e080e7          	jalr	590(ra) # 800033ae <namei>
    80004168:	c92d                	beqz	a0,800041da <exec+0xbc>
    8000416a:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000416c:	fffff097          	auipc	ra,0xfffff
    80004170:	a9c080e7          	jalr	-1380(ra) # 80002c08 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004174:	04000713          	li	a4,64
    80004178:	4681                	li	a3,0
    8000417a:	e5040613          	addi	a2,s0,-432
    8000417e:	4581                	li	a1,0
    80004180:	8526                	mv	a0,s1
    80004182:	fffff097          	auipc	ra,0xfffff
    80004186:	d3a080e7          	jalr	-710(ra) # 80002ebc <readi>
    8000418a:	04000793          	li	a5,64
    8000418e:	00f51a63          	bne	a0,a5,800041a2 <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004192:	e5042703          	lw	a4,-432(s0)
    80004196:	464c47b7          	lui	a5,0x464c4
    8000419a:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000419e:	04f70463          	beq	a4,a5,800041e6 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800041a2:	8526                	mv	a0,s1
    800041a4:	fffff097          	auipc	ra,0xfffff
    800041a8:	cc6080e7          	jalr	-826(ra) # 80002e6a <iunlockput>
    end_op();
    800041ac:	fffff097          	auipc	ra,0xfffff
    800041b0:	49e080e7          	jalr	1182(ra) # 8000364a <end_op>
  }
  return -1;
    800041b4:	557d                	li	a0,-1
}
    800041b6:	20813083          	ld	ra,520(sp)
    800041ba:	20013403          	ld	s0,512(sp)
    800041be:	74fe                	ld	s1,504(sp)
    800041c0:	795e                	ld	s2,496(sp)
    800041c2:	79be                	ld	s3,488(sp)
    800041c4:	7a1e                	ld	s4,480(sp)
    800041c6:	6afe                	ld	s5,472(sp)
    800041c8:	6b5e                	ld	s6,464(sp)
    800041ca:	6bbe                	ld	s7,456(sp)
    800041cc:	6c1e                	ld	s8,448(sp)
    800041ce:	7cfa                	ld	s9,440(sp)
    800041d0:	7d5a                	ld	s10,432(sp)
    800041d2:	7dba                	ld	s11,424(sp)
    800041d4:	21010113          	addi	sp,sp,528
    800041d8:	8082                	ret
    end_op();
    800041da:	fffff097          	auipc	ra,0xfffff
    800041de:	470080e7          	jalr	1136(ra) # 8000364a <end_op>
    return -1;
    800041e2:	557d                	li	a0,-1
    800041e4:	bfc9                	j	800041b6 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    800041e6:	854a                	mv	a0,s2
    800041e8:	ffffd097          	auipc	ra,0xffffd
    800041ec:	d58080e7          	jalr	-680(ra) # 80000f40 <proc_pagetable>
    800041f0:	8baa                	mv	s7,a0
    800041f2:	d945                	beqz	a0,800041a2 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800041f4:	e7042983          	lw	s3,-400(s0)
    800041f8:	e8845783          	lhu	a5,-376(s0)
    800041fc:	c7ad                	beqz	a5,80004266 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800041fe:	4a01                	li	s4,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004200:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80004202:	6c85                	lui	s9,0x1
    80004204:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004208:	def43823          	sd	a5,-528(s0)
    8000420c:	ac0d                	j	8000443e <exec+0x320>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    8000420e:	00004517          	auipc	a0,0x4
    80004212:	63250513          	addi	a0,a0,1586 # 80008840 <syscallnames+0x288>
    80004216:	00002097          	auipc	ra,0x2
    8000421a:	aec080e7          	jalr	-1300(ra) # 80005d02 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000421e:	8756                	mv	a4,s5
    80004220:	012d86bb          	addw	a3,s11,s2
    80004224:	4581                	li	a1,0
    80004226:	8526                	mv	a0,s1
    80004228:	fffff097          	auipc	ra,0xfffff
    8000422c:	c94080e7          	jalr	-876(ra) # 80002ebc <readi>
    80004230:	2501                	sext.w	a0,a0
    80004232:	1aaa9a63          	bne	s5,a0,800043e6 <exec+0x2c8>
  for(i = 0; i < sz; i += PGSIZE){
    80004236:	6785                	lui	a5,0x1
    80004238:	0127893b          	addw	s2,a5,s2
    8000423c:	77fd                	lui	a5,0xfffff
    8000423e:	01478a3b          	addw	s4,a5,s4
    80004242:	1f897563          	bgeu	s2,s8,8000442c <exec+0x30e>
    pa = walkaddr(pagetable, va + i);
    80004246:	02091593          	slli	a1,s2,0x20
    8000424a:	9181                	srli	a1,a1,0x20
    8000424c:	95ea                	add	a1,a1,s10
    8000424e:	855e                	mv	a0,s7
    80004250:	ffffc097          	auipc	ra,0xffffc
    80004254:	2de080e7          	jalr	734(ra) # 8000052e <walkaddr>
    80004258:	862a                	mv	a2,a0
    if(pa == 0)
    8000425a:	d955                	beqz	a0,8000420e <exec+0xf0>
      n = PGSIZE;
    8000425c:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    8000425e:	fd9a70e3          	bgeu	s4,s9,8000421e <exec+0x100>
      n = sz - i;
    80004262:	8ad2                	mv	s5,s4
    80004264:	bf6d                	j	8000421e <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004266:	4a01                	li	s4,0
  iunlockput(ip);
    80004268:	8526                	mv	a0,s1
    8000426a:	fffff097          	auipc	ra,0xfffff
    8000426e:	c00080e7          	jalr	-1024(ra) # 80002e6a <iunlockput>
  end_op();
    80004272:	fffff097          	auipc	ra,0xfffff
    80004276:	3d8080e7          	jalr	984(ra) # 8000364a <end_op>
  p = myproc();
    8000427a:	ffffd097          	auipc	ra,0xffffd
    8000427e:	c02080e7          	jalr	-1022(ra) # 80000e7c <myproc>
    80004282:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004284:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004288:	6785                	lui	a5,0x1
    8000428a:	17fd                	addi	a5,a5,-1
    8000428c:	9a3e                	add	s4,s4,a5
    8000428e:	757d                	lui	a0,0xfffff
    80004290:	00aa77b3          	and	a5,s4,a0
    80004294:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004298:	4691                	li	a3,4
    8000429a:	6609                	lui	a2,0x2
    8000429c:	963e                	add	a2,a2,a5
    8000429e:	85be                	mv	a1,a5
    800042a0:	855e                	mv	a0,s7
    800042a2:	ffffc097          	auipc	ra,0xffffc
    800042a6:	640080e7          	jalr	1600(ra) # 800008e2 <uvmalloc>
    800042aa:	8b2a                	mv	s6,a0
  ip = 0;
    800042ac:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800042ae:	12050c63          	beqz	a0,800043e6 <exec+0x2c8>
  uvmclear(pagetable, sz-2*PGSIZE);
    800042b2:	75f9                	lui	a1,0xffffe
    800042b4:	95aa                	add	a1,a1,a0
    800042b6:	855e                	mv	a0,s7
    800042b8:	ffffd097          	auipc	ra,0xffffd
    800042bc:	850080e7          	jalr	-1968(ra) # 80000b08 <uvmclear>
  stackbase = sp - PGSIZE;
    800042c0:	7c7d                	lui	s8,0xfffff
    800042c2:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    800042c4:	e0043783          	ld	a5,-512(s0)
    800042c8:	6388                	ld	a0,0(a5)
    800042ca:	c535                	beqz	a0,80004336 <exec+0x218>
    800042cc:	e9040993          	addi	s3,s0,-368
    800042d0:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800042d4:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    800042d6:	ffffc097          	auipc	ra,0xffffc
    800042da:	04a080e7          	jalr	74(ra) # 80000320 <strlen>
    800042de:	2505                	addiw	a0,a0,1
    800042e0:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800042e4:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800042e8:	13896663          	bltu	s2,s8,80004414 <exec+0x2f6>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800042ec:	e0043d83          	ld	s11,-512(s0)
    800042f0:	000dba03          	ld	s4,0(s11)
    800042f4:	8552                	mv	a0,s4
    800042f6:	ffffc097          	auipc	ra,0xffffc
    800042fa:	02a080e7          	jalr	42(ra) # 80000320 <strlen>
    800042fe:	0015069b          	addiw	a3,a0,1
    80004302:	8652                	mv	a2,s4
    80004304:	85ca                	mv	a1,s2
    80004306:	855e                	mv	a0,s7
    80004308:	ffffd097          	auipc	ra,0xffffd
    8000430c:	832080e7          	jalr	-1998(ra) # 80000b3a <copyout>
    80004310:	10054663          	bltz	a0,8000441c <exec+0x2fe>
    ustack[argc] = sp;
    80004314:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004318:	0485                	addi	s1,s1,1
    8000431a:	008d8793          	addi	a5,s11,8
    8000431e:	e0f43023          	sd	a5,-512(s0)
    80004322:	008db503          	ld	a0,8(s11)
    80004326:	c911                	beqz	a0,8000433a <exec+0x21c>
    if(argc >= MAXARG)
    80004328:	09a1                	addi	s3,s3,8
    8000432a:	fb3c96e3          	bne	s9,s3,800042d6 <exec+0x1b8>
  sz = sz1;
    8000432e:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004332:	4481                	li	s1,0
    80004334:	a84d                	j	800043e6 <exec+0x2c8>
  sp = sz;
    80004336:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80004338:	4481                	li	s1,0
  ustack[argc] = 0;
    8000433a:	00349793          	slli	a5,s1,0x3
    8000433e:	f9040713          	addi	a4,s0,-112
    80004342:	97ba                	add	a5,a5,a4
    80004344:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    80004348:	00148693          	addi	a3,s1,1
    8000434c:	068e                	slli	a3,a3,0x3
    8000434e:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004352:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004356:	01897663          	bgeu	s2,s8,80004362 <exec+0x244>
  sz = sz1;
    8000435a:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000435e:	4481                	li	s1,0
    80004360:	a059                	j	800043e6 <exec+0x2c8>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004362:	e9040613          	addi	a2,s0,-368
    80004366:	85ca                	mv	a1,s2
    80004368:	855e                	mv	a0,s7
    8000436a:	ffffc097          	auipc	ra,0xffffc
    8000436e:	7d0080e7          	jalr	2000(ra) # 80000b3a <copyout>
    80004372:	0a054963          	bltz	a0,80004424 <exec+0x306>
  p->trapframe->a1 = sp;
    80004376:	058ab783          	ld	a5,88(s5)
    8000437a:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000437e:	df843783          	ld	a5,-520(s0)
    80004382:	0007c703          	lbu	a4,0(a5)
    80004386:	cf11                	beqz	a4,800043a2 <exec+0x284>
    80004388:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000438a:	02f00693          	li	a3,47
    8000438e:	a039                	j	8000439c <exec+0x27e>
      last = s+1;
    80004390:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004394:	0785                	addi	a5,a5,1
    80004396:	fff7c703          	lbu	a4,-1(a5)
    8000439a:	c701                	beqz	a4,800043a2 <exec+0x284>
    if(*s == '/')
    8000439c:	fed71ce3          	bne	a4,a3,80004394 <exec+0x276>
    800043a0:	bfc5                	j	80004390 <exec+0x272>
  safestrcpy(p->name, last, sizeof(p->name));
    800043a2:	4641                	li	a2,16
    800043a4:	df843583          	ld	a1,-520(s0)
    800043a8:	158a8513          	addi	a0,s5,344
    800043ac:	ffffc097          	auipc	ra,0xffffc
    800043b0:	f42080e7          	jalr	-190(ra) # 800002ee <safestrcpy>
  oldpagetable = p->pagetable;
    800043b4:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800043b8:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    800043bc:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800043c0:	058ab783          	ld	a5,88(s5)
    800043c4:	e6843703          	ld	a4,-408(s0)
    800043c8:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800043ca:	058ab783          	ld	a5,88(s5)
    800043ce:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800043d2:	85ea                	mv	a1,s10
    800043d4:	ffffd097          	auipc	ra,0xffffd
    800043d8:	c08080e7          	jalr	-1016(ra) # 80000fdc <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800043dc:	0004851b          	sext.w	a0,s1
    800043e0:	bbd9                	j	800041b6 <exec+0x98>
    800043e2:	e1443423          	sd	s4,-504(s0)
    proc_freepagetable(pagetable, sz);
    800043e6:	e0843583          	ld	a1,-504(s0)
    800043ea:	855e                	mv	a0,s7
    800043ec:	ffffd097          	auipc	ra,0xffffd
    800043f0:	bf0080e7          	jalr	-1040(ra) # 80000fdc <proc_freepagetable>
  if(ip){
    800043f4:	da0497e3          	bnez	s1,800041a2 <exec+0x84>
  return -1;
    800043f8:	557d                	li	a0,-1
    800043fa:	bb75                	j	800041b6 <exec+0x98>
    800043fc:	e1443423          	sd	s4,-504(s0)
    80004400:	b7dd                	j	800043e6 <exec+0x2c8>
    80004402:	e1443423          	sd	s4,-504(s0)
    80004406:	b7c5                	j	800043e6 <exec+0x2c8>
    80004408:	e1443423          	sd	s4,-504(s0)
    8000440c:	bfe9                	j	800043e6 <exec+0x2c8>
    8000440e:	e1443423          	sd	s4,-504(s0)
    80004412:	bfd1                	j	800043e6 <exec+0x2c8>
  sz = sz1;
    80004414:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004418:	4481                	li	s1,0
    8000441a:	b7f1                	j	800043e6 <exec+0x2c8>
  sz = sz1;
    8000441c:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004420:	4481                	li	s1,0
    80004422:	b7d1                	j	800043e6 <exec+0x2c8>
  sz = sz1;
    80004424:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004428:	4481                	li	s1,0
    8000442a:	bf75                	j	800043e6 <exec+0x2c8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000442c:	e0843a03          	ld	s4,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004430:	2b05                	addiw	s6,s6,1
    80004432:	0389899b          	addiw	s3,s3,56
    80004436:	e8845783          	lhu	a5,-376(s0)
    8000443a:	e2fb57e3          	bge	s6,a5,80004268 <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000443e:	2981                	sext.w	s3,s3
    80004440:	03800713          	li	a4,56
    80004444:	86ce                	mv	a3,s3
    80004446:	e1840613          	addi	a2,s0,-488
    8000444a:	4581                	li	a1,0
    8000444c:	8526                	mv	a0,s1
    8000444e:	fffff097          	auipc	ra,0xfffff
    80004452:	a6e080e7          	jalr	-1426(ra) # 80002ebc <readi>
    80004456:	03800793          	li	a5,56
    8000445a:	f8f514e3          	bne	a0,a5,800043e2 <exec+0x2c4>
    if(ph.type != ELF_PROG_LOAD)
    8000445e:	e1842783          	lw	a5,-488(s0)
    80004462:	4705                	li	a4,1
    80004464:	fce796e3          	bne	a5,a4,80004430 <exec+0x312>
    if(ph.memsz < ph.filesz)
    80004468:	e4043903          	ld	s2,-448(s0)
    8000446c:	e3843783          	ld	a5,-456(s0)
    80004470:	f8f966e3          	bltu	s2,a5,800043fc <exec+0x2de>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004474:	e2843783          	ld	a5,-472(s0)
    80004478:	993e                	add	s2,s2,a5
    8000447a:	f8f964e3          	bltu	s2,a5,80004402 <exec+0x2e4>
    if(ph.vaddr % PGSIZE != 0)
    8000447e:	df043703          	ld	a4,-528(s0)
    80004482:	8ff9                	and	a5,a5,a4
    80004484:	f3d1                	bnez	a5,80004408 <exec+0x2ea>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004486:	e1c42503          	lw	a0,-484(s0)
    8000448a:	00000097          	auipc	ra,0x0
    8000448e:	c78080e7          	jalr	-904(ra) # 80004102 <flags2perm>
    80004492:	86aa                	mv	a3,a0
    80004494:	864a                	mv	a2,s2
    80004496:	85d2                	mv	a1,s4
    80004498:	855e                	mv	a0,s7
    8000449a:	ffffc097          	auipc	ra,0xffffc
    8000449e:	448080e7          	jalr	1096(ra) # 800008e2 <uvmalloc>
    800044a2:	e0a43423          	sd	a0,-504(s0)
    800044a6:	d525                	beqz	a0,8000440e <exec+0x2f0>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800044a8:	e2843d03          	ld	s10,-472(s0)
    800044ac:	e2042d83          	lw	s11,-480(s0)
    800044b0:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800044b4:	f60c0ce3          	beqz	s8,8000442c <exec+0x30e>
    800044b8:	8a62                	mv	s4,s8
    800044ba:	4901                	li	s2,0
    800044bc:	b369                	j	80004246 <exec+0x128>

00000000800044be <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800044be:	7179                	addi	sp,sp,-48
    800044c0:	f406                	sd	ra,40(sp)
    800044c2:	f022                	sd	s0,32(sp)
    800044c4:	ec26                	sd	s1,24(sp)
    800044c6:	e84a                	sd	s2,16(sp)
    800044c8:	1800                	addi	s0,sp,48
    800044ca:	892e                	mv	s2,a1
    800044cc:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800044ce:	fdc40593          	addi	a1,s0,-36
    800044d2:	ffffe097          	auipc	ra,0xffffe
    800044d6:	af0080e7          	jalr	-1296(ra) # 80001fc2 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800044da:	fdc42703          	lw	a4,-36(s0)
    800044de:	47bd                	li	a5,15
    800044e0:	02e7eb63          	bltu	a5,a4,80004516 <argfd+0x58>
    800044e4:	ffffd097          	auipc	ra,0xffffd
    800044e8:	998080e7          	jalr	-1640(ra) # 80000e7c <myproc>
    800044ec:	fdc42703          	lw	a4,-36(s0)
    800044f0:	01a70793          	addi	a5,a4,26
    800044f4:	078e                	slli	a5,a5,0x3
    800044f6:	953e                	add	a0,a0,a5
    800044f8:	611c                	ld	a5,0(a0)
    800044fa:	c385                	beqz	a5,8000451a <argfd+0x5c>
    return -1;
  if(pfd)
    800044fc:	00090463          	beqz	s2,80004504 <argfd+0x46>
    *pfd = fd;
    80004500:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004504:	4501                	li	a0,0
  if(pf)
    80004506:	c091                	beqz	s1,8000450a <argfd+0x4c>
    *pf = f;
    80004508:	e09c                	sd	a5,0(s1)
}
    8000450a:	70a2                	ld	ra,40(sp)
    8000450c:	7402                	ld	s0,32(sp)
    8000450e:	64e2                	ld	s1,24(sp)
    80004510:	6942                	ld	s2,16(sp)
    80004512:	6145                	addi	sp,sp,48
    80004514:	8082                	ret
    return -1;
    80004516:	557d                	li	a0,-1
    80004518:	bfcd                	j	8000450a <argfd+0x4c>
    8000451a:	557d                	li	a0,-1
    8000451c:	b7fd                	j	8000450a <argfd+0x4c>

000000008000451e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000451e:	1101                	addi	sp,sp,-32
    80004520:	ec06                	sd	ra,24(sp)
    80004522:	e822                	sd	s0,16(sp)
    80004524:	e426                	sd	s1,8(sp)
    80004526:	1000                	addi	s0,sp,32
    80004528:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000452a:	ffffd097          	auipc	ra,0xffffd
    8000452e:	952080e7          	jalr	-1710(ra) # 80000e7c <myproc>
    80004532:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004534:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7ffdcf90>
    80004538:	4501                	li	a0,0
    8000453a:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000453c:	6398                	ld	a4,0(a5)
    8000453e:	cb19                	beqz	a4,80004554 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80004540:	2505                	addiw	a0,a0,1
    80004542:	07a1                	addi	a5,a5,8
    80004544:	fed51ce3          	bne	a0,a3,8000453c <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004548:	557d                	li	a0,-1
}
    8000454a:	60e2                	ld	ra,24(sp)
    8000454c:	6442                	ld	s0,16(sp)
    8000454e:	64a2                	ld	s1,8(sp)
    80004550:	6105                	addi	sp,sp,32
    80004552:	8082                	ret
      p->ofile[fd] = f;
    80004554:	01a50793          	addi	a5,a0,26
    80004558:	078e                	slli	a5,a5,0x3
    8000455a:	963e                	add	a2,a2,a5
    8000455c:	e204                	sd	s1,0(a2)
      return fd;
    8000455e:	b7f5                	j	8000454a <fdalloc+0x2c>

0000000080004560 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004560:	715d                	addi	sp,sp,-80
    80004562:	e486                	sd	ra,72(sp)
    80004564:	e0a2                	sd	s0,64(sp)
    80004566:	fc26                	sd	s1,56(sp)
    80004568:	f84a                	sd	s2,48(sp)
    8000456a:	f44e                	sd	s3,40(sp)
    8000456c:	f052                	sd	s4,32(sp)
    8000456e:	ec56                	sd	s5,24(sp)
    80004570:	e85a                	sd	s6,16(sp)
    80004572:	0880                	addi	s0,sp,80
    80004574:	8b2e                	mv	s6,a1
    80004576:	89b2                	mv	s3,a2
    80004578:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000457a:	fb040593          	addi	a1,s0,-80
    8000457e:	fffff097          	auipc	ra,0xfffff
    80004582:	e4e080e7          	jalr	-434(ra) # 800033cc <nameiparent>
    80004586:	84aa                	mv	s1,a0
    80004588:	16050063          	beqz	a0,800046e8 <create+0x188>
    return 0;

  ilock(dp);
    8000458c:	ffffe097          	auipc	ra,0xffffe
    80004590:	67c080e7          	jalr	1660(ra) # 80002c08 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004594:	4601                	li	a2,0
    80004596:	fb040593          	addi	a1,s0,-80
    8000459a:	8526                	mv	a0,s1
    8000459c:	fffff097          	auipc	ra,0xfffff
    800045a0:	b50080e7          	jalr	-1200(ra) # 800030ec <dirlookup>
    800045a4:	8aaa                	mv	s5,a0
    800045a6:	c931                	beqz	a0,800045fa <create+0x9a>
    iunlockput(dp);
    800045a8:	8526                	mv	a0,s1
    800045aa:	fffff097          	auipc	ra,0xfffff
    800045ae:	8c0080e7          	jalr	-1856(ra) # 80002e6a <iunlockput>
    ilock(ip);
    800045b2:	8556                	mv	a0,s5
    800045b4:	ffffe097          	auipc	ra,0xffffe
    800045b8:	654080e7          	jalr	1620(ra) # 80002c08 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800045bc:	000b059b          	sext.w	a1,s6
    800045c0:	4789                	li	a5,2
    800045c2:	02f59563          	bne	a1,a5,800045ec <create+0x8c>
    800045c6:	044ad783          	lhu	a5,68(s5)
    800045ca:	37f9                	addiw	a5,a5,-2
    800045cc:	17c2                	slli	a5,a5,0x30
    800045ce:	93c1                	srli	a5,a5,0x30
    800045d0:	4705                	li	a4,1
    800045d2:	00f76d63          	bltu	a4,a5,800045ec <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800045d6:	8556                	mv	a0,s5
    800045d8:	60a6                	ld	ra,72(sp)
    800045da:	6406                	ld	s0,64(sp)
    800045dc:	74e2                	ld	s1,56(sp)
    800045de:	7942                	ld	s2,48(sp)
    800045e0:	79a2                	ld	s3,40(sp)
    800045e2:	7a02                	ld	s4,32(sp)
    800045e4:	6ae2                	ld	s5,24(sp)
    800045e6:	6b42                	ld	s6,16(sp)
    800045e8:	6161                	addi	sp,sp,80
    800045ea:	8082                	ret
    iunlockput(ip);
    800045ec:	8556                	mv	a0,s5
    800045ee:	fffff097          	auipc	ra,0xfffff
    800045f2:	87c080e7          	jalr	-1924(ra) # 80002e6a <iunlockput>
    return 0;
    800045f6:	4a81                	li	s5,0
    800045f8:	bff9                	j	800045d6 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    800045fa:	85da                	mv	a1,s6
    800045fc:	4088                	lw	a0,0(s1)
    800045fe:	ffffe097          	auipc	ra,0xffffe
    80004602:	46e080e7          	jalr	1134(ra) # 80002a6c <ialloc>
    80004606:	8a2a                	mv	s4,a0
    80004608:	c921                	beqz	a0,80004658 <create+0xf8>
  ilock(ip);
    8000460a:	ffffe097          	auipc	ra,0xffffe
    8000460e:	5fe080e7          	jalr	1534(ra) # 80002c08 <ilock>
  ip->major = major;
    80004612:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004616:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000461a:	4785                	li	a5,1
    8000461c:	04fa1523          	sh	a5,74(s4)
  iupdate(ip);
    80004620:	8552                	mv	a0,s4
    80004622:	ffffe097          	auipc	ra,0xffffe
    80004626:	51c080e7          	jalr	1308(ra) # 80002b3e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000462a:	000b059b          	sext.w	a1,s6
    8000462e:	4785                	li	a5,1
    80004630:	02f58b63          	beq	a1,a5,80004666 <create+0x106>
  if(dirlink(dp, name, ip->inum) < 0)
    80004634:	004a2603          	lw	a2,4(s4)
    80004638:	fb040593          	addi	a1,s0,-80
    8000463c:	8526                	mv	a0,s1
    8000463e:	fffff097          	auipc	ra,0xfffff
    80004642:	cbe080e7          	jalr	-834(ra) # 800032fc <dirlink>
    80004646:	06054f63          	bltz	a0,800046c4 <create+0x164>
  iunlockput(dp);
    8000464a:	8526                	mv	a0,s1
    8000464c:	fffff097          	auipc	ra,0xfffff
    80004650:	81e080e7          	jalr	-2018(ra) # 80002e6a <iunlockput>
  return ip;
    80004654:	8ad2                	mv	s5,s4
    80004656:	b741                	j	800045d6 <create+0x76>
    iunlockput(dp);
    80004658:	8526                	mv	a0,s1
    8000465a:	fffff097          	auipc	ra,0xfffff
    8000465e:	810080e7          	jalr	-2032(ra) # 80002e6a <iunlockput>
    return 0;
    80004662:	8ad2                	mv	s5,s4
    80004664:	bf8d                	j	800045d6 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004666:	004a2603          	lw	a2,4(s4)
    8000466a:	00004597          	auipc	a1,0x4
    8000466e:	1f658593          	addi	a1,a1,502 # 80008860 <syscallnames+0x2a8>
    80004672:	8552                	mv	a0,s4
    80004674:	fffff097          	auipc	ra,0xfffff
    80004678:	c88080e7          	jalr	-888(ra) # 800032fc <dirlink>
    8000467c:	04054463          	bltz	a0,800046c4 <create+0x164>
    80004680:	40d0                	lw	a2,4(s1)
    80004682:	00004597          	auipc	a1,0x4
    80004686:	1e658593          	addi	a1,a1,486 # 80008868 <syscallnames+0x2b0>
    8000468a:	8552                	mv	a0,s4
    8000468c:	fffff097          	auipc	ra,0xfffff
    80004690:	c70080e7          	jalr	-912(ra) # 800032fc <dirlink>
    80004694:	02054863          	bltz	a0,800046c4 <create+0x164>
  if(dirlink(dp, name, ip->inum) < 0)
    80004698:	004a2603          	lw	a2,4(s4)
    8000469c:	fb040593          	addi	a1,s0,-80
    800046a0:	8526                	mv	a0,s1
    800046a2:	fffff097          	auipc	ra,0xfffff
    800046a6:	c5a080e7          	jalr	-934(ra) # 800032fc <dirlink>
    800046aa:	00054d63          	bltz	a0,800046c4 <create+0x164>
    dp->nlink++;  // for ".."
    800046ae:	04a4d783          	lhu	a5,74(s1)
    800046b2:	2785                	addiw	a5,a5,1
    800046b4:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800046b8:	8526                	mv	a0,s1
    800046ba:	ffffe097          	auipc	ra,0xffffe
    800046be:	484080e7          	jalr	1156(ra) # 80002b3e <iupdate>
    800046c2:	b761                	j	8000464a <create+0xea>
  ip->nlink = 0;
    800046c4:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800046c8:	8552                	mv	a0,s4
    800046ca:	ffffe097          	auipc	ra,0xffffe
    800046ce:	474080e7          	jalr	1140(ra) # 80002b3e <iupdate>
  iunlockput(ip);
    800046d2:	8552                	mv	a0,s4
    800046d4:	ffffe097          	auipc	ra,0xffffe
    800046d8:	796080e7          	jalr	1942(ra) # 80002e6a <iunlockput>
  iunlockput(dp);
    800046dc:	8526                	mv	a0,s1
    800046de:	ffffe097          	auipc	ra,0xffffe
    800046e2:	78c080e7          	jalr	1932(ra) # 80002e6a <iunlockput>
  return 0;
    800046e6:	bdc5                	j	800045d6 <create+0x76>
    return 0;
    800046e8:	8aaa                	mv	s5,a0
    800046ea:	b5f5                	j	800045d6 <create+0x76>

00000000800046ec <sys_dup>:
{
    800046ec:	7179                	addi	sp,sp,-48
    800046ee:	f406                	sd	ra,40(sp)
    800046f0:	f022                	sd	s0,32(sp)
    800046f2:	ec26                	sd	s1,24(sp)
    800046f4:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800046f6:	fd840613          	addi	a2,s0,-40
    800046fa:	4581                	li	a1,0
    800046fc:	4501                	li	a0,0
    800046fe:	00000097          	auipc	ra,0x0
    80004702:	dc0080e7          	jalr	-576(ra) # 800044be <argfd>
    return -1;
    80004706:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004708:	02054363          	bltz	a0,8000472e <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    8000470c:	fd843503          	ld	a0,-40(s0)
    80004710:	00000097          	auipc	ra,0x0
    80004714:	e0e080e7          	jalr	-498(ra) # 8000451e <fdalloc>
    80004718:	84aa                	mv	s1,a0
    return -1;
    8000471a:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000471c:	00054963          	bltz	a0,8000472e <sys_dup+0x42>
  filedup(f);
    80004720:	fd843503          	ld	a0,-40(s0)
    80004724:	fffff097          	auipc	ra,0xfffff
    80004728:	320080e7          	jalr	800(ra) # 80003a44 <filedup>
  return fd;
    8000472c:	87a6                	mv	a5,s1
}
    8000472e:	853e                	mv	a0,a5
    80004730:	70a2                	ld	ra,40(sp)
    80004732:	7402                	ld	s0,32(sp)
    80004734:	64e2                	ld	s1,24(sp)
    80004736:	6145                	addi	sp,sp,48
    80004738:	8082                	ret

000000008000473a <sys_read>:
{
    8000473a:	7179                	addi	sp,sp,-48
    8000473c:	f406                	sd	ra,40(sp)
    8000473e:	f022                	sd	s0,32(sp)
    80004740:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004742:	fd840593          	addi	a1,s0,-40
    80004746:	4505                	li	a0,1
    80004748:	ffffe097          	auipc	ra,0xffffe
    8000474c:	89a080e7          	jalr	-1894(ra) # 80001fe2 <argaddr>
  argint(2, &n);
    80004750:	fe440593          	addi	a1,s0,-28
    80004754:	4509                	li	a0,2
    80004756:	ffffe097          	auipc	ra,0xffffe
    8000475a:	86c080e7          	jalr	-1940(ra) # 80001fc2 <argint>
  if(argfd(0, 0, &f) < 0)
    8000475e:	fe840613          	addi	a2,s0,-24
    80004762:	4581                	li	a1,0
    80004764:	4501                	li	a0,0
    80004766:	00000097          	auipc	ra,0x0
    8000476a:	d58080e7          	jalr	-680(ra) # 800044be <argfd>
    8000476e:	87aa                	mv	a5,a0
    return -1;
    80004770:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004772:	0007cc63          	bltz	a5,8000478a <sys_read+0x50>
  return fileread(f, p, n);
    80004776:	fe442603          	lw	a2,-28(s0)
    8000477a:	fd843583          	ld	a1,-40(s0)
    8000477e:	fe843503          	ld	a0,-24(s0)
    80004782:	fffff097          	auipc	ra,0xfffff
    80004786:	44e080e7          	jalr	1102(ra) # 80003bd0 <fileread>
}
    8000478a:	70a2                	ld	ra,40(sp)
    8000478c:	7402                	ld	s0,32(sp)
    8000478e:	6145                	addi	sp,sp,48
    80004790:	8082                	ret

0000000080004792 <sys_write>:
{
    80004792:	7179                	addi	sp,sp,-48
    80004794:	f406                	sd	ra,40(sp)
    80004796:	f022                	sd	s0,32(sp)
    80004798:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000479a:	fd840593          	addi	a1,s0,-40
    8000479e:	4505                	li	a0,1
    800047a0:	ffffe097          	auipc	ra,0xffffe
    800047a4:	842080e7          	jalr	-1982(ra) # 80001fe2 <argaddr>
  argint(2, &n);
    800047a8:	fe440593          	addi	a1,s0,-28
    800047ac:	4509                	li	a0,2
    800047ae:	ffffe097          	auipc	ra,0xffffe
    800047b2:	814080e7          	jalr	-2028(ra) # 80001fc2 <argint>
  if(argfd(0, 0, &f) < 0)
    800047b6:	fe840613          	addi	a2,s0,-24
    800047ba:	4581                	li	a1,0
    800047bc:	4501                	li	a0,0
    800047be:	00000097          	auipc	ra,0x0
    800047c2:	d00080e7          	jalr	-768(ra) # 800044be <argfd>
    800047c6:	87aa                	mv	a5,a0
    return -1;
    800047c8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800047ca:	0007cc63          	bltz	a5,800047e2 <sys_write+0x50>
  return filewrite(f, p, n);
    800047ce:	fe442603          	lw	a2,-28(s0)
    800047d2:	fd843583          	ld	a1,-40(s0)
    800047d6:	fe843503          	ld	a0,-24(s0)
    800047da:	fffff097          	auipc	ra,0xfffff
    800047de:	4b8080e7          	jalr	1208(ra) # 80003c92 <filewrite>
}
    800047e2:	70a2                	ld	ra,40(sp)
    800047e4:	7402                	ld	s0,32(sp)
    800047e6:	6145                	addi	sp,sp,48
    800047e8:	8082                	ret

00000000800047ea <sys_close>:
{
    800047ea:	1101                	addi	sp,sp,-32
    800047ec:	ec06                	sd	ra,24(sp)
    800047ee:	e822                	sd	s0,16(sp)
    800047f0:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800047f2:	fe040613          	addi	a2,s0,-32
    800047f6:	fec40593          	addi	a1,s0,-20
    800047fa:	4501                	li	a0,0
    800047fc:	00000097          	auipc	ra,0x0
    80004800:	cc2080e7          	jalr	-830(ra) # 800044be <argfd>
    return -1;
    80004804:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004806:	02054463          	bltz	a0,8000482e <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000480a:	ffffc097          	auipc	ra,0xffffc
    8000480e:	672080e7          	jalr	1650(ra) # 80000e7c <myproc>
    80004812:	fec42783          	lw	a5,-20(s0)
    80004816:	07e9                	addi	a5,a5,26
    80004818:	078e                	slli	a5,a5,0x3
    8000481a:	97aa                	add	a5,a5,a0
    8000481c:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80004820:	fe043503          	ld	a0,-32(s0)
    80004824:	fffff097          	auipc	ra,0xfffff
    80004828:	272080e7          	jalr	626(ra) # 80003a96 <fileclose>
  return 0;
    8000482c:	4781                	li	a5,0
}
    8000482e:	853e                	mv	a0,a5
    80004830:	60e2                	ld	ra,24(sp)
    80004832:	6442                	ld	s0,16(sp)
    80004834:	6105                	addi	sp,sp,32
    80004836:	8082                	ret

0000000080004838 <sys_fstat>:
{
    80004838:	1101                	addi	sp,sp,-32
    8000483a:	ec06                	sd	ra,24(sp)
    8000483c:	e822                	sd	s0,16(sp)
    8000483e:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004840:	fe040593          	addi	a1,s0,-32
    80004844:	4505                	li	a0,1
    80004846:	ffffd097          	auipc	ra,0xffffd
    8000484a:	79c080e7          	jalr	1948(ra) # 80001fe2 <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000484e:	fe840613          	addi	a2,s0,-24
    80004852:	4581                	li	a1,0
    80004854:	4501                	li	a0,0
    80004856:	00000097          	auipc	ra,0x0
    8000485a:	c68080e7          	jalr	-920(ra) # 800044be <argfd>
    8000485e:	87aa                	mv	a5,a0
    return -1;
    80004860:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004862:	0007ca63          	bltz	a5,80004876 <sys_fstat+0x3e>
  return filestat(f, st);
    80004866:	fe043583          	ld	a1,-32(s0)
    8000486a:	fe843503          	ld	a0,-24(s0)
    8000486e:	fffff097          	auipc	ra,0xfffff
    80004872:	2f0080e7          	jalr	752(ra) # 80003b5e <filestat>
}
    80004876:	60e2                	ld	ra,24(sp)
    80004878:	6442                	ld	s0,16(sp)
    8000487a:	6105                	addi	sp,sp,32
    8000487c:	8082                	ret

000000008000487e <sys_link>:
{
    8000487e:	7169                	addi	sp,sp,-304
    80004880:	f606                	sd	ra,296(sp)
    80004882:	f222                	sd	s0,288(sp)
    80004884:	ee26                	sd	s1,280(sp)
    80004886:	ea4a                	sd	s2,272(sp)
    80004888:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000488a:	08000613          	li	a2,128
    8000488e:	ed040593          	addi	a1,s0,-304
    80004892:	4501                	li	a0,0
    80004894:	ffffd097          	auipc	ra,0xffffd
    80004898:	76e080e7          	jalr	1902(ra) # 80002002 <argstr>
    return -1;
    8000489c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000489e:	10054e63          	bltz	a0,800049ba <sys_link+0x13c>
    800048a2:	08000613          	li	a2,128
    800048a6:	f5040593          	addi	a1,s0,-176
    800048aa:	4505                	li	a0,1
    800048ac:	ffffd097          	auipc	ra,0xffffd
    800048b0:	756080e7          	jalr	1878(ra) # 80002002 <argstr>
    return -1;
    800048b4:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800048b6:	10054263          	bltz	a0,800049ba <sys_link+0x13c>
  begin_op();
    800048ba:	fffff097          	auipc	ra,0xfffff
    800048be:	d10080e7          	jalr	-752(ra) # 800035ca <begin_op>
  if((ip = namei(old)) == 0){
    800048c2:	ed040513          	addi	a0,s0,-304
    800048c6:	fffff097          	auipc	ra,0xfffff
    800048ca:	ae8080e7          	jalr	-1304(ra) # 800033ae <namei>
    800048ce:	84aa                	mv	s1,a0
    800048d0:	c551                	beqz	a0,8000495c <sys_link+0xde>
  ilock(ip);
    800048d2:	ffffe097          	auipc	ra,0xffffe
    800048d6:	336080e7          	jalr	822(ra) # 80002c08 <ilock>
  if(ip->type == T_DIR){
    800048da:	04449703          	lh	a4,68(s1)
    800048de:	4785                	li	a5,1
    800048e0:	08f70463          	beq	a4,a5,80004968 <sys_link+0xea>
  ip->nlink++;
    800048e4:	04a4d783          	lhu	a5,74(s1)
    800048e8:	2785                	addiw	a5,a5,1
    800048ea:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800048ee:	8526                	mv	a0,s1
    800048f0:	ffffe097          	auipc	ra,0xffffe
    800048f4:	24e080e7          	jalr	590(ra) # 80002b3e <iupdate>
  iunlock(ip);
    800048f8:	8526                	mv	a0,s1
    800048fa:	ffffe097          	auipc	ra,0xffffe
    800048fe:	3d0080e7          	jalr	976(ra) # 80002cca <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004902:	fd040593          	addi	a1,s0,-48
    80004906:	f5040513          	addi	a0,s0,-176
    8000490a:	fffff097          	auipc	ra,0xfffff
    8000490e:	ac2080e7          	jalr	-1342(ra) # 800033cc <nameiparent>
    80004912:	892a                	mv	s2,a0
    80004914:	c935                	beqz	a0,80004988 <sys_link+0x10a>
  ilock(dp);
    80004916:	ffffe097          	auipc	ra,0xffffe
    8000491a:	2f2080e7          	jalr	754(ra) # 80002c08 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000491e:	00092703          	lw	a4,0(s2)
    80004922:	409c                	lw	a5,0(s1)
    80004924:	04f71d63          	bne	a4,a5,8000497e <sys_link+0x100>
    80004928:	40d0                	lw	a2,4(s1)
    8000492a:	fd040593          	addi	a1,s0,-48
    8000492e:	854a                	mv	a0,s2
    80004930:	fffff097          	auipc	ra,0xfffff
    80004934:	9cc080e7          	jalr	-1588(ra) # 800032fc <dirlink>
    80004938:	04054363          	bltz	a0,8000497e <sys_link+0x100>
  iunlockput(dp);
    8000493c:	854a                	mv	a0,s2
    8000493e:	ffffe097          	auipc	ra,0xffffe
    80004942:	52c080e7          	jalr	1324(ra) # 80002e6a <iunlockput>
  iput(ip);
    80004946:	8526                	mv	a0,s1
    80004948:	ffffe097          	auipc	ra,0xffffe
    8000494c:	47a080e7          	jalr	1146(ra) # 80002dc2 <iput>
  end_op();
    80004950:	fffff097          	auipc	ra,0xfffff
    80004954:	cfa080e7          	jalr	-774(ra) # 8000364a <end_op>
  return 0;
    80004958:	4781                	li	a5,0
    8000495a:	a085                	j	800049ba <sys_link+0x13c>
    end_op();
    8000495c:	fffff097          	auipc	ra,0xfffff
    80004960:	cee080e7          	jalr	-786(ra) # 8000364a <end_op>
    return -1;
    80004964:	57fd                	li	a5,-1
    80004966:	a891                	j	800049ba <sys_link+0x13c>
    iunlockput(ip);
    80004968:	8526                	mv	a0,s1
    8000496a:	ffffe097          	auipc	ra,0xffffe
    8000496e:	500080e7          	jalr	1280(ra) # 80002e6a <iunlockput>
    end_op();
    80004972:	fffff097          	auipc	ra,0xfffff
    80004976:	cd8080e7          	jalr	-808(ra) # 8000364a <end_op>
    return -1;
    8000497a:	57fd                	li	a5,-1
    8000497c:	a83d                	j	800049ba <sys_link+0x13c>
    iunlockput(dp);
    8000497e:	854a                	mv	a0,s2
    80004980:	ffffe097          	auipc	ra,0xffffe
    80004984:	4ea080e7          	jalr	1258(ra) # 80002e6a <iunlockput>
  ilock(ip);
    80004988:	8526                	mv	a0,s1
    8000498a:	ffffe097          	auipc	ra,0xffffe
    8000498e:	27e080e7          	jalr	638(ra) # 80002c08 <ilock>
  ip->nlink--;
    80004992:	04a4d783          	lhu	a5,74(s1)
    80004996:	37fd                	addiw	a5,a5,-1
    80004998:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000499c:	8526                	mv	a0,s1
    8000499e:	ffffe097          	auipc	ra,0xffffe
    800049a2:	1a0080e7          	jalr	416(ra) # 80002b3e <iupdate>
  iunlockput(ip);
    800049a6:	8526                	mv	a0,s1
    800049a8:	ffffe097          	auipc	ra,0xffffe
    800049ac:	4c2080e7          	jalr	1218(ra) # 80002e6a <iunlockput>
  end_op();
    800049b0:	fffff097          	auipc	ra,0xfffff
    800049b4:	c9a080e7          	jalr	-870(ra) # 8000364a <end_op>
  return -1;
    800049b8:	57fd                	li	a5,-1
}
    800049ba:	853e                	mv	a0,a5
    800049bc:	70b2                	ld	ra,296(sp)
    800049be:	7412                	ld	s0,288(sp)
    800049c0:	64f2                	ld	s1,280(sp)
    800049c2:	6952                	ld	s2,272(sp)
    800049c4:	6155                	addi	sp,sp,304
    800049c6:	8082                	ret

00000000800049c8 <sys_unlink>:
{
    800049c8:	7151                	addi	sp,sp,-240
    800049ca:	f586                	sd	ra,232(sp)
    800049cc:	f1a2                	sd	s0,224(sp)
    800049ce:	eda6                	sd	s1,216(sp)
    800049d0:	e9ca                	sd	s2,208(sp)
    800049d2:	e5ce                	sd	s3,200(sp)
    800049d4:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800049d6:	08000613          	li	a2,128
    800049da:	f3040593          	addi	a1,s0,-208
    800049de:	4501                	li	a0,0
    800049e0:	ffffd097          	auipc	ra,0xffffd
    800049e4:	622080e7          	jalr	1570(ra) # 80002002 <argstr>
    800049e8:	18054163          	bltz	a0,80004b6a <sys_unlink+0x1a2>
  begin_op();
    800049ec:	fffff097          	auipc	ra,0xfffff
    800049f0:	bde080e7          	jalr	-1058(ra) # 800035ca <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800049f4:	fb040593          	addi	a1,s0,-80
    800049f8:	f3040513          	addi	a0,s0,-208
    800049fc:	fffff097          	auipc	ra,0xfffff
    80004a00:	9d0080e7          	jalr	-1584(ra) # 800033cc <nameiparent>
    80004a04:	84aa                	mv	s1,a0
    80004a06:	c979                	beqz	a0,80004adc <sys_unlink+0x114>
  ilock(dp);
    80004a08:	ffffe097          	auipc	ra,0xffffe
    80004a0c:	200080e7          	jalr	512(ra) # 80002c08 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004a10:	00004597          	auipc	a1,0x4
    80004a14:	e5058593          	addi	a1,a1,-432 # 80008860 <syscallnames+0x2a8>
    80004a18:	fb040513          	addi	a0,s0,-80
    80004a1c:	ffffe097          	auipc	ra,0xffffe
    80004a20:	6b6080e7          	jalr	1718(ra) # 800030d2 <namecmp>
    80004a24:	14050a63          	beqz	a0,80004b78 <sys_unlink+0x1b0>
    80004a28:	00004597          	auipc	a1,0x4
    80004a2c:	e4058593          	addi	a1,a1,-448 # 80008868 <syscallnames+0x2b0>
    80004a30:	fb040513          	addi	a0,s0,-80
    80004a34:	ffffe097          	auipc	ra,0xffffe
    80004a38:	69e080e7          	jalr	1694(ra) # 800030d2 <namecmp>
    80004a3c:	12050e63          	beqz	a0,80004b78 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004a40:	f2c40613          	addi	a2,s0,-212
    80004a44:	fb040593          	addi	a1,s0,-80
    80004a48:	8526                	mv	a0,s1
    80004a4a:	ffffe097          	auipc	ra,0xffffe
    80004a4e:	6a2080e7          	jalr	1698(ra) # 800030ec <dirlookup>
    80004a52:	892a                	mv	s2,a0
    80004a54:	12050263          	beqz	a0,80004b78 <sys_unlink+0x1b0>
  ilock(ip);
    80004a58:	ffffe097          	auipc	ra,0xffffe
    80004a5c:	1b0080e7          	jalr	432(ra) # 80002c08 <ilock>
  if(ip->nlink < 1)
    80004a60:	04a91783          	lh	a5,74(s2)
    80004a64:	08f05263          	blez	a5,80004ae8 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004a68:	04491703          	lh	a4,68(s2)
    80004a6c:	4785                	li	a5,1
    80004a6e:	08f70563          	beq	a4,a5,80004af8 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80004a72:	4641                	li	a2,16
    80004a74:	4581                	li	a1,0
    80004a76:	fc040513          	addi	a0,s0,-64
    80004a7a:	ffffb097          	auipc	ra,0xffffb
    80004a7e:	722080e7          	jalr	1826(ra) # 8000019c <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004a82:	4741                	li	a4,16
    80004a84:	f2c42683          	lw	a3,-212(s0)
    80004a88:	fc040613          	addi	a2,s0,-64
    80004a8c:	4581                	li	a1,0
    80004a8e:	8526                	mv	a0,s1
    80004a90:	ffffe097          	auipc	ra,0xffffe
    80004a94:	524080e7          	jalr	1316(ra) # 80002fb4 <writei>
    80004a98:	47c1                	li	a5,16
    80004a9a:	0af51563          	bne	a0,a5,80004b44 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80004a9e:	04491703          	lh	a4,68(s2)
    80004aa2:	4785                	li	a5,1
    80004aa4:	0af70863          	beq	a4,a5,80004b54 <sys_unlink+0x18c>
  iunlockput(dp);
    80004aa8:	8526                	mv	a0,s1
    80004aaa:	ffffe097          	auipc	ra,0xffffe
    80004aae:	3c0080e7          	jalr	960(ra) # 80002e6a <iunlockput>
  ip->nlink--;
    80004ab2:	04a95783          	lhu	a5,74(s2)
    80004ab6:	37fd                	addiw	a5,a5,-1
    80004ab8:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004abc:	854a                	mv	a0,s2
    80004abe:	ffffe097          	auipc	ra,0xffffe
    80004ac2:	080080e7          	jalr	128(ra) # 80002b3e <iupdate>
  iunlockput(ip);
    80004ac6:	854a                	mv	a0,s2
    80004ac8:	ffffe097          	auipc	ra,0xffffe
    80004acc:	3a2080e7          	jalr	930(ra) # 80002e6a <iunlockput>
  end_op();
    80004ad0:	fffff097          	auipc	ra,0xfffff
    80004ad4:	b7a080e7          	jalr	-1158(ra) # 8000364a <end_op>
  return 0;
    80004ad8:	4501                	li	a0,0
    80004ada:	a84d                	j	80004b8c <sys_unlink+0x1c4>
    end_op();
    80004adc:	fffff097          	auipc	ra,0xfffff
    80004ae0:	b6e080e7          	jalr	-1170(ra) # 8000364a <end_op>
    return -1;
    80004ae4:	557d                	li	a0,-1
    80004ae6:	a05d                	j	80004b8c <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80004ae8:	00004517          	auipc	a0,0x4
    80004aec:	d8850513          	addi	a0,a0,-632 # 80008870 <syscallnames+0x2b8>
    80004af0:	00001097          	auipc	ra,0x1
    80004af4:	212080e7          	jalr	530(ra) # 80005d02 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004af8:	04c92703          	lw	a4,76(s2)
    80004afc:	02000793          	li	a5,32
    80004b00:	f6e7f9e3          	bgeu	a5,a4,80004a72 <sys_unlink+0xaa>
    80004b04:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004b08:	4741                	li	a4,16
    80004b0a:	86ce                	mv	a3,s3
    80004b0c:	f1840613          	addi	a2,s0,-232
    80004b10:	4581                	li	a1,0
    80004b12:	854a                	mv	a0,s2
    80004b14:	ffffe097          	auipc	ra,0xffffe
    80004b18:	3a8080e7          	jalr	936(ra) # 80002ebc <readi>
    80004b1c:	47c1                	li	a5,16
    80004b1e:	00f51b63          	bne	a0,a5,80004b34 <sys_unlink+0x16c>
    if(de.inum != 0)
    80004b22:	f1845783          	lhu	a5,-232(s0)
    80004b26:	e7a1                	bnez	a5,80004b6e <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004b28:	29c1                	addiw	s3,s3,16
    80004b2a:	04c92783          	lw	a5,76(s2)
    80004b2e:	fcf9ede3          	bltu	s3,a5,80004b08 <sys_unlink+0x140>
    80004b32:	b781                	j	80004a72 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80004b34:	00004517          	auipc	a0,0x4
    80004b38:	d5450513          	addi	a0,a0,-684 # 80008888 <syscallnames+0x2d0>
    80004b3c:	00001097          	auipc	ra,0x1
    80004b40:	1c6080e7          	jalr	454(ra) # 80005d02 <panic>
    panic("unlink: writei");
    80004b44:	00004517          	auipc	a0,0x4
    80004b48:	d5c50513          	addi	a0,a0,-676 # 800088a0 <syscallnames+0x2e8>
    80004b4c:	00001097          	auipc	ra,0x1
    80004b50:	1b6080e7          	jalr	438(ra) # 80005d02 <panic>
    dp->nlink--;
    80004b54:	04a4d783          	lhu	a5,74(s1)
    80004b58:	37fd                	addiw	a5,a5,-1
    80004b5a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004b5e:	8526                	mv	a0,s1
    80004b60:	ffffe097          	auipc	ra,0xffffe
    80004b64:	fde080e7          	jalr	-34(ra) # 80002b3e <iupdate>
    80004b68:	b781                	j	80004aa8 <sys_unlink+0xe0>
    return -1;
    80004b6a:	557d                	li	a0,-1
    80004b6c:	a005                	j	80004b8c <sys_unlink+0x1c4>
    iunlockput(ip);
    80004b6e:	854a                	mv	a0,s2
    80004b70:	ffffe097          	auipc	ra,0xffffe
    80004b74:	2fa080e7          	jalr	762(ra) # 80002e6a <iunlockput>
  iunlockput(dp);
    80004b78:	8526                	mv	a0,s1
    80004b7a:	ffffe097          	auipc	ra,0xffffe
    80004b7e:	2f0080e7          	jalr	752(ra) # 80002e6a <iunlockput>
  end_op();
    80004b82:	fffff097          	auipc	ra,0xfffff
    80004b86:	ac8080e7          	jalr	-1336(ra) # 8000364a <end_op>
  return -1;
    80004b8a:	557d                	li	a0,-1
}
    80004b8c:	70ae                	ld	ra,232(sp)
    80004b8e:	740e                	ld	s0,224(sp)
    80004b90:	64ee                	ld	s1,216(sp)
    80004b92:	694e                	ld	s2,208(sp)
    80004b94:	69ae                	ld	s3,200(sp)
    80004b96:	616d                	addi	sp,sp,240
    80004b98:	8082                	ret

0000000080004b9a <sys_open>:

uint64
sys_open(void)
{
    80004b9a:	7131                	addi	sp,sp,-192
    80004b9c:	fd06                	sd	ra,184(sp)
    80004b9e:	f922                	sd	s0,176(sp)
    80004ba0:	f526                	sd	s1,168(sp)
    80004ba2:	f14a                	sd	s2,160(sp)
    80004ba4:	ed4e                	sd	s3,152(sp)
    80004ba6:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004ba8:	f4c40593          	addi	a1,s0,-180
    80004bac:	4505                	li	a0,1
    80004bae:	ffffd097          	auipc	ra,0xffffd
    80004bb2:	414080e7          	jalr	1044(ra) # 80001fc2 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004bb6:	08000613          	li	a2,128
    80004bba:	f5040593          	addi	a1,s0,-176
    80004bbe:	4501                	li	a0,0
    80004bc0:	ffffd097          	auipc	ra,0xffffd
    80004bc4:	442080e7          	jalr	1090(ra) # 80002002 <argstr>
    80004bc8:	87aa                	mv	a5,a0
    return -1;
    80004bca:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004bcc:	0a07c963          	bltz	a5,80004c7e <sys_open+0xe4>

  begin_op();
    80004bd0:	fffff097          	auipc	ra,0xfffff
    80004bd4:	9fa080e7          	jalr	-1542(ra) # 800035ca <begin_op>

  if(omode & O_CREATE){
    80004bd8:	f4c42783          	lw	a5,-180(s0)
    80004bdc:	2007f793          	andi	a5,a5,512
    80004be0:	cfc5                	beqz	a5,80004c98 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80004be2:	4681                	li	a3,0
    80004be4:	4601                	li	a2,0
    80004be6:	4589                	li	a1,2
    80004be8:	f5040513          	addi	a0,s0,-176
    80004bec:	00000097          	auipc	ra,0x0
    80004bf0:	974080e7          	jalr	-1676(ra) # 80004560 <create>
    80004bf4:	84aa                	mv	s1,a0
    if(ip == 0){
    80004bf6:	c959                	beqz	a0,80004c8c <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004bf8:	04449703          	lh	a4,68(s1)
    80004bfc:	478d                	li	a5,3
    80004bfe:	00f71763          	bne	a4,a5,80004c0c <sys_open+0x72>
    80004c02:	0464d703          	lhu	a4,70(s1)
    80004c06:	47a5                	li	a5,9
    80004c08:	0ce7ed63          	bltu	a5,a4,80004ce2 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004c0c:	fffff097          	auipc	ra,0xfffff
    80004c10:	dce080e7          	jalr	-562(ra) # 800039da <filealloc>
    80004c14:	89aa                	mv	s3,a0
    80004c16:	10050363          	beqz	a0,80004d1c <sys_open+0x182>
    80004c1a:	00000097          	auipc	ra,0x0
    80004c1e:	904080e7          	jalr	-1788(ra) # 8000451e <fdalloc>
    80004c22:	892a                	mv	s2,a0
    80004c24:	0e054763          	bltz	a0,80004d12 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004c28:	04449703          	lh	a4,68(s1)
    80004c2c:	478d                	li	a5,3
    80004c2e:	0cf70563          	beq	a4,a5,80004cf8 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004c32:	4789                	li	a5,2
    80004c34:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80004c38:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80004c3c:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80004c40:	f4c42783          	lw	a5,-180(s0)
    80004c44:	0017c713          	xori	a4,a5,1
    80004c48:	8b05                	andi	a4,a4,1
    80004c4a:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004c4e:	0037f713          	andi	a4,a5,3
    80004c52:	00e03733          	snez	a4,a4
    80004c56:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004c5a:	4007f793          	andi	a5,a5,1024
    80004c5e:	c791                	beqz	a5,80004c6a <sys_open+0xd0>
    80004c60:	04449703          	lh	a4,68(s1)
    80004c64:	4789                	li	a5,2
    80004c66:	0af70063          	beq	a4,a5,80004d06 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80004c6a:	8526                	mv	a0,s1
    80004c6c:	ffffe097          	auipc	ra,0xffffe
    80004c70:	05e080e7          	jalr	94(ra) # 80002cca <iunlock>
  end_op();
    80004c74:	fffff097          	auipc	ra,0xfffff
    80004c78:	9d6080e7          	jalr	-1578(ra) # 8000364a <end_op>

  return fd;
    80004c7c:	854a                	mv	a0,s2
}
    80004c7e:	70ea                	ld	ra,184(sp)
    80004c80:	744a                	ld	s0,176(sp)
    80004c82:	74aa                	ld	s1,168(sp)
    80004c84:	790a                	ld	s2,160(sp)
    80004c86:	69ea                	ld	s3,152(sp)
    80004c88:	6129                	addi	sp,sp,192
    80004c8a:	8082                	ret
      end_op();
    80004c8c:	fffff097          	auipc	ra,0xfffff
    80004c90:	9be080e7          	jalr	-1602(ra) # 8000364a <end_op>
      return -1;
    80004c94:	557d                	li	a0,-1
    80004c96:	b7e5                	j	80004c7e <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80004c98:	f5040513          	addi	a0,s0,-176
    80004c9c:	ffffe097          	auipc	ra,0xffffe
    80004ca0:	712080e7          	jalr	1810(ra) # 800033ae <namei>
    80004ca4:	84aa                	mv	s1,a0
    80004ca6:	c905                	beqz	a0,80004cd6 <sys_open+0x13c>
    ilock(ip);
    80004ca8:	ffffe097          	auipc	ra,0xffffe
    80004cac:	f60080e7          	jalr	-160(ra) # 80002c08 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004cb0:	04449703          	lh	a4,68(s1)
    80004cb4:	4785                	li	a5,1
    80004cb6:	f4f711e3          	bne	a4,a5,80004bf8 <sys_open+0x5e>
    80004cba:	f4c42783          	lw	a5,-180(s0)
    80004cbe:	d7b9                	beqz	a5,80004c0c <sys_open+0x72>
      iunlockput(ip);
    80004cc0:	8526                	mv	a0,s1
    80004cc2:	ffffe097          	auipc	ra,0xffffe
    80004cc6:	1a8080e7          	jalr	424(ra) # 80002e6a <iunlockput>
      end_op();
    80004cca:	fffff097          	auipc	ra,0xfffff
    80004cce:	980080e7          	jalr	-1664(ra) # 8000364a <end_op>
      return -1;
    80004cd2:	557d                	li	a0,-1
    80004cd4:	b76d                	j	80004c7e <sys_open+0xe4>
      end_op();
    80004cd6:	fffff097          	auipc	ra,0xfffff
    80004cda:	974080e7          	jalr	-1676(ra) # 8000364a <end_op>
      return -1;
    80004cde:	557d                	li	a0,-1
    80004ce0:	bf79                	j	80004c7e <sys_open+0xe4>
    iunlockput(ip);
    80004ce2:	8526                	mv	a0,s1
    80004ce4:	ffffe097          	auipc	ra,0xffffe
    80004ce8:	186080e7          	jalr	390(ra) # 80002e6a <iunlockput>
    end_op();
    80004cec:	fffff097          	auipc	ra,0xfffff
    80004cf0:	95e080e7          	jalr	-1698(ra) # 8000364a <end_op>
    return -1;
    80004cf4:	557d                	li	a0,-1
    80004cf6:	b761                	j	80004c7e <sys_open+0xe4>
    f->type = FD_DEVICE;
    80004cf8:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80004cfc:	04649783          	lh	a5,70(s1)
    80004d00:	02f99223          	sh	a5,36(s3)
    80004d04:	bf25                	j	80004c3c <sys_open+0xa2>
    itrunc(ip);
    80004d06:	8526                	mv	a0,s1
    80004d08:	ffffe097          	auipc	ra,0xffffe
    80004d0c:	00e080e7          	jalr	14(ra) # 80002d16 <itrunc>
    80004d10:	bfa9                	j	80004c6a <sys_open+0xd0>
      fileclose(f);
    80004d12:	854e                	mv	a0,s3
    80004d14:	fffff097          	auipc	ra,0xfffff
    80004d18:	d82080e7          	jalr	-638(ra) # 80003a96 <fileclose>
    iunlockput(ip);
    80004d1c:	8526                	mv	a0,s1
    80004d1e:	ffffe097          	auipc	ra,0xffffe
    80004d22:	14c080e7          	jalr	332(ra) # 80002e6a <iunlockput>
    end_op();
    80004d26:	fffff097          	auipc	ra,0xfffff
    80004d2a:	924080e7          	jalr	-1756(ra) # 8000364a <end_op>
    return -1;
    80004d2e:	557d                	li	a0,-1
    80004d30:	b7b9                	j	80004c7e <sys_open+0xe4>

0000000080004d32 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80004d32:	7175                	addi	sp,sp,-144
    80004d34:	e506                	sd	ra,136(sp)
    80004d36:	e122                	sd	s0,128(sp)
    80004d38:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80004d3a:	fffff097          	auipc	ra,0xfffff
    80004d3e:	890080e7          	jalr	-1904(ra) # 800035ca <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80004d42:	08000613          	li	a2,128
    80004d46:	f7040593          	addi	a1,s0,-144
    80004d4a:	4501                	li	a0,0
    80004d4c:	ffffd097          	auipc	ra,0xffffd
    80004d50:	2b6080e7          	jalr	694(ra) # 80002002 <argstr>
    80004d54:	02054963          	bltz	a0,80004d86 <sys_mkdir+0x54>
    80004d58:	4681                	li	a3,0
    80004d5a:	4601                	li	a2,0
    80004d5c:	4585                	li	a1,1
    80004d5e:	f7040513          	addi	a0,s0,-144
    80004d62:	fffff097          	auipc	ra,0xfffff
    80004d66:	7fe080e7          	jalr	2046(ra) # 80004560 <create>
    80004d6a:	cd11                	beqz	a0,80004d86 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004d6c:	ffffe097          	auipc	ra,0xffffe
    80004d70:	0fe080e7          	jalr	254(ra) # 80002e6a <iunlockput>
  end_op();
    80004d74:	fffff097          	auipc	ra,0xfffff
    80004d78:	8d6080e7          	jalr	-1834(ra) # 8000364a <end_op>
  return 0;
    80004d7c:	4501                	li	a0,0
}
    80004d7e:	60aa                	ld	ra,136(sp)
    80004d80:	640a                	ld	s0,128(sp)
    80004d82:	6149                	addi	sp,sp,144
    80004d84:	8082                	ret
    end_op();
    80004d86:	fffff097          	auipc	ra,0xfffff
    80004d8a:	8c4080e7          	jalr	-1852(ra) # 8000364a <end_op>
    return -1;
    80004d8e:	557d                	li	a0,-1
    80004d90:	b7fd                	j	80004d7e <sys_mkdir+0x4c>

0000000080004d92 <sys_mknod>:

uint64
sys_mknod(void)
{
    80004d92:	7135                	addi	sp,sp,-160
    80004d94:	ed06                	sd	ra,152(sp)
    80004d96:	e922                	sd	s0,144(sp)
    80004d98:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80004d9a:	fffff097          	auipc	ra,0xfffff
    80004d9e:	830080e7          	jalr	-2000(ra) # 800035ca <begin_op>
  argint(1, &major);
    80004da2:	f6c40593          	addi	a1,s0,-148
    80004da6:	4505                	li	a0,1
    80004da8:	ffffd097          	auipc	ra,0xffffd
    80004dac:	21a080e7          	jalr	538(ra) # 80001fc2 <argint>
  argint(2, &minor);
    80004db0:	f6840593          	addi	a1,s0,-152
    80004db4:	4509                	li	a0,2
    80004db6:	ffffd097          	auipc	ra,0xffffd
    80004dba:	20c080e7          	jalr	524(ra) # 80001fc2 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004dbe:	08000613          	li	a2,128
    80004dc2:	f7040593          	addi	a1,s0,-144
    80004dc6:	4501                	li	a0,0
    80004dc8:	ffffd097          	auipc	ra,0xffffd
    80004dcc:	23a080e7          	jalr	570(ra) # 80002002 <argstr>
    80004dd0:	02054b63          	bltz	a0,80004e06 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80004dd4:	f6841683          	lh	a3,-152(s0)
    80004dd8:	f6c41603          	lh	a2,-148(s0)
    80004ddc:	458d                	li	a1,3
    80004dde:	f7040513          	addi	a0,s0,-144
    80004de2:	fffff097          	auipc	ra,0xfffff
    80004de6:	77e080e7          	jalr	1918(ra) # 80004560 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004dea:	cd11                	beqz	a0,80004e06 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004dec:	ffffe097          	auipc	ra,0xffffe
    80004df0:	07e080e7          	jalr	126(ra) # 80002e6a <iunlockput>
  end_op();
    80004df4:	fffff097          	auipc	ra,0xfffff
    80004df8:	856080e7          	jalr	-1962(ra) # 8000364a <end_op>
  return 0;
    80004dfc:	4501                	li	a0,0
}
    80004dfe:	60ea                	ld	ra,152(sp)
    80004e00:	644a                	ld	s0,144(sp)
    80004e02:	610d                	addi	sp,sp,160
    80004e04:	8082                	ret
    end_op();
    80004e06:	fffff097          	auipc	ra,0xfffff
    80004e0a:	844080e7          	jalr	-1980(ra) # 8000364a <end_op>
    return -1;
    80004e0e:	557d                	li	a0,-1
    80004e10:	b7fd                	j	80004dfe <sys_mknod+0x6c>

0000000080004e12 <sys_chdir>:

uint64
sys_chdir(void)
{
    80004e12:	7135                	addi	sp,sp,-160
    80004e14:	ed06                	sd	ra,152(sp)
    80004e16:	e922                	sd	s0,144(sp)
    80004e18:	e526                	sd	s1,136(sp)
    80004e1a:	e14a                	sd	s2,128(sp)
    80004e1c:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80004e1e:	ffffc097          	auipc	ra,0xffffc
    80004e22:	05e080e7          	jalr	94(ra) # 80000e7c <myproc>
    80004e26:	892a                	mv	s2,a0
  
  begin_op();
    80004e28:	ffffe097          	auipc	ra,0xffffe
    80004e2c:	7a2080e7          	jalr	1954(ra) # 800035ca <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80004e30:	08000613          	li	a2,128
    80004e34:	f6040593          	addi	a1,s0,-160
    80004e38:	4501                	li	a0,0
    80004e3a:	ffffd097          	auipc	ra,0xffffd
    80004e3e:	1c8080e7          	jalr	456(ra) # 80002002 <argstr>
    80004e42:	04054b63          	bltz	a0,80004e98 <sys_chdir+0x86>
    80004e46:	f6040513          	addi	a0,s0,-160
    80004e4a:	ffffe097          	auipc	ra,0xffffe
    80004e4e:	564080e7          	jalr	1380(ra) # 800033ae <namei>
    80004e52:	84aa                	mv	s1,a0
    80004e54:	c131                	beqz	a0,80004e98 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80004e56:	ffffe097          	auipc	ra,0xffffe
    80004e5a:	db2080e7          	jalr	-590(ra) # 80002c08 <ilock>
  if(ip->type != T_DIR){
    80004e5e:	04449703          	lh	a4,68(s1)
    80004e62:	4785                	li	a5,1
    80004e64:	04f71063          	bne	a4,a5,80004ea4 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80004e68:	8526                	mv	a0,s1
    80004e6a:	ffffe097          	auipc	ra,0xffffe
    80004e6e:	e60080e7          	jalr	-416(ra) # 80002cca <iunlock>
  iput(p->cwd);
    80004e72:	15093503          	ld	a0,336(s2)
    80004e76:	ffffe097          	auipc	ra,0xffffe
    80004e7a:	f4c080e7          	jalr	-180(ra) # 80002dc2 <iput>
  end_op();
    80004e7e:	ffffe097          	auipc	ra,0xffffe
    80004e82:	7cc080e7          	jalr	1996(ra) # 8000364a <end_op>
  p->cwd = ip;
    80004e86:	14993823          	sd	s1,336(s2)
  return 0;
    80004e8a:	4501                	li	a0,0
}
    80004e8c:	60ea                	ld	ra,152(sp)
    80004e8e:	644a                	ld	s0,144(sp)
    80004e90:	64aa                	ld	s1,136(sp)
    80004e92:	690a                	ld	s2,128(sp)
    80004e94:	610d                	addi	sp,sp,160
    80004e96:	8082                	ret
    end_op();
    80004e98:	ffffe097          	auipc	ra,0xffffe
    80004e9c:	7b2080e7          	jalr	1970(ra) # 8000364a <end_op>
    return -1;
    80004ea0:	557d                	li	a0,-1
    80004ea2:	b7ed                	j	80004e8c <sys_chdir+0x7a>
    iunlockput(ip);
    80004ea4:	8526                	mv	a0,s1
    80004ea6:	ffffe097          	auipc	ra,0xffffe
    80004eaa:	fc4080e7          	jalr	-60(ra) # 80002e6a <iunlockput>
    end_op();
    80004eae:	ffffe097          	auipc	ra,0xffffe
    80004eb2:	79c080e7          	jalr	1948(ra) # 8000364a <end_op>
    return -1;
    80004eb6:	557d                	li	a0,-1
    80004eb8:	bfd1                	j	80004e8c <sys_chdir+0x7a>

0000000080004eba <sys_exec>:

uint64
sys_exec(void)
{
    80004eba:	7145                	addi	sp,sp,-464
    80004ebc:	e786                	sd	ra,456(sp)
    80004ebe:	e3a2                	sd	s0,448(sp)
    80004ec0:	ff26                	sd	s1,440(sp)
    80004ec2:	fb4a                	sd	s2,432(sp)
    80004ec4:	f74e                	sd	s3,424(sp)
    80004ec6:	f352                	sd	s4,416(sp)
    80004ec8:	ef56                	sd	s5,408(sp)
    80004eca:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80004ecc:	e3840593          	addi	a1,s0,-456
    80004ed0:	4505                	li	a0,1
    80004ed2:	ffffd097          	auipc	ra,0xffffd
    80004ed6:	110080e7          	jalr	272(ra) # 80001fe2 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80004eda:	08000613          	li	a2,128
    80004ede:	f4040593          	addi	a1,s0,-192
    80004ee2:	4501                	li	a0,0
    80004ee4:	ffffd097          	auipc	ra,0xffffd
    80004ee8:	11e080e7          	jalr	286(ra) # 80002002 <argstr>
    80004eec:	87aa                	mv	a5,a0
    return -1;
    80004eee:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80004ef0:	0c07c263          	bltz	a5,80004fb4 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80004ef4:	10000613          	li	a2,256
    80004ef8:	4581                	li	a1,0
    80004efa:	e4040513          	addi	a0,s0,-448
    80004efe:	ffffb097          	auipc	ra,0xffffb
    80004f02:	29e080e7          	jalr	670(ra) # 8000019c <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80004f06:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80004f0a:	89a6                	mv	s3,s1
    80004f0c:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80004f0e:	02000a13          	li	s4,32
    80004f12:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80004f16:	00391513          	slli	a0,s2,0x3
    80004f1a:	e3040593          	addi	a1,s0,-464
    80004f1e:	e3843783          	ld	a5,-456(s0)
    80004f22:	953e                	add	a0,a0,a5
    80004f24:	ffffd097          	auipc	ra,0xffffd
    80004f28:	000080e7          	jalr	ra # 80001f24 <fetchaddr>
    80004f2c:	02054a63          	bltz	a0,80004f60 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80004f30:	e3043783          	ld	a5,-464(s0)
    80004f34:	c3b9                	beqz	a5,80004f7a <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80004f36:	ffffb097          	auipc	ra,0xffffb
    80004f3a:	1e2080e7          	jalr	482(ra) # 80000118 <kalloc>
    80004f3e:	85aa                	mv	a1,a0
    80004f40:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80004f44:	cd11                	beqz	a0,80004f60 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80004f46:	6605                	lui	a2,0x1
    80004f48:	e3043503          	ld	a0,-464(s0)
    80004f4c:	ffffd097          	auipc	ra,0xffffd
    80004f50:	02a080e7          	jalr	42(ra) # 80001f76 <fetchstr>
    80004f54:	00054663          	bltz	a0,80004f60 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80004f58:	0905                	addi	s2,s2,1
    80004f5a:	09a1                	addi	s3,s3,8
    80004f5c:	fb491be3          	bne	s2,s4,80004f12 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004f60:	10048913          	addi	s2,s1,256
    80004f64:	6088                	ld	a0,0(s1)
    80004f66:	c531                	beqz	a0,80004fb2 <sys_exec+0xf8>
    kfree(argv[i]);
    80004f68:	ffffb097          	auipc	ra,0xffffb
    80004f6c:	0b4080e7          	jalr	180(ra) # 8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004f70:	04a1                	addi	s1,s1,8
    80004f72:	ff2499e3          	bne	s1,s2,80004f64 <sys_exec+0xaa>
  return -1;
    80004f76:	557d                	li	a0,-1
    80004f78:	a835                	j	80004fb4 <sys_exec+0xfa>
      argv[i] = 0;
    80004f7a:	0a8e                	slli	s5,s5,0x3
    80004f7c:	fc040793          	addi	a5,s0,-64
    80004f80:	9abe                	add	s5,s5,a5
    80004f82:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80004f86:	e4040593          	addi	a1,s0,-448
    80004f8a:	f4040513          	addi	a0,s0,-192
    80004f8e:	fffff097          	auipc	ra,0xfffff
    80004f92:	190080e7          	jalr	400(ra) # 8000411e <exec>
    80004f96:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004f98:	10048993          	addi	s3,s1,256
    80004f9c:	6088                	ld	a0,0(s1)
    80004f9e:	c901                	beqz	a0,80004fae <sys_exec+0xf4>
    kfree(argv[i]);
    80004fa0:	ffffb097          	auipc	ra,0xffffb
    80004fa4:	07c080e7          	jalr	124(ra) # 8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004fa8:	04a1                	addi	s1,s1,8
    80004faa:	ff3499e3          	bne	s1,s3,80004f9c <sys_exec+0xe2>
  return ret;
    80004fae:	854a                	mv	a0,s2
    80004fb0:	a011                	j	80004fb4 <sys_exec+0xfa>
  return -1;
    80004fb2:	557d                	li	a0,-1
}
    80004fb4:	60be                	ld	ra,456(sp)
    80004fb6:	641e                	ld	s0,448(sp)
    80004fb8:	74fa                	ld	s1,440(sp)
    80004fba:	795a                	ld	s2,432(sp)
    80004fbc:	79ba                	ld	s3,424(sp)
    80004fbe:	7a1a                	ld	s4,416(sp)
    80004fc0:	6afa                	ld	s5,408(sp)
    80004fc2:	6179                	addi	sp,sp,464
    80004fc4:	8082                	ret

0000000080004fc6 <sys_pipe>:

uint64
sys_pipe(void)
{
    80004fc6:	7139                	addi	sp,sp,-64
    80004fc8:	fc06                	sd	ra,56(sp)
    80004fca:	f822                	sd	s0,48(sp)
    80004fcc:	f426                	sd	s1,40(sp)
    80004fce:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80004fd0:	ffffc097          	auipc	ra,0xffffc
    80004fd4:	eac080e7          	jalr	-340(ra) # 80000e7c <myproc>
    80004fd8:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80004fda:	fd840593          	addi	a1,s0,-40
    80004fde:	4501                	li	a0,0
    80004fe0:	ffffd097          	auipc	ra,0xffffd
    80004fe4:	002080e7          	jalr	2(ra) # 80001fe2 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80004fe8:	fc840593          	addi	a1,s0,-56
    80004fec:	fd040513          	addi	a0,s0,-48
    80004ff0:	fffff097          	auipc	ra,0xfffff
    80004ff4:	dd6080e7          	jalr	-554(ra) # 80003dc6 <pipealloc>
    return -1;
    80004ff8:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80004ffa:	0c054463          	bltz	a0,800050c2 <sys_pipe+0xfc>
  fd0 = -1;
    80004ffe:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005002:	fd043503          	ld	a0,-48(s0)
    80005006:	fffff097          	auipc	ra,0xfffff
    8000500a:	518080e7          	jalr	1304(ra) # 8000451e <fdalloc>
    8000500e:	fca42223          	sw	a0,-60(s0)
    80005012:	08054b63          	bltz	a0,800050a8 <sys_pipe+0xe2>
    80005016:	fc843503          	ld	a0,-56(s0)
    8000501a:	fffff097          	auipc	ra,0xfffff
    8000501e:	504080e7          	jalr	1284(ra) # 8000451e <fdalloc>
    80005022:	fca42023          	sw	a0,-64(s0)
    80005026:	06054863          	bltz	a0,80005096 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000502a:	4691                	li	a3,4
    8000502c:	fc440613          	addi	a2,s0,-60
    80005030:	fd843583          	ld	a1,-40(s0)
    80005034:	68a8                	ld	a0,80(s1)
    80005036:	ffffc097          	auipc	ra,0xffffc
    8000503a:	b04080e7          	jalr	-1276(ra) # 80000b3a <copyout>
    8000503e:	02054063          	bltz	a0,8000505e <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005042:	4691                	li	a3,4
    80005044:	fc040613          	addi	a2,s0,-64
    80005048:	fd843583          	ld	a1,-40(s0)
    8000504c:	0591                	addi	a1,a1,4
    8000504e:	68a8                	ld	a0,80(s1)
    80005050:	ffffc097          	auipc	ra,0xffffc
    80005054:	aea080e7          	jalr	-1302(ra) # 80000b3a <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005058:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000505a:	06055463          	bgez	a0,800050c2 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    8000505e:	fc442783          	lw	a5,-60(s0)
    80005062:	07e9                	addi	a5,a5,26
    80005064:	078e                	slli	a5,a5,0x3
    80005066:	97a6                	add	a5,a5,s1
    80005068:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000506c:	fc042503          	lw	a0,-64(s0)
    80005070:	0569                	addi	a0,a0,26
    80005072:	050e                	slli	a0,a0,0x3
    80005074:	94aa                	add	s1,s1,a0
    80005076:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000507a:	fd043503          	ld	a0,-48(s0)
    8000507e:	fffff097          	auipc	ra,0xfffff
    80005082:	a18080e7          	jalr	-1512(ra) # 80003a96 <fileclose>
    fileclose(wf);
    80005086:	fc843503          	ld	a0,-56(s0)
    8000508a:	fffff097          	auipc	ra,0xfffff
    8000508e:	a0c080e7          	jalr	-1524(ra) # 80003a96 <fileclose>
    return -1;
    80005092:	57fd                	li	a5,-1
    80005094:	a03d                	j	800050c2 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005096:	fc442783          	lw	a5,-60(s0)
    8000509a:	0007c763          	bltz	a5,800050a8 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    8000509e:	07e9                	addi	a5,a5,26
    800050a0:	078e                	slli	a5,a5,0x3
    800050a2:	94be                	add	s1,s1,a5
    800050a4:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800050a8:	fd043503          	ld	a0,-48(s0)
    800050ac:	fffff097          	auipc	ra,0xfffff
    800050b0:	9ea080e7          	jalr	-1558(ra) # 80003a96 <fileclose>
    fileclose(wf);
    800050b4:	fc843503          	ld	a0,-56(s0)
    800050b8:	fffff097          	auipc	ra,0xfffff
    800050bc:	9de080e7          	jalr	-1570(ra) # 80003a96 <fileclose>
    return -1;
    800050c0:	57fd                	li	a5,-1
}
    800050c2:	853e                	mv	a0,a5
    800050c4:	70e2                	ld	ra,56(sp)
    800050c6:	7442                	ld	s0,48(sp)
    800050c8:	74a2                	ld	s1,40(sp)
    800050ca:	6121                	addi	sp,sp,64
    800050cc:	8082                	ret
	...

00000000800050d0 <kernelvec>:
    800050d0:	7111                	addi	sp,sp,-256
    800050d2:	e006                	sd	ra,0(sp)
    800050d4:	e40a                	sd	sp,8(sp)
    800050d6:	e80e                	sd	gp,16(sp)
    800050d8:	ec12                	sd	tp,24(sp)
    800050da:	f016                	sd	t0,32(sp)
    800050dc:	f41a                	sd	t1,40(sp)
    800050de:	f81e                	sd	t2,48(sp)
    800050e0:	fc22                	sd	s0,56(sp)
    800050e2:	e0a6                	sd	s1,64(sp)
    800050e4:	e4aa                	sd	a0,72(sp)
    800050e6:	e8ae                	sd	a1,80(sp)
    800050e8:	ecb2                	sd	a2,88(sp)
    800050ea:	f0b6                	sd	a3,96(sp)
    800050ec:	f4ba                	sd	a4,104(sp)
    800050ee:	f8be                	sd	a5,112(sp)
    800050f0:	fcc2                	sd	a6,120(sp)
    800050f2:	e146                	sd	a7,128(sp)
    800050f4:	e54a                	sd	s2,136(sp)
    800050f6:	e94e                	sd	s3,144(sp)
    800050f8:	ed52                	sd	s4,152(sp)
    800050fa:	f156                	sd	s5,160(sp)
    800050fc:	f55a                	sd	s6,168(sp)
    800050fe:	f95e                	sd	s7,176(sp)
    80005100:	fd62                	sd	s8,184(sp)
    80005102:	e1e6                	sd	s9,192(sp)
    80005104:	e5ea                	sd	s10,200(sp)
    80005106:	e9ee                	sd	s11,208(sp)
    80005108:	edf2                	sd	t3,216(sp)
    8000510a:	f1f6                	sd	t4,224(sp)
    8000510c:	f5fa                	sd	t5,232(sp)
    8000510e:	f9fe                	sd	t6,240(sp)
    80005110:	ce1fc0ef          	jal	ra,80001df0 <kerneltrap>
    80005114:	6082                	ld	ra,0(sp)
    80005116:	6122                	ld	sp,8(sp)
    80005118:	61c2                	ld	gp,16(sp)
    8000511a:	7282                	ld	t0,32(sp)
    8000511c:	7322                	ld	t1,40(sp)
    8000511e:	73c2                	ld	t2,48(sp)
    80005120:	7462                	ld	s0,56(sp)
    80005122:	6486                	ld	s1,64(sp)
    80005124:	6526                	ld	a0,72(sp)
    80005126:	65c6                	ld	a1,80(sp)
    80005128:	6666                	ld	a2,88(sp)
    8000512a:	7686                	ld	a3,96(sp)
    8000512c:	7726                	ld	a4,104(sp)
    8000512e:	77c6                	ld	a5,112(sp)
    80005130:	7866                	ld	a6,120(sp)
    80005132:	688a                	ld	a7,128(sp)
    80005134:	692a                	ld	s2,136(sp)
    80005136:	69ca                	ld	s3,144(sp)
    80005138:	6a6a                	ld	s4,152(sp)
    8000513a:	7a8a                	ld	s5,160(sp)
    8000513c:	7b2a                	ld	s6,168(sp)
    8000513e:	7bca                	ld	s7,176(sp)
    80005140:	7c6a                	ld	s8,184(sp)
    80005142:	6c8e                	ld	s9,192(sp)
    80005144:	6d2e                	ld	s10,200(sp)
    80005146:	6dce                	ld	s11,208(sp)
    80005148:	6e6e                	ld	t3,216(sp)
    8000514a:	7e8e                	ld	t4,224(sp)
    8000514c:	7f2e                	ld	t5,232(sp)
    8000514e:	7fce                	ld	t6,240(sp)
    80005150:	6111                	addi	sp,sp,256
    80005152:	10200073          	sret
    80005156:	00000013          	nop
    8000515a:	00000013          	nop
    8000515e:	0001                	nop

0000000080005160 <timervec>:
    80005160:	34051573          	csrrw	a0,mscratch,a0
    80005164:	e10c                	sd	a1,0(a0)
    80005166:	e510                	sd	a2,8(a0)
    80005168:	e914                	sd	a3,16(a0)
    8000516a:	6d0c                	ld	a1,24(a0)
    8000516c:	7110                	ld	a2,32(a0)
    8000516e:	6194                	ld	a3,0(a1)
    80005170:	96b2                	add	a3,a3,a2
    80005172:	e194                	sd	a3,0(a1)
    80005174:	4589                	li	a1,2
    80005176:	14459073          	csrw	sip,a1
    8000517a:	6914                	ld	a3,16(a0)
    8000517c:	6510                	ld	a2,8(a0)
    8000517e:	610c                	ld	a1,0(a0)
    80005180:	34051573          	csrrw	a0,mscratch,a0
    80005184:	30200073          	mret
	...

000000008000518a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000518a:	1141                	addi	sp,sp,-16
    8000518c:	e422                	sd	s0,8(sp)
    8000518e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005190:	0c0007b7          	lui	a5,0xc000
    80005194:	4705                	li	a4,1
    80005196:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005198:	c3d8                	sw	a4,4(a5)
}
    8000519a:	6422                	ld	s0,8(sp)
    8000519c:	0141                	addi	sp,sp,16
    8000519e:	8082                	ret

00000000800051a0 <plicinithart>:

void
plicinithart(void)
{
    800051a0:	1141                	addi	sp,sp,-16
    800051a2:	e406                	sd	ra,8(sp)
    800051a4:	e022                	sd	s0,0(sp)
    800051a6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800051a8:	ffffc097          	auipc	ra,0xffffc
    800051ac:	ca8080e7          	jalr	-856(ra) # 80000e50 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800051b0:	0085171b          	slliw	a4,a0,0x8
    800051b4:	0c0027b7          	lui	a5,0xc002
    800051b8:	97ba                	add	a5,a5,a4
    800051ba:	40200713          	li	a4,1026
    800051be:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800051c2:	00d5151b          	slliw	a0,a0,0xd
    800051c6:	0c2017b7          	lui	a5,0xc201
    800051ca:	953e                	add	a0,a0,a5
    800051cc:	00052023          	sw	zero,0(a0)
}
    800051d0:	60a2                	ld	ra,8(sp)
    800051d2:	6402                	ld	s0,0(sp)
    800051d4:	0141                	addi	sp,sp,16
    800051d6:	8082                	ret

00000000800051d8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800051d8:	1141                	addi	sp,sp,-16
    800051da:	e406                	sd	ra,8(sp)
    800051dc:	e022                	sd	s0,0(sp)
    800051de:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800051e0:	ffffc097          	auipc	ra,0xffffc
    800051e4:	c70080e7          	jalr	-912(ra) # 80000e50 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800051e8:	00d5179b          	slliw	a5,a0,0xd
    800051ec:	0c201537          	lui	a0,0xc201
    800051f0:	953e                	add	a0,a0,a5
  return irq;
}
    800051f2:	4148                	lw	a0,4(a0)
    800051f4:	60a2                	ld	ra,8(sp)
    800051f6:	6402                	ld	s0,0(sp)
    800051f8:	0141                	addi	sp,sp,16
    800051fa:	8082                	ret

00000000800051fc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800051fc:	1101                	addi	sp,sp,-32
    800051fe:	ec06                	sd	ra,24(sp)
    80005200:	e822                	sd	s0,16(sp)
    80005202:	e426                	sd	s1,8(sp)
    80005204:	1000                	addi	s0,sp,32
    80005206:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005208:	ffffc097          	auipc	ra,0xffffc
    8000520c:	c48080e7          	jalr	-952(ra) # 80000e50 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005210:	00d5151b          	slliw	a0,a0,0xd
    80005214:	0c2017b7          	lui	a5,0xc201
    80005218:	97aa                	add	a5,a5,a0
    8000521a:	c3c4                	sw	s1,4(a5)
}
    8000521c:	60e2                	ld	ra,24(sp)
    8000521e:	6442                	ld	s0,16(sp)
    80005220:	64a2                	ld	s1,8(sp)
    80005222:	6105                	addi	sp,sp,32
    80005224:	8082                	ret

0000000080005226 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005226:	1141                	addi	sp,sp,-16
    80005228:	e406                	sd	ra,8(sp)
    8000522a:	e022                	sd	s0,0(sp)
    8000522c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000522e:	479d                	li	a5,7
    80005230:	04a7cc63          	blt	a5,a0,80005288 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005234:	00015797          	auipc	a5,0x15
    80005238:	b8c78793          	addi	a5,a5,-1140 # 80019dc0 <disk>
    8000523c:	97aa                	add	a5,a5,a0
    8000523e:	0187c783          	lbu	a5,24(a5)
    80005242:	ebb9                	bnez	a5,80005298 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005244:	00451613          	slli	a2,a0,0x4
    80005248:	00015797          	auipc	a5,0x15
    8000524c:	b7878793          	addi	a5,a5,-1160 # 80019dc0 <disk>
    80005250:	6394                	ld	a3,0(a5)
    80005252:	96b2                	add	a3,a3,a2
    80005254:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005258:	6398                	ld	a4,0(a5)
    8000525a:	9732                	add	a4,a4,a2
    8000525c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005260:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005264:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005268:	953e                	add	a0,a0,a5
    8000526a:	4785                	li	a5,1
    8000526c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80005270:	00015517          	auipc	a0,0x15
    80005274:	b6850513          	addi	a0,a0,-1176 # 80019dd8 <disk+0x18>
    80005278:	ffffc097          	auipc	ra,0xffffc
    8000527c:	314080e7          	jalr	788(ra) # 8000158c <wakeup>
}
    80005280:	60a2                	ld	ra,8(sp)
    80005282:	6402                	ld	s0,0(sp)
    80005284:	0141                	addi	sp,sp,16
    80005286:	8082                	ret
    panic("free_desc 1");
    80005288:	00003517          	auipc	a0,0x3
    8000528c:	62850513          	addi	a0,a0,1576 # 800088b0 <syscallnames+0x2f8>
    80005290:	00001097          	auipc	ra,0x1
    80005294:	a72080e7          	jalr	-1422(ra) # 80005d02 <panic>
    panic("free_desc 2");
    80005298:	00003517          	auipc	a0,0x3
    8000529c:	62850513          	addi	a0,a0,1576 # 800088c0 <syscallnames+0x308>
    800052a0:	00001097          	auipc	ra,0x1
    800052a4:	a62080e7          	jalr	-1438(ra) # 80005d02 <panic>

00000000800052a8 <virtio_disk_init>:
{
    800052a8:	1101                	addi	sp,sp,-32
    800052aa:	ec06                	sd	ra,24(sp)
    800052ac:	e822                	sd	s0,16(sp)
    800052ae:	e426                	sd	s1,8(sp)
    800052b0:	e04a                	sd	s2,0(sp)
    800052b2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800052b4:	00003597          	auipc	a1,0x3
    800052b8:	61c58593          	addi	a1,a1,1564 # 800088d0 <syscallnames+0x318>
    800052bc:	00015517          	auipc	a0,0x15
    800052c0:	c2c50513          	addi	a0,a0,-980 # 80019ee8 <disk+0x128>
    800052c4:	00001097          	auipc	ra,0x1
    800052c8:	ef8080e7          	jalr	-264(ra) # 800061bc <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800052cc:	100017b7          	lui	a5,0x10001
    800052d0:	4398                	lw	a4,0(a5)
    800052d2:	2701                	sext.w	a4,a4
    800052d4:	747277b7          	lui	a5,0x74727
    800052d8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800052dc:	14f71e63          	bne	a4,a5,80005438 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800052e0:	100017b7          	lui	a5,0x10001
    800052e4:	43dc                	lw	a5,4(a5)
    800052e6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800052e8:	4709                	li	a4,2
    800052ea:	14e79763          	bne	a5,a4,80005438 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800052ee:	100017b7          	lui	a5,0x10001
    800052f2:	479c                	lw	a5,8(a5)
    800052f4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800052f6:	14e79163          	bne	a5,a4,80005438 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800052fa:	100017b7          	lui	a5,0x10001
    800052fe:	47d8                	lw	a4,12(a5)
    80005300:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005302:	554d47b7          	lui	a5,0x554d4
    80005306:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000530a:	12f71763          	bne	a4,a5,80005438 <virtio_disk_init+0x190>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000530e:	100017b7          	lui	a5,0x10001
    80005312:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005316:	4705                	li	a4,1
    80005318:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000531a:	470d                	li	a4,3
    8000531c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000531e:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005320:	c7ffe737          	lui	a4,0xc7ffe
    80005324:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc61f>
    80005328:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000532a:	2701                	sext.w	a4,a4
    8000532c:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000532e:	472d                	li	a4,11
    80005330:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005332:	0707a903          	lw	s2,112(a5)
    80005336:	2901                	sext.w	s2,s2
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005338:	00897793          	andi	a5,s2,8
    8000533c:	10078663          	beqz	a5,80005448 <virtio_disk_init+0x1a0>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005340:	100017b7          	lui	a5,0x10001
    80005344:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005348:	43fc                	lw	a5,68(a5)
    8000534a:	2781                	sext.w	a5,a5
    8000534c:	10079663          	bnez	a5,80005458 <virtio_disk_init+0x1b0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005350:	100017b7          	lui	a5,0x10001
    80005354:	5bdc                	lw	a5,52(a5)
    80005356:	2781                	sext.w	a5,a5
  if(max == 0)
    80005358:	10078863          	beqz	a5,80005468 <virtio_disk_init+0x1c0>
  if(max < NUM)
    8000535c:	471d                	li	a4,7
    8000535e:	10f77d63          	bgeu	a4,a5,80005478 <virtio_disk_init+0x1d0>
  disk.desc = kalloc();
    80005362:	ffffb097          	auipc	ra,0xffffb
    80005366:	db6080e7          	jalr	-586(ra) # 80000118 <kalloc>
    8000536a:	00015497          	auipc	s1,0x15
    8000536e:	a5648493          	addi	s1,s1,-1450 # 80019dc0 <disk>
    80005372:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005374:	ffffb097          	auipc	ra,0xffffb
    80005378:	da4080e7          	jalr	-604(ra) # 80000118 <kalloc>
    8000537c:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000537e:	ffffb097          	auipc	ra,0xffffb
    80005382:	d9a080e7          	jalr	-614(ra) # 80000118 <kalloc>
    80005386:	87aa                	mv	a5,a0
    80005388:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    8000538a:	6088                	ld	a0,0(s1)
    8000538c:	cd75                	beqz	a0,80005488 <virtio_disk_init+0x1e0>
    8000538e:	00015717          	auipc	a4,0x15
    80005392:	a3a73703          	ld	a4,-1478(a4) # 80019dc8 <disk+0x8>
    80005396:	cb6d                	beqz	a4,80005488 <virtio_disk_init+0x1e0>
    80005398:	cbe5                	beqz	a5,80005488 <virtio_disk_init+0x1e0>
  memset(disk.desc, 0, PGSIZE);
    8000539a:	6605                	lui	a2,0x1
    8000539c:	4581                	li	a1,0
    8000539e:	ffffb097          	auipc	ra,0xffffb
    800053a2:	dfe080e7          	jalr	-514(ra) # 8000019c <memset>
  memset(disk.avail, 0, PGSIZE);
    800053a6:	00015497          	auipc	s1,0x15
    800053aa:	a1a48493          	addi	s1,s1,-1510 # 80019dc0 <disk>
    800053ae:	6605                	lui	a2,0x1
    800053b0:	4581                	li	a1,0
    800053b2:	6488                	ld	a0,8(s1)
    800053b4:	ffffb097          	auipc	ra,0xffffb
    800053b8:	de8080e7          	jalr	-536(ra) # 8000019c <memset>
  memset(disk.used, 0, PGSIZE);
    800053bc:	6605                	lui	a2,0x1
    800053be:	4581                	li	a1,0
    800053c0:	6888                	ld	a0,16(s1)
    800053c2:	ffffb097          	auipc	ra,0xffffb
    800053c6:	dda080e7          	jalr	-550(ra) # 8000019c <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800053ca:	100017b7          	lui	a5,0x10001
    800053ce:	4721                	li	a4,8
    800053d0:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800053d2:	4098                	lw	a4,0(s1)
    800053d4:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800053d8:	40d8                	lw	a4,4(s1)
    800053da:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800053de:	6498                	ld	a4,8(s1)
    800053e0:	0007069b          	sext.w	a3,a4
    800053e4:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800053e8:	9701                	srai	a4,a4,0x20
    800053ea:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800053ee:	6898                	ld	a4,16(s1)
    800053f0:	0007069b          	sext.w	a3,a4
    800053f4:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800053f8:	9701                	srai	a4,a4,0x20
    800053fa:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800053fe:	4685                	li	a3,1
    80005400:	c3f4                	sw	a3,68(a5)
    disk.free[i] = 1;
    80005402:	4705                	li	a4,1
    80005404:	00d48c23          	sb	a3,24(s1)
    80005408:	00e48ca3          	sb	a4,25(s1)
    8000540c:	00e48d23          	sb	a4,26(s1)
    80005410:	00e48da3          	sb	a4,27(s1)
    80005414:	00e48e23          	sb	a4,28(s1)
    80005418:	00e48ea3          	sb	a4,29(s1)
    8000541c:	00e48f23          	sb	a4,30(s1)
    80005420:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005424:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005428:	0727a823          	sw	s2,112(a5)
}
    8000542c:	60e2                	ld	ra,24(sp)
    8000542e:	6442                	ld	s0,16(sp)
    80005430:	64a2                	ld	s1,8(sp)
    80005432:	6902                	ld	s2,0(sp)
    80005434:	6105                	addi	sp,sp,32
    80005436:	8082                	ret
    panic("could not find virtio disk");
    80005438:	00003517          	auipc	a0,0x3
    8000543c:	4a850513          	addi	a0,a0,1192 # 800088e0 <syscallnames+0x328>
    80005440:	00001097          	auipc	ra,0x1
    80005444:	8c2080e7          	jalr	-1854(ra) # 80005d02 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005448:	00003517          	auipc	a0,0x3
    8000544c:	4b850513          	addi	a0,a0,1208 # 80008900 <syscallnames+0x348>
    80005450:	00001097          	auipc	ra,0x1
    80005454:	8b2080e7          	jalr	-1870(ra) # 80005d02 <panic>
    panic("virtio disk should not be ready");
    80005458:	00003517          	auipc	a0,0x3
    8000545c:	4c850513          	addi	a0,a0,1224 # 80008920 <syscallnames+0x368>
    80005460:	00001097          	auipc	ra,0x1
    80005464:	8a2080e7          	jalr	-1886(ra) # 80005d02 <panic>
    panic("virtio disk has no queue 0");
    80005468:	00003517          	auipc	a0,0x3
    8000546c:	4d850513          	addi	a0,a0,1240 # 80008940 <syscallnames+0x388>
    80005470:	00001097          	auipc	ra,0x1
    80005474:	892080e7          	jalr	-1902(ra) # 80005d02 <panic>
    panic("virtio disk max queue too short");
    80005478:	00003517          	auipc	a0,0x3
    8000547c:	4e850513          	addi	a0,a0,1256 # 80008960 <syscallnames+0x3a8>
    80005480:	00001097          	auipc	ra,0x1
    80005484:	882080e7          	jalr	-1918(ra) # 80005d02 <panic>
    panic("virtio disk kalloc");
    80005488:	00003517          	auipc	a0,0x3
    8000548c:	4f850513          	addi	a0,a0,1272 # 80008980 <syscallnames+0x3c8>
    80005490:	00001097          	auipc	ra,0x1
    80005494:	872080e7          	jalr	-1934(ra) # 80005d02 <panic>

0000000080005498 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005498:	7159                	addi	sp,sp,-112
    8000549a:	f486                	sd	ra,104(sp)
    8000549c:	f0a2                	sd	s0,96(sp)
    8000549e:	eca6                	sd	s1,88(sp)
    800054a0:	e8ca                	sd	s2,80(sp)
    800054a2:	e4ce                	sd	s3,72(sp)
    800054a4:	e0d2                	sd	s4,64(sp)
    800054a6:	fc56                	sd	s5,56(sp)
    800054a8:	f85a                	sd	s6,48(sp)
    800054aa:	f45e                	sd	s7,40(sp)
    800054ac:	f062                	sd	s8,32(sp)
    800054ae:	ec66                	sd	s9,24(sp)
    800054b0:	e86a                	sd	s10,16(sp)
    800054b2:	1880                	addi	s0,sp,112
    800054b4:	892a                	mv	s2,a0
    800054b6:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800054b8:	00c52c83          	lw	s9,12(a0)
    800054bc:	001c9c9b          	slliw	s9,s9,0x1
    800054c0:	1c82                	slli	s9,s9,0x20
    800054c2:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800054c6:	00015517          	auipc	a0,0x15
    800054ca:	a2250513          	addi	a0,a0,-1502 # 80019ee8 <disk+0x128>
    800054ce:	00001097          	auipc	ra,0x1
    800054d2:	d7e080e7          	jalr	-642(ra) # 8000624c <acquire>
  for(int i = 0; i < 3; i++){
    800054d6:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800054d8:	4ba1                	li	s7,8
      disk.free[i] = 0;
    800054da:	00015b17          	auipc	s6,0x15
    800054de:	8e6b0b13          	addi	s6,s6,-1818 # 80019dc0 <disk>
  for(int i = 0; i < 3; i++){
    800054e2:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    800054e4:	8a4e                	mv	s4,s3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800054e6:	00015c17          	auipc	s8,0x15
    800054ea:	a02c0c13          	addi	s8,s8,-1534 # 80019ee8 <disk+0x128>
    800054ee:	a8b5                	j	8000556a <virtio_disk_rw+0xd2>
      disk.free[i] = 0;
    800054f0:	00fb06b3          	add	a3,s6,a5
    800054f4:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    800054f8:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    800054fa:	0207c563          	bltz	a5,80005524 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    800054fe:	2485                	addiw	s1,s1,1
    80005500:	0711                	addi	a4,a4,4
    80005502:	1f548a63          	beq	s1,s5,800056f6 <virtio_disk_rw+0x25e>
    idx[i] = alloc_desc();
    80005506:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80005508:	00015697          	auipc	a3,0x15
    8000550c:	8b868693          	addi	a3,a3,-1864 # 80019dc0 <disk>
    80005510:	87d2                	mv	a5,s4
    if(disk.free[i]){
    80005512:	0186c583          	lbu	a1,24(a3)
    80005516:	fde9                	bnez	a1,800054f0 <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80005518:	2785                	addiw	a5,a5,1
    8000551a:	0685                	addi	a3,a3,1
    8000551c:	ff779be3          	bne	a5,s7,80005512 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    80005520:	57fd                	li	a5,-1
    80005522:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    80005524:	02905a63          	blez	s1,80005558 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    80005528:	f9042503          	lw	a0,-112(s0)
    8000552c:	00000097          	auipc	ra,0x0
    80005530:	cfa080e7          	jalr	-774(ra) # 80005226 <free_desc>
      for(int j = 0; j < i; j++)
    80005534:	4785                	li	a5,1
    80005536:	0297d163          	bge	a5,s1,80005558 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    8000553a:	f9442503          	lw	a0,-108(s0)
    8000553e:	00000097          	auipc	ra,0x0
    80005542:	ce8080e7          	jalr	-792(ra) # 80005226 <free_desc>
      for(int j = 0; j < i; j++)
    80005546:	4789                	li	a5,2
    80005548:	0097d863          	bge	a5,s1,80005558 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    8000554c:	f9842503          	lw	a0,-104(s0)
    80005550:	00000097          	auipc	ra,0x0
    80005554:	cd6080e7          	jalr	-810(ra) # 80005226 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005558:	85e2                	mv	a1,s8
    8000555a:	00015517          	auipc	a0,0x15
    8000555e:	87e50513          	addi	a0,a0,-1922 # 80019dd8 <disk+0x18>
    80005562:	ffffc097          	auipc	ra,0xffffc
    80005566:	fc6080e7          	jalr	-58(ra) # 80001528 <sleep>
  for(int i = 0; i < 3; i++){
    8000556a:	f9040713          	addi	a4,s0,-112
    8000556e:	84ce                	mv	s1,s3
    80005570:	bf59                	j	80005506 <virtio_disk_rw+0x6e>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80005572:	00a60793          	addi	a5,a2,10 # 100a <_entry-0x7fffeff6>
    80005576:	00479693          	slli	a3,a5,0x4
    8000557a:	00015797          	auipc	a5,0x15
    8000557e:	84678793          	addi	a5,a5,-1978 # 80019dc0 <disk>
    80005582:	97b6                	add	a5,a5,a3
    80005584:	4685                	li	a3,1
    80005586:	c794                	sw	a3,8(a5)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005588:	00015597          	auipc	a1,0x15
    8000558c:	83858593          	addi	a1,a1,-1992 # 80019dc0 <disk>
    80005590:	00a60793          	addi	a5,a2,10
    80005594:	0792                	slli	a5,a5,0x4
    80005596:	97ae                	add	a5,a5,a1
    80005598:	0007a623          	sw	zero,12(a5)
  buf0->sector = sector;
    8000559c:	0197b823          	sd	s9,16(a5)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800055a0:	f6070693          	addi	a3,a4,-160
    800055a4:	619c                	ld	a5,0(a1)
    800055a6:	97b6                	add	a5,a5,a3
    800055a8:	e388                	sd	a0,0(a5)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800055aa:	6188                	ld	a0,0(a1)
    800055ac:	96aa                	add	a3,a3,a0
    800055ae:	47c1                	li	a5,16
    800055b0:	c69c                	sw	a5,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800055b2:	4785                	li	a5,1
    800055b4:	00f69623          	sh	a5,12(a3)
  disk.desc[idx[0]].next = idx[1];
    800055b8:	f9442783          	lw	a5,-108(s0)
    800055bc:	00f69723          	sh	a5,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800055c0:	0792                	slli	a5,a5,0x4
    800055c2:	953e                	add	a0,a0,a5
    800055c4:	05890693          	addi	a3,s2,88
    800055c8:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    800055ca:	6188                	ld	a0,0(a1)
    800055cc:	97aa                	add	a5,a5,a0
    800055ce:	40000693          	li	a3,1024
    800055d2:	c794                	sw	a3,8(a5)
  if(write)
    800055d4:	100d0d63          	beqz	s10,800056ee <virtio_disk_rw+0x256>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800055d8:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800055dc:	00c7d683          	lhu	a3,12(a5)
    800055e0:	0016e693          	ori	a3,a3,1
    800055e4:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[1]].next = idx[2];
    800055e8:	f9842583          	lw	a1,-104(s0)
    800055ec:	00b79723          	sh	a1,14(a5)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800055f0:	00014697          	auipc	a3,0x14
    800055f4:	7d068693          	addi	a3,a3,2000 # 80019dc0 <disk>
    800055f8:	00260793          	addi	a5,a2,2
    800055fc:	0792                	slli	a5,a5,0x4
    800055fe:	97b6                	add	a5,a5,a3
    80005600:	587d                	li	a6,-1
    80005602:	01078823          	sb	a6,16(a5)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005606:	0592                	slli	a1,a1,0x4
    80005608:	952e                	add	a0,a0,a1
    8000560a:	f9070713          	addi	a4,a4,-112
    8000560e:	9736                	add	a4,a4,a3
    80005610:	e118                	sd	a4,0(a0)
  disk.desc[idx[2]].len = 1;
    80005612:	6298                	ld	a4,0(a3)
    80005614:	972e                	add	a4,a4,a1
    80005616:	4585                	li	a1,1
    80005618:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000561a:	4509                	li	a0,2
    8000561c:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[2]].next = 0;
    80005620:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005624:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    80005628:	0127b423          	sd	s2,8(a5)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    8000562c:	6698                	ld	a4,8(a3)
    8000562e:	00275783          	lhu	a5,2(a4)
    80005632:	8b9d                	andi	a5,a5,7
    80005634:	0786                	slli	a5,a5,0x1
    80005636:	97ba                	add	a5,a5,a4
    80005638:	00c79223          	sh	a2,4(a5)

  __sync_synchronize();
    8000563c:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005640:	6698                	ld	a4,8(a3)
    80005642:	00275783          	lhu	a5,2(a4)
    80005646:	2785                	addiw	a5,a5,1
    80005648:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000564c:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005650:	100017b7          	lui	a5,0x10001
    80005654:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005658:	00492703          	lw	a4,4(s2)
    8000565c:	4785                	li	a5,1
    8000565e:	02f71163          	bne	a4,a5,80005680 <virtio_disk_rw+0x1e8>
    sleep(b, &disk.vdisk_lock);
    80005662:	00015997          	auipc	s3,0x15
    80005666:	88698993          	addi	s3,s3,-1914 # 80019ee8 <disk+0x128>
  while(b->disk == 1) {
    8000566a:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    8000566c:	85ce                	mv	a1,s3
    8000566e:	854a                	mv	a0,s2
    80005670:	ffffc097          	auipc	ra,0xffffc
    80005674:	eb8080e7          	jalr	-328(ra) # 80001528 <sleep>
  while(b->disk == 1) {
    80005678:	00492783          	lw	a5,4(s2)
    8000567c:	fe9788e3          	beq	a5,s1,8000566c <virtio_disk_rw+0x1d4>
  }

  disk.info[idx[0]].b = 0;
    80005680:	f9042903          	lw	s2,-112(s0)
    80005684:	00290793          	addi	a5,s2,2
    80005688:	00479713          	slli	a4,a5,0x4
    8000568c:	00014797          	auipc	a5,0x14
    80005690:	73478793          	addi	a5,a5,1844 # 80019dc0 <disk>
    80005694:	97ba                	add	a5,a5,a4
    80005696:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000569a:	00014997          	auipc	s3,0x14
    8000569e:	72698993          	addi	s3,s3,1830 # 80019dc0 <disk>
    800056a2:	00491713          	slli	a4,s2,0x4
    800056a6:	0009b783          	ld	a5,0(s3)
    800056aa:	97ba                	add	a5,a5,a4
    800056ac:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800056b0:	854a                	mv	a0,s2
    800056b2:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800056b6:	00000097          	auipc	ra,0x0
    800056ba:	b70080e7          	jalr	-1168(ra) # 80005226 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800056be:	8885                	andi	s1,s1,1
    800056c0:	f0ed                	bnez	s1,800056a2 <virtio_disk_rw+0x20a>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800056c2:	00015517          	auipc	a0,0x15
    800056c6:	82650513          	addi	a0,a0,-2010 # 80019ee8 <disk+0x128>
    800056ca:	00001097          	auipc	ra,0x1
    800056ce:	c36080e7          	jalr	-970(ra) # 80006300 <release>
}
    800056d2:	70a6                	ld	ra,104(sp)
    800056d4:	7406                	ld	s0,96(sp)
    800056d6:	64e6                	ld	s1,88(sp)
    800056d8:	6946                	ld	s2,80(sp)
    800056da:	69a6                	ld	s3,72(sp)
    800056dc:	6a06                	ld	s4,64(sp)
    800056de:	7ae2                	ld	s5,56(sp)
    800056e0:	7b42                	ld	s6,48(sp)
    800056e2:	7ba2                	ld	s7,40(sp)
    800056e4:	7c02                	ld	s8,32(sp)
    800056e6:	6ce2                	ld	s9,24(sp)
    800056e8:	6d42                	ld	s10,16(sp)
    800056ea:	6165                	addi	sp,sp,112
    800056ec:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800056ee:	4689                	li	a3,2
    800056f0:	00d79623          	sh	a3,12(a5)
    800056f4:	b5e5                	j	800055dc <virtio_disk_rw+0x144>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800056f6:	f9042603          	lw	a2,-112(s0)
    800056fa:	00a60713          	addi	a4,a2,10
    800056fe:	0712                	slli	a4,a4,0x4
    80005700:	00014517          	auipc	a0,0x14
    80005704:	6c850513          	addi	a0,a0,1736 # 80019dc8 <disk+0x8>
    80005708:	953a                	add	a0,a0,a4
  if(write)
    8000570a:	e60d14e3          	bnez	s10,80005572 <virtio_disk_rw+0xda>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    8000570e:	00a60793          	addi	a5,a2,10
    80005712:	00479693          	slli	a3,a5,0x4
    80005716:	00014797          	auipc	a5,0x14
    8000571a:	6aa78793          	addi	a5,a5,1706 # 80019dc0 <disk>
    8000571e:	97b6                	add	a5,a5,a3
    80005720:	0007a423          	sw	zero,8(a5)
    80005724:	b595                	j	80005588 <virtio_disk_rw+0xf0>

0000000080005726 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005726:	1101                	addi	sp,sp,-32
    80005728:	ec06                	sd	ra,24(sp)
    8000572a:	e822                	sd	s0,16(sp)
    8000572c:	e426                	sd	s1,8(sp)
    8000572e:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005730:	00014497          	auipc	s1,0x14
    80005734:	69048493          	addi	s1,s1,1680 # 80019dc0 <disk>
    80005738:	00014517          	auipc	a0,0x14
    8000573c:	7b050513          	addi	a0,a0,1968 # 80019ee8 <disk+0x128>
    80005740:	00001097          	auipc	ra,0x1
    80005744:	b0c080e7          	jalr	-1268(ra) # 8000624c <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005748:	10001737          	lui	a4,0x10001
    8000574c:	533c                	lw	a5,96(a4)
    8000574e:	8b8d                	andi	a5,a5,3
    80005750:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80005752:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005756:	689c                	ld	a5,16(s1)
    80005758:	0204d703          	lhu	a4,32(s1)
    8000575c:	0027d783          	lhu	a5,2(a5)
    80005760:	04f70863          	beq	a4,a5,800057b0 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80005764:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005768:	6898                	ld	a4,16(s1)
    8000576a:	0204d783          	lhu	a5,32(s1)
    8000576e:	8b9d                	andi	a5,a5,7
    80005770:	078e                	slli	a5,a5,0x3
    80005772:	97ba                	add	a5,a5,a4
    80005774:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005776:	00278713          	addi	a4,a5,2
    8000577a:	0712                	slli	a4,a4,0x4
    8000577c:	9726                	add	a4,a4,s1
    8000577e:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80005782:	e721                	bnez	a4,800057ca <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005784:	0789                	addi	a5,a5,2
    80005786:	0792                	slli	a5,a5,0x4
    80005788:	97a6                	add	a5,a5,s1
    8000578a:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000578c:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005790:	ffffc097          	auipc	ra,0xffffc
    80005794:	dfc080e7          	jalr	-516(ra) # 8000158c <wakeup>

    disk.used_idx += 1;
    80005798:	0204d783          	lhu	a5,32(s1)
    8000579c:	2785                	addiw	a5,a5,1
    8000579e:	17c2                	slli	a5,a5,0x30
    800057a0:	93c1                	srli	a5,a5,0x30
    800057a2:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800057a6:	6898                	ld	a4,16(s1)
    800057a8:	00275703          	lhu	a4,2(a4)
    800057ac:	faf71ce3          	bne	a4,a5,80005764 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800057b0:	00014517          	auipc	a0,0x14
    800057b4:	73850513          	addi	a0,a0,1848 # 80019ee8 <disk+0x128>
    800057b8:	00001097          	auipc	ra,0x1
    800057bc:	b48080e7          	jalr	-1208(ra) # 80006300 <release>
}
    800057c0:	60e2                	ld	ra,24(sp)
    800057c2:	6442                	ld	s0,16(sp)
    800057c4:	64a2                	ld	s1,8(sp)
    800057c6:	6105                	addi	sp,sp,32
    800057c8:	8082                	ret
      panic("virtio_disk_intr status");
    800057ca:	00003517          	auipc	a0,0x3
    800057ce:	1ce50513          	addi	a0,a0,462 # 80008998 <syscallnames+0x3e0>
    800057d2:	00000097          	auipc	ra,0x0
    800057d6:	530080e7          	jalr	1328(ra) # 80005d02 <panic>

00000000800057da <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    800057da:	1141                	addi	sp,sp,-16
    800057dc:	e422                	sd	s0,8(sp)
    800057de:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800057e0:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    800057e4:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    800057e8:	0037979b          	slliw	a5,a5,0x3
    800057ec:	02004737          	lui	a4,0x2004
    800057f0:	97ba                	add	a5,a5,a4
    800057f2:	0200c737          	lui	a4,0x200c
    800057f6:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    800057fa:	000f4637          	lui	a2,0xf4
    800057fe:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80005802:	95b2                	add	a1,a1,a2
    80005804:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80005806:	00269713          	slli	a4,a3,0x2
    8000580a:	9736                	add	a4,a4,a3
    8000580c:	00371693          	slli	a3,a4,0x3
    80005810:	00014717          	auipc	a4,0x14
    80005814:	6f070713          	addi	a4,a4,1776 # 80019f00 <timer_scratch>
    80005818:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000581a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000581c:	f310                	sd	a2,32(a4)
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000581e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80005822:	00000797          	auipc	a5,0x0
    80005826:	93e78793          	addi	a5,a5,-1730 # 80005160 <timervec>
    8000582a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000582e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80005832:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80005836:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000583a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000583e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80005842:	30479073          	csrw	mie,a5
}
    80005846:	6422                	ld	s0,8(sp)
    80005848:	0141                	addi	sp,sp,16
    8000584a:	8082                	ret

000000008000584c <start>:
{
    8000584c:	1141                	addi	sp,sp,-16
    8000584e:	e406                	sd	ra,8(sp)
    80005850:	e022                	sd	s0,0(sp)
    80005852:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80005854:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80005858:	7779                	lui	a4,0xffffe
    8000585a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc6bf>
    8000585e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80005860:	6705                	lui	a4,0x1
    80005862:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80005866:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80005868:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    8000586c:	ffffb797          	auipc	a5,0xffffb
    80005870:	ade78793          	addi	a5,a5,-1314 # 8000034a <main>
    80005874:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80005878:	4781                	li	a5,0
    8000587a:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    8000587e:	67c1                	lui	a5,0x10
    80005880:	17fd                	addi	a5,a5,-1
    80005882:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    80005886:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000588a:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    8000588e:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80005892:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    80005896:	57fd                	li	a5,-1
    80005898:	83a9                	srli	a5,a5,0xa
    8000589a:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    8000589e:	47bd                	li	a5,15
    800058a0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800058a4:	00000097          	auipc	ra,0x0
    800058a8:	f36080e7          	jalr	-202(ra) # 800057da <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800058ac:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800058b0:	2781                	sext.w	a5,a5
  asm volatile("mv tp, %0" : : "r" (x));
    800058b2:	823e                	mv	tp,a5
  asm volatile("mret");
    800058b4:	30200073          	mret
}
    800058b8:	60a2                	ld	ra,8(sp)
    800058ba:	6402                	ld	s0,0(sp)
    800058bc:	0141                	addi	sp,sp,16
    800058be:	8082                	ret

00000000800058c0 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800058c0:	715d                	addi	sp,sp,-80
    800058c2:	e486                	sd	ra,72(sp)
    800058c4:	e0a2                	sd	s0,64(sp)
    800058c6:	fc26                	sd	s1,56(sp)
    800058c8:	f84a                	sd	s2,48(sp)
    800058ca:	f44e                	sd	s3,40(sp)
    800058cc:	f052                	sd	s4,32(sp)
    800058ce:	ec56                	sd	s5,24(sp)
    800058d0:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    800058d2:	04c05663          	blez	a2,8000591e <consolewrite+0x5e>
    800058d6:	8a2a                	mv	s4,a0
    800058d8:	84ae                	mv	s1,a1
    800058da:	89b2                	mv	s3,a2
    800058dc:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    800058de:	5afd                	li	s5,-1
    800058e0:	4685                	li	a3,1
    800058e2:	8626                	mv	a2,s1
    800058e4:	85d2                	mv	a1,s4
    800058e6:	fbf40513          	addi	a0,s0,-65
    800058ea:	ffffc097          	auipc	ra,0xffffc
    800058ee:	09c080e7          	jalr	156(ra) # 80001986 <either_copyin>
    800058f2:	01550c63          	beq	a0,s5,8000590a <consolewrite+0x4a>
      break;
    uartputc(c);
    800058f6:	fbf44503          	lbu	a0,-65(s0)
    800058fa:	00000097          	auipc	ra,0x0
    800058fe:	794080e7          	jalr	1940(ra) # 8000608e <uartputc>
  for(i = 0; i < n; i++){
    80005902:	2905                	addiw	s2,s2,1
    80005904:	0485                	addi	s1,s1,1
    80005906:	fd299de3          	bne	s3,s2,800058e0 <consolewrite+0x20>
  }

  return i;
}
    8000590a:	854a                	mv	a0,s2
    8000590c:	60a6                	ld	ra,72(sp)
    8000590e:	6406                	ld	s0,64(sp)
    80005910:	74e2                	ld	s1,56(sp)
    80005912:	7942                	ld	s2,48(sp)
    80005914:	79a2                	ld	s3,40(sp)
    80005916:	7a02                	ld	s4,32(sp)
    80005918:	6ae2                	ld	s5,24(sp)
    8000591a:	6161                	addi	sp,sp,80
    8000591c:	8082                	ret
  for(i = 0; i < n; i++){
    8000591e:	4901                	li	s2,0
    80005920:	b7ed                	j	8000590a <consolewrite+0x4a>

0000000080005922 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80005922:	7119                	addi	sp,sp,-128
    80005924:	fc86                	sd	ra,120(sp)
    80005926:	f8a2                	sd	s0,112(sp)
    80005928:	f4a6                	sd	s1,104(sp)
    8000592a:	f0ca                	sd	s2,96(sp)
    8000592c:	ecce                	sd	s3,88(sp)
    8000592e:	e8d2                	sd	s4,80(sp)
    80005930:	e4d6                	sd	s5,72(sp)
    80005932:	e0da                	sd	s6,64(sp)
    80005934:	fc5e                	sd	s7,56(sp)
    80005936:	f862                	sd	s8,48(sp)
    80005938:	f466                	sd	s9,40(sp)
    8000593a:	f06a                	sd	s10,32(sp)
    8000593c:	ec6e                	sd	s11,24(sp)
    8000593e:	0100                	addi	s0,sp,128
    80005940:	8b2a                	mv	s6,a0
    80005942:	8aae                	mv	s5,a1
    80005944:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80005946:	00060b9b          	sext.w	s7,a2
  acquire(&cons.lock);
    8000594a:	0001c517          	auipc	a0,0x1c
    8000594e:	6f650513          	addi	a0,a0,1782 # 80022040 <cons>
    80005952:	00001097          	auipc	ra,0x1
    80005956:	8fa080e7          	jalr	-1798(ra) # 8000624c <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000595a:	0001c497          	auipc	s1,0x1c
    8000595e:	6e648493          	addi	s1,s1,1766 # 80022040 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80005962:	89a6                	mv	s3,s1
    80005964:	0001c917          	auipc	s2,0x1c
    80005968:	77490913          	addi	s2,s2,1908 # 800220d8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    8000596c:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000596e:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    80005970:	4da9                	li	s11,10
  while(n > 0){
    80005972:	07405b63          	blez	s4,800059e8 <consoleread+0xc6>
    while(cons.r == cons.w){
    80005976:	0984a783          	lw	a5,152(s1)
    8000597a:	09c4a703          	lw	a4,156(s1)
    8000597e:	02f71763          	bne	a4,a5,800059ac <consoleread+0x8a>
      if(killed(myproc())){
    80005982:	ffffb097          	auipc	ra,0xffffb
    80005986:	4fa080e7          	jalr	1274(ra) # 80000e7c <myproc>
    8000598a:	ffffc097          	auipc	ra,0xffffc
    8000598e:	e46080e7          	jalr	-442(ra) # 800017d0 <killed>
    80005992:	e535                	bnez	a0,800059fe <consoleread+0xdc>
      sleep(&cons.r, &cons.lock);
    80005994:	85ce                	mv	a1,s3
    80005996:	854a                	mv	a0,s2
    80005998:	ffffc097          	auipc	ra,0xffffc
    8000599c:	b90080e7          	jalr	-1136(ra) # 80001528 <sleep>
    while(cons.r == cons.w){
    800059a0:	0984a783          	lw	a5,152(s1)
    800059a4:	09c4a703          	lw	a4,156(s1)
    800059a8:	fcf70de3          	beq	a4,a5,80005982 <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800059ac:	0017871b          	addiw	a4,a5,1
    800059b0:	08e4ac23          	sw	a4,152(s1)
    800059b4:	07f7f713          	andi	a4,a5,127
    800059b8:	9726                	add	a4,a4,s1
    800059ba:	01874703          	lbu	a4,24(a4)
    800059be:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    800059c2:	079c0663          	beq	s8,s9,80005a2e <consoleread+0x10c>
    cbuf = c;
    800059c6:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800059ca:	4685                	li	a3,1
    800059cc:	f8f40613          	addi	a2,s0,-113
    800059d0:	85d6                	mv	a1,s5
    800059d2:	855a                	mv	a0,s6
    800059d4:	ffffc097          	auipc	ra,0xffffc
    800059d8:	f5c080e7          	jalr	-164(ra) # 80001930 <either_copyout>
    800059dc:	01a50663          	beq	a0,s10,800059e8 <consoleread+0xc6>
    dst++;
    800059e0:	0a85                	addi	s5,s5,1
    --n;
    800059e2:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    800059e4:	f9bc17e3          	bne	s8,s11,80005972 <consoleread+0x50>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    800059e8:	0001c517          	auipc	a0,0x1c
    800059ec:	65850513          	addi	a0,a0,1624 # 80022040 <cons>
    800059f0:	00001097          	auipc	ra,0x1
    800059f4:	910080e7          	jalr	-1776(ra) # 80006300 <release>

  return target - n;
    800059f8:	414b853b          	subw	a0,s7,s4
    800059fc:	a811                	j	80005a10 <consoleread+0xee>
        release(&cons.lock);
    800059fe:	0001c517          	auipc	a0,0x1c
    80005a02:	64250513          	addi	a0,a0,1602 # 80022040 <cons>
    80005a06:	00001097          	auipc	ra,0x1
    80005a0a:	8fa080e7          	jalr	-1798(ra) # 80006300 <release>
        return -1;
    80005a0e:	557d                	li	a0,-1
}
    80005a10:	70e6                	ld	ra,120(sp)
    80005a12:	7446                	ld	s0,112(sp)
    80005a14:	74a6                	ld	s1,104(sp)
    80005a16:	7906                	ld	s2,96(sp)
    80005a18:	69e6                	ld	s3,88(sp)
    80005a1a:	6a46                	ld	s4,80(sp)
    80005a1c:	6aa6                	ld	s5,72(sp)
    80005a1e:	6b06                	ld	s6,64(sp)
    80005a20:	7be2                	ld	s7,56(sp)
    80005a22:	7c42                	ld	s8,48(sp)
    80005a24:	7ca2                	ld	s9,40(sp)
    80005a26:	7d02                	ld	s10,32(sp)
    80005a28:	6de2                	ld	s11,24(sp)
    80005a2a:	6109                	addi	sp,sp,128
    80005a2c:	8082                	ret
      if(n < target){
    80005a2e:	000a071b          	sext.w	a4,s4
    80005a32:	fb777be3          	bgeu	a4,s7,800059e8 <consoleread+0xc6>
        cons.r--;
    80005a36:	0001c717          	auipc	a4,0x1c
    80005a3a:	6af72123          	sw	a5,1698(a4) # 800220d8 <cons+0x98>
    80005a3e:	b76d                	j	800059e8 <consoleread+0xc6>

0000000080005a40 <consputc>:
{
    80005a40:	1141                	addi	sp,sp,-16
    80005a42:	e406                	sd	ra,8(sp)
    80005a44:	e022                	sd	s0,0(sp)
    80005a46:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80005a48:	10000793          	li	a5,256
    80005a4c:	00f50a63          	beq	a0,a5,80005a60 <consputc+0x20>
    uartputc_sync(c);
    80005a50:	00000097          	auipc	ra,0x0
    80005a54:	564080e7          	jalr	1380(ra) # 80005fb4 <uartputc_sync>
}
    80005a58:	60a2                	ld	ra,8(sp)
    80005a5a:	6402                	ld	s0,0(sp)
    80005a5c:	0141                	addi	sp,sp,16
    80005a5e:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80005a60:	4521                	li	a0,8
    80005a62:	00000097          	auipc	ra,0x0
    80005a66:	552080e7          	jalr	1362(ra) # 80005fb4 <uartputc_sync>
    80005a6a:	02000513          	li	a0,32
    80005a6e:	00000097          	auipc	ra,0x0
    80005a72:	546080e7          	jalr	1350(ra) # 80005fb4 <uartputc_sync>
    80005a76:	4521                	li	a0,8
    80005a78:	00000097          	auipc	ra,0x0
    80005a7c:	53c080e7          	jalr	1340(ra) # 80005fb4 <uartputc_sync>
    80005a80:	bfe1                	j	80005a58 <consputc+0x18>

0000000080005a82 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80005a82:	1101                	addi	sp,sp,-32
    80005a84:	ec06                	sd	ra,24(sp)
    80005a86:	e822                	sd	s0,16(sp)
    80005a88:	e426                	sd	s1,8(sp)
    80005a8a:	e04a                	sd	s2,0(sp)
    80005a8c:	1000                	addi	s0,sp,32
    80005a8e:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    80005a90:	0001c517          	auipc	a0,0x1c
    80005a94:	5b050513          	addi	a0,a0,1456 # 80022040 <cons>
    80005a98:	00000097          	auipc	ra,0x0
    80005a9c:	7b4080e7          	jalr	1972(ra) # 8000624c <acquire>

  switch(c){
    80005aa0:	47d5                	li	a5,21
    80005aa2:	0af48663          	beq	s1,a5,80005b4e <consoleintr+0xcc>
    80005aa6:	0297ca63          	blt	a5,s1,80005ada <consoleintr+0x58>
    80005aaa:	47a1                	li	a5,8
    80005aac:	0ef48763          	beq	s1,a5,80005b9a <consoleintr+0x118>
    80005ab0:	47c1                	li	a5,16
    80005ab2:	10f49a63          	bne	s1,a5,80005bc6 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    80005ab6:	ffffc097          	auipc	ra,0xffffc
    80005aba:	f26080e7          	jalr	-218(ra) # 800019dc <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80005abe:	0001c517          	auipc	a0,0x1c
    80005ac2:	58250513          	addi	a0,a0,1410 # 80022040 <cons>
    80005ac6:	00001097          	auipc	ra,0x1
    80005aca:	83a080e7          	jalr	-1990(ra) # 80006300 <release>
}
    80005ace:	60e2                	ld	ra,24(sp)
    80005ad0:	6442                	ld	s0,16(sp)
    80005ad2:	64a2                	ld	s1,8(sp)
    80005ad4:	6902                	ld	s2,0(sp)
    80005ad6:	6105                	addi	sp,sp,32
    80005ad8:	8082                	ret
  switch(c){
    80005ada:	07f00793          	li	a5,127
    80005ade:	0af48e63          	beq	s1,a5,80005b9a <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80005ae2:	0001c717          	auipc	a4,0x1c
    80005ae6:	55e70713          	addi	a4,a4,1374 # 80022040 <cons>
    80005aea:	0a072783          	lw	a5,160(a4)
    80005aee:	09872703          	lw	a4,152(a4)
    80005af2:	9f99                	subw	a5,a5,a4
    80005af4:	07f00713          	li	a4,127
    80005af8:	fcf763e3          	bltu	a4,a5,80005abe <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80005afc:	47b5                	li	a5,13
    80005afe:	0cf48763          	beq	s1,a5,80005bcc <consoleintr+0x14a>
      consputc(c);
    80005b02:	8526                	mv	a0,s1
    80005b04:	00000097          	auipc	ra,0x0
    80005b08:	f3c080e7          	jalr	-196(ra) # 80005a40 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80005b0c:	0001c797          	auipc	a5,0x1c
    80005b10:	53478793          	addi	a5,a5,1332 # 80022040 <cons>
    80005b14:	0a07a683          	lw	a3,160(a5)
    80005b18:	0016871b          	addiw	a4,a3,1
    80005b1c:	0007061b          	sext.w	a2,a4
    80005b20:	0ae7a023          	sw	a4,160(a5)
    80005b24:	07f6f693          	andi	a3,a3,127
    80005b28:	97b6                	add	a5,a5,a3
    80005b2a:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80005b2e:	47a9                	li	a5,10
    80005b30:	0cf48563          	beq	s1,a5,80005bfa <consoleintr+0x178>
    80005b34:	4791                	li	a5,4
    80005b36:	0cf48263          	beq	s1,a5,80005bfa <consoleintr+0x178>
    80005b3a:	0001c797          	auipc	a5,0x1c
    80005b3e:	59e7a783          	lw	a5,1438(a5) # 800220d8 <cons+0x98>
    80005b42:	9f1d                	subw	a4,a4,a5
    80005b44:	08000793          	li	a5,128
    80005b48:	f6f71be3          	bne	a4,a5,80005abe <consoleintr+0x3c>
    80005b4c:	a07d                	j	80005bfa <consoleintr+0x178>
    while(cons.e != cons.w &&
    80005b4e:	0001c717          	auipc	a4,0x1c
    80005b52:	4f270713          	addi	a4,a4,1266 # 80022040 <cons>
    80005b56:	0a072783          	lw	a5,160(a4)
    80005b5a:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80005b5e:	0001c497          	auipc	s1,0x1c
    80005b62:	4e248493          	addi	s1,s1,1250 # 80022040 <cons>
    while(cons.e != cons.w &&
    80005b66:	4929                	li	s2,10
    80005b68:	f4f70be3          	beq	a4,a5,80005abe <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80005b6c:	37fd                	addiw	a5,a5,-1
    80005b6e:	07f7f713          	andi	a4,a5,127
    80005b72:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80005b74:	01874703          	lbu	a4,24(a4)
    80005b78:	f52703e3          	beq	a4,s2,80005abe <consoleintr+0x3c>
      cons.e--;
    80005b7c:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80005b80:	10000513          	li	a0,256
    80005b84:	00000097          	auipc	ra,0x0
    80005b88:	ebc080e7          	jalr	-324(ra) # 80005a40 <consputc>
    while(cons.e != cons.w &&
    80005b8c:	0a04a783          	lw	a5,160(s1)
    80005b90:	09c4a703          	lw	a4,156(s1)
    80005b94:	fcf71ce3          	bne	a4,a5,80005b6c <consoleintr+0xea>
    80005b98:	b71d                	j	80005abe <consoleintr+0x3c>
    if(cons.e != cons.w){
    80005b9a:	0001c717          	auipc	a4,0x1c
    80005b9e:	4a670713          	addi	a4,a4,1190 # 80022040 <cons>
    80005ba2:	0a072783          	lw	a5,160(a4)
    80005ba6:	09c72703          	lw	a4,156(a4)
    80005baa:	f0f70ae3          	beq	a4,a5,80005abe <consoleintr+0x3c>
      cons.e--;
    80005bae:	37fd                	addiw	a5,a5,-1
    80005bb0:	0001c717          	auipc	a4,0x1c
    80005bb4:	52f72823          	sw	a5,1328(a4) # 800220e0 <cons+0xa0>
      consputc(BACKSPACE);
    80005bb8:	10000513          	li	a0,256
    80005bbc:	00000097          	auipc	ra,0x0
    80005bc0:	e84080e7          	jalr	-380(ra) # 80005a40 <consputc>
    80005bc4:	bded                	j	80005abe <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80005bc6:	ee048ce3          	beqz	s1,80005abe <consoleintr+0x3c>
    80005bca:	bf21                	j	80005ae2 <consoleintr+0x60>
      consputc(c);
    80005bcc:	4529                	li	a0,10
    80005bce:	00000097          	auipc	ra,0x0
    80005bd2:	e72080e7          	jalr	-398(ra) # 80005a40 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80005bd6:	0001c797          	auipc	a5,0x1c
    80005bda:	46a78793          	addi	a5,a5,1130 # 80022040 <cons>
    80005bde:	0a07a703          	lw	a4,160(a5)
    80005be2:	0017069b          	addiw	a3,a4,1
    80005be6:	0006861b          	sext.w	a2,a3
    80005bea:	0ad7a023          	sw	a3,160(a5)
    80005bee:	07f77713          	andi	a4,a4,127
    80005bf2:	97ba                	add	a5,a5,a4
    80005bf4:	4729                	li	a4,10
    80005bf6:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80005bfa:	0001c797          	auipc	a5,0x1c
    80005bfe:	4ec7a123          	sw	a2,1250(a5) # 800220dc <cons+0x9c>
        wakeup(&cons.r);
    80005c02:	0001c517          	auipc	a0,0x1c
    80005c06:	4d650513          	addi	a0,a0,1238 # 800220d8 <cons+0x98>
    80005c0a:	ffffc097          	auipc	ra,0xffffc
    80005c0e:	982080e7          	jalr	-1662(ra) # 8000158c <wakeup>
    80005c12:	b575                	j	80005abe <consoleintr+0x3c>

0000000080005c14 <consoleinit>:

void
consoleinit(void)
{
    80005c14:	1141                	addi	sp,sp,-16
    80005c16:	e406                	sd	ra,8(sp)
    80005c18:	e022                	sd	s0,0(sp)
    80005c1a:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80005c1c:	00003597          	auipc	a1,0x3
    80005c20:	d9458593          	addi	a1,a1,-620 # 800089b0 <syscallnames+0x3f8>
    80005c24:	0001c517          	auipc	a0,0x1c
    80005c28:	41c50513          	addi	a0,a0,1052 # 80022040 <cons>
    80005c2c:	00000097          	auipc	ra,0x0
    80005c30:	590080e7          	jalr	1424(ra) # 800061bc <initlock>

  uartinit();
    80005c34:	00000097          	auipc	ra,0x0
    80005c38:	330080e7          	jalr	816(ra) # 80005f64 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80005c3c:	00013797          	auipc	a5,0x13
    80005c40:	12c78793          	addi	a5,a5,300 # 80018d68 <devsw>
    80005c44:	00000717          	auipc	a4,0x0
    80005c48:	cde70713          	addi	a4,a4,-802 # 80005922 <consoleread>
    80005c4c:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80005c4e:	00000717          	auipc	a4,0x0
    80005c52:	c7270713          	addi	a4,a4,-910 # 800058c0 <consolewrite>
    80005c56:	ef98                	sd	a4,24(a5)
}
    80005c58:	60a2                	ld	ra,8(sp)
    80005c5a:	6402                	ld	s0,0(sp)
    80005c5c:	0141                	addi	sp,sp,16
    80005c5e:	8082                	ret

0000000080005c60 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80005c60:	7179                	addi	sp,sp,-48
    80005c62:	f406                	sd	ra,40(sp)
    80005c64:	f022                	sd	s0,32(sp)
    80005c66:	ec26                	sd	s1,24(sp)
    80005c68:	e84a                	sd	s2,16(sp)
    80005c6a:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    80005c6c:	c219                	beqz	a2,80005c72 <printint+0x12>
    80005c6e:	08054663          	bltz	a0,80005cfa <printint+0x9a>
    x = -xx;
  else
    x = xx;
    80005c72:	2501                	sext.w	a0,a0
    80005c74:	4881                	li	a7,0
    80005c76:	fd040693          	addi	a3,s0,-48

  i = 0;
    80005c7a:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    80005c7c:	2581                	sext.w	a1,a1
    80005c7e:	00003617          	auipc	a2,0x3
    80005c82:	d6260613          	addi	a2,a2,-670 # 800089e0 <digits>
    80005c86:	883a                	mv	a6,a4
    80005c88:	2705                	addiw	a4,a4,1
    80005c8a:	02b577bb          	remuw	a5,a0,a1
    80005c8e:	1782                	slli	a5,a5,0x20
    80005c90:	9381                	srli	a5,a5,0x20
    80005c92:	97b2                	add	a5,a5,a2
    80005c94:	0007c783          	lbu	a5,0(a5)
    80005c98:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    80005c9c:	0005079b          	sext.w	a5,a0
    80005ca0:	02b5553b          	divuw	a0,a0,a1
    80005ca4:	0685                	addi	a3,a3,1
    80005ca6:	feb7f0e3          	bgeu	a5,a1,80005c86 <printint+0x26>

  if(sign)
    80005caa:	00088b63          	beqz	a7,80005cc0 <printint+0x60>
    buf[i++] = '-';
    80005cae:	fe040793          	addi	a5,s0,-32
    80005cb2:	973e                	add	a4,a4,a5
    80005cb4:	02d00793          	li	a5,45
    80005cb8:	fef70823          	sb	a5,-16(a4)
    80005cbc:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80005cc0:	02e05763          	blez	a4,80005cee <printint+0x8e>
    80005cc4:	fd040793          	addi	a5,s0,-48
    80005cc8:	00e784b3          	add	s1,a5,a4
    80005ccc:	fff78913          	addi	s2,a5,-1
    80005cd0:	993a                	add	s2,s2,a4
    80005cd2:	377d                	addiw	a4,a4,-1
    80005cd4:	1702                	slli	a4,a4,0x20
    80005cd6:	9301                	srli	a4,a4,0x20
    80005cd8:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80005cdc:	fff4c503          	lbu	a0,-1(s1)
    80005ce0:	00000097          	auipc	ra,0x0
    80005ce4:	d60080e7          	jalr	-672(ra) # 80005a40 <consputc>
  while(--i >= 0)
    80005ce8:	14fd                	addi	s1,s1,-1
    80005cea:	ff2499e3          	bne	s1,s2,80005cdc <printint+0x7c>
}
    80005cee:	70a2                	ld	ra,40(sp)
    80005cf0:	7402                	ld	s0,32(sp)
    80005cf2:	64e2                	ld	s1,24(sp)
    80005cf4:	6942                	ld	s2,16(sp)
    80005cf6:	6145                	addi	sp,sp,48
    80005cf8:	8082                	ret
    x = -xx;
    80005cfa:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80005cfe:	4885                	li	a7,1
    x = -xx;
    80005d00:	bf9d                	j	80005c76 <printint+0x16>

0000000080005d02 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80005d02:	1101                	addi	sp,sp,-32
    80005d04:	ec06                	sd	ra,24(sp)
    80005d06:	e822                	sd	s0,16(sp)
    80005d08:	e426                	sd	s1,8(sp)
    80005d0a:	1000                	addi	s0,sp,32
    80005d0c:	84aa                	mv	s1,a0
  pr.locking = 0;
    80005d0e:	0001c797          	auipc	a5,0x1c
    80005d12:	3e07a923          	sw	zero,1010(a5) # 80022100 <pr+0x18>
  printf("panic: ");
    80005d16:	00003517          	auipc	a0,0x3
    80005d1a:	ca250513          	addi	a0,a0,-862 # 800089b8 <syscallnames+0x400>
    80005d1e:	00000097          	auipc	ra,0x0
    80005d22:	02e080e7          	jalr	46(ra) # 80005d4c <printf>
  printf(s);
    80005d26:	8526                	mv	a0,s1
    80005d28:	00000097          	auipc	ra,0x0
    80005d2c:	024080e7          	jalr	36(ra) # 80005d4c <printf>
  printf("\n");
    80005d30:	00002517          	auipc	a0,0x2
    80005d34:	31850513          	addi	a0,a0,792 # 80008048 <etext+0x48>
    80005d38:	00000097          	auipc	ra,0x0
    80005d3c:	014080e7          	jalr	20(ra) # 80005d4c <printf>
  panicked = 1; // freeze uart output from other CPUs
    80005d40:	4785                	li	a5,1
    80005d42:	00003717          	auipc	a4,0x3
    80005d46:	d6f72d23          	sw	a5,-646(a4) # 80008abc <panicked>
  for(;;)
    80005d4a:	a001                	j	80005d4a <panic+0x48>

0000000080005d4c <printf>:
{
    80005d4c:	7131                	addi	sp,sp,-192
    80005d4e:	fc86                	sd	ra,120(sp)
    80005d50:	f8a2                	sd	s0,112(sp)
    80005d52:	f4a6                	sd	s1,104(sp)
    80005d54:	f0ca                	sd	s2,96(sp)
    80005d56:	ecce                	sd	s3,88(sp)
    80005d58:	e8d2                	sd	s4,80(sp)
    80005d5a:	e4d6                	sd	s5,72(sp)
    80005d5c:	e0da                	sd	s6,64(sp)
    80005d5e:	fc5e                	sd	s7,56(sp)
    80005d60:	f862                	sd	s8,48(sp)
    80005d62:	f466                	sd	s9,40(sp)
    80005d64:	f06a                	sd	s10,32(sp)
    80005d66:	ec6e                	sd	s11,24(sp)
    80005d68:	0100                	addi	s0,sp,128
    80005d6a:	8a2a                	mv	s4,a0
    80005d6c:	e40c                	sd	a1,8(s0)
    80005d6e:	e810                	sd	a2,16(s0)
    80005d70:	ec14                	sd	a3,24(s0)
    80005d72:	f018                	sd	a4,32(s0)
    80005d74:	f41c                	sd	a5,40(s0)
    80005d76:	03043823          	sd	a6,48(s0)
    80005d7a:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    80005d7e:	0001cd97          	auipc	s11,0x1c
    80005d82:	382dad83          	lw	s11,898(s11) # 80022100 <pr+0x18>
  if(locking)
    80005d86:	020d9b63          	bnez	s11,80005dbc <printf+0x70>
  if (fmt == 0)
    80005d8a:	040a0263          	beqz	s4,80005dce <printf+0x82>
  va_start(ap, fmt);
    80005d8e:	00840793          	addi	a5,s0,8
    80005d92:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80005d96:	000a4503          	lbu	a0,0(s4)
    80005d9a:	16050263          	beqz	a0,80005efe <printf+0x1b2>
    80005d9e:	4481                	li	s1,0
    if(c != '%'){
    80005da0:	02500a93          	li	s5,37
    switch(c){
    80005da4:	07000b13          	li	s6,112
  consputc('x');
    80005da8:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80005daa:	00003b97          	auipc	s7,0x3
    80005dae:	c36b8b93          	addi	s7,s7,-970 # 800089e0 <digits>
    switch(c){
    80005db2:	07300c93          	li	s9,115
    80005db6:	06400c13          	li	s8,100
    80005dba:	a82d                	j	80005df4 <printf+0xa8>
    acquire(&pr.lock);
    80005dbc:	0001c517          	auipc	a0,0x1c
    80005dc0:	32c50513          	addi	a0,a0,812 # 800220e8 <pr>
    80005dc4:	00000097          	auipc	ra,0x0
    80005dc8:	488080e7          	jalr	1160(ra) # 8000624c <acquire>
    80005dcc:	bf7d                	j	80005d8a <printf+0x3e>
    panic("null fmt");
    80005dce:	00003517          	auipc	a0,0x3
    80005dd2:	bfa50513          	addi	a0,a0,-1030 # 800089c8 <syscallnames+0x410>
    80005dd6:	00000097          	auipc	ra,0x0
    80005dda:	f2c080e7          	jalr	-212(ra) # 80005d02 <panic>
      consputc(c);
    80005dde:	00000097          	auipc	ra,0x0
    80005de2:	c62080e7          	jalr	-926(ra) # 80005a40 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80005de6:	2485                	addiw	s1,s1,1
    80005de8:	009a07b3          	add	a5,s4,s1
    80005dec:	0007c503          	lbu	a0,0(a5)
    80005df0:	10050763          	beqz	a0,80005efe <printf+0x1b2>
    if(c != '%'){
    80005df4:	ff5515e3          	bne	a0,s5,80005dde <printf+0x92>
    c = fmt[++i] & 0xff;
    80005df8:	2485                	addiw	s1,s1,1
    80005dfa:	009a07b3          	add	a5,s4,s1
    80005dfe:	0007c783          	lbu	a5,0(a5)
    80005e02:	0007891b          	sext.w	s2,a5
    if(c == 0)
    80005e06:	cfe5                	beqz	a5,80005efe <printf+0x1b2>
    switch(c){
    80005e08:	05678a63          	beq	a5,s6,80005e5c <printf+0x110>
    80005e0c:	02fb7663          	bgeu	s6,a5,80005e38 <printf+0xec>
    80005e10:	09978963          	beq	a5,s9,80005ea2 <printf+0x156>
    80005e14:	07800713          	li	a4,120
    80005e18:	0ce79863          	bne	a5,a4,80005ee8 <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    80005e1c:	f8843783          	ld	a5,-120(s0)
    80005e20:	00878713          	addi	a4,a5,8
    80005e24:	f8e43423          	sd	a4,-120(s0)
    80005e28:	4605                	li	a2,1
    80005e2a:	85ea                	mv	a1,s10
    80005e2c:	4388                	lw	a0,0(a5)
    80005e2e:	00000097          	auipc	ra,0x0
    80005e32:	e32080e7          	jalr	-462(ra) # 80005c60 <printint>
      break;
    80005e36:	bf45                	j	80005de6 <printf+0x9a>
    switch(c){
    80005e38:	0b578263          	beq	a5,s5,80005edc <printf+0x190>
    80005e3c:	0b879663          	bne	a5,s8,80005ee8 <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    80005e40:	f8843783          	ld	a5,-120(s0)
    80005e44:	00878713          	addi	a4,a5,8
    80005e48:	f8e43423          	sd	a4,-120(s0)
    80005e4c:	4605                	li	a2,1
    80005e4e:	45a9                	li	a1,10
    80005e50:	4388                	lw	a0,0(a5)
    80005e52:	00000097          	auipc	ra,0x0
    80005e56:	e0e080e7          	jalr	-498(ra) # 80005c60 <printint>
      break;
    80005e5a:	b771                	j	80005de6 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80005e5c:	f8843783          	ld	a5,-120(s0)
    80005e60:	00878713          	addi	a4,a5,8
    80005e64:	f8e43423          	sd	a4,-120(s0)
    80005e68:	0007b983          	ld	s3,0(a5)
  consputc('0');
    80005e6c:	03000513          	li	a0,48
    80005e70:	00000097          	auipc	ra,0x0
    80005e74:	bd0080e7          	jalr	-1072(ra) # 80005a40 <consputc>
  consputc('x');
    80005e78:	07800513          	li	a0,120
    80005e7c:	00000097          	auipc	ra,0x0
    80005e80:	bc4080e7          	jalr	-1084(ra) # 80005a40 <consputc>
    80005e84:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80005e86:	03c9d793          	srli	a5,s3,0x3c
    80005e8a:	97de                	add	a5,a5,s7
    80005e8c:	0007c503          	lbu	a0,0(a5)
    80005e90:	00000097          	auipc	ra,0x0
    80005e94:	bb0080e7          	jalr	-1104(ra) # 80005a40 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80005e98:	0992                	slli	s3,s3,0x4
    80005e9a:	397d                	addiw	s2,s2,-1
    80005e9c:	fe0915e3          	bnez	s2,80005e86 <printf+0x13a>
    80005ea0:	b799                	j	80005de6 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    80005ea2:	f8843783          	ld	a5,-120(s0)
    80005ea6:	00878713          	addi	a4,a5,8
    80005eaa:	f8e43423          	sd	a4,-120(s0)
    80005eae:	0007b903          	ld	s2,0(a5)
    80005eb2:	00090e63          	beqz	s2,80005ece <printf+0x182>
      for(; *s; s++)
    80005eb6:	00094503          	lbu	a0,0(s2)
    80005eba:	d515                	beqz	a0,80005de6 <printf+0x9a>
        consputc(*s);
    80005ebc:	00000097          	auipc	ra,0x0
    80005ec0:	b84080e7          	jalr	-1148(ra) # 80005a40 <consputc>
      for(; *s; s++)
    80005ec4:	0905                	addi	s2,s2,1
    80005ec6:	00094503          	lbu	a0,0(s2)
    80005eca:	f96d                	bnez	a0,80005ebc <printf+0x170>
    80005ecc:	bf29                	j	80005de6 <printf+0x9a>
        s = "(null)";
    80005ece:	00003917          	auipc	s2,0x3
    80005ed2:	af290913          	addi	s2,s2,-1294 # 800089c0 <syscallnames+0x408>
      for(; *s; s++)
    80005ed6:	02800513          	li	a0,40
    80005eda:	b7cd                	j	80005ebc <printf+0x170>
      consputc('%');
    80005edc:	8556                	mv	a0,s5
    80005ede:	00000097          	auipc	ra,0x0
    80005ee2:	b62080e7          	jalr	-1182(ra) # 80005a40 <consputc>
      break;
    80005ee6:	b701                	j	80005de6 <printf+0x9a>
      consputc('%');
    80005ee8:	8556                	mv	a0,s5
    80005eea:	00000097          	auipc	ra,0x0
    80005eee:	b56080e7          	jalr	-1194(ra) # 80005a40 <consputc>
      consputc(c);
    80005ef2:	854a                	mv	a0,s2
    80005ef4:	00000097          	auipc	ra,0x0
    80005ef8:	b4c080e7          	jalr	-1204(ra) # 80005a40 <consputc>
      break;
    80005efc:	b5ed                	j	80005de6 <printf+0x9a>
  if(locking)
    80005efe:	020d9163          	bnez	s11,80005f20 <printf+0x1d4>
}
    80005f02:	70e6                	ld	ra,120(sp)
    80005f04:	7446                	ld	s0,112(sp)
    80005f06:	74a6                	ld	s1,104(sp)
    80005f08:	7906                	ld	s2,96(sp)
    80005f0a:	69e6                	ld	s3,88(sp)
    80005f0c:	6a46                	ld	s4,80(sp)
    80005f0e:	6aa6                	ld	s5,72(sp)
    80005f10:	6b06                	ld	s6,64(sp)
    80005f12:	7be2                	ld	s7,56(sp)
    80005f14:	7c42                	ld	s8,48(sp)
    80005f16:	7ca2                	ld	s9,40(sp)
    80005f18:	7d02                	ld	s10,32(sp)
    80005f1a:	6de2                	ld	s11,24(sp)
    80005f1c:	6129                	addi	sp,sp,192
    80005f1e:	8082                	ret
    release(&pr.lock);
    80005f20:	0001c517          	auipc	a0,0x1c
    80005f24:	1c850513          	addi	a0,a0,456 # 800220e8 <pr>
    80005f28:	00000097          	auipc	ra,0x0
    80005f2c:	3d8080e7          	jalr	984(ra) # 80006300 <release>
}
    80005f30:	bfc9                	j	80005f02 <printf+0x1b6>

0000000080005f32 <printfinit>:
    ;
}

void
printfinit(void)
{
    80005f32:	1101                	addi	sp,sp,-32
    80005f34:	ec06                	sd	ra,24(sp)
    80005f36:	e822                	sd	s0,16(sp)
    80005f38:	e426                	sd	s1,8(sp)
    80005f3a:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80005f3c:	0001c497          	auipc	s1,0x1c
    80005f40:	1ac48493          	addi	s1,s1,428 # 800220e8 <pr>
    80005f44:	00003597          	auipc	a1,0x3
    80005f48:	a9458593          	addi	a1,a1,-1388 # 800089d8 <syscallnames+0x420>
    80005f4c:	8526                	mv	a0,s1
    80005f4e:	00000097          	auipc	ra,0x0
    80005f52:	26e080e7          	jalr	622(ra) # 800061bc <initlock>
  pr.locking = 1;
    80005f56:	4785                	li	a5,1
    80005f58:	cc9c                	sw	a5,24(s1)
}
    80005f5a:	60e2                	ld	ra,24(sp)
    80005f5c:	6442                	ld	s0,16(sp)
    80005f5e:	64a2                	ld	s1,8(sp)
    80005f60:	6105                	addi	sp,sp,32
    80005f62:	8082                	ret

0000000080005f64 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80005f64:	1141                	addi	sp,sp,-16
    80005f66:	e406                	sd	ra,8(sp)
    80005f68:	e022                	sd	s0,0(sp)
    80005f6a:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80005f6c:	100007b7          	lui	a5,0x10000
    80005f70:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80005f74:	f8000713          	li	a4,-128
    80005f78:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80005f7c:	470d                	li	a4,3
    80005f7e:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80005f82:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80005f86:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80005f8a:	469d                	li	a3,7
    80005f8c:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80005f90:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    80005f94:	00003597          	auipc	a1,0x3
    80005f98:	a6458593          	addi	a1,a1,-1436 # 800089f8 <digits+0x18>
    80005f9c:	0001c517          	auipc	a0,0x1c
    80005fa0:	16c50513          	addi	a0,a0,364 # 80022108 <uart_tx_lock>
    80005fa4:	00000097          	auipc	ra,0x0
    80005fa8:	218080e7          	jalr	536(ra) # 800061bc <initlock>
}
    80005fac:	60a2                	ld	ra,8(sp)
    80005fae:	6402                	ld	s0,0(sp)
    80005fb0:	0141                	addi	sp,sp,16
    80005fb2:	8082                	ret

0000000080005fb4 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80005fb4:	1101                	addi	sp,sp,-32
    80005fb6:	ec06                	sd	ra,24(sp)
    80005fb8:	e822                	sd	s0,16(sp)
    80005fba:	e426                	sd	s1,8(sp)
    80005fbc:	1000                	addi	s0,sp,32
    80005fbe:	84aa                	mv	s1,a0
  push_off();
    80005fc0:	00000097          	auipc	ra,0x0
    80005fc4:	240080e7          	jalr	576(ra) # 80006200 <push_off>

  if(panicked){
    80005fc8:	00003797          	auipc	a5,0x3
    80005fcc:	af47a783          	lw	a5,-1292(a5) # 80008abc <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80005fd0:	10000737          	lui	a4,0x10000
  if(panicked){
    80005fd4:	c391                	beqz	a5,80005fd8 <uartputc_sync+0x24>
    for(;;)
    80005fd6:	a001                	j	80005fd6 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80005fd8:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80005fdc:	0ff7f793          	andi	a5,a5,255
    80005fe0:	0207f793          	andi	a5,a5,32
    80005fe4:	dbf5                	beqz	a5,80005fd8 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80005fe6:	0ff4f793          	andi	a5,s1,255
    80005fea:	10000737          	lui	a4,0x10000
    80005fee:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    80005ff2:	00000097          	auipc	ra,0x0
    80005ff6:	2ae080e7          	jalr	686(ra) # 800062a0 <pop_off>
}
    80005ffa:	60e2                	ld	ra,24(sp)
    80005ffc:	6442                	ld	s0,16(sp)
    80005ffe:	64a2                	ld	s1,8(sp)
    80006000:	6105                	addi	sp,sp,32
    80006002:	8082                	ret

0000000080006004 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80006004:	00003717          	auipc	a4,0x3
    80006008:	abc73703          	ld	a4,-1348(a4) # 80008ac0 <uart_tx_r>
    8000600c:	00003797          	auipc	a5,0x3
    80006010:	abc7b783          	ld	a5,-1348(a5) # 80008ac8 <uart_tx_w>
    80006014:	06e78c63          	beq	a5,a4,8000608c <uartstart+0x88>
{
    80006018:	7139                	addi	sp,sp,-64
    8000601a:	fc06                	sd	ra,56(sp)
    8000601c:	f822                	sd	s0,48(sp)
    8000601e:	f426                	sd	s1,40(sp)
    80006020:	f04a                	sd	s2,32(sp)
    80006022:	ec4e                	sd	s3,24(sp)
    80006024:	e852                	sd	s4,16(sp)
    80006026:	e456                	sd	s5,8(sp)
    80006028:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000602a:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000602e:	0001ca17          	auipc	s4,0x1c
    80006032:	0daa0a13          	addi	s4,s4,218 # 80022108 <uart_tx_lock>
    uart_tx_r += 1;
    80006036:	00003497          	auipc	s1,0x3
    8000603a:	a8a48493          	addi	s1,s1,-1398 # 80008ac0 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000603e:	00003997          	auipc	s3,0x3
    80006042:	a8a98993          	addi	s3,s3,-1398 # 80008ac8 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80006046:	00594783          	lbu	a5,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000604a:	0ff7f793          	andi	a5,a5,255
    8000604e:	0207f793          	andi	a5,a5,32
    80006052:	c785                	beqz	a5,8000607a <uartstart+0x76>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80006054:	01f77793          	andi	a5,a4,31
    80006058:	97d2                	add	a5,a5,s4
    8000605a:	0187ca83          	lbu	s5,24(a5)
    uart_tx_r += 1;
    8000605e:	0705                	addi	a4,a4,1
    80006060:	e098                	sd	a4,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80006062:	8526                	mv	a0,s1
    80006064:	ffffb097          	auipc	ra,0xffffb
    80006068:	528080e7          	jalr	1320(ra) # 8000158c <wakeup>
    
    WriteReg(THR, c);
    8000606c:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    80006070:	6098                	ld	a4,0(s1)
    80006072:	0009b783          	ld	a5,0(s3)
    80006076:	fce798e3          	bne	a5,a4,80006046 <uartstart+0x42>
  }
}
    8000607a:	70e2                	ld	ra,56(sp)
    8000607c:	7442                	ld	s0,48(sp)
    8000607e:	74a2                	ld	s1,40(sp)
    80006080:	7902                	ld	s2,32(sp)
    80006082:	69e2                	ld	s3,24(sp)
    80006084:	6a42                	ld	s4,16(sp)
    80006086:	6aa2                	ld	s5,8(sp)
    80006088:	6121                	addi	sp,sp,64
    8000608a:	8082                	ret
    8000608c:	8082                	ret

000000008000608e <uartputc>:
{
    8000608e:	7179                	addi	sp,sp,-48
    80006090:	f406                	sd	ra,40(sp)
    80006092:	f022                	sd	s0,32(sp)
    80006094:	ec26                	sd	s1,24(sp)
    80006096:	e84a                	sd	s2,16(sp)
    80006098:	e44e                	sd	s3,8(sp)
    8000609a:	e052                	sd	s4,0(sp)
    8000609c:	1800                	addi	s0,sp,48
    8000609e:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    800060a0:	0001c517          	auipc	a0,0x1c
    800060a4:	06850513          	addi	a0,a0,104 # 80022108 <uart_tx_lock>
    800060a8:	00000097          	auipc	ra,0x0
    800060ac:	1a4080e7          	jalr	420(ra) # 8000624c <acquire>
  if(panicked){
    800060b0:	00003797          	auipc	a5,0x3
    800060b4:	a0c7a783          	lw	a5,-1524(a5) # 80008abc <panicked>
    800060b8:	e7c9                	bnez	a5,80006142 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800060ba:	00003797          	auipc	a5,0x3
    800060be:	a0e7b783          	ld	a5,-1522(a5) # 80008ac8 <uart_tx_w>
    800060c2:	00003717          	auipc	a4,0x3
    800060c6:	9fe73703          	ld	a4,-1538(a4) # 80008ac0 <uart_tx_r>
    800060ca:	02070713          	addi	a4,a4,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800060ce:	0001ca17          	auipc	s4,0x1c
    800060d2:	03aa0a13          	addi	s4,s4,58 # 80022108 <uart_tx_lock>
    800060d6:	00003497          	auipc	s1,0x3
    800060da:	9ea48493          	addi	s1,s1,-1558 # 80008ac0 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800060de:	00003917          	auipc	s2,0x3
    800060e2:	9ea90913          	addi	s2,s2,-1558 # 80008ac8 <uart_tx_w>
    800060e6:	00f71f63          	bne	a4,a5,80006104 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    800060ea:	85d2                	mv	a1,s4
    800060ec:	8526                	mv	a0,s1
    800060ee:	ffffb097          	auipc	ra,0xffffb
    800060f2:	43a080e7          	jalr	1082(ra) # 80001528 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800060f6:	00093783          	ld	a5,0(s2)
    800060fa:	6098                	ld	a4,0(s1)
    800060fc:	02070713          	addi	a4,a4,32
    80006100:	fef705e3          	beq	a4,a5,800060ea <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80006104:	0001c497          	auipc	s1,0x1c
    80006108:	00448493          	addi	s1,s1,4 # 80022108 <uart_tx_lock>
    8000610c:	01f7f713          	andi	a4,a5,31
    80006110:	9726                	add	a4,a4,s1
    80006112:	01370c23          	sb	s3,24(a4)
  uart_tx_w += 1;
    80006116:	0785                	addi	a5,a5,1
    80006118:	00003717          	auipc	a4,0x3
    8000611c:	9af73823          	sd	a5,-1616(a4) # 80008ac8 <uart_tx_w>
  uartstart();
    80006120:	00000097          	auipc	ra,0x0
    80006124:	ee4080e7          	jalr	-284(ra) # 80006004 <uartstart>
  release(&uart_tx_lock);
    80006128:	8526                	mv	a0,s1
    8000612a:	00000097          	auipc	ra,0x0
    8000612e:	1d6080e7          	jalr	470(ra) # 80006300 <release>
}
    80006132:	70a2                	ld	ra,40(sp)
    80006134:	7402                	ld	s0,32(sp)
    80006136:	64e2                	ld	s1,24(sp)
    80006138:	6942                	ld	s2,16(sp)
    8000613a:	69a2                	ld	s3,8(sp)
    8000613c:	6a02                	ld	s4,0(sp)
    8000613e:	6145                	addi	sp,sp,48
    80006140:	8082                	ret
    for(;;)
    80006142:	a001                	j	80006142 <uartputc+0xb4>

0000000080006144 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80006144:	1141                	addi	sp,sp,-16
    80006146:	e422                	sd	s0,8(sp)
    80006148:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    8000614a:	100007b7          	lui	a5,0x10000
    8000614e:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80006152:	8b85                	andi	a5,a5,1
    80006154:	cb91                	beqz	a5,80006168 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80006156:	100007b7          	lui	a5,0x10000
    8000615a:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    8000615e:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    80006162:	6422                	ld	s0,8(sp)
    80006164:	0141                	addi	sp,sp,16
    80006166:	8082                	ret
    return -1;
    80006168:	557d                	li	a0,-1
    8000616a:	bfe5                	j	80006162 <uartgetc+0x1e>

000000008000616c <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    8000616c:	1101                	addi	sp,sp,-32
    8000616e:	ec06                	sd	ra,24(sp)
    80006170:	e822                	sd	s0,16(sp)
    80006172:	e426                	sd	s1,8(sp)
    80006174:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80006176:	54fd                	li	s1,-1
    int c = uartgetc();
    80006178:	00000097          	auipc	ra,0x0
    8000617c:	fcc080e7          	jalr	-52(ra) # 80006144 <uartgetc>
    if(c == -1)
    80006180:	00950763          	beq	a0,s1,8000618e <uartintr+0x22>
      break;
    consoleintr(c);
    80006184:	00000097          	auipc	ra,0x0
    80006188:	8fe080e7          	jalr	-1794(ra) # 80005a82 <consoleintr>
  while(1){
    8000618c:	b7f5                	j	80006178 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    8000618e:	0001c497          	auipc	s1,0x1c
    80006192:	f7a48493          	addi	s1,s1,-134 # 80022108 <uart_tx_lock>
    80006196:	8526                	mv	a0,s1
    80006198:	00000097          	auipc	ra,0x0
    8000619c:	0b4080e7          	jalr	180(ra) # 8000624c <acquire>
  uartstart();
    800061a0:	00000097          	auipc	ra,0x0
    800061a4:	e64080e7          	jalr	-412(ra) # 80006004 <uartstart>
  release(&uart_tx_lock);
    800061a8:	8526                	mv	a0,s1
    800061aa:	00000097          	auipc	ra,0x0
    800061ae:	156080e7          	jalr	342(ra) # 80006300 <release>
}
    800061b2:	60e2                	ld	ra,24(sp)
    800061b4:	6442                	ld	s0,16(sp)
    800061b6:	64a2                	ld	s1,8(sp)
    800061b8:	6105                	addi	sp,sp,32
    800061ba:	8082                	ret

00000000800061bc <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    800061bc:	1141                	addi	sp,sp,-16
    800061be:	e422                	sd	s0,8(sp)
    800061c0:	0800                	addi	s0,sp,16
  lk->name = name;
    800061c2:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    800061c4:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    800061c8:	00053823          	sd	zero,16(a0)
}
    800061cc:	6422                	ld	s0,8(sp)
    800061ce:	0141                	addi	sp,sp,16
    800061d0:	8082                	ret

00000000800061d2 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    800061d2:	411c                	lw	a5,0(a0)
    800061d4:	e399                	bnez	a5,800061da <holding+0x8>
    800061d6:	4501                	li	a0,0
  return r;
}
    800061d8:	8082                	ret
{
    800061da:	1101                	addi	sp,sp,-32
    800061dc:	ec06                	sd	ra,24(sp)
    800061de:	e822                	sd	s0,16(sp)
    800061e0:	e426                	sd	s1,8(sp)
    800061e2:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    800061e4:	6904                	ld	s1,16(a0)
    800061e6:	ffffb097          	auipc	ra,0xffffb
    800061ea:	c7a080e7          	jalr	-902(ra) # 80000e60 <mycpu>
    800061ee:	40a48533          	sub	a0,s1,a0
    800061f2:	00153513          	seqz	a0,a0
}
    800061f6:	60e2                	ld	ra,24(sp)
    800061f8:	6442                	ld	s0,16(sp)
    800061fa:	64a2                	ld	s1,8(sp)
    800061fc:	6105                	addi	sp,sp,32
    800061fe:	8082                	ret

0000000080006200 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80006200:	1101                	addi	sp,sp,-32
    80006202:	ec06                	sd	ra,24(sp)
    80006204:	e822                	sd	s0,16(sp)
    80006206:	e426                	sd	s1,8(sp)
    80006208:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000620a:	100024f3          	csrr	s1,sstatus
    8000620e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80006212:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80006214:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80006218:	ffffb097          	auipc	ra,0xffffb
    8000621c:	c48080e7          	jalr	-952(ra) # 80000e60 <mycpu>
    80006220:	5d3c                	lw	a5,120(a0)
    80006222:	cf89                	beqz	a5,8000623c <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80006224:	ffffb097          	auipc	ra,0xffffb
    80006228:	c3c080e7          	jalr	-964(ra) # 80000e60 <mycpu>
    8000622c:	5d3c                	lw	a5,120(a0)
    8000622e:	2785                	addiw	a5,a5,1
    80006230:	dd3c                	sw	a5,120(a0)
}
    80006232:	60e2                	ld	ra,24(sp)
    80006234:	6442                	ld	s0,16(sp)
    80006236:	64a2                	ld	s1,8(sp)
    80006238:	6105                	addi	sp,sp,32
    8000623a:	8082                	ret
    mycpu()->intena = old;
    8000623c:	ffffb097          	auipc	ra,0xffffb
    80006240:	c24080e7          	jalr	-988(ra) # 80000e60 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80006244:	8085                	srli	s1,s1,0x1
    80006246:	8885                	andi	s1,s1,1
    80006248:	dd64                	sw	s1,124(a0)
    8000624a:	bfe9                	j	80006224 <push_off+0x24>

000000008000624c <acquire>:
{
    8000624c:	1101                	addi	sp,sp,-32
    8000624e:	ec06                	sd	ra,24(sp)
    80006250:	e822                	sd	s0,16(sp)
    80006252:	e426                	sd	s1,8(sp)
    80006254:	1000                	addi	s0,sp,32
    80006256:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80006258:	00000097          	auipc	ra,0x0
    8000625c:	fa8080e7          	jalr	-88(ra) # 80006200 <push_off>
  if(holding(lk))
    80006260:	8526                	mv	a0,s1
    80006262:	00000097          	auipc	ra,0x0
    80006266:	f70080e7          	jalr	-144(ra) # 800061d2 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    8000626a:	4705                	li	a4,1
  if(holding(lk))
    8000626c:	e115                	bnez	a0,80006290 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    8000626e:	87ba                	mv	a5,a4
    80006270:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80006274:	2781                	sext.w	a5,a5
    80006276:	ffe5                	bnez	a5,8000626e <acquire+0x22>
  __sync_synchronize();
    80006278:	0ff0000f          	fence
  lk->cpu = mycpu();
    8000627c:	ffffb097          	auipc	ra,0xffffb
    80006280:	be4080e7          	jalr	-1052(ra) # 80000e60 <mycpu>
    80006284:	e888                	sd	a0,16(s1)
}
    80006286:	60e2                	ld	ra,24(sp)
    80006288:	6442                	ld	s0,16(sp)
    8000628a:	64a2                	ld	s1,8(sp)
    8000628c:	6105                	addi	sp,sp,32
    8000628e:	8082                	ret
    panic("acquire");
    80006290:	00002517          	auipc	a0,0x2
    80006294:	77050513          	addi	a0,a0,1904 # 80008a00 <digits+0x20>
    80006298:	00000097          	auipc	ra,0x0
    8000629c:	a6a080e7          	jalr	-1430(ra) # 80005d02 <panic>

00000000800062a0 <pop_off>:

void
pop_off(void)
{
    800062a0:	1141                	addi	sp,sp,-16
    800062a2:	e406                	sd	ra,8(sp)
    800062a4:	e022                	sd	s0,0(sp)
    800062a6:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    800062a8:	ffffb097          	auipc	ra,0xffffb
    800062ac:	bb8080e7          	jalr	-1096(ra) # 80000e60 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800062b0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800062b4:	8b89                	andi	a5,a5,2
  if(intr_get())
    800062b6:	e78d                	bnez	a5,800062e0 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    800062b8:	5d3c                	lw	a5,120(a0)
    800062ba:	02f05b63          	blez	a5,800062f0 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    800062be:	37fd                	addiw	a5,a5,-1
    800062c0:	0007871b          	sext.w	a4,a5
    800062c4:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    800062c6:	eb09                	bnez	a4,800062d8 <pop_off+0x38>
    800062c8:	5d7c                	lw	a5,124(a0)
    800062ca:	c799                	beqz	a5,800062d8 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800062cc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800062d0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800062d4:	10079073          	csrw	sstatus,a5
    intr_on();
}
    800062d8:	60a2                	ld	ra,8(sp)
    800062da:	6402                	ld	s0,0(sp)
    800062dc:	0141                	addi	sp,sp,16
    800062de:	8082                	ret
    panic("pop_off - interruptible");
    800062e0:	00002517          	auipc	a0,0x2
    800062e4:	72850513          	addi	a0,a0,1832 # 80008a08 <digits+0x28>
    800062e8:	00000097          	auipc	ra,0x0
    800062ec:	a1a080e7          	jalr	-1510(ra) # 80005d02 <panic>
    panic("pop_off");
    800062f0:	00002517          	auipc	a0,0x2
    800062f4:	73050513          	addi	a0,a0,1840 # 80008a20 <digits+0x40>
    800062f8:	00000097          	auipc	ra,0x0
    800062fc:	a0a080e7          	jalr	-1526(ra) # 80005d02 <panic>

0000000080006300 <release>:
{
    80006300:	1101                	addi	sp,sp,-32
    80006302:	ec06                	sd	ra,24(sp)
    80006304:	e822                	sd	s0,16(sp)
    80006306:	e426                	sd	s1,8(sp)
    80006308:	1000                	addi	s0,sp,32
    8000630a:	84aa                	mv	s1,a0
  if(!holding(lk))
    8000630c:	00000097          	auipc	ra,0x0
    80006310:	ec6080e7          	jalr	-314(ra) # 800061d2 <holding>
    80006314:	c115                	beqz	a0,80006338 <release+0x38>
  lk->cpu = 0;
    80006316:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    8000631a:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    8000631e:	0f50000f          	fence	iorw,ow
    80006322:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80006326:	00000097          	auipc	ra,0x0
    8000632a:	f7a080e7          	jalr	-134(ra) # 800062a0 <pop_off>
}
    8000632e:	60e2                	ld	ra,24(sp)
    80006330:	6442                	ld	s0,16(sp)
    80006332:	64a2                	ld	s1,8(sp)
    80006334:	6105                	addi	sp,sp,32
    80006336:	8082                	ret
    panic("release");
    80006338:	00002517          	auipc	a0,0x2
    8000633c:	6f050513          	addi	a0,a0,1776 # 80008a28 <digits+0x48>
    80006340:	00000097          	auipc	ra,0x0
    80006344:	9c2080e7          	jalr	-1598(ra) # 80005d02 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
