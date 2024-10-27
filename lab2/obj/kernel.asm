
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02042b7          	lui	t0,0xc0204
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
ffffffffc0200024:	c0204137          	lui	sp,0xc0204

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
ffffffffc0200032:	00005517          	auipc	a0,0x5
ffffffffc0200036:	fde50513          	addi	a0,a0,-34 # ffffffffc0205010 <page_pool>
ffffffffc020003a:	00007617          	auipc	a2,0x7
ffffffffc020003e:	8c660613          	addi	a2,a2,-1850 # ffffffffc0206900 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	507000ef          	jal	ra,ffffffffc0200d50 <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00001517          	auipc	a0,0x1
ffffffffc0200056:	20650513          	addi	a0,a0,518 # ffffffffc0201258 <etext+0x4>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	138000ef          	jal	ra,ffffffffc0200196 <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	79c000ef          	jal	ra,ffffffffc0200802 <pmm_init>

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
ffffffffc02000a6:	529000ef          	jal	ra,ffffffffc0200dce <vprintfmt>
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
ffffffffc02000b4:	02810313          	addi	t1,sp,40 # ffffffffc0204028 <boot_page_table_sv39+0x28>
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
ffffffffc02000dc:	4f3000ef          	jal	ra,ffffffffc0200dce <vprintfmt>
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

ffffffffc020013a <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc020013a:	00006317          	auipc	t1,0x6
ffffffffc020013e:	77630313          	addi	t1,t1,1910 # ffffffffc02068b0 <is_panic>
ffffffffc0200142:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200146:	715d                	addi	sp,sp,-80
ffffffffc0200148:	ec06                	sd	ra,24(sp)
ffffffffc020014a:	e822                	sd	s0,16(sp)
ffffffffc020014c:	f436                	sd	a3,40(sp)
ffffffffc020014e:	f83a                	sd	a4,48(sp)
ffffffffc0200150:	fc3e                	sd	a5,56(sp)
ffffffffc0200152:	e0c2                	sd	a6,64(sp)
ffffffffc0200154:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200156:	020e1a63          	bnez	t3,ffffffffc020018a <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc020015a:	4785                	li	a5,1
ffffffffc020015c:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc0200160:	8432                	mv	s0,a2
ffffffffc0200162:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200164:	862e                	mv	a2,a1
ffffffffc0200166:	85aa                	mv	a1,a0
ffffffffc0200168:	00001517          	auipc	a0,0x1
ffffffffc020016c:	11050513          	addi	a0,a0,272 # ffffffffc0201278 <etext+0x24>
    va_start(ap, fmt);
ffffffffc0200170:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200172:	f41ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200176:	65a2                	ld	a1,8(sp)
ffffffffc0200178:	8522                	mv	a0,s0
ffffffffc020017a:	f19ff0ef          	jal	ra,ffffffffc0200092 <vcprintf>
    cprintf("\n");
ffffffffc020017e:	00001517          	auipc	a0,0x1
ffffffffc0200182:	1e250513          	addi	a0,a0,482 # ffffffffc0201360 <etext+0x10c>
ffffffffc0200186:	f2dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc020018a:	2d4000ef          	jal	ra,ffffffffc020045e <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc020018e:	4501                	li	a0,0
ffffffffc0200190:	130000ef          	jal	ra,ffffffffc02002c0 <kmonitor>
    while (1) {
ffffffffc0200194:	bfed                	j	ffffffffc020018e <__panic+0x54>

ffffffffc0200196 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200196:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200198:	00001517          	auipc	a0,0x1
ffffffffc020019c:	10050513          	addi	a0,a0,256 # ffffffffc0201298 <etext+0x44>
void print_kerninfo(void) {
ffffffffc02001a0:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001a2:	f11ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc02001a6:	00000597          	auipc	a1,0x0
ffffffffc02001aa:	e8c58593          	addi	a1,a1,-372 # ffffffffc0200032 <kern_init>
ffffffffc02001ae:	00001517          	auipc	a0,0x1
ffffffffc02001b2:	10a50513          	addi	a0,a0,266 # ffffffffc02012b8 <etext+0x64>
ffffffffc02001b6:	efdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc02001ba:	00001597          	auipc	a1,0x1
ffffffffc02001be:	09a58593          	addi	a1,a1,154 # ffffffffc0201254 <etext>
ffffffffc02001c2:	00001517          	auipc	a0,0x1
ffffffffc02001c6:	11650513          	addi	a0,a0,278 # ffffffffc02012d8 <etext+0x84>
ffffffffc02001ca:	ee9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc02001ce:	00005597          	auipc	a1,0x5
ffffffffc02001d2:	e4258593          	addi	a1,a1,-446 # ffffffffc0205010 <page_pool>
ffffffffc02001d6:	00001517          	auipc	a0,0x1
ffffffffc02001da:	12250513          	addi	a0,a0,290 # ffffffffc02012f8 <etext+0xa4>
ffffffffc02001de:	ed5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc02001e2:	00006597          	auipc	a1,0x6
ffffffffc02001e6:	71e58593          	addi	a1,a1,1822 # ffffffffc0206900 <end>
ffffffffc02001ea:	00001517          	auipc	a0,0x1
ffffffffc02001ee:	12e50513          	addi	a0,a0,302 # ffffffffc0201318 <etext+0xc4>
ffffffffc02001f2:	ec1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001f6:	00007597          	auipc	a1,0x7
ffffffffc02001fa:	b0958593          	addi	a1,a1,-1271 # ffffffffc0206cff <end+0x3ff>
ffffffffc02001fe:	00000797          	auipc	a5,0x0
ffffffffc0200202:	e3478793          	addi	a5,a5,-460 # ffffffffc0200032 <kern_init>
ffffffffc0200206:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020020a:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020020e:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200210:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200214:	95be                	add	a1,a1,a5
ffffffffc0200216:	85a9                	srai	a1,a1,0xa
ffffffffc0200218:	00001517          	auipc	a0,0x1
ffffffffc020021c:	12050513          	addi	a0,a0,288 # ffffffffc0201338 <etext+0xe4>
}
ffffffffc0200220:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200222:	bd41                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200224 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200224:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc0200226:	00001617          	auipc	a2,0x1
ffffffffc020022a:	14260613          	addi	a2,a2,322 # ffffffffc0201368 <etext+0x114>
ffffffffc020022e:	04e00593          	li	a1,78
ffffffffc0200232:	00001517          	auipc	a0,0x1
ffffffffc0200236:	14e50513          	addi	a0,a0,334 # ffffffffc0201380 <etext+0x12c>
void print_stackframe(void) {
ffffffffc020023a:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020023c:	effff0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0200240 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200240:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200242:	00001617          	auipc	a2,0x1
ffffffffc0200246:	15660613          	addi	a2,a2,342 # ffffffffc0201398 <etext+0x144>
ffffffffc020024a:	00001597          	auipc	a1,0x1
ffffffffc020024e:	16e58593          	addi	a1,a1,366 # ffffffffc02013b8 <etext+0x164>
ffffffffc0200252:	00001517          	auipc	a0,0x1
ffffffffc0200256:	16e50513          	addi	a0,a0,366 # ffffffffc02013c0 <etext+0x16c>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020025a:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020025c:	e57ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200260:	00001617          	auipc	a2,0x1
ffffffffc0200264:	17060613          	addi	a2,a2,368 # ffffffffc02013d0 <etext+0x17c>
ffffffffc0200268:	00001597          	auipc	a1,0x1
ffffffffc020026c:	19058593          	addi	a1,a1,400 # ffffffffc02013f8 <etext+0x1a4>
ffffffffc0200270:	00001517          	auipc	a0,0x1
ffffffffc0200274:	15050513          	addi	a0,a0,336 # ffffffffc02013c0 <etext+0x16c>
ffffffffc0200278:	e3bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020027c:	00001617          	auipc	a2,0x1
ffffffffc0200280:	18c60613          	addi	a2,a2,396 # ffffffffc0201408 <etext+0x1b4>
ffffffffc0200284:	00001597          	auipc	a1,0x1
ffffffffc0200288:	1a458593          	addi	a1,a1,420 # ffffffffc0201428 <etext+0x1d4>
ffffffffc020028c:	00001517          	auipc	a0,0x1
ffffffffc0200290:	13450513          	addi	a0,a0,308 # ffffffffc02013c0 <etext+0x16c>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    }
    return 0;
}
ffffffffc0200298:	60a2                	ld	ra,8(sp)
ffffffffc020029a:	4501                	li	a0,0
ffffffffc020029c:	0141                	addi	sp,sp,16
ffffffffc020029e:	8082                	ret

ffffffffc02002a0 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002a0:	1141                	addi	sp,sp,-16
ffffffffc02002a2:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02002a4:	ef3ff0ef          	jal	ra,ffffffffc0200196 <print_kerninfo>
    return 0;
}
ffffffffc02002a8:	60a2                	ld	ra,8(sp)
ffffffffc02002aa:	4501                	li	a0,0
ffffffffc02002ac:	0141                	addi	sp,sp,16
ffffffffc02002ae:	8082                	ret

ffffffffc02002b0 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002b0:	1141                	addi	sp,sp,-16
ffffffffc02002b2:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02002b4:	f71ff0ef          	jal	ra,ffffffffc0200224 <print_stackframe>
    return 0;
}
ffffffffc02002b8:	60a2                	ld	ra,8(sp)
ffffffffc02002ba:	4501                	li	a0,0
ffffffffc02002bc:	0141                	addi	sp,sp,16
ffffffffc02002be:	8082                	ret

