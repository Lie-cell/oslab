
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc020001c:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200020:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200024:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	00006517          	auipc	a0,0x6
ffffffffc0200036:	fde50513          	addi	a0,a0,-34 # ffffffffc0206010 <buf>
ffffffffc020003a:	00006617          	auipc	a2,0x6
ffffffffc020003e:	43e60613          	addi	a2,a2,1086 # ffffffffc0206478 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	638010ef          	jal	ra,ffffffffc0201682 <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00001517          	auipc	a0,0x1
ffffffffc0200056:	64650513          	addi	a0,a0,1606 # ffffffffc0201698 <etext+0x4>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	0dc000ef          	jal	ra,ffffffffc020013a <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	747000ef          	jal	ra,ffffffffc0200fac <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006a:	3fa000ef          	jal	ra,ffffffffc0200464 <idt_init>

    clock_init();   // init clock interrupt
ffffffffc020006e:	39a000ef          	jal	ra,ffffffffc0200408 <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200072:	3e6000ef          	jal	ra,ffffffffc0200458 <intr_enable>



    /* do nothing */
    while (1)
ffffffffc0200076:	a001                	j	ffffffffc0200076 <kern_init+0x44>

ffffffffc0200078 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200078:	1141                	addi	sp,sp,-16
ffffffffc020007a:	e022                	sd	s0,0(sp)
ffffffffc020007c:	e406                	sd	ra,8(sp)
ffffffffc020007e:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200080:	3cc000ef          	jal	ra,ffffffffc020044c <cons_putc>
    (*cnt) ++;
ffffffffc0200084:	401c                	lw	a5,0(s0)
}
ffffffffc0200086:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200088:	2785                	addiw	a5,a5,1
ffffffffc020008a:	c01c                	sw	a5,0(s0)
}
ffffffffc020008c:	6402                	ld	s0,0(sp)
ffffffffc020008e:	0141                	addi	sp,sp,16
ffffffffc0200090:	8082                	ret

ffffffffc0200092 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200092:	1101                	addi	sp,sp,-32
ffffffffc0200094:	862a                	mv	a2,a0
ffffffffc0200096:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	00000517          	auipc	a0,0x0
ffffffffc020009c:	fe050513          	addi	a0,a0,-32 # ffffffffc0200078 <cputch>
ffffffffc02000a0:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a2:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a4:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a6:	106010ef          	jal	ra,ffffffffc02011ac <vprintfmt>
    return cnt;
}
ffffffffc02000aa:	60e2                	ld	ra,24(sp)
ffffffffc02000ac:	4532                	lw	a0,12(sp)
ffffffffc02000ae:	6105                	addi	sp,sp,32
ffffffffc02000b0:	8082                	ret

ffffffffc02000b2 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b2:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b4:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000b8:	8e2a                	mv	t3,a0
ffffffffc02000ba:	f42e                	sd	a1,40(sp)
ffffffffc02000bc:	f832                	sd	a2,48(sp)
ffffffffc02000be:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c0:	00000517          	auipc	a0,0x0
ffffffffc02000c4:	fb850513          	addi	a0,a0,-72 # ffffffffc0200078 <cputch>
ffffffffc02000c8:	004c                	addi	a1,sp,4
ffffffffc02000ca:	869a                	mv	a3,t1
ffffffffc02000cc:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000ce:	ec06                	sd	ra,24(sp)
ffffffffc02000d0:	e0ba                	sd	a4,64(sp)
ffffffffc02000d2:	e4be                	sd	a5,72(sp)
ffffffffc02000d4:	e8c2                	sd	a6,80(sp)
ffffffffc02000d6:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000d8:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000da:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000dc:	0d0010ef          	jal	ra,ffffffffc02011ac <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e0:	60e2                	ld	ra,24(sp)
ffffffffc02000e2:	4512                	lw	a0,4(sp)
ffffffffc02000e4:	6125                	addi	sp,sp,96
ffffffffc02000e6:	8082                	ret

ffffffffc02000e8 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000e8:	a695                	j	ffffffffc020044c <cons_putc>

ffffffffc02000ea <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ea:	1101                	addi	sp,sp,-32
ffffffffc02000ec:	e822                	sd	s0,16(sp)
ffffffffc02000ee:	ec06                	sd	ra,24(sp)
ffffffffc02000f0:	e426                	sd	s1,8(sp)
ffffffffc02000f2:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f4:	00054503          	lbu	a0,0(a0)
ffffffffc02000f8:	c51d                	beqz	a0,ffffffffc0200126 <cputs+0x3c>
ffffffffc02000fa:	0405                	addi	s0,s0,1
ffffffffc02000fc:	4485                	li	s1,1
ffffffffc02000fe:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200100:	34c000ef          	jal	ra,ffffffffc020044c <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc0200104:	00044503          	lbu	a0,0(s0)
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	f96d                	bnez	a0,ffffffffc0200100 <cputs+0x16>
    (*cnt) ++;
ffffffffc0200110:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200114:	4529                	li	a0,10
ffffffffc0200116:	336000ef          	jal	ra,ffffffffc020044c <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011a:	60e2                	ld	ra,24(sp)
ffffffffc020011c:	8522                	mv	a0,s0
ffffffffc020011e:	6442                	ld	s0,16(sp)
ffffffffc0200120:	64a2                	ld	s1,8(sp)
ffffffffc0200122:	6105                	addi	sp,sp,32
ffffffffc0200124:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200126:	4405                	li	s0,1
ffffffffc0200128:	b7f5                	j	ffffffffc0200114 <cputs+0x2a>

ffffffffc020012a <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012a:	1141                	addi	sp,sp,-16
ffffffffc020012c:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020012e:	326000ef          	jal	ra,ffffffffc0200454 <cons_getc>
ffffffffc0200132:	dd75                	beqz	a0,ffffffffc020012e <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200134:	60a2                	ld	ra,8(sp)
ffffffffc0200136:	0141                	addi	sp,sp,16
ffffffffc0200138:	8082                	ret

ffffffffc020013a <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020013a:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020013c:	00001517          	auipc	a0,0x1
ffffffffc0200140:	57c50513          	addi	a0,a0,1404 # ffffffffc02016b8 <etext+0x24>
void print_kerninfo(void) {
ffffffffc0200144:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200146:	f6dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014a:	00000597          	auipc	a1,0x0
ffffffffc020014e:	ee858593          	addi	a1,a1,-280 # ffffffffc0200032 <kern_init>
ffffffffc0200152:	00001517          	auipc	a0,0x1
ffffffffc0200156:	58650513          	addi	a0,a0,1414 # ffffffffc02016d8 <etext+0x44>
ffffffffc020015a:	f59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020015e:	00001597          	auipc	a1,0x1
ffffffffc0200162:	53658593          	addi	a1,a1,1334 # ffffffffc0201694 <etext>
ffffffffc0200166:	00001517          	auipc	a0,0x1
ffffffffc020016a:	59250513          	addi	a0,a0,1426 # ffffffffc02016f8 <etext+0x64>
ffffffffc020016e:	f45ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200172:	00006597          	auipc	a1,0x6
ffffffffc0200176:	e9e58593          	addi	a1,a1,-354 # ffffffffc0206010 <buf>
ffffffffc020017a:	00001517          	auipc	a0,0x1
ffffffffc020017e:	59e50513          	addi	a0,a0,1438 # ffffffffc0201718 <etext+0x84>
ffffffffc0200182:	f31ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200186:	00006597          	auipc	a1,0x6
ffffffffc020018a:	2f258593          	addi	a1,a1,754 # ffffffffc0206478 <end>
ffffffffc020018e:	00001517          	auipc	a0,0x1
ffffffffc0200192:	5aa50513          	addi	a0,a0,1450 # ffffffffc0201738 <etext+0xa4>
ffffffffc0200196:	f1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019a:	00006597          	auipc	a1,0x6
ffffffffc020019e:	6dd58593          	addi	a1,a1,1757 # ffffffffc0206877 <end+0x3ff>
ffffffffc02001a2:	00000797          	auipc	a5,0x0
ffffffffc02001a6:	e9078793          	addi	a5,a5,-368 # ffffffffc0200032 <kern_init>
ffffffffc02001aa:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ae:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001b2:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b4:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001b8:	95be                	add	a1,a1,a5
ffffffffc02001ba:	85a9                	srai	a1,a1,0xa
ffffffffc02001bc:	00001517          	auipc	a0,0x1
ffffffffc02001c0:	59c50513          	addi	a0,a0,1436 # ffffffffc0201758 <etext+0xc4>
}
ffffffffc02001c4:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001c6:	b5f5                	j	ffffffffc02000b2 <cprintf>

ffffffffc02001c8 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001c8:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001ca:	00001617          	auipc	a2,0x1
ffffffffc02001ce:	5be60613          	addi	a2,a2,1470 # ffffffffc0201788 <etext+0xf4>
ffffffffc02001d2:	04e00593          	li	a1,78
ffffffffc02001d6:	00001517          	auipc	a0,0x1
ffffffffc02001da:	5ca50513          	addi	a0,a0,1482 # ffffffffc02017a0 <etext+0x10c>
void print_stackframe(void) {
ffffffffc02001de:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e0:	1cc000ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02001e4 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001e4:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001e6:	00001617          	auipc	a2,0x1
ffffffffc02001ea:	5d260613          	addi	a2,a2,1490 # ffffffffc02017b8 <etext+0x124>
ffffffffc02001ee:	00001597          	auipc	a1,0x1
ffffffffc02001f2:	5ea58593          	addi	a1,a1,1514 # ffffffffc02017d8 <etext+0x144>
ffffffffc02001f6:	00001517          	auipc	a0,0x1
ffffffffc02001fa:	5ea50513          	addi	a0,a0,1514 # ffffffffc02017e0 <etext+0x14c>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001fe:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200200:	eb3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200204:	00001617          	auipc	a2,0x1
ffffffffc0200208:	5ec60613          	addi	a2,a2,1516 # ffffffffc02017f0 <etext+0x15c>
ffffffffc020020c:	00001597          	auipc	a1,0x1
ffffffffc0200210:	60c58593          	addi	a1,a1,1548 # ffffffffc0201818 <etext+0x184>
ffffffffc0200214:	00001517          	auipc	a0,0x1
ffffffffc0200218:	5cc50513          	addi	a0,a0,1484 # ffffffffc02017e0 <etext+0x14c>
ffffffffc020021c:	e97ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200220:	00001617          	auipc	a2,0x1
ffffffffc0200224:	60860613          	addi	a2,a2,1544 # ffffffffc0201828 <etext+0x194>
ffffffffc0200228:	00001597          	auipc	a1,0x1
ffffffffc020022c:	62058593          	addi	a1,a1,1568 # ffffffffc0201848 <etext+0x1b4>
ffffffffc0200230:	00001517          	auipc	a0,0x1
ffffffffc0200234:	5b050513          	addi	a0,a0,1456 # ffffffffc02017e0 <etext+0x14c>
ffffffffc0200238:	e7bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    }
    return 0;
}
ffffffffc020023c:	60a2                	ld	ra,8(sp)
ffffffffc020023e:	4501                	li	a0,0
ffffffffc0200240:	0141                	addi	sp,sp,16
ffffffffc0200242:	8082                	ret

ffffffffc0200244 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200244:	1141                	addi	sp,sp,-16
ffffffffc0200246:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200248:	ef3ff0ef          	jal	ra,ffffffffc020013a <print_kerninfo>
    return 0;
}
ffffffffc020024c:	60a2                	ld	ra,8(sp)
ffffffffc020024e:	4501                	li	a0,0
ffffffffc0200250:	0141                	addi	sp,sp,16
ffffffffc0200252:	8082                	ret

ffffffffc0200254 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200254:	1141                	addi	sp,sp,-16
ffffffffc0200256:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200258:	f71ff0ef          	jal	ra,ffffffffc02001c8 <print_stackframe>
    return 0;
}
ffffffffc020025c:	60a2                	ld	ra,8(sp)
ffffffffc020025e:	4501                	li	a0,0
ffffffffc0200260:	0141                	addi	sp,sp,16
ffffffffc0200262:	8082                	ret

