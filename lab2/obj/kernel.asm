
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
ffffffffc020003a:	0000f617          	auipc	a2,0xf
ffffffffc020003e:	4c660613          	addi	a2,a2,1222 # ffffffffc020f500 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	49b000ef          	jal	ra,ffffffffc0200ce4 <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00001517          	auipc	a0,0x1
ffffffffc0200056:	19650513          	addi	a0,a0,406 # ffffffffc02011e8 <etext>
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
ffffffffc02000a6:	4bd000ef          	jal	ra,ffffffffc0200d62 <vprintfmt>
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
ffffffffc02000dc:	487000ef          	jal	ra,ffffffffc0200d62 <vprintfmt>
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
ffffffffc020013a:	0000f317          	auipc	t1,0xf
ffffffffc020013e:	37630313          	addi	t1,t1,886 # ffffffffc020f4b0 <is_panic>
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
ffffffffc020016c:	0a050513          	addi	a0,a0,160 # ffffffffc0201208 <etext+0x20>
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
ffffffffc0200182:	17250513          	addi	a0,a0,370 # ffffffffc02012f0 <etext+0x108>
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
ffffffffc020019c:	09050513          	addi	a0,a0,144 # ffffffffc0201228 <etext+0x40>
void print_kerninfo(void) {
ffffffffc02001a0:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001a2:	f11ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc02001a6:	00000597          	auipc	a1,0x0
ffffffffc02001aa:	e8c58593          	addi	a1,a1,-372 # ffffffffc0200032 <kern_init>
ffffffffc02001ae:	00001517          	auipc	a0,0x1
ffffffffc02001b2:	09a50513          	addi	a0,a0,154 # ffffffffc0201248 <etext+0x60>
ffffffffc02001b6:	efdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc02001ba:	00001597          	auipc	a1,0x1
ffffffffc02001be:	02e58593          	addi	a1,a1,46 # ffffffffc02011e8 <etext>
ffffffffc02001c2:	00001517          	auipc	a0,0x1
ffffffffc02001c6:	0a650513          	addi	a0,a0,166 # ffffffffc0201268 <etext+0x80>
ffffffffc02001ca:	ee9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc02001ce:	00005597          	auipc	a1,0x5
ffffffffc02001d2:	e4258593          	addi	a1,a1,-446 # ffffffffc0205010 <page_pool>
ffffffffc02001d6:	00001517          	auipc	a0,0x1
ffffffffc02001da:	0b250513          	addi	a0,a0,178 # ffffffffc0201288 <etext+0xa0>
ffffffffc02001de:	ed5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc02001e2:	0000f597          	auipc	a1,0xf
ffffffffc02001e6:	31e58593          	addi	a1,a1,798 # ffffffffc020f500 <end>
ffffffffc02001ea:	00001517          	auipc	a0,0x1
ffffffffc02001ee:	0be50513          	addi	a0,a0,190 # ffffffffc02012a8 <etext+0xc0>
ffffffffc02001f2:	ec1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001f6:	0000f597          	auipc	a1,0xf
ffffffffc02001fa:	70958593          	addi	a1,a1,1801 # ffffffffc020f8ff <end+0x3ff>
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
ffffffffc020021c:	0b050513          	addi	a0,a0,176 # ffffffffc02012c8 <etext+0xe0>
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
ffffffffc020022a:	0d260613          	addi	a2,a2,210 # ffffffffc02012f8 <etext+0x110>
ffffffffc020022e:	04e00593          	li	a1,78
ffffffffc0200232:	00001517          	auipc	a0,0x1
ffffffffc0200236:	0de50513          	addi	a0,a0,222 # ffffffffc0201310 <etext+0x128>
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
ffffffffc0200246:	0e660613          	addi	a2,a2,230 # ffffffffc0201328 <etext+0x140>
ffffffffc020024a:	00001597          	auipc	a1,0x1
ffffffffc020024e:	0fe58593          	addi	a1,a1,254 # ffffffffc0201348 <etext+0x160>
ffffffffc0200252:	00001517          	auipc	a0,0x1
ffffffffc0200256:	0fe50513          	addi	a0,a0,254 # ffffffffc0201350 <etext+0x168>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020025a:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020025c:	e57ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200260:	00001617          	auipc	a2,0x1
ffffffffc0200264:	10060613          	addi	a2,a2,256 # ffffffffc0201360 <etext+0x178>
ffffffffc0200268:	00001597          	auipc	a1,0x1
ffffffffc020026c:	12058593          	addi	a1,a1,288 # ffffffffc0201388 <etext+0x1a0>
ffffffffc0200270:	00001517          	auipc	a0,0x1
ffffffffc0200274:	0e050513          	addi	a0,a0,224 # ffffffffc0201350 <etext+0x168>
ffffffffc0200278:	e3bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020027c:	00001617          	auipc	a2,0x1
ffffffffc0200280:	11c60613          	addi	a2,a2,284 # ffffffffc0201398 <etext+0x1b0>
ffffffffc0200284:	00001597          	auipc	a1,0x1
ffffffffc0200288:	13458593          	addi	a1,a1,308 # ffffffffc02013b8 <etext+0x1d0>
ffffffffc020028c:	00001517          	auipc	a0,0x1
ffffffffc0200290:	0c450513          	addi	a0,a0,196 # ffffffffc0201350 <etext+0x168>
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
ffffffffc02002ca:	10250513          	addi	a0,a0,258 # ffffffffc02013c8 <etext+0x1e0>
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
ffffffffc02002ec:	10850513          	addi	a0,a0,264 # ffffffffc02013f0 <etext+0x208>
ffffffffc02002f0:	dc3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc02002f4:	000b8563          	beqz	s7,ffffffffc02002fe <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002f8:	855e                	mv	a0,s7
ffffffffc02002fa:	348000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002fe:	00001c17          	auipc	s8,0x1
ffffffffc0200302:	162c0c13          	addi	s8,s8,354 # ffffffffc0201460 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200306:	00001917          	auipc	s2,0x1
ffffffffc020030a:	11290913          	addi	s2,s2,274 # ffffffffc0201418 <etext+0x230>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020030e:	00001497          	auipc	s1,0x1
ffffffffc0200312:	11248493          	addi	s1,s1,274 # ffffffffc0201420 <etext+0x238>
        if (argc == MAXARGS - 1) {
ffffffffc0200316:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200318:	00001b17          	auipc	s6,0x1
ffffffffc020031c:	110b0b13          	addi	s6,s6,272 # ffffffffc0201428 <etext+0x240>
        argv[argc ++] = buf;
ffffffffc0200320:	00001a17          	auipc	s4,0x1
ffffffffc0200324:	028a0a13          	addi	s4,s4,40 # ffffffffc0201348 <etext+0x160>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200328:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020032a:	854a                	mv	a0,s2
ffffffffc020032c:	5b9000ef          	jal	ra,ffffffffc02010e4 <readline>
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
ffffffffc0200346:	11ed0d13          	addi	s10,s10,286 # ffffffffc0201460 <commands>
        argv[argc ++] = buf;
ffffffffc020034a:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020034c:	4401                	li	s0,0
ffffffffc020034e:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200350:	161000ef          	jal	ra,ffffffffc0200cb0 <strcmp>
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
ffffffffc0200364:	14d000ef          	jal	ra,ffffffffc0200cb0 <strcmp>
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
ffffffffc02003a2:	12d000ef          	jal	ra,ffffffffc0200cce <strchr>
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
ffffffffc02003e0:	0ef000ef          	jal	ra,ffffffffc0200cce <strchr>
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
ffffffffc02003fe:	04e50513          	addi	a0,a0,78 # ffffffffc0201448 <etext+0x260>
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
ffffffffc0200420:	593000ef          	jal	ra,ffffffffc02011b2 <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	0000f797          	auipc	a5,0xf
ffffffffc020042a:	0807b923          	sd	zero,146(a5) # ffffffffc020f4b8 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00001517          	auipc	a0,0x1
ffffffffc0200432:	07a50513          	addi	a0,a0,122 # ffffffffc02014a8 <commands+0x48>
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
ffffffffc0200446:	56d0006f          	j	ffffffffc02011b2 <sbi_set_timer>

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
ffffffffc0200450:	5490006f          	j	ffffffffc0201198 <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	5790006f          	j	ffffffffc02011cc <sbi_console_getchar>

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
ffffffffc0200482:	04a50513          	addi	a0,a0,74 # ffffffffc02014c8 <commands+0x68>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00001517          	auipc	a0,0x1
ffffffffc0200492:	05250513          	addi	a0,a0,82 # ffffffffc02014e0 <commands+0x80>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00001517          	auipc	a0,0x1
ffffffffc02004a0:	05c50513          	addi	a0,a0,92 # ffffffffc02014f8 <commands+0x98>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00001517          	auipc	a0,0x1
ffffffffc02004ae:	06650513          	addi	a0,a0,102 # ffffffffc0201510 <commands+0xb0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00001517          	auipc	a0,0x1
ffffffffc02004bc:	07050513          	addi	a0,a0,112 # ffffffffc0201528 <commands+0xc8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00001517          	auipc	a0,0x1
ffffffffc02004ca:	07a50513          	addi	a0,a0,122 # ffffffffc0201540 <commands+0xe0>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00001517          	auipc	a0,0x1
ffffffffc02004d8:	08450513          	addi	a0,a0,132 # ffffffffc0201558 <commands+0xf8>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00001517          	auipc	a0,0x1
ffffffffc02004e6:	08e50513          	addi	a0,a0,142 # ffffffffc0201570 <commands+0x110>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00001517          	auipc	a0,0x1
ffffffffc02004f4:	09850513          	addi	a0,a0,152 # ffffffffc0201588 <commands+0x128>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00001517          	auipc	a0,0x1
ffffffffc0200502:	0a250513          	addi	a0,a0,162 # ffffffffc02015a0 <commands+0x140>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00001517          	auipc	a0,0x1
ffffffffc0200510:	0ac50513          	addi	a0,a0,172 # ffffffffc02015b8 <commands+0x158>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00001517          	auipc	a0,0x1
ffffffffc020051e:	0b650513          	addi	a0,a0,182 # ffffffffc02015d0 <commands+0x170>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00001517          	auipc	a0,0x1
ffffffffc020052c:	0c050513          	addi	a0,a0,192 # ffffffffc02015e8 <commands+0x188>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00001517          	auipc	a0,0x1
ffffffffc020053a:	0ca50513          	addi	a0,a0,202 # ffffffffc0201600 <commands+0x1a0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00001517          	auipc	a0,0x1
ffffffffc0200548:	0d450513          	addi	a0,a0,212 # ffffffffc0201618 <commands+0x1b8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00001517          	auipc	a0,0x1
ffffffffc0200556:	0de50513          	addi	a0,a0,222 # ffffffffc0201630 <commands+0x1d0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00001517          	auipc	a0,0x1
ffffffffc0200564:	0e850513          	addi	a0,a0,232 # ffffffffc0201648 <commands+0x1e8>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00001517          	auipc	a0,0x1
ffffffffc0200572:	0f250513          	addi	a0,a0,242 # ffffffffc0201660 <commands+0x200>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00001517          	auipc	a0,0x1
ffffffffc0200580:	0fc50513          	addi	a0,a0,252 # ffffffffc0201678 <commands+0x218>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00001517          	auipc	a0,0x1
ffffffffc020058e:	10650513          	addi	a0,a0,262 # ffffffffc0201690 <commands+0x230>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00001517          	auipc	a0,0x1
ffffffffc020059c:	11050513          	addi	a0,a0,272 # ffffffffc02016a8 <commands+0x248>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00001517          	auipc	a0,0x1
ffffffffc02005aa:	11a50513          	addi	a0,a0,282 # ffffffffc02016c0 <commands+0x260>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00001517          	auipc	a0,0x1
ffffffffc02005b8:	12450513          	addi	a0,a0,292 # ffffffffc02016d8 <commands+0x278>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00001517          	auipc	a0,0x1
ffffffffc02005c6:	12e50513          	addi	a0,a0,302 # ffffffffc02016f0 <commands+0x290>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00001517          	auipc	a0,0x1
ffffffffc02005d4:	13850513          	addi	a0,a0,312 # ffffffffc0201708 <commands+0x2a8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00001517          	auipc	a0,0x1
ffffffffc02005e2:	14250513          	addi	a0,a0,322 # ffffffffc0201720 <commands+0x2c0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00001517          	auipc	a0,0x1
ffffffffc02005f0:	14c50513          	addi	a0,a0,332 # ffffffffc0201738 <commands+0x2d8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00001517          	auipc	a0,0x1
ffffffffc02005fe:	15650513          	addi	a0,a0,342 # ffffffffc0201750 <commands+0x2f0>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00001517          	auipc	a0,0x1
ffffffffc020060c:	16050513          	addi	a0,a0,352 # ffffffffc0201768 <commands+0x308>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00001517          	auipc	a0,0x1
ffffffffc020061a:	16a50513          	addi	a0,a0,362 # ffffffffc0201780 <commands+0x320>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00001517          	auipc	a0,0x1
ffffffffc0200628:	17450513          	addi	a0,a0,372 # ffffffffc0201798 <commands+0x338>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00001517          	auipc	a0,0x1
ffffffffc020063a:	17a50513          	addi	a0,a0,378 # ffffffffc02017b0 <commands+0x350>
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
ffffffffc020064e:	17e50513          	addi	a0,a0,382 # ffffffffc02017c8 <commands+0x368>
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
ffffffffc0200666:	17e50513          	addi	a0,a0,382 # ffffffffc02017e0 <commands+0x380>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00001517          	auipc	a0,0x1
ffffffffc0200676:	18650513          	addi	a0,a0,390 # ffffffffc02017f8 <commands+0x398>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00001517          	auipc	a0,0x1
ffffffffc0200686:	18e50513          	addi	a0,a0,398 # ffffffffc0201810 <commands+0x3b0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00001517          	auipc	a0,0x1
ffffffffc020069a:	19250513          	addi	a0,a0,402 # ffffffffc0201828 <commands+0x3c8>
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
ffffffffc02006b4:	25870713          	addi	a4,a4,600 # ffffffffc0201908 <commands+0x4a8>
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
ffffffffc02006c6:	1de50513          	addi	a0,a0,478 # ffffffffc02018a0 <commands+0x440>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00001517          	auipc	a0,0x1
ffffffffc02006d0:	1b450513          	addi	a0,a0,436 # ffffffffc0201880 <commands+0x420>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00001517          	auipc	a0,0x1
ffffffffc02006da:	16a50513          	addi	a0,a0,362 # ffffffffc0201840 <commands+0x3e0>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00001517          	auipc	a0,0x1
ffffffffc02006e4:	1e050513          	addi	a0,a0,480 # ffffffffc02018c0 <commands+0x460>
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
ffffffffc02006f2:	0000f697          	auipc	a3,0xf
ffffffffc02006f6:	dc668693          	addi	a3,a3,-570 # ffffffffc020f4b8 <ticks>
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
ffffffffc0200714:	1d850513          	addi	a0,a0,472 # ffffffffc02018e8 <commands+0x488>
ffffffffc0200718:	ba69                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020071a:	00001517          	auipc	a0,0x1
ffffffffc020071e:	14650513          	addi	a0,a0,326 # ffffffffc0201860 <commands+0x400>
ffffffffc0200722:	ba41                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200724:	bf39                	j	ffffffffc0200642 <print_trapframe>
}
ffffffffc0200726:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200728:	06400593          	li	a1,100
ffffffffc020072c:	00001517          	auipc	a0,0x1
ffffffffc0200730:	1ac50513          	addi	a0,a0,428 # ffffffffc02018d8 <commands+0x478>
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
ffffffffc0200806:	2fe78793          	addi	a5,a5,766 # ffffffffc0201b00 <slub_pmm_manager>
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
ffffffffc0200814:	12850513          	addi	a0,a0,296 # ffffffffc0201938 <commands+0x4d8>
    pmm_manager = &slub_pmm_manager;
ffffffffc0200818:	0000f497          	auipc	s1,0xf
ffffffffc020081c:	cb848493          	addi	s1,s1,-840 # ffffffffc020f4d0 <pmm_manager>
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
ffffffffc020082c:	0000f417          	auipc	s0,0xf
ffffffffc0200830:	cbc40413          	addi	s0,s0,-836 # ffffffffc020f4e8 <va_pa_offset>
    pmm_manager->init();
ffffffffc0200834:	679c                	ld	a5,8(a5)
ffffffffc0200836:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200838:	57f5                	li	a5,-3
ffffffffc020083a:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc020083c:	00001517          	auipc	a0,0x1
ffffffffc0200840:	11450513          	addi	a0,a0,276 # ffffffffc0201950 <commands+0x4f0>
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
ffffffffc020085e:	10e50513          	addi	a0,a0,270 # ffffffffc0201968 <commands+0x508>
ffffffffc0200862:	851ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200866:	777d                	lui	a4,0xfffff
ffffffffc0200868:	00010797          	auipc	a5,0x10
ffffffffc020086c:	c9778793          	addi	a5,a5,-873 # ffffffffc02104ff <end+0xfff>
ffffffffc0200870:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0200872:	0000f517          	auipc	a0,0xf
ffffffffc0200876:	c4e50513          	addi	a0,a0,-946 # ffffffffc020f4c0 <npage>
ffffffffc020087a:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020087e:	0000f597          	auipc	a1,0xf
ffffffffc0200882:	c4a58593          	addi	a1,a1,-950 # ffffffffc020f4c8 <pages>
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
ffffffffc02008e0:	12450513          	addi	a0,a0,292 # ffffffffc0201a00 <commands+0x5a0>
ffffffffc02008e4:	fceff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02008e8:	00003597          	auipc	a1,0x3
ffffffffc02008ec:	71858593          	addi	a1,a1,1816 # ffffffffc0204000 <boot_page_table_sv39>
ffffffffc02008f0:	0000f797          	auipc	a5,0xf
ffffffffc02008f4:	beb7b823          	sd	a1,-1040(a5) # ffffffffc020f4e0 <satp_virtual>
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
ffffffffc020090c:	0000f797          	auipc	a5,0xf
ffffffffc0200910:	bcc7b623          	sd	a2,-1076(a5) # ffffffffc020f4d8 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200914:	00001517          	auipc	a0,0x1
ffffffffc0200918:	10c50513          	addi	a0,a0,268 # ffffffffc0201a20 <commands+0x5c0>
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
ffffffffc0200950:	08460613          	addi	a2,a2,132 # ffffffffc02019d0 <commands+0x570>
ffffffffc0200954:	06900593          	li	a1,105
ffffffffc0200958:	00001517          	auipc	a0,0x1
ffffffffc020095c:	09850513          	addi	a0,a0,152 # ffffffffc02019f0 <commands+0x590>
ffffffffc0200960:	fdaff0ef          	jal	ra,ffffffffc020013a <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200964:	00001617          	auipc	a2,0x1
ffffffffc0200968:	03460613          	addi	a2,a2,52 # ffffffffc0201998 <commands+0x538>
ffffffffc020096c:	07000593          	li	a1,112
ffffffffc0200970:	00001517          	auipc	a0,0x1
ffffffffc0200974:	05050513          	addi	a0,a0,80 # ffffffffc02019c0 <commands+0x560>
ffffffffc0200978:	fc2ff0ef          	jal	ra,ffffffffc020013a <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc020097c:	86ae                	mv	a3,a1
ffffffffc020097e:	00001617          	auipc	a2,0x1
ffffffffc0200982:	01a60613          	addi	a2,a2,26 # ffffffffc0201998 <commands+0x538>
ffffffffc0200986:	08b00593          	li	a1,139
ffffffffc020098a:	00001517          	auipc	a0,0x1
ffffffffc020098e:	03650513          	addi	a0,a0,54 # ffffffffc02019c0 <commands+0x560>
ffffffffc0200992:	fa8ff0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0200996 <slub_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200996:	0000e797          	auipc	a5,0xe
ffffffffc020099a:	67a78793          	addi	a5,a5,1658 # ffffffffc020f010 <slab_caches>
ffffffffc020099e:	0000e517          	auipc	a0,0xe
ffffffffc02009a2:	68a50513          	addi	a0,a0,1674 # ffffffffc020f028 <slab_caches+0x18>
ffffffffc02009a6:	0000e597          	auipc	a1,0xe
ffffffffc02009aa:	6aa58593          	addi	a1,a1,1706 # ffffffffc020f050 <slab_caches+0x40>
ffffffffc02009ae:	0000e617          	auipc	a2,0xe
ffffffffc02009b2:	6ca60613          	addi	a2,a2,1738 # ffffffffc020f078 <slab_caches+0x68>
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
ffffffffc02009ca:	0000e697          	auipc	a3,0xe
ffffffffc02009ce:	6d668693          	addi	a3,a3,1750 # ffffffffc020f0a0 <slab_caches+0x90>
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
ffffffffc0200a06:	0000f797          	auipc	a5,0xf
ffffffffc0200a0a:	ae07b523          	sd	zero,-1302(a5) # ffffffffc020f4f0 <allocated_pages>
}
ffffffffc0200a0e:	8082                	ret