ffffffffc02002c0 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02002c0:	7115                	addi	sp,sp,-224
ffffffffc02002c2:	ed5e                	sd	s7,152(sp)
ffffffffc02002c4:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002c6:	00001517          	auipc	a0,0x1
ffffffffc02002ca:	17250513          	addi	a0,a0,370 # ffffffffc0201438 <etext+0x1e4>
kmonitor(struct trapframe *tf) {
ffffffffc02002ce:	ed86                	sd	ra,216(sp)
ffffffffc02002d0:	e9a2                	sd	s0,208(sp)
ffffffffc02002d2:	e5a6                	sd	s1,200(sp)
ffffffffc02002d4:	e1ca                	sd	s2,192(sp)
ffffffffc02002d6:	fd4e                	sd	s3,184(sp)
ffffffffc02002d8:	f952                	sd	s4,176(sp)
ffffffffc02002da:	f556                	sd	s5,168(sp)
ffffffffc02002dc:	f15a                	sd	s6,160(sp)
ffffffffc02002de:	e962                	sd	s8,144(sp)
ffffffffc02002e0:	e566                	sd	s9,136(sp)
ffffffffc02002e2:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002e4:	dcfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc02002e8:	00001517          	auipc	a0,0x1
ffffffffc02002ec:	17850513          	addi	a0,a0,376 # ffffffffc0201460 <etext+0x20c>
ffffffffc02002f0:	dc3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc02002f4:	000b8563          	beqz	s7,ffffffffc02002fe <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002f8:	855e                	mv	a0,s7
ffffffffc02002fa:	348000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002fe:	00001c17          	auipc	s8,0x1
ffffffffc0200302:	1d2c0c13          	addi	s8,s8,466 # ffffffffc02014d0 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200306:	00001917          	auipc	s2,0x1
ffffffffc020030a:	18290913          	addi	s2,s2,386 # ffffffffc0201488 <etext+0x234>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020030e:	00001497          	auipc	s1,0x1
ffffffffc0200312:	18248493          	addi	s1,s1,386 # ffffffffc0201490 <etext+0x23c>
        if (argc == MAXARGS - 1) {
ffffffffc0200316:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200318:	00001b17          	auipc	s6,0x1
ffffffffc020031c:	180b0b13          	addi	s6,s6,384 # ffffffffc0201498 <etext+0x244>
        argv[argc ++] = buf;
ffffffffc0200320:	00001a17          	auipc	s4,0x1
ffffffffc0200324:	098a0a13          	addi	s4,s4,152 # ffffffffc02013b8 <etext+0x164>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200328:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020032a:	854a                	mv	a0,s2
ffffffffc020032c:	625000ef          	jal	ra,ffffffffc0201150 <readline>
ffffffffc0200330:	842a                	mv	s0,a0
ffffffffc0200332:	dd65                	beqz	a0,ffffffffc020032a <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200334:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200338:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020033a:	e1bd                	bnez	a1,ffffffffc02003a0 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc020033c:	fe0c87e3          	beqz	s9,ffffffffc020032a <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200340:	6582                	ld	a1,0(sp)
ffffffffc0200342:	00001d17          	auipc	s10,0x1
ffffffffc0200346:	18ed0d13          	addi	s10,s10,398 # ffffffffc02014d0 <commands>
        argv[argc ++] = buf;
ffffffffc020034a:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020034c:	4401                	li	s0,0
ffffffffc020034e:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200350:	1cd000ef          	jal	ra,ffffffffc0200d1c <strcmp>
ffffffffc0200354:	c919                	beqz	a0,ffffffffc020036a <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200356:	2405                	addiw	s0,s0,1
ffffffffc0200358:	0b540063          	beq	s0,s5,ffffffffc02003f8 <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020035c:	000d3503          	ld	a0,0(s10)
ffffffffc0200360:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200362:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200364:	1b9000ef          	jal	ra,ffffffffc0200d1c <strcmp>
ffffffffc0200368:	f57d                	bnez	a0,ffffffffc0200356 <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020036a:	00141793          	slli	a5,s0,0x1
ffffffffc020036e:	97a2                	add	a5,a5,s0
ffffffffc0200370:	078e                	slli	a5,a5,0x3
ffffffffc0200372:	97e2                	add	a5,a5,s8
ffffffffc0200374:	6b9c                	ld	a5,16(a5)
ffffffffc0200376:	865e                	mv	a2,s7
ffffffffc0200378:	002c                	addi	a1,sp,8
ffffffffc020037a:	fffc851b          	addiw	a0,s9,-1
ffffffffc020037e:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200380:	fa0555e3          	bgez	a0,ffffffffc020032a <kmonitor+0x6a>
}
ffffffffc0200384:	60ee                	ld	ra,216(sp)
ffffffffc0200386:	644e                	ld	s0,208(sp)
ffffffffc0200388:	64ae                	ld	s1,200(sp)
ffffffffc020038a:	690e                	ld	s2,192(sp)
ffffffffc020038c:	79ea                	ld	s3,184(sp)
ffffffffc020038e:	7a4a                	ld	s4,176(sp)
ffffffffc0200390:	7aaa                	ld	s5,168(sp)
ffffffffc0200392:	7b0a                	ld	s6,160(sp)
ffffffffc0200394:	6bea                	ld	s7,152(sp)
ffffffffc0200396:	6c4a                	ld	s8,144(sp)
ffffffffc0200398:	6caa                	ld	s9,136(sp)
ffffffffc020039a:	6d0a                	ld	s10,128(sp)
ffffffffc020039c:	612d                	addi	sp,sp,224
ffffffffc020039e:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003a0:	8526                	mv	a0,s1
ffffffffc02003a2:	199000ef          	jal	ra,ffffffffc0200d3a <strchr>
ffffffffc02003a6:	c901                	beqz	a0,ffffffffc02003b6 <kmonitor+0xf6>
ffffffffc02003a8:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc02003ac:	00040023          	sb	zero,0(s0)
ffffffffc02003b0:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003b2:	d5c9                	beqz	a1,ffffffffc020033c <kmonitor+0x7c>
ffffffffc02003b4:	b7f5                	j	ffffffffc02003a0 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc02003b6:	00044783          	lbu	a5,0(s0)
ffffffffc02003ba:	d3c9                	beqz	a5,ffffffffc020033c <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc02003bc:	033c8963          	beq	s9,s3,ffffffffc02003ee <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc02003c0:	003c9793          	slli	a5,s9,0x3
ffffffffc02003c4:	0118                	addi	a4,sp,128
ffffffffc02003c6:	97ba                	add	a5,a5,a4
ffffffffc02003c8:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003cc:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02003d0:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003d2:	e591                	bnez	a1,ffffffffc02003de <kmonitor+0x11e>
ffffffffc02003d4:	b7b5                	j	ffffffffc0200340 <kmonitor+0x80>
ffffffffc02003d6:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc02003da:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003dc:	d1a5                	beqz	a1,ffffffffc020033c <kmonitor+0x7c>
ffffffffc02003de:	8526                	mv	a0,s1
ffffffffc02003e0:	15b000ef          	jal	ra,ffffffffc0200d3a <strchr>
ffffffffc02003e4:	d96d                	beqz	a0,ffffffffc02003d6 <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003e6:	00044583          	lbu	a1,0(s0)
ffffffffc02003ea:	d9a9                	beqz	a1,ffffffffc020033c <kmonitor+0x7c>
ffffffffc02003ec:	bf55                	j	ffffffffc02003a0 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003ee:	45c1                	li	a1,16
ffffffffc02003f0:	855a                	mv	a0,s6
ffffffffc02003f2:	cc1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02003f6:	b7e9                	j	ffffffffc02003c0 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02003f8:	6582                	ld	a1,0(sp)
ffffffffc02003fa:	00001517          	auipc	a0,0x1
ffffffffc02003fe:	0be50513          	addi	a0,a0,190 # ffffffffc02014b8 <etext+0x264>
ffffffffc0200402:	cb1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    return 0;
ffffffffc0200406:	b715                	j	ffffffffc020032a <kmonitor+0x6a>

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
ffffffffc0200420:	5ff000ef          	jal	ra,ffffffffc020121e <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	4807b923          	sd	zero,1170(a5) # ffffffffc02068b8 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00001517          	auipc	a0,0x1
ffffffffc0200432:	0ea50513          	addi	a0,a0,234 # ffffffffc0201518 <commands+0x48>
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
ffffffffc0200446:	5d90006f          	j	ffffffffc020121e <sbi_set_timer>

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
ffffffffc0200450:	5b50006f          	j	ffffffffc0201204 <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	5e50006f          	j	ffffffffc0201238 <sbi_console_getchar>

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
ffffffffc0200482:	0ba50513          	addi	a0,a0,186 # ffffffffc0201538 <commands+0x68>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00001517          	auipc	a0,0x1
ffffffffc0200492:	0c250513          	addi	a0,a0,194 # ffffffffc0201550 <commands+0x80>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00001517          	auipc	a0,0x1
ffffffffc02004a0:	0cc50513          	addi	a0,a0,204 # ffffffffc0201568 <commands+0x98>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00001517          	auipc	a0,0x1
ffffffffc02004ae:	0d650513          	addi	a0,a0,214 # ffffffffc0201580 <commands+0xb0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00001517          	auipc	a0,0x1
ffffffffc02004bc:	0e050513          	addi	a0,a0,224 # ffffffffc0201598 <commands+0xc8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00001517          	auipc	a0,0x1
ffffffffc02004ca:	0ea50513          	addi	a0,a0,234 # ffffffffc02015b0 <commands+0xe0>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00001517          	auipc	a0,0x1
ffffffffc02004d8:	0f450513          	addi	a0,a0,244 # ffffffffc02015c8 <commands+0xf8>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00001517          	auipc	a0,0x1
ffffffffc02004e6:	0fe50513          	addi	a0,a0,254 # ffffffffc02015e0 <commands+0x110>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00001517          	auipc	a0,0x1
ffffffffc02004f4:	10850513          	addi	a0,a0,264 # ffffffffc02015f8 <commands+0x128>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00001517          	auipc	a0,0x1
ffffffffc0200502:	11250513          	addi	a0,a0,274 # ffffffffc0201610 <commands+0x140>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00001517          	auipc	a0,0x1
ffffffffc0200510:	11c50513          	addi	a0,a0,284 # ffffffffc0201628 <commands+0x158>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00001517          	auipc	a0,0x1
ffffffffc020051e:	12650513          	addi	a0,a0,294 # ffffffffc0201640 <commands+0x170>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00001517          	auipc	a0,0x1
ffffffffc020052c:	13050513          	addi	a0,a0,304 # ffffffffc0201658 <commands+0x188>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00001517          	auipc	a0,0x1
ffffffffc020053a:	13a50513          	addi	a0,a0,314 # ffffffffc0201670 <commands+0x1a0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00001517          	auipc	a0,0x1
ffffffffc0200548:	14450513          	addi	a0,a0,324 # ffffffffc0201688 <commands+0x1b8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00001517          	auipc	a0,0x1
ffffffffc0200556:	14e50513          	addi	a0,a0,334 # ffffffffc02016a0 <commands+0x1d0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00001517          	auipc	a0,0x1
ffffffffc0200564:	15850513          	addi	a0,a0,344 # ffffffffc02016b8 <commands+0x1e8>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00001517          	auipc	a0,0x1
ffffffffc0200572:	16250513          	addi	a0,a0,354 # ffffffffc02016d0 <commands+0x200>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00001517          	auipc	a0,0x1
ffffffffc0200580:	16c50513          	addi	a0,a0,364 # ffffffffc02016e8 <commands+0x218>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00001517          	auipc	a0,0x1
ffffffffc020058e:	17650513          	addi	a0,a0,374 # ffffffffc0201700 <commands+0x230>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00001517          	auipc	a0,0x1
ffffffffc020059c:	18050513          	addi	a0,a0,384 # ffffffffc0201718 <commands+0x248>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00001517          	auipc	a0,0x1
ffffffffc02005aa:	18a50513          	addi	a0,a0,394 # ffffffffc0201730 <commands+0x260>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00001517          	auipc	a0,0x1
ffffffffc02005b8:	19450513          	addi	a0,a0,404 # ffffffffc0201748 <commands+0x278>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00001517          	auipc	a0,0x1
ffffffffc02005c6:	19e50513          	addi	a0,a0,414 # ffffffffc0201760 <commands+0x290>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00001517          	auipc	a0,0x1
ffffffffc02005d4:	1a850513          	addi	a0,a0,424 # ffffffffc0201778 <commands+0x2a8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00001517          	auipc	a0,0x1
ffffffffc02005e2:	1b250513          	addi	a0,a0,434 # ffffffffc0201790 <commands+0x2c0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00001517          	auipc	a0,0x1
ffffffffc02005f0:	1bc50513          	addi	a0,a0,444 # ffffffffc02017a8 <commands+0x2d8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00001517          	auipc	a0,0x1
ffffffffc02005fe:	1c650513          	addi	a0,a0,454 # ffffffffc02017c0 <commands+0x2f0>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00001517          	auipc	a0,0x1
ffffffffc020060c:	1d050513          	addi	a0,a0,464 # ffffffffc02017d8 <commands+0x308>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00001517          	auipc	a0,0x1
ffffffffc020061a:	1da50513          	addi	a0,a0,474 # ffffffffc02017f0 <commands+0x320>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00001517          	auipc	a0,0x1
ffffffffc0200628:	1e450513          	addi	a0,a0,484 # ffffffffc0201808 <commands+0x338>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00001517          	auipc	a0,0x1
ffffffffc020063a:	1ea50513          	addi	a0,a0,490 # ffffffffc0201820 <commands+0x350>
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
ffffffffc020064e:	1ee50513          	addi	a0,a0,494 # ffffffffc0201838 <commands+0x368>
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
ffffffffc0200666:	1ee50513          	addi	a0,a0,494 # ffffffffc0201850 <commands+0x380>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00001517          	auipc	a0,0x1
ffffffffc0200676:	1f650513          	addi	a0,a0,502 # ffffffffc0201868 <commands+0x398>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00001517          	auipc	a0,0x1
ffffffffc0200686:	1fe50513          	addi	a0,a0,510 # ffffffffc0201880 <commands+0x3b0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00001517          	auipc	a0,0x1
ffffffffc020069a:	20250513          	addi	a0,a0,514 # ffffffffc0201898 <commands+0x3c8>
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
ffffffffc02006b4:	2c870713          	addi	a4,a4,712 # ffffffffc0201978 <commands+0x4a8>
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
ffffffffc02006c6:	24e50513          	addi	a0,a0,590 # ffffffffc0201910 <commands+0x440>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00001517          	auipc	a0,0x1
ffffffffc02006d0:	22450513          	addi	a0,a0,548 # ffffffffc02018f0 <commands+0x420>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00001517          	auipc	a0,0x1
ffffffffc02006da:	1da50513          	addi	a0,a0,474 # ffffffffc02018b0 <commands+0x3e0>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00001517          	auipc	a0,0x1
ffffffffc02006e4:	25050513          	addi	a0,a0,592 # ffffffffc0201930 <commands+0x460>
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
ffffffffc02006f6:	1c668693          	addi	a3,a3,454 # ffffffffc02068b8 <ticks>
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
ffffffffc0200714:	24850513          	addi	a0,a0,584 # ffffffffc0201958 <commands+0x488>
ffffffffc0200718:	ba69                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020071a:	00001517          	auipc	a0,0x1
ffffffffc020071e:	1b650513          	addi	a0,a0,438 # ffffffffc02018d0 <commands+0x400>
ffffffffc0200722:	ba41                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200724:	bf39                	j	ffffffffc0200642 <print_trapframe>
}
ffffffffc0200726:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200728:	06400593          	li	a1,100
ffffffffc020072c:	00001517          	auipc	a0,0x1
ffffffffc0200730:	21c50513          	addi	a0,a0,540 # ffffffffc0201948 <commands+0x478>
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

ffffffffc0200802 <pmm_init>:

static void check_alloc_page(void);

// init_pmm_manager - initialize a pmm_manager instance
static void init_pmm_manager(void) {
    pmm_manager = &slub_pmm_manager;
ffffffffc0200802:	00001797          	auipc	a5,0x1
ffffffffc0200806:	38678793          	addi	a5,a5,902 # ffffffffc0201b88 <slub_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020080a:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc020080c:	1101                	addi	sp,sp,-32
ffffffffc020080e:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200810:	00001517          	auipc	a0,0x1
ffffffffc0200814:	19850513          	addi	a0,a0,408 # ffffffffc02019a8 <commands+0x4d8>
    pmm_manager = &slub_pmm_manager;
ffffffffc0200818:	00006497          	auipc	s1,0x6
ffffffffc020081c:	0b848493          	addi	s1,s1,184 # ffffffffc02068d0 <pmm_manager>
void pmm_init(void) {
ffffffffc0200820:	ec06                	sd	ra,24(sp)
ffffffffc0200822:	e822                	sd	s0,16(sp)
    pmm_manager = &slub_pmm_manager;
ffffffffc0200824:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200826:	88dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc020082a:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020082c:	00006417          	auipc	s0,0x6
ffffffffc0200830:	0bc40413          	addi	s0,s0,188 # ffffffffc02068e8 <va_pa_offset>
    pmm_manager->init();
ffffffffc0200834:	679c                	ld	a5,8(a5)
ffffffffc0200836:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200838:	57f5                	li	a5,-3
ffffffffc020083a:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc020083c:	00001517          	auipc	a0,0x1
ffffffffc0200840:	18450513          	addi	a0,a0,388 # ffffffffc02019c0 <commands+0x4f0>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200844:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc0200846:	86dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc020084a:	46c5                	li	a3,17
ffffffffc020084c:	06ee                	slli	a3,a3,0x1b
ffffffffc020084e:	40100613          	li	a2,1025
ffffffffc0200852:	16fd                	addi	a3,a3,-1
ffffffffc0200854:	07e005b7          	lui	a1,0x7e00
ffffffffc0200858:	0656                	slli	a2,a2,0x15
ffffffffc020085a:	00001517          	auipc	a0,0x1
ffffffffc020085e:	17e50513          	addi	a0,a0,382 # ffffffffc02019d8 <commands+0x508>
ffffffffc0200862:	851ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200866:	777d                	lui	a4,0xfffff
ffffffffc0200868:	00007797          	auipc	a5,0x7
ffffffffc020086c:	09778793          	addi	a5,a5,151 # ffffffffc02078ff <end+0xfff>
ffffffffc0200870:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0200872:	00006517          	auipc	a0,0x6
ffffffffc0200876:	04e50513          	addi	a0,a0,78 # ffffffffc02068c0 <npage>
ffffffffc020087a:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020087e:	00006597          	auipc	a1,0x6
ffffffffc0200882:	04a58593          	addi	a1,a1,74 # ffffffffc02068c8 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0200886:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200888:	e19c                	sd	a5,0(a1)
ffffffffc020088a:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020088c:	4701                	li	a4,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020088e:	4885                	li	a7,1
ffffffffc0200890:	fff80837          	lui	a6,0xfff80
ffffffffc0200894:	a011                	j	ffffffffc0200898 <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc0200896:	619c                	ld	a5,0(a1)
ffffffffc0200898:	97b6                	add	a5,a5,a3
ffffffffc020089a:	07a1                	addi	a5,a5,8
ffffffffc020089c:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02008a0:	611c                	ld	a5,0(a0)
ffffffffc02008a2:	0705                	addi	a4,a4,1
ffffffffc02008a4:	02868693          	addi	a3,a3,40
ffffffffc02008a8:	01078633          	add	a2,a5,a6
ffffffffc02008ac:	fec765e3          	bltu	a4,a2,ffffffffc0200896 <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02008b0:	6190                	ld	a2,0(a1)
ffffffffc02008b2:	00279713          	slli	a4,a5,0x2
ffffffffc02008b6:	973e                	add	a4,a4,a5
ffffffffc02008b8:	fec006b7          	lui	a3,0xfec00
ffffffffc02008bc:	070e                	slli	a4,a4,0x3
ffffffffc02008be:	96b2                	add	a3,a3,a2
ffffffffc02008c0:	96ba                	add	a3,a3,a4
ffffffffc02008c2:	c0200737          	lui	a4,0xc0200
ffffffffc02008c6:	08e6ef63          	bltu	a3,a4,ffffffffc0200964 <pmm_init+0x162>
ffffffffc02008ca:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc02008cc:	45c5                	li	a1,17
ffffffffc02008ce:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02008d0:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc02008d2:	04b6e863          	bltu	a3,a1,ffffffffc0200922 <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02008d6:	609c                	ld	a5,0(s1)
ffffffffc02008d8:	7b9c                	ld	a5,48(a5)
ffffffffc02008da:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02008dc:	00001517          	auipc	a0,0x1
ffffffffc02008e0:	19450513          	addi	a0,a0,404 # ffffffffc0201a70 <commands+0x5a0>
ffffffffc02008e4:	fceff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02008e8:	00003597          	auipc	a1,0x3
ffffffffc02008ec:	71858593          	addi	a1,a1,1816 # ffffffffc0204000 <boot_page_table_sv39>
ffffffffc02008f0:	00006797          	auipc	a5,0x6
ffffffffc02008f4:	feb7b823          	sd	a1,-16(a5) # ffffffffc02068e0 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02008f8:	c02007b7          	lui	a5,0xc0200
ffffffffc02008fc:	08f5e063          	bltu	a1,a5,ffffffffc020097c <pmm_init+0x17a>
ffffffffc0200900:	6010                	ld	a2,0(s0)
}
ffffffffc0200902:	6442                	ld	s0,16(sp)
ffffffffc0200904:	60e2                	ld	ra,24(sp)
ffffffffc0200906:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0200908:	40c58633          	sub	a2,a1,a2
ffffffffc020090c:	00006797          	auipc	a5,0x6
ffffffffc0200910:	fcc7b623          	sd	a2,-52(a5) # ffffffffc02068d8 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200914:	00001517          	auipc	a0,0x1
ffffffffc0200918:	17c50513          	addi	a0,a0,380 # ffffffffc0201a90 <commands+0x5c0>
}
ffffffffc020091c:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020091e:	f94ff06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200922:	6705                	lui	a4,0x1
ffffffffc0200924:	177d                	addi	a4,a4,-1
ffffffffc0200926:	96ba                	add	a3,a3,a4
ffffffffc0200928:	777d                	lui	a4,0xfffff
ffffffffc020092a:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc020092c:	00c6d513          	srli	a0,a3,0xc
ffffffffc0200930:	00f57e63          	bgeu	a0,a5,ffffffffc020094c <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc0200934:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200936:	982a                	add	a6,a6,a0
ffffffffc0200938:	00281513          	slli	a0,a6,0x2
ffffffffc020093c:	9542                	add	a0,a0,a6
ffffffffc020093e:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200940:	8d95                	sub	a1,a1,a3
ffffffffc0200942:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0200944:	81b1                	srli	a1,a1,0xc
ffffffffc0200946:	9532                	add	a0,a0,a2
ffffffffc0200948:	9782                	jalr	a5
}
ffffffffc020094a:	b771                	j	ffffffffc02008d6 <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc020094c:	00001617          	auipc	a2,0x1
ffffffffc0200950:	0f460613          	addi	a2,a2,244 # ffffffffc0201a40 <commands+0x570>
ffffffffc0200954:	06900593          	li	a1,105
ffffffffc0200958:	00001517          	auipc	a0,0x1
ffffffffc020095c:	10850513          	addi	a0,a0,264 # ffffffffc0201a60 <commands+0x590>
ffffffffc0200960:	fdaff0ef          	jal	ra,ffffffffc020013a <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200964:	00001617          	auipc	a2,0x1
ffffffffc0200968:	0a460613          	addi	a2,a2,164 # ffffffffc0201a08 <commands+0x538>
ffffffffc020096c:	07000593          	li	a1,112
ffffffffc0200970:	00001517          	auipc	a0,0x1
ffffffffc0200974:	0c050513          	addi	a0,a0,192 # ffffffffc0201a30 <commands+0x560>
ffffffffc0200978:	fc2ff0ef          	jal	ra,ffffffffc020013a <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc020097c:	86ae                	mv	a3,a1
ffffffffc020097e:	00001617          	auipc	a2,0x1
ffffffffc0200982:	08a60613          	addi	a2,a2,138 # ffffffffc0201a08 <commands+0x538>
ffffffffc0200986:	08b00593          	li	a1,139
ffffffffc020098a:	00001517          	auipc	a0,0x1
ffffffffc020098e:	0a650513          	addi	a0,a0,166 # ffffffffc0201a30 <commands+0x560>
ffffffffc0200992:	fa8ff0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0200996 <slub_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200996:	00006797          	auipc	a5,0x6
ffffffffc020099a:	a7a78793          	addi	a5,a5,-1414 # ffffffffc0206410 <slab_caches>
ffffffffc020099e:	00006517          	auipc	a0,0x6
ffffffffc02009a2:	a8a50513          	addi	a0,a0,-1398 # ffffffffc0206428 <slab_caches+0x18>
ffffffffc02009a6:	00006597          	auipc	a1,0x6
ffffffffc02009aa:	aaa58593          	addi	a1,a1,-1366 # ffffffffc0206450 <slab_caches+0x40>
ffffffffc02009ae:	00006617          	auipc	a2,0x6
ffffffffc02009b2:	aca60613          	addi	a2,a2,-1334 # ffffffffc0206478 <slab_caches+0x68>
ffffffffc02009b6:	f388                	sd	a0,32(a5)
ffffffffc02009b8:	ef88                	sd	a0,24(a5)
ffffffffc02009ba:	e7ac                	sd	a1,72(a5)

void slub_init(void) {
    for (int i = 0; i < SLAB_MAX_ORDER - SLAB_MIN_ORDER + 1; i++) {
        list_init(&slab_caches[i].free_list);
        slab_caches[i].free_count = 0;
        slab_caches[i].objsize = (1 << (SLAB_MIN_ORDER + i)); // 计算 slab 对象大小
ffffffffc02009bc:	4521                	li	a0,8
ffffffffc02009be:	e3ac                	sd	a1,64(a5)
ffffffffc02009c0:	fbb0                	sd	a2,112(a5)
ffffffffc02009c2:	45c1                	li	a1,16
ffffffffc02009c4:	f7b0                	sd	a2,104(a5)
ffffffffc02009c6:	02000613          	li	a2,32
ffffffffc02009ca:	00006697          	auipc	a3,0x6
ffffffffc02009ce:	ad668693          	addi	a3,a3,-1322 # ffffffffc02064a0 <slab_caches+0x90>
ffffffffc02009d2:	04000713          	li	a4,64
ffffffffc02009d6:	e388                	sd	a0,0(a5)
ffffffffc02009d8:	f78c                	sd	a1,40(a5)
ffffffffc02009da:	ebb0                	sd	a2,80(a5)
        slab_caches[i].total_objects = PGSIZE / slab_caches[i].objsize; // 计算每个 slab 中的对象数量
ffffffffc02009dc:	20000513          	li	a0,512
ffffffffc02009e0:	10000593          	li	a1,256
ffffffffc02009e4:	08000613          	li	a2,128
        slab_caches[i].free_count = 0;
ffffffffc02009e8:	0007b823          	sd	zero,16(a5)
        slab_caches[i].total_objects = PGSIZE / slab_caches[i].objsize; // 计算每个 slab 中的对象数量
ffffffffc02009ec:	e788                	sd	a0,8(a5)
        slab_caches[i].free_count = 0;
ffffffffc02009ee:	0207bc23          	sd	zero,56(a5)
        slab_caches[i].total_objects = PGSIZE / slab_caches[i].objsize; // 计算每个 slab 中的对象数量
ffffffffc02009f2:	fb8c                	sd	a1,48(a5)
        slab_caches[i].free_count = 0;
ffffffffc02009f4:	0607b023          	sd	zero,96(a5)
        slab_caches[i].total_objects = PGSIZE / slab_caches[i].objsize; // 计算每个 slab 中的对象数量
ffffffffc02009f8:	efb0                	sd	a2,88(a5)
ffffffffc02009fa:	efd4                	sd	a3,152(a5)
ffffffffc02009fc:	ebd4                	sd	a3,144(a5)
        slab_caches[i].free_count = 0;
ffffffffc02009fe:	0807b423          	sd	zero,136(a5)
        slab_caches[i].objsize = (1 << (SLAB_MIN_ORDER + i)); // 计算 slab 对象大小
ffffffffc0200a02:	ffb8                	sd	a4,120(a5)
        slab_caches[i].total_objects = PGSIZE / slab_caches[i].objsize; // 计算每个 slab 中的对象数量
ffffffffc0200a04:	e3d8                	sd	a4,128(a5)
    }
    allocated_pages = 0;
ffffffffc0200a06:	00006797          	auipc	a5,0x6
ffffffffc0200a0a:	ee07b523          	sd	zero,-278(a5) # ffffffffc02068f0 <allocated_pages>
}
ffffffffc0200a0e:	8082                	ret

ffffffffc0200a10 <slub_nr_free_pages>:

size_t slub_nr_free_pages(void) {
    size_t total_free_pages = 0;
    for (int order = SLAB_MIN_ORDER; order <= SLAB_MAX_ORDER; order++) {
        struct slab_cache *cache = &slab_caches[order - SLAB_MIN_ORDER];
        total_free_pages += cache->free_count;
ffffffffc0200a10:	00006717          	auipc	a4,0x6
ffffffffc0200a14:	a0070713          	addi	a4,a4,-1536 # ffffffffc0206410 <slab_caches>
ffffffffc0200a18:	6b1c                	ld	a5,16(a4)
ffffffffc0200a1a:	7f10                	ld	a2,56(a4)
ffffffffc0200a1c:	7334                	ld	a3,96(a4)
ffffffffc0200a1e:	6748                	ld	a0,136(a4)
ffffffffc0200a20:	97b2                	add	a5,a5,a2
ffffffffc0200a22:	97b6                	add	a5,a5,a3
    }
    return total_free_pages;
}
ffffffffc0200a24:	953e                	add	a0,a0,a5
ffffffffc0200a26:	8082                	ret

ffffffffc0200a28 <slub_init_memmap>:
void slub_init_memmap(struct Page *base, size_t n) {
ffffffffc0200a28:	1141                	addi	sp,sp,-16
ffffffffc0200a2a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200a2c:	c9dd                	beqz	a1,ffffffffc0200ae2 <slub_init_memmap+0xba>
    for (; p != base + n; p ++) {
ffffffffc0200a2e:	00259893          	slli	a7,a1,0x2
ffffffffc0200a32:	98ae                	add	a7,a7,a1
ffffffffc0200a34:	088e                	slli	a7,a7,0x3
ffffffffc0200a36:	011506b3          	add	a3,a0,a7
ffffffffc0200a3a:	87aa                	mv	a5,a0
ffffffffc0200a3c:	00d50f63          	beq	a0,a3,ffffffffc0200a5a <slub_init_memmap+0x32>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200a40:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0200a42:	8b05                	andi	a4,a4,1
ffffffffc0200a44:	cf3d                	beqz	a4,ffffffffc0200ac2 <slub_init_memmap+0x9a>
        p->flags =0;
ffffffffc0200a46:	0007b423          	sd	zero,8(a5)
        p->property = 0;
ffffffffc0200a4a:	0007a823          	sw	zero,16(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200a4e:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0200a52:	02878793          	addi	a5,a5,40
ffffffffc0200a56:	fed795e3          	bne	a5,a3,ffffffffc0200a40 <slub_init_memmap+0x18>
ffffffffc0200a5a:	01850593          	addi	a1,a0,24
ffffffffc0200a5e:	98ae                	add	a7,a7,a1
ffffffffc0200a60:	00006317          	auipc	t1,0x6
ffffffffc0200a64:	9b030313          	addi	t1,t1,-1616 # ffffffffc0206410 <slab_caches>
        for (int order = SLAB_MIN_ORDER; order <= SLAB_MAX_ORDER; order++) {
ffffffffc0200a68:	4811                	li	a6,4
ffffffffc0200a6a:	00006797          	auipc	a5,0x6
ffffffffc0200a6e:	9a678793          	addi	a5,a5,-1626 # ffffffffc0206410 <slab_caches>
    for (; p != base + n; p ++) {
ffffffffc0200a72:	4701                	li	a4,0
            if (cache->free_count < cache->total_objects) {
ffffffffc0200a74:	6b90                	ld	a2,16(a5)
ffffffffc0200a76:	6794                	ld	a3,8(a5)
            struct slab_cache *cache = &slab_caches[order - SLAB_MIN_ORDER];
ffffffffc0200a78:	0007051b          	sext.w	a0,a4
            if (cache->free_count < cache->total_objects) {
ffffffffc0200a7c:	00d66e63          	bltu	a2,a3,ffffffffc0200a98 <slub_init_memmap+0x70>
        for (int order = SLAB_MIN_ORDER; order <= SLAB_MAX_ORDER; order++) {
ffffffffc0200a80:	2705                	addiw	a4,a4,1
ffffffffc0200a82:	02878793          	addi	a5,a5,40
ffffffffc0200a86:	ff0717e3          	bne	a4,a6,ffffffffc0200a74 <slub_init_memmap+0x4c>
    for (size_t i = 0; i < n; i++) {
ffffffffc0200a8a:	02858593          	addi	a1,a1,40
ffffffffc0200a8e:	fd159ee3          	bne	a1,a7,ffffffffc0200a6a <slub_init_memmap+0x42>
}
ffffffffc0200a92:	60a2                	ld	ra,8(sp)
ffffffffc0200a94:	0141                	addi	sp,sp,16
ffffffffc0200a96:	8082                	ret
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
ffffffffc0200a98:	00251793          	slli	a5,a0,0x2
ffffffffc0200a9c:	953e                	add	a0,a0,a5
ffffffffc0200a9e:	050e                	slli	a0,a0,0x3
ffffffffc0200aa0:	00a307b3          	add	a5,t1,a0
ffffffffc0200aa4:	7398                	ld	a4,32(a5)
                list_add(&cache->free_list, &page->page_link);  
ffffffffc0200aa6:	0561                	addi	a0,a0,24
ffffffffc0200aa8:	951a                	add	a0,a0,t1
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200aaa:	e30c                	sd	a1,0(a4)
ffffffffc0200aac:	f38c                	sd	a1,32(a5)
    elm->next = next;
ffffffffc0200aae:	e598                	sd	a4,8(a1)
    elm->prev = prev;
ffffffffc0200ab0:	e188                	sd	a0,0(a1)
                cache->free_count++;
ffffffffc0200ab2:	6b98                	ld	a4,16(a5)
    for (size_t i = 0; i < n; i++) {
ffffffffc0200ab4:	02858593          	addi	a1,a1,40
                cache->free_count++;
ffffffffc0200ab8:	0705                	addi	a4,a4,1
ffffffffc0200aba:	eb98                	sd	a4,16(a5)
    for (size_t i = 0; i < n; i++) {
ffffffffc0200abc:	fb1597e3          	bne	a1,a7,ffffffffc0200a6a <slub_init_memmap+0x42>
ffffffffc0200ac0:	bfc9                	j	ffffffffc0200a92 <slub_init_memmap+0x6a>
        assert(PageReserved(p));
ffffffffc0200ac2:	00001697          	auipc	a3,0x1
ffffffffc0200ac6:	04668693          	addi	a3,a3,70 # ffffffffc0201b08 <commands+0x638>
ffffffffc0200aca:	00001617          	auipc	a2,0x1
ffffffffc0200ace:	00e60613          	addi	a2,a2,14 # ffffffffc0201ad8 <commands+0x608>
ffffffffc0200ad2:	02800593          	li	a1,40
ffffffffc0200ad6:	00001517          	auipc	a0,0x1
ffffffffc0200ada:	01a50513          	addi	a0,a0,26 # ffffffffc0201af0 <commands+0x620>
ffffffffc0200ade:	e5cff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(n > 0);
ffffffffc0200ae2:	00001697          	auipc	a3,0x1
ffffffffc0200ae6:	fee68693          	addi	a3,a3,-18 # ffffffffc0201ad0 <commands+0x600>
ffffffffc0200aea:	00001617          	auipc	a2,0x1
ffffffffc0200aee:	fee60613          	addi	a2,a2,-18 # ffffffffc0201ad8 <commands+0x608>
ffffffffc0200af2:	02500593          	li	a1,37
ffffffffc0200af6:	00001517          	auipc	a0,0x1
ffffffffc0200afa:	ffa50513          	addi	a0,a0,-6 # ffffffffc0201af0 <commands+0x620>
ffffffffc0200afe:	e3cff0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0200b02 <slub_alloc_pages>:
    if (n == 1) {
ffffffffc0200b02:	4785                	li	a5,1
ffffffffc0200b04:	08f51363          	bne	a0,a5,ffffffffc0200b8a <slub_alloc_pages+0x88>
    return list->next == list;
ffffffffc0200b08:	00006797          	auipc	a5,0x6
ffffffffc0200b0c:	90878793          	addi	a5,a5,-1784 # ffffffffc0206410 <slab_caches>
ffffffffc0200b10:	7388                	ld	a0,32(a5)
            if (!list_empty(&cache->free_list)) {
ffffffffc0200b12:	00006697          	auipc	a3,0x6
ffffffffc0200b16:	91668693          	addi	a3,a3,-1770 # ffffffffc0206428 <slab_caches+0x18>
ffffffffc0200b1a:	08d51963          	bne	a0,a3,ffffffffc0200bac <slub_alloc_pages+0xaa>
ffffffffc0200b1e:	67a8                	ld	a0,72(a5)
ffffffffc0200b20:	00006717          	auipc	a4,0x6
ffffffffc0200b24:	93070713          	addi	a4,a4,-1744 # ffffffffc0206450 <slab_caches+0x40>
ffffffffc0200b28:	06e51363          	bne	a0,a4,ffffffffc0200b8e <slub_alloc_pages+0x8c>
ffffffffc0200b2c:	7ba8                	ld	a0,112(a5)
ffffffffc0200b2e:	00006717          	auipc	a4,0x6
ffffffffc0200b32:	94a70713          	addi	a4,a4,-1718 # ffffffffc0206478 <slab_caches+0x68>
ffffffffc0200b36:	06e51d63          	bne	a0,a4,ffffffffc0200bb0 <slub_alloc_pages+0xae>
ffffffffc0200b3a:	6fc8                	ld	a0,152(a5)
ffffffffc0200b3c:	00006717          	auipc	a4,0x6
ffffffffc0200b40:	96470713          	addi	a4,a4,-1692 # ffffffffc02064a0 <slab_caches+0x90>
ffffffffc0200b44:	06e51863          	bne	a0,a4,ffffffffc0200bb4 <slub_alloc_pages+0xb2>
    if (allocated_pages + n > MAX_PAGES) {
ffffffffc0200b48:	00006597          	auipc	a1,0x6
ffffffffc0200b4c:	da858593          	addi	a1,a1,-600 # ffffffffc02068f0 <allocated_pages>
ffffffffc0200b50:	6198                	ld	a4,0(a1)
ffffffffc0200b52:	08000613          	li	a2,128
ffffffffc0200b56:	00170813          	addi	a6,a4,1
ffffffffc0200b5a:	03066863          	bltu	a2,a6,ffffffffc0200b8a <slub_alloc_pages+0x88>
    struct Page* page = &page_pool[allocated_pages];
ffffffffc0200b5e:	00271513          	slli	a0,a4,0x2
                cache->free_count++;
ffffffffc0200b62:	6b90                	ld	a2,16(a5)
ffffffffc0200b64:	953a                	add	a0,a0,a4
ffffffffc0200b66:	050e                	slli	a0,a0,0x3
    struct Page* page = &page_pool[allocated_pages];
ffffffffc0200b68:	00004897          	auipc	a7,0x4
ffffffffc0200b6c:	4a888893          	addi	a7,a7,1192 # ffffffffc0205010 <page_pool>
                list_add(&cache->free_list, &new_page->page_link);
ffffffffc0200b70:	01850713          	addi	a4,a0,24
ffffffffc0200b74:	9746                	add	a4,a4,a7
    struct Page* page = &page_pool[allocated_pages];
ffffffffc0200b76:	9546                	add	a0,a0,a7
                cache->free_count++;
ffffffffc0200b78:	0605                	addi	a2,a2,1
    allocated_pages += n;
ffffffffc0200b7a:	0105b023          	sd	a6,0(a1)
    prev->next = next->prev = elm;
ffffffffc0200b7e:	ef98                	sd	a4,24(a5)
ffffffffc0200b80:	f398                	sd	a4,32(a5)
    elm->next = next;
ffffffffc0200b82:	f114                	sd	a3,32(a0)
    elm->prev = prev;
ffffffffc0200b84:	ed14                	sd	a3,24(a0)
                cache->free_count++;
ffffffffc0200b86:	eb90                	sd	a2,16(a5)
                return new_page;  // 返回新分配的页
ffffffffc0200b88:	8082                	ret
    return NULL;  // 如果找不到合适的 slab 或静态分配失败，返回 NULL
ffffffffc0200b8a:	4501                	li	a0,0
}
ffffffffc0200b8c:	8082                	ret
            struct slab_cache *cache = &slab_caches[order - SLAB_MIN_ORDER];
ffffffffc0200b8e:	4685                	li	a3,1
    __list_del(listelm->prev, listelm->next);
ffffffffc0200b90:	610c                	ld	a1,0(a0)
ffffffffc0200b92:	6510                	ld	a2,8(a0)
                cache->free_count--;
ffffffffc0200b94:	00269713          	slli	a4,a3,0x2
ffffffffc0200b98:	9736                	add	a4,a4,a3
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200b9a:	e590                	sd	a2,8(a1)
ffffffffc0200b9c:	070e                	slli	a4,a4,0x3
    next->prev = prev;
ffffffffc0200b9e:	e20c                	sd	a1,0(a2)
ffffffffc0200ba0:	97ba                	add	a5,a5,a4
ffffffffc0200ba2:	6b98                	ld	a4,16(a5)
                struct Page *page = le2page(list_next(&cache->free_list), page_link);
ffffffffc0200ba4:	1521                	addi	a0,a0,-24
                cache->free_count--;
ffffffffc0200ba6:	177d                	addi	a4,a4,-1
ffffffffc0200ba8:	eb98                	sd	a4,16(a5)
                return page;
ffffffffc0200baa:	8082                	ret
            struct slab_cache *cache = &slab_caches[order - SLAB_MIN_ORDER];
ffffffffc0200bac:	4681                	li	a3,0
ffffffffc0200bae:	b7cd                	j	ffffffffc0200b90 <slub_alloc_pages+0x8e>
ffffffffc0200bb0:	4689                	li	a3,2
ffffffffc0200bb2:	bff9                	j	ffffffffc0200b90 <slub_alloc_pages+0x8e>
ffffffffc0200bb4:	468d                	li	a3,3
ffffffffc0200bb6:	bfe9                	j	ffffffffc0200b90 <slub_alloc_pages+0x8e>

ffffffffc0200bb8 <slub_free_pages>:
    if (n == 1) {
ffffffffc0200bb8:	4785                	li	a5,1
ffffffffc0200bba:	00f58363          	beq	a1,a5,ffffffffc0200bc0 <slub_free_pages+0x8>
}
ffffffffc0200bbe:	8082                	ret
    __list_add(elm, listelm, listelm->next);
ffffffffc0200bc0:	00006797          	auipc	a5,0x6
ffffffffc0200bc4:	85078793          	addi	a5,a5,-1968 # ffffffffc0206410 <slab_caches>
ffffffffc0200bc8:	7394                	ld	a3,32(a5)
            cache->free_count++;
ffffffffc0200bca:	6b98                	ld	a4,16(a5)
            list_add(&cache->free_list, &base->page_link);  
ffffffffc0200bcc:	01850613          	addi	a2,a0,24
    prev->next = next->prev = elm;
ffffffffc0200bd0:	e290                	sd	a2,0(a3)
ffffffffc0200bd2:	f390                	sd	a2,32(a5)
            cache->free_count++;
ffffffffc0200bd4:	0705                	addi	a4,a4,1
    elm->next = next;
ffffffffc0200bd6:	f114                	sd	a3,32(a0)
    elm->prev = prev;
ffffffffc0200bd8:	00006697          	auipc	a3,0x6
ffffffffc0200bdc:	85068693          	addi	a3,a3,-1968 # ffffffffc0206428 <slab_caches+0x18>
ffffffffc0200be0:	ed14                	sd	a3,24(a0)
ffffffffc0200be2:	eb98                	sd	a4,16(a5)
}
ffffffffc0200be4:	8082                	ret

ffffffffc0200be6 <slub_check>:
void slub_check(void) {
ffffffffc0200be6:	7179                	addi	sp,sp,-48
ffffffffc0200be8:	f022                	sd	s0,32(sp)
        total_free_pages += cache->free_count;
ffffffffc0200bea:	00006417          	auipc	s0,0x6
ffffffffc0200bee:	82640413          	addi	s0,s0,-2010 # ffffffffc0206410 <slab_caches>
ffffffffc0200bf2:	681c                	ld	a5,16(s0)
ffffffffc0200bf4:	7c14                	ld	a3,56(s0)
ffffffffc0200bf6:	7038                	ld	a4,96(s0)
void slub_check(void) {
ffffffffc0200bf8:	e44e                	sd	s3,8(sp)
        total_free_pages += cache->free_count;
ffffffffc0200bfa:	08843983          	ld	s3,136(s0)
ffffffffc0200bfe:	97b6                	add	a5,a5,a3
ffffffffc0200c00:	97ba                	add	a5,a5,a4
    size_t all_pages = slub_nr_free_pages();
    struct Page *p0, *p1, *p2;

    // 测试分配和释放
    p0 = slub_alloc_pages(1);
ffffffffc0200c02:	4505                	li	a0,1
void slub_check(void) {
ffffffffc0200c04:	f406                	sd	ra,40(sp)
ffffffffc0200c06:	ec26                	sd	s1,24(sp)
ffffffffc0200c08:	e84a                	sd	s2,16(sp)
        total_free_pages += cache->free_count;
ffffffffc0200c0a:	99be                	add	s3,s3,a5
    p0 = slub_alloc_pages(1);
ffffffffc0200c0c:	ef7ff0ef          	jal	ra,ffffffffc0200b02 <slub_alloc_pages>
    assert(p0 != NULL);
ffffffffc0200c10:	c925                	beqz	a0,ffffffffc0200c80 <slub_check+0x9a>
ffffffffc0200c12:	84aa                	mv	s1,a0
    p1 = slub_alloc_pages(1);
ffffffffc0200c14:	4505                	li	a0,1
ffffffffc0200c16:	eedff0ef          	jal	ra,ffffffffc0200b02 <slub_alloc_pages>
ffffffffc0200c1a:	892a                	mv	s2,a0
    assert(p1 != NULL);
ffffffffc0200c1c:	c171                	beqz	a0,ffffffffc0200ce0 <slub_check+0xfa>
    p2 = slub_alloc_pages(1);
ffffffffc0200c1e:	4505                	li	a0,1
ffffffffc0200c20:	ee3ff0ef          	jal	ra,ffffffffc0200b02 <slub_alloc_pages>
    assert(p2 != NULL);
ffffffffc0200c24:	cd51                	beqz	a0,ffffffffc0200cc0 <slub_check+0xda>
    __list_add(elm, listelm, listelm->next);
ffffffffc0200c26:	7018                	ld	a4,32(s0)
            list_add(&cache->free_list, &base->page_link);  
ffffffffc0200c28:	01848693          	addi	a3,s1,24
    elm->prev = prev;
ffffffffc0200c2c:	00005797          	auipc	a5,0x5
ffffffffc0200c30:	7fc78793          	addi	a5,a5,2044 # ffffffffc0206428 <slab_caches+0x18>
    prev->next = next->prev = elm;
ffffffffc0200c34:	e314                	sd	a3,0(a4)
ffffffffc0200c36:	f014                	sd	a3,32(s0)
    elm->next = next;
ffffffffc0200c38:	f098                	sd	a4,32(s1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200c3a:	7014                	ld	a3,32(s0)
ffffffffc0200c3c:	01890613          	addi	a2,s2,24
    elm->prev = prev;
ffffffffc0200c40:	ec9c                	sd	a5,24(s1)
            cache->free_count++;
ffffffffc0200c42:	6818                	ld	a4,16(s0)
    prev->next = next->prev = elm;
ffffffffc0200c44:	e290                	sd	a2,0(a3)
ffffffffc0200c46:	f010                	sd	a2,32(s0)
    elm->next = next;
ffffffffc0200c48:	02d93023          	sd	a3,32(s2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200c4c:	7014                	ld	a3,32(s0)
            list_add(&cache->free_list, &base->page_link);  
ffffffffc0200c4e:	01850613          	addi	a2,a0,24
    elm->prev = prev;
ffffffffc0200c52:	00f93c23          	sd	a5,24(s2)
    prev->next = next->prev = elm;
ffffffffc0200c56:	e290                	sd	a2,0(a3)
ffffffffc0200c58:	f010                	sd	a2,32(s0)
    elm->next = next;
ffffffffc0200c5a:	f114                	sd	a3,32(a0)
    elm->prev = prev;
ffffffffc0200c5c:	ed1c                	sd	a5,24(a0)
        total_free_pages += cache->free_count;
ffffffffc0200c5e:	7c1c                	ld	a5,56(s0)
ffffffffc0200c60:	7030                	ld	a2,96(s0)
ffffffffc0200c62:	6454                	ld	a3,136(s0)
            cache->free_count++;
ffffffffc0200c64:	070d                	addi	a4,a4,3
        total_free_pages += cache->free_count;
ffffffffc0200c66:	97b2                	add	a5,a5,a2
ffffffffc0200c68:	97b6                	add	a5,a5,a3
            cache->free_count++;
ffffffffc0200c6a:	e818                	sd	a4,16(s0)
        total_free_pages += cache->free_count;
ffffffffc0200c6c:	97ba                	add	a5,a5,a4
    slub_free_pages(p0, 1);
    slub_free_pages(p1, 1);
    slub_free_pages(p2, 1);

    // 确认所有页数都正确释放
    assert(slub_nr_free_pages() == all_pages);
ffffffffc0200c6e:	03379963          	bne	a5,s3,ffffffffc0200ca0 <slub_check+0xba>

    // cprintf("SLUB allocator test passed.\n");
}
ffffffffc0200c72:	70a2                	ld	ra,40(sp)
ffffffffc0200c74:	7402                	ld	s0,32(sp)
ffffffffc0200c76:	64e2                	ld	s1,24(sp)
ffffffffc0200c78:	6942                	ld	s2,16(sp)
ffffffffc0200c7a:	69a2                	ld	s3,8(sp)
ffffffffc0200c7c:	6145                	addi	sp,sp,48
ffffffffc0200c7e:	8082                	ret
    assert(p0 != NULL);
ffffffffc0200c80:	00001697          	auipc	a3,0x1
ffffffffc0200c84:	e9868693          	addi	a3,a3,-360 # ffffffffc0201b18 <commands+0x648>
ffffffffc0200c88:	00001617          	auipc	a2,0x1
ffffffffc0200c8c:	e5060613          	addi	a2,a2,-432 # ffffffffc0201ad8 <commands+0x608>
ffffffffc0200c90:	07b00593          	li	a1,123
ffffffffc0200c94:	00001517          	auipc	a0,0x1
ffffffffc0200c98:	e5c50513          	addi	a0,a0,-420 # ffffffffc0201af0 <commands+0x620>
ffffffffc0200c9c:	c9eff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(slub_nr_free_pages() == all_pages);
ffffffffc0200ca0:	00001697          	auipc	a3,0x1
ffffffffc0200ca4:	ea868693          	addi	a3,a3,-344 # ffffffffc0201b48 <commands+0x678>
ffffffffc0200ca8:	00001617          	auipc	a2,0x1
ffffffffc0200cac:	e3060613          	addi	a2,a2,-464 # ffffffffc0201ad8 <commands+0x608>
ffffffffc0200cb0:	08700593          	li	a1,135
ffffffffc0200cb4:	00001517          	auipc	a0,0x1
ffffffffc0200cb8:	e3c50513          	addi	a0,a0,-452 # ffffffffc0201af0 <commands+0x620>
ffffffffc0200cbc:	c7eff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(p2 != NULL);
ffffffffc0200cc0:	00001697          	auipc	a3,0x1
ffffffffc0200cc4:	e7868693          	addi	a3,a3,-392 # ffffffffc0201b38 <commands+0x668>
ffffffffc0200cc8:	00001617          	auipc	a2,0x1
ffffffffc0200ccc:	e1060613          	addi	a2,a2,-496 # ffffffffc0201ad8 <commands+0x608>
ffffffffc0200cd0:	07f00593          	li	a1,127
ffffffffc0200cd4:	00001517          	auipc	a0,0x1
ffffffffc0200cd8:	e1c50513          	addi	a0,a0,-484 # ffffffffc0201af0 <commands+0x620>
ffffffffc0200cdc:	c5eff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(p1 != NULL);
ffffffffc0200ce0:	00001697          	auipc	a3,0x1
ffffffffc0200ce4:	e4868693          	addi	a3,a3,-440 # ffffffffc0201b28 <commands+0x658>
ffffffffc0200ce8:	00001617          	auipc	a2,0x1
ffffffffc0200cec:	df060613          	addi	a2,a2,-528 # ffffffffc0201ad8 <commands+0x608>
ffffffffc0200cf0:	07d00593          	li	a1,125
ffffffffc0200cf4:	00001517          	auipc	a0,0x1
ffffffffc0200cf8:	dfc50513          	addi	a0,a0,-516 # ffffffffc0201af0 <commands+0x620>
ffffffffc0200cfc:	c3eff0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0200d00 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0200d00:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0200d02:	e589                	bnez	a1,ffffffffc0200d0c <strnlen+0xc>
ffffffffc0200d04:	a811                	j	ffffffffc0200d18 <strnlen+0x18>
        cnt ++;
ffffffffc0200d06:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0200d08:	00f58863          	beq	a1,a5,ffffffffc0200d18 <strnlen+0x18>
ffffffffc0200d0c:	00f50733          	add	a4,a0,a5
ffffffffc0200d10:	00074703          	lbu	a4,0(a4)
ffffffffc0200d14:	fb6d                	bnez	a4,ffffffffc0200d06 <strnlen+0x6>
ffffffffc0200d16:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0200d18:	852e                	mv	a0,a1
ffffffffc0200d1a:	8082                	ret

ffffffffc0200d1c <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0200d1c:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0200d20:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0200d24:	cb89                	beqz	a5,ffffffffc0200d36 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0200d26:	0505                	addi	a0,a0,1
ffffffffc0200d28:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0200d2a:	fee789e3          	beq	a5,a4,ffffffffc0200d1c <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0200d2e:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0200d32:	9d19                	subw	a0,a0,a4
ffffffffc0200d34:	8082                	ret
ffffffffc0200d36:	4501                	li	a0,0
ffffffffc0200d38:	bfed                	j	ffffffffc0200d32 <strcmp+0x16>

ffffffffc0200d3a <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0200d3a:	00054783          	lbu	a5,0(a0)
ffffffffc0200d3e:	c799                	beqz	a5,ffffffffc0200d4c <strchr+0x12>
        if (*s == c) {
ffffffffc0200d40:	00f58763          	beq	a1,a5,ffffffffc0200d4e <strchr+0x14>
    while (*s != '\0') {
ffffffffc0200d44:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0200d48:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0200d4a:	fbfd                	bnez	a5,ffffffffc0200d40 <strchr+0x6>
    }
    return NULL;
ffffffffc0200d4c:	4501                	li	a0,0
}
ffffffffc0200d4e:	8082                	ret

ffffffffc0200d50 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0200d50:	ca01                	beqz	a2,ffffffffc0200d60 <memset+0x10>
ffffffffc0200d52:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0200d54:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0200d56:	0785                	addi	a5,a5,1
ffffffffc0200d58:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0200d5c:	fec79de3          	bne	a5,a2,ffffffffc0200d56 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0200d60:	8082                	ret

ffffffffc0200d62 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0200d62:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200d66:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0200d68:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200d6c:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0200d6e:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200d72:	f022                	sd	s0,32(sp)
ffffffffc0200d74:	ec26                	sd	s1,24(sp)
ffffffffc0200d76:	e84a                	sd	s2,16(sp)
ffffffffc0200d78:	f406                	sd	ra,40(sp)
ffffffffc0200d7a:	e44e                	sd	s3,8(sp)
ffffffffc0200d7c:	84aa                	mv	s1,a0
ffffffffc0200d7e:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0200d80:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0200d84:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0200d86:	03067e63          	bgeu	a2,a6,ffffffffc0200dc2 <printnum+0x60>
ffffffffc0200d8a:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0200d8c:	00805763          	blez	s0,ffffffffc0200d9a <printnum+0x38>
ffffffffc0200d90:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0200d92:	85ca                	mv	a1,s2
ffffffffc0200d94:	854e                	mv	a0,s3
ffffffffc0200d96:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0200d98:	fc65                	bnez	s0,ffffffffc0200d90 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200d9a:	1a02                	slli	s4,s4,0x20
ffffffffc0200d9c:	00001797          	auipc	a5,0x1
ffffffffc0200da0:	e2478793          	addi	a5,a5,-476 # ffffffffc0201bc0 <slub_pmm_manager+0x38>
ffffffffc0200da4:	020a5a13          	srli	s4,s4,0x20
ffffffffc0200da8:	9a3e                	add	s4,s4,a5
}
ffffffffc0200daa:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200dac:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0200db0:	70a2                	ld	ra,40(sp)
ffffffffc0200db2:	69a2                	ld	s3,8(sp)
ffffffffc0200db4:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200db6:	85ca                	mv	a1,s2
ffffffffc0200db8:	87a6                	mv	a5,s1
}
ffffffffc0200dba:	6942                	ld	s2,16(sp)
ffffffffc0200dbc:	64e2                	ld	s1,24(sp)
ffffffffc0200dbe:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200dc0:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0200dc2:	03065633          	divu	a2,a2,a6
ffffffffc0200dc6:	8722                	mv	a4,s0
ffffffffc0200dc8:	f9bff0ef          	jal	ra,ffffffffc0200d62 <printnum>
ffffffffc0200dcc:	b7f9                	j	ffffffffc0200d9a <printnum+0x38>

ffffffffc0200dce <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0200dce:	7119                	addi	sp,sp,-128
ffffffffc0200dd0:	f4a6                	sd	s1,104(sp)
ffffffffc0200dd2:	f0ca                	sd	s2,96(sp)
ffffffffc0200dd4:	ecce                	sd	s3,88(sp)
ffffffffc0200dd6:	e8d2                	sd	s4,80(sp)
ffffffffc0200dd8:	e4d6                	sd	s5,72(sp)
ffffffffc0200dda:	e0da                	sd	s6,64(sp)
ffffffffc0200ddc:	fc5e                	sd	s7,56(sp)
ffffffffc0200dde:	f06a                	sd	s10,32(sp)
ffffffffc0200de0:	fc86                	sd	ra,120(sp)
ffffffffc0200de2:	f8a2                	sd	s0,112(sp)
ffffffffc0200de4:	f862                	sd	s8,48(sp)
ffffffffc0200de6:	f466                	sd	s9,40(sp)
ffffffffc0200de8:	ec6e                	sd	s11,24(sp)
ffffffffc0200dea:	892a                	mv	s2,a0
ffffffffc0200dec:	84ae                	mv	s1,a1
ffffffffc0200dee:	8d32                	mv	s10,a2
ffffffffc0200df0:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0200df2:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0200df6:	5b7d                	li	s6,-1
ffffffffc0200df8:	00001a97          	auipc	s5,0x1
ffffffffc0200dfc:	dfca8a93          	addi	s5,s5,-516 # ffffffffc0201bf4 <slub_pmm_manager+0x6c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0200e00:	00001b97          	auipc	s7,0x1
ffffffffc0200e04:	fd0b8b93          	addi	s7,s7,-48 # ffffffffc0201dd0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0200e08:	000d4503          	lbu	a0,0(s10)
ffffffffc0200e0c:	001d0413          	addi	s0,s10,1
ffffffffc0200e10:	01350a63          	beq	a0,s3,ffffffffc0200e24 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0200e14:	c121                	beqz	a0,ffffffffc0200e54 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0200e16:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0200e18:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0200e1a:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0200e1c:	fff44503          	lbu	a0,-1(s0)
ffffffffc0200e20:	ff351ae3          	bne	a0,s3,ffffffffc0200e14 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200e24:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0200e28:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0200e2c:	4c81                	li	s9,0
ffffffffc0200e2e:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0200e30:	5c7d                	li	s8,-1
ffffffffc0200e32:	5dfd                	li	s11,-1
ffffffffc0200e34:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0200e38:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200e3a:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0200e3e:	0ff5f593          	zext.b	a1,a1
ffffffffc0200e42:	00140d13          	addi	s10,s0,1
ffffffffc0200e46:	04b56263          	bltu	a0,a1,ffffffffc0200e8a <vprintfmt+0xbc>
ffffffffc0200e4a:	058a                	slli	a1,a1,0x2
ffffffffc0200e4c:	95d6                	add	a1,a1,s5
ffffffffc0200e4e:	4194                	lw	a3,0(a1)
ffffffffc0200e50:	96d6                	add	a3,a3,s5
ffffffffc0200e52:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0200e54:	70e6                	ld	ra,120(sp)
ffffffffc0200e56:	7446                	ld	s0,112(sp)
ffffffffc0200e58:	74a6                	ld	s1,104(sp)
ffffffffc0200e5a:	7906                	ld	s2,96(sp)
ffffffffc0200e5c:	69e6                	ld	s3,88(sp)
ffffffffc0200e5e:	6a46                	ld	s4,80(sp)
ffffffffc0200e60:	6aa6                	ld	s5,72(sp)
ffffffffc0200e62:	6b06                	ld	s6,64(sp)
ffffffffc0200e64:	7be2                	ld	s7,56(sp)
ffffffffc0200e66:	7c42                	ld	s8,48(sp)
ffffffffc0200e68:	7ca2                	ld	s9,40(sp)
ffffffffc0200e6a:	7d02                	ld	s10,32(sp)
ffffffffc0200e6c:	6de2                	ld	s11,24(sp)
ffffffffc0200e6e:	6109                	addi	sp,sp,128
ffffffffc0200e70:	8082                	ret
            padc = '0';
ffffffffc0200e72:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0200e74:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200e78:	846a                	mv	s0,s10
ffffffffc0200e7a:	00140d13          	addi	s10,s0,1
ffffffffc0200e7e:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0200e82:	0ff5f593          	zext.b	a1,a1
ffffffffc0200e86:	fcb572e3          	bgeu	a0,a1,ffffffffc0200e4a <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0200e8a:	85a6                	mv	a1,s1
ffffffffc0200e8c:	02500513          	li	a0,37
ffffffffc0200e90:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0200e92:	fff44783          	lbu	a5,-1(s0)
ffffffffc0200e96:	8d22                	mv	s10,s0
ffffffffc0200e98:	f73788e3          	beq	a5,s3,ffffffffc0200e08 <vprintfmt+0x3a>
ffffffffc0200e9c:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0200ea0:	1d7d                	addi	s10,s10,-1
ffffffffc0200ea2:	ff379de3          	bne	a5,s3,ffffffffc0200e9c <vprintfmt+0xce>
ffffffffc0200ea6:	b78d                	j	ffffffffc0200e08 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0200ea8:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0200eac:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200eb0:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0200eb2:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0200eb6:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0200eba:	02d86463          	bltu	a6,a3,ffffffffc0200ee2 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0200ebe:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0200ec2:	002c169b          	slliw	a3,s8,0x2
ffffffffc0200ec6:	0186873b          	addw	a4,a3,s8
ffffffffc0200eca:	0017171b          	slliw	a4,a4,0x1
ffffffffc0200ece:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0200ed0:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0200ed4:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0200ed6:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0200eda:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0200ede:	fed870e3          	bgeu	a6,a3,ffffffffc0200ebe <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0200ee2:	f40ddce3          	bgez	s11,ffffffffc0200e3a <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0200ee6:	8de2                	mv	s11,s8
ffffffffc0200ee8:	5c7d                	li	s8,-1
ffffffffc0200eea:	bf81                	j	ffffffffc0200e3a <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0200eec:	fffdc693          	not	a3,s11
ffffffffc0200ef0:	96fd                	srai	a3,a3,0x3f
ffffffffc0200ef2:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200ef6:	00144603          	lbu	a2,1(s0)
ffffffffc0200efa:	2d81                	sext.w	s11,s11
ffffffffc0200efc:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0200efe:	bf35                	j	ffffffffc0200e3a <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0200f00:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200f04:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0200f08:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200f0a:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0200f0c:	bfd9                	j	ffffffffc0200ee2 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0200f0e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0200f10:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0200f14:	01174463          	blt	a4,a7,ffffffffc0200f1c <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0200f18:	1a088e63          	beqz	a7,ffffffffc02010d4 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0200f1c:	000a3603          	ld	a2,0(s4)
ffffffffc0200f20:	46c1                	li	a3,16
ffffffffc0200f22:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0200f24:	2781                	sext.w	a5,a5
ffffffffc0200f26:	876e                	mv	a4,s11
ffffffffc0200f28:	85a6                	mv	a1,s1
ffffffffc0200f2a:	854a                	mv	a0,s2
ffffffffc0200f2c:	e37ff0ef          	jal	ra,ffffffffc0200d62 <printnum>
            break;
ffffffffc0200f30:	bde1                	j	ffffffffc0200e08 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0200f32:	000a2503          	lw	a0,0(s4)
ffffffffc0200f36:	85a6                	mv	a1,s1
ffffffffc0200f38:	0a21                	addi	s4,s4,8
ffffffffc0200f3a:	9902                	jalr	s2
            break;
ffffffffc0200f3c:	b5f1                	j	ffffffffc0200e08 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0200f3e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0200f40:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0200f44:	01174463          	blt	a4,a7,ffffffffc0200f4c <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0200f48:	18088163          	beqz	a7,ffffffffc02010ca <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0200f4c:	000a3603          	ld	a2,0(s4)
ffffffffc0200f50:	46a9                	li	a3,10
ffffffffc0200f52:	8a2e                	mv	s4,a1
ffffffffc0200f54:	bfc1                	j	ffffffffc0200f24 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200f56:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0200f5a:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200f5c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0200f5e:	bdf1                	j	ffffffffc0200e3a <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0200f60:	85a6                	mv	a1,s1
ffffffffc0200f62:	02500513          	li	a0,37
ffffffffc0200f66:	9902                	jalr	s2
            break;
ffffffffc0200f68:	b545                	j	ffffffffc0200e08 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200f6a:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0200f6e:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200f70:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0200f72:	b5e1                	j	ffffffffc0200e3a <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0200f74:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0200f76:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0200f7a:	01174463          	blt	a4,a7,ffffffffc0200f82 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0200f7e:	14088163          	beqz	a7,ffffffffc02010c0 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0200f82:	000a3603          	ld	a2,0(s4)
ffffffffc0200f86:	46a1                	li	a3,8
ffffffffc0200f88:	8a2e                	mv	s4,a1
ffffffffc0200f8a:	bf69                	j	ffffffffc0200f24 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0200f8c:	03000513          	li	a0,48
ffffffffc0200f90:	85a6                	mv	a1,s1
ffffffffc0200f92:	e03e                	sd	a5,0(sp)
ffffffffc0200f94:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0200f96:	85a6                	mv	a1,s1
ffffffffc0200f98:	07800513          	li	a0,120
ffffffffc0200f9c:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0200f9e:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0200fa0:	6782                	ld	a5,0(sp)
ffffffffc0200fa2:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0200fa4:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0200fa8:	bfb5                	j	ffffffffc0200f24 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0200faa:	000a3403          	ld	s0,0(s4)
ffffffffc0200fae:	008a0713          	addi	a4,s4,8
ffffffffc0200fb2:	e03a                	sd	a4,0(sp)
ffffffffc0200fb4:	14040263          	beqz	s0,ffffffffc02010f8 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0200fb8:	0fb05763          	blez	s11,ffffffffc02010a6 <vprintfmt+0x2d8>
ffffffffc0200fbc:	02d00693          	li	a3,45
ffffffffc0200fc0:	0cd79163          	bne	a5,a3,ffffffffc0201082 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0200fc4:	00044783          	lbu	a5,0(s0)
ffffffffc0200fc8:	0007851b          	sext.w	a0,a5
ffffffffc0200fcc:	cf85                	beqz	a5,ffffffffc0201004 <vprintfmt+0x236>
ffffffffc0200fce:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0200fd2:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0200fd6:	000c4563          	bltz	s8,ffffffffc0200fe0 <vprintfmt+0x212>
ffffffffc0200fda:	3c7d                	addiw	s8,s8,-1
ffffffffc0200fdc:	036c0263          	beq	s8,s6,ffffffffc0201000 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0200fe0:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0200fe2:	0e0c8e63          	beqz	s9,ffffffffc02010de <vprintfmt+0x310>
ffffffffc0200fe6:	3781                	addiw	a5,a5,-32
ffffffffc0200fe8:	0ef47b63          	bgeu	s0,a5,ffffffffc02010de <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0200fec:	03f00513          	li	a0,63
ffffffffc0200ff0:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0200ff2:	000a4783          	lbu	a5,0(s4)
ffffffffc0200ff6:	3dfd                	addiw	s11,s11,-1
ffffffffc0200ff8:	0a05                	addi	s4,s4,1
ffffffffc0200ffa:	0007851b          	sext.w	a0,a5
ffffffffc0200ffe:	ffe1                	bnez	a5,ffffffffc0200fd6 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0201000:	01b05963          	blez	s11,ffffffffc0201012 <vprintfmt+0x244>
ffffffffc0201004:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201006:	85a6                	mv	a1,s1
ffffffffc0201008:	02000513          	li	a0,32
ffffffffc020100c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020100e:	fe0d9be3          	bnez	s11,ffffffffc0201004 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201012:	6a02                	ld	s4,0(sp)
ffffffffc0201014:	bbd5                	j	ffffffffc0200e08 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201016:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201018:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc020101c:	01174463          	blt	a4,a7,ffffffffc0201024 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0201020:	08088d63          	beqz	a7,ffffffffc02010ba <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0201024:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0201028:	0a044d63          	bltz	s0,ffffffffc02010e2 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc020102c:	8622                	mv	a2,s0
ffffffffc020102e:	8a66                	mv	s4,s9
ffffffffc0201030:	46a9                	li	a3,10
ffffffffc0201032:	bdcd                	j	ffffffffc0200f24 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0201034:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201038:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc020103a:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc020103c:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201040:	8fb5                	xor	a5,a5,a3
ffffffffc0201042:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201046:	02d74163          	blt	a4,a3,ffffffffc0201068 <vprintfmt+0x29a>
ffffffffc020104a:	00369793          	slli	a5,a3,0x3
ffffffffc020104e:	97de                	add	a5,a5,s7
ffffffffc0201050:	639c                	ld	a5,0(a5)
ffffffffc0201052:	cb99                	beqz	a5,ffffffffc0201068 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201054:	86be                	mv	a3,a5
ffffffffc0201056:	00001617          	auipc	a2,0x1
ffffffffc020105a:	b9a60613          	addi	a2,a2,-1126 # ffffffffc0201bf0 <slub_pmm_manager+0x68>
ffffffffc020105e:	85a6                	mv	a1,s1
ffffffffc0201060:	854a                	mv	a0,s2
ffffffffc0201062:	0ce000ef          	jal	ra,ffffffffc0201130 <printfmt>
ffffffffc0201066:	b34d                	j	ffffffffc0200e08 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201068:	00001617          	auipc	a2,0x1
ffffffffc020106c:	b7860613          	addi	a2,a2,-1160 # ffffffffc0201be0 <slub_pmm_manager+0x58>
ffffffffc0201070:	85a6                	mv	a1,s1
ffffffffc0201072:	854a                	mv	a0,s2
ffffffffc0201074:	0bc000ef          	jal	ra,ffffffffc0201130 <printfmt>
ffffffffc0201078:	bb41                	j	ffffffffc0200e08 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020107a:	00001417          	auipc	s0,0x1
ffffffffc020107e:	b5e40413          	addi	s0,s0,-1186 # ffffffffc0201bd8 <slub_pmm_manager+0x50>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201082:	85e2                	mv	a1,s8
ffffffffc0201084:	8522                	mv	a0,s0
ffffffffc0201086:	e43e                	sd	a5,8(sp)
ffffffffc0201088:	c79ff0ef          	jal	ra,ffffffffc0200d00 <strnlen>
ffffffffc020108c:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201090:	01b05b63          	blez	s11,ffffffffc02010a6 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0201094:	67a2                	ld	a5,8(sp)
ffffffffc0201096:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020109a:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc020109c:	85a6                	mv	a1,s1
ffffffffc020109e:	8552                	mv	a0,s4
ffffffffc02010a0:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02010a2:	fe0d9ce3          	bnez	s11,ffffffffc020109a <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02010a6:	00044783          	lbu	a5,0(s0)
ffffffffc02010aa:	00140a13          	addi	s4,s0,1
ffffffffc02010ae:	0007851b          	sext.w	a0,a5
ffffffffc02010b2:	d3a5                	beqz	a5,ffffffffc0201012 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02010b4:	05e00413          	li	s0,94
ffffffffc02010b8:	bf39                	j	ffffffffc0200fd6 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02010ba:	000a2403          	lw	s0,0(s4)
ffffffffc02010be:	b7ad                	j	ffffffffc0201028 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02010c0:	000a6603          	lwu	a2,0(s4)
ffffffffc02010c4:	46a1                	li	a3,8
ffffffffc02010c6:	8a2e                	mv	s4,a1
ffffffffc02010c8:	bdb1                	j	ffffffffc0200f24 <vprintfmt+0x156>
ffffffffc02010ca:	000a6603          	lwu	a2,0(s4)
ffffffffc02010ce:	46a9                	li	a3,10
ffffffffc02010d0:	8a2e                	mv	s4,a1
ffffffffc02010d2:	bd89                	j	ffffffffc0200f24 <vprintfmt+0x156>
ffffffffc02010d4:	000a6603          	lwu	a2,0(s4)
ffffffffc02010d8:	46c1                	li	a3,16
ffffffffc02010da:	8a2e                	mv	s4,a1
ffffffffc02010dc:	b5a1                	j	ffffffffc0200f24 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02010de:	9902                	jalr	s2
ffffffffc02010e0:	bf09                	j	ffffffffc0200ff2 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc02010e2:	85a6                	mv	a1,s1
ffffffffc02010e4:	02d00513          	li	a0,45
ffffffffc02010e8:	e03e                	sd	a5,0(sp)
ffffffffc02010ea:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02010ec:	6782                	ld	a5,0(sp)
ffffffffc02010ee:	8a66                	mv	s4,s9
ffffffffc02010f0:	40800633          	neg	a2,s0
ffffffffc02010f4:	46a9                	li	a3,10
ffffffffc02010f6:	b53d                	j	ffffffffc0200f24 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02010f8:	03b05163          	blez	s11,ffffffffc020111a <vprintfmt+0x34c>
ffffffffc02010fc:	02d00693          	li	a3,45
ffffffffc0201100:	f6d79de3          	bne	a5,a3,ffffffffc020107a <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0201104:	00001417          	auipc	s0,0x1
ffffffffc0201108:	ad440413          	addi	s0,s0,-1324 # ffffffffc0201bd8 <slub_pmm_manager+0x50>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020110c:	02800793          	li	a5,40
ffffffffc0201110:	02800513          	li	a0,40
ffffffffc0201114:	00140a13          	addi	s4,s0,1
ffffffffc0201118:	bd6d                	j	ffffffffc0200fd2 <vprintfmt+0x204>
ffffffffc020111a:	00001a17          	auipc	s4,0x1
ffffffffc020111e:	abfa0a13          	addi	s4,s4,-1345 # ffffffffc0201bd9 <slub_pmm_manager+0x51>
ffffffffc0201122:	02800513          	li	a0,40
ffffffffc0201126:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020112a:	05e00413          	li	s0,94
ffffffffc020112e:	b565                	j	ffffffffc0200fd6 <vprintfmt+0x208>

ffffffffc0201130 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201130:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201132:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201136:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201138:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020113a:	ec06                	sd	ra,24(sp)
ffffffffc020113c:	f83a                	sd	a4,48(sp)
ffffffffc020113e:	fc3e                	sd	a5,56(sp)
ffffffffc0201140:	e0c2                	sd	a6,64(sp)
ffffffffc0201142:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201144:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201146:	c89ff0ef          	jal	ra,ffffffffc0200dce <vprintfmt>
}
ffffffffc020114a:	60e2                	ld	ra,24(sp)
ffffffffc020114c:	6161                	addi	sp,sp,80
ffffffffc020114e:	8082                	ret

ffffffffc0201150 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201150:	715d                	addi	sp,sp,-80
ffffffffc0201152:	e486                	sd	ra,72(sp)
ffffffffc0201154:	e0a6                	sd	s1,64(sp)
ffffffffc0201156:	fc4a                	sd	s2,56(sp)
ffffffffc0201158:	f84e                	sd	s3,48(sp)
ffffffffc020115a:	f452                	sd	s4,40(sp)
ffffffffc020115c:	f056                	sd	s5,32(sp)
ffffffffc020115e:	ec5a                	sd	s6,24(sp)
ffffffffc0201160:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0201162:	c901                	beqz	a0,ffffffffc0201172 <readline+0x22>
ffffffffc0201164:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0201166:	00001517          	auipc	a0,0x1
ffffffffc020116a:	a8a50513          	addi	a0,a0,-1398 # ffffffffc0201bf0 <slub_pmm_manager+0x68>
ffffffffc020116e:	f45fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc0201172:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201174:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201176:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201178:	4aa9                	li	s5,10
ffffffffc020117a:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc020117c:	00005b97          	auipc	s7,0x5
ffffffffc0201180:	334b8b93          	addi	s7,s7,820 # ffffffffc02064b0 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201184:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201188:	fa3fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc020118c:	00054a63          	bltz	a0,ffffffffc02011a0 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201190:	00a95a63          	bge	s2,a0,ffffffffc02011a4 <readline+0x54>
ffffffffc0201194:	029a5263          	bge	s4,s1,ffffffffc02011b8 <readline+0x68>
        c = getchar();
ffffffffc0201198:	f93fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc020119c:	fe055ae3          	bgez	a0,ffffffffc0201190 <readline+0x40>
            return NULL;
ffffffffc02011a0:	4501                	li	a0,0
ffffffffc02011a2:	a091                	j	ffffffffc02011e6 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02011a4:	03351463          	bne	a0,s3,ffffffffc02011cc <readline+0x7c>
ffffffffc02011a8:	e8a9                	bnez	s1,ffffffffc02011fa <readline+0xaa>
        c = getchar();
ffffffffc02011aa:	f81fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02011ae:	fe0549e3          	bltz	a0,ffffffffc02011a0 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02011b2:	fea959e3          	bge	s2,a0,ffffffffc02011a4 <readline+0x54>
ffffffffc02011b6:	4481                	li	s1,0
            cputchar(c);
ffffffffc02011b8:	e42a                	sd	a0,8(sp)
ffffffffc02011ba:	f2ffe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc02011be:	6522                	ld	a0,8(sp)
ffffffffc02011c0:	009b87b3          	add	a5,s7,s1
ffffffffc02011c4:	2485                	addiw	s1,s1,1
ffffffffc02011c6:	00a78023          	sb	a0,0(a5)
ffffffffc02011ca:	bf7d                	j	ffffffffc0201188 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02011cc:	01550463          	beq	a0,s5,ffffffffc02011d4 <readline+0x84>
ffffffffc02011d0:	fb651ce3          	bne	a0,s6,ffffffffc0201188 <readline+0x38>
            cputchar(c);
ffffffffc02011d4:	f15fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc02011d8:	00005517          	auipc	a0,0x5
ffffffffc02011dc:	2d850513          	addi	a0,a0,728 # ffffffffc02064b0 <buf>
ffffffffc02011e0:	94aa                	add	s1,s1,a0
ffffffffc02011e2:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02011e6:	60a6                	ld	ra,72(sp)
ffffffffc02011e8:	6486                	ld	s1,64(sp)
ffffffffc02011ea:	7962                	ld	s2,56(sp)
ffffffffc02011ec:	79c2                	ld	s3,48(sp)
ffffffffc02011ee:	7a22                	ld	s4,40(sp)
ffffffffc02011f0:	7a82                	ld	s5,32(sp)
ffffffffc02011f2:	6b62                	ld	s6,24(sp)
ffffffffc02011f4:	6bc2                	ld	s7,16(sp)
ffffffffc02011f6:	6161                	addi	sp,sp,80
ffffffffc02011f8:	8082                	ret
            cputchar(c);
ffffffffc02011fa:	4521                	li	a0,8
ffffffffc02011fc:	eedfe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc0201200:	34fd                	addiw	s1,s1,-1
ffffffffc0201202:	b759                	j	ffffffffc0201188 <readline+0x38>

ffffffffc0201204 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0201204:	4781                	li	a5,0
ffffffffc0201206:	00004717          	auipc	a4,0x4
ffffffffc020120a:	e0273703          	ld	a4,-510(a4) # ffffffffc0205008 <SBI_CONSOLE_PUTCHAR>
ffffffffc020120e:	88ba                	mv	a7,a4
ffffffffc0201210:	852a                	mv	a0,a0
ffffffffc0201212:	85be                	mv	a1,a5
ffffffffc0201214:	863e                	mv	a2,a5
ffffffffc0201216:	00000073          	ecall
ffffffffc020121a:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc020121c:	8082                	ret

ffffffffc020121e <sbi_set_timer>:
    __asm__ volatile (
ffffffffc020121e:	4781                	li	a5,0
ffffffffc0201220:	00005717          	auipc	a4,0x5
ffffffffc0201224:	6d873703          	ld	a4,1752(a4) # ffffffffc02068f8 <SBI_SET_TIMER>
ffffffffc0201228:	88ba                	mv	a7,a4
ffffffffc020122a:	852a                	mv	a0,a0
ffffffffc020122c:	85be                	mv	a1,a5
ffffffffc020122e:	863e                	mv	a2,a5
ffffffffc0201230:	00000073          	ecall
ffffffffc0201234:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc0201236:	8082                	ret

ffffffffc0201238 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc0201238:	4501                	li	a0,0
ffffffffc020123a:	00004797          	auipc	a5,0x4
ffffffffc020123e:	dc67b783          	ld	a5,-570(a5) # ffffffffc0205000 <SBI_CONSOLE_GETCHAR>
ffffffffc0201242:	88be                	mv	a7,a5
ffffffffc0201244:	852a                	mv	a0,a0
ffffffffc0201246:	85aa                	mv	a1,a0
ffffffffc0201248:	862a                	mv	a2,a0
ffffffffc020124a:	00000073          	ecall
ffffffffc020124e:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201250:	2501                	sext.w	a0,a0
ffffffffc0201252:	8082                	ret
