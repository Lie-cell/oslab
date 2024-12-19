
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020b2b7          	lui	t0,0xc020b
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
ffffffffc0200024:	c020b137          	lui	sp,0xc020b

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

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	000a7517          	auipc	a0,0xa7
ffffffffc0200036:	3ae50513          	addi	a0,a0,942 # ffffffffc02a73e0 <buf>
ffffffffc020003a:	000b3617          	auipc	a2,0xb3
ffffffffc020003e:	90260613          	addi	a2,a2,-1790 # ffffffffc02b293c <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	2f8060ef          	jal	ra,ffffffffc0206342 <memset>
    cons_init();                // init the console
ffffffffc020004e:	580000ef          	jal	ra,ffffffffc02005ce <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00006597          	auipc	a1,0x6
ffffffffc0200056:	71e58593          	addi	a1,a1,1822 # ffffffffc0206770 <etext>
ffffffffc020005a:	00006517          	auipc	a0,0x6
ffffffffc020005e:	73650513          	addi	a0,a0,1846 # ffffffffc0206790 <etext+0x20>
ffffffffc0200062:	06a000ef          	jal	ra,ffffffffc02000cc <cprintf>

    print_kerninfo();
ffffffffc0200066:	24e000ef          	jal	ra,ffffffffc02002b4 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	58b030ef          	jal	ra,ffffffffc0203df4 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc020006e:	5d2000ef          	jal	ra,ffffffffc0200640 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200072:	5dc000ef          	jal	ra,ffffffffc020064e <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200076:	184010ef          	jal	ra,ffffffffc02011fa <vmm_init>
    proc_init();                // init process table
ffffffffc020007a:	6af050ef          	jal	ra,ffffffffc0205f28 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc020007e:	4a8000ef          	jal	ra,ffffffffc0200526 <ide_init>
    swap_init();                // init swap
ffffffffc0200082:	13b010ef          	jal	ra,ffffffffc02019bc <swap_init>

    clock_init();               // init clock interrupt
ffffffffc0200086:	4f6000ef          	jal	ra,ffffffffc020057c <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008a:	5b8000ef          	jal	ra,ffffffffc0200642 <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc020008e:	032060ef          	jal	ra,ffffffffc02060c0 <cpu_idle>

ffffffffc0200092 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200092:	1141                	addi	sp,sp,-16
ffffffffc0200094:	e022                	sd	s0,0(sp)
ffffffffc0200096:	e406                	sd	ra,8(sp)
ffffffffc0200098:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020009a:	536000ef          	jal	ra,ffffffffc02005d0 <cons_putc>
    (*cnt) ++;
ffffffffc020009e:	401c                	lw	a5,0(s0)
}
ffffffffc02000a0:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc02000a2:	2785                	addiw	a5,a5,1
ffffffffc02000a4:	c01c                	sw	a5,0(s0)
}
ffffffffc02000a6:	6402                	ld	s0,0(sp)
ffffffffc02000a8:	0141                	addi	sp,sp,16
ffffffffc02000aa:	8082                	ret

ffffffffc02000ac <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000ac:	1101                	addi	sp,sp,-32
ffffffffc02000ae:	862a                	mv	a2,a0
ffffffffc02000b0:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000b2:	00000517          	auipc	a0,0x0
ffffffffc02000b6:	fe050513          	addi	a0,a0,-32 # ffffffffc0200092 <cputch>
ffffffffc02000ba:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000bc:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000be:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c0:	318060ef          	jal	ra,ffffffffc02063d8 <vprintfmt>
    return cnt;
}
ffffffffc02000c4:	60e2                	ld	ra,24(sp)
ffffffffc02000c6:	4532                	lw	a0,12(sp)
ffffffffc02000c8:	6105                	addi	sp,sp,32
ffffffffc02000ca:	8082                	ret

ffffffffc02000cc <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000cc:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000ce:	02810313          	addi	t1,sp,40 # ffffffffc020b028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000d2:	8e2a                	mv	t3,a0
ffffffffc02000d4:	f42e                	sd	a1,40(sp)
ffffffffc02000d6:	f832                	sd	a2,48(sp)
ffffffffc02000d8:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000da:	00000517          	auipc	a0,0x0
ffffffffc02000de:	fb850513          	addi	a0,a0,-72 # ffffffffc0200092 <cputch>
ffffffffc02000e2:	004c                	addi	a1,sp,4
ffffffffc02000e4:	869a                	mv	a3,t1
ffffffffc02000e6:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000e8:	ec06                	sd	ra,24(sp)
ffffffffc02000ea:	e0ba                	sd	a4,64(sp)
ffffffffc02000ec:	e4be                	sd	a5,72(sp)
ffffffffc02000ee:	e8c2                	sd	a6,80(sp)
ffffffffc02000f0:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000f2:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000f4:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000f6:	2e2060ef          	jal	ra,ffffffffc02063d8 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000fa:	60e2                	ld	ra,24(sp)
ffffffffc02000fc:	4512                	lw	a0,4(sp)
ffffffffc02000fe:	6125                	addi	sp,sp,96
ffffffffc0200100:	8082                	ret

ffffffffc0200102 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc0200102:	a1f9                	j	ffffffffc02005d0 <cons_putc>

ffffffffc0200104 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc0200104:	1101                	addi	sp,sp,-32
ffffffffc0200106:	e822                	sd	s0,16(sp)
ffffffffc0200108:	ec06                	sd	ra,24(sp)
ffffffffc020010a:	e426                	sd	s1,8(sp)
ffffffffc020010c:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc020010e:	00054503          	lbu	a0,0(a0)
ffffffffc0200112:	c51d                	beqz	a0,ffffffffc0200140 <cputs+0x3c>
ffffffffc0200114:	0405                	addi	s0,s0,1
ffffffffc0200116:	4485                	li	s1,1
ffffffffc0200118:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc020011a:	4b6000ef          	jal	ra,ffffffffc02005d0 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc020011e:	00044503          	lbu	a0,0(s0)
ffffffffc0200122:	008487bb          	addw	a5,s1,s0
ffffffffc0200126:	0405                	addi	s0,s0,1
ffffffffc0200128:	f96d                	bnez	a0,ffffffffc020011a <cputs+0x16>
    (*cnt) ++;
ffffffffc020012a:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc020012e:	4529                	li	a0,10
ffffffffc0200130:	4a0000ef          	jal	ra,ffffffffc02005d0 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc0200134:	60e2                	ld	ra,24(sp)
ffffffffc0200136:	8522                	mv	a0,s0
ffffffffc0200138:	6442                	ld	s0,16(sp)
ffffffffc020013a:	64a2                	ld	s1,8(sp)
ffffffffc020013c:	6105                	addi	sp,sp,32
ffffffffc020013e:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200140:	4405                	li	s0,1
ffffffffc0200142:	b7f5                	j	ffffffffc020012e <cputs+0x2a>

ffffffffc0200144 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200144:	1141                	addi	sp,sp,-16
ffffffffc0200146:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200148:	4bc000ef          	jal	ra,ffffffffc0200604 <cons_getc>
ffffffffc020014c:	dd75                	beqz	a0,ffffffffc0200148 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc020014e:	60a2                	ld	ra,8(sp)
ffffffffc0200150:	0141                	addi	sp,sp,16
ffffffffc0200152:	8082                	ret

ffffffffc0200154 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200154:	715d                	addi	sp,sp,-80
ffffffffc0200156:	e486                	sd	ra,72(sp)
ffffffffc0200158:	e0a6                	sd	s1,64(sp)
ffffffffc020015a:	fc4a                	sd	s2,56(sp)
ffffffffc020015c:	f84e                	sd	s3,48(sp)
ffffffffc020015e:	f452                	sd	s4,40(sp)
ffffffffc0200160:	f056                	sd	s5,32(sp)
ffffffffc0200162:	ec5a                	sd	s6,24(sp)
ffffffffc0200164:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0200166:	c901                	beqz	a0,ffffffffc0200176 <readline+0x22>
ffffffffc0200168:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc020016a:	00006517          	auipc	a0,0x6
ffffffffc020016e:	62e50513          	addi	a0,a0,1582 # ffffffffc0206798 <etext+0x28>
ffffffffc0200172:	f5bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
readline(const char *prompt) {
ffffffffc0200176:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200178:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020017a:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020017c:	4aa9                	li	s5,10
ffffffffc020017e:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0200180:	000a7b97          	auipc	s7,0xa7
ffffffffc0200184:	260b8b93          	addi	s7,s7,608 # ffffffffc02a73e0 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200188:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020018c:	fb9ff0ef          	jal	ra,ffffffffc0200144 <getchar>
        if (c < 0) {
ffffffffc0200190:	00054a63          	bltz	a0,ffffffffc02001a4 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200194:	00a95a63          	bge	s2,a0,ffffffffc02001a8 <readline+0x54>
ffffffffc0200198:	029a5263          	bge	s4,s1,ffffffffc02001bc <readline+0x68>
        c = getchar();
ffffffffc020019c:	fa9ff0ef          	jal	ra,ffffffffc0200144 <getchar>
        if (c < 0) {
ffffffffc02001a0:	fe055ae3          	bgez	a0,ffffffffc0200194 <readline+0x40>
            return NULL;
ffffffffc02001a4:	4501                	li	a0,0
ffffffffc02001a6:	a091                	j	ffffffffc02001ea <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02001a8:	03351463          	bne	a0,s3,ffffffffc02001d0 <readline+0x7c>
ffffffffc02001ac:	e8a9                	bnez	s1,ffffffffc02001fe <readline+0xaa>
        c = getchar();
ffffffffc02001ae:	f97ff0ef          	jal	ra,ffffffffc0200144 <getchar>
        if (c < 0) {
ffffffffc02001b2:	fe0549e3          	bltz	a0,ffffffffc02001a4 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02001b6:	fea959e3          	bge	s2,a0,ffffffffc02001a8 <readline+0x54>
ffffffffc02001ba:	4481                	li	s1,0
            cputchar(c);
ffffffffc02001bc:	e42a                	sd	a0,8(sp)
ffffffffc02001be:	f45ff0ef          	jal	ra,ffffffffc0200102 <cputchar>
            buf[i ++] = c;
ffffffffc02001c2:	6522                	ld	a0,8(sp)
ffffffffc02001c4:	009b87b3          	add	a5,s7,s1
ffffffffc02001c8:	2485                	addiw	s1,s1,1
ffffffffc02001ca:	00a78023          	sb	a0,0(a5)
ffffffffc02001ce:	bf7d                	j	ffffffffc020018c <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02001d0:	01550463          	beq	a0,s5,ffffffffc02001d8 <readline+0x84>
ffffffffc02001d4:	fb651ce3          	bne	a0,s6,ffffffffc020018c <readline+0x38>
            cputchar(c);
ffffffffc02001d8:	f2bff0ef          	jal	ra,ffffffffc0200102 <cputchar>
            buf[i] = '\0';
ffffffffc02001dc:	000a7517          	auipc	a0,0xa7
ffffffffc02001e0:	20450513          	addi	a0,a0,516 # ffffffffc02a73e0 <buf>
ffffffffc02001e4:	94aa                	add	s1,s1,a0
ffffffffc02001e6:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02001ea:	60a6                	ld	ra,72(sp)
ffffffffc02001ec:	6486                	ld	s1,64(sp)
ffffffffc02001ee:	7962                	ld	s2,56(sp)
ffffffffc02001f0:	79c2                	ld	s3,48(sp)
ffffffffc02001f2:	7a22                	ld	s4,40(sp)
ffffffffc02001f4:	7a82                	ld	s5,32(sp)
ffffffffc02001f6:	6b62                	ld	s6,24(sp)
ffffffffc02001f8:	6bc2                	ld	s7,16(sp)
ffffffffc02001fa:	6161                	addi	sp,sp,80
ffffffffc02001fc:	8082                	ret
            cputchar(c);
ffffffffc02001fe:	4521                	li	a0,8
ffffffffc0200200:	f03ff0ef          	jal	ra,ffffffffc0200102 <cputchar>
            i --;
ffffffffc0200204:	34fd                	addiw	s1,s1,-1
ffffffffc0200206:	b759                	j	ffffffffc020018c <readline+0x38>

ffffffffc0200208 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200208:	000b2317          	auipc	t1,0xb2
ffffffffc020020c:	6a030313          	addi	t1,t1,1696 # ffffffffc02b28a8 <is_panic>
ffffffffc0200210:	00033e03          	ld	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200214:	715d                	addi	sp,sp,-80
ffffffffc0200216:	ec06                	sd	ra,24(sp)
ffffffffc0200218:	e822                	sd	s0,16(sp)
ffffffffc020021a:	f436                	sd	a3,40(sp)
ffffffffc020021c:	f83a                	sd	a4,48(sp)
ffffffffc020021e:	fc3e                	sd	a5,56(sp)
ffffffffc0200220:	e0c2                	sd	a6,64(sp)
ffffffffc0200222:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200224:	020e1a63          	bnez	t3,ffffffffc0200258 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200228:	4785                	li	a5,1
ffffffffc020022a:	00f33023          	sd	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc020022e:	8432                	mv	s0,a2
ffffffffc0200230:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200232:	862e                	mv	a2,a1
ffffffffc0200234:	85aa                	mv	a1,a0
ffffffffc0200236:	00006517          	auipc	a0,0x6
ffffffffc020023a:	56a50513          	addi	a0,a0,1386 # ffffffffc02067a0 <etext+0x30>
    va_start(ap, fmt);
ffffffffc020023e:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200240:	e8dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200244:	65a2                	ld	a1,8(sp)
ffffffffc0200246:	8522                	mv	a0,s0
ffffffffc0200248:	e65ff0ef          	jal	ra,ffffffffc02000ac <vcprintf>
    cprintf("\n");
ffffffffc020024c:	00008517          	auipc	a0,0x8
ffffffffc0200250:	07c50513          	addi	a0,a0,124 # ffffffffc02082c8 <default_pmm_manager+0x400>
ffffffffc0200254:	e79ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200258:	4501                	li	a0,0
ffffffffc020025a:	4581                	li	a1,0
ffffffffc020025c:	4601                	li	a2,0
ffffffffc020025e:	48a1                	li	a7,8
ffffffffc0200260:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc0200264:	3e4000ef          	jal	ra,ffffffffc0200648 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200268:	4501                	li	a0,0
ffffffffc020026a:	174000ef          	jal	ra,ffffffffc02003de <kmonitor>
    while (1) {
ffffffffc020026e:	bfed                	j	ffffffffc0200268 <__panic+0x60>

ffffffffc0200270 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200270:	715d                	addi	sp,sp,-80
ffffffffc0200272:	832e                	mv	t1,a1
ffffffffc0200274:	e822                	sd	s0,16(sp)
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200276:	85aa                	mv	a1,a0
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200278:	8432                	mv	s0,a2
ffffffffc020027a:	fc3e                	sd	a5,56(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc020027c:	861a                	mv	a2,t1
    va_start(ap, fmt);
ffffffffc020027e:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200280:	00006517          	auipc	a0,0x6
ffffffffc0200284:	54050513          	addi	a0,a0,1344 # ffffffffc02067c0 <etext+0x50>
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200288:	ec06                	sd	ra,24(sp)
ffffffffc020028a:	f436                	sd	a3,40(sp)
ffffffffc020028c:	f83a                	sd	a4,48(sp)
ffffffffc020028e:	e0c2                	sd	a6,64(sp)
ffffffffc0200290:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0200292:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200294:	e39ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200298:	65a2                	ld	a1,8(sp)
ffffffffc020029a:	8522                	mv	a0,s0
ffffffffc020029c:	e11ff0ef          	jal	ra,ffffffffc02000ac <vcprintf>
    cprintf("\n");
ffffffffc02002a0:	00008517          	auipc	a0,0x8
ffffffffc02002a4:	02850513          	addi	a0,a0,40 # ffffffffc02082c8 <default_pmm_manager+0x400>
ffffffffc02002a8:	e25ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    va_end(ap);
}
ffffffffc02002ac:	60e2                	ld	ra,24(sp)
ffffffffc02002ae:	6442                	ld	s0,16(sp)
ffffffffc02002b0:	6161                	addi	sp,sp,80
ffffffffc02002b2:	8082                	ret

ffffffffc02002b4 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc02002b4:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02002b6:	00006517          	auipc	a0,0x6
ffffffffc02002ba:	52a50513          	addi	a0,a0,1322 # ffffffffc02067e0 <etext+0x70>
void print_kerninfo(void) {
ffffffffc02002be:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02002c0:	e0dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02002c4:	00000597          	auipc	a1,0x0
ffffffffc02002c8:	d6e58593          	addi	a1,a1,-658 # ffffffffc0200032 <kern_init>
ffffffffc02002cc:	00006517          	auipc	a0,0x6
ffffffffc02002d0:	53450513          	addi	a0,a0,1332 # ffffffffc0206800 <etext+0x90>
ffffffffc02002d4:	df9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02002d8:	00006597          	auipc	a1,0x6
ffffffffc02002dc:	49858593          	addi	a1,a1,1176 # ffffffffc0206770 <etext>
ffffffffc02002e0:	00006517          	auipc	a0,0x6
ffffffffc02002e4:	54050513          	addi	a0,a0,1344 # ffffffffc0206820 <etext+0xb0>
ffffffffc02002e8:	de5ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc02002ec:	000a7597          	auipc	a1,0xa7
ffffffffc02002f0:	0f458593          	addi	a1,a1,244 # ffffffffc02a73e0 <buf>
ffffffffc02002f4:	00006517          	auipc	a0,0x6
ffffffffc02002f8:	54c50513          	addi	a0,a0,1356 # ffffffffc0206840 <etext+0xd0>
ffffffffc02002fc:	dd1ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200300:	000b2597          	auipc	a1,0xb2
ffffffffc0200304:	63c58593          	addi	a1,a1,1596 # ffffffffc02b293c <end>
ffffffffc0200308:	00006517          	auipc	a0,0x6
ffffffffc020030c:	55850513          	addi	a0,a0,1368 # ffffffffc0206860 <etext+0xf0>
ffffffffc0200310:	dbdff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200314:	000b3597          	auipc	a1,0xb3
ffffffffc0200318:	a2758593          	addi	a1,a1,-1497 # ffffffffc02b2d3b <end+0x3ff>
ffffffffc020031c:	00000797          	auipc	a5,0x0
ffffffffc0200320:	d1678793          	addi	a5,a5,-746 # ffffffffc0200032 <kern_init>
ffffffffc0200324:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200328:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020032c:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020032e:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200332:	95be                	add	a1,a1,a5
ffffffffc0200334:	85a9                	srai	a1,a1,0xa
ffffffffc0200336:	00006517          	auipc	a0,0x6
ffffffffc020033a:	54a50513          	addi	a0,a0,1354 # ffffffffc0206880 <etext+0x110>
}
ffffffffc020033e:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200340:	b371                	j	ffffffffc02000cc <cprintf>

ffffffffc0200342 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200342:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc0200344:	00006617          	auipc	a2,0x6
ffffffffc0200348:	56c60613          	addi	a2,a2,1388 # ffffffffc02068b0 <etext+0x140>
ffffffffc020034c:	04d00593          	li	a1,77
ffffffffc0200350:	00006517          	auipc	a0,0x6
ffffffffc0200354:	57850513          	addi	a0,a0,1400 # ffffffffc02068c8 <etext+0x158>
void print_stackframe(void) {
ffffffffc0200358:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020035a:	eafff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020035e <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020035e:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200360:	00006617          	auipc	a2,0x6
ffffffffc0200364:	58060613          	addi	a2,a2,1408 # ffffffffc02068e0 <etext+0x170>
ffffffffc0200368:	00006597          	auipc	a1,0x6
ffffffffc020036c:	59858593          	addi	a1,a1,1432 # ffffffffc0206900 <etext+0x190>
ffffffffc0200370:	00006517          	auipc	a0,0x6
ffffffffc0200374:	59850513          	addi	a0,a0,1432 # ffffffffc0206908 <etext+0x198>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200378:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020037a:	d53ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc020037e:	00006617          	auipc	a2,0x6
ffffffffc0200382:	59a60613          	addi	a2,a2,1434 # ffffffffc0206918 <etext+0x1a8>
ffffffffc0200386:	00006597          	auipc	a1,0x6
ffffffffc020038a:	5ba58593          	addi	a1,a1,1466 # ffffffffc0206940 <etext+0x1d0>
ffffffffc020038e:	00006517          	auipc	a0,0x6
ffffffffc0200392:	57a50513          	addi	a0,a0,1402 # ffffffffc0206908 <etext+0x198>
ffffffffc0200396:	d37ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc020039a:	00006617          	auipc	a2,0x6
ffffffffc020039e:	5b660613          	addi	a2,a2,1462 # ffffffffc0206950 <etext+0x1e0>
ffffffffc02003a2:	00006597          	auipc	a1,0x6
ffffffffc02003a6:	5ce58593          	addi	a1,a1,1486 # ffffffffc0206970 <etext+0x200>
ffffffffc02003aa:	00006517          	auipc	a0,0x6
ffffffffc02003ae:	55e50513          	addi	a0,a0,1374 # ffffffffc0206908 <etext+0x198>
ffffffffc02003b2:	d1bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    }
    return 0;
}
ffffffffc02003b6:	60a2                	ld	ra,8(sp)
ffffffffc02003b8:	4501                	li	a0,0
ffffffffc02003ba:	0141                	addi	sp,sp,16
ffffffffc02003bc:	8082                	ret

ffffffffc02003be <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02003be:	1141                	addi	sp,sp,-16
ffffffffc02003c0:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02003c2:	ef3ff0ef          	jal	ra,ffffffffc02002b4 <print_kerninfo>
    return 0;
}
ffffffffc02003c6:	60a2                	ld	ra,8(sp)
ffffffffc02003c8:	4501                	li	a0,0
ffffffffc02003ca:	0141                	addi	sp,sp,16
ffffffffc02003cc:	8082                	ret

ffffffffc02003ce <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02003ce:	1141                	addi	sp,sp,-16
ffffffffc02003d0:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02003d2:	f71ff0ef          	jal	ra,ffffffffc0200342 <print_stackframe>
    return 0;
}
ffffffffc02003d6:	60a2                	ld	ra,8(sp)
ffffffffc02003d8:	4501                	li	a0,0
ffffffffc02003da:	0141                	addi	sp,sp,16
ffffffffc02003dc:	8082                	ret

ffffffffc02003de <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02003de:	7115                	addi	sp,sp,-224
ffffffffc02003e0:	ed5e                	sd	s7,152(sp)
ffffffffc02003e2:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02003e4:	00006517          	auipc	a0,0x6
ffffffffc02003e8:	59c50513          	addi	a0,a0,1436 # ffffffffc0206980 <etext+0x210>
kmonitor(struct trapframe *tf) {
ffffffffc02003ec:	ed86                	sd	ra,216(sp)
ffffffffc02003ee:	e9a2                	sd	s0,208(sp)
ffffffffc02003f0:	e5a6                	sd	s1,200(sp)
ffffffffc02003f2:	e1ca                	sd	s2,192(sp)
ffffffffc02003f4:	fd4e                	sd	s3,184(sp)
ffffffffc02003f6:	f952                	sd	s4,176(sp)
ffffffffc02003f8:	f556                	sd	s5,168(sp)
ffffffffc02003fa:	f15a                	sd	s6,160(sp)
ffffffffc02003fc:	e962                	sd	s8,144(sp)
ffffffffc02003fe:	e566                	sd	s9,136(sp)
ffffffffc0200400:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200402:	ccbff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200406:	00006517          	auipc	a0,0x6
ffffffffc020040a:	5a250513          	addi	a0,a0,1442 # ffffffffc02069a8 <etext+0x238>
ffffffffc020040e:	cbfff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    if (tf != NULL) {
ffffffffc0200412:	000b8563          	beqz	s7,ffffffffc020041c <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200416:	855e                	mv	a0,s7
ffffffffc0200418:	41e000ef          	jal	ra,ffffffffc0200836 <print_trapframe>
ffffffffc020041c:	00006c17          	auipc	s8,0x6
ffffffffc0200420:	5fcc0c13          	addi	s8,s8,1532 # ffffffffc0206a18 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200424:	00006917          	auipc	s2,0x6
ffffffffc0200428:	5ac90913          	addi	s2,s2,1452 # ffffffffc02069d0 <etext+0x260>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020042c:	00006497          	auipc	s1,0x6
ffffffffc0200430:	5ac48493          	addi	s1,s1,1452 # ffffffffc02069d8 <etext+0x268>
        if (argc == MAXARGS - 1) {
ffffffffc0200434:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200436:	00006b17          	auipc	s6,0x6
ffffffffc020043a:	5aab0b13          	addi	s6,s6,1450 # ffffffffc02069e0 <etext+0x270>
        argv[argc ++] = buf;
ffffffffc020043e:	00006a17          	auipc	s4,0x6
ffffffffc0200442:	4c2a0a13          	addi	s4,s4,1218 # ffffffffc0206900 <etext+0x190>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200446:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200448:	854a                	mv	a0,s2
ffffffffc020044a:	d0bff0ef          	jal	ra,ffffffffc0200154 <readline>
ffffffffc020044e:	842a                	mv	s0,a0
ffffffffc0200450:	dd65                	beqz	a0,ffffffffc0200448 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200452:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200456:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200458:	e1bd                	bnez	a1,ffffffffc02004be <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc020045a:	fe0c87e3          	beqz	s9,ffffffffc0200448 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020045e:	6582                	ld	a1,0(sp)
ffffffffc0200460:	00006d17          	auipc	s10,0x6
ffffffffc0200464:	5b8d0d13          	addi	s10,s10,1464 # ffffffffc0206a18 <commands>
        argv[argc ++] = buf;
ffffffffc0200468:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020046a:	4401                	li	s0,0
ffffffffc020046c:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020046e:	6a1050ef          	jal	ra,ffffffffc020630e <strcmp>
ffffffffc0200472:	c919                	beqz	a0,ffffffffc0200488 <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200474:	2405                	addiw	s0,s0,1
ffffffffc0200476:	0b540063          	beq	s0,s5,ffffffffc0200516 <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020047a:	000d3503          	ld	a0,0(s10)
ffffffffc020047e:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200480:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200482:	68d050ef          	jal	ra,ffffffffc020630e <strcmp>
ffffffffc0200486:	f57d                	bnez	a0,ffffffffc0200474 <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200488:	00141793          	slli	a5,s0,0x1
ffffffffc020048c:	97a2                	add	a5,a5,s0
ffffffffc020048e:	078e                	slli	a5,a5,0x3
ffffffffc0200490:	97e2                	add	a5,a5,s8
ffffffffc0200492:	6b9c                	ld	a5,16(a5)
ffffffffc0200494:	865e                	mv	a2,s7
ffffffffc0200496:	002c                	addi	a1,sp,8
ffffffffc0200498:	fffc851b          	addiw	a0,s9,-1
ffffffffc020049c:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020049e:	fa0555e3          	bgez	a0,ffffffffc0200448 <kmonitor+0x6a>
}
ffffffffc02004a2:	60ee                	ld	ra,216(sp)
ffffffffc02004a4:	644e                	ld	s0,208(sp)
ffffffffc02004a6:	64ae                	ld	s1,200(sp)
ffffffffc02004a8:	690e                	ld	s2,192(sp)
ffffffffc02004aa:	79ea                	ld	s3,184(sp)
ffffffffc02004ac:	7a4a                	ld	s4,176(sp)
ffffffffc02004ae:	7aaa                	ld	s5,168(sp)
ffffffffc02004b0:	7b0a                	ld	s6,160(sp)
ffffffffc02004b2:	6bea                	ld	s7,152(sp)
ffffffffc02004b4:	6c4a                	ld	s8,144(sp)
ffffffffc02004b6:	6caa                	ld	s9,136(sp)
ffffffffc02004b8:	6d0a                	ld	s10,128(sp)
ffffffffc02004ba:	612d                	addi	sp,sp,224
ffffffffc02004bc:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02004be:	8526                	mv	a0,s1
ffffffffc02004c0:	66d050ef          	jal	ra,ffffffffc020632c <strchr>
ffffffffc02004c4:	c901                	beqz	a0,ffffffffc02004d4 <kmonitor+0xf6>
ffffffffc02004c6:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc02004ca:	00040023          	sb	zero,0(s0)
ffffffffc02004ce:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02004d0:	d5c9                	beqz	a1,ffffffffc020045a <kmonitor+0x7c>
ffffffffc02004d2:	b7f5                	j	ffffffffc02004be <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc02004d4:	00044783          	lbu	a5,0(s0)
ffffffffc02004d8:	d3c9                	beqz	a5,ffffffffc020045a <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc02004da:	033c8963          	beq	s9,s3,ffffffffc020050c <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc02004de:	003c9793          	slli	a5,s9,0x3
ffffffffc02004e2:	0118                	addi	a4,sp,128
ffffffffc02004e4:	97ba                	add	a5,a5,a4
ffffffffc02004e6:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02004ea:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02004ee:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02004f0:	e591                	bnez	a1,ffffffffc02004fc <kmonitor+0x11e>
ffffffffc02004f2:	b7b5                	j	ffffffffc020045e <kmonitor+0x80>
ffffffffc02004f4:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc02004f8:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02004fa:	d1a5                	beqz	a1,ffffffffc020045a <kmonitor+0x7c>
ffffffffc02004fc:	8526                	mv	a0,s1
ffffffffc02004fe:	62f050ef          	jal	ra,ffffffffc020632c <strchr>
ffffffffc0200502:	d96d                	beqz	a0,ffffffffc02004f4 <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200504:	00044583          	lbu	a1,0(s0)
ffffffffc0200508:	d9a9                	beqz	a1,ffffffffc020045a <kmonitor+0x7c>
ffffffffc020050a:	bf55                	j	ffffffffc02004be <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020050c:	45c1                	li	a1,16
ffffffffc020050e:	855a                	mv	a0,s6
ffffffffc0200510:	bbdff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0200514:	b7e9                	j	ffffffffc02004de <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200516:	6582                	ld	a1,0(sp)
ffffffffc0200518:	00006517          	auipc	a0,0x6
ffffffffc020051c:	4e850513          	addi	a0,a0,1256 # ffffffffc0206a00 <etext+0x290>
ffffffffc0200520:	badff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    return 0;
ffffffffc0200524:	b715                	j	ffffffffc0200448 <kmonitor+0x6a>

ffffffffc0200526 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc0200526:	8082                	ret

ffffffffc0200528 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc0200528:	00253513          	sltiu	a0,a0,2
ffffffffc020052c:	8082                	ret

ffffffffc020052e <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc020052e:	03800513          	li	a0,56
ffffffffc0200532:	8082                	ret

ffffffffc0200534 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200534:	000a7797          	auipc	a5,0xa7
ffffffffc0200538:	2ac78793          	addi	a5,a5,684 # ffffffffc02a77e0 <ide>
    int iobase = secno * SECTSIZE;
ffffffffc020053c:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc0200540:	1141                	addi	sp,sp,-16
ffffffffc0200542:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200544:	95be                	add	a1,a1,a5
ffffffffc0200546:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc020054a:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc020054c:	609050ef          	jal	ra,ffffffffc0206354 <memcpy>
    return 0;
}
ffffffffc0200550:	60a2                	ld	ra,8(sp)
ffffffffc0200552:	4501                	li	a0,0
ffffffffc0200554:	0141                	addi	sp,sp,16
ffffffffc0200556:	8082                	ret

ffffffffc0200558 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc0200558:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020055c:	000a7517          	auipc	a0,0xa7
ffffffffc0200560:	28450513          	addi	a0,a0,644 # ffffffffc02a77e0 <ide>
                   size_t nsecs) {
ffffffffc0200564:	1141                	addi	sp,sp,-16
ffffffffc0200566:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200568:	953e                	add	a0,a0,a5
ffffffffc020056a:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc020056e:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200570:	5e5050ef          	jal	ra,ffffffffc0206354 <memcpy>
    return 0;
}
ffffffffc0200574:	60a2                	ld	ra,8(sp)
ffffffffc0200576:	4501                	li	a0,0
ffffffffc0200578:	0141                	addi	sp,sp,16
ffffffffc020057a:	8082                	ret

ffffffffc020057c <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc020057c:	67e1                	lui	a5,0x18
ffffffffc020057e:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xd570>
ffffffffc0200582:	000b2717          	auipc	a4,0xb2
ffffffffc0200586:	32f73b23          	sd	a5,822(a4) # ffffffffc02b28b8 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020058a:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020058e:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200590:	953e                	add	a0,a0,a5
ffffffffc0200592:	4601                	li	a2,0
ffffffffc0200594:	4881                	li	a7,0
ffffffffc0200596:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc020059a:	02000793          	li	a5,32
ffffffffc020059e:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02005a2:	00006517          	auipc	a0,0x6
ffffffffc02005a6:	4be50513          	addi	a0,a0,1214 # ffffffffc0206a60 <commands+0x48>
    ticks = 0;
ffffffffc02005aa:	000b2797          	auipc	a5,0xb2
ffffffffc02005ae:	3007b323          	sd	zero,774(a5) # ffffffffc02b28b0 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc02005b2:	be29                	j	ffffffffc02000cc <cprintf>

ffffffffc02005b4 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02005b4:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02005b8:	000b2797          	auipc	a5,0xb2
ffffffffc02005bc:	3007b783          	ld	a5,768(a5) # ffffffffc02b28b8 <timebase>
ffffffffc02005c0:	953e                	add	a0,a0,a5
ffffffffc02005c2:	4581                	li	a1,0
ffffffffc02005c4:	4601                	li	a2,0
ffffffffc02005c6:	4881                	li	a7,0
ffffffffc02005c8:	00000073          	ecall
ffffffffc02005cc:	8082                	ret

ffffffffc02005ce <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc02005ce:	8082                	ret

ffffffffc02005d0 <cons_putc>:
#include <sched.h>
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005d0:	100027f3          	csrr	a5,sstatus
ffffffffc02005d4:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc02005d6:	0ff57513          	zext.b	a0,a0
ffffffffc02005da:	e799                	bnez	a5,ffffffffc02005e8 <cons_putc+0x18>
ffffffffc02005dc:	4581                	li	a1,0
ffffffffc02005de:	4601                	li	a2,0
ffffffffc02005e0:	4885                	li	a7,1
ffffffffc02005e2:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc02005e6:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc02005e8:	1101                	addi	sp,sp,-32
ffffffffc02005ea:	ec06                	sd	ra,24(sp)
ffffffffc02005ec:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02005ee:	05a000ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc02005f2:	6522                	ld	a0,8(sp)
ffffffffc02005f4:	4581                	li	a1,0
ffffffffc02005f6:	4601                	li	a2,0
ffffffffc02005f8:	4885                	li	a7,1
ffffffffc02005fa:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02005fe:	60e2                	ld	ra,24(sp)
ffffffffc0200600:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200602:	a081                	j	ffffffffc0200642 <intr_enable>

ffffffffc0200604 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200604:	100027f3          	csrr	a5,sstatus
ffffffffc0200608:	8b89                	andi	a5,a5,2
ffffffffc020060a:	eb89                	bnez	a5,ffffffffc020061c <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc020060c:	4501                	li	a0,0
ffffffffc020060e:	4581                	li	a1,0
ffffffffc0200610:	4601                	li	a2,0
ffffffffc0200612:	4889                	li	a7,2
ffffffffc0200614:	00000073          	ecall
ffffffffc0200618:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc020061a:	8082                	ret
int cons_getc(void) {
ffffffffc020061c:	1101                	addi	sp,sp,-32
ffffffffc020061e:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200620:	028000ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc0200624:	4501                	li	a0,0
ffffffffc0200626:	4581                	li	a1,0
ffffffffc0200628:	4601                	li	a2,0
ffffffffc020062a:	4889                	li	a7,2
ffffffffc020062c:	00000073          	ecall
ffffffffc0200630:	2501                	sext.w	a0,a0
ffffffffc0200632:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200634:	00e000ef          	jal	ra,ffffffffc0200642 <intr_enable>
}
ffffffffc0200638:	60e2                	ld	ra,24(sp)
ffffffffc020063a:	6522                	ld	a0,8(sp)
ffffffffc020063c:	6105                	addi	sp,sp,32
ffffffffc020063e:	8082                	ret

ffffffffc0200640 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc0200640:	8082                	ret

ffffffffc0200642 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200642:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200646:	8082                	ret

ffffffffc0200648 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200648:	100177f3          	csrrci	a5,sstatus,2
ffffffffc020064c:	8082                	ret

ffffffffc020064e <idt_init>:
void
idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020064e:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200652:	00000797          	auipc	a5,0x0
ffffffffc0200656:	65a78793          	addi	a5,a5,1626 # ffffffffc0200cac <__alltraps>
ffffffffc020065a:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020065e:	000407b7          	lui	a5,0x40
ffffffffc0200662:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200666:	8082                	ret

ffffffffc0200668 <print_regs>:
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs* gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200668:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs* gpr) {
ffffffffc020066a:	1141                	addi	sp,sp,-16
ffffffffc020066c:	e022                	sd	s0,0(sp)
ffffffffc020066e:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200670:	00006517          	auipc	a0,0x6
ffffffffc0200674:	41050513          	addi	a0,a0,1040 # ffffffffc0206a80 <commands+0x68>
void print_regs(struct pushregs* gpr) {
ffffffffc0200678:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020067a:	a53ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020067e:	640c                	ld	a1,8(s0)
ffffffffc0200680:	00006517          	auipc	a0,0x6
ffffffffc0200684:	41850513          	addi	a0,a0,1048 # ffffffffc0206a98 <commands+0x80>
ffffffffc0200688:	a45ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020068c:	680c                	ld	a1,16(s0)
ffffffffc020068e:	00006517          	auipc	a0,0x6
ffffffffc0200692:	42250513          	addi	a0,a0,1058 # ffffffffc0206ab0 <commands+0x98>
ffffffffc0200696:	a37ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc020069a:	6c0c                	ld	a1,24(s0)
ffffffffc020069c:	00006517          	auipc	a0,0x6
ffffffffc02006a0:	42c50513          	addi	a0,a0,1068 # ffffffffc0206ac8 <commands+0xb0>
ffffffffc02006a4:	a29ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006a8:	700c                	ld	a1,32(s0)
ffffffffc02006aa:	00006517          	auipc	a0,0x6
ffffffffc02006ae:	43650513          	addi	a0,a0,1078 # ffffffffc0206ae0 <commands+0xc8>
ffffffffc02006b2:	a1bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006b6:	740c                	ld	a1,40(s0)
ffffffffc02006b8:	00006517          	auipc	a0,0x6
ffffffffc02006bc:	44050513          	addi	a0,a0,1088 # ffffffffc0206af8 <commands+0xe0>
ffffffffc02006c0:	a0dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006c4:	780c                	ld	a1,48(s0)
ffffffffc02006c6:	00006517          	auipc	a0,0x6
ffffffffc02006ca:	44a50513          	addi	a0,a0,1098 # ffffffffc0206b10 <commands+0xf8>
ffffffffc02006ce:	9ffff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006d2:	7c0c                	ld	a1,56(s0)
ffffffffc02006d4:	00006517          	auipc	a0,0x6
ffffffffc02006d8:	45450513          	addi	a0,a0,1108 # ffffffffc0206b28 <commands+0x110>
ffffffffc02006dc:	9f1ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006e0:	602c                	ld	a1,64(s0)
ffffffffc02006e2:	00006517          	auipc	a0,0x6
ffffffffc02006e6:	45e50513          	addi	a0,a0,1118 # ffffffffc0206b40 <commands+0x128>
ffffffffc02006ea:	9e3ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006ee:	642c                	ld	a1,72(s0)
ffffffffc02006f0:	00006517          	auipc	a0,0x6
ffffffffc02006f4:	46850513          	addi	a0,a0,1128 # ffffffffc0206b58 <commands+0x140>
ffffffffc02006f8:	9d5ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006fc:	682c                	ld	a1,80(s0)
ffffffffc02006fe:	00006517          	auipc	a0,0x6
ffffffffc0200702:	47250513          	addi	a0,a0,1138 # ffffffffc0206b70 <commands+0x158>
ffffffffc0200706:	9c7ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020070a:	6c2c                	ld	a1,88(s0)
ffffffffc020070c:	00006517          	auipc	a0,0x6
ffffffffc0200710:	47c50513          	addi	a0,a0,1148 # ffffffffc0206b88 <commands+0x170>
ffffffffc0200714:	9b9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200718:	702c                	ld	a1,96(s0)
ffffffffc020071a:	00006517          	auipc	a0,0x6
ffffffffc020071e:	48650513          	addi	a0,a0,1158 # ffffffffc0206ba0 <commands+0x188>
ffffffffc0200722:	9abff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200726:	742c                	ld	a1,104(s0)
ffffffffc0200728:	00006517          	auipc	a0,0x6
ffffffffc020072c:	49050513          	addi	a0,a0,1168 # ffffffffc0206bb8 <commands+0x1a0>
ffffffffc0200730:	99dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200734:	782c                	ld	a1,112(s0)
ffffffffc0200736:	00006517          	auipc	a0,0x6
ffffffffc020073a:	49a50513          	addi	a0,a0,1178 # ffffffffc0206bd0 <commands+0x1b8>
ffffffffc020073e:	98fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200742:	7c2c                	ld	a1,120(s0)
ffffffffc0200744:	00006517          	auipc	a0,0x6
ffffffffc0200748:	4a450513          	addi	a0,a0,1188 # ffffffffc0206be8 <commands+0x1d0>
ffffffffc020074c:	981ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200750:	604c                	ld	a1,128(s0)
ffffffffc0200752:	00006517          	auipc	a0,0x6
ffffffffc0200756:	4ae50513          	addi	a0,a0,1198 # ffffffffc0206c00 <commands+0x1e8>
ffffffffc020075a:	973ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020075e:	644c                	ld	a1,136(s0)
ffffffffc0200760:	00006517          	auipc	a0,0x6
ffffffffc0200764:	4b850513          	addi	a0,a0,1208 # ffffffffc0206c18 <commands+0x200>
ffffffffc0200768:	965ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020076c:	684c                	ld	a1,144(s0)
ffffffffc020076e:	00006517          	auipc	a0,0x6
ffffffffc0200772:	4c250513          	addi	a0,a0,1218 # ffffffffc0206c30 <commands+0x218>
ffffffffc0200776:	957ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020077a:	6c4c                	ld	a1,152(s0)
ffffffffc020077c:	00006517          	auipc	a0,0x6
ffffffffc0200780:	4cc50513          	addi	a0,a0,1228 # ffffffffc0206c48 <commands+0x230>
ffffffffc0200784:	949ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200788:	704c                	ld	a1,160(s0)
ffffffffc020078a:	00006517          	auipc	a0,0x6
ffffffffc020078e:	4d650513          	addi	a0,a0,1238 # ffffffffc0206c60 <commands+0x248>
ffffffffc0200792:	93bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200796:	744c                	ld	a1,168(s0)
ffffffffc0200798:	00006517          	auipc	a0,0x6
ffffffffc020079c:	4e050513          	addi	a0,a0,1248 # ffffffffc0206c78 <commands+0x260>
ffffffffc02007a0:	92dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007a4:	784c                	ld	a1,176(s0)
ffffffffc02007a6:	00006517          	auipc	a0,0x6
ffffffffc02007aa:	4ea50513          	addi	a0,a0,1258 # ffffffffc0206c90 <commands+0x278>
ffffffffc02007ae:	91fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007b2:	7c4c                	ld	a1,184(s0)
ffffffffc02007b4:	00006517          	auipc	a0,0x6
ffffffffc02007b8:	4f450513          	addi	a0,a0,1268 # ffffffffc0206ca8 <commands+0x290>
ffffffffc02007bc:	911ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007c0:	606c                	ld	a1,192(s0)
ffffffffc02007c2:	00006517          	auipc	a0,0x6
ffffffffc02007c6:	4fe50513          	addi	a0,a0,1278 # ffffffffc0206cc0 <commands+0x2a8>
ffffffffc02007ca:	903ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007ce:	646c                	ld	a1,200(s0)
ffffffffc02007d0:	00006517          	auipc	a0,0x6
ffffffffc02007d4:	50850513          	addi	a0,a0,1288 # ffffffffc0206cd8 <commands+0x2c0>
ffffffffc02007d8:	8f5ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007dc:	686c                	ld	a1,208(s0)
ffffffffc02007de:	00006517          	auipc	a0,0x6
ffffffffc02007e2:	51250513          	addi	a0,a0,1298 # ffffffffc0206cf0 <commands+0x2d8>
ffffffffc02007e6:	8e7ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007ea:	6c6c                	ld	a1,216(s0)
ffffffffc02007ec:	00006517          	auipc	a0,0x6
ffffffffc02007f0:	51c50513          	addi	a0,a0,1308 # ffffffffc0206d08 <commands+0x2f0>
ffffffffc02007f4:	8d9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007f8:	706c                	ld	a1,224(s0)
ffffffffc02007fa:	00006517          	auipc	a0,0x6
ffffffffc02007fe:	52650513          	addi	a0,a0,1318 # ffffffffc0206d20 <commands+0x308>
ffffffffc0200802:	8cbff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200806:	746c                	ld	a1,232(s0)
ffffffffc0200808:	00006517          	auipc	a0,0x6
ffffffffc020080c:	53050513          	addi	a0,a0,1328 # ffffffffc0206d38 <commands+0x320>
ffffffffc0200810:	8bdff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200814:	786c                	ld	a1,240(s0)
ffffffffc0200816:	00006517          	auipc	a0,0x6
ffffffffc020081a:	53a50513          	addi	a0,a0,1338 # ffffffffc0206d50 <commands+0x338>
ffffffffc020081e:	8afff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200822:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200824:	6402                	ld	s0,0(sp)
ffffffffc0200826:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200828:	00006517          	auipc	a0,0x6
ffffffffc020082c:	54050513          	addi	a0,a0,1344 # ffffffffc0206d68 <commands+0x350>
}
ffffffffc0200830:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200832:	89bff06f          	j	ffffffffc02000cc <cprintf>

ffffffffc0200836 <print_trapframe>:
print_trapframe(struct trapframe *tf) {
ffffffffc0200836:	1141                	addi	sp,sp,-16
ffffffffc0200838:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020083a:	85aa                	mv	a1,a0
print_trapframe(struct trapframe *tf) {
ffffffffc020083c:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020083e:	00006517          	auipc	a0,0x6
ffffffffc0200842:	54250513          	addi	a0,a0,1346 # ffffffffc0206d80 <commands+0x368>
print_trapframe(struct trapframe *tf) {
ffffffffc0200846:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200848:	885ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    print_regs(&tf->gpr);
ffffffffc020084c:	8522                	mv	a0,s0
ffffffffc020084e:	e1bff0ef          	jal	ra,ffffffffc0200668 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200852:	10043583          	ld	a1,256(s0)
ffffffffc0200856:	00006517          	auipc	a0,0x6
ffffffffc020085a:	54250513          	addi	a0,a0,1346 # ffffffffc0206d98 <commands+0x380>
ffffffffc020085e:	86fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200862:	10843583          	ld	a1,264(s0)
ffffffffc0200866:	00006517          	auipc	a0,0x6
ffffffffc020086a:	54a50513          	addi	a0,a0,1354 # ffffffffc0206db0 <commands+0x398>
ffffffffc020086e:	85fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200872:	11043583          	ld	a1,272(s0)
ffffffffc0200876:	00006517          	auipc	a0,0x6
ffffffffc020087a:	55250513          	addi	a0,a0,1362 # ffffffffc0206dc8 <commands+0x3b0>
ffffffffc020087e:	84fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200882:	11843583          	ld	a1,280(s0)
}
ffffffffc0200886:	6402                	ld	s0,0(sp)
ffffffffc0200888:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020088a:	00006517          	auipc	a0,0x6
ffffffffc020088e:	54e50513          	addi	a0,a0,1358 # ffffffffc0206dd8 <commands+0x3c0>
}
ffffffffc0200892:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200894:	839ff06f          	j	ffffffffc02000cc <cprintf>

ffffffffc0200898 <pgfault_handler>:
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int
pgfault_handler(struct trapframe *tf) {
ffffffffc0200898:	1101                	addi	sp,sp,-32
ffffffffc020089a:	e426                	sd	s1,8(sp)
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc020089c:	000b2497          	auipc	s1,0xb2
ffffffffc02008a0:	02448493          	addi	s1,s1,36 # ffffffffc02b28c0 <check_mm_struct>
ffffffffc02008a4:	609c                	ld	a5,0(s1)
pgfault_handler(struct trapframe *tf) {
ffffffffc02008a6:	e822                	sd	s0,16(sp)
ffffffffc02008a8:	ec06                	sd	ra,24(sp)
ffffffffc02008aa:	842a                	mv	s0,a0
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008ac:	cbad                	beqz	a5,ffffffffc020091e <pgfault_handler+0x86>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008ae:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008b2:	11053583          	ld	a1,272(a0)
ffffffffc02008b6:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008ba:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008be:	c7b1                	beqz	a5,ffffffffc020090a <pgfault_handler+0x72>
ffffffffc02008c0:	11843703          	ld	a4,280(s0)
ffffffffc02008c4:	47bd                	li	a5,15
ffffffffc02008c6:	05700693          	li	a3,87
ffffffffc02008ca:	00f70463          	beq	a4,a5,ffffffffc02008d2 <pgfault_handler+0x3a>
ffffffffc02008ce:	05200693          	li	a3,82
ffffffffc02008d2:	00006517          	auipc	a0,0x6
ffffffffc02008d6:	51e50513          	addi	a0,a0,1310 # ffffffffc0206df0 <commands+0x3d8>
ffffffffc02008da:	ff2ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008de:	6088                	ld	a0,0(s1)
ffffffffc02008e0:	cd1d                	beqz	a0,ffffffffc020091e <pgfault_handler+0x86>
        assert(current == idleproc);
ffffffffc02008e2:	000b2717          	auipc	a4,0xb2
ffffffffc02008e6:	03e73703          	ld	a4,62(a4) # ffffffffc02b2920 <current>
ffffffffc02008ea:	000b2797          	auipc	a5,0xb2
ffffffffc02008ee:	03e7b783          	ld	a5,62(a5) # ffffffffc02b2928 <idleproc>
ffffffffc02008f2:	04f71663          	bne	a4,a5,ffffffffc020093e <pgfault_handler+0xa6>
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc02008f6:	11043603          	ld	a2,272(s0)
ffffffffc02008fa:	11843583          	ld	a1,280(s0)
}
ffffffffc02008fe:	6442                	ld	s0,16(sp)
ffffffffc0200900:	60e2                	ld	ra,24(sp)
ffffffffc0200902:	64a2                	ld	s1,8(sp)
ffffffffc0200904:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200906:	6210006f          	j	ffffffffc0201726 <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020090a:	11843703          	ld	a4,280(s0)
ffffffffc020090e:	47bd                	li	a5,15
ffffffffc0200910:	05500613          	li	a2,85
ffffffffc0200914:	05700693          	li	a3,87
ffffffffc0200918:	faf71be3          	bne	a4,a5,ffffffffc02008ce <pgfault_handler+0x36>
ffffffffc020091c:	bf5d                	j	ffffffffc02008d2 <pgfault_handler+0x3a>
        if (current == NULL) {
ffffffffc020091e:	000b2797          	auipc	a5,0xb2
ffffffffc0200922:	0027b783          	ld	a5,2(a5) # ffffffffc02b2920 <current>
ffffffffc0200926:	cf85                	beqz	a5,ffffffffc020095e <pgfault_handler+0xc6>
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200928:	11043603          	ld	a2,272(s0)
ffffffffc020092c:	11843583          	ld	a1,280(s0)
}
ffffffffc0200930:	6442                	ld	s0,16(sp)
ffffffffc0200932:	60e2                	ld	ra,24(sp)
ffffffffc0200934:	64a2                	ld	s1,8(sp)
        mm = current->mm;
ffffffffc0200936:	7788                	ld	a0,40(a5)
}
ffffffffc0200938:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020093a:	5ed0006f          	j	ffffffffc0201726 <do_pgfault>
        assert(current == idleproc);
ffffffffc020093e:	00006697          	auipc	a3,0x6
ffffffffc0200942:	4d268693          	addi	a3,a3,1234 # ffffffffc0206e10 <commands+0x3f8>
ffffffffc0200946:	00006617          	auipc	a2,0x6
ffffffffc020094a:	4e260613          	addi	a2,a2,1250 # ffffffffc0206e28 <commands+0x410>
ffffffffc020094e:	06b00593          	li	a1,107
ffffffffc0200952:	00006517          	auipc	a0,0x6
ffffffffc0200956:	4ee50513          	addi	a0,a0,1262 # ffffffffc0206e40 <commands+0x428>
ffffffffc020095a:	8afff0ef          	jal	ra,ffffffffc0200208 <__panic>
            print_trapframe(tf);
ffffffffc020095e:	8522                	mv	a0,s0
ffffffffc0200960:	ed7ff0ef          	jal	ra,ffffffffc0200836 <print_trapframe>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200964:	10043783          	ld	a5,256(s0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200968:	11043583          	ld	a1,272(s0)
ffffffffc020096c:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200970:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200974:	e399                	bnez	a5,ffffffffc020097a <pgfault_handler+0xe2>
ffffffffc0200976:	05500613          	li	a2,85
ffffffffc020097a:	11843703          	ld	a4,280(s0)
ffffffffc020097e:	47bd                	li	a5,15
ffffffffc0200980:	02f70663          	beq	a4,a5,ffffffffc02009ac <pgfault_handler+0x114>
ffffffffc0200984:	05200693          	li	a3,82
ffffffffc0200988:	00006517          	auipc	a0,0x6
ffffffffc020098c:	46850513          	addi	a0,a0,1128 # ffffffffc0206df0 <commands+0x3d8>
ffffffffc0200990:	f3cff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            panic("unhandled page fault.\n");
ffffffffc0200994:	00006617          	auipc	a2,0x6
ffffffffc0200998:	4c460613          	addi	a2,a2,1220 # ffffffffc0206e58 <commands+0x440>
ffffffffc020099c:	07200593          	li	a1,114
ffffffffc02009a0:	00006517          	auipc	a0,0x6
ffffffffc02009a4:	4a050513          	addi	a0,a0,1184 # ffffffffc0206e40 <commands+0x428>
ffffffffc02009a8:	861ff0ef          	jal	ra,ffffffffc0200208 <__panic>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02009ac:	05700693          	li	a3,87
ffffffffc02009b0:	bfe1                	j	ffffffffc0200988 <pgfault_handler+0xf0>

ffffffffc02009b2 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02009b2:	11853783          	ld	a5,280(a0)
ffffffffc02009b6:	472d                	li	a4,11
ffffffffc02009b8:	0786                	slli	a5,a5,0x1
ffffffffc02009ba:	8385                	srli	a5,a5,0x1
ffffffffc02009bc:	08f76363          	bltu	a4,a5,ffffffffc0200a42 <interrupt_handler+0x90>
ffffffffc02009c0:	00006717          	auipc	a4,0x6
ffffffffc02009c4:	55070713          	addi	a4,a4,1360 # ffffffffc0206f10 <commands+0x4f8>
ffffffffc02009c8:	078a                	slli	a5,a5,0x2
ffffffffc02009ca:	97ba                	add	a5,a5,a4
ffffffffc02009cc:	439c                	lw	a5,0(a5)
ffffffffc02009ce:	97ba                	add	a5,a5,a4
ffffffffc02009d0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009d2:	00006517          	auipc	a0,0x6
ffffffffc02009d6:	4fe50513          	addi	a0,a0,1278 # ffffffffc0206ed0 <commands+0x4b8>
ffffffffc02009da:	ef2ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009de:	00006517          	auipc	a0,0x6
ffffffffc02009e2:	4d250513          	addi	a0,a0,1234 # ffffffffc0206eb0 <commands+0x498>
ffffffffc02009e6:	ee6ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02009ea:	00006517          	auipc	a0,0x6
ffffffffc02009ee:	48650513          	addi	a0,a0,1158 # ffffffffc0206e70 <commands+0x458>
ffffffffc02009f2:	edaff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02009f6:	00006517          	auipc	a0,0x6
ffffffffc02009fa:	49a50513          	addi	a0,a0,1178 # ffffffffc0206e90 <commands+0x478>
ffffffffc02009fe:	eceff06f          	j	ffffffffc02000cc <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200a02:	1141                	addi	sp,sp,-16
ffffffffc0200a04:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc0200a06:	bafff0ef          	jal	ra,ffffffffc02005b4 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 && current) {
ffffffffc0200a0a:	000b2697          	auipc	a3,0xb2
ffffffffc0200a0e:	ea668693          	addi	a3,a3,-346 # ffffffffc02b28b0 <ticks>
ffffffffc0200a12:	629c                	ld	a5,0(a3)
ffffffffc0200a14:	06400713          	li	a4,100
ffffffffc0200a18:	0785                	addi	a5,a5,1
ffffffffc0200a1a:	02e7f733          	remu	a4,a5,a4
ffffffffc0200a1e:	e29c                	sd	a5,0(a3)
ffffffffc0200a20:	eb01                	bnez	a4,ffffffffc0200a30 <interrupt_handler+0x7e>
ffffffffc0200a22:	000b2797          	auipc	a5,0xb2
ffffffffc0200a26:	efe7b783          	ld	a5,-258(a5) # ffffffffc02b2920 <current>
ffffffffc0200a2a:	c399                	beqz	a5,ffffffffc0200a30 <interrupt_handler+0x7e>
                // print_ticks();
                current->need_resched = 1;
ffffffffc0200a2c:	4705                	li	a4,1
ffffffffc0200a2e:	ef98                	sd	a4,24(a5)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a30:	60a2                	ld	ra,8(sp)
ffffffffc0200a32:	0141                	addi	sp,sp,16
ffffffffc0200a34:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a36:	00006517          	auipc	a0,0x6
ffffffffc0200a3a:	4ba50513          	addi	a0,a0,1210 # ffffffffc0206ef0 <commands+0x4d8>
ffffffffc0200a3e:	e8eff06f          	j	ffffffffc02000cc <cprintf>
            print_trapframe(tf);
ffffffffc0200a42:	bbd5                	j	ffffffffc0200836 <print_trapframe>

ffffffffc0200a44 <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a44:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a48:	1101                	addi	sp,sp,-32
ffffffffc0200a4a:	e822                	sd	s0,16(sp)
ffffffffc0200a4c:	ec06                	sd	ra,24(sp)
ffffffffc0200a4e:	e426                	sd	s1,8(sp)
ffffffffc0200a50:	473d                	li	a4,15
ffffffffc0200a52:	842a                	mv	s0,a0
ffffffffc0200a54:	18f76563          	bltu	a4,a5,ffffffffc0200bde <exception_handler+0x19a>
ffffffffc0200a58:	00006717          	auipc	a4,0x6
ffffffffc0200a5c:	68070713          	addi	a4,a4,1664 # ffffffffc02070d8 <commands+0x6c0>
ffffffffc0200a60:	078a                	slli	a5,a5,0x2
ffffffffc0200a62:	97ba                	add	a5,a5,a4
ffffffffc0200a64:	439c                	lw	a5,0(a5)
ffffffffc0200a66:	97ba                	add	a5,a5,a4
ffffffffc0200a68:	8782                	jr	a5
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a6a:	00006517          	auipc	a0,0x6
ffffffffc0200a6e:	5c650513          	addi	a0,a0,1478 # ffffffffc0207030 <commands+0x618>
ffffffffc0200a72:	e5aff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            tf->epc += 4;
ffffffffc0200a76:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a7a:	60e2                	ld	ra,24(sp)
ffffffffc0200a7c:	64a2                	ld	s1,8(sp)
            tf->epc += 4;
ffffffffc0200a7e:	0791                	addi	a5,a5,4
ffffffffc0200a80:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200a84:	6442                	ld	s0,16(sp)
ffffffffc0200a86:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200a88:	7be0506f          	j	ffffffffc0206246 <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a8c:	00006517          	auipc	a0,0x6
ffffffffc0200a90:	5c450513          	addi	a0,a0,1476 # ffffffffc0207050 <commands+0x638>
}
ffffffffc0200a94:	6442                	ld	s0,16(sp)
ffffffffc0200a96:	60e2                	ld	ra,24(sp)
ffffffffc0200a98:	64a2                	ld	s1,8(sp)
ffffffffc0200a9a:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200a9c:	e30ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200aa0:	00006517          	auipc	a0,0x6
ffffffffc0200aa4:	5d050513          	addi	a0,a0,1488 # ffffffffc0207070 <commands+0x658>
ffffffffc0200aa8:	b7f5                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200aaa:	00006517          	auipc	a0,0x6
ffffffffc0200aae:	5e650513          	addi	a0,a0,1510 # ffffffffc0207090 <commands+0x678>
ffffffffc0200ab2:	b7cd                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200ab4:	00006517          	auipc	a0,0x6
ffffffffc0200ab8:	5f450513          	addi	a0,a0,1524 # ffffffffc02070a8 <commands+0x690>
ffffffffc0200abc:	e10ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ac0:	8522                	mv	a0,s0
ffffffffc0200ac2:	dd7ff0ef          	jal	ra,ffffffffc0200898 <pgfault_handler>
ffffffffc0200ac6:	84aa                	mv	s1,a0
ffffffffc0200ac8:	12051d63          	bnez	a0,ffffffffc0200c02 <exception_handler+0x1be>
}
ffffffffc0200acc:	60e2                	ld	ra,24(sp)
ffffffffc0200ace:	6442                	ld	s0,16(sp)
ffffffffc0200ad0:	64a2                	ld	s1,8(sp)
ffffffffc0200ad2:	6105                	addi	sp,sp,32
ffffffffc0200ad4:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200ad6:	00006517          	auipc	a0,0x6
ffffffffc0200ada:	5ea50513          	addi	a0,a0,1514 # ffffffffc02070c0 <commands+0x6a8>
ffffffffc0200ade:	deeff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ae2:	8522                	mv	a0,s0
ffffffffc0200ae4:	db5ff0ef          	jal	ra,ffffffffc0200898 <pgfault_handler>
ffffffffc0200ae8:	84aa                	mv	s1,a0
ffffffffc0200aea:	d16d                	beqz	a0,ffffffffc0200acc <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200aec:	8522                	mv	a0,s0
ffffffffc0200aee:	d49ff0ef          	jal	ra,ffffffffc0200836 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200af2:	86a6                	mv	a3,s1
ffffffffc0200af4:	00006617          	auipc	a2,0x6
ffffffffc0200af8:	4ec60613          	addi	a2,a2,1260 # ffffffffc0206fe0 <commands+0x5c8>
ffffffffc0200afc:	0f800593          	li	a1,248
ffffffffc0200b00:	00006517          	auipc	a0,0x6
ffffffffc0200b04:	34050513          	addi	a0,a0,832 # ffffffffc0206e40 <commands+0x428>
ffffffffc0200b08:	f00ff0ef          	jal	ra,ffffffffc0200208 <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200b0c:	00006517          	auipc	a0,0x6
ffffffffc0200b10:	43450513          	addi	a0,a0,1076 # ffffffffc0206f40 <commands+0x528>
ffffffffc0200b14:	b741                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200b16:	00006517          	auipc	a0,0x6
ffffffffc0200b1a:	44a50513          	addi	a0,a0,1098 # ffffffffc0206f60 <commands+0x548>
ffffffffc0200b1e:	bf9d                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200b20:	00006517          	auipc	a0,0x6
ffffffffc0200b24:	46050513          	addi	a0,a0,1120 # ffffffffc0206f80 <commands+0x568>
ffffffffc0200b28:	b7b5                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b2a:	00006517          	auipc	a0,0x6
ffffffffc0200b2e:	46e50513          	addi	a0,a0,1134 # ffffffffc0206f98 <commands+0x580>
ffffffffc0200b32:	d9aff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b36:	6458                	ld	a4,136(s0)
ffffffffc0200b38:	47a9                	li	a5,10
ffffffffc0200b3a:	f8f719e3          	bne	a4,a5,ffffffffc0200acc <exception_handler+0x88>
                tf->epc += 4;
ffffffffc0200b3e:	10843783          	ld	a5,264(s0)
ffffffffc0200b42:	0791                	addi	a5,a5,4
ffffffffc0200b44:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200b48:	6fe050ef          	jal	ra,ffffffffc0206246 <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b4c:	000b2797          	auipc	a5,0xb2
ffffffffc0200b50:	dd47b783          	ld	a5,-556(a5) # ffffffffc02b2920 <current>
ffffffffc0200b54:	6b9c                	ld	a5,16(a5)
ffffffffc0200b56:	8522                	mv	a0,s0
}
ffffffffc0200b58:	6442                	ld	s0,16(sp)
ffffffffc0200b5a:	60e2                	ld	ra,24(sp)
ffffffffc0200b5c:	64a2                	ld	s1,8(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b5e:	6589                	lui	a1,0x2
ffffffffc0200b60:	95be                	add	a1,a1,a5
}
ffffffffc0200b62:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b64:	ac19                	j	ffffffffc0200d7a <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200b66:	00006517          	auipc	a0,0x6
ffffffffc0200b6a:	44250513          	addi	a0,a0,1090 # ffffffffc0206fa8 <commands+0x590>
ffffffffc0200b6e:	b71d                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200b70:	00006517          	auipc	a0,0x6
ffffffffc0200b74:	45850513          	addi	a0,a0,1112 # ffffffffc0206fc8 <commands+0x5b0>
ffffffffc0200b78:	d54ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b7c:	8522                	mv	a0,s0
ffffffffc0200b7e:	d1bff0ef          	jal	ra,ffffffffc0200898 <pgfault_handler>
ffffffffc0200b82:	84aa                	mv	s1,a0
ffffffffc0200b84:	d521                	beqz	a0,ffffffffc0200acc <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b86:	8522                	mv	a0,s0
ffffffffc0200b88:	cafff0ef          	jal	ra,ffffffffc0200836 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b8c:	86a6                	mv	a3,s1
ffffffffc0200b8e:	00006617          	auipc	a2,0x6
ffffffffc0200b92:	45260613          	addi	a2,a2,1106 # ffffffffc0206fe0 <commands+0x5c8>
ffffffffc0200b96:	0cd00593          	li	a1,205
ffffffffc0200b9a:	00006517          	auipc	a0,0x6
ffffffffc0200b9e:	2a650513          	addi	a0,a0,678 # ffffffffc0206e40 <commands+0x428>
ffffffffc0200ba2:	e66ff0ef          	jal	ra,ffffffffc0200208 <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200ba6:	00006517          	auipc	a0,0x6
ffffffffc0200baa:	47250513          	addi	a0,a0,1138 # ffffffffc0207018 <commands+0x600>
ffffffffc0200bae:	d1eff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200bb2:	8522                	mv	a0,s0
ffffffffc0200bb4:	ce5ff0ef          	jal	ra,ffffffffc0200898 <pgfault_handler>
ffffffffc0200bb8:	84aa                	mv	s1,a0
ffffffffc0200bba:	f00509e3          	beqz	a0,ffffffffc0200acc <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200bbe:	8522                	mv	a0,s0
ffffffffc0200bc0:	c77ff0ef          	jal	ra,ffffffffc0200836 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bc4:	86a6                	mv	a3,s1
ffffffffc0200bc6:	00006617          	auipc	a2,0x6
ffffffffc0200bca:	41a60613          	addi	a2,a2,1050 # ffffffffc0206fe0 <commands+0x5c8>
ffffffffc0200bce:	0d700593          	li	a1,215
ffffffffc0200bd2:	00006517          	auipc	a0,0x6
ffffffffc0200bd6:	26e50513          	addi	a0,a0,622 # ffffffffc0206e40 <commands+0x428>
ffffffffc0200bda:	e2eff0ef          	jal	ra,ffffffffc0200208 <__panic>
            print_trapframe(tf);
ffffffffc0200bde:	8522                	mv	a0,s0
}
ffffffffc0200be0:	6442                	ld	s0,16(sp)
ffffffffc0200be2:	60e2                	ld	ra,24(sp)
ffffffffc0200be4:	64a2                	ld	s1,8(sp)
ffffffffc0200be6:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200be8:	b1b9                	j	ffffffffc0200836 <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200bea:	00006617          	auipc	a2,0x6
ffffffffc0200bee:	41660613          	addi	a2,a2,1046 # ffffffffc0207000 <commands+0x5e8>
ffffffffc0200bf2:	0d100593          	li	a1,209
ffffffffc0200bf6:	00006517          	auipc	a0,0x6
ffffffffc0200bfa:	24a50513          	addi	a0,a0,586 # ffffffffc0206e40 <commands+0x428>
ffffffffc0200bfe:	e0aff0ef          	jal	ra,ffffffffc0200208 <__panic>
                print_trapframe(tf);
ffffffffc0200c02:	8522                	mv	a0,s0
ffffffffc0200c04:	c33ff0ef          	jal	ra,ffffffffc0200836 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200c08:	86a6                	mv	a3,s1
ffffffffc0200c0a:	00006617          	auipc	a2,0x6
ffffffffc0200c0e:	3d660613          	addi	a2,a2,982 # ffffffffc0206fe0 <commands+0x5c8>
ffffffffc0200c12:	0f100593          	li	a1,241
ffffffffc0200c16:	00006517          	auipc	a0,0x6
ffffffffc0200c1a:	22a50513          	addi	a0,a0,554 # ffffffffc0206e40 <commands+0x428>
ffffffffc0200c1e:	deaff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0200c22 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200c22:	1101                	addi	sp,sp,-32
ffffffffc0200c24:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c26:	000b2417          	auipc	s0,0xb2
ffffffffc0200c2a:	cfa40413          	addi	s0,s0,-774 # ffffffffc02b2920 <current>
ffffffffc0200c2e:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c30:	ec06                	sd	ra,24(sp)
ffffffffc0200c32:	e426                	sd	s1,8(sp)
ffffffffc0200c34:	e04a                	sd	s2,0(sp)
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c36:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c3a:	cf1d                	beqz	a4,ffffffffc0200c78 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c3c:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c40:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c44:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c46:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c4a:	0206c463          	bltz	a3,ffffffffc0200c72 <trap+0x50>
        exception_handler(tf);
ffffffffc0200c4e:	df7ff0ef          	jal	ra,ffffffffc0200a44 <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c52:	601c                	ld	a5,0(s0)
ffffffffc0200c54:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200c58:	e499                	bnez	s1,ffffffffc0200c66 <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200c5a:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c5e:	8b05                	andi	a4,a4,1
ffffffffc0200c60:	e329                	bnez	a4,ffffffffc0200ca2 <trap+0x80>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200c62:	6f9c                	ld	a5,24(a5)
ffffffffc0200c64:	eb85                	bnez	a5,ffffffffc0200c94 <trap+0x72>
                schedule();
            }
        }
    }
}
ffffffffc0200c66:	60e2                	ld	ra,24(sp)
ffffffffc0200c68:	6442                	ld	s0,16(sp)
ffffffffc0200c6a:	64a2                	ld	s1,8(sp)
ffffffffc0200c6c:	6902                	ld	s2,0(sp)
ffffffffc0200c6e:	6105                	addi	sp,sp,32
ffffffffc0200c70:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200c72:	d41ff0ef          	jal	ra,ffffffffc02009b2 <interrupt_handler>
ffffffffc0200c76:	bff1                	j	ffffffffc0200c52 <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c78:	0006c863          	bltz	a3,ffffffffc0200c88 <trap+0x66>
}
ffffffffc0200c7c:	6442                	ld	s0,16(sp)
ffffffffc0200c7e:	60e2                	ld	ra,24(sp)
ffffffffc0200c80:	64a2                	ld	s1,8(sp)
ffffffffc0200c82:	6902                	ld	s2,0(sp)
ffffffffc0200c84:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200c86:	bb7d                	j	ffffffffc0200a44 <exception_handler>
}
ffffffffc0200c88:	6442                	ld	s0,16(sp)
ffffffffc0200c8a:	60e2                	ld	ra,24(sp)
ffffffffc0200c8c:	64a2                	ld	s1,8(sp)
ffffffffc0200c8e:	6902                	ld	s2,0(sp)
ffffffffc0200c90:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200c92:	b305                	j	ffffffffc02009b2 <interrupt_handler>
}
ffffffffc0200c94:	6442                	ld	s0,16(sp)
ffffffffc0200c96:	60e2                	ld	ra,24(sp)
ffffffffc0200c98:	64a2                	ld	s1,8(sp)
ffffffffc0200c9a:	6902                	ld	s2,0(sp)
ffffffffc0200c9c:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200c9e:	4bc0506f          	j	ffffffffc020615a <schedule>
                do_exit(-E_KILLED);
ffffffffc0200ca2:	555d                	li	a0,-9
ffffffffc0200ca4:	067040ef          	jal	ra,ffffffffc020550a <do_exit>
            if (current->need_resched) {
ffffffffc0200ca8:	601c                	ld	a5,0(s0)
ffffffffc0200caa:	bf65                	j	ffffffffc0200c62 <trap+0x40>

ffffffffc0200cac <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200cac:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200cb0:	00011463          	bnez	sp,ffffffffc0200cb8 <__alltraps+0xc>
ffffffffc0200cb4:	14002173          	csrr	sp,sscratch
ffffffffc0200cb8:	712d                	addi	sp,sp,-288
ffffffffc0200cba:	e002                	sd	zero,0(sp)
ffffffffc0200cbc:	e406                	sd	ra,8(sp)
ffffffffc0200cbe:	ec0e                	sd	gp,24(sp)
ffffffffc0200cc0:	f012                	sd	tp,32(sp)
ffffffffc0200cc2:	f416                	sd	t0,40(sp)
ffffffffc0200cc4:	f81a                	sd	t1,48(sp)
ffffffffc0200cc6:	fc1e                	sd	t2,56(sp)
ffffffffc0200cc8:	e0a2                	sd	s0,64(sp)
ffffffffc0200cca:	e4a6                	sd	s1,72(sp)
ffffffffc0200ccc:	e8aa                	sd	a0,80(sp)
ffffffffc0200cce:	ecae                	sd	a1,88(sp)
ffffffffc0200cd0:	f0b2                	sd	a2,96(sp)
ffffffffc0200cd2:	f4b6                	sd	a3,104(sp)
ffffffffc0200cd4:	f8ba                	sd	a4,112(sp)
ffffffffc0200cd6:	fcbe                	sd	a5,120(sp)
ffffffffc0200cd8:	e142                	sd	a6,128(sp)
ffffffffc0200cda:	e546                	sd	a7,136(sp)
ffffffffc0200cdc:	e94a                	sd	s2,144(sp)
ffffffffc0200cde:	ed4e                	sd	s3,152(sp)
ffffffffc0200ce0:	f152                	sd	s4,160(sp)
ffffffffc0200ce2:	f556                	sd	s5,168(sp)
ffffffffc0200ce4:	f95a                	sd	s6,176(sp)
ffffffffc0200ce6:	fd5e                	sd	s7,184(sp)
ffffffffc0200ce8:	e1e2                	sd	s8,192(sp)
ffffffffc0200cea:	e5e6                	sd	s9,200(sp)
ffffffffc0200cec:	e9ea                	sd	s10,208(sp)
ffffffffc0200cee:	edee                	sd	s11,216(sp)
ffffffffc0200cf0:	f1f2                	sd	t3,224(sp)
ffffffffc0200cf2:	f5f6                	sd	t4,232(sp)
ffffffffc0200cf4:	f9fa                	sd	t5,240(sp)
ffffffffc0200cf6:	fdfe                	sd	t6,248(sp)
ffffffffc0200cf8:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200cfc:	100024f3          	csrr	s1,sstatus
ffffffffc0200d00:	14102973          	csrr	s2,sepc
ffffffffc0200d04:	143029f3          	csrr	s3,stval
ffffffffc0200d08:	14202a73          	csrr	s4,scause
ffffffffc0200d0c:	e822                	sd	s0,16(sp)
ffffffffc0200d0e:	e226                	sd	s1,256(sp)
ffffffffc0200d10:	e64a                	sd	s2,264(sp)
ffffffffc0200d12:	ea4e                	sd	s3,272(sp)
ffffffffc0200d14:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200d16:	850a                	mv	a0,sp
    jal trap
ffffffffc0200d18:	f0bff0ef          	jal	ra,ffffffffc0200c22 <trap>

ffffffffc0200d1c <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200d1c:	6492                	ld	s1,256(sp)
ffffffffc0200d1e:	6932                	ld	s2,264(sp)
ffffffffc0200d20:	1004f413          	andi	s0,s1,256
ffffffffc0200d24:	e401                	bnez	s0,ffffffffc0200d2c <__trapret+0x10>
ffffffffc0200d26:	1200                	addi	s0,sp,288
ffffffffc0200d28:	14041073          	csrw	sscratch,s0
ffffffffc0200d2c:	10049073          	csrw	sstatus,s1
ffffffffc0200d30:	14191073          	csrw	sepc,s2
ffffffffc0200d34:	60a2                	ld	ra,8(sp)
ffffffffc0200d36:	61e2                	ld	gp,24(sp)
ffffffffc0200d38:	7202                	ld	tp,32(sp)
ffffffffc0200d3a:	72a2                	ld	t0,40(sp)
ffffffffc0200d3c:	7342                	ld	t1,48(sp)
ffffffffc0200d3e:	73e2                	ld	t2,56(sp)
ffffffffc0200d40:	6406                	ld	s0,64(sp)
ffffffffc0200d42:	64a6                	ld	s1,72(sp)
ffffffffc0200d44:	6546                	ld	a0,80(sp)
ffffffffc0200d46:	65e6                	ld	a1,88(sp)
ffffffffc0200d48:	7606                	ld	a2,96(sp)
ffffffffc0200d4a:	76a6                	ld	a3,104(sp)
ffffffffc0200d4c:	7746                	ld	a4,112(sp)
ffffffffc0200d4e:	77e6                	ld	a5,120(sp)
ffffffffc0200d50:	680a                	ld	a6,128(sp)
ffffffffc0200d52:	68aa                	ld	a7,136(sp)
ffffffffc0200d54:	694a                	ld	s2,144(sp)
ffffffffc0200d56:	69ea                	ld	s3,152(sp)
ffffffffc0200d58:	7a0a                	ld	s4,160(sp)
ffffffffc0200d5a:	7aaa                	ld	s5,168(sp)
ffffffffc0200d5c:	7b4a                	ld	s6,176(sp)
ffffffffc0200d5e:	7bea                	ld	s7,184(sp)
ffffffffc0200d60:	6c0e                	ld	s8,192(sp)
ffffffffc0200d62:	6cae                	ld	s9,200(sp)
ffffffffc0200d64:	6d4e                	ld	s10,208(sp)
ffffffffc0200d66:	6dee                	ld	s11,216(sp)
ffffffffc0200d68:	7e0e                	ld	t3,224(sp)
ffffffffc0200d6a:	7eae                	ld	t4,232(sp)
ffffffffc0200d6c:	7f4e                	ld	t5,240(sp)
ffffffffc0200d6e:	7fee                	ld	t6,248(sp)
ffffffffc0200d70:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200d72:	10200073          	sret

ffffffffc0200d76 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200d76:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200d78:	b755                	j	ffffffffc0200d1c <__trapret>

ffffffffc0200d7a <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200d7a:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7ce0>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200d7e:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200d82:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200d86:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200d8a:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200d8e:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200d92:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200d96:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200d9a:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200d9e:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200da0:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200da2:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200da4:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200da6:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200da8:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200daa:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200dac:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200dae:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200db0:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200db2:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200db4:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200db6:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200db8:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200dba:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200dbc:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200dbe:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200dc0:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200dc2:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200dc4:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200dc6:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200dc8:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200dca:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200dcc:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200dce:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200dd0:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200dd2:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200dd4:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200dd6:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200dd8:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200dda:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200ddc:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200dde:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200de0:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200de2:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200de4:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200de6:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200de8:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200dea:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200dec:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200dee:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200df0:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200df2:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200df4:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200df6:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200df8:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200dfa:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200dfc:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200dfe:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200e00:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200e02:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200e04:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200e06:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200e08:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200e0a:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200e0c:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200e0e:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200e10:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200e12:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200e14:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200e16:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200e18:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200e1a:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200e1c:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200e1e:	812e                	mv	sp,a1
ffffffffc0200e20:	bdf5                	j	ffffffffc0200d1c <__trapret>

ffffffffc0200e22 <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200e22:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0200e24:	00006697          	auipc	a3,0x6
ffffffffc0200e28:	2f468693          	addi	a3,a3,756 # ffffffffc0207118 <commands+0x700>
ffffffffc0200e2c:	00006617          	auipc	a2,0x6
ffffffffc0200e30:	ffc60613          	addi	a2,a2,-4 # ffffffffc0206e28 <commands+0x410>
ffffffffc0200e34:	06d00593          	li	a1,109
ffffffffc0200e38:	00006517          	auipc	a0,0x6
ffffffffc0200e3c:	30050513          	addi	a0,a0,768 # ffffffffc0207138 <commands+0x720>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200e40:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0200e42:	bc6ff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0200e46 <pa2page.part.0>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
ffffffffc0200e46:	1141                	addi	sp,sp,-16
    if (PPN(pa) >= npage) {
        panic("pa2page called with invalid pa");
ffffffffc0200e48:	00006617          	auipc	a2,0x6
ffffffffc0200e4c:	30060613          	addi	a2,a2,768 # ffffffffc0207148 <commands+0x730>
ffffffffc0200e50:	06200593          	li	a1,98
ffffffffc0200e54:	00006517          	auipc	a0,0x6
ffffffffc0200e58:	31450513          	addi	a0,a0,788 # ffffffffc0207168 <commands+0x750>
pa2page(uintptr_t pa) {
ffffffffc0200e5c:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0200e5e:	baaff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0200e62 <mm_create>:
mm_create(void) {
ffffffffc0200e62:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200e64:	04000513          	li	a0,64
mm_create(void) {
ffffffffc0200e68:	e022                	sd	s0,0(sp)
ffffffffc0200e6a:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200e6c:	66e010ef          	jal	ra,ffffffffc02024da <kmalloc>
ffffffffc0200e70:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0200e72:	c505                	beqz	a0,ffffffffc0200e9a <mm_create+0x38>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200e74:	e408                	sd	a0,8(s0)
ffffffffc0200e76:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0200e78:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200e7c:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200e80:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200e84:	000b2797          	auipc	a5,0xb2
ffffffffc0200e88:	a5c7a783          	lw	a5,-1444(a5) # ffffffffc02b28e0 <swap_init_ok>
ffffffffc0200e8c:	ef81                	bnez	a5,ffffffffc0200ea4 <mm_create+0x42>
        else mm->sm_priv = NULL;
ffffffffc0200e8e:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc0200e92:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc0200e96:	02043c23          	sd	zero,56(s0)
}
ffffffffc0200e9a:	60a2                	ld	ra,8(sp)
ffffffffc0200e9c:	8522                	mv	a0,s0
ffffffffc0200e9e:	6402                	ld	s0,0(sp)
ffffffffc0200ea0:	0141                	addi	sp,sp,16
ffffffffc0200ea2:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200ea4:	25e010ef          	jal	ra,ffffffffc0202102 <swap_init_mm>
ffffffffc0200ea8:	b7ed                	j	ffffffffc0200e92 <mm_create+0x30>

ffffffffc0200eaa <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0200eaa:	1101                	addi	sp,sp,-32
ffffffffc0200eac:	e04a                	sd	s2,0(sp)
ffffffffc0200eae:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200eb0:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0200eb4:	e822                	sd	s0,16(sp)
ffffffffc0200eb6:	e426                	sd	s1,8(sp)
ffffffffc0200eb8:	ec06                	sd	ra,24(sp)
ffffffffc0200eba:	84ae                	mv	s1,a1
ffffffffc0200ebc:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200ebe:	61c010ef          	jal	ra,ffffffffc02024da <kmalloc>
    if (vma != NULL) {
ffffffffc0200ec2:	c509                	beqz	a0,ffffffffc0200ecc <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0200ec4:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200ec8:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200eca:	cd00                	sw	s0,24(a0)
}
ffffffffc0200ecc:	60e2                	ld	ra,24(sp)
ffffffffc0200ece:	6442                	ld	s0,16(sp)
ffffffffc0200ed0:	64a2                	ld	s1,8(sp)
ffffffffc0200ed2:	6902                	ld	s2,0(sp)
ffffffffc0200ed4:	6105                	addi	sp,sp,32
ffffffffc0200ed6:	8082                	ret

ffffffffc0200ed8 <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc0200ed8:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc0200eda:	c505                	beqz	a0,ffffffffc0200f02 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0200edc:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0200ede:	c501                	beqz	a0,ffffffffc0200ee6 <find_vma+0xe>
ffffffffc0200ee0:	651c                	ld	a5,8(a0)
ffffffffc0200ee2:	02f5f263          	bgeu	a1,a5,ffffffffc0200f06 <find_vma+0x2e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200ee6:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc0200ee8:	00f68d63          	beq	a3,a5,ffffffffc0200f02 <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0200eec:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200ef0:	00e5e663          	bltu	a1,a4,ffffffffc0200efc <find_vma+0x24>
ffffffffc0200ef4:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200ef8:	00e5ec63          	bltu	a1,a4,ffffffffc0200f10 <find_vma+0x38>
ffffffffc0200efc:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0200efe:	fef697e3          	bne	a3,a5,ffffffffc0200eec <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0200f02:	4501                	li	a0,0
}
ffffffffc0200f04:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0200f06:	691c                	ld	a5,16(a0)
ffffffffc0200f08:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0200ee6 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0200f0c:	ea88                	sd	a0,16(a3)
ffffffffc0200f0e:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc0200f10:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0200f14:	ea88                	sd	a0,16(a3)
ffffffffc0200f16:	8082                	ret

ffffffffc0200f18 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200f18:	6590                	ld	a2,8(a1)
ffffffffc0200f1a:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0200f1e:	1141                	addi	sp,sp,-16
ffffffffc0200f20:	e406                	sd	ra,8(sp)
ffffffffc0200f22:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200f24:	01066763          	bltu	a2,a6,ffffffffc0200f32 <insert_vma_struct+0x1a>
ffffffffc0200f28:	a085                	j	ffffffffc0200f88 <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0200f2a:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200f2e:	04e66863          	bltu	a2,a4,ffffffffc0200f7e <insert_vma_struct+0x66>
ffffffffc0200f32:	86be                	mv	a3,a5
ffffffffc0200f34:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0200f36:	fef51ae3          	bne	a0,a5,ffffffffc0200f2a <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0200f3a:	02a68463          	beq	a3,a0,ffffffffc0200f62 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0200f3e:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200f42:	fe86b883          	ld	a7,-24(a3)
ffffffffc0200f46:	08e8f163          	bgeu	a7,a4,ffffffffc0200fc8 <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200f4a:	04e66f63          	bltu	a2,a4,ffffffffc0200fa8 <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc0200f4e:	00f50a63          	beq	a0,a5,ffffffffc0200f62 <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0200f52:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200f56:	05076963          	bltu	a4,a6,ffffffffc0200fa8 <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc0200f5a:	ff07b603          	ld	a2,-16(a5)
ffffffffc0200f5e:	02c77363          	bgeu	a4,a2,ffffffffc0200f84 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0200f62:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0200f64:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0200f66:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200f6a:	e390                	sd	a2,0(a5)
ffffffffc0200f6c:	e690                	sd	a2,8(a3)
}
ffffffffc0200f6e:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0200f70:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0200f72:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc0200f74:	0017079b          	addiw	a5,a4,1
ffffffffc0200f78:	d11c                	sw	a5,32(a0)
}
ffffffffc0200f7a:	0141                	addi	sp,sp,16
ffffffffc0200f7c:	8082                	ret
    if (le_prev != list) {
ffffffffc0200f7e:	fca690e3          	bne	a3,a0,ffffffffc0200f3e <insert_vma_struct+0x26>
ffffffffc0200f82:	bfd1                	j	ffffffffc0200f56 <insert_vma_struct+0x3e>
ffffffffc0200f84:	e9fff0ef          	jal	ra,ffffffffc0200e22 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200f88:	00006697          	auipc	a3,0x6
ffffffffc0200f8c:	1f068693          	addi	a3,a3,496 # ffffffffc0207178 <commands+0x760>
ffffffffc0200f90:	00006617          	auipc	a2,0x6
ffffffffc0200f94:	e9860613          	addi	a2,a2,-360 # ffffffffc0206e28 <commands+0x410>
ffffffffc0200f98:	07400593          	li	a1,116
ffffffffc0200f9c:	00006517          	auipc	a0,0x6
ffffffffc0200fa0:	19c50513          	addi	a0,a0,412 # ffffffffc0207138 <commands+0x720>
ffffffffc0200fa4:	a64ff0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200fa8:	00006697          	auipc	a3,0x6
ffffffffc0200fac:	21068693          	addi	a3,a3,528 # ffffffffc02071b8 <commands+0x7a0>
ffffffffc0200fb0:	00006617          	auipc	a2,0x6
ffffffffc0200fb4:	e7860613          	addi	a2,a2,-392 # ffffffffc0206e28 <commands+0x410>
ffffffffc0200fb8:	06c00593          	li	a1,108
ffffffffc0200fbc:	00006517          	auipc	a0,0x6
ffffffffc0200fc0:	17c50513          	addi	a0,a0,380 # ffffffffc0207138 <commands+0x720>
ffffffffc0200fc4:	a44ff0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200fc8:	00006697          	auipc	a3,0x6
ffffffffc0200fcc:	1d068693          	addi	a3,a3,464 # ffffffffc0207198 <commands+0x780>
ffffffffc0200fd0:	00006617          	auipc	a2,0x6
ffffffffc0200fd4:	e5860613          	addi	a2,a2,-424 # ffffffffc0206e28 <commands+0x410>
ffffffffc0200fd8:	06b00593          	li	a1,107
ffffffffc0200fdc:	00006517          	auipc	a0,0x6
ffffffffc0200fe0:	15c50513          	addi	a0,a0,348 # ffffffffc0207138 <commands+0x720>
ffffffffc0200fe4:	a24ff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0200fe8 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc0200fe8:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc0200fea:	1141                	addi	sp,sp,-16
ffffffffc0200fec:	e406                	sd	ra,8(sp)
ffffffffc0200fee:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0200ff0:	e78d                	bnez	a5,ffffffffc020101a <mm_destroy+0x32>
ffffffffc0200ff2:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0200ff4:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0200ff6:	00a40c63          	beq	s0,a0,ffffffffc020100e <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200ffa:	6118                	ld	a4,0(a0)
ffffffffc0200ffc:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0200ffe:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201000:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201002:	e398                	sd	a4,0(a5)
ffffffffc0201004:	586010ef          	jal	ra,ffffffffc020258a <kfree>
    return listelm->next;
ffffffffc0201008:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc020100a:	fea418e3          	bne	s0,a0,ffffffffc0200ffa <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc020100e:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0201010:	6402                	ld	s0,0(sp)
ffffffffc0201012:	60a2                	ld	ra,8(sp)
ffffffffc0201014:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc0201016:	5740106f          	j	ffffffffc020258a <kfree>
    assert(mm_count(mm) == 0);
ffffffffc020101a:	00006697          	auipc	a3,0x6
ffffffffc020101e:	1be68693          	addi	a3,a3,446 # ffffffffc02071d8 <commands+0x7c0>
ffffffffc0201022:	00006617          	auipc	a2,0x6
ffffffffc0201026:	e0660613          	addi	a2,a2,-506 # ffffffffc0206e28 <commands+0x410>
ffffffffc020102a:	09400593          	li	a1,148
ffffffffc020102e:	00006517          	auipc	a0,0x6
ffffffffc0201032:	10a50513          	addi	a0,a0,266 # ffffffffc0207138 <commands+0x720>
ffffffffc0201036:	9d2ff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020103a <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
ffffffffc020103a:	7139                	addi	sp,sp,-64
ffffffffc020103c:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020103e:	6405                	lui	s0,0x1
ffffffffc0201040:	147d                	addi	s0,s0,-1
ffffffffc0201042:	77fd                	lui	a5,0xfffff
ffffffffc0201044:	9622                	add	a2,a2,s0
ffffffffc0201046:	962e                	add	a2,a2,a1
       struct vma_struct **vma_store) {
ffffffffc0201048:	f426                	sd	s1,40(sp)
ffffffffc020104a:	fc06                	sd	ra,56(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020104c:	00f5f4b3          	and	s1,a1,a5
       struct vma_struct **vma_store) {
ffffffffc0201050:	f04a                	sd	s2,32(sp)
ffffffffc0201052:	ec4e                	sd	s3,24(sp)
ffffffffc0201054:	e852                	sd	s4,16(sp)
ffffffffc0201056:	e456                	sd	s5,8(sp)
    if (!USER_ACCESS(start, end)) {
ffffffffc0201058:	002005b7          	lui	a1,0x200
ffffffffc020105c:	00f67433          	and	s0,a2,a5
ffffffffc0201060:	06b4e363          	bltu	s1,a1,ffffffffc02010c6 <mm_map+0x8c>
ffffffffc0201064:	0684f163          	bgeu	s1,s0,ffffffffc02010c6 <mm_map+0x8c>
ffffffffc0201068:	4785                	li	a5,1
ffffffffc020106a:	07fe                	slli	a5,a5,0x1f
ffffffffc020106c:	0487ed63          	bltu	a5,s0,ffffffffc02010c6 <mm_map+0x8c>
ffffffffc0201070:	89aa                	mv	s3,a0
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc0201072:	cd21                	beqz	a0,ffffffffc02010ca <mm_map+0x90>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc0201074:	85a6                	mv	a1,s1
ffffffffc0201076:	8ab6                	mv	s5,a3
ffffffffc0201078:	8a3a                	mv	s4,a4
ffffffffc020107a:	e5fff0ef          	jal	ra,ffffffffc0200ed8 <find_vma>
ffffffffc020107e:	c501                	beqz	a0,ffffffffc0201086 <mm_map+0x4c>
ffffffffc0201080:	651c                	ld	a5,8(a0)
ffffffffc0201082:	0487e263          	bltu	a5,s0,ffffffffc02010c6 <mm_map+0x8c>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201086:	03000513          	li	a0,48
ffffffffc020108a:	450010ef          	jal	ra,ffffffffc02024da <kmalloc>
ffffffffc020108e:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc0201090:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc0201092:	02090163          	beqz	s2,ffffffffc02010b4 <mm_map+0x7a>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc0201096:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc0201098:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc020109c:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc02010a0:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc02010a4:	85ca                	mv	a1,s2
ffffffffc02010a6:	e73ff0ef          	jal	ra,ffffffffc0200f18 <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc02010aa:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc02010ac:	000a0463          	beqz	s4,ffffffffc02010b4 <mm_map+0x7a>
        *vma_store = vma;
ffffffffc02010b0:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc02010b4:	70e2                	ld	ra,56(sp)
ffffffffc02010b6:	7442                	ld	s0,48(sp)
ffffffffc02010b8:	74a2                	ld	s1,40(sp)
ffffffffc02010ba:	7902                	ld	s2,32(sp)
ffffffffc02010bc:	69e2                	ld	s3,24(sp)
ffffffffc02010be:	6a42                	ld	s4,16(sp)
ffffffffc02010c0:	6aa2                	ld	s5,8(sp)
ffffffffc02010c2:	6121                	addi	sp,sp,64
ffffffffc02010c4:	8082                	ret
        return -E_INVAL;
ffffffffc02010c6:	5575                	li	a0,-3
ffffffffc02010c8:	b7f5                	j	ffffffffc02010b4 <mm_map+0x7a>
    assert(mm != NULL);
ffffffffc02010ca:	00006697          	auipc	a3,0x6
ffffffffc02010ce:	12668693          	addi	a3,a3,294 # ffffffffc02071f0 <commands+0x7d8>
ffffffffc02010d2:	00006617          	auipc	a2,0x6
ffffffffc02010d6:	d5660613          	addi	a2,a2,-682 # ffffffffc0206e28 <commands+0x410>
ffffffffc02010da:	0a700593          	li	a1,167
ffffffffc02010de:	00006517          	auipc	a0,0x6
ffffffffc02010e2:	05a50513          	addi	a0,a0,90 # ffffffffc0207138 <commands+0x720>
ffffffffc02010e6:	922ff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02010ea <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc02010ea:	7139                	addi	sp,sp,-64
ffffffffc02010ec:	fc06                	sd	ra,56(sp)
ffffffffc02010ee:	f822                	sd	s0,48(sp)
ffffffffc02010f0:	f426                	sd	s1,40(sp)
ffffffffc02010f2:	f04a                	sd	s2,32(sp)
ffffffffc02010f4:	ec4e                	sd	s3,24(sp)
ffffffffc02010f6:	e852                	sd	s4,16(sp)
ffffffffc02010f8:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc02010fa:	c52d                	beqz	a0,ffffffffc0201164 <dup_mmap+0x7a>
ffffffffc02010fc:	892a                	mv	s2,a0
ffffffffc02010fe:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc0201100:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc0201102:	e595                	bnez	a1,ffffffffc020112e <dup_mmap+0x44>
ffffffffc0201104:	a085                	j	ffffffffc0201164 <dup_mmap+0x7a>
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc0201106:	854a                	mv	a0,s2
        vma->vm_start = vm_start;
ffffffffc0201108:	0155b423          	sd	s5,8(a1) # 200008 <_binary_obj___user_exit_out_size+0x1f4ed8>
        vma->vm_end = vm_end;
ffffffffc020110c:	0145b823          	sd	s4,16(a1)
        vma->vm_flags = vm_flags;
ffffffffc0201110:	0135ac23          	sw	s3,24(a1)
        insert_vma_struct(to, nvma);
ffffffffc0201114:	e05ff0ef          	jal	ra,ffffffffc0200f18 <insert_vma_struct>
        //cow
        bool share = 1;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
ffffffffc0201118:	ff043683          	ld	a3,-16(s0) # ff0 <_binary_obj___user_faultread_out_size-0x8bd0>
ffffffffc020111c:	fe843603          	ld	a2,-24(s0)
ffffffffc0201120:	6c8c                	ld	a1,24(s1)
ffffffffc0201122:	01893503          	ld	a0,24(s2)
ffffffffc0201126:	4705                	li	a4,1
ffffffffc0201128:	067030ef          	jal	ra,ffffffffc020498e <copy_range>
ffffffffc020112c:	e105                	bnez	a0,ffffffffc020114c <dup_mmap+0x62>
    return listelm->prev;
ffffffffc020112e:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc0201130:	02848863          	beq	s1,s0,ffffffffc0201160 <dup_mmap+0x76>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201134:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc0201138:	fe843a83          	ld	s5,-24(s0)
ffffffffc020113c:	ff043a03          	ld	s4,-16(s0)
ffffffffc0201140:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201144:	396010ef          	jal	ra,ffffffffc02024da <kmalloc>
ffffffffc0201148:	85aa                	mv	a1,a0
    if (vma != NULL) {
ffffffffc020114a:	fd55                	bnez	a0,ffffffffc0201106 <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc020114c:	5571                	li	a0,-4
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc020114e:	70e2                	ld	ra,56(sp)
ffffffffc0201150:	7442                	ld	s0,48(sp)
ffffffffc0201152:	74a2                	ld	s1,40(sp)
ffffffffc0201154:	7902                	ld	s2,32(sp)
ffffffffc0201156:	69e2                	ld	s3,24(sp)
ffffffffc0201158:	6a42                	ld	s4,16(sp)
ffffffffc020115a:	6aa2                	ld	s5,8(sp)
ffffffffc020115c:	6121                	addi	sp,sp,64
ffffffffc020115e:	8082                	ret
    return 0;
ffffffffc0201160:	4501                	li	a0,0
ffffffffc0201162:	b7f5                	j	ffffffffc020114e <dup_mmap+0x64>
    assert(to != NULL && from != NULL);
ffffffffc0201164:	00006697          	auipc	a3,0x6
ffffffffc0201168:	09c68693          	addi	a3,a3,156 # ffffffffc0207200 <commands+0x7e8>
ffffffffc020116c:	00006617          	auipc	a2,0x6
ffffffffc0201170:	cbc60613          	addi	a2,a2,-836 # ffffffffc0206e28 <commands+0x410>
ffffffffc0201174:	0c000593          	li	a1,192
ffffffffc0201178:	00006517          	auipc	a0,0x6
ffffffffc020117c:	fc050513          	addi	a0,a0,-64 # ffffffffc0207138 <commands+0x720>
ffffffffc0201180:	888ff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0201184 <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
ffffffffc0201184:	1101                	addi	sp,sp,-32
ffffffffc0201186:	ec06                	sd	ra,24(sp)
ffffffffc0201188:	e822                	sd	s0,16(sp)
ffffffffc020118a:	e426                	sd	s1,8(sp)
ffffffffc020118c:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc020118e:	c531                	beqz	a0,ffffffffc02011da <exit_mmap+0x56>
ffffffffc0201190:	591c                	lw	a5,48(a0)
ffffffffc0201192:	84aa                	mv	s1,a0
ffffffffc0201194:	e3b9                	bnez	a5,ffffffffc02011da <exit_mmap+0x56>
    return listelm->next;
ffffffffc0201196:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc0201198:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc020119c:	02850663          	beq	a0,s0,ffffffffc02011c8 <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc02011a0:	ff043603          	ld	a2,-16(s0)
ffffffffc02011a4:	fe843583          	ld	a1,-24(s0)
ffffffffc02011a8:	854a                	mv	a0,s2
ffffffffc02011aa:	6e0020ef          	jal	ra,ffffffffc020388a <unmap_range>
ffffffffc02011ae:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc02011b0:	fe8498e3          	bne	s1,s0,ffffffffc02011a0 <exit_mmap+0x1c>
ffffffffc02011b4:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc02011b6:	00848c63          	beq	s1,s0,ffffffffc02011ce <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc02011ba:	ff043603          	ld	a2,-16(s0)
ffffffffc02011be:	fe843583          	ld	a1,-24(s0)
ffffffffc02011c2:	854a                	mv	a0,s2
ffffffffc02011c4:	00d020ef          	jal	ra,ffffffffc02039d0 <exit_range>
ffffffffc02011c8:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc02011ca:	fe8498e3          	bne	s1,s0,ffffffffc02011ba <exit_mmap+0x36>
    }
}
ffffffffc02011ce:	60e2                	ld	ra,24(sp)
ffffffffc02011d0:	6442                	ld	s0,16(sp)
ffffffffc02011d2:	64a2                	ld	s1,8(sp)
ffffffffc02011d4:	6902                	ld	s2,0(sp)
ffffffffc02011d6:	6105                	addi	sp,sp,32
ffffffffc02011d8:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc02011da:	00006697          	auipc	a3,0x6
ffffffffc02011de:	04668693          	addi	a3,a3,70 # ffffffffc0207220 <commands+0x808>
ffffffffc02011e2:	00006617          	auipc	a2,0x6
ffffffffc02011e6:	c4660613          	addi	a2,a2,-954 # ffffffffc0206e28 <commands+0x410>
ffffffffc02011ea:	0d600593          	li	a1,214
ffffffffc02011ee:	00006517          	auipc	a0,0x6
ffffffffc02011f2:	f4a50513          	addi	a0,a0,-182 # ffffffffc0207138 <commands+0x720>
ffffffffc02011f6:	812ff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02011fa <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc02011fa:	7139                	addi	sp,sp,-64
ffffffffc02011fc:	f822                	sd	s0,48(sp)
ffffffffc02011fe:	f426                	sd	s1,40(sp)
ffffffffc0201200:	fc06                	sd	ra,56(sp)
ffffffffc0201202:	f04a                	sd	s2,32(sp)
ffffffffc0201204:	ec4e                	sd	s3,24(sp)
ffffffffc0201206:	e852                	sd	s4,16(sp)
ffffffffc0201208:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc020120a:	c59ff0ef          	jal	ra,ffffffffc0200e62 <mm_create>
    assert(mm != NULL);
ffffffffc020120e:	84aa                	mv	s1,a0
ffffffffc0201210:	03200413          	li	s0,50
ffffffffc0201214:	e919                	bnez	a0,ffffffffc020122a <vmm_init+0x30>
ffffffffc0201216:	a991                	j	ffffffffc020166a <vmm_init+0x470>
        vma->vm_start = vm_start;
ffffffffc0201218:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc020121a:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020121c:	00052c23          	sw	zero,24(a0)

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc0201220:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0201222:	8526                	mv	a0,s1
ffffffffc0201224:	cf5ff0ef          	jal	ra,ffffffffc0200f18 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0201228:	c80d                	beqz	s0,ffffffffc020125a <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020122a:	03000513          	li	a0,48
ffffffffc020122e:	2ac010ef          	jal	ra,ffffffffc02024da <kmalloc>
ffffffffc0201232:	85aa                	mv	a1,a0
ffffffffc0201234:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0201238:	f165                	bnez	a0,ffffffffc0201218 <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc020123a:	00006697          	auipc	a3,0x6
ffffffffc020123e:	24668693          	addi	a3,a3,582 # ffffffffc0207480 <commands+0xa68>
ffffffffc0201242:	00006617          	auipc	a2,0x6
ffffffffc0201246:	be660613          	addi	a2,a2,-1050 # ffffffffc0206e28 <commands+0x410>
ffffffffc020124a:	11300593          	li	a1,275
ffffffffc020124e:	00006517          	auipc	a0,0x6
ffffffffc0201252:	eea50513          	addi	a0,a0,-278 # ffffffffc0207138 <commands+0x720>
ffffffffc0201256:	fb3fe0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc020125a:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020125e:	1f900913          	li	s2,505
ffffffffc0201262:	a819                	j	ffffffffc0201278 <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc0201264:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201266:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201268:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020126c:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020126e:	8526                	mv	a0,s1
ffffffffc0201270:	ca9ff0ef          	jal	ra,ffffffffc0200f18 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0201274:	03240a63          	beq	s0,s2,ffffffffc02012a8 <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201278:	03000513          	li	a0,48
ffffffffc020127c:	25e010ef          	jal	ra,ffffffffc02024da <kmalloc>
ffffffffc0201280:	85aa                	mv	a1,a0
ffffffffc0201282:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0201286:	fd79                	bnez	a0,ffffffffc0201264 <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc0201288:	00006697          	auipc	a3,0x6
ffffffffc020128c:	1f868693          	addi	a3,a3,504 # ffffffffc0207480 <commands+0xa68>
ffffffffc0201290:	00006617          	auipc	a2,0x6
ffffffffc0201294:	b9860613          	addi	a2,a2,-1128 # ffffffffc0206e28 <commands+0x410>
ffffffffc0201298:	11900593          	li	a1,281
ffffffffc020129c:	00006517          	auipc	a0,0x6
ffffffffc02012a0:	e9c50513          	addi	a0,a0,-356 # ffffffffc0207138 <commands+0x720>
ffffffffc02012a4:	f65fe0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc02012a8:	649c                	ld	a5,8(s1)
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
        assert(le != &(mm->mmap_list));
ffffffffc02012aa:	471d                	li	a4,7
    for (i = 1; i <= step2; i ++) {
ffffffffc02012ac:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc02012b0:	2cf48d63          	beq	s1,a5,ffffffffc020158a <vmm_init+0x390>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02012b4:	fe87b683          	ld	a3,-24(a5) # ffffffffffffefe8 <end+0x3fd4c6ac>
ffffffffc02012b8:	ffe70613          	addi	a2,a4,-2
ffffffffc02012bc:	24d61763          	bne	a2,a3,ffffffffc020150a <vmm_init+0x310>
ffffffffc02012c0:	ff07b683          	ld	a3,-16(a5)
ffffffffc02012c4:	24d71363          	bne	a4,a3,ffffffffc020150a <vmm_init+0x310>
    for (i = 1; i <= step2; i ++) {
ffffffffc02012c8:	0715                	addi	a4,a4,5
ffffffffc02012ca:	679c                	ld	a5,8(a5)
ffffffffc02012cc:	feb712e3          	bne	a4,a1,ffffffffc02012b0 <vmm_init+0xb6>
ffffffffc02012d0:	4a1d                	li	s4,7
ffffffffc02012d2:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02012d4:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc02012d8:	85a2                	mv	a1,s0
ffffffffc02012da:	8526                	mv	a0,s1
ffffffffc02012dc:	bfdff0ef          	jal	ra,ffffffffc0200ed8 <find_vma>
ffffffffc02012e0:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc02012e2:	30050463          	beqz	a0,ffffffffc02015ea <vmm_init+0x3f0>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc02012e6:	00140593          	addi	a1,s0,1
ffffffffc02012ea:	8526                	mv	a0,s1
ffffffffc02012ec:	bedff0ef          	jal	ra,ffffffffc0200ed8 <find_vma>
ffffffffc02012f0:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc02012f2:	2c050c63          	beqz	a0,ffffffffc02015ca <vmm_init+0x3d0>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc02012f6:	85d2                	mv	a1,s4
ffffffffc02012f8:	8526                	mv	a0,s1
ffffffffc02012fa:	bdfff0ef          	jal	ra,ffffffffc0200ed8 <find_vma>
        assert(vma3 == NULL);
ffffffffc02012fe:	2a051663          	bnez	a0,ffffffffc02015aa <vmm_init+0x3b0>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0201302:	00340593          	addi	a1,s0,3
ffffffffc0201306:	8526                	mv	a0,s1
ffffffffc0201308:	bd1ff0ef          	jal	ra,ffffffffc0200ed8 <find_vma>
        assert(vma4 == NULL);
ffffffffc020130c:	30051f63          	bnez	a0,ffffffffc020162a <vmm_init+0x430>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0201310:	00440593          	addi	a1,s0,4
ffffffffc0201314:	8526                	mv	a0,s1
ffffffffc0201316:	bc3ff0ef          	jal	ra,ffffffffc0200ed8 <find_vma>
        assert(vma5 == NULL);
ffffffffc020131a:	2e051863          	bnez	a0,ffffffffc020160a <vmm_init+0x410>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020131e:	00893783          	ld	a5,8(s2)
ffffffffc0201322:	20f41463          	bne	s0,a5,ffffffffc020152a <vmm_init+0x330>
ffffffffc0201326:	01093783          	ld	a5,16(s2)
ffffffffc020132a:	21479063          	bne	a5,s4,ffffffffc020152a <vmm_init+0x330>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020132e:	0089b783          	ld	a5,8(s3)
ffffffffc0201332:	20f41c63          	bne	s0,a5,ffffffffc020154a <vmm_init+0x350>
ffffffffc0201336:	0109b783          	ld	a5,16(s3)
ffffffffc020133a:	21479863          	bne	a5,s4,ffffffffc020154a <vmm_init+0x350>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020133e:	0415                	addi	s0,s0,5
ffffffffc0201340:	0a15                	addi	s4,s4,5
ffffffffc0201342:	f9541be3          	bne	s0,s5,ffffffffc02012d8 <vmm_init+0xde>
ffffffffc0201346:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0201348:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc020134a:	85a2                	mv	a1,s0
ffffffffc020134c:	8526                	mv	a0,s1
ffffffffc020134e:	b8bff0ef          	jal	ra,ffffffffc0200ed8 <find_vma>
ffffffffc0201352:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc0201356:	c90d                	beqz	a0,ffffffffc0201388 <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0201358:	6914                	ld	a3,16(a0)
ffffffffc020135a:	6510                	ld	a2,8(a0)
ffffffffc020135c:	00006517          	auipc	a0,0x6
ffffffffc0201360:	fe450513          	addi	a0,a0,-28 # ffffffffc0207340 <commands+0x928>
ffffffffc0201364:	d69fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0201368:	00006697          	auipc	a3,0x6
ffffffffc020136c:	00068693          	mv	a3,a3
ffffffffc0201370:	00006617          	auipc	a2,0x6
ffffffffc0201374:	ab860613          	addi	a2,a2,-1352 # ffffffffc0206e28 <commands+0x410>
ffffffffc0201378:	13b00593          	li	a1,315
ffffffffc020137c:	00006517          	auipc	a0,0x6
ffffffffc0201380:	dbc50513          	addi	a0,a0,-580 # ffffffffc0207138 <commands+0x720>
ffffffffc0201384:	e85fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    for (i =4; i>=0; i--) {
ffffffffc0201388:	147d                	addi	s0,s0,-1
ffffffffc020138a:	fd2410e3          	bne	s0,s2,ffffffffc020134a <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc020138e:	8526                	mv	a0,s1
ffffffffc0201390:	c59ff0ef          	jal	ra,ffffffffc0200fe8 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0201394:	00006517          	auipc	a0,0x6
ffffffffc0201398:	fec50513          	addi	a0,a0,-20 # ffffffffc0207380 <commands+0x968>
ffffffffc020139c:	d31fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02013a0:	28a020ef          	jal	ra,ffffffffc020362a <nr_free_pages>
ffffffffc02013a4:	892a                	mv	s2,a0

    check_mm_struct = mm_create();
ffffffffc02013a6:	abdff0ef          	jal	ra,ffffffffc0200e62 <mm_create>
ffffffffc02013aa:	000b1797          	auipc	a5,0xb1
ffffffffc02013ae:	50a7bb23          	sd	a0,1302(a5) # ffffffffc02b28c0 <check_mm_struct>
ffffffffc02013b2:	842a                	mv	s0,a0
    assert(check_mm_struct != NULL);
ffffffffc02013b4:	28050b63          	beqz	a0,ffffffffc020164a <vmm_init+0x450>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02013b8:	000b1497          	auipc	s1,0xb1
ffffffffc02013bc:	5404b483          	ld	s1,1344(s1) # ffffffffc02b28f8 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc02013c0:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02013c2:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc02013c4:	2e079f63          	bnez	a5,ffffffffc02016c2 <vmm_init+0x4c8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02013c8:	03000513          	li	a0,48
ffffffffc02013cc:	10e010ef          	jal	ra,ffffffffc02024da <kmalloc>
ffffffffc02013d0:	89aa                	mv	s3,a0
    if (vma != NULL) {
ffffffffc02013d2:	18050c63          	beqz	a0,ffffffffc020156a <vmm_init+0x370>
        vma->vm_end = vm_end;
ffffffffc02013d6:	002007b7          	lui	a5,0x200
ffffffffc02013da:	00f9b823          	sd	a5,16(s3)
        vma->vm_flags = vm_flags;
ffffffffc02013de:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc02013e0:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc02013e2:	00f9ac23          	sw	a5,24(s3)
    insert_vma_struct(mm, vma);
ffffffffc02013e6:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc02013e8:	0009b423          	sd	zero,8(s3)
    insert_vma_struct(mm, vma);
ffffffffc02013ec:	b2dff0ef          	jal	ra,ffffffffc0200f18 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc02013f0:	10000593          	li	a1,256
ffffffffc02013f4:	8522                	mv	a0,s0
ffffffffc02013f6:	ae3ff0ef          	jal	ra,ffffffffc0200ed8 <find_vma>
ffffffffc02013fa:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc02013fe:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0201402:	2ea99063          	bne	s3,a0,ffffffffc02016e2 <vmm_init+0x4e8>
        *(char *)(addr + i) = i;
ffffffffc0201406:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_exit_out_size+0x1f4ed0>
    for (i = 0; i < 100; i ++) {
ffffffffc020140a:	0785                	addi	a5,a5,1
ffffffffc020140c:	fee79de3          	bne	a5,a4,ffffffffc0201406 <vmm_init+0x20c>
        sum += i;
ffffffffc0201410:	6705                	lui	a4,0x1
ffffffffc0201412:	10000793          	li	a5,256
ffffffffc0201416:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x886a>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc020141a:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc020141e:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc0201422:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc0201424:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0201426:	fec79ce3          	bne	a5,a2,ffffffffc020141e <vmm_init+0x224>
    }

    assert(sum == 0);
ffffffffc020142a:	2c071e63          	bnez	a4,ffffffffc0201706 <vmm_init+0x50c>
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
ffffffffc020142e:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc0201430:	000b1a97          	auipc	s5,0xb1
ffffffffc0201434:	4d0a8a93          	addi	s5,s5,1232 # ffffffffc02b2900 <npage>
ffffffffc0201438:	000ab603          	ld	a2,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc020143c:	078a                	slli	a5,a5,0x2
ffffffffc020143e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201440:	2cc7f163          	bgeu	a5,a2,ffffffffc0201702 <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc0201444:	00008a17          	auipc	s4,0x8
ffffffffc0201448:	a2ca3a03          	ld	s4,-1492(s4) # ffffffffc0208e70 <nbase>
ffffffffc020144c:	414787b3          	sub	a5,a5,s4
ffffffffc0201450:	079a                	slli	a5,a5,0x6
    return page - pages + nbase;
ffffffffc0201452:	8799                	srai	a5,a5,0x6
ffffffffc0201454:	97d2                	add	a5,a5,s4
    return KADDR(page2pa(page));
ffffffffc0201456:	00c79713          	slli	a4,a5,0xc
ffffffffc020145a:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020145c:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0201460:	24c77563          	bgeu	a4,a2,ffffffffc02016aa <vmm_init+0x4b0>
ffffffffc0201464:	000b1997          	auipc	s3,0xb1
ffffffffc0201468:	4b49b983          	ld	s3,1204(s3) # ffffffffc02b2918 <va_pa_offset>

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc020146c:	4581                	li	a1,0
ffffffffc020146e:	8526                	mv	a0,s1
ffffffffc0201470:	99b6                	add	s3,s3,a3
ffffffffc0201472:	7f0020ef          	jal	ra,ffffffffc0203c62 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201476:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc020147a:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc020147e:	078a                	slli	a5,a5,0x2
ffffffffc0201480:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201482:	28e7f063          	bgeu	a5,a4,ffffffffc0201702 <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc0201486:	000b1997          	auipc	s3,0xb1
ffffffffc020148a:	48298993          	addi	s3,s3,1154 # ffffffffc02b2908 <pages>
ffffffffc020148e:	0009b503          	ld	a0,0(s3)
ffffffffc0201492:	414787b3          	sub	a5,a5,s4
ffffffffc0201496:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0201498:	953e                	add	a0,a0,a5
ffffffffc020149a:	4585                	li	a1,1
ffffffffc020149c:	14e020ef          	jal	ra,ffffffffc02035ea <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02014a0:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc02014a2:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02014a6:	078a                	slli	a5,a5,0x2
ffffffffc02014a8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02014aa:	24e7fc63          	bgeu	a5,a4,ffffffffc0201702 <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc02014ae:	0009b503          	ld	a0,0(s3)
ffffffffc02014b2:	414787b3          	sub	a5,a5,s4
ffffffffc02014b6:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc02014b8:	4585                	li	a1,1
ffffffffc02014ba:	953e                	add	a0,a0,a5
ffffffffc02014bc:	12e020ef          	jal	ra,ffffffffc02035ea <free_pages>
    pgdir[0] = 0;
ffffffffc02014c0:	0004b023          	sd	zero,0(s1)
    page->ref -= 1;
    return page->ref;
}

static inline void flush_tlb() {
  asm volatile("sfence.vma");
ffffffffc02014c4:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
    mm_destroy(mm);
ffffffffc02014c8:	8522                	mv	a0,s0
    mm->pgdir = NULL;
ffffffffc02014ca:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc02014ce:	b1bff0ef          	jal	ra,ffffffffc0200fe8 <mm_destroy>
    check_mm_struct = NULL;
ffffffffc02014d2:	000b1797          	auipc	a5,0xb1
ffffffffc02014d6:	3e07b723          	sd	zero,1006(a5) # ffffffffc02b28c0 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02014da:	150020ef          	jal	ra,ffffffffc020362a <nr_free_pages>
ffffffffc02014de:	1aa91663          	bne	s2,a0,ffffffffc020168a <vmm_init+0x490>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc02014e2:	00006517          	auipc	a0,0x6
ffffffffc02014e6:	f6650513          	addi	a0,a0,-154 # ffffffffc0207448 <commands+0xa30>
ffffffffc02014ea:	be3fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc02014ee:	7442                	ld	s0,48(sp)
ffffffffc02014f0:	70e2                	ld	ra,56(sp)
ffffffffc02014f2:	74a2                	ld	s1,40(sp)
ffffffffc02014f4:	7902                	ld	s2,32(sp)
ffffffffc02014f6:	69e2                	ld	s3,24(sp)
ffffffffc02014f8:	6a42                	ld	s4,16(sp)
ffffffffc02014fa:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc02014fc:	00006517          	auipc	a0,0x6
ffffffffc0201500:	f6c50513          	addi	a0,a0,-148 # ffffffffc0207468 <commands+0xa50>
}
ffffffffc0201504:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0201506:	bc7fe06f          	j	ffffffffc02000cc <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020150a:	00006697          	auipc	a3,0x6
ffffffffc020150e:	d4e68693          	addi	a3,a3,-690 # ffffffffc0207258 <commands+0x840>
ffffffffc0201512:	00006617          	auipc	a2,0x6
ffffffffc0201516:	91660613          	addi	a2,a2,-1770 # ffffffffc0206e28 <commands+0x410>
ffffffffc020151a:	12200593          	li	a1,290
ffffffffc020151e:	00006517          	auipc	a0,0x6
ffffffffc0201522:	c1a50513          	addi	a0,a0,-998 # ffffffffc0207138 <commands+0x720>
ffffffffc0201526:	ce3fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020152a:	00006697          	auipc	a3,0x6
ffffffffc020152e:	db668693          	addi	a3,a3,-586 # ffffffffc02072e0 <commands+0x8c8>
ffffffffc0201532:	00006617          	auipc	a2,0x6
ffffffffc0201536:	8f660613          	addi	a2,a2,-1802 # ffffffffc0206e28 <commands+0x410>
ffffffffc020153a:	13200593          	li	a1,306
ffffffffc020153e:	00006517          	auipc	a0,0x6
ffffffffc0201542:	bfa50513          	addi	a0,a0,-1030 # ffffffffc0207138 <commands+0x720>
ffffffffc0201546:	cc3fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020154a:	00006697          	auipc	a3,0x6
ffffffffc020154e:	dc668693          	addi	a3,a3,-570 # ffffffffc0207310 <commands+0x8f8>
ffffffffc0201552:	00006617          	auipc	a2,0x6
ffffffffc0201556:	8d660613          	addi	a2,a2,-1834 # ffffffffc0206e28 <commands+0x410>
ffffffffc020155a:	13300593          	li	a1,307
ffffffffc020155e:	00006517          	auipc	a0,0x6
ffffffffc0201562:	bda50513          	addi	a0,a0,-1062 # ffffffffc0207138 <commands+0x720>
ffffffffc0201566:	ca3fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(vma != NULL);
ffffffffc020156a:	00006697          	auipc	a3,0x6
ffffffffc020156e:	f1668693          	addi	a3,a3,-234 # ffffffffc0207480 <commands+0xa68>
ffffffffc0201572:	00006617          	auipc	a2,0x6
ffffffffc0201576:	8b660613          	addi	a2,a2,-1866 # ffffffffc0206e28 <commands+0x410>
ffffffffc020157a:	15200593          	li	a1,338
ffffffffc020157e:	00006517          	auipc	a0,0x6
ffffffffc0201582:	bba50513          	addi	a0,a0,-1094 # ffffffffc0207138 <commands+0x720>
ffffffffc0201586:	c83fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc020158a:	00006697          	auipc	a3,0x6
ffffffffc020158e:	cb668693          	addi	a3,a3,-842 # ffffffffc0207240 <commands+0x828>
ffffffffc0201592:	00006617          	auipc	a2,0x6
ffffffffc0201596:	89660613          	addi	a2,a2,-1898 # ffffffffc0206e28 <commands+0x410>
ffffffffc020159a:	12000593          	li	a1,288
ffffffffc020159e:	00006517          	auipc	a0,0x6
ffffffffc02015a2:	b9a50513          	addi	a0,a0,-1126 # ffffffffc0207138 <commands+0x720>
ffffffffc02015a6:	c63fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma3 == NULL);
ffffffffc02015aa:	00006697          	auipc	a3,0x6
ffffffffc02015ae:	d0668693          	addi	a3,a3,-762 # ffffffffc02072b0 <commands+0x898>
ffffffffc02015b2:	00006617          	auipc	a2,0x6
ffffffffc02015b6:	87660613          	addi	a2,a2,-1930 # ffffffffc0206e28 <commands+0x410>
ffffffffc02015ba:	12c00593          	li	a1,300
ffffffffc02015be:	00006517          	auipc	a0,0x6
ffffffffc02015c2:	b7a50513          	addi	a0,a0,-1158 # ffffffffc0207138 <commands+0x720>
ffffffffc02015c6:	c43fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma2 != NULL);
ffffffffc02015ca:	00006697          	auipc	a3,0x6
ffffffffc02015ce:	cd668693          	addi	a3,a3,-810 # ffffffffc02072a0 <commands+0x888>
ffffffffc02015d2:	00006617          	auipc	a2,0x6
ffffffffc02015d6:	85660613          	addi	a2,a2,-1962 # ffffffffc0206e28 <commands+0x410>
ffffffffc02015da:	12a00593          	li	a1,298
ffffffffc02015de:	00006517          	auipc	a0,0x6
ffffffffc02015e2:	b5a50513          	addi	a0,a0,-1190 # ffffffffc0207138 <commands+0x720>
ffffffffc02015e6:	c23fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma1 != NULL);
ffffffffc02015ea:	00006697          	auipc	a3,0x6
ffffffffc02015ee:	ca668693          	addi	a3,a3,-858 # ffffffffc0207290 <commands+0x878>
ffffffffc02015f2:	00006617          	auipc	a2,0x6
ffffffffc02015f6:	83660613          	addi	a2,a2,-1994 # ffffffffc0206e28 <commands+0x410>
ffffffffc02015fa:	12800593          	li	a1,296
ffffffffc02015fe:	00006517          	auipc	a0,0x6
ffffffffc0201602:	b3a50513          	addi	a0,a0,-1222 # ffffffffc0207138 <commands+0x720>
ffffffffc0201606:	c03fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma5 == NULL);
ffffffffc020160a:	00006697          	auipc	a3,0x6
ffffffffc020160e:	cc668693          	addi	a3,a3,-826 # ffffffffc02072d0 <commands+0x8b8>
ffffffffc0201612:	00006617          	auipc	a2,0x6
ffffffffc0201616:	81660613          	addi	a2,a2,-2026 # ffffffffc0206e28 <commands+0x410>
ffffffffc020161a:	13000593          	li	a1,304
ffffffffc020161e:	00006517          	auipc	a0,0x6
ffffffffc0201622:	b1a50513          	addi	a0,a0,-1254 # ffffffffc0207138 <commands+0x720>
ffffffffc0201626:	be3fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma4 == NULL);
ffffffffc020162a:	00006697          	auipc	a3,0x6
ffffffffc020162e:	c9668693          	addi	a3,a3,-874 # ffffffffc02072c0 <commands+0x8a8>
ffffffffc0201632:	00005617          	auipc	a2,0x5
ffffffffc0201636:	7f660613          	addi	a2,a2,2038 # ffffffffc0206e28 <commands+0x410>
ffffffffc020163a:	12e00593          	li	a1,302
ffffffffc020163e:	00006517          	auipc	a0,0x6
ffffffffc0201642:	afa50513          	addi	a0,a0,-1286 # ffffffffc0207138 <commands+0x720>
ffffffffc0201646:	bc3fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc020164a:	00006697          	auipc	a3,0x6
ffffffffc020164e:	d5668693          	addi	a3,a3,-682 # ffffffffc02073a0 <commands+0x988>
ffffffffc0201652:	00005617          	auipc	a2,0x5
ffffffffc0201656:	7d660613          	addi	a2,a2,2006 # ffffffffc0206e28 <commands+0x410>
ffffffffc020165a:	14b00593          	li	a1,331
ffffffffc020165e:	00006517          	auipc	a0,0x6
ffffffffc0201662:	ada50513          	addi	a0,a0,-1318 # ffffffffc0207138 <commands+0x720>
ffffffffc0201666:	ba3fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(mm != NULL);
ffffffffc020166a:	00006697          	auipc	a3,0x6
ffffffffc020166e:	b8668693          	addi	a3,a3,-1146 # ffffffffc02071f0 <commands+0x7d8>
ffffffffc0201672:	00005617          	auipc	a2,0x5
ffffffffc0201676:	7b660613          	addi	a2,a2,1974 # ffffffffc0206e28 <commands+0x410>
ffffffffc020167a:	10c00593          	li	a1,268
ffffffffc020167e:	00006517          	auipc	a0,0x6
ffffffffc0201682:	aba50513          	addi	a0,a0,-1350 # ffffffffc0207138 <commands+0x720>
ffffffffc0201686:	b83fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020168a:	00006697          	auipc	a3,0x6
ffffffffc020168e:	d9668693          	addi	a3,a3,-618 # ffffffffc0207420 <commands+0xa08>
ffffffffc0201692:	00005617          	auipc	a2,0x5
ffffffffc0201696:	79660613          	addi	a2,a2,1942 # ffffffffc0206e28 <commands+0x410>
ffffffffc020169a:	17000593          	li	a1,368
ffffffffc020169e:	00006517          	auipc	a0,0x6
ffffffffc02016a2:	a9a50513          	addi	a0,a0,-1382 # ffffffffc0207138 <commands+0x720>
ffffffffc02016a6:	b63fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc02016aa:	00006617          	auipc	a2,0x6
ffffffffc02016ae:	d4e60613          	addi	a2,a2,-690 # ffffffffc02073f8 <commands+0x9e0>
ffffffffc02016b2:	06900593          	li	a1,105
ffffffffc02016b6:	00006517          	auipc	a0,0x6
ffffffffc02016ba:	ab250513          	addi	a0,a0,-1358 # ffffffffc0207168 <commands+0x750>
ffffffffc02016be:	b4bfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir[0] == 0);
ffffffffc02016c2:	00006697          	auipc	a3,0x6
ffffffffc02016c6:	cf668693          	addi	a3,a3,-778 # ffffffffc02073b8 <commands+0x9a0>
ffffffffc02016ca:	00005617          	auipc	a2,0x5
ffffffffc02016ce:	75e60613          	addi	a2,a2,1886 # ffffffffc0206e28 <commands+0x410>
ffffffffc02016d2:	14f00593          	li	a1,335
ffffffffc02016d6:	00006517          	auipc	a0,0x6
ffffffffc02016da:	a6250513          	addi	a0,a0,-1438 # ffffffffc0207138 <commands+0x720>
ffffffffc02016de:	b2bfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc02016e2:	00006697          	auipc	a3,0x6
ffffffffc02016e6:	ce668693          	addi	a3,a3,-794 # ffffffffc02073c8 <commands+0x9b0>
ffffffffc02016ea:	00005617          	auipc	a2,0x5
ffffffffc02016ee:	73e60613          	addi	a2,a2,1854 # ffffffffc0206e28 <commands+0x410>
ffffffffc02016f2:	15700593          	li	a1,343
ffffffffc02016f6:	00006517          	auipc	a0,0x6
ffffffffc02016fa:	a4250513          	addi	a0,a0,-1470 # ffffffffc0207138 <commands+0x720>
ffffffffc02016fe:	b0bfe0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0201702:	f44ff0ef          	jal	ra,ffffffffc0200e46 <pa2page.part.0>
    assert(sum == 0);
ffffffffc0201706:	00006697          	auipc	a3,0x6
ffffffffc020170a:	ce268693          	addi	a3,a3,-798 # ffffffffc02073e8 <commands+0x9d0>
ffffffffc020170e:	00005617          	auipc	a2,0x5
ffffffffc0201712:	71a60613          	addi	a2,a2,1818 # ffffffffc0206e28 <commands+0x410>
ffffffffc0201716:	16300593          	li	a1,355
ffffffffc020171a:	00006517          	auipc	a0,0x6
ffffffffc020171e:	a1e50513          	addi	a0,a0,-1506 # ffffffffc0207138 <commands+0x720>
ffffffffc0201722:	ae7fe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0201726 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0201726:	715d                	addi	sp,sp,-80
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0201728:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc020172a:	e0a2                	sd	s0,64(sp)
ffffffffc020172c:	f84a                	sd	s2,48(sp)
ffffffffc020172e:	e486                	sd	ra,72(sp)
ffffffffc0201730:	fc26                	sd	s1,56(sp)
ffffffffc0201732:	f44e                	sd	s3,40(sp)
ffffffffc0201734:	f052                	sd	s4,32(sp)
ffffffffc0201736:	ec56                	sd	s5,24(sp)
ffffffffc0201738:	8432                	mv	s0,a2
ffffffffc020173a:	892a                	mv	s2,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020173c:	f9cff0ef          	jal	ra,ffffffffc0200ed8 <find_vma>

    pgfault_num++;
ffffffffc0201740:	000b1797          	auipc	a5,0xb1
ffffffffc0201744:	1887a783          	lw	a5,392(a5) # ffffffffc02b28c8 <pgfault_num>
ffffffffc0201748:	2785                	addiw	a5,a5,1
ffffffffc020174a:	000b1717          	auipc	a4,0xb1
ffffffffc020174e:	16f72f23          	sw	a5,382(a4) # ffffffffc02b28c8 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0201752:	14050563          	beqz	a0,ffffffffc020189c <do_pgfault+0x176>
ffffffffc0201756:	651c                	ld	a5,8(a0)
ffffffffc0201758:	14f46263          	bltu	s0,a5,ffffffffc020189c <do_pgfault+0x176>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc020175c:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc020175e:	49c1                	li	s3,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0201760:	8b89                	andi	a5,a5,2
ffffffffc0201762:	e3a9                	bnez	a5,ffffffffc02017a4 <do_pgfault+0x7e>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0201764:	75fd                	lui	a1,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0201766:	01893503          	ld	a0,24(s2)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc020176a:	8c6d                	and	s0,s0,a1
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc020176c:	4605                	li	a2,1
ffffffffc020176e:	85a2                	mv	a1,s0
ffffffffc0201770:	6f5010ef          	jal	ra,ffffffffc0203664 <get_pte>
ffffffffc0201774:	84aa                	mv	s1,a0
ffffffffc0201776:	12050c63          	beqz	a0,ffffffffc02018ae <do_pgfault+0x188>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc020177a:	6110                	ld	a2,0(a0)
ffffffffc020177c:	c669                	beqz	a2,ffffffffc0201846 <do_pgfault+0x120>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        struct Page *page =NULL;
ffffffffc020177e:	e402                	sd	zero,8(sp)
        if(*ptep & PTE_V)
ffffffffc0201780:	00167793          	andi	a5,a2,1
ffffffffc0201784:	e395                	bnez	a5,ffffffffc02017a8 <do_pgfault+0x82>
            }
            else
                page_insert(mm->pgdir, page, addr, perm);
        }
        else{
            if (swap_init_ok) {
ffffffffc0201786:	000b1797          	auipc	a5,0xb1
ffffffffc020178a:	15a7a783          	lw	a5,346(a5) # ffffffffc02b28e0 <swap_init_ok>
ffffffffc020178e:	efe9                	bnez	a5,ffffffffc0201868 <do_pgfault+0x142>
                //logical addr
                //(3) make the page swappable.
            } 
        }
   }
   ret = 0;
ffffffffc0201790:	4501                	li	a0,0
failed:
    return ret;
}
ffffffffc0201792:	60a6                	ld	ra,72(sp)
ffffffffc0201794:	6406                	ld	s0,64(sp)
ffffffffc0201796:	74e2                	ld	s1,56(sp)
ffffffffc0201798:	7942                	ld	s2,48(sp)
ffffffffc020179a:	79a2                	ld	s3,40(sp)
ffffffffc020179c:	7a02                	ld	s4,32(sp)
ffffffffc020179e:	6ae2                	ld	s5,24(sp)
ffffffffc02017a0:	6161                	addi	sp,sp,80
ffffffffc02017a2:	8082                	ret
        perm |= READ_WRITE;
ffffffffc02017a4:	49dd                	li	s3,23
ffffffffc02017a6:	bf7d                	j	ffffffffc0201764 <do_pgfault+0x3e>
            cprintf("\n\nCOW: ptep 0x%x, pte 0x%x\n",ptep, *ptep);
ffffffffc02017a8:	85aa                	mv	a1,a0
ffffffffc02017aa:	00006517          	auipc	a0,0x6
ffffffffc02017ae:	d5e50513          	addi	a0,a0,-674 # ffffffffc0207508 <commands+0xaf0>
ffffffffc02017b2:	91bfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
            page = pte2page(*ptep);
ffffffffc02017b6:	609c                	ld	a5,0(s1)
    if (!(pte & PTE_V)) {
ffffffffc02017b8:	0017f713          	andi	a4,a5,1
ffffffffc02017bc:	12070a63          	beqz	a4,ffffffffc02018f0 <do_pgfault+0x1ca>
    if (PPN(pa) >= npage) {
ffffffffc02017c0:	000b1a17          	auipc	s4,0xb1
ffffffffc02017c4:	140a0a13          	addi	s4,s4,320 # ffffffffc02b2900 <npage>
ffffffffc02017c8:	000a3703          	ld	a4,0(s4)
    return pa2page(PTE_ADDR(pte));
ffffffffc02017cc:	078a                	slli	a5,a5,0x2
ffffffffc02017ce:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02017d0:	12e7fc63          	bgeu	a5,a4,ffffffffc0201908 <do_pgfault+0x1e2>
    return &pages[PPN(pa) - nbase];
ffffffffc02017d4:	000b1a97          	auipc	s5,0xb1
ffffffffc02017d8:	134a8a93          	addi	s5,s5,308 # ffffffffc02b2908 <pages>
ffffffffc02017dc:	000ab583          	ld	a1,0(s5)
ffffffffc02017e0:	00007497          	auipc	s1,0x7
ffffffffc02017e4:	6904b483          	ld	s1,1680(s1) # ffffffffc0208e70 <nbase>
ffffffffc02017e8:	8f85                	sub	a5,a5,s1
ffffffffc02017ea:	079a                	slli	a5,a5,0x6
ffffffffc02017ec:	95be                	add	a1,a1,a5
            if (page_ref(page) > 1)
ffffffffc02017ee:	4198                	lw	a4,0(a1)
ffffffffc02017f0:	4785                	li	a5,1
            page = pte2page(*ptep);
ffffffffc02017f2:	e42e                	sd	a1,8(sp)
                struct Page *newPage = pgdir_alloc_page(mm->pgdir, addr, perm);
ffffffffc02017f4:	01893503          	ld	a0,24(s2)
            if (page_ref(page) > 1)
ffffffffc02017f8:	08e7dd63          	bge	a5,a4,ffffffffc0201892 <do_pgfault+0x16c>
                struct Page *newPage = pgdir_alloc_page(mm->pgdir, addr, perm);
ffffffffc02017fc:	864e                	mv	a2,s3
ffffffffc02017fe:	85a2                	mv	a1,s0
ffffffffc0201800:	44e030ef          	jal	ra,ffffffffc0204c4e <pgdir_alloc_page>
    return page - pages + nbase;
ffffffffc0201804:	000ab683          	ld	a3,0(s5)
ffffffffc0201808:	65a2                	ld	a1,8(sp)
    return KADDR(page2pa(page));
ffffffffc020180a:	57fd                	li	a5,-1
ffffffffc020180c:	000a3703          	ld	a4,0(s4)
    return page - pages + nbase;
ffffffffc0201810:	8d95                	sub	a1,a1,a3
ffffffffc0201812:	8599                	srai	a1,a1,0x6
ffffffffc0201814:	95a6                	add	a1,a1,s1
    return KADDR(page2pa(page));
ffffffffc0201816:	83b1                	srli	a5,a5,0xc
ffffffffc0201818:	00f5f633          	and	a2,a1,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc020181c:	05b2                	slli	a1,a1,0xc
    return KADDR(page2pa(page));
ffffffffc020181e:	0ae67c63          	bgeu	a2,a4,ffffffffc02018d6 <do_pgfault+0x1b0>
    return page - pages + nbase;
ffffffffc0201822:	40d506b3          	sub	a3,a0,a3
ffffffffc0201826:	8699                	srai	a3,a3,0x6
ffffffffc0201828:	96a6                	add	a3,a3,s1
    return KADDR(page2pa(page));
ffffffffc020182a:	000b1517          	auipc	a0,0xb1
ffffffffc020182e:	0ee53503          	ld	a0,238(a0) # ffffffffc02b2918 <va_pa_offset>
ffffffffc0201832:	8ff5                	and	a5,a5,a3
ffffffffc0201834:	95aa                	add	a1,a1,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201836:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201838:	08e7f363          	bgeu	a5,a4,ffffffffc02018be <do_pgfault+0x198>
                memcpy(kva_dst, kva_src, PGSIZE);
ffffffffc020183c:	6605                	lui	a2,0x1
ffffffffc020183e:	9536                	add	a0,a0,a3
ffffffffc0201840:	315040ef          	jal	ra,ffffffffc0206354 <memcpy>
ffffffffc0201844:	b7b1                	j	ffffffffc0201790 <do_pgfault+0x6a>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0201846:	01893503          	ld	a0,24(s2)
ffffffffc020184a:	864e                	mv	a2,s3
ffffffffc020184c:	85a2                	mv	a1,s0
ffffffffc020184e:	400030ef          	jal	ra,ffffffffc0204c4e <pgdir_alloc_page>
ffffffffc0201852:	87aa                	mv	a5,a0
   ret = 0;
ffffffffc0201854:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0201856:	ff95                	bnez	a5,ffffffffc0201792 <do_pgfault+0x6c>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0201858:	00006517          	auipc	a0,0x6
ffffffffc020185c:	c8850513          	addi	a0,a0,-888 # ffffffffc02074e0 <commands+0xac8>
ffffffffc0201860:	86dfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc0201864:	5571                	li	a0,-4
            goto failed;
ffffffffc0201866:	b735                	j	ffffffffc0201792 <do_pgfault+0x6c>
                swap_in(mm, addr, &page); 
ffffffffc0201868:	85a2                	mv	a1,s0
ffffffffc020186a:	0030                	addi	a2,sp,8
ffffffffc020186c:	854a                	mv	a0,s2
ffffffffc020186e:	1c1000ef          	jal	ra,ffffffffc020222e <swap_in>
                page_insert(mm->pgdir, page, addr, perm); 
ffffffffc0201872:	65a2                	ld	a1,8(sp)
ffffffffc0201874:	01893503          	ld	a0,24(s2)
ffffffffc0201878:	86ce                	mv	a3,s3
ffffffffc020187a:	8622                	mv	a2,s0
ffffffffc020187c:	482020ef          	jal	ra,ffffffffc0203cfe <page_insert>
                swap_map_swappable(mm, addr, page, 1);  
ffffffffc0201880:	6622                	ld	a2,8(sp)
ffffffffc0201882:	4685                	li	a3,1
ffffffffc0201884:	85a2                	mv	a1,s0
ffffffffc0201886:	854a                	mv	a0,s2
ffffffffc0201888:	087000ef          	jal	ra,ffffffffc020210e <swap_map_swappable>
                page->pra_vaddr = addr;
ffffffffc020188c:	67a2                	ld	a5,8(sp)
ffffffffc020188e:	ff80                	sd	s0,56(a5)
ffffffffc0201890:	b701                	j	ffffffffc0201790 <do_pgfault+0x6a>
                page_insert(mm->pgdir, page, addr, perm);
ffffffffc0201892:	86ce                	mv	a3,s3
ffffffffc0201894:	8622                	mv	a2,s0
ffffffffc0201896:	468020ef          	jal	ra,ffffffffc0203cfe <page_insert>
ffffffffc020189a:	bddd                	j	ffffffffc0201790 <do_pgfault+0x6a>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc020189c:	85a2                	mv	a1,s0
ffffffffc020189e:	00006517          	auipc	a0,0x6
ffffffffc02018a2:	bf250513          	addi	a0,a0,-1038 # ffffffffc0207490 <commands+0xa78>
ffffffffc02018a6:	827fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    int ret = -E_INVAL;
ffffffffc02018aa:	5575                	li	a0,-3
        goto failed;
ffffffffc02018ac:	b5dd                	j	ffffffffc0201792 <do_pgfault+0x6c>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc02018ae:	00006517          	auipc	a0,0x6
ffffffffc02018b2:	c1250513          	addi	a0,a0,-1006 # ffffffffc02074c0 <commands+0xaa8>
ffffffffc02018b6:	817fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc02018ba:	5571                	li	a0,-4
        goto failed;
ffffffffc02018bc:	bdd9                	j	ffffffffc0201792 <do_pgfault+0x6c>
ffffffffc02018be:	00006617          	auipc	a2,0x6
ffffffffc02018c2:	b3a60613          	addi	a2,a2,-1222 # ffffffffc02073f8 <commands+0x9e0>
ffffffffc02018c6:	06900593          	li	a1,105
ffffffffc02018ca:	00006517          	auipc	a0,0x6
ffffffffc02018ce:	89e50513          	addi	a0,a0,-1890 # ffffffffc0207168 <commands+0x750>
ffffffffc02018d2:	937fe0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc02018d6:	86ae                	mv	a3,a1
ffffffffc02018d8:	00006617          	auipc	a2,0x6
ffffffffc02018dc:	b2060613          	addi	a2,a2,-1248 # ffffffffc02073f8 <commands+0x9e0>
ffffffffc02018e0:	06900593          	li	a1,105
ffffffffc02018e4:	00006517          	auipc	a0,0x6
ffffffffc02018e8:	88450513          	addi	a0,a0,-1916 # ffffffffc0207168 <commands+0x750>
ffffffffc02018ec:	91dfe0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02018f0:	00006617          	auipc	a2,0x6
ffffffffc02018f4:	c3860613          	addi	a2,a2,-968 # ffffffffc0207528 <commands+0xb10>
ffffffffc02018f8:	07400593          	li	a1,116
ffffffffc02018fc:	00006517          	auipc	a0,0x6
ffffffffc0201900:	86c50513          	addi	a0,a0,-1940 # ffffffffc0207168 <commands+0x750>
ffffffffc0201904:	905fe0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0201908:	d3eff0ef          	jal	ra,ffffffffc0200e46 <pa2page.part.0>

ffffffffc020190c <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc020190c:	7179                	addi	sp,sp,-48
ffffffffc020190e:	f022                	sd	s0,32(sp)
ffffffffc0201910:	f406                	sd	ra,40(sp)
ffffffffc0201912:	ec26                	sd	s1,24(sp)
ffffffffc0201914:	e84a                	sd	s2,16(sp)
ffffffffc0201916:	e44e                	sd	s3,8(sp)
ffffffffc0201918:	e052                	sd	s4,0(sp)
ffffffffc020191a:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc020191c:	c135                	beqz	a0,ffffffffc0201980 <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc020191e:	002007b7          	lui	a5,0x200
ffffffffc0201922:	04f5e663          	bltu	a1,a5,ffffffffc020196e <user_mem_check+0x62>
ffffffffc0201926:	00c584b3          	add	s1,a1,a2
ffffffffc020192a:	0495f263          	bgeu	a1,s1,ffffffffc020196e <user_mem_check+0x62>
ffffffffc020192e:	4785                	li	a5,1
ffffffffc0201930:	07fe                	slli	a5,a5,0x1f
ffffffffc0201932:	0297ee63          	bltu	a5,s1,ffffffffc020196e <user_mem_check+0x62>
ffffffffc0201936:	892a                	mv	s2,a0
ffffffffc0201938:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc020193a:	6a05                	lui	s4,0x1
ffffffffc020193c:	a821                	j	ffffffffc0201954 <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc020193e:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0201942:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0201944:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0201946:	c685                	beqz	a3,ffffffffc020196e <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0201948:	c399                	beqz	a5,ffffffffc020194e <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc020194a:	02e46263          	bltu	s0,a4,ffffffffc020196e <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc020194e:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc0201950:	04947663          	bgeu	s0,s1,ffffffffc020199c <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc0201954:	85a2                	mv	a1,s0
ffffffffc0201956:	854a                	mv	a0,s2
ffffffffc0201958:	d80ff0ef          	jal	ra,ffffffffc0200ed8 <find_vma>
ffffffffc020195c:	c909                	beqz	a0,ffffffffc020196e <user_mem_check+0x62>
ffffffffc020195e:	6518                	ld	a4,8(a0)
ffffffffc0201960:	00e46763          	bltu	s0,a4,ffffffffc020196e <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0201964:	4d1c                	lw	a5,24(a0)
ffffffffc0201966:	fc099ce3          	bnez	s3,ffffffffc020193e <user_mem_check+0x32>
ffffffffc020196a:	8b85                	andi	a5,a5,1
ffffffffc020196c:	f3ed                	bnez	a5,ffffffffc020194e <user_mem_check+0x42>
            return 0;
ffffffffc020196e:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0201970:	70a2                	ld	ra,40(sp)
ffffffffc0201972:	7402                	ld	s0,32(sp)
ffffffffc0201974:	64e2                	ld	s1,24(sp)
ffffffffc0201976:	6942                	ld	s2,16(sp)
ffffffffc0201978:	69a2                	ld	s3,8(sp)
ffffffffc020197a:	6a02                	ld	s4,0(sp)
ffffffffc020197c:	6145                	addi	sp,sp,48
ffffffffc020197e:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0201980:	c02007b7          	lui	a5,0xc0200
ffffffffc0201984:	4501                	li	a0,0
ffffffffc0201986:	fef5e5e3          	bltu	a1,a5,ffffffffc0201970 <user_mem_check+0x64>
ffffffffc020198a:	962e                	add	a2,a2,a1
ffffffffc020198c:	fec5f2e3          	bgeu	a1,a2,ffffffffc0201970 <user_mem_check+0x64>
ffffffffc0201990:	c8000537          	lui	a0,0xc8000
ffffffffc0201994:	0505                	addi	a0,a0,1
ffffffffc0201996:	00a63533          	sltu	a0,a2,a0
ffffffffc020199a:	bfd9                	j	ffffffffc0201970 <user_mem_check+0x64>
        return 1;
ffffffffc020199c:	4505                	li	a0,1
ffffffffc020199e:	bfc9                	j	ffffffffc0201970 <user_mem_check+0x64>

ffffffffc02019a0 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc02019a0:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc02019a2:	00005617          	auipc	a2,0x5
ffffffffc02019a6:	7a660613          	addi	a2,a2,1958 # ffffffffc0207148 <commands+0x730>
ffffffffc02019aa:	06200593          	li	a1,98
ffffffffc02019ae:	00005517          	auipc	a0,0x5
ffffffffc02019b2:	7ba50513          	addi	a0,a0,1978 # ffffffffc0207168 <commands+0x750>
pa2page(uintptr_t pa) {
ffffffffc02019b6:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02019b8:	851fe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02019bc <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc02019bc:	7135                	addi	sp,sp,-160
ffffffffc02019be:	ed06                	sd	ra,152(sp)
ffffffffc02019c0:	e922                	sd	s0,144(sp)
ffffffffc02019c2:	e526                	sd	s1,136(sp)
ffffffffc02019c4:	e14a                	sd	s2,128(sp)
ffffffffc02019c6:	fcce                	sd	s3,120(sp)
ffffffffc02019c8:	f8d2                	sd	s4,112(sp)
ffffffffc02019ca:	f4d6                	sd	s5,104(sp)
ffffffffc02019cc:	f0da                	sd	s6,96(sp)
ffffffffc02019ce:	ecde                	sd	s7,88(sp)
ffffffffc02019d0:	e8e2                	sd	s8,80(sp)
ffffffffc02019d2:	e4e6                	sd	s9,72(sp)
ffffffffc02019d4:	e0ea                	sd	s10,64(sp)
ffffffffc02019d6:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc02019d8:	330030ef          	jal	ra,ffffffffc0204d08 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc02019dc:	000b1697          	auipc	a3,0xb1
ffffffffc02019e0:	ef46b683          	ld	a3,-268(a3) # ffffffffc02b28d0 <max_swap_offset>
ffffffffc02019e4:	010007b7          	lui	a5,0x1000
ffffffffc02019e8:	ff968713          	addi	a4,a3,-7
ffffffffc02019ec:	17e1                	addi	a5,a5,-8
ffffffffc02019ee:	42e7e663          	bltu	a5,a4,ffffffffc0201e1a <swap_init+0x45e>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc02019f2:	000a6797          	auipc	a5,0xa6
ffffffffc02019f6:	99e78793          	addi	a5,a5,-1634 # ffffffffc02a7390 <swap_manager_fifo>
     int r = sm->init();
ffffffffc02019fa:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc02019fc:	000b1b97          	auipc	s7,0xb1
ffffffffc0201a00:	edcb8b93          	addi	s7,s7,-292 # ffffffffc02b28d8 <sm>
ffffffffc0201a04:	00fbb023          	sd	a5,0(s7)
     int r = sm->init();
ffffffffc0201a08:	9702                	jalr	a4
ffffffffc0201a0a:	892a                	mv	s2,a0
     
     if (r == 0)
ffffffffc0201a0c:	c10d                	beqz	a0,ffffffffc0201a2e <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0201a0e:	60ea                	ld	ra,152(sp)
ffffffffc0201a10:	644a                	ld	s0,144(sp)
ffffffffc0201a12:	64aa                	ld	s1,136(sp)
ffffffffc0201a14:	79e6                	ld	s3,120(sp)
ffffffffc0201a16:	7a46                	ld	s4,112(sp)
ffffffffc0201a18:	7aa6                	ld	s5,104(sp)
ffffffffc0201a1a:	7b06                	ld	s6,96(sp)
ffffffffc0201a1c:	6be6                	ld	s7,88(sp)
ffffffffc0201a1e:	6c46                	ld	s8,80(sp)
ffffffffc0201a20:	6ca6                	ld	s9,72(sp)
ffffffffc0201a22:	6d06                	ld	s10,64(sp)
ffffffffc0201a24:	7de2                	ld	s11,56(sp)
ffffffffc0201a26:	854a                	mv	a0,s2
ffffffffc0201a28:	690a                	ld	s2,128(sp)
ffffffffc0201a2a:	610d                	addi	sp,sp,160
ffffffffc0201a2c:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0201a2e:	000bb783          	ld	a5,0(s7)
ffffffffc0201a32:	00006517          	auipc	a0,0x6
ffffffffc0201a36:	b4e50513          	addi	a0,a0,-1202 # ffffffffc0207580 <commands+0xb68>
ffffffffc0201a3a:	000ad417          	auipc	s0,0xad
ffffffffc0201a3e:	e4640413          	addi	s0,s0,-442 # ffffffffc02ae880 <free_area>
ffffffffc0201a42:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0201a44:	4785                	li	a5,1
ffffffffc0201a46:	000b1717          	auipc	a4,0xb1
ffffffffc0201a4a:	e8f72d23          	sw	a5,-358(a4) # ffffffffc02b28e0 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0201a4e:	e7efe0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0201a52:	641c                	ld	a5,8(s0)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc0201a54:	4d01                	li	s10,0
ffffffffc0201a56:	4d81                	li	s11,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201a58:	34878163          	beq	a5,s0,ffffffffc0201d9a <swap_init+0x3de>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201a5c:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0201a60:	8b09                	andi	a4,a4,2
ffffffffc0201a62:	32070e63          	beqz	a4,ffffffffc0201d9e <swap_init+0x3e2>
        count ++, total += p->property;
ffffffffc0201a66:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201a6a:	679c                	ld	a5,8(a5)
ffffffffc0201a6c:	2d85                	addiw	s11,s11,1
ffffffffc0201a6e:	01a70d3b          	addw	s10,a4,s10
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201a72:	fe8795e3          	bne	a5,s0,ffffffffc0201a5c <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc0201a76:	84ea                	mv	s1,s10
ffffffffc0201a78:	3b3010ef          	jal	ra,ffffffffc020362a <nr_free_pages>
ffffffffc0201a7c:	42951763          	bne	a0,s1,ffffffffc0201eaa <swap_init+0x4ee>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0201a80:	866a                	mv	a2,s10
ffffffffc0201a82:	85ee                	mv	a1,s11
ffffffffc0201a84:	00006517          	auipc	a0,0x6
ffffffffc0201a88:	b4450513          	addi	a0,a0,-1212 # ffffffffc02075c8 <commands+0xbb0>
ffffffffc0201a8c:	e40fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0201a90:	bd2ff0ef          	jal	ra,ffffffffc0200e62 <mm_create>
ffffffffc0201a94:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc0201a96:	46050a63          	beqz	a0,ffffffffc0201f0a <swap_init+0x54e>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0201a9a:	000b1797          	auipc	a5,0xb1
ffffffffc0201a9e:	e2678793          	addi	a5,a5,-474 # ffffffffc02b28c0 <check_mm_struct>
ffffffffc0201aa2:	6398                	ld	a4,0(a5)
ffffffffc0201aa4:	3e071363          	bnez	a4,ffffffffc0201e8a <swap_init+0x4ce>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0201aa8:	000b1717          	auipc	a4,0xb1
ffffffffc0201aac:	e5070713          	addi	a4,a4,-432 # ffffffffc02b28f8 <boot_pgdir>
ffffffffc0201ab0:	00073b03          	ld	s6,0(a4)
     check_mm_struct = mm;
ffffffffc0201ab4:	e388                	sd	a0,0(a5)
     assert(pgdir[0] == 0);
ffffffffc0201ab6:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0201aba:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0201abe:	42079663          	bnez	a5,ffffffffc0201eea <swap_init+0x52e>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0201ac2:	6599                	lui	a1,0x6
ffffffffc0201ac4:	460d                	li	a2,3
ffffffffc0201ac6:	6505                	lui	a0,0x1
ffffffffc0201ac8:	be2ff0ef          	jal	ra,ffffffffc0200eaa <vma_create>
ffffffffc0201acc:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0201ace:	52050a63          	beqz	a0,ffffffffc0202002 <swap_init+0x646>

     insert_vma_struct(mm, vma);
ffffffffc0201ad2:	8556                	mv	a0,s5
ffffffffc0201ad4:	c44ff0ef          	jal	ra,ffffffffc0200f18 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0201ad8:	00006517          	auipc	a0,0x6
ffffffffc0201adc:	b3050513          	addi	a0,a0,-1232 # ffffffffc0207608 <commands+0xbf0>
ffffffffc0201ae0:	decfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0201ae4:	018ab503          	ld	a0,24(s5)
ffffffffc0201ae8:	4605                	li	a2,1
ffffffffc0201aea:	6585                	lui	a1,0x1
ffffffffc0201aec:	379010ef          	jal	ra,ffffffffc0203664 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0201af0:	4c050963          	beqz	a0,ffffffffc0201fc2 <swap_init+0x606>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0201af4:	00006517          	auipc	a0,0x6
ffffffffc0201af8:	b6450513          	addi	a0,a0,-1180 # ffffffffc0207658 <commands+0xc40>
ffffffffc0201afc:	000ad497          	auipc	s1,0xad
ffffffffc0201b00:	d0448493          	addi	s1,s1,-764 # ffffffffc02ae800 <check_rp>
ffffffffc0201b04:	dc8fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201b08:	000ad997          	auipc	s3,0xad
ffffffffc0201b0c:	d1898993          	addi	s3,s3,-744 # ffffffffc02ae820 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0201b10:	8a26                	mv	s4,s1
          check_rp[i] = alloc_page();
ffffffffc0201b12:	4505                	li	a0,1
ffffffffc0201b14:	245010ef          	jal	ra,ffffffffc0203558 <alloc_pages>
ffffffffc0201b18:	00aa3023          	sd	a0,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bc0>
          assert(check_rp[i] != NULL );
ffffffffc0201b1c:	2c050f63          	beqz	a0,ffffffffc0201dfa <swap_init+0x43e>
ffffffffc0201b20:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0201b22:	8b89                	andi	a5,a5,2
ffffffffc0201b24:	34079363          	bnez	a5,ffffffffc0201e6a <swap_init+0x4ae>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201b28:	0a21                	addi	s4,s4,8
ffffffffc0201b2a:	ff3a14e3          	bne	s4,s3,ffffffffc0201b12 <swap_init+0x156>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0201b2e:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0201b30:	000ada17          	auipc	s4,0xad
ffffffffc0201b34:	cd0a0a13          	addi	s4,s4,-816 # ffffffffc02ae800 <check_rp>
    elm->prev = elm->next = elm;
ffffffffc0201b38:	e000                	sd	s0,0(s0)
     list_entry_t free_list_store = free_list;
ffffffffc0201b3a:	ec3e                	sd	a5,24(sp)
ffffffffc0201b3c:	641c                	ld	a5,8(s0)
ffffffffc0201b3e:	e400                	sd	s0,8(s0)
ffffffffc0201b40:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0201b42:	481c                	lw	a5,16(s0)
ffffffffc0201b44:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc0201b46:	000ad797          	auipc	a5,0xad
ffffffffc0201b4a:	d407a523          	sw	zero,-694(a5) # ffffffffc02ae890 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0201b4e:	000a3503          	ld	a0,0(s4)
ffffffffc0201b52:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201b54:	0a21                	addi	s4,s4,8
        free_pages(check_rp[i],1);
ffffffffc0201b56:	295010ef          	jal	ra,ffffffffc02035ea <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201b5a:	ff3a1ae3          	bne	s4,s3,ffffffffc0201b4e <swap_init+0x192>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0201b5e:	01042a03          	lw	s4,16(s0)
ffffffffc0201b62:	4791                	li	a5,4
ffffffffc0201b64:	42fa1f63          	bne	s4,a5,ffffffffc0201fa2 <swap_init+0x5e6>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0201b68:	00006517          	auipc	a0,0x6
ffffffffc0201b6c:	b7850513          	addi	a0,a0,-1160 # ffffffffc02076e0 <commands+0xcc8>
ffffffffc0201b70:	d5cfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201b74:	6705                	lui	a4,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0201b76:	000b1797          	auipc	a5,0xb1
ffffffffc0201b7a:	d407a923          	sw	zero,-686(a5) # ffffffffc02b28c8 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201b7e:	4629                	li	a2,10
ffffffffc0201b80:	00c70023          	sb	a2,0(a4) # 1000 <_binary_obj___user_faultread_out_size-0x8bc0>
     assert(pgfault_num==1);
ffffffffc0201b84:	000b1697          	auipc	a3,0xb1
ffffffffc0201b88:	d446a683          	lw	a3,-700(a3) # ffffffffc02b28c8 <pgfault_num>
ffffffffc0201b8c:	4585                	li	a1,1
ffffffffc0201b8e:	000b1797          	auipc	a5,0xb1
ffffffffc0201b92:	d3a78793          	addi	a5,a5,-710 # ffffffffc02b28c8 <pgfault_num>
ffffffffc0201b96:	54b69663          	bne	a3,a1,ffffffffc02020e2 <swap_init+0x726>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0201b9a:	00c70823          	sb	a2,16(a4)
     assert(pgfault_num==1);
ffffffffc0201b9e:	4398                	lw	a4,0(a5)
ffffffffc0201ba0:	2701                	sext.w	a4,a4
ffffffffc0201ba2:	3ed71063          	bne	a4,a3,ffffffffc0201f82 <swap_init+0x5c6>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201ba6:	6689                	lui	a3,0x2
ffffffffc0201ba8:	462d                	li	a2,11
ffffffffc0201baa:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x7bc0>
     assert(pgfault_num==2);
ffffffffc0201bae:	4398                	lw	a4,0(a5)
ffffffffc0201bb0:	4589                	li	a1,2
ffffffffc0201bb2:	2701                	sext.w	a4,a4
ffffffffc0201bb4:	4ab71763          	bne	a4,a1,ffffffffc0202062 <swap_init+0x6a6>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0201bb8:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0201bbc:	4394                	lw	a3,0(a5)
ffffffffc0201bbe:	2681                	sext.w	a3,a3
ffffffffc0201bc0:	4ce69163          	bne	a3,a4,ffffffffc0202082 <swap_init+0x6c6>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201bc4:	668d                	lui	a3,0x3
ffffffffc0201bc6:	4631                	li	a2,12
ffffffffc0201bc8:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x6bc0>
     assert(pgfault_num==3);
ffffffffc0201bcc:	4398                	lw	a4,0(a5)
ffffffffc0201bce:	458d                	li	a1,3
ffffffffc0201bd0:	2701                	sext.w	a4,a4
ffffffffc0201bd2:	4cb71863          	bne	a4,a1,ffffffffc02020a2 <swap_init+0x6e6>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0201bd6:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0201bda:	4394                	lw	a3,0(a5)
ffffffffc0201bdc:	2681                	sext.w	a3,a3
ffffffffc0201bde:	4ee69263          	bne	a3,a4,ffffffffc02020c2 <swap_init+0x706>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201be2:	6691                	lui	a3,0x4
ffffffffc0201be4:	4635                	li	a2,13
ffffffffc0201be6:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x5bc0>
     assert(pgfault_num==4);
ffffffffc0201bea:	4398                	lw	a4,0(a5)
ffffffffc0201bec:	2701                	sext.w	a4,a4
ffffffffc0201bee:	43471a63          	bne	a4,s4,ffffffffc0202022 <swap_init+0x666>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0201bf2:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0201bf6:	439c                	lw	a5,0(a5)
ffffffffc0201bf8:	2781                	sext.w	a5,a5
ffffffffc0201bfa:	44e79463          	bne	a5,a4,ffffffffc0202042 <swap_init+0x686>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0201bfe:	481c                	lw	a5,16(s0)
ffffffffc0201c00:	2c079563          	bnez	a5,ffffffffc0201eca <swap_init+0x50e>
ffffffffc0201c04:	000ad797          	auipc	a5,0xad
ffffffffc0201c08:	c1c78793          	addi	a5,a5,-996 # ffffffffc02ae820 <swap_in_seq_no>
ffffffffc0201c0c:	000ad717          	auipc	a4,0xad
ffffffffc0201c10:	c3c70713          	addi	a4,a4,-964 # ffffffffc02ae848 <swap_out_seq_no>
ffffffffc0201c14:	000ad617          	auipc	a2,0xad
ffffffffc0201c18:	c3460613          	addi	a2,a2,-972 # ffffffffc02ae848 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0201c1c:	56fd                	li	a3,-1
ffffffffc0201c1e:	c394                	sw	a3,0(a5)
ffffffffc0201c20:	c314                	sw	a3,0(a4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0201c22:	0791                	addi	a5,a5,4
ffffffffc0201c24:	0711                	addi	a4,a4,4
ffffffffc0201c26:	fec79ce3          	bne	a5,a2,ffffffffc0201c1e <swap_init+0x262>
ffffffffc0201c2a:	000ad717          	auipc	a4,0xad
ffffffffc0201c2e:	bb670713          	addi	a4,a4,-1098 # ffffffffc02ae7e0 <check_ptep>
ffffffffc0201c32:	000ad697          	auipc	a3,0xad
ffffffffc0201c36:	bce68693          	addi	a3,a3,-1074 # ffffffffc02ae800 <check_rp>
ffffffffc0201c3a:	6585                	lui	a1,0x1
    if (PPN(pa) >= npage) {
ffffffffc0201c3c:	000b1c17          	auipc	s8,0xb1
ffffffffc0201c40:	cc4c0c13          	addi	s8,s8,-828 # ffffffffc02b2900 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0201c44:	000b1c97          	auipc	s9,0xb1
ffffffffc0201c48:	cc4c8c93          	addi	s9,s9,-828 # ffffffffc02b2908 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0201c4c:	00073023          	sd	zero,0(a4)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0201c50:	4601                	li	a2,0
ffffffffc0201c52:	855a                	mv	a0,s6
ffffffffc0201c54:	e836                	sd	a3,16(sp)
ffffffffc0201c56:	e42e                	sd	a1,8(sp)
         check_ptep[i]=0;
ffffffffc0201c58:	e03a                	sd	a4,0(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0201c5a:	20b010ef          	jal	ra,ffffffffc0203664 <get_pte>
ffffffffc0201c5e:	6702                	ld	a4,0(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0201c60:	65a2                	ld	a1,8(sp)
ffffffffc0201c62:	66c2                	ld	a3,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0201c64:	e308                	sd	a0,0(a4)
         assert(check_ptep[i] != NULL);
ffffffffc0201c66:	1c050663          	beqz	a0,ffffffffc0201e32 <swap_init+0x476>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0201c6a:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201c6c:	0017f613          	andi	a2,a5,1
ffffffffc0201c70:	1e060163          	beqz	a2,ffffffffc0201e52 <swap_init+0x496>
    if (PPN(pa) >= npage) {
ffffffffc0201c74:	000c3603          	ld	a2,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201c78:	078a                	slli	a5,a5,0x2
ffffffffc0201c7a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201c7c:	14c7f363          	bgeu	a5,a2,ffffffffc0201dc2 <swap_init+0x406>
    return &pages[PPN(pa) - nbase];
ffffffffc0201c80:	00007617          	auipc	a2,0x7
ffffffffc0201c84:	1f060613          	addi	a2,a2,496 # ffffffffc0208e70 <nbase>
ffffffffc0201c88:	00063a03          	ld	s4,0(a2)
ffffffffc0201c8c:	000cb603          	ld	a2,0(s9)
ffffffffc0201c90:	6288                	ld	a0,0(a3)
ffffffffc0201c92:	414787b3          	sub	a5,a5,s4
ffffffffc0201c96:	079a                	slli	a5,a5,0x6
ffffffffc0201c98:	97b2                	add	a5,a5,a2
ffffffffc0201c9a:	14f51063          	bne	a0,a5,ffffffffc0201dda <swap_init+0x41e>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201c9e:	6785                	lui	a5,0x1
ffffffffc0201ca0:	95be                	add	a1,a1,a5
ffffffffc0201ca2:	6795                	lui	a5,0x5
ffffffffc0201ca4:	0721                	addi	a4,a4,8
ffffffffc0201ca6:	06a1                	addi	a3,a3,8
ffffffffc0201ca8:	faf592e3          	bne	a1,a5,ffffffffc0201c4c <swap_init+0x290>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0201cac:	00006517          	auipc	a0,0x6
ffffffffc0201cb0:	aec50513          	addi	a0,a0,-1300 # ffffffffc0207798 <commands+0xd80>
ffffffffc0201cb4:	c18fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    int ret = sm->check_swap();
ffffffffc0201cb8:	000bb783          	ld	a5,0(s7)
ffffffffc0201cbc:	7f9c                	ld	a5,56(a5)
ffffffffc0201cbe:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0201cc0:	32051163          	bnez	a0,ffffffffc0201fe2 <swap_init+0x626>

     nr_free = nr_free_store;
ffffffffc0201cc4:	77a2                	ld	a5,40(sp)
ffffffffc0201cc6:	c81c                	sw	a5,16(s0)
     free_list = free_list_store;
ffffffffc0201cc8:	67e2                	ld	a5,24(sp)
ffffffffc0201cca:	e01c                	sd	a5,0(s0)
ffffffffc0201ccc:	7782                	ld	a5,32(sp)
ffffffffc0201cce:	e41c                	sd	a5,8(s0)

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0201cd0:	6088                	ld	a0,0(s1)
ffffffffc0201cd2:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201cd4:	04a1                	addi	s1,s1,8
         free_pages(check_rp[i],1);
ffffffffc0201cd6:	115010ef          	jal	ra,ffffffffc02035ea <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201cda:	ff349be3          	bne	s1,s3,ffffffffc0201cd0 <swap_init+0x314>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc0201cde:	000abc23          	sd	zero,24(s5)
     mm_destroy(mm);
ffffffffc0201ce2:	8556                	mv	a0,s5
ffffffffc0201ce4:	b04ff0ef          	jal	ra,ffffffffc0200fe8 <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0201ce8:	000b1797          	auipc	a5,0xb1
ffffffffc0201cec:	c1078793          	addi	a5,a5,-1008 # ffffffffc02b28f8 <boot_pgdir>
ffffffffc0201cf0:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0201cf2:	000c3703          	ld	a4,0(s8)
     check_mm_struct = NULL;
ffffffffc0201cf6:	000b1697          	auipc	a3,0xb1
ffffffffc0201cfa:	bc06b523          	sd	zero,-1078(a3) # ffffffffc02b28c0 <check_mm_struct>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201cfe:	639c                	ld	a5,0(a5)
ffffffffc0201d00:	078a                	slli	a5,a5,0x2
ffffffffc0201d02:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201d04:	0ae7fd63          	bgeu	a5,a4,ffffffffc0201dbe <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc0201d08:	414786b3          	sub	a3,a5,s4
ffffffffc0201d0c:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0201d0e:	8699                	srai	a3,a3,0x6
ffffffffc0201d10:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0201d12:	00c69793          	slli	a5,a3,0xc
ffffffffc0201d16:	83b1                	srli	a5,a5,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0201d18:	000cb503          	ld	a0,0(s9)
    return page2ppn(page) << PGSHIFT;
ffffffffc0201d1c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201d1e:	22e7f663          	bgeu	a5,a4,ffffffffc0201f4a <swap_init+0x58e>
     free_page(pde2page(pd0[0]));
ffffffffc0201d22:	000b1797          	auipc	a5,0xb1
ffffffffc0201d26:	bf67b783          	ld	a5,-1034(a5) # ffffffffc02b2918 <va_pa_offset>
ffffffffc0201d2a:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201d2c:	629c                	ld	a5,0(a3)
ffffffffc0201d2e:	078a                	slli	a5,a5,0x2
ffffffffc0201d30:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201d32:	08e7f663          	bgeu	a5,a4,ffffffffc0201dbe <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc0201d36:	414787b3          	sub	a5,a5,s4
ffffffffc0201d3a:	079a                	slli	a5,a5,0x6
ffffffffc0201d3c:	953e                	add	a0,a0,a5
ffffffffc0201d3e:	4585                	li	a1,1
ffffffffc0201d40:	0ab010ef          	jal	ra,ffffffffc02035ea <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201d44:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0201d48:	000c3703          	ld	a4,0(s8)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201d4c:	078a                	slli	a5,a5,0x2
ffffffffc0201d4e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201d50:	06e7f763          	bgeu	a5,a4,ffffffffc0201dbe <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc0201d54:	000cb503          	ld	a0,0(s9)
ffffffffc0201d58:	414787b3          	sub	a5,a5,s4
ffffffffc0201d5c:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0201d5e:	4585                	li	a1,1
ffffffffc0201d60:	953e                	add	a0,a0,a5
ffffffffc0201d62:	089010ef          	jal	ra,ffffffffc02035ea <free_pages>
     pgdir[0] = 0;
ffffffffc0201d66:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0201d6a:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0201d6e:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201d70:	00878a63          	beq	a5,s0,ffffffffc0201d84 <swap_init+0x3c8>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0201d74:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201d78:	679c                	ld	a5,8(a5)
ffffffffc0201d7a:	3dfd                	addiw	s11,s11,-1
ffffffffc0201d7c:	40ed0d3b          	subw	s10,s10,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201d80:	fe879ae3          	bne	a5,s0,ffffffffc0201d74 <swap_init+0x3b8>
     }
     assert(count==0);
ffffffffc0201d84:	1c0d9f63          	bnez	s11,ffffffffc0201f62 <swap_init+0x5a6>
     assert(total==0);
ffffffffc0201d88:	1a0d1163          	bnez	s10,ffffffffc0201f2a <swap_init+0x56e>

     cprintf("check_swap() succeeded!\n");
ffffffffc0201d8c:	00006517          	auipc	a0,0x6
ffffffffc0201d90:	a5c50513          	addi	a0,a0,-1444 # ffffffffc02077e8 <commands+0xdd0>
ffffffffc0201d94:	b38fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc0201d98:	b99d                	j	ffffffffc0201a0e <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201d9a:	4481                	li	s1,0
ffffffffc0201d9c:	b9f1                	j	ffffffffc0201a78 <swap_init+0xbc>
        assert(PageProperty(p));
ffffffffc0201d9e:	00005697          	auipc	a3,0x5
ffffffffc0201da2:	7fa68693          	addi	a3,a3,2042 # ffffffffc0207598 <commands+0xb80>
ffffffffc0201da6:	00005617          	auipc	a2,0x5
ffffffffc0201daa:	08260613          	addi	a2,a2,130 # ffffffffc0206e28 <commands+0x410>
ffffffffc0201dae:	0bc00593          	li	a1,188
ffffffffc0201db2:	00005517          	auipc	a0,0x5
ffffffffc0201db6:	7be50513          	addi	a0,a0,1982 # ffffffffc0207570 <commands+0xb58>
ffffffffc0201dba:	c4efe0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0201dbe:	be3ff0ef          	jal	ra,ffffffffc02019a0 <pa2page.part.0>
        panic("pa2page called with invalid pa");
ffffffffc0201dc2:	00005617          	auipc	a2,0x5
ffffffffc0201dc6:	38660613          	addi	a2,a2,902 # ffffffffc0207148 <commands+0x730>
ffffffffc0201dca:	06200593          	li	a1,98
ffffffffc0201dce:	00005517          	auipc	a0,0x5
ffffffffc0201dd2:	39a50513          	addi	a0,a0,922 # ffffffffc0207168 <commands+0x750>
ffffffffc0201dd6:	c32fe0ef          	jal	ra,ffffffffc0200208 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0201dda:	00006697          	auipc	a3,0x6
ffffffffc0201dde:	99668693          	addi	a3,a3,-1642 # ffffffffc0207770 <commands+0xd58>
ffffffffc0201de2:	00005617          	auipc	a2,0x5
ffffffffc0201de6:	04660613          	addi	a2,a2,70 # ffffffffc0206e28 <commands+0x410>
ffffffffc0201dea:	0fc00593          	li	a1,252
ffffffffc0201dee:	00005517          	auipc	a0,0x5
ffffffffc0201df2:	78250513          	addi	a0,a0,1922 # ffffffffc0207570 <commands+0xb58>
ffffffffc0201df6:	c12fe0ef          	jal	ra,ffffffffc0200208 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0201dfa:	00006697          	auipc	a3,0x6
ffffffffc0201dfe:	88668693          	addi	a3,a3,-1914 # ffffffffc0207680 <commands+0xc68>
ffffffffc0201e02:	00005617          	auipc	a2,0x5
ffffffffc0201e06:	02660613          	addi	a2,a2,38 # ffffffffc0206e28 <commands+0x410>
ffffffffc0201e0a:	0dc00593          	li	a1,220
ffffffffc0201e0e:	00005517          	auipc	a0,0x5
ffffffffc0201e12:	76250513          	addi	a0,a0,1890 # ffffffffc0207570 <commands+0xb58>
ffffffffc0201e16:	bf2fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0201e1a:	00005617          	auipc	a2,0x5
ffffffffc0201e1e:	73660613          	addi	a2,a2,1846 # ffffffffc0207550 <commands+0xb38>
ffffffffc0201e22:	02800593          	li	a1,40
ffffffffc0201e26:	00005517          	auipc	a0,0x5
ffffffffc0201e2a:	74a50513          	addi	a0,a0,1866 # ffffffffc0207570 <commands+0xb58>
ffffffffc0201e2e:	bdafe0ef          	jal	ra,ffffffffc0200208 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0201e32:	00006697          	auipc	a3,0x6
ffffffffc0201e36:	92668693          	addi	a3,a3,-1754 # ffffffffc0207758 <commands+0xd40>
ffffffffc0201e3a:	00005617          	auipc	a2,0x5
ffffffffc0201e3e:	fee60613          	addi	a2,a2,-18 # ffffffffc0206e28 <commands+0x410>
ffffffffc0201e42:	0fb00593          	li	a1,251
ffffffffc0201e46:	00005517          	auipc	a0,0x5
ffffffffc0201e4a:	72a50513          	addi	a0,a0,1834 # ffffffffc0207570 <commands+0xb58>
ffffffffc0201e4e:	bbafe0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0201e52:	00005617          	auipc	a2,0x5
ffffffffc0201e56:	6d660613          	addi	a2,a2,1750 # ffffffffc0207528 <commands+0xb10>
ffffffffc0201e5a:	07400593          	li	a1,116
ffffffffc0201e5e:	00005517          	auipc	a0,0x5
ffffffffc0201e62:	30a50513          	addi	a0,a0,778 # ffffffffc0207168 <commands+0x750>
ffffffffc0201e66:	ba2fe0ef          	jal	ra,ffffffffc0200208 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0201e6a:	00006697          	auipc	a3,0x6
ffffffffc0201e6e:	82e68693          	addi	a3,a3,-2002 # ffffffffc0207698 <commands+0xc80>
ffffffffc0201e72:	00005617          	auipc	a2,0x5
ffffffffc0201e76:	fb660613          	addi	a2,a2,-74 # ffffffffc0206e28 <commands+0x410>
ffffffffc0201e7a:	0dd00593          	li	a1,221
ffffffffc0201e7e:	00005517          	auipc	a0,0x5
ffffffffc0201e82:	6f250513          	addi	a0,a0,1778 # ffffffffc0207570 <commands+0xb58>
ffffffffc0201e86:	b82fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0201e8a:	00005697          	auipc	a3,0x5
ffffffffc0201e8e:	76668693          	addi	a3,a3,1894 # ffffffffc02075f0 <commands+0xbd8>
ffffffffc0201e92:	00005617          	auipc	a2,0x5
ffffffffc0201e96:	f9660613          	addi	a2,a2,-106 # ffffffffc0206e28 <commands+0x410>
ffffffffc0201e9a:	0c700593          	li	a1,199
ffffffffc0201e9e:	00005517          	auipc	a0,0x5
ffffffffc0201ea2:	6d250513          	addi	a0,a0,1746 # ffffffffc0207570 <commands+0xb58>
ffffffffc0201ea6:	b62fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(total == nr_free_pages());
ffffffffc0201eaa:	00005697          	auipc	a3,0x5
ffffffffc0201eae:	6fe68693          	addi	a3,a3,1790 # ffffffffc02075a8 <commands+0xb90>
ffffffffc0201eb2:	00005617          	auipc	a2,0x5
ffffffffc0201eb6:	f7660613          	addi	a2,a2,-138 # ffffffffc0206e28 <commands+0x410>
ffffffffc0201eba:	0bf00593          	li	a1,191
ffffffffc0201ebe:	00005517          	auipc	a0,0x5
ffffffffc0201ec2:	6b250513          	addi	a0,a0,1714 # ffffffffc0207570 <commands+0xb58>
ffffffffc0201ec6:	b42fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert( nr_free == 0);         
ffffffffc0201eca:	00006697          	auipc	a3,0x6
ffffffffc0201ece:	87e68693          	addi	a3,a3,-1922 # ffffffffc0207748 <commands+0xd30>
ffffffffc0201ed2:	00005617          	auipc	a2,0x5
ffffffffc0201ed6:	f5660613          	addi	a2,a2,-170 # ffffffffc0206e28 <commands+0x410>
ffffffffc0201eda:	0f300593          	li	a1,243
ffffffffc0201ede:	00005517          	auipc	a0,0x5
ffffffffc0201ee2:	69250513          	addi	a0,a0,1682 # ffffffffc0207570 <commands+0xb58>
ffffffffc0201ee6:	b22fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0201eea:	00005697          	auipc	a3,0x5
ffffffffc0201eee:	4ce68693          	addi	a3,a3,1230 # ffffffffc02073b8 <commands+0x9a0>
ffffffffc0201ef2:	00005617          	auipc	a2,0x5
ffffffffc0201ef6:	f3660613          	addi	a2,a2,-202 # ffffffffc0206e28 <commands+0x410>
ffffffffc0201efa:	0cc00593          	li	a1,204
ffffffffc0201efe:	00005517          	auipc	a0,0x5
ffffffffc0201f02:	67250513          	addi	a0,a0,1650 # ffffffffc0207570 <commands+0xb58>
ffffffffc0201f06:	b02fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(mm != NULL);
ffffffffc0201f0a:	00005697          	auipc	a3,0x5
ffffffffc0201f0e:	2e668693          	addi	a3,a3,742 # ffffffffc02071f0 <commands+0x7d8>
ffffffffc0201f12:	00005617          	auipc	a2,0x5
ffffffffc0201f16:	f1660613          	addi	a2,a2,-234 # ffffffffc0206e28 <commands+0x410>
ffffffffc0201f1a:	0c400593          	li	a1,196
ffffffffc0201f1e:	00005517          	auipc	a0,0x5
ffffffffc0201f22:	65250513          	addi	a0,a0,1618 # ffffffffc0207570 <commands+0xb58>
ffffffffc0201f26:	ae2fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(total==0);
ffffffffc0201f2a:	00006697          	auipc	a3,0x6
ffffffffc0201f2e:	8ae68693          	addi	a3,a3,-1874 # ffffffffc02077d8 <commands+0xdc0>
ffffffffc0201f32:	00005617          	auipc	a2,0x5
ffffffffc0201f36:	ef660613          	addi	a2,a2,-266 # ffffffffc0206e28 <commands+0x410>
ffffffffc0201f3a:	11e00593          	li	a1,286
ffffffffc0201f3e:	00005517          	auipc	a0,0x5
ffffffffc0201f42:	63250513          	addi	a0,a0,1586 # ffffffffc0207570 <commands+0xb58>
ffffffffc0201f46:	ac2fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc0201f4a:	00005617          	auipc	a2,0x5
ffffffffc0201f4e:	4ae60613          	addi	a2,a2,1198 # ffffffffc02073f8 <commands+0x9e0>
ffffffffc0201f52:	06900593          	li	a1,105
ffffffffc0201f56:	00005517          	auipc	a0,0x5
ffffffffc0201f5a:	21250513          	addi	a0,a0,530 # ffffffffc0207168 <commands+0x750>
ffffffffc0201f5e:	aaafe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(count==0);
ffffffffc0201f62:	00006697          	auipc	a3,0x6
ffffffffc0201f66:	86668693          	addi	a3,a3,-1946 # ffffffffc02077c8 <commands+0xdb0>
ffffffffc0201f6a:	00005617          	auipc	a2,0x5
ffffffffc0201f6e:	ebe60613          	addi	a2,a2,-322 # ffffffffc0206e28 <commands+0x410>
ffffffffc0201f72:	11d00593          	li	a1,285
ffffffffc0201f76:	00005517          	auipc	a0,0x5
ffffffffc0201f7a:	5fa50513          	addi	a0,a0,1530 # ffffffffc0207570 <commands+0xb58>
ffffffffc0201f7e:	a8afe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==1);
ffffffffc0201f82:	00005697          	auipc	a3,0x5
ffffffffc0201f86:	78668693          	addi	a3,a3,1926 # ffffffffc0207708 <commands+0xcf0>
ffffffffc0201f8a:	00005617          	auipc	a2,0x5
ffffffffc0201f8e:	e9e60613          	addi	a2,a2,-354 # ffffffffc0206e28 <commands+0x410>
ffffffffc0201f92:	09500593          	li	a1,149
ffffffffc0201f96:	00005517          	auipc	a0,0x5
ffffffffc0201f9a:	5da50513          	addi	a0,a0,1498 # ffffffffc0207570 <commands+0xb58>
ffffffffc0201f9e:	a6afe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0201fa2:	00005697          	auipc	a3,0x5
ffffffffc0201fa6:	71668693          	addi	a3,a3,1814 # ffffffffc02076b8 <commands+0xca0>
ffffffffc0201faa:	00005617          	auipc	a2,0x5
ffffffffc0201fae:	e7e60613          	addi	a2,a2,-386 # ffffffffc0206e28 <commands+0x410>
ffffffffc0201fb2:	0ea00593          	li	a1,234
ffffffffc0201fb6:	00005517          	auipc	a0,0x5
ffffffffc0201fba:	5ba50513          	addi	a0,a0,1466 # ffffffffc0207570 <commands+0xb58>
ffffffffc0201fbe:	a4afe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0201fc2:	00005697          	auipc	a3,0x5
ffffffffc0201fc6:	67e68693          	addi	a3,a3,1662 # ffffffffc0207640 <commands+0xc28>
ffffffffc0201fca:	00005617          	auipc	a2,0x5
ffffffffc0201fce:	e5e60613          	addi	a2,a2,-418 # ffffffffc0206e28 <commands+0x410>
ffffffffc0201fd2:	0d700593          	li	a1,215
ffffffffc0201fd6:	00005517          	auipc	a0,0x5
ffffffffc0201fda:	59a50513          	addi	a0,a0,1434 # ffffffffc0207570 <commands+0xb58>
ffffffffc0201fde:	a2afe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(ret==0);
ffffffffc0201fe2:	00005697          	auipc	a3,0x5
ffffffffc0201fe6:	7de68693          	addi	a3,a3,2014 # ffffffffc02077c0 <commands+0xda8>
ffffffffc0201fea:	00005617          	auipc	a2,0x5
ffffffffc0201fee:	e3e60613          	addi	a2,a2,-450 # ffffffffc0206e28 <commands+0x410>
ffffffffc0201ff2:	10200593          	li	a1,258
ffffffffc0201ff6:	00005517          	auipc	a0,0x5
ffffffffc0201ffa:	57a50513          	addi	a0,a0,1402 # ffffffffc0207570 <commands+0xb58>
ffffffffc0201ffe:	a0afe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(vma != NULL);
ffffffffc0202002:	00005697          	auipc	a3,0x5
ffffffffc0202006:	47e68693          	addi	a3,a3,1150 # ffffffffc0207480 <commands+0xa68>
ffffffffc020200a:	00005617          	auipc	a2,0x5
ffffffffc020200e:	e1e60613          	addi	a2,a2,-482 # ffffffffc0206e28 <commands+0x410>
ffffffffc0202012:	0cf00593          	li	a1,207
ffffffffc0202016:	00005517          	auipc	a0,0x5
ffffffffc020201a:	55a50513          	addi	a0,a0,1370 # ffffffffc0207570 <commands+0xb58>
ffffffffc020201e:	9eafe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==4);
ffffffffc0202022:	00005697          	auipc	a3,0x5
ffffffffc0202026:	71668693          	addi	a3,a3,1814 # ffffffffc0207738 <commands+0xd20>
ffffffffc020202a:	00005617          	auipc	a2,0x5
ffffffffc020202e:	dfe60613          	addi	a2,a2,-514 # ffffffffc0206e28 <commands+0x410>
ffffffffc0202032:	09f00593          	li	a1,159
ffffffffc0202036:	00005517          	auipc	a0,0x5
ffffffffc020203a:	53a50513          	addi	a0,a0,1338 # ffffffffc0207570 <commands+0xb58>
ffffffffc020203e:	9cafe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==4);
ffffffffc0202042:	00005697          	auipc	a3,0x5
ffffffffc0202046:	6f668693          	addi	a3,a3,1782 # ffffffffc0207738 <commands+0xd20>
ffffffffc020204a:	00005617          	auipc	a2,0x5
ffffffffc020204e:	dde60613          	addi	a2,a2,-546 # ffffffffc0206e28 <commands+0x410>
ffffffffc0202052:	0a100593          	li	a1,161
ffffffffc0202056:	00005517          	auipc	a0,0x5
ffffffffc020205a:	51a50513          	addi	a0,a0,1306 # ffffffffc0207570 <commands+0xb58>
ffffffffc020205e:	9aafe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==2);
ffffffffc0202062:	00005697          	auipc	a3,0x5
ffffffffc0202066:	6b668693          	addi	a3,a3,1718 # ffffffffc0207718 <commands+0xd00>
ffffffffc020206a:	00005617          	auipc	a2,0x5
ffffffffc020206e:	dbe60613          	addi	a2,a2,-578 # ffffffffc0206e28 <commands+0x410>
ffffffffc0202072:	09700593          	li	a1,151
ffffffffc0202076:	00005517          	auipc	a0,0x5
ffffffffc020207a:	4fa50513          	addi	a0,a0,1274 # ffffffffc0207570 <commands+0xb58>
ffffffffc020207e:	98afe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==2);
ffffffffc0202082:	00005697          	auipc	a3,0x5
ffffffffc0202086:	69668693          	addi	a3,a3,1686 # ffffffffc0207718 <commands+0xd00>
ffffffffc020208a:	00005617          	auipc	a2,0x5
ffffffffc020208e:	d9e60613          	addi	a2,a2,-610 # ffffffffc0206e28 <commands+0x410>
ffffffffc0202092:	09900593          	li	a1,153
ffffffffc0202096:	00005517          	auipc	a0,0x5
ffffffffc020209a:	4da50513          	addi	a0,a0,1242 # ffffffffc0207570 <commands+0xb58>
ffffffffc020209e:	96afe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==3);
ffffffffc02020a2:	00005697          	auipc	a3,0x5
ffffffffc02020a6:	68668693          	addi	a3,a3,1670 # ffffffffc0207728 <commands+0xd10>
ffffffffc02020aa:	00005617          	auipc	a2,0x5
ffffffffc02020ae:	d7e60613          	addi	a2,a2,-642 # ffffffffc0206e28 <commands+0x410>
ffffffffc02020b2:	09b00593          	li	a1,155
ffffffffc02020b6:	00005517          	auipc	a0,0x5
ffffffffc02020ba:	4ba50513          	addi	a0,a0,1210 # ffffffffc0207570 <commands+0xb58>
ffffffffc02020be:	94afe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==3);
ffffffffc02020c2:	00005697          	auipc	a3,0x5
ffffffffc02020c6:	66668693          	addi	a3,a3,1638 # ffffffffc0207728 <commands+0xd10>
ffffffffc02020ca:	00005617          	auipc	a2,0x5
ffffffffc02020ce:	d5e60613          	addi	a2,a2,-674 # ffffffffc0206e28 <commands+0x410>
ffffffffc02020d2:	09d00593          	li	a1,157
ffffffffc02020d6:	00005517          	auipc	a0,0x5
ffffffffc02020da:	49a50513          	addi	a0,a0,1178 # ffffffffc0207570 <commands+0xb58>
ffffffffc02020de:	92afe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==1);
ffffffffc02020e2:	00005697          	auipc	a3,0x5
ffffffffc02020e6:	62668693          	addi	a3,a3,1574 # ffffffffc0207708 <commands+0xcf0>
ffffffffc02020ea:	00005617          	auipc	a2,0x5
ffffffffc02020ee:	d3e60613          	addi	a2,a2,-706 # ffffffffc0206e28 <commands+0x410>
ffffffffc02020f2:	09300593          	li	a1,147
ffffffffc02020f6:	00005517          	auipc	a0,0x5
ffffffffc02020fa:	47a50513          	addi	a0,a0,1146 # ffffffffc0207570 <commands+0xb58>
ffffffffc02020fe:	90afe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202102 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0202102:	000b0797          	auipc	a5,0xb0
ffffffffc0202106:	7d67b783          	ld	a5,2006(a5) # ffffffffc02b28d8 <sm>
ffffffffc020210a:	6b9c                	ld	a5,16(a5)
ffffffffc020210c:	8782                	jr	a5

ffffffffc020210e <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc020210e:	000b0797          	auipc	a5,0xb0
ffffffffc0202112:	7ca7b783          	ld	a5,1994(a5) # ffffffffc02b28d8 <sm>
ffffffffc0202116:	739c                	ld	a5,32(a5)
ffffffffc0202118:	8782                	jr	a5

ffffffffc020211a <swap_out>:
{
ffffffffc020211a:	711d                	addi	sp,sp,-96
ffffffffc020211c:	ec86                	sd	ra,88(sp)
ffffffffc020211e:	e8a2                	sd	s0,80(sp)
ffffffffc0202120:	e4a6                	sd	s1,72(sp)
ffffffffc0202122:	e0ca                	sd	s2,64(sp)
ffffffffc0202124:	fc4e                	sd	s3,56(sp)
ffffffffc0202126:	f852                	sd	s4,48(sp)
ffffffffc0202128:	f456                	sd	s5,40(sp)
ffffffffc020212a:	f05a                	sd	s6,32(sp)
ffffffffc020212c:	ec5e                	sd	s7,24(sp)
ffffffffc020212e:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0202130:	cde9                	beqz	a1,ffffffffc020220a <swap_out+0xf0>
ffffffffc0202132:	8a2e                	mv	s4,a1
ffffffffc0202134:	892a                	mv	s2,a0
ffffffffc0202136:	8ab2                	mv	s5,a2
ffffffffc0202138:	4401                	li	s0,0
ffffffffc020213a:	000b0997          	auipc	s3,0xb0
ffffffffc020213e:	79e98993          	addi	s3,s3,1950 # ffffffffc02b28d8 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202142:	00005b17          	auipc	s6,0x5
ffffffffc0202146:	726b0b13          	addi	s6,s6,1830 # ffffffffc0207868 <commands+0xe50>
                    cprintf("SWAP: failed to save\n");
ffffffffc020214a:	00005b97          	auipc	s7,0x5
ffffffffc020214e:	706b8b93          	addi	s7,s7,1798 # ffffffffc0207850 <commands+0xe38>
ffffffffc0202152:	a825                	j	ffffffffc020218a <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202154:	67a2                	ld	a5,8(sp)
ffffffffc0202156:	8626                	mv	a2,s1
ffffffffc0202158:	85a2                	mv	a1,s0
ffffffffc020215a:	7f94                	ld	a3,56(a5)
ffffffffc020215c:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc020215e:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202160:	82b1                	srli	a3,a3,0xc
ffffffffc0202162:	0685                	addi	a3,a3,1
ffffffffc0202164:	f69fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202168:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc020216a:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc020216c:	7d1c                	ld	a5,56(a0)
ffffffffc020216e:	83b1                	srli	a5,a5,0xc
ffffffffc0202170:	0785                	addi	a5,a5,1
ffffffffc0202172:	07a2                	slli	a5,a5,0x8
ffffffffc0202174:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0202178:	472010ef          	jal	ra,ffffffffc02035ea <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc020217c:	01893503          	ld	a0,24(s2)
ffffffffc0202180:	85a6                	mv	a1,s1
ffffffffc0202182:	2c7020ef          	jal	ra,ffffffffc0204c48 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0202186:	048a0d63          	beq	s4,s0,ffffffffc02021e0 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc020218a:	0009b783          	ld	a5,0(s3)
ffffffffc020218e:	8656                	mv	a2,s5
ffffffffc0202190:	002c                	addi	a1,sp,8
ffffffffc0202192:	7b9c                	ld	a5,48(a5)
ffffffffc0202194:	854a                	mv	a0,s2
ffffffffc0202196:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0202198:	e12d                	bnez	a0,ffffffffc02021fa <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc020219a:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020219c:	01893503          	ld	a0,24(s2)
ffffffffc02021a0:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc02021a2:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc02021a4:	85a6                	mv	a1,s1
ffffffffc02021a6:	4be010ef          	jal	ra,ffffffffc0203664 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc02021aa:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc02021ac:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc02021ae:	8b85                	andi	a5,a5,1
ffffffffc02021b0:	cfb9                	beqz	a5,ffffffffc020220e <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc02021b2:	65a2                	ld	a1,8(sp)
ffffffffc02021b4:	7d9c                	ld	a5,56(a1)
ffffffffc02021b6:	83b1                	srli	a5,a5,0xc
ffffffffc02021b8:	0785                	addi	a5,a5,1
ffffffffc02021ba:	00879513          	slli	a0,a5,0x8
ffffffffc02021be:	411020ef          	jal	ra,ffffffffc0204dce <swapfs_write>
ffffffffc02021c2:	d949                	beqz	a0,ffffffffc0202154 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc02021c4:	855e                	mv	a0,s7
ffffffffc02021c6:	f07fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc02021ca:	0009b783          	ld	a5,0(s3)
ffffffffc02021ce:	6622                	ld	a2,8(sp)
ffffffffc02021d0:	4681                	li	a3,0
ffffffffc02021d2:	739c                	ld	a5,32(a5)
ffffffffc02021d4:	85a6                	mv	a1,s1
ffffffffc02021d6:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc02021d8:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc02021da:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc02021dc:	fa8a17e3          	bne	s4,s0,ffffffffc020218a <swap_out+0x70>
}
ffffffffc02021e0:	60e6                	ld	ra,88(sp)
ffffffffc02021e2:	8522                	mv	a0,s0
ffffffffc02021e4:	6446                	ld	s0,80(sp)
ffffffffc02021e6:	64a6                	ld	s1,72(sp)
ffffffffc02021e8:	6906                	ld	s2,64(sp)
ffffffffc02021ea:	79e2                	ld	s3,56(sp)
ffffffffc02021ec:	7a42                	ld	s4,48(sp)
ffffffffc02021ee:	7aa2                	ld	s5,40(sp)
ffffffffc02021f0:	7b02                	ld	s6,32(sp)
ffffffffc02021f2:	6be2                	ld	s7,24(sp)
ffffffffc02021f4:	6c42                	ld	s8,16(sp)
ffffffffc02021f6:	6125                	addi	sp,sp,96
ffffffffc02021f8:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc02021fa:	85a2                	mv	a1,s0
ffffffffc02021fc:	00005517          	auipc	a0,0x5
ffffffffc0202200:	60c50513          	addi	a0,a0,1548 # ffffffffc0207808 <commands+0xdf0>
ffffffffc0202204:	ec9fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
                  break;
ffffffffc0202208:	bfe1                	j	ffffffffc02021e0 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc020220a:	4401                	li	s0,0
ffffffffc020220c:	bfd1                	j	ffffffffc02021e0 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc020220e:	00005697          	auipc	a3,0x5
ffffffffc0202212:	62a68693          	addi	a3,a3,1578 # ffffffffc0207838 <commands+0xe20>
ffffffffc0202216:	00005617          	auipc	a2,0x5
ffffffffc020221a:	c1260613          	addi	a2,a2,-1006 # ffffffffc0206e28 <commands+0x410>
ffffffffc020221e:	06800593          	li	a1,104
ffffffffc0202222:	00005517          	auipc	a0,0x5
ffffffffc0202226:	34e50513          	addi	a0,a0,846 # ffffffffc0207570 <commands+0xb58>
ffffffffc020222a:	fdffd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020222e <swap_in>:
{
ffffffffc020222e:	7179                	addi	sp,sp,-48
ffffffffc0202230:	e84a                	sd	s2,16(sp)
ffffffffc0202232:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0202234:	4505                	li	a0,1
{
ffffffffc0202236:	ec26                	sd	s1,24(sp)
ffffffffc0202238:	e44e                	sd	s3,8(sp)
ffffffffc020223a:	f406                	sd	ra,40(sp)
ffffffffc020223c:	f022                	sd	s0,32(sp)
ffffffffc020223e:	84ae                	mv	s1,a1
ffffffffc0202240:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0202242:	316010ef          	jal	ra,ffffffffc0203558 <alloc_pages>
     assert(result!=NULL);
ffffffffc0202246:	c129                	beqz	a0,ffffffffc0202288 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0202248:	842a                	mv	s0,a0
ffffffffc020224a:	01893503          	ld	a0,24(s2)
ffffffffc020224e:	4601                	li	a2,0
ffffffffc0202250:	85a6                	mv	a1,s1
ffffffffc0202252:	412010ef          	jal	ra,ffffffffc0203664 <get_pte>
ffffffffc0202256:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0202258:	6108                	ld	a0,0(a0)
ffffffffc020225a:	85a2                	mv	a1,s0
ffffffffc020225c:	2e5020ef          	jal	ra,ffffffffc0204d40 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0202260:	00093583          	ld	a1,0(s2)
ffffffffc0202264:	8626                	mv	a2,s1
ffffffffc0202266:	00005517          	auipc	a0,0x5
ffffffffc020226a:	65250513          	addi	a0,a0,1618 # ffffffffc02078b8 <commands+0xea0>
ffffffffc020226e:	81a1                	srli	a1,a1,0x8
ffffffffc0202270:	e5dfd0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc0202274:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0202276:	0089b023          	sd	s0,0(s3)
}
ffffffffc020227a:	7402                	ld	s0,32(sp)
ffffffffc020227c:	64e2                	ld	s1,24(sp)
ffffffffc020227e:	6942                	ld	s2,16(sp)
ffffffffc0202280:	69a2                	ld	s3,8(sp)
ffffffffc0202282:	4501                	li	a0,0
ffffffffc0202284:	6145                	addi	sp,sp,48
ffffffffc0202286:	8082                	ret
     assert(result!=NULL);
ffffffffc0202288:	00005697          	auipc	a3,0x5
ffffffffc020228c:	62068693          	addi	a3,a3,1568 # ffffffffc02078a8 <commands+0xe90>
ffffffffc0202290:	00005617          	auipc	a2,0x5
ffffffffc0202294:	b9860613          	addi	a2,a2,-1128 # ffffffffc0206e28 <commands+0x410>
ffffffffc0202298:	07e00593          	li	a1,126
ffffffffc020229c:	00005517          	auipc	a0,0x5
ffffffffc02022a0:	2d450513          	addi	a0,a0,724 # ffffffffc0207570 <commands+0xb58>
ffffffffc02022a4:	f65fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02022a8 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc02022a8:	c94d                	beqz	a0,ffffffffc020235a <slob_free+0xb2>
{
ffffffffc02022aa:	1141                	addi	sp,sp,-16
ffffffffc02022ac:	e022                	sd	s0,0(sp)
ffffffffc02022ae:	e406                	sd	ra,8(sp)
ffffffffc02022b0:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc02022b2:	e9c1                	bnez	a1,ffffffffc0202342 <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02022b4:	100027f3          	csrr	a5,sstatus
ffffffffc02022b8:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02022ba:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02022bc:	ebd9                	bnez	a5,ffffffffc0202352 <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02022be:	000a5617          	auipc	a2,0xa5
ffffffffc02022c2:	11260613          	addi	a2,a2,274 # ffffffffc02a73d0 <slobfree>
ffffffffc02022c6:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02022c8:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02022ca:	679c                	ld	a5,8(a5)
ffffffffc02022cc:	02877a63          	bgeu	a4,s0,ffffffffc0202300 <slob_free+0x58>
ffffffffc02022d0:	00f46463          	bltu	s0,a5,ffffffffc02022d8 <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02022d4:	fef76ae3          	bltu	a4,a5,ffffffffc02022c8 <slob_free+0x20>
			break;

	if (b + b->units == cur->next) {
ffffffffc02022d8:	400c                	lw	a1,0(s0)
ffffffffc02022da:	00459693          	slli	a3,a1,0x4
ffffffffc02022de:	96a2                	add	a3,a3,s0
ffffffffc02022e0:	02d78a63          	beq	a5,a3,ffffffffc0202314 <slob_free+0x6c>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc02022e4:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc02022e6:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc02022e8:	00469793          	slli	a5,a3,0x4
ffffffffc02022ec:	97ba                	add	a5,a5,a4
ffffffffc02022ee:	02f40e63          	beq	s0,a5,ffffffffc020232a <slob_free+0x82>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc02022f2:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc02022f4:	e218                	sd	a4,0(a2)
    if (flag) {
ffffffffc02022f6:	e129                	bnez	a0,ffffffffc0202338 <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc02022f8:	60a2                	ld	ra,8(sp)
ffffffffc02022fa:	6402                	ld	s0,0(sp)
ffffffffc02022fc:	0141                	addi	sp,sp,16
ffffffffc02022fe:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0202300:	fcf764e3          	bltu	a4,a5,ffffffffc02022c8 <slob_free+0x20>
ffffffffc0202304:	fcf472e3          	bgeu	s0,a5,ffffffffc02022c8 <slob_free+0x20>
	if (b + b->units == cur->next) {
ffffffffc0202308:	400c                	lw	a1,0(s0)
ffffffffc020230a:	00459693          	slli	a3,a1,0x4
ffffffffc020230e:	96a2                	add	a3,a3,s0
ffffffffc0202310:	fcd79ae3          	bne	a5,a3,ffffffffc02022e4 <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc0202314:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0202316:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0202318:	9db5                	addw	a1,a1,a3
ffffffffc020231a:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b) {
ffffffffc020231c:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc020231e:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc0202320:	00469793          	slli	a5,a3,0x4
ffffffffc0202324:	97ba                	add	a5,a5,a4
ffffffffc0202326:	fcf416e3          	bne	s0,a5,ffffffffc02022f2 <slob_free+0x4a>
		cur->units += b->units;
ffffffffc020232a:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc020232c:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc020232e:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc0202330:	9ebd                	addw	a3,a3,a5
ffffffffc0202332:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc0202334:	e70c                	sd	a1,8(a4)
ffffffffc0202336:	d169                	beqz	a0,ffffffffc02022f8 <slob_free+0x50>
}
ffffffffc0202338:	6402                	ld	s0,0(sp)
ffffffffc020233a:	60a2                	ld	ra,8(sp)
ffffffffc020233c:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc020233e:	b04fe06f          	j	ffffffffc0200642 <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc0202342:	25bd                	addiw	a1,a1,15
ffffffffc0202344:	8191                	srli	a1,a1,0x4
ffffffffc0202346:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202348:	100027f3          	csrr	a5,sstatus
ffffffffc020234c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020234e:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202350:	d7bd                	beqz	a5,ffffffffc02022be <slob_free+0x16>
        intr_disable();
ffffffffc0202352:	af6fe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc0202356:	4505                	li	a0,1
ffffffffc0202358:	b79d                	j	ffffffffc02022be <slob_free+0x16>
ffffffffc020235a:	8082                	ret

ffffffffc020235c <__slob_get_free_pages.constprop.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc020235c:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc020235e:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0202360:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0202364:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0202366:	1f2010ef          	jal	ra,ffffffffc0203558 <alloc_pages>
  if(!page)
ffffffffc020236a:	c91d                	beqz	a0,ffffffffc02023a0 <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc020236c:	000b0697          	auipc	a3,0xb0
ffffffffc0202370:	59c6b683          	ld	a3,1436(a3) # ffffffffc02b2908 <pages>
ffffffffc0202374:	8d15                	sub	a0,a0,a3
ffffffffc0202376:	8519                	srai	a0,a0,0x6
ffffffffc0202378:	00007697          	auipc	a3,0x7
ffffffffc020237c:	af86b683          	ld	a3,-1288(a3) # ffffffffc0208e70 <nbase>
ffffffffc0202380:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc0202382:	00c51793          	slli	a5,a0,0xc
ffffffffc0202386:	83b1                	srli	a5,a5,0xc
ffffffffc0202388:	000b0717          	auipc	a4,0xb0
ffffffffc020238c:	57873703          	ld	a4,1400(a4) # ffffffffc02b2900 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc0202390:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0202392:	00e7fa63          	bgeu	a5,a4,ffffffffc02023a6 <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc0202396:	000b0697          	auipc	a3,0xb0
ffffffffc020239a:	5826b683          	ld	a3,1410(a3) # ffffffffc02b2918 <va_pa_offset>
ffffffffc020239e:	9536                	add	a0,a0,a3
}
ffffffffc02023a0:	60a2                	ld	ra,8(sp)
ffffffffc02023a2:	0141                	addi	sp,sp,16
ffffffffc02023a4:	8082                	ret
ffffffffc02023a6:	86aa                	mv	a3,a0
ffffffffc02023a8:	00005617          	auipc	a2,0x5
ffffffffc02023ac:	05060613          	addi	a2,a2,80 # ffffffffc02073f8 <commands+0x9e0>
ffffffffc02023b0:	06900593          	li	a1,105
ffffffffc02023b4:	00005517          	auipc	a0,0x5
ffffffffc02023b8:	db450513          	addi	a0,a0,-588 # ffffffffc0207168 <commands+0x750>
ffffffffc02023bc:	e4dfd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02023c0 <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc02023c0:	1101                	addi	sp,sp,-32
ffffffffc02023c2:	ec06                	sd	ra,24(sp)
ffffffffc02023c4:	e822                	sd	s0,16(sp)
ffffffffc02023c6:	e426                	sd	s1,8(sp)
ffffffffc02023c8:	e04a                	sd	s2,0(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc02023ca:	01050713          	addi	a4,a0,16
ffffffffc02023ce:	6785                	lui	a5,0x1
ffffffffc02023d0:	0cf77363          	bgeu	a4,a5,ffffffffc0202496 <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc02023d4:	00f50493          	addi	s1,a0,15
ffffffffc02023d8:	8091                	srli	s1,s1,0x4
ffffffffc02023da:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02023dc:	10002673          	csrr	a2,sstatus
ffffffffc02023e0:	8a09                	andi	a2,a2,2
ffffffffc02023e2:	e25d                	bnez	a2,ffffffffc0202488 <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc02023e4:	000a5917          	auipc	s2,0xa5
ffffffffc02023e8:	fec90913          	addi	s2,s2,-20 # ffffffffc02a73d0 <slobfree>
ffffffffc02023ec:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02023f0:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02023f2:	4398                	lw	a4,0(a5)
ffffffffc02023f4:	08975e63          	bge	a4,s1,ffffffffc0202490 <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree) {
ffffffffc02023f8:	00f68b63          	beq	a3,a5,ffffffffc020240e <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02023fc:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02023fe:	4018                	lw	a4,0(s0)
ffffffffc0202400:	02975a63          	bge	a4,s1,ffffffffc0202434 <slob_alloc.constprop.0+0x74>
		if (cur == slobfree) {
ffffffffc0202404:	00093683          	ld	a3,0(s2)
ffffffffc0202408:	87a2                	mv	a5,s0
ffffffffc020240a:	fef699e3          	bne	a3,a5,ffffffffc02023fc <slob_alloc.constprop.0+0x3c>
    if (flag) {
ffffffffc020240e:	ee31                	bnez	a2,ffffffffc020246a <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0202410:	4501                	li	a0,0
ffffffffc0202412:	f4bff0ef          	jal	ra,ffffffffc020235c <__slob_get_free_pages.constprop.0>
ffffffffc0202416:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0202418:	cd05                	beqz	a0,ffffffffc0202450 <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc020241a:	6585                	lui	a1,0x1
ffffffffc020241c:	e8dff0ef          	jal	ra,ffffffffc02022a8 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202420:	10002673          	csrr	a2,sstatus
ffffffffc0202424:	8a09                	andi	a2,a2,2
ffffffffc0202426:	ee05                	bnez	a2,ffffffffc020245e <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc0202428:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc020242c:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc020242e:	4018                	lw	a4,0(s0)
ffffffffc0202430:	fc974ae3          	blt	a4,s1,ffffffffc0202404 <slob_alloc.constprop.0+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc0202434:	04e48763          	beq	s1,a4,ffffffffc0202482 <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc0202438:	00449693          	slli	a3,s1,0x4
ffffffffc020243c:	96a2                	add	a3,a3,s0
ffffffffc020243e:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0202440:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0202442:	9f05                	subw	a4,a4,s1
ffffffffc0202444:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0202446:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0202448:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc020244a:	00f93023          	sd	a5,0(s2)
    if (flag) {
ffffffffc020244e:	e20d                	bnez	a2,ffffffffc0202470 <slob_alloc.constprop.0+0xb0>
}
ffffffffc0202450:	60e2                	ld	ra,24(sp)
ffffffffc0202452:	8522                	mv	a0,s0
ffffffffc0202454:	6442                	ld	s0,16(sp)
ffffffffc0202456:	64a2                	ld	s1,8(sp)
ffffffffc0202458:	6902                	ld	s2,0(sp)
ffffffffc020245a:	6105                	addi	sp,sp,32
ffffffffc020245c:	8082                	ret
        intr_disable();
ffffffffc020245e:	9eafe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
			cur = slobfree;
ffffffffc0202462:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc0202466:	4605                	li	a2,1
ffffffffc0202468:	b7d1                	j	ffffffffc020242c <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc020246a:	9d8fe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc020246e:	b74d                	j	ffffffffc0202410 <slob_alloc.constprop.0+0x50>
ffffffffc0202470:	9d2fe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
}
ffffffffc0202474:	60e2                	ld	ra,24(sp)
ffffffffc0202476:	8522                	mv	a0,s0
ffffffffc0202478:	6442                	ld	s0,16(sp)
ffffffffc020247a:	64a2                	ld	s1,8(sp)
ffffffffc020247c:	6902                	ld	s2,0(sp)
ffffffffc020247e:	6105                	addi	sp,sp,32
ffffffffc0202480:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0202482:	6418                	ld	a4,8(s0)
ffffffffc0202484:	e798                	sd	a4,8(a5)
ffffffffc0202486:	b7d1                	j	ffffffffc020244a <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc0202488:	9c0fe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc020248c:	4605                	li	a2,1
ffffffffc020248e:	bf99                	j	ffffffffc02023e4 <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0202490:	843e                	mv	s0,a5
ffffffffc0202492:	87b6                	mv	a5,a3
ffffffffc0202494:	b745                	j	ffffffffc0202434 <slob_alloc.constprop.0+0x74>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0202496:	00005697          	auipc	a3,0x5
ffffffffc020249a:	46268693          	addi	a3,a3,1122 # ffffffffc02078f8 <commands+0xee0>
ffffffffc020249e:	00005617          	auipc	a2,0x5
ffffffffc02024a2:	98a60613          	addi	a2,a2,-1654 # ffffffffc0206e28 <commands+0x410>
ffffffffc02024a6:	06400593          	li	a1,100
ffffffffc02024aa:	00005517          	auipc	a0,0x5
ffffffffc02024ae:	46e50513          	addi	a0,a0,1134 # ffffffffc0207918 <commands+0xf00>
ffffffffc02024b2:	d57fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02024b6 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc02024b6:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc02024b8:	00005517          	auipc	a0,0x5
ffffffffc02024bc:	47850513          	addi	a0,a0,1144 # ffffffffc0207930 <commands+0xf18>
kmalloc_init(void) {
ffffffffc02024c0:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc02024c2:	c0bfd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc02024c6:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc02024c8:	00005517          	auipc	a0,0x5
ffffffffc02024cc:	48050513          	addi	a0,a0,1152 # ffffffffc0207948 <commands+0xf30>
}
ffffffffc02024d0:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc02024d2:	bfbfd06f          	j	ffffffffc02000cc <cprintf>

ffffffffc02024d6 <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc02024d6:	4501                	li	a0,0
ffffffffc02024d8:	8082                	ret

ffffffffc02024da <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc02024da:	1101                	addi	sp,sp,-32
ffffffffc02024dc:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02024de:	6905                	lui	s2,0x1
{
ffffffffc02024e0:	e822                	sd	s0,16(sp)
ffffffffc02024e2:	ec06                	sd	ra,24(sp)
ffffffffc02024e4:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02024e6:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8bd1>
{
ffffffffc02024ea:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02024ec:	04a7f963          	bgeu	a5,a0,ffffffffc020253e <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc02024f0:	4561                	li	a0,24
ffffffffc02024f2:	ecfff0ef          	jal	ra,ffffffffc02023c0 <slob_alloc.constprop.0>
ffffffffc02024f6:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc02024f8:	c929                	beqz	a0,ffffffffc020254a <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc02024fa:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc02024fe:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0202500:	00f95763          	bge	s2,a5,ffffffffc020250e <kmalloc+0x34>
ffffffffc0202504:	6705                	lui	a4,0x1
ffffffffc0202506:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0202508:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc020250a:	fef74ee3          	blt	a4,a5,ffffffffc0202506 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc020250e:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0202510:	e4dff0ef          	jal	ra,ffffffffc020235c <__slob_get_free_pages.constprop.0>
ffffffffc0202514:	e488                	sd	a0,8(s1)
ffffffffc0202516:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0202518:	c525                	beqz	a0,ffffffffc0202580 <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020251a:	100027f3          	csrr	a5,sstatus
ffffffffc020251e:	8b89                	andi	a5,a5,2
ffffffffc0202520:	ef8d                	bnez	a5,ffffffffc020255a <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc0202522:	000b0797          	auipc	a5,0xb0
ffffffffc0202526:	3c678793          	addi	a5,a5,966 # ffffffffc02b28e8 <bigblocks>
ffffffffc020252a:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc020252c:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc020252e:	e898                	sd	a4,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0202530:	60e2                	ld	ra,24(sp)
ffffffffc0202532:	8522                	mv	a0,s0
ffffffffc0202534:	6442                	ld	s0,16(sp)
ffffffffc0202536:	64a2                	ld	s1,8(sp)
ffffffffc0202538:	6902                	ld	s2,0(sp)
ffffffffc020253a:	6105                	addi	sp,sp,32
ffffffffc020253c:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc020253e:	0541                	addi	a0,a0,16
ffffffffc0202540:	e81ff0ef          	jal	ra,ffffffffc02023c0 <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc0202544:	01050413          	addi	s0,a0,16
ffffffffc0202548:	f565                	bnez	a0,ffffffffc0202530 <kmalloc+0x56>
ffffffffc020254a:	4401                	li	s0,0
}
ffffffffc020254c:	60e2                	ld	ra,24(sp)
ffffffffc020254e:	8522                	mv	a0,s0
ffffffffc0202550:	6442                	ld	s0,16(sp)
ffffffffc0202552:	64a2                	ld	s1,8(sp)
ffffffffc0202554:	6902                	ld	s2,0(sp)
ffffffffc0202556:	6105                	addi	sp,sp,32
ffffffffc0202558:	8082                	ret
        intr_disable();
ffffffffc020255a:	8eefe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
		bb->next = bigblocks;
ffffffffc020255e:	000b0797          	auipc	a5,0xb0
ffffffffc0202562:	38a78793          	addi	a5,a5,906 # ffffffffc02b28e8 <bigblocks>
ffffffffc0202566:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0202568:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc020256a:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc020256c:	8d6fe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
		return bb->pages;
ffffffffc0202570:	6480                	ld	s0,8(s1)
}
ffffffffc0202572:	60e2                	ld	ra,24(sp)
ffffffffc0202574:	64a2                	ld	s1,8(sp)
ffffffffc0202576:	8522                	mv	a0,s0
ffffffffc0202578:	6442                	ld	s0,16(sp)
ffffffffc020257a:	6902                	ld	s2,0(sp)
ffffffffc020257c:	6105                	addi	sp,sp,32
ffffffffc020257e:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0202580:	45e1                	li	a1,24
ffffffffc0202582:	8526                	mv	a0,s1
ffffffffc0202584:	d25ff0ef          	jal	ra,ffffffffc02022a8 <slob_free>
  return __kmalloc(size, 0);
ffffffffc0202588:	b765                	j	ffffffffc0202530 <kmalloc+0x56>

ffffffffc020258a <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc020258a:	c179                	beqz	a0,ffffffffc0202650 <kfree+0xc6>
{
ffffffffc020258c:	1101                	addi	sp,sp,-32
ffffffffc020258e:	e822                	sd	s0,16(sp)
ffffffffc0202590:	ec06                	sd	ra,24(sp)
ffffffffc0202592:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0202594:	03451793          	slli	a5,a0,0x34
ffffffffc0202598:	842a                	mv	s0,a0
ffffffffc020259a:	e7c1                	bnez	a5,ffffffffc0202622 <kfree+0x98>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020259c:	100027f3          	csrr	a5,sstatus
ffffffffc02025a0:	8b89                	andi	a5,a5,2
ffffffffc02025a2:	ebc9                	bnez	a5,ffffffffc0202634 <kfree+0xaa>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc02025a4:	000b0797          	auipc	a5,0xb0
ffffffffc02025a8:	3447b783          	ld	a5,836(a5) # ffffffffc02b28e8 <bigblocks>
    return 0;
ffffffffc02025ac:	4601                	li	a2,0
ffffffffc02025ae:	cbb5                	beqz	a5,ffffffffc0202622 <kfree+0x98>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc02025b0:	000b0697          	auipc	a3,0xb0
ffffffffc02025b4:	33868693          	addi	a3,a3,824 # ffffffffc02b28e8 <bigblocks>
ffffffffc02025b8:	a021                	j	ffffffffc02025c0 <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc02025ba:	01048693          	addi	a3,s1,16
ffffffffc02025be:	c3ad                	beqz	a5,ffffffffc0202620 <kfree+0x96>
			if (bb->pages == block) {
ffffffffc02025c0:	6798                	ld	a4,8(a5)
ffffffffc02025c2:	84be                	mv	s1,a5
				*last = bb->next;
ffffffffc02025c4:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block) {
ffffffffc02025c6:	fe871ae3          	bne	a4,s0,ffffffffc02025ba <kfree+0x30>
				*last = bb->next;
ffffffffc02025ca:	e29c                	sd	a5,0(a3)
    if (flag) {
ffffffffc02025cc:	ee3d                	bnez	a2,ffffffffc020264a <kfree+0xc0>
    return pa2page(PADDR(kva));
ffffffffc02025ce:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc02025d2:	4098                	lw	a4,0(s1)
ffffffffc02025d4:	08f46b63          	bltu	s0,a5,ffffffffc020266a <kfree+0xe0>
ffffffffc02025d8:	000b0697          	auipc	a3,0xb0
ffffffffc02025dc:	3406b683          	ld	a3,832(a3) # ffffffffc02b2918 <va_pa_offset>
ffffffffc02025e0:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage) {
ffffffffc02025e2:	8031                	srli	s0,s0,0xc
ffffffffc02025e4:	000b0797          	auipc	a5,0xb0
ffffffffc02025e8:	31c7b783          	ld	a5,796(a5) # ffffffffc02b2900 <npage>
ffffffffc02025ec:	06f47363          	bgeu	s0,a5,ffffffffc0202652 <kfree+0xc8>
    return &pages[PPN(pa) - nbase];
ffffffffc02025f0:	00007517          	auipc	a0,0x7
ffffffffc02025f4:	88053503          	ld	a0,-1920(a0) # ffffffffc0208e70 <nbase>
ffffffffc02025f8:	8c09                	sub	s0,s0,a0
ffffffffc02025fa:	041a                	slli	s0,s0,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc02025fc:	000b0517          	auipc	a0,0xb0
ffffffffc0202600:	30c53503          	ld	a0,780(a0) # ffffffffc02b2908 <pages>
ffffffffc0202604:	4585                	li	a1,1
ffffffffc0202606:	9522                	add	a0,a0,s0
ffffffffc0202608:	00e595bb          	sllw	a1,a1,a4
ffffffffc020260c:	7df000ef          	jal	ra,ffffffffc02035ea <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0202610:	6442                	ld	s0,16(sp)
ffffffffc0202612:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0202614:	8526                	mv	a0,s1
}
ffffffffc0202616:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0202618:	45e1                	li	a1,24
}
ffffffffc020261a:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc020261c:	c8dff06f          	j	ffffffffc02022a8 <slob_free>
ffffffffc0202620:	e215                	bnez	a2,ffffffffc0202644 <kfree+0xba>
ffffffffc0202622:	ff040513          	addi	a0,s0,-16
}
ffffffffc0202626:	6442                	ld	s0,16(sp)
ffffffffc0202628:	60e2                	ld	ra,24(sp)
ffffffffc020262a:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc020262c:	4581                	li	a1,0
}
ffffffffc020262e:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0202630:	c79ff06f          	j	ffffffffc02022a8 <slob_free>
        intr_disable();
ffffffffc0202634:	814fe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0202638:	000b0797          	auipc	a5,0xb0
ffffffffc020263c:	2b07b783          	ld	a5,688(a5) # ffffffffc02b28e8 <bigblocks>
        return 1;
ffffffffc0202640:	4605                	li	a2,1
ffffffffc0202642:	f7bd                	bnez	a5,ffffffffc02025b0 <kfree+0x26>
        intr_enable();
ffffffffc0202644:	ffffd0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0202648:	bfe9                	j	ffffffffc0202622 <kfree+0x98>
ffffffffc020264a:	ff9fd0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc020264e:	b741                	j	ffffffffc02025ce <kfree+0x44>
ffffffffc0202650:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0202652:	00005617          	auipc	a2,0x5
ffffffffc0202656:	af660613          	addi	a2,a2,-1290 # ffffffffc0207148 <commands+0x730>
ffffffffc020265a:	06200593          	li	a1,98
ffffffffc020265e:	00005517          	auipc	a0,0x5
ffffffffc0202662:	b0a50513          	addi	a0,a0,-1270 # ffffffffc0207168 <commands+0x750>
ffffffffc0202666:	ba3fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    return pa2page(PADDR(kva));
ffffffffc020266a:	86a2                	mv	a3,s0
ffffffffc020266c:	00005617          	auipc	a2,0x5
ffffffffc0202670:	2fc60613          	addi	a2,a2,764 # ffffffffc0207968 <commands+0xf50>
ffffffffc0202674:	06e00593          	li	a1,110
ffffffffc0202678:	00005517          	auipc	a0,0x5
ffffffffc020267c:	af050513          	addi	a0,a0,-1296 # ffffffffc0207168 <commands+0x750>
ffffffffc0202680:	b89fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202684 <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0202684:	000ac797          	auipc	a5,0xac
ffffffffc0202688:	1ec78793          	addi	a5,a5,492 # ffffffffc02ae870 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc020268c:	f51c                	sd	a5,40(a0)
ffffffffc020268e:	e79c                	sd	a5,8(a5)
ffffffffc0202690:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0202692:	4501                	li	a0,0
ffffffffc0202694:	8082                	ret

ffffffffc0202696 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0202696:	4501                	li	a0,0
ffffffffc0202698:	8082                	ret

ffffffffc020269a <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc020269a:	4501                	li	a0,0
ffffffffc020269c:	8082                	ret

ffffffffc020269e <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc020269e:	4501                	li	a0,0
ffffffffc02026a0:	8082                	ret

ffffffffc02026a2 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc02026a2:	711d                	addi	sp,sp,-96
ffffffffc02026a4:	fc4e                	sd	s3,56(sp)
ffffffffc02026a6:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02026a8:	00005517          	auipc	a0,0x5
ffffffffc02026ac:	2e850513          	addi	a0,a0,744 # ffffffffc0207990 <commands+0xf78>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02026b0:	698d                	lui	s3,0x3
ffffffffc02026b2:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc02026b4:	e0ca                	sd	s2,64(sp)
ffffffffc02026b6:	ec86                	sd	ra,88(sp)
ffffffffc02026b8:	e8a2                	sd	s0,80(sp)
ffffffffc02026ba:	e4a6                	sd	s1,72(sp)
ffffffffc02026bc:	f456                	sd	s5,40(sp)
ffffffffc02026be:	f05a                	sd	s6,32(sp)
ffffffffc02026c0:	ec5e                	sd	s7,24(sp)
ffffffffc02026c2:	e862                	sd	s8,16(sp)
ffffffffc02026c4:	e466                	sd	s9,8(sp)
ffffffffc02026c6:	e06a                	sd	s10,0(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02026c8:	a05fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02026cc:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x6bc0>
    assert(pgfault_num==4);
ffffffffc02026d0:	000b0917          	auipc	s2,0xb0
ffffffffc02026d4:	1f892903          	lw	s2,504(s2) # ffffffffc02b28c8 <pgfault_num>
ffffffffc02026d8:	4791                	li	a5,4
ffffffffc02026da:	14f91e63          	bne	s2,a5,ffffffffc0202836 <_fifo_check_swap+0x194>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02026de:	00005517          	auipc	a0,0x5
ffffffffc02026e2:	2f250513          	addi	a0,a0,754 # ffffffffc02079d0 <commands+0xfb8>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02026e6:	6a85                	lui	s5,0x1
ffffffffc02026e8:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02026ea:	9e3fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc02026ee:	000b0417          	auipc	s0,0xb0
ffffffffc02026f2:	1da40413          	addi	s0,s0,474 # ffffffffc02b28c8 <pgfault_num>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02026f6:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8bc0>
    assert(pgfault_num==4);
ffffffffc02026fa:	4004                	lw	s1,0(s0)
ffffffffc02026fc:	2481                	sext.w	s1,s1
ffffffffc02026fe:	2b249c63          	bne	s1,s2,ffffffffc02029b6 <_fifo_check_swap+0x314>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0202702:	00005517          	auipc	a0,0x5
ffffffffc0202706:	2f650513          	addi	a0,a0,758 # ffffffffc02079f8 <commands+0xfe0>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc020270a:	6b91                	lui	s7,0x4
ffffffffc020270c:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc020270e:	9bffd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202712:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x5bc0>
    assert(pgfault_num==4);
ffffffffc0202716:	00042903          	lw	s2,0(s0)
ffffffffc020271a:	2901                	sext.w	s2,s2
ffffffffc020271c:	26991d63          	bne	s2,s1,ffffffffc0202996 <_fifo_check_swap+0x2f4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0202720:	00005517          	auipc	a0,0x5
ffffffffc0202724:	30050513          	addi	a0,a0,768 # ffffffffc0207a20 <commands+0x1008>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202728:	6c89                	lui	s9,0x2
ffffffffc020272a:	4d2d                	li	s10,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc020272c:	9a1fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202730:	01ac8023          	sb	s10,0(s9) # 2000 <_binary_obj___user_faultread_out_size-0x7bc0>
    assert(pgfault_num==4);
ffffffffc0202734:	401c                	lw	a5,0(s0)
ffffffffc0202736:	2781                	sext.w	a5,a5
ffffffffc0202738:	23279f63          	bne	a5,s2,ffffffffc0202976 <_fifo_check_swap+0x2d4>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc020273c:	00005517          	auipc	a0,0x5
ffffffffc0202740:	30c50513          	addi	a0,a0,780 # ffffffffc0207a48 <commands+0x1030>
ffffffffc0202744:	989fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0202748:	6795                	lui	a5,0x5
ffffffffc020274a:	4739                	li	a4,14
ffffffffc020274c:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4bc0>
    assert(pgfault_num==5);
ffffffffc0202750:	4004                	lw	s1,0(s0)
ffffffffc0202752:	4795                	li	a5,5
ffffffffc0202754:	2481                	sext.w	s1,s1
ffffffffc0202756:	20f49063          	bne	s1,a5,ffffffffc0202956 <_fifo_check_swap+0x2b4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc020275a:	00005517          	auipc	a0,0x5
ffffffffc020275e:	2c650513          	addi	a0,a0,710 # ffffffffc0207a20 <commands+0x1008>
ffffffffc0202762:	96bfd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202766:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==5);
ffffffffc020276a:	401c                	lw	a5,0(s0)
ffffffffc020276c:	2781                	sext.w	a5,a5
ffffffffc020276e:	1c979463          	bne	a5,s1,ffffffffc0202936 <_fifo_check_swap+0x294>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0202772:	00005517          	auipc	a0,0x5
ffffffffc0202776:	25e50513          	addi	a0,a0,606 # ffffffffc02079d0 <commands+0xfb8>
ffffffffc020277a:	953fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020277e:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0202782:	401c                	lw	a5,0(s0)
ffffffffc0202784:	4719                	li	a4,6
ffffffffc0202786:	2781                	sext.w	a5,a5
ffffffffc0202788:	18e79763          	bne	a5,a4,ffffffffc0202916 <_fifo_check_swap+0x274>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc020278c:	00005517          	auipc	a0,0x5
ffffffffc0202790:	29450513          	addi	a0,a0,660 # ffffffffc0207a20 <commands+0x1008>
ffffffffc0202794:	939fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202798:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==7);
ffffffffc020279c:	401c                	lw	a5,0(s0)
ffffffffc020279e:	471d                	li	a4,7
ffffffffc02027a0:	2781                	sext.w	a5,a5
ffffffffc02027a2:	14e79a63          	bne	a5,a4,ffffffffc02028f6 <_fifo_check_swap+0x254>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02027a6:	00005517          	auipc	a0,0x5
ffffffffc02027aa:	1ea50513          	addi	a0,a0,490 # ffffffffc0207990 <commands+0xf78>
ffffffffc02027ae:	91ffd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02027b2:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc02027b6:	401c                	lw	a5,0(s0)
ffffffffc02027b8:	4721                	li	a4,8
ffffffffc02027ba:	2781                	sext.w	a5,a5
ffffffffc02027bc:	10e79d63          	bne	a5,a4,ffffffffc02028d6 <_fifo_check_swap+0x234>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02027c0:	00005517          	auipc	a0,0x5
ffffffffc02027c4:	23850513          	addi	a0,a0,568 # ffffffffc02079f8 <commands+0xfe0>
ffffffffc02027c8:	905fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02027cc:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc02027d0:	401c                	lw	a5,0(s0)
ffffffffc02027d2:	4725                	li	a4,9
ffffffffc02027d4:	2781                	sext.w	a5,a5
ffffffffc02027d6:	0ee79063          	bne	a5,a4,ffffffffc02028b6 <_fifo_check_swap+0x214>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc02027da:	00005517          	auipc	a0,0x5
ffffffffc02027de:	26e50513          	addi	a0,a0,622 # ffffffffc0207a48 <commands+0x1030>
ffffffffc02027e2:	8ebfd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02027e6:	6795                	lui	a5,0x5
ffffffffc02027e8:	4739                	li	a4,14
ffffffffc02027ea:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4bc0>
    assert(pgfault_num==10);
ffffffffc02027ee:	4004                	lw	s1,0(s0)
ffffffffc02027f0:	47a9                	li	a5,10
ffffffffc02027f2:	2481                	sext.w	s1,s1
ffffffffc02027f4:	0af49163          	bne	s1,a5,ffffffffc0202896 <_fifo_check_swap+0x1f4>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02027f8:	00005517          	auipc	a0,0x5
ffffffffc02027fc:	1d850513          	addi	a0,a0,472 # ffffffffc02079d0 <commands+0xfb8>
ffffffffc0202800:	8cdfd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0202804:	6785                	lui	a5,0x1
ffffffffc0202806:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8bc0>
ffffffffc020280a:	06979663          	bne	a5,s1,ffffffffc0202876 <_fifo_check_swap+0x1d4>
    assert(pgfault_num==11);
ffffffffc020280e:	401c                	lw	a5,0(s0)
ffffffffc0202810:	472d                	li	a4,11
ffffffffc0202812:	2781                	sext.w	a5,a5
ffffffffc0202814:	04e79163          	bne	a5,a4,ffffffffc0202856 <_fifo_check_swap+0x1b4>
}
ffffffffc0202818:	60e6                	ld	ra,88(sp)
ffffffffc020281a:	6446                	ld	s0,80(sp)
ffffffffc020281c:	64a6                	ld	s1,72(sp)
ffffffffc020281e:	6906                	ld	s2,64(sp)
ffffffffc0202820:	79e2                	ld	s3,56(sp)
ffffffffc0202822:	7a42                	ld	s4,48(sp)
ffffffffc0202824:	7aa2                	ld	s5,40(sp)
ffffffffc0202826:	7b02                	ld	s6,32(sp)
ffffffffc0202828:	6be2                	ld	s7,24(sp)
ffffffffc020282a:	6c42                	ld	s8,16(sp)
ffffffffc020282c:	6ca2                	ld	s9,8(sp)
ffffffffc020282e:	6d02                	ld	s10,0(sp)
ffffffffc0202830:	4501                	li	a0,0
ffffffffc0202832:	6125                	addi	sp,sp,96
ffffffffc0202834:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0202836:	00005697          	auipc	a3,0x5
ffffffffc020283a:	f0268693          	addi	a3,a3,-254 # ffffffffc0207738 <commands+0xd20>
ffffffffc020283e:	00004617          	auipc	a2,0x4
ffffffffc0202842:	5ea60613          	addi	a2,a2,1514 # ffffffffc0206e28 <commands+0x410>
ffffffffc0202846:	05100593          	li	a1,81
ffffffffc020284a:	00005517          	auipc	a0,0x5
ffffffffc020284e:	16e50513          	addi	a0,a0,366 # ffffffffc02079b8 <commands+0xfa0>
ffffffffc0202852:	9b7fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==11);
ffffffffc0202856:	00005697          	auipc	a3,0x5
ffffffffc020285a:	2a268693          	addi	a3,a3,674 # ffffffffc0207af8 <commands+0x10e0>
ffffffffc020285e:	00004617          	auipc	a2,0x4
ffffffffc0202862:	5ca60613          	addi	a2,a2,1482 # ffffffffc0206e28 <commands+0x410>
ffffffffc0202866:	07300593          	li	a1,115
ffffffffc020286a:	00005517          	auipc	a0,0x5
ffffffffc020286e:	14e50513          	addi	a0,a0,334 # ffffffffc02079b8 <commands+0xfa0>
ffffffffc0202872:	997fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0202876:	00005697          	auipc	a3,0x5
ffffffffc020287a:	25a68693          	addi	a3,a3,602 # ffffffffc0207ad0 <commands+0x10b8>
ffffffffc020287e:	00004617          	auipc	a2,0x4
ffffffffc0202882:	5aa60613          	addi	a2,a2,1450 # ffffffffc0206e28 <commands+0x410>
ffffffffc0202886:	07100593          	li	a1,113
ffffffffc020288a:	00005517          	auipc	a0,0x5
ffffffffc020288e:	12e50513          	addi	a0,a0,302 # ffffffffc02079b8 <commands+0xfa0>
ffffffffc0202892:	977fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==10);
ffffffffc0202896:	00005697          	auipc	a3,0x5
ffffffffc020289a:	22a68693          	addi	a3,a3,554 # ffffffffc0207ac0 <commands+0x10a8>
ffffffffc020289e:	00004617          	auipc	a2,0x4
ffffffffc02028a2:	58a60613          	addi	a2,a2,1418 # ffffffffc0206e28 <commands+0x410>
ffffffffc02028a6:	06f00593          	li	a1,111
ffffffffc02028aa:	00005517          	auipc	a0,0x5
ffffffffc02028ae:	10e50513          	addi	a0,a0,270 # ffffffffc02079b8 <commands+0xfa0>
ffffffffc02028b2:	957fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==9);
ffffffffc02028b6:	00005697          	auipc	a3,0x5
ffffffffc02028ba:	1fa68693          	addi	a3,a3,506 # ffffffffc0207ab0 <commands+0x1098>
ffffffffc02028be:	00004617          	auipc	a2,0x4
ffffffffc02028c2:	56a60613          	addi	a2,a2,1386 # ffffffffc0206e28 <commands+0x410>
ffffffffc02028c6:	06c00593          	li	a1,108
ffffffffc02028ca:	00005517          	auipc	a0,0x5
ffffffffc02028ce:	0ee50513          	addi	a0,a0,238 # ffffffffc02079b8 <commands+0xfa0>
ffffffffc02028d2:	937fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==8);
ffffffffc02028d6:	00005697          	auipc	a3,0x5
ffffffffc02028da:	1ca68693          	addi	a3,a3,458 # ffffffffc0207aa0 <commands+0x1088>
ffffffffc02028de:	00004617          	auipc	a2,0x4
ffffffffc02028e2:	54a60613          	addi	a2,a2,1354 # ffffffffc0206e28 <commands+0x410>
ffffffffc02028e6:	06900593          	li	a1,105
ffffffffc02028ea:	00005517          	auipc	a0,0x5
ffffffffc02028ee:	0ce50513          	addi	a0,a0,206 # ffffffffc02079b8 <commands+0xfa0>
ffffffffc02028f2:	917fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==7);
ffffffffc02028f6:	00005697          	auipc	a3,0x5
ffffffffc02028fa:	19a68693          	addi	a3,a3,410 # ffffffffc0207a90 <commands+0x1078>
ffffffffc02028fe:	00004617          	auipc	a2,0x4
ffffffffc0202902:	52a60613          	addi	a2,a2,1322 # ffffffffc0206e28 <commands+0x410>
ffffffffc0202906:	06600593          	li	a1,102
ffffffffc020290a:	00005517          	auipc	a0,0x5
ffffffffc020290e:	0ae50513          	addi	a0,a0,174 # ffffffffc02079b8 <commands+0xfa0>
ffffffffc0202912:	8f7fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==6);
ffffffffc0202916:	00005697          	auipc	a3,0x5
ffffffffc020291a:	16a68693          	addi	a3,a3,362 # ffffffffc0207a80 <commands+0x1068>
ffffffffc020291e:	00004617          	auipc	a2,0x4
ffffffffc0202922:	50a60613          	addi	a2,a2,1290 # ffffffffc0206e28 <commands+0x410>
ffffffffc0202926:	06300593          	li	a1,99
ffffffffc020292a:	00005517          	auipc	a0,0x5
ffffffffc020292e:	08e50513          	addi	a0,a0,142 # ffffffffc02079b8 <commands+0xfa0>
ffffffffc0202932:	8d7fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==5);
ffffffffc0202936:	00005697          	auipc	a3,0x5
ffffffffc020293a:	13a68693          	addi	a3,a3,314 # ffffffffc0207a70 <commands+0x1058>
ffffffffc020293e:	00004617          	auipc	a2,0x4
ffffffffc0202942:	4ea60613          	addi	a2,a2,1258 # ffffffffc0206e28 <commands+0x410>
ffffffffc0202946:	06000593          	li	a1,96
ffffffffc020294a:	00005517          	auipc	a0,0x5
ffffffffc020294e:	06e50513          	addi	a0,a0,110 # ffffffffc02079b8 <commands+0xfa0>
ffffffffc0202952:	8b7fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==5);
ffffffffc0202956:	00005697          	auipc	a3,0x5
ffffffffc020295a:	11a68693          	addi	a3,a3,282 # ffffffffc0207a70 <commands+0x1058>
ffffffffc020295e:	00004617          	auipc	a2,0x4
ffffffffc0202962:	4ca60613          	addi	a2,a2,1226 # ffffffffc0206e28 <commands+0x410>
ffffffffc0202966:	05d00593          	li	a1,93
ffffffffc020296a:	00005517          	auipc	a0,0x5
ffffffffc020296e:	04e50513          	addi	a0,a0,78 # ffffffffc02079b8 <commands+0xfa0>
ffffffffc0202972:	897fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==4);
ffffffffc0202976:	00005697          	auipc	a3,0x5
ffffffffc020297a:	dc268693          	addi	a3,a3,-574 # ffffffffc0207738 <commands+0xd20>
ffffffffc020297e:	00004617          	auipc	a2,0x4
ffffffffc0202982:	4aa60613          	addi	a2,a2,1194 # ffffffffc0206e28 <commands+0x410>
ffffffffc0202986:	05a00593          	li	a1,90
ffffffffc020298a:	00005517          	auipc	a0,0x5
ffffffffc020298e:	02e50513          	addi	a0,a0,46 # ffffffffc02079b8 <commands+0xfa0>
ffffffffc0202992:	877fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==4);
ffffffffc0202996:	00005697          	auipc	a3,0x5
ffffffffc020299a:	da268693          	addi	a3,a3,-606 # ffffffffc0207738 <commands+0xd20>
ffffffffc020299e:	00004617          	auipc	a2,0x4
ffffffffc02029a2:	48a60613          	addi	a2,a2,1162 # ffffffffc0206e28 <commands+0x410>
ffffffffc02029a6:	05700593          	li	a1,87
ffffffffc02029aa:	00005517          	auipc	a0,0x5
ffffffffc02029ae:	00e50513          	addi	a0,a0,14 # ffffffffc02079b8 <commands+0xfa0>
ffffffffc02029b2:	857fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==4);
ffffffffc02029b6:	00005697          	auipc	a3,0x5
ffffffffc02029ba:	d8268693          	addi	a3,a3,-638 # ffffffffc0207738 <commands+0xd20>
ffffffffc02029be:	00004617          	auipc	a2,0x4
ffffffffc02029c2:	46a60613          	addi	a2,a2,1130 # ffffffffc0206e28 <commands+0x410>
ffffffffc02029c6:	05400593          	li	a1,84
ffffffffc02029ca:	00005517          	auipc	a0,0x5
ffffffffc02029ce:	fee50513          	addi	a0,a0,-18 # ffffffffc02079b8 <commands+0xfa0>
ffffffffc02029d2:	837fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02029d6 <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02029d6:	751c                	ld	a5,40(a0)
{
ffffffffc02029d8:	1141                	addi	sp,sp,-16
ffffffffc02029da:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc02029dc:	cf91                	beqz	a5,ffffffffc02029f8 <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc02029de:	ee0d                	bnez	a2,ffffffffc0202a18 <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc02029e0:	679c                	ld	a5,8(a5)
}
ffffffffc02029e2:	60a2                	ld	ra,8(sp)
ffffffffc02029e4:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc02029e6:	6394                	ld	a3,0(a5)
ffffffffc02029e8:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc02029ea:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc02029ee:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc02029f0:	e314                	sd	a3,0(a4)
ffffffffc02029f2:	e19c                	sd	a5,0(a1)
}
ffffffffc02029f4:	0141                	addi	sp,sp,16
ffffffffc02029f6:	8082                	ret
         assert(head != NULL);
ffffffffc02029f8:	00005697          	auipc	a3,0x5
ffffffffc02029fc:	11068693          	addi	a3,a3,272 # ffffffffc0207b08 <commands+0x10f0>
ffffffffc0202a00:	00004617          	auipc	a2,0x4
ffffffffc0202a04:	42860613          	addi	a2,a2,1064 # ffffffffc0206e28 <commands+0x410>
ffffffffc0202a08:	04100593          	li	a1,65
ffffffffc0202a0c:	00005517          	auipc	a0,0x5
ffffffffc0202a10:	fac50513          	addi	a0,a0,-84 # ffffffffc02079b8 <commands+0xfa0>
ffffffffc0202a14:	ff4fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(in_tick==0);
ffffffffc0202a18:	00005697          	auipc	a3,0x5
ffffffffc0202a1c:	10068693          	addi	a3,a3,256 # ffffffffc0207b18 <commands+0x1100>
ffffffffc0202a20:	00004617          	auipc	a2,0x4
ffffffffc0202a24:	40860613          	addi	a2,a2,1032 # ffffffffc0206e28 <commands+0x410>
ffffffffc0202a28:	04200593          	li	a1,66
ffffffffc0202a2c:	00005517          	auipc	a0,0x5
ffffffffc0202a30:	f8c50513          	addi	a0,a0,-116 # ffffffffc02079b8 <commands+0xfa0>
ffffffffc0202a34:	fd4fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202a38 <_fifo_map_swappable>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0202a38:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0202a3a:	cb91                	beqz	a5,ffffffffc0202a4e <_fifo_map_swappable+0x16>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0202a3c:	6394                	ld	a3,0(a5)
ffffffffc0202a3e:	02860713          	addi	a4,a2,40
    prev->next = next->prev = elm;
ffffffffc0202a42:	e398                	sd	a4,0(a5)
ffffffffc0202a44:	e698                	sd	a4,8(a3)
}
ffffffffc0202a46:	4501                	li	a0,0
    elm->next = next;
ffffffffc0202a48:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc0202a4a:	f614                	sd	a3,40(a2)
ffffffffc0202a4c:	8082                	ret
{
ffffffffc0202a4e:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0202a50:	00005697          	auipc	a3,0x5
ffffffffc0202a54:	0d868693          	addi	a3,a3,216 # ffffffffc0207b28 <commands+0x1110>
ffffffffc0202a58:	00004617          	auipc	a2,0x4
ffffffffc0202a5c:	3d060613          	addi	a2,a2,976 # ffffffffc0206e28 <commands+0x410>
ffffffffc0202a60:	03200593          	li	a1,50
ffffffffc0202a64:	00005517          	auipc	a0,0x5
ffffffffc0202a68:	f5450513          	addi	a0,a0,-172 # ffffffffc02079b8 <commands+0xfa0>
{
ffffffffc0202a6c:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0202a6e:	f9afd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202a72 <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0202a72:	000ac797          	auipc	a5,0xac
ffffffffc0202a76:	e0e78793          	addi	a5,a5,-498 # ffffffffc02ae880 <free_area>
ffffffffc0202a7a:	e79c                	sd	a5,8(a5)
ffffffffc0202a7c:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0202a7e:	0007a823          	sw	zero,16(a5)
}
ffffffffc0202a82:	8082                	ret

ffffffffc0202a84 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0202a84:	000ac517          	auipc	a0,0xac
ffffffffc0202a88:	e0c56503          	lwu	a0,-500(a0) # ffffffffc02ae890 <free_area+0x10>
ffffffffc0202a8c:	8082                	ret

ffffffffc0202a8e <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0202a8e:	715d                	addi	sp,sp,-80
ffffffffc0202a90:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc0202a92:	000ac417          	auipc	s0,0xac
ffffffffc0202a96:	dee40413          	addi	s0,s0,-530 # ffffffffc02ae880 <free_area>
ffffffffc0202a9a:	641c                	ld	a5,8(s0)
ffffffffc0202a9c:	e486                	sd	ra,72(sp)
ffffffffc0202a9e:	fc26                	sd	s1,56(sp)
ffffffffc0202aa0:	f84a                	sd	s2,48(sp)
ffffffffc0202aa2:	f44e                	sd	s3,40(sp)
ffffffffc0202aa4:	f052                	sd	s4,32(sp)
ffffffffc0202aa6:	ec56                	sd	s5,24(sp)
ffffffffc0202aa8:	e85a                	sd	s6,16(sp)
ffffffffc0202aaa:	e45e                	sd	s7,8(sp)
ffffffffc0202aac:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202aae:	2a878d63          	beq	a5,s0,ffffffffc0202d68 <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc0202ab2:	4481                	li	s1,0
ffffffffc0202ab4:	4901                	li	s2,0
ffffffffc0202ab6:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202aba:	8b09                	andi	a4,a4,2
ffffffffc0202abc:	2a070a63          	beqz	a4,ffffffffc0202d70 <default_check+0x2e2>
        count ++, total += p->property;
ffffffffc0202ac0:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202ac4:	679c                	ld	a5,8(a5)
ffffffffc0202ac6:	2905                	addiw	s2,s2,1
ffffffffc0202ac8:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202aca:	fe8796e3          	bne	a5,s0,ffffffffc0202ab6 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0202ace:	89a6                	mv	s3,s1
ffffffffc0202ad0:	35b000ef          	jal	ra,ffffffffc020362a <nr_free_pages>
ffffffffc0202ad4:	6f351e63          	bne	a0,s3,ffffffffc02031d0 <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202ad8:	4505                	li	a0,1
ffffffffc0202ada:	27f000ef          	jal	ra,ffffffffc0203558 <alloc_pages>
ffffffffc0202ade:	8aaa                	mv	s5,a0
ffffffffc0202ae0:	42050863          	beqz	a0,ffffffffc0202f10 <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202ae4:	4505                	li	a0,1
ffffffffc0202ae6:	273000ef          	jal	ra,ffffffffc0203558 <alloc_pages>
ffffffffc0202aea:	89aa                	mv	s3,a0
ffffffffc0202aec:	70050263          	beqz	a0,ffffffffc02031f0 <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202af0:	4505                	li	a0,1
ffffffffc0202af2:	267000ef          	jal	ra,ffffffffc0203558 <alloc_pages>
ffffffffc0202af6:	8a2a                	mv	s4,a0
ffffffffc0202af8:	48050c63          	beqz	a0,ffffffffc0202f90 <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0202afc:	293a8a63          	beq	s5,s3,ffffffffc0202d90 <default_check+0x302>
ffffffffc0202b00:	28aa8863          	beq	s5,a0,ffffffffc0202d90 <default_check+0x302>
ffffffffc0202b04:	28a98663          	beq	s3,a0,ffffffffc0202d90 <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0202b08:	000aa783          	lw	a5,0(s5)
ffffffffc0202b0c:	2a079263          	bnez	a5,ffffffffc0202db0 <default_check+0x322>
ffffffffc0202b10:	0009a783          	lw	a5,0(s3)
ffffffffc0202b14:	28079e63          	bnez	a5,ffffffffc0202db0 <default_check+0x322>
ffffffffc0202b18:	411c                	lw	a5,0(a0)
ffffffffc0202b1a:	28079b63          	bnez	a5,ffffffffc0202db0 <default_check+0x322>
    return page - pages + nbase;
ffffffffc0202b1e:	000b0797          	auipc	a5,0xb0
ffffffffc0202b22:	dea7b783          	ld	a5,-534(a5) # ffffffffc02b2908 <pages>
ffffffffc0202b26:	40fa8733          	sub	a4,s5,a5
ffffffffc0202b2a:	00006617          	auipc	a2,0x6
ffffffffc0202b2e:	34663603          	ld	a2,838(a2) # ffffffffc0208e70 <nbase>
ffffffffc0202b32:	8719                	srai	a4,a4,0x6
ffffffffc0202b34:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0202b36:	000b0697          	auipc	a3,0xb0
ffffffffc0202b3a:	dca6b683          	ld	a3,-566(a3) # ffffffffc02b2900 <npage>
ffffffffc0202b3e:	06b2                	slli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202b40:	0732                	slli	a4,a4,0xc
ffffffffc0202b42:	28d77763          	bgeu	a4,a3,ffffffffc0202dd0 <default_check+0x342>
    return page - pages + nbase;
ffffffffc0202b46:	40f98733          	sub	a4,s3,a5
ffffffffc0202b4a:	8719                	srai	a4,a4,0x6
ffffffffc0202b4c:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202b4e:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0202b50:	4cd77063          	bgeu	a4,a3,ffffffffc0203010 <default_check+0x582>
    return page - pages + nbase;
ffffffffc0202b54:	40f507b3          	sub	a5,a0,a5
ffffffffc0202b58:	8799                	srai	a5,a5,0x6
ffffffffc0202b5a:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202b5c:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0202b5e:	30d7f963          	bgeu	a5,a3,ffffffffc0202e70 <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc0202b62:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202b64:	00043c03          	ld	s8,0(s0)
ffffffffc0202b68:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0202b6c:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0202b70:	e400                	sd	s0,8(s0)
ffffffffc0202b72:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0202b74:	000ac797          	auipc	a5,0xac
ffffffffc0202b78:	d007ae23          	sw	zero,-740(a5) # ffffffffc02ae890 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0202b7c:	1dd000ef          	jal	ra,ffffffffc0203558 <alloc_pages>
ffffffffc0202b80:	2c051863          	bnez	a0,ffffffffc0202e50 <default_check+0x3c2>
    free_page(p0);
ffffffffc0202b84:	4585                	li	a1,1
ffffffffc0202b86:	8556                	mv	a0,s5
ffffffffc0202b88:	263000ef          	jal	ra,ffffffffc02035ea <free_pages>
    free_page(p1);
ffffffffc0202b8c:	4585                	li	a1,1
ffffffffc0202b8e:	854e                	mv	a0,s3
ffffffffc0202b90:	25b000ef          	jal	ra,ffffffffc02035ea <free_pages>
    free_page(p2);
ffffffffc0202b94:	4585                	li	a1,1
ffffffffc0202b96:	8552                	mv	a0,s4
ffffffffc0202b98:	253000ef          	jal	ra,ffffffffc02035ea <free_pages>
    assert(nr_free == 3);
ffffffffc0202b9c:	4818                	lw	a4,16(s0)
ffffffffc0202b9e:	478d                	li	a5,3
ffffffffc0202ba0:	28f71863          	bne	a4,a5,ffffffffc0202e30 <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202ba4:	4505                	li	a0,1
ffffffffc0202ba6:	1b3000ef          	jal	ra,ffffffffc0203558 <alloc_pages>
ffffffffc0202baa:	89aa                	mv	s3,a0
ffffffffc0202bac:	26050263          	beqz	a0,ffffffffc0202e10 <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202bb0:	4505                	li	a0,1
ffffffffc0202bb2:	1a7000ef          	jal	ra,ffffffffc0203558 <alloc_pages>
ffffffffc0202bb6:	8aaa                	mv	s5,a0
ffffffffc0202bb8:	3a050c63          	beqz	a0,ffffffffc0202f70 <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202bbc:	4505                	li	a0,1
ffffffffc0202bbe:	19b000ef          	jal	ra,ffffffffc0203558 <alloc_pages>
ffffffffc0202bc2:	8a2a                	mv	s4,a0
ffffffffc0202bc4:	38050663          	beqz	a0,ffffffffc0202f50 <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc0202bc8:	4505                	li	a0,1
ffffffffc0202bca:	18f000ef          	jal	ra,ffffffffc0203558 <alloc_pages>
ffffffffc0202bce:	36051163          	bnez	a0,ffffffffc0202f30 <default_check+0x4a2>
    free_page(p0);
ffffffffc0202bd2:	4585                	li	a1,1
ffffffffc0202bd4:	854e                	mv	a0,s3
ffffffffc0202bd6:	215000ef          	jal	ra,ffffffffc02035ea <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0202bda:	641c                	ld	a5,8(s0)
ffffffffc0202bdc:	20878a63          	beq	a5,s0,ffffffffc0202df0 <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc0202be0:	4505                	li	a0,1
ffffffffc0202be2:	177000ef          	jal	ra,ffffffffc0203558 <alloc_pages>
ffffffffc0202be6:	30a99563          	bne	s3,a0,ffffffffc0202ef0 <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc0202bea:	4505                	li	a0,1
ffffffffc0202bec:	16d000ef          	jal	ra,ffffffffc0203558 <alloc_pages>
ffffffffc0202bf0:	2e051063          	bnez	a0,ffffffffc0202ed0 <default_check+0x442>
    assert(nr_free == 0);
ffffffffc0202bf4:	481c                	lw	a5,16(s0)
ffffffffc0202bf6:	2a079d63          	bnez	a5,ffffffffc0202eb0 <default_check+0x422>
    free_page(p);
ffffffffc0202bfa:	854e                	mv	a0,s3
ffffffffc0202bfc:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0202bfe:	01843023          	sd	s8,0(s0)
ffffffffc0202c02:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0202c06:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0202c0a:	1e1000ef          	jal	ra,ffffffffc02035ea <free_pages>
    free_page(p1);
ffffffffc0202c0e:	4585                	li	a1,1
ffffffffc0202c10:	8556                	mv	a0,s5
ffffffffc0202c12:	1d9000ef          	jal	ra,ffffffffc02035ea <free_pages>
    free_page(p2);
ffffffffc0202c16:	4585                	li	a1,1
ffffffffc0202c18:	8552                	mv	a0,s4
ffffffffc0202c1a:	1d1000ef          	jal	ra,ffffffffc02035ea <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0202c1e:	4515                	li	a0,5
ffffffffc0202c20:	139000ef          	jal	ra,ffffffffc0203558 <alloc_pages>
ffffffffc0202c24:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0202c26:	26050563          	beqz	a0,ffffffffc0202e90 <default_check+0x402>
ffffffffc0202c2a:	651c                	ld	a5,8(a0)
ffffffffc0202c2c:	8385                	srli	a5,a5,0x1
ffffffffc0202c2e:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc0202c30:	54079063          	bnez	a5,ffffffffc0203170 <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0202c34:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202c36:	00043b03          	ld	s6,0(s0)
ffffffffc0202c3a:	00843a83          	ld	s5,8(s0)
ffffffffc0202c3e:	e000                	sd	s0,0(s0)
ffffffffc0202c40:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0202c42:	117000ef          	jal	ra,ffffffffc0203558 <alloc_pages>
ffffffffc0202c46:	50051563          	bnez	a0,ffffffffc0203150 <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0202c4a:	08098a13          	addi	s4,s3,128
ffffffffc0202c4e:	8552                	mv	a0,s4
ffffffffc0202c50:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0202c52:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0202c56:	000ac797          	auipc	a5,0xac
ffffffffc0202c5a:	c207ad23          	sw	zero,-966(a5) # ffffffffc02ae890 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0202c5e:	18d000ef          	jal	ra,ffffffffc02035ea <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0202c62:	4511                	li	a0,4
ffffffffc0202c64:	0f5000ef          	jal	ra,ffffffffc0203558 <alloc_pages>
ffffffffc0202c68:	4c051463          	bnez	a0,ffffffffc0203130 <default_check+0x6a2>
ffffffffc0202c6c:	0889b783          	ld	a5,136(s3)
ffffffffc0202c70:	8385                	srli	a5,a5,0x1
ffffffffc0202c72:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0202c74:	48078e63          	beqz	a5,ffffffffc0203110 <default_check+0x682>
ffffffffc0202c78:	0909a703          	lw	a4,144(s3)
ffffffffc0202c7c:	478d                	li	a5,3
ffffffffc0202c7e:	48f71963          	bne	a4,a5,ffffffffc0203110 <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0202c82:	450d                	li	a0,3
ffffffffc0202c84:	0d5000ef          	jal	ra,ffffffffc0203558 <alloc_pages>
ffffffffc0202c88:	8c2a                	mv	s8,a0
ffffffffc0202c8a:	46050363          	beqz	a0,ffffffffc02030f0 <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc0202c8e:	4505                	li	a0,1
ffffffffc0202c90:	0c9000ef          	jal	ra,ffffffffc0203558 <alloc_pages>
ffffffffc0202c94:	42051e63          	bnez	a0,ffffffffc02030d0 <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc0202c98:	418a1c63          	bne	s4,s8,ffffffffc02030b0 <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0202c9c:	4585                	li	a1,1
ffffffffc0202c9e:	854e                	mv	a0,s3
ffffffffc0202ca0:	14b000ef          	jal	ra,ffffffffc02035ea <free_pages>
    free_pages(p1, 3);
ffffffffc0202ca4:	458d                	li	a1,3
ffffffffc0202ca6:	8552                	mv	a0,s4
ffffffffc0202ca8:	143000ef          	jal	ra,ffffffffc02035ea <free_pages>
ffffffffc0202cac:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0202cb0:	04098c13          	addi	s8,s3,64
ffffffffc0202cb4:	8385                	srli	a5,a5,0x1
ffffffffc0202cb6:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0202cb8:	3c078c63          	beqz	a5,ffffffffc0203090 <default_check+0x602>
ffffffffc0202cbc:	0109a703          	lw	a4,16(s3)
ffffffffc0202cc0:	4785                	li	a5,1
ffffffffc0202cc2:	3cf71763          	bne	a4,a5,ffffffffc0203090 <default_check+0x602>
ffffffffc0202cc6:	008a3783          	ld	a5,8(s4)
ffffffffc0202cca:	8385                	srli	a5,a5,0x1
ffffffffc0202ccc:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0202cce:	3a078163          	beqz	a5,ffffffffc0203070 <default_check+0x5e2>
ffffffffc0202cd2:	010a2703          	lw	a4,16(s4)
ffffffffc0202cd6:	478d                	li	a5,3
ffffffffc0202cd8:	38f71c63          	bne	a4,a5,ffffffffc0203070 <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0202cdc:	4505                	li	a0,1
ffffffffc0202cde:	07b000ef          	jal	ra,ffffffffc0203558 <alloc_pages>
ffffffffc0202ce2:	36a99763          	bne	s3,a0,ffffffffc0203050 <default_check+0x5c2>
    free_page(p0);
ffffffffc0202ce6:	4585                	li	a1,1
ffffffffc0202ce8:	103000ef          	jal	ra,ffffffffc02035ea <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202cec:	4509                	li	a0,2
ffffffffc0202cee:	06b000ef          	jal	ra,ffffffffc0203558 <alloc_pages>
ffffffffc0202cf2:	32aa1f63          	bne	s4,a0,ffffffffc0203030 <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc0202cf6:	4589                	li	a1,2
ffffffffc0202cf8:	0f3000ef          	jal	ra,ffffffffc02035ea <free_pages>
    free_page(p2);
ffffffffc0202cfc:	4585                	li	a1,1
ffffffffc0202cfe:	8562                	mv	a0,s8
ffffffffc0202d00:	0eb000ef          	jal	ra,ffffffffc02035ea <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0202d04:	4515                	li	a0,5
ffffffffc0202d06:	053000ef          	jal	ra,ffffffffc0203558 <alloc_pages>
ffffffffc0202d0a:	89aa                	mv	s3,a0
ffffffffc0202d0c:	48050263          	beqz	a0,ffffffffc0203190 <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc0202d10:	4505                	li	a0,1
ffffffffc0202d12:	047000ef          	jal	ra,ffffffffc0203558 <alloc_pages>
ffffffffc0202d16:	2c051d63          	bnez	a0,ffffffffc0202ff0 <default_check+0x562>

    assert(nr_free == 0);
ffffffffc0202d1a:	481c                	lw	a5,16(s0)
ffffffffc0202d1c:	2a079a63          	bnez	a5,ffffffffc0202fd0 <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0202d20:	4595                	li	a1,5
ffffffffc0202d22:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0202d24:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0202d28:	01643023          	sd	s6,0(s0)
ffffffffc0202d2c:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0202d30:	0bb000ef          	jal	ra,ffffffffc02035ea <free_pages>
    return listelm->next;
ffffffffc0202d34:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202d36:	00878963          	beq	a5,s0,ffffffffc0202d48 <default_check+0x2ba>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0202d3a:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202d3e:	679c                	ld	a5,8(a5)
ffffffffc0202d40:	397d                	addiw	s2,s2,-1
ffffffffc0202d42:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202d44:	fe879be3          	bne	a5,s0,ffffffffc0202d3a <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc0202d48:	26091463          	bnez	s2,ffffffffc0202fb0 <default_check+0x522>
    assert(total == 0);
ffffffffc0202d4c:	46049263          	bnez	s1,ffffffffc02031b0 <default_check+0x722>
}
ffffffffc0202d50:	60a6                	ld	ra,72(sp)
ffffffffc0202d52:	6406                	ld	s0,64(sp)
ffffffffc0202d54:	74e2                	ld	s1,56(sp)
ffffffffc0202d56:	7942                	ld	s2,48(sp)
ffffffffc0202d58:	79a2                	ld	s3,40(sp)
ffffffffc0202d5a:	7a02                	ld	s4,32(sp)
ffffffffc0202d5c:	6ae2                	ld	s5,24(sp)
ffffffffc0202d5e:	6b42                	ld	s6,16(sp)
ffffffffc0202d60:	6ba2                	ld	s7,8(sp)
ffffffffc0202d62:	6c02                	ld	s8,0(sp)
ffffffffc0202d64:	6161                	addi	sp,sp,80
ffffffffc0202d66:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202d68:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0202d6a:	4481                	li	s1,0
ffffffffc0202d6c:	4901                	li	s2,0
ffffffffc0202d6e:	b38d                	j	ffffffffc0202ad0 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0202d70:	00005697          	auipc	a3,0x5
ffffffffc0202d74:	82868693          	addi	a3,a3,-2008 # ffffffffc0207598 <commands+0xb80>
ffffffffc0202d78:	00004617          	auipc	a2,0x4
ffffffffc0202d7c:	0b060613          	addi	a2,a2,176 # ffffffffc0206e28 <commands+0x410>
ffffffffc0202d80:	0f000593          	li	a1,240
ffffffffc0202d84:	00005517          	auipc	a0,0x5
ffffffffc0202d88:	ddc50513          	addi	a0,a0,-548 # ffffffffc0207b60 <commands+0x1148>
ffffffffc0202d8c:	c7cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0202d90:	00005697          	auipc	a3,0x5
ffffffffc0202d94:	e4868693          	addi	a3,a3,-440 # ffffffffc0207bd8 <commands+0x11c0>
ffffffffc0202d98:	00004617          	auipc	a2,0x4
ffffffffc0202d9c:	09060613          	addi	a2,a2,144 # ffffffffc0206e28 <commands+0x410>
ffffffffc0202da0:	0bd00593          	li	a1,189
ffffffffc0202da4:	00005517          	auipc	a0,0x5
ffffffffc0202da8:	dbc50513          	addi	a0,a0,-580 # ffffffffc0207b60 <commands+0x1148>
ffffffffc0202dac:	c5cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0202db0:	00005697          	auipc	a3,0x5
ffffffffc0202db4:	e5068693          	addi	a3,a3,-432 # ffffffffc0207c00 <commands+0x11e8>
ffffffffc0202db8:	00004617          	auipc	a2,0x4
ffffffffc0202dbc:	07060613          	addi	a2,a2,112 # ffffffffc0206e28 <commands+0x410>
ffffffffc0202dc0:	0be00593          	li	a1,190
ffffffffc0202dc4:	00005517          	auipc	a0,0x5
ffffffffc0202dc8:	d9c50513          	addi	a0,a0,-612 # ffffffffc0207b60 <commands+0x1148>
ffffffffc0202dcc:	c3cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0202dd0:	00005697          	auipc	a3,0x5
ffffffffc0202dd4:	e7068693          	addi	a3,a3,-400 # ffffffffc0207c40 <commands+0x1228>
ffffffffc0202dd8:	00004617          	auipc	a2,0x4
ffffffffc0202ddc:	05060613          	addi	a2,a2,80 # ffffffffc0206e28 <commands+0x410>
ffffffffc0202de0:	0c000593          	li	a1,192
ffffffffc0202de4:	00005517          	auipc	a0,0x5
ffffffffc0202de8:	d7c50513          	addi	a0,a0,-644 # ffffffffc0207b60 <commands+0x1148>
ffffffffc0202dec:	c1cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0202df0:	00005697          	auipc	a3,0x5
ffffffffc0202df4:	ed868693          	addi	a3,a3,-296 # ffffffffc0207cc8 <commands+0x12b0>
ffffffffc0202df8:	00004617          	auipc	a2,0x4
ffffffffc0202dfc:	03060613          	addi	a2,a2,48 # ffffffffc0206e28 <commands+0x410>
ffffffffc0202e00:	0d900593          	li	a1,217
ffffffffc0202e04:	00005517          	auipc	a0,0x5
ffffffffc0202e08:	d5c50513          	addi	a0,a0,-676 # ffffffffc0207b60 <commands+0x1148>
ffffffffc0202e0c:	bfcfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202e10:	00005697          	auipc	a3,0x5
ffffffffc0202e14:	d6868693          	addi	a3,a3,-664 # ffffffffc0207b78 <commands+0x1160>
ffffffffc0202e18:	00004617          	auipc	a2,0x4
ffffffffc0202e1c:	01060613          	addi	a2,a2,16 # ffffffffc0206e28 <commands+0x410>
ffffffffc0202e20:	0d200593          	li	a1,210
ffffffffc0202e24:	00005517          	auipc	a0,0x5
ffffffffc0202e28:	d3c50513          	addi	a0,a0,-708 # ffffffffc0207b60 <commands+0x1148>
ffffffffc0202e2c:	bdcfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free == 3);
ffffffffc0202e30:	00005697          	auipc	a3,0x5
ffffffffc0202e34:	e8868693          	addi	a3,a3,-376 # ffffffffc0207cb8 <commands+0x12a0>
ffffffffc0202e38:	00004617          	auipc	a2,0x4
ffffffffc0202e3c:	ff060613          	addi	a2,a2,-16 # ffffffffc0206e28 <commands+0x410>
ffffffffc0202e40:	0d000593          	li	a1,208
ffffffffc0202e44:	00005517          	auipc	a0,0x5
ffffffffc0202e48:	d1c50513          	addi	a0,a0,-740 # ffffffffc0207b60 <commands+0x1148>
ffffffffc0202e4c:	bbcfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202e50:	00005697          	auipc	a3,0x5
ffffffffc0202e54:	e5068693          	addi	a3,a3,-432 # ffffffffc0207ca0 <commands+0x1288>
ffffffffc0202e58:	00004617          	auipc	a2,0x4
ffffffffc0202e5c:	fd060613          	addi	a2,a2,-48 # ffffffffc0206e28 <commands+0x410>
ffffffffc0202e60:	0cb00593          	li	a1,203
ffffffffc0202e64:	00005517          	auipc	a0,0x5
ffffffffc0202e68:	cfc50513          	addi	a0,a0,-772 # ffffffffc0207b60 <commands+0x1148>
ffffffffc0202e6c:	b9cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0202e70:	00005697          	auipc	a3,0x5
ffffffffc0202e74:	e1068693          	addi	a3,a3,-496 # ffffffffc0207c80 <commands+0x1268>
ffffffffc0202e78:	00004617          	auipc	a2,0x4
ffffffffc0202e7c:	fb060613          	addi	a2,a2,-80 # ffffffffc0206e28 <commands+0x410>
ffffffffc0202e80:	0c200593          	li	a1,194
ffffffffc0202e84:	00005517          	auipc	a0,0x5
ffffffffc0202e88:	cdc50513          	addi	a0,a0,-804 # ffffffffc0207b60 <commands+0x1148>
ffffffffc0202e8c:	b7cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(p0 != NULL);
ffffffffc0202e90:	00005697          	auipc	a3,0x5
ffffffffc0202e94:	e7068693          	addi	a3,a3,-400 # ffffffffc0207d00 <commands+0x12e8>
ffffffffc0202e98:	00004617          	auipc	a2,0x4
ffffffffc0202e9c:	f9060613          	addi	a2,a2,-112 # ffffffffc0206e28 <commands+0x410>
ffffffffc0202ea0:	0f800593          	li	a1,248
ffffffffc0202ea4:	00005517          	auipc	a0,0x5
ffffffffc0202ea8:	cbc50513          	addi	a0,a0,-836 # ffffffffc0207b60 <commands+0x1148>
ffffffffc0202eac:	b5cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free == 0);
ffffffffc0202eb0:	00005697          	auipc	a3,0x5
ffffffffc0202eb4:	89868693          	addi	a3,a3,-1896 # ffffffffc0207748 <commands+0xd30>
ffffffffc0202eb8:	00004617          	auipc	a2,0x4
ffffffffc0202ebc:	f7060613          	addi	a2,a2,-144 # ffffffffc0206e28 <commands+0x410>
ffffffffc0202ec0:	0df00593          	li	a1,223
ffffffffc0202ec4:	00005517          	auipc	a0,0x5
ffffffffc0202ec8:	c9c50513          	addi	a0,a0,-868 # ffffffffc0207b60 <commands+0x1148>
ffffffffc0202ecc:	b3cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202ed0:	00005697          	auipc	a3,0x5
ffffffffc0202ed4:	dd068693          	addi	a3,a3,-560 # ffffffffc0207ca0 <commands+0x1288>
ffffffffc0202ed8:	00004617          	auipc	a2,0x4
ffffffffc0202edc:	f5060613          	addi	a2,a2,-176 # ffffffffc0206e28 <commands+0x410>
ffffffffc0202ee0:	0dd00593          	li	a1,221
ffffffffc0202ee4:	00005517          	auipc	a0,0x5
ffffffffc0202ee8:	c7c50513          	addi	a0,a0,-900 # ffffffffc0207b60 <commands+0x1148>
ffffffffc0202eec:	b1cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0202ef0:	00005697          	auipc	a3,0x5
ffffffffc0202ef4:	df068693          	addi	a3,a3,-528 # ffffffffc0207ce0 <commands+0x12c8>
ffffffffc0202ef8:	00004617          	auipc	a2,0x4
ffffffffc0202efc:	f3060613          	addi	a2,a2,-208 # ffffffffc0206e28 <commands+0x410>
ffffffffc0202f00:	0dc00593          	li	a1,220
ffffffffc0202f04:	00005517          	auipc	a0,0x5
ffffffffc0202f08:	c5c50513          	addi	a0,a0,-932 # ffffffffc0207b60 <commands+0x1148>
ffffffffc0202f0c:	afcfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202f10:	00005697          	auipc	a3,0x5
ffffffffc0202f14:	c6868693          	addi	a3,a3,-920 # ffffffffc0207b78 <commands+0x1160>
ffffffffc0202f18:	00004617          	auipc	a2,0x4
ffffffffc0202f1c:	f1060613          	addi	a2,a2,-240 # ffffffffc0206e28 <commands+0x410>
ffffffffc0202f20:	0b900593          	li	a1,185
ffffffffc0202f24:	00005517          	auipc	a0,0x5
ffffffffc0202f28:	c3c50513          	addi	a0,a0,-964 # ffffffffc0207b60 <commands+0x1148>
ffffffffc0202f2c:	adcfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202f30:	00005697          	auipc	a3,0x5
ffffffffc0202f34:	d7068693          	addi	a3,a3,-656 # ffffffffc0207ca0 <commands+0x1288>
ffffffffc0202f38:	00004617          	auipc	a2,0x4
ffffffffc0202f3c:	ef060613          	addi	a2,a2,-272 # ffffffffc0206e28 <commands+0x410>
ffffffffc0202f40:	0d600593          	li	a1,214
ffffffffc0202f44:	00005517          	auipc	a0,0x5
ffffffffc0202f48:	c1c50513          	addi	a0,a0,-996 # ffffffffc0207b60 <commands+0x1148>
ffffffffc0202f4c:	abcfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202f50:	00005697          	auipc	a3,0x5
ffffffffc0202f54:	c6868693          	addi	a3,a3,-920 # ffffffffc0207bb8 <commands+0x11a0>
ffffffffc0202f58:	00004617          	auipc	a2,0x4
ffffffffc0202f5c:	ed060613          	addi	a2,a2,-304 # ffffffffc0206e28 <commands+0x410>
ffffffffc0202f60:	0d400593          	li	a1,212
ffffffffc0202f64:	00005517          	auipc	a0,0x5
ffffffffc0202f68:	bfc50513          	addi	a0,a0,-1028 # ffffffffc0207b60 <commands+0x1148>
ffffffffc0202f6c:	a9cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202f70:	00005697          	auipc	a3,0x5
ffffffffc0202f74:	c2868693          	addi	a3,a3,-984 # ffffffffc0207b98 <commands+0x1180>
ffffffffc0202f78:	00004617          	auipc	a2,0x4
ffffffffc0202f7c:	eb060613          	addi	a2,a2,-336 # ffffffffc0206e28 <commands+0x410>
ffffffffc0202f80:	0d300593          	li	a1,211
ffffffffc0202f84:	00005517          	auipc	a0,0x5
ffffffffc0202f88:	bdc50513          	addi	a0,a0,-1060 # ffffffffc0207b60 <commands+0x1148>
ffffffffc0202f8c:	a7cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202f90:	00005697          	auipc	a3,0x5
ffffffffc0202f94:	c2868693          	addi	a3,a3,-984 # ffffffffc0207bb8 <commands+0x11a0>
ffffffffc0202f98:	00004617          	auipc	a2,0x4
ffffffffc0202f9c:	e9060613          	addi	a2,a2,-368 # ffffffffc0206e28 <commands+0x410>
ffffffffc0202fa0:	0bb00593          	li	a1,187
ffffffffc0202fa4:	00005517          	auipc	a0,0x5
ffffffffc0202fa8:	bbc50513          	addi	a0,a0,-1092 # ffffffffc0207b60 <commands+0x1148>
ffffffffc0202fac:	a5cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(count == 0);
ffffffffc0202fb0:	00005697          	auipc	a3,0x5
ffffffffc0202fb4:	ea068693          	addi	a3,a3,-352 # ffffffffc0207e50 <commands+0x1438>
ffffffffc0202fb8:	00004617          	auipc	a2,0x4
ffffffffc0202fbc:	e7060613          	addi	a2,a2,-400 # ffffffffc0206e28 <commands+0x410>
ffffffffc0202fc0:	12500593          	li	a1,293
ffffffffc0202fc4:	00005517          	auipc	a0,0x5
ffffffffc0202fc8:	b9c50513          	addi	a0,a0,-1124 # ffffffffc0207b60 <commands+0x1148>
ffffffffc0202fcc:	a3cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free == 0);
ffffffffc0202fd0:	00004697          	auipc	a3,0x4
ffffffffc0202fd4:	77868693          	addi	a3,a3,1912 # ffffffffc0207748 <commands+0xd30>
ffffffffc0202fd8:	00004617          	auipc	a2,0x4
ffffffffc0202fdc:	e5060613          	addi	a2,a2,-432 # ffffffffc0206e28 <commands+0x410>
ffffffffc0202fe0:	11a00593          	li	a1,282
ffffffffc0202fe4:	00005517          	auipc	a0,0x5
ffffffffc0202fe8:	b7c50513          	addi	a0,a0,-1156 # ffffffffc0207b60 <commands+0x1148>
ffffffffc0202fec:	a1cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202ff0:	00005697          	auipc	a3,0x5
ffffffffc0202ff4:	cb068693          	addi	a3,a3,-848 # ffffffffc0207ca0 <commands+0x1288>
ffffffffc0202ff8:	00004617          	auipc	a2,0x4
ffffffffc0202ffc:	e3060613          	addi	a2,a2,-464 # ffffffffc0206e28 <commands+0x410>
ffffffffc0203000:	11800593          	li	a1,280
ffffffffc0203004:	00005517          	auipc	a0,0x5
ffffffffc0203008:	b5c50513          	addi	a0,a0,-1188 # ffffffffc0207b60 <commands+0x1148>
ffffffffc020300c:	9fcfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0203010:	00005697          	auipc	a3,0x5
ffffffffc0203014:	c5068693          	addi	a3,a3,-944 # ffffffffc0207c60 <commands+0x1248>
ffffffffc0203018:	00004617          	auipc	a2,0x4
ffffffffc020301c:	e1060613          	addi	a2,a2,-496 # ffffffffc0206e28 <commands+0x410>
ffffffffc0203020:	0c100593          	li	a1,193
ffffffffc0203024:	00005517          	auipc	a0,0x5
ffffffffc0203028:	b3c50513          	addi	a0,a0,-1220 # ffffffffc0207b60 <commands+0x1148>
ffffffffc020302c:	9dcfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0203030:	00005697          	auipc	a3,0x5
ffffffffc0203034:	de068693          	addi	a3,a3,-544 # ffffffffc0207e10 <commands+0x13f8>
ffffffffc0203038:	00004617          	auipc	a2,0x4
ffffffffc020303c:	df060613          	addi	a2,a2,-528 # ffffffffc0206e28 <commands+0x410>
ffffffffc0203040:	11200593          	li	a1,274
ffffffffc0203044:	00005517          	auipc	a0,0x5
ffffffffc0203048:	b1c50513          	addi	a0,a0,-1252 # ffffffffc0207b60 <commands+0x1148>
ffffffffc020304c:	9bcfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0203050:	00005697          	auipc	a3,0x5
ffffffffc0203054:	da068693          	addi	a3,a3,-608 # ffffffffc0207df0 <commands+0x13d8>
ffffffffc0203058:	00004617          	auipc	a2,0x4
ffffffffc020305c:	dd060613          	addi	a2,a2,-560 # ffffffffc0206e28 <commands+0x410>
ffffffffc0203060:	11000593          	li	a1,272
ffffffffc0203064:	00005517          	auipc	a0,0x5
ffffffffc0203068:	afc50513          	addi	a0,a0,-1284 # ffffffffc0207b60 <commands+0x1148>
ffffffffc020306c:	99cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0203070:	00005697          	auipc	a3,0x5
ffffffffc0203074:	d5868693          	addi	a3,a3,-680 # ffffffffc0207dc8 <commands+0x13b0>
ffffffffc0203078:	00004617          	auipc	a2,0x4
ffffffffc020307c:	db060613          	addi	a2,a2,-592 # ffffffffc0206e28 <commands+0x410>
ffffffffc0203080:	10e00593          	li	a1,270
ffffffffc0203084:	00005517          	auipc	a0,0x5
ffffffffc0203088:	adc50513          	addi	a0,a0,-1316 # ffffffffc0207b60 <commands+0x1148>
ffffffffc020308c:	97cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0203090:	00005697          	auipc	a3,0x5
ffffffffc0203094:	d1068693          	addi	a3,a3,-752 # ffffffffc0207da0 <commands+0x1388>
ffffffffc0203098:	00004617          	auipc	a2,0x4
ffffffffc020309c:	d9060613          	addi	a2,a2,-624 # ffffffffc0206e28 <commands+0x410>
ffffffffc02030a0:	10d00593          	li	a1,269
ffffffffc02030a4:	00005517          	auipc	a0,0x5
ffffffffc02030a8:	abc50513          	addi	a0,a0,-1348 # ffffffffc0207b60 <commands+0x1148>
ffffffffc02030ac:	95cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(p0 + 2 == p1);
ffffffffc02030b0:	00005697          	auipc	a3,0x5
ffffffffc02030b4:	ce068693          	addi	a3,a3,-800 # ffffffffc0207d90 <commands+0x1378>
ffffffffc02030b8:	00004617          	auipc	a2,0x4
ffffffffc02030bc:	d7060613          	addi	a2,a2,-656 # ffffffffc0206e28 <commands+0x410>
ffffffffc02030c0:	10800593          	li	a1,264
ffffffffc02030c4:	00005517          	auipc	a0,0x5
ffffffffc02030c8:	a9c50513          	addi	a0,a0,-1380 # ffffffffc0207b60 <commands+0x1148>
ffffffffc02030cc:	93cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02030d0:	00005697          	auipc	a3,0x5
ffffffffc02030d4:	bd068693          	addi	a3,a3,-1072 # ffffffffc0207ca0 <commands+0x1288>
ffffffffc02030d8:	00004617          	auipc	a2,0x4
ffffffffc02030dc:	d5060613          	addi	a2,a2,-688 # ffffffffc0206e28 <commands+0x410>
ffffffffc02030e0:	10700593          	li	a1,263
ffffffffc02030e4:	00005517          	auipc	a0,0x5
ffffffffc02030e8:	a7c50513          	addi	a0,a0,-1412 # ffffffffc0207b60 <commands+0x1148>
ffffffffc02030ec:	91cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02030f0:	00005697          	auipc	a3,0x5
ffffffffc02030f4:	c8068693          	addi	a3,a3,-896 # ffffffffc0207d70 <commands+0x1358>
ffffffffc02030f8:	00004617          	auipc	a2,0x4
ffffffffc02030fc:	d3060613          	addi	a2,a2,-720 # ffffffffc0206e28 <commands+0x410>
ffffffffc0203100:	10600593          	li	a1,262
ffffffffc0203104:	00005517          	auipc	a0,0x5
ffffffffc0203108:	a5c50513          	addi	a0,a0,-1444 # ffffffffc0207b60 <commands+0x1148>
ffffffffc020310c:	8fcfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0203110:	00005697          	auipc	a3,0x5
ffffffffc0203114:	c3068693          	addi	a3,a3,-976 # ffffffffc0207d40 <commands+0x1328>
ffffffffc0203118:	00004617          	auipc	a2,0x4
ffffffffc020311c:	d1060613          	addi	a2,a2,-752 # ffffffffc0206e28 <commands+0x410>
ffffffffc0203120:	10500593          	li	a1,261
ffffffffc0203124:	00005517          	auipc	a0,0x5
ffffffffc0203128:	a3c50513          	addi	a0,a0,-1476 # ffffffffc0207b60 <commands+0x1148>
ffffffffc020312c:	8dcfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0203130:	00005697          	auipc	a3,0x5
ffffffffc0203134:	bf868693          	addi	a3,a3,-1032 # ffffffffc0207d28 <commands+0x1310>
ffffffffc0203138:	00004617          	auipc	a2,0x4
ffffffffc020313c:	cf060613          	addi	a2,a2,-784 # ffffffffc0206e28 <commands+0x410>
ffffffffc0203140:	10400593          	li	a1,260
ffffffffc0203144:	00005517          	auipc	a0,0x5
ffffffffc0203148:	a1c50513          	addi	a0,a0,-1508 # ffffffffc0207b60 <commands+0x1148>
ffffffffc020314c:	8bcfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203150:	00005697          	auipc	a3,0x5
ffffffffc0203154:	b5068693          	addi	a3,a3,-1200 # ffffffffc0207ca0 <commands+0x1288>
ffffffffc0203158:	00004617          	auipc	a2,0x4
ffffffffc020315c:	cd060613          	addi	a2,a2,-816 # ffffffffc0206e28 <commands+0x410>
ffffffffc0203160:	0fe00593          	li	a1,254
ffffffffc0203164:	00005517          	auipc	a0,0x5
ffffffffc0203168:	9fc50513          	addi	a0,a0,-1540 # ffffffffc0207b60 <commands+0x1148>
ffffffffc020316c:	89cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(!PageProperty(p0));
ffffffffc0203170:	00005697          	auipc	a3,0x5
ffffffffc0203174:	ba068693          	addi	a3,a3,-1120 # ffffffffc0207d10 <commands+0x12f8>
ffffffffc0203178:	00004617          	auipc	a2,0x4
ffffffffc020317c:	cb060613          	addi	a2,a2,-848 # ffffffffc0206e28 <commands+0x410>
ffffffffc0203180:	0f900593          	li	a1,249
ffffffffc0203184:	00005517          	auipc	a0,0x5
ffffffffc0203188:	9dc50513          	addi	a0,a0,-1572 # ffffffffc0207b60 <commands+0x1148>
ffffffffc020318c:	87cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0203190:	00005697          	auipc	a3,0x5
ffffffffc0203194:	ca068693          	addi	a3,a3,-864 # ffffffffc0207e30 <commands+0x1418>
ffffffffc0203198:	00004617          	auipc	a2,0x4
ffffffffc020319c:	c9060613          	addi	a2,a2,-880 # ffffffffc0206e28 <commands+0x410>
ffffffffc02031a0:	11700593          	li	a1,279
ffffffffc02031a4:	00005517          	auipc	a0,0x5
ffffffffc02031a8:	9bc50513          	addi	a0,a0,-1604 # ffffffffc0207b60 <commands+0x1148>
ffffffffc02031ac:	85cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(total == 0);
ffffffffc02031b0:	00005697          	auipc	a3,0x5
ffffffffc02031b4:	cb068693          	addi	a3,a3,-848 # ffffffffc0207e60 <commands+0x1448>
ffffffffc02031b8:	00004617          	auipc	a2,0x4
ffffffffc02031bc:	c7060613          	addi	a2,a2,-912 # ffffffffc0206e28 <commands+0x410>
ffffffffc02031c0:	12600593          	li	a1,294
ffffffffc02031c4:	00005517          	auipc	a0,0x5
ffffffffc02031c8:	99c50513          	addi	a0,a0,-1636 # ffffffffc0207b60 <commands+0x1148>
ffffffffc02031cc:	83cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(total == nr_free_pages());
ffffffffc02031d0:	00004697          	auipc	a3,0x4
ffffffffc02031d4:	3d868693          	addi	a3,a3,984 # ffffffffc02075a8 <commands+0xb90>
ffffffffc02031d8:	00004617          	auipc	a2,0x4
ffffffffc02031dc:	c5060613          	addi	a2,a2,-944 # ffffffffc0206e28 <commands+0x410>
ffffffffc02031e0:	0f300593          	li	a1,243
ffffffffc02031e4:	00005517          	auipc	a0,0x5
ffffffffc02031e8:	97c50513          	addi	a0,a0,-1668 # ffffffffc0207b60 <commands+0x1148>
ffffffffc02031ec:	81cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02031f0:	00005697          	auipc	a3,0x5
ffffffffc02031f4:	9a868693          	addi	a3,a3,-1624 # ffffffffc0207b98 <commands+0x1180>
ffffffffc02031f8:	00004617          	auipc	a2,0x4
ffffffffc02031fc:	c3060613          	addi	a2,a2,-976 # ffffffffc0206e28 <commands+0x410>
ffffffffc0203200:	0ba00593          	li	a1,186
ffffffffc0203204:	00005517          	auipc	a0,0x5
ffffffffc0203208:	95c50513          	addi	a0,a0,-1700 # ffffffffc0207b60 <commands+0x1148>
ffffffffc020320c:	ffdfc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0203210 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0203210:	1141                	addi	sp,sp,-16
ffffffffc0203212:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203214:	14058463          	beqz	a1,ffffffffc020335c <default_free_pages+0x14c>
    for (; p != base + n; p ++) {
ffffffffc0203218:	00659693          	slli	a3,a1,0x6
ffffffffc020321c:	96aa                	add	a3,a3,a0
ffffffffc020321e:	87aa                	mv	a5,a0
ffffffffc0203220:	02d50263          	beq	a0,a3,ffffffffc0203244 <default_free_pages+0x34>
ffffffffc0203224:	6798                	ld	a4,8(a5)
ffffffffc0203226:	8b05                	andi	a4,a4,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0203228:	10071a63          	bnez	a4,ffffffffc020333c <default_free_pages+0x12c>
ffffffffc020322c:	6798                	ld	a4,8(a5)
ffffffffc020322e:	8b09                	andi	a4,a4,2
ffffffffc0203230:	10071663          	bnez	a4,ffffffffc020333c <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc0203234:	0007b423          	sd	zero,8(a5)
    page->ref = val;
ffffffffc0203238:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020323c:	04078793          	addi	a5,a5,64
ffffffffc0203240:	fed792e3          	bne	a5,a3,ffffffffc0203224 <default_free_pages+0x14>
    base->property = n;
ffffffffc0203244:	2581                	sext.w	a1,a1
ffffffffc0203246:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0203248:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020324c:	4789                	li	a5,2
ffffffffc020324e:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0203252:	000ab697          	auipc	a3,0xab
ffffffffc0203256:	62e68693          	addi	a3,a3,1582 # ffffffffc02ae880 <free_area>
ffffffffc020325a:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020325c:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc020325e:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0203262:	9db9                	addw	a1,a1,a4
ffffffffc0203264:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0203266:	0ad78463          	beq	a5,a3,ffffffffc020330e <default_free_pages+0xfe>
            struct Page* page = le2page(le, page_link);
ffffffffc020326a:	fe878713          	addi	a4,a5,-24
ffffffffc020326e:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0203272:	4581                	li	a1,0
            if (base < page) {
ffffffffc0203274:	00e56a63          	bltu	a0,a4,ffffffffc0203288 <default_free_pages+0x78>
    return listelm->next;
ffffffffc0203278:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020327a:	04d70c63          	beq	a4,a3,ffffffffc02032d2 <default_free_pages+0xc2>
    for (; p != base + n; p ++) {
ffffffffc020327e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0203280:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0203284:	fee57ae3          	bgeu	a0,a4,ffffffffc0203278 <default_free_pages+0x68>
ffffffffc0203288:	c199                	beqz	a1,ffffffffc020328e <default_free_pages+0x7e>
ffffffffc020328a:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020328e:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc0203290:	e390                	sd	a2,0(a5)
ffffffffc0203292:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0203294:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203296:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc0203298:	00d70d63          	beq	a4,a3,ffffffffc02032b2 <default_free_pages+0xa2>
        if (p + p->property == base) {
ffffffffc020329c:	ff872583          	lw	a1,-8(a4) # ff8 <_binary_obj___user_faultread_out_size-0x8bc8>
        p = le2page(le, page_link);
ffffffffc02032a0:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base) {
ffffffffc02032a4:	02059813          	slli	a6,a1,0x20
ffffffffc02032a8:	01a85793          	srli	a5,a6,0x1a
ffffffffc02032ac:	97b2                	add	a5,a5,a2
ffffffffc02032ae:	02f50c63          	beq	a0,a5,ffffffffc02032e6 <default_free_pages+0xd6>
    return listelm->next;
ffffffffc02032b2:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc02032b4:	00d78c63          	beq	a5,a3,ffffffffc02032cc <default_free_pages+0xbc>
        if (base + base->property == p) {
ffffffffc02032b8:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc02032ba:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p) {
ffffffffc02032be:	02061593          	slli	a1,a2,0x20
ffffffffc02032c2:	01a5d713          	srli	a4,a1,0x1a
ffffffffc02032c6:	972a                	add	a4,a4,a0
ffffffffc02032c8:	04e68a63          	beq	a3,a4,ffffffffc020331c <default_free_pages+0x10c>
}
ffffffffc02032cc:	60a2                	ld	ra,8(sp)
ffffffffc02032ce:	0141                	addi	sp,sp,16
ffffffffc02032d0:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02032d2:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02032d4:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02032d6:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02032d8:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02032da:	02d70763          	beq	a4,a3,ffffffffc0203308 <default_free_pages+0xf8>
    prev->next = next->prev = elm;
ffffffffc02032de:	8832                	mv	a6,a2
ffffffffc02032e0:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02032e2:	87ba                	mv	a5,a4
ffffffffc02032e4:	bf71                	j	ffffffffc0203280 <default_free_pages+0x70>
            p->property += base->property;
ffffffffc02032e6:	491c                	lw	a5,16(a0)
ffffffffc02032e8:	9dbd                	addw	a1,a1,a5
ffffffffc02032ea:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02032ee:	57f5                	li	a5,-3
ffffffffc02032f0:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02032f4:	01853803          	ld	a6,24(a0)
ffffffffc02032f8:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc02032fa:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc02032fc:	00b83423          	sd	a1,8(a6)
    return listelm->next;
ffffffffc0203300:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc0203302:	0105b023          	sd	a6,0(a1) # 1000 <_binary_obj___user_faultread_out_size-0x8bc0>
ffffffffc0203306:	b77d                	j	ffffffffc02032b4 <default_free_pages+0xa4>
ffffffffc0203308:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020330a:	873e                	mv	a4,a5
ffffffffc020330c:	bf41                	j	ffffffffc020329c <default_free_pages+0x8c>
}
ffffffffc020330e:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0203310:	e390                	sd	a2,0(a5)
ffffffffc0203312:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203314:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203316:	ed1c                	sd	a5,24(a0)
ffffffffc0203318:	0141                	addi	sp,sp,16
ffffffffc020331a:	8082                	ret
            base->property += p->property;
ffffffffc020331c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203320:	ff078693          	addi	a3,a5,-16
ffffffffc0203324:	9e39                	addw	a2,a2,a4
ffffffffc0203326:	c910                	sw	a2,16(a0)
ffffffffc0203328:	5775                	li	a4,-3
ffffffffc020332a:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020332e:	6398                	ld	a4,0(a5)
ffffffffc0203330:	679c                	ld	a5,8(a5)
}
ffffffffc0203332:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0203334:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203336:	e398                	sd	a4,0(a5)
ffffffffc0203338:	0141                	addi	sp,sp,16
ffffffffc020333a:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020333c:	00005697          	auipc	a3,0x5
ffffffffc0203340:	b3c68693          	addi	a3,a3,-1220 # ffffffffc0207e78 <commands+0x1460>
ffffffffc0203344:	00004617          	auipc	a2,0x4
ffffffffc0203348:	ae460613          	addi	a2,a2,-1308 # ffffffffc0206e28 <commands+0x410>
ffffffffc020334c:	08300593          	li	a1,131
ffffffffc0203350:	00005517          	auipc	a0,0x5
ffffffffc0203354:	81050513          	addi	a0,a0,-2032 # ffffffffc0207b60 <commands+0x1148>
ffffffffc0203358:	eb1fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(n > 0);
ffffffffc020335c:	00005697          	auipc	a3,0x5
ffffffffc0203360:	b1468693          	addi	a3,a3,-1260 # ffffffffc0207e70 <commands+0x1458>
ffffffffc0203364:	00004617          	auipc	a2,0x4
ffffffffc0203368:	ac460613          	addi	a2,a2,-1340 # ffffffffc0206e28 <commands+0x410>
ffffffffc020336c:	08000593          	li	a1,128
ffffffffc0203370:	00004517          	auipc	a0,0x4
ffffffffc0203374:	7f050513          	addi	a0,a0,2032 # ffffffffc0207b60 <commands+0x1148>
ffffffffc0203378:	e91fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020337c <default_alloc_pages>:
    assert(n > 0);
ffffffffc020337c:	c941                	beqz	a0,ffffffffc020340c <default_alloc_pages+0x90>
    if (n > nr_free) {
ffffffffc020337e:	000ab597          	auipc	a1,0xab
ffffffffc0203382:	50258593          	addi	a1,a1,1282 # ffffffffc02ae880 <free_area>
ffffffffc0203386:	0105a803          	lw	a6,16(a1)
ffffffffc020338a:	872a                	mv	a4,a0
ffffffffc020338c:	02081793          	slli	a5,a6,0x20
ffffffffc0203390:	9381                	srli	a5,a5,0x20
ffffffffc0203392:	00a7ee63          	bltu	a5,a0,ffffffffc02033ae <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0203396:	87ae                	mv	a5,a1
ffffffffc0203398:	a801                	j	ffffffffc02033a8 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc020339a:	ff87a683          	lw	a3,-8(a5)
ffffffffc020339e:	02069613          	slli	a2,a3,0x20
ffffffffc02033a2:	9201                	srli	a2,a2,0x20
ffffffffc02033a4:	00e67763          	bgeu	a2,a4,ffffffffc02033b2 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc02033a8:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02033aa:	feb798e3          	bne	a5,a1,ffffffffc020339a <default_alloc_pages+0x1e>
        return NULL;
ffffffffc02033ae:	4501                	li	a0,0
}
ffffffffc02033b0:	8082                	ret
    return listelm->prev;
ffffffffc02033b2:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02033b6:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc02033ba:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc02033be:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc02033c2:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc02033c6:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc02033ca:	02c77863          	bgeu	a4,a2,ffffffffc02033fa <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc02033ce:	071a                	slli	a4,a4,0x6
ffffffffc02033d0:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc02033d2:	41c686bb          	subw	a3,a3,t3
ffffffffc02033d6:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02033d8:	00870613          	addi	a2,a4,8
ffffffffc02033dc:	4689                	li	a3,2
ffffffffc02033de:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc02033e2:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc02033e6:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc02033ea:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc02033ee:	e290                	sd	a2,0(a3)
ffffffffc02033f0:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc02033f4:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc02033f6:	01173c23          	sd	a7,24(a4)
ffffffffc02033fa:	41c8083b          	subw	a6,a6,t3
ffffffffc02033fe:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0203402:	5775                	li	a4,-3
ffffffffc0203404:	17c1                	addi	a5,a5,-16
ffffffffc0203406:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc020340a:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc020340c:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc020340e:	00005697          	auipc	a3,0x5
ffffffffc0203412:	a6268693          	addi	a3,a3,-1438 # ffffffffc0207e70 <commands+0x1458>
ffffffffc0203416:	00004617          	auipc	a2,0x4
ffffffffc020341a:	a1260613          	addi	a2,a2,-1518 # ffffffffc0206e28 <commands+0x410>
ffffffffc020341e:	06200593          	li	a1,98
ffffffffc0203422:	00004517          	auipc	a0,0x4
ffffffffc0203426:	73e50513          	addi	a0,a0,1854 # ffffffffc0207b60 <commands+0x1148>
default_alloc_pages(size_t n) {
ffffffffc020342a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020342c:	dddfc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0203430 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0203430:	1141                	addi	sp,sp,-16
ffffffffc0203432:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203434:	c5f1                	beqz	a1,ffffffffc0203500 <default_init_memmap+0xd0>
    for (; p != base + n; p ++) {
ffffffffc0203436:	00659693          	slli	a3,a1,0x6
ffffffffc020343a:	96aa                	add	a3,a3,a0
ffffffffc020343c:	87aa                	mv	a5,a0
ffffffffc020343e:	00d50f63          	beq	a0,a3,ffffffffc020345c <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0203442:	6798                	ld	a4,8(a5)
ffffffffc0203444:	8b05                	andi	a4,a4,1
        assert(PageReserved(p));
ffffffffc0203446:	cf49                	beqz	a4,ffffffffc02034e0 <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc0203448:	0007a823          	sw	zero,16(a5)
ffffffffc020344c:	0007b423          	sd	zero,8(a5)
ffffffffc0203450:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0203454:	04078793          	addi	a5,a5,64
ffffffffc0203458:	fed795e3          	bne	a5,a3,ffffffffc0203442 <default_init_memmap+0x12>
    base->property = n;
ffffffffc020345c:	2581                	sext.w	a1,a1
ffffffffc020345e:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0203460:	4789                	li	a5,2
ffffffffc0203462:	00850713          	addi	a4,a0,8
ffffffffc0203466:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020346a:	000ab697          	auipc	a3,0xab
ffffffffc020346e:	41668693          	addi	a3,a3,1046 # ffffffffc02ae880 <free_area>
ffffffffc0203472:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0203474:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0203476:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc020347a:	9db9                	addw	a1,a1,a4
ffffffffc020347c:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020347e:	04d78a63          	beq	a5,a3,ffffffffc02034d2 <default_init_memmap+0xa2>
            struct Page* page = le2page(le, page_link);
ffffffffc0203482:	fe878713          	addi	a4,a5,-24
ffffffffc0203486:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020348a:	4581                	li	a1,0
            if (base < page) {
ffffffffc020348c:	00e56a63          	bltu	a0,a4,ffffffffc02034a0 <default_init_memmap+0x70>
    return listelm->next;
ffffffffc0203490:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0203492:	02d70263          	beq	a4,a3,ffffffffc02034b6 <default_init_memmap+0x86>
    for (; p != base + n; p ++) {
ffffffffc0203496:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0203498:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020349c:	fee57ae3          	bgeu	a0,a4,ffffffffc0203490 <default_init_memmap+0x60>
ffffffffc02034a0:	c199                	beqz	a1,ffffffffc02034a6 <default_init_memmap+0x76>
ffffffffc02034a2:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02034a6:	6398                	ld	a4,0(a5)
}
ffffffffc02034a8:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02034aa:	e390                	sd	a2,0(a5)
ffffffffc02034ac:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02034ae:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02034b0:	ed18                	sd	a4,24(a0)
ffffffffc02034b2:	0141                	addi	sp,sp,16
ffffffffc02034b4:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02034b6:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02034b8:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02034ba:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02034bc:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02034be:	00d70663          	beq	a4,a3,ffffffffc02034ca <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc02034c2:	8832                	mv	a6,a2
ffffffffc02034c4:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02034c6:	87ba                	mv	a5,a4
ffffffffc02034c8:	bfc1                	j	ffffffffc0203498 <default_init_memmap+0x68>
}
ffffffffc02034ca:	60a2                	ld	ra,8(sp)
ffffffffc02034cc:	e290                	sd	a2,0(a3)
ffffffffc02034ce:	0141                	addi	sp,sp,16
ffffffffc02034d0:	8082                	ret
ffffffffc02034d2:	60a2                	ld	ra,8(sp)
ffffffffc02034d4:	e390                	sd	a2,0(a5)
ffffffffc02034d6:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02034d8:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02034da:	ed1c                	sd	a5,24(a0)
ffffffffc02034dc:	0141                	addi	sp,sp,16
ffffffffc02034de:	8082                	ret
        assert(PageReserved(p));
ffffffffc02034e0:	00005697          	auipc	a3,0x5
ffffffffc02034e4:	9c068693          	addi	a3,a3,-1600 # ffffffffc0207ea0 <commands+0x1488>
ffffffffc02034e8:	00004617          	auipc	a2,0x4
ffffffffc02034ec:	94060613          	addi	a2,a2,-1728 # ffffffffc0206e28 <commands+0x410>
ffffffffc02034f0:	04900593          	li	a1,73
ffffffffc02034f4:	00004517          	auipc	a0,0x4
ffffffffc02034f8:	66c50513          	addi	a0,a0,1644 # ffffffffc0207b60 <commands+0x1148>
ffffffffc02034fc:	d0dfc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(n > 0);
ffffffffc0203500:	00005697          	auipc	a3,0x5
ffffffffc0203504:	97068693          	addi	a3,a3,-1680 # ffffffffc0207e70 <commands+0x1458>
ffffffffc0203508:	00004617          	auipc	a2,0x4
ffffffffc020350c:	92060613          	addi	a2,a2,-1760 # ffffffffc0206e28 <commands+0x410>
ffffffffc0203510:	04600593          	li	a1,70
ffffffffc0203514:	00004517          	auipc	a0,0x4
ffffffffc0203518:	64c50513          	addi	a0,a0,1612 # ffffffffc0207b60 <commands+0x1148>
ffffffffc020351c:	cedfc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0203520 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc0203520:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0203522:	00004617          	auipc	a2,0x4
ffffffffc0203526:	c2660613          	addi	a2,a2,-986 # ffffffffc0207148 <commands+0x730>
ffffffffc020352a:	06200593          	li	a1,98
ffffffffc020352e:	00004517          	auipc	a0,0x4
ffffffffc0203532:	c3a50513          	addi	a0,a0,-966 # ffffffffc0207168 <commands+0x750>
pa2page(uintptr_t pa) {
ffffffffc0203536:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0203538:	cd1fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020353c <pte2page.part.0>:
pte2page(pte_t pte) {
ffffffffc020353c:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc020353e:	00004617          	auipc	a2,0x4
ffffffffc0203542:	fea60613          	addi	a2,a2,-22 # ffffffffc0207528 <commands+0xb10>
ffffffffc0203546:	07400593          	li	a1,116
ffffffffc020354a:	00004517          	auipc	a0,0x4
ffffffffc020354e:	c1e50513          	addi	a0,a0,-994 # ffffffffc0207168 <commands+0x750>
pte2page(pte_t pte) {
ffffffffc0203552:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0203554:	cb5fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0203558 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0203558:	7139                	addi	sp,sp,-64
ffffffffc020355a:	f426                	sd	s1,40(sp)
ffffffffc020355c:	f04a                	sd	s2,32(sp)
ffffffffc020355e:	ec4e                	sd	s3,24(sp)
ffffffffc0203560:	e852                	sd	s4,16(sp)
ffffffffc0203562:	e456                	sd	s5,8(sp)
ffffffffc0203564:	e05a                	sd	s6,0(sp)
ffffffffc0203566:	fc06                	sd	ra,56(sp)
ffffffffc0203568:	f822                	sd	s0,48(sp)
ffffffffc020356a:	84aa                	mv	s1,a0
ffffffffc020356c:	000af917          	auipc	s2,0xaf
ffffffffc0203570:	3a490913          	addi	s2,s2,932 # ffffffffc02b2910 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0203574:	4a05                	li	s4,1
ffffffffc0203576:	000afa97          	auipc	s5,0xaf
ffffffffc020357a:	36aa8a93          	addi	s5,s5,874 # ffffffffc02b28e0 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc020357e:	0005099b          	sext.w	s3,a0
ffffffffc0203582:	000afb17          	auipc	s6,0xaf
ffffffffc0203586:	33eb0b13          	addi	s6,s6,830 # ffffffffc02b28c0 <check_mm_struct>
ffffffffc020358a:	a01d                	j	ffffffffc02035b0 <alloc_pages+0x58>
            page = pmm_manager->alloc_pages(n);
ffffffffc020358c:	00093783          	ld	a5,0(s2)
ffffffffc0203590:	6f9c                	ld	a5,24(a5)
ffffffffc0203592:	9782                	jalr	a5
ffffffffc0203594:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0203596:	4601                	li	a2,0
ffffffffc0203598:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc020359a:	ec0d                	bnez	s0,ffffffffc02035d4 <alloc_pages+0x7c>
ffffffffc020359c:	029a6c63          	bltu	s4,s1,ffffffffc02035d4 <alloc_pages+0x7c>
ffffffffc02035a0:	000aa783          	lw	a5,0(s5)
ffffffffc02035a4:	2781                	sext.w	a5,a5
ffffffffc02035a6:	c79d                	beqz	a5,ffffffffc02035d4 <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc02035a8:	000b3503          	ld	a0,0(s6)
ffffffffc02035ac:	b6ffe0ef          	jal	ra,ffffffffc020211a <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02035b0:	100027f3          	csrr	a5,sstatus
ffffffffc02035b4:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc02035b6:	8526                	mv	a0,s1
ffffffffc02035b8:	dbf1                	beqz	a5,ffffffffc020358c <alloc_pages+0x34>
        intr_disable();
ffffffffc02035ba:	88efd0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc02035be:	00093783          	ld	a5,0(s2)
ffffffffc02035c2:	8526                	mv	a0,s1
ffffffffc02035c4:	6f9c                	ld	a5,24(a5)
ffffffffc02035c6:	9782                	jalr	a5
ffffffffc02035c8:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02035ca:	878fd0ef          	jal	ra,ffffffffc0200642 <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc02035ce:	4601                	li	a2,0
ffffffffc02035d0:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02035d2:	d469                	beqz	s0,ffffffffc020359c <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc02035d4:	70e2                	ld	ra,56(sp)
ffffffffc02035d6:	8522                	mv	a0,s0
ffffffffc02035d8:	7442                	ld	s0,48(sp)
ffffffffc02035da:	74a2                	ld	s1,40(sp)
ffffffffc02035dc:	7902                	ld	s2,32(sp)
ffffffffc02035de:	69e2                	ld	s3,24(sp)
ffffffffc02035e0:	6a42                	ld	s4,16(sp)
ffffffffc02035e2:	6aa2                	ld	s5,8(sp)
ffffffffc02035e4:	6b02                	ld	s6,0(sp)
ffffffffc02035e6:	6121                	addi	sp,sp,64
ffffffffc02035e8:	8082                	ret

ffffffffc02035ea <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02035ea:	100027f3          	csrr	a5,sstatus
ffffffffc02035ee:	8b89                	andi	a5,a5,2
ffffffffc02035f0:	e799                	bnez	a5,ffffffffc02035fe <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc02035f2:	000af797          	auipc	a5,0xaf
ffffffffc02035f6:	31e7b783          	ld	a5,798(a5) # ffffffffc02b2910 <pmm_manager>
ffffffffc02035fa:	739c                	ld	a5,32(a5)
ffffffffc02035fc:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc02035fe:	1101                	addi	sp,sp,-32
ffffffffc0203600:	ec06                	sd	ra,24(sp)
ffffffffc0203602:	e822                	sd	s0,16(sp)
ffffffffc0203604:	e426                	sd	s1,8(sp)
ffffffffc0203606:	842a                	mv	s0,a0
ffffffffc0203608:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc020360a:	83efd0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020360e:	000af797          	auipc	a5,0xaf
ffffffffc0203612:	3027b783          	ld	a5,770(a5) # ffffffffc02b2910 <pmm_manager>
ffffffffc0203616:	739c                	ld	a5,32(a5)
ffffffffc0203618:	85a6                	mv	a1,s1
ffffffffc020361a:	8522                	mv	a0,s0
ffffffffc020361c:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc020361e:	6442                	ld	s0,16(sp)
ffffffffc0203620:	60e2                	ld	ra,24(sp)
ffffffffc0203622:	64a2                	ld	s1,8(sp)
ffffffffc0203624:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0203626:	81cfd06f          	j	ffffffffc0200642 <intr_enable>

ffffffffc020362a <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020362a:	100027f3          	csrr	a5,sstatus
ffffffffc020362e:	8b89                	andi	a5,a5,2
ffffffffc0203630:	e799                	bnez	a5,ffffffffc020363e <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0203632:	000af797          	auipc	a5,0xaf
ffffffffc0203636:	2de7b783          	ld	a5,734(a5) # ffffffffc02b2910 <pmm_manager>
ffffffffc020363a:	779c                	ld	a5,40(a5)
ffffffffc020363c:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc020363e:	1141                	addi	sp,sp,-16
ffffffffc0203640:	e406                	sd	ra,8(sp)
ffffffffc0203642:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0203644:	804fd0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0203648:	000af797          	auipc	a5,0xaf
ffffffffc020364c:	2c87b783          	ld	a5,712(a5) # ffffffffc02b2910 <pmm_manager>
ffffffffc0203650:	779c                	ld	a5,40(a5)
ffffffffc0203652:	9782                	jalr	a5
ffffffffc0203654:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203656:	fedfc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc020365a:	60a2                	ld	ra,8(sp)
ffffffffc020365c:	8522                	mv	a0,s0
ffffffffc020365e:	6402                	ld	s0,0(sp)
ffffffffc0203660:	0141                	addi	sp,sp,16
ffffffffc0203662:	8082                	ret

ffffffffc0203664 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0203664:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0203668:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc020366c:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc020366e:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0203670:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0203672:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc0203676:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0203678:	f04a                	sd	s2,32(sp)
ffffffffc020367a:	ec4e                	sd	s3,24(sp)
ffffffffc020367c:	e852                	sd	s4,16(sp)
ffffffffc020367e:	fc06                	sd	ra,56(sp)
ffffffffc0203680:	f822                	sd	s0,48(sp)
ffffffffc0203682:	e456                	sd	s5,8(sp)
ffffffffc0203684:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0203686:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc020368a:	892e                	mv	s2,a1
ffffffffc020368c:	89b2                	mv	s3,a2
ffffffffc020368e:	000afa17          	auipc	s4,0xaf
ffffffffc0203692:	272a0a13          	addi	s4,s4,626 # ffffffffc02b2900 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0203696:	e7b5                	bnez	a5,ffffffffc0203702 <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0203698:	12060b63          	beqz	a2,ffffffffc02037ce <get_pte+0x16a>
ffffffffc020369c:	4505                	li	a0,1
ffffffffc020369e:	ebbff0ef          	jal	ra,ffffffffc0203558 <alloc_pages>
ffffffffc02036a2:	842a                	mv	s0,a0
ffffffffc02036a4:	12050563          	beqz	a0,ffffffffc02037ce <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc02036a8:	000afb17          	auipc	s6,0xaf
ffffffffc02036ac:	260b0b13          	addi	s6,s6,608 # ffffffffc02b2908 <pages>
ffffffffc02036b0:	000b3503          	ld	a0,0(s6)
ffffffffc02036b4:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02036b8:	000afa17          	auipc	s4,0xaf
ffffffffc02036bc:	248a0a13          	addi	s4,s4,584 # ffffffffc02b2900 <npage>
ffffffffc02036c0:	40a40533          	sub	a0,s0,a0
ffffffffc02036c4:	8519                	srai	a0,a0,0x6
ffffffffc02036c6:	9556                	add	a0,a0,s5
ffffffffc02036c8:	000a3703          	ld	a4,0(s4)
ffffffffc02036cc:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc02036d0:	4685                	li	a3,1
ffffffffc02036d2:	c014                	sw	a3,0(s0)
ffffffffc02036d4:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02036d6:	0532                	slli	a0,a0,0xc
ffffffffc02036d8:	14e7f263          	bgeu	a5,a4,ffffffffc020381c <get_pte+0x1b8>
ffffffffc02036dc:	000af797          	auipc	a5,0xaf
ffffffffc02036e0:	23c7b783          	ld	a5,572(a5) # ffffffffc02b2918 <va_pa_offset>
ffffffffc02036e4:	6605                	lui	a2,0x1
ffffffffc02036e6:	4581                	li	a1,0
ffffffffc02036e8:	953e                	add	a0,a0,a5
ffffffffc02036ea:	459020ef          	jal	ra,ffffffffc0206342 <memset>
    return page - pages + nbase;
ffffffffc02036ee:	000b3683          	ld	a3,0(s6)
ffffffffc02036f2:	40d406b3          	sub	a3,s0,a3
ffffffffc02036f6:	8699                	srai	a3,a3,0x6
ffffffffc02036f8:	96d6                	add	a3,a3,s5
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02036fa:	06aa                	slli	a3,a3,0xa
ffffffffc02036fc:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0203700:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0203702:	77fd                	lui	a5,0xfffff
ffffffffc0203704:	068a                	slli	a3,a3,0x2
ffffffffc0203706:	000a3703          	ld	a4,0(s4)
ffffffffc020370a:	8efd                	and	a3,a3,a5
ffffffffc020370c:	00c6d793          	srli	a5,a3,0xc
ffffffffc0203710:	0ce7f163          	bgeu	a5,a4,ffffffffc02037d2 <get_pte+0x16e>
ffffffffc0203714:	000afa97          	auipc	s5,0xaf
ffffffffc0203718:	204a8a93          	addi	s5,s5,516 # ffffffffc02b2918 <va_pa_offset>
ffffffffc020371c:	000ab403          	ld	s0,0(s5)
ffffffffc0203720:	01595793          	srli	a5,s2,0x15
ffffffffc0203724:	1ff7f793          	andi	a5,a5,511
ffffffffc0203728:	96a2                	add	a3,a3,s0
ffffffffc020372a:	00379413          	slli	s0,a5,0x3
ffffffffc020372e:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0203730:	6014                	ld	a3,0(s0)
ffffffffc0203732:	0016f793          	andi	a5,a3,1
ffffffffc0203736:	e3ad                	bnez	a5,ffffffffc0203798 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0203738:	08098b63          	beqz	s3,ffffffffc02037ce <get_pte+0x16a>
ffffffffc020373c:	4505                	li	a0,1
ffffffffc020373e:	e1bff0ef          	jal	ra,ffffffffc0203558 <alloc_pages>
ffffffffc0203742:	84aa                	mv	s1,a0
ffffffffc0203744:	c549                	beqz	a0,ffffffffc02037ce <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0203746:	000afb17          	auipc	s6,0xaf
ffffffffc020374a:	1c2b0b13          	addi	s6,s6,450 # ffffffffc02b2908 <pages>
ffffffffc020374e:	000b3503          	ld	a0,0(s6)
ffffffffc0203752:	000809b7          	lui	s3,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0203756:	000a3703          	ld	a4,0(s4)
ffffffffc020375a:	40a48533          	sub	a0,s1,a0
ffffffffc020375e:	8519                	srai	a0,a0,0x6
ffffffffc0203760:	954e                	add	a0,a0,s3
ffffffffc0203762:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0203766:	4685                	li	a3,1
ffffffffc0203768:	c094                	sw	a3,0(s1)
ffffffffc020376a:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020376c:	0532                	slli	a0,a0,0xc
ffffffffc020376e:	08e7fa63          	bgeu	a5,a4,ffffffffc0203802 <get_pte+0x19e>
ffffffffc0203772:	000ab783          	ld	a5,0(s5)
ffffffffc0203776:	6605                	lui	a2,0x1
ffffffffc0203778:	4581                	li	a1,0
ffffffffc020377a:	953e                	add	a0,a0,a5
ffffffffc020377c:	3c7020ef          	jal	ra,ffffffffc0206342 <memset>
    return page - pages + nbase;
ffffffffc0203780:	000b3683          	ld	a3,0(s6)
ffffffffc0203784:	40d486b3          	sub	a3,s1,a3
ffffffffc0203788:	8699                	srai	a3,a3,0x6
ffffffffc020378a:	96ce                	add	a3,a3,s3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020378c:	06aa                	slli	a3,a3,0xa
ffffffffc020378e:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0203792:	e014                	sd	a3,0(s0)
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0203794:	000a3703          	ld	a4,0(s4)
ffffffffc0203798:	068a                	slli	a3,a3,0x2
ffffffffc020379a:	757d                	lui	a0,0xfffff
ffffffffc020379c:	8ee9                	and	a3,a3,a0
ffffffffc020379e:	00c6d793          	srli	a5,a3,0xc
ffffffffc02037a2:	04e7f463          	bgeu	a5,a4,ffffffffc02037ea <get_pte+0x186>
ffffffffc02037a6:	000ab503          	ld	a0,0(s5)
ffffffffc02037aa:	00c95913          	srli	s2,s2,0xc
ffffffffc02037ae:	1ff97913          	andi	s2,s2,511
ffffffffc02037b2:	96aa                	add	a3,a3,a0
ffffffffc02037b4:	00391513          	slli	a0,s2,0x3
ffffffffc02037b8:	9536                	add	a0,a0,a3
}
ffffffffc02037ba:	70e2                	ld	ra,56(sp)
ffffffffc02037bc:	7442                	ld	s0,48(sp)
ffffffffc02037be:	74a2                	ld	s1,40(sp)
ffffffffc02037c0:	7902                	ld	s2,32(sp)
ffffffffc02037c2:	69e2                	ld	s3,24(sp)
ffffffffc02037c4:	6a42                	ld	s4,16(sp)
ffffffffc02037c6:	6aa2                	ld	s5,8(sp)
ffffffffc02037c8:	6b02                	ld	s6,0(sp)
ffffffffc02037ca:	6121                	addi	sp,sp,64
ffffffffc02037cc:	8082                	ret
            return NULL;
ffffffffc02037ce:	4501                	li	a0,0
ffffffffc02037d0:	b7ed                	j	ffffffffc02037ba <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02037d2:	00004617          	auipc	a2,0x4
ffffffffc02037d6:	c2660613          	addi	a2,a2,-986 # ffffffffc02073f8 <commands+0x9e0>
ffffffffc02037da:	0e300593          	li	a1,227
ffffffffc02037de:	00004517          	auipc	a0,0x4
ffffffffc02037e2:	72250513          	addi	a0,a0,1826 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc02037e6:	a23fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02037ea:	00004617          	auipc	a2,0x4
ffffffffc02037ee:	c0e60613          	addi	a2,a2,-1010 # ffffffffc02073f8 <commands+0x9e0>
ffffffffc02037f2:	0ee00593          	li	a1,238
ffffffffc02037f6:	00004517          	auipc	a0,0x4
ffffffffc02037fa:	70a50513          	addi	a0,a0,1802 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc02037fe:	a0bfc0ef          	jal	ra,ffffffffc0200208 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0203802:	86aa                	mv	a3,a0
ffffffffc0203804:	00004617          	auipc	a2,0x4
ffffffffc0203808:	bf460613          	addi	a2,a2,-1036 # ffffffffc02073f8 <commands+0x9e0>
ffffffffc020380c:	0eb00593          	li	a1,235
ffffffffc0203810:	00004517          	auipc	a0,0x4
ffffffffc0203814:	6f050513          	addi	a0,a0,1776 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc0203818:	9f1fc0ef          	jal	ra,ffffffffc0200208 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020381c:	86aa                	mv	a3,a0
ffffffffc020381e:	00004617          	auipc	a2,0x4
ffffffffc0203822:	bda60613          	addi	a2,a2,-1062 # ffffffffc02073f8 <commands+0x9e0>
ffffffffc0203826:	0df00593          	li	a1,223
ffffffffc020382a:	00004517          	auipc	a0,0x4
ffffffffc020382e:	6d650513          	addi	a0,a0,1750 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc0203832:	9d7fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0203836 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0203836:	1141                	addi	sp,sp,-16
ffffffffc0203838:	e022                	sd	s0,0(sp)
ffffffffc020383a:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020383c:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc020383e:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0203840:	e25ff0ef          	jal	ra,ffffffffc0203664 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0203844:	c011                	beqz	s0,ffffffffc0203848 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0203846:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0203848:	c511                	beqz	a0,ffffffffc0203854 <get_page+0x1e>
ffffffffc020384a:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc020384c:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc020384e:	0017f713          	andi	a4,a5,1
ffffffffc0203852:	e709                	bnez	a4,ffffffffc020385c <get_page+0x26>
}
ffffffffc0203854:	60a2                	ld	ra,8(sp)
ffffffffc0203856:	6402                	ld	s0,0(sp)
ffffffffc0203858:	0141                	addi	sp,sp,16
ffffffffc020385a:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc020385c:	078a                	slli	a5,a5,0x2
ffffffffc020385e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203860:	000af717          	auipc	a4,0xaf
ffffffffc0203864:	0a073703          	ld	a4,160(a4) # ffffffffc02b2900 <npage>
ffffffffc0203868:	00e7ff63          	bgeu	a5,a4,ffffffffc0203886 <get_page+0x50>
ffffffffc020386c:	60a2                	ld	ra,8(sp)
ffffffffc020386e:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc0203870:	fff80537          	lui	a0,0xfff80
ffffffffc0203874:	97aa                	add	a5,a5,a0
ffffffffc0203876:	079a                	slli	a5,a5,0x6
ffffffffc0203878:	000af517          	auipc	a0,0xaf
ffffffffc020387c:	09053503          	ld	a0,144(a0) # ffffffffc02b2908 <pages>
ffffffffc0203880:	953e                	add	a0,a0,a5
ffffffffc0203882:	0141                	addi	sp,sp,16
ffffffffc0203884:	8082                	ret
ffffffffc0203886:	c9bff0ef          	jal	ra,ffffffffc0203520 <pa2page.part.0>

ffffffffc020388a <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc020388a:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020388c:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0203890:	f486                	sd	ra,104(sp)
ffffffffc0203892:	f0a2                	sd	s0,96(sp)
ffffffffc0203894:	eca6                	sd	s1,88(sp)
ffffffffc0203896:	e8ca                	sd	s2,80(sp)
ffffffffc0203898:	e4ce                	sd	s3,72(sp)
ffffffffc020389a:	e0d2                	sd	s4,64(sp)
ffffffffc020389c:	fc56                	sd	s5,56(sp)
ffffffffc020389e:	f85a                	sd	s6,48(sp)
ffffffffc02038a0:	f45e                	sd	s7,40(sp)
ffffffffc02038a2:	f062                	sd	s8,32(sp)
ffffffffc02038a4:	ec66                	sd	s9,24(sp)
ffffffffc02038a6:	e86a                	sd	s10,16(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02038a8:	17d2                	slli	a5,a5,0x34
ffffffffc02038aa:	e3ed                	bnez	a5,ffffffffc020398c <unmap_range+0x102>
    assert(USER_ACCESS(start, end));
ffffffffc02038ac:	002007b7          	lui	a5,0x200
ffffffffc02038b0:	842e                	mv	s0,a1
ffffffffc02038b2:	0ef5ed63          	bltu	a1,a5,ffffffffc02039ac <unmap_range+0x122>
ffffffffc02038b6:	8932                	mv	s2,a2
ffffffffc02038b8:	0ec5fa63          	bgeu	a1,a2,ffffffffc02039ac <unmap_range+0x122>
ffffffffc02038bc:	4785                	li	a5,1
ffffffffc02038be:	07fe                	slli	a5,a5,0x1f
ffffffffc02038c0:	0ec7e663          	bltu	a5,a2,ffffffffc02039ac <unmap_range+0x122>
ffffffffc02038c4:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc02038c6:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc02038c8:	000afc97          	auipc	s9,0xaf
ffffffffc02038cc:	038c8c93          	addi	s9,s9,56 # ffffffffc02b2900 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02038d0:	000afc17          	auipc	s8,0xaf
ffffffffc02038d4:	038c0c13          	addi	s8,s8,56 # ffffffffc02b2908 <pages>
ffffffffc02038d8:	fff80bb7          	lui	s7,0xfff80
        pmm_manager->free_pages(base, n);
ffffffffc02038dc:	000afd17          	auipc	s10,0xaf
ffffffffc02038e0:	034d0d13          	addi	s10,s10,52 # ffffffffc02b2910 <pmm_manager>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02038e4:	00200b37          	lui	s6,0x200
ffffffffc02038e8:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc02038ec:	4601                	li	a2,0
ffffffffc02038ee:	85a2                	mv	a1,s0
ffffffffc02038f0:	854e                	mv	a0,s3
ffffffffc02038f2:	d73ff0ef          	jal	ra,ffffffffc0203664 <get_pte>
ffffffffc02038f6:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc02038f8:	cd29                	beqz	a0,ffffffffc0203952 <unmap_range+0xc8>
        if (*ptep != 0) {
ffffffffc02038fa:	611c                	ld	a5,0(a0)
ffffffffc02038fc:	e395                	bnez	a5,ffffffffc0203920 <unmap_range+0x96>
        start += PGSIZE;
ffffffffc02038fe:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0203900:	ff2466e3          	bltu	s0,s2,ffffffffc02038ec <unmap_range+0x62>
}
ffffffffc0203904:	70a6                	ld	ra,104(sp)
ffffffffc0203906:	7406                	ld	s0,96(sp)
ffffffffc0203908:	64e6                	ld	s1,88(sp)
ffffffffc020390a:	6946                	ld	s2,80(sp)
ffffffffc020390c:	69a6                	ld	s3,72(sp)
ffffffffc020390e:	6a06                	ld	s4,64(sp)
ffffffffc0203910:	7ae2                	ld	s5,56(sp)
ffffffffc0203912:	7b42                	ld	s6,48(sp)
ffffffffc0203914:	7ba2                	ld	s7,40(sp)
ffffffffc0203916:	7c02                	ld	s8,32(sp)
ffffffffc0203918:	6ce2                	ld	s9,24(sp)
ffffffffc020391a:	6d42                	ld	s10,16(sp)
ffffffffc020391c:	6165                	addi	sp,sp,112
ffffffffc020391e:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0203920:	0017f713          	andi	a4,a5,1
ffffffffc0203924:	df69                	beqz	a4,ffffffffc02038fe <unmap_range+0x74>
    if (PPN(pa) >= npage) {
ffffffffc0203926:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020392a:	078a                	slli	a5,a5,0x2
ffffffffc020392c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020392e:	08e7ff63          	bgeu	a5,a4,ffffffffc02039cc <unmap_range+0x142>
    return &pages[PPN(pa) - nbase];
ffffffffc0203932:	000c3503          	ld	a0,0(s8)
ffffffffc0203936:	97de                	add	a5,a5,s7
ffffffffc0203938:	079a                	slli	a5,a5,0x6
ffffffffc020393a:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020393c:	411c                	lw	a5,0(a0)
ffffffffc020393e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0203942:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0203944:	cf11                	beqz	a4,ffffffffc0203960 <unmap_range+0xd6>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0203946:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020394a:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc020394e:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0203950:	bf45                	j	ffffffffc0203900 <unmap_range+0x76>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0203952:	945a                	add	s0,s0,s6
ffffffffc0203954:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc0203958:	d455                	beqz	s0,ffffffffc0203904 <unmap_range+0x7a>
ffffffffc020395a:	f92469e3          	bltu	s0,s2,ffffffffc02038ec <unmap_range+0x62>
ffffffffc020395e:	b75d                	j	ffffffffc0203904 <unmap_range+0x7a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203960:	100027f3          	csrr	a5,sstatus
ffffffffc0203964:	8b89                	andi	a5,a5,2
ffffffffc0203966:	e799                	bnez	a5,ffffffffc0203974 <unmap_range+0xea>
        pmm_manager->free_pages(base, n);
ffffffffc0203968:	000d3783          	ld	a5,0(s10)
ffffffffc020396c:	4585                	li	a1,1
ffffffffc020396e:	739c                	ld	a5,32(a5)
ffffffffc0203970:	9782                	jalr	a5
    if (flag) {
ffffffffc0203972:	bfd1                	j	ffffffffc0203946 <unmap_range+0xbc>
ffffffffc0203974:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203976:	cd3fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc020397a:	000d3783          	ld	a5,0(s10)
ffffffffc020397e:	6522                	ld	a0,8(sp)
ffffffffc0203980:	4585                	li	a1,1
ffffffffc0203982:	739c                	ld	a5,32(a5)
ffffffffc0203984:	9782                	jalr	a5
        intr_enable();
ffffffffc0203986:	cbdfc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc020398a:	bf75                	j	ffffffffc0203946 <unmap_range+0xbc>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020398c:	00004697          	auipc	a3,0x4
ffffffffc0203990:	58468693          	addi	a3,a3,1412 # ffffffffc0207f10 <default_pmm_manager+0x48>
ffffffffc0203994:	00003617          	auipc	a2,0x3
ffffffffc0203998:	49460613          	addi	a2,a2,1172 # ffffffffc0206e28 <commands+0x410>
ffffffffc020399c:	10f00593          	li	a1,271
ffffffffc02039a0:	00004517          	auipc	a0,0x4
ffffffffc02039a4:	56050513          	addi	a0,a0,1376 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc02039a8:	861fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02039ac:	00004697          	auipc	a3,0x4
ffffffffc02039b0:	59468693          	addi	a3,a3,1428 # ffffffffc0207f40 <default_pmm_manager+0x78>
ffffffffc02039b4:	00003617          	auipc	a2,0x3
ffffffffc02039b8:	47460613          	addi	a2,a2,1140 # ffffffffc0206e28 <commands+0x410>
ffffffffc02039bc:	11000593          	li	a1,272
ffffffffc02039c0:	00004517          	auipc	a0,0x4
ffffffffc02039c4:	54050513          	addi	a0,a0,1344 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc02039c8:	841fc0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc02039cc:	b55ff0ef          	jal	ra,ffffffffc0203520 <pa2page.part.0>

ffffffffc02039d0 <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02039d0:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02039d2:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02039d6:	fc86                	sd	ra,120(sp)
ffffffffc02039d8:	f8a2                	sd	s0,112(sp)
ffffffffc02039da:	f4a6                	sd	s1,104(sp)
ffffffffc02039dc:	f0ca                	sd	s2,96(sp)
ffffffffc02039de:	ecce                	sd	s3,88(sp)
ffffffffc02039e0:	e8d2                	sd	s4,80(sp)
ffffffffc02039e2:	e4d6                	sd	s5,72(sp)
ffffffffc02039e4:	e0da                	sd	s6,64(sp)
ffffffffc02039e6:	fc5e                	sd	s7,56(sp)
ffffffffc02039e8:	f862                	sd	s8,48(sp)
ffffffffc02039ea:	f466                	sd	s9,40(sp)
ffffffffc02039ec:	f06a                	sd	s10,32(sp)
ffffffffc02039ee:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02039f0:	17d2                	slli	a5,a5,0x34
ffffffffc02039f2:	20079a63          	bnez	a5,ffffffffc0203c06 <exit_range+0x236>
    assert(USER_ACCESS(start, end));
ffffffffc02039f6:	002007b7          	lui	a5,0x200
ffffffffc02039fa:	24f5e463          	bltu	a1,a5,ffffffffc0203c42 <exit_range+0x272>
ffffffffc02039fe:	8ab2                	mv	s5,a2
ffffffffc0203a00:	24c5f163          	bgeu	a1,a2,ffffffffc0203c42 <exit_range+0x272>
ffffffffc0203a04:	4785                	li	a5,1
ffffffffc0203a06:	07fe                	slli	a5,a5,0x1f
ffffffffc0203a08:	22c7ed63          	bltu	a5,a2,ffffffffc0203c42 <exit_range+0x272>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc0203a0c:	c00009b7          	lui	s3,0xc0000
ffffffffc0203a10:	0135f9b3          	and	s3,a1,s3
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0203a14:	ffe00937          	lui	s2,0xffe00
ffffffffc0203a18:	400007b7          	lui	a5,0x40000
    return KADDR(page2pa(page));
ffffffffc0203a1c:	5cfd                	li	s9,-1
ffffffffc0203a1e:	8c2a                	mv	s8,a0
ffffffffc0203a20:	0125f933          	and	s2,a1,s2
ffffffffc0203a24:	99be                	add	s3,s3,a5
    if (PPN(pa) >= npage) {
ffffffffc0203a26:	000afd17          	auipc	s10,0xaf
ffffffffc0203a2a:	edad0d13          	addi	s10,s10,-294 # ffffffffc02b2900 <npage>
    return KADDR(page2pa(page));
ffffffffc0203a2e:	00ccdc93          	srli	s9,s9,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0203a32:	000af717          	auipc	a4,0xaf
ffffffffc0203a36:	ed670713          	addi	a4,a4,-298 # ffffffffc02b2908 <pages>
        pmm_manager->free_pages(base, n);
ffffffffc0203a3a:	000afd97          	auipc	s11,0xaf
ffffffffc0203a3e:	ed6d8d93          	addi	s11,s11,-298 # ffffffffc02b2910 <pmm_manager>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc0203a42:	c0000437          	lui	s0,0xc0000
ffffffffc0203a46:	944e                	add	s0,s0,s3
ffffffffc0203a48:	8079                	srli	s0,s0,0x1e
ffffffffc0203a4a:	1ff47413          	andi	s0,s0,511
ffffffffc0203a4e:	040e                	slli	s0,s0,0x3
ffffffffc0203a50:	9462                	add	s0,s0,s8
ffffffffc0203a52:	00043a03          	ld	s4,0(s0) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ed0>
        if (pde1&PTE_V){
ffffffffc0203a56:	001a7793          	andi	a5,s4,1
ffffffffc0203a5a:	eb99                	bnez	a5,ffffffffc0203a70 <exit_range+0xa0>
    } while (d1start != 0 && d1start < end);
ffffffffc0203a5c:	12098463          	beqz	s3,ffffffffc0203b84 <exit_range+0x1b4>
ffffffffc0203a60:	400007b7          	lui	a5,0x40000
ffffffffc0203a64:	97ce                	add	a5,a5,s3
ffffffffc0203a66:	894e                	mv	s2,s3
ffffffffc0203a68:	1159fe63          	bgeu	s3,s5,ffffffffc0203b84 <exit_range+0x1b4>
ffffffffc0203a6c:	89be                	mv	s3,a5
ffffffffc0203a6e:	bfd1                	j	ffffffffc0203a42 <exit_range+0x72>
    if (PPN(pa) >= npage) {
ffffffffc0203a70:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203a74:	0a0a                	slli	s4,s4,0x2
ffffffffc0203a76:	00ca5a13          	srli	s4,s4,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203a7a:	1cfa7263          	bgeu	s4,a5,ffffffffc0203c3e <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0203a7e:	fff80637          	lui	a2,0xfff80
ffffffffc0203a82:	9652                	add	a2,a2,s4
    return page - pages + nbase;
ffffffffc0203a84:	000806b7          	lui	a3,0x80
ffffffffc0203a88:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc0203a8a:	0196f5b3          	and	a1,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc0203a8e:	061a                	slli	a2,a2,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0203a90:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203a92:	18f5fa63          	bgeu	a1,a5,ffffffffc0203c26 <exit_range+0x256>
ffffffffc0203a96:	000af817          	auipc	a6,0xaf
ffffffffc0203a9a:	e8280813          	addi	a6,a6,-382 # ffffffffc02b2918 <va_pa_offset>
ffffffffc0203a9e:	00083b03          	ld	s6,0(a6)
            free_pd0 = 1;
ffffffffc0203aa2:	4b85                	li	s7,1
    return &pages[PPN(pa) - nbase];
ffffffffc0203aa4:	fff80e37          	lui	t3,0xfff80
    return KADDR(page2pa(page));
ffffffffc0203aa8:	9b36                	add	s6,s6,a3
    return page - pages + nbase;
ffffffffc0203aaa:	00080337          	lui	t1,0x80
ffffffffc0203aae:	6885                	lui	a7,0x1
ffffffffc0203ab0:	a819                	j	ffffffffc0203ac6 <exit_range+0xf6>
                    free_pd0 = 0;
ffffffffc0203ab2:	4b81                	li	s7,0
                d0start += PTSIZE;
ffffffffc0203ab4:	002007b7          	lui	a5,0x200
ffffffffc0203ab8:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0203aba:	08090c63          	beqz	s2,ffffffffc0203b52 <exit_range+0x182>
ffffffffc0203abe:	09397a63          	bgeu	s2,s3,ffffffffc0203b52 <exit_range+0x182>
ffffffffc0203ac2:	0f597063          	bgeu	s2,s5,ffffffffc0203ba2 <exit_range+0x1d2>
                pde0 = pd0[PDX0(d0start)];
ffffffffc0203ac6:	01595493          	srli	s1,s2,0x15
ffffffffc0203aca:	1ff4f493          	andi	s1,s1,511
ffffffffc0203ace:	048e                	slli	s1,s1,0x3
ffffffffc0203ad0:	94da                	add	s1,s1,s6
ffffffffc0203ad2:	609c                	ld	a5,0(s1)
                if (pde0&PTE_V) {
ffffffffc0203ad4:	0017f693          	andi	a3,a5,1
ffffffffc0203ad8:	dee9                	beqz	a3,ffffffffc0203ab2 <exit_range+0xe2>
    if (PPN(pa) >= npage) {
ffffffffc0203ada:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203ade:	078a                	slli	a5,a5,0x2
ffffffffc0203ae0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203ae2:	14b7fe63          	bgeu	a5,a1,ffffffffc0203c3e <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0203ae6:	97f2                	add	a5,a5,t3
    return page - pages + nbase;
ffffffffc0203ae8:	006786b3          	add	a3,a5,t1
    return KADDR(page2pa(page));
ffffffffc0203aec:	0196feb3          	and	t4,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc0203af0:	00679513          	slli	a0,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0203af4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203af6:	12bef863          	bgeu	t4,a1,ffffffffc0203c26 <exit_range+0x256>
ffffffffc0203afa:	00083783          	ld	a5,0(a6)
ffffffffc0203afe:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc0203b00:	011685b3          	add	a1,a3,a7
                        if (pt[i]&PTE_V){
ffffffffc0203b04:	629c                	ld	a5,0(a3)
ffffffffc0203b06:	8b85                	andi	a5,a5,1
ffffffffc0203b08:	f7d5                	bnez	a5,ffffffffc0203ab4 <exit_range+0xe4>
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc0203b0a:	06a1                	addi	a3,a3,8
ffffffffc0203b0c:	fed59ce3          	bne	a1,a3,ffffffffc0203b04 <exit_range+0x134>
    return &pages[PPN(pa) - nbase];
ffffffffc0203b10:	631c                	ld	a5,0(a4)
ffffffffc0203b12:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203b14:	100027f3          	csrr	a5,sstatus
ffffffffc0203b18:	8b89                	andi	a5,a5,2
ffffffffc0203b1a:	e7d9                	bnez	a5,ffffffffc0203ba8 <exit_range+0x1d8>
        pmm_manager->free_pages(base, n);
ffffffffc0203b1c:	000db783          	ld	a5,0(s11)
ffffffffc0203b20:	4585                	li	a1,1
ffffffffc0203b22:	e032                	sd	a2,0(sp)
ffffffffc0203b24:	739c                	ld	a5,32(a5)
ffffffffc0203b26:	9782                	jalr	a5
    if (flag) {
ffffffffc0203b28:	6602                	ld	a2,0(sp)
ffffffffc0203b2a:	000af817          	auipc	a6,0xaf
ffffffffc0203b2e:	dee80813          	addi	a6,a6,-530 # ffffffffc02b2918 <va_pa_offset>
ffffffffc0203b32:	fff80e37          	lui	t3,0xfff80
ffffffffc0203b36:	00080337          	lui	t1,0x80
ffffffffc0203b3a:	6885                	lui	a7,0x1
ffffffffc0203b3c:	000af717          	auipc	a4,0xaf
ffffffffc0203b40:	dcc70713          	addi	a4,a4,-564 # ffffffffc02b2908 <pages>
                        pd0[PDX0(d0start)] = 0;
ffffffffc0203b44:	0004b023          	sd	zero,0(s1)
                d0start += PTSIZE;
ffffffffc0203b48:	002007b7          	lui	a5,0x200
ffffffffc0203b4c:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0203b4e:	f60918e3          	bnez	s2,ffffffffc0203abe <exit_range+0xee>
            if (free_pd0) {
ffffffffc0203b52:	f00b85e3          	beqz	s7,ffffffffc0203a5c <exit_range+0x8c>
    if (PPN(pa) >= npage) {
ffffffffc0203b56:	000d3783          	ld	a5,0(s10)
ffffffffc0203b5a:	0efa7263          	bgeu	s4,a5,ffffffffc0203c3e <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0203b5e:	6308                	ld	a0,0(a4)
ffffffffc0203b60:	9532                	add	a0,a0,a2
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203b62:	100027f3          	csrr	a5,sstatus
ffffffffc0203b66:	8b89                	andi	a5,a5,2
ffffffffc0203b68:	efad                	bnez	a5,ffffffffc0203be2 <exit_range+0x212>
        pmm_manager->free_pages(base, n);
ffffffffc0203b6a:	000db783          	ld	a5,0(s11)
ffffffffc0203b6e:	4585                	li	a1,1
ffffffffc0203b70:	739c                	ld	a5,32(a5)
ffffffffc0203b72:	9782                	jalr	a5
ffffffffc0203b74:	000af717          	auipc	a4,0xaf
ffffffffc0203b78:	d9470713          	addi	a4,a4,-620 # ffffffffc02b2908 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0203b7c:	00043023          	sd	zero,0(s0)
    } while (d1start != 0 && d1start < end);
ffffffffc0203b80:	ee0990e3          	bnez	s3,ffffffffc0203a60 <exit_range+0x90>
}
ffffffffc0203b84:	70e6                	ld	ra,120(sp)
ffffffffc0203b86:	7446                	ld	s0,112(sp)
ffffffffc0203b88:	74a6                	ld	s1,104(sp)
ffffffffc0203b8a:	7906                	ld	s2,96(sp)
ffffffffc0203b8c:	69e6                	ld	s3,88(sp)
ffffffffc0203b8e:	6a46                	ld	s4,80(sp)
ffffffffc0203b90:	6aa6                	ld	s5,72(sp)
ffffffffc0203b92:	6b06                	ld	s6,64(sp)
ffffffffc0203b94:	7be2                	ld	s7,56(sp)
ffffffffc0203b96:	7c42                	ld	s8,48(sp)
ffffffffc0203b98:	7ca2                	ld	s9,40(sp)
ffffffffc0203b9a:	7d02                	ld	s10,32(sp)
ffffffffc0203b9c:	6de2                	ld	s11,24(sp)
ffffffffc0203b9e:	6109                	addi	sp,sp,128
ffffffffc0203ba0:	8082                	ret
            if (free_pd0) {
ffffffffc0203ba2:	ea0b8fe3          	beqz	s7,ffffffffc0203a60 <exit_range+0x90>
ffffffffc0203ba6:	bf45                	j	ffffffffc0203b56 <exit_range+0x186>
ffffffffc0203ba8:	e032                	sd	a2,0(sp)
        intr_disable();
ffffffffc0203baa:	e42a                	sd	a0,8(sp)
ffffffffc0203bac:	a9dfc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203bb0:	000db783          	ld	a5,0(s11)
ffffffffc0203bb4:	6522                	ld	a0,8(sp)
ffffffffc0203bb6:	4585                	li	a1,1
ffffffffc0203bb8:	739c                	ld	a5,32(a5)
ffffffffc0203bba:	9782                	jalr	a5
        intr_enable();
ffffffffc0203bbc:	a87fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0203bc0:	6602                	ld	a2,0(sp)
ffffffffc0203bc2:	000af717          	auipc	a4,0xaf
ffffffffc0203bc6:	d4670713          	addi	a4,a4,-698 # ffffffffc02b2908 <pages>
ffffffffc0203bca:	6885                	lui	a7,0x1
ffffffffc0203bcc:	00080337          	lui	t1,0x80
ffffffffc0203bd0:	fff80e37          	lui	t3,0xfff80
ffffffffc0203bd4:	000af817          	auipc	a6,0xaf
ffffffffc0203bd8:	d4480813          	addi	a6,a6,-700 # ffffffffc02b2918 <va_pa_offset>
                        pd0[PDX0(d0start)] = 0;
ffffffffc0203bdc:	0004b023          	sd	zero,0(s1)
ffffffffc0203be0:	b7a5                	j	ffffffffc0203b48 <exit_range+0x178>
ffffffffc0203be2:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc0203be4:	a65fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203be8:	000db783          	ld	a5,0(s11)
ffffffffc0203bec:	6502                	ld	a0,0(sp)
ffffffffc0203bee:	4585                	li	a1,1
ffffffffc0203bf0:	739c                	ld	a5,32(a5)
ffffffffc0203bf2:	9782                	jalr	a5
        intr_enable();
ffffffffc0203bf4:	a4ffc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0203bf8:	000af717          	auipc	a4,0xaf
ffffffffc0203bfc:	d1070713          	addi	a4,a4,-752 # ffffffffc02b2908 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0203c00:	00043023          	sd	zero,0(s0)
ffffffffc0203c04:	bfb5                	j	ffffffffc0203b80 <exit_range+0x1b0>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203c06:	00004697          	auipc	a3,0x4
ffffffffc0203c0a:	30a68693          	addi	a3,a3,778 # ffffffffc0207f10 <default_pmm_manager+0x48>
ffffffffc0203c0e:	00003617          	auipc	a2,0x3
ffffffffc0203c12:	21a60613          	addi	a2,a2,538 # ffffffffc0206e28 <commands+0x410>
ffffffffc0203c16:	12000593          	li	a1,288
ffffffffc0203c1a:	00004517          	auipc	a0,0x4
ffffffffc0203c1e:	2e650513          	addi	a0,a0,742 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc0203c22:	de6fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203c26:	00003617          	auipc	a2,0x3
ffffffffc0203c2a:	7d260613          	addi	a2,a2,2002 # ffffffffc02073f8 <commands+0x9e0>
ffffffffc0203c2e:	06900593          	li	a1,105
ffffffffc0203c32:	00003517          	auipc	a0,0x3
ffffffffc0203c36:	53650513          	addi	a0,a0,1334 # ffffffffc0207168 <commands+0x750>
ffffffffc0203c3a:	dcefc0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0203c3e:	8e3ff0ef          	jal	ra,ffffffffc0203520 <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc0203c42:	00004697          	auipc	a3,0x4
ffffffffc0203c46:	2fe68693          	addi	a3,a3,766 # ffffffffc0207f40 <default_pmm_manager+0x78>
ffffffffc0203c4a:	00003617          	auipc	a2,0x3
ffffffffc0203c4e:	1de60613          	addi	a2,a2,478 # ffffffffc0206e28 <commands+0x410>
ffffffffc0203c52:	12100593          	li	a1,289
ffffffffc0203c56:	00004517          	auipc	a0,0x4
ffffffffc0203c5a:	2aa50513          	addi	a0,a0,682 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc0203c5e:	daafc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0203c62 <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0203c62:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0203c64:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0203c66:	ec26                	sd	s1,24(sp)
ffffffffc0203c68:	f406                	sd	ra,40(sp)
ffffffffc0203c6a:	f022                	sd	s0,32(sp)
ffffffffc0203c6c:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0203c6e:	9f7ff0ef          	jal	ra,ffffffffc0203664 <get_pte>
    if (ptep != NULL) {
ffffffffc0203c72:	c511                	beqz	a0,ffffffffc0203c7e <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0203c74:	611c                	ld	a5,0(a0)
ffffffffc0203c76:	842a                	mv	s0,a0
ffffffffc0203c78:	0017f713          	andi	a4,a5,1
ffffffffc0203c7c:	e711                	bnez	a4,ffffffffc0203c88 <page_remove+0x26>
}
ffffffffc0203c7e:	70a2                	ld	ra,40(sp)
ffffffffc0203c80:	7402                	ld	s0,32(sp)
ffffffffc0203c82:	64e2                	ld	s1,24(sp)
ffffffffc0203c84:	6145                	addi	sp,sp,48
ffffffffc0203c86:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0203c88:	078a                	slli	a5,a5,0x2
ffffffffc0203c8a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203c8c:	000af717          	auipc	a4,0xaf
ffffffffc0203c90:	c7473703          	ld	a4,-908(a4) # ffffffffc02b2900 <npage>
ffffffffc0203c94:	06e7f363          	bgeu	a5,a4,ffffffffc0203cfa <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc0203c98:	fff80537          	lui	a0,0xfff80
ffffffffc0203c9c:	97aa                	add	a5,a5,a0
ffffffffc0203c9e:	079a                	slli	a5,a5,0x6
ffffffffc0203ca0:	000af517          	auipc	a0,0xaf
ffffffffc0203ca4:	c6853503          	ld	a0,-920(a0) # ffffffffc02b2908 <pages>
ffffffffc0203ca8:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0203caa:	411c                	lw	a5,0(a0)
ffffffffc0203cac:	fff7871b          	addiw	a4,a5,-1
ffffffffc0203cb0:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0203cb2:	cb11                	beqz	a4,ffffffffc0203cc6 <page_remove+0x64>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0203cb4:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203cb8:	12048073          	sfence.vma	s1
}
ffffffffc0203cbc:	70a2                	ld	ra,40(sp)
ffffffffc0203cbe:	7402                	ld	s0,32(sp)
ffffffffc0203cc0:	64e2                	ld	s1,24(sp)
ffffffffc0203cc2:	6145                	addi	sp,sp,48
ffffffffc0203cc4:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203cc6:	100027f3          	csrr	a5,sstatus
ffffffffc0203cca:	8b89                	andi	a5,a5,2
ffffffffc0203ccc:	eb89                	bnez	a5,ffffffffc0203cde <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc0203cce:	000af797          	auipc	a5,0xaf
ffffffffc0203cd2:	c427b783          	ld	a5,-958(a5) # ffffffffc02b2910 <pmm_manager>
ffffffffc0203cd6:	739c                	ld	a5,32(a5)
ffffffffc0203cd8:	4585                	li	a1,1
ffffffffc0203cda:	9782                	jalr	a5
    if (flag) {
ffffffffc0203cdc:	bfe1                	j	ffffffffc0203cb4 <page_remove+0x52>
        intr_disable();
ffffffffc0203cde:	e42a                	sd	a0,8(sp)
ffffffffc0203ce0:	969fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc0203ce4:	000af797          	auipc	a5,0xaf
ffffffffc0203ce8:	c2c7b783          	ld	a5,-980(a5) # ffffffffc02b2910 <pmm_manager>
ffffffffc0203cec:	739c                	ld	a5,32(a5)
ffffffffc0203cee:	6522                	ld	a0,8(sp)
ffffffffc0203cf0:	4585                	li	a1,1
ffffffffc0203cf2:	9782                	jalr	a5
        intr_enable();
ffffffffc0203cf4:	94ffc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0203cf8:	bf75                	j	ffffffffc0203cb4 <page_remove+0x52>
ffffffffc0203cfa:	827ff0ef          	jal	ra,ffffffffc0203520 <pa2page.part.0>

ffffffffc0203cfe <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0203cfe:	7139                	addi	sp,sp,-64
ffffffffc0203d00:	e852                	sd	s4,16(sp)
ffffffffc0203d02:	8a32                	mv	s4,a2
ffffffffc0203d04:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0203d06:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0203d08:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0203d0a:	85d2                	mv	a1,s4
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0203d0c:	f426                	sd	s1,40(sp)
ffffffffc0203d0e:	fc06                	sd	ra,56(sp)
ffffffffc0203d10:	f04a                	sd	s2,32(sp)
ffffffffc0203d12:	ec4e                	sd	s3,24(sp)
ffffffffc0203d14:	e456                	sd	s5,8(sp)
ffffffffc0203d16:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0203d18:	94dff0ef          	jal	ra,ffffffffc0203664 <get_pte>
    if (ptep == NULL) {
ffffffffc0203d1c:	c961                	beqz	a0,ffffffffc0203dec <page_insert+0xee>
    page->ref += 1;
ffffffffc0203d1e:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0203d20:	611c                	ld	a5,0(a0)
ffffffffc0203d22:	89aa                	mv	s3,a0
ffffffffc0203d24:	0016871b          	addiw	a4,a3,1
ffffffffc0203d28:	c018                	sw	a4,0(s0)
ffffffffc0203d2a:	0017f713          	andi	a4,a5,1
ffffffffc0203d2e:	ef05                	bnez	a4,ffffffffc0203d66 <page_insert+0x68>
    return page - pages + nbase;
ffffffffc0203d30:	000af717          	auipc	a4,0xaf
ffffffffc0203d34:	bd873703          	ld	a4,-1064(a4) # ffffffffc02b2908 <pages>
ffffffffc0203d38:	8c19                	sub	s0,s0,a4
ffffffffc0203d3a:	000807b7          	lui	a5,0x80
ffffffffc0203d3e:	8419                	srai	s0,s0,0x6
ffffffffc0203d40:	943e                	add	s0,s0,a5
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0203d42:	042a                	slli	s0,s0,0xa
ffffffffc0203d44:	8cc1                	or	s1,s1,s0
ffffffffc0203d46:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0203d4a:	0099b023          	sd	s1,0(s3) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ed0>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203d4e:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc0203d52:	4501                	li	a0,0
}
ffffffffc0203d54:	70e2                	ld	ra,56(sp)
ffffffffc0203d56:	7442                	ld	s0,48(sp)
ffffffffc0203d58:	74a2                	ld	s1,40(sp)
ffffffffc0203d5a:	7902                	ld	s2,32(sp)
ffffffffc0203d5c:	69e2                	ld	s3,24(sp)
ffffffffc0203d5e:	6a42                	ld	s4,16(sp)
ffffffffc0203d60:	6aa2                	ld	s5,8(sp)
ffffffffc0203d62:	6121                	addi	sp,sp,64
ffffffffc0203d64:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0203d66:	078a                	slli	a5,a5,0x2
ffffffffc0203d68:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203d6a:	000af717          	auipc	a4,0xaf
ffffffffc0203d6e:	b9673703          	ld	a4,-1130(a4) # ffffffffc02b2900 <npage>
ffffffffc0203d72:	06e7ff63          	bgeu	a5,a4,ffffffffc0203df0 <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc0203d76:	000afa97          	auipc	s5,0xaf
ffffffffc0203d7a:	b92a8a93          	addi	s5,s5,-1134 # ffffffffc02b2908 <pages>
ffffffffc0203d7e:	000ab703          	ld	a4,0(s5)
ffffffffc0203d82:	fff80937          	lui	s2,0xfff80
ffffffffc0203d86:	993e                	add	s2,s2,a5
ffffffffc0203d88:	091a                	slli	s2,s2,0x6
ffffffffc0203d8a:	993a                	add	s2,s2,a4
        if (p == page) {
ffffffffc0203d8c:	01240c63          	beq	s0,s2,ffffffffc0203da4 <page_insert+0xa6>
    page->ref -= 1;
ffffffffc0203d90:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fccd6c4>
ffffffffc0203d94:	fff7869b          	addiw	a3,a5,-1
ffffffffc0203d98:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) ==
ffffffffc0203d9c:	c691                	beqz	a3,ffffffffc0203da8 <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203d9e:	120a0073          	sfence.vma	s4
}
ffffffffc0203da2:	bf59                	j	ffffffffc0203d38 <page_insert+0x3a>
ffffffffc0203da4:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0203da6:	bf49                	j	ffffffffc0203d38 <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203da8:	100027f3          	csrr	a5,sstatus
ffffffffc0203dac:	8b89                	andi	a5,a5,2
ffffffffc0203dae:	ef91                	bnez	a5,ffffffffc0203dca <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc0203db0:	000af797          	auipc	a5,0xaf
ffffffffc0203db4:	b607b783          	ld	a5,-1184(a5) # ffffffffc02b2910 <pmm_manager>
ffffffffc0203db8:	739c                	ld	a5,32(a5)
ffffffffc0203dba:	4585                	li	a1,1
ffffffffc0203dbc:	854a                	mv	a0,s2
ffffffffc0203dbe:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc0203dc0:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203dc4:	120a0073          	sfence.vma	s4
ffffffffc0203dc8:	bf85                	j	ffffffffc0203d38 <page_insert+0x3a>
        intr_disable();
ffffffffc0203dca:	87ffc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203dce:	000af797          	auipc	a5,0xaf
ffffffffc0203dd2:	b427b783          	ld	a5,-1214(a5) # ffffffffc02b2910 <pmm_manager>
ffffffffc0203dd6:	739c                	ld	a5,32(a5)
ffffffffc0203dd8:	4585                	li	a1,1
ffffffffc0203dda:	854a                	mv	a0,s2
ffffffffc0203ddc:	9782                	jalr	a5
        intr_enable();
ffffffffc0203dde:	865fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0203de2:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203de6:	120a0073          	sfence.vma	s4
ffffffffc0203dea:	b7b9                	j	ffffffffc0203d38 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0203dec:	5571                	li	a0,-4
ffffffffc0203dee:	b79d                	j	ffffffffc0203d54 <page_insert+0x56>
ffffffffc0203df0:	f30ff0ef          	jal	ra,ffffffffc0203520 <pa2page.part.0>

ffffffffc0203df4 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0203df4:	00004797          	auipc	a5,0x4
ffffffffc0203df8:	0d478793          	addi	a5,a5,212 # ffffffffc0207ec8 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203dfc:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0203dfe:	711d                	addi	sp,sp,-96
ffffffffc0203e00:	ec5e                	sd	s7,24(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203e02:	00004517          	auipc	a0,0x4
ffffffffc0203e06:	15650513          	addi	a0,a0,342 # ffffffffc0207f58 <default_pmm_manager+0x90>
    pmm_manager = &default_pmm_manager;
ffffffffc0203e0a:	000afb97          	auipc	s7,0xaf
ffffffffc0203e0e:	b06b8b93          	addi	s7,s7,-1274 # ffffffffc02b2910 <pmm_manager>
void pmm_init(void) {
ffffffffc0203e12:	ec86                	sd	ra,88(sp)
ffffffffc0203e14:	e4a6                	sd	s1,72(sp)
ffffffffc0203e16:	fc4e                	sd	s3,56(sp)
ffffffffc0203e18:	f05a                	sd	s6,32(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0203e1a:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc0203e1e:	e8a2                	sd	s0,80(sp)
ffffffffc0203e20:	e0ca                	sd	s2,64(sp)
ffffffffc0203e22:	f852                	sd	s4,48(sp)
ffffffffc0203e24:	f456                	sd	s5,40(sp)
ffffffffc0203e26:	e862                	sd	s8,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203e28:	aa4fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    pmm_manager->init();
ffffffffc0203e2c:	000bb783          	ld	a5,0(s7)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0203e30:	000af997          	auipc	s3,0xaf
ffffffffc0203e34:	ae898993          	addi	s3,s3,-1304 # ffffffffc02b2918 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc0203e38:	000af497          	auipc	s1,0xaf
ffffffffc0203e3c:	ac848493          	addi	s1,s1,-1336 # ffffffffc02b2900 <npage>
    pmm_manager->init();
ffffffffc0203e40:	679c                	ld	a5,8(a5)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0203e42:	000afb17          	auipc	s6,0xaf
ffffffffc0203e46:	ac6b0b13          	addi	s6,s6,-1338 # ffffffffc02b2908 <pages>
    pmm_manager->init();
ffffffffc0203e4a:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0203e4c:	57f5                	li	a5,-3
ffffffffc0203e4e:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0203e50:	00004517          	auipc	a0,0x4
ffffffffc0203e54:	12050513          	addi	a0,a0,288 # ffffffffc0207f70 <default_pmm_manager+0xa8>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0203e58:	00f9b023          	sd	a5,0(s3)
    cprintf("physcial memory map:\n");
ffffffffc0203e5c:	a70fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0203e60:	46c5                	li	a3,17
ffffffffc0203e62:	06ee                	slli	a3,a3,0x1b
ffffffffc0203e64:	40100613          	li	a2,1025
ffffffffc0203e68:	07e005b7          	lui	a1,0x7e00
ffffffffc0203e6c:	16fd                	addi	a3,a3,-1
ffffffffc0203e6e:	0656                	slli	a2,a2,0x15
ffffffffc0203e70:	00004517          	auipc	a0,0x4
ffffffffc0203e74:	11850513          	addi	a0,a0,280 # ffffffffc0207f88 <default_pmm_manager+0xc0>
ffffffffc0203e78:	a54fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0203e7c:	777d                	lui	a4,0xfffff
ffffffffc0203e7e:	000b0797          	auipc	a5,0xb0
ffffffffc0203e82:	abd78793          	addi	a5,a5,-1347 # ffffffffc02b393b <end+0xfff>
ffffffffc0203e86:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0203e88:	00088737          	lui	a4,0x88
ffffffffc0203e8c:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0203e8e:	00fb3023          	sd	a5,0(s6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0203e92:	4701                	li	a4,0
ffffffffc0203e94:	4585                	li	a1,1
ffffffffc0203e96:	fff80837          	lui	a6,0xfff80
ffffffffc0203e9a:	a019                	j	ffffffffc0203ea0 <pmm_init+0xac>
        SetPageReserved(pages + i);
ffffffffc0203e9c:	000b3783          	ld	a5,0(s6)
ffffffffc0203ea0:	00671693          	slli	a3,a4,0x6
ffffffffc0203ea4:	97b6                	add	a5,a5,a3
ffffffffc0203ea6:	07a1                	addi	a5,a5,8
ffffffffc0203ea8:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0203eac:	6090                	ld	a2,0(s1)
ffffffffc0203eae:	0705                	addi	a4,a4,1
ffffffffc0203eb0:	010607b3          	add	a5,a2,a6
ffffffffc0203eb4:	fef764e3          	bltu	a4,a5,ffffffffc0203e9c <pmm_init+0xa8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203eb8:	000b3503          	ld	a0,0(s6)
ffffffffc0203ebc:	079a                	slli	a5,a5,0x6
ffffffffc0203ebe:	c0200737          	lui	a4,0xc0200
ffffffffc0203ec2:	00f506b3          	add	a3,a0,a5
ffffffffc0203ec6:	60e6e563          	bltu	a3,a4,ffffffffc02044d0 <pmm_init+0x6dc>
ffffffffc0203eca:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc0203ece:	4745                	li	a4,17
ffffffffc0203ed0:	076e                	slli	a4,a4,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203ed2:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc0203ed4:	4ae6e563          	bltu	a3,a4,ffffffffc020437e <pmm_init+0x58a>
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0203ed8:	00004517          	auipc	a0,0x4
ffffffffc0203edc:	0d850513          	addi	a0,a0,216 # ffffffffc0207fb0 <default_pmm_manager+0xe8>
ffffffffc0203ee0:	9ecfc0ef          	jal	ra,ffffffffc02000cc <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0203ee4:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0203ee8:	000af917          	auipc	s2,0xaf
ffffffffc0203eec:	a1090913          	addi	s2,s2,-1520 # ffffffffc02b28f8 <boot_pgdir>
    pmm_manager->check();
ffffffffc0203ef0:	7b9c                	ld	a5,48(a5)
ffffffffc0203ef2:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0203ef4:	00004517          	auipc	a0,0x4
ffffffffc0203ef8:	0d450513          	addi	a0,a0,212 # ffffffffc0207fc8 <default_pmm_manager+0x100>
ffffffffc0203efc:	9d0fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0203f00:	00007697          	auipc	a3,0x7
ffffffffc0203f04:	10068693          	addi	a3,a3,256 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc0203f08:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0203f0c:	c02007b7          	lui	a5,0xc0200
ffffffffc0203f10:	5cf6ec63          	bltu	a3,a5,ffffffffc02044e8 <pmm_init+0x6f4>
ffffffffc0203f14:	0009b783          	ld	a5,0(s3)
ffffffffc0203f18:	8e9d                	sub	a3,a3,a5
ffffffffc0203f1a:	000af797          	auipc	a5,0xaf
ffffffffc0203f1e:	9cd7bb23          	sd	a3,-1578(a5) # ffffffffc02b28f0 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203f22:	100027f3          	csrr	a5,sstatus
ffffffffc0203f26:	8b89                	andi	a5,a5,2
ffffffffc0203f28:	48079263          	bnez	a5,ffffffffc02043ac <pmm_init+0x5b8>
        ret = pmm_manager->nr_free_pages();
ffffffffc0203f2c:	000bb783          	ld	a5,0(s7)
ffffffffc0203f30:	779c                	ld	a5,40(a5)
ffffffffc0203f32:	9782                	jalr	a5
ffffffffc0203f34:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203f36:	6098                	ld	a4,0(s1)
ffffffffc0203f38:	c80007b7          	lui	a5,0xc8000
ffffffffc0203f3c:	83b1                	srli	a5,a5,0xc
ffffffffc0203f3e:	5ee7e163          	bltu	a5,a4,ffffffffc0204520 <pmm_init+0x72c>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0203f42:	00093503          	ld	a0,0(s2)
ffffffffc0203f46:	5a050d63          	beqz	a0,ffffffffc0204500 <pmm_init+0x70c>
ffffffffc0203f4a:	03451793          	slli	a5,a0,0x34
ffffffffc0203f4e:	5a079963          	bnez	a5,ffffffffc0204500 <pmm_init+0x70c>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0203f52:	4601                	li	a2,0
ffffffffc0203f54:	4581                	li	a1,0
ffffffffc0203f56:	8e1ff0ef          	jal	ra,ffffffffc0203836 <get_page>
ffffffffc0203f5a:	62051563          	bnez	a0,ffffffffc0204584 <pmm_init+0x790>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0203f5e:	4505                	li	a0,1
ffffffffc0203f60:	df8ff0ef          	jal	ra,ffffffffc0203558 <alloc_pages>
ffffffffc0203f64:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0203f66:	00093503          	ld	a0,0(s2)
ffffffffc0203f6a:	4681                	li	a3,0
ffffffffc0203f6c:	4601                	li	a2,0
ffffffffc0203f6e:	85d2                	mv	a1,s4
ffffffffc0203f70:	d8fff0ef          	jal	ra,ffffffffc0203cfe <page_insert>
ffffffffc0203f74:	5e051863          	bnez	a0,ffffffffc0204564 <pmm_init+0x770>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0203f78:	00093503          	ld	a0,0(s2)
ffffffffc0203f7c:	4601                	li	a2,0
ffffffffc0203f7e:	4581                	li	a1,0
ffffffffc0203f80:	ee4ff0ef          	jal	ra,ffffffffc0203664 <get_pte>
ffffffffc0203f84:	5c050063          	beqz	a0,ffffffffc0204544 <pmm_init+0x750>
    assert(pte2page(*ptep) == p1);
ffffffffc0203f88:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203f8a:	0017f713          	andi	a4,a5,1
ffffffffc0203f8e:	5a070963          	beqz	a4,ffffffffc0204540 <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc0203f92:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203f94:	078a                	slli	a5,a5,0x2
ffffffffc0203f96:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203f98:	52e7fa63          	bgeu	a5,a4,ffffffffc02044cc <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0203f9c:	000b3683          	ld	a3,0(s6)
ffffffffc0203fa0:	fff80637          	lui	a2,0xfff80
ffffffffc0203fa4:	97b2                	add	a5,a5,a2
ffffffffc0203fa6:	079a                	slli	a5,a5,0x6
ffffffffc0203fa8:	97b6                	add	a5,a5,a3
ffffffffc0203faa:	10fa16e3          	bne	s4,a5,ffffffffc02048b6 <pmm_init+0xac2>
    assert(page_ref(p1) == 1);
ffffffffc0203fae:	000a2683          	lw	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bc0>
ffffffffc0203fb2:	4785                	li	a5,1
ffffffffc0203fb4:	12f69de3          	bne	a3,a5,ffffffffc02048ee <pmm_init+0xafa>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0203fb8:	00093503          	ld	a0,0(s2)
ffffffffc0203fbc:	77fd                	lui	a5,0xfffff
ffffffffc0203fbe:	6114                	ld	a3,0(a0)
ffffffffc0203fc0:	068a                	slli	a3,a3,0x2
ffffffffc0203fc2:	8efd                	and	a3,a3,a5
ffffffffc0203fc4:	00c6d613          	srli	a2,a3,0xc
ffffffffc0203fc8:	10e677e3          	bgeu	a2,a4,ffffffffc02048d6 <pmm_init+0xae2>
ffffffffc0203fcc:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203fd0:	96e2                	add	a3,a3,s8
ffffffffc0203fd2:	0006ba83          	ld	s5,0(a3)
ffffffffc0203fd6:	0a8a                	slli	s5,s5,0x2
ffffffffc0203fd8:	00fafab3          	and	s5,s5,a5
ffffffffc0203fdc:	00cad793          	srli	a5,s5,0xc
ffffffffc0203fe0:	62e7f263          	bgeu	a5,a4,ffffffffc0204604 <pmm_init+0x810>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203fe4:	4601                	li	a2,0
ffffffffc0203fe6:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203fe8:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203fea:	e7aff0ef          	jal	ra,ffffffffc0203664 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203fee:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203ff0:	5f551a63          	bne	a0,s5,ffffffffc02045e4 <pmm_init+0x7f0>

    p2 = alloc_page();
ffffffffc0203ff4:	4505                	li	a0,1
ffffffffc0203ff6:	d62ff0ef          	jal	ra,ffffffffc0203558 <alloc_pages>
ffffffffc0203ffa:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0203ffc:	00093503          	ld	a0,0(s2)
ffffffffc0204000:	46d1                	li	a3,20
ffffffffc0204002:	6605                	lui	a2,0x1
ffffffffc0204004:	85d6                	mv	a1,s5
ffffffffc0204006:	cf9ff0ef          	jal	ra,ffffffffc0203cfe <page_insert>
ffffffffc020400a:	58051d63          	bnez	a0,ffffffffc02045a4 <pmm_init+0x7b0>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020400e:	00093503          	ld	a0,0(s2)
ffffffffc0204012:	4601                	li	a2,0
ffffffffc0204014:	6585                	lui	a1,0x1
ffffffffc0204016:	e4eff0ef          	jal	ra,ffffffffc0203664 <get_pte>
ffffffffc020401a:	0e050ae3          	beqz	a0,ffffffffc020490e <pmm_init+0xb1a>
    assert(*ptep & PTE_U);
ffffffffc020401e:	611c                	ld	a5,0(a0)
ffffffffc0204020:	0107f713          	andi	a4,a5,16
ffffffffc0204024:	6e070d63          	beqz	a4,ffffffffc020471e <pmm_init+0x92a>
    assert(*ptep & PTE_W);
ffffffffc0204028:	8b91                	andi	a5,a5,4
ffffffffc020402a:	6a078a63          	beqz	a5,ffffffffc02046de <pmm_init+0x8ea>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020402e:	00093503          	ld	a0,0(s2)
ffffffffc0204032:	611c                	ld	a5,0(a0)
ffffffffc0204034:	8bc1                	andi	a5,a5,16
ffffffffc0204036:	68078463          	beqz	a5,ffffffffc02046be <pmm_init+0x8ca>
    assert(page_ref(p2) == 1);
ffffffffc020403a:	000aa703          	lw	a4,0(s5)
ffffffffc020403e:	4785                	li	a5,1
ffffffffc0204040:	58f71263          	bne	a4,a5,ffffffffc02045c4 <pmm_init+0x7d0>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0204044:	4681                	li	a3,0
ffffffffc0204046:	6605                	lui	a2,0x1
ffffffffc0204048:	85d2                	mv	a1,s4
ffffffffc020404a:	cb5ff0ef          	jal	ra,ffffffffc0203cfe <page_insert>
ffffffffc020404e:	62051863          	bnez	a0,ffffffffc020467e <pmm_init+0x88a>
    assert(page_ref(p1) == 2);
ffffffffc0204052:	000a2703          	lw	a4,0(s4)
ffffffffc0204056:	4789                	li	a5,2
ffffffffc0204058:	60f71363          	bne	a4,a5,ffffffffc020465e <pmm_init+0x86a>
    assert(page_ref(p2) == 0);
ffffffffc020405c:	000aa783          	lw	a5,0(s5)
ffffffffc0204060:	5c079f63          	bnez	a5,ffffffffc020463e <pmm_init+0x84a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0204064:	00093503          	ld	a0,0(s2)
ffffffffc0204068:	4601                	li	a2,0
ffffffffc020406a:	6585                	lui	a1,0x1
ffffffffc020406c:	df8ff0ef          	jal	ra,ffffffffc0203664 <get_pte>
ffffffffc0204070:	5a050763          	beqz	a0,ffffffffc020461e <pmm_init+0x82a>
    assert(pte2page(*ptep) == p1);
ffffffffc0204074:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0204076:	00177793          	andi	a5,a4,1
ffffffffc020407a:	4c078363          	beqz	a5,ffffffffc0204540 <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc020407e:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0204080:	00271793          	slli	a5,a4,0x2
ffffffffc0204084:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204086:	44d7f363          	bgeu	a5,a3,ffffffffc02044cc <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc020408a:	000b3683          	ld	a3,0(s6)
ffffffffc020408e:	fff80637          	lui	a2,0xfff80
ffffffffc0204092:	97b2                	add	a5,a5,a2
ffffffffc0204094:	079a                	slli	a5,a5,0x6
ffffffffc0204096:	97b6                	add	a5,a5,a3
ffffffffc0204098:	6efa1363          	bne	s4,a5,ffffffffc020477e <pmm_init+0x98a>
    assert((*ptep & PTE_U) == 0);
ffffffffc020409c:	8b41                	andi	a4,a4,16
ffffffffc020409e:	6c071063          	bnez	a4,ffffffffc020475e <pmm_init+0x96a>

    page_remove(boot_pgdir, 0x0);
ffffffffc02040a2:	00093503          	ld	a0,0(s2)
ffffffffc02040a6:	4581                	li	a1,0
ffffffffc02040a8:	bbbff0ef          	jal	ra,ffffffffc0203c62 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc02040ac:	000a2703          	lw	a4,0(s4)
ffffffffc02040b0:	4785                	li	a5,1
ffffffffc02040b2:	68f71663          	bne	a4,a5,ffffffffc020473e <pmm_init+0x94a>
    assert(page_ref(p2) == 0);
ffffffffc02040b6:	000aa783          	lw	a5,0(s5)
ffffffffc02040ba:	74079e63          	bnez	a5,ffffffffc0204816 <pmm_init+0xa22>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc02040be:	00093503          	ld	a0,0(s2)
ffffffffc02040c2:	6585                	lui	a1,0x1
ffffffffc02040c4:	b9fff0ef          	jal	ra,ffffffffc0203c62 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc02040c8:	000a2783          	lw	a5,0(s4)
ffffffffc02040cc:	72079563          	bnez	a5,ffffffffc02047f6 <pmm_init+0xa02>
    assert(page_ref(p2) == 0);
ffffffffc02040d0:	000aa783          	lw	a5,0(s5)
ffffffffc02040d4:	70079163          	bnez	a5,ffffffffc02047d6 <pmm_init+0x9e2>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02040d8:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02040dc:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02040de:	000a3683          	ld	a3,0(s4)
ffffffffc02040e2:	068a                	slli	a3,a3,0x2
ffffffffc02040e4:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc02040e6:	3ee6f363          	bgeu	a3,a4,ffffffffc02044cc <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02040ea:	fff807b7          	lui	a5,0xfff80
ffffffffc02040ee:	000b3503          	ld	a0,0(s6)
ffffffffc02040f2:	96be                	add	a3,a3,a5
ffffffffc02040f4:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc02040f6:	00d507b3          	add	a5,a0,a3
ffffffffc02040fa:	4390                	lw	a2,0(a5)
ffffffffc02040fc:	4785                	li	a5,1
ffffffffc02040fe:	6af61c63          	bne	a2,a5,ffffffffc02047b6 <pmm_init+0x9c2>
    return page - pages + nbase;
ffffffffc0204102:	8699                	srai	a3,a3,0x6
ffffffffc0204104:	000805b7          	lui	a1,0x80
ffffffffc0204108:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc020410a:	00c69613          	slli	a2,a3,0xc
ffffffffc020410e:	8231                	srli	a2,a2,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0204110:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204112:	68e67663          	bgeu	a2,a4,ffffffffc020479e <pmm_init+0x9aa>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0204116:	0009b603          	ld	a2,0(s3)
ffffffffc020411a:	96b2                	add	a3,a3,a2
    return pa2page(PDE_ADDR(pde));
ffffffffc020411c:	629c                	ld	a5,0(a3)
ffffffffc020411e:	078a                	slli	a5,a5,0x2
ffffffffc0204120:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204122:	3ae7f563          	bgeu	a5,a4,ffffffffc02044cc <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0204126:	8f8d                	sub	a5,a5,a1
ffffffffc0204128:	079a                	slli	a5,a5,0x6
ffffffffc020412a:	953e                	add	a0,a0,a5
ffffffffc020412c:	100027f3          	csrr	a5,sstatus
ffffffffc0204130:	8b89                	andi	a5,a5,2
ffffffffc0204132:	2c079763          	bnez	a5,ffffffffc0204400 <pmm_init+0x60c>
        pmm_manager->free_pages(base, n);
ffffffffc0204136:	000bb783          	ld	a5,0(s7)
ffffffffc020413a:	4585                	li	a1,1
ffffffffc020413c:	739c                	ld	a5,32(a5)
ffffffffc020413e:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0204140:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0204144:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204146:	078a                	slli	a5,a5,0x2
ffffffffc0204148:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020414a:	38e7f163          	bgeu	a5,a4,ffffffffc02044cc <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc020414e:	000b3503          	ld	a0,0(s6)
ffffffffc0204152:	fff80737          	lui	a4,0xfff80
ffffffffc0204156:	97ba                	add	a5,a5,a4
ffffffffc0204158:	079a                	slli	a5,a5,0x6
ffffffffc020415a:	953e                	add	a0,a0,a5
ffffffffc020415c:	100027f3          	csrr	a5,sstatus
ffffffffc0204160:	8b89                	andi	a5,a5,2
ffffffffc0204162:	28079363          	bnez	a5,ffffffffc02043e8 <pmm_init+0x5f4>
ffffffffc0204166:	000bb783          	ld	a5,0(s7)
ffffffffc020416a:	4585                	li	a1,1
ffffffffc020416c:	739c                	ld	a5,32(a5)
ffffffffc020416e:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0204170:	00093783          	ld	a5,0(s2)
ffffffffc0204174:	0007b023          	sd	zero,0(a5) # fffffffffff80000 <end+0x3fccd6c4>
  asm volatile("sfence.vma");
ffffffffc0204178:	12000073          	sfence.vma
ffffffffc020417c:	100027f3          	csrr	a5,sstatus
ffffffffc0204180:	8b89                	andi	a5,a5,2
ffffffffc0204182:	24079963          	bnez	a5,ffffffffc02043d4 <pmm_init+0x5e0>
        ret = pmm_manager->nr_free_pages();
ffffffffc0204186:	000bb783          	ld	a5,0(s7)
ffffffffc020418a:	779c                	ld	a5,40(a5)
ffffffffc020418c:	9782                	jalr	a5
ffffffffc020418e:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0204190:	71441363          	bne	s0,s4,ffffffffc0204896 <pmm_init+0xaa2>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0204194:	00004517          	auipc	a0,0x4
ffffffffc0204198:	11c50513          	addi	a0,a0,284 # ffffffffc02082b0 <default_pmm_manager+0x3e8>
ffffffffc020419c:	f31fb0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc02041a0:	100027f3          	csrr	a5,sstatus
ffffffffc02041a4:	8b89                	andi	a5,a5,2
ffffffffc02041a6:	20079d63          	bnez	a5,ffffffffc02043c0 <pmm_init+0x5cc>
        ret = pmm_manager->nr_free_pages();
ffffffffc02041aa:	000bb783          	ld	a5,0(s7)
ffffffffc02041ae:	779c                	ld	a5,40(a5)
ffffffffc02041b0:	9782                	jalr	a5
ffffffffc02041b2:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02041b4:	6098                	ld	a4,0(s1)
ffffffffc02041b6:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02041ba:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02041bc:	00c71793          	slli	a5,a4,0xc
ffffffffc02041c0:	6a05                	lui	s4,0x1
ffffffffc02041c2:	02f47c63          	bgeu	s0,a5,ffffffffc02041fa <pmm_init+0x406>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02041c6:	00c45793          	srli	a5,s0,0xc
ffffffffc02041ca:	00093503          	ld	a0,0(s2)
ffffffffc02041ce:	2ee7f263          	bgeu	a5,a4,ffffffffc02044b2 <pmm_init+0x6be>
ffffffffc02041d2:	0009b583          	ld	a1,0(s3)
ffffffffc02041d6:	4601                	li	a2,0
ffffffffc02041d8:	95a2                	add	a1,a1,s0
ffffffffc02041da:	c8aff0ef          	jal	ra,ffffffffc0203664 <get_pte>
ffffffffc02041de:	2a050a63          	beqz	a0,ffffffffc0204492 <pmm_init+0x69e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02041e2:	611c                	ld	a5,0(a0)
ffffffffc02041e4:	078a                	slli	a5,a5,0x2
ffffffffc02041e6:	0157f7b3          	and	a5,a5,s5
ffffffffc02041ea:	28879463          	bne	a5,s0,ffffffffc0204472 <pmm_init+0x67e>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02041ee:	6098                	ld	a4,0(s1)
ffffffffc02041f0:	9452                	add	s0,s0,s4
ffffffffc02041f2:	00c71793          	slli	a5,a4,0xc
ffffffffc02041f6:	fcf468e3          	bltu	s0,a5,ffffffffc02041c6 <pmm_init+0x3d2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc02041fa:	00093783          	ld	a5,0(s2)
ffffffffc02041fe:	639c                	ld	a5,0(a5)
ffffffffc0204200:	66079b63          	bnez	a5,ffffffffc0204876 <pmm_init+0xa82>

    struct Page *p;
    p = alloc_page();
ffffffffc0204204:	4505                	li	a0,1
ffffffffc0204206:	b52ff0ef          	jal	ra,ffffffffc0203558 <alloc_pages>
ffffffffc020420a:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc020420c:	00093503          	ld	a0,0(s2)
ffffffffc0204210:	4699                	li	a3,6
ffffffffc0204212:	10000613          	li	a2,256
ffffffffc0204216:	85d6                	mv	a1,s5
ffffffffc0204218:	ae7ff0ef          	jal	ra,ffffffffc0203cfe <page_insert>
ffffffffc020421c:	62051d63          	bnez	a0,ffffffffc0204856 <pmm_init+0xa62>
    assert(page_ref(p) == 1);
ffffffffc0204220:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fd4c6c4>
ffffffffc0204224:	4785                	li	a5,1
ffffffffc0204226:	60f71863          	bne	a4,a5,ffffffffc0204836 <pmm_init+0xa42>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020422a:	00093503          	ld	a0,0(s2)
ffffffffc020422e:	6405                	lui	s0,0x1
ffffffffc0204230:	4699                	li	a3,6
ffffffffc0204232:	10040613          	addi	a2,s0,256 # 1100 <_binary_obj___user_faultread_out_size-0x8ac0>
ffffffffc0204236:	85d6                	mv	a1,s5
ffffffffc0204238:	ac7ff0ef          	jal	ra,ffffffffc0203cfe <page_insert>
ffffffffc020423c:	46051163          	bnez	a0,ffffffffc020469e <pmm_init+0x8aa>
    assert(page_ref(p) == 2);
ffffffffc0204240:	000aa703          	lw	a4,0(s5)
ffffffffc0204244:	4789                	li	a5,2
ffffffffc0204246:	72f71463          	bne	a4,a5,ffffffffc020496e <pmm_init+0xb7a>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc020424a:	00004597          	auipc	a1,0x4
ffffffffc020424e:	19e58593          	addi	a1,a1,414 # ffffffffc02083e8 <default_pmm_manager+0x520>
ffffffffc0204252:	10000513          	li	a0,256
ffffffffc0204256:	0a6020ef          	jal	ra,ffffffffc02062fc <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020425a:	10040593          	addi	a1,s0,256
ffffffffc020425e:	10000513          	li	a0,256
ffffffffc0204262:	0ac020ef          	jal	ra,ffffffffc020630e <strcmp>
ffffffffc0204266:	6e051463          	bnez	a0,ffffffffc020494e <pmm_init+0xb5a>
    return page - pages + nbase;
ffffffffc020426a:	000b3683          	ld	a3,0(s6)
ffffffffc020426e:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0204272:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc0204274:	40da86b3          	sub	a3,s5,a3
ffffffffc0204278:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc020427a:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc020427c:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc020427e:	8031                	srli	s0,s0,0xc
ffffffffc0204280:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0204284:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204286:	50f77c63          	bgeu	a4,a5,ffffffffc020479e <pmm_init+0x9aa>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc020428a:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc020428e:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0204292:	96be                	add	a3,a3,a5
ffffffffc0204294:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0204298:	02e020ef          	jal	ra,ffffffffc02062c6 <strlen>
ffffffffc020429c:	68051963          	bnez	a0,ffffffffc020492e <pmm_init+0xb3a>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02042a0:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02042a4:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02042a6:	000a3683          	ld	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bc0>
ffffffffc02042aa:	068a                	slli	a3,a3,0x2
ffffffffc02042ac:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc02042ae:	20f6ff63          	bgeu	a3,a5,ffffffffc02044cc <pmm_init+0x6d8>
    return KADDR(page2pa(page));
ffffffffc02042b2:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02042b4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02042b6:	4ef47463          	bgeu	s0,a5,ffffffffc020479e <pmm_init+0x9aa>
ffffffffc02042ba:	0009b403          	ld	s0,0(s3)
ffffffffc02042be:	9436                	add	s0,s0,a3
ffffffffc02042c0:	100027f3          	csrr	a5,sstatus
ffffffffc02042c4:	8b89                	andi	a5,a5,2
ffffffffc02042c6:	18079b63          	bnez	a5,ffffffffc020445c <pmm_init+0x668>
        pmm_manager->free_pages(base, n);
ffffffffc02042ca:	000bb783          	ld	a5,0(s7)
ffffffffc02042ce:	4585                	li	a1,1
ffffffffc02042d0:	8556                	mv	a0,s5
ffffffffc02042d2:	739c                	ld	a5,32(a5)
ffffffffc02042d4:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02042d6:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02042d8:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02042da:	078a                	slli	a5,a5,0x2
ffffffffc02042dc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02042de:	1ee7f763          	bgeu	a5,a4,ffffffffc02044cc <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02042e2:	000b3503          	ld	a0,0(s6)
ffffffffc02042e6:	fff80737          	lui	a4,0xfff80
ffffffffc02042ea:	97ba                	add	a5,a5,a4
ffffffffc02042ec:	079a                	slli	a5,a5,0x6
ffffffffc02042ee:	953e                	add	a0,a0,a5
ffffffffc02042f0:	100027f3          	csrr	a5,sstatus
ffffffffc02042f4:	8b89                	andi	a5,a5,2
ffffffffc02042f6:	14079763          	bnez	a5,ffffffffc0204444 <pmm_init+0x650>
ffffffffc02042fa:	000bb783          	ld	a5,0(s7)
ffffffffc02042fe:	4585                	li	a1,1
ffffffffc0204300:	739c                	ld	a5,32(a5)
ffffffffc0204302:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0204304:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0204308:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020430a:	078a                	slli	a5,a5,0x2
ffffffffc020430c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020430e:	1ae7ff63          	bgeu	a5,a4,ffffffffc02044cc <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0204312:	000b3503          	ld	a0,0(s6)
ffffffffc0204316:	fff80737          	lui	a4,0xfff80
ffffffffc020431a:	97ba                	add	a5,a5,a4
ffffffffc020431c:	079a                	slli	a5,a5,0x6
ffffffffc020431e:	953e                	add	a0,a0,a5
ffffffffc0204320:	100027f3          	csrr	a5,sstatus
ffffffffc0204324:	8b89                	andi	a5,a5,2
ffffffffc0204326:	10079363          	bnez	a5,ffffffffc020442c <pmm_init+0x638>
ffffffffc020432a:	000bb783          	ld	a5,0(s7)
ffffffffc020432e:	4585                	li	a1,1
ffffffffc0204330:	739c                	ld	a5,32(a5)
ffffffffc0204332:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0204334:	00093783          	ld	a5,0(s2)
ffffffffc0204338:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc020433c:	12000073          	sfence.vma
ffffffffc0204340:	100027f3          	csrr	a5,sstatus
ffffffffc0204344:	8b89                	andi	a5,a5,2
ffffffffc0204346:	0c079963          	bnez	a5,ffffffffc0204418 <pmm_init+0x624>
        ret = pmm_manager->nr_free_pages();
ffffffffc020434a:	000bb783          	ld	a5,0(s7)
ffffffffc020434e:	779c                	ld	a5,40(a5)
ffffffffc0204350:	9782                	jalr	a5
ffffffffc0204352:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0204354:	3a8c1563          	bne	s8,s0,ffffffffc02046fe <pmm_init+0x90a>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0204358:	00004517          	auipc	a0,0x4
ffffffffc020435c:	10850513          	addi	a0,a0,264 # ffffffffc0208460 <default_pmm_manager+0x598>
ffffffffc0204360:	d6dfb0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc0204364:	6446                	ld	s0,80(sp)
ffffffffc0204366:	60e6                	ld	ra,88(sp)
ffffffffc0204368:	64a6                	ld	s1,72(sp)
ffffffffc020436a:	6906                	ld	s2,64(sp)
ffffffffc020436c:	79e2                	ld	s3,56(sp)
ffffffffc020436e:	7a42                	ld	s4,48(sp)
ffffffffc0204370:	7aa2                	ld	s5,40(sp)
ffffffffc0204372:	7b02                	ld	s6,32(sp)
ffffffffc0204374:	6be2                	ld	s7,24(sp)
ffffffffc0204376:	6c42                	ld	s8,16(sp)
ffffffffc0204378:	6125                	addi	sp,sp,96
    kmalloc_init();
ffffffffc020437a:	93cfe06f          	j	ffffffffc02024b6 <kmalloc_init>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020437e:	6785                	lui	a5,0x1
ffffffffc0204380:	17fd                	addi	a5,a5,-1
ffffffffc0204382:	96be                	add	a3,a3,a5
ffffffffc0204384:	77fd                	lui	a5,0xfffff
ffffffffc0204386:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage) {
ffffffffc0204388:	00c7d693          	srli	a3,a5,0xc
ffffffffc020438c:	14c6f063          	bgeu	a3,a2,ffffffffc02044cc <pmm_init+0x6d8>
    pmm_manager->init_memmap(base, n);
ffffffffc0204390:	000bb603          	ld	a2,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc0204394:	96c2                	add	a3,a3,a6
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0204396:	40f707b3          	sub	a5,a4,a5
    pmm_manager->init_memmap(base, n);
ffffffffc020439a:	6a10                	ld	a2,16(a2)
ffffffffc020439c:	069a                	slli	a3,a3,0x6
ffffffffc020439e:	00c7d593          	srli	a1,a5,0xc
ffffffffc02043a2:	9536                	add	a0,a0,a3
ffffffffc02043a4:	9602                	jalr	a2
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc02043a6:	0009b583          	ld	a1,0(s3)
}
ffffffffc02043aa:	b63d                	j	ffffffffc0203ed8 <pmm_init+0xe4>
        intr_disable();
ffffffffc02043ac:	a9cfc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02043b0:	000bb783          	ld	a5,0(s7)
ffffffffc02043b4:	779c                	ld	a5,40(a5)
ffffffffc02043b6:	9782                	jalr	a5
ffffffffc02043b8:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02043ba:	a88fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc02043be:	bea5                	j	ffffffffc0203f36 <pmm_init+0x142>
        intr_disable();
ffffffffc02043c0:	a88fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc02043c4:	000bb783          	ld	a5,0(s7)
ffffffffc02043c8:	779c                	ld	a5,40(a5)
ffffffffc02043ca:	9782                	jalr	a5
ffffffffc02043cc:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc02043ce:	a74fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc02043d2:	b3cd                	j	ffffffffc02041b4 <pmm_init+0x3c0>
        intr_disable();
ffffffffc02043d4:	a74fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc02043d8:	000bb783          	ld	a5,0(s7)
ffffffffc02043dc:	779c                	ld	a5,40(a5)
ffffffffc02043de:	9782                	jalr	a5
ffffffffc02043e0:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc02043e2:	a60fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc02043e6:	b36d                	j	ffffffffc0204190 <pmm_init+0x39c>
ffffffffc02043e8:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02043ea:	a5efc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02043ee:	000bb783          	ld	a5,0(s7)
ffffffffc02043f2:	6522                	ld	a0,8(sp)
ffffffffc02043f4:	4585                	li	a1,1
ffffffffc02043f6:	739c                	ld	a5,32(a5)
ffffffffc02043f8:	9782                	jalr	a5
        intr_enable();
ffffffffc02043fa:	a48fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc02043fe:	bb8d                	j	ffffffffc0204170 <pmm_init+0x37c>
ffffffffc0204400:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0204402:	a46fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc0204406:	000bb783          	ld	a5,0(s7)
ffffffffc020440a:	6522                	ld	a0,8(sp)
ffffffffc020440c:	4585                	li	a1,1
ffffffffc020440e:	739c                	ld	a5,32(a5)
ffffffffc0204410:	9782                	jalr	a5
        intr_enable();
ffffffffc0204412:	a30fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0204416:	b32d                	j	ffffffffc0204140 <pmm_init+0x34c>
        intr_disable();
ffffffffc0204418:	a30fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc020441c:	000bb783          	ld	a5,0(s7)
ffffffffc0204420:	779c                	ld	a5,40(a5)
ffffffffc0204422:	9782                	jalr	a5
ffffffffc0204424:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0204426:	a1cfc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc020442a:	b72d                	j	ffffffffc0204354 <pmm_init+0x560>
ffffffffc020442c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020442e:	a1afc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0204432:	000bb783          	ld	a5,0(s7)
ffffffffc0204436:	6522                	ld	a0,8(sp)
ffffffffc0204438:	4585                	li	a1,1
ffffffffc020443a:	739c                	ld	a5,32(a5)
ffffffffc020443c:	9782                	jalr	a5
        intr_enable();
ffffffffc020443e:	a04fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0204442:	bdcd                	j	ffffffffc0204334 <pmm_init+0x540>
ffffffffc0204444:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0204446:	a02fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc020444a:	000bb783          	ld	a5,0(s7)
ffffffffc020444e:	6522                	ld	a0,8(sp)
ffffffffc0204450:	4585                	li	a1,1
ffffffffc0204452:	739c                	ld	a5,32(a5)
ffffffffc0204454:	9782                	jalr	a5
        intr_enable();
ffffffffc0204456:	9ecfc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc020445a:	b56d                	j	ffffffffc0204304 <pmm_init+0x510>
        intr_disable();
ffffffffc020445c:	9ecfc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc0204460:	000bb783          	ld	a5,0(s7)
ffffffffc0204464:	4585                	li	a1,1
ffffffffc0204466:	8556                	mv	a0,s5
ffffffffc0204468:	739c                	ld	a5,32(a5)
ffffffffc020446a:	9782                	jalr	a5
        intr_enable();
ffffffffc020446c:	9d6fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0204470:	b59d                	j	ffffffffc02042d6 <pmm_init+0x4e2>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0204472:	00004697          	auipc	a3,0x4
ffffffffc0204476:	e9e68693          	addi	a3,a3,-354 # ffffffffc0208310 <default_pmm_manager+0x448>
ffffffffc020447a:	00003617          	auipc	a2,0x3
ffffffffc020447e:	9ae60613          	addi	a2,a2,-1618 # ffffffffc0206e28 <commands+0x410>
ffffffffc0204482:	23200593          	li	a1,562
ffffffffc0204486:	00004517          	auipc	a0,0x4
ffffffffc020448a:	a7a50513          	addi	a0,a0,-1414 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc020448e:	d7bfb0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0204492:	00004697          	auipc	a3,0x4
ffffffffc0204496:	e3e68693          	addi	a3,a3,-450 # ffffffffc02082d0 <default_pmm_manager+0x408>
ffffffffc020449a:	00003617          	auipc	a2,0x3
ffffffffc020449e:	98e60613          	addi	a2,a2,-1650 # ffffffffc0206e28 <commands+0x410>
ffffffffc02044a2:	23100593          	li	a1,561
ffffffffc02044a6:	00004517          	auipc	a0,0x4
ffffffffc02044aa:	a5a50513          	addi	a0,a0,-1446 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc02044ae:	d5bfb0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc02044b2:	86a2                	mv	a3,s0
ffffffffc02044b4:	00003617          	auipc	a2,0x3
ffffffffc02044b8:	f4460613          	addi	a2,a2,-188 # ffffffffc02073f8 <commands+0x9e0>
ffffffffc02044bc:	23100593          	li	a1,561
ffffffffc02044c0:	00004517          	auipc	a0,0x4
ffffffffc02044c4:	a4050513          	addi	a0,a0,-1472 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc02044c8:	d41fb0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc02044cc:	854ff0ef          	jal	ra,ffffffffc0203520 <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02044d0:	00003617          	auipc	a2,0x3
ffffffffc02044d4:	49860613          	addi	a2,a2,1176 # ffffffffc0207968 <commands+0xf50>
ffffffffc02044d8:	07f00593          	li	a1,127
ffffffffc02044dc:	00004517          	auipc	a0,0x4
ffffffffc02044e0:	a2450513          	addi	a0,a0,-1500 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc02044e4:	d25fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02044e8:	00003617          	auipc	a2,0x3
ffffffffc02044ec:	48060613          	addi	a2,a2,1152 # ffffffffc0207968 <commands+0xf50>
ffffffffc02044f0:	0c100593          	li	a1,193
ffffffffc02044f4:	00004517          	auipc	a0,0x4
ffffffffc02044f8:	a0c50513          	addi	a0,a0,-1524 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc02044fc:	d0dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0204500:	00004697          	auipc	a3,0x4
ffffffffc0204504:	b0868693          	addi	a3,a3,-1272 # ffffffffc0208008 <default_pmm_manager+0x140>
ffffffffc0204508:	00003617          	auipc	a2,0x3
ffffffffc020450c:	92060613          	addi	a2,a2,-1760 # ffffffffc0206e28 <commands+0x410>
ffffffffc0204510:	1f500593          	li	a1,501
ffffffffc0204514:	00004517          	auipc	a0,0x4
ffffffffc0204518:	9ec50513          	addi	a0,a0,-1556 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc020451c:	cedfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0204520:	00004697          	auipc	a3,0x4
ffffffffc0204524:	ac868693          	addi	a3,a3,-1336 # ffffffffc0207fe8 <default_pmm_manager+0x120>
ffffffffc0204528:	00003617          	auipc	a2,0x3
ffffffffc020452c:	90060613          	addi	a2,a2,-1792 # ffffffffc0206e28 <commands+0x410>
ffffffffc0204530:	1f400593          	li	a1,500
ffffffffc0204534:	00004517          	auipc	a0,0x4
ffffffffc0204538:	9cc50513          	addi	a0,a0,-1588 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc020453c:	ccdfb0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0204540:	ffdfe0ef          	jal	ra,ffffffffc020353c <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0204544:	00004697          	auipc	a3,0x4
ffffffffc0204548:	b5468693          	addi	a3,a3,-1196 # ffffffffc0208098 <default_pmm_manager+0x1d0>
ffffffffc020454c:	00003617          	auipc	a2,0x3
ffffffffc0204550:	8dc60613          	addi	a2,a2,-1828 # ffffffffc0206e28 <commands+0x410>
ffffffffc0204554:	1fd00593          	li	a1,509
ffffffffc0204558:	00004517          	auipc	a0,0x4
ffffffffc020455c:	9a850513          	addi	a0,a0,-1624 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc0204560:	ca9fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0204564:	00004697          	auipc	a3,0x4
ffffffffc0204568:	b0468693          	addi	a3,a3,-1276 # ffffffffc0208068 <default_pmm_manager+0x1a0>
ffffffffc020456c:	00003617          	auipc	a2,0x3
ffffffffc0204570:	8bc60613          	addi	a2,a2,-1860 # ffffffffc0206e28 <commands+0x410>
ffffffffc0204574:	1fa00593          	li	a1,506
ffffffffc0204578:	00004517          	auipc	a0,0x4
ffffffffc020457c:	98850513          	addi	a0,a0,-1656 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc0204580:	c89fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0204584:	00004697          	auipc	a3,0x4
ffffffffc0204588:	abc68693          	addi	a3,a3,-1348 # ffffffffc0208040 <default_pmm_manager+0x178>
ffffffffc020458c:	00003617          	auipc	a2,0x3
ffffffffc0204590:	89c60613          	addi	a2,a2,-1892 # ffffffffc0206e28 <commands+0x410>
ffffffffc0204594:	1f600593          	li	a1,502
ffffffffc0204598:	00004517          	auipc	a0,0x4
ffffffffc020459c:	96850513          	addi	a0,a0,-1688 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc02045a0:	c69fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02045a4:	00004697          	auipc	a3,0x4
ffffffffc02045a8:	b7c68693          	addi	a3,a3,-1156 # ffffffffc0208120 <default_pmm_manager+0x258>
ffffffffc02045ac:	00003617          	auipc	a2,0x3
ffffffffc02045b0:	87c60613          	addi	a2,a2,-1924 # ffffffffc0206e28 <commands+0x410>
ffffffffc02045b4:	20600593          	li	a1,518
ffffffffc02045b8:	00004517          	auipc	a0,0x4
ffffffffc02045bc:	94850513          	addi	a0,a0,-1720 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc02045c0:	c49fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc02045c4:	00004697          	auipc	a3,0x4
ffffffffc02045c8:	bfc68693          	addi	a3,a3,-1028 # ffffffffc02081c0 <default_pmm_manager+0x2f8>
ffffffffc02045cc:	00003617          	auipc	a2,0x3
ffffffffc02045d0:	85c60613          	addi	a2,a2,-1956 # ffffffffc0206e28 <commands+0x410>
ffffffffc02045d4:	20b00593          	li	a1,523
ffffffffc02045d8:	00004517          	auipc	a0,0x4
ffffffffc02045dc:	92850513          	addi	a0,a0,-1752 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc02045e0:	c29fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02045e4:	00004697          	auipc	a3,0x4
ffffffffc02045e8:	b1468693          	addi	a3,a3,-1260 # ffffffffc02080f8 <default_pmm_manager+0x230>
ffffffffc02045ec:	00003617          	auipc	a2,0x3
ffffffffc02045f0:	83c60613          	addi	a2,a2,-1988 # ffffffffc0206e28 <commands+0x410>
ffffffffc02045f4:	20300593          	li	a1,515
ffffffffc02045f8:	00004517          	auipc	a0,0x4
ffffffffc02045fc:	90850513          	addi	a0,a0,-1784 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc0204600:	c09fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0204604:	86d6                	mv	a3,s5
ffffffffc0204606:	00003617          	auipc	a2,0x3
ffffffffc020460a:	df260613          	addi	a2,a2,-526 # ffffffffc02073f8 <commands+0x9e0>
ffffffffc020460e:	20200593          	li	a1,514
ffffffffc0204612:	00004517          	auipc	a0,0x4
ffffffffc0204616:	8ee50513          	addi	a0,a0,-1810 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc020461a:	beffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020461e:	00004697          	auipc	a3,0x4
ffffffffc0204622:	b3a68693          	addi	a3,a3,-1222 # ffffffffc0208158 <default_pmm_manager+0x290>
ffffffffc0204626:	00003617          	auipc	a2,0x3
ffffffffc020462a:	80260613          	addi	a2,a2,-2046 # ffffffffc0206e28 <commands+0x410>
ffffffffc020462e:	21000593          	li	a1,528
ffffffffc0204632:	00004517          	auipc	a0,0x4
ffffffffc0204636:	8ce50513          	addi	a0,a0,-1842 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc020463a:	bcffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020463e:	00004697          	auipc	a3,0x4
ffffffffc0204642:	be268693          	addi	a3,a3,-1054 # ffffffffc0208220 <default_pmm_manager+0x358>
ffffffffc0204646:	00002617          	auipc	a2,0x2
ffffffffc020464a:	7e260613          	addi	a2,a2,2018 # ffffffffc0206e28 <commands+0x410>
ffffffffc020464e:	20f00593          	li	a1,527
ffffffffc0204652:	00004517          	auipc	a0,0x4
ffffffffc0204656:	8ae50513          	addi	a0,a0,-1874 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc020465a:	baffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc020465e:	00004697          	auipc	a3,0x4
ffffffffc0204662:	baa68693          	addi	a3,a3,-1110 # ffffffffc0208208 <default_pmm_manager+0x340>
ffffffffc0204666:	00002617          	auipc	a2,0x2
ffffffffc020466a:	7c260613          	addi	a2,a2,1986 # ffffffffc0206e28 <commands+0x410>
ffffffffc020466e:	20e00593          	li	a1,526
ffffffffc0204672:	00004517          	auipc	a0,0x4
ffffffffc0204676:	88e50513          	addi	a0,a0,-1906 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc020467a:	b8ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc020467e:	00004697          	auipc	a3,0x4
ffffffffc0204682:	b5a68693          	addi	a3,a3,-1190 # ffffffffc02081d8 <default_pmm_manager+0x310>
ffffffffc0204686:	00002617          	auipc	a2,0x2
ffffffffc020468a:	7a260613          	addi	a2,a2,1954 # ffffffffc0206e28 <commands+0x410>
ffffffffc020468e:	20d00593          	li	a1,525
ffffffffc0204692:	00004517          	auipc	a0,0x4
ffffffffc0204696:	86e50513          	addi	a0,a0,-1938 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc020469a:	b6ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020469e:	00004697          	auipc	a3,0x4
ffffffffc02046a2:	cf268693          	addi	a3,a3,-782 # ffffffffc0208390 <default_pmm_manager+0x4c8>
ffffffffc02046a6:	00002617          	auipc	a2,0x2
ffffffffc02046aa:	78260613          	addi	a2,a2,1922 # ffffffffc0206e28 <commands+0x410>
ffffffffc02046ae:	23c00593          	li	a1,572
ffffffffc02046b2:	00004517          	auipc	a0,0x4
ffffffffc02046b6:	84e50513          	addi	a0,a0,-1970 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc02046ba:	b4ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02046be:	00004697          	auipc	a3,0x4
ffffffffc02046c2:	aea68693          	addi	a3,a3,-1302 # ffffffffc02081a8 <default_pmm_manager+0x2e0>
ffffffffc02046c6:	00002617          	auipc	a2,0x2
ffffffffc02046ca:	76260613          	addi	a2,a2,1890 # ffffffffc0206e28 <commands+0x410>
ffffffffc02046ce:	20a00593          	li	a1,522
ffffffffc02046d2:	00004517          	auipc	a0,0x4
ffffffffc02046d6:	82e50513          	addi	a0,a0,-2002 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc02046da:	b2ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(*ptep & PTE_W);
ffffffffc02046de:	00004697          	auipc	a3,0x4
ffffffffc02046e2:	aba68693          	addi	a3,a3,-1350 # ffffffffc0208198 <default_pmm_manager+0x2d0>
ffffffffc02046e6:	00002617          	auipc	a2,0x2
ffffffffc02046ea:	74260613          	addi	a2,a2,1858 # ffffffffc0206e28 <commands+0x410>
ffffffffc02046ee:	20900593          	li	a1,521
ffffffffc02046f2:	00004517          	auipc	a0,0x4
ffffffffc02046f6:	80e50513          	addi	a0,a0,-2034 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc02046fa:	b0ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02046fe:	00004697          	auipc	a3,0x4
ffffffffc0204702:	b9268693          	addi	a3,a3,-1134 # ffffffffc0208290 <default_pmm_manager+0x3c8>
ffffffffc0204706:	00002617          	auipc	a2,0x2
ffffffffc020470a:	72260613          	addi	a2,a2,1826 # ffffffffc0206e28 <commands+0x410>
ffffffffc020470e:	24d00593          	li	a1,589
ffffffffc0204712:	00003517          	auipc	a0,0x3
ffffffffc0204716:	7ee50513          	addi	a0,a0,2030 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc020471a:	aeffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(*ptep & PTE_U);
ffffffffc020471e:	00004697          	auipc	a3,0x4
ffffffffc0204722:	a6a68693          	addi	a3,a3,-1430 # ffffffffc0208188 <default_pmm_manager+0x2c0>
ffffffffc0204726:	00002617          	auipc	a2,0x2
ffffffffc020472a:	70260613          	addi	a2,a2,1794 # ffffffffc0206e28 <commands+0x410>
ffffffffc020472e:	20800593          	li	a1,520
ffffffffc0204732:	00003517          	auipc	a0,0x3
ffffffffc0204736:	7ce50513          	addi	a0,a0,1998 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc020473a:	acffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020473e:	00004697          	auipc	a3,0x4
ffffffffc0204742:	9a268693          	addi	a3,a3,-1630 # ffffffffc02080e0 <default_pmm_manager+0x218>
ffffffffc0204746:	00002617          	auipc	a2,0x2
ffffffffc020474a:	6e260613          	addi	a2,a2,1762 # ffffffffc0206e28 <commands+0x410>
ffffffffc020474e:	21500593          	li	a1,533
ffffffffc0204752:	00003517          	auipc	a0,0x3
ffffffffc0204756:	7ae50513          	addi	a0,a0,1966 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc020475a:	aaffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc020475e:	00004697          	auipc	a3,0x4
ffffffffc0204762:	ada68693          	addi	a3,a3,-1318 # ffffffffc0208238 <default_pmm_manager+0x370>
ffffffffc0204766:	00002617          	auipc	a2,0x2
ffffffffc020476a:	6c260613          	addi	a2,a2,1730 # ffffffffc0206e28 <commands+0x410>
ffffffffc020476e:	21200593          	li	a1,530
ffffffffc0204772:	00003517          	auipc	a0,0x3
ffffffffc0204776:	78e50513          	addi	a0,a0,1934 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc020477a:	a8ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020477e:	00004697          	auipc	a3,0x4
ffffffffc0204782:	94a68693          	addi	a3,a3,-1718 # ffffffffc02080c8 <default_pmm_manager+0x200>
ffffffffc0204786:	00002617          	auipc	a2,0x2
ffffffffc020478a:	6a260613          	addi	a2,a2,1698 # ffffffffc0206e28 <commands+0x410>
ffffffffc020478e:	21100593          	li	a1,529
ffffffffc0204792:	00003517          	auipc	a0,0x3
ffffffffc0204796:	76e50513          	addi	a0,a0,1902 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc020479a:	a6ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc020479e:	00003617          	auipc	a2,0x3
ffffffffc02047a2:	c5a60613          	addi	a2,a2,-934 # ffffffffc02073f8 <commands+0x9e0>
ffffffffc02047a6:	06900593          	li	a1,105
ffffffffc02047aa:	00003517          	auipc	a0,0x3
ffffffffc02047ae:	9be50513          	addi	a0,a0,-1602 # ffffffffc0207168 <commands+0x750>
ffffffffc02047b2:	a57fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02047b6:	00004697          	auipc	a3,0x4
ffffffffc02047ba:	ab268693          	addi	a3,a3,-1358 # ffffffffc0208268 <default_pmm_manager+0x3a0>
ffffffffc02047be:	00002617          	auipc	a2,0x2
ffffffffc02047c2:	66a60613          	addi	a2,a2,1642 # ffffffffc0206e28 <commands+0x410>
ffffffffc02047c6:	21c00593          	li	a1,540
ffffffffc02047ca:	00003517          	auipc	a0,0x3
ffffffffc02047ce:	73650513          	addi	a0,a0,1846 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc02047d2:	a37fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02047d6:	00004697          	auipc	a3,0x4
ffffffffc02047da:	a4a68693          	addi	a3,a3,-1462 # ffffffffc0208220 <default_pmm_manager+0x358>
ffffffffc02047de:	00002617          	auipc	a2,0x2
ffffffffc02047e2:	64a60613          	addi	a2,a2,1610 # ffffffffc0206e28 <commands+0x410>
ffffffffc02047e6:	21a00593          	li	a1,538
ffffffffc02047ea:	00003517          	auipc	a0,0x3
ffffffffc02047ee:	71650513          	addi	a0,a0,1814 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc02047f2:	a17fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02047f6:	00004697          	auipc	a3,0x4
ffffffffc02047fa:	a5a68693          	addi	a3,a3,-1446 # ffffffffc0208250 <default_pmm_manager+0x388>
ffffffffc02047fe:	00002617          	auipc	a2,0x2
ffffffffc0204802:	62a60613          	addi	a2,a2,1578 # ffffffffc0206e28 <commands+0x410>
ffffffffc0204806:	21900593          	li	a1,537
ffffffffc020480a:	00003517          	auipc	a0,0x3
ffffffffc020480e:	6f650513          	addi	a0,a0,1782 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc0204812:	9f7fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0204816:	00004697          	auipc	a3,0x4
ffffffffc020481a:	a0a68693          	addi	a3,a3,-1526 # ffffffffc0208220 <default_pmm_manager+0x358>
ffffffffc020481e:	00002617          	auipc	a2,0x2
ffffffffc0204822:	60a60613          	addi	a2,a2,1546 # ffffffffc0206e28 <commands+0x410>
ffffffffc0204826:	21600593          	li	a1,534
ffffffffc020482a:	00003517          	auipc	a0,0x3
ffffffffc020482e:	6d650513          	addi	a0,a0,1750 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc0204832:	9d7fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0204836:	00004697          	auipc	a3,0x4
ffffffffc020483a:	b4268693          	addi	a3,a3,-1214 # ffffffffc0208378 <default_pmm_manager+0x4b0>
ffffffffc020483e:	00002617          	auipc	a2,0x2
ffffffffc0204842:	5ea60613          	addi	a2,a2,1514 # ffffffffc0206e28 <commands+0x410>
ffffffffc0204846:	23b00593          	li	a1,571
ffffffffc020484a:	00003517          	auipc	a0,0x3
ffffffffc020484e:	6b650513          	addi	a0,a0,1718 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc0204852:	9b7fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0204856:	00004697          	auipc	a3,0x4
ffffffffc020485a:	aea68693          	addi	a3,a3,-1302 # ffffffffc0208340 <default_pmm_manager+0x478>
ffffffffc020485e:	00002617          	auipc	a2,0x2
ffffffffc0204862:	5ca60613          	addi	a2,a2,1482 # ffffffffc0206e28 <commands+0x410>
ffffffffc0204866:	23a00593          	li	a1,570
ffffffffc020486a:	00003517          	auipc	a0,0x3
ffffffffc020486e:	69650513          	addi	a0,a0,1686 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc0204872:	997fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0204876:	00004697          	auipc	a3,0x4
ffffffffc020487a:	ab268693          	addi	a3,a3,-1358 # ffffffffc0208328 <default_pmm_manager+0x460>
ffffffffc020487e:	00002617          	auipc	a2,0x2
ffffffffc0204882:	5aa60613          	addi	a2,a2,1450 # ffffffffc0206e28 <commands+0x410>
ffffffffc0204886:	23600593          	li	a1,566
ffffffffc020488a:	00003517          	auipc	a0,0x3
ffffffffc020488e:	67650513          	addi	a0,a0,1654 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc0204892:	977fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0204896:	00004697          	auipc	a3,0x4
ffffffffc020489a:	9fa68693          	addi	a3,a3,-1542 # ffffffffc0208290 <default_pmm_manager+0x3c8>
ffffffffc020489e:	00002617          	auipc	a2,0x2
ffffffffc02048a2:	58a60613          	addi	a2,a2,1418 # ffffffffc0206e28 <commands+0x410>
ffffffffc02048a6:	22400593          	li	a1,548
ffffffffc02048aa:	00003517          	auipc	a0,0x3
ffffffffc02048ae:	65650513          	addi	a0,a0,1622 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc02048b2:	957fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02048b6:	00004697          	auipc	a3,0x4
ffffffffc02048ba:	81268693          	addi	a3,a3,-2030 # ffffffffc02080c8 <default_pmm_manager+0x200>
ffffffffc02048be:	00002617          	auipc	a2,0x2
ffffffffc02048c2:	56a60613          	addi	a2,a2,1386 # ffffffffc0206e28 <commands+0x410>
ffffffffc02048c6:	1fe00593          	li	a1,510
ffffffffc02048ca:	00003517          	auipc	a0,0x3
ffffffffc02048ce:	63650513          	addi	a0,a0,1590 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc02048d2:	937fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02048d6:	00003617          	auipc	a2,0x3
ffffffffc02048da:	b2260613          	addi	a2,a2,-1246 # ffffffffc02073f8 <commands+0x9e0>
ffffffffc02048de:	20100593          	li	a1,513
ffffffffc02048e2:	00003517          	auipc	a0,0x3
ffffffffc02048e6:	61e50513          	addi	a0,a0,1566 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc02048ea:	91ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02048ee:	00003697          	auipc	a3,0x3
ffffffffc02048f2:	7f268693          	addi	a3,a3,2034 # ffffffffc02080e0 <default_pmm_manager+0x218>
ffffffffc02048f6:	00002617          	auipc	a2,0x2
ffffffffc02048fa:	53260613          	addi	a2,a2,1330 # ffffffffc0206e28 <commands+0x410>
ffffffffc02048fe:	1ff00593          	li	a1,511
ffffffffc0204902:	00003517          	auipc	a0,0x3
ffffffffc0204906:	5fe50513          	addi	a0,a0,1534 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc020490a:	8fffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020490e:	00004697          	auipc	a3,0x4
ffffffffc0204912:	84a68693          	addi	a3,a3,-1974 # ffffffffc0208158 <default_pmm_manager+0x290>
ffffffffc0204916:	00002617          	auipc	a2,0x2
ffffffffc020491a:	51260613          	addi	a2,a2,1298 # ffffffffc0206e28 <commands+0x410>
ffffffffc020491e:	20700593          	li	a1,519
ffffffffc0204922:	00003517          	auipc	a0,0x3
ffffffffc0204926:	5de50513          	addi	a0,a0,1502 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc020492a:	8dffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020492e:	00004697          	auipc	a3,0x4
ffffffffc0204932:	b0a68693          	addi	a3,a3,-1270 # ffffffffc0208438 <default_pmm_manager+0x570>
ffffffffc0204936:	00002617          	auipc	a2,0x2
ffffffffc020493a:	4f260613          	addi	a2,a2,1266 # ffffffffc0206e28 <commands+0x410>
ffffffffc020493e:	24400593          	li	a1,580
ffffffffc0204942:	00003517          	auipc	a0,0x3
ffffffffc0204946:	5be50513          	addi	a0,a0,1470 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc020494a:	8bffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020494e:	00004697          	auipc	a3,0x4
ffffffffc0204952:	ab268693          	addi	a3,a3,-1358 # ffffffffc0208400 <default_pmm_manager+0x538>
ffffffffc0204956:	00002617          	auipc	a2,0x2
ffffffffc020495a:	4d260613          	addi	a2,a2,1234 # ffffffffc0206e28 <commands+0x410>
ffffffffc020495e:	24100593          	li	a1,577
ffffffffc0204962:	00003517          	auipc	a0,0x3
ffffffffc0204966:	59e50513          	addi	a0,a0,1438 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc020496a:	89ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p) == 2);
ffffffffc020496e:	00004697          	auipc	a3,0x4
ffffffffc0204972:	a6268693          	addi	a3,a3,-1438 # ffffffffc02083d0 <default_pmm_manager+0x508>
ffffffffc0204976:	00002617          	auipc	a2,0x2
ffffffffc020497a:	4b260613          	addi	a2,a2,1202 # ffffffffc0206e28 <commands+0x410>
ffffffffc020497e:	23d00593          	li	a1,573
ffffffffc0204982:	00003517          	auipc	a0,0x3
ffffffffc0204986:	57e50513          	addi	a0,a0,1406 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc020498a:	87ffb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020498e <copy_range>:
               bool share) {
ffffffffc020498e:	7119                	addi	sp,sp,-128
ffffffffc0204990:	f4a6                	sd	s1,104(sp)
ffffffffc0204992:	84b6                	mv	s1,a3
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0204994:	8ed1                	or	a3,a3,a2
               bool share) {
ffffffffc0204996:	fc86                	sd	ra,120(sp)
ffffffffc0204998:	f8a2                	sd	s0,112(sp)
ffffffffc020499a:	f0ca                	sd	s2,96(sp)
ffffffffc020499c:	ecce                	sd	s3,88(sp)
ffffffffc020499e:	e8d2                	sd	s4,80(sp)
ffffffffc02049a0:	e4d6                	sd	s5,72(sp)
ffffffffc02049a2:	e0da                	sd	s6,64(sp)
ffffffffc02049a4:	fc5e                	sd	s7,56(sp)
ffffffffc02049a6:	f862                	sd	s8,48(sp)
ffffffffc02049a8:	f466                	sd	s9,40(sp)
ffffffffc02049aa:	f06a                	sd	s10,32(sp)
ffffffffc02049ac:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02049ae:	16d2                	slli	a3,a3,0x34
               bool share) {
ffffffffc02049b0:	e43a                	sd	a4,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02049b2:	26069b63          	bnez	a3,ffffffffc0204c28 <copy_range+0x29a>
    assert(USER_ACCESS(start, end));
ffffffffc02049b6:	00200737          	lui	a4,0x200
ffffffffc02049ba:	8d32                	mv	s10,a2
ffffffffc02049bc:	1ce66e63          	bltu	a2,a4,ffffffffc0204b98 <copy_range+0x20a>
ffffffffc02049c0:	1c967c63          	bgeu	a2,s1,ffffffffc0204b98 <copy_range+0x20a>
ffffffffc02049c4:	4705                	li	a4,1
ffffffffc02049c6:	077e                	slli	a4,a4,0x1f
ffffffffc02049c8:	1c976863          	bltu	a4,s1,ffffffffc0204b98 <copy_range+0x20a>
ffffffffc02049cc:	5afd                	li	s5,-1
ffffffffc02049ce:	8a2a                	mv	s4,a0
ffffffffc02049d0:	842e                	mv	s0,a1
        start += PGSIZE;
ffffffffc02049d2:	6985                	lui	s3,0x1
    if (PPN(pa) >= npage) {
ffffffffc02049d4:	000aec17          	auipc	s8,0xae
ffffffffc02049d8:	f2cc0c13          	addi	s8,s8,-212 # ffffffffc02b2900 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02049dc:	000aeb97          	auipc	s7,0xae
ffffffffc02049e0:	f2cb8b93          	addi	s7,s7,-212 # ffffffffc02b2908 <pages>
    return KADDR(page2pa(page));
ffffffffc02049e4:	00cada93          	srli	s5,s5,0xc
ffffffffc02049e8:	000aec97          	auipc	s9,0xae
ffffffffc02049ec:	f30c8c93          	addi	s9,s9,-208 # ffffffffc02b2918 <va_pa_offset>
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc02049f0:	4601                	li	a2,0
ffffffffc02049f2:	85ea                	mv	a1,s10
ffffffffc02049f4:	8522                	mv	a0,s0
ffffffffc02049f6:	c6ffe0ef          	jal	ra,ffffffffc0203664 <get_pte>
ffffffffc02049fa:	892a                	mv	s2,a0
        if (ptep == NULL) {
ffffffffc02049fc:	c969                	beqz	a0,ffffffffc0204ace <copy_range+0x140>
        if (*ptep & PTE_V) {
ffffffffc02049fe:	6118                	ld	a4,0(a0)
ffffffffc0204a00:	8b05                	andi	a4,a4,1
ffffffffc0204a02:	e705                	bnez	a4,ffffffffc0204a2a <copy_range+0x9c>
        start += PGSIZE;
ffffffffc0204a04:	9d4e                	add	s10,s10,s3
    } while (start != 0 && start < end);
ffffffffc0204a06:	fe9d65e3          	bltu	s10,s1,ffffffffc02049f0 <copy_range+0x62>
    return 0;
ffffffffc0204a0a:	4501                	li	a0,0
}
ffffffffc0204a0c:	70e6                	ld	ra,120(sp)
ffffffffc0204a0e:	7446                	ld	s0,112(sp)
ffffffffc0204a10:	74a6                	ld	s1,104(sp)
ffffffffc0204a12:	7906                	ld	s2,96(sp)
ffffffffc0204a14:	69e6                	ld	s3,88(sp)
ffffffffc0204a16:	6a46                	ld	s4,80(sp)
ffffffffc0204a18:	6aa6                	ld	s5,72(sp)
ffffffffc0204a1a:	6b06                	ld	s6,64(sp)
ffffffffc0204a1c:	7be2                	ld	s7,56(sp)
ffffffffc0204a1e:	7c42                	ld	s8,48(sp)
ffffffffc0204a20:	7ca2                	ld	s9,40(sp)
ffffffffc0204a22:	7d02                	ld	s10,32(sp)
ffffffffc0204a24:	6de2                	ld	s11,24(sp)
ffffffffc0204a26:	6109                	addi	sp,sp,128
ffffffffc0204a28:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL) {
ffffffffc0204a2a:	4605                	li	a2,1
ffffffffc0204a2c:	85ea                	mv	a1,s10
ffffffffc0204a2e:	8552                	mv	a0,s4
ffffffffc0204a30:	c35fe0ef          	jal	ra,ffffffffc0203664 <get_pte>
ffffffffc0204a34:	14050363          	beqz	a0,ffffffffc0204b7a <copy_range+0x1ec>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc0204a38:	00093703          	ld	a4,0(s2)
    if (!(pte & PTE_V)) {
ffffffffc0204a3c:	00177693          	andi	a3,a4,1
ffffffffc0204a40:	0007091b          	sext.w	s2,a4
ffffffffc0204a44:	1a068663          	beqz	a3,ffffffffc0204bf0 <copy_range+0x262>
    if (PPN(pa) >= npage) {
ffffffffc0204a48:	000c3683          	ld	a3,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0204a4c:	070a                	slli	a4,a4,0x2
ffffffffc0204a4e:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204a50:	16d77463          	bgeu	a4,a3,ffffffffc0204bb8 <copy_range+0x22a>
    return &pages[PPN(pa) - nbase];
ffffffffc0204a54:	000bb803          	ld	a6,0(s7)
ffffffffc0204a58:	fff807b7          	lui	a5,0xfff80
ffffffffc0204a5c:	973e                	add	a4,a4,a5
ffffffffc0204a5e:	071a                	slli	a4,a4,0x6
ffffffffc0204a60:	00e80b33          	add	s6,a6,a4
            assert(page != NULL);
ffffffffc0204a64:	1a0b0263          	beqz	s6,ffffffffc0204c08 <copy_range+0x27a>
             if(share){
ffffffffc0204a68:	67a2                	ld	a5,8(sp)
ffffffffc0204a6a:	cfbd                	beqz	a5,ffffffffc0204ae8 <copy_range+0x15a>
    return page - pages + nbase;
ffffffffc0204a6c:	8719                	srai	a4,a4,0x6
ffffffffc0204a6e:	000807b7          	lui	a5,0x80
ffffffffc0204a72:	973e                	add	a4,a4,a5
    return KADDR(page2pa(page));
ffffffffc0204a74:	01577633          	and	a2,a4,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204a78:	0732                	slli	a4,a4,0xc
    return KADDR(page2pa(page));
ffffffffc0204a7a:	10d67263          	bgeu	a2,a3,ffffffffc0204b7e <copy_range+0x1f0>
ffffffffc0204a7e:	000cb583          	ld	a1,0(s9)
                cprintf("Sharing the page 0x%x\n", page2kva(page));
ffffffffc0204a82:	00004517          	auipc	a0,0x4
ffffffffc0204a86:	a0e50513          	addi	a0,a0,-1522 # ffffffffc0208490 <default_pmm_manager+0x5c8>
                page_insert(from, page, start, perm & (~PTE_W));
ffffffffc0204a8a:	01b97913          	andi	s2,s2,27
                cprintf("Sharing the page 0x%x\n", page2kva(page));
ffffffffc0204a8e:	95ba                	add	a1,a1,a4
ffffffffc0204a90:	e3cfb0ef          	jal	ra,ffffffffc02000cc <cprintf>
                page_insert(from, page, start, perm & (~PTE_W));
ffffffffc0204a94:	86ca                	mv	a3,s2
ffffffffc0204a96:	866a                	mv	a2,s10
ffffffffc0204a98:	85da                	mv	a1,s6
ffffffffc0204a9a:	8522                	mv	a0,s0
ffffffffc0204a9c:	a62ff0ef          	jal	ra,ffffffffc0203cfe <page_insert>
                ret = page_insert(to, page, start, perm & (~PTE_W));
ffffffffc0204aa0:	86ca                	mv	a3,s2
ffffffffc0204aa2:	866a                	mv	a2,s10
ffffffffc0204aa4:	85da                	mv	a1,s6
ffffffffc0204aa6:	8552                	mv	a0,s4
ffffffffc0204aa8:	a56ff0ef          	jal	ra,ffffffffc0203cfe <page_insert>
            assert(ret == 0);
ffffffffc0204aac:	dd21                	beqz	a0,ffffffffc0204a04 <copy_range+0x76>
ffffffffc0204aae:	00004697          	auipc	a3,0x4
ffffffffc0204ab2:	a2268693          	addi	a3,a3,-1502 # ffffffffc02084d0 <default_pmm_manager+0x608>
ffffffffc0204ab6:	00002617          	auipc	a2,0x2
ffffffffc0204aba:	37260613          	addi	a2,a2,882 # ffffffffc0206e28 <commands+0x410>
ffffffffc0204abe:	19600593          	li	a1,406
ffffffffc0204ac2:	00003517          	auipc	a0,0x3
ffffffffc0204ac6:	43e50513          	addi	a0,a0,1086 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc0204aca:	f3efb0ef          	jal	ra,ffffffffc0200208 <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0204ace:	00200637          	lui	a2,0x200
ffffffffc0204ad2:	00cd07b3          	add	a5,s10,a2
ffffffffc0204ad6:	ffe00637          	lui	a2,0xffe00
ffffffffc0204ada:	00c7fd33          	and	s10,a5,a2
    } while (start != 0 && start < end);
ffffffffc0204ade:	f20d06e3          	beqz	s10,ffffffffc0204a0a <copy_range+0x7c>
ffffffffc0204ae2:	f09d67e3          	bltu	s10,s1,ffffffffc02049f0 <copy_range+0x62>
ffffffffc0204ae6:	b715                	j	ffffffffc0204a0a <copy_range+0x7c>
                struct Page *npage = alloc_page();
ffffffffc0204ae8:	4505                	li	a0,1
ffffffffc0204aea:	a6ffe0ef          	jal	ra,ffffffffc0203558 <alloc_pages>
ffffffffc0204aee:	8daa                	mv	s11,a0
                assert(npage != NULL);
ffffffffc0204af0:	c165                	beqz	a0,ffffffffc0204bd0 <copy_range+0x242>
    return page - pages + nbase;
ffffffffc0204af2:	000bb683          	ld	a3,0(s7)
ffffffffc0204af6:	000807b7          	lui	a5,0x80
    return KADDR(page2pa(page));
ffffffffc0204afa:	000c3703          	ld	a4,0(s8)
    return page - pages + nbase;
ffffffffc0204afe:	40d506b3          	sub	a3,a0,a3
ffffffffc0204b02:	8699                	srai	a3,a3,0x6
ffffffffc0204b04:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204b06:	0156f633          	and	a2,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204b0a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204b0c:	06e67a63          	bgeu	a2,a4,ffffffffc0204b80 <copy_range+0x1f2>
ffffffffc0204b10:	000cb583          	ld	a1,0(s9)
                cprintf("alloc a new page 0x%x\n", page2kva(npage));
ffffffffc0204b14:	00004517          	auipc	a0,0x4
ffffffffc0204b18:	9a450513          	addi	a0,a0,-1628 # ffffffffc02084b8 <default_pmm_manager+0x5f0>
ffffffffc0204b1c:	95b6                	add	a1,a1,a3
ffffffffc0204b1e:	daefb0ef          	jal	ra,ffffffffc02000cc <cprintf>
    return page - pages + nbase;
ffffffffc0204b22:	000bb703          	ld	a4,0(s7)
ffffffffc0204b26:	000807b7          	lui	a5,0x80
    return KADDR(page2pa(page));
ffffffffc0204b2a:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc0204b2e:	40eb06b3          	sub	a3,s6,a4
ffffffffc0204b32:	8699                	srai	a3,a3,0x6
ffffffffc0204b34:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204b36:	0156f5b3          	and	a1,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204b3a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204b3c:	04c5f263          	bgeu	a1,a2,ffffffffc0204b80 <copy_range+0x1f2>
    return page - pages + nbase;
ffffffffc0204b40:	40ed8733          	sub	a4,s11,a4
    return KADDR(page2pa(page));
ffffffffc0204b44:	000cb503          	ld	a0,0(s9)
    return page - pages + nbase;
ffffffffc0204b48:	8719                	srai	a4,a4,0x6
ffffffffc0204b4a:	000807b7          	lui	a5,0x80
ffffffffc0204b4e:	973e                	add	a4,a4,a5
    return KADDR(page2pa(page));
ffffffffc0204b50:	01577833          	and	a6,a4,s5
ffffffffc0204b54:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0204b58:	0732                	slli	a4,a4,0xc
    return KADDR(page2pa(page));
ffffffffc0204b5a:	02c87263          	bgeu	a6,a2,ffffffffc0204b7e <copy_range+0x1f0>
                memcpy(kva_dst, kva_src, PGSIZE);
ffffffffc0204b5e:	6605                	lui	a2,0x1
ffffffffc0204b60:	953a                	add	a0,a0,a4
ffffffffc0204b62:	7f2010ef          	jal	ra,ffffffffc0206354 <memcpy>
                ret = page_insert(to, npage, start, perm);
ffffffffc0204b66:	01f97693          	andi	a3,s2,31
ffffffffc0204b6a:	866a                	mv	a2,s10
ffffffffc0204b6c:	85ee                	mv	a1,s11
ffffffffc0204b6e:	8552                	mv	a0,s4
ffffffffc0204b70:	98eff0ef          	jal	ra,ffffffffc0203cfe <page_insert>
            assert(ret == 0);
ffffffffc0204b74:	e80508e3          	beqz	a0,ffffffffc0204a04 <copy_range+0x76>
ffffffffc0204b78:	bf1d                	j	ffffffffc0204aae <copy_range+0x120>
                return -E_NO_MEM;
ffffffffc0204b7a:	5571                	li	a0,-4
ffffffffc0204b7c:	bd41                	j	ffffffffc0204a0c <copy_range+0x7e>
ffffffffc0204b7e:	86ba                	mv	a3,a4
ffffffffc0204b80:	00003617          	auipc	a2,0x3
ffffffffc0204b84:	87860613          	addi	a2,a2,-1928 # ffffffffc02073f8 <commands+0x9e0>
ffffffffc0204b88:	06900593          	li	a1,105
ffffffffc0204b8c:	00002517          	auipc	a0,0x2
ffffffffc0204b90:	5dc50513          	addi	a0,a0,1500 # ffffffffc0207168 <commands+0x750>
ffffffffc0204b94:	e74fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0204b98:	00003697          	auipc	a3,0x3
ffffffffc0204b9c:	3a868693          	addi	a3,a3,936 # ffffffffc0207f40 <default_pmm_manager+0x78>
ffffffffc0204ba0:	00002617          	auipc	a2,0x2
ffffffffc0204ba4:	28860613          	addi	a2,a2,648 # ffffffffc0206e28 <commands+0x410>
ffffffffc0204ba8:	15e00593          	li	a1,350
ffffffffc0204bac:	00003517          	auipc	a0,0x3
ffffffffc0204bb0:	35450513          	addi	a0,a0,852 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc0204bb4:	e54fb0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204bb8:	00002617          	auipc	a2,0x2
ffffffffc0204bbc:	59060613          	addi	a2,a2,1424 # ffffffffc0207148 <commands+0x730>
ffffffffc0204bc0:	06200593          	li	a1,98
ffffffffc0204bc4:	00002517          	auipc	a0,0x2
ffffffffc0204bc8:	5a450513          	addi	a0,a0,1444 # ffffffffc0207168 <commands+0x750>
ffffffffc0204bcc:	e3cfb0ef          	jal	ra,ffffffffc0200208 <__panic>
                assert(npage != NULL);
ffffffffc0204bd0:	00004697          	auipc	a3,0x4
ffffffffc0204bd4:	8d868693          	addi	a3,a3,-1832 # ffffffffc02084a8 <default_pmm_manager+0x5e0>
ffffffffc0204bd8:	00002617          	auipc	a2,0x2
ffffffffc0204bdc:	25060613          	addi	a2,a2,592 # ffffffffc0206e28 <commands+0x410>
ffffffffc0204be0:	18a00593          	li	a1,394
ffffffffc0204be4:	00003517          	auipc	a0,0x3
ffffffffc0204be8:	31c50513          	addi	a0,a0,796 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc0204bec:	e1cfb0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0204bf0:	00003617          	auipc	a2,0x3
ffffffffc0204bf4:	93860613          	addi	a2,a2,-1736 # ffffffffc0207528 <commands+0xb10>
ffffffffc0204bf8:	07400593          	li	a1,116
ffffffffc0204bfc:	00002517          	auipc	a0,0x2
ffffffffc0204c00:	56c50513          	addi	a0,a0,1388 # ffffffffc0207168 <commands+0x750>
ffffffffc0204c04:	e04fb0ef          	jal	ra,ffffffffc0200208 <__panic>
            assert(page != NULL);
ffffffffc0204c08:	00004697          	auipc	a3,0x4
ffffffffc0204c0c:	87868693          	addi	a3,a3,-1928 # ffffffffc0208480 <default_pmm_manager+0x5b8>
ffffffffc0204c10:	00002617          	auipc	a2,0x2
ffffffffc0204c14:	21860613          	addi	a2,a2,536 # ffffffffc0206e28 <commands+0x410>
ffffffffc0204c18:	17000593          	li	a1,368
ffffffffc0204c1c:	00003517          	auipc	a0,0x3
ffffffffc0204c20:	2e450513          	addi	a0,a0,740 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc0204c24:	de4fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0204c28:	00003697          	auipc	a3,0x3
ffffffffc0204c2c:	2e868693          	addi	a3,a3,744 # ffffffffc0207f10 <default_pmm_manager+0x48>
ffffffffc0204c30:	00002617          	auipc	a2,0x2
ffffffffc0204c34:	1f860613          	addi	a2,a2,504 # ffffffffc0206e28 <commands+0x410>
ffffffffc0204c38:	15d00593          	li	a1,349
ffffffffc0204c3c:	00003517          	auipc	a0,0x3
ffffffffc0204c40:	2c450513          	addi	a0,a0,708 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc0204c44:	dc4fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204c48 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0204c48:	12058073          	sfence.vma	a1
}
ffffffffc0204c4c:	8082                	ret

ffffffffc0204c4e <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0204c4e:	7179                	addi	sp,sp,-48
ffffffffc0204c50:	e84a                	sd	s2,16(sp)
ffffffffc0204c52:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0204c54:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0204c56:	f022                	sd	s0,32(sp)
ffffffffc0204c58:	ec26                	sd	s1,24(sp)
ffffffffc0204c5a:	e44e                	sd	s3,8(sp)
ffffffffc0204c5c:	f406                	sd	ra,40(sp)
ffffffffc0204c5e:	84ae                	mv	s1,a1
ffffffffc0204c60:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0204c62:	8f7fe0ef          	jal	ra,ffffffffc0203558 <alloc_pages>
ffffffffc0204c66:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0204c68:	cd05                	beqz	a0,ffffffffc0204ca0 <pgdir_alloc_page+0x52>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0204c6a:	85aa                	mv	a1,a0
ffffffffc0204c6c:	86ce                	mv	a3,s3
ffffffffc0204c6e:	8626                	mv	a2,s1
ffffffffc0204c70:	854a                	mv	a0,s2
ffffffffc0204c72:	88cff0ef          	jal	ra,ffffffffc0203cfe <page_insert>
ffffffffc0204c76:	ed0d                	bnez	a0,ffffffffc0204cb0 <pgdir_alloc_page+0x62>
        if (swap_init_ok) {
ffffffffc0204c78:	000ae797          	auipc	a5,0xae
ffffffffc0204c7c:	c687a783          	lw	a5,-920(a5) # ffffffffc02b28e0 <swap_init_ok>
ffffffffc0204c80:	c385                	beqz	a5,ffffffffc0204ca0 <pgdir_alloc_page+0x52>
            if (check_mm_struct != NULL) {
ffffffffc0204c82:	000ae517          	auipc	a0,0xae
ffffffffc0204c86:	c3e53503          	ld	a0,-962(a0) # ffffffffc02b28c0 <check_mm_struct>
ffffffffc0204c8a:	c919                	beqz	a0,ffffffffc0204ca0 <pgdir_alloc_page+0x52>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0204c8c:	4681                	li	a3,0
ffffffffc0204c8e:	8622                	mv	a2,s0
ffffffffc0204c90:	85a6                	mv	a1,s1
ffffffffc0204c92:	c7cfd0ef          	jal	ra,ffffffffc020210e <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc0204c96:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc0204c98:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc0204c9a:	4785                	li	a5,1
ffffffffc0204c9c:	04f71663          	bne	a4,a5,ffffffffc0204ce8 <pgdir_alloc_page+0x9a>
}
ffffffffc0204ca0:	70a2                	ld	ra,40(sp)
ffffffffc0204ca2:	8522                	mv	a0,s0
ffffffffc0204ca4:	7402                	ld	s0,32(sp)
ffffffffc0204ca6:	64e2                	ld	s1,24(sp)
ffffffffc0204ca8:	6942                	ld	s2,16(sp)
ffffffffc0204caa:	69a2                	ld	s3,8(sp)
ffffffffc0204cac:	6145                	addi	sp,sp,48
ffffffffc0204cae:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204cb0:	100027f3          	csrr	a5,sstatus
ffffffffc0204cb4:	8b89                	andi	a5,a5,2
ffffffffc0204cb6:	eb99                	bnez	a5,ffffffffc0204ccc <pgdir_alloc_page+0x7e>
        pmm_manager->free_pages(base, n);
ffffffffc0204cb8:	000ae797          	auipc	a5,0xae
ffffffffc0204cbc:	c587b783          	ld	a5,-936(a5) # ffffffffc02b2910 <pmm_manager>
ffffffffc0204cc0:	739c                	ld	a5,32(a5)
ffffffffc0204cc2:	8522                	mv	a0,s0
ffffffffc0204cc4:	4585                	li	a1,1
ffffffffc0204cc6:	9782                	jalr	a5
            return NULL;
ffffffffc0204cc8:	4401                	li	s0,0
ffffffffc0204cca:	bfd9                	j	ffffffffc0204ca0 <pgdir_alloc_page+0x52>
        intr_disable();
ffffffffc0204ccc:	97dfb0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0204cd0:	000ae797          	auipc	a5,0xae
ffffffffc0204cd4:	c407b783          	ld	a5,-960(a5) # ffffffffc02b2910 <pmm_manager>
ffffffffc0204cd8:	739c                	ld	a5,32(a5)
ffffffffc0204cda:	8522                	mv	a0,s0
ffffffffc0204cdc:	4585                	li	a1,1
ffffffffc0204cde:	9782                	jalr	a5
            return NULL;
ffffffffc0204ce0:	4401                	li	s0,0
        intr_enable();
ffffffffc0204ce2:	961fb0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0204ce6:	bf6d                	j	ffffffffc0204ca0 <pgdir_alloc_page+0x52>
                assert(page_ref(page) == 1);
ffffffffc0204ce8:	00003697          	auipc	a3,0x3
ffffffffc0204cec:	7f868693          	addi	a3,a3,2040 # ffffffffc02084e0 <default_pmm_manager+0x618>
ffffffffc0204cf0:	00002617          	auipc	a2,0x2
ffffffffc0204cf4:	13860613          	addi	a2,a2,312 # ffffffffc0206e28 <commands+0x410>
ffffffffc0204cf8:	1d500593          	li	a1,469
ffffffffc0204cfc:	00003517          	auipc	a0,0x3
ffffffffc0204d00:	20450513          	addi	a0,a0,516 # ffffffffc0207f00 <default_pmm_manager+0x38>
ffffffffc0204d04:	d04fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204d08 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204d08:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204d0a:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204d0c:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204d0e:	81bfb0ef          	jal	ra,ffffffffc0200528 <ide_device_valid>
ffffffffc0204d12:	cd01                	beqz	a0,ffffffffc0204d2a <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204d14:	4505                	li	a0,1
ffffffffc0204d16:	819fb0ef          	jal	ra,ffffffffc020052e <ide_device_size>
}
ffffffffc0204d1a:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204d1c:	810d                	srli	a0,a0,0x3
ffffffffc0204d1e:	000ae797          	auipc	a5,0xae
ffffffffc0204d22:	baa7b923          	sd	a0,-1102(a5) # ffffffffc02b28d0 <max_swap_offset>
}
ffffffffc0204d26:	0141                	addi	sp,sp,16
ffffffffc0204d28:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204d2a:	00003617          	auipc	a2,0x3
ffffffffc0204d2e:	7ce60613          	addi	a2,a2,1998 # ffffffffc02084f8 <default_pmm_manager+0x630>
ffffffffc0204d32:	45b5                	li	a1,13
ffffffffc0204d34:	00003517          	auipc	a0,0x3
ffffffffc0204d38:	7e450513          	addi	a0,a0,2020 # ffffffffc0208518 <default_pmm_manager+0x650>
ffffffffc0204d3c:	cccfb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204d40 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204d40:	1141                	addi	sp,sp,-16
ffffffffc0204d42:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204d44:	00855793          	srli	a5,a0,0x8
ffffffffc0204d48:	cbb1                	beqz	a5,ffffffffc0204d9c <swapfs_read+0x5c>
ffffffffc0204d4a:	000ae717          	auipc	a4,0xae
ffffffffc0204d4e:	b8673703          	ld	a4,-1146(a4) # ffffffffc02b28d0 <max_swap_offset>
ffffffffc0204d52:	04e7f563          	bgeu	a5,a4,ffffffffc0204d9c <swapfs_read+0x5c>
    return page - pages + nbase;
ffffffffc0204d56:	000ae617          	auipc	a2,0xae
ffffffffc0204d5a:	bb263603          	ld	a2,-1102(a2) # ffffffffc02b2908 <pages>
ffffffffc0204d5e:	8d91                	sub	a1,a1,a2
ffffffffc0204d60:	4065d613          	srai	a2,a1,0x6
ffffffffc0204d64:	00004717          	auipc	a4,0x4
ffffffffc0204d68:	10c73703          	ld	a4,268(a4) # ffffffffc0208e70 <nbase>
ffffffffc0204d6c:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204d6e:	00c61713          	slli	a4,a2,0xc
ffffffffc0204d72:	8331                	srli	a4,a4,0xc
ffffffffc0204d74:	000ae697          	auipc	a3,0xae
ffffffffc0204d78:	b8c6b683          	ld	a3,-1140(a3) # ffffffffc02b2900 <npage>
ffffffffc0204d7c:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204d80:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204d82:	02d77963          	bgeu	a4,a3,ffffffffc0204db4 <swapfs_read+0x74>
}
ffffffffc0204d86:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204d88:	000ae797          	auipc	a5,0xae
ffffffffc0204d8c:	b907b783          	ld	a5,-1136(a5) # ffffffffc02b2918 <va_pa_offset>
ffffffffc0204d90:	46a1                	li	a3,8
ffffffffc0204d92:	963e                	add	a2,a2,a5
ffffffffc0204d94:	4505                	li	a0,1
}
ffffffffc0204d96:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204d98:	f9cfb06f          	j	ffffffffc0200534 <ide_read_secs>
ffffffffc0204d9c:	86aa                	mv	a3,a0
ffffffffc0204d9e:	00003617          	auipc	a2,0x3
ffffffffc0204da2:	79260613          	addi	a2,a2,1938 # ffffffffc0208530 <default_pmm_manager+0x668>
ffffffffc0204da6:	45d1                	li	a1,20
ffffffffc0204da8:	00003517          	auipc	a0,0x3
ffffffffc0204dac:	77050513          	addi	a0,a0,1904 # ffffffffc0208518 <default_pmm_manager+0x650>
ffffffffc0204db0:	c58fb0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0204db4:	86b2                	mv	a3,a2
ffffffffc0204db6:	06900593          	li	a1,105
ffffffffc0204dba:	00002617          	auipc	a2,0x2
ffffffffc0204dbe:	63e60613          	addi	a2,a2,1598 # ffffffffc02073f8 <commands+0x9e0>
ffffffffc0204dc2:	00002517          	auipc	a0,0x2
ffffffffc0204dc6:	3a650513          	addi	a0,a0,934 # ffffffffc0207168 <commands+0x750>
ffffffffc0204dca:	c3efb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204dce <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204dce:	1141                	addi	sp,sp,-16
ffffffffc0204dd0:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204dd2:	00855793          	srli	a5,a0,0x8
ffffffffc0204dd6:	cbb1                	beqz	a5,ffffffffc0204e2a <swapfs_write+0x5c>
ffffffffc0204dd8:	000ae717          	auipc	a4,0xae
ffffffffc0204ddc:	af873703          	ld	a4,-1288(a4) # ffffffffc02b28d0 <max_swap_offset>
ffffffffc0204de0:	04e7f563          	bgeu	a5,a4,ffffffffc0204e2a <swapfs_write+0x5c>
    return page - pages + nbase;
ffffffffc0204de4:	000ae617          	auipc	a2,0xae
ffffffffc0204de8:	b2463603          	ld	a2,-1244(a2) # ffffffffc02b2908 <pages>
ffffffffc0204dec:	8d91                	sub	a1,a1,a2
ffffffffc0204dee:	4065d613          	srai	a2,a1,0x6
ffffffffc0204df2:	00004717          	auipc	a4,0x4
ffffffffc0204df6:	07e73703          	ld	a4,126(a4) # ffffffffc0208e70 <nbase>
ffffffffc0204dfa:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204dfc:	00c61713          	slli	a4,a2,0xc
ffffffffc0204e00:	8331                	srli	a4,a4,0xc
ffffffffc0204e02:	000ae697          	auipc	a3,0xae
ffffffffc0204e06:	afe6b683          	ld	a3,-1282(a3) # ffffffffc02b2900 <npage>
ffffffffc0204e0a:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204e0e:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204e10:	02d77963          	bgeu	a4,a3,ffffffffc0204e42 <swapfs_write+0x74>
}
ffffffffc0204e14:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204e16:	000ae797          	auipc	a5,0xae
ffffffffc0204e1a:	b027b783          	ld	a5,-1278(a5) # ffffffffc02b2918 <va_pa_offset>
ffffffffc0204e1e:	46a1                	li	a3,8
ffffffffc0204e20:	963e                	add	a2,a2,a5
ffffffffc0204e22:	4505                	li	a0,1
}
ffffffffc0204e24:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204e26:	f32fb06f          	j	ffffffffc0200558 <ide_write_secs>
ffffffffc0204e2a:	86aa                	mv	a3,a0
ffffffffc0204e2c:	00003617          	auipc	a2,0x3
ffffffffc0204e30:	70460613          	addi	a2,a2,1796 # ffffffffc0208530 <default_pmm_manager+0x668>
ffffffffc0204e34:	45e5                	li	a1,25
ffffffffc0204e36:	00003517          	auipc	a0,0x3
ffffffffc0204e3a:	6e250513          	addi	a0,a0,1762 # ffffffffc0208518 <default_pmm_manager+0x650>
ffffffffc0204e3e:	bcafb0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0204e42:	86b2                	mv	a3,a2
ffffffffc0204e44:	06900593          	li	a1,105
ffffffffc0204e48:	00002617          	auipc	a2,0x2
ffffffffc0204e4c:	5b060613          	addi	a2,a2,1456 # ffffffffc02073f8 <commands+0x9e0>
ffffffffc0204e50:	00002517          	auipc	a0,0x2
ffffffffc0204e54:	31850513          	addi	a0,a0,792 # ffffffffc0207168 <commands+0x750>
ffffffffc0204e58:	bb0fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204e5c <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0204e5c:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0204e60:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0204e64:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0204e66:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0204e68:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0204e6c:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0204e70:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0204e74:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0204e78:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0204e7c:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0204e80:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0204e84:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0204e88:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0204e8c:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0204e90:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0204e94:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0204e98:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0204e9a:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0204e9c:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0204ea0:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0204ea4:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0204ea8:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0204eac:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0204eb0:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0204eb4:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0204eb8:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0204ebc:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0204ec0:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0204ec4:	8082                	ret

ffffffffc0204ec6 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204ec6:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204ec8:	9402                	jalr	s0

	jal do_exit
ffffffffc0204eca:	640000ef          	jal	ra,ffffffffc020550a <do_exit>

ffffffffc0204ece <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204ece:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204ed0:	10800513          	li	a0,264
alloc_proc(void) {
ffffffffc0204ed4:	e022                	sd	s0,0(sp)
ffffffffc0204ed6:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204ed8:	e02fd0ef          	jal	ra,ffffffffc02024da <kmalloc>
ffffffffc0204edc:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204ede:	cd39                	beqz	a0,ffffffffc0204f3c <alloc_proc+0x6e>
     /*
     * below fields(add in LAB5) in proc_struct need to be initialized  
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
     */
    proc->state = PROC_UNINIT;              
ffffffffc0204ee0:	57fd                	li	a5,-1
ffffffffc0204ee2:	1782                	slli	a5,a5,0x20
ffffffffc0204ee4:	e11c                	sd	a5,0(a0)
    proc->pid = -1;                        
    proc->runs = 0;                        
ffffffffc0204ee6:	00052423          	sw	zero,8(a0)
    proc->kstack = 0;
ffffffffc0204eea:	00053823          	sd	zero,16(a0)
    proc->need_resched = 0;                 
ffffffffc0204eee:	00053c23          	sd	zero,24(a0)
    proc->parent = NULL;                    
ffffffffc0204ef2:	02053023          	sd	zero,32(a0)
    proc->mm = NULL;                       
ffffffffc0204ef6:	02053423          	sd	zero,40(a0)
    memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204efa:	07000613          	li	a2,112
ffffffffc0204efe:	4581                	li	a1,0
ffffffffc0204f00:	03050513          	addi	a0,a0,48
ffffffffc0204f04:	43e010ef          	jal	ra,ffffffffc0206342 <memset>
    proc->tf = NULL;                        
    proc->cr3 = boot_cr3;                   
ffffffffc0204f08:	000ae797          	auipc	a5,0xae
ffffffffc0204f0c:	9e87b783          	ld	a5,-1560(a5) # ffffffffc02b28f0 <boot_cr3>
ffffffffc0204f10:	f45c                	sd	a5,168(s0)
    proc->tf = NULL;                        
ffffffffc0204f12:	0a043023          	sd	zero,160(s0)
    proc->flags = 0;                        
ffffffffc0204f16:	0a042823          	sw	zero,176(s0)
    for (int i = 0; i < PROC_NAME_LEN + 1; i++) {
ffffffffc0204f1a:	0b440793          	addi	a5,s0,180
ffffffffc0204f1e:	0c440713          	addi	a4,s0,196
    proc->name[i] =0; }
ffffffffc0204f22:	00078023          	sb	zero,0(a5)
    for (int i = 0; i < PROC_NAME_LEN + 1; i++) {
ffffffffc0204f26:	0785                	addi	a5,a5,1
ffffffffc0204f28:	fee79de3          	bne	a5,a4,ffffffffc0204f22 <alloc_proc+0x54>
    proc->wait_state = 0;
ffffffffc0204f2c:	0e042623          	sw	zero,236(s0)
    proc->cptr =  NULL;
ffffffffc0204f30:	0e043823          	sd	zero,240(s0)
    proc->optr =  NULL;
ffffffffc0204f34:	10043023          	sd	zero,256(s0)
    proc->yptr =  NULL;
ffffffffc0204f38:	0e043c23          	sd	zero,248(s0)
    }
    return proc;
}
ffffffffc0204f3c:	60a2                	ld	ra,8(sp)
ffffffffc0204f3e:	8522                	mv	a0,s0
ffffffffc0204f40:	6402                	ld	s0,0(sp)
ffffffffc0204f42:	0141                	addi	sp,sp,16
ffffffffc0204f44:	8082                	ret

ffffffffc0204f46 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204f46:	000ae797          	auipc	a5,0xae
ffffffffc0204f4a:	9da7b783          	ld	a5,-1574(a5) # ffffffffc02b2920 <current>
ffffffffc0204f4e:	73c8                	ld	a0,160(a5)
ffffffffc0204f50:	e27fb06f          	j	ffffffffc0200d76 <forkrets>

ffffffffc0204f54 <user_main>:

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204f54:	000ae797          	auipc	a5,0xae
ffffffffc0204f58:	9cc7b783          	ld	a5,-1588(a5) # ffffffffc02b2920 <current>
ffffffffc0204f5c:	43cc                	lw	a1,4(a5)
user_main(void *arg) {
ffffffffc0204f5e:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204f60:	00003617          	auipc	a2,0x3
ffffffffc0204f64:	5f060613          	addi	a2,a2,1520 # ffffffffc0208550 <default_pmm_manager+0x688>
ffffffffc0204f68:	00003517          	auipc	a0,0x3
ffffffffc0204f6c:	5f850513          	addi	a0,a0,1528 # ffffffffc0208560 <default_pmm_manager+0x698>
user_main(void *arg) {
ffffffffc0204f70:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204f72:	95afb0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0204f76:	3fe06797          	auipc	a5,0x3fe06
ffffffffc0204f7a:	a0278793          	addi	a5,a5,-1534 # a978 <_binary_obj___user_forktest_out_size>
ffffffffc0204f7e:	e43e                	sd	a5,8(sp)
ffffffffc0204f80:	00003517          	auipc	a0,0x3
ffffffffc0204f84:	5d050513          	addi	a0,a0,1488 # ffffffffc0208550 <default_pmm_manager+0x688>
ffffffffc0204f88:	00098797          	auipc	a5,0x98
ffffffffc0204f8c:	a8078793          	addi	a5,a5,-1408 # ffffffffc029ca08 <_binary_obj___user_forktest_out_start>
ffffffffc0204f90:	f03e                	sd	a5,32(sp)
ffffffffc0204f92:	f42a                	sd	a0,40(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc0204f94:	e802                	sd	zero,16(sp)
ffffffffc0204f96:	330010ef          	jal	ra,ffffffffc02062c6 <strlen>
ffffffffc0204f9a:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204f9c:	4511                	li	a0,4
ffffffffc0204f9e:	55a2                	lw	a1,40(sp)
ffffffffc0204fa0:	4662                	lw	a2,24(sp)
ffffffffc0204fa2:	5682                	lw	a3,32(sp)
ffffffffc0204fa4:	4722                	lw	a4,8(sp)
ffffffffc0204fa6:	48a9                	li	a7,10
ffffffffc0204fa8:	9002                	ebreak
ffffffffc0204faa:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204fac:	65c2                	ld	a1,16(sp)
ffffffffc0204fae:	00003517          	auipc	a0,0x3
ffffffffc0204fb2:	5da50513          	addi	a0,a0,1498 # ffffffffc0208588 <default_pmm_manager+0x6c0>
ffffffffc0204fb6:	916fb0ef          	jal	ra,ffffffffc02000cc <cprintf>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
ffffffffc0204fba:	00003617          	auipc	a2,0x3
ffffffffc0204fbe:	5de60613          	addi	a2,a2,1502 # ffffffffc0208598 <default_pmm_manager+0x6d0>
ffffffffc0204fc2:	34f00593          	li	a1,847
ffffffffc0204fc6:	00003517          	auipc	a0,0x3
ffffffffc0204fca:	5f250513          	addi	a0,a0,1522 # ffffffffc02085b8 <default_pmm_manager+0x6f0>
ffffffffc0204fce:	a3afb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204fd2 <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204fd2:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc0204fd4:	1141                	addi	sp,sp,-16
ffffffffc0204fd6:	e406                	sd	ra,8(sp)
ffffffffc0204fd8:	c02007b7          	lui	a5,0xc0200
ffffffffc0204fdc:	02f6ee63          	bltu	a3,a5,ffffffffc0205018 <put_pgdir+0x46>
ffffffffc0204fe0:	000ae517          	auipc	a0,0xae
ffffffffc0204fe4:	93853503          	ld	a0,-1736(a0) # ffffffffc02b2918 <va_pa_offset>
ffffffffc0204fe8:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc0204fea:	82b1                	srli	a3,a3,0xc
ffffffffc0204fec:	000ae797          	auipc	a5,0xae
ffffffffc0204ff0:	9147b783          	ld	a5,-1772(a5) # ffffffffc02b2900 <npage>
ffffffffc0204ff4:	02f6fe63          	bgeu	a3,a5,ffffffffc0205030 <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0204ff8:	00004517          	auipc	a0,0x4
ffffffffc0204ffc:	e7853503          	ld	a0,-392(a0) # ffffffffc0208e70 <nbase>
}
ffffffffc0205000:	60a2                	ld	ra,8(sp)
ffffffffc0205002:	8e89                	sub	a3,a3,a0
ffffffffc0205004:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0205006:	000ae517          	auipc	a0,0xae
ffffffffc020500a:	90253503          	ld	a0,-1790(a0) # ffffffffc02b2908 <pages>
ffffffffc020500e:	4585                	li	a1,1
ffffffffc0205010:	9536                	add	a0,a0,a3
}
ffffffffc0205012:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0205014:	dd6fe06f          	j	ffffffffc02035ea <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0205018:	00003617          	auipc	a2,0x3
ffffffffc020501c:	95060613          	addi	a2,a2,-1712 # ffffffffc0207968 <commands+0xf50>
ffffffffc0205020:	06e00593          	li	a1,110
ffffffffc0205024:	00002517          	auipc	a0,0x2
ffffffffc0205028:	14450513          	addi	a0,a0,324 # ffffffffc0207168 <commands+0x750>
ffffffffc020502c:	9dcfb0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0205030:	00002617          	auipc	a2,0x2
ffffffffc0205034:	11860613          	addi	a2,a2,280 # ffffffffc0207148 <commands+0x730>
ffffffffc0205038:	06200593          	li	a1,98
ffffffffc020503c:	00002517          	auipc	a0,0x2
ffffffffc0205040:	12c50513          	addi	a0,a0,300 # ffffffffc0207168 <commands+0x750>
ffffffffc0205044:	9c4fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205048 <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0205048:	7179                	addi	sp,sp,-48
ffffffffc020504a:	f026                	sd	s1,32(sp)
    if (proc != current) {
ffffffffc020504c:	000ae497          	auipc	s1,0xae
ffffffffc0205050:	8d448493          	addi	s1,s1,-1836 # ffffffffc02b2920 <current>
ffffffffc0205054:	6098                	ld	a4,0(s1)
proc_run(struct proc_struct *proc) {
ffffffffc0205056:	f406                	sd	ra,40(sp)
ffffffffc0205058:	ec4a                	sd	s2,24(sp)
    if (proc != current) {
ffffffffc020505a:	02a70763          	beq	a4,a0,ffffffffc0205088 <proc_run+0x40>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020505e:	100027f3          	csrr	a5,sstatus
ffffffffc0205062:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205064:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205066:	ef85                	bnez	a5,ffffffffc020509e <proc_run+0x56>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0205068:	755c                	ld	a5,168(a0)
ffffffffc020506a:	56fd                	li	a3,-1
ffffffffc020506c:	16fe                	slli	a3,a3,0x3f
ffffffffc020506e:	83b1                	srli	a5,a5,0xc
        current = proc; 
ffffffffc0205070:	e088                	sd	a0,0(s1)
ffffffffc0205072:	8fd5                	or	a5,a5,a3
ffffffffc0205074:	18079073          	csrw	satp,a5
        switch_to(&(a->context), &(b->context)); 
ffffffffc0205078:	03050593          	addi	a1,a0,48
ffffffffc020507c:	03070513          	addi	a0,a4,48
ffffffffc0205080:	dddff0ef          	jal	ra,ffffffffc0204e5c <switch_to>
    if (flag) {
ffffffffc0205084:	00091763          	bnez	s2,ffffffffc0205092 <proc_run+0x4a>
}
ffffffffc0205088:	70a2                	ld	ra,40(sp)
ffffffffc020508a:	7482                	ld	s1,32(sp)
ffffffffc020508c:	6962                	ld	s2,24(sp)
ffffffffc020508e:	6145                	addi	sp,sp,48
ffffffffc0205090:	8082                	ret
ffffffffc0205092:	70a2                	ld	ra,40(sp)
ffffffffc0205094:	7482                	ld	s1,32(sp)
ffffffffc0205096:	6962                	ld	s2,24(sp)
ffffffffc0205098:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc020509a:	da8fb06f          	j	ffffffffc0200642 <intr_enable>
ffffffffc020509e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02050a0:	da8fb0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        struct proc_struct *a = current , *b = proc; 
ffffffffc02050a4:	6098                	ld	a4,0(s1)
        return 1;
ffffffffc02050a6:	6522                	ld	a0,8(sp)
ffffffffc02050a8:	4905                	li	s2,1
ffffffffc02050aa:	bf7d                	j	ffffffffc0205068 <proc_run+0x20>

ffffffffc02050ac <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc02050ac:	7159                	addi	sp,sp,-112
ffffffffc02050ae:	e8ca                	sd	s2,80(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc02050b0:	000ae917          	auipc	s2,0xae
ffffffffc02050b4:	88890913          	addi	s2,s2,-1912 # ffffffffc02b2938 <nr_process>
ffffffffc02050b8:	00092703          	lw	a4,0(s2)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc02050bc:	f486                	sd	ra,104(sp)
ffffffffc02050be:	f0a2                	sd	s0,96(sp)
ffffffffc02050c0:	eca6                	sd	s1,88(sp)
ffffffffc02050c2:	e4ce                	sd	s3,72(sp)
ffffffffc02050c4:	e0d2                	sd	s4,64(sp)
ffffffffc02050c6:	fc56                	sd	s5,56(sp)
ffffffffc02050c8:	f85a                	sd	s6,48(sp)
ffffffffc02050ca:	f45e                	sd	s7,40(sp)
ffffffffc02050cc:	f062                	sd	s8,32(sp)
ffffffffc02050ce:	ec66                	sd	s9,24(sp)
ffffffffc02050d0:	e86a                	sd	s10,16(sp)
ffffffffc02050d2:	e46e                	sd	s11,8(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc02050d4:	6785                	lui	a5,0x1
ffffffffc02050d6:	34f75063          	bge	a4,a5,ffffffffc0205416 <do_fork+0x36a>
ffffffffc02050da:	8a2a                	mv	s4,a0
ffffffffc02050dc:	89ae                	mv	s3,a1
ffffffffc02050de:	8432                	mv	s0,a2
    proc = alloc_proc();    
ffffffffc02050e0:	defff0ef          	jal	ra,ffffffffc0204ece <alloc_proc>
ffffffffc02050e4:	84aa                	mv	s1,a0
    if (proc == NULL) { 
ffffffffc02050e6:	2c050863          	beqz	a0,ffffffffc02053b6 <do_fork+0x30a>
    assert(current->wait_state == 0);
ffffffffc02050ea:	000aea97          	auipc	s5,0xae
ffffffffc02050ee:	836a8a93          	addi	s5,s5,-1994 # ffffffffc02b2920 <current>
ffffffffc02050f2:	000ab783          	ld	a5,0(s5)
ffffffffc02050f6:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x8ad4>
ffffffffc02050fa:	38071463          	bnez	a4,ffffffffc0205482 <do_fork+0x3d6>
    proc->parent = current;
ffffffffc02050fe:	f11c                	sd	a5,32(a0)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0205100:	4509                	li	a0,2
ffffffffc0205102:	c56fe0ef          	jal	ra,ffffffffc0203558 <alloc_pages>
    if (page != NULL) {
ffffffffc0205106:	2c050763          	beqz	a0,ffffffffc02053d4 <do_fork+0x328>
    return page - pages + nbase;
ffffffffc020510a:	000add97          	auipc	s11,0xad
ffffffffc020510e:	7fed8d93          	addi	s11,s11,2046 # ffffffffc02b2908 <pages>
ffffffffc0205112:	000db683          	ld	a3,0(s11)
    return KADDR(page2pa(page));
ffffffffc0205116:	000add17          	auipc	s10,0xad
ffffffffc020511a:	7ead0d13          	addi	s10,s10,2026 # ffffffffc02b2900 <npage>
    return page - pages + nbase;
ffffffffc020511e:	00004c97          	auipc	s9,0x4
ffffffffc0205122:	d52cbc83          	ld	s9,-686(s9) # ffffffffc0208e70 <nbase>
ffffffffc0205126:	40d506b3          	sub	a3,a0,a3
ffffffffc020512a:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc020512c:	5c7d                	li	s8,-1
ffffffffc020512e:	000d3783          	ld	a5,0(s10)
    return page - pages + nbase;
ffffffffc0205132:	96e6                	add	a3,a3,s9
    return KADDR(page2pa(page));
ffffffffc0205134:	00cc5c13          	srli	s8,s8,0xc
ffffffffc0205138:	0186f733          	and	a4,a3,s8
    return page2ppn(page) << PGSHIFT;
ffffffffc020513c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020513e:	30f77963          	bgeu	a4,a5,ffffffffc0205450 <do_fork+0x3a4>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0205142:	000ab703          	ld	a4,0(s5)
ffffffffc0205146:	000ada97          	auipc	s5,0xad
ffffffffc020514a:	7d2a8a93          	addi	s5,s5,2002 # ffffffffc02b2918 <va_pa_offset>
ffffffffc020514e:	000ab783          	ld	a5,0(s5)
ffffffffc0205152:	02873b83          	ld	s7,40(a4)
ffffffffc0205156:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0205158:	e894                	sd	a3,16(s1)
    if (oldmm == NULL) {
ffffffffc020515a:	020b8863          	beqz	s7,ffffffffc020518a <do_fork+0xde>
    if (clone_flags & CLONE_VM) {
ffffffffc020515e:	100a7a13          	andi	s4,s4,256
ffffffffc0205162:	1c0a0163          	beqz	s4,ffffffffc0205324 <do_fork+0x278>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc0205166:	030ba703          	lw	a4,48(s7)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc020516a:	018bb783          	ld	a5,24(s7)
ffffffffc020516e:	c02006b7          	lui	a3,0xc0200
ffffffffc0205172:	2705                	addiw	a4,a4,1
ffffffffc0205174:	02eba823          	sw	a4,48(s7)
    proc->mm = mm;
ffffffffc0205178:	0374b423          	sd	s7,40(s1)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc020517c:	2ed7e663          	bltu	a5,a3,ffffffffc0205468 <do_fork+0x3bc>
ffffffffc0205180:	000ab703          	ld	a4,0(s5)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0205184:	6894                	ld	a3,16(s1)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205186:	8f99                	sub	a5,a5,a4
ffffffffc0205188:	f4dc                	sd	a5,168(s1)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc020518a:	6789                	lui	a5,0x2
ffffffffc020518c:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7ce0>
ffffffffc0205190:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc0205192:	8622                	mv	a2,s0
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0205194:	f0d4                	sd	a3,160(s1)
    *(proc->tf) = *tf;
ffffffffc0205196:	87b6                	mv	a5,a3
ffffffffc0205198:	12040893          	addi	a7,s0,288
ffffffffc020519c:	00063803          	ld	a6,0(a2)
ffffffffc02051a0:	6608                	ld	a0,8(a2)
ffffffffc02051a2:	6a0c                	ld	a1,16(a2)
ffffffffc02051a4:	6e18                	ld	a4,24(a2)
ffffffffc02051a6:	0107b023          	sd	a6,0(a5)
ffffffffc02051aa:	e788                	sd	a0,8(a5)
ffffffffc02051ac:	eb8c                	sd	a1,16(a5)
ffffffffc02051ae:	ef98                	sd	a4,24(a5)
ffffffffc02051b0:	02060613          	addi	a2,a2,32
ffffffffc02051b4:	02078793          	addi	a5,a5,32
ffffffffc02051b8:	ff1612e3          	bne	a2,a7,ffffffffc020519c <do_fork+0xf0>
    proc->tf->gpr.a0 = 0;
ffffffffc02051bc:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1e>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02051c0:	12098f63          	beqz	s3,ffffffffc02052fe <do_fork+0x252>
ffffffffc02051c4:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02051c8:	00000797          	auipc	a5,0x0
ffffffffc02051cc:	d7e78793          	addi	a5,a5,-642 # ffffffffc0204f46 <forkret>
ffffffffc02051d0:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02051d2:	fc94                	sd	a3,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02051d4:	100027f3          	csrr	a5,sstatus
ffffffffc02051d8:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02051da:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02051dc:	14079063          	bnez	a5,ffffffffc020531c <do_fork+0x270>
    if (++ last_pid >= MAX_PID) {
ffffffffc02051e0:	000a2817          	auipc	a6,0xa2
ffffffffc02051e4:	1f880813          	addi	a6,a6,504 # ffffffffc02a73d8 <last_pid.1>
ffffffffc02051e8:	00082783          	lw	a5,0(a6)
ffffffffc02051ec:	6709                	lui	a4,0x2
ffffffffc02051ee:	0017851b          	addiw	a0,a5,1
ffffffffc02051f2:	00a82023          	sw	a0,0(a6)
ffffffffc02051f6:	08e55d63          	bge	a0,a4,ffffffffc0205290 <do_fork+0x1e4>
    if (last_pid >= next_safe) {
ffffffffc02051fa:	000a2317          	auipc	t1,0xa2
ffffffffc02051fe:	1e230313          	addi	t1,t1,482 # ffffffffc02a73dc <next_safe.0>
ffffffffc0205202:	00032783          	lw	a5,0(t1)
ffffffffc0205206:	000ad417          	auipc	s0,0xad
ffffffffc020520a:	69240413          	addi	s0,s0,1682 # ffffffffc02b2898 <proc_list>
ffffffffc020520e:	08f55963          	bge	a0,a5,ffffffffc02052a0 <do_fork+0x1f4>
        proc->pid = get_pid();
ffffffffc0205212:	c0c8                	sw	a0,4(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0205214:	45a9                	li	a1,10
ffffffffc0205216:	2501                	sext.w	a0,a0
ffffffffc0205218:	542010ef          	jal	ra,ffffffffc020675a <hash32>
ffffffffc020521c:	02051793          	slli	a5,a0,0x20
ffffffffc0205220:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0205224:	000a9797          	auipc	a5,0xa9
ffffffffc0205228:	67478793          	addi	a5,a5,1652 # ffffffffc02ae898 <hash_list>
ffffffffc020522c:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc020522e:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0205230:	7094                	ld	a3,32(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0205232:	0d848793          	addi	a5,s1,216
    prev->next = next->prev = elm;
ffffffffc0205236:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0205238:	6410                	ld	a2,8(s0)
    prev->next = next->prev = elm;
ffffffffc020523a:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc020523c:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc020523e:	0c848793          	addi	a5,s1,200
    elm->next = next;
ffffffffc0205242:	f0ec                	sd	a1,224(s1)
    elm->prev = prev;
ffffffffc0205244:	ece8                	sd	a0,216(s1)
    prev->next = next->prev = elm;
ffffffffc0205246:	e21c                	sd	a5,0(a2)
ffffffffc0205248:	e41c                	sd	a5,8(s0)
    elm->next = next;
ffffffffc020524a:	e8f0                	sd	a2,208(s1)
    elm->prev = prev;
ffffffffc020524c:	e4e0                	sd	s0,200(s1)
    proc->yptr = NULL;
ffffffffc020524e:	0e04bc23          	sd	zero,248(s1)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0205252:	10e4b023          	sd	a4,256(s1)
ffffffffc0205256:	c311                	beqz	a4,ffffffffc020525a <do_fork+0x1ae>
        proc->optr->yptr = proc;
ffffffffc0205258:	ff64                	sd	s1,248(a4)
    nr_process ++;
ffffffffc020525a:	00092783          	lw	a5,0(s2)
    proc->parent->cptr = proc;
ffffffffc020525e:	fae4                	sd	s1,240(a3)
    nr_process ++;
ffffffffc0205260:	2785                	addiw	a5,a5,1
ffffffffc0205262:	00f92023          	sw	a5,0(s2)
    if (flag) {
ffffffffc0205266:	14099a63          	bnez	s3,ffffffffc02053ba <do_fork+0x30e>
    wakeup_proc(proc);
ffffffffc020526a:	8526                	mv	a0,s1
ffffffffc020526c:	66f000ef          	jal	ra,ffffffffc02060da <wakeup_proc>
    ret = proc->pid;
ffffffffc0205270:	40c8                	lw	a0,4(s1)
}
ffffffffc0205272:	70a6                	ld	ra,104(sp)
ffffffffc0205274:	7406                	ld	s0,96(sp)
ffffffffc0205276:	64e6                	ld	s1,88(sp)
ffffffffc0205278:	6946                	ld	s2,80(sp)
ffffffffc020527a:	69a6                	ld	s3,72(sp)
ffffffffc020527c:	6a06                	ld	s4,64(sp)
ffffffffc020527e:	7ae2                	ld	s5,56(sp)
ffffffffc0205280:	7b42                	ld	s6,48(sp)
ffffffffc0205282:	7ba2                	ld	s7,40(sp)
ffffffffc0205284:	7c02                	ld	s8,32(sp)
ffffffffc0205286:	6ce2                	ld	s9,24(sp)
ffffffffc0205288:	6d42                	ld	s10,16(sp)
ffffffffc020528a:	6da2                	ld	s11,8(sp)
ffffffffc020528c:	6165                	addi	sp,sp,112
ffffffffc020528e:	8082                	ret
        last_pid = 1;
ffffffffc0205290:	4785                	li	a5,1
ffffffffc0205292:	00f82023          	sw	a5,0(a6)
        goto inside;
ffffffffc0205296:	4505                	li	a0,1
ffffffffc0205298:	000a2317          	auipc	t1,0xa2
ffffffffc020529c:	14430313          	addi	t1,t1,324 # ffffffffc02a73dc <next_safe.0>
    return listelm->next;
ffffffffc02052a0:	000ad417          	auipc	s0,0xad
ffffffffc02052a4:	5f840413          	addi	s0,s0,1528 # ffffffffc02b2898 <proc_list>
ffffffffc02052a8:	00843e03          	ld	t3,8(s0)
        next_safe = MAX_PID;
ffffffffc02052ac:	6789                	lui	a5,0x2
ffffffffc02052ae:	00f32023          	sw	a5,0(t1)
ffffffffc02052b2:	86aa                	mv	a3,a0
ffffffffc02052b4:	4581                	li	a1,0
        while ((le = list_next(le)) != list) {
ffffffffc02052b6:	6e89                	lui	t4,0x2
ffffffffc02052b8:	108e0963          	beq	t3,s0,ffffffffc02053ca <do_fork+0x31e>
ffffffffc02052bc:	88ae                	mv	a7,a1
ffffffffc02052be:	87f2                	mv	a5,t3
ffffffffc02052c0:	6609                	lui	a2,0x2
ffffffffc02052c2:	a811                	j	ffffffffc02052d6 <do_fork+0x22a>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc02052c4:	00e6d663          	bge	a3,a4,ffffffffc02052d0 <do_fork+0x224>
ffffffffc02052c8:	00c75463          	bge	a4,a2,ffffffffc02052d0 <do_fork+0x224>
ffffffffc02052cc:	863a                	mv	a2,a4
ffffffffc02052ce:	4885                	li	a7,1
ffffffffc02052d0:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc02052d2:	00878d63          	beq	a5,s0,ffffffffc02052ec <do_fork+0x240>
            if (proc->pid == last_pid) {
ffffffffc02052d6:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_faultread_out_size-0x7c84>
ffffffffc02052da:	fed715e3          	bne	a4,a3,ffffffffc02052c4 <do_fork+0x218>
                if (++ last_pid >= next_safe) {
ffffffffc02052de:	2685                	addiw	a3,a3,1
ffffffffc02052e0:	0ec6d063          	bge	a3,a2,ffffffffc02053c0 <do_fork+0x314>
ffffffffc02052e4:	679c                	ld	a5,8(a5)
ffffffffc02052e6:	4585                	li	a1,1
        while ((le = list_next(le)) != list) {
ffffffffc02052e8:	fe8797e3          	bne	a5,s0,ffffffffc02052d6 <do_fork+0x22a>
ffffffffc02052ec:	c581                	beqz	a1,ffffffffc02052f4 <do_fork+0x248>
ffffffffc02052ee:	00d82023          	sw	a3,0(a6)
ffffffffc02052f2:	8536                	mv	a0,a3
ffffffffc02052f4:	f0088fe3          	beqz	a7,ffffffffc0205212 <do_fork+0x166>
ffffffffc02052f8:	00c32023          	sw	a2,0(t1)
ffffffffc02052fc:	bf19                	j	ffffffffc0205212 <do_fork+0x166>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02052fe:	89b6                	mv	s3,a3
ffffffffc0205300:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0205304:	00000797          	auipc	a5,0x0
ffffffffc0205308:	c4278793          	addi	a5,a5,-958 # ffffffffc0204f46 <forkret>
ffffffffc020530c:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc020530e:	fc94                	sd	a3,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205310:	100027f3          	csrr	a5,sstatus
ffffffffc0205314:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205316:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205318:	ec0784e3          	beqz	a5,ffffffffc02051e0 <do_fork+0x134>
        intr_disable();
ffffffffc020531c:	b2cfb0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc0205320:	4985                	li	s3,1
ffffffffc0205322:	bd7d                	j	ffffffffc02051e0 <do_fork+0x134>
    if ((mm = mm_create()) == NULL) {
ffffffffc0205324:	b3ffb0ef          	jal	ra,ffffffffc0200e62 <mm_create>
ffffffffc0205328:	8b2a                	mv	s6,a0
ffffffffc020532a:	c159                	beqz	a0,ffffffffc02053b0 <do_fork+0x304>
    if ((page = alloc_page()) == NULL) {
ffffffffc020532c:	4505                	li	a0,1
ffffffffc020532e:	a2afe0ef          	jal	ra,ffffffffc0203558 <alloc_pages>
ffffffffc0205332:	cd25                	beqz	a0,ffffffffc02053aa <do_fork+0x2fe>
    return page - pages + nbase;
ffffffffc0205334:	000db683          	ld	a3,0(s11)
    return KADDR(page2pa(page));
ffffffffc0205338:	000d3783          	ld	a5,0(s10)
    return page - pages + nbase;
ffffffffc020533c:	40d506b3          	sub	a3,a0,a3
ffffffffc0205340:	8699                	srai	a3,a3,0x6
ffffffffc0205342:	96e6                	add	a3,a3,s9
    return KADDR(page2pa(page));
ffffffffc0205344:	0186fc33          	and	s8,a3,s8
    return page2ppn(page) << PGSHIFT;
ffffffffc0205348:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020534a:	10fc7363          	bgeu	s8,a5,ffffffffc0205450 <do_fork+0x3a4>
ffffffffc020534e:	000aba03          	ld	s4,0(s5)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc0205352:	6605                	lui	a2,0x1
ffffffffc0205354:	000ad597          	auipc	a1,0xad
ffffffffc0205358:	5a45b583          	ld	a1,1444(a1) # ffffffffc02b28f8 <boot_pgdir>
ffffffffc020535c:	9a36                	add	s4,s4,a3
ffffffffc020535e:	8552                	mv	a0,s4
ffffffffc0205360:	7f5000ef          	jal	ra,ffffffffc0206354 <memcpy>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc0205364:	038b8c13          	addi	s8,s7,56
    mm->pgdir = pgdir;
ffffffffc0205368:	014b3c23          	sd	s4,24(s6)
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020536c:	4785                	li	a5,1
ffffffffc020536e:	40fc37af          	amoor.d	a5,a5,(s8)
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc0205372:	8b85                	andi	a5,a5,1
ffffffffc0205374:	4a05                	li	s4,1
ffffffffc0205376:	c799                	beqz	a5,ffffffffc0205384 <do_fork+0x2d8>
        schedule();
ffffffffc0205378:	5e3000ef          	jal	ra,ffffffffc020615a <schedule>
ffffffffc020537c:	414c37af          	amoor.d	a5,s4,(s8)
    while (!try_lock(lock)) {
ffffffffc0205380:	8b85                	andi	a5,a5,1
ffffffffc0205382:	fbfd                	bnez	a5,ffffffffc0205378 <do_fork+0x2cc>
        ret = dup_mmap(mm, oldmm);
ffffffffc0205384:	85de                	mv	a1,s7
ffffffffc0205386:	855a                	mv	a0,s6
ffffffffc0205388:	d63fb0ef          	jal	ra,ffffffffc02010ea <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020538c:	57f9                	li	a5,-2
ffffffffc020538e:	60fc37af          	amoand.d	a5,a5,(s8)
ffffffffc0205392:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc0205394:	10078763          	beqz	a5,ffffffffc02054a2 <do_fork+0x3f6>
good_mm:
ffffffffc0205398:	8bda                	mv	s7,s6
    if (ret != 0) {
ffffffffc020539a:	dc0506e3          	beqz	a0,ffffffffc0205166 <do_fork+0xba>
    exit_mmap(mm);
ffffffffc020539e:	855a                	mv	a0,s6
ffffffffc02053a0:	de5fb0ef          	jal	ra,ffffffffc0201184 <exit_mmap>
    put_pgdir(mm);
ffffffffc02053a4:	855a                	mv	a0,s6
ffffffffc02053a6:	c2dff0ef          	jal	ra,ffffffffc0204fd2 <put_pgdir>
    mm_destroy(mm);
ffffffffc02053aa:	855a                	mv	a0,s6
ffffffffc02053ac:	c3dfb0ef          	jal	ra,ffffffffc0200fe8 <mm_destroy>
    kfree(proc);
ffffffffc02053b0:	8526                	mv	a0,s1
ffffffffc02053b2:	9d8fd0ef          	jal	ra,ffffffffc020258a <kfree>
    ret = -E_NO_MEM;
ffffffffc02053b6:	5571                	li	a0,-4
    return ret;
ffffffffc02053b8:	bd6d                	j	ffffffffc0205272 <do_fork+0x1c6>
        intr_enable();
ffffffffc02053ba:	a88fb0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc02053be:	b575                	j	ffffffffc020526a <do_fork+0x1be>
                    if (last_pid >= MAX_PID) {
ffffffffc02053c0:	01d6c363          	blt	a3,t4,ffffffffc02053c6 <do_fork+0x31a>
                        last_pid = 1;
ffffffffc02053c4:	4685                	li	a3,1
                    goto repeat;
ffffffffc02053c6:	4585                	li	a1,1
ffffffffc02053c8:	bdc5                	j	ffffffffc02052b8 <do_fork+0x20c>
ffffffffc02053ca:	c9a1                	beqz	a1,ffffffffc020541a <do_fork+0x36e>
ffffffffc02053cc:	00d82023          	sw	a3,0(a6)
    return last_pid;
ffffffffc02053d0:	8536                	mv	a0,a3
ffffffffc02053d2:	b581                	j	ffffffffc0205212 <do_fork+0x166>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02053d4:	6894                	ld	a3,16(s1)
    return pa2page(PADDR(kva));
ffffffffc02053d6:	c02007b7          	lui	a5,0xc0200
ffffffffc02053da:	04f6ef63          	bltu	a3,a5,ffffffffc0205438 <do_fork+0x38c>
ffffffffc02053de:	000ad797          	auipc	a5,0xad
ffffffffc02053e2:	53a7b783          	ld	a5,1338(a5) # ffffffffc02b2918 <va_pa_offset>
ffffffffc02053e6:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc02053ea:	83b1                	srli	a5,a5,0xc
ffffffffc02053ec:	000ad717          	auipc	a4,0xad
ffffffffc02053f0:	51473703          	ld	a4,1300(a4) # ffffffffc02b2900 <npage>
ffffffffc02053f4:	02e7f663          	bgeu	a5,a4,ffffffffc0205420 <do_fork+0x374>
    return &pages[PPN(pa) - nbase];
ffffffffc02053f8:	00004717          	auipc	a4,0x4
ffffffffc02053fc:	a7873703          	ld	a4,-1416(a4) # ffffffffc0208e70 <nbase>
ffffffffc0205400:	8f99                	sub	a5,a5,a4
ffffffffc0205402:	079a                	slli	a5,a5,0x6
ffffffffc0205404:	000ad517          	auipc	a0,0xad
ffffffffc0205408:	50453503          	ld	a0,1284(a0) # ffffffffc02b2908 <pages>
ffffffffc020540c:	4589                	li	a1,2
ffffffffc020540e:	953e                	add	a0,a0,a5
ffffffffc0205410:	9dafe0ef          	jal	ra,ffffffffc02035ea <free_pages>
}
ffffffffc0205414:	bf71                	j	ffffffffc02053b0 <do_fork+0x304>
    int ret = -E_NO_FREE_PROC;
ffffffffc0205416:	556d                	li	a0,-5
ffffffffc0205418:	bda9                	j	ffffffffc0205272 <do_fork+0x1c6>
    return last_pid;
ffffffffc020541a:	00082503          	lw	a0,0(a6)
ffffffffc020541e:	bbd5                	j	ffffffffc0205212 <do_fork+0x166>
        panic("pa2page called with invalid pa");
ffffffffc0205420:	00002617          	auipc	a2,0x2
ffffffffc0205424:	d2860613          	addi	a2,a2,-728 # ffffffffc0207148 <commands+0x730>
ffffffffc0205428:	06200593          	li	a1,98
ffffffffc020542c:	00002517          	auipc	a0,0x2
ffffffffc0205430:	d3c50513          	addi	a0,a0,-708 # ffffffffc0207168 <commands+0x750>
ffffffffc0205434:	dd5fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0205438:	00002617          	auipc	a2,0x2
ffffffffc020543c:	53060613          	addi	a2,a2,1328 # ffffffffc0207968 <commands+0xf50>
ffffffffc0205440:	06e00593          	li	a1,110
ffffffffc0205444:	00002517          	auipc	a0,0x2
ffffffffc0205448:	d2450513          	addi	a0,a0,-732 # ffffffffc0207168 <commands+0x750>
ffffffffc020544c:	dbdfa0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc0205450:	00002617          	auipc	a2,0x2
ffffffffc0205454:	fa860613          	addi	a2,a2,-88 # ffffffffc02073f8 <commands+0x9e0>
ffffffffc0205458:	06900593          	li	a1,105
ffffffffc020545c:	00002517          	auipc	a0,0x2
ffffffffc0205460:	d0c50513          	addi	a0,a0,-756 # ffffffffc0207168 <commands+0x750>
ffffffffc0205464:	da5fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205468:	86be                	mv	a3,a5
ffffffffc020546a:	00002617          	auipc	a2,0x2
ffffffffc020546e:	4fe60613          	addi	a2,a2,1278 # ffffffffc0207968 <commands+0xf50>
ffffffffc0205472:	16500593          	li	a1,357
ffffffffc0205476:	00003517          	auipc	a0,0x3
ffffffffc020547a:	14250513          	addi	a0,a0,322 # ffffffffc02085b8 <default_pmm_manager+0x6f0>
ffffffffc020547e:	d8bfa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(current->wait_state == 0);
ffffffffc0205482:	00003697          	auipc	a3,0x3
ffffffffc0205486:	14e68693          	addi	a3,a3,334 # ffffffffc02085d0 <default_pmm_manager+0x708>
ffffffffc020548a:	00002617          	auipc	a2,0x2
ffffffffc020548e:	99e60613          	addi	a2,a2,-1634 # ffffffffc0206e28 <commands+0x410>
ffffffffc0205492:	1b200593          	li	a1,434
ffffffffc0205496:	00003517          	auipc	a0,0x3
ffffffffc020549a:	12250513          	addi	a0,a0,290 # ffffffffc02085b8 <default_pmm_manager+0x6f0>
ffffffffc020549e:	d6bfa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("Unlock failed.\n");
ffffffffc02054a2:	00003617          	auipc	a2,0x3
ffffffffc02054a6:	14e60613          	addi	a2,a2,334 # ffffffffc02085f0 <default_pmm_manager+0x728>
ffffffffc02054aa:	03100593          	li	a1,49
ffffffffc02054ae:	00003517          	auipc	a0,0x3
ffffffffc02054b2:	15250513          	addi	a0,a0,338 # ffffffffc0208600 <default_pmm_manager+0x738>
ffffffffc02054b6:	d53fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02054ba <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02054ba:	7129                	addi	sp,sp,-320
ffffffffc02054bc:	fa22                	sd	s0,304(sp)
ffffffffc02054be:	f626                	sd	s1,296(sp)
ffffffffc02054c0:	f24a                	sd	s2,288(sp)
ffffffffc02054c2:	84ae                	mv	s1,a1
ffffffffc02054c4:	892a                	mv	s2,a0
ffffffffc02054c6:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02054c8:	4581                	li	a1,0
ffffffffc02054ca:	12000613          	li	a2,288
ffffffffc02054ce:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02054d0:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02054d2:	671000ef          	jal	ra,ffffffffc0206342 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc02054d6:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc02054d8:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02054da:	100027f3          	csrr	a5,sstatus
ffffffffc02054de:	edd7f793          	andi	a5,a5,-291
ffffffffc02054e2:	1207e793          	ori	a5,a5,288
ffffffffc02054e6:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02054e8:	860a                	mv	a2,sp
ffffffffc02054ea:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02054ee:	00000797          	auipc	a5,0x0
ffffffffc02054f2:	9d878793          	addi	a5,a5,-1576 # ffffffffc0204ec6 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02054f6:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02054f8:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02054fa:	bb3ff0ef          	jal	ra,ffffffffc02050ac <do_fork>
}
ffffffffc02054fe:	70f2                	ld	ra,312(sp)
ffffffffc0205500:	7452                	ld	s0,304(sp)
ffffffffc0205502:	74b2                	ld	s1,296(sp)
ffffffffc0205504:	7912                	ld	s2,288(sp)
ffffffffc0205506:	6131                	addi	sp,sp,320
ffffffffc0205508:	8082                	ret

ffffffffc020550a <do_exit>:
do_exit(int error_code) {
ffffffffc020550a:	7179                	addi	sp,sp,-48
ffffffffc020550c:	f022                	sd	s0,32(sp)
    if (current == idleproc) {
ffffffffc020550e:	000ad417          	auipc	s0,0xad
ffffffffc0205512:	41240413          	addi	s0,s0,1042 # ffffffffc02b2920 <current>
ffffffffc0205516:	601c                	ld	a5,0(s0)
do_exit(int error_code) {
ffffffffc0205518:	f406                	sd	ra,40(sp)
ffffffffc020551a:	ec26                	sd	s1,24(sp)
ffffffffc020551c:	e84a                	sd	s2,16(sp)
ffffffffc020551e:	e44e                	sd	s3,8(sp)
ffffffffc0205520:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc0205522:	000ad717          	auipc	a4,0xad
ffffffffc0205526:	40673703          	ld	a4,1030(a4) # ffffffffc02b2928 <idleproc>
ffffffffc020552a:	0ce78c63          	beq	a5,a4,ffffffffc0205602 <do_exit+0xf8>
    if (current == initproc) {
ffffffffc020552e:	000ad497          	auipc	s1,0xad
ffffffffc0205532:	40248493          	addi	s1,s1,1026 # ffffffffc02b2930 <initproc>
ffffffffc0205536:	6098                	ld	a4,0(s1)
ffffffffc0205538:	0ee78b63          	beq	a5,a4,ffffffffc020562e <do_exit+0x124>
    struct mm_struct *mm = current->mm;
ffffffffc020553c:	0287b983          	ld	s3,40(a5)
ffffffffc0205540:	892a                	mv	s2,a0
    if (mm != NULL) {
ffffffffc0205542:	02098663          	beqz	s3,ffffffffc020556e <do_exit+0x64>
ffffffffc0205546:	000ad797          	auipc	a5,0xad
ffffffffc020554a:	3aa7b783          	ld	a5,938(a5) # ffffffffc02b28f0 <boot_cr3>
ffffffffc020554e:	577d                	li	a4,-1
ffffffffc0205550:	177e                	slli	a4,a4,0x3f
ffffffffc0205552:	83b1                	srli	a5,a5,0xc
ffffffffc0205554:	8fd9                	or	a5,a5,a4
ffffffffc0205556:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc020555a:	0309a783          	lw	a5,48(s3) # 1030 <_binary_obj___user_faultread_out_size-0x8b90>
ffffffffc020555e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0205562:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205566:	cb55                	beqz	a4,ffffffffc020561a <do_exit+0x110>
        current->mm = NULL;
ffffffffc0205568:	601c                	ld	a5,0(s0)
ffffffffc020556a:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc020556e:	601c                	ld	a5,0(s0)
ffffffffc0205570:	470d                	li	a4,3
ffffffffc0205572:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc0205574:	0f27a423          	sw	s2,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205578:	100027f3          	csrr	a5,sstatus
ffffffffc020557c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020557e:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205580:	e3f9                	bnez	a5,ffffffffc0205646 <do_exit+0x13c>
        proc = current->parent;
ffffffffc0205582:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD) {
ffffffffc0205584:	800007b7          	lui	a5,0x80000
ffffffffc0205588:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc020558a:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc020558c:	0ec52703          	lw	a4,236(a0)
ffffffffc0205590:	0af70f63          	beq	a4,a5,ffffffffc020564e <do_exit+0x144>
        while (current->cptr != NULL) {
ffffffffc0205594:	6018                	ld	a4,0(s0)
ffffffffc0205596:	7b7c                	ld	a5,240(a4)
ffffffffc0205598:	c3a1                	beqz	a5,ffffffffc02055d8 <do_exit+0xce>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc020559a:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020559e:	490d                	li	s2,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02055a0:	0985                	addi	s3,s3,1
ffffffffc02055a2:	a021                	j	ffffffffc02055aa <do_exit+0xa0>
        while (current->cptr != NULL) {
ffffffffc02055a4:	6018                	ld	a4,0(s0)
ffffffffc02055a6:	7b7c                	ld	a5,240(a4)
ffffffffc02055a8:	cb85                	beqz	a5,ffffffffc02055d8 <do_exit+0xce>
            current->cptr = proc->optr;
ffffffffc02055aa:	1007b683          	ld	a3,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff4fd0>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02055ae:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc02055b0:	fb74                	sd	a3,240(a4)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02055b2:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc02055b4:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02055b8:	10e7b023          	sd	a4,256(a5)
ffffffffc02055bc:	c311                	beqz	a4,ffffffffc02055c0 <do_exit+0xb6>
                initproc->cptr->yptr = proc;
ffffffffc02055be:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02055c0:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc02055c2:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc02055c4:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02055c6:	fd271fe3          	bne	a4,s2,ffffffffc02055a4 <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02055ca:	0ec52783          	lw	a5,236(a0)
ffffffffc02055ce:	fd379be3          	bne	a5,s3,ffffffffc02055a4 <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc02055d2:	309000ef          	jal	ra,ffffffffc02060da <wakeup_proc>
ffffffffc02055d6:	b7f9                	j	ffffffffc02055a4 <do_exit+0x9a>
    if (flag) {
ffffffffc02055d8:	020a1263          	bnez	s4,ffffffffc02055fc <do_exit+0xf2>
    schedule();
ffffffffc02055dc:	37f000ef          	jal	ra,ffffffffc020615a <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc02055e0:	601c                	ld	a5,0(s0)
ffffffffc02055e2:	00003617          	auipc	a2,0x3
ffffffffc02055e6:	05660613          	addi	a2,a2,86 # ffffffffc0208638 <default_pmm_manager+0x770>
ffffffffc02055ea:	20500593          	li	a1,517
ffffffffc02055ee:	43d4                	lw	a3,4(a5)
ffffffffc02055f0:	00003517          	auipc	a0,0x3
ffffffffc02055f4:	fc850513          	addi	a0,a0,-56 # ffffffffc02085b8 <default_pmm_manager+0x6f0>
ffffffffc02055f8:	c11fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        intr_enable();
ffffffffc02055fc:	846fb0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0205600:	bff1                	j	ffffffffc02055dc <do_exit+0xd2>
        panic("idleproc exit.\n");
ffffffffc0205602:	00003617          	auipc	a2,0x3
ffffffffc0205606:	01660613          	addi	a2,a2,22 # ffffffffc0208618 <default_pmm_manager+0x750>
ffffffffc020560a:	1d900593          	li	a1,473
ffffffffc020560e:	00003517          	auipc	a0,0x3
ffffffffc0205612:	faa50513          	addi	a0,a0,-86 # ffffffffc02085b8 <default_pmm_manager+0x6f0>
ffffffffc0205616:	bf3fa0ef          	jal	ra,ffffffffc0200208 <__panic>
            exit_mmap(mm);
ffffffffc020561a:	854e                	mv	a0,s3
ffffffffc020561c:	b69fb0ef          	jal	ra,ffffffffc0201184 <exit_mmap>
            put_pgdir(mm);
ffffffffc0205620:	854e                	mv	a0,s3
ffffffffc0205622:	9b1ff0ef          	jal	ra,ffffffffc0204fd2 <put_pgdir>
            mm_destroy(mm);
ffffffffc0205626:	854e                	mv	a0,s3
ffffffffc0205628:	9c1fb0ef          	jal	ra,ffffffffc0200fe8 <mm_destroy>
ffffffffc020562c:	bf35                	j	ffffffffc0205568 <do_exit+0x5e>
        panic("initproc exit.\n");
ffffffffc020562e:	00003617          	auipc	a2,0x3
ffffffffc0205632:	ffa60613          	addi	a2,a2,-6 # ffffffffc0208628 <default_pmm_manager+0x760>
ffffffffc0205636:	1dc00593          	li	a1,476
ffffffffc020563a:	00003517          	auipc	a0,0x3
ffffffffc020563e:	f7e50513          	addi	a0,a0,-130 # ffffffffc02085b8 <default_pmm_manager+0x6f0>
ffffffffc0205642:	bc7fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        intr_disable();
ffffffffc0205646:	802fb0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc020564a:	4a05                	li	s4,1
ffffffffc020564c:	bf1d                	j	ffffffffc0205582 <do_exit+0x78>
            wakeup_proc(proc);
ffffffffc020564e:	28d000ef          	jal	ra,ffffffffc02060da <wakeup_proc>
ffffffffc0205652:	b789                	j	ffffffffc0205594 <do_exit+0x8a>

ffffffffc0205654 <do_wait.part.0>:
do_wait(int pid, int *code_store) {
ffffffffc0205654:	715d                	addi	sp,sp,-80
ffffffffc0205656:	f84a                	sd	s2,48(sp)
ffffffffc0205658:	f44e                	sd	s3,40(sp)
        current->wait_state = WT_CHILD;
ffffffffc020565a:	80000937          	lui	s2,0x80000
    if (0 < pid && pid < MAX_PID) {
ffffffffc020565e:	6989                	lui	s3,0x2
do_wait(int pid, int *code_store) {
ffffffffc0205660:	fc26                	sd	s1,56(sp)
ffffffffc0205662:	f052                	sd	s4,32(sp)
ffffffffc0205664:	ec56                	sd	s5,24(sp)
ffffffffc0205666:	e85a                	sd	s6,16(sp)
ffffffffc0205668:	e45e                	sd	s7,8(sp)
ffffffffc020566a:	e486                	sd	ra,72(sp)
ffffffffc020566c:	e0a2                	sd	s0,64(sp)
ffffffffc020566e:	84aa                	mv	s1,a0
ffffffffc0205670:	8a2e                	mv	s4,a1
        proc = current->cptr;
ffffffffc0205672:	000adb97          	auipc	s7,0xad
ffffffffc0205676:	2aeb8b93          	addi	s7,s7,686 # ffffffffc02b2920 <current>
    if (0 < pid && pid < MAX_PID) {
ffffffffc020567a:	00050b1b          	sext.w	s6,a0
ffffffffc020567e:	fff50a9b          	addiw	s5,a0,-1
ffffffffc0205682:	19f9                	addi	s3,s3,-2
        current->wait_state = WT_CHILD;
ffffffffc0205684:	0905                	addi	s2,s2,1
    if (pid != 0) {
ffffffffc0205686:	ccbd                	beqz	s1,ffffffffc0205704 <do_wait.part.0+0xb0>
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205688:	0359e863          	bltu	s3,s5,ffffffffc02056b8 <do_wait.part.0+0x64>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc020568c:	45a9                	li	a1,10
ffffffffc020568e:	855a                	mv	a0,s6
ffffffffc0205690:	0ca010ef          	jal	ra,ffffffffc020675a <hash32>
ffffffffc0205694:	02051793          	slli	a5,a0,0x20
ffffffffc0205698:	01c7d513          	srli	a0,a5,0x1c
ffffffffc020569c:	000a9797          	auipc	a5,0xa9
ffffffffc02056a0:	1fc78793          	addi	a5,a5,508 # ffffffffc02ae898 <hash_list>
ffffffffc02056a4:	953e                	add	a0,a0,a5
ffffffffc02056a6:	842a                	mv	s0,a0
        while ((le = list_next(le)) != list) {
ffffffffc02056a8:	a029                	j	ffffffffc02056b2 <do_wait.part.0+0x5e>
            if (proc->pid == pid) {
ffffffffc02056aa:	f2c42783          	lw	a5,-212(s0)
ffffffffc02056ae:	02978163          	beq	a5,s1,ffffffffc02056d0 <do_wait.part.0+0x7c>
ffffffffc02056b2:	6400                	ld	s0,8(s0)
        while ((le = list_next(le)) != list) {
ffffffffc02056b4:	fe851be3          	bne	a0,s0,ffffffffc02056aa <do_wait.part.0+0x56>
    return -E_BAD_PROC;
ffffffffc02056b8:	5579                	li	a0,-2
}
ffffffffc02056ba:	60a6                	ld	ra,72(sp)
ffffffffc02056bc:	6406                	ld	s0,64(sp)
ffffffffc02056be:	74e2                	ld	s1,56(sp)
ffffffffc02056c0:	7942                	ld	s2,48(sp)
ffffffffc02056c2:	79a2                	ld	s3,40(sp)
ffffffffc02056c4:	7a02                	ld	s4,32(sp)
ffffffffc02056c6:	6ae2                	ld	s5,24(sp)
ffffffffc02056c8:	6b42                	ld	s6,16(sp)
ffffffffc02056ca:	6ba2                	ld	s7,8(sp)
ffffffffc02056cc:	6161                	addi	sp,sp,80
ffffffffc02056ce:	8082                	ret
        if (proc != NULL && proc->parent == current) {
ffffffffc02056d0:	000bb683          	ld	a3,0(s7)
ffffffffc02056d4:	f4843783          	ld	a5,-184(s0)
ffffffffc02056d8:	fed790e3          	bne	a5,a3,ffffffffc02056b8 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02056dc:	f2842703          	lw	a4,-216(s0)
ffffffffc02056e0:	478d                	li	a5,3
ffffffffc02056e2:	0ef70b63          	beq	a4,a5,ffffffffc02057d8 <do_wait.part.0+0x184>
        current->state = PROC_SLEEPING;
ffffffffc02056e6:	4785                	li	a5,1
ffffffffc02056e8:	c29c                	sw	a5,0(a3)
        current->wait_state = WT_CHILD;
ffffffffc02056ea:	0f26a623          	sw	s2,236(a3)
        schedule();
ffffffffc02056ee:	26d000ef          	jal	ra,ffffffffc020615a <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc02056f2:	000bb783          	ld	a5,0(s7)
ffffffffc02056f6:	0b07a783          	lw	a5,176(a5)
ffffffffc02056fa:	8b85                	andi	a5,a5,1
ffffffffc02056fc:	d7c9                	beqz	a5,ffffffffc0205686 <do_wait.part.0+0x32>
            do_exit(-E_KILLED);
ffffffffc02056fe:	555d                	li	a0,-9
ffffffffc0205700:	e0bff0ef          	jal	ra,ffffffffc020550a <do_exit>
        proc = current->cptr;
ffffffffc0205704:	000bb683          	ld	a3,0(s7)
ffffffffc0205708:	7ae0                	ld	s0,240(a3)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc020570a:	d45d                	beqz	s0,ffffffffc02056b8 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020570c:	470d                	li	a4,3
ffffffffc020570e:	a021                	j	ffffffffc0205716 <do_wait.part.0+0xc2>
        for (; proc != NULL; proc = proc->optr) {
ffffffffc0205710:	10043403          	ld	s0,256(s0)
ffffffffc0205714:	d869                	beqz	s0,ffffffffc02056e6 <do_wait.part.0+0x92>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205716:	401c                	lw	a5,0(s0)
ffffffffc0205718:	fee79ce3          	bne	a5,a4,ffffffffc0205710 <do_wait.part.0+0xbc>
    if (proc == idleproc || proc == initproc) {
ffffffffc020571c:	000ad797          	auipc	a5,0xad
ffffffffc0205720:	20c7b783          	ld	a5,524(a5) # ffffffffc02b2928 <idleproc>
ffffffffc0205724:	0c878963          	beq	a5,s0,ffffffffc02057f6 <do_wait.part.0+0x1a2>
ffffffffc0205728:	000ad797          	auipc	a5,0xad
ffffffffc020572c:	2087b783          	ld	a5,520(a5) # ffffffffc02b2930 <initproc>
ffffffffc0205730:	0cf40363          	beq	s0,a5,ffffffffc02057f6 <do_wait.part.0+0x1a2>
    if (code_store != NULL) {
ffffffffc0205734:	000a0663          	beqz	s4,ffffffffc0205740 <do_wait.part.0+0xec>
        *code_store = proc->exit_code;
ffffffffc0205738:	0e842783          	lw	a5,232(s0)
ffffffffc020573c:	00fa2023          	sw	a5,0(s4)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205740:	100027f3          	csrr	a5,sstatus
ffffffffc0205744:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205746:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205748:	e7c1                	bnez	a5,ffffffffc02057d0 <do_wait.part.0+0x17c>
    __list_del(listelm->prev, listelm->next);
ffffffffc020574a:	6c70                	ld	a2,216(s0)
ffffffffc020574c:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc020574e:	10043703          	ld	a4,256(s0)
        proc->optr->yptr = proc->yptr;
ffffffffc0205752:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc0205754:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0205756:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0205758:	6470                	ld	a2,200(s0)
ffffffffc020575a:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc020575c:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc020575e:	e290                	sd	a2,0(a3)
    if (proc->optr != NULL) {
ffffffffc0205760:	c319                	beqz	a4,ffffffffc0205766 <do_wait.part.0+0x112>
        proc->optr->yptr = proc->yptr;
ffffffffc0205762:	ff7c                	sd	a5,248(a4)
    if (proc->yptr != NULL) {
ffffffffc0205764:	7c7c                	ld	a5,248(s0)
ffffffffc0205766:	c3b5                	beqz	a5,ffffffffc02057ca <do_wait.part.0+0x176>
        proc->yptr->optr = proc->optr;
ffffffffc0205768:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc020576c:	000ad717          	auipc	a4,0xad
ffffffffc0205770:	1cc70713          	addi	a4,a4,460 # ffffffffc02b2938 <nr_process>
ffffffffc0205774:	431c                	lw	a5,0(a4)
ffffffffc0205776:	37fd                	addiw	a5,a5,-1
ffffffffc0205778:	c31c                	sw	a5,0(a4)
    if (flag) {
ffffffffc020577a:	e5a9                	bnez	a1,ffffffffc02057c4 <do_wait.part.0+0x170>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc020577c:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc020577e:	c02007b7          	lui	a5,0xc0200
ffffffffc0205782:	04f6ee63          	bltu	a3,a5,ffffffffc02057de <do_wait.part.0+0x18a>
ffffffffc0205786:	000ad797          	auipc	a5,0xad
ffffffffc020578a:	1927b783          	ld	a5,402(a5) # ffffffffc02b2918 <va_pa_offset>
ffffffffc020578e:	8e9d                	sub	a3,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc0205790:	82b1                	srli	a3,a3,0xc
ffffffffc0205792:	000ad797          	auipc	a5,0xad
ffffffffc0205796:	16e7b783          	ld	a5,366(a5) # ffffffffc02b2900 <npage>
ffffffffc020579a:	06f6fa63          	bgeu	a3,a5,ffffffffc020580e <do_wait.part.0+0x1ba>
    return &pages[PPN(pa) - nbase];
ffffffffc020579e:	00003517          	auipc	a0,0x3
ffffffffc02057a2:	6d253503          	ld	a0,1746(a0) # ffffffffc0208e70 <nbase>
ffffffffc02057a6:	8e89                	sub	a3,a3,a0
ffffffffc02057a8:	069a                	slli	a3,a3,0x6
ffffffffc02057aa:	000ad517          	auipc	a0,0xad
ffffffffc02057ae:	15e53503          	ld	a0,350(a0) # ffffffffc02b2908 <pages>
ffffffffc02057b2:	9536                	add	a0,a0,a3
ffffffffc02057b4:	4589                	li	a1,2
ffffffffc02057b6:	e35fd0ef          	jal	ra,ffffffffc02035ea <free_pages>
    kfree(proc);
ffffffffc02057ba:	8522                	mv	a0,s0
ffffffffc02057bc:	dcffc0ef          	jal	ra,ffffffffc020258a <kfree>
    return 0;
ffffffffc02057c0:	4501                	li	a0,0
ffffffffc02057c2:	bde5                	j	ffffffffc02056ba <do_wait.part.0+0x66>
        intr_enable();
ffffffffc02057c4:	e7ffa0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc02057c8:	bf55                	j	ffffffffc020577c <do_wait.part.0+0x128>
       proc->parent->cptr = proc->optr;
ffffffffc02057ca:	701c                	ld	a5,32(s0)
ffffffffc02057cc:	fbf8                	sd	a4,240(a5)
ffffffffc02057ce:	bf79                	j	ffffffffc020576c <do_wait.part.0+0x118>
        intr_disable();
ffffffffc02057d0:	e79fa0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc02057d4:	4585                	li	a1,1
ffffffffc02057d6:	bf95                	j	ffffffffc020574a <do_wait.part.0+0xf6>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02057d8:	f2840413          	addi	s0,s0,-216
ffffffffc02057dc:	b781                	j	ffffffffc020571c <do_wait.part.0+0xc8>
    return pa2page(PADDR(kva));
ffffffffc02057de:	00002617          	auipc	a2,0x2
ffffffffc02057e2:	18a60613          	addi	a2,a2,394 # ffffffffc0207968 <commands+0xf50>
ffffffffc02057e6:	06e00593          	li	a1,110
ffffffffc02057ea:	00002517          	auipc	a0,0x2
ffffffffc02057ee:	97e50513          	addi	a0,a0,-1666 # ffffffffc0207168 <commands+0x750>
ffffffffc02057f2:	a17fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("wait idleproc or initproc.\n");
ffffffffc02057f6:	00003617          	auipc	a2,0x3
ffffffffc02057fa:	e6260613          	addi	a2,a2,-414 # ffffffffc0208658 <default_pmm_manager+0x790>
ffffffffc02057fe:	2fd00593          	li	a1,765
ffffffffc0205802:	00003517          	auipc	a0,0x3
ffffffffc0205806:	db650513          	addi	a0,a0,-586 # ffffffffc02085b8 <default_pmm_manager+0x6f0>
ffffffffc020580a:	9fffa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020580e:	00002617          	auipc	a2,0x2
ffffffffc0205812:	93a60613          	addi	a2,a2,-1734 # ffffffffc0207148 <commands+0x730>
ffffffffc0205816:	06200593          	li	a1,98
ffffffffc020581a:	00002517          	auipc	a0,0x2
ffffffffc020581e:	94e50513          	addi	a0,a0,-1714 # ffffffffc0207168 <commands+0x750>
ffffffffc0205822:	9e7fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205826 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc0205826:	1141                	addi	sp,sp,-16
ffffffffc0205828:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020582a:	e01fd0ef          	jal	ra,ffffffffc020362a <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc020582e:	ca9fc0ef          	jal	ra,ffffffffc02024d6 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc0205832:	4601                	li	a2,0
ffffffffc0205834:	4581                	li	a1,0
ffffffffc0205836:	fffff517          	auipc	a0,0xfffff
ffffffffc020583a:	71e50513          	addi	a0,a0,1822 # ffffffffc0204f54 <user_main>
ffffffffc020583e:	c7dff0ef          	jal	ra,ffffffffc02054ba <kernel_thread>
    if (pid <= 0) {
ffffffffc0205842:	00a04563          	bgtz	a0,ffffffffc020584c <init_main+0x26>
ffffffffc0205846:	a071                	j	ffffffffc02058d2 <init_main+0xac>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
ffffffffc0205848:	113000ef          	jal	ra,ffffffffc020615a <schedule>
    if (code_store != NULL) {
ffffffffc020584c:	4581                	li	a1,0
ffffffffc020584e:	4501                	li	a0,0
ffffffffc0205850:	e05ff0ef          	jal	ra,ffffffffc0205654 <do_wait.part.0>
    while (do_wait(0, NULL) == 0) {
ffffffffc0205854:	d975                	beqz	a0,ffffffffc0205848 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc0205856:	00003517          	auipc	a0,0x3
ffffffffc020585a:	e4250513          	addi	a0,a0,-446 # ffffffffc0208698 <default_pmm_manager+0x7d0>
ffffffffc020585e:	86ffa0ef          	jal	ra,ffffffffc02000cc <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0205862:	000ad797          	auipc	a5,0xad
ffffffffc0205866:	0ce7b783          	ld	a5,206(a5) # ffffffffc02b2930 <initproc>
ffffffffc020586a:	7bf8                	ld	a4,240(a5)
ffffffffc020586c:	e339                	bnez	a4,ffffffffc02058b2 <init_main+0x8c>
ffffffffc020586e:	7ff8                	ld	a4,248(a5)
ffffffffc0205870:	e329                	bnez	a4,ffffffffc02058b2 <init_main+0x8c>
ffffffffc0205872:	1007b703          	ld	a4,256(a5)
ffffffffc0205876:	ef15                	bnez	a4,ffffffffc02058b2 <init_main+0x8c>
    assert(nr_process == 2);
ffffffffc0205878:	000ad697          	auipc	a3,0xad
ffffffffc020587c:	0c06a683          	lw	a3,192(a3) # ffffffffc02b2938 <nr_process>
ffffffffc0205880:	4709                	li	a4,2
ffffffffc0205882:	0ae69463          	bne	a3,a4,ffffffffc020592a <init_main+0x104>
    return listelm->next;
ffffffffc0205886:	000ad697          	auipc	a3,0xad
ffffffffc020588a:	01268693          	addi	a3,a3,18 # ffffffffc02b2898 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc020588e:	6698                	ld	a4,8(a3)
ffffffffc0205890:	0c878793          	addi	a5,a5,200
ffffffffc0205894:	06f71b63          	bne	a4,a5,ffffffffc020590a <init_main+0xe4>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0205898:	629c                	ld	a5,0(a3)
ffffffffc020589a:	04f71863          	bne	a4,a5,ffffffffc02058ea <init_main+0xc4>

    cprintf("init check memory pass.\n");
ffffffffc020589e:	00003517          	auipc	a0,0x3
ffffffffc02058a2:	ee250513          	addi	a0,a0,-286 # ffffffffc0208780 <default_pmm_manager+0x8b8>
ffffffffc02058a6:	827fa0ef          	jal	ra,ffffffffc02000cc <cprintf>
    return 0;
}
ffffffffc02058aa:	60a2                	ld	ra,8(sp)
ffffffffc02058ac:	4501                	li	a0,0
ffffffffc02058ae:	0141                	addi	sp,sp,16
ffffffffc02058b0:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc02058b2:	00003697          	auipc	a3,0x3
ffffffffc02058b6:	e0e68693          	addi	a3,a3,-498 # ffffffffc02086c0 <default_pmm_manager+0x7f8>
ffffffffc02058ba:	00001617          	auipc	a2,0x1
ffffffffc02058be:	56e60613          	addi	a2,a2,1390 # ffffffffc0206e28 <commands+0x410>
ffffffffc02058c2:	36200593          	li	a1,866
ffffffffc02058c6:	00003517          	auipc	a0,0x3
ffffffffc02058ca:	cf250513          	addi	a0,a0,-782 # ffffffffc02085b8 <default_pmm_manager+0x6f0>
ffffffffc02058ce:	93bfa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("create user_main failed.\n");
ffffffffc02058d2:	00003617          	auipc	a2,0x3
ffffffffc02058d6:	da660613          	addi	a2,a2,-602 # ffffffffc0208678 <default_pmm_manager+0x7b0>
ffffffffc02058da:	35a00593          	li	a1,858
ffffffffc02058de:	00003517          	auipc	a0,0x3
ffffffffc02058e2:	cda50513          	addi	a0,a0,-806 # ffffffffc02085b8 <default_pmm_manager+0x6f0>
ffffffffc02058e6:	923fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02058ea:	00003697          	auipc	a3,0x3
ffffffffc02058ee:	e6668693          	addi	a3,a3,-410 # ffffffffc0208750 <default_pmm_manager+0x888>
ffffffffc02058f2:	00001617          	auipc	a2,0x1
ffffffffc02058f6:	53660613          	addi	a2,a2,1334 # ffffffffc0206e28 <commands+0x410>
ffffffffc02058fa:	36500593          	li	a1,869
ffffffffc02058fe:	00003517          	auipc	a0,0x3
ffffffffc0205902:	cba50513          	addi	a0,a0,-838 # ffffffffc02085b8 <default_pmm_manager+0x6f0>
ffffffffc0205906:	903fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc020590a:	00003697          	auipc	a3,0x3
ffffffffc020590e:	e1668693          	addi	a3,a3,-490 # ffffffffc0208720 <default_pmm_manager+0x858>
ffffffffc0205912:	00001617          	auipc	a2,0x1
ffffffffc0205916:	51660613          	addi	a2,a2,1302 # ffffffffc0206e28 <commands+0x410>
ffffffffc020591a:	36400593          	li	a1,868
ffffffffc020591e:	00003517          	auipc	a0,0x3
ffffffffc0205922:	c9a50513          	addi	a0,a0,-870 # ffffffffc02085b8 <default_pmm_manager+0x6f0>
ffffffffc0205926:	8e3fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_process == 2);
ffffffffc020592a:	00003697          	auipc	a3,0x3
ffffffffc020592e:	de668693          	addi	a3,a3,-538 # ffffffffc0208710 <default_pmm_manager+0x848>
ffffffffc0205932:	00001617          	auipc	a2,0x1
ffffffffc0205936:	4f660613          	addi	a2,a2,1270 # ffffffffc0206e28 <commands+0x410>
ffffffffc020593a:	36300593          	li	a1,867
ffffffffc020593e:	00003517          	auipc	a0,0x3
ffffffffc0205942:	c7a50513          	addi	a0,a0,-902 # ffffffffc02085b8 <default_pmm_manager+0x6f0>
ffffffffc0205946:	8c3fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020594a <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc020594a:	7171                	addi	sp,sp,-176
ffffffffc020594c:	e4ee                	sd	s11,72(sp)
    struct mm_struct *mm = current->mm;
ffffffffc020594e:	000add97          	auipc	s11,0xad
ffffffffc0205952:	fd2d8d93          	addi	s11,s11,-46 # ffffffffc02b2920 <current>
ffffffffc0205956:	000db783          	ld	a5,0(s11)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc020595a:	e54e                	sd	s3,136(sp)
ffffffffc020595c:	ed26                	sd	s1,152(sp)
    struct mm_struct *mm = current->mm;
ffffffffc020595e:	0287b983          	ld	s3,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205962:	e94a                	sd	s2,144(sp)
ffffffffc0205964:	f4de                	sd	s7,104(sp)
ffffffffc0205966:	892a                	mv	s2,a0
ffffffffc0205968:	8bb2                	mv	s7,a2
ffffffffc020596a:	84ae                	mv	s1,a1
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc020596c:	862e                	mv	a2,a1
ffffffffc020596e:	4681                	li	a3,0
ffffffffc0205970:	85aa                	mv	a1,a0
ffffffffc0205972:	854e                	mv	a0,s3
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205974:	f506                	sd	ra,168(sp)
ffffffffc0205976:	f122                	sd	s0,160(sp)
ffffffffc0205978:	e152                	sd	s4,128(sp)
ffffffffc020597a:	fcd6                	sd	s5,120(sp)
ffffffffc020597c:	f8da                	sd	s6,112(sp)
ffffffffc020597e:	f0e2                	sd	s8,96(sp)
ffffffffc0205980:	ece6                	sd	s9,88(sp)
ffffffffc0205982:	e8ea                	sd	s10,80(sp)
ffffffffc0205984:	f05e                	sd	s7,32(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc0205986:	f87fb0ef          	jal	ra,ffffffffc020190c <user_mem_check>
ffffffffc020598a:	40050a63          	beqz	a0,ffffffffc0205d9e <do_execve+0x454>
    memset(local_name, 0, sizeof(local_name));
ffffffffc020598e:	4641                	li	a2,16
ffffffffc0205990:	4581                	li	a1,0
ffffffffc0205992:	1808                	addi	a0,sp,48
ffffffffc0205994:	1af000ef          	jal	ra,ffffffffc0206342 <memset>
    memcpy(local_name, name, len);
ffffffffc0205998:	47bd                	li	a5,15
ffffffffc020599a:	8626                	mv	a2,s1
ffffffffc020599c:	1e97e263          	bltu	a5,s1,ffffffffc0205b80 <do_execve+0x236>
ffffffffc02059a0:	85ca                	mv	a1,s2
ffffffffc02059a2:	1808                	addi	a0,sp,48
ffffffffc02059a4:	1b1000ef          	jal	ra,ffffffffc0206354 <memcpy>
    if (mm != NULL) {
ffffffffc02059a8:	1e098363          	beqz	s3,ffffffffc0205b8e <do_execve+0x244>
        cputs("mm != NULL");
ffffffffc02059ac:	00002517          	auipc	a0,0x2
ffffffffc02059b0:	84450513          	addi	a0,a0,-1980 # ffffffffc02071f0 <commands+0x7d8>
ffffffffc02059b4:	f50fa0ef          	jal	ra,ffffffffc0200104 <cputs>
ffffffffc02059b8:	000ad797          	auipc	a5,0xad
ffffffffc02059bc:	f387b783          	ld	a5,-200(a5) # ffffffffc02b28f0 <boot_cr3>
ffffffffc02059c0:	577d                	li	a4,-1
ffffffffc02059c2:	177e                	slli	a4,a4,0x3f
ffffffffc02059c4:	83b1                	srli	a5,a5,0xc
ffffffffc02059c6:	8fd9                	or	a5,a5,a4
ffffffffc02059c8:	18079073          	csrw	satp,a5
ffffffffc02059cc:	0309a783          	lw	a5,48(s3) # 2030 <_binary_obj___user_faultread_out_size-0x7b90>
ffffffffc02059d0:	fff7871b          	addiw	a4,a5,-1
ffffffffc02059d4:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc02059d8:	2c070463          	beqz	a4,ffffffffc0205ca0 <do_execve+0x356>
        current->mm = NULL;
ffffffffc02059dc:	000db783          	ld	a5,0(s11)
ffffffffc02059e0:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc02059e4:	c7efb0ef          	jal	ra,ffffffffc0200e62 <mm_create>
ffffffffc02059e8:	84aa                	mv	s1,a0
ffffffffc02059ea:	1c050d63          	beqz	a0,ffffffffc0205bc4 <do_execve+0x27a>
    if ((page = alloc_page()) == NULL) {
ffffffffc02059ee:	4505                	li	a0,1
ffffffffc02059f0:	b69fd0ef          	jal	ra,ffffffffc0203558 <alloc_pages>
ffffffffc02059f4:	3a050963          	beqz	a0,ffffffffc0205da6 <do_execve+0x45c>
    return page - pages + nbase;
ffffffffc02059f8:	000adc97          	auipc	s9,0xad
ffffffffc02059fc:	f10c8c93          	addi	s9,s9,-240 # ffffffffc02b2908 <pages>
ffffffffc0205a00:	000cb683          	ld	a3,0(s9)
    return KADDR(page2pa(page));
ffffffffc0205a04:	000adc17          	auipc	s8,0xad
ffffffffc0205a08:	efcc0c13          	addi	s8,s8,-260 # ffffffffc02b2900 <npage>
    return page - pages + nbase;
ffffffffc0205a0c:	00003717          	auipc	a4,0x3
ffffffffc0205a10:	46473703          	ld	a4,1124(a4) # ffffffffc0208e70 <nbase>
ffffffffc0205a14:	40d506b3          	sub	a3,a0,a3
ffffffffc0205a18:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205a1a:	5afd                	li	s5,-1
ffffffffc0205a1c:	000c3783          	ld	a5,0(s8)
    return page - pages + nbase;
ffffffffc0205a20:	96ba                	add	a3,a3,a4
ffffffffc0205a22:	e83a                	sd	a4,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205a24:	00cad713          	srli	a4,s5,0xc
ffffffffc0205a28:	ec3a                	sd	a4,24(sp)
ffffffffc0205a2a:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0205a2c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205a2e:	38f77063          	bgeu	a4,a5,ffffffffc0205dae <do_execve+0x464>
ffffffffc0205a32:	000adb17          	auipc	s6,0xad
ffffffffc0205a36:	ee6b0b13          	addi	s6,s6,-282 # ffffffffc02b2918 <va_pa_offset>
ffffffffc0205a3a:	000b3903          	ld	s2,0(s6)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc0205a3e:	6605                	lui	a2,0x1
ffffffffc0205a40:	000ad597          	auipc	a1,0xad
ffffffffc0205a44:	eb85b583          	ld	a1,-328(a1) # ffffffffc02b28f8 <boot_pgdir>
ffffffffc0205a48:	9936                	add	s2,s2,a3
ffffffffc0205a4a:	854a                	mv	a0,s2
ffffffffc0205a4c:	109000ef          	jal	ra,ffffffffc0206354 <memcpy>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc0205a50:	7782                	ld	a5,32(sp)
ffffffffc0205a52:	4398                	lw	a4,0(a5)
ffffffffc0205a54:	464c47b7          	lui	a5,0x464c4
    mm->pgdir = pgdir;
ffffffffc0205a58:	0124bc23          	sd	s2,24(s1)
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc0205a5c:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b944f>
ffffffffc0205a60:	14f71863          	bne	a4,a5,ffffffffc0205bb0 <do_execve+0x266>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205a64:	7682                	ld	a3,32(sp)
ffffffffc0205a66:	0386d703          	lhu	a4,56(a3)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205a6a:	0206b983          	ld	s3,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205a6e:	00371793          	slli	a5,a4,0x3
ffffffffc0205a72:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205a74:	99b6                	add	s3,s3,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205a76:	078e                	slli	a5,a5,0x3
ffffffffc0205a78:	97ce                	add	a5,a5,s3
ffffffffc0205a7a:	f43e                	sd	a5,40(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc0205a7c:	00f9fc63          	bgeu	s3,a5,ffffffffc0205a94 <do_execve+0x14a>
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc0205a80:	0009a783          	lw	a5,0(s3)
ffffffffc0205a84:	4705                	li	a4,1
ffffffffc0205a86:	14e78163          	beq	a5,a4,ffffffffc0205bc8 <do_execve+0x27e>
    for (; ph < ph_end; ph ++) {
ffffffffc0205a8a:	77a2                	ld	a5,40(sp)
ffffffffc0205a8c:	03898993          	addi	s3,s3,56
ffffffffc0205a90:	fef9e8e3          	bltu	s3,a5,ffffffffc0205a80 <do_execve+0x136>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc0205a94:	4701                	li	a4,0
ffffffffc0205a96:	46ad                	li	a3,11
ffffffffc0205a98:	00100637          	lui	a2,0x100
ffffffffc0205a9c:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0205aa0:	8526                	mv	a0,s1
ffffffffc0205aa2:	d98fb0ef          	jal	ra,ffffffffc020103a <mm_map>
ffffffffc0205aa6:	8a2a                	mv	s4,a0
ffffffffc0205aa8:	1e051263          	bnez	a0,ffffffffc0205c8c <do_execve+0x342>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205aac:	6c88                	ld	a0,24(s1)
ffffffffc0205aae:	467d                	li	a2,31
ffffffffc0205ab0:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0205ab4:	99aff0ef          	jal	ra,ffffffffc0204c4e <pgdir_alloc_page>
ffffffffc0205ab8:	38050363          	beqz	a0,ffffffffc0205e3e <do_execve+0x4f4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205abc:	6c88                	ld	a0,24(s1)
ffffffffc0205abe:	467d                	li	a2,31
ffffffffc0205ac0:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0205ac4:	98aff0ef          	jal	ra,ffffffffc0204c4e <pgdir_alloc_page>
ffffffffc0205ac8:	34050b63          	beqz	a0,ffffffffc0205e1e <do_execve+0x4d4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205acc:	6c88                	ld	a0,24(s1)
ffffffffc0205ace:	467d                	li	a2,31
ffffffffc0205ad0:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0205ad4:	97aff0ef          	jal	ra,ffffffffc0204c4e <pgdir_alloc_page>
ffffffffc0205ad8:	32050363          	beqz	a0,ffffffffc0205dfe <do_execve+0x4b4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205adc:	6c88                	ld	a0,24(s1)
ffffffffc0205ade:	467d                	li	a2,31
ffffffffc0205ae0:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0205ae4:	96aff0ef          	jal	ra,ffffffffc0204c4e <pgdir_alloc_page>
ffffffffc0205ae8:	2e050b63          	beqz	a0,ffffffffc0205dde <do_execve+0x494>
    mm->mm_count += 1;
ffffffffc0205aec:	589c                	lw	a5,48(s1)
    current->mm = mm;
ffffffffc0205aee:	000db603          	ld	a2,0(s11)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205af2:	6c94                	ld	a3,24(s1)
ffffffffc0205af4:	2785                	addiw	a5,a5,1
ffffffffc0205af6:	d89c                	sw	a5,48(s1)
    current->mm = mm;
ffffffffc0205af8:	f604                	sd	s1,40(a2)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205afa:	c02007b7          	lui	a5,0xc0200
ffffffffc0205afe:	2cf6e463          	bltu	a3,a5,ffffffffc0205dc6 <do_execve+0x47c>
ffffffffc0205b02:	000b3783          	ld	a5,0(s6)
ffffffffc0205b06:	577d                	li	a4,-1
ffffffffc0205b08:	177e                	slli	a4,a4,0x3f
ffffffffc0205b0a:	8e9d                	sub	a3,a3,a5
ffffffffc0205b0c:	00c6d793          	srli	a5,a3,0xc
ffffffffc0205b10:	f654                	sd	a3,168(a2)
ffffffffc0205b12:	8fd9                	or	a5,a5,a4
ffffffffc0205b14:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0205b18:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205b1a:	4581                	li	a1,0
ffffffffc0205b1c:	12000613          	li	a2,288
ffffffffc0205b20:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc0205b22:	10043483          	ld	s1,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205b26:	01d000ef          	jal	ra,ffffffffc0206342 <memset>
    tf->epc = elf->e_entry;
ffffffffc0205b2a:	7782                	ld	a5,32(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205b2c:	000db903          	ld	s2,0(s11)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0205b30:	edf4f493          	andi	s1,s1,-289
    tf->epc = elf->e_entry;
ffffffffc0205b34:	6f98                	ld	a4,24(a5)
    tf->gpr.sp = USTACKTOP;
ffffffffc0205b36:	4785                	li	a5,1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205b38:	0b490913          	addi	s2,s2,180 # ffffffff800000b4 <_binary_obj___user_exit_out_size+0xffffffff7fff4f84>
    tf->gpr.sp = USTACKTOP;
ffffffffc0205b3c:	07fe                	slli	a5,a5,0x1f
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0205b3e:	0204e493          	ori	s1,s1,32
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205b42:	4641                	li	a2,16
ffffffffc0205b44:	4581                	li	a1,0
    tf->gpr.sp = USTACKTOP;
ffffffffc0205b46:	e81c                	sd	a5,16(s0)
    tf->epc = elf->e_entry;
ffffffffc0205b48:	10e43423          	sd	a4,264(s0)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0205b4c:	10943023          	sd	s1,256(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205b50:	854a                	mv	a0,s2
ffffffffc0205b52:	7f0000ef          	jal	ra,ffffffffc0206342 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205b56:	463d                	li	a2,15
ffffffffc0205b58:	180c                	addi	a1,sp,48
ffffffffc0205b5a:	854a                	mv	a0,s2
ffffffffc0205b5c:	7f8000ef          	jal	ra,ffffffffc0206354 <memcpy>
}
ffffffffc0205b60:	70aa                	ld	ra,168(sp)
ffffffffc0205b62:	740a                	ld	s0,160(sp)
ffffffffc0205b64:	64ea                	ld	s1,152(sp)
ffffffffc0205b66:	694a                	ld	s2,144(sp)
ffffffffc0205b68:	69aa                	ld	s3,136(sp)
ffffffffc0205b6a:	7ae6                	ld	s5,120(sp)
ffffffffc0205b6c:	7b46                	ld	s6,112(sp)
ffffffffc0205b6e:	7ba6                	ld	s7,104(sp)
ffffffffc0205b70:	7c06                	ld	s8,96(sp)
ffffffffc0205b72:	6ce6                	ld	s9,88(sp)
ffffffffc0205b74:	6d46                	ld	s10,80(sp)
ffffffffc0205b76:	6da6                	ld	s11,72(sp)
ffffffffc0205b78:	8552                	mv	a0,s4
ffffffffc0205b7a:	6a0a                	ld	s4,128(sp)
ffffffffc0205b7c:	614d                	addi	sp,sp,176
ffffffffc0205b7e:	8082                	ret
    memcpy(local_name, name, len);
ffffffffc0205b80:	463d                	li	a2,15
ffffffffc0205b82:	85ca                	mv	a1,s2
ffffffffc0205b84:	1808                	addi	a0,sp,48
ffffffffc0205b86:	7ce000ef          	jal	ra,ffffffffc0206354 <memcpy>
    if (mm != NULL) {
ffffffffc0205b8a:	e20991e3          	bnez	s3,ffffffffc02059ac <do_execve+0x62>
    if (current->mm != NULL) {
ffffffffc0205b8e:	000db783          	ld	a5,0(s11)
ffffffffc0205b92:	779c                	ld	a5,40(a5)
ffffffffc0205b94:	e40788e3          	beqz	a5,ffffffffc02059e4 <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0205b98:	00003617          	auipc	a2,0x3
ffffffffc0205b9c:	c0860613          	addi	a2,a2,-1016 # ffffffffc02087a0 <default_pmm_manager+0x8d8>
ffffffffc0205ba0:	20f00593          	li	a1,527
ffffffffc0205ba4:	00003517          	auipc	a0,0x3
ffffffffc0205ba8:	a1450513          	addi	a0,a0,-1516 # ffffffffc02085b8 <default_pmm_manager+0x6f0>
ffffffffc0205bac:	e5cfa0ef          	jal	ra,ffffffffc0200208 <__panic>
    put_pgdir(mm);
ffffffffc0205bb0:	8526                	mv	a0,s1
ffffffffc0205bb2:	c20ff0ef          	jal	ra,ffffffffc0204fd2 <put_pgdir>
    mm_destroy(mm);
ffffffffc0205bb6:	8526                	mv	a0,s1
ffffffffc0205bb8:	c30fb0ef          	jal	ra,ffffffffc0200fe8 <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc0205bbc:	5a61                	li	s4,-8
    do_exit(ret);
ffffffffc0205bbe:	8552                	mv	a0,s4
ffffffffc0205bc0:	94bff0ef          	jal	ra,ffffffffc020550a <do_exit>
    int ret = -E_NO_MEM;
ffffffffc0205bc4:	5a71                	li	s4,-4
ffffffffc0205bc6:	bfe5                	j	ffffffffc0205bbe <do_execve+0x274>
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc0205bc8:	0289b603          	ld	a2,40(s3)
ffffffffc0205bcc:	0209b783          	ld	a5,32(s3)
ffffffffc0205bd0:	1cf66d63          	bltu	a2,a5,ffffffffc0205daa <do_execve+0x460>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205bd4:	0049a783          	lw	a5,4(s3)
ffffffffc0205bd8:	0017f693          	andi	a3,a5,1
ffffffffc0205bdc:	c291                	beqz	a3,ffffffffc0205be0 <do_execve+0x296>
ffffffffc0205bde:	4691                	li	a3,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205be0:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205be4:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205be6:	e779                	bnez	a4,ffffffffc0205cb4 <do_execve+0x36a>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205be8:	4d45                	li	s10,17
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205bea:	c781                	beqz	a5,ffffffffc0205bf2 <do_execve+0x2a8>
ffffffffc0205bec:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205bf0:	4d4d                	li	s10,19
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205bf2:	0026f793          	andi	a5,a3,2
ffffffffc0205bf6:	e3f1                	bnez	a5,ffffffffc0205cba <do_execve+0x370>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc0205bf8:	0046f793          	andi	a5,a3,4
ffffffffc0205bfc:	c399                	beqz	a5,ffffffffc0205c02 <do_execve+0x2b8>
ffffffffc0205bfe:	008d6d13          	ori	s10,s10,8
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc0205c02:	0109b583          	ld	a1,16(s3)
ffffffffc0205c06:	4701                	li	a4,0
ffffffffc0205c08:	8526                	mv	a0,s1
ffffffffc0205c0a:	c30fb0ef          	jal	ra,ffffffffc020103a <mm_map>
ffffffffc0205c0e:	8a2a                	mv	s4,a0
ffffffffc0205c10:	ed35                	bnez	a0,ffffffffc0205c8c <do_execve+0x342>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205c12:	0109bb83          	ld	s7,16(s3)
ffffffffc0205c16:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0205c18:	0209ba03          	ld	s4,32(s3)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205c1c:	0089b903          	ld	s2,8(s3)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205c20:	00fbfab3          	and	s5,s7,a5
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205c24:	7782                	ld	a5,32(sp)
        end = ph->p_va + ph->p_filesz;
ffffffffc0205c26:	9a5e                	add	s4,s4,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205c28:	993e                	add	s2,s2,a5
        while (start < end) {
ffffffffc0205c2a:	054be963          	bltu	s7,s4,ffffffffc0205c7c <do_execve+0x332>
ffffffffc0205c2e:	aa95                	j	ffffffffc0205da2 <do_execve+0x458>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205c30:	6785                	lui	a5,0x1
ffffffffc0205c32:	415b8533          	sub	a0,s7,s5
ffffffffc0205c36:	9abe                	add	s5,s5,a5
ffffffffc0205c38:	417a8633          	sub	a2,s5,s7
            if (end < la) {
ffffffffc0205c3c:	015a7463          	bgeu	s4,s5,ffffffffc0205c44 <do_execve+0x2fa>
                size -= la - end;
ffffffffc0205c40:	417a0633          	sub	a2,s4,s7
    return page - pages + nbase;
ffffffffc0205c44:	000cb683          	ld	a3,0(s9)
ffffffffc0205c48:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205c4a:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0205c4e:	40d406b3          	sub	a3,s0,a3
ffffffffc0205c52:	8699                	srai	a3,a3,0x6
ffffffffc0205c54:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205c56:	67e2                	ld	a5,24(sp)
ffffffffc0205c58:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205c5c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205c5e:	14b87863          	bgeu	a6,a1,ffffffffc0205dae <do_execve+0x464>
ffffffffc0205c62:	000b3803          	ld	a6,0(s6)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205c66:	85ca                	mv	a1,s2
            start += size, from += size;
ffffffffc0205c68:	9bb2                	add	s7,s7,a2
ffffffffc0205c6a:	96c2                	add	a3,a3,a6
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205c6c:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0205c6e:	e432                	sd	a2,8(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205c70:	6e4000ef          	jal	ra,ffffffffc0206354 <memcpy>
            start += size, from += size;
ffffffffc0205c74:	6622                	ld	a2,8(sp)
ffffffffc0205c76:	9932                	add	s2,s2,a2
        while (start < end) {
ffffffffc0205c78:	054bf363          	bgeu	s7,s4,ffffffffc0205cbe <do_execve+0x374>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205c7c:	6c88                	ld	a0,24(s1)
ffffffffc0205c7e:	866a                	mv	a2,s10
ffffffffc0205c80:	85d6                	mv	a1,s5
ffffffffc0205c82:	fcdfe0ef          	jal	ra,ffffffffc0204c4e <pgdir_alloc_page>
ffffffffc0205c86:	842a                	mv	s0,a0
ffffffffc0205c88:	f545                	bnez	a0,ffffffffc0205c30 <do_execve+0x2e6>
        ret = -E_NO_MEM;
ffffffffc0205c8a:	5a71                	li	s4,-4
    exit_mmap(mm);
ffffffffc0205c8c:	8526                	mv	a0,s1
ffffffffc0205c8e:	cf6fb0ef          	jal	ra,ffffffffc0201184 <exit_mmap>
    put_pgdir(mm);
ffffffffc0205c92:	8526                	mv	a0,s1
ffffffffc0205c94:	b3eff0ef          	jal	ra,ffffffffc0204fd2 <put_pgdir>
    mm_destroy(mm);
ffffffffc0205c98:	8526                	mv	a0,s1
ffffffffc0205c9a:	b4efb0ef          	jal	ra,ffffffffc0200fe8 <mm_destroy>
    return ret;
ffffffffc0205c9e:	b705                	j	ffffffffc0205bbe <do_execve+0x274>
            exit_mmap(mm);
ffffffffc0205ca0:	854e                	mv	a0,s3
ffffffffc0205ca2:	ce2fb0ef          	jal	ra,ffffffffc0201184 <exit_mmap>
            put_pgdir(mm);
ffffffffc0205ca6:	854e                	mv	a0,s3
ffffffffc0205ca8:	b2aff0ef          	jal	ra,ffffffffc0204fd2 <put_pgdir>
            mm_destroy(mm);
ffffffffc0205cac:	854e                	mv	a0,s3
ffffffffc0205cae:	b3afb0ef          	jal	ra,ffffffffc0200fe8 <mm_destroy>
ffffffffc0205cb2:	b32d                	j	ffffffffc02059dc <do_execve+0x92>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205cb4:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205cb8:	fb95                	bnez	a5,ffffffffc0205bec <do_execve+0x2a2>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205cba:	4d5d                	li	s10,23
ffffffffc0205cbc:	bf35                	j	ffffffffc0205bf8 <do_execve+0x2ae>
        end = ph->p_va + ph->p_memsz;
ffffffffc0205cbe:	0109b683          	ld	a3,16(s3)
ffffffffc0205cc2:	0289b903          	ld	s2,40(s3)
ffffffffc0205cc6:	9936                	add	s2,s2,a3
        if (start < la) {
ffffffffc0205cc8:	075bfd63          	bgeu	s7,s5,ffffffffc0205d42 <do_execve+0x3f8>
            if (start == end) {
ffffffffc0205ccc:	db790fe3          	beq	s2,s7,ffffffffc0205a8a <do_execve+0x140>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205cd0:	6785                	lui	a5,0x1
ffffffffc0205cd2:	00fb8533          	add	a0,s7,a5
ffffffffc0205cd6:	41550533          	sub	a0,a0,s5
                size -= la - end;
ffffffffc0205cda:	41790a33          	sub	s4,s2,s7
            if (end < la) {
ffffffffc0205cde:	0b597d63          	bgeu	s2,s5,ffffffffc0205d98 <do_execve+0x44e>
    return page - pages + nbase;
ffffffffc0205ce2:	000cb683          	ld	a3,0(s9)
ffffffffc0205ce6:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205ce8:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc0205cec:	40d406b3          	sub	a3,s0,a3
ffffffffc0205cf0:	8699                	srai	a3,a3,0x6
ffffffffc0205cf2:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205cf4:	67e2                	ld	a5,24(sp)
ffffffffc0205cf6:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205cfa:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205cfc:	0ac5f963          	bgeu	a1,a2,ffffffffc0205dae <do_execve+0x464>
ffffffffc0205d00:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205d04:	8652                	mv	a2,s4
ffffffffc0205d06:	4581                	li	a1,0
ffffffffc0205d08:	96c2                	add	a3,a3,a6
ffffffffc0205d0a:	9536                	add	a0,a0,a3
ffffffffc0205d0c:	636000ef          	jal	ra,ffffffffc0206342 <memset>
            start += size;
ffffffffc0205d10:	017a0733          	add	a4,s4,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205d14:	03597463          	bgeu	s2,s5,ffffffffc0205d3c <do_execve+0x3f2>
ffffffffc0205d18:	d6e909e3          	beq	s2,a4,ffffffffc0205a8a <do_execve+0x140>
ffffffffc0205d1c:	00003697          	auipc	a3,0x3
ffffffffc0205d20:	aac68693          	addi	a3,a3,-1364 # ffffffffc02087c8 <default_pmm_manager+0x900>
ffffffffc0205d24:	00001617          	auipc	a2,0x1
ffffffffc0205d28:	10460613          	addi	a2,a2,260 # ffffffffc0206e28 <commands+0x410>
ffffffffc0205d2c:	26400593          	li	a1,612
ffffffffc0205d30:	00003517          	auipc	a0,0x3
ffffffffc0205d34:	88850513          	addi	a0,a0,-1912 # ffffffffc02085b8 <default_pmm_manager+0x6f0>
ffffffffc0205d38:	cd0fa0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0205d3c:	ff5710e3          	bne	a4,s5,ffffffffc0205d1c <do_execve+0x3d2>
ffffffffc0205d40:	8bd6                	mv	s7,s5
        while (start < end) {
ffffffffc0205d42:	d52bf4e3          	bgeu	s7,s2,ffffffffc0205a8a <do_execve+0x140>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205d46:	6c88                	ld	a0,24(s1)
ffffffffc0205d48:	866a                	mv	a2,s10
ffffffffc0205d4a:	85d6                	mv	a1,s5
ffffffffc0205d4c:	f03fe0ef          	jal	ra,ffffffffc0204c4e <pgdir_alloc_page>
ffffffffc0205d50:	842a                	mv	s0,a0
ffffffffc0205d52:	dd05                	beqz	a0,ffffffffc0205c8a <do_execve+0x340>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205d54:	6785                	lui	a5,0x1
ffffffffc0205d56:	415b8533          	sub	a0,s7,s5
ffffffffc0205d5a:	9abe                	add	s5,s5,a5
ffffffffc0205d5c:	417a8633          	sub	a2,s5,s7
            if (end < la) {
ffffffffc0205d60:	01597463          	bgeu	s2,s5,ffffffffc0205d68 <do_execve+0x41e>
                size -= la - end;
ffffffffc0205d64:	41790633          	sub	a2,s2,s7
    return page - pages + nbase;
ffffffffc0205d68:	000cb683          	ld	a3,0(s9)
ffffffffc0205d6c:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205d6e:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0205d72:	40d406b3          	sub	a3,s0,a3
ffffffffc0205d76:	8699                	srai	a3,a3,0x6
ffffffffc0205d78:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205d7a:	67e2                	ld	a5,24(sp)
ffffffffc0205d7c:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205d80:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205d82:	02b87663          	bgeu	a6,a1,ffffffffc0205dae <do_execve+0x464>
ffffffffc0205d86:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205d8a:	4581                	li	a1,0
            start += size;
ffffffffc0205d8c:	9bb2                	add	s7,s7,a2
ffffffffc0205d8e:	96c2                	add	a3,a3,a6
            memset(page2kva(page) + off, 0, size);
ffffffffc0205d90:	9536                	add	a0,a0,a3
ffffffffc0205d92:	5b0000ef          	jal	ra,ffffffffc0206342 <memset>
ffffffffc0205d96:	b775                	j	ffffffffc0205d42 <do_execve+0x3f8>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205d98:	417a8a33          	sub	s4,s5,s7
ffffffffc0205d9c:	b799                	j	ffffffffc0205ce2 <do_execve+0x398>
        return -E_INVAL;
ffffffffc0205d9e:	5a75                	li	s4,-3
ffffffffc0205da0:	b3c1                	j	ffffffffc0205b60 <do_execve+0x216>
        while (start < end) {
ffffffffc0205da2:	86de                	mv	a3,s7
ffffffffc0205da4:	bf39                	j	ffffffffc0205cc2 <do_execve+0x378>
    int ret = -E_NO_MEM;
ffffffffc0205da6:	5a71                	li	s4,-4
ffffffffc0205da8:	bdc5                	j	ffffffffc0205c98 <do_execve+0x34e>
            ret = -E_INVAL_ELF;
ffffffffc0205daa:	5a61                	li	s4,-8
ffffffffc0205dac:	b5c5                	j	ffffffffc0205c8c <do_execve+0x342>
ffffffffc0205dae:	00001617          	auipc	a2,0x1
ffffffffc0205db2:	64a60613          	addi	a2,a2,1610 # ffffffffc02073f8 <commands+0x9e0>
ffffffffc0205db6:	06900593          	li	a1,105
ffffffffc0205dba:	00001517          	auipc	a0,0x1
ffffffffc0205dbe:	3ae50513          	addi	a0,a0,942 # ffffffffc0207168 <commands+0x750>
ffffffffc0205dc2:	c46fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205dc6:	00002617          	auipc	a2,0x2
ffffffffc0205dca:	ba260613          	addi	a2,a2,-1118 # ffffffffc0207968 <commands+0xf50>
ffffffffc0205dce:	27f00593          	li	a1,639
ffffffffc0205dd2:	00002517          	auipc	a0,0x2
ffffffffc0205dd6:	7e650513          	addi	a0,a0,2022 # ffffffffc02085b8 <default_pmm_manager+0x6f0>
ffffffffc0205dda:	c2efa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205dde:	00003697          	auipc	a3,0x3
ffffffffc0205de2:	b0268693          	addi	a3,a3,-1278 # ffffffffc02088e0 <default_pmm_manager+0xa18>
ffffffffc0205de6:	00001617          	auipc	a2,0x1
ffffffffc0205dea:	04260613          	addi	a2,a2,66 # ffffffffc0206e28 <commands+0x410>
ffffffffc0205dee:	27a00593          	li	a1,634
ffffffffc0205df2:	00002517          	auipc	a0,0x2
ffffffffc0205df6:	7c650513          	addi	a0,a0,1990 # ffffffffc02085b8 <default_pmm_manager+0x6f0>
ffffffffc0205dfa:	c0efa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205dfe:	00003697          	auipc	a3,0x3
ffffffffc0205e02:	a9a68693          	addi	a3,a3,-1382 # ffffffffc0208898 <default_pmm_manager+0x9d0>
ffffffffc0205e06:	00001617          	auipc	a2,0x1
ffffffffc0205e0a:	02260613          	addi	a2,a2,34 # ffffffffc0206e28 <commands+0x410>
ffffffffc0205e0e:	27900593          	li	a1,633
ffffffffc0205e12:	00002517          	auipc	a0,0x2
ffffffffc0205e16:	7a650513          	addi	a0,a0,1958 # ffffffffc02085b8 <default_pmm_manager+0x6f0>
ffffffffc0205e1a:	beefa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205e1e:	00003697          	auipc	a3,0x3
ffffffffc0205e22:	a3268693          	addi	a3,a3,-1486 # ffffffffc0208850 <default_pmm_manager+0x988>
ffffffffc0205e26:	00001617          	auipc	a2,0x1
ffffffffc0205e2a:	00260613          	addi	a2,a2,2 # ffffffffc0206e28 <commands+0x410>
ffffffffc0205e2e:	27800593          	li	a1,632
ffffffffc0205e32:	00002517          	auipc	a0,0x2
ffffffffc0205e36:	78650513          	addi	a0,a0,1926 # ffffffffc02085b8 <default_pmm_manager+0x6f0>
ffffffffc0205e3a:	bcefa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205e3e:	00003697          	auipc	a3,0x3
ffffffffc0205e42:	9ca68693          	addi	a3,a3,-1590 # ffffffffc0208808 <default_pmm_manager+0x940>
ffffffffc0205e46:	00001617          	auipc	a2,0x1
ffffffffc0205e4a:	fe260613          	addi	a2,a2,-30 # ffffffffc0206e28 <commands+0x410>
ffffffffc0205e4e:	27700593          	li	a1,631
ffffffffc0205e52:	00002517          	auipc	a0,0x2
ffffffffc0205e56:	76650513          	addi	a0,a0,1894 # ffffffffc02085b8 <default_pmm_manager+0x6f0>
ffffffffc0205e5a:	baefa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205e5e <do_yield>:
    current->need_resched = 1;
ffffffffc0205e5e:	000ad797          	auipc	a5,0xad
ffffffffc0205e62:	ac27b783          	ld	a5,-1342(a5) # ffffffffc02b2920 <current>
ffffffffc0205e66:	4705                	li	a4,1
ffffffffc0205e68:	ef98                	sd	a4,24(a5)
}
ffffffffc0205e6a:	4501                	li	a0,0
ffffffffc0205e6c:	8082                	ret

ffffffffc0205e6e <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205e6e:	1101                	addi	sp,sp,-32
ffffffffc0205e70:	e822                	sd	s0,16(sp)
ffffffffc0205e72:	e426                	sd	s1,8(sp)
ffffffffc0205e74:	ec06                	sd	ra,24(sp)
ffffffffc0205e76:	842e                	mv	s0,a1
ffffffffc0205e78:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205e7a:	c999                	beqz	a1,ffffffffc0205e90 <do_wait+0x22>
    struct mm_struct *mm = current->mm;
ffffffffc0205e7c:	000ad797          	auipc	a5,0xad
ffffffffc0205e80:	aa47b783          	ld	a5,-1372(a5) # ffffffffc02b2920 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205e84:	7788                	ld	a0,40(a5)
ffffffffc0205e86:	4685                	li	a3,1
ffffffffc0205e88:	4611                	li	a2,4
ffffffffc0205e8a:	a83fb0ef          	jal	ra,ffffffffc020190c <user_mem_check>
ffffffffc0205e8e:	c909                	beqz	a0,ffffffffc0205ea0 <do_wait+0x32>
ffffffffc0205e90:	85a2                	mv	a1,s0
}
ffffffffc0205e92:	6442                	ld	s0,16(sp)
ffffffffc0205e94:	60e2                	ld	ra,24(sp)
ffffffffc0205e96:	8526                	mv	a0,s1
ffffffffc0205e98:	64a2                	ld	s1,8(sp)
ffffffffc0205e9a:	6105                	addi	sp,sp,32
ffffffffc0205e9c:	fb8ff06f          	j	ffffffffc0205654 <do_wait.part.0>
ffffffffc0205ea0:	60e2                	ld	ra,24(sp)
ffffffffc0205ea2:	6442                	ld	s0,16(sp)
ffffffffc0205ea4:	64a2                	ld	s1,8(sp)
ffffffffc0205ea6:	5575                	li	a0,-3
ffffffffc0205ea8:	6105                	addi	sp,sp,32
ffffffffc0205eaa:	8082                	ret

ffffffffc0205eac <do_kill>:
do_kill(int pid) {
ffffffffc0205eac:	1141                	addi	sp,sp,-16
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205eae:	6789                	lui	a5,0x2
do_kill(int pid) {
ffffffffc0205eb0:	e406                	sd	ra,8(sp)
ffffffffc0205eb2:	e022                	sd	s0,0(sp)
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205eb4:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205eb8:	17f9                	addi	a5,a5,-2
ffffffffc0205eba:	02e7e963          	bltu	a5,a4,ffffffffc0205eec <do_kill+0x40>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205ebe:	842a                	mv	s0,a0
ffffffffc0205ec0:	45a9                	li	a1,10
ffffffffc0205ec2:	2501                	sext.w	a0,a0
ffffffffc0205ec4:	097000ef          	jal	ra,ffffffffc020675a <hash32>
ffffffffc0205ec8:	02051793          	slli	a5,a0,0x20
ffffffffc0205ecc:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0205ed0:	000a9797          	auipc	a5,0xa9
ffffffffc0205ed4:	9c878793          	addi	a5,a5,-1592 # ffffffffc02ae898 <hash_list>
ffffffffc0205ed8:	953e                	add	a0,a0,a5
ffffffffc0205eda:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list) {
ffffffffc0205edc:	a029                	j	ffffffffc0205ee6 <do_kill+0x3a>
            if (proc->pid == pid) {
ffffffffc0205ede:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0205ee2:	00870b63          	beq	a4,s0,ffffffffc0205ef8 <do_kill+0x4c>
ffffffffc0205ee6:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205ee8:	fef51be3          	bne	a0,a5,ffffffffc0205ede <do_kill+0x32>
    return -E_INVAL;
ffffffffc0205eec:	5475                	li	s0,-3
}
ffffffffc0205eee:	60a2                	ld	ra,8(sp)
ffffffffc0205ef0:	8522                	mv	a0,s0
ffffffffc0205ef2:	6402                	ld	s0,0(sp)
ffffffffc0205ef4:	0141                	addi	sp,sp,16
ffffffffc0205ef6:	8082                	ret
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205ef8:	fd87a703          	lw	a4,-40(a5)
ffffffffc0205efc:	00177693          	andi	a3,a4,1
ffffffffc0205f00:	e295                	bnez	a3,ffffffffc0205f24 <do_kill+0x78>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205f02:	4bd4                	lw	a3,20(a5)
            proc->flags |= PF_EXITING;
ffffffffc0205f04:	00176713          	ori	a4,a4,1
ffffffffc0205f08:	fce7ac23          	sw	a4,-40(a5)
            return 0;
ffffffffc0205f0c:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205f0e:	fe06d0e3          	bgez	a3,ffffffffc0205eee <do_kill+0x42>
                wakeup_proc(proc);
ffffffffc0205f12:	f2878513          	addi	a0,a5,-216
ffffffffc0205f16:	1c4000ef          	jal	ra,ffffffffc02060da <wakeup_proc>
}
ffffffffc0205f1a:	60a2                	ld	ra,8(sp)
ffffffffc0205f1c:	8522                	mv	a0,s0
ffffffffc0205f1e:	6402                	ld	s0,0(sp)
ffffffffc0205f20:	0141                	addi	sp,sp,16
ffffffffc0205f22:	8082                	ret
        return -E_KILLED;
ffffffffc0205f24:	545d                	li	s0,-9
ffffffffc0205f26:	b7e1                	j	ffffffffc0205eee <do_kill+0x42>

ffffffffc0205f28 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205f28:	1101                	addi	sp,sp,-32
ffffffffc0205f2a:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0205f2c:	000ad797          	auipc	a5,0xad
ffffffffc0205f30:	96c78793          	addi	a5,a5,-1684 # ffffffffc02b2898 <proc_list>
ffffffffc0205f34:	ec06                	sd	ra,24(sp)
ffffffffc0205f36:	e822                	sd	s0,16(sp)
ffffffffc0205f38:	e04a                	sd	s2,0(sp)
ffffffffc0205f3a:	000a9497          	auipc	s1,0xa9
ffffffffc0205f3e:	95e48493          	addi	s1,s1,-1698 # ffffffffc02ae898 <hash_list>
ffffffffc0205f42:	e79c                	sd	a5,8(a5)
ffffffffc0205f44:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0205f46:	000ad717          	auipc	a4,0xad
ffffffffc0205f4a:	95270713          	addi	a4,a4,-1710 # ffffffffc02b2898 <proc_list>
ffffffffc0205f4e:	87a6                	mv	a5,s1
ffffffffc0205f50:	e79c                	sd	a5,8(a5)
ffffffffc0205f52:	e39c                	sd	a5,0(a5)
ffffffffc0205f54:	07c1                	addi	a5,a5,16
ffffffffc0205f56:	fef71de3          	bne	a4,a5,ffffffffc0205f50 <proc_init+0x28>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0205f5a:	f75fe0ef          	jal	ra,ffffffffc0204ece <alloc_proc>
ffffffffc0205f5e:	000ad917          	auipc	s2,0xad
ffffffffc0205f62:	9ca90913          	addi	s2,s2,-1590 # ffffffffc02b2928 <idleproc>
ffffffffc0205f66:	00a93023          	sd	a0,0(s2)
ffffffffc0205f6a:	0e050f63          	beqz	a0,ffffffffc0206068 <proc_init+0x140>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205f6e:	4789                	li	a5,2
ffffffffc0205f70:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205f72:	00003797          	auipc	a5,0x3
ffffffffc0205f76:	08e78793          	addi	a5,a5,142 # ffffffffc0209000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205f7a:	0b450413          	addi	s0,a0,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205f7e:	e91c                	sd	a5,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205f80:	4785                	li	a5,1
ffffffffc0205f82:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205f84:	4641                	li	a2,16
ffffffffc0205f86:	4581                	li	a1,0
ffffffffc0205f88:	8522                	mv	a0,s0
ffffffffc0205f8a:	3b8000ef          	jal	ra,ffffffffc0206342 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205f8e:	463d                	li	a2,15
ffffffffc0205f90:	00003597          	auipc	a1,0x3
ffffffffc0205f94:	9b058593          	addi	a1,a1,-1616 # ffffffffc0208940 <default_pmm_manager+0xa78>
ffffffffc0205f98:	8522                	mv	a0,s0
ffffffffc0205f9a:	3ba000ef          	jal	ra,ffffffffc0206354 <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process ++;
ffffffffc0205f9e:	000ad717          	auipc	a4,0xad
ffffffffc0205fa2:	99a70713          	addi	a4,a4,-1638 # ffffffffc02b2938 <nr_process>
ffffffffc0205fa6:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc0205fa8:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205fac:	4601                	li	a2,0
    nr_process ++;
ffffffffc0205fae:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205fb0:	4581                	li	a1,0
ffffffffc0205fb2:	00000517          	auipc	a0,0x0
ffffffffc0205fb6:	87450513          	addi	a0,a0,-1932 # ffffffffc0205826 <init_main>
    nr_process ++;
ffffffffc0205fba:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc0205fbc:	000ad797          	auipc	a5,0xad
ffffffffc0205fc0:	96d7b223          	sd	a3,-1692(a5) # ffffffffc02b2920 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205fc4:	cf6ff0ef          	jal	ra,ffffffffc02054ba <kernel_thread>
ffffffffc0205fc8:	842a                	mv	s0,a0
    if (pid <= 0) {
ffffffffc0205fca:	08a05363          	blez	a0,ffffffffc0206050 <proc_init+0x128>
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205fce:	6789                	lui	a5,0x2
ffffffffc0205fd0:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205fd4:	17f9                	addi	a5,a5,-2
ffffffffc0205fd6:	2501                	sext.w	a0,a0
ffffffffc0205fd8:	02e7e363          	bltu	a5,a4,ffffffffc0205ffe <proc_init+0xd6>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205fdc:	45a9                	li	a1,10
ffffffffc0205fde:	77c000ef          	jal	ra,ffffffffc020675a <hash32>
ffffffffc0205fe2:	02051793          	slli	a5,a0,0x20
ffffffffc0205fe6:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0205fea:	96a6                	add	a3,a3,s1
ffffffffc0205fec:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0205fee:	a029                	j	ffffffffc0205ff8 <proc_init+0xd0>
            if (proc->pid == pid) {
ffffffffc0205ff0:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x7c94>
ffffffffc0205ff4:	04870b63          	beq	a4,s0,ffffffffc020604a <proc_init+0x122>
    return listelm->next;
ffffffffc0205ff8:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205ffa:	fef69be3          	bne	a3,a5,ffffffffc0205ff0 <proc_init+0xc8>
    return NULL;
ffffffffc0205ffe:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0206000:	0b478493          	addi	s1,a5,180
ffffffffc0206004:	4641                	li	a2,16
ffffffffc0206006:	4581                	li	a1,0
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0206008:	000ad417          	auipc	s0,0xad
ffffffffc020600c:	92840413          	addi	s0,s0,-1752 # ffffffffc02b2930 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0206010:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc0206012:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0206014:	32e000ef          	jal	ra,ffffffffc0206342 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0206018:	463d                	li	a2,15
ffffffffc020601a:	00003597          	auipc	a1,0x3
ffffffffc020601e:	94e58593          	addi	a1,a1,-1714 # ffffffffc0208968 <default_pmm_manager+0xaa0>
ffffffffc0206022:	8526                	mv	a0,s1
ffffffffc0206024:	330000ef          	jal	ra,ffffffffc0206354 <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0206028:	00093783          	ld	a5,0(s2)
ffffffffc020602c:	cbb5                	beqz	a5,ffffffffc02060a0 <proc_init+0x178>
ffffffffc020602e:	43dc                	lw	a5,4(a5)
ffffffffc0206030:	eba5                	bnez	a5,ffffffffc02060a0 <proc_init+0x178>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0206032:	601c                	ld	a5,0(s0)
ffffffffc0206034:	c7b1                	beqz	a5,ffffffffc0206080 <proc_init+0x158>
ffffffffc0206036:	43d8                	lw	a4,4(a5)
ffffffffc0206038:	4785                	li	a5,1
ffffffffc020603a:	04f71363          	bne	a4,a5,ffffffffc0206080 <proc_init+0x158>
}
ffffffffc020603e:	60e2                	ld	ra,24(sp)
ffffffffc0206040:	6442                	ld	s0,16(sp)
ffffffffc0206042:	64a2                	ld	s1,8(sp)
ffffffffc0206044:	6902                	ld	s2,0(sp)
ffffffffc0206046:	6105                	addi	sp,sp,32
ffffffffc0206048:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc020604a:	f2878793          	addi	a5,a5,-216
ffffffffc020604e:	bf4d                	j	ffffffffc0206000 <proc_init+0xd8>
        panic("create init_main failed.\n");
ffffffffc0206050:	00003617          	auipc	a2,0x3
ffffffffc0206054:	8f860613          	addi	a2,a2,-1800 # ffffffffc0208948 <default_pmm_manager+0xa80>
ffffffffc0206058:	38500593          	li	a1,901
ffffffffc020605c:	00002517          	auipc	a0,0x2
ffffffffc0206060:	55c50513          	addi	a0,a0,1372 # ffffffffc02085b8 <default_pmm_manager+0x6f0>
ffffffffc0206064:	9a4fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc0206068:	00003617          	auipc	a2,0x3
ffffffffc020606c:	8c060613          	addi	a2,a2,-1856 # ffffffffc0208928 <default_pmm_manager+0xa60>
ffffffffc0206070:	37700593          	li	a1,887
ffffffffc0206074:	00002517          	auipc	a0,0x2
ffffffffc0206078:	54450513          	addi	a0,a0,1348 # ffffffffc02085b8 <default_pmm_manager+0x6f0>
ffffffffc020607c:	98cfa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0206080:	00003697          	auipc	a3,0x3
ffffffffc0206084:	91868693          	addi	a3,a3,-1768 # ffffffffc0208998 <default_pmm_manager+0xad0>
ffffffffc0206088:	00001617          	auipc	a2,0x1
ffffffffc020608c:	da060613          	addi	a2,a2,-608 # ffffffffc0206e28 <commands+0x410>
ffffffffc0206090:	38c00593          	li	a1,908
ffffffffc0206094:	00002517          	auipc	a0,0x2
ffffffffc0206098:	52450513          	addi	a0,a0,1316 # ffffffffc02085b8 <default_pmm_manager+0x6f0>
ffffffffc020609c:	96cfa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc02060a0:	00003697          	auipc	a3,0x3
ffffffffc02060a4:	8d068693          	addi	a3,a3,-1840 # ffffffffc0208970 <default_pmm_manager+0xaa8>
ffffffffc02060a8:	00001617          	auipc	a2,0x1
ffffffffc02060ac:	d8060613          	addi	a2,a2,-640 # ffffffffc0206e28 <commands+0x410>
ffffffffc02060b0:	38b00593          	li	a1,907
ffffffffc02060b4:	00002517          	auipc	a0,0x2
ffffffffc02060b8:	50450513          	addi	a0,a0,1284 # ffffffffc02085b8 <default_pmm_manager+0x6f0>
ffffffffc02060bc:	94cfa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02060c0 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc02060c0:	1141                	addi	sp,sp,-16
ffffffffc02060c2:	e022                	sd	s0,0(sp)
ffffffffc02060c4:	e406                	sd	ra,8(sp)
ffffffffc02060c6:	000ad417          	auipc	s0,0xad
ffffffffc02060ca:	85a40413          	addi	s0,s0,-1958 # ffffffffc02b2920 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc02060ce:	6018                	ld	a4,0(s0)
ffffffffc02060d0:	6f1c                	ld	a5,24(a4)
ffffffffc02060d2:	dffd                	beqz	a5,ffffffffc02060d0 <cpu_idle+0x10>
            schedule();
ffffffffc02060d4:	086000ef          	jal	ra,ffffffffc020615a <schedule>
ffffffffc02060d8:	bfdd                	j	ffffffffc02060ce <cpu_idle+0xe>

ffffffffc02060da <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02060da:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc02060dc:	1101                	addi	sp,sp,-32
ffffffffc02060de:	ec06                	sd	ra,24(sp)
ffffffffc02060e0:	e822                	sd	s0,16(sp)
ffffffffc02060e2:	e426                	sd	s1,8(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02060e4:	478d                	li	a5,3
ffffffffc02060e6:	04f70b63          	beq	a4,a5,ffffffffc020613c <wakeup_proc+0x62>
ffffffffc02060ea:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02060ec:	100027f3          	csrr	a5,sstatus
ffffffffc02060f0:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02060f2:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02060f4:	ef9d                	bnez	a5,ffffffffc0206132 <wakeup_proc+0x58>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc02060f6:	4789                	li	a5,2
ffffffffc02060f8:	02f70163          	beq	a4,a5,ffffffffc020611a <wakeup_proc+0x40>
            proc->state = PROC_RUNNABLE;
ffffffffc02060fc:	c01c                	sw	a5,0(s0)
            proc->wait_state = 0;
ffffffffc02060fe:	0e042623          	sw	zero,236(s0)
    if (flag) {
ffffffffc0206102:	e491                	bnez	s1,ffffffffc020610e <wakeup_proc+0x34>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0206104:	60e2                	ld	ra,24(sp)
ffffffffc0206106:	6442                	ld	s0,16(sp)
ffffffffc0206108:	64a2                	ld	s1,8(sp)
ffffffffc020610a:	6105                	addi	sp,sp,32
ffffffffc020610c:	8082                	ret
ffffffffc020610e:	6442                	ld	s0,16(sp)
ffffffffc0206110:	60e2                	ld	ra,24(sp)
ffffffffc0206112:	64a2                	ld	s1,8(sp)
ffffffffc0206114:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0206116:	d2cfa06f          	j	ffffffffc0200642 <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc020611a:	00003617          	auipc	a2,0x3
ffffffffc020611e:	8de60613          	addi	a2,a2,-1826 # ffffffffc02089f8 <default_pmm_manager+0xb30>
ffffffffc0206122:	45c9                	li	a1,18
ffffffffc0206124:	00003517          	auipc	a0,0x3
ffffffffc0206128:	8bc50513          	addi	a0,a0,-1860 # ffffffffc02089e0 <default_pmm_manager+0xb18>
ffffffffc020612c:	944fa0ef          	jal	ra,ffffffffc0200270 <__warn>
ffffffffc0206130:	bfc9                	j	ffffffffc0206102 <wakeup_proc+0x28>
        intr_disable();
ffffffffc0206132:	d16fa0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0206136:	4018                	lw	a4,0(s0)
        return 1;
ffffffffc0206138:	4485                	li	s1,1
ffffffffc020613a:	bf75                	j	ffffffffc02060f6 <wakeup_proc+0x1c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc020613c:	00003697          	auipc	a3,0x3
ffffffffc0206140:	88468693          	addi	a3,a3,-1916 # ffffffffc02089c0 <default_pmm_manager+0xaf8>
ffffffffc0206144:	00001617          	auipc	a2,0x1
ffffffffc0206148:	ce460613          	addi	a2,a2,-796 # ffffffffc0206e28 <commands+0x410>
ffffffffc020614c:	45a5                	li	a1,9
ffffffffc020614e:	00003517          	auipc	a0,0x3
ffffffffc0206152:	89250513          	addi	a0,a0,-1902 # ffffffffc02089e0 <default_pmm_manager+0xb18>
ffffffffc0206156:	8b2fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020615a <schedule>:

void
schedule(void) {
ffffffffc020615a:	1141                	addi	sp,sp,-16
ffffffffc020615c:	e406                	sd	ra,8(sp)
ffffffffc020615e:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0206160:	100027f3          	csrr	a5,sstatus
ffffffffc0206164:	8b89                	andi	a5,a5,2
ffffffffc0206166:	4401                	li	s0,0
ffffffffc0206168:	efbd                	bnez	a5,ffffffffc02061e6 <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc020616a:	000ac897          	auipc	a7,0xac
ffffffffc020616e:	7b68b883          	ld	a7,1974(a7) # ffffffffc02b2920 <current>
ffffffffc0206172:	0008bc23          	sd	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0206176:	000ac517          	auipc	a0,0xac
ffffffffc020617a:	7b253503          	ld	a0,1970(a0) # ffffffffc02b2928 <idleproc>
ffffffffc020617e:	04a88e63          	beq	a7,a0,ffffffffc02061da <schedule+0x80>
ffffffffc0206182:	0c888693          	addi	a3,a7,200
ffffffffc0206186:	000ac617          	auipc	a2,0xac
ffffffffc020618a:	71260613          	addi	a2,a2,1810 # ffffffffc02b2898 <proc_list>
        le = last;
ffffffffc020618e:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0206190:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0206192:	4809                	li	a6,2
ffffffffc0206194:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0206196:	00c78863          	beq	a5,a2,ffffffffc02061a6 <schedule+0x4c>
                if (next->state == PROC_RUNNABLE) {
ffffffffc020619a:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc020619e:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc02061a2:	03070163          	beq	a4,a6,ffffffffc02061c4 <schedule+0x6a>
                    break;
                }
            }
        } while (le != last);
ffffffffc02061a6:	fef697e3          	bne	a3,a5,ffffffffc0206194 <schedule+0x3a>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc02061aa:	ed89                	bnez	a1,ffffffffc02061c4 <schedule+0x6a>
            next = idleproc;
        }
        next->runs ++;
ffffffffc02061ac:	451c                	lw	a5,8(a0)
ffffffffc02061ae:	2785                	addiw	a5,a5,1
ffffffffc02061b0:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc02061b2:	00a88463          	beq	a7,a0,ffffffffc02061ba <schedule+0x60>
            proc_run(next);
ffffffffc02061b6:	e93fe0ef          	jal	ra,ffffffffc0205048 <proc_run>
    if (flag) {
ffffffffc02061ba:	e819                	bnez	s0,ffffffffc02061d0 <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc02061bc:	60a2                	ld	ra,8(sp)
ffffffffc02061be:	6402                	ld	s0,0(sp)
ffffffffc02061c0:	0141                	addi	sp,sp,16
ffffffffc02061c2:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc02061c4:	4198                	lw	a4,0(a1)
ffffffffc02061c6:	4789                	li	a5,2
ffffffffc02061c8:	fef712e3          	bne	a4,a5,ffffffffc02061ac <schedule+0x52>
ffffffffc02061cc:	852e                	mv	a0,a1
ffffffffc02061ce:	bff9                	j	ffffffffc02061ac <schedule+0x52>
}
ffffffffc02061d0:	6402                	ld	s0,0(sp)
ffffffffc02061d2:	60a2                	ld	ra,8(sp)
ffffffffc02061d4:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc02061d6:	c6cfa06f          	j	ffffffffc0200642 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02061da:	000ac617          	auipc	a2,0xac
ffffffffc02061de:	6be60613          	addi	a2,a2,1726 # ffffffffc02b2898 <proc_list>
ffffffffc02061e2:	86b2                	mv	a3,a2
ffffffffc02061e4:	b76d                	j	ffffffffc020618e <schedule+0x34>
        intr_disable();
ffffffffc02061e6:	c62fa0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc02061ea:	4405                	li	s0,1
ffffffffc02061ec:	bfbd                	j	ffffffffc020616a <schedule+0x10>

ffffffffc02061ee <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc02061ee:	000ac797          	auipc	a5,0xac
ffffffffc02061f2:	7327b783          	ld	a5,1842(a5) # ffffffffc02b2920 <current>
}
ffffffffc02061f6:	43c8                	lw	a0,4(a5)
ffffffffc02061f8:	8082                	ret

ffffffffc02061fa <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc02061fa:	4501                	li	a0,0
ffffffffc02061fc:	8082                	ret

ffffffffc02061fe <sys_putc>:
    cputchar(c);
ffffffffc02061fe:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0206200:	1141                	addi	sp,sp,-16
ffffffffc0206202:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc0206204:	efff90ef          	jal	ra,ffffffffc0200102 <cputchar>
}
ffffffffc0206208:	60a2                	ld	ra,8(sp)
ffffffffc020620a:	4501                	li	a0,0
ffffffffc020620c:	0141                	addi	sp,sp,16
ffffffffc020620e:	8082                	ret

ffffffffc0206210 <sys_kill>:
    return do_kill(pid);
ffffffffc0206210:	4108                	lw	a0,0(a0)
ffffffffc0206212:	c9bff06f          	j	ffffffffc0205eac <do_kill>

ffffffffc0206216 <sys_yield>:
    return do_yield();
ffffffffc0206216:	c49ff06f          	j	ffffffffc0205e5e <do_yield>

ffffffffc020621a <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc020621a:	6d14                	ld	a3,24(a0)
ffffffffc020621c:	6910                	ld	a2,16(a0)
ffffffffc020621e:	650c                	ld	a1,8(a0)
ffffffffc0206220:	6108                	ld	a0,0(a0)
ffffffffc0206222:	f28ff06f          	j	ffffffffc020594a <do_execve>

ffffffffc0206226 <sys_wait>:
    return do_wait(pid, store);
ffffffffc0206226:	650c                	ld	a1,8(a0)
ffffffffc0206228:	4108                	lw	a0,0(a0)
ffffffffc020622a:	c45ff06f          	j	ffffffffc0205e6e <do_wait>

ffffffffc020622e <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc020622e:	000ac797          	auipc	a5,0xac
ffffffffc0206232:	6f27b783          	ld	a5,1778(a5) # ffffffffc02b2920 <current>
ffffffffc0206236:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc0206238:	4501                	li	a0,0
ffffffffc020623a:	6a0c                	ld	a1,16(a2)
ffffffffc020623c:	e71fe06f          	j	ffffffffc02050ac <do_fork>

ffffffffc0206240 <sys_exit>:
    return do_exit(error_code);
ffffffffc0206240:	4108                	lw	a0,0(a0)
ffffffffc0206242:	ac8ff06f          	j	ffffffffc020550a <do_exit>

ffffffffc0206246 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc0206246:	715d                	addi	sp,sp,-80
ffffffffc0206248:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc020624a:	000ac497          	auipc	s1,0xac
ffffffffc020624e:	6d648493          	addi	s1,s1,1750 # ffffffffc02b2920 <current>
ffffffffc0206252:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc0206254:	e0a2                	sd	s0,64(sp)
ffffffffc0206256:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc0206258:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc020625a:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc020625c:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc020625e:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0206262:	0327ee63          	bltu	a5,s2,ffffffffc020629e <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc0206266:	00391713          	slli	a4,s2,0x3
ffffffffc020626a:	00002797          	auipc	a5,0x2
ffffffffc020626e:	7f678793          	addi	a5,a5,2038 # ffffffffc0208a60 <syscalls>
ffffffffc0206272:	97ba                	add	a5,a5,a4
ffffffffc0206274:	639c                	ld	a5,0(a5)
ffffffffc0206276:	c785                	beqz	a5,ffffffffc020629e <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc0206278:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc020627a:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc020627c:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc020627e:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc0206280:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc0206282:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc0206284:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc0206286:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc0206288:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc020628a:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc020628c:	0028                	addi	a0,sp,8
ffffffffc020628e:	9782                	jalr	a5
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc0206290:	60a6                	ld	ra,72(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0206292:	e828                	sd	a0,80(s0)
}
ffffffffc0206294:	6406                	ld	s0,64(sp)
ffffffffc0206296:	74e2                	ld	s1,56(sp)
ffffffffc0206298:	7942                	ld	s2,48(sp)
ffffffffc020629a:	6161                	addi	sp,sp,80
ffffffffc020629c:	8082                	ret
    print_trapframe(tf);
ffffffffc020629e:	8522                	mv	a0,s0
ffffffffc02062a0:	d96fa0ef          	jal	ra,ffffffffc0200836 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc02062a4:	609c                	ld	a5,0(s1)
ffffffffc02062a6:	86ca                	mv	a3,s2
ffffffffc02062a8:	00002617          	auipc	a2,0x2
ffffffffc02062ac:	77060613          	addi	a2,a2,1904 # ffffffffc0208a18 <default_pmm_manager+0xb50>
ffffffffc02062b0:	43d8                	lw	a4,4(a5)
ffffffffc02062b2:	06200593          	li	a1,98
ffffffffc02062b6:	0b478793          	addi	a5,a5,180
ffffffffc02062ba:	00002517          	auipc	a0,0x2
ffffffffc02062be:	78e50513          	addi	a0,a0,1934 # ffffffffc0208a48 <default_pmm_manager+0xb80>
ffffffffc02062c2:	f47f90ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02062c6 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02062c6:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc02062ca:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc02062cc:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc02062ce:	cb81                	beqz	a5,ffffffffc02062de <strlen+0x18>
        cnt ++;
ffffffffc02062d0:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc02062d2:	00a707b3          	add	a5,a4,a0
ffffffffc02062d6:	0007c783          	lbu	a5,0(a5)
ffffffffc02062da:	fbfd                	bnez	a5,ffffffffc02062d0 <strlen+0xa>
ffffffffc02062dc:	8082                	ret
    }
    return cnt;
}
ffffffffc02062de:	8082                	ret

ffffffffc02062e0 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc02062e0:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc02062e2:	e589                	bnez	a1,ffffffffc02062ec <strnlen+0xc>
ffffffffc02062e4:	a811                	j	ffffffffc02062f8 <strnlen+0x18>
        cnt ++;
ffffffffc02062e6:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02062e8:	00f58863          	beq	a1,a5,ffffffffc02062f8 <strnlen+0x18>
ffffffffc02062ec:	00f50733          	add	a4,a0,a5
ffffffffc02062f0:	00074703          	lbu	a4,0(a4)
ffffffffc02062f4:	fb6d                	bnez	a4,ffffffffc02062e6 <strnlen+0x6>
ffffffffc02062f6:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc02062f8:	852e                	mv	a0,a1
ffffffffc02062fa:	8082                	ret

ffffffffc02062fc <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc02062fc:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc02062fe:	0005c703          	lbu	a4,0(a1)
ffffffffc0206302:	0785                	addi	a5,a5,1
ffffffffc0206304:	0585                	addi	a1,a1,1
ffffffffc0206306:	fee78fa3          	sb	a4,-1(a5)
ffffffffc020630a:	fb75                	bnez	a4,ffffffffc02062fe <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc020630c:	8082                	ret

ffffffffc020630e <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020630e:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0206312:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206316:	cb89                	beqz	a5,ffffffffc0206328 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0206318:	0505                	addi	a0,a0,1
ffffffffc020631a:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020631c:	fee789e3          	beq	a5,a4,ffffffffc020630e <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0206320:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0206324:	9d19                	subw	a0,a0,a4
ffffffffc0206326:	8082                	ret
ffffffffc0206328:	4501                	li	a0,0
ffffffffc020632a:	bfed                	j	ffffffffc0206324 <strcmp+0x16>

ffffffffc020632c <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc020632c:	00054783          	lbu	a5,0(a0)
ffffffffc0206330:	c799                	beqz	a5,ffffffffc020633e <strchr+0x12>
        if (*s == c) {
ffffffffc0206332:	00f58763          	beq	a1,a5,ffffffffc0206340 <strchr+0x14>
    while (*s != '\0') {
ffffffffc0206336:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc020633a:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc020633c:	fbfd                	bnez	a5,ffffffffc0206332 <strchr+0x6>
    }
    return NULL;
ffffffffc020633e:	4501                	li	a0,0
}
ffffffffc0206340:	8082                	ret

ffffffffc0206342 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0206342:	ca01                	beqz	a2,ffffffffc0206352 <memset+0x10>
ffffffffc0206344:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0206346:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0206348:	0785                	addi	a5,a5,1
ffffffffc020634a:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc020634e:	fec79de3          	bne	a5,a2,ffffffffc0206348 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0206352:	8082                	ret

ffffffffc0206354 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0206354:	ca19                	beqz	a2,ffffffffc020636a <memcpy+0x16>
ffffffffc0206356:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0206358:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc020635a:	0005c703          	lbu	a4,0(a1)
ffffffffc020635e:	0585                	addi	a1,a1,1
ffffffffc0206360:	0785                	addi	a5,a5,1
ffffffffc0206362:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0206366:	fec59ae3          	bne	a1,a2,ffffffffc020635a <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc020636a:	8082                	ret

ffffffffc020636c <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020636c:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206370:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0206372:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206376:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0206378:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020637c:	f022                	sd	s0,32(sp)
ffffffffc020637e:	ec26                	sd	s1,24(sp)
ffffffffc0206380:	e84a                	sd	s2,16(sp)
ffffffffc0206382:	f406                	sd	ra,40(sp)
ffffffffc0206384:	e44e                	sd	s3,8(sp)
ffffffffc0206386:	84aa                	mv	s1,a0
ffffffffc0206388:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020638a:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020638e:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0206390:	03067e63          	bgeu	a2,a6,ffffffffc02063cc <printnum+0x60>
ffffffffc0206394:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0206396:	00805763          	blez	s0,ffffffffc02063a4 <printnum+0x38>
ffffffffc020639a:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020639c:	85ca                	mv	a1,s2
ffffffffc020639e:	854e                	mv	a0,s3
ffffffffc02063a0:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02063a2:	fc65                	bnez	s0,ffffffffc020639a <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02063a4:	1a02                	slli	s4,s4,0x20
ffffffffc02063a6:	00002797          	auipc	a5,0x2
ffffffffc02063aa:	7ba78793          	addi	a5,a5,1978 # ffffffffc0208b60 <syscalls+0x100>
ffffffffc02063ae:	020a5a13          	srli	s4,s4,0x20
ffffffffc02063b2:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc02063b4:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02063b6:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02063ba:	70a2                	ld	ra,40(sp)
ffffffffc02063bc:	69a2                	ld	s3,8(sp)
ffffffffc02063be:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02063c0:	85ca                	mv	a1,s2
ffffffffc02063c2:	87a6                	mv	a5,s1
}
ffffffffc02063c4:	6942                	ld	s2,16(sp)
ffffffffc02063c6:	64e2                	ld	s1,24(sp)
ffffffffc02063c8:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02063ca:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02063cc:	03065633          	divu	a2,a2,a6
ffffffffc02063d0:	8722                	mv	a4,s0
ffffffffc02063d2:	f9bff0ef          	jal	ra,ffffffffc020636c <printnum>
ffffffffc02063d6:	b7f9                	j	ffffffffc02063a4 <printnum+0x38>

ffffffffc02063d8 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02063d8:	7119                	addi	sp,sp,-128
ffffffffc02063da:	f4a6                	sd	s1,104(sp)
ffffffffc02063dc:	f0ca                	sd	s2,96(sp)
ffffffffc02063de:	ecce                	sd	s3,88(sp)
ffffffffc02063e0:	e8d2                	sd	s4,80(sp)
ffffffffc02063e2:	e4d6                	sd	s5,72(sp)
ffffffffc02063e4:	e0da                	sd	s6,64(sp)
ffffffffc02063e6:	fc5e                	sd	s7,56(sp)
ffffffffc02063e8:	f06a                	sd	s10,32(sp)
ffffffffc02063ea:	fc86                	sd	ra,120(sp)
ffffffffc02063ec:	f8a2                	sd	s0,112(sp)
ffffffffc02063ee:	f862                	sd	s8,48(sp)
ffffffffc02063f0:	f466                	sd	s9,40(sp)
ffffffffc02063f2:	ec6e                	sd	s11,24(sp)
ffffffffc02063f4:	892a                	mv	s2,a0
ffffffffc02063f6:	84ae                	mv	s1,a1
ffffffffc02063f8:	8d32                	mv	s10,a2
ffffffffc02063fa:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02063fc:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0206400:	5b7d                	li	s6,-1
ffffffffc0206402:	00002a97          	auipc	s5,0x2
ffffffffc0206406:	78aa8a93          	addi	s5,s5,1930 # ffffffffc0208b8c <syscalls+0x12c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020640a:	00003b97          	auipc	s7,0x3
ffffffffc020640e:	99eb8b93          	addi	s7,s7,-1634 # ffffffffc0208da8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206412:	000d4503          	lbu	a0,0(s10)
ffffffffc0206416:	001d0413          	addi	s0,s10,1
ffffffffc020641a:	01350a63          	beq	a0,s3,ffffffffc020642e <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc020641e:	c121                	beqz	a0,ffffffffc020645e <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0206420:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206422:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0206424:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206426:	fff44503          	lbu	a0,-1(s0)
ffffffffc020642a:	ff351ae3          	bne	a0,s3,ffffffffc020641e <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020642e:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0206432:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0206436:	4c81                	li	s9,0
ffffffffc0206438:	4881                	li	a7,0
        width = precision = -1;
ffffffffc020643a:	5c7d                	li	s8,-1
ffffffffc020643c:	5dfd                	li	s11,-1
ffffffffc020643e:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0206442:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206444:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0206448:	0ff5f593          	zext.b	a1,a1
ffffffffc020644c:	00140d13          	addi	s10,s0,1
ffffffffc0206450:	04b56263          	bltu	a0,a1,ffffffffc0206494 <vprintfmt+0xbc>
ffffffffc0206454:	058a                	slli	a1,a1,0x2
ffffffffc0206456:	95d6                	add	a1,a1,s5
ffffffffc0206458:	4194                	lw	a3,0(a1)
ffffffffc020645a:	96d6                	add	a3,a3,s5
ffffffffc020645c:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020645e:	70e6                	ld	ra,120(sp)
ffffffffc0206460:	7446                	ld	s0,112(sp)
ffffffffc0206462:	74a6                	ld	s1,104(sp)
ffffffffc0206464:	7906                	ld	s2,96(sp)
ffffffffc0206466:	69e6                	ld	s3,88(sp)
ffffffffc0206468:	6a46                	ld	s4,80(sp)
ffffffffc020646a:	6aa6                	ld	s5,72(sp)
ffffffffc020646c:	6b06                	ld	s6,64(sp)
ffffffffc020646e:	7be2                	ld	s7,56(sp)
ffffffffc0206470:	7c42                	ld	s8,48(sp)
ffffffffc0206472:	7ca2                	ld	s9,40(sp)
ffffffffc0206474:	7d02                	ld	s10,32(sp)
ffffffffc0206476:	6de2                	ld	s11,24(sp)
ffffffffc0206478:	6109                	addi	sp,sp,128
ffffffffc020647a:	8082                	ret
            padc = '0';
ffffffffc020647c:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc020647e:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206482:	846a                	mv	s0,s10
ffffffffc0206484:	00140d13          	addi	s10,s0,1
ffffffffc0206488:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020648c:	0ff5f593          	zext.b	a1,a1
ffffffffc0206490:	fcb572e3          	bgeu	a0,a1,ffffffffc0206454 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0206494:	85a6                	mv	a1,s1
ffffffffc0206496:	02500513          	li	a0,37
ffffffffc020649a:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020649c:	fff44783          	lbu	a5,-1(s0)
ffffffffc02064a0:	8d22                	mv	s10,s0
ffffffffc02064a2:	f73788e3          	beq	a5,s3,ffffffffc0206412 <vprintfmt+0x3a>
ffffffffc02064a6:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02064aa:	1d7d                	addi	s10,s10,-1
ffffffffc02064ac:	ff379de3          	bne	a5,s3,ffffffffc02064a6 <vprintfmt+0xce>
ffffffffc02064b0:	b78d                	j	ffffffffc0206412 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02064b2:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02064b6:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02064ba:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02064bc:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02064c0:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02064c4:	02d86463          	bltu	a6,a3,ffffffffc02064ec <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02064c8:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02064cc:	002c169b          	slliw	a3,s8,0x2
ffffffffc02064d0:	0186873b          	addw	a4,a3,s8
ffffffffc02064d4:	0017171b          	slliw	a4,a4,0x1
ffffffffc02064d8:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02064da:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02064de:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02064e0:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02064e4:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02064e8:	fed870e3          	bgeu	a6,a3,ffffffffc02064c8 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc02064ec:	f40ddce3          	bgez	s11,ffffffffc0206444 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02064f0:	8de2                	mv	s11,s8
ffffffffc02064f2:	5c7d                	li	s8,-1
ffffffffc02064f4:	bf81                	j	ffffffffc0206444 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02064f6:	fffdc693          	not	a3,s11
ffffffffc02064fa:	96fd                	srai	a3,a3,0x3f
ffffffffc02064fc:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206500:	00144603          	lbu	a2,1(s0)
ffffffffc0206504:	2d81                	sext.w	s11,s11
ffffffffc0206506:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206508:	bf35                	j	ffffffffc0206444 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc020650a:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020650e:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0206512:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206514:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0206516:	bfd9                	j	ffffffffc02064ec <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0206518:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020651a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020651e:	01174463          	blt	a4,a7,ffffffffc0206526 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0206522:	1a088e63          	beqz	a7,ffffffffc02066de <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0206526:	000a3603          	ld	a2,0(s4)
ffffffffc020652a:	46c1                	li	a3,16
ffffffffc020652c:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020652e:	2781                	sext.w	a5,a5
ffffffffc0206530:	876e                	mv	a4,s11
ffffffffc0206532:	85a6                	mv	a1,s1
ffffffffc0206534:	854a                	mv	a0,s2
ffffffffc0206536:	e37ff0ef          	jal	ra,ffffffffc020636c <printnum>
            break;
ffffffffc020653a:	bde1                	j	ffffffffc0206412 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc020653c:	000a2503          	lw	a0,0(s4)
ffffffffc0206540:	85a6                	mv	a1,s1
ffffffffc0206542:	0a21                	addi	s4,s4,8
ffffffffc0206544:	9902                	jalr	s2
            break;
ffffffffc0206546:	b5f1                	j	ffffffffc0206412 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0206548:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020654a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020654e:	01174463          	blt	a4,a7,ffffffffc0206556 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0206552:	18088163          	beqz	a7,ffffffffc02066d4 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0206556:	000a3603          	ld	a2,0(s4)
ffffffffc020655a:	46a9                	li	a3,10
ffffffffc020655c:	8a2e                	mv	s4,a1
ffffffffc020655e:	bfc1                	j	ffffffffc020652e <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206560:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0206564:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206566:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206568:	bdf1                	j	ffffffffc0206444 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc020656a:	85a6                	mv	a1,s1
ffffffffc020656c:	02500513          	li	a0,37
ffffffffc0206570:	9902                	jalr	s2
            break;
ffffffffc0206572:	b545                	j	ffffffffc0206412 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206574:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0206578:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020657a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020657c:	b5e1                	j	ffffffffc0206444 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc020657e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0206580:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0206584:	01174463          	blt	a4,a7,ffffffffc020658c <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0206588:	14088163          	beqz	a7,ffffffffc02066ca <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc020658c:	000a3603          	ld	a2,0(s4)
ffffffffc0206590:	46a1                	li	a3,8
ffffffffc0206592:	8a2e                	mv	s4,a1
ffffffffc0206594:	bf69                	j	ffffffffc020652e <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0206596:	03000513          	li	a0,48
ffffffffc020659a:	85a6                	mv	a1,s1
ffffffffc020659c:	e03e                	sd	a5,0(sp)
ffffffffc020659e:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02065a0:	85a6                	mv	a1,s1
ffffffffc02065a2:	07800513          	li	a0,120
ffffffffc02065a6:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02065a8:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02065aa:	6782                	ld	a5,0(sp)
ffffffffc02065ac:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02065ae:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02065b2:	bfb5                	j	ffffffffc020652e <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02065b4:	000a3403          	ld	s0,0(s4)
ffffffffc02065b8:	008a0713          	addi	a4,s4,8
ffffffffc02065bc:	e03a                	sd	a4,0(sp)
ffffffffc02065be:	14040263          	beqz	s0,ffffffffc0206702 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02065c2:	0fb05763          	blez	s11,ffffffffc02066b0 <vprintfmt+0x2d8>
ffffffffc02065c6:	02d00693          	li	a3,45
ffffffffc02065ca:	0cd79163          	bne	a5,a3,ffffffffc020668c <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02065ce:	00044783          	lbu	a5,0(s0)
ffffffffc02065d2:	0007851b          	sext.w	a0,a5
ffffffffc02065d6:	cf85                	beqz	a5,ffffffffc020660e <vprintfmt+0x236>
ffffffffc02065d8:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02065dc:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02065e0:	000c4563          	bltz	s8,ffffffffc02065ea <vprintfmt+0x212>
ffffffffc02065e4:	3c7d                	addiw	s8,s8,-1
ffffffffc02065e6:	036c0263          	beq	s8,s6,ffffffffc020660a <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc02065ea:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02065ec:	0e0c8e63          	beqz	s9,ffffffffc02066e8 <vprintfmt+0x310>
ffffffffc02065f0:	3781                	addiw	a5,a5,-32
ffffffffc02065f2:	0ef47b63          	bgeu	s0,a5,ffffffffc02066e8 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02065f6:	03f00513          	li	a0,63
ffffffffc02065fa:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02065fc:	000a4783          	lbu	a5,0(s4)
ffffffffc0206600:	3dfd                	addiw	s11,s11,-1
ffffffffc0206602:	0a05                	addi	s4,s4,1
ffffffffc0206604:	0007851b          	sext.w	a0,a5
ffffffffc0206608:	ffe1                	bnez	a5,ffffffffc02065e0 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc020660a:	01b05963          	blez	s11,ffffffffc020661c <vprintfmt+0x244>
ffffffffc020660e:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0206610:	85a6                	mv	a1,s1
ffffffffc0206612:	02000513          	li	a0,32
ffffffffc0206616:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0206618:	fe0d9be3          	bnez	s11,ffffffffc020660e <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020661c:	6a02                	ld	s4,0(sp)
ffffffffc020661e:	bbd5                	j	ffffffffc0206412 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0206620:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0206622:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0206626:	01174463          	blt	a4,a7,ffffffffc020662e <vprintfmt+0x256>
    else if (lflag) {
ffffffffc020662a:	08088d63          	beqz	a7,ffffffffc02066c4 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc020662e:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0206632:	0a044d63          	bltz	s0,ffffffffc02066ec <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0206636:	8622                	mv	a2,s0
ffffffffc0206638:	8a66                	mv	s4,s9
ffffffffc020663a:	46a9                	li	a3,10
ffffffffc020663c:	bdcd                	j	ffffffffc020652e <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc020663e:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206642:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc0206644:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0206646:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc020664a:	8fb5                	xor	a5,a5,a3
ffffffffc020664c:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206650:	02d74163          	blt	a4,a3,ffffffffc0206672 <vprintfmt+0x29a>
ffffffffc0206654:	00369793          	slli	a5,a3,0x3
ffffffffc0206658:	97de                	add	a5,a5,s7
ffffffffc020665a:	639c                	ld	a5,0(a5)
ffffffffc020665c:	cb99                	beqz	a5,ffffffffc0206672 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc020665e:	86be                	mv	a3,a5
ffffffffc0206660:	00000617          	auipc	a2,0x0
ffffffffc0206664:	13860613          	addi	a2,a2,312 # ffffffffc0206798 <etext+0x28>
ffffffffc0206668:	85a6                	mv	a1,s1
ffffffffc020666a:	854a                	mv	a0,s2
ffffffffc020666c:	0ce000ef          	jal	ra,ffffffffc020673a <printfmt>
ffffffffc0206670:	b34d                	j	ffffffffc0206412 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0206672:	00002617          	auipc	a2,0x2
ffffffffc0206676:	50e60613          	addi	a2,a2,1294 # ffffffffc0208b80 <syscalls+0x120>
ffffffffc020667a:	85a6                	mv	a1,s1
ffffffffc020667c:	854a                	mv	a0,s2
ffffffffc020667e:	0bc000ef          	jal	ra,ffffffffc020673a <printfmt>
ffffffffc0206682:	bb41                	j	ffffffffc0206412 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0206684:	00002417          	auipc	s0,0x2
ffffffffc0206688:	4f440413          	addi	s0,s0,1268 # ffffffffc0208b78 <syscalls+0x118>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020668c:	85e2                	mv	a1,s8
ffffffffc020668e:	8522                	mv	a0,s0
ffffffffc0206690:	e43e                	sd	a5,8(sp)
ffffffffc0206692:	c4fff0ef          	jal	ra,ffffffffc02062e0 <strnlen>
ffffffffc0206696:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020669a:	01b05b63          	blez	s11,ffffffffc02066b0 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc020669e:	67a2                	ld	a5,8(sp)
ffffffffc02066a0:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02066a4:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02066a6:	85a6                	mv	a1,s1
ffffffffc02066a8:	8552                	mv	a0,s4
ffffffffc02066aa:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02066ac:	fe0d9ce3          	bnez	s11,ffffffffc02066a4 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02066b0:	00044783          	lbu	a5,0(s0)
ffffffffc02066b4:	00140a13          	addi	s4,s0,1
ffffffffc02066b8:	0007851b          	sext.w	a0,a5
ffffffffc02066bc:	d3a5                	beqz	a5,ffffffffc020661c <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02066be:	05e00413          	li	s0,94
ffffffffc02066c2:	bf39                	j	ffffffffc02065e0 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02066c4:	000a2403          	lw	s0,0(s4)
ffffffffc02066c8:	b7ad                	j	ffffffffc0206632 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02066ca:	000a6603          	lwu	a2,0(s4)
ffffffffc02066ce:	46a1                	li	a3,8
ffffffffc02066d0:	8a2e                	mv	s4,a1
ffffffffc02066d2:	bdb1                	j	ffffffffc020652e <vprintfmt+0x156>
ffffffffc02066d4:	000a6603          	lwu	a2,0(s4)
ffffffffc02066d8:	46a9                	li	a3,10
ffffffffc02066da:	8a2e                	mv	s4,a1
ffffffffc02066dc:	bd89                	j	ffffffffc020652e <vprintfmt+0x156>
ffffffffc02066de:	000a6603          	lwu	a2,0(s4)
ffffffffc02066e2:	46c1                	li	a3,16
ffffffffc02066e4:	8a2e                	mv	s4,a1
ffffffffc02066e6:	b5a1                	j	ffffffffc020652e <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02066e8:	9902                	jalr	s2
ffffffffc02066ea:	bf09                	j	ffffffffc02065fc <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc02066ec:	85a6                	mv	a1,s1
ffffffffc02066ee:	02d00513          	li	a0,45
ffffffffc02066f2:	e03e                	sd	a5,0(sp)
ffffffffc02066f4:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02066f6:	6782                	ld	a5,0(sp)
ffffffffc02066f8:	8a66                	mv	s4,s9
ffffffffc02066fa:	40800633          	neg	a2,s0
ffffffffc02066fe:	46a9                	li	a3,10
ffffffffc0206700:	b53d                	j	ffffffffc020652e <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0206702:	03b05163          	blez	s11,ffffffffc0206724 <vprintfmt+0x34c>
ffffffffc0206706:	02d00693          	li	a3,45
ffffffffc020670a:	f6d79de3          	bne	a5,a3,ffffffffc0206684 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc020670e:	00002417          	auipc	s0,0x2
ffffffffc0206712:	46a40413          	addi	s0,s0,1130 # ffffffffc0208b78 <syscalls+0x118>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206716:	02800793          	li	a5,40
ffffffffc020671a:	02800513          	li	a0,40
ffffffffc020671e:	00140a13          	addi	s4,s0,1
ffffffffc0206722:	bd6d                	j	ffffffffc02065dc <vprintfmt+0x204>
ffffffffc0206724:	00002a17          	auipc	s4,0x2
ffffffffc0206728:	455a0a13          	addi	s4,s4,1109 # ffffffffc0208b79 <syscalls+0x119>
ffffffffc020672c:	02800513          	li	a0,40
ffffffffc0206730:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206734:	05e00413          	li	s0,94
ffffffffc0206738:	b565                	j	ffffffffc02065e0 <vprintfmt+0x208>

ffffffffc020673a <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020673a:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020673c:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206740:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0206742:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206744:	ec06                	sd	ra,24(sp)
ffffffffc0206746:	f83a                	sd	a4,48(sp)
ffffffffc0206748:	fc3e                	sd	a5,56(sp)
ffffffffc020674a:	e0c2                	sd	a6,64(sp)
ffffffffc020674c:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020674e:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0206750:	c89ff0ef          	jal	ra,ffffffffc02063d8 <vprintfmt>
}
ffffffffc0206754:	60e2                	ld	ra,24(sp)
ffffffffc0206756:	6161                	addi	sp,sp,80
ffffffffc0206758:	8082                	ret

ffffffffc020675a <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc020675a:	9e3707b7          	lui	a5,0x9e370
ffffffffc020675e:	2785                	addiw	a5,a5,1
ffffffffc0206760:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc0206764:	02000793          	li	a5,32
ffffffffc0206768:	9f8d                	subw	a5,a5,a1
}
ffffffffc020676a:	00f5553b          	srlw	a0,a0,a5
ffffffffc020676e:	8082                	ret