ffffffffc0200264 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200264:	7115                	addi	sp,sp,-224
ffffffffc0200266:	ed5e                	sd	s7,152(sp)
ffffffffc0200268:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020026a:	00001517          	auipc	a0,0x1
ffffffffc020026e:	5ee50513          	addi	a0,a0,1518 # ffffffffc0201858 <etext+0x1c4>
kmonitor(struct trapframe *tf) {
ffffffffc0200272:	ed86                	sd	ra,216(sp)
ffffffffc0200274:	e9a2                	sd	s0,208(sp)
ffffffffc0200276:	e5a6                	sd	s1,200(sp)
ffffffffc0200278:	e1ca                	sd	s2,192(sp)
ffffffffc020027a:	fd4e                	sd	s3,184(sp)
ffffffffc020027c:	f952                	sd	s4,176(sp)
ffffffffc020027e:	f556                	sd	s5,168(sp)
ffffffffc0200280:	f15a                	sd	s6,160(sp)
ffffffffc0200282:	e962                	sd	s8,144(sp)
ffffffffc0200284:	e566                	sd	s9,136(sp)
ffffffffc0200286:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200288:	e2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020028c:	00001517          	auipc	a0,0x1
ffffffffc0200290:	5f450513          	addi	a0,a0,1524 # ffffffffc0201880 <etext+0x1ec>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc0200298:	000b8563          	beqz	s7,ffffffffc02002a2 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029c:	855e                	mv	a0,s7
ffffffffc020029e:	3a4000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a2:	00001c17          	auipc	s8,0x1
ffffffffc02002a6:	64ec0c13          	addi	s8,s8,1614 # ffffffffc02018f0 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002aa:	00001917          	auipc	s2,0x1
ffffffffc02002ae:	5fe90913          	addi	s2,s2,1534 # ffffffffc02018a8 <etext+0x214>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b2:	00001497          	auipc	s1,0x1
ffffffffc02002b6:	5fe48493          	addi	s1,s1,1534 # ffffffffc02018b0 <etext+0x21c>
        if (argc == MAXARGS - 1) {
ffffffffc02002ba:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002bc:	00001b17          	auipc	s6,0x1
ffffffffc02002c0:	5fcb0b13          	addi	s6,s6,1532 # ffffffffc02018b8 <etext+0x224>
        argv[argc ++] = buf;
ffffffffc02002c4:	00001a17          	auipc	s4,0x1
ffffffffc02002c8:	514a0a13          	addi	s4,s4,1300 # ffffffffc02017d8 <etext+0x144>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002cc:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ce:	854a                	mv	a0,s2
ffffffffc02002d0:	25e010ef          	jal	ra,ffffffffc020152e <readline>
ffffffffc02002d4:	842a                	mv	s0,a0
ffffffffc02002d6:	dd65                	beqz	a0,ffffffffc02002ce <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002d8:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002dc:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002de:	e1bd                	bnez	a1,ffffffffc0200344 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02002e0:	fe0c87e3          	beqz	s9,ffffffffc02002ce <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002e4:	6582                	ld	a1,0(sp)
ffffffffc02002e6:	00001d17          	auipc	s10,0x1
ffffffffc02002ea:	60ad0d13          	addi	s10,s10,1546 # ffffffffc02018f0 <commands>
        argv[argc ++] = buf;
ffffffffc02002ee:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4401                	li	s0,0
ffffffffc02002f2:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002f4:	35a010ef          	jal	ra,ffffffffc020164e <strcmp>
ffffffffc02002f8:	c919                	beqz	a0,ffffffffc020030e <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002fa:	2405                	addiw	s0,s0,1
ffffffffc02002fc:	0b540063          	beq	s0,s5,ffffffffc020039c <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200300:	000d3503          	ld	a0,0(s10)
ffffffffc0200304:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200306:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200308:	346010ef          	jal	ra,ffffffffc020164e <strcmp>
ffffffffc020030c:	f57d                	bnez	a0,ffffffffc02002fa <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020030e:	00141793          	slli	a5,s0,0x1
ffffffffc0200312:	97a2                	add	a5,a5,s0
ffffffffc0200314:	078e                	slli	a5,a5,0x3
ffffffffc0200316:	97e2                	add	a5,a5,s8
ffffffffc0200318:	6b9c                	ld	a5,16(a5)
ffffffffc020031a:	865e                	mv	a2,s7
ffffffffc020031c:	002c                	addi	a1,sp,8
ffffffffc020031e:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200322:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200324:	fa0555e3          	bgez	a0,ffffffffc02002ce <kmonitor+0x6a>
}
ffffffffc0200328:	60ee                	ld	ra,216(sp)
ffffffffc020032a:	644e                	ld	s0,208(sp)
ffffffffc020032c:	64ae                	ld	s1,200(sp)
ffffffffc020032e:	690e                	ld	s2,192(sp)
ffffffffc0200330:	79ea                	ld	s3,184(sp)
ffffffffc0200332:	7a4a                	ld	s4,176(sp)
ffffffffc0200334:	7aaa                	ld	s5,168(sp)
ffffffffc0200336:	7b0a                	ld	s6,160(sp)
ffffffffc0200338:	6bea                	ld	s7,152(sp)
ffffffffc020033a:	6c4a                	ld	s8,144(sp)
ffffffffc020033c:	6caa                	ld	s9,136(sp)
ffffffffc020033e:	6d0a                	ld	s10,128(sp)
ffffffffc0200340:	612d                	addi	sp,sp,224
ffffffffc0200342:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200344:	8526                	mv	a0,s1
ffffffffc0200346:	326010ef          	jal	ra,ffffffffc020166c <strchr>
ffffffffc020034a:	c901                	beqz	a0,ffffffffc020035a <kmonitor+0xf6>
ffffffffc020034c:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200350:	00040023          	sb	zero,0(s0)
ffffffffc0200354:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200356:	d5c9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200358:	b7f5                	j	ffffffffc0200344 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc020035a:	00044783          	lbu	a5,0(s0)
ffffffffc020035e:	d3c9                	beqz	a5,ffffffffc02002e0 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200360:	033c8963          	beq	s9,s3,ffffffffc0200392 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc0200364:	003c9793          	slli	a5,s9,0x3
ffffffffc0200368:	0118                	addi	a4,sp,128
ffffffffc020036a:	97ba                	add	a5,a5,a4
ffffffffc020036c:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200370:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200374:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200376:	e591                	bnez	a1,ffffffffc0200382 <kmonitor+0x11e>
ffffffffc0200378:	b7b5                	j	ffffffffc02002e4 <kmonitor+0x80>
ffffffffc020037a:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc020037e:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200380:	d1a5                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200382:	8526                	mv	a0,s1
ffffffffc0200384:	2e8010ef          	jal	ra,ffffffffc020166c <strchr>
ffffffffc0200388:	d96d                	beqz	a0,ffffffffc020037a <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020038a:	00044583          	lbu	a1,0(s0)
ffffffffc020038e:	d9a9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200390:	bf55                	j	ffffffffc0200344 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200392:	45c1                	li	a1,16
ffffffffc0200394:	855a                	mv	a0,s6
ffffffffc0200396:	d1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020039a:	b7e9                	j	ffffffffc0200364 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020039c:	6582                	ld	a1,0(sp)
ffffffffc020039e:	00001517          	auipc	a0,0x1
ffffffffc02003a2:	53a50513          	addi	a0,a0,1338 # ffffffffc02018d8 <etext+0x244>
ffffffffc02003a6:	d0dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    return 0;
ffffffffc02003aa:	b715                	j	ffffffffc02002ce <kmonitor+0x6a>

ffffffffc02003ac <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003ac:	00006317          	auipc	t1,0x6
ffffffffc02003b0:	06430313          	addi	t1,t1,100 # ffffffffc0206410 <is_panic>
ffffffffc02003b4:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b8:	715d                	addi	sp,sp,-80
ffffffffc02003ba:	ec06                	sd	ra,24(sp)
ffffffffc02003bc:	e822                	sd	s0,16(sp)
ffffffffc02003be:	f436                	sd	a3,40(sp)
ffffffffc02003c0:	f83a                	sd	a4,48(sp)
ffffffffc02003c2:	fc3e                	sd	a5,56(sp)
ffffffffc02003c4:	e0c2                	sd	a6,64(sp)
ffffffffc02003c6:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c8:	020e1a63          	bnez	t3,ffffffffc02003fc <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003cc:	4785                	li	a5,1
ffffffffc02003ce:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02003d2:	8432                	mv	s0,a2
ffffffffc02003d4:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d6:	862e                	mv	a2,a1
ffffffffc02003d8:	85aa                	mv	a1,a0
ffffffffc02003da:	00001517          	auipc	a0,0x1
ffffffffc02003de:	55e50513          	addi	a0,a0,1374 # ffffffffc0201938 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02003e2:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e4:	ccfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003e8:	65a2                	ld	a1,8(sp)
ffffffffc02003ea:	8522                	mv	a0,s0
ffffffffc02003ec:	ca7ff0ef          	jal	ra,ffffffffc0200092 <vcprintf>
    cprintf("\n");
ffffffffc02003f0:	00001517          	auipc	a0,0x1
ffffffffc02003f4:	39050513          	addi	a0,a0,912 # ffffffffc0201780 <etext+0xec>
ffffffffc02003f8:	cbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003fc:	062000ef          	jal	ra,ffffffffc020045e <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200400:	4501                	li	a0,0
ffffffffc0200402:	e63ff0ef          	jal	ra,ffffffffc0200264 <kmonitor>
    while (1) {
ffffffffc0200406:	bfed                	j	ffffffffc0200400 <__panic+0x54>

ffffffffc0200408 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc0200408:	1141                	addi	sp,sp,-16
ffffffffc020040a:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc020040c:	02000793          	li	a5,32
ffffffffc0200410:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200414:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200418:	67e1                	lui	a5,0x18
ffffffffc020041a:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020041e:	953e                	add	a0,a0,a5
ffffffffc0200420:	1dc010ef          	jal	ra,ffffffffc02015fc <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	fe07b923          	sd	zero,-14(a5) # ffffffffc0206418 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00001517          	auipc	a0,0x1
ffffffffc0200432:	52a50513          	addi	a0,a0,1322 # ffffffffc0201958 <commands+0x68>
}
ffffffffc0200436:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc0200438:	b9ad                	j	ffffffffc02000b2 <cprintf>

ffffffffc020043a <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020043a:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020043e:	67e1                	lui	a5,0x18
ffffffffc0200440:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200444:	953e                	add	a0,a0,a5
ffffffffc0200446:	1b60106f          	j	ffffffffc02015fc <sbi_set_timer>

ffffffffc020044a <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020044a:	8082                	ret

ffffffffc020044c <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc020044c:	0ff57513          	zext.b	a0,a0
ffffffffc0200450:	1920106f          	j	ffffffffc02015e2 <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	1c20106f          	j	ffffffffc0201616 <sbi_console_getchar>

ffffffffc0200458 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200458:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020045c:	8082                	ret

ffffffffc020045e <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200464:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200468:	00000797          	auipc	a5,0x0
ffffffffc020046c:	2e478793          	addi	a5,a5,740 # ffffffffc020074c <__alltraps>
ffffffffc0200470:	10579073          	csrw	stvec,a5
}
ffffffffc0200474:	8082                	ret

ffffffffc0200476 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200476:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200478:	1141                	addi	sp,sp,-16
ffffffffc020047a:	e022                	sd	s0,0(sp)
ffffffffc020047c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047e:	00001517          	auipc	a0,0x1
ffffffffc0200482:	4fa50513          	addi	a0,a0,1274 # ffffffffc0201978 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00001517          	auipc	a0,0x1
ffffffffc0200492:	50250513          	addi	a0,a0,1282 # ffffffffc0201990 <commands+0xa0>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00001517          	auipc	a0,0x1
ffffffffc02004a0:	50c50513          	addi	a0,a0,1292 # ffffffffc02019a8 <commands+0xb8>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00001517          	auipc	a0,0x1
ffffffffc02004ae:	51650513          	addi	a0,a0,1302 # ffffffffc02019c0 <commands+0xd0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00001517          	auipc	a0,0x1
ffffffffc02004bc:	52050513          	addi	a0,a0,1312 # ffffffffc02019d8 <commands+0xe8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00001517          	auipc	a0,0x1
ffffffffc02004ca:	52a50513          	addi	a0,a0,1322 # ffffffffc02019f0 <commands+0x100>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00001517          	auipc	a0,0x1
ffffffffc02004d8:	53450513          	addi	a0,a0,1332 # ffffffffc0201a08 <commands+0x118>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00001517          	auipc	a0,0x1
ffffffffc02004e6:	53e50513          	addi	a0,a0,1342 # ffffffffc0201a20 <commands+0x130>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00001517          	auipc	a0,0x1
ffffffffc02004f4:	54850513          	addi	a0,a0,1352 # ffffffffc0201a38 <commands+0x148>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00001517          	auipc	a0,0x1
ffffffffc0200502:	55250513          	addi	a0,a0,1362 # ffffffffc0201a50 <commands+0x160>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00001517          	auipc	a0,0x1
ffffffffc0200510:	55c50513          	addi	a0,a0,1372 # ffffffffc0201a68 <commands+0x178>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00001517          	auipc	a0,0x1
ffffffffc020051e:	56650513          	addi	a0,a0,1382 # ffffffffc0201a80 <commands+0x190>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00001517          	auipc	a0,0x1
ffffffffc020052c:	57050513          	addi	a0,a0,1392 # ffffffffc0201a98 <commands+0x1a8>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00001517          	auipc	a0,0x1
ffffffffc020053a:	57a50513          	addi	a0,a0,1402 # ffffffffc0201ab0 <commands+0x1c0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00001517          	auipc	a0,0x1
ffffffffc0200548:	58450513          	addi	a0,a0,1412 # ffffffffc0201ac8 <commands+0x1d8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00001517          	auipc	a0,0x1
ffffffffc0200556:	58e50513          	addi	a0,a0,1422 # ffffffffc0201ae0 <commands+0x1f0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00001517          	auipc	a0,0x1
ffffffffc0200564:	59850513          	addi	a0,a0,1432 # ffffffffc0201af8 <commands+0x208>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00001517          	auipc	a0,0x1
ffffffffc0200572:	5a250513          	addi	a0,a0,1442 # ffffffffc0201b10 <commands+0x220>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00001517          	auipc	a0,0x1
ffffffffc0200580:	5ac50513          	addi	a0,a0,1452 # ffffffffc0201b28 <commands+0x238>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00001517          	auipc	a0,0x1
ffffffffc020058e:	5b650513          	addi	a0,a0,1462 # ffffffffc0201b40 <commands+0x250>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00001517          	auipc	a0,0x1
ffffffffc020059c:	5c050513          	addi	a0,a0,1472 # ffffffffc0201b58 <commands+0x268>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00001517          	auipc	a0,0x1
ffffffffc02005aa:	5ca50513          	addi	a0,a0,1482 # ffffffffc0201b70 <commands+0x280>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00001517          	auipc	a0,0x1
ffffffffc02005b8:	5d450513          	addi	a0,a0,1492 # ffffffffc0201b88 <commands+0x298>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00001517          	auipc	a0,0x1
ffffffffc02005c6:	5de50513          	addi	a0,a0,1502 # ffffffffc0201ba0 <commands+0x2b0>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00001517          	auipc	a0,0x1
ffffffffc02005d4:	5e850513          	addi	a0,a0,1512 # ffffffffc0201bb8 <commands+0x2c8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00001517          	auipc	a0,0x1
ffffffffc02005e2:	5f250513          	addi	a0,a0,1522 # ffffffffc0201bd0 <commands+0x2e0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00001517          	auipc	a0,0x1
ffffffffc02005f0:	5fc50513          	addi	a0,a0,1532 # ffffffffc0201be8 <commands+0x2f8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00001517          	auipc	a0,0x1
ffffffffc02005fe:	60650513          	addi	a0,a0,1542 # ffffffffc0201c00 <commands+0x310>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00001517          	auipc	a0,0x1
ffffffffc020060c:	61050513          	addi	a0,a0,1552 # ffffffffc0201c18 <commands+0x328>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00001517          	auipc	a0,0x1
ffffffffc020061a:	61a50513          	addi	a0,a0,1562 # ffffffffc0201c30 <commands+0x340>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00001517          	auipc	a0,0x1
ffffffffc0200628:	62450513          	addi	a0,a0,1572 # ffffffffc0201c48 <commands+0x358>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00001517          	auipc	a0,0x1
ffffffffc020063a:	62a50513          	addi	a0,a0,1578 # ffffffffc0201c60 <commands+0x370>
}
ffffffffc020063e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200640:	bc8d                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200642 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200642:	1141                	addi	sp,sp,-16
ffffffffc0200644:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200646:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200648:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020064a:	00001517          	auipc	a0,0x1
ffffffffc020064e:	62e50513          	addi	a0,a0,1582 # ffffffffc0201c78 <commands+0x388>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200652:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200654:	a5fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200658:	8522                	mv	a0,s0
ffffffffc020065a:	e1dff0ef          	jal	ra,ffffffffc0200476 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020065e:	10043583          	ld	a1,256(s0)
ffffffffc0200662:	00001517          	auipc	a0,0x1
ffffffffc0200666:	62e50513          	addi	a0,a0,1582 # ffffffffc0201c90 <commands+0x3a0>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00001517          	auipc	a0,0x1
ffffffffc0200676:	63650513          	addi	a0,a0,1590 # ffffffffc0201ca8 <commands+0x3b8>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00001517          	auipc	a0,0x1
ffffffffc0200686:	63e50513          	addi	a0,a0,1598 # ffffffffc0201cc0 <commands+0x3d0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00001517          	auipc	a0,0x1
ffffffffc020069a:	64250513          	addi	a0,a0,1602 # ffffffffc0201cd8 <commands+0x3e8>
}
ffffffffc020069e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a0:	bc09                	j	ffffffffc02000b2 <cprintf>

