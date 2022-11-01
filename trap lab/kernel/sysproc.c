#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  exit(n);
  return 0;  // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return fork();
}

uint64
sys_wait(void)
{
  uint64 p;
  argaddr(0, &p);
  return wait(p);
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int n;

  argint(0, &n);
  addr = myproc()->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

uint64
sys_sleep(void)
{
    backtrace();

  int n;
  uint ticks0;

  argint(0, &n);
  if(n < 0)
    n = 0;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  argint(0, &pid);
  return kill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

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