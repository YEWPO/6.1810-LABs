// Buffer cache.
//
// The buffer cache is a linked list of buf structures holding
// cached copies of disk block contents.  Caching disk blocks
// in memory reduces the number of disk reads and also provides
// a synchronization point for disk blocks used by multiple processes.
//
// Interface:
// * To get a buffer for a particular disk block, call bread.
// * After changing buffer data, call bwrite to write it to disk.
// * When done with the buffer, call brelse.
// * Do not use the buffer after calling brelse.
// * Only one process at a time can use a buffer,
//     so do not keep them longer than necessary.


#include "types.h"
#include "param.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "riscv.h"
#include "defs.h"
#include "fs.h"
#include "buf.h"

#define HASHMAP(number) (number % NBUCKET)

struct {
  struct spinlock lock;
  struct buf buf[NBUF];

  struct {
    struct spinlock lock;
    struct buf head;
  } bucket[NBUCKET];
} bcache;

void
binit(void)
{
  struct buf *b;

  initlock(&bcache.lock, "bcache.eviction");

  for (int i = 0; i < NBUCKET; ++i) {
    initlock(&bcache.bucket[i].lock, "bcache.bucket");
    bcache.bucket[i].head.next = 0;

    b = &bcache.bucket[i].head;
    for (int j = i * 3; j < i * 3 + 3; j++) {
      initsleeplock(&bcache.buf[j].lock, "buffer");
      bcache.buf[j].next = b->next;
      b->next = &bcache.buf[j];
      b = b->next;
    }
  }
}

// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
  struct buf *b;

  int index = HASHMAP(blockno);

  acquire(&bcache.bucket[index].lock);
  for (b = bcache.bucket[index].head.next; b; b = b->next) {
    if (b->blockno == blockno && b->dev == dev) {
      b->refcnt++;
      release(&bcache.bucket[index].lock);
      acquiresleep(&b->lock);
      return b;
    }
  }

  for (b = bcache.bucket[index].head.next; b; b = b->next) {
    if (b->refcnt == 0) {
      b->blockno = blockno;
      b->dev = dev;
      b->valid = 0;
      b->refcnt = 1;
      release(&bcache.bucket[index].lock);
      acquiresleep(&b->lock);
      return b;
    }
  }
  release(&bcache.bucket[index].lock);

  acquire(&bcache.lock);
  for (int i = 0; i < NBUCKET; ++i) {
    if (i != index) {
      struct buf *pre;
      acquire(&bcache.bucket[i].lock);
      for (pre = &bcache.bucket[i].head, b = bcache.bucket[i].head.next; b; pre = b, b = b->next) {
        if (b->refcnt == 0) {
          pre->next = b->next;
          release(&bcache.bucket[i].lock);

          acquire(&bcache.bucket[index].lock);
          b->next = bcache.bucket[index].head.next;
          bcache.bucket[index].head.next = b;
          b->blockno = blockno;
          b->dev = dev;
          b->valid = 0;
          b->refcnt = 1;
          release(&bcache.bucket[index].lock);
          acquiresleep(&b->lock);
          release(&bcache.lock);
          return b;
        }
      }
      release(&bcache.bucket[i].lock);
    }
  }
  release(&bcache.lock);

  panic("bget: no buffers");
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
  if(!holdingsleep(&b->lock))
    panic("bwrite");
  virtio_disk_rw(b, 1);
}

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
  if(!holdingsleep(&b->lock))
    panic("brelse");

  int index = HASHMAP(b->blockno);

  releasesleep(&b->lock);

  acquire(&bcache.bucket[index].lock);
  b->refcnt--;
  release(&bcache.bucket[index].lock);
}

void
bpin(struct buf *b) {
  int index = HASHMAP(b->blockno);

  acquire(&bcache.bucket[index].lock);
  b->refcnt++;
  release(&bcache.bucket[index].lock);
}

void
bunpin(struct buf *b) {
  int index = HASHMAP(b->blockno);

  acquire(&bcache.bucket[index].lock);
  b->refcnt--;
  release(&bcache.bucket[index].lock);
}