ffffffffc0200a10 <slub_init_memmap>:

void slub_init_memmap(struct Page *base, size_t n) {
    for (size_t i = 0; i < n; i++) {
ffffffffc0200a10:	c1a9                	beqz	a1,ffffffffc0200a52 <slub_init_memmap+0x42>
ffffffffc0200a12:	00259893          	slli	a7,a1,0x2
ffffffffc0200a16:	98ae                	add	a7,a7,a1
ffffffffc0200a18:	088e                	slli	a7,a7,0x3
ffffffffc0200a1a:	01850593          	addi	a1,a0,24
ffffffffc0200a1e:	98ae                	add	a7,a7,a1
ffffffffc0200a20:	0000e317          	auipc	t1,0xe
ffffffffc0200a24:	5f030313          	addi	t1,t1,1520 # ffffffffc020f010 <slab_caches>
        struct Page *page = base + i;

        // 尝试将每个页面分配到合适的 slab 缓存
        for (int order = SLAB_MIN_ORDER; order <= SLAB_MAX_ORDER; order++) {
ffffffffc0200a28:	4811                	li	a6,4
ffffffffc0200a2a:	0000e717          	auipc	a4,0xe
ffffffffc0200a2e:	5e670713          	addi	a4,a4,1510 # ffffffffc020f010 <slab_caches>
void slub_init_memmap(struct Page *base, size_t n) {
ffffffffc0200a32:	4781                	li	a5,0
            struct slab_cache *cache = &slab_caches[order - SLAB_MIN_ORDER];
            if (cache->free_count < cache->total_objects) {
ffffffffc0200a34:	6b10                	ld	a2,16(a4)
ffffffffc0200a36:	6714                	ld	a3,8(a4)
            struct slab_cache *cache = &slab_caches[order - SLAB_MIN_ORDER];
ffffffffc0200a38:	0007851b          	sext.w	a0,a5
        for (int order = SLAB_MIN_ORDER; order <= SLAB_MAX_ORDER; order++) {
ffffffffc0200a3c:	2785                	addiw	a5,a5,1
            if (cache->free_count < cache->total_objects) {
ffffffffc0200a3e:	00d66b63          	bltu	a2,a3,ffffffffc0200a54 <slub_init_memmap+0x44>
        for (int order = SLAB_MIN_ORDER; order <= SLAB_MAX_ORDER; order++) {
ffffffffc0200a42:	02870713          	addi	a4,a4,40
ffffffffc0200a46:	ff0797e3          	bne	a5,a6,ffffffffc0200a34 <slub_init_memmap+0x24>
    for (size_t i = 0; i < n; i++) {
ffffffffc0200a4a:	02858593          	addi	a1,a1,40
ffffffffc0200a4e:	fd159ee3          	bne	a1,a7,ffffffffc0200a2a <slub_init_memmap+0x1a>
                cache->free_count++;
                break; // 成功分配后退出循环
            }
        }
    }
}
ffffffffc0200a52:	8082                	ret
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
ffffffffc0200a54:	00251793          	slli	a5,a0,0x2
ffffffffc0200a58:	953e                	add	a0,a0,a5
ffffffffc0200a5a:	050e                	slli	a0,a0,0x3
ffffffffc0200a5c:	00a307b3          	add	a5,t1,a0
ffffffffc0200a60:	7398                	ld	a4,32(a5)
                list_add(&cache->free_list, &page->page_link);  
ffffffffc0200a62:	0561                	addi	a0,a0,24
ffffffffc0200a64:	951a                	add	a0,a0,t1
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200a66:	e30c                	sd	a1,0(a4)
ffffffffc0200a68:	f38c                	sd	a1,32(a5)
    elm->next = next;
ffffffffc0200a6a:	e598                	sd	a4,8(a1)
    elm->prev = prev;
ffffffffc0200a6c:	e188                	sd	a0,0(a1)
                cache->free_count++;
ffffffffc0200a6e:	6b98                	ld	a4,16(a5)
    for (size_t i = 0; i < n; i++) {
ffffffffc0200a70:	02858593          	addi	a1,a1,40
                cache->free_count++;
ffffffffc0200a74:	0705                	addi	a4,a4,1
ffffffffc0200a76:	eb98                	sd	a4,16(a5)
    for (size_t i = 0; i < n; i++) {
ffffffffc0200a78:	fb1599e3          	bne	a1,a7,ffffffffc0200a2a <slub_init_memmap+0x1a>
ffffffffc0200a7c:	bfd9                	j	ffffffffc0200a52 <slub_init_memmap+0x42>

ffffffffc0200a7e <slub_nr_free_pages>:

size_t slub_nr_free_pages(void) {
    size_t total_free_pages = 0;
    for (int order = SLAB_MIN_ORDER; order <= SLAB_MAX_ORDER; order++) {
        struct slab_cache *cache = &slab_caches[order - SLAB_MIN_ORDER];
        total_free_pages += cache->free_count;
ffffffffc0200a7e:	0000e717          	auipc	a4,0xe
ffffffffc0200a82:	59270713          	addi	a4,a4,1426 # ffffffffc020f010 <slab_caches>
ffffffffc0200a86:	6b1c                	ld	a5,16(a4)
ffffffffc0200a88:	7f10                	ld	a2,56(a4)
ffffffffc0200a8a:	7334                	ld	a3,96(a4)
ffffffffc0200a8c:	6748                	ld	a0,136(a4)
ffffffffc0200a8e:	97b2                	add	a5,a5,a2
ffffffffc0200a90:	97b6                	add	a5,a5,a3
    }
    return total_free_pages;
}
ffffffffc0200a92:	953e                	add	a0,a0,a5
ffffffffc0200a94:	8082                	ret

ffffffffc0200a96 <slub_alloc_pages>:
    if (n == 1) {
ffffffffc0200a96:	4785                	li	a5,1
ffffffffc0200a98:	08f51363          	bne	a0,a5,ffffffffc0200b1e <slub_alloc_pages+0x88>
    return list->next == list;
ffffffffc0200a9c:	0000e797          	auipc	a5,0xe
ffffffffc0200aa0:	57478793          	addi	a5,a5,1396 # ffffffffc020f010 <slab_caches>
ffffffffc0200aa4:	7388                	ld	a0,32(a5)
            if (!list_empty(&cache->free_list)) {
ffffffffc0200aa6:	0000e697          	auipc	a3,0xe
ffffffffc0200aaa:	58268693          	addi	a3,a3,1410 # ffffffffc020f028 <slab_caches+0x18>
ffffffffc0200aae:	08d51963          	bne	a0,a3,ffffffffc0200b40 <slub_alloc_pages+0xaa>
ffffffffc0200ab2:	67a8                	ld	a0,72(a5)
ffffffffc0200ab4:	0000e717          	auipc	a4,0xe
ffffffffc0200ab8:	59c70713          	addi	a4,a4,1436 # ffffffffc020f050 <slab_caches+0x40>
ffffffffc0200abc:	06e51363          	bne	a0,a4,ffffffffc0200b22 <slub_alloc_pages+0x8c>
ffffffffc0200ac0:	7ba8                	ld	a0,112(a5)
ffffffffc0200ac2:	0000e717          	auipc	a4,0xe
ffffffffc0200ac6:	5b670713          	addi	a4,a4,1462 # ffffffffc020f078 <slab_caches+0x68>
ffffffffc0200aca:	06e51d63          	bne	a0,a4,ffffffffc0200b44 <slub_alloc_pages+0xae>
ffffffffc0200ace:	6fc8                	ld	a0,152(a5)
ffffffffc0200ad0:	0000e717          	auipc	a4,0xe
ffffffffc0200ad4:	5d070713          	addi	a4,a4,1488 # ffffffffc020f0a0 <slab_caches+0x90>
ffffffffc0200ad8:	06e51863          	bne	a0,a4,ffffffffc0200b48 <slub_alloc_pages+0xb2>
    if (allocated_pages + n > MAX_PAGES) {
ffffffffc0200adc:	0000f597          	auipc	a1,0xf
ffffffffc0200ae0:	a1458593          	addi	a1,a1,-1516 # ffffffffc020f4f0 <allocated_pages>
ffffffffc0200ae4:	6198                	ld	a4,0(a1)
ffffffffc0200ae6:	40000613          	li	a2,1024
ffffffffc0200aea:	00170813          	addi	a6,a4,1
ffffffffc0200aee:	03066863          	bltu	a2,a6,ffffffffc0200b1e <slub_alloc_pages+0x88>
    struct Page* page = &page_pool[allocated_pages];
ffffffffc0200af2:	00271513          	slli	a0,a4,0x2
                cache->free_count++;
ffffffffc0200af6:	6b90                	ld	a2,16(a5)
ffffffffc0200af8:	953a                	add	a0,a0,a4
ffffffffc0200afa:	050e                	slli	a0,a0,0x3
    struct Page* page = &page_pool[allocated_pages];
ffffffffc0200afc:	00004897          	auipc	a7,0x4
ffffffffc0200b00:	51488893          	addi	a7,a7,1300 # ffffffffc0205010 <page_pool>
                list_add(&cache->free_list, &new_page->page_link);
ffffffffc0200b04:	01850713          	addi	a4,a0,24
ffffffffc0200b08:	9746                	add	a4,a4,a7
    struct Page* page = &page_pool[allocated_pages];
ffffffffc0200b0a:	9546                	add	a0,a0,a7
                cache->free_count++;
ffffffffc0200b0c:	0605                	addi	a2,a2,1
    allocated_pages += n;
ffffffffc0200b0e:	0105b023          	sd	a6,0(a1)
    prev->next = next->prev = elm;
ffffffffc0200b12:	ef98                	sd	a4,24(a5)
ffffffffc0200b14:	f398                	sd	a4,32(a5)
    elm->next = next;
ffffffffc0200b16:	f114                	sd	a3,32(a0)
    elm->prev = prev;
ffffffffc0200b18:	ed14                	sd	a3,24(a0)
                cache->free_count++;
ffffffffc0200b1a:	eb90                	sd	a2,16(a5)
                return new_page;  // 返回新分配的页
ffffffffc0200b1c:	8082                	ret
    return NULL;  // 如果找不到合适的 slab 或静态分配失败，返回 NULL
ffffffffc0200b1e:	4501                	li	a0,0
}
ffffffffc0200b20:	8082                	ret
            struct slab_cache *cache = &slab_caches[order - SLAB_MIN_ORDER];
ffffffffc0200b22:	4685                	li	a3,1
    __list_del(listelm->prev, listelm->next);
ffffffffc0200b24:	610c                	ld	a1,0(a0)
ffffffffc0200b26:	6510                	ld	a2,8(a0)
                cache->free_count--;
ffffffffc0200b28:	00269713          	slli	a4,a3,0x2
ffffffffc0200b2c:	9736                	add	a4,a4,a3
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200b2e:	e590                	sd	a2,8(a1)
ffffffffc0200b30:	070e                	slli	a4,a4,0x3
    next->prev = prev;
ffffffffc0200b32:	e20c                	sd	a1,0(a2)
ffffffffc0200b34:	97ba                	add	a5,a5,a4
ffffffffc0200b36:	6b98                	ld	a4,16(a5)
                struct Page *page = le2page(list_next(&cache->free_list), page_link);
ffffffffc0200b38:	1521                	addi	a0,a0,-24
                cache->free_count--;
ffffffffc0200b3a:	177d                	addi	a4,a4,-1
ffffffffc0200b3c:	eb98                	sd	a4,16(a5)
                return page;
ffffffffc0200b3e:	8082                	ret
            struct slab_cache *cache = &slab_caches[order - SLAB_MIN_ORDER];
ffffffffc0200b40:	4681                	li	a3,0
ffffffffc0200b42:	b7cd                	j	ffffffffc0200b24 <slub_alloc_pages+0x8e>
ffffffffc0200b44:	4689                	li	a3,2
ffffffffc0200b46:	bff9                	j	ffffffffc0200b24 <slub_alloc_pages+0x8e>
ffffffffc0200b48:	468d                	li	a3,3
ffffffffc0200b4a:	bfe9                	j	ffffffffc0200b24 <slub_alloc_pages+0x8e>

ffffffffc0200b4c <slub_free_pages>:
    if (n == 1) {
ffffffffc0200b4c:	4785                	li	a5,1
ffffffffc0200b4e:	00f58363          	beq	a1,a5,ffffffffc0200b54 <slub_free_pages+0x8>
}
ffffffffc0200b52:	8082                	ret
    __list_add(elm, listelm, listelm->next);
ffffffffc0200b54:	0000e797          	auipc	a5,0xe
ffffffffc0200b58:	4bc78793          	addi	a5,a5,1212 # ffffffffc020f010 <slab_caches>
ffffffffc0200b5c:	7394                	ld	a3,32(a5)
            cache->free_count++;
ffffffffc0200b5e:	6b98                	ld	a4,16(a5)
            list_add(&cache->free_list, &base->page_link);  
ffffffffc0200b60:	01850613          	addi	a2,a0,24
    prev->next = next->prev = elm;
ffffffffc0200b64:	e290                	sd	a2,0(a3)
ffffffffc0200b66:	f390                	sd	a2,32(a5)
            cache->free_count++;
ffffffffc0200b68:	0705                	addi	a4,a4,1
    elm->next = next;
ffffffffc0200b6a:	f114                	sd	a3,32(a0)
    elm->prev = prev;
ffffffffc0200b6c:	0000e697          	auipc	a3,0xe
ffffffffc0200b70:	4bc68693          	addi	a3,a3,1212 # ffffffffc020f028 <slab_caches+0x18>
ffffffffc0200b74:	ed14                	sd	a3,24(a0)
ffffffffc0200b76:	eb98                	sd	a4,16(a5)
}
ffffffffc0200b78:	8082                	ret

ffffffffc0200b7a <slub_check>:
void slub_check(void) {
ffffffffc0200b7a:	7179                	addi	sp,sp,-48
ffffffffc0200b7c:	f022                	sd	s0,32(sp)
        total_free_pages += cache->free_count;
ffffffffc0200b7e:	0000e417          	auipc	s0,0xe
ffffffffc0200b82:	49240413          	addi	s0,s0,1170 # ffffffffc020f010 <slab_caches>
ffffffffc0200b86:	681c                	ld	a5,16(s0)
ffffffffc0200b88:	7c14                	ld	a3,56(s0)
ffffffffc0200b8a:	7038                	ld	a4,96(s0)
void slub_check(void) {
ffffffffc0200b8c:	e44e                	sd	s3,8(sp)
        total_free_pages += cache->free_count;
ffffffffc0200b8e:	08843983          	ld	s3,136(s0)
ffffffffc0200b92:	97b6                	add	a5,a5,a3
ffffffffc0200b94:	97ba                	add	a5,a5,a4
    size_t all_pages = slub_nr_free_pages();
    struct Page *p0, *p1, *p2;

    // 测试分配和释放
    p0 = slub_alloc_pages(1);
ffffffffc0200b96:	4505                	li	a0,1
void slub_check(void) {
ffffffffc0200b98:	f406                	sd	ra,40(sp)
ffffffffc0200b9a:	ec26                	sd	s1,24(sp)
ffffffffc0200b9c:	e84a                	sd	s2,16(sp)
        total_free_pages += cache->free_count;
ffffffffc0200b9e:	99be                	add	s3,s3,a5
    p0 = slub_alloc_pages(1);
ffffffffc0200ba0:	ef7ff0ef          	jal	ra,ffffffffc0200a96 <slub_alloc_pages>
    assert(p0 != NULL);
ffffffffc0200ba4:	c925                	beqz	a0,ffffffffc0200c14 <slub_check+0x9a>
ffffffffc0200ba6:	84aa                	mv	s1,a0
    p1 = slub_alloc_pages(1);
ffffffffc0200ba8:	4505                	li	a0,1
ffffffffc0200baa:	eedff0ef          	jal	ra,ffffffffc0200a96 <slub_alloc_pages>
ffffffffc0200bae:	892a                	mv	s2,a0
    assert(p1 != NULL);
ffffffffc0200bb0:	c171                	beqz	a0,ffffffffc0200c74 <slub_check+0xfa>
    p2 = slub_alloc_pages(1);
ffffffffc0200bb2:	4505                	li	a0,1
ffffffffc0200bb4:	ee3ff0ef          	jal	ra,ffffffffc0200a96 <slub_alloc_pages>
    assert(p2 != NULL);
ffffffffc0200bb8:	cd51                	beqz	a0,ffffffffc0200c54 <slub_check+0xda>
    __list_add(elm, listelm, listelm->next);
ffffffffc0200bba:	7018                	ld	a4,32(s0)
            list_add(&cache->free_list, &base->page_link);  
ffffffffc0200bbc:	01848693          	addi	a3,s1,24
    elm->prev = prev;
ffffffffc0200bc0:	0000e797          	auipc	a5,0xe
ffffffffc0200bc4:	46878793          	addi	a5,a5,1128 # ffffffffc020f028 <slab_caches+0x18>
    prev->next = next->prev = elm;
ffffffffc0200bc8:	e314                	sd	a3,0(a4)
ffffffffc0200bca:	f014                	sd	a3,32(s0)
    elm->next = next;
ffffffffc0200bcc:	f098                	sd	a4,32(s1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200bce:	7014                	ld	a3,32(s0)
ffffffffc0200bd0:	01890613          	addi	a2,s2,24
    elm->prev = prev;
ffffffffc0200bd4:	ec9c                	sd	a5,24(s1)
            cache->free_count++;
ffffffffc0200bd6:	6818                	ld	a4,16(s0)
    prev->next = next->prev = elm;
ffffffffc0200bd8:	e290                	sd	a2,0(a3)
ffffffffc0200bda:	f010                	sd	a2,32(s0)
    elm->next = next;
ffffffffc0200bdc:	02d93023          	sd	a3,32(s2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200be0:	7014                	ld	a3,32(s0)
            list_add(&cache->free_list, &base->page_link);  
ffffffffc0200be2:	01850613          	addi	a2,a0,24
    elm->prev = prev;
ffffffffc0200be6:	00f93c23          	sd	a5,24(s2)
    prev->next = next->prev = elm;
ffffffffc0200bea:	e290                	sd	a2,0(a3)
ffffffffc0200bec:	f010                	sd	a2,32(s0)
    elm->next = next;
ffffffffc0200bee:	f114                	sd	a3,32(a0)
    elm->prev = prev;
ffffffffc0200bf0:	ed1c                	sd	a5,24(a0)
        total_free_pages += cache->free_count;
ffffffffc0200bf2:	7c1c                	ld	a5,56(s0)
ffffffffc0200bf4:	7030                	ld	a2,96(s0)
ffffffffc0200bf6:	6454                	ld	a3,136(s0)
            cache->free_count++;
ffffffffc0200bf8:	070d                	addi	a4,a4,3
        total_free_pages += cache->free_count;
ffffffffc0200bfa:	97b2                	add	a5,a5,a2
ffffffffc0200bfc:	97b6                	add	a5,a5,a3
            cache->free_count++;
ffffffffc0200bfe:	e818                	sd	a4,16(s0)
        total_free_pages += cache->free_count;
ffffffffc0200c00:	97ba                	add	a5,a5,a4
    slub_free_pages(p0, 1);
    slub_free_pages(p1, 1);
    slub_free_pages(p2, 1);

    // 确认所有页数都正确释放
    assert(slub_nr_free_pages() == all_pages);
ffffffffc0200c02:	03379963          	bne	a5,s3,ffffffffc0200c34 <slub_check+0xba>

    // cprintf("SLUB allocator test passed.\n");
}
ffffffffc0200c06:	70a2                	ld	ra,40(sp)
ffffffffc0200c08:	7402                	ld	s0,32(sp)
ffffffffc0200c0a:	64e2                	ld	s1,24(sp)
ffffffffc0200c0c:	6942                	ld	s2,16(sp)
ffffffffc0200c0e:	69a2                	ld	s3,8(sp)
ffffffffc0200c10:	6145                	addi	sp,sp,48
ffffffffc0200c12:	8082                	ret
    assert(p0 != NULL);
ffffffffc0200c14:	00001697          	auipc	a3,0x1
ffffffffc0200c18:	e4c68693          	addi	a3,a3,-436 # ffffffffc0201a60 <commands+0x600>
ffffffffc0200c1c:	00001617          	auipc	a2,0x1
ffffffffc0200c20:	e5460613          	addi	a2,a2,-428 # ffffffffc0201a70 <commands+0x610>
ffffffffc0200c24:	07300593          	li	a1,115
ffffffffc0200c28:	00001517          	auipc	a0,0x1
ffffffffc0200c2c:	e6050513          	addi	a0,a0,-416 # ffffffffc0201a88 <commands+0x628>
ffffffffc0200c30:	d0aff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(slub_nr_free_pages() == all_pages);
ffffffffc0200c34:	00001697          	auipc	a3,0x1
ffffffffc0200c38:	e8c68693          	addi	a3,a3,-372 # ffffffffc0201ac0 <commands+0x660>
ffffffffc0200c3c:	00001617          	auipc	a2,0x1
ffffffffc0200c40:	e3460613          	addi	a2,a2,-460 # ffffffffc0201a70 <commands+0x610>
ffffffffc0200c44:	07f00593          	li	a1,127
ffffffffc0200c48:	00001517          	auipc	a0,0x1
ffffffffc0200c4c:	e4050513          	addi	a0,a0,-448 # ffffffffc0201a88 <commands+0x628>
ffffffffc0200c50:	ceaff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(p2 != NULL);
ffffffffc0200c54:	00001697          	auipc	a3,0x1
ffffffffc0200c58:	e5c68693          	addi	a3,a3,-420 # ffffffffc0201ab0 <commands+0x650>
ffffffffc0200c5c:	00001617          	auipc	a2,0x1
ffffffffc0200c60:	e1460613          	addi	a2,a2,-492 # ffffffffc0201a70 <commands+0x610>
ffffffffc0200c64:	07700593          	li	a1,119
ffffffffc0200c68:	00001517          	auipc	a0,0x1
ffffffffc0200c6c:	e2050513          	addi	a0,a0,-480 # ffffffffc0201a88 <commands+0x628>
ffffffffc0200c70:	ccaff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(p1 != NULL);
ffffffffc0200c74:	00001697          	auipc	a3,0x1
ffffffffc0200c78:	e2c68693          	addi	a3,a3,-468 # ffffffffc0201aa0 <commands+0x640>
ffffffffc0200c7c:	00001617          	auipc	a2,0x1
ffffffffc0200c80:	df460613          	addi	a2,a2,-524 # ffffffffc0201a70 <commands+0x610>
ffffffffc0200c84:	07500593          	li	a1,117
ffffffffc0200c88:	00001517          	auipc	a0,0x1
ffffffffc0200c8c:	e0050513          	addi	a0,a0,-512 # ffffffffc0201a88 <commands+0x628>
ffffffffc0200c90:	caaff0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0200c94 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0200c94:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0200c96:	e589                	bnez	a1,ffffffffc0200ca0 <strnlen+0xc>
ffffffffc0200c98:	a811                	j	ffffffffc0200cac <strnlen+0x18>
        cnt ++;
ffffffffc0200c9a:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0200c9c:	00f58863          	beq	a1,a5,ffffffffc0200cac <strnlen+0x18>
ffffffffc0200ca0:	00f50733          	add	a4,a0,a5
ffffffffc0200ca4:	00074703          	lbu	a4,0(a4)
ffffffffc0200ca8:	fb6d                	bnez	a4,ffffffffc0200c9a <strnlen+0x6>
ffffffffc0200caa:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0200cac:	852e                	mv	a0,a1
ffffffffc0200cae:	8082                	ret

ffffffffc0200cb0 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0200cb0:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0200cb4:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0200cb8:	cb89                	beqz	a5,ffffffffc0200cca <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0200cba:	0505                	addi	a0,a0,1
ffffffffc0200cbc:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0200cbe:	fee789e3          	beq	a5,a4,ffffffffc0200cb0 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0200cc2:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0200cc6:	9d19                	subw	a0,a0,a4
ffffffffc0200cc8:	8082                	ret
ffffffffc0200cca:	4501                	li	a0,0
ffffffffc0200ccc:	bfed                	j	ffffffffc0200cc6 <strcmp+0x16>

ffffffffc0200cce <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0200cce:	00054783          	lbu	a5,0(a0)
ffffffffc0200cd2:	c799                	beqz	a5,ffffffffc0200ce0 <strchr+0x12>
        if (*s == c) {
ffffffffc0200cd4:	00f58763          	beq	a1,a5,ffffffffc0200ce2 <strchr+0x14>
    while (*s != '\0') {
ffffffffc0200cd8:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0200cdc:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0200cde:	fbfd                	bnez	a5,ffffffffc0200cd4 <strchr+0x6>
    }
    return NULL;
ffffffffc0200ce0:	4501                	li	a0,0
}
ffffffffc0200ce2:	8082                	ret

ffffffffc0200ce4 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0200ce4:	ca01                	beqz	a2,ffffffffc0200cf4 <memset+0x10>
ffffffffc0200ce6:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0200ce8:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0200cea:	0785                	addi	a5,a5,1
ffffffffc0200cec:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0200cf0:	fec79de3          	bne	a5,a2,ffffffffc0200cea <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0200cf4:	8082                	ret

ffffffffc0200cf6 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0200cf6:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200cfa:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0200cfc:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200d00:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0200d02:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200d06:	f022                	sd	s0,32(sp)
ffffffffc0200d08:	ec26                	sd	s1,24(sp)
ffffffffc0200d0a:	e84a                	sd	s2,16(sp)
ffffffffc0200d0c:	f406                	sd	ra,40(sp)
ffffffffc0200d0e:	e44e                	sd	s3,8(sp)
ffffffffc0200d10:	84aa                	mv	s1,a0
ffffffffc0200d12:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0200d14:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0200d18:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0200d1a:	03067e63          	bgeu	a2,a6,ffffffffc0200d56 <printnum+0x60>
ffffffffc0200d1e:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0200d20:	00805763          	blez	s0,ffffffffc0200d2e <printnum+0x38>
ffffffffc0200d24:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0200d26:	85ca                	mv	a1,s2
ffffffffc0200d28:	854e                	mv	a0,s3
ffffffffc0200d2a:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0200d2c:	fc65                	bnez	s0,ffffffffc0200d24 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200d2e:	1a02                	slli	s4,s4,0x20
ffffffffc0200d30:	00001797          	auipc	a5,0x1
ffffffffc0200d34:	e0878793          	addi	a5,a5,-504 # ffffffffc0201b38 <slub_pmm_manager+0x38>
ffffffffc0200d38:	020a5a13          	srli	s4,s4,0x20
ffffffffc0200d3c:	9a3e                	add	s4,s4,a5
}
ffffffffc0200d3e:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200d40:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0200d44:	70a2                	ld	ra,40(sp)
ffffffffc0200d46:	69a2                	ld	s3,8(sp)
ffffffffc0200d48:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200d4a:	85ca                	mv	a1,s2
ffffffffc0200d4c:	87a6                	mv	a5,s1
}
ffffffffc0200d4e:	6942                	ld	s2,16(sp)
ffffffffc0200d50:	64e2                	ld	s1,24(sp)
ffffffffc0200d52:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200d54:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0200d56:	03065633          	divu	a2,a2,a6
ffffffffc0200d5a:	8722                	mv	a4,s0
ffffffffc0200d5c:	f9bff0ef          	jal	ra,ffffffffc0200cf6 <printnum>
ffffffffc0200d60:	b7f9                	j	ffffffffc0200d2e <printnum+0x38>

ffffffffc0200d62 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0200d62:	7119                	addi	sp,sp,-128
ffffffffc0200d64:	f4a6                	sd	s1,104(sp)
ffffffffc0200d66:	f0ca                	sd	s2,96(sp)
ffffffffc0200d68:	ecce                	sd	s3,88(sp)
ffffffffc0200d6a:	e8d2                	sd	s4,80(sp)
ffffffffc0200d6c:	e4d6                	sd	s5,72(sp)
ffffffffc0200d6e:	e0da                	sd	s6,64(sp)
ffffffffc0200d70:	fc5e                	sd	s7,56(sp)
ffffffffc0200d72:	f06a                	sd	s10,32(sp)
ffffffffc0200d74:	fc86                	sd	ra,120(sp)
ffffffffc0200d76:	f8a2                	sd	s0,112(sp)
ffffffffc0200d78:	f862                	sd	s8,48(sp)
ffffffffc0200d7a:	f466                	sd	s9,40(sp)
ffffffffc0200d7c:	ec6e                	sd	s11,24(sp)
ffffffffc0200d7e:	892a                	mv	s2,a0
ffffffffc0200d80:	84ae                	mv	s1,a1
ffffffffc0200d82:	8d32                	mv	s10,a2
ffffffffc0200d84:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0200d86:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0200d8a:	5b7d                	li	s6,-1
ffffffffc0200d8c:	00001a97          	auipc	s5,0x1
ffffffffc0200d90:	de0a8a93          	addi	s5,s5,-544 # ffffffffc0201b6c <slub_pmm_manager+0x6c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0200d94:	00001b97          	auipc	s7,0x1
ffffffffc0200d98:	fb4b8b93          	addi	s7,s7,-76 # ffffffffc0201d48 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0200d9c:	000d4503          	lbu	a0,0(s10)
ffffffffc0200da0:	001d0413          	addi	s0,s10,1
ffffffffc0200da4:	01350a63          	beq	a0,s3,ffffffffc0200db8 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0200da8:	c121                	beqz	a0,ffffffffc0200de8 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0200daa:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0200dac:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0200dae:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0200db0:	fff44503          	lbu	a0,-1(s0)
ffffffffc0200db4:	ff351ae3          	bne	a0,s3,ffffffffc0200da8 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200db8:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0200dbc:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0200dc0:	4c81                	li	s9,0
ffffffffc0200dc2:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0200dc4:	5c7d                	li	s8,-1
ffffffffc0200dc6:	5dfd                	li	s11,-1
ffffffffc0200dc8:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0200dcc:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200dce:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0200dd2:	0ff5f593          	zext.b	a1,a1
ffffffffc0200dd6:	00140d13          	addi	s10,s0,1
ffffffffc0200dda:	04b56263          	bltu	a0,a1,ffffffffc0200e1e <vprintfmt+0xbc>
ffffffffc0200dde:	058a                	slli	a1,a1,0x2
ffffffffc0200de0:	95d6                	add	a1,a1,s5
ffffffffc0200de2:	4194                	lw	a3,0(a1)
ffffffffc0200de4:	96d6                	add	a3,a3,s5
ffffffffc0200de6:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0200de8:	70e6                	ld	ra,120(sp)
ffffffffc0200dea:	7446                	ld	s0,112(sp)
ffffffffc0200dec:	74a6                	ld	s1,104(sp)
ffffffffc0200dee:	7906                	ld	s2,96(sp)
ffffffffc0200df0:	69e6                	ld	s3,88(sp)
ffffffffc0200df2:	6a46                	ld	s4,80(sp)
ffffffffc0200df4:	6aa6                	ld	s5,72(sp)
ffffffffc0200df6:	6b06                	ld	s6,64(sp)
ffffffffc0200df8:	7be2                	ld	s7,56(sp)
ffffffffc0200dfa:	7c42                	ld	s8,48(sp)
ffffffffc0200dfc:	7ca2                	ld	s9,40(sp)
ffffffffc0200dfe:	7d02                	ld	s10,32(sp)
ffffffffc0200e00:	6de2                	ld	s11,24(sp)
ffffffffc0200e02:	6109                	addi	sp,sp,128
ffffffffc0200e04:	8082                	ret
            padc = '0';
ffffffffc0200e06:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0200e08:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200e0c:	846a                	mv	s0,s10
ffffffffc0200e0e:	00140d13          	addi	s10,s0,1
ffffffffc0200e12:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0200e16:	0ff5f593          	zext.b	a1,a1
ffffffffc0200e1a:	fcb572e3          	bgeu	a0,a1,ffffffffc0200dde <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0200e1e:	85a6                	mv	a1,s1
ffffffffc0200e20:	02500513          	li	a0,37
ffffffffc0200e24:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0200e26:	fff44783          	lbu	a5,-1(s0)
ffffffffc0200e2a:	8d22                	mv	s10,s0
ffffffffc0200e2c:	f73788e3          	beq	a5,s3,ffffffffc0200d9c <vprintfmt+0x3a>
ffffffffc0200e30:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0200e34:	1d7d                	addi	s10,s10,-1
ffffffffc0200e36:	ff379de3          	bne	a5,s3,ffffffffc0200e30 <vprintfmt+0xce>
ffffffffc0200e3a:	b78d                	j	ffffffffc0200d9c <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0200e3c:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0200e40:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200e44:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0200e46:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0200e4a:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0200e4e:	02d86463          	bltu	a6,a3,ffffffffc0200e76 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0200e52:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0200e56:	002c169b          	slliw	a3,s8,0x2
ffffffffc0200e5a:	0186873b          	addw	a4,a3,s8
ffffffffc0200e5e:	0017171b          	slliw	a4,a4,0x1
ffffffffc0200e62:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0200e64:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0200e68:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0200e6a:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0200e6e:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0200e72:	fed870e3          	bgeu	a6,a3,ffffffffc0200e52 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0200e76:	f40ddce3          	bgez	s11,ffffffffc0200dce <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0200e7a:	8de2                	mv	s11,s8
ffffffffc0200e7c:	5c7d                	li	s8,-1
ffffffffc0200e7e:	bf81                	j	ffffffffc0200dce <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0200e80:	fffdc693          	not	a3,s11
ffffffffc0200e84:	96fd                	srai	a3,a3,0x3f
ffffffffc0200e86:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200e8a:	00144603          	lbu	a2,1(s0)
ffffffffc0200e8e:	2d81                	sext.w	s11,s11
ffffffffc0200e90:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0200e92:	bf35                	j	ffffffffc0200dce <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0200e94:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200e98:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0200e9c:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200e9e:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0200ea0:	bfd9                	j	ffffffffc0200e76 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0200ea2:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0200ea4:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0200ea8:	01174463          	blt	a4,a7,ffffffffc0200eb0 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0200eac:	1a088e63          	beqz	a7,ffffffffc0201068 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0200eb0:	000a3603          	ld	a2,0(s4)
ffffffffc0200eb4:	46c1                	li	a3,16
ffffffffc0200eb6:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0200eb8:	2781                	sext.w	a5,a5
ffffffffc0200eba:	876e                	mv	a4,s11
ffffffffc0200ebc:	85a6                	mv	a1,s1
ffffffffc0200ebe:	854a                	mv	a0,s2
ffffffffc0200ec0:	e37ff0ef          	jal	ra,ffffffffc0200cf6 <printnum>
            break;
ffffffffc0200ec4:	bde1                	j	ffffffffc0200d9c <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0200ec6:	000a2503          	lw	a0,0(s4)
ffffffffc0200eca:	85a6                	mv	a1,s1
ffffffffc0200ecc:	0a21                	addi	s4,s4,8
ffffffffc0200ece:	9902                	jalr	s2
            break;
ffffffffc0200ed0:	b5f1                	j	ffffffffc0200d9c <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0200ed2:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0200ed4:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0200ed8:	01174463          	blt	a4,a7,ffffffffc0200ee0 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0200edc:	18088163          	beqz	a7,ffffffffc020105e <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0200ee0:	000a3603          	ld	a2,0(s4)
ffffffffc0200ee4:	46a9                	li	a3,10
ffffffffc0200ee6:	8a2e                	mv	s4,a1
ffffffffc0200ee8:	bfc1                	j	ffffffffc0200eb8 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200eea:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0200eee:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200ef0:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0200ef2:	bdf1                	j	ffffffffc0200dce <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0200ef4:	85a6                	mv	a1,s1
ffffffffc0200ef6:	02500513          	li	a0,37
ffffffffc0200efa:	9902                	jalr	s2
            break;
ffffffffc0200efc:	b545                	j	ffffffffc0200d9c <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200efe:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0200f02:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200f04:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0200f06:	b5e1                	j	ffffffffc0200dce <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0200f08:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0200f0a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0200f0e:	01174463          	blt	a4,a7,ffffffffc0200f16 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0200f12:	14088163          	beqz	a7,ffffffffc0201054 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0200f16:	000a3603          	ld	a2,0(s4)
ffffffffc0200f1a:	46a1                	li	a3,8
ffffffffc0200f1c:	8a2e                	mv	s4,a1
ffffffffc0200f1e:	bf69                	j	ffffffffc0200eb8 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0200f20:	03000513          	li	a0,48
ffffffffc0200f24:	85a6                	mv	a1,s1
ffffffffc0200f26:	e03e                	sd	a5,0(sp)
ffffffffc0200f28:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0200f2a:	85a6                	mv	a1,s1
ffffffffc0200f2c:	07800513          	li	a0,120
ffffffffc0200f30:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0200f32:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0200f34:	6782                	ld	a5,0(sp)
ffffffffc0200f36:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0200f38:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0200f3c:	bfb5                	j	ffffffffc0200eb8 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0200f3e:	000a3403          	ld	s0,0(s4)
ffffffffc0200f42:	008a0713          	addi	a4,s4,8
ffffffffc0200f46:	e03a                	sd	a4,0(sp)
ffffffffc0200f48:	14040263          	beqz	s0,ffffffffc020108c <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0200f4c:	0fb05763          	blez	s11,ffffffffc020103a <vprintfmt+0x2d8>
ffffffffc0200f50:	02d00693          	li	a3,45
ffffffffc0200f54:	0cd79163          	bne	a5,a3,ffffffffc0201016 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0200f58:	00044783          	lbu	a5,0(s0)
ffffffffc0200f5c:	0007851b          	sext.w	a0,a5
ffffffffc0200f60:	cf85                	beqz	a5,ffffffffc0200f98 <vprintfmt+0x236>
ffffffffc0200f62:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0200f66:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0200f6a:	000c4563          	bltz	s8,ffffffffc0200f74 <vprintfmt+0x212>
ffffffffc0200f6e:	3c7d                	addiw	s8,s8,-1
ffffffffc0200f70:	036c0263          	beq	s8,s6,ffffffffc0200f94 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0200f74:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0200f76:	0e0c8e63          	beqz	s9,ffffffffc0201072 <vprintfmt+0x310>
ffffffffc0200f7a:	3781                	addiw	a5,a5,-32
ffffffffc0200f7c:	0ef47b63          	bgeu	s0,a5,ffffffffc0201072 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0200f80:	03f00513          	li	a0,63
ffffffffc0200f84:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0200f86:	000a4783          	lbu	a5,0(s4)
ffffffffc0200f8a:	3dfd                	addiw	s11,s11,-1
ffffffffc0200f8c:	0a05                	addi	s4,s4,1
ffffffffc0200f8e:	0007851b          	sext.w	a0,a5
ffffffffc0200f92:	ffe1                	bnez	a5,ffffffffc0200f6a <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0200f94:	01b05963          	blez	s11,ffffffffc0200fa6 <vprintfmt+0x244>
ffffffffc0200f98:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0200f9a:	85a6                	mv	a1,s1
ffffffffc0200f9c:	02000513          	li	a0,32
ffffffffc0200fa0:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0200fa2:	fe0d9be3          	bnez	s11,ffffffffc0200f98 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0200fa6:	6a02                	ld	s4,0(sp)
ffffffffc0200fa8:	bbd5                	j	ffffffffc0200d9c <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0200faa:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0200fac:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0200fb0:	01174463          	blt	a4,a7,ffffffffc0200fb8 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0200fb4:	08088d63          	beqz	a7,ffffffffc020104e <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0200fb8:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0200fbc:	0a044d63          	bltz	s0,ffffffffc0201076 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0200fc0:	8622                	mv	a2,s0
ffffffffc0200fc2:	8a66                	mv	s4,s9
ffffffffc0200fc4:	46a9                	li	a3,10
ffffffffc0200fc6:	bdcd                	j	ffffffffc0200eb8 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0200fc8:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0200fcc:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0200fce:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0200fd0:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0200fd4:	8fb5                	xor	a5,a5,a3
ffffffffc0200fd6:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0200fda:	02d74163          	blt	a4,a3,ffffffffc0200ffc <vprintfmt+0x29a>
ffffffffc0200fde:	00369793          	slli	a5,a3,0x3
ffffffffc0200fe2:	97de                	add	a5,a5,s7
ffffffffc0200fe4:	639c                	ld	a5,0(a5)
ffffffffc0200fe6:	cb99                	beqz	a5,ffffffffc0200ffc <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0200fe8:	86be                	mv	a3,a5
ffffffffc0200fea:	00001617          	auipc	a2,0x1
ffffffffc0200fee:	b7e60613          	addi	a2,a2,-1154 # ffffffffc0201b68 <slub_pmm_manager+0x68>
ffffffffc0200ff2:	85a6                	mv	a1,s1
ffffffffc0200ff4:	854a                	mv	a0,s2
ffffffffc0200ff6:	0ce000ef          	jal	ra,ffffffffc02010c4 <printfmt>
ffffffffc0200ffa:	b34d                	j	ffffffffc0200d9c <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0200ffc:	00001617          	auipc	a2,0x1
ffffffffc0201000:	b5c60613          	addi	a2,a2,-1188 # ffffffffc0201b58 <slub_pmm_manager+0x58>
ffffffffc0201004:	85a6                	mv	a1,s1
ffffffffc0201006:	854a                	mv	a0,s2
ffffffffc0201008:	0bc000ef          	jal	ra,ffffffffc02010c4 <printfmt>
ffffffffc020100c:	bb41                	j	ffffffffc0200d9c <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020100e:	00001417          	auipc	s0,0x1
ffffffffc0201012:	b4240413          	addi	s0,s0,-1214 # ffffffffc0201b50 <slub_pmm_manager+0x50>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201016:	85e2                	mv	a1,s8
ffffffffc0201018:	8522                	mv	a0,s0
ffffffffc020101a:	e43e                	sd	a5,8(sp)
ffffffffc020101c:	c79ff0ef          	jal	ra,ffffffffc0200c94 <strnlen>
ffffffffc0201020:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201024:	01b05b63          	blez	s11,ffffffffc020103a <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0201028:	67a2                	ld	a5,8(sp)
ffffffffc020102a:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020102e:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201030:	85a6                	mv	a1,s1
ffffffffc0201032:	8552                	mv	a0,s4
ffffffffc0201034:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201036:	fe0d9ce3          	bnez	s11,ffffffffc020102e <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020103a:	00044783          	lbu	a5,0(s0)
ffffffffc020103e:	00140a13          	addi	s4,s0,1
ffffffffc0201042:	0007851b          	sext.w	a0,a5
ffffffffc0201046:	d3a5                	beqz	a5,ffffffffc0200fa6 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201048:	05e00413          	li	s0,94
ffffffffc020104c:	bf39                	j	ffffffffc0200f6a <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc020104e:	000a2403          	lw	s0,0(s4)
ffffffffc0201052:	b7ad                	j	ffffffffc0200fbc <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0201054:	000a6603          	lwu	a2,0(s4)
ffffffffc0201058:	46a1                	li	a3,8
ffffffffc020105a:	8a2e                	mv	s4,a1
ffffffffc020105c:	bdb1                	j	ffffffffc0200eb8 <vprintfmt+0x156>
ffffffffc020105e:	000a6603          	lwu	a2,0(s4)
ffffffffc0201062:	46a9                	li	a3,10
ffffffffc0201064:	8a2e                	mv	s4,a1
ffffffffc0201066:	bd89                	j	ffffffffc0200eb8 <vprintfmt+0x156>
ffffffffc0201068:	000a6603          	lwu	a2,0(s4)
ffffffffc020106c:	46c1                	li	a3,16
ffffffffc020106e:	8a2e                	mv	s4,a1
ffffffffc0201070:	b5a1                	j	ffffffffc0200eb8 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0201072:	9902                	jalr	s2
ffffffffc0201074:	bf09                	j	ffffffffc0200f86 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0201076:	85a6                	mv	a1,s1
ffffffffc0201078:	02d00513          	li	a0,45
ffffffffc020107c:	e03e                	sd	a5,0(sp)
ffffffffc020107e:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201080:	6782                	ld	a5,0(sp)
ffffffffc0201082:	8a66                	mv	s4,s9
ffffffffc0201084:	40800633          	neg	a2,s0
ffffffffc0201088:	46a9                	li	a3,10
ffffffffc020108a:	b53d                	j	ffffffffc0200eb8 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc020108c:	03b05163          	blez	s11,ffffffffc02010ae <vprintfmt+0x34c>
ffffffffc0201090:	02d00693          	li	a3,45
ffffffffc0201094:	f6d79de3          	bne	a5,a3,ffffffffc020100e <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0201098:	00001417          	auipc	s0,0x1
ffffffffc020109c:	ab840413          	addi	s0,s0,-1352 # ffffffffc0201b50 <slub_pmm_manager+0x50>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02010a0:	02800793          	li	a5,40
ffffffffc02010a4:	02800513          	li	a0,40
ffffffffc02010a8:	00140a13          	addi	s4,s0,1
ffffffffc02010ac:	bd6d                	j	ffffffffc0200f66 <vprintfmt+0x204>
ffffffffc02010ae:	00001a17          	auipc	s4,0x1
ffffffffc02010b2:	aa3a0a13          	addi	s4,s4,-1373 # ffffffffc0201b51 <slub_pmm_manager+0x51>
ffffffffc02010b6:	02800513          	li	a0,40
ffffffffc02010ba:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02010be:	05e00413          	li	s0,94
ffffffffc02010c2:	b565                	j	ffffffffc0200f6a <vprintfmt+0x208>

ffffffffc02010c4 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02010c4:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02010c6:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02010ca:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02010cc:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02010ce:	ec06                	sd	ra,24(sp)
ffffffffc02010d0:	f83a                	sd	a4,48(sp)
ffffffffc02010d2:	fc3e                	sd	a5,56(sp)
ffffffffc02010d4:	e0c2                	sd	a6,64(sp)
ffffffffc02010d6:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02010d8:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02010da:	c89ff0ef          	jal	ra,ffffffffc0200d62 <vprintfmt>
}
ffffffffc02010de:	60e2                	ld	ra,24(sp)
ffffffffc02010e0:	6161                	addi	sp,sp,80
ffffffffc02010e2:	8082                	ret

ffffffffc02010e4 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02010e4:	715d                	addi	sp,sp,-80
ffffffffc02010e6:	e486                	sd	ra,72(sp)
ffffffffc02010e8:	e0a6                	sd	s1,64(sp)
ffffffffc02010ea:	fc4a                	sd	s2,56(sp)
ffffffffc02010ec:	f84e                	sd	s3,48(sp)
ffffffffc02010ee:	f452                	sd	s4,40(sp)
ffffffffc02010f0:	f056                	sd	s5,32(sp)
ffffffffc02010f2:	ec5a                	sd	s6,24(sp)
ffffffffc02010f4:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc02010f6:	c901                	beqz	a0,ffffffffc0201106 <readline+0x22>
ffffffffc02010f8:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02010fa:	00001517          	auipc	a0,0x1
ffffffffc02010fe:	a6e50513          	addi	a0,a0,-1426 # ffffffffc0201b68 <slub_pmm_manager+0x68>
ffffffffc0201102:	fb1fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc0201106:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201108:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020110a:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020110c:	4aa9                	li	s5,10
ffffffffc020110e:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201110:	0000eb97          	auipc	s7,0xe
ffffffffc0201114:	fa0b8b93          	addi	s7,s7,-96 # ffffffffc020f0b0 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201118:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020111c:	80eff0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201120:	00054a63          	bltz	a0,ffffffffc0201134 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201124:	00a95a63          	bge	s2,a0,ffffffffc0201138 <readline+0x54>
ffffffffc0201128:	029a5263          	bge	s4,s1,ffffffffc020114c <readline+0x68>
        c = getchar();
ffffffffc020112c:	ffffe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201130:	fe055ae3          	bgez	a0,ffffffffc0201124 <readline+0x40>
            return NULL;
ffffffffc0201134:	4501                	li	a0,0
ffffffffc0201136:	a091                	j	ffffffffc020117a <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0201138:	03351463          	bne	a0,s3,ffffffffc0201160 <readline+0x7c>
ffffffffc020113c:	e8a9                	bnez	s1,ffffffffc020118e <readline+0xaa>
        c = getchar();
ffffffffc020113e:	fedfe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201142:	fe0549e3          	bltz	a0,ffffffffc0201134 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201146:	fea959e3          	bge	s2,a0,ffffffffc0201138 <readline+0x54>
ffffffffc020114a:	4481                	li	s1,0
            cputchar(c);
ffffffffc020114c:	e42a                	sd	a0,8(sp)
ffffffffc020114e:	f9bfe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc0201152:	6522                	ld	a0,8(sp)
ffffffffc0201154:	009b87b3          	add	a5,s7,s1
ffffffffc0201158:	2485                	addiw	s1,s1,1
ffffffffc020115a:	00a78023          	sb	a0,0(a5)
ffffffffc020115e:	bf7d                	j	ffffffffc020111c <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0201160:	01550463          	beq	a0,s5,ffffffffc0201168 <readline+0x84>
ffffffffc0201164:	fb651ce3          	bne	a0,s6,ffffffffc020111c <readline+0x38>
            cputchar(c);
ffffffffc0201168:	f81fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc020116c:	0000e517          	auipc	a0,0xe
ffffffffc0201170:	f4450513          	addi	a0,a0,-188 # ffffffffc020f0b0 <buf>
ffffffffc0201174:	94aa                	add	s1,s1,a0
ffffffffc0201176:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc020117a:	60a6                	ld	ra,72(sp)
ffffffffc020117c:	6486                	ld	s1,64(sp)
ffffffffc020117e:	7962                	ld	s2,56(sp)
ffffffffc0201180:	79c2                	ld	s3,48(sp)
ffffffffc0201182:	7a22                	ld	s4,40(sp)
ffffffffc0201184:	7a82                	ld	s5,32(sp)
ffffffffc0201186:	6b62                	ld	s6,24(sp)
ffffffffc0201188:	6bc2                	ld	s7,16(sp)
ffffffffc020118a:	6161                	addi	sp,sp,80
ffffffffc020118c:	8082                	ret
            cputchar(c);
ffffffffc020118e:	4521                	li	a0,8
ffffffffc0201190:	f59fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc0201194:	34fd                	addiw	s1,s1,-1
ffffffffc0201196:	b759                	j	ffffffffc020111c <readline+0x38>

ffffffffc0201198 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0201198:	4781                	li	a5,0
ffffffffc020119a:	00004717          	auipc	a4,0x4
ffffffffc020119e:	e6e73703          	ld	a4,-402(a4) # ffffffffc0205008 <SBI_CONSOLE_PUTCHAR>
ffffffffc02011a2:	88ba                	mv	a7,a4
ffffffffc02011a4:	852a                	mv	a0,a0
ffffffffc02011a6:	85be                	mv	a1,a5
ffffffffc02011a8:	863e                	mv	a2,a5
ffffffffc02011aa:	00000073          	ecall
ffffffffc02011ae:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc02011b0:	8082                	ret

ffffffffc02011b2 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc02011b2:	4781                	li	a5,0
ffffffffc02011b4:	0000e717          	auipc	a4,0xe
ffffffffc02011b8:	34473703          	ld	a4,836(a4) # ffffffffc020f4f8 <SBI_SET_TIMER>
ffffffffc02011bc:	88ba                	mv	a7,a4
ffffffffc02011be:	852a                	mv	a0,a0
ffffffffc02011c0:	85be                	mv	a1,a5
ffffffffc02011c2:	863e                	mv	a2,a5
ffffffffc02011c4:	00000073          	ecall
ffffffffc02011c8:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc02011ca:	8082                	ret

ffffffffc02011cc <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc02011cc:	4501                	li	a0,0
ffffffffc02011ce:	00004797          	auipc	a5,0x4
ffffffffc02011d2:	e327b783          	ld	a5,-462(a5) # ffffffffc0205000 <SBI_CONSOLE_GETCHAR>
ffffffffc02011d6:	88be                	mv	a7,a5
ffffffffc02011d8:	852a                	mv	a0,a0
ffffffffc02011da:	85aa                	mv	a1,a0
ffffffffc02011dc:	862a                	mv	a2,a0
ffffffffc02011de:	00000073          	ecall
ffffffffc02011e2:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc02011e4:	2501                	sext.w	a0,a0
ffffffffc02011e6:	8082                	ret