ffffffffc02006a2 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006a2:	11853783          	ld	a5,280(a0)
ffffffffc02006a6:	472d                	li	a4,11
ffffffffc02006a8:	0786                	slli	a5,a5,0x1
ffffffffc02006aa:	8385                	srli	a5,a5,0x1
ffffffffc02006ac:	06f76c63          	bltu	a4,a5,ffffffffc0200724 <interrupt_handler+0x82>
ffffffffc02006b0:	00001717          	auipc	a4,0x1
ffffffffc02006b4:	70870713          	addi	a4,a4,1800 # ffffffffc0201db8 <commands+0x4c8>
ffffffffc02006b8:	078a                	slli	a5,a5,0x2
ffffffffc02006ba:	97ba                	add	a5,a5,a4
ffffffffc02006bc:	439c                	lw	a5,0(a5)
ffffffffc02006be:	97ba                	add	a5,a5,a4
ffffffffc02006c0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006c2:	00001517          	auipc	a0,0x1
ffffffffc02006c6:	68e50513          	addi	a0,a0,1678 # ffffffffc0201d50 <commands+0x460>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00001517          	auipc	a0,0x1
ffffffffc02006d0:	66450513          	addi	a0,a0,1636 # ffffffffc0201d30 <commands+0x440>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00001517          	auipc	a0,0x1
ffffffffc02006da:	61a50513          	addi	a0,a0,1562 # ffffffffc0201cf0 <commands+0x400>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00001517          	auipc	a0,0x1
ffffffffc02006e4:	69050513          	addi	a0,a0,1680 # ffffffffc0201d70 <commands+0x480>
ffffffffc02006e8:	b2e9                	j	ffffffffc02000b2 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006ea:	1141                	addi	sp,sp,-16
ffffffffc02006ec:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02006ee:	d4dff0ef          	jal	ra,ffffffffc020043a <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02006f2:	00006697          	auipc	a3,0x6
ffffffffc02006f6:	d2668693          	addi	a3,a3,-730 # ffffffffc0206418 <ticks>
ffffffffc02006fa:	629c                	ld	a5,0(a3)
ffffffffc02006fc:	06400713          	li	a4,100
ffffffffc0200700:	0785                	addi	a5,a5,1
ffffffffc0200702:	02e7f733          	remu	a4,a5,a4
ffffffffc0200706:	e29c                	sd	a5,0(a3)
ffffffffc0200708:	cf19                	beqz	a4,ffffffffc0200726 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020070a:	60a2                	ld	ra,8(sp)
ffffffffc020070c:	0141                	addi	sp,sp,16
ffffffffc020070e:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200710:	00001517          	auipc	a0,0x1
ffffffffc0200714:	68850513          	addi	a0,a0,1672 # ffffffffc0201d98 <commands+0x4a8>
ffffffffc0200718:	ba69                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020071a:	00001517          	auipc	a0,0x1
ffffffffc020071e:	5f650513          	addi	a0,a0,1526 # ffffffffc0201d10 <commands+0x420>
ffffffffc0200722:	ba41                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200724:	bf39                	j	ffffffffc0200642 <print_trapframe>
}
ffffffffc0200726:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200728:	06400593          	li	a1,100
ffffffffc020072c:	00001517          	auipc	a0,0x1
ffffffffc0200730:	65c50513          	addi	a0,a0,1628 # ffffffffc0201d88 <commands+0x498>
}
ffffffffc0200734:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200736:	bab5                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200738 <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200738:	11853783          	ld	a5,280(a0)
ffffffffc020073c:	0007c763          	bltz	a5,ffffffffc020074a <trap+0x12>
    switch (tf->cause) {
ffffffffc0200740:	472d                	li	a4,11
ffffffffc0200742:	00f76363          	bltu	a4,a5,ffffffffc0200748 <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200746:	8082                	ret
            print_trapframe(tf);
ffffffffc0200748:	bded                	j	ffffffffc0200642 <print_trapframe>
        interrupt_handler(tf);
ffffffffc020074a:	bfa1                	j	ffffffffc02006a2 <interrupt_handler>

ffffffffc020074c <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc020074c:	14011073          	csrw	sscratch,sp
ffffffffc0200750:	712d                	addi	sp,sp,-288
ffffffffc0200752:	e002                	sd	zero,0(sp)
ffffffffc0200754:	e406                	sd	ra,8(sp)
ffffffffc0200756:	ec0e                	sd	gp,24(sp)
ffffffffc0200758:	f012                	sd	tp,32(sp)
ffffffffc020075a:	f416                	sd	t0,40(sp)
ffffffffc020075c:	f81a                	sd	t1,48(sp)
ffffffffc020075e:	fc1e                	sd	t2,56(sp)
ffffffffc0200760:	e0a2                	sd	s0,64(sp)
ffffffffc0200762:	e4a6                	sd	s1,72(sp)
ffffffffc0200764:	e8aa                	sd	a0,80(sp)
ffffffffc0200766:	ecae                	sd	a1,88(sp)
ffffffffc0200768:	f0b2                	sd	a2,96(sp)
ffffffffc020076a:	f4b6                	sd	a3,104(sp)
ffffffffc020076c:	f8ba                	sd	a4,112(sp)
ffffffffc020076e:	fcbe                	sd	a5,120(sp)
ffffffffc0200770:	e142                	sd	a6,128(sp)
ffffffffc0200772:	e546                	sd	a7,136(sp)
ffffffffc0200774:	e94a                	sd	s2,144(sp)
ffffffffc0200776:	ed4e                	sd	s3,152(sp)
ffffffffc0200778:	f152                	sd	s4,160(sp)
ffffffffc020077a:	f556                	sd	s5,168(sp)
ffffffffc020077c:	f95a                	sd	s6,176(sp)
ffffffffc020077e:	fd5e                	sd	s7,184(sp)
ffffffffc0200780:	e1e2                	sd	s8,192(sp)
ffffffffc0200782:	e5e6                	sd	s9,200(sp)
ffffffffc0200784:	e9ea                	sd	s10,208(sp)
ffffffffc0200786:	edee                	sd	s11,216(sp)
ffffffffc0200788:	f1f2                	sd	t3,224(sp)
ffffffffc020078a:	f5f6                	sd	t4,232(sp)
ffffffffc020078c:	f9fa                	sd	t5,240(sp)
ffffffffc020078e:	fdfe                	sd	t6,248(sp)
ffffffffc0200790:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200794:	100024f3          	csrr	s1,sstatus
ffffffffc0200798:	14102973          	csrr	s2,sepc
ffffffffc020079c:	143029f3          	csrr	s3,stval
ffffffffc02007a0:	14202a73          	csrr	s4,scause
ffffffffc02007a4:	e822                	sd	s0,16(sp)
ffffffffc02007a6:	e226                	sd	s1,256(sp)
ffffffffc02007a8:	e64a                	sd	s2,264(sp)
ffffffffc02007aa:	ea4e                	sd	s3,272(sp)
ffffffffc02007ac:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007ae:	850a                	mv	a0,sp
    jal trap
ffffffffc02007b0:	f89ff0ef          	jal	ra,ffffffffc0200738 <trap>

ffffffffc02007b4 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007b4:	6492                	ld	s1,256(sp)
ffffffffc02007b6:	6932                	ld	s2,264(sp)
ffffffffc02007b8:	10049073          	csrw	sstatus,s1
ffffffffc02007bc:	14191073          	csrw	sepc,s2
ffffffffc02007c0:	60a2                	ld	ra,8(sp)
ffffffffc02007c2:	61e2                	ld	gp,24(sp)
ffffffffc02007c4:	7202                	ld	tp,32(sp)
ffffffffc02007c6:	72a2                	ld	t0,40(sp)
ffffffffc02007c8:	7342                	ld	t1,48(sp)
ffffffffc02007ca:	73e2                	ld	t2,56(sp)
ffffffffc02007cc:	6406                	ld	s0,64(sp)
ffffffffc02007ce:	64a6                	ld	s1,72(sp)
ffffffffc02007d0:	6546                	ld	a0,80(sp)
ffffffffc02007d2:	65e6                	ld	a1,88(sp)
ffffffffc02007d4:	7606                	ld	a2,96(sp)
ffffffffc02007d6:	76a6                	ld	a3,104(sp)
ffffffffc02007d8:	7746                	ld	a4,112(sp)
ffffffffc02007da:	77e6                	ld	a5,120(sp)
ffffffffc02007dc:	680a                	ld	a6,128(sp)
ffffffffc02007de:	68aa                	ld	a7,136(sp)
ffffffffc02007e0:	694a                	ld	s2,144(sp)
ffffffffc02007e2:	69ea                	ld	s3,152(sp)
ffffffffc02007e4:	7a0a                	ld	s4,160(sp)
ffffffffc02007e6:	7aaa                	ld	s5,168(sp)
ffffffffc02007e8:	7b4a                	ld	s6,176(sp)
ffffffffc02007ea:	7bea                	ld	s7,184(sp)
ffffffffc02007ec:	6c0e                	ld	s8,192(sp)
ffffffffc02007ee:	6cae                	ld	s9,200(sp)
ffffffffc02007f0:	6d4e                	ld	s10,208(sp)
ffffffffc02007f2:	6dee                	ld	s11,216(sp)
ffffffffc02007f4:	7e0e                	ld	t3,224(sp)
ffffffffc02007f6:	7eae                	ld	t4,232(sp)
ffffffffc02007f8:	7f4e                	ld	t5,240(sp)
ffffffffc02007fa:	7fee                	ld	t6,248(sp)
ffffffffc02007fc:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc02007fe:	10200073          	sret

ffffffffc0200802 <buddy_init>:
    x |= x >> 8;
    x |= x >> 16;
    return x + 1; // 得到下一个 2 的幂
}
*/
static void buddy_init(void) {}
ffffffffc0200802:	8082                	ret

ffffffffc0200804 <buddy_nr_free_pages>:
        }
    }
}

static size_t buddy_nr_free_pages(void) {
    return buddy_free_tree[1];
ffffffffc0200804:	00006797          	auipc	a5,0x6
ffffffffc0200808:	c2c7b783          	ld	a5,-980(a5) # ffffffffc0206430 <buddy_free_tree>
}
ffffffffc020080c:	0047e503          	lwu	a0,4(a5)
ffffffffc0200810:	8082                	ret

ffffffffc0200812 <buddy_free_pages>:
static void buddy_free_pages(struct Page *base, size_t n) {
ffffffffc0200812:	1141                	addi	sp,sp,-16
ffffffffc0200814:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200816:	c5f5                	beqz	a1,ffffffffc0200902 <buddy_free_pages+0xf0>
    unsigned int start_index = (unsigned int)(base - available_page_start);
ffffffffc0200818:	00006617          	auipc	a2,0x6
ffffffffc020081c:	c1063603          	ld	a2,-1008(a2) # ffffffffc0206428 <available_page_start>
ffffffffc0200820:	40c50633          	sub	a2,a0,a2
ffffffffc0200824:	860d                	srai	a2,a2,0x3
ffffffffc0200826:	00002797          	auipc	a5,0x2
ffffffffc020082a:	bb27b783          	ld	a5,-1102(a5) # ffffffffc02023d8 <error_string+0x38>
ffffffffc020082e:	02f607b3          	mul	a5,a2,a5
    unsigned int index = available_page_count + start_index;
ffffffffc0200832:	00006617          	auipc	a2,0x6
ffffffffc0200836:	bee62603          	lw	a2,-1042(a2) # ffffffffc0206420 <available_page_count>
    for (size_t i = 0; i < n; i++) {
ffffffffc020083a:	4681                	li	a3,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020083c:	4809                	li	a6,2
    unsigned int index = available_page_count + start_index;
ffffffffc020083e:	9e3d                	addw	a2,a2,a5
ffffffffc0200840:	0006071b          	sext.w	a4,a2
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200844:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200846:	8b85                	andi	a5,a5,1
ffffffffc0200848:	efc9                	bnez	a5,ffffffffc02008e2 <buddy_free_pages+0xd0>
ffffffffc020084a:	651c                	ld	a5,8(a0)
ffffffffc020084c:	8b89                	andi	a5,a5,2
ffffffffc020084e:	ebd1                	bnez	a5,ffffffffc02008e2 <buddy_free_pages+0xd0>
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200850:	00850793          	addi	a5,a0,8
ffffffffc0200854:	4107b02f          	amoor.d	zero,a6,(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200858:	00052023          	sw	zero,0(a0)
    for (size_t i = 0; i < n; i++) {
ffffffffc020085c:	0685                	addi	a3,a3,1
ffffffffc020085e:	02850513          	addi	a0,a0,40
ffffffffc0200862:	fed591e3          	bne	a1,a3,ffffffffc0200844 <buddy_free_pages+0x32>
    for (; buddy_free_tree[index] > 0; index = PARENT(index)) {
ffffffffc0200866:	02061793          	slli	a5,a2,0x20
ffffffffc020086a:	01e7d613          	srli	a2,a5,0x1e
ffffffffc020086e:	00006597          	auipc	a1,0x6
ffffffffc0200872:	bc25b583          	ld	a1,-1086(a1) # ffffffffc0206430 <buddy_free_tree>
ffffffffc0200876:	962e                	add	a2,a2,a1
ffffffffc0200878:	421c                	lw	a5,0(a2)
    unsigned int size = 1;
ffffffffc020087a:	4685                	li	a3,1
    for (; buddy_free_tree[index] > 0; index = PARENT(index)) {
ffffffffc020087c:	cf89                	beqz	a5,ffffffffc0200896 <buddy_free_pages+0x84>
ffffffffc020087e:	0017579b          	srliw	a5,a4,0x1
ffffffffc0200882:	02079613          	slli	a2,a5,0x20
ffffffffc0200886:	8279                	srli	a2,a2,0x1e
ffffffffc0200888:	962e                	add	a2,a2,a1
ffffffffc020088a:	4208                	lw	a0,0(a2)
        size *= 2;
ffffffffc020088c:	0016969b          	slliw	a3,a3,0x1
    for (; buddy_free_tree[index] > 0; index = PARENT(index)) {
ffffffffc0200890:	0007871b          	sext.w	a4,a5
ffffffffc0200894:	f56d                	bnez	a0,ffffffffc020087e <buddy_free_pages+0x6c>
    buddy_free_tree[index] = size;
ffffffffc0200896:	c214                	sw	a3,0(a2)
    for (index = PARENT(index); index > 0; index = PARENT(index)) {
ffffffffc0200898:	0017579b          	srliw	a5,a4,0x1
ffffffffc020089c:	c3a1                	beqz	a5,ffffffffc02008dc <buddy_free_pages+0xca>
        if (buddy_free_tree[LEFT_CHILD(index)] + buddy_free_tree[RIGHT_CHILD(index)] == size) {
ffffffffc020089e:	0017971b          	slliw	a4,a5,0x1
ffffffffc02008a2:	2705                	addiw	a4,a4,1
ffffffffc02008a4:	02071513          	slli	a0,a4,0x20
ffffffffc02008a8:	01e55713          	srli	a4,a0,0x1e
ffffffffc02008ac:	00379613          	slli	a2,a5,0x3
ffffffffc02008b0:	972e                	add	a4,a4,a1
ffffffffc02008b2:	962e                	add	a2,a2,a1
ffffffffc02008b4:	4308                	lw	a0,0(a4)
ffffffffc02008b6:	4210                	lw	a2,0(a2)
        size *= 2;
ffffffffc02008b8:	0016969b          	slliw	a3,a3,0x1
            buddy_free_tree[index] = size;
ffffffffc02008bc:	00279713          	slli	a4,a5,0x2
        if (buddy_free_tree[LEFT_CHILD(index)] + buddy_free_tree[RIGHT_CHILD(index)] == size) {
ffffffffc02008c0:	00a608bb          	addw	a7,a2,a0
        size *= 2;
ffffffffc02008c4:	8836                	mv	a6,a3
            buddy_free_tree[index] = size;
ffffffffc02008c6:	972e                	add	a4,a4,a1
        if (buddy_free_tree[LEFT_CHILD(index)] + buddy_free_tree[RIGHT_CHILD(index)] == size) {
ffffffffc02008c8:	00d88663          	beq	a7,a3,ffffffffc02008d4 <buddy_free_pages+0xc2>
            buddy_free_tree[index] = MAX(buddy_free_tree[LEFT_CHILD(index)], buddy_free_tree[RIGHT_CHILD(index)]);
ffffffffc02008cc:	8832                	mv	a6,a2
ffffffffc02008ce:	00a67363          	bgeu	a2,a0,ffffffffc02008d4 <buddy_free_pages+0xc2>
ffffffffc02008d2:	882a                	mv	a6,a0
ffffffffc02008d4:	01072023          	sw	a6,0(a4)
    for (index = PARENT(index); index > 0; index = PARENT(index)) {
ffffffffc02008d8:	8385                	srli	a5,a5,0x1
ffffffffc02008da:	f3f1                	bnez	a5,ffffffffc020089e <buddy_free_pages+0x8c>
}
ffffffffc02008dc:	60a2                	ld	ra,8(sp)
ffffffffc02008de:	0141                	addi	sp,sp,16
ffffffffc02008e0:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02008e2:	00001697          	auipc	a3,0x1
ffffffffc02008e6:	53e68693          	addi	a3,a3,1342 # ffffffffc0201e20 <commands+0x530>
ffffffffc02008ea:	00001617          	auipc	a2,0x1
ffffffffc02008ee:	50660613          	addi	a2,a2,1286 # ffffffffc0201df0 <commands+0x500>
ffffffffc02008f2:	06500593          	li	a1,101
ffffffffc02008f6:	00001517          	auipc	a0,0x1
ffffffffc02008fa:	51250513          	addi	a0,a0,1298 # ffffffffc0201e08 <commands+0x518>
ffffffffc02008fe:	aafff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0200902:	00001697          	auipc	a3,0x1
ffffffffc0200906:	4e668693          	addi	a3,a3,1254 # ffffffffc0201de8 <commands+0x4f8>
ffffffffc020090a:	00001617          	auipc	a2,0x1
ffffffffc020090e:	4e660613          	addi	a2,a2,1254 # ffffffffc0201df0 <commands+0x500>
ffffffffc0200912:	05f00593          	li	a1,95
ffffffffc0200916:	00001517          	auipc	a0,0x1
ffffffffc020091a:	4f250513          	addi	a0,a0,1266 # ffffffffc0201e08 <commands+0x518>
ffffffffc020091e:	a8fff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200922 <buddy_alloc_pages>:
    assert(n > 0);
ffffffffc0200922:	c965                	beqz	a0,ffffffffc0200a12 <buddy_alloc_pages+0xf0>
    if (n > buddy_free_tree[1]) {
ffffffffc0200924:	00006817          	auipc	a6,0x6
ffffffffc0200928:	b0c80813          	addi	a6,a6,-1268 # ffffffffc0206430 <buddy_free_tree>
ffffffffc020092c:	00083583          	ld	a1,0(a6)
ffffffffc0200930:	0045e783          	lwu	a5,4(a1)
ffffffffc0200934:	0ca7ed63          	bltu	a5,a0,ffffffffc0200a0e <buddy_alloc_pages+0xec>
    unsigned int index = 1;
ffffffffc0200938:	4705                	li	a4,1
        if (buddy_free_tree[LEFT_CHILD(index)] >= n) {
ffffffffc020093a:	0017169b          	slliw	a3,a4,0x1
ffffffffc020093e:	02069793          	slli	a5,a3,0x20
ffffffffc0200942:	83f9                	srli	a5,a5,0x1e
ffffffffc0200944:	97ae                	add	a5,a5,a1
ffffffffc0200946:	0007e783          	lwu	a5,0(a5)
ffffffffc020094a:	0007061b          	sext.w	a2,a4
ffffffffc020094e:	0006871b          	sext.w	a4,a3
ffffffffc0200952:	fea7f4e3          	bgeu	a5,a0,ffffffffc020093a <buddy_alloc_pages+0x18>
        } else if (buddy_free_tree[RIGHT_CHILD(index)] >= n) {
ffffffffc0200956:	2705                	addiw	a4,a4,1
ffffffffc0200958:	02071693          	slli	a3,a4,0x20
ffffffffc020095c:	01e6d793          	srli	a5,a3,0x1e
ffffffffc0200960:	97ae                	add	a5,a5,a1
ffffffffc0200962:	0007e783          	lwu	a5,0(a5)
ffffffffc0200966:	fca7fae3          	bgeu	a5,a0,ffffffffc020093a <buddy_alloc_pages+0x18>
    unsigned int allocated_size = buddy_free_tree[index];
ffffffffc020096a:	02061713          	slli	a4,a2,0x20
ffffffffc020096e:	01e75793          	srli	a5,a4,0x1e
ffffffffc0200972:	95be                	add	a1,a1,a5
ffffffffc0200974:	4198                	lw	a4,0(a1)
    struct Page* allocated_page = &available_page_start[(index * allocated_size) - available_page_count];
ffffffffc0200976:	00006517          	auipc	a0,0x6
ffffffffc020097a:	ab253503          	ld	a0,-1358(a0) # ffffffffc0206428 <available_page_start>
    buddy_free_tree[index] = 0; 
ffffffffc020097e:	0005a023          	sw	zero,0(a1)
    struct Page* allocated_page = &available_page_start[(index * allocated_size) - available_page_count];
ffffffffc0200982:	02e607bb          	mulw	a5,a2,a4
    struct Page* end_page = allocated_page + allocated_size; 
ffffffffc0200986:	02071693          	slli	a3,a4,0x20
ffffffffc020098a:	9281                	srli	a3,a3,0x20
ffffffffc020098c:	00269713          	slli	a4,a3,0x2
ffffffffc0200990:	9736                	add	a4,a4,a3
    struct Page* allocated_page = &available_page_start[(index * allocated_size) - available_page_count];
ffffffffc0200992:	00006697          	auipc	a3,0x6
ffffffffc0200996:	a8e6a683          	lw	a3,-1394(a3) # ffffffffc0206420 <available_page_count>
    struct Page* end_page = allocated_page + allocated_size; 
ffffffffc020099a:	070e                	slli	a4,a4,0x3
    struct Page* allocated_page = &available_page_start[(index * allocated_size) - available_page_count];
ffffffffc020099c:	9f95                	subw	a5,a5,a3
ffffffffc020099e:	1782                	slli	a5,a5,0x20
ffffffffc02009a0:	9381                	srli	a5,a5,0x20
ffffffffc02009a2:	00279693          	slli	a3,a5,0x2
ffffffffc02009a6:	97b6                	add	a5,a5,a3
ffffffffc02009a8:	078e                	slli	a5,a5,0x3
ffffffffc02009aa:	953e                	add	a0,a0,a5
    struct Page* end_page = allocated_page + allocated_size; 
ffffffffc02009ac:	972a                	add	a4,a4,a0
    for (struct Page* p = allocated_page; p < end_page; p++) {
ffffffffc02009ae:	00e57e63          	bgeu	a0,a4,ffffffffc02009ca <buddy_alloc_pages+0xa8>
ffffffffc02009b2:	87aa                	mv	a5,a0
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02009b4:	56f5                	li	a3,-3
ffffffffc02009b6:	00878593          	addi	a1,a5,8
ffffffffc02009ba:	60d5b02f          	amoand.d	zero,a3,(a1)
ffffffffc02009be:	0007a023          	sw	zero,0(a5)
ffffffffc02009c2:	02878793          	addi	a5,a5,40
ffffffffc02009c6:	fee7e8e3          	bltu	a5,a4,ffffffffc02009b6 <buddy_alloc_pages+0x94>
    for (unsigned int parent_idx = PARENT(index); parent_idx > 0; parent_idx = PARENT(parent_idx)) {
ffffffffc02009ca:	0016561b          	srliw	a2,a2,0x1
ffffffffc02009ce:	c229                	beqz	a2,ffffffffc0200a10 <buddy_alloc_pages+0xee>
        buddy_free_tree[parent_idx] = MAX(buddy_free_tree[left_child], buddy_free_tree[right_child]);
ffffffffc02009d0:	00083683          	ld	a3,0(a6)
        unsigned int left_child = LEFT_CHILD(parent_idx);
ffffffffc02009d4:	0016179b          	slliw	a5,a2,0x1
        unsigned int right_child = RIGHT_CHILD(parent_idx);
ffffffffc02009d8:	0017871b          	addiw	a4,a5,1
        buddy_free_tree[parent_idx] = MAX(buddy_free_tree[left_child], buddy_free_tree[right_child]);
ffffffffc02009dc:	1782                	slli	a5,a5,0x20
ffffffffc02009de:	02071593          	slli	a1,a4,0x20
ffffffffc02009e2:	9381                	srli	a5,a5,0x20
ffffffffc02009e4:	01e5d713          	srli	a4,a1,0x1e
ffffffffc02009e8:	078a                	slli	a5,a5,0x2
ffffffffc02009ea:	97b6                	add	a5,a5,a3
ffffffffc02009ec:	9736                	add	a4,a4,a3
ffffffffc02009ee:	438c                	lw	a1,0(a5)
ffffffffc02009f0:	4318                	lw	a4,0(a4)
ffffffffc02009f2:	00261793          	slli	a5,a2,0x2
ffffffffc02009f6:	0005881b          	sext.w	a6,a1
ffffffffc02009fa:	0007089b          	sext.w	a7,a4
ffffffffc02009fe:	97b6                	add	a5,a5,a3
ffffffffc0200a00:	0108f363          	bgeu	a7,a6,ffffffffc0200a06 <buddy_alloc_pages+0xe4>
ffffffffc0200a04:	872e                	mv	a4,a1
ffffffffc0200a06:	c398                	sw	a4,0(a5)
    for (unsigned int parent_idx = PARENT(index); parent_idx > 0; parent_idx = PARENT(parent_idx)) {
ffffffffc0200a08:	8205                	srli	a2,a2,0x1
ffffffffc0200a0a:	f669                	bnez	a2,ffffffffc02009d4 <buddy_alloc_pages+0xb2>
ffffffffc0200a0c:	8082                	ret
        return NULL;
ffffffffc0200a0e:	4501                	li	a0,0
}
ffffffffc0200a10:	8082                	ret
static struct Page* buddy_alloc_pages(size_t n) {
ffffffffc0200a12:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200a14:	00001697          	auipc	a3,0x1
ffffffffc0200a18:	3d468693          	addi	a3,a3,980 # ffffffffc0201de8 <commands+0x4f8>
ffffffffc0200a1c:	00001617          	auipc	a2,0x1
ffffffffc0200a20:	3d460613          	addi	a2,a2,980 # ffffffffc0201df0 <commands+0x500>
ffffffffc0200a24:	04000593          	li	a1,64
ffffffffc0200a28:	00001517          	auipc	a0,0x1
ffffffffc0200a2c:	3e050513          	addi	a0,a0,992 # ffffffffc0201e08 <commands+0x518>
static struct Page* buddy_alloc_pages(size_t n) {
ffffffffc0200a30:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200a32:	97bff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200a36 <buddy_check>:



static void
buddy_check(void) {
ffffffffc0200a36:	7179                	addi	sp,sp,-48
ffffffffc0200a38:	e44e                	sd	s3,8(sp)
ffffffffc0200a3a:	f406                	sd	ra,40(sp)
ffffffffc0200a3c:	f022                	sd	s0,32(sp)
ffffffffc0200a3e:	ec26                	sd	s1,24(sp)
ffffffffc0200a40:	e84a                	sd	s2,16(sp)
ffffffffc0200a42:	e052                	sd	s4,0(sp)
    int all_pages = nr_free_pages();
ffffffffc0200a44:	52e000ef          	jal	ra,ffffffffc0200f72 <nr_free_pages>
ffffffffc0200a48:	89aa                	mv	s3,a0
    struct Page* p0, *p1, *p2, *p3;
    // 分配过大的页数
    assert(alloc_pages(all_pages + 1) == NULL);
ffffffffc0200a4a:	2505                	addiw	a0,a0,1
ffffffffc0200a4c:	4a8000ef          	jal	ra,ffffffffc0200ef4 <alloc_pages>
ffffffffc0200a50:	26051263          	bnez	a0,ffffffffc0200cb4 <buddy_check+0x27e>
    // 分配两个组页
    p0 = alloc_pages(1);
ffffffffc0200a54:	4505                	li	a0,1
ffffffffc0200a56:	49e000ef          	jal	ra,ffffffffc0200ef4 <alloc_pages>
ffffffffc0200a5a:	842a                	mv	s0,a0
    assert(p0 != NULL);
ffffffffc0200a5c:	22050c63          	beqz	a0,ffffffffc0200c94 <buddy_check+0x25e>
    p1 = alloc_pages(2);
ffffffffc0200a60:	4509                	li	a0,2
ffffffffc0200a62:	492000ef          	jal	ra,ffffffffc0200ef4 <alloc_pages>
    assert(p1 == p0 + 2);
ffffffffc0200a66:	05040793          	addi	a5,s0,80
    p1 = alloc_pages(2);
ffffffffc0200a6a:	84aa                	mv	s1,a0
    assert(p1 == p0 + 2);
ffffffffc0200a6c:	1af51463          	bne	a0,a5,ffffffffc0200c14 <buddy_check+0x1de>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200a70:	641c                	ld	a5,8(s0)
    assert(!PageReserved(p0) && !PageProperty(p0));
ffffffffc0200a72:	8b85                	andi	a5,a5,1
ffffffffc0200a74:	12079063          	bnez	a5,ffffffffc0200b94 <buddy_check+0x15e>
ffffffffc0200a78:	641c                	ld	a5,8(s0)
ffffffffc0200a7a:	8385                	srli	a5,a5,0x1
ffffffffc0200a7c:	8b85                	andi	a5,a5,1
ffffffffc0200a7e:	10079b63          	bnez	a5,ffffffffc0200b94 <buddy_check+0x15e>
ffffffffc0200a82:	651c                	ld	a5,8(a0)
    assert(!PageReserved(p1) && !PageProperty(p1));
ffffffffc0200a84:	8b85                	andi	a5,a5,1
ffffffffc0200a86:	0e079763          	bnez	a5,ffffffffc0200b74 <buddy_check+0x13e>
ffffffffc0200a8a:	651c                	ld	a5,8(a0)
ffffffffc0200a8c:	8385                	srli	a5,a5,0x1
ffffffffc0200a8e:	8b85                	andi	a5,a5,1
ffffffffc0200a90:	0e079263          	bnez	a5,ffffffffc0200b74 <buddy_check+0x13e>
    // 再分配两个组页
    p2 = alloc_pages(1);
ffffffffc0200a94:	4505                	li	a0,1
ffffffffc0200a96:	45e000ef          	jal	ra,ffffffffc0200ef4 <alloc_pages>
    assert(p2 == p0 + 1);
ffffffffc0200a9a:	02840793          	addi	a5,s0,40
    p2 = alloc_pages(1);
ffffffffc0200a9e:	8a2a                	mv	s4,a0
    assert(p2 == p0 + 1);
ffffffffc0200aa0:	12f51a63          	bne	a0,a5,ffffffffc0200bd4 <buddy_check+0x19e>
    p3 = alloc_pages(8);
ffffffffc0200aa4:	4521                	li	a0,8
ffffffffc0200aa6:	44e000ef          	jal	ra,ffffffffc0200ef4 <alloc_pages>
    assert(p3 == p0 + 8);
ffffffffc0200aaa:	14040793          	addi	a5,s0,320
    p3 = alloc_pages(8);
ffffffffc0200aae:	892a                	mv	s2,a0
    assert(p3 == p0 + 8);
ffffffffc0200ab0:	24f51263          	bne	a0,a5,ffffffffc0200cf4 <buddy_check+0x2be>
ffffffffc0200ab4:	651c                	ld	a5,8(a0)
ffffffffc0200ab6:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p3) && !PageProperty(p3 + 7) && PageProperty(p3 + 8));
ffffffffc0200ab8:	8b85                	andi	a5,a5,1
ffffffffc0200aba:	efc9                	bnez	a5,ffffffffc0200b54 <buddy_check+0x11e>
ffffffffc0200abc:	12053783          	ld	a5,288(a0)
ffffffffc0200ac0:	8385                	srli	a5,a5,0x1
ffffffffc0200ac2:	8b85                	andi	a5,a5,1
ffffffffc0200ac4:	ebc1                	bnez	a5,ffffffffc0200b54 <buddy_check+0x11e>
ffffffffc0200ac6:	14853783          	ld	a5,328(a0)
ffffffffc0200aca:	8385                	srli	a5,a5,0x1
ffffffffc0200acc:	8b85                	andi	a5,a5,1
ffffffffc0200ace:	c3d9                	beqz	a5,ffffffffc0200b54 <buddy_check+0x11e>
    // 回收页
    free_pages(p1, 2);
ffffffffc0200ad0:	4589                	li	a1,2
ffffffffc0200ad2:	8526                	mv	a0,s1
ffffffffc0200ad4:	45e000ef          	jal	ra,ffffffffc0200f32 <free_pages>
ffffffffc0200ad8:	649c                	ld	a5,8(s1)
ffffffffc0200ada:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && PageProperty(p1 + 1));
ffffffffc0200adc:	8b85                	andi	a5,a5,1
ffffffffc0200ade:	0c078b63          	beqz	a5,ffffffffc0200bb4 <buddy_check+0x17e>
ffffffffc0200ae2:	789c                	ld	a5,48(s1)
ffffffffc0200ae4:	8385                	srli	a5,a5,0x1
ffffffffc0200ae6:	8b85                	andi	a5,a5,1
ffffffffc0200ae8:	c7f1                	beqz	a5,ffffffffc0200bb4 <buddy_check+0x17e>
    assert(p1->ref == 0);
ffffffffc0200aea:	409c                	lw	a5,0(s1)
ffffffffc0200aec:	14079463          	bnez	a5,ffffffffc0200c34 <buddy_check+0x1fe>
    free_pages(p0, 1);
ffffffffc0200af0:	4585                	li	a1,1
ffffffffc0200af2:	8522                	mv	a0,s0
ffffffffc0200af4:	43e000ef          	jal	ra,ffffffffc0200f32 <free_pages>
    free_pages(p2, 1);
ffffffffc0200af8:	8552                	mv	a0,s4
ffffffffc0200afa:	4585                	li	a1,1
ffffffffc0200afc:	436000ef          	jal	ra,ffffffffc0200f32 <free_pages>
    // 回收后再分配
    p2 = alloc_pages(3);
ffffffffc0200b00:	450d                	li	a0,3
ffffffffc0200b02:	3f2000ef          	jal	ra,ffffffffc0200ef4 <alloc_pages>
    assert(p2 == p0);
ffffffffc0200b06:	16a41763          	bne	s0,a0,ffffffffc0200c74 <buddy_check+0x23e>
    free_pages(p2, 3);
ffffffffc0200b0a:	458d                	li	a1,3
ffffffffc0200b0c:	426000ef          	jal	ra,ffffffffc0200f32 <free_pages>
    assert((p2 + 2)->ref == 0);
ffffffffc0200b10:	483c                	lw	a5,80(s0)
ffffffffc0200b12:	14079163          	bnez	a5,ffffffffc0200c54 <buddy_check+0x21e>
    assert(nr_free_pages() == all_pages >> 1);
ffffffffc0200b16:	2981                	sext.w	s3,s3
ffffffffc0200b18:	45a000ef          	jal	ra,ffffffffc0200f72 <nr_free_pages>
ffffffffc0200b1c:	4019d993          	srai	s3,s3,0x1
ffffffffc0200b20:	0d351a63          	bne	a0,s3,ffffffffc0200bf4 <buddy_check+0x1be>

    p1 = alloc_pages(129);
ffffffffc0200b24:	08100513          	li	a0,129
ffffffffc0200b28:	3cc000ef          	jal	ra,ffffffffc0200ef4 <alloc_pages>
    assert(p1 == p0 + 256);
ffffffffc0200b2c:	678d                	lui	a5,0x3
ffffffffc0200b2e:	80078793          	addi	a5,a5,-2048 # 2800 <kern_entry-0xffffffffc01fd800>
ffffffffc0200b32:	943e                	add	s0,s0,a5
ffffffffc0200b34:	1a851063          	bne	a0,s0,ffffffffc0200cd4 <buddy_check+0x29e>
    free_pages(p1, 256);
ffffffffc0200b38:	10000593          	li	a1,256
ffffffffc0200b3c:	3f6000ef          	jal	ra,ffffffffc0200f32 <free_pages>
    free_pages(p3, 8);
}
ffffffffc0200b40:	7402                	ld	s0,32(sp)
ffffffffc0200b42:	70a2                	ld	ra,40(sp)
ffffffffc0200b44:	64e2                	ld	s1,24(sp)
ffffffffc0200b46:	69a2                	ld	s3,8(sp)
ffffffffc0200b48:	6a02                	ld	s4,0(sp)
    free_pages(p3, 8);
ffffffffc0200b4a:	854a                	mv	a0,s2
}
ffffffffc0200b4c:	6942                	ld	s2,16(sp)
    free_pages(p3, 8);
ffffffffc0200b4e:	45a1                	li	a1,8
}
ffffffffc0200b50:	6145                	addi	sp,sp,48
    free_pages(p3, 8);
ffffffffc0200b52:	a6c5                	j	ffffffffc0200f32 <free_pages>
    assert(!PageProperty(p3) && !PageProperty(p3 + 7) && PageProperty(p3 + 8));
ffffffffc0200b54:	00001697          	auipc	a3,0x1
ffffffffc0200b58:	3ac68693          	addi	a3,a3,940 # ffffffffc0201f00 <commands+0x610>
ffffffffc0200b5c:	00001617          	auipc	a2,0x1
ffffffffc0200b60:	29460613          	addi	a2,a2,660 # ffffffffc0201df0 <commands+0x500>
ffffffffc0200b64:	09000593          	li	a1,144
ffffffffc0200b68:	00001517          	auipc	a0,0x1
ffffffffc0200b6c:	2a050513          	addi	a0,a0,672 # ffffffffc0201e08 <commands+0x518>
ffffffffc0200b70:	83dff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!PageReserved(p1) && !PageProperty(p1));
ffffffffc0200b74:	00001697          	auipc	a3,0x1
ffffffffc0200b78:	34468693          	addi	a3,a3,836 # ffffffffc0201eb8 <commands+0x5c8>
ffffffffc0200b7c:	00001617          	auipc	a2,0x1
ffffffffc0200b80:	27460613          	addi	a2,a2,628 # ffffffffc0201df0 <commands+0x500>
ffffffffc0200b84:	08a00593          	li	a1,138
ffffffffc0200b88:	00001517          	auipc	a0,0x1
ffffffffc0200b8c:	28050513          	addi	a0,a0,640 # ffffffffc0201e08 <commands+0x518>
ffffffffc0200b90:	81dff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!PageReserved(p0) && !PageProperty(p0));
ffffffffc0200b94:	00001697          	auipc	a3,0x1
ffffffffc0200b98:	2fc68693          	addi	a3,a3,764 # ffffffffc0201e90 <commands+0x5a0>
ffffffffc0200b9c:	00001617          	auipc	a2,0x1
ffffffffc0200ba0:	25460613          	addi	a2,a2,596 # ffffffffc0201df0 <commands+0x500>
ffffffffc0200ba4:	08900593          	li	a1,137
ffffffffc0200ba8:	00001517          	auipc	a0,0x1
ffffffffc0200bac:	26050513          	addi	a0,a0,608 # ffffffffc0201e08 <commands+0x518>
ffffffffc0200bb0:	ffcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(PageProperty(p1) && PageProperty(p1 + 1));
ffffffffc0200bb4:	00001697          	auipc	a3,0x1
ffffffffc0200bb8:	39468693          	addi	a3,a3,916 # ffffffffc0201f48 <commands+0x658>
ffffffffc0200bbc:	00001617          	auipc	a2,0x1
ffffffffc0200bc0:	23460613          	addi	a2,a2,564 # ffffffffc0201df0 <commands+0x500>
ffffffffc0200bc4:	09300593          	li	a1,147
ffffffffc0200bc8:	00001517          	auipc	a0,0x1
ffffffffc0200bcc:	24050513          	addi	a0,a0,576 # ffffffffc0201e08 <commands+0x518>
ffffffffc0200bd0:	fdcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p2 == p0 + 1);
ffffffffc0200bd4:	00001697          	auipc	a3,0x1
ffffffffc0200bd8:	30c68693          	addi	a3,a3,780 # ffffffffc0201ee0 <commands+0x5f0>
ffffffffc0200bdc:	00001617          	auipc	a2,0x1
ffffffffc0200be0:	21460613          	addi	a2,a2,532 # ffffffffc0201df0 <commands+0x500>
ffffffffc0200be4:	08d00593          	li	a1,141
ffffffffc0200be8:	00001517          	auipc	a0,0x1
ffffffffc0200bec:	22050513          	addi	a0,a0,544 # ffffffffc0201e08 <commands+0x518>
ffffffffc0200bf0:	fbcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free_pages() == all_pages >> 1);
ffffffffc0200bf4:	00001697          	auipc	a3,0x1
ffffffffc0200bf8:	3bc68693          	addi	a3,a3,956 # ffffffffc0201fb0 <commands+0x6c0>
ffffffffc0200bfc:	00001617          	auipc	a2,0x1
ffffffffc0200c00:	1f460613          	addi	a2,a2,500 # ffffffffc0201df0 <commands+0x500>
ffffffffc0200c04:	09c00593          	li	a1,156
ffffffffc0200c08:	00001517          	auipc	a0,0x1
ffffffffc0200c0c:	20050513          	addi	a0,a0,512 # ffffffffc0201e08 <commands+0x518>
ffffffffc0200c10:	f9cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p1 == p0 + 2);
ffffffffc0200c14:	00001697          	auipc	a3,0x1
ffffffffc0200c18:	26c68693          	addi	a3,a3,620 # ffffffffc0201e80 <commands+0x590>
ffffffffc0200c1c:	00001617          	auipc	a2,0x1
ffffffffc0200c20:	1d460613          	addi	a2,a2,468 # ffffffffc0201df0 <commands+0x500>
ffffffffc0200c24:	08800593          	li	a1,136
ffffffffc0200c28:	00001517          	auipc	a0,0x1
ffffffffc0200c2c:	1e050513          	addi	a0,a0,480 # ffffffffc0201e08 <commands+0x518>
ffffffffc0200c30:	f7cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p1->ref == 0);
ffffffffc0200c34:	00001697          	auipc	a3,0x1
ffffffffc0200c38:	34468693          	addi	a3,a3,836 # ffffffffc0201f78 <commands+0x688>
ffffffffc0200c3c:	00001617          	auipc	a2,0x1
ffffffffc0200c40:	1b460613          	addi	a2,a2,436 # ffffffffc0201df0 <commands+0x500>
ffffffffc0200c44:	09400593          	li	a1,148
ffffffffc0200c48:	00001517          	auipc	a0,0x1
ffffffffc0200c4c:	1c050513          	addi	a0,a0,448 # ffffffffc0201e08 <commands+0x518>
ffffffffc0200c50:	f5cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 + 2)->ref == 0);
ffffffffc0200c54:	00001697          	auipc	a3,0x1
ffffffffc0200c58:	34468693          	addi	a3,a3,836 # ffffffffc0201f98 <commands+0x6a8>
ffffffffc0200c5c:	00001617          	auipc	a2,0x1
ffffffffc0200c60:	19460613          	addi	a2,a2,404 # ffffffffc0201df0 <commands+0x500>
ffffffffc0200c64:	09b00593          	li	a1,155
ffffffffc0200c68:	00001517          	auipc	a0,0x1
ffffffffc0200c6c:	1a050513          	addi	a0,a0,416 # ffffffffc0201e08 <commands+0x518>
ffffffffc0200c70:	f3cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p2 == p0);
ffffffffc0200c74:	00001697          	auipc	a3,0x1
ffffffffc0200c78:	31468693          	addi	a3,a3,788 # ffffffffc0201f88 <commands+0x698>
ffffffffc0200c7c:	00001617          	auipc	a2,0x1
ffffffffc0200c80:	17460613          	addi	a2,a2,372 # ffffffffc0201df0 <commands+0x500>
ffffffffc0200c84:	09900593          	li	a1,153
ffffffffc0200c88:	00001517          	auipc	a0,0x1
ffffffffc0200c8c:	18050513          	addi	a0,a0,384 # ffffffffc0201e08 <commands+0x518>
ffffffffc0200c90:	f1cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != NULL);
ffffffffc0200c94:	00001697          	auipc	a3,0x1
ffffffffc0200c98:	1dc68693          	addi	a3,a3,476 # ffffffffc0201e70 <commands+0x580>
ffffffffc0200c9c:	00001617          	auipc	a2,0x1
ffffffffc0200ca0:	15460613          	addi	a2,a2,340 # ffffffffc0201df0 <commands+0x500>
ffffffffc0200ca4:	08600593          	li	a1,134
ffffffffc0200ca8:	00001517          	auipc	a0,0x1
ffffffffc0200cac:	16050513          	addi	a0,a0,352 # ffffffffc0201e08 <commands+0x518>
ffffffffc0200cb0:	efcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_pages(all_pages + 1) == NULL);
ffffffffc0200cb4:	00001697          	auipc	a3,0x1
ffffffffc0200cb8:	19468693          	addi	a3,a3,404 # ffffffffc0201e48 <commands+0x558>
ffffffffc0200cbc:	00001617          	auipc	a2,0x1
ffffffffc0200cc0:	13460613          	addi	a2,a2,308 # ffffffffc0201df0 <commands+0x500>
ffffffffc0200cc4:	08300593          	li	a1,131
ffffffffc0200cc8:	00001517          	auipc	a0,0x1
ffffffffc0200ccc:	14050513          	addi	a0,a0,320 # ffffffffc0201e08 <commands+0x518>
ffffffffc0200cd0:	edcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p1 == p0 + 256);
ffffffffc0200cd4:	00001697          	auipc	a3,0x1
ffffffffc0200cd8:	30468693          	addi	a3,a3,772 # ffffffffc0201fd8 <commands+0x6e8>
ffffffffc0200cdc:	00001617          	auipc	a2,0x1
ffffffffc0200ce0:	11460613          	addi	a2,a2,276 # ffffffffc0201df0 <commands+0x500>
ffffffffc0200ce4:	09f00593          	li	a1,159
ffffffffc0200ce8:	00001517          	auipc	a0,0x1
ffffffffc0200cec:	12050513          	addi	a0,a0,288 # ffffffffc0201e08 <commands+0x518>
ffffffffc0200cf0:	ebcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p3 == p0 + 8);
ffffffffc0200cf4:	00001697          	auipc	a3,0x1
ffffffffc0200cf8:	1fc68693          	addi	a3,a3,508 # ffffffffc0201ef0 <commands+0x600>
ffffffffc0200cfc:	00001617          	auipc	a2,0x1
ffffffffc0200d00:	0f460613          	addi	a2,a2,244 # ffffffffc0201df0 <commands+0x500>
ffffffffc0200d04:	08f00593          	li	a1,143
ffffffffc0200d08:	00001517          	auipc	a0,0x1
ffffffffc0200d0c:	10050513          	addi	a0,a0,256 # ffffffffc0201e08 <commands+0x518>
ffffffffc0200d10:	e9cff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200d14 <buddy_init_memmap>:
static void buddy_init_memmap(struct Page *base, size_t n) {
ffffffffc0200d14:	1141                	addi	sp,sp,-16
ffffffffc0200d16:	e406                	sd	ra,8(sp)
    assert((n > 0));
ffffffffc0200d18:	1a058e63          	beqz	a1,ffffffffc0200ed4 <buddy_init_memmap+0x1c0>
ffffffffc0200d1c:	464d                	li	a2,19
ffffffffc0200d1e:	4881                	li	a7,0
ffffffffc0200d20:	4705                	li	a4,1
ffffffffc0200d22:	a029                	j	ffffffffc0200d2c <buddy_init_memmap+0x18>
    for (int i = 1; i < BUDDY_MAX_DEPTH; i++) {
ffffffffc0200d24:	367d                	addiw	a2,a2,-1
ffffffffc0200d26:	4885                	li	a7,1
ffffffffc0200d28:	16060363          	beqz	a2,ffffffffc0200e8e <buddy_init_memmap+0x17a>
        if (available_page_count + ((2 * available_page_count - 1) / 1024) < n) {
ffffffffc0200d2c:	0017169b          	slliw	a3,a4,0x1
ffffffffc0200d30:	fff6879b          	addiw	a5,a3,-1
ffffffffc0200d34:	0007081b          	sext.w	a6,a4
ffffffffc0200d38:	00a7d79b          	srliw	a5,a5,0xa
ffffffffc0200d3c:	010787bb          	addw	a5,a5,a6
ffffffffc0200d40:	1782                	slli	a5,a5,0x20
ffffffffc0200d42:	9381                	srli	a5,a5,0x20
ffffffffc0200d44:	0006871b          	sext.w	a4,a3
ffffffffc0200d48:	fcb7eee3          	bltu	a5,a1,ffffffffc0200d24 <buddy_init_memmap+0x10>
ffffffffc0200d4c:	16088163          	beqz	a7,ffffffffc0200eae <buddy_init_memmap+0x19a>
    total_buddy_pages = ((2 * available_page_count - 1) / 1024) + 1;
ffffffffc0200d50:	ffe87793          	andi	a5,a6,-2
ffffffffc0200d54:	37fd                	addiw	a5,a5,-1
ffffffffc0200d56:	00a7d79b          	srliw	a5,a5,0xa
ffffffffc0200d5a:	2785                	addiw	a5,a5,1
    available_page_start = base + total_buddy_pages;
ffffffffc0200d5c:	02079713          	slli	a4,a5,0x20
ffffffffc0200d60:	9301                	srli	a4,a4,0x20
ffffffffc0200d62:	00271693          	slli	a3,a4,0x2
ffffffffc0200d66:	96ba                	add	a3,a3,a4
ffffffffc0200d68:	068e                	slli	a3,a3,0x3
    available_page_count /= 2;
ffffffffc0200d6a:	0018571b          	srliw	a4,a6,0x1
    available_page_start = base + total_buddy_pages;
ffffffffc0200d6e:	96aa                	add	a3,a3,a0
    total_buddy_pages = ((2 * available_page_count - 1) / 1024) + 1;
ffffffffc0200d70:	00005817          	auipc	a6,0x5
ffffffffc0200d74:	6c880813          	addi	a6,a6,1736 # ffffffffc0206438 <total_buddy_pages>
ffffffffc0200d78:	00f82023          	sw	a5,0(a6)
    available_page_count /= 2;
ffffffffc0200d7c:	00005897          	auipc	a7,0x5
ffffffffc0200d80:	6a488893          	addi	a7,a7,1700 # ffffffffc0206420 <available_page_count>
    available_page_start = base + total_buddy_pages;
ffffffffc0200d84:	00005797          	auipc	a5,0x5
ffffffffc0200d88:	6ad7b223          	sd	a3,1700(a5) # ffffffffc0206428 <available_page_start>
    available_page_count /= 2;
ffffffffc0200d8c:	00e8a023          	sw	a4,0(a7)
    for (int i = 0; i < total_buddy_pages; i++) {
ffffffffc0200d90:	00850793          	addi	a5,a0,8
ffffffffc0200d94:	4681                	li	a3,0
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200d96:	4605                	li	a2,1
ffffffffc0200d98:	40c7b02f          	amoor.d	zero,a2,(a5)
ffffffffc0200d9c:	00082703          	lw	a4,0(a6)
ffffffffc0200da0:	2685                	addiw	a3,a3,1
ffffffffc0200da2:	02878793          	addi	a5,a5,40
ffffffffc0200da6:	fee6e9e3          	bltu	a3,a4,ffffffffc0200d98 <buddy_init_memmap+0x84>
    for (int i = total_buddy_pages; i < n; i++) {
ffffffffc0200daa:	1702                	slli	a4,a4,0x20
ffffffffc0200dac:	9301                	srli	a4,a4,0x20
ffffffffc0200dae:	02b77563          	bgeu	a4,a1,ffffffffc0200dd8 <buddy_init_memmap+0xc4>
ffffffffc0200db2:	00271793          	slli	a5,a4,0x2
ffffffffc0200db6:	97ba                	add	a5,a5,a4
ffffffffc0200db8:	078e                	slli	a5,a5,0x3
ffffffffc0200dba:	07a1                	addi	a5,a5,8
ffffffffc0200dbc:	97aa                	add	a5,a5,a0
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200dbe:	5679                	li	a2,-2
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200dc0:	4689                	li	a3,2
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200dc2:	60c7b02f          	amoand.d	zero,a2,(a5)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200dc6:	40d7b02f          	amoor.d	zero,a3,(a5)
ffffffffc0200dca:	fe07ac23          	sw	zero,-8(a5)
ffffffffc0200dce:	0705                	addi	a4,a4,1
ffffffffc0200dd0:	02878793          	addi	a5,a5,40
ffffffffc0200dd4:	feb767e3          	bltu	a4,a1,ffffffffc0200dc2 <buddy_init_memmap+0xae>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200dd8:	00005617          	auipc	a2,0x5
ffffffffc0200ddc:	67063603          	ld	a2,1648(a2) # ffffffffc0206448 <pages>
ffffffffc0200de0:	40c50633          	sub	a2,a0,a2
ffffffffc0200de4:	860d                	srai	a2,a2,0x3
ffffffffc0200de6:	00001597          	auipc	a1,0x1
ffffffffc0200dea:	5f25b583          	ld	a1,1522(a1) # ffffffffc02023d8 <error_string+0x38>
ffffffffc0200dee:	02b60633          	mul	a2,a2,a1
ffffffffc0200df2:	00001697          	auipc	a3,0x1
ffffffffc0200df6:	5ee6b683          	ld	a3,1518(a3) # ffffffffc02023e0 <nbase>
    buddy_free_tree = (unsigned int*)KADDR(page2pa(base));
ffffffffc0200dfa:	00005717          	auipc	a4,0x5
ffffffffc0200dfe:	64673703          	ld	a4,1606(a4) # ffffffffc0206440 <npage>
ffffffffc0200e02:	9636                	add	a2,a2,a3
ffffffffc0200e04:	00c61793          	slli	a5,a2,0xc
ffffffffc0200e08:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0200e0a:	0632                	slli	a2,a2,0xc
ffffffffc0200e0c:	0ae7f763          	bgeu	a5,a4,ffffffffc0200eba <buddy_init_memmap+0x1a6>
    for (int i = available_page_count; i < available_page_count * 2; i++) {
ffffffffc0200e10:	0008a703          	lw	a4,0(a7)
    buddy_free_tree = (unsigned int*)KADDR(page2pa(base));
ffffffffc0200e14:	00005597          	auipc	a1,0x5
ffffffffc0200e18:	6545b583          	ld	a1,1620(a1) # ffffffffc0206468 <va_pa_offset>
ffffffffc0200e1c:	95b2                	add	a1,a1,a2
ffffffffc0200e1e:	00005797          	auipc	a5,0x5
ffffffffc0200e22:	60b7b923          	sd	a1,1554(a5) # ffffffffc0206430 <buddy_free_tree>
    for (int i = available_page_count; i < available_page_count * 2; i++) {
ffffffffc0200e26:	0017161b          	slliw	a2,a4,0x1
ffffffffc0200e2a:	0007079b          	sext.w	a5,a4
ffffffffc0200e2e:	02c77263          	bgeu	a4,a2,ffffffffc0200e52 <buddy_init_memmap+0x13e>
ffffffffc0200e32:	40e606bb          	subw	a3,a2,a4
ffffffffc0200e36:	36fd                	addiw	a3,a3,-1
ffffffffc0200e38:	1682                	slli	a3,a3,0x20
ffffffffc0200e3a:	9281                	srli	a3,a3,0x20
ffffffffc0200e3c:	96be                	add	a3,a3,a5
ffffffffc0200e3e:	0685                	addi	a3,a3,1
ffffffffc0200e40:	078a                	slli	a5,a5,0x2
ffffffffc0200e42:	068a                	slli	a3,a3,0x2
ffffffffc0200e44:	97ae                	add	a5,a5,a1
ffffffffc0200e46:	96ae                	add	a3,a3,a1
        buddy_free_tree[i] = 1;
ffffffffc0200e48:	4605                	li	a2,1
ffffffffc0200e4a:	c390                	sw	a2,0(a5)
    for (int i = available_page_count; i < available_page_count * 2; i++) {
ffffffffc0200e4c:	0791                	addi	a5,a5,4
ffffffffc0200e4e:	fef69ee3          	bne	a3,a5,ffffffffc0200e4a <buddy_init_memmap+0x136>
    for (int i = available_page_count - 1; i > 0; i--) {
ffffffffc0200e52:	fff7069b          	addiw	a3,a4,-1
ffffffffc0200e56:	02d05963          	blez	a3,ffffffffc0200e88 <buddy_init_memmap+0x174>
ffffffffc0200e5a:	ffe7061b          	addiw	a2,a4,-2
ffffffffc0200e5e:	1602                	slli	a2,a2,0x20
ffffffffc0200e60:	9201                	srli	a2,a2,0x20
ffffffffc0200e62:	40c68633          	sub	a2,a3,a2
ffffffffc0200e66:	0016979b          	slliw	a5,a3,0x1
ffffffffc0200e6a:	060e                	slli	a2,a2,0x3
ffffffffc0200e6c:	078a                	slli	a5,a5,0x2
ffffffffc0200e6e:	068a                	slli	a3,a3,0x2
ffffffffc0200e70:	1661                	addi	a2,a2,-8
ffffffffc0200e72:	97ae                	add	a5,a5,a1
ffffffffc0200e74:	96ae                	add	a3,a3,a1
ffffffffc0200e76:	962e                	add	a2,a2,a1
        buddy_free_tree[i] = buddy_free_tree[i * 2] + buddy_free_tree[i * 2 + 1];
ffffffffc0200e78:	43d8                	lw	a4,4(a5)
ffffffffc0200e7a:	438c                	lw	a1,0(a5)
    for (int i = available_page_count - 1; i > 0; i--) {
ffffffffc0200e7c:	16f1                	addi	a3,a3,-4
ffffffffc0200e7e:	17e1                	addi	a5,a5,-8
        buddy_free_tree[i] = buddy_free_tree[i * 2] + buddy_free_tree[i * 2 + 1];
ffffffffc0200e80:	9f2d                	addw	a4,a4,a1
ffffffffc0200e82:	c2d8                	sw	a4,4(a3)
    for (int i = available_page_count - 1; i > 0; i--) {
ffffffffc0200e84:	fef61ae3          	bne	a2,a5,ffffffffc0200e78 <buddy_init_memmap+0x164>
}
ffffffffc0200e88:	60a2                	ld	ra,8(sp)
ffffffffc0200e8a:	0141                	addi	sp,sp,16
ffffffffc0200e8c:	8082                	ret
    total_buddy_pages = ((2 * available_page_count - 1) / 1024) + 1;
ffffffffc0200e8e:	ffe77793          	andi	a5,a4,-2
ffffffffc0200e92:	37fd                	addiw	a5,a5,-1
ffffffffc0200e94:	00a7d79b          	srliw	a5,a5,0xa
ffffffffc0200e98:	2785                	addiw	a5,a5,1
    available_page_start = base + total_buddy_pages;
ffffffffc0200e9a:	02079613          	slli	a2,a5,0x20
ffffffffc0200e9e:	9201                	srli	a2,a2,0x20
ffffffffc0200ea0:	00261693          	slli	a3,a2,0x2
ffffffffc0200ea4:	96b2                	add	a3,a3,a2
    available_page_count /= 2;
ffffffffc0200ea6:	0017571b          	srliw	a4,a4,0x1
    available_page_start = base + total_buddy_pages;
ffffffffc0200eaa:	068e                	slli	a3,a3,0x3
ffffffffc0200eac:	b5c9                	j	ffffffffc0200d6e <buddy_init_memmap+0x5a>
        if (available_page_count + ((2 * available_page_count - 1) / 1024) < n) {
ffffffffc0200eae:	0a0006b7          	lui	a3,0xa000
ffffffffc0200eb2:	004007b7          	lui	a5,0x400
ffffffffc0200eb6:	4701                	li	a4,0
ffffffffc0200eb8:	bd5d                	j	ffffffffc0200d6e <buddy_init_memmap+0x5a>
    buddy_free_tree = (unsigned int*)KADDR(page2pa(base));
ffffffffc0200eba:	86b2                	mv	a3,a2
ffffffffc0200ebc:	03600593          	li	a1,54
ffffffffc0200ec0:	00001617          	auipc	a2,0x1
ffffffffc0200ec4:	13060613          	addi	a2,a2,304 # ffffffffc0201ff0 <commands+0x700>
ffffffffc0200ec8:	00001517          	auipc	a0,0x1
ffffffffc0200ecc:	f4050513          	addi	a0,a0,-192 # ffffffffc0201e08 <commands+0x518>
ffffffffc0200ed0:	cdcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((n > 0));
ffffffffc0200ed4:	00001697          	auipc	a3,0x1
ffffffffc0200ed8:	11468693          	addi	a3,a3,276 # ffffffffc0201fe8 <commands+0x6f8>
ffffffffc0200edc:	00001617          	auipc	a2,0x1
ffffffffc0200ee0:	f1460613          	addi	a2,a2,-236 # ffffffffc0201df0 <commands+0x500>
ffffffffc0200ee4:	02400593          	li	a1,36
ffffffffc0200ee8:	00001517          	auipc	a0,0x1
ffffffffc0200eec:	f2050513          	addi	a0,a0,-224 # ffffffffc0201e08 <commands+0x518>
ffffffffc0200ef0:	cbcff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200ef4 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200ef4:	100027f3          	csrr	a5,sstatus
ffffffffc0200ef8:	8b89                	andi	a5,a5,2
ffffffffc0200efa:	e799                	bnez	a5,ffffffffc0200f08 <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0200efc:	00005797          	auipc	a5,0x5
ffffffffc0200f00:	5547b783          	ld	a5,1364(a5) # ffffffffc0206450 <pmm_manager>
ffffffffc0200f04:	6f9c                	ld	a5,24(a5)
ffffffffc0200f06:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc0200f08:	1141                	addi	sp,sp,-16
ffffffffc0200f0a:	e406                	sd	ra,8(sp)
ffffffffc0200f0c:	e022                	sd	s0,0(sp)
ffffffffc0200f0e:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0200f10:	d4eff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0200f14:	00005797          	auipc	a5,0x5
ffffffffc0200f18:	53c7b783          	ld	a5,1340(a5) # ffffffffc0206450 <pmm_manager>
ffffffffc0200f1c:	6f9c                	ld	a5,24(a5)
ffffffffc0200f1e:	8522                	mv	a0,s0
ffffffffc0200f20:	9782                	jalr	a5
ffffffffc0200f22:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0200f24:	d34ff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0200f28:	60a2                	ld	ra,8(sp)
ffffffffc0200f2a:	8522                	mv	a0,s0
ffffffffc0200f2c:	6402                	ld	s0,0(sp)
ffffffffc0200f2e:	0141                	addi	sp,sp,16
ffffffffc0200f30:	8082                	ret

ffffffffc0200f32 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200f32:	100027f3          	csrr	a5,sstatus
ffffffffc0200f36:	8b89                	andi	a5,a5,2
ffffffffc0200f38:	e799                	bnez	a5,ffffffffc0200f46 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200f3a:	00005797          	auipc	a5,0x5
ffffffffc0200f3e:	5167b783          	ld	a5,1302(a5) # ffffffffc0206450 <pmm_manager>
ffffffffc0200f42:	739c                	ld	a5,32(a5)
ffffffffc0200f44:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0200f46:	1101                	addi	sp,sp,-32
ffffffffc0200f48:	ec06                	sd	ra,24(sp)
ffffffffc0200f4a:	e822                	sd	s0,16(sp)
ffffffffc0200f4c:	e426                	sd	s1,8(sp)
ffffffffc0200f4e:	842a                	mv	s0,a0
ffffffffc0200f50:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200f52:	d0cff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200f56:	00005797          	auipc	a5,0x5
ffffffffc0200f5a:	4fa7b783          	ld	a5,1274(a5) # ffffffffc0206450 <pmm_manager>
ffffffffc0200f5e:	739c                	ld	a5,32(a5)
ffffffffc0200f60:	85a6                	mv	a1,s1
ffffffffc0200f62:	8522                	mv	a0,s0
ffffffffc0200f64:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200f66:	6442                	ld	s0,16(sp)
ffffffffc0200f68:	60e2                	ld	ra,24(sp)
ffffffffc0200f6a:	64a2                	ld	s1,8(sp)
ffffffffc0200f6c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200f6e:	ceaff06f          	j	ffffffffc0200458 <intr_enable>

ffffffffc0200f72 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200f72:	100027f3          	csrr	a5,sstatus
ffffffffc0200f76:	8b89                	andi	a5,a5,2
ffffffffc0200f78:	e799                	bnez	a5,ffffffffc0200f86 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0200f7a:	00005797          	auipc	a5,0x5
ffffffffc0200f7e:	4d67b783          	ld	a5,1238(a5) # ffffffffc0206450 <pmm_manager>
ffffffffc0200f82:	779c                	ld	a5,40(a5)
ffffffffc0200f84:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0200f86:	1141                	addi	sp,sp,-16
ffffffffc0200f88:	e406                	sd	ra,8(sp)
ffffffffc0200f8a:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0200f8c:	cd2ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0200f90:	00005797          	auipc	a5,0x5
ffffffffc0200f94:	4c07b783          	ld	a5,1216(a5) # ffffffffc0206450 <pmm_manager>
ffffffffc0200f98:	779c                	ld	a5,40(a5)
ffffffffc0200f9a:	9782                	jalr	a5
ffffffffc0200f9c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200f9e:	cbaff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0200fa2:	60a2                	ld	ra,8(sp)
ffffffffc0200fa4:	8522                	mv	a0,s0
ffffffffc0200fa6:	6402                	ld	s0,0(sp)
ffffffffc0200fa8:	0141                	addi	sp,sp,16
ffffffffc0200faa:	8082                	ret

ffffffffc0200fac <pmm_init>:
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200fac:	00001797          	auipc	a5,0x1
ffffffffc0200fb0:	08478793          	addi	a5,a5,132 # ffffffffc0202030 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200fb4:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200fb6:	1101                	addi	sp,sp,-32
ffffffffc0200fb8:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200fba:	00001517          	auipc	a0,0x1
ffffffffc0200fbe:	0ae50513          	addi	a0,a0,174 # ffffffffc0202068 <buddy_pmm_manager+0x38>
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200fc2:	00005497          	auipc	s1,0x5
ffffffffc0200fc6:	48e48493          	addi	s1,s1,1166 # ffffffffc0206450 <pmm_manager>
void pmm_init(void) {
ffffffffc0200fca:	ec06                	sd	ra,24(sp)
ffffffffc0200fcc:	e822                	sd	s0,16(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200fce:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200fd0:	8e2ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc0200fd4:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200fd6:	00005417          	auipc	s0,0x5
ffffffffc0200fda:	49240413          	addi	s0,s0,1170 # ffffffffc0206468 <va_pa_offset>
    pmm_manager->init();
ffffffffc0200fde:	679c                	ld	a5,8(a5)
ffffffffc0200fe0:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200fe2:	57f5                	li	a5,-3
ffffffffc0200fe4:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0200fe6:	00001517          	auipc	a0,0x1
ffffffffc0200fea:	09a50513          	addi	a0,a0,154 # ffffffffc0202080 <buddy_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200fee:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc0200ff0:	8c2ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200ff4:	46c5                	li	a3,17
ffffffffc0200ff6:	06ee                	slli	a3,a3,0x1b
ffffffffc0200ff8:	40100613          	li	a2,1025
ffffffffc0200ffc:	16fd                	addi	a3,a3,-1
ffffffffc0200ffe:	07e005b7          	lui	a1,0x7e00
ffffffffc0201002:	0656                	slli	a2,a2,0x15
ffffffffc0201004:	00001517          	auipc	a0,0x1
ffffffffc0201008:	09450513          	addi	a0,a0,148 # ffffffffc0202098 <buddy_pmm_manager+0x68>
ffffffffc020100c:	8a6ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201010:	777d                	lui	a4,0xfffff
ffffffffc0201012:	00006797          	auipc	a5,0x6
ffffffffc0201016:	46578793          	addi	a5,a5,1125 # ffffffffc0207477 <end+0xfff>
ffffffffc020101a:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc020101c:	00005517          	auipc	a0,0x5
ffffffffc0201020:	42450513          	addi	a0,a0,1060 # ffffffffc0206440 <npage>
ffffffffc0201024:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201028:	00005597          	auipc	a1,0x5
ffffffffc020102c:	42058593          	addi	a1,a1,1056 # ffffffffc0206448 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0201030:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201032:	e19c                	sd	a5,0(a1)
ffffffffc0201034:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201036:	4701                	li	a4,0
ffffffffc0201038:	4885                	li	a7,1
ffffffffc020103a:	fff80837          	lui	a6,0xfff80
ffffffffc020103e:	a011                	j	ffffffffc0201042 <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc0201040:	619c                	ld	a5,0(a1)
ffffffffc0201042:	97b6                	add	a5,a5,a3
ffffffffc0201044:	07a1                	addi	a5,a5,8
ffffffffc0201046:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020104a:	611c                	ld	a5,0(a0)
ffffffffc020104c:	0705                	addi	a4,a4,1
ffffffffc020104e:	02868693          	addi	a3,a3,40
ffffffffc0201052:	01078633          	add	a2,a5,a6
ffffffffc0201056:	fec765e3          	bltu	a4,a2,ffffffffc0201040 <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020105a:	6190                	ld	a2,0(a1)
ffffffffc020105c:	00279713          	slli	a4,a5,0x2
ffffffffc0201060:	973e                	add	a4,a4,a5
ffffffffc0201062:	fec006b7          	lui	a3,0xfec00
ffffffffc0201066:	070e                	slli	a4,a4,0x3
ffffffffc0201068:	96b2                	add	a3,a3,a2
ffffffffc020106a:	96ba                	add	a3,a3,a4
ffffffffc020106c:	c0200737          	lui	a4,0xc0200
ffffffffc0201070:	08e6ef63          	bltu	a3,a4,ffffffffc020110e <pmm_init+0x162>
ffffffffc0201074:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc0201076:	45c5                	li	a1,17
ffffffffc0201078:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020107a:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc020107c:	04b6e863          	bltu	a3,a1,ffffffffc02010cc <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201080:	609c                	ld	a5,0(s1)
ffffffffc0201082:	7b9c                	ld	a5,48(a5)
ffffffffc0201084:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201086:	00001517          	auipc	a0,0x1
ffffffffc020108a:	0aa50513          	addi	a0,a0,170 # ffffffffc0202130 <buddy_pmm_manager+0x100>
ffffffffc020108e:	824ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0201092:	00004597          	auipc	a1,0x4
ffffffffc0201096:	f6e58593          	addi	a1,a1,-146 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc020109a:	00005797          	auipc	a5,0x5
ffffffffc020109e:	3cb7b323          	sd	a1,966(a5) # ffffffffc0206460 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02010a2:	c02007b7          	lui	a5,0xc0200
ffffffffc02010a6:	08f5e063          	bltu	a1,a5,ffffffffc0201126 <pmm_init+0x17a>
ffffffffc02010aa:	6010                	ld	a2,0(s0)
}
ffffffffc02010ac:	6442                	ld	s0,16(sp)
ffffffffc02010ae:	60e2                	ld	ra,24(sp)
ffffffffc02010b0:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc02010b2:	40c58633          	sub	a2,a1,a2
ffffffffc02010b6:	00005797          	auipc	a5,0x5
ffffffffc02010ba:	3ac7b123          	sd	a2,930(a5) # ffffffffc0206458 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02010be:	00001517          	auipc	a0,0x1
ffffffffc02010c2:	09250513          	addi	a0,a0,146 # ffffffffc0202150 <buddy_pmm_manager+0x120>
}
ffffffffc02010c6:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02010c8:	febfe06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02010cc:	6705                	lui	a4,0x1
ffffffffc02010ce:	177d                	addi	a4,a4,-1
ffffffffc02010d0:	96ba                	add	a3,a3,a4
ffffffffc02010d2:	777d                	lui	a4,0xfffff
ffffffffc02010d4:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02010d6:	00c6d513          	srli	a0,a3,0xc
ffffffffc02010da:	00f57e63          	bgeu	a0,a5,ffffffffc02010f6 <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc02010de:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02010e0:	982a                	add	a6,a6,a0
ffffffffc02010e2:	00281513          	slli	a0,a6,0x2
ffffffffc02010e6:	9542                	add	a0,a0,a6
ffffffffc02010e8:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02010ea:	8d95                	sub	a1,a1,a3
ffffffffc02010ec:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02010ee:	81b1                	srli	a1,a1,0xc
ffffffffc02010f0:	9532                	add	a0,a0,a2
ffffffffc02010f2:	9782                	jalr	a5
}
ffffffffc02010f4:	b771                	j	ffffffffc0201080 <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc02010f6:	00001617          	auipc	a2,0x1
ffffffffc02010fa:	00a60613          	addi	a2,a2,10 # ffffffffc0202100 <buddy_pmm_manager+0xd0>
ffffffffc02010fe:	06900593          	li	a1,105
ffffffffc0201102:	00001517          	auipc	a0,0x1
ffffffffc0201106:	01e50513          	addi	a0,a0,30 # ffffffffc0202120 <buddy_pmm_manager+0xf0>
ffffffffc020110a:	aa2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020110e:	00001617          	auipc	a2,0x1
ffffffffc0201112:	fba60613          	addi	a2,a2,-70 # ffffffffc02020c8 <buddy_pmm_manager+0x98>
ffffffffc0201116:	06f00593          	li	a1,111
ffffffffc020111a:	00001517          	auipc	a0,0x1
ffffffffc020111e:	fd650513          	addi	a0,a0,-42 # ffffffffc02020f0 <buddy_pmm_manager+0xc0>
ffffffffc0201122:	a8aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201126:	86ae                	mv	a3,a1
ffffffffc0201128:	00001617          	auipc	a2,0x1
ffffffffc020112c:	fa060613          	addi	a2,a2,-96 # ffffffffc02020c8 <buddy_pmm_manager+0x98>
ffffffffc0201130:	08a00593          	li	a1,138
ffffffffc0201134:	00001517          	auipc	a0,0x1
ffffffffc0201138:	fbc50513          	addi	a0,a0,-68 # ffffffffc02020f0 <buddy_pmm_manager+0xc0>
ffffffffc020113c:	a70ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201140 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201140:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201144:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201146:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020114a:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020114c:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201150:	f022                	sd	s0,32(sp)
ffffffffc0201152:	ec26                	sd	s1,24(sp)
ffffffffc0201154:	e84a                	sd	s2,16(sp)
ffffffffc0201156:	f406                	sd	ra,40(sp)
ffffffffc0201158:	e44e                	sd	s3,8(sp)
ffffffffc020115a:	84aa                	mv	s1,a0
ffffffffc020115c:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020115e:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201162:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0201164:	03067e63          	bgeu	a2,a6,ffffffffc02011a0 <printnum+0x60>
ffffffffc0201168:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc020116a:	00805763          	blez	s0,ffffffffc0201178 <printnum+0x38>
ffffffffc020116e:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201170:	85ca                	mv	a1,s2
ffffffffc0201172:	854e                	mv	a0,s3
ffffffffc0201174:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201176:	fc65                	bnez	s0,ffffffffc020116e <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201178:	1a02                	slli	s4,s4,0x20
ffffffffc020117a:	00001797          	auipc	a5,0x1
ffffffffc020117e:	01678793          	addi	a5,a5,22 # ffffffffc0202190 <buddy_pmm_manager+0x160>
ffffffffc0201182:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201186:	9a3e                	add	s4,s4,a5
}
ffffffffc0201188:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020118a:	000a4503          	lbu	a0,0(s4)
}
ffffffffc020118e:	70a2                	ld	ra,40(sp)
ffffffffc0201190:	69a2                	ld	s3,8(sp)
ffffffffc0201192:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201194:	85ca                	mv	a1,s2
ffffffffc0201196:	87a6                	mv	a5,s1
}
ffffffffc0201198:	6942                	ld	s2,16(sp)
ffffffffc020119a:	64e2                	ld	s1,24(sp)
ffffffffc020119c:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020119e:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02011a0:	03065633          	divu	a2,a2,a6
ffffffffc02011a4:	8722                	mv	a4,s0
ffffffffc02011a6:	f9bff0ef          	jal	ra,ffffffffc0201140 <printnum>
ffffffffc02011aa:	b7f9                	j	ffffffffc0201178 <printnum+0x38>

ffffffffc02011ac <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02011ac:	7119                	addi	sp,sp,-128
ffffffffc02011ae:	f4a6                	sd	s1,104(sp)
ffffffffc02011b0:	f0ca                	sd	s2,96(sp)
ffffffffc02011b2:	ecce                	sd	s3,88(sp)
ffffffffc02011b4:	e8d2                	sd	s4,80(sp)
ffffffffc02011b6:	e4d6                	sd	s5,72(sp)
ffffffffc02011b8:	e0da                	sd	s6,64(sp)
ffffffffc02011ba:	fc5e                	sd	s7,56(sp)
ffffffffc02011bc:	f06a                	sd	s10,32(sp)
ffffffffc02011be:	fc86                	sd	ra,120(sp)
ffffffffc02011c0:	f8a2                	sd	s0,112(sp)
ffffffffc02011c2:	f862                	sd	s8,48(sp)
ffffffffc02011c4:	f466                	sd	s9,40(sp)
ffffffffc02011c6:	ec6e                	sd	s11,24(sp)
ffffffffc02011c8:	892a                	mv	s2,a0
ffffffffc02011ca:	84ae                	mv	s1,a1
ffffffffc02011cc:	8d32                	mv	s10,a2
ffffffffc02011ce:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02011d0:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02011d4:	5b7d                	li	s6,-1
ffffffffc02011d6:	00001a97          	auipc	s5,0x1
ffffffffc02011da:	feea8a93          	addi	s5,s5,-18 # ffffffffc02021c4 <buddy_pmm_manager+0x194>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02011de:	00001b97          	auipc	s7,0x1
ffffffffc02011e2:	1c2b8b93          	addi	s7,s7,450 # ffffffffc02023a0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02011e6:	000d4503          	lbu	a0,0(s10)
ffffffffc02011ea:	001d0413          	addi	s0,s10,1
ffffffffc02011ee:	01350a63          	beq	a0,s3,ffffffffc0201202 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02011f2:	c121                	beqz	a0,ffffffffc0201232 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02011f4:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02011f6:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02011f8:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02011fa:	fff44503          	lbu	a0,-1(s0)
ffffffffc02011fe:	ff351ae3          	bne	a0,s3,ffffffffc02011f2 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201202:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201206:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020120a:	4c81                	li	s9,0
ffffffffc020120c:	4881                	li	a7,0
        width = precision = -1;
ffffffffc020120e:	5c7d                	li	s8,-1
ffffffffc0201210:	5dfd                	li	s11,-1
ffffffffc0201212:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0201216:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201218:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020121c:	0ff5f593          	zext.b	a1,a1
ffffffffc0201220:	00140d13          	addi	s10,s0,1
ffffffffc0201224:	04b56263          	bltu	a0,a1,ffffffffc0201268 <vprintfmt+0xbc>
ffffffffc0201228:	058a                	slli	a1,a1,0x2
ffffffffc020122a:	95d6                	add	a1,a1,s5
ffffffffc020122c:	4194                	lw	a3,0(a1)
ffffffffc020122e:	96d6                	add	a3,a3,s5
ffffffffc0201230:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201232:	70e6                	ld	ra,120(sp)
ffffffffc0201234:	7446                	ld	s0,112(sp)
ffffffffc0201236:	74a6                	ld	s1,104(sp)
ffffffffc0201238:	7906                	ld	s2,96(sp)
ffffffffc020123a:	69e6                	ld	s3,88(sp)
ffffffffc020123c:	6a46                	ld	s4,80(sp)
ffffffffc020123e:	6aa6                	ld	s5,72(sp)
ffffffffc0201240:	6b06                	ld	s6,64(sp)
ffffffffc0201242:	7be2                	ld	s7,56(sp)
ffffffffc0201244:	7c42                	ld	s8,48(sp)
ffffffffc0201246:	7ca2                	ld	s9,40(sp)
ffffffffc0201248:	7d02                	ld	s10,32(sp)
ffffffffc020124a:	6de2                	ld	s11,24(sp)
ffffffffc020124c:	6109                	addi	sp,sp,128
ffffffffc020124e:	8082                	ret
            padc = '0';
ffffffffc0201250:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0201252:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201256:	846a                	mv	s0,s10
ffffffffc0201258:	00140d13          	addi	s10,s0,1
ffffffffc020125c:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201260:	0ff5f593          	zext.b	a1,a1
ffffffffc0201264:	fcb572e3          	bgeu	a0,a1,ffffffffc0201228 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0201268:	85a6                	mv	a1,s1
ffffffffc020126a:	02500513          	li	a0,37
ffffffffc020126e:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201270:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201274:	8d22                	mv	s10,s0
ffffffffc0201276:	f73788e3          	beq	a5,s3,ffffffffc02011e6 <vprintfmt+0x3a>
ffffffffc020127a:	ffed4783          	lbu	a5,-2(s10)
ffffffffc020127e:	1d7d                	addi	s10,s10,-1
ffffffffc0201280:	ff379de3          	bne	a5,s3,ffffffffc020127a <vprintfmt+0xce>
ffffffffc0201284:	b78d                	j	ffffffffc02011e6 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0201286:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc020128a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020128e:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201290:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201294:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201298:	02d86463          	bltu	a6,a3,ffffffffc02012c0 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc020129c:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02012a0:	002c169b          	slliw	a3,s8,0x2
ffffffffc02012a4:	0186873b          	addw	a4,a3,s8
ffffffffc02012a8:	0017171b          	slliw	a4,a4,0x1
ffffffffc02012ac:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02012ae:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02012b2:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02012b4:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02012b8:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02012bc:	fed870e3          	bgeu	a6,a3,ffffffffc020129c <vprintfmt+0xf0>
            if (width < 0)
ffffffffc02012c0:	f40ddce3          	bgez	s11,ffffffffc0201218 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02012c4:	8de2                	mv	s11,s8
ffffffffc02012c6:	5c7d                	li	s8,-1
ffffffffc02012c8:	bf81                	j	ffffffffc0201218 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02012ca:	fffdc693          	not	a3,s11
ffffffffc02012ce:	96fd                	srai	a3,a3,0x3f
ffffffffc02012d0:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012d4:	00144603          	lbu	a2,1(s0)
ffffffffc02012d8:	2d81                	sext.w	s11,s11
ffffffffc02012da:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02012dc:	bf35                	j	ffffffffc0201218 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02012de:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012e2:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02012e6:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012e8:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02012ea:	bfd9                	j	ffffffffc02012c0 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02012ec:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02012ee:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02012f2:	01174463          	blt	a4,a7,ffffffffc02012fa <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02012f6:	1a088e63          	beqz	a7,ffffffffc02014b2 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02012fa:	000a3603          	ld	a2,0(s4)
ffffffffc02012fe:	46c1                	li	a3,16
ffffffffc0201300:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201302:	2781                	sext.w	a5,a5
ffffffffc0201304:	876e                	mv	a4,s11
ffffffffc0201306:	85a6                	mv	a1,s1
ffffffffc0201308:	854a                	mv	a0,s2
ffffffffc020130a:	e37ff0ef          	jal	ra,ffffffffc0201140 <printnum>
            break;
ffffffffc020130e:	bde1                	j	ffffffffc02011e6 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0201310:	000a2503          	lw	a0,0(s4)
ffffffffc0201314:	85a6                	mv	a1,s1
ffffffffc0201316:	0a21                	addi	s4,s4,8
ffffffffc0201318:	9902                	jalr	s2
            break;
ffffffffc020131a:	b5f1                	j	ffffffffc02011e6 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020131c:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020131e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201322:	01174463          	blt	a4,a7,ffffffffc020132a <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0201326:	18088163          	beqz	a7,ffffffffc02014a8 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc020132a:	000a3603          	ld	a2,0(s4)
ffffffffc020132e:	46a9                	li	a3,10
ffffffffc0201330:	8a2e                	mv	s4,a1
ffffffffc0201332:	bfc1                	j	ffffffffc0201302 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201334:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201338:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020133a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020133c:	bdf1                	j	ffffffffc0201218 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc020133e:	85a6                	mv	a1,s1
ffffffffc0201340:	02500513          	li	a0,37
ffffffffc0201344:	9902                	jalr	s2
            break;
ffffffffc0201346:	b545                	j	ffffffffc02011e6 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201348:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc020134c:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020134e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201350:	b5e1                	j	ffffffffc0201218 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0201352:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201354:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201358:	01174463          	blt	a4,a7,ffffffffc0201360 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc020135c:	14088163          	beqz	a7,ffffffffc020149e <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0201360:	000a3603          	ld	a2,0(s4)
ffffffffc0201364:	46a1                	li	a3,8
ffffffffc0201366:	8a2e                	mv	s4,a1
ffffffffc0201368:	bf69                	j	ffffffffc0201302 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc020136a:	03000513          	li	a0,48
ffffffffc020136e:	85a6                	mv	a1,s1
ffffffffc0201370:	e03e                	sd	a5,0(sp)
ffffffffc0201372:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201374:	85a6                	mv	a1,s1
ffffffffc0201376:	07800513          	li	a0,120
ffffffffc020137a:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020137c:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc020137e:	6782                	ld	a5,0(sp)
ffffffffc0201380:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201382:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0201386:	bfb5                	j	ffffffffc0201302 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201388:	000a3403          	ld	s0,0(s4)
ffffffffc020138c:	008a0713          	addi	a4,s4,8
ffffffffc0201390:	e03a                	sd	a4,0(sp)
ffffffffc0201392:	14040263          	beqz	s0,ffffffffc02014d6 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0201396:	0fb05763          	blez	s11,ffffffffc0201484 <vprintfmt+0x2d8>
ffffffffc020139a:	02d00693          	li	a3,45
ffffffffc020139e:	0cd79163          	bne	a5,a3,ffffffffc0201460 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02013a2:	00044783          	lbu	a5,0(s0)
ffffffffc02013a6:	0007851b          	sext.w	a0,a5
ffffffffc02013aa:	cf85                	beqz	a5,ffffffffc02013e2 <vprintfmt+0x236>
ffffffffc02013ac:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02013b0:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02013b4:	000c4563          	bltz	s8,ffffffffc02013be <vprintfmt+0x212>
ffffffffc02013b8:	3c7d                	addiw	s8,s8,-1
ffffffffc02013ba:	036c0263          	beq	s8,s6,ffffffffc02013de <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc02013be:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02013c0:	0e0c8e63          	beqz	s9,ffffffffc02014bc <vprintfmt+0x310>
ffffffffc02013c4:	3781                	addiw	a5,a5,-32
ffffffffc02013c6:	0ef47b63          	bgeu	s0,a5,ffffffffc02014bc <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02013ca:	03f00513          	li	a0,63
ffffffffc02013ce:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02013d0:	000a4783          	lbu	a5,0(s4)
ffffffffc02013d4:	3dfd                	addiw	s11,s11,-1
ffffffffc02013d6:	0a05                	addi	s4,s4,1
ffffffffc02013d8:	0007851b          	sext.w	a0,a5
ffffffffc02013dc:	ffe1                	bnez	a5,ffffffffc02013b4 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02013de:	01b05963          	blez	s11,ffffffffc02013f0 <vprintfmt+0x244>
ffffffffc02013e2:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02013e4:	85a6                	mv	a1,s1
ffffffffc02013e6:	02000513          	li	a0,32
ffffffffc02013ea:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02013ec:	fe0d9be3          	bnez	s11,ffffffffc02013e2 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02013f0:	6a02                	ld	s4,0(sp)
ffffffffc02013f2:	bbd5                	j	ffffffffc02011e6 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02013f4:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02013f6:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02013fa:	01174463          	blt	a4,a7,ffffffffc0201402 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02013fe:	08088d63          	beqz	a7,ffffffffc0201498 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0201402:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0201406:	0a044d63          	bltz	s0,ffffffffc02014c0 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc020140a:	8622                	mv	a2,s0
ffffffffc020140c:	8a66                	mv	s4,s9
ffffffffc020140e:	46a9                	li	a3,10
ffffffffc0201410:	bdcd                	j	ffffffffc0201302 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0201412:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201416:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201418:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc020141a:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc020141e:	8fb5                	xor	a5,a5,a3
ffffffffc0201420:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201424:	02d74163          	blt	a4,a3,ffffffffc0201446 <vprintfmt+0x29a>
ffffffffc0201428:	00369793          	slli	a5,a3,0x3
ffffffffc020142c:	97de                	add	a5,a5,s7
ffffffffc020142e:	639c                	ld	a5,0(a5)
ffffffffc0201430:	cb99                	beqz	a5,ffffffffc0201446 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201432:	86be                	mv	a3,a5
ffffffffc0201434:	00001617          	auipc	a2,0x1
ffffffffc0201438:	d8c60613          	addi	a2,a2,-628 # ffffffffc02021c0 <buddy_pmm_manager+0x190>
ffffffffc020143c:	85a6                	mv	a1,s1
ffffffffc020143e:	854a                	mv	a0,s2
ffffffffc0201440:	0ce000ef          	jal	ra,ffffffffc020150e <printfmt>
ffffffffc0201444:	b34d                	j	ffffffffc02011e6 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201446:	00001617          	auipc	a2,0x1
ffffffffc020144a:	d6a60613          	addi	a2,a2,-662 # ffffffffc02021b0 <buddy_pmm_manager+0x180>
ffffffffc020144e:	85a6                	mv	a1,s1
ffffffffc0201450:	854a                	mv	a0,s2
ffffffffc0201452:	0bc000ef          	jal	ra,ffffffffc020150e <printfmt>
ffffffffc0201456:	bb41                	j	ffffffffc02011e6 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201458:	00001417          	auipc	s0,0x1
ffffffffc020145c:	d5040413          	addi	s0,s0,-688 # ffffffffc02021a8 <buddy_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201460:	85e2                	mv	a1,s8
ffffffffc0201462:	8522                	mv	a0,s0
ffffffffc0201464:	e43e                	sd	a5,8(sp)
ffffffffc0201466:	1cc000ef          	jal	ra,ffffffffc0201632 <strnlen>
ffffffffc020146a:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020146e:	01b05b63          	blez	s11,ffffffffc0201484 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0201472:	67a2                	ld	a5,8(sp)
ffffffffc0201474:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201478:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc020147a:	85a6                	mv	a1,s1
ffffffffc020147c:	8552                	mv	a0,s4
ffffffffc020147e:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201480:	fe0d9ce3          	bnez	s11,ffffffffc0201478 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201484:	00044783          	lbu	a5,0(s0)
ffffffffc0201488:	00140a13          	addi	s4,s0,1
ffffffffc020148c:	0007851b          	sext.w	a0,a5
ffffffffc0201490:	d3a5                	beqz	a5,ffffffffc02013f0 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201492:	05e00413          	li	s0,94
ffffffffc0201496:	bf39                	j	ffffffffc02013b4 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0201498:	000a2403          	lw	s0,0(s4)
ffffffffc020149c:	b7ad                	j	ffffffffc0201406 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc020149e:	000a6603          	lwu	a2,0(s4)
ffffffffc02014a2:	46a1                	li	a3,8
ffffffffc02014a4:	8a2e                	mv	s4,a1
ffffffffc02014a6:	bdb1                	j	ffffffffc0201302 <vprintfmt+0x156>
ffffffffc02014a8:	000a6603          	lwu	a2,0(s4)
ffffffffc02014ac:	46a9                	li	a3,10
ffffffffc02014ae:	8a2e                	mv	s4,a1
ffffffffc02014b0:	bd89                	j	ffffffffc0201302 <vprintfmt+0x156>
ffffffffc02014b2:	000a6603          	lwu	a2,0(s4)
ffffffffc02014b6:	46c1                	li	a3,16
ffffffffc02014b8:	8a2e                	mv	s4,a1
ffffffffc02014ba:	b5a1                	j	ffffffffc0201302 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02014bc:	9902                	jalr	s2
ffffffffc02014be:	bf09                	j	ffffffffc02013d0 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc02014c0:	85a6                	mv	a1,s1
ffffffffc02014c2:	02d00513          	li	a0,45
ffffffffc02014c6:	e03e                	sd	a5,0(sp)
ffffffffc02014c8:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02014ca:	6782                	ld	a5,0(sp)
ffffffffc02014cc:	8a66                	mv	s4,s9
ffffffffc02014ce:	40800633          	neg	a2,s0
ffffffffc02014d2:	46a9                	li	a3,10
ffffffffc02014d4:	b53d                	j	ffffffffc0201302 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02014d6:	03b05163          	blez	s11,ffffffffc02014f8 <vprintfmt+0x34c>
ffffffffc02014da:	02d00693          	li	a3,45
ffffffffc02014de:	f6d79de3          	bne	a5,a3,ffffffffc0201458 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02014e2:	00001417          	auipc	s0,0x1
ffffffffc02014e6:	cc640413          	addi	s0,s0,-826 # ffffffffc02021a8 <buddy_pmm_manager+0x178>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02014ea:	02800793          	li	a5,40
ffffffffc02014ee:	02800513          	li	a0,40
ffffffffc02014f2:	00140a13          	addi	s4,s0,1
ffffffffc02014f6:	bd6d                	j	ffffffffc02013b0 <vprintfmt+0x204>
ffffffffc02014f8:	00001a17          	auipc	s4,0x1
ffffffffc02014fc:	cb1a0a13          	addi	s4,s4,-847 # ffffffffc02021a9 <buddy_pmm_manager+0x179>
ffffffffc0201500:	02800513          	li	a0,40
ffffffffc0201504:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201508:	05e00413          	li	s0,94
ffffffffc020150c:	b565                	j	ffffffffc02013b4 <vprintfmt+0x208>

ffffffffc020150e <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020150e:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201510:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201514:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201516:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201518:	ec06                	sd	ra,24(sp)
ffffffffc020151a:	f83a                	sd	a4,48(sp)
ffffffffc020151c:	fc3e                	sd	a5,56(sp)
ffffffffc020151e:	e0c2                	sd	a6,64(sp)
ffffffffc0201520:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201522:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201524:	c89ff0ef          	jal	ra,ffffffffc02011ac <vprintfmt>
}
ffffffffc0201528:	60e2                	ld	ra,24(sp)
ffffffffc020152a:	6161                	addi	sp,sp,80
ffffffffc020152c:	8082                	ret

ffffffffc020152e <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc020152e:	715d                	addi	sp,sp,-80
ffffffffc0201530:	e486                	sd	ra,72(sp)
ffffffffc0201532:	e0a6                	sd	s1,64(sp)
ffffffffc0201534:	fc4a                	sd	s2,56(sp)
ffffffffc0201536:	f84e                	sd	s3,48(sp)
ffffffffc0201538:	f452                	sd	s4,40(sp)
ffffffffc020153a:	f056                	sd	s5,32(sp)
ffffffffc020153c:	ec5a                	sd	s6,24(sp)
ffffffffc020153e:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0201540:	c901                	beqz	a0,ffffffffc0201550 <readline+0x22>
ffffffffc0201542:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0201544:	00001517          	auipc	a0,0x1
ffffffffc0201548:	c7c50513          	addi	a0,a0,-900 # ffffffffc02021c0 <buddy_pmm_manager+0x190>
ffffffffc020154c:	b67fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc0201550:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201552:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201554:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201556:	4aa9                	li	s5,10
ffffffffc0201558:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc020155a:	00005b97          	auipc	s7,0x5
ffffffffc020155e:	ab6b8b93          	addi	s7,s7,-1354 # ffffffffc0206010 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201562:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201566:	bc5fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc020156a:	00054a63          	bltz	a0,ffffffffc020157e <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020156e:	00a95a63          	bge	s2,a0,ffffffffc0201582 <readline+0x54>
ffffffffc0201572:	029a5263          	bge	s4,s1,ffffffffc0201596 <readline+0x68>
        c = getchar();
ffffffffc0201576:	bb5fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc020157a:	fe055ae3          	bgez	a0,ffffffffc020156e <readline+0x40>
            return NULL;
ffffffffc020157e:	4501                	li	a0,0
ffffffffc0201580:	a091                	j	ffffffffc02015c4 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0201582:	03351463          	bne	a0,s3,ffffffffc02015aa <readline+0x7c>
ffffffffc0201586:	e8a9                	bnez	s1,ffffffffc02015d8 <readline+0xaa>
        c = getchar();
ffffffffc0201588:	ba3fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc020158c:	fe0549e3          	bltz	a0,ffffffffc020157e <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201590:	fea959e3          	bge	s2,a0,ffffffffc0201582 <readline+0x54>
ffffffffc0201594:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201596:	e42a                	sd	a0,8(sp)
ffffffffc0201598:	b51fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc020159c:	6522                	ld	a0,8(sp)
ffffffffc020159e:	009b87b3          	add	a5,s7,s1
ffffffffc02015a2:	2485                	addiw	s1,s1,1
ffffffffc02015a4:	00a78023          	sb	a0,0(a5)
ffffffffc02015a8:	bf7d                	j	ffffffffc0201566 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02015aa:	01550463          	beq	a0,s5,ffffffffc02015b2 <readline+0x84>
ffffffffc02015ae:	fb651ce3          	bne	a0,s6,ffffffffc0201566 <readline+0x38>
            cputchar(c);
ffffffffc02015b2:	b37fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc02015b6:	00005517          	auipc	a0,0x5
ffffffffc02015ba:	a5a50513          	addi	a0,a0,-1446 # ffffffffc0206010 <buf>
ffffffffc02015be:	94aa                	add	s1,s1,a0
ffffffffc02015c0:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02015c4:	60a6                	ld	ra,72(sp)
ffffffffc02015c6:	6486                	ld	s1,64(sp)
ffffffffc02015c8:	7962                	ld	s2,56(sp)
ffffffffc02015ca:	79c2                	ld	s3,48(sp)
ffffffffc02015cc:	7a22                	ld	s4,40(sp)
ffffffffc02015ce:	7a82                	ld	s5,32(sp)
ffffffffc02015d0:	6b62                	ld	s6,24(sp)
ffffffffc02015d2:	6bc2                	ld	s7,16(sp)
ffffffffc02015d4:	6161                	addi	sp,sp,80
ffffffffc02015d6:	8082                	ret
            cputchar(c);
ffffffffc02015d8:	4521                	li	a0,8
ffffffffc02015da:	b0ffe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc02015de:	34fd                	addiw	s1,s1,-1
ffffffffc02015e0:	b759                	j	ffffffffc0201566 <readline+0x38>

ffffffffc02015e2 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc02015e2:	4781                	li	a5,0
ffffffffc02015e4:	00005717          	auipc	a4,0x5
ffffffffc02015e8:	a2473703          	ld	a4,-1500(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc02015ec:	88ba                	mv	a7,a4
ffffffffc02015ee:	852a                	mv	a0,a0
ffffffffc02015f0:	85be                	mv	a1,a5
ffffffffc02015f2:	863e                	mv	a2,a5
ffffffffc02015f4:	00000073          	ecall
ffffffffc02015f8:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc02015fa:	8082                	ret

ffffffffc02015fc <sbi_set_timer>:
    __asm__ volatile (
ffffffffc02015fc:	4781                	li	a5,0
ffffffffc02015fe:	00005717          	auipc	a4,0x5
ffffffffc0201602:	e7273703          	ld	a4,-398(a4) # ffffffffc0206470 <SBI_SET_TIMER>
ffffffffc0201606:	88ba                	mv	a7,a4
ffffffffc0201608:	852a                	mv	a0,a0
ffffffffc020160a:	85be                	mv	a1,a5
ffffffffc020160c:	863e                	mv	a2,a5
ffffffffc020160e:	00000073          	ecall
ffffffffc0201612:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc0201614:	8082                	ret

ffffffffc0201616 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc0201616:	4501                	li	a0,0
ffffffffc0201618:	00005797          	auipc	a5,0x5
ffffffffc020161c:	9e87b783          	ld	a5,-1560(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc0201620:	88be                	mv	a7,a5
ffffffffc0201622:	852a                	mv	a0,a0
ffffffffc0201624:	85aa                	mv	a1,a0
ffffffffc0201626:	862a                	mv	a2,a0
ffffffffc0201628:	00000073          	ecall
ffffffffc020162c:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc020162e:	2501                	sext.w	a0,a0
ffffffffc0201630:	8082                	ret

ffffffffc0201632 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0201632:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201634:	e589                	bnez	a1,ffffffffc020163e <strnlen+0xc>
ffffffffc0201636:	a811                	j	ffffffffc020164a <strnlen+0x18>
        cnt ++;
ffffffffc0201638:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020163a:	00f58863          	beq	a1,a5,ffffffffc020164a <strnlen+0x18>
ffffffffc020163e:	00f50733          	add	a4,a0,a5
ffffffffc0201642:	00074703          	lbu	a4,0(a4)
ffffffffc0201646:	fb6d                	bnez	a4,ffffffffc0201638 <strnlen+0x6>
ffffffffc0201648:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc020164a:	852e                	mv	a0,a1
ffffffffc020164c:	8082                	ret

ffffffffc020164e <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020164e:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201652:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201656:	cb89                	beqz	a5,ffffffffc0201668 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201658:	0505                	addi	a0,a0,1
ffffffffc020165a:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020165c:	fee789e3          	beq	a5,a4,ffffffffc020164e <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201660:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201664:	9d19                	subw	a0,a0,a4
ffffffffc0201666:	8082                	ret
ffffffffc0201668:	4501                	li	a0,0
ffffffffc020166a:	bfed                	j	ffffffffc0201664 <strcmp+0x16>

ffffffffc020166c <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc020166c:	00054783          	lbu	a5,0(a0)
ffffffffc0201670:	c799                	beqz	a5,ffffffffc020167e <strchr+0x12>
        if (*s == c) {
ffffffffc0201672:	00f58763          	beq	a1,a5,ffffffffc0201680 <strchr+0x14>
    while (*s != '\0') {
ffffffffc0201676:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc020167a:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc020167c:	fbfd                	bnez	a5,ffffffffc0201672 <strchr+0x6>
    }
    return NULL;
ffffffffc020167e:	4501                	li	a0,0
}
ffffffffc0201680:	8082                	ret

ffffffffc0201682 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201682:	ca01                	beqz	a2,ffffffffc0201692 <memset+0x10>
ffffffffc0201684:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201686:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201688:	0785                	addi	a5,a5,1
ffffffffc020168a:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc020168e:	fec79de3          	bne	a5,a2,ffffffffc0201688 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201692:	8082                	ret
