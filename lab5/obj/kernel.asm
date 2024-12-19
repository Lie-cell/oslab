
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
ffffffffc0200036:	34650513          	addi	a0,a0,838 # ffffffffc02a7378 <buf>
ffffffffc020003a:	000b3617          	auipc	a2,0xb3
ffffffffc020003e:	89a60613          	addi	a2,a2,-1894 # ffffffffc02b28d4 <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	160060ef          	jal	ra,ffffffffc02061aa <memset>
    cons_init();                // init the console
ffffffffc020004e:	580000ef          	jal	ra,ffffffffc02005ce <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00006597          	auipc	a1,0x6
ffffffffc0200056:	58658593          	addi	a1,a1,1414 # ffffffffc02065d8 <etext>
ffffffffc020005a:	00006517          	auipc	a0,0x6
ffffffffc020005e:	59e50513          	addi	a0,a0,1438 # ffffffffc02065f8 <etext+0x20>
ffffffffc0200062:	06a000ef          	jal	ra,ffffffffc02000cc <cprintf>

    print_kerninfo();
ffffffffc0200066:	24e000ef          	jal	ra,ffffffffc02002b4 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	47d030ef          	jal	ra,ffffffffc0203ce6 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc020006e:	5d2000ef          	jal	ra,ffffffffc0200640 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200072:	5dc000ef          	jal	ra,ffffffffc020064e <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200076:	168010ef          	jal	ra,ffffffffc02011de <vmm_init>
    proc_init();                // init process table
ffffffffc020007a:	517050ef          	jal	ra,ffffffffc0205d90 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc020007e:	4a8000ef          	jal	ra,ffffffffc0200526 <ide_init>
    swap_init();                // init swap
ffffffffc0200082:	02d010ef          	jal	ra,ffffffffc02018ae <swap_init>

    clock_init();               // init clock interrupt
ffffffffc0200086:	4f6000ef          	jal	ra,ffffffffc020057c <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008a:	5b8000ef          	jal	ra,ffffffffc0200642 <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc020008e:	69b050ef          	jal	ra,ffffffffc0205f28 <cpu_idle>

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
ffffffffc02000c0:	180060ef          	jal	ra,ffffffffc0206240 <vprintfmt>
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
ffffffffc02000f6:	14a060ef          	jal	ra,ffffffffc0206240 <vprintfmt>
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
ffffffffc020016e:	49650513          	addi	a0,a0,1174 # ffffffffc0206600 <etext+0x28>
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
ffffffffc0200184:	1f8b8b93          	addi	s7,s7,504 # ffffffffc02a7378 <buf>
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
ffffffffc02001e0:	19c50513          	addi	a0,a0,412 # ffffffffc02a7378 <buf>
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
ffffffffc020020c:	63830313          	addi	t1,t1,1592 # ffffffffc02b2840 <is_panic>
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
ffffffffc020023a:	3d250513          	addi	a0,a0,978 # ffffffffc0206608 <etext+0x30>
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
ffffffffc0200250:	eec50513          	addi	a0,a0,-276 # ffffffffc0208138 <default_pmm_manager+0x400>
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
ffffffffc0200284:	3a850513          	addi	a0,a0,936 # ffffffffc0206628 <etext+0x50>
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
ffffffffc02002a4:	e9850513          	addi	a0,a0,-360 # ffffffffc0208138 <default_pmm_manager+0x400>
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
ffffffffc02002ba:	39250513          	addi	a0,a0,914 # ffffffffc0206648 <etext+0x70>
void print_kerninfo(void) {
ffffffffc02002be:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02002c0:	e0dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02002c4:	00000597          	auipc	a1,0x0
ffffffffc02002c8:	d6e58593          	addi	a1,a1,-658 # ffffffffc0200032 <kern_init>
ffffffffc02002cc:	00006517          	auipc	a0,0x6
ffffffffc02002d0:	39c50513          	addi	a0,a0,924 # ffffffffc0206668 <etext+0x90>
ffffffffc02002d4:	df9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02002d8:	00006597          	auipc	a1,0x6
ffffffffc02002dc:	30058593          	addi	a1,a1,768 # ffffffffc02065d8 <etext>
ffffffffc02002e0:	00006517          	auipc	a0,0x6
ffffffffc02002e4:	3a850513          	addi	a0,a0,936 # ffffffffc0206688 <etext+0xb0>
ffffffffc02002e8:	de5ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc02002ec:	000a7597          	auipc	a1,0xa7
ffffffffc02002f0:	08c58593          	addi	a1,a1,140 # ffffffffc02a7378 <buf>
ffffffffc02002f4:	00006517          	auipc	a0,0x6
ffffffffc02002f8:	3b450513          	addi	a0,a0,948 # ffffffffc02066a8 <etext+0xd0>
ffffffffc02002fc:	dd1ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200300:	000b2597          	auipc	a1,0xb2
ffffffffc0200304:	5d458593          	addi	a1,a1,1492 # ffffffffc02b28d4 <end>
ffffffffc0200308:	00006517          	auipc	a0,0x6
ffffffffc020030c:	3c050513          	addi	a0,a0,960 # ffffffffc02066c8 <etext+0xf0>
ffffffffc0200310:	dbdff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200314:	000b3597          	auipc	a1,0xb3
ffffffffc0200318:	9bf58593          	addi	a1,a1,-1601 # ffffffffc02b2cd3 <end+0x3ff>
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
ffffffffc020033a:	3b250513          	addi	a0,a0,946 # ffffffffc02066e8 <etext+0x110>
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
ffffffffc0200348:	3d460613          	addi	a2,a2,980 # ffffffffc0206718 <etext+0x140>
ffffffffc020034c:	04d00593          	li	a1,77
ffffffffc0200350:	00006517          	auipc	a0,0x6
ffffffffc0200354:	3e050513          	addi	a0,a0,992 # ffffffffc0206730 <etext+0x158>
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
ffffffffc0200364:	3e860613          	addi	a2,a2,1000 # ffffffffc0206748 <etext+0x170>
ffffffffc0200368:	00006597          	auipc	a1,0x6
ffffffffc020036c:	40058593          	addi	a1,a1,1024 # ffffffffc0206768 <etext+0x190>
ffffffffc0200370:	00006517          	auipc	a0,0x6
ffffffffc0200374:	40050513          	addi	a0,a0,1024 # ffffffffc0206770 <etext+0x198>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200378:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020037a:	d53ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc020037e:	00006617          	auipc	a2,0x6
ffffffffc0200382:	40260613          	addi	a2,a2,1026 # ffffffffc0206780 <etext+0x1a8>
ffffffffc0200386:	00006597          	auipc	a1,0x6
ffffffffc020038a:	42258593          	addi	a1,a1,1058 # ffffffffc02067a8 <etext+0x1d0>
ffffffffc020038e:	00006517          	auipc	a0,0x6
ffffffffc0200392:	3e250513          	addi	a0,a0,994 # ffffffffc0206770 <etext+0x198>
ffffffffc0200396:	d37ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc020039a:	00006617          	auipc	a2,0x6
ffffffffc020039e:	41e60613          	addi	a2,a2,1054 # ffffffffc02067b8 <etext+0x1e0>
ffffffffc02003a2:	00006597          	auipc	a1,0x6
ffffffffc02003a6:	43658593          	addi	a1,a1,1078 # ffffffffc02067d8 <etext+0x200>
ffffffffc02003aa:	00006517          	auipc	a0,0x6
ffffffffc02003ae:	3c650513          	addi	a0,a0,966 # ffffffffc0206770 <etext+0x198>
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
ffffffffc02003e8:	40450513          	addi	a0,a0,1028 # ffffffffc02067e8 <etext+0x210>
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
ffffffffc020040a:	40a50513          	addi	a0,a0,1034 # ffffffffc0206810 <etext+0x238>
ffffffffc020040e:	cbfff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    if (tf != NULL) {
ffffffffc0200412:	000b8563          	beqz	s7,ffffffffc020041c <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200416:	855e                	mv	a0,s7
ffffffffc0200418:	41e000ef          	jal	ra,ffffffffc0200836 <print_trapframe>
ffffffffc020041c:	00006c17          	auipc	s8,0x6
ffffffffc0200420:	464c0c13          	addi	s8,s8,1124 # ffffffffc0206880 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200424:	00006917          	auipc	s2,0x6
ffffffffc0200428:	41490913          	addi	s2,s2,1044 # ffffffffc0206838 <etext+0x260>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020042c:	00006497          	auipc	s1,0x6
ffffffffc0200430:	41448493          	addi	s1,s1,1044 # ffffffffc0206840 <etext+0x268>
        if (argc == MAXARGS - 1) {
ffffffffc0200434:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200436:	00006b17          	auipc	s6,0x6
ffffffffc020043a:	412b0b13          	addi	s6,s6,1042 # ffffffffc0206848 <etext+0x270>
        argv[argc ++] = buf;
ffffffffc020043e:	00006a17          	auipc	s4,0x6
ffffffffc0200442:	32aa0a13          	addi	s4,s4,810 # ffffffffc0206768 <etext+0x190>
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
ffffffffc0200464:	420d0d13          	addi	s10,s10,1056 # ffffffffc0206880 <commands>
        argv[argc ++] = buf;
ffffffffc0200468:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020046a:	4401                	li	s0,0
ffffffffc020046c:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020046e:	509050ef          	jal	ra,ffffffffc0206176 <strcmp>
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
ffffffffc0200482:	4f5050ef          	jal	ra,ffffffffc0206176 <strcmp>
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
ffffffffc02004c0:	4d5050ef          	jal	ra,ffffffffc0206194 <strchr>
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
ffffffffc02004fe:	497050ef          	jal	ra,ffffffffc0206194 <strchr>
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
ffffffffc020051c:	35050513          	addi	a0,a0,848 # ffffffffc0206868 <etext+0x290>
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
ffffffffc0200538:	24478793          	addi	a5,a5,580 # ffffffffc02a7778 <ide>
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
ffffffffc020054c:	471050ef          	jal	ra,ffffffffc02061bc <memcpy>
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
ffffffffc0200560:	21c50513          	addi	a0,a0,540 # ffffffffc02a7778 <ide>
                   size_t nsecs) {
ffffffffc0200564:	1141                	addi	sp,sp,-16
ffffffffc0200566:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200568:	953e                	add	a0,a0,a5
ffffffffc020056a:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc020056e:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200570:	44d050ef          	jal	ra,ffffffffc02061bc <memcpy>
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
ffffffffc020057e:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xd578>
ffffffffc0200582:	000b2717          	auipc	a4,0xb2
ffffffffc0200586:	2cf73723          	sd	a5,718(a4) # ffffffffc02b2850 <timebase>
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
ffffffffc02005a6:	32650513          	addi	a0,a0,806 # ffffffffc02068c8 <commands+0x48>
    ticks = 0;
ffffffffc02005aa:	000b2797          	auipc	a5,0xb2
ffffffffc02005ae:	2807bf23          	sd	zero,670(a5) # ffffffffc02b2848 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc02005b2:	be29                	j	ffffffffc02000cc <cprintf>

ffffffffc02005b4 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02005b4:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02005b8:	000b2797          	auipc	a5,0xb2
ffffffffc02005bc:	2987b783          	ld	a5,664(a5) # ffffffffc02b2850 <timebase>
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
ffffffffc0200674:	27850513          	addi	a0,a0,632 # ffffffffc02068e8 <commands+0x68>
void print_regs(struct pushregs* gpr) {
ffffffffc0200678:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020067a:	a53ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020067e:	640c                	ld	a1,8(s0)
ffffffffc0200680:	00006517          	auipc	a0,0x6
ffffffffc0200684:	28050513          	addi	a0,a0,640 # ffffffffc0206900 <commands+0x80>
ffffffffc0200688:	a45ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020068c:	680c                	ld	a1,16(s0)
ffffffffc020068e:	00006517          	auipc	a0,0x6
ffffffffc0200692:	28a50513          	addi	a0,a0,650 # ffffffffc0206918 <commands+0x98>
ffffffffc0200696:	a37ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc020069a:	6c0c                	ld	a1,24(s0)
ffffffffc020069c:	00006517          	auipc	a0,0x6
ffffffffc02006a0:	29450513          	addi	a0,a0,660 # ffffffffc0206930 <commands+0xb0>
ffffffffc02006a4:	a29ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006a8:	700c                	ld	a1,32(s0)
ffffffffc02006aa:	00006517          	auipc	a0,0x6
ffffffffc02006ae:	29e50513          	addi	a0,a0,670 # ffffffffc0206948 <commands+0xc8>
ffffffffc02006b2:	a1bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006b6:	740c                	ld	a1,40(s0)
ffffffffc02006b8:	00006517          	auipc	a0,0x6
ffffffffc02006bc:	2a850513          	addi	a0,a0,680 # ffffffffc0206960 <commands+0xe0>
ffffffffc02006c0:	a0dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006c4:	780c                	ld	a1,48(s0)
ffffffffc02006c6:	00006517          	auipc	a0,0x6
ffffffffc02006ca:	2b250513          	addi	a0,a0,690 # ffffffffc0206978 <commands+0xf8>
ffffffffc02006ce:	9ffff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006d2:	7c0c                	ld	a1,56(s0)
ffffffffc02006d4:	00006517          	auipc	a0,0x6
ffffffffc02006d8:	2bc50513          	addi	a0,a0,700 # ffffffffc0206990 <commands+0x110>
ffffffffc02006dc:	9f1ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006e0:	602c                	ld	a1,64(s0)
ffffffffc02006e2:	00006517          	auipc	a0,0x6
ffffffffc02006e6:	2c650513          	addi	a0,a0,710 # ffffffffc02069a8 <commands+0x128>
ffffffffc02006ea:	9e3ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006ee:	642c                	ld	a1,72(s0)
ffffffffc02006f0:	00006517          	auipc	a0,0x6
ffffffffc02006f4:	2d050513          	addi	a0,a0,720 # ffffffffc02069c0 <commands+0x140>
ffffffffc02006f8:	9d5ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006fc:	682c                	ld	a1,80(s0)
ffffffffc02006fe:	00006517          	auipc	a0,0x6
ffffffffc0200702:	2da50513          	addi	a0,a0,730 # ffffffffc02069d8 <commands+0x158>
ffffffffc0200706:	9c7ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020070a:	6c2c                	ld	a1,88(s0)
ffffffffc020070c:	00006517          	auipc	a0,0x6
ffffffffc0200710:	2e450513          	addi	a0,a0,740 # ffffffffc02069f0 <commands+0x170>
ffffffffc0200714:	9b9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200718:	702c                	ld	a1,96(s0)
ffffffffc020071a:	00006517          	auipc	a0,0x6
ffffffffc020071e:	2ee50513          	addi	a0,a0,750 # ffffffffc0206a08 <commands+0x188>
ffffffffc0200722:	9abff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200726:	742c                	ld	a1,104(s0)
ffffffffc0200728:	00006517          	auipc	a0,0x6
ffffffffc020072c:	2f850513          	addi	a0,a0,760 # ffffffffc0206a20 <commands+0x1a0>
ffffffffc0200730:	99dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200734:	782c                	ld	a1,112(s0)
ffffffffc0200736:	00006517          	auipc	a0,0x6
ffffffffc020073a:	30250513          	addi	a0,a0,770 # ffffffffc0206a38 <commands+0x1b8>
ffffffffc020073e:	98fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200742:	7c2c                	ld	a1,120(s0)
ffffffffc0200744:	00006517          	auipc	a0,0x6
ffffffffc0200748:	30c50513          	addi	a0,a0,780 # ffffffffc0206a50 <commands+0x1d0>
ffffffffc020074c:	981ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200750:	604c                	ld	a1,128(s0)
ffffffffc0200752:	00006517          	auipc	a0,0x6
ffffffffc0200756:	31650513          	addi	a0,a0,790 # ffffffffc0206a68 <commands+0x1e8>
ffffffffc020075a:	973ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020075e:	644c                	ld	a1,136(s0)
ffffffffc0200760:	00006517          	auipc	a0,0x6
ffffffffc0200764:	32050513          	addi	a0,a0,800 # ffffffffc0206a80 <commands+0x200>
ffffffffc0200768:	965ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020076c:	684c                	ld	a1,144(s0)
ffffffffc020076e:	00006517          	auipc	a0,0x6
ffffffffc0200772:	32a50513          	addi	a0,a0,810 # ffffffffc0206a98 <commands+0x218>
ffffffffc0200776:	957ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020077a:	6c4c                	ld	a1,152(s0)
ffffffffc020077c:	00006517          	auipc	a0,0x6
ffffffffc0200780:	33450513          	addi	a0,a0,820 # ffffffffc0206ab0 <commands+0x230>
ffffffffc0200784:	949ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200788:	704c                	ld	a1,160(s0)
ffffffffc020078a:	00006517          	auipc	a0,0x6
ffffffffc020078e:	33e50513          	addi	a0,a0,830 # ffffffffc0206ac8 <commands+0x248>
ffffffffc0200792:	93bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200796:	744c                	ld	a1,168(s0)
ffffffffc0200798:	00006517          	auipc	a0,0x6
ffffffffc020079c:	34850513          	addi	a0,a0,840 # ffffffffc0206ae0 <commands+0x260>
ffffffffc02007a0:	92dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007a4:	784c                	ld	a1,176(s0)
ffffffffc02007a6:	00006517          	auipc	a0,0x6
ffffffffc02007aa:	35250513          	addi	a0,a0,850 # ffffffffc0206af8 <commands+0x278>
ffffffffc02007ae:	91fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007b2:	7c4c                	ld	a1,184(s0)
ffffffffc02007b4:	00006517          	auipc	a0,0x6
ffffffffc02007b8:	35c50513          	addi	a0,a0,860 # ffffffffc0206b10 <commands+0x290>
ffffffffc02007bc:	911ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007c0:	606c                	ld	a1,192(s0)
ffffffffc02007c2:	00006517          	auipc	a0,0x6
ffffffffc02007c6:	36650513          	addi	a0,a0,870 # ffffffffc0206b28 <commands+0x2a8>
ffffffffc02007ca:	903ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007ce:	646c                	ld	a1,200(s0)
ffffffffc02007d0:	00006517          	auipc	a0,0x6
ffffffffc02007d4:	37050513          	addi	a0,a0,880 # ffffffffc0206b40 <commands+0x2c0>
ffffffffc02007d8:	8f5ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007dc:	686c                	ld	a1,208(s0)
ffffffffc02007de:	00006517          	auipc	a0,0x6
ffffffffc02007e2:	37a50513          	addi	a0,a0,890 # ffffffffc0206b58 <commands+0x2d8>
ffffffffc02007e6:	8e7ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007ea:	6c6c                	ld	a1,216(s0)
ffffffffc02007ec:	00006517          	auipc	a0,0x6
ffffffffc02007f0:	38450513          	addi	a0,a0,900 # ffffffffc0206b70 <commands+0x2f0>
ffffffffc02007f4:	8d9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007f8:	706c                	ld	a1,224(s0)
ffffffffc02007fa:	00006517          	auipc	a0,0x6
ffffffffc02007fe:	38e50513          	addi	a0,a0,910 # ffffffffc0206b88 <commands+0x308>
ffffffffc0200802:	8cbff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200806:	746c                	ld	a1,232(s0)
ffffffffc0200808:	00006517          	auipc	a0,0x6
ffffffffc020080c:	39850513          	addi	a0,a0,920 # ffffffffc0206ba0 <commands+0x320>
ffffffffc0200810:	8bdff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200814:	786c                	ld	a1,240(s0)
ffffffffc0200816:	00006517          	auipc	a0,0x6
ffffffffc020081a:	3a250513          	addi	a0,a0,930 # ffffffffc0206bb8 <commands+0x338>
ffffffffc020081e:	8afff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200822:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200824:	6402                	ld	s0,0(sp)
ffffffffc0200826:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200828:	00006517          	auipc	a0,0x6
ffffffffc020082c:	3a850513          	addi	a0,a0,936 # ffffffffc0206bd0 <commands+0x350>
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
ffffffffc0200842:	3aa50513          	addi	a0,a0,938 # ffffffffc0206be8 <commands+0x368>
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
ffffffffc020085a:	3aa50513          	addi	a0,a0,938 # ffffffffc0206c00 <commands+0x380>
ffffffffc020085e:	86fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200862:	10843583          	ld	a1,264(s0)
ffffffffc0200866:	00006517          	auipc	a0,0x6
ffffffffc020086a:	3b250513          	addi	a0,a0,946 # ffffffffc0206c18 <commands+0x398>
ffffffffc020086e:	85fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200872:	11043583          	ld	a1,272(s0)
ffffffffc0200876:	00006517          	auipc	a0,0x6
ffffffffc020087a:	3ba50513          	addi	a0,a0,954 # ffffffffc0206c30 <commands+0x3b0>
ffffffffc020087e:	84fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200882:	11843583          	ld	a1,280(s0)
}
ffffffffc0200886:	6402                	ld	s0,0(sp)
ffffffffc0200888:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020088a:	00006517          	auipc	a0,0x6
ffffffffc020088e:	3b650513          	addi	a0,a0,950 # ffffffffc0206c40 <commands+0x3c0>
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
ffffffffc02008a0:	fbc48493          	addi	s1,s1,-68 # ffffffffc02b2858 <check_mm_struct>
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
ffffffffc02008d6:	38650513          	addi	a0,a0,902 # ffffffffc0206c58 <commands+0x3d8>
ffffffffc02008da:	ff2ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008de:	6088                	ld	a0,0(s1)
ffffffffc02008e0:	cd1d                	beqz	a0,ffffffffc020091e <pgfault_handler+0x86>
        assert(current == idleproc);
ffffffffc02008e2:	000b2717          	auipc	a4,0xb2
ffffffffc02008e6:	fd673703          	ld	a4,-42(a4) # ffffffffc02b28b8 <current>
ffffffffc02008ea:	000b2797          	auipc	a5,0xb2
ffffffffc02008ee:	fd67b783          	ld	a5,-42(a5) # ffffffffc02b28c0 <idleproc>
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
ffffffffc0200906:	6190006f          	j	ffffffffc020171e <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020090a:	11843703          	ld	a4,280(s0)
ffffffffc020090e:	47bd                	li	a5,15
ffffffffc0200910:	05500613          	li	a2,85
ffffffffc0200914:	05700693          	li	a3,87
ffffffffc0200918:	faf71be3          	bne	a4,a5,ffffffffc02008ce <pgfault_handler+0x36>
ffffffffc020091c:	bf5d                	j	ffffffffc02008d2 <pgfault_handler+0x3a>
        if (current == NULL) {
ffffffffc020091e:	000b2797          	auipc	a5,0xb2
ffffffffc0200922:	f9a7b783          	ld	a5,-102(a5) # ffffffffc02b28b8 <current>
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
ffffffffc020093a:	5e50006f          	j	ffffffffc020171e <do_pgfault>
        assert(current == idleproc);
ffffffffc020093e:	00006697          	auipc	a3,0x6
ffffffffc0200942:	33a68693          	addi	a3,a3,826 # ffffffffc0206c78 <commands+0x3f8>
ffffffffc0200946:	00006617          	auipc	a2,0x6
ffffffffc020094a:	34a60613          	addi	a2,a2,842 # ffffffffc0206c90 <commands+0x410>
ffffffffc020094e:	06b00593          	li	a1,107
ffffffffc0200952:	00006517          	auipc	a0,0x6
ffffffffc0200956:	35650513          	addi	a0,a0,854 # ffffffffc0206ca8 <commands+0x428>
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
ffffffffc020098c:	2d050513          	addi	a0,a0,720 # ffffffffc0206c58 <commands+0x3d8>
ffffffffc0200990:	f3cff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            panic("unhandled page fault.\n");
ffffffffc0200994:	00006617          	auipc	a2,0x6
ffffffffc0200998:	32c60613          	addi	a2,a2,812 # ffffffffc0206cc0 <commands+0x440>
ffffffffc020099c:	07200593          	li	a1,114
ffffffffc02009a0:	00006517          	auipc	a0,0x6
ffffffffc02009a4:	30850513          	addi	a0,a0,776 # ffffffffc0206ca8 <commands+0x428>
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
ffffffffc02009c4:	3b870713          	addi	a4,a4,952 # ffffffffc0206d78 <commands+0x4f8>
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
ffffffffc02009d6:	36650513          	addi	a0,a0,870 # ffffffffc0206d38 <commands+0x4b8>
ffffffffc02009da:	ef2ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009de:	00006517          	auipc	a0,0x6
ffffffffc02009e2:	33a50513          	addi	a0,a0,826 # ffffffffc0206d18 <commands+0x498>
ffffffffc02009e6:	ee6ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02009ea:	00006517          	auipc	a0,0x6
ffffffffc02009ee:	2ee50513          	addi	a0,a0,750 # ffffffffc0206cd8 <commands+0x458>
ffffffffc02009f2:	edaff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02009f6:	00006517          	auipc	a0,0x6
ffffffffc02009fa:	30250513          	addi	a0,a0,770 # ffffffffc0206cf8 <commands+0x478>
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
ffffffffc0200a0e:	e3e68693          	addi	a3,a3,-450 # ffffffffc02b2848 <ticks>
ffffffffc0200a12:	629c                	ld	a5,0(a3)
ffffffffc0200a14:	06400713          	li	a4,100
ffffffffc0200a18:	0785                	addi	a5,a5,1
ffffffffc0200a1a:	02e7f733          	remu	a4,a5,a4
ffffffffc0200a1e:	e29c                	sd	a5,0(a3)
ffffffffc0200a20:	eb01                	bnez	a4,ffffffffc0200a30 <interrupt_handler+0x7e>
ffffffffc0200a22:	000b2797          	auipc	a5,0xb2
ffffffffc0200a26:	e967b783          	ld	a5,-362(a5) # ffffffffc02b28b8 <current>
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
ffffffffc0200a3a:	32250513          	addi	a0,a0,802 # ffffffffc0206d58 <commands+0x4d8>
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
ffffffffc0200a5c:	4e870713          	addi	a4,a4,1256 # ffffffffc0206f40 <commands+0x6c0>
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
ffffffffc0200a6e:	42e50513          	addi	a0,a0,1070 # ffffffffc0206e98 <commands+0x618>
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
ffffffffc0200a88:	6260506f          	j	ffffffffc02060ae <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a8c:	00006517          	auipc	a0,0x6
ffffffffc0200a90:	42c50513          	addi	a0,a0,1068 # ffffffffc0206eb8 <commands+0x638>
}
ffffffffc0200a94:	6442                	ld	s0,16(sp)
ffffffffc0200a96:	60e2                	ld	ra,24(sp)
ffffffffc0200a98:	64a2                	ld	s1,8(sp)
ffffffffc0200a9a:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200a9c:	e30ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200aa0:	00006517          	auipc	a0,0x6
ffffffffc0200aa4:	43850513          	addi	a0,a0,1080 # ffffffffc0206ed8 <commands+0x658>
ffffffffc0200aa8:	b7f5                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200aaa:	00006517          	auipc	a0,0x6
ffffffffc0200aae:	44e50513          	addi	a0,a0,1102 # ffffffffc0206ef8 <commands+0x678>
ffffffffc0200ab2:	b7cd                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200ab4:	00006517          	auipc	a0,0x6
ffffffffc0200ab8:	45c50513          	addi	a0,a0,1116 # ffffffffc0206f10 <commands+0x690>
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
ffffffffc0200ada:	45250513          	addi	a0,a0,1106 # ffffffffc0206f28 <commands+0x6a8>
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
ffffffffc0200af8:	35460613          	addi	a2,a2,852 # ffffffffc0206e48 <commands+0x5c8>
ffffffffc0200afc:	0f800593          	li	a1,248
ffffffffc0200b00:	00006517          	auipc	a0,0x6
ffffffffc0200b04:	1a850513          	addi	a0,a0,424 # ffffffffc0206ca8 <commands+0x428>
ffffffffc0200b08:	f00ff0ef          	jal	ra,ffffffffc0200208 <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200b0c:	00006517          	auipc	a0,0x6
ffffffffc0200b10:	29c50513          	addi	a0,a0,668 # ffffffffc0206da8 <commands+0x528>
ffffffffc0200b14:	b741                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200b16:	00006517          	auipc	a0,0x6
ffffffffc0200b1a:	2b250513          	addi	a0,a0,690 # ffffffffc0206dc8 <commands+0x548>
ffffffffc0200b1e:	bf9d                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200b20:	00006517          	auipc	a0,0x6
ffffffffc0200b24:	2c850513          	addi	a0,a0,712 # ffffffffc0206de8 <commands+0x568>
ffffffffc0200b28:	b7b5                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b2a:	00006517          	auipc	a0,0x6
ffffffffc0200b2e:	2d650513          	addi	a0,a0,726 # ffffffffc0206e00 <commands+0x580>
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
ffffffffc0200b48:	566050ef          	jal	ra,ffffffffc02060ae <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b4c:	000b2797          	auipc	a5,0xb2
ffffffffc0200b50:	d6c7b783          	ld	a5,-660(a5) # ffffffffc02b28b8 <current>
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
ffffffffc0200b6a:	2aa50513          	addi	a0,a0,682 # ffffffffc0206e10 <commands+0x590>
ffffffffc0200b6e:	b71d                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200b70:	00006517          	auipc	a0,0x6
ffffffffc0200b74:	2c050513          	addi	a0,a0,704 # ffffffffc0206e30 <commands+0x5b0>
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
ffffffffc0200b92:	2ba60613          	addi	a2,a2,698 # ffffffffc0206e48 <commands+0x5c8>
ffffffffc0200b96:	0cd00593          	li	a1,205
ffffffffc0200b9a:	00006517          	auipc	a0,0x6
ffffffffc0200b9e:	10e50513          	addi	a0,a0,270 # ffffffffc0206ca8 <commands+0x428>
ffffffffc0200ba2:	e66ff0ef          	jal	ra,ffffffffc0200208 <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200ba6:	00006517          	auipc	a0,0x6
ffffffffc0200baa:	2da50513          	addi	a0,a0,730 # ffffffffc0206e80 <commands+0x600>
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
ffffffffc0200bca:	28260613          	addi	a2,a2,642 # ffffffffc0206e48 <commands+0x5c8>
ffffffffc0200bce:	0d700593          	li	a1,215
ffffffffc0200bd2:	00006517          	auipc	a0,0x6
ffffffffc0200bd6:	0d650513          	addi	a0,a0,214 # ffffffffc0206ca8 <commands+0x428>
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
ffffffffc0200bee:	27e60613          	addi	a2,a2,638 # ffffffffc0206e68 <commands+0x5e8>
ffffffffc0200bf2:	0d100593          	li	a1,209
ffffffffc0200bf6:	00006517          	auipc	a0,0x6
ffffffffc0200bfa:	0b250513          	addi	a0,a0,178 # ffffffffc0206ca8 <commands+0x428>
ffffffffc0200bfe:	e0aff0ef          	jal	ra,ffffffffc0200208 <__panic>
                print_trapframe(tf);
ffffffffc0200c02:	8522                	mv	a0,s0
ffffffffc0200c04:	c33ff0ef          	jal	ra,ffffffffc0200836 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200c08:	86a6                	mv	a3,s1
ffffffffc0200c0a:	00006617          	auipc	a2,0x6
ffffffffc0200c0e:	23e60613          	addi	a2,a2,574 # ffffffffc0206e48 <commands+0x5c8>
ffffffffc0200c12:	0f100593          	li	a1,241
ffffffffc0200c16:	00006517          	auipc	a0,0x6
ffffffffc0200c1a:	09250513          	addi	a0,a0,146 # ffffffffc0206ca8 <commands+0x428>
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
ffffffffc0200c2a:	c9240413          	addi	s0,s0,-878 # ffffffffc02b28b8 <current>
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
ffffffffc0200c9e:	3240506f          	j	ffffffffc0205fc2 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200ca2:	555d                	li	a0,-9
ffffffffc0200ca4:	6ce040ef          	jal	ra,ffffffffc0205372 <do_exit>
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
ffffffffc0200d7a:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7cd8>

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
ffffffffc0200e28:	15c68693          	addi	a3,a3,348 # ffffffffc0206f80 <commands+0x700>
ffffffffc0200e2c:	00006617          	auipc	a2,0x6
ffffffffc0200e30:	e6460613          	addi	a2,a2,-412 # ffffffffc0206c90 <commands+0x410>
ffffffffc0200e34:	06d00593          	li	a1,109
ffffffffc0200e38:	00006517          	auipc	a0,0x6
ffffffffc0200e3c:	16850513          	addi	a0,a0,360 # ffffffffc0206fa0 <commands+0x720>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200e40:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0200e42:	bc6ff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0200e46 <mm_create>:
mm_create(void) {
ffffffffc0200e46:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200e48:	04000513          	li	a0,64
mm_create(void) {
ffffffffc0200e4c:	e022                	sd	s0,0(sp)
ffffffffc0200e4e:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200e50:	57c010ef          	jal	ra,ffffffffc02023cc <kmalloc>
ffffffffc0200e54:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0200e56:	c505                	beqz	a0,ffffffffc0200e7e <mm_create+0x38>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200e58:	e408                	sd	a0,8(s0)
ffffffffc0200e5a:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0200e5c:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200e60:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200e64:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200e68:	000b2797          	auipc	a5,0xb2
ffffffffc0200e6c:	a107a783          	lw	a5,-1520(a5) # ffffffffc02b2878 <swap_init_ok>
ffffffffc0200e70:	ef81                	bnez	a5,ffffffffc0200e88 <mm_create+0x42>
        else mm->sm_priv = NULL;
ffffffffc0200e72:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc0200e76:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc0200e7a:	02043c23          	sd	zero,56(s0)
}
ffffffffc0200e7e:	60a2                	ld	ra,8(sp)
ffffffffc0200e80:	8522                	mv	a0,s0
ffffffffc0200e82:	6402                	ld	s0,0(sp)
ffffffffc0200e84:	0141                	addi	sp,sp,16
ffffffffc0200e86:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200e88:	16c010ef          	jal	ra,ffffffffc0201ff4 <swap_init_mm>
ffffffffc0200e8c:	b7ed                	j	ffffffffc0200e76 <mm_create+0x30>

ffffffffc0200e8e <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0200e8e:	1101                	addi	sp,sp,-32
ffffffffc0200e90:	e04a                	sd	s2,0(sp)
ffffffffc0200e92:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200e94:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0200e98:	e822                	sd	s0,16(sp)
ffffffffc0200e9a:	e426                	sd	s1,8(sp)
ffffffffc0200e9c:	ec06                	sd	ra,24(sp)
ffffffffc0200e9e:	84ae                	mv	s1,a1
ffffffffc0200ea0:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200ea2:	52a010ef          	jal	ra,ffffffffc02023cc <kmalloc>
    if (vma != NULL) {
ffffffffc0200ea6:	c509                	beqz	a0,ffffffffc0200eb0 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0200ea8:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200eac:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200eae:	cd00                	sw	s0,24(a0)
}
ffffffffc0200eb0:	60e2                	ld	ra,24(sp)
ffffffffc0200eb2:	6442                	ld	s0,16(sp)
ffffffffc0200eb4:	64a2                	ld	s1,8(sp)
ffffffffc0200eb6:	6902                	ld	s2,0(sp)
ffffffffc0200eb8:	6105                	addi	sp,sp,32
ffffffffc0200eba:	8082                	ret

ffffffffc0200ebc <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc0200ebc:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc0200ebe:	c505                	beqz	a0,ffffffffc0200ee6 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0200ec0:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0200ec2:	c501                	beqz	a0,ffffffffc0200eca <find_vma+0xe>
ffffffffc0200ec4:	651c                	ld	a5,8(a0)
ffffffffc0200ec6:	02f5f263          	bgeu	a1,a5,ffffffffc0200eea <find_vma+0x2e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200eca:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc0200ecc:	00f68d63          	beq	a3,a5,ffffffffc0200ee6 <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0200ed0:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200ed4:	00e5e663          	bltu	a1,a4,ffffffffc0200ee0 <find_vma+0x24>
ffffffffc0200ed8:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200edc:	00e5ec63          	bltu	a1,a4,ffffffffc0200ef4 <find_vma+0x38>
ffffffffc0200ee0:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0200ee2:	fef697e3          	bne	a3,a5,ffffffffc0200ed0 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0200ee6:	4501                	li	a0,0
}
ffffffffc0200ee8:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0200eea:	691c                	ld	a5,16(a0)
ffffffffc0200eec:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0200eca <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0200ef0:	ea88                	sd	a0,16(a3)
ffffffffc0200ef2:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc0200ef4:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0200ef8:	ea88                	sd	a0,16(a3)
ffffffffc0200efa:	8082                	ret

ffffffffc0200efc <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200efc:	6590                	ld	a2,8(a1)
ffffffffc0200efe:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0200f02:	1141                	addi	sp,sp,-16
ffffffffc0200f04:	e406                	sd	ra,8(sp)
ffffffffc0200f06:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200f08:	01066763          	bltu	a2,a6,ffffffffc0200f16 <insert_vma_struct+0x1a>
ffffffffc0200f0c:	a085                	j	ffffffffc0200f6c <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0200f0e:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200f12:	04e66863          	bltu	a2,a4,ffffffffc0200f62 <insert_vma_struct+0x66>
ffffffffc0200f16:	86be                	mv	a3,a5
ffffffffc0200f18:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0200f1a:	fef51ae3          	bne	a0,a5,ffffffffc0200f0e <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0200f1e:	02a68463          	beq	a3,a0,ffffffffc0200f46 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0200f22:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200f26:	fe86b883          	ld	a7,-24(a3)
ffffffffc0200f2a:	08e8f163          	bgeu	a7,a4,ffffffffc0200fac <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200f2e:	04e66f63          	bltu	a2,a4,ffffffffc0200f8c <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc0200f32:	00f50a63          	beq	a0,a5,ffffffffc0200f46 <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0200f36:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200f3a:	05076963          	bltu	a4,a6,ffffffffc0200f8c <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc0200f3e:	ff07b603          	ld	a2,-16(a5)
ffffffffc0200f42:	02c77363          	bgeu	a4,a2,ffffffffc0200f68 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0200f46:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0200f48:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0200f4a:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200f4e:	e390                	sd	a2,0(a5)
ffffffffc0200f50:	e690                	sd	a2,8(a3)
}
ffffffffc0200f52:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0200f54:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0200f56:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc0200f58:	0017079b          	addiw	a5,a4,1
ffffffffc0200f5c:	d11c                	sw	a5,32(a0)
}
ffffffffc0200f5e:	0141                	addi	sp,sp,16
ffffffffc0200f60:	8082                	ret
    if (le_prev != list) {
ffffffffc0200f62:	fca690e3          	bne	a3,a0,ffffffffc0200f22 <insert_vma_struct+0x26>
ffffffffc0200f66:	bfd1                	j	ffffffffc0200f3a <insert_vma_struct+0x3e>
ffffffffc0200f68:	ebbff0ef          	jal	ra,ffffffffc0200e22 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200f6c:	00006697          	auipc	a3,0x6
ffffffffc0200f70:	04468693          	addi	a3,a3,68 # ffffffffc0206fb0 <commands+0x730>
ffffffffc0200f74:	00006617          	auipc	a2,0x6
ffffffffc0200f78:	d1c60613          	addi	a2,a2,-740 # ffffffffc0206c90 <commands+0x410>
ffffffffc0200f7c:	07400593          	li	a1,116
ffffffffc0200f80:	00006517          	auipc	a0,0x6
ffffffffc0200f84:	02050513          	addi	a0,a0,32 # ffffffffc0206fa0 <commands+0x720>
ffffffffc0200f88:	a80ff0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200f8c:	00006697          	auipc	a3,0x6
ffffffffc0200f90:	06468693          	addi	a3,a3,100 # ffffffffc0206ff0 <commands+0x770>
ffffffffc0200f94:	00006617          	auipc	a2,0x6
ffffffffc0200f98:	cfc60613          	addi	a2,a2,-772 # ffffffffc0206c90 <commands+0x410>
ffffffffc0200f9c:	06c00593          	li	a1,108
ffffffffc0200fa0:	00006517          	auipc	a0,0x6
ffffffffc0200fa4:	00050513          	mv	a0,a0
ffffffffc0200fa8:	a60ff0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200fac:	00006697          	auipc	a3,0x6
ffffffffc0200fb0:	02468693          	addi	a3,a3,36 # ffffffffc0206fd0 <commands+0x750>
ffffffffc0200fb4:	00006617          	auipc	a2,0x6
ffffffffc0200fb8:	cdc60613          	addi	a2,a2,-804 # ffffffffc0206c90 <commands+0x410>
ffffffffc0200fbc:	06b00593          	li	a1,107
ffffffffc0200fc0:	00006517          	auipc	a0,0x6
ffffffffc0200fc4:	fe050513          	addi	a0,a0,-32 # ffffffffc0206fa0 <commands+0x720>
ffffffffc0200fc8:	a40ff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0200fcc <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc0200fcc:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc0200fce:	1141                	addi	sp,sp,-16
ffffffffc0200fd0:	e406                	sd	ra,8(sp)
ffffffffc0200fd2:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0200fd4:	e78d                	bnez	a5,ffffffffc0200ffe <mm_destroy+0x32>
ffffffffc0200fd6:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0200fd8:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0200fda:	00a40c63          	beq	s0,a0,ffffffffc0200ff2 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200fde:	6118                	ld	a4,0(a0)
ffffffffc0200fe0:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0200fe2:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200fe4:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200fe6:	e398                	sd	a4,0(a5)
ffffffffc0200fe8:	494010ef          	jal	ra,ffffffffc020247c <kfree>
    return listelm->next;
ffffffffc0200fec:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0200fee:	fea418e3          	bne	s0,a0,ffffffffc0200fde <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc0200ff2:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0200ff4:	6402                	ld	s0,0(sp)
ffffffffc0200ff6:	60a2                	ld	ra,8(sp)
ffffffffc0200ff8:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc0200ffa:	4820106f          	j	ffffffffc020247c <kfree>
    assert(mm_count(mm) == 0);
ffffffffc0200ffe:	00006697          	auipc	a3,0x6
ffffffffc0201002:	01268693          	addi	a3,a3,18 # ffffffffc0207010 <commands+0x790>
ffffffffc0201006:	00006617          	auipc	a2,0x6
ffffffffc020100a:	c8a60613          	addi	a2,a2,-886 # ffffffffc0206c90 <commands+0x410>
ffffffffc020100e:	09400593          	li	a1,148
ffffffffc0201012:	00006517          	auipc	a0,0x6
ffffffffc0201016:	f8e50513          	addi	a0,a0,-114 # ffffffffc0206fa0 <commands+0x720>
ffffffffc020101a:	9eeff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020101e <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
ffffffffc020101e:	7139                	addi	sp,sp,-64
ffffffffc0201020:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0201022:	6405                	lui	s0,0x1
ffffffffc0201024:	147d                	addi	s0,s0,-1
ffffffffc0201026:	77fd                	lui	a5,0xfffff
ffffffffc0201028:	9622                	add	a2,a2,s0
ffffffffc020102a:	962e                	add	a2,a2,a1
       struct vma_struct **vma_store) {
ffffffffc020102c:	f426                	sd	s1,40(sp)
ffffffffc020102e:	fc06                	sd	ra,56(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0201030:	00f5f4b3          	and	s1,a1,a5
       struct vma_struct **vma_store) {
ffffffffc0201034:	f04a                	sd	s2,32(sp)
ffffffffc0201036:	ec4e                	sd	s3,24(sp)
ffffffffc0201038:	e852                	sd	s4,16(sp)
ffffffffc020103a:	e456                	sd	s5,8(sp)
    if (!USER_ACCESS(start, end)) {
ffffffffc020103c:	002005b7          	lui	a1,0x200
ffffffffc0201040:	00f67433          	and	s0,a2,a5
ffffffffc0201044:	06b4e363          	bltu	s1,a1,ffffffffc02010aa <mm_map+0x8c>
ffffffffc0201048:	0684f163          	bgeu	s1,s0,ffffffffc02010aa <mm_map+0x8c>
ffffffffc020104c:	4785                	li	a5,1
ffffffffc020104e:	07fe                	slli	a5,a5,0x1f
ffffffffc0201050:	0487ed63          	bltu	a5,s0,ffffffffc02010aa <mm_map+0x8c>
ffffffffc0201054:	89aa                	mv	s3,a0
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc0201056:	cd21                	beqz	a0,ffffffffc02010ae <mm_map+0x90>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc0201058:	85a6                	mv	a1,s1
ffffffffc020105a:	8ab6                	mv	s5,a3
ffffffffc020105c:	8a3a                	mv	s4,a4
ffffffffc020105e:	e5fff0ef          	jal	ra,ffffffffc0200ebc <find_vma>
ffffffffc0201062:	c501                	beqz	a0,ffffffffc020106a <mm_map+0x4c>
ffffffffc0201064:	651c                	ld	a5,8(a0)
ffffffffc0201066:	0487e263          	bltu	a5,s0,ffffffffc02010aa <mm_map+0x8c>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020106a:	03000513          	li	a0,48
ffffffffc020106e:	35e010ef          	jal	ra,ffffffffc02023cc <kmalloc>
ffffffffc0201072:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc0201074:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc0201076:	02090163          	beqz	s2,ffffffffc0201098 <mm_map+0x7a>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc020107a:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc020107c:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc0201080:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc0201084:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc0201088:	85ca                	mv	a1,s2
ffffffffc020108a:	e73ff0ef          	jal	ra,ffffffffc0200efc <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc020108e:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc0201090:	000a0463          	beqz	s4,ffffffffc0201098 <mm_map+0x7a>
        *vma_store = vma;
ffffffffc0201094:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc0201098:	70e2                	ld	ra,56(sp)
ffffffffc020109a:	7442                	ld	s0,48(sp)
ffffffffc020109c:	74a2                	ld	s1,40(sp)
ffffffffc020109e:	7902                	ld	s2,32(sp)
ffffffffc02010a0:	69e2                	ld	s3,24(sp)
ffffffffc02010a2:	6a42                	ld	s4,16(sp)
ffffffffc02010a4:	6aa2                	ld	s5,8(sp)
ffffffffc02010a6:	6121                	addi	sp,sp,64
ffffffffc02010a8:	8082                	ret
        return -E_INVAL;
ffffffffc02010aa:	5575                	li	a0,-3
ffffffffc02010ac:	b7f5                	j	ffffffffc0201098 <mm_map+0x7a>
    assert(mm != NULL);
ffffffffc02010ae:	00006697          	auipc	a3,0x6
ffffffffc02010b2:	f7a68693          	addi	a3,a3,-134 # ffffffffc0207028 <commands+0x7a8>
ffffffffc02010b6:	00006617          	auipc	a2,0x6
ffffffffc02010ba:	bda60613          	addi	a2,a2,-1062 # ffffffffc0206c90 <commands+0x410>
ffffffffc02010be:	0a700593          	li	a1,167
ffffffffc02010c2:	00006517          	auipc	a0,0x6
ffffffffc02010c6:	ede50513          	addi	a0,a0,-290 # ffffffffc0206fa0 <commands+0x720>
ffffffffc02010ca:	93eff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02010ce <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc02010ce:	7139                	addi	sp,sp,-64
ffffffffc02010d0:	fc06                	sd	ra,56(sp)
ffffffffc02010d2:	f822                	sd	s0,48(sp)
ffffffffc02010d4:	f426                	sd	s1,40(sp)
ffffffffc02010d6:	f04a                	sd	s2,32(sp)
ffffffffc02010d8:	ec4e                	sd	s3,24(sp)
ffffffffc02010da:	e852                	sd	s4,16(sp)
ffffffffc02010dc:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc02010de:	c52d                	beqz	a0,ffffffffc0201148 <dup_mmap+0x7a>
ffffffffc02010e0:	892a                	mv	s2,a0
ffffffffc02010e2:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc02010e4:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc02010e6:	e595                	bnez	a1,ffffffffc0201112 <dup_mmap+0x44>
ffffffffc02010e8:	a085                	j	ffffffffc0201148 <dup_mmap+0x7a>
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc02010ea:	854a                	mv	a0,s2
        vma->vm_start = vm_start;
ffffffffc02010ec:	0155b423          	sd	s5,8(a1) # 200008 <_binary_obj___user_exit_out_size+0x1f4ee0>
        vma->vm_end = vm_end;
ffffffffc02010f0:	0145b823          	sd	s4,16(a1)
        vma->vm_flags = vm_flags;
ffffffffc02010f4:	0135ac23          	sw	s3,24(a1)
        insert_vma_struct(to, nvma);
ffffffffc02010f8:	e05ff0ef          	jal	ra,ffffffffc0200efc <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
ffffffffc02010fc:	ff043683          	ld	a3,-16(s0) # ff0 <_binary_obj___user_faultread_out_size-0x8bc8>
ffffffffc0201100:	fe843603          	ld	a2,-24(s0)
ffffffffc0201104:	6c8c                	ld	a1,24(s1)
ffffffffc0201106:	01893503          	ld	a0,24(s2)
ffffffffc020110a:	4701                	li	a4,0
ffffffffc020110c:	774030ef          	jal	ra,ffffffffc0204880 <copy_range>
ffffffffc0201110:	e105                	bnez	a0,ffffffffc0201130 <dup_mmap+0x62>
    return listelm->prev;
ffffffffc0201112:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc0201114:	02848863          	beq	s1,s0,ffffffffc0201144 <dup_mmap+0x76>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201118:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc020111c:	fe843a83          	ld	s5,-24(s0)
ffffffffc0201120:	ff043a03          	ld	s4,-16(s0)
ffffffffc0201124:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201128:	2a4010ef          	jal	ra,ffffffffc02023cc <kmalloc>
ffffffffc020112c:	85aa                	mv	a1,a0
    if (vma != NULL) {
ffffffffc020112e:	fd55                	bnez	a0,ffffffffc02010ea <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc0201130:	5571                	li	a0,-4
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc0201132:	70e2                	ld	ra,56(sp)
ffffffffc0201134:	7442                	ld	s0,48(sp)
ffffffffc0201136:	74a2                	ld	s1,40(sp)
ffffffffc0201138:	7902                	ld	s2,32(sp)
ffffffffc020113a:	69e2                	ld	s3,24(sp)
ffffffffc020113c:	6a42                	ld	s4,16(sp)
ffffffffc020113e:	6aa2                	ld	s5,8(sp)
ffffffffc0201140:	6121                	addi	sp,sp,64
ffffffffc0201142:	8082                	ret
    return 0;
ffffffffc0201144:	4501                	li	a0,0
ffffffffc0201146:	b7f5                	j	ffffffffc0201132 <dup_mmap+0x64>
    assert(to != NULL && from != NULL);
ffffffffc0201148:	00006697          	auipc	a3,0x6
ffffffffc020114c:	ef068693          	addi	a3,a3,-272 # ffffffffc0207038 <commands+0x7b8>
ffffffffc0201150:	00006617          	auipc	a2,0x6
ffffffffc0201154:	b4060613          	addi	a2,a2,-1216 # ffffffffc0206c90 <commands+0x410>
ffffffffc0201158:	0c000593          	li	a1,192
ffffffffc020115c:	00006517          	auipc	a0,0x6
ffffffffc0201160:	e4450513          	addi	a0,a0,-444 # ffffffffc0206fa0 <commands+0x720>
ffffffffc0201164:	8a4ff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0201168 <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
ffffffffc0201168:	1101                	addi	sp,sp,-32
ffffffffc020116a:	ec06                	sd	ra,24(sp)
ffffffffc020116c:	e822                	sd	s0,16(sp)
ffffffffc020116e:	e426                	sd	s1,8(sp)
ffffffffc0201170:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0201172:	c531                	beqz	a0,ffffffffc02011be <exit_mmap+0x56>
ffffffffc0201174:	591c                	lw	a5,48(a0)
ffffffffc0201176:	84aa                	mv	s1,a0
ffffffffc0201178:	e3b9                	bnez	a5,ffffffffc02011be <exit_mmap+0x56>
    return listelm->next;
ffffffffc020117a:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc020117c:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc0201180:	02850663          	beq	a0,s0,ffffffffc02011ac <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0201184:	ff043603          	ld	a2,-16(s0)
ffffffffc0201188:	fe843583          	ld	a1,-24(s0)
ffffffffc020118c:	854a                	mv	a0,s2
ffffffffc020118e:	5ee020ef          	jal	ra,ffffffffc020377c <unmap_range>
ffffffffc0201192:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0201194:	fe8498e3          	bne	s1,s0,ffffffffc0201184 <exit_mmap+0x1c>
ffffffffc0201198:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc020119a:	00848c63          	beq	s1,s0,ffffffffc02011b2 <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc020119e:	ff043603          	ld	a2,-16(s0)
ffffffffc02011a2:	fe843583          	ld	a1,-24(s0)
ffffffffc02011a6:	854a                	mv	a0,s2
ffffffffc02011a8:	71a020ef          	jal	ra,ffffffffc02038c2 <exit_range>
ffffffffc02011ac:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc02011ae:	fe8498e3          	bne	s1,s0,ffffffffc020119e <exit_mmap+0x36>
    }
}
ffffffffc02011b2:	60e2                	ld	ra,24(sp)
ffffffffc02011b4:	6442                	ld	s0,16(sp)
ffffffffc02011b6:	64a2                	ld	s1,8(sp)
ffffffffc02011b8:	6902                	ld	s2,0(sp)
ffffffffc02011ba:	6105                	addi	sp,sp,32
ffffffffc02011bc:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc02011be:	00006697          	auipc	a3,0x6
ffffffffc02011c2:	e9a68693          	addi	a3,a3,-358 # ffffffffc0207058 <commands+0x7d8>
ffffffffc02011c6:	00006617          	auipc	a2,0x6
ffffffffc02011ca:	aca60613          	addi	a2,a2,-1334 # ffffffffc0206c90 <commands+0x410>
ffffffffc02011ce:	0d600593          	li	a1,214
ffffffffc02011d2:	00006517          	auipc	a0,0x6
ffffffffc02011d6:	dce50513          	addi	a0,a0,-562 # ffffffffc0206fa0 <commands+0x720>
ffffffffc02011da:	82eff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02011de <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc02011de:	7139                	addi	sp,sp,-64
ffffffffc02011e0:	f822                	sd	s0,48(sp)
ffffffffc02011e2:	f426                	sd	s1,40(sp)
ffffffffc02011e4:	fc06                	sd	ra,56(sp)
ffffffffc02011e6:	f04a                	sd	s2,32(sp)
ffffffffc02011e8:	ec4e                	sd	s3,24(sp)
ffffffffc02011ea:	e852                	sd	s4,16(sp)
ffffffffc02011ec:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc02011ee:	c59ff0ef          	jal	ra,ffffffffc0200e46 <mm_create>
    assert(mm != NULL);
ffffffffc02011f2:	84aa                	mv	s1,a0
ffffffffc02011f4:	03200413          	li	s0,50
ffffffffc02011f8:	e919                	bnez	a0,ffffffffc020120e <vmm_init+0x30>
ffffffffc02011fa:	a991                	j	ffffffffc020164e <vmm_init+0x470>
        vma->vm_start = vm_start;
ffffffffc02011fc:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc02011fe:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201200:	00052c23          	sw	zero,24(a0)

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc0201204:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0201206:	8526                	mv	a0,s1
ffffffffc0201208:	cf5ff0ef          	jal	ra,ffffffffc0200efc <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc020120c:	c80d                	beqz	s0,ffffffffc020123e <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020120e:	03000513          	li	a0,48
ffffffffc0201212:	1ba010ef          	jal	ra,ffffffffc02023cc <kmalloc>
ffffffffc0201216:	85aa                	mv	a1,a0
ffffffffc0201218:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc020121c:	f165                	bnez	a0,ffffffffc02011fc <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc020121e:	00006697          	auipc	a3,0x6
ffffffffc0201222:	0ca68693          	addi	a3,a3,202 # ffffffffc02072e8 <commands+0xa68>
ffffffffc0201226:	00006617          	auipc	a2,0x6
ffffffffc020122a:	a6a60613          	addi	a2,a2,-1430 # ffffffffc0206c90 <commands+0x410>
ffffffffc020122e:	11300593          	li	a1,275
ffffffffc0201232:	00006517          	auipc	a0,0x6
ffffffffc0201236:	d6e50513          	addi	a0,a0,-658 # ffffffffc0206fa0 <commands+0x720>
ffffffffc020123a:	fcffe0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc020123e:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0201242:	1f900913          	li	s2,505
ffffffffc0201246:	a819                	j	ffffffffc020125c <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc0201248:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc020124a:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020124c:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0201250:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0201252:	8526                	mv	a0,s1
ffffffffc0201254:	ca9ff0ef          	jal	ra,ffffffffc0200efc <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0201258:	03240a63          	beq	s0,s2,ffffffffc020128c <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020125c:	03000513          	li	a0,48
ffffffffc0201260:	16c010ef          	jal	ra,ffffffffc02023cc <kmalloc>
ffffffffc0201264:	85aa                	mv	a1,a0
ffffffffc0201266:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc020126a:	fd79                	bnez	a0,ffffffffc0201248 <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc020126c:	00006697          	auipc	a3,0x6
ffffffffc0201270:	07c68693          	addi	a3,a3,124 # ffffffffc02072e8 <commands+0xa68>
ffffffffc0201274:	00006617          	auipc	a2,0x6
ffffffffc0201278:	a1c60613          	addi	a2,a2,-1508 # ffffffffc0206c90 <commands+0x410>
ffffffffc020127c:	11900593          	li	a1,281
ffffffffc0201280:	00006517          	auipc	a0,0x6
ffffffffc0201284:	d2050513          	addi	a0,a0,-736 # ffffffffc0206fa0 <commands+0x720>
ffffffffc0201288:	f81fe0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc020128c:	649c                	ld	a5,8(s1)
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
        assert(le != &(mm->mmap_list));
ffffffffc020128e:	471d                	li	a4,7
    for (i = 1; i <= step2; i ++) {
ffffffffc0201290:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0201294:	2cf48d63          	beq	s1,a5,ffffffffc020156e <vmm_init+0x390>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0201298:	fe87b683          	ld	a3,-24(a5) # ffffffffffffefe8 <end+0x3fd4c714>
ffffffffc020129c:	ffe70613          	addi	a2,a4,-2
ffffffffc02012a0:	24d61763          	bne	a2,a3,ffffffffc02014ee <vmm_init+0x310>
ffffffffc02012a4:	ff07b683          	ld	a3,-16(a5)
ffffffffc02012a8:	24e69363          	bne	a3,a4,ffffffffc02014ee <vmm_init+0x310>
    for (i = 1; i <= step2; i ++) {
ffffffffc02012ac:	0715                	addi	a4,a4,5
ffffffffc02012ae:	679c                	ld	a5,8(a5)
ffffffffc02012b0:	feb712e3          	bne	a4,a1,ffffffffc0201294 <vmm_init+0xb6>
ffffffffc02012b4:	4a1d                	li	s4,7
ffffffffc02012b6:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02012b8:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc02012bc:	85a2                	mv	a1,s0
ffffffffc02012be:	8526                	mv	a0,s1
ffffffffc02012c0:	bfdff0ef          	jal	ra,ffffffffc0200ebc <find_vma>
ffffffffc02012c4:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc02012c6:	30050463          	beqz	a0,ffffffffc02015ce <vmm_init+0x3f0>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc02012ca:	00140593          	addi	a1,s0,1
ffffffffc02012ce:	8526                	mv	a0,s1
ffffffffc02012d0:	bedff0ef          	jal	ra,ffffffffc0200ebc <find_vma>
ffffffffc02012d4:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc02012d6:	2c050c63          	beqz	a0,ffffffffc02015ae <vmm_init+0x3d0>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc02012da:	85d2                	mv	a1,s4
ffffffffc02012dc:	8526                	mv	a0,s1
ffffffffc02012de:	bdfff0ef          	jal	ra,ffffffffc0200ebc <find_vma>
        assert(vma3 == NULL);
ffffffffc02012e2:	2a051663          	bnez	a0,ffffffffc020158e <vmm_init+0x3b0>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc02012e6:	00340593          	addi	a1,s0,3
ffffffffc02012ea:	8526                	mv	a0,s1
ffffffffc02012ec:	bd1ff0ef          	jal	ra,ffffffffc0200ebc <find_vma>
        assert(vma4 == NULL);
ffffffffc02012f0:	30051f63          	bnez	a0,ffffffffc020160e <vmm_init+0x430>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc02012f4:	00440593          	addi	a1,s0,4
ffffffffc02012f8:	8526                	mv	a0,s1
ffffffffc02012fa:	bc3ff0ef          	jal	ra,ffffffffc0200ebc <find_vma>
        assert(vma5 == NULL);
ffffffffc02012fe:	2e051863          	bnez	a0,ffffffffc02015ee <vmm_init+0x410>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0201302:	00893783          	ld	a5,8(s2)
ffffffffc0201306:	20879463          	bne	a5,s0,ffffffffc020150e <vmm_init+0x330>
ffffffffc020130a:	01093783          	ld	a5,16(s2)
ffffffffc020130e:	20fa1063          	bne	s4,a5,ffffffffc020150e <vmm_init+0x330>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0201312:	0089b783          	ld	a5,8(s3)
ffffffffc0201316:	20879c63          	bne	a5,s0,ffffffffc020152e <vmm_init+0x350>
ffffffffc020131a:	0109b783          	ld	a5,16(s3)
ffffffffc020131e:	20fa1863          	bne	s4,a5,ffffffffc020152e <vmm_init+0x350>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0201322:	0415                	addi	s0,s0,5
ffffffffc0201324:	0a15                	addi	s4,s4,5
ffffffffc0201326:	f9541be3          	bne	s0,s5,ffffffffc02012bc <vmm_init+0xde>
ffffffffc020132a:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc020132c:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc020132e:	85a2                	mv	a1,s0
ffffffffc0201330:	8526                	mv	a0,s1
ffffffffc0201332:	b8bff0ef          	jal	ra,ffffffffc0200ebc <find_vma>
ffffffffc0201336:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc020133a:	c90d                	beqz	a0,ffffffffc020136c <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc020133c:	6914                	ld	a3,16(a0)
ffffffffc020133e:	6510                	ld	a2,8(a0)
ffffffffc0201340:	00006517          	auipc	a0,0x6
ffffffffc0201344:	e3850513          	addi	a0,a0,-456 # ffffffffc0207178 <commands+0x8f8>
ffffffffc0201348:	d85fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc020134c:	00006697          	auipc	a3,0x6
ffffffffc0201350:	e5468693          	addi	a3,a3,-428 # ffffffffc02071a0 <commands+0x920>
ffffffffc0201354:	00006617          	auipc	a2,0x6
ffffffffc0201358:	93c60613          	addi	a2,a2,-1732 # ffffffffc0206c90 <commands+0x410>
ffffffffc020135c:	13b00593          	li	a1,315
ffffffffc0201360:	00006517          	auipc	a0,0x6
ffffffffc0201364:	c4050513          	addi	a0,a0,-960 # ffffffffc0206fa0 <commands+0x720>
ffffffffc0201368:	ea1fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    for (i =4; i>=0; i--) {
ffffffffc020136c:	147d                	addi	s0,s0,-1
ffffffffc020136e:	fd2410e3          	bne	s0,s2,ffffffffc020132e <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc0201372:	8526                	mv	a0,s1
ffffffffc0201374:	c59ff0ef          	jal	ra,ffffffffc0200fcc <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0201378:	00006517          	auipc	a0,0x6
ffffffffc020137c:	e4050513          	addi	a0,a0,-448 # ffffffffc02071b8 <commands+0x938>
ffffffffc0201380:	d4dfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0201384:	198020ef          	jal	ra,ffffffffc020351c <nr_free_pages>
ffffffffc0201388:	892a                	mv	s2,a0

    check_mm_struct = mm_create();
ffffffffc020138a:	abdff0ef          	jal	ra,ffffffffc0200e46 <mm_create>
ffffffffc020138e:	000b1797          	auipc	a5,0xb1
ffffffffc0201392:	4ca7b523          	sd	a0,1226(a5) # ffffffffc02b2858 <check_mm_struct>
ffffffffc0201396:	842a                	mv	s0,a0
    assert(check_mm_struct != NULL);
ffffffffc0201398:	28050b63          	beqz	a0,ffffffffc020162e <vmm_init+0x450>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020139c:	000b1497          	auipc	s1,0xb1
ffffffffc02013a0:	4f44b483          	ld	s1,1268(s1) # ffffffffc02b2890 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc02013a4:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02013a6:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc02013a8:	2e079f63          	bnez	a5,ffffffffc02016a6 <vmm_init+0x4c8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02013ac:	03000513          	li	a0,48
ffffffffc02013b0:	01c010ef          	jal	ra,ffffffffc02023cc <kmalloc>
ffffffffc02013b4:	89aa                	mv	s3,a0
    if (vma != NULL) {
ffffffffc02013b6:	18050c63          	beqz	a0,ffffffffc020154e <vmm_init+0x370>
        vma->vm_end = vm_end;
ffffffffc02013ba:	002007b7          	lui	a5,0x200
ffffffffc02013be:	00f9b823          	sd	a5,16(s3)
        vma->vm_flags = vm_flags;
ffffffffc02013c2:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc02013c4:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc02013c6:	00f9ac23          	sw	a5,24(s3)
    insert_vma_struct(mm, vma);
ffffffffc02013ca:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc02013cc:	0009b423          	sd	zero,8(s3)
    insert_vma_struct(mm, vma);
ffffffffc02013d0:	b2dff0ef          	jal	ra,ffffffffc0200efc <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc02013d4:	10000593          	li	a1,256
ffffffffc02013d8:	8522                	mv	a0,s0
ffffffffc02013da:	ae3ff0ef          	jal	ra,ffffffffc0200ebc <find_vma>
ffffffffc02013de:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc02013e2:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc02013e6:	2ea99063          	bne	s3,a0,ffffffffc02016c6 <vmm_init+0x4e8>
        *(char *)(addr + i) = i;
ffffffffc02013ea:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_exit_out_size+0x1f4ed8>
    for (i = 0; i < 100; i ++) {
ffffffffc02013ee:	0785                	addi	a5,a5,1
ffffffffc02013f0:	fee79de3          	bne	a5,a4,ffffffffc02013ea <vmm_init+0x20c>
        sum += i;
ffffffffc02013f4:	6705                	lui	a4,0x1
ffffffffc02013f6:	10000793          	li	a5,256
ffffffffc02013fa:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x8862>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc02013fe:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0201402:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc0201406:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc0201408:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc020140a:	fec79ce3          	bne	a5,a2,ffffffffc0201402 <vmm_init+0x224>
    }

    assert(sum == 0);
ffffffffc020140e:	2e071863          	bnez	a4,ffffffffc02016fe <vmm_init+0x520>
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
ffffffffc0201412:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc0201414:	000b1a97          	auipc	s5,0xb1
ffffffffc0201418:	484a8a93          	addi	s5,s5,1156 # ffffffffc02b2898 <npage>
ffffffffc020141c:	000ab603          	ld	a2,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201420:	078a                	slli	a5,a5,0x2
ffffffffc0201422:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201424:	2cc7f163          	bgeu	a5,a2,ffffffffc02016e6 <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc0201428:	00008a17          	auipc	s4,0x8
ffffffffc020142c:	888a3a03          	ld	s4,-1912(s4) # ffffffffc0208cb0 <nbase>
ffffffffc0201430:	414787b3          	sub	a5,a5,s4
ffffffffc0201434:	079a                	slli	a5,a5,0x6
    return page - pages + nbase;
ffffffffc0201436:	8799                	srai	a5,a5,0x6
ffffffffc0201438:	97d2                	add	a5,a5,s4
    return KADDR(page2pa(page));
ffffffffc020143a:	00c79713          	slli	a4,a5,0xc
ffffffffc020143e:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201440:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0201444:	24c77563          	bgeu	a4,a2,ffffffffc020168e <vmm_init+0x4b0>
ffffffffc0201448:	000b1997          	auipc	s3,0xb1
ffffffffc020144c:	4689b983          	ld	s3,1128(s3) # ffffffffc02b28b0 <va_pa_offset>

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0201450:	4581                	li	a1,0
ffffffffc0201452:	8526                	mv	a0,s1
ffffffffc0201454:	99b6                	add	s3,s3,a3
ffffffffc0201456:	6fe020ef          	jal	ra,ffffffffc0203b54 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc020145a:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc020145e:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201462:	078a                	slli	a5,a5,0x2
ffffffffc0201464:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201466:	28e7f063          	bgeu	a5,a4,ffffffffc02016e6 <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc020146a:	000b1997          	auipc	s3,0xb1
ffffffffc020146e:	43698993          	addi	s3,s3,1078 # ffffffffc02b28a0 <pages>
ffffffffc0201472:	0009b503          	ld	a0,0(s3)
ffffffffc0201476:	414787b3          	sub	a5,a5,s4
ffffffffc020147a:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc020147c:	953e                	add	a0,a0,a5
ffffffffc020147e:	4585                	li	a1,1
ffffffffc0201480:	05c020ef          	jal	ra,ffffffffc02034dc <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201484:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc0201486:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc020148a:	078a                	slli	a5,a5,0x2
ffffffffc020148c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020148e:	24e7fc63          	bgeu	a5,a4,ffffffffc02016e6 <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc0201492:	0009b503          	ld	a0,0(s3)
ffffffffc0201496:	414787b3          	sub	a5,a5,s4
ffffffffc020149a:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc020149c:	4585                	li	a1,1
ffffffffc020149e:	953e                	add	a0,a0,a5
ffffffffc02014a0:	03c020ef          	jal	ra,ffffffffc02034dc <free_pages>
    pgdir[0] = 0;
ffffffffc02014a4:	0004b023          	sd	zero,0(s1)
    page->ref -= 1;
    return page->ref;
}

static inline void flush_tlb() {
  asm volatile("sfence.vma");
ffffffffc02014a8:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
    mm_destroy(mm);
ffffffffc02014ac:	8522                	mv	a0,s0
    mm->pgdir = NULL;
ffffffffc02014ae:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc02014b2:	b1bff0ef          	jal	ra,ffffffffc0200fcc <mm_destroy>
    check_mm_struct = NULL;
ffffffffc02014b6:	000b1797          	auipc	a5,0xb1
ffffffffc02014ba:	3a07b123          	sd	zero,930(a5) # ffffffffc02b2858 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02014be:	05e020ef          	jal	ra,ffffffffc020351c <nr_free_pages>
ffffffffc02014c2:	1aa91663          	bne	s2,a0,ffffffffc020166e <vmm_init+0x490>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc02014c6:	00006517          	auipc	a0,0x6
ffffffffc02014ca:	dea50513          	addi	a0,a0,-534 # ffffffffc02072b0 <commands+0xa30>
ffffffffc02014ce:	bfffe0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc02014d2:	7442                	ld	s0,48(sp)
ffffffffc02014d4:	70e2                	ld	ra,56(sp)
ffffffffc02014d6:	74a2                	ld	s1,40(sp)
ffffffffc02014d8:	7902                	ld	s2,32(sp)
ffffffffc02014da:	69e2                	ld	s3,24(sp)
ffffffffc02014dc:	6a42                	ld	s4,16(sp)
ffffffffc02014de:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc02014e0:	00006517          	auipc	a0,0x6
ffffffffc02014e4:	df050513          	addi	a0,a0,-528 # ffffffffc02072d0 <commands+0xa50>
}
ffffffffc02014e8:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc02014ea:	be3fe06f          	j	ffffffffc02000cc <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02014ee:	00006697          	auipc	a3,0x6
ffffffffc02014f2:	ba268693          	addi	a3,a3,-1118 # ffffffffc0207090 <commands+0x810>
ffffffffc02014f6:	00005617          	auipc	a2,0x5
ffffffffc02014fa:	79a60613          	addi	a2,a2,1946 # ffffffffc0206c90 <commands+0x410>
ffffffffc02014fe:	12200593          	li	a1,290
ffffffffc0201502:	00006517          	auipc	a0,0x6
ffffffffc0201506:	a9e50513          	addi	a0,a0,-1378 # ffffffffc0206fa0 <commands+0x720>
ffffffffc020150a:	cfffe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020150e:	00006697          	auipc	a3,0x6
ffffffffc0201512:	c0a68693          	addi	a3,a3,-1014 # ffffffffc0207118 <commands+0x898>
ffffffffc0201516:	00005617          	auipc	a2,0x5
ffffffffc020151a:	77a60613          	addi	a2,a2,1914 # ffffffffc0206c90 <commands+0x410>
ffffffffc020151e:	13200593          	li	a1,306
ffffffffc0201522:	00006517          	auipc	a0,0x6
ffffffffc0201526:	a7e50513          	addi	a0,a0,-1410 # ffffffffc0206fa0 <commands+0x720>
ffffffffc020152a:	cdffe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020152e:	00006697          	auipc	a3,0x6
ffffffffc0201532:	c1a68693          	addi	a3,a3,-998 # ffffffffc0207148 <commands+0x8c8>
ffffffffc0201536:	00005617          	auipc	a2,0x5
ffffffffc020153a:	75a60613          	addi	a2,a2,1882 # ffffffffc0206c90 <commands+0x410>
ffffffffc020153e:	13300593          	li	a1,307
ffffffffc0201542:	00006517          	auipc	a0,0x6
ffffffffc0201546:	a5e50513          	addi	a0,a0,-1442 # ffffffffc0206fa0 <commands+0x720>
ffffffffc020154a:	cbffe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(vma != NULL);
ffffffffc020154e:	00006697          	auipc	a3,0x6
ffffffffc0201552:	d9a68693          	addi	a3,a3,-614 # ffffffffc02072e8 <commands+0xa68>
ffffffffc0201556:	00005617          	auipc	a2,0x5
ffffffffc020155a:	73a60613          	addi	a2,a2,1850 # ffffffffc0206c90 <commands+0x410>
ffffffffc020155e:	15200593          	li	a1,338
ffffffffc0201562:	00006517          	auipc	a0,0x6
ffffffffc0201566:	a3e50513          	addi	a0,a0,-1474 # ffffffffc0206fa0 <commands+0x720>
ffffffffc020156a:	c9ffe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc020156e:	00006697          	auipc	a3,0x6
ffffffffc0201572:	b0a68693          	addi	a3,a3,-1270 # ffffffffc0207078 <commands+0x7f8>
ffffffffc0201576:	00005617          	auipc	a2,0x5
ffffffffc020157a:	71a60613          	addi	a2,a2,1818 # ffffffffc0206c90 <commands+0x410>
ffffffffc020157e:	12000593          	li	a1,288
ffffffffc0201582:	00006517          	auipc	a0,0x6
ffffffffc0201586:	a1e50513          	addi	a0,a0,-1506 # ffffffffc0206fa0 <commands+0x720>
ffffffffc020158a:	c7ffe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma3 == NULL);
ffffffffc020158e:	00006697          	auipc	a3,0x6
ffffffffc0201592:	b5a68693          	addi	a3,a3,-1190 # ffffffffc02070e8 <commands+0x868>
ffffffffc0201596:	00005617          	auipc	a2,0x5
ffffffffc020159a:	6fa60613          	addi	a2,a2,1786 # ffffffffc0206c90 <commands+0x410>
ffffffffc020159e:	12c00593          	li	a1,300
ffffffffc02015a2:	00006517          	auipc	a0,0x6
ffffffffc02015a6:	9fe50513          	addi	a0,a0,-1538 # ffffffffc0206fa0 <commands+0x720>
ffffffffc02015aa:	c5ffe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma2 != NULL);
ffffffffc02015ae:	00006697          	auipc	a3,0x6
ffffffffc02015b2:	b2a68693          	addi	a3,a3,-1238 # ffffffffc02070d8 <commands+0x858>
ffffffffc02015b6:	00005617          	auipc	a2,0x5
ffffffffc02015ba:	6da60613          	addi	a2,a2,1754 # ffffffffc0206c90 <commands+0x410>
ffffffffc02015be:	12a00593          	li	a1,298
ffffffffc02015c2:	00006517          	auipc	a0,0x6
ffffffffc02015c6:	9de50513          	addi	a0,a0,-1570 # ffffffffc0206fa0 <commands+0x720>
ffffffffc02015ca:	c3ffe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma1 != NULL);
ffffffffc02015ce:	00006697          	auipc	a3,0x6
ffffffffc02015d2:	afa68693          	addi	a3,a3,-1286 # ffffffffc02070c8 <commands+0x848>
ffffffffc02015d6:	00005617          	auipc	a2,0x5
ffffffffc02015da:	6ba60613          	addi	a2,a2,1722 # ffffffffc0206c90 <commands+0x410>
ffffffffc02015de:	12800593          	li	a1,296
ffffffffc02015e2:	00006517          	auipc	a0,0x6
ffffffffc02015e6:	9be50513          	addi	a0,a0,-1602 # ffffffffc0206fa0 <commands+0x720>
ffffffffc02015ea:	c1ffe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma5 == NULL);
ffffffffc02015ee:	00006697          	auipc	a3,0x6
ffffffffc02015f2:	b1a68693          	addi	a3,a3,-1254 # ffffffffc0207108 <commands+0x888>
ffffffffc02015f6:	00005617          	auipc	a2,0x5
ffffffffc02015fa:	69a60613          	addi	a2,a2,1690 # ffffffffc0206c90 <commands+0x410>
ffffffffc02015fe:	13000593          	li	a1,304
ffffffffc0201602:	00006517          	auipc	a0,0x6
ffffffffc0201606:	99e50513          	addi	a0,a0,-1634 # ffffffffc0206fa0 <commands+0x720>
ffffffffc020160a:	bfffe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma4 == NULL);
ffffffffc020160e:	00006697          	auipc	a3,0x6
ffffffffc0201612:	aea68693          	addi	a3,a3,-1302 # ffffffffc02070f8 <commands+0x878>
ffffffffc0201616:	00005617          	auipc	a2,0x5
ffffffffc020161a:	67a60613          	addi	a2,a2,1658 # ffffffffc0206c90 <commands+0x410>
ffffffffc020161e:	12e00593          	li	a1,302
ffffffffc0201622:	00006517          	auipc	a0,0x6
ffffffffc0201626:	97e50513          	addi	a0,a0,-1666 # ffffffffc0206fa0 <commands+0x720>
ffffffffc020162a:	bdffe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc020162e:	00006697          	auipc	a3,0x6
ffffffffc0201632:	baa68693          	addi	a3,a3,-1110 # ffffffffc02071d8 <commands+0x958>
ffffffffc0201636:	00005617          	auipc	a2,0x5
ffffffffc020163a:	65a60613          	addi	a2,a2,1626 # ffffffffc0206c90 <commands+0x410>
ffffffffc020163e:	14b00593          	li	a1,331
ffffffffc0201642:	00006517          	auipc	a0,0x6
ffffffffc0201646:	95e50513          	addi	a0,a0,-1698 # ffffffffc0206fa0 <commands+0x720>
ffffffffc020164a:	bbffe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(mm != NULL);
ffffffffc020164e:	00006697          	auipc	a3,0x6
ffffffffc0201652:	9da68693          	addi	a3,a3,-1574 # ffffffffc0207028 <commands+0x7a8>
ffffffffc0201656:	00005617          	auipc	a2,0x5
ffffffffc020165a:	63a60613          	addi	a2,a2,1594 # ffffffffc0206c90 <commands+0x410>
ffffffffc020165e:	10c00593          	li	a1,268
ffffffffc0201662:	00006517          	auipc	a0,0x6
ffffffffc0201666:	93e50513          	addi	a0,a0,-1730 # ffffffffc0206fa0 <commands+0x720>
ffffffffc020166a:	b9ffe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020166e:	00006697          	auipc	a3,0x6
ffffffffc0201672:	c1a68693          	addi	a3,a3,-998 # ffffffffc0207288 <commands+0xa08>
ffffffffc0201676:	00005617          	auipc	a2,0x5
ffffffffc020167a:	61a60613          	addi	a2,a2,1562 # ffffffffc0206c90 <commands+0x410>
ffffffffc020167e:	17000593          	li	a1,368
ffffffffc0201682:	00006517          	auipc	a0,0x6
ffffffffc0201686:	91e50513          	addi	a0,a0,-1762 # ffffffffc0206fa0 <commands+0x720>
ffffffffc020168a:	b7ffe0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc020168e:	00006617          	auipc	a2,0x6
ffffffffc0201692:	bd260613          	addi	a2,a2,-1070 # ffffffffc0207260 <commands+0x9e0>
ffffffffc0201696:	06900593          	li	a1,105
ffffffffc020169a:	00006517          	auipc	a0,0x6
ffffffffc020169e:	bb650513          	addi	a0,a0,-1098 # ffffffffc0207250 <commands+0x9d0>
ffffffffc02016a2:	b67fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir[0] == 0);
ffffffffc02016a6:	00006697          	auipc	a3,0x6
ffffffffc02016aa:	b4a68693          	addi	a3,a3,-1206 # ffffffffc02071f0 <commands+0x970>
ffffffffc02016ae:	00005617          	auipc	a2,0x5
ffffffffc02016b2:	5e260613          	addi	a2,a2,1506 # ffffffffc0206c90 <commands+0x410>
ffffffffc02016b6:	14f00593          	li	a1,335
ffffffffc02016ba:	00006517          	auipc	a0,0x6
ffffffffc02016be:	8e650513          	addi	a0,a0,-1818 # ffffffffc0206fa0 <commands+0x720>
ffffffffc02016c2:	b47fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc02016c6:	00006697          	auipc	a3,0x6
ffffffffc02016ca:	b3a68693          	addi	a3,a3,-1222 # ffffffffc0207200 <commands+0x980>
ffffffffc02016ce:	00005617          	auipc	a2,0x5
ffffffffc02016d2:	5c260613          	addi	a2,a2,1474 # ffffffffc0206c90 <commands+0x410>
ffffffffc02016d6:	15700593          	li	a1,343
ffffffffc02016da:	00006517          	auipc	a0,0x6
ffffffffc02016de:	8c650513          	addi	a0,a0,-1850 # ffffffffc0206fa0 <commands+0x720>
ffffffffc02016e2:	b27fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02016e6:	00006617          	auipc	a2,0x6
ffffffffc02016ea:	b4a60613          	addi	a2,a2,-1206 # ffffffffc0207230 <commands+0x9b0>
ffffffffc02016ee:	06200593          	li	a1,98
ffffffffc02016f2:	00006517          	auipc	a0,0x6
ffffffffc02016f6:	b5e50513          	addi	a0,a0,-1186 # ffffffffc0207250 <commands+0x9d0>
ffffffffc02016fa:	b0ffe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(sum == 0);
ffffffffc02016fe:	00006697          	auipc	a3,0x6
ffffffffc0201702:	b2268693          	addi	a3,a3,-1246 # ffffffffc0207220 <commands+0x9a0>
ffffffffc0201706:	00005617          	auipc	a2,0x5
ffffffffc020170a:	58a60613          	addi	a2,a2,1418 # ffffffffc0206c90 <commands+0x410>
ffffffffc020170e:	16300593          	li	a1,355
ffffffffc0201712:	00006517          	auipc	a0,0x6
ffffffffc0201716:	88e50513          	addi	a0,a0,-1906 # ffffffffc0206fa0 <commands+0x720>
ffffffffc020171a:	aeffe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020171e <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc020171e:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0201720:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0201722:	f022                	sd	s0,32(sp)
ffffffffc0201724:	ec26                	sd	s1,24(sp)
ffffffffc0201726:	f406                	sd	ra,40(sp)
ffffffffc0201728:	e84a                	sd	s2,16(sp)
ffffffffc020172a:	8432                	mv	s0,a2
ffffffffc020172c:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020172e:	f8eff0ef          	jal	ra,ffffffffc0200ebc <find_vma>

    pgfault_num++;
ffffffffc0201732:	000b1797          	auipc	a5,0xb1
ffffffffc0201736:	12e7a783          	lw	a5,302(a5) # ffffffffc02b2860 <pgfault_num>
ffffffffc020173a:	2785                	addiw	a5,a5,1
ffffffffc020173c:	000b1717          	auipc	a4,0xb1
ffffffffc0201740:	12f72223          	sw	a5,292(a4) # ffffffffc02b2860 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0201744:	c541                	beqz	a0,ffffffffc02017cc <do_pgfault+0xae>
ffffffffc0201746:	651c                	ld	a5,8(a0)
ffffffffc0201748:	08f46263          	bltu	s0,a5,ffffffffc02017cc <do_pgfault+0xae>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc020174c:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc020174e:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0201750:	8b89                	andi	a5,a5,2
ffffffffc0201752:	ebb9                	bnez	a5,ffffffffc02017a8 <do_pgfault+0x8a>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0201754:	75fd                	lui	a1,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0201756:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0201758:	8c6d                	and	s0,s0,a1
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc020175a:	4605                	li	a2,1
ffffffffc020175c:	85a2                	mv	a1,s0
ffffffffc020175e:	5f9010ef          	jal	ra,ffffffffc0203556 <get_pte>
ffffffffc0201762:	c551                	beqz	a0,ffffffffc02017ee <do_pgfault+0xd0>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0201764:	610c                	ld	a1,0(a0)
ffffffffc0201766:	c1b9                	beqz	a1,ffffffffc02017ac <do_pgfault+0x8e>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0201768:	000b1797          	auipc	a5,0xb1
ffffffffc020176c:	1107a783          	lw	a5,272(a5) # ffffffffc02b2878 <swap_init_ok>
ffffffffc0201770:	c7bd                	beqz	a5,ffffffffc02017de <do_pgfault+0xc0>
            struct Page *page = NULL;
            swap_in(mm, addr, &page); 
ffffffffc0201772:	85a2                	mv	a1,s0
ffffffffc0201774:	0030                	addi	a2,sp,8
ffffffffc0201776:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0201778:	e402                	sd	zero,8(sp)
            swap_in(mm, addr, &page); 
ffffffffc020177a:	1a7000ef          	jal	ra,ffffffffc0202120 <swap_in>
            page_insert(mm->pgdir, page, addr, perm); 
ffffffffc020177e:	65a2                	ld	a1,8(sp)
ffffffffc0201780:	6c88                	ld	a0,24(s1)
ffffffffc0201782:	86ca                	mv	a3,s2
ffffffffc0201784:	8622                	mv	a2,s0
ffffffffc0201786:	46a020ef          	jal	ra,ffffffffc0203bf0 <page_insert>
            swap_map_swappable(mm, addr, page, 1);  
ffffffffc020178a:	6622                	ld	a2,8(sp)
ffffffffc020178c:	4685                	li	a3,1
ffffffffc020178e:	85a2                	mv	a1,s0
ffffffffc0201790:	8526                	mv	a0,s1
ffffffffc0201792:	06f000ef          	jal	ra,ffffffffc0202000 <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc0201796:	67a2                	ld	a5,8(sp)
        } else {
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }
   ret = 0;
ffffffffc0201798:	4501                	li	a0,0
            page->pra_vaddr = addr;
ffffffffc020179a:	ff80                	sd	s0,56(a5)
failed:
    return ret;
}
ffffffffc020179c:	70a2                	ld	ra,40(sp)
ffffffffc020179e:	7402                	ld	s0,32(sp)
ffffffffc02017a0:	64e2                	ld	s1,24(sp)
ffffffffc02017a2:	6942                	ld	s2,16(sp)
ffffffffc02017a4:	6145                	addi	sp,sp,48
ffffffffc02017a6:	8082                	ret
        perm |= READ_WRITE;
ffffffffc02017a8:	495d                	li	s2,23
ffffffffc02017aa:	b76d                	j	ffffffffc0201754 <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02017ac:	6c88                	ld	a0,24(s1)
ffffffffc02017ae:	864a                	mv	a2,s2
ffffffffc02017b0:	85a2                	mv	a1,s0
ffffffffc02017b2:	304030ef          	jal	ra,ffffffffc0204ab6 <pgdir_alloc_page>
ffffffffc02017b6:	87aa                	mv	a5,a0
   ret = 0;
ffffffffc02017b8:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02017ba:	f3ed                	bnez	a5,ffffffffc020179c <do_pgfault+0x7e>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc02017bc:	00006517          	auipc	a0,0x6
ffffffffc02017c0:	b8c50513          	addi	a0,a0,-1140 # ffffffffc0207348 <commands+0xac8>
ffffffffc02017c4:	909fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc02017c8:	5571                	li	a0,-4
            goto failed;
ffffffffc02017ca:	bfc9                	j	ffffffffc020179c <do_pgfault+0x7e>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc02017cc:	85a2                	mv	a1,s0
ffffffffc02017ce:	00006517          	auipc	a0,0x6
ffffffffc02017d2:	b2a50513          	addi	a0,a0,-1238 # ffffffffc02072f8 <commands+0xa78>
ffffffffc02017d6:	8f7fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    int ret = -E_INVAL;
ffffffffc02017da:	5575                	li	a0,-3
        goto failed;
ffffffffc02017dc:	b7c1                	j	ffffffffc020179c <do_pgfault+0x7e>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc02017de:	00006517          	auipc	a0,0x6
ffffffffc02017e2:	b9250513          	addi	a0,a0,-1134 # ffffffffc0207370 <commands+0xaf0>
ffffffffc02017e6:	8e7fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc02017ea:	5571                	li	a0,-4
            goto failed;
ffffffffc02017ec:	bf45                	j	ffffffffc020179c <do_pgfault+0x7e>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc02017ee:	00006517          	auipc	a0,0x6
ffffffffc02017f2:	b3a50513          	addi	a0,a0,-1222 # ffffffffc0207328 <commands+0xaa8>
ffffffffc02017f6:	8d7fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc02017fa:	5571                	li	a0,-4
        goto failed;
ffffffffc02017fc:	b745                	j	ffffffffc020179c <do_pgfault+0x7e>

ffffffffc02017fe <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc02017fe:	7179                	addi	sp,sp,-48
ffffffffc0201800:	f022                	sd	s0,32(sp)
ffffffffc0201802:	f406                	sd	ra,40(sp)
ffffffffc0201804:	ec26                	sd	s1,24(sp)
ffffffffc0201806:	e84a                	sd	s2,16(sp)
ffffffffc0201808:	e44e                	sd	s3,8(sp)
ffffffffc020180a:	e052                	sd	s4,0(sp)
ffffffffc020180c:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc020180e:	c135                	beqz	a0,ffffffffc0201872 <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc0201810:	002007b7          	lui	a5,0x200
ffffffffc0201814:	04f5e663          	bltu	a1,a5,ffffffffc0201860 <user_mem_check+0x62>
ffffffffc0201818:	00c584b3          	add	s1,a1,a2
ffffffffc020181c:	0495f263          	bgeu	a1,s1,ffffffffc0201860 <user_mem_check+0x62>
ffffffffc0201820:	4785                	li	a5,1
ffffffffc0201822:	07fe                	slli	a5,a5,0x1f
ffffffffc0201824:	0297ee63          	bltu	a5,s1,ffffffffc0201860 <user_mem_check+0x62>
ffffffffc0201828:	892a                	mv	s2,a0
ffffffffc020182a:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc020182c:	6a05                	lui	s4,0x1
ffffffffc020182e:	a821                	j	ffffffffc0201846 <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0201830:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0201834:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0201836:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0201838:	c685                	beqz	a3,ffffffffc0201860 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc020183a:	c399                	beqz	a5,ffffffffc0201840 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc020183c:	02e46263          	bltu	s0,a4,ffffffffc0201860 <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0201840:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc0201842:	04947663          	bgeu	s0,s1,ffffffffc020188e <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc0201846:	85a2                	mv	a1,s0
ffffffffc0201848:	854a                	mv	a0,s2
ffffffffc020184a:	e72ff0ef          	jal	ra,ffffffffc0200ebc <find_vma>
ffffffffc020184e:	c909                	beqz	a0,ffffffffc0201860 <user_mem_check+0x62>
ffffffffc0201850:	6518                	ld	a4,8(a0)
ffffffffc0201852:	00e46763          	bltu	s0,a4,ffffffffc0201860 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0201856:	4d1c                	lw	a5,24(a0)
ffffffffc0201858:	fc099ce3          	bnez	s3,ffffffffc0201830 <user_mem_check+0x32>
ffffffffc020185c:	8b85                	andi	a5,a5,1
ffffffffc020185e:	f3ed                	bnez	a5,ffffffffc0201840 <user_mem_check+0x42>
            return 0;
ffffffffc0201860:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0201862:	70a2                	ld	ra,40(sp)
ffffffffc0201864:	7402                	ld	s0,32(sp)
ffffffffc0201866:	64e2                	ld	s1,24(sp)
ffffffffc0201868:	6942                	ld	s2,16(sp)
ffffffffc020186a:	69a2                	ld	s3,8(sp)
ffffffffc020186c:	6a02                	ld	s4,0(sp)
ffffffffc020186e:	6145                	addi	sp,sp,48
ffffffffc0201870:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0201872:	c02007b7          	lui	a5,0xc0200
ffffffffc0201876:	4501                	li	a0,0
ffffffffc0201878:	fef5e5e3          	bltu	a1,a5,ffffffffc0201862 <user_mem_check+0x64>
ffffffffc020187c:	962e                	add	a2,a2,a1
ffffffffc020187e:	fec5f2e3          	bgeu	a1,a2,ffffffffc0201862 <user_mem_check+0x64>
ffffffffc0201882:	c8000537          	lui	a0,0xc8000
ffffffffc0201886:	0505                	addi	a0,a0,1
ffffffffc0201888:	00a63533          	sltu	a0,a2,a0
ffffffffc020188c:	bfd9                	j	ffffffffc0201862 <user_mem_check+0x64>
        return 1;
ffffffffc020188e:	4505                	li	a0,1
ffffffffc0201890:	bfc9                	j	ffffffffc0201862 <user_mem_check+0x64>

ffffffffc0201892 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc0201892:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201894:	00006617          	auipc	a2,0x6
ffffffffc0201898:	99c60613          	addi	a2,a2,-1636 # ffffffffc0207230 <commands+0x9b0>
ffffffffc020189c:	06200593          	li	a1,98
ffffffffc02018a0:	00006517          	auipc	a0,0x6
ffffffffc02018a4:	9b050513          	addi	a0,a0,-1616 # ffffffffc0207250 <commands+0x9d0>
pa2page(uintptr_t pa) {
ffffffffc02018a8:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02018aa:	95ffe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02018ae <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc02018ae:	7135                	addi	sp,sp,-160
ffffffffc02018b0:	ed06                	sd	ra,152(sp)
ffffffffc02018b2:	e922                	sd	s0,144(sp)
ffffffffc02018b4:	e526                	sd	s1,136(sp)
ffffffffc02018b6:	e14a                	sd	s2,128(sp)
ffffffffc02018b8:	fcce                	sd	s3,120(sp)
ffffffffc02018ba:	f8d2                	sd	s4,112(sp)
ffffffffc02018bc:	f4d6                	sd	s5,104(sp)
ffffffffc02018be:	f0da                	sd	s6,96(sp)
ffffffffc02018c0:	ecde                	sd	s7,88(sp)
ffffffffc02018c2:	e8e2                	sd	s8,80(sp)
ffffffffc02018c4:	e4e6                	sd	s9,72(sp)
ffffffffc02018c6:	e0ea                	sd	s10,64(sp)
ffffffffc02018c8:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc02018ca:	2a6030ef          	jal	ra,ffffffffc0204b70 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc02018ce:	000b1697          	auipc	a3,0xb1
ffffffffc02018d2:	f9a6b683          	ld	a3,-102(a3) # ffffffffc02b2868 <max_swap_offset>
ffffffffc02018d6:	010007b7          	lui	a5,0x1000
ffffffffc02018da:	ff968713          	addi	a4,a3,-7
ffffffffc02018de:	17e1                	addi	a5,a5,-8
ffffffffc02018e0:	42e7e663          	bltu	a5,a4,ffffffffc0201d0c <swap_init+0x45e>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc02018e4:	000a6797          	auipc	a5,0xa6
ffffffffc02018e8:	a4478793          	addi	a5,a5,-1468 # ffffffffc02a7328 <swap_manager_fifo>
     int r = sm->init();
ffffffffc02018ec:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc02018ee:	000b1b97          	auipc	s7,0xb1
ffffffffc02018f2:	f82b8b93          	addi	s7,s7,-126 # ffffffffc02b2870 <sm>
ffffffffc02018f6:	00fbb023          	sd	a5,0(s7)
     int r = sm->init();
ffffffffc02018fa:	9702                	jalr	a4
ffffffffc02018fc:	892a                	mv	s2,a0
     
     if (r == 0)
ffffffffc02018fe:	c10d                	beqz	a0,ffffffffc0201920 <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0201900:	60ea                	ld	ra,152(sp)
ffffffffc0201902:	644a                	ld	s0,144(sp)
ffffffffc0201904:	64aa                	ld	s1,136(sp)
ffffffffc0201906:	79e6                	ld	s3,120(sp)
ffffffffc0201908:	7a46                	ld	s4,112(sp)
ffffffffc020190a:	7aa6                	ld	s5,104(sp)
ffffffffc020190c:	7b06                	ld	s6,96(sp)
ffffffffc020190e:	6be6                	ld	s7,88(sp)
ffffffffc0201910:	6c46                	ld	s8,80(sp)
ffffffffc0201912:	6ca6                	ld	s9,72(sp)
ffffffffc0201914:	6d06                	ld	s10,64(sp)
ffffffffc0201916:	7de2                	ld	s11,56(sp)
ffffffffc0201918:	854a                	mv	a0,s2
ffffffffc020191a:	690a                	ld	s2,128(sp)
ffffffffc020191c:	610d                	addi	sp,sp,160
ffffffffc020191e:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0201920:	000bb783          	ld	a5,0(s7)
ffffffffc0201924:	00006517          	auipc	a0,0x6
ffffffffc0201928:	aa450513          	addi	a0,a0,-1372 # ffffffffc02073c8 <commands+0xb48>
ffffffffc020192c:	000ad417          	auipc	s0,0xad
ffffffffc0201930:	eec40413          	addi	s0,s0,-276 # ffffffffc02ae818 <free_area>
ffffffffc0201934:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0201936:	4785                	li	a5,1
ffffffffc0201938:	000b1717          	auipc	a4,0xb1
ffffffffc020193c:	f4f72023          	sw	a5,-192(a4) # ffffffffc02b2878 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0201940:	f8cfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0201944:	641c                	ld	a5,8(s0)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc0201946:	4d01                	li	s10,0
ffffffffc0201948:	4d81                	li	s11,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc020194a:	34878163          	beq	a5,s0,ffffffffc0201c8c <swap_init+0x3de>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020194e:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0201952:	8b09                	andi	a4,a4,2
ffffffffc0201954:	32070e63          	beqz	a4,ffffffffc0201c90 <swap_init+0x3e2>
        count ++, total += p->property;
ffffffffc0201958:	ff87a703          	lw	a4,-8(a5)
ffffffffc020195c:	679c                	ld	a5,8(a5)
ffffffffc020195e:	2d85                	addiw	s11,s11,1
ffffffffc0201960:	01a70d3b          	addw	s10,a4,s10
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201964:	fe8795e3          	bne	a5,s0,ffffffffc020194e <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc0201968:	84ea                	mv	s1,s10
ffffffffc020196a:	3b3010ef          	jal	ra,ffffffffc020351c <nr_free_pages>
ffffffffc020196e:	42951763          	bne	a0,s1,ffffffffc0201d9c <swap_init+0x4ee>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0201972:	866a                	mv	a2,s10
ffffffffc0201974:	85ee                	mv	a1,s11
ffffffffc0201976:	00006517          	auipc	a0,0x6
ffffffffc020197a:	a9a50513          	addi	a0,a0,-1382 # ffffffffc0207410 <commands+0xb90>
ffffffffc020197e:	f4efe0ef          	jal	ra,ffffffffc02000cc <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0201982:	cc4ff0ef          	jal	ra,ffffffffc0200e46 <mm_create>
ffffffffc0201986:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc0201988:	46050a63          	beqz	a0,ffffffffc0201dfc <swap_init+0x54e>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc020198c:	000b1797          	auipc	a5,0xb1
ffffffffc0201990:	ecc78793          	addi	a5,a5,-308 # ffffffffc02b2858 <check_mm_struct>
ffffffffc0201994:	6398                	ld	a4,0(a5)
ffffffffc0201996:	3e071363          	bnez	a4,ffffffffc0201d7c <swap_init+0x4ce>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020199a:	000b1717          	auipc	a4,0xb1
ffffffffc020199e:	ef670713          	addi	a4,a4,-266 # ffffffffc02b2890 <boot_pgdir>
ffffffffc02019a2:	00073b03          	ld	s6,0(a4)
     check_mm_struct = mm;
ffffffffc02019a6:	e388                	sd	a0,0(a5)
     assert(pgdir[0] == 0);
ffffffffc02019a8:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02019ac:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc02019b0:	42079663          	bnez	a5,ffffffffc0201ddc <swap_init+0x52e>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc02019b4:	6599                	lui	a1,0x6
ffffffffc02019b6:	460d                	li	a2,3
ffffffffc02019b8:	6505                	lui	a0,0x1
ffffffffc02019ba:	cd4ff0ef          	jal	ra,ffffffffc0200e8e <vma_create>
ffffffffc02019be:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc02019c0:	52050a63          	beqz	a0,ffffffffc0201ef4 <swap_init+0x646>

     insert_vma_struct(mm, vma);
ffffffffc02019c4:	8556                	mv	a0,s5
ffffffffc02019c6:	d36ff0ef          	jal	ra,ffffffffc0200efc <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc02019ca:	00006517          	auipc	a0,0x6
ffffffffc02019ce:	a8650513          	addi	a0,a0,-1402 # ffffffffc0207450 <commands+0xbd0>
ffffffffc02019d2:	efafe0ef          	jal	ra,ffffffffc02000cc <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc02019d6:	018ab503          	ld	a0,24(s5)
ffffffffc02019da:	4605                	li	a2,1
ffffffffc02019dc:	6585                	lui	a1,0x1
ffffffffc02019de:	379010ef          	jal	ra,ffffffffc0203556 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc02019e2:	4c050963          	beqz	a0,ffffffffc0201eb4 <swap_init+0x606>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02019e6:	00006517          	auipc	a0,0x6
ffffffffc02019ea:	aba50513          	addi	a0,a0,-1350 # ffffffffc02074a0 <commands+0xc20>
ffffffffc02019ee:	000ad497          	auipc	s1,0xad
ffffffffc02019f2:	daa48493          	addi	s1,s1,-598 # ffffffffc02ae798 <check_rp>
ffffffffc02019f6:	ed6fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02019fa:	000ad997          	auipc	s3,0xad
ffffffffc02019fe:	dbe98993          	addi	s3,s3,-578 # ffffffffc02ae7b8 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0201a02:	8a26                	mv	s4,s1
          check_rp[i] = alloc_page();
ffffffffc0201a04:	4505                	li	a0,1
ffffffffc0201a06:	245010ef          	jal	ra,ffffffffc020344a <alloc_pages>
ffffffffc0201a0a:	00aa3023          	sd	a0,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb8>
          assert(check_rp[i] != NULL );
ffffffffc0201a0e:	2c050f63          	beqz	a0,ffffffffc0201cec <swap_init+0x43e>
ffffffffc0201a12:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0201a14:	8b89                	andi	a5,a5,2
ffffffffc0201a16:	34079363          	bnez	a5,ffffffffc0201d5c <swap_init+0x4ae>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201a1a:	0a21                	addi	s4,s4,8
ffffffffc0201a1c:	ff3a14e3          	bne	s4,s3,ffffffffc0201a04 <swap_init+0x156>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0201a20:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0201a22:	000ada17          	auipc	s4,0xad
ffffffffc0201a26:	d76a0a13          	addi	s4,s4,-650 # ffffffffc02ae798 <check_rp>
    elm->prev = elm->next = elm;
ffffffffc0201a2a:	e000                	sd	s0,0(s0)
     list_entry_t free_list_store = free_list;
ffffffffc0201a2c:	ec3e                	sd	a5,24(sp)
ffffffffc0201a2e:	641c                	ld	a5,8(s0)
ffffffffc0201a30:	e400                	sd	s0,8(s0)
ffffffffc0201a32:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0201a34:	481c                	lw	a5,16(s0)
ffffffffc0201a36:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc0201a38:	000ad797          	auipc	a5,0xad
ffffffffc0201a3c:	de07a823          	sw	zero,-528(a5) # ffffffffc02ae828 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0201a40:	000a3503          	ld	a0,0(s4)
ffffffffc0201a44:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201a46:	0a21                	addi	s4,s4,8
        free_pages(check_rp[i],1);
ffffffffc0201a48:	295010ef          	jal	ra,ffffffffc02034dc <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201a4c:	ff3a1ae3          	bne	s4,s3,ffffffffc0201a40 <swap_init+0x192>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0201a50:	01042a03          	lw	s4,16(s0)
ffffffffc0201a54:	4791                	li	a5,4
ffffffffc0201a56:	42fa1f63          	bne	s4,a5,ffffffffc0201e94 <swap_init+0x5e6>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0201a5a:	00006517          	auipc	a0,0x6
ffffffffc0201a5e:	ace50513          	addi	a0,a0,-1330 # ffffffffc0207528 <commands+0xca8>
ffffffffc0201a62:	e6afe0ef          	jal	ra,ffffffffc02000cc <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201a66:	6705                	lui	a4,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0201a68:	000b1797          	auipc	a5,0xb1
ffffffffc0201a6c:	de07ac23          	sw	zero,-520(a5) # ffffffffc02b2860 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201a70:	4629                	li	a2,10
ffffffffc0201a72:	00c70023          	sb	a2,0(a4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb8>
     assert(pgfault_num==1);
ffffffffc0201a76:	000b1697          	auipc	a3,0xb1
ffffffffc0201a7a:	dea6a683          	lw	a3,-534(a3) # ffffffffc02b2860 <pgfault_num>
ffffffffc0201a7e:	4585                	li	a1,1
ffffffffc0201a80:	000b1797          	auipc	a5,0xb1
ffffffffc0201a84:	de078793          	addi	a5,a5,-544 # ffffffffc02b2860 <pgfault_num>
ffffffffc0201a88:	54b69663          	bne	a3,a1,ffffffffc0201fd4 <swap_init+0x726>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0201a8c:	00c70823          	sb	a2,16(a4)
     assert(pgfault_num==1);
ffffffffc0201a90:	4398                	lw	a4,0(a5)
ffffffffc0201a92:	2701                	sext.w	a4,a4
ffffffffc0201a94:	3ed71063          	bne	a4,a3,ffffffffc0201e74 <swap_init+0x5c6>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201a98:	6689                	lui	a3,0x2
ffffffffc0201a9a:	462d                	li	a2,11
ffffffffc0201a9c:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x7bb8>
     assert(pgfault_num==2);
ffffffffc0201aa0:	4398                	lw	a4,0(a5)
ffffffffc0201aa2:	4589                	li	a1,2
ffffffffc0201aa4:	2701                	sext.w	a4,a4
ffffffffc0201aa6:	4ab71763          	bne	a4,a1,ffffffffc0201f54 <swap_init+0x6a6>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0201aaa:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0201aae:	4394                	lw	a3,0(a5)
ffffffffc0201ab0:	2681                	sext.w	a3,a3
ffffffffc0201ab2:	4ce69163          	bne	a3,a4,ffffffffc0201f74 <swap_init+0x6c6>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201ab6:	668d                	lui	a3,0x3
ffffffffc0201ab8:	4631                	li	a2,12
ffffffffc0201aba:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x6bb8>
     assert(pgfault_num==3);
ffffffffc0201abe:	4398                	lw	a4,0(a5)
ffffffffc0201ac0:	458d                	li	a1,3
ffffffffc0201ac2:	2701                	sext.w	a4,a4
ffffffffc0201ac4:	4cb71863          	bne	a4,a1,ffffffffc0201f94 <swap_init+0x6e6>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0201ac8:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0201acc:	4394                	lw	a3,0(a5)
ffffffffc0201ace:	2681                	sext.w	a3,a3
ffffffffc0201ad0:	4ee69263          	bne	a3,a4,ffffffffc0201fb4 <swap_init+0x706>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201ad4:	6691                	lui	a3,0x4
ffffffffc0201ad6:	4635                	li	a2,13
ffffffffc0201ad8:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x5bb8>
     assert(pgfault_num==4);
ffffffffc0201adc:	4398                	lw	a4,0(a5)
ffffffffc0201ade:	2701                	sext.w	a4,a4
ffffffffc0201ae0:	43471a63          	bne	a4,s4,ffffffffc0201f14 <swap_init+0x666>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0201ae4:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0201ae8:	439c                	lw	a5,0(a5)
ffffffffc0201aea:	2781                	sext.w	a5,a5
ffffffffc0201aec:	44e79463          	bne	a5,a4,ffffffffc0201f34 <swap_init+0x686>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0201af0:	481c                	lw	a5,16(s0)
ffffffffc0201af2:	2c079563          	bnez	a5,ffffffffc0201dbc <swap_init+0x50e>
ffffffffc0201af6:	000ad797          	auipc	a5,0xad
ffffffffc0201afa:	cc278793          	addi	a5,a5,-830 # ffffffffc02ae7b8 <swap_in_seq_no>
ffffffffc0201afe:	000ad717          	auipc	a4,0xad
ffffffffc0201b02:	ce270713          	addi	a4,a4,-798 # ffffffffc02ae7e0 <swap_out_seq_no>
ffffffffc0201b06:	000ad617          	auipc	a2,0xad
ffffffffc0201b0a:	cda60613          	addi	a2,a2,-806 # ffffffffc02ae7e0 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0201b0e:	56fd                	li	a3,-1
ffffffffc0201b10:	c394                	sw	a3,0(a5)
ffffffffc0201b12:	c314                	sw	a3,0(a4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0201b14:	0791                	addi	a5,a5,4
ffffffffc0201b16:	0711                	addi	a4,a4,4
ffffffffc0201b18:	fec79ce3          	bne	a5,a2,ffffffffc0201b10 <swap_init+0x262>
ffffffffc0201b1c:	000ad717          	auipc	a4,0xad
ffffffffc0201b20:	c5c70713          	addi	a4,a4,-932 # ffffffffc02ae778 <check_ptep>
ffffffffc0201b24:	000ad697          	auipc	a3,0xad
ffffffffc0201b28:	c7468693          	addi	a3,a3,-908 # ffffffffc02ae798 <check_rp>
ffffffffc0201b2c:	6585                	lui	a1,0x1
    if (PPN(pa) >= npage) {
ffffffffc0201b2e:	000b1c17          	auipc	s8,0xb1
ffffffffc0201b32:	d6ac0c13          	addi	s8,s8,-662 # ffffffffc02b2898 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0201b36:	000b1c97          	auipc	s9,0xb1
ffffffffc0201b3a:	d6ac8c93          	addi	s9,s9,-662 # ffffffffc02b28a0 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0201b3e:	00073023          	sd	zero,0(a4)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0201b42:	4601                	li	a2,0
ffffffffc0201b44:	855a                	mv	a0,s6
ffffffffc0201b46:	e836                	sd	a3,16(sp)
ffffffffc0201b48:	e42e                	sd	a1,8(sp)
         check_ptep[i]=0;
ffffffffc0201b4a:	e03a                	sd	a4,0(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0201b4c:	20b010ef          	jal	ra,ffffffffc0203556 <get_pte>
ffffffffc0201b50:	6702                	ld	a4,0(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0201b52:	65a2                	ld	a1,8(sp)
ffffffffc0201b54:	66c2                	ld	a3,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0201b56:	e308                	sd	a0,0(a4)
         assert(check_ptep[i] != NULL);
ffffffffc0201b58:	1c050663          	beqz	a0,ffffffffc0201d24 <swap_init+0x476>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0201b5c:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201b5e:	0017f613          	andi	a2,a5,1
ffffffffc0201b62:	1e060163          	beqz	a2,ffffffffc0201d44 <swap_init+0x496>
    if (PPN(pa) >= npage) {
ffffffffc0201b66:	000c3603          	ld	a2,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201b6a:	078a                	slli	a5,a5,0x2
ffffffffc0201b6c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201b6e:	14c7f363          	bgeu	a5,a2,ffffffffc0201cb4 <swap_init+0x406>
    return &pages[PPN(pa) - nbase];
ffffffffc0201b72:	00007617          	auipc	a2,0x7
ffffffffc0201b76:	13e60613          	addi	a2,a2,318 # ffffffffc0208cb0 <nbase>
ffffffffc0201b7a:	00063a03          	ld	s4,0(a2)
ffffffffc0201b7e:	000cb603          	ld	a2,0(s9)
ffffffffc0201b82:	6288                	ld	a0,0(a3)
ffffffffc0201b84:	414787b3          	sub	a5,a5,s4
ffffffffc0201b88:	079a                	slli	a5,a5,0x6
ffffffffc0201b8a:	97b2                	add	a5,a5,a2
ffffffffc0201b8c:	14f51063          	bne	a0,a5,ffffffffc0201ccc <swap_init+0x41e>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201b90:	6785                	lui	a5,0x1
ffffffffc0201b92:	95be                	add	a1,a1,a5
ffffffffc0201b94:	6795                	lui	a5,0x5
ffffffffc0201b96:	0721                	addi	a4,a4,8
ffffffffc0201b98:	06a1                	addi	a3,a3,8
ffffffffc0201b9a:	faf592e3          	bne	a1,a5,ffffffffc0201b3e <swap_init+0x290>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0201b9e:	00006517          	auipc	a0,0x6
ffffffffc0201ba2:	a6a50513          	addi	a0,a0,-1430 # ffffffffc0207608 <commands+0xd88>
ffffffffc0201ba6:	d26fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    int ret = sm->check_swap();
ffffffffc0201baa:	000bb783          	ld	a5,0(s7)
ffffffffc0201bae:	7f9c                	ld	a5,56(a5)
ffffffffc0201bb0:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0201bb2:	32051163          	bnez	a0,ffffffffc0201ed4 <swap_init+0x626>

     nr_free = nr_free_store;
ffffffffc0201bb6:	77a2                	ld	a5,40(sp)
ffffffffc0201bb8:	c81c                	sw	a5,16(s0)
     free_list = free_list_store;
ffffffffc0201bba:	67e2                	ld	a5,24(sp)
ffffffffc0201bbc:	e01c                	sd	a5,0(s0)
ffffffffc0201bbe:	7782                	ld	a5,32(sp)
ffffffffc0201bc0:	e41c                	sd	a5,8(s0)

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0201bc2:	6088                	ld	a0,0(s1)
ffffffffc0201bc4:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201bc6:	04a1                	addi	s1,s1,8
         free_pages(check_rp[i],1);
ffffffffc0201bc8:	115010ef          	jal	ra,ffffffffc02034dc <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201bcc:	ff349be3          	bne	s1,s3,ffffffffc0201bc2 <swap_init+0x314>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc0201bd0:	000abc23          	sd	zero,24(s5)
     mm_destroy(mm);
ffffffffc0201bd4:	8556                	mv	a0,s5
ffffffffc0201bd6:	bf6ff0ef          	jal	ra,ffffffffc0200fcc <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0201bda:	000b1797          	auipc	a5,0xb1
ffffffffc0201bde:	cb678793          	addi	a5,a5,-842 # ffffffffc02b2890 <boot_pgdir>
ffffffffc0201be2:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0201be4:	000c3703          	ld	a4,0(s8)
     check_mm_struct = NULL;
ffffffffc0201be8:	000b1697          	auipc	a3,0xb1
ffffffffc0201bec:	c606b823          	sd	zero,-912(a3) # ffffffffc02b2858 <check_mm_struct>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201bf0:	639c                	ld	a5,0(a5)
ffffffffc0201bf2:	078a                	slli	a5,a5,0x2
ffffffffc0201bf4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201bf6:	0ae7fd63          	bgeu	a5,a4,ffffffffc0201cb0 <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc0201bfa:	414786b3          	sub	a3,a5,s4
ffffffffc0201bfe:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0201c00:	8699                	srai	a3,a3,0x6
ffffffffc0201c02:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0201c04:	00c69793          	slli	a5,a3,0xc
ffffffffc0201c08:	83b1                	srli	a5,a5,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0201c0a:	000cb503          	ld	a0,0(s9)
    return page2ppn(page) << PGSHIFT;
ffffffffc0201c0e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201c10:	22e7f663          	bgeu	a5,a4,ffffffffc0201e3c <swap_init+0x58e>
     free_page(pde2page(pd0[0]));
ffffffffc0201c14:	000b1797          	auipc	a5,0xb1
ffffffffc0201c18:	c9c7b783          	ld	a5,-868(a5) # ffffffffc02b28b0 <va_pa_offset>
ffffffffc0201c1c:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201c1e:	629c                	ld	a5,0(a3)
ffffffffc0201c20:	078a                	slli	a5,a5,0x2
ffffffffc0201c22:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201c24:	08e7f663          	bgeu	a5,a4,ffffffffc0201cb0 <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc0201c28:	414787b3          	sub	a5,a5,s4
ffffffffc0201c2c:	079a                	slli	a5,a5,0x6
ffffffffc0201c2e:	953e                	add	a0,a0,a5
ffffffffc0201c30:	4585                	li	a1,1
ffffffffc0201c32:	0ab010ef          	jal	ra,ffffffffc02034dc <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201c36:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0201c3a:	000c3703          	ld	a4,0(s8)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201c3e:	078a                	slli	a5,a5,0x2
ffffffffc0201c40:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201c42:	06e7f763          	bgeu	a5,a4,ffffffffc0201cb0 <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc0201c46:	000cb503          	ld	a0,0(s9)
ffffffffc0201c4a:	414787b3          	sub	a5,a5,s4
ffffffffc0201c4e:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0201c50:	4585                	li	a1,1
ffffffffc0201c52:	953e                	add	a0,a0,a5
ffffffffc0201c54:	089010ef          	jal	ra,ffffffffc02034dc <free_pages>
     pgdir[0] = 0;
ffffffffc0201c58:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0201c5c:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0201c60:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201c62:	00878a63          	beq	a5,s0,ffffffffc0201c76 <swap_init+0x3c8>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0201c66:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201c6a:	679c                	ld	a5,8(a5)
ffffffffc0201c6c:	3dfd                	addiw	s11,s11,-1
ffffffffc0201c6e:	40ed0d3b          	subw	s10,s10,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201c72:	fe879ae3          	bne	a5,s0,ffffffffc0201c66 <swap_init+0x3b8>
     }
     assert(count==0);
ffffffffc0201c76:	1c0d9f63          	bnez	s11,ffffffffc0201e54 <swap_init+0x5a6>
     assert(total==0);
ffffffffc0201c7a:	1a0d1163          	bnez	s10,ffffffffc0201e1c <swap_init+0x56e>

     cprintf("check_swap() succeeded!\n");
ffffffffc0201c7e:	00006517          	auipc	a0,0x6
ffffffffc0201c82:	9da50513          	addi	a0,a0,-1574 # ffffffffc0207658 <commands+0xdd8>
ffffffffc0201c86:	c46fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc0201c8a:	b99d                	j	ffffffffc0201900 <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201c8c:	4481                	li	s1,0
ffffffffc0201c8e:	b9f1                	j	ffffffffc020196a <swap_init+0xbc>
        assert(PageProperty(p));
ffffffffc0201c90:	00005697          	auipc	a3,0x5
ffffffffc0201c94:	75068693          	addi	a3,a3,1872 # ffffffffc02073e0 <commands+0xb60>
ffffffffc0201c98:	00005617          	auipc	a2,0x5
ffffffffc0201c9c:	ff860613          	addi	a2,a2,-8 # ffffffffc0206c90 <commands+0x410>
ffffffffc0201ca0:	0bc00593          	li	a1,188
ffffffffc0201ca4:	00005517          	auipc	a0,0x5
ffffffffc0201ca8:	71450513          	addi	a0,a0,1812 # ffffffffc02073b8 <commands+0xb38>
ffffffffc0201cac:	d5cfe0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0201cb0:	be3ff0ef          	jal	ra,ffffffffc0201892 <pa2page.part.0>
        panic("pa2page called with invalid pa");
ffffffffc0201cb4:	00005617          	auipc	a2,0x5
ffffffffc0201cb8:	57c60613          	addi	a2,a2,1404 # ffffffffc0207230 <commands+0x9b0>
ffffffffc0201cbc:	06200593          	li	a1,98
ffffffffc0201cc0:	00005517          	auipc	a0,0x5
ffffffffc0201cc4:	59050513          	addi	a0,a0,1424 # ffffffffc0207250 <commands+0x9d0>
ffffffffc0201cc8:	d40fe0ef          	jal	ra,ffffffffc0200208 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0201ccc:	00006697          	auipc	a3,0x6
ffffffffc0201cd0:	91468693          	addi	a3,a3,-1772 # ffffffffc02075e0 <commands+0xd60>
ffffffffc0201cd4:	00005617          	auipc	a2,0x5
ffffffffc0201cd8:	fbc60613          	addi	a2,a2,-68 # ffffffffc0206c90 <commands+0x410>
ffffffffc0201cdc:	0fc00593          	li	a1,252
ffffffffc0201ce0:	00005517          	auipc	a0,0x5
ffffffffc0201ce4:	6d850513          	addi	a0,a0,1752 # ffffffffc02073b8 <commands+0xb38>
ffffffffc0201ce8:	d20fe0ef          	jal	ra,ffffffffc0200208 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0201cec:	00005697          	auipc	a3,0x5
ffffffffc0201cf0:	7dc68693          	addi	a3,a3,2012 # ffffffffc02074c8 <commands+0xc48>
ffffffffc0201cf4:	00005617          	auipc	a2,0x5
ffffffffc0201cf8:	f9c60613          	addi	a2,a2,-100 # ffffffffc0206c90 <commands+0x410>
ffffffffc0201cfc:	0dc00593          	li	a1,220
ffffffffc0201d00:	00005517          	auipc	a0,0x5
ffffffffc0201d04:	6b850513          	addi	a0,a0,1720 # ffffffffc02073b8 <commands+0xb38>
ffffffffc0201d08:	d00fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0201d0c:	00005617          	auipc	a2,0x5
ffffffffc0201d10:	68c60613          	addi	a2,a2,1676 # ffffffffc0207398 <commands+0xb18>
ffffffffc0201d14:	02800593          	li	a1,40
ffffffffc0201d18:	00005517          	auipc	a0,0x5
ffffffffc0201d1c:	6a050513          	addi	a0,a0,1696 # ffffffffc02073b8 <commands+0xb38>
ffffffffc0201d20:	ce8fe0ef          	jal	ra,ffffffffc0200208 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0201d24:	00006697          	auipc	a3,0x6
ffffffffc0201d28:	87c68693          	addi	a3,a3,-1924 # ffffffffc02075a0 <commands+0xd20>
ffffffffc0201d2c:	00005617          	auipc	a2,0x5
ffffffffc0201d30:	f6460613          	addi	a2,a2,-156 # ffffffffc0206c90 <commands+0x410>
ffffffffc0201d34:	0fb00593          	li	a1,251
ffffffffc0201d38:	00005517          	auipc	a0,0x5
ffffffffc0201d3c:	68050513          	addi	a0,a0,1664 # ffffffffc02073b8 <commands+0xb38>
ffffffffc0201d40:	cc8fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0201d44:	00006617          	auipc	a2,0x6
ffffffffc0201d48:	87460613          	addi	a2,a2,-1932 # ffffffffc02075b8 <commands+0xd38>
ffffffffc0201d4c:	07400593          	li	a1,116
ffffffffc0201d50:	00005517          	auipc	a0,0x5
ffffffffc0201d54:	50050513          	addi	a0,a0,1280 # ffffffffc0207250 <commands+0x9d0>
ffffffffc0201d58:	cb0fe0ef          	jal	ra,ffffffffc0200208 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0201d5c:	00005697          	auipc	a3,0x5
ffffffffc0201d60:	78468693          	addi	a3,a3,1924 # ffffffffc02074e0 <commands+0xc60>
ffffffffc0201d64:	00005617          	auipc	a2,0x5
ffffffffc0201d68:	f2c60613          	addi	a2,a2,-212 # ffffffffc0206c90 <commands+0x410>
ffffffffc0201d6c:	0dd00593          	li	a1,221
ffffffffc0201d70:	00005517          	auipc	a0,0x5
ffffffffc0201d74:	64850513          	addi	a0,a0,1608 # ffffffffc02073b8 <commands+0xb38>
ffffffffc0201d78:	c90fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0201d7c:	00005697          	auipc	a3,0x5
ffffffffc0201d80:	6bc68693          	addi	a3,a3,1724 # ffffffffc0207438 <commands+0xbb8>
ffffffffc0201d84:	00005617          	auipc	a2,0x5
ffffffffc0201d88:	f0c60613          	addi	a2,a2,-244 # ffffffffc0206c90 <commands+0x410>
ffffffffc0201d8c:	0c700593          	li	a1,199
ffffffffc0201d90:	00005517          	auipc	a0,0x5
ffffffffc0201d94:	62850513          	addi	a0,a0,1576 # ffffffffc02073b8 <commands+0xb38>
ffffffffc0201d98:	c70fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(total == nr_free_pages());
ffffffffc0201d9c:	00005697          	auipc	a3,0x5
ffffffffc0201da0:	65468693          	addi	a3,a3,1620 # ffffffffc02073f0 <commands+0xb70>
ffffffffc0201da4:	00005617          	auipc	a2,0x5
ffffffffc0201da8:	eec60613          	addi	a2,a2,-276 # ffffffffc0206c90 <commands+0x410>
ffffffffc0201dac:	0bf00593          	li	a1,191
ffffffffc0201db0:	00005517          	auipc	a0,0x5
ffffffffc0201db4:	60850513          	addi	a0,a0,1544 # ffffffffc02073b8 <commands+0xb38>
ffffffffc0201db8:	c50fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert( nr_free == 0);         
ffffffffc0201dbc:	00005697          	auipc	a3,0x5
ffffffffc0201dc0:	7d468693          	addi	a3,a3,2004 # ffffffffc0207590 <commands+0xd10>
ffffffffc0201dc4:	00005617          	auipc	a2,0x5
ffffffffc0201dc8:	ecc60613          	addi	a2,a2,-308 # ffffffffc0206c90 <commands+0x410>
ffffffffc0201dcc:	0f300593          	li	a1,243
ffffffffc0201dd0:	00005517          	auipc	a0,0x5
ffffffffc0201dd4:	5e850513          	addi	a0,a0,1512 # ffffffffc02073b8 <commands+0xb38>
ffffffffc0201dd8:	c30fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0201ddc:	00005697          	auipc	a3,0x5
ffffffffc0201de0:	41468693          	addi	a3,a3,1044 # ffffffffc02071f0 <commands+0x970>
ffffffffc0201de4:	00005617          	auipc	a2,0x5
ffffffffc0201de8:	eac60613          	addi	a2,a2,-340 # ffffffffc0206c90 <commands+0x410>
ffffffffc0201dec:	0cc00593          	li	a1,204
ffffffffc0201df0:	00005517          	auipc	a0,0x5
ffffffffc0201df4:	5c850513          	addi	a0,a0,1480 # ffffffffc02073b8 <commands+0xb38>
ffffffffc0201df8:	c10fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(mm != NULL);
ffffffffc0201dfc:	00005697          	auipc	a3,0x5
ffffffffc0201e00:	22c68693          	addi	a3,a3,556 # ffffffffc0207028 <commands+0x7a8>
ffffffffc0201e04:	00005617          	auipc	a2,0x5
ffffffffc0201e08:	e8c60613          	addi	a2,a2,-372 # ffffffffc0206c90 <commands+0x410>
ffffffffc0201e0c:	0c400593          	li	a1,196
ffffffffc0201e10:	00005517          	auipc	a0,0x5
ffffffffc0201e14:	5a850513          	addi	a0,a0,1448 # ffffffffc02073b8 <commands+0xb38>
ffffffffc0201e18:	bf0fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(total==0);
ffffffffc0201e1c:	00006697          	auipc	a3,0x6
ffffffffc0201e20:	82c68693          	addi	a3,a3,-2004 # ffffffffc0207648 <commands+0xdc8>
ffffffffc0201e24:	00005617          	auipc	a2,0x5
ffffffffc0201e28:	e6c60613          	addi	a2,a2,-404 # ffffffffc0206c90 <commands+0x410>
ffffffffc0201e2c:	11e00593          	li	a1,286
ffffffffc0201e30:	00005517          	auipc	a0,0x5
ffffffffc0201e34:	58850513          	addi	a0,a0,1416 # ffffffffc02073b8 <commands+0xb38>
ffffffffc0201e38:	bd0fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc0201e3c:	00005617          	auipc	a2,0x5
ffffffffc0201e40:	42460613          	addi	a2,a2,1060 # ffffffffc0207260 <commands+0x9e0>
ffffffffc0201e44:	06900593          	li	a1,105
ffffffffc0201e48:	00005517          	auipc	a0,0x5
ffffffffc0201e4c:	40850513          	addi	a0,a0,1032 # ffffffffc0207250 <commands+0x9d0>
ffffffffc0201e50:	bb8fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(count==0);
ffffffffc0201e54:	00005697          	auipc	a3,0x5
ffffffffc0201e58:	7e468693          	addi	a3,a3,2020 # ffffffffc0207638 <commands+0xdb8>
ffffffffc0201e5c:	00005617          	auipc	a2,0x5
ffffffffc0201e60:	e3460613          	addi	a2,a2,-460 # ffffffffc0206c90 <commands+0x410>
ffffffffc0201e64:	11d00593          	li	a1,285
ffffffffc0201e68:	00005517          	auipc	a0,0x5
ffffffffc0201e6c:	55050513          	addi	a0,a0,1360 # ffffffffc02073b8 <commands+0xb38>
ffffffffc0201e70:	b98fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==1);
ffffffffc0201e74:	00005697          	auipc	a3,0x5
ffffffffc0201e78:	6dc68693          	addi	a3,a3,1756 # ffffffffc0207550 <commands+0xcd0>
ffffffffc0201e7c:	00005617          	auipc	a2,0x5
ffffffffc0201e80:	e1460613          	addi	a2,a2,-492 # ffffffffc0206c90 <commands+0x410>
ffffffffc0201e84:	09500593          	li	a1,149
ffffffffc0201e88:	00005517          	auipc	a0,0x5
ffffffffc0201e8c:	53050513          	addi	a0,a0,1328 # ffffffffc02073b8 <commands+0xb38>
ffffffffc0201e90:	b78fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0201e94:	00005697          	auipc	a3,0x5
ffffffffc0201e98:	66c68693          	addi	a3,a3,1644 # ffffffffc0207500 <commands+0xc80>
ffffffffc0201e9c:	00005617          	auipc	a2,0x5
ffffffffc0201ea0:	df460613          	addi	a2,a2,-524 # ffffffffc0206c90 <commands+0x410>
ffffffffc0201ea4:	0ea00593          	li	a1,234
ffffffffc0201ea8:	00005517          	auipc	a0,0x5
ffffffffc0201eac:	51050513          	addi	a0,a0,1296 # ffffffffc02073b8 <commands+0xb38>
ffffffffc0201eb0:	b58fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0201eb4:	00005697          	auipc	a3,0x5
ffffffffc0201eb8:	5d468693          	addi	a3,a3,1492 # ffffffffc0207488 <commands+0xc08>
ffffffffc0201ebc:	00005617          	auipc	a2,0x5
ffffffffc0201ec0:	dd460613          	addi	a2,a2,-556 # ffffffffc0206c90 <commands+0x410>
ffffffffc0201ec4:	0d700593          	li	a1,215
ffffffffc0201ec8:	00005517          	auipc	a0,0x5
ffffffffc0201ecc:	4f050513          	addi	a0,a0,1264 # ffffffffc02073b8 <commands+0xb38>
ffffffffc0201ed0:	b38fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(ret==0);
ffffffffc0201ed4:	00005697          	auipc	a3,0x5
ffffffffc0201ed8:	75c68693          	addi	a3,a3,1884 # ffffffffc0207630 <commands+0xdb0>
ffffffffc0201edc:	00005617          	auipc	a2,0x5
ffffffffc0201ee0:	db460613          	addi	a2,a2,-588 # ffffffffc0206c90 <commands+0x410>
ffffffffc0201ee4:	10200593          	li	a1,258
ffffffffc0201ee8:	00005517          	auipc	a0,0x5
ffffffffc0201eec:	4d050513          	addi	a0,a0,1232 # ffffffffc02073b8 <commands+0xb38>
ffffffffc0201ef0:	b18fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(vma != NULL);
ffffffffc0201ef4:	00005697          	auipc	a3,0x5
ffffffffc0201ef8:	3f468693          	addi	a3,a3,1012 # ffffffffc02072e8 <commands+0xa68>
ffffffffc0201efc:	00005617          	auipc	a2,0x5
ffffffffc0201f00:	d9460613          	addi	a2,a2,-620 # ffffffffc0206c90 <commands+0x410>
ffffffffc0201f04:	0cf00593          	li	a1,207
ffffffffc0201f08:	00005517          	auipc	a0,0x5
ffffffffc0201f0c:	4b050513          	addi	a0,a0,1200 # ffffffffc02073b8 <commands+0xb38>
ffffffffc0201f10:	af8fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==4);
ffffffffc0201f14:	00005697          	auipc	a3,0x5
ffffffffc0201f18:	66c68693          	addi	a3,a3,1644 # ffffffffc0207580 <commands+0xd00>
ffffffffc0201f1c:	00005617          	auipc	a2,0x5
ffffffffc0201f20:	d7460613          	addi	a2,a2,-652 # ffffffffc0206c90 <commands+0x410>
ffffffffc0201f24:	09f00593          	li	a1,159
ffffffffc0201f28:	00005517          	auipc	a0,0x5
ffffffffc0201f2c:	49050513          	addi	a0,a0,1168 # ffffffffc02073b8 <commands+0xb38>
ffffffffc0201f30:	ad8fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==4);
ffffffffc0201f34:	00005697          	auipc	a3,0x5
ffffffffc0201f38:	64c68693          	addi	a3,a3,1612 # ffffffffc0207580 <commands+0xd00>
ffffffffc0201f3c:	00005617          	auipc	a2,0x5
ffffffffc0201f40:	d5460613          	addi	a2,a2,-684 # ffffffffc0206c90 <commands+0x410>
ffffffffc0201f44:	0a100593          	li	a1,161
ffffffffc0201f48:	00005517          	auipc	a0,0x5
ffffffffc0201f4c:	47050513          	addi	a0,a0,1136 # ffffffffc02073b8 <commands+0xb38>
ffffffffc0201f50:	ab8fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==2);
ffffffffc0201f54:	00005697          	auipc	a3,0x5
ffffffffc0201f58:	60c68693          	addi	a3,a3,1548 # ffffffffc0207560 <commands+0xce0>
ffffffffc0201f5c:	00005617          	auipc	a2,0x5
ffffffffc0201f60:	d3460613          	addi	a2,a2,-716 # ffffffffc0206c90 <commands+0x410>
ffffffffc0201f64:	09700593          	li	a1,151
ffffffffc0201f68:	00005517          	auipc	a0,0x5
ffffffffc0201f6c:	45050513          	addi	a0,a0,1104 # ffffffffc02073b8 <commands+0xb38>
ffffffffc0201f70:	a98fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==2);
ffffffffc0201f74:	00005697          	auipc	a3,0x5
ffffffffc0201f78:	5ec68693          	addi	a3,a3,1516 # ffffffffc0207560 <commands+0xce0>
ffffffffc0201f7c:	00005617          	auipc	a2,0x5
ffffffffc0201f80:	d1460613          	addi	a2,a2,-748 # ffffffffc0206c90 <commands+0x410>
ffffffffc0201f84:	09900593          	li	a1,153
ffffffffc0201f88:	00005517          	auipc	a0,0x5
ffffffffc0201f8c:	43050513          	addi	a0,a0,1072 # ffffffffc02073b8 <commands+0xb38>
ffffffffc0201f90:	a78fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==3);
ffffffffc0201f94:	00005697          	auipc	a3,0x5
ffffffffc0201f98:	5dc68693          	addi	a3,a3,1500 # ffffffffc0207570 <commands+0xcf0>
ffffffffc0201f9c:	00005617          	auipc	a2,0x5
ffffffffc0201fa0:	cf460613          	addi	a2,a2,-780 # ffffffffc0206c90 <commands+0x410>
ffffffffc0201fa4:	09b00593          	li	a1,155
ffffffffc0201fa8:	00005517          	auipc	a0,0x5
ffffffffc0201fac:	41050513          	addi	a0,a0,1040 # ffffffffc02073b8 <commands+0xb38>
ffffffffc0201fb0:	a58fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==3);
ffffffffc0201fb4:	00005697          	auipc	a3,0x5
ffffffffc0201fb8:	5bc68693          	addi	a3,a3,1468 # ffffffffc0207570 <commands+0xcf0>
ffffffffc0201fbc:	00005617          	auipc	a2,0x5
ffffffffc0201fc0:	cd460613          	addi	a2,a2,-812 # ffffffffc0206c90 <commands+0x410>
ffffffffc0201fc4:	09d00593          	li	a1,157
ffffffffc0201fc8:	00005517          	auipc	a0,0x5
ffffffffc0201fcc:	3f050513          	addi	a0,a0,1008 # ffffffffc02073b8 <commands+0xb38>
ffffffffc0201fd0:	a38fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==1);
ffffffffc0201fd4:	00005697          	auipc	a3,0x5
ffffffffc0201fd8:	57c68693          	addi	a3,a3,1404 # ffffffffc0207550 <commands+0xcd0>
ffffffffc0201fdc:	00005617          	auipc	a2,0x5
ffffffffc0201fe0:	cb460613          	addi	a2,a2,-844 # ffffffffc0206c90 <commands+0x410>
ffffffffc0201fe4:	09300593          	li	a1,147
ffffffffc0201fe8:	00005517          	auipc	a0,0x5
ffffffffc0201fec:	3d050513          	addi	a0,a0,976 # ffffffffc02073b8 <commands+0xb38>
ffffffffc0201ff0:	a18fe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0201ff4 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0201ff4:	000b1797          	auipc	a5,0xb1
ffffffffc0201ff8:	87c7b783          	ld	a5,-1924(a5) # ffffffffc02b2870 <sm>
ffffffffc0201ffc:	6b9c                	ld	a5,16(a5)
ffffffffc0201ffe:	8782                	jr	a5

ffffffffc0202000 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0202000:	000b1797          	auipc	a5,0xb1
ffffffffc0202004:	8707b783          	ld	a5,-1936(a5) # ffffffffc02b2870 <sm>
ffffffffc0202008:	739c                	ld	a5,32(a5)
ffffffffc020200a:	8782                	jr	a5

ffffffffc020200c <swap_out>:
{
ffffffffc020200c:	711d                	addi	sp,sp,-96
ffffffffc020200e:	ec86                	sd	ra,88(sp)
ffffffffc0202010:	e8a2                	sd	s0,80(sp)
ffffffffc0202012:	e4a6                	sd	s1,72(sp)
ffffffffc0202014:	e0ca                	sd	s2,64(sp)
ffffffffc0202016:	fc4e                	sd	s3,56(sp)
ffffffffc0202018:	f852                	sd	s4,48(sp)
ffffffffc020201a:	f456                	sd	s5,40(sp)
ffffffffc020201c:	f05a                	sd	s6,32(sp)
ffffffffc020201e:	ec5e                	sd	s7,24(sp)
ffffffffc0202020:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0202022:	cde9                	beqz	a1,ffffffffc02020fc <swap_out+0xf0>
ffffffffc0202024:	8a2e                	mv	s4,a1
ffffffffc0202026:	892a                	mv	s2,a0
ffffffffc0202028:	8ab2                	mv	s5,a2
ffffffffc020202a:	4401                	li	s0,0
ffffffffc020202c:	000b1997          	auipc	s3,0xb1
ffffffffc0202030:	84498993          	addi	s3,s3,-1980 # ffffffffc02b2870 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202034:	00005b17          	auipc	s6,0x5
ffffffffc0202038:	6a4b0b13          	addi	s6,s6,1700 # ffffffffc02076d8 <commands+0xe58>
                    cprintf("SWAP: failed to save\n");
ffffffffc020203c:	00005b97          	auipc	s7,0x5
ffffffffc0202040:	684b8b93          	addi	s7,s7,1668 # ffffffffc02076c0 <commands+0xe40>
ffffffffc0202044:	a825                	j	ffffffffc020207c <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202046:	67a2                	ld	a5,8(sp)
ffffffffc0202048:	8626                	mv	a2,s1
ffffffffc020204a:	85a2                	mv	a1,s0
ffffffffc020204c:	7f94                	ld	a3,56(a5)
ffffffffc020204e:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0202050:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202052:	82b1                	srli	a3,a3,0xc
ffffffffc0202054:	0685                	addi	a3,a3,1
ffffffffc0202056:	876fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc020205a:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc020205c:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc020205e:	7d1c                	ld	a5,56(a0)
ffffffffc0202060:	83b1                	srli	a5,a5,0xc
ffffffffc0202062:	0785                	addi	a5,a5,1
ffffffffc0202064:	07a2                	slli	a5,a5,0x8
ffffffffc0202066:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc020206a:	472010ef          	jal	ra,ffffffffc02034dc <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc020206e:	01893503          	ld	a0,24(s2)
ffffffffc0202072:	85a6                	mv	a1,s1
ffffffffc0202074:	23d020ef          	jal	ra,ffffffffc0204ab0 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0202078:	048a0d63          	beq	s4,s0,ffffffffc02020d2 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc020207c:	0009b783          	ld	a5,0(s3)
ffffffffc0202080:	8656                	mv	a2,s5
ffffffffc0202082:	002c                	addi	a1,sp,8
ffffffffc0202084:	7b9c                	ld	a5,48(a5)
ffffffffc0202086:	854a                	mv	a0,s2
ffffffffc0202088:	9782                	jalr	a5
          if (r != 0) {
ffffffffc020208a:	e12d                	bnez	a0,ffffffffc02020ec <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc020208c:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020208e:	01893503          	ld	a0,24(s2)
ffffffffc0202092:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0202094:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202096:	85a6                	mv	a1,s1
ffffffffc0202098:	4be010ef          	jal	ra,ffffffffc0203556 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc020209c:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020209e:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc02020a0:	8b85                	andi	a5,a5,1
ffffffffc02020a2:	cfb9                	beqz	a5,ffffffffc0202100 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc02020a4:	65a2                	ld	a1,8(sp)
ffffffffc02020a6:	7d9c                	ld	a5,56(a1)
ffffffffc02020a8:	83b1                	srli	a5,a5,0xc
ffffffffc02020aa:	0785                	addi	a5,a5,1
ffffffffc02020ac:	00879513          	slli	a0,a5,0x8
ffffffffc02020b0:	387020ef          	jal	ra,ffffffffc0204c36 <swapfs_write>
ffffffffc02020b4:	d949                	beqz	a0,ffffffffc0202046 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc02020b6:	855e                	mv	a0,s7
ffffffffc02020b8:	814fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc02020bc:	0009b783          	ld	a5,0(s3)
ffffffffc02020c0:	6622                	ld	a2,8(sp)
ffffffffc02020c2:	4681                	li	a3,0
ffffffffc02020c4:	739c                	ld	a5,32(a5)
ffffffffc02020c6:	85a6                	mv	a1,s1
ffffffffc02020c8:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc02020ca:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc02020cc:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc02020ce:	fa8a17e3          	bne	s4,s0,ffffffffc020207c <swap_out+0x70>
}
ffffffffc02020d2:	60e6                	ld	ra,88(sp)
ffffffffc02020d4:	8522                	mv	a0,s0
ffffffffc02020d6:	6446                	ld	s0,80(sp)
ffffffffc02020d8:	64a6                	ld	s1,72(sp)
ffffffffc02020da:	6906                	ld	s2,64(sp)
ffffffffc02020dc:	79e2                	ld	s3,56(sp)
ffffffffc02020de:	7a42                	ld	s4,48(sp)
ffffffffc02020e0:	7aa2                	ld	s5,40(sp)
ffffffffc02020e2:	7b02                	ld	s6,32(sp)
ffffffffc02020e4:	6be2                	ld	s7,24(sp)
ffffffffc02020e6:	6c42                	ld	s8,16(sp)
ffffffffc02020e8:	6125                	addi	sp,sp,96
ffffffffc02020ea:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc02020ec:	85a2                	mv	a1,s0
ffffffffc02020ee:	00005517          	auipc	a0,0x5
ffffffffc02020f2:	58a50513          	addi	a0,a0,1418 # ffffffffc0207678 <commands+0xdf8>
ffffffffc02020f6:	fd7fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
                  break;
ffffffffc02020fa:	bfe1                	j	ffffffffc02020d2 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc02020fc:	4401                	li	s0,0
ffffffffc02020fe:	bfd1                	j	ffffffffc02020d2 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202100:	00005697          	auipc	a3,0x5
ffffffffc0202104:	5a868693          	addi	a3,a3,1448 # ffffffffc02076a8 <commands+0xe28>
ffffffffc0202108:	00005617          	auipc	a2,0x5
ffffffffc020210c:	b8860613          	addi	a2,a2,-1144 # ffffffffc0206c90 <commands+0x410>
ffffffffc0202110:	06800593          	li	a1,104
ffffffffc0202114:	00005517          	auipc	a0,0x5
ffffffffc0202118:	2a450513          	addi	a0,a0,676 # ffffffffc02073b8 <commands+0xb38>
ffffffffc020211c:	8ecfe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202120 <swap_in>:
{
ffffffffc0202120:	7179                	addi	sp,sp,-48
ffffffffc0202122:	e84a                	sd	s2,16(sp)
ffffffffc0202124:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0202126:	4505                	li	a0,1
{
ffffffffc0202128:	ec26                	sd	s1,24(sp)
ffffffffc020212a:	e44e                	sd	s3,8(sp)
ffffffffc020212c:	f406                	sd	ra,40(sp)
ffffffffc020212e:	f022                	sd	s0,32(sp)
ffffffffc0202130:	84ae                	mv	s1,a1
ffffffffc0202132:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0202134:	316010ef          	jal	ra,ffffffffc020344a <alloc_pages>
     assert(result!=NULL);
ffffffffc0202138:	c129                	beqz	a0,ffffffffc020217a <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc020213a:	842a                	mv	s0,a0
ffffffffc020213c:	01893503          	ld	a0,24(s2)
ffffffffc0202140:	4601                	li	a2,0
ffffffffc0202142:	85a6                	mv	a1,s1
ffffffffc0202144:	412010ef          	jal	ra,ffffffffc0203556 <get_pte>
ffffffffc0202148:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc020214a:	6108                	ld	a0,0(a0)
ffffffffc020214c:	85a2                	mv	a1,s0
ffffffffc020214e:	25b020ef          	jal	ra,ffffffffc0204ba8 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0202152:	00093583          	ld	a1,0(s2)
ffffffffc0202156:	8626                	mv	a2,s1
ffffffffc0202158:	00005517          	auipc	a0,0x5
ffffffffc020215c:	5d050513          	addi	a0,a0,1488 # ffffffffc0207728 <commands+0xea8>
ffffffffc0202160:	81a1                	srli	a1,a1,0x8
ffffffffc0202162:	f6bfd0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc0202166:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0202168:	0089b023          	sd	s0,0(s3)
}
ffffffffc020216c:	7402                	ld	s0,32(sp)
ffffffffc020216e:	64e2                	ld	s1,24(sp)
ffffffffc0202170:	6942                	ld	s2,16(sp)
ffffffffc0202172:	69a2                	ld	s3,8(sp)
ffffffffc0202174:	4501                	li	a0,0
ffffffffc0202176:	6145                	addi	sp,sp,48
ffffffffc0202178:	8082                	ret
     assert(result!=NULL);
ffffffffc020217a:	00005697          	auipc	a3,0x5
ffffffffc020217e:	59e68693          	addi	a3,a3,1438 # ffffffffc0207718 <commands+0xe98>
ffffffffc0202182:	00005617          	auipc	a2,0x5
ffffffffc0202186:	b0e60613          	addi	a2,a2,-1266 # ffffffffc0206c90 <commands+0x410>
ffffffffc020218a:	07e00593          	li	a1,126
ffffffffc020218e:	00005517          	auipc	a0,0x5
ffffffffc0202192:	22a50513          	addi	a0,a0,554 # ffffffffc02073b8 <commands+0xb38>
ffffffffc0202196:	872fe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020219a <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc020219a:	c94d                	beqz	a0,ffffffffc020224c <slob_free+0xb2>
{
ffffffffc020219c:	1141                	addi	sp,sp,-16
ffffffffc020219e:	e022                	sd	s0,0(sp)
ffffffffc02021a0:	e406                	sd	ra,8(sp)
ffffffffc02021a2:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc02021a4:	e9c1                	bnez	a1,ffffffffc0202234 <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02021a6:	100027f3          	csrr	a5,sstatus
ffffffffc02021aa:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02021ac:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02021ae:	ebd9                	bnez	a5,ffffffffc0202244 <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02021b0:	000a5617          	auipc	a2,0xa5
ffffffffc02021b4:	1b860613          	addi	a2,a2,440 # ffffffffc02a7368 <slobfree>
ffffffffc02021b8:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02021ba:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02021bc:	679c                	ld	a5,8(a5)
ffffffffc02021be:	02877a63          	bgeu	a4,s0,ffffffffc02021f2 <slob_free+0x58>
ffffffffc02021c2:	00f46463          	bltu	s0,a5,ffffffffc02021ca <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02021c6:	fef76ae3          	bltu	a4,a5,ffffffffc02021ba <slob_free+0x20>
			break;

	if (b + b->units == cur->next) {
ffffffffc02021ca:	400c                	lw	a1,0(s0)
ffffffffc02021cc:	00459693          	slli	a3,a1,0x4
ffffffffc02021d0:	96a2                	add	a3,a3,s0
ffffffffc02021d2:	02d78a63          	beq	a5,a3,ffffffffc0202206 <slob_free+0x6c>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc02021d6:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc02021d8:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc02021da:	00469793          	slli	a5,a3,0x4
ffffffffc02021de:	97ba                	add	a5,a5,a4
ffffffffc02021e0:	02f40e63          	beq	s0,a5,ffffffffc020221c <slob_free+0x82>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc02021e4:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc02021e6:	e218                	sd	a4,0(a2)
    if (flag) {
ffffffffc02021e8:	e129                	bnez	a0,ffffffffc020222a <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc02021ea:	60a2                	ld	ra,8(sp)
ffffffffc02021ec:	6402                	ld	s0,0(sp)
ffffffffc02021ee:	0141                	addi	sp,sp,16
ffffffffc02021f0:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02021f2:	fcf764e3          	bltu	a4,a5,ffffffffc02021ba <slob_free+0x20>
ffffffffc02021f6:	fcf472e3          	bgeu	s0,a5,ffffffffc02021ba <slob_free+0x20>
	if (b + b->units == cur->next) {
ffffffffc02021fa:	400c                	lw	a1,0(s0)
ffffffffc02021fc:	00459693          	slli	a3,a1,0x4
ffffffffc0202200:	96a2                	add	a3,a3,s0
ffffffffc0202202:	fcd79ae3          	bne	a5,a3,ffffffffc02021d6 <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc0202206:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0202208:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc020220a:	9db5                	addw	a1,a1,a3
ffffffffc020220c:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b) {
ffffffffc020220e:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0202210:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc0202212:	00469793          	slli	a5,a3,0x4
ffffffffc0202216:	97ba                	add	a5,a5,a4
ffffffffc0202218:	fcf416e3          	bne	s0,a5,ffffffffc02021e4 <slob_free+0x4a>
		cur->units += b->units;
ffffffffc020221c:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc020221e:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc0202220:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc0202222:	9ebd                	addw	a3,a3,a5
ffffffffc0202224:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc0202226:	e70c                	sd	a1,8(a4)
ffffffffc0202228:	d169                	beqz	a0,ffffffffc02021ea <slob_free+0x50>
}
ffffffffc020222a:	6402                	ld	s0,0(sp)
ffffffffc020222c:	60a2                	ld	ra,8(sp)
ffffffffc020222e:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0202230:	c12fe06f          	j	ffffffffc0200642 <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc0202234:	25bd                	addiw	a1,a1,15
ffffffffc0202236:	8191                	srli	a1,a1,0x4
ffffffffc0202238:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020223a:	100027f3          	csrr	a5,sstatus
ffffffffc020223e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0202240:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202242:	d7bd                	beqz	a5,ffffffffc02021b0 <slob_free+0x16>
        intr_disable();
ffffffffc0202244:	c04fe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc0202248:	4505                	li	a0,1
ffffffffc020224a:	b79d                	j	ffffffffc02021b0 <slob_free+0x16>
ffffffffc020224c:	8082                	ret

ffffffffc020224e <__slob_get_free_pages.constprop.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc020224e:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0202250:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0202252:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0202256:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0202258:	1f2010ef          	jal	ra,ffffffffc020344a <alloc_pages>
  if(!page)
ffffffffc020225c:	c91d                	beqz	a0,ffffffffc0202292 <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc020225e:	000b0697          	auipc	a3,0xb0
ffffffffc0202262:	6426b683          	ld	a3,1602(a3) # ffffffffc02b28a0 <pages>
ffffffffc0202266:	8d15                	sub	a0,a0,a3
ffffffffc0202268:	8519                	srai	a0,a0,0x6
ffffffffc020226a:	00007697          	auipc	a3,0x7
ffffffffc020226e:	a466b683          	ld	a3,-1466(a3) # ffffffffc0208cb0 <nbase>
ffffffffc0202272:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc0202274:	00c51793          	slli	a5,a0,0xc
ffffffffc0202278:	83b1                	srli	a5,a5,0xc
ffffffffc020227a:	000b0717          	auipc	a4,0xb0
ffffffffc020227e:	61e73703          	ld	a4,1566(a4) # ffffffffc02b2898 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc0202282:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0202284:	00e7fa63          	bgeu	a5,a4,ffffffffc0202298 <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc0202288:	000b0697          	auipc	a3,0xb0
ffffffffc020228c:	6286b683          	ld	a3,1576(a3) # ffffffffc02b28b0 <va_pa_offset>
ffffffffc0202290:	9536                	add	a0,a0,a3
}
ffffffffc0202292:	60a2                	ld	ra,8(sp)
ffffffffc0202294:	0141                	addi	sp,sp,16
ffffffffc0202296:	8082                	ret
ffffffffc0202298:	86aa                	mv	a3,a0
ffffffffc020229a:	00005617          	auipc	a2,0x5
ffffffffc020229e:	fc660613          	addi	a2,a2,-58 # ffffffffc0207260 <commands+0x9e0>
ffffffffc02022a2:	06900593          	li	a1,105
ffffffffc02022a6:	00005517          	auipc	a0,0x5
ffffffffc02022aa:	faa50513          	addi	a0,a0,-86 # ffffffffc0207250 <commands+0x9d0>
ffffffffc02022ae:	f5bfd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02022b2 <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc02022b2:	1101                	addi	sp,sp,-32
ffffffffc02022b4:	ec06                	sd	ra,24(sp)
ffffffffc02022b6:	e822                	sd	s0,16(sp)
ffffffffc02022b8:	e426                	sd	s1,8(sp)
ffffffffc02022ba:	e04a                	sd	s2,0(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc02022bc:	01050713          	addi	a4,a0,16
ffffffffc02022c0:	6785                	lui	a5,0x1
ffffffffc02022c2:	0cf77363          	bgeu	a4,a5,ffffffffc0202388 <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc02022c6:	00f50493          	addi	s1,a0,15
ffffffffc02022ca:	8091                	srli	s1,s1,0x4
ffffffffc02022cc:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02022ce:	10002673          	csrr	a2,sstatus
ffffffffc02022d2:	8a09                	andi	a2,a2,2
ffffffffc02022d4:	e25d                	bnez	a2,ffffffffc020237a <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc02022d6:	000a5917          	auipc	s2,0xa5
ffffffffc02022da:	09290913          	addi	s2,s2,146 # ffffffffc02a7368 <slobfree>
ffffffffc02022de:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02022e2:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02022e4:	4398                	lw	a4,0(a5)
ffffffffc02022e6:	08975e63          	bge	a4,s1,ffffffffc0202382 <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree) {
ffffffffc02022ea:	00f68b63          	beq	a3,a5,ffffffffc0202300 <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02022ee:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02022f0:	4018                	lw	a4,0(s0)
ffffffffc02022f2:	02975a63          	bge	a4,s1,ffffffffc0202326 <slob_alloc.constprop.0+0x74>
		if (cur == slobfree) {
ffffffffc02022f6:	00093683          	ld	a3,0(s2)
ffffffffc02022fa:	87a2                	mv	a5,s0
ffffffffc02022fc:	fef699e3          	bne	a3,a5,ffffffffc02022ee <slob_alloc.constprop.0+0x3c>
    if (flag) {
ffffffffc0202300:	ee31                	bnez	a2,ffffffffc020235c <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0202302:	4501                	li	a0,0
ffffffffc0202304:	f4bff0ef          	jal	ra,ffffffffc020224e <__slob_get_free_pages.constprop.0>
ffffffffc0202308:	842a                	mv	s0,a0
			if (!cur)
ffffffffc020230a:	cd05                	beqz	a0,ffffffffc0202342 <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc020230c:	6585                	lui	a1,0x1
ffffffffc020230e:	e8dff0ef          	jal	ra,ffffffffc020219a <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202312:	10002673          	csrr	a2,sstatus
ffffffffc0202316:	8a09                	andi	a2,a2,2
ffffffffc0202318:	ee05                	bnez	a2,ffffffffc0202350 <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc020231a:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc020231e:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0202320:	4018                	lw	a4,0(s0)
ffffffffc0202322:	fc974ae3          	blt	a4,s1,ffffffffc02022f6 <slob_alloc.constprop.0+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc0202326:	04e48763          	beq	s1,a4,ffffffffc0202374 <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc020232a:	00449693          	slli	a3,s1,0x4
ffffffffc020232e:	96a2                	add	a3,a3,s0
ffffffffc0202330:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0202332:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0202334:	9f05                	subw	a4,a4,s1
ffffffffc0202336:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0202338:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc020233a:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc020233c:	00f93023          	sd	a5,0(s2)
    if (flag) {
ffffffffc0202340:	e20d                	bnez	a2,ffffffffc0202362 <slob_alloc.constprop.0+0xb0>
}
ffffffffc0202342:	60e2                	ld	ra,24(sp)
ffffffffc0202344:	8522                	mv	a0,s0
ffffffffc0202346:	6442                	ld	s0,16(sp)
ffffffffc0202348:	64a2                	ld	s1,8(sp)
ffffffffc020234a:	6902                	ld	s2,0(sp)
ffffffffc020234c:	6105                	addi	sp,sp,32
ffffffffc020234e:	8082                	ret
        intr_disable();
ffffffffc0202350:	af8fe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
			cur = slobfree;
ffffffffc0202354:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc0202358:	4605                	li	a2,1
ffffffffc020235a:	b7d1                	j	ffffffffc020231e <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc020235c:	ae6fe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0202360:	b74d                	j	ffffffffc0202302 <slob_alloc.constprop.0+0x50>
ffffffffc0202362:	ae0fe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
}
ffffffffc0202366:	60e2                	ld	ra,24(sp)
ffffffffc0202368:	8522                	mv	a0,s0
ffffffffc020236a:	6442                	ld	s0,16(sp)
ffffffffc020236c:	64a2                	ld	s1,8(sp)
ffffffffc020236e:	6902                	ld	s2,0(sp)
ffffffffc0202370:	6105                	addi	sp,sp,32
ffffffffc0202372:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0202374:	6418                	ld	a4,8(s0)
ffffffffc0202376:	e798                	sd	a4,8(a5)
ffffffffc0202378:	b7d1                	j	ffffffffc020233c <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc020237a:	acefe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc020237e:	4605                	li	a2,1
ffffffffc0202380:	bf99                	j	ffffffffc02022d6 <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0202382:	843e                	mv	s0,a5
ffffffffc0202384:	87b6                	mv	a5,a3
ffffffffc0202386:	b745                	j	ffffffffc0202326 <slob_alloc.constprop.0+0x74>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0202388:	00005697          	auipc	a3,0x5
ffffffffc020238c:	3e068693          	addi	a3,a3,992 # ffffffffc0207768 <commands+0xee8>
ffffffffc0202390:	00005617          	auipc	a2,0x5
ffffffffc0202394:	90060613          	addi	a2,a2,-1792 # ffffffffc0206c90 <commands+0x410>
ffffffffc0202398:	06400593          	li	a1,100
ffffffffc020239c:	00005517          	auipc	a0,0x5
ffffffffc02023a0:	3ec50513          	addi	a0,a0,1004 # ffffffffc0207788 <commands+0xf08>
ffffffffc02023a4:	e65fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02023a8 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc02023a8:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc02023aa:	00005517          	auipc	a0,0x5
ffffffffc02023ae:	3f650513          	addi	a0,a0,1014 # ffffffffc02077a0 <commands+0xf20>
kmalloc_init(void) {
ffffffffc02023b2:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc02023b4:	d19fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc02023b8:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc02023ba:	00005517          	auipc	a0,0x5
ffffffffc02023be:	3fe50513          	addi	a0,a0,1022 # ffffffffc02077b8 <commands+0xf38>
}
ffffffffc02023c2:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc02023c4:	d09fd06f          	j	ffffffffc02000cc <cprintf>

ffffffffc02023c8 <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc02023c8:	4501                	li	a0,0
ffffffffc02023ca:	8082                	ret

ffffffffc02023cc <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc02023cc:	1101                	addi	sp,sp,-32
ffffffffc02023ce:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02023d0:	6905                	lui	s2,0x1
{
ffffffffc02023d2:	e822                	sd	s0,16(sp)
ffffffffc02023d4:	ec06                	sd	ra,24(sp)
ffffffffc02023d6:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02023d8:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8bc9>
{
ffffffffc02023dc:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02023de:	04a7f963          	bgeu	a5,a0,ffffffffc0202430 <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc02023e2:	4561                	li	a0,24
ffffffffc02023e4:	ecfff0ef          	jal	ra,ffffffffc02022b2 <slob_alloc.constprop.0>
ffffffffc02023e8:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc02023ea:	c929                	beqz	a0,ffffffffc020243c <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc02023ec:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc02023f0:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc02023f2:	00f95763          	bge	s2,a5,ffffffffc0202400 <kmalloc+0x34>
ffffffffc02023f6:	6705                	lui	a4,0x1
ffffffffc02023f8:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc02023fa:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc02023fc:	fef74ee3          	blt	a4,a5,ffffffffc02023f8 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0202400:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0202402:	e4dff0ef          	jal	ra,ffffffffc020224e <__slob_get_free_pages.constprop.0>
ffffffffc0202406:	e488                	sd	a0,8(s1)
ffffffffc0202408:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc020240a:	c525                	beqz	a0,ffffffffc0202472 <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020240c:	100027f3          	csrr	a5,sstatus
ffffffffc0202410:	8b89                	andi	a5,a5,2
ffffffffc0202412:	ef8d                	bnez	a5,ffffffffc020244c <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc0202414:	000b0797          	auipc	a5,0xb0
ffffffffc0202418:	46c78793          	addi	a5,a5,1132 # ffffffffc02b2880 <bigblocks>
ffffffffc020241c:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc020241e:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0202420:	e898                	sd	a4,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0202422:	60e2                	ld	ra,24(sp)
ffffffffc0202424:	8522                	mv	a0,s0
ffffffffc0202426:	6442                	ld	s0,16(sp)
ffffffffc0202428:	64a2                	ld	s1,8(sp)
ffffffffc020242a:	6902                	ld	s2,0(sp)
ffffffffc020242c:	6105                	addi	sp,sp,32
ffffffffc020242e:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0202430:	0541                	addi	a0,a0,16
ffffffffc0202432:	e81ff0ef          	jal	ra,ffffffffc02022b2 <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc0202436:	01050413          	addi	s0,a0,16
ffffffffc020243a:	f565                	bnez	a0,ffffffffc0202422 <kmalloc+0x56>
ffffffffc020243c:	4401                	li	s0,0
}
ffffffffc020243e:	60e2                	ld	ra,24(sp)
ffffffffc0202440:	8522                	mv	a0,s0
ffffffffc0202442:	6442                	ld	s0,16(sp)
ffffffffc0202444:	64a2                	ld	s1,8(sp)
ffffffffc0202446:	6902                	ld	s2,0(sp)
ffffffffc0202448:	6105                	addi	sp,sp,32
ffffffffc020244a:	8082                	ret
        intr_disable();
ffffffffc020244c:	9fcfe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
		bb->next = bigblocks;
ffffffffc0202450:	000b0797          	auipc	a5,0xb0
ffffffffc0202454:	43078793          	addi	a5,a5,1072 # ffffffffc02b2880 <bigblocks>
ffffffffc0202458:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc020245a:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc020245c:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc020245e:	9e4fe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
		return bb->pages;
ffffffffc0202462:	6480                	ld	s0,8(s1)
}
ffffffffc0202464:	60e2                	ld	ra,24(sp)
ffffffffc0202466:	64a2                	ld	s1,8(sp)
ffffffffc0202468:	8522                	mv	a0,s0
ffffffffc020246a:	6442                	ld	s0,16(sp)
ffffffffc020246c:	6902                	ld	s2,0(sp)
ffffffffc020246e:	6105                	addi	sp,sp,32
ffffffffc0202470:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0202472:	45e1                	li	a1,24
ffffffffc0202474:	8526                	mv	a0,s1
ffffffffc0202476:	d25ff0ef          	jal	ra,ffffffffc020219a <slob_free>
  return __kmalloc(size, 0);
ffffffffc020247a:	b765                	j	ffffffffc0202422 <kmalloc+0x56>

ffffffffc020247c <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc020247c:	c179                	beqz	a0,ffffffffc0202542 <kfree+0xc6>
{
ffffffffc020247e:	1101                	addi	sp,sp,-32
ffffffffc0202480:	e822                	sd	s0,16(sp)
ffffffffc0202482:	ec06                	sd	ra,24(sp)
ffffffffc0202484:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0202486:	03451793          	slli	a5,a0,0x34
ffffffffc020248a:	842a                	mv	s0,a0
ffffffffc020248c:	e7c1                	bnez	a5,ffffffffc0202514 <kfree+0x98>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020248e:	100027f3          	csrr	a5,sstatus
ffffffffc0202492:	8b89                	andi	a5,a5,2
ffffffffc0202494:	ebc9                	bnez	a5,ffffffffc0202526 <kfree+0xaa>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0202496:	000b0797          	auipc	a5,0xb0
ffffffffc020249a:	3ea7b783          	ld	a5,1002(a5) # ffffffffc02b2880 <bigblocks>
    return 0;
ffffffffc020249e:	4601                	li	a2,0
ffffffffc02024a0:	cbb5                	beqz	a5,ffffffffc0202514 <kfree+0x98>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc02024a2:	000b0697          	auipc	a3,0xb0
ffffffffc02024a6:	3de68693          	addi	a3,a3,990 # ffffffffc02b2880 <bigblocks>
ffffffffc02024aa:	a021                	j	ffffffffc02024b2 <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc02024ac:	01048693          	addi	a3,s1,16
ffffffffc02024b0:	c3ad                	beqz	a5,ffffffffc0202512 <kfree+0x96>
			if (bb->pages == block) {
ffffffffc02024b2:	6798                	ld	a4,8(a5)
ffffffffc02024b4:	84be                	mv	s1,a5
				*last = bb->next;
ffffffffc02024b6:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block) {
ffffffffc02024b8:	fe871ae3          	bne	a4,s0,ffffffffc02024ac <kfree+0x30>
				*last = bb->next;
ffffffffc02024bc:	e29c                	sd	a5,0(a3)
    if (flag) {
ffffffffc02024be:	ee3d                	bnez	a2,ffffffffc020253c <kfree+0xc0>
    return pa2page(PADDR(kva));
ffffffffc02024c0:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc02024c4:	4098                	lw	a4,0(s1)
ffffffffc02024c6:	08f46b63          	bltu	s0,a5,ffffffffc020255c <kfree+0xe0>
ffffffffc02024ca:	000b0697          	auipc	a3,0xb0
ffffffffc02024ce:	3e66b683          	ld	a3,998(a3) # ffffffffc02b28b0 <va_pa_offset>
ffffffffc02024d2:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage) {
ffffffffc02024d4:	8031                	srli	s0,s0,0xc
ffffffffc02024d6:	000b0797          	auipc	a5,0xb0
ffffffffc02024da:	3c27b783          	ld	a5,962(a5) # ffffffffc02b2898 <npage>
ffffffffc02024de:	06f47363          	bgeu	s0,a5,ffffffffc0202544 <kfree+0xc8>
    return &pages[PPN(pa) - nbase];
ffffffffc02024e2:	00006517          	auipc	a0,0x6
ffffffffc02024e6:	7ce53503          	ld	a0,1998(a0) # ffffffffc0208cb0 <nbase>
ffffffffc02024ea:	8c09                	sub	s0,s0,a0
ffffffffc02024ec:	041a                	slli	s0,s0,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc02024ee:	000b0517          	auipc	a0,0xb0
ffffffffc02024f2:	3b253503          	ld	a0,946(a0) # ffffffffc02b28a0 <pages>
ffffffffc02024f6:	4585                	li	a1,1
ffffffffc02024f8:	9522                	add	a0,a0,s0
ffffffffc02024fa:	00e595bb          	sllw	a1,a1,a4
ffffffffc02024fe:	7df000ef          	jal	ra,ffffffffc02034dc <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0202502:	6442                	ld	s0,16(sp)
ffffffffc0202504:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0202506:	8526                	mv	a0,s1
}
ffffffffc0202508:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc020250a:	45e1                	li	a1,24
}
ffffffffc020250c:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc020250e:	c8dff06f          	j	ffffffffc020219a <slob_free>
ffffffffc0202512:	e215                	bnez	a2,ffffffffc0202536 <kfree+0xba>
ffffffffc0202514:	ff040513          	addi	a0,s0,-16
}
ffffffffc0202518:	6442                	ld	s0,16(sp)
ffffffffc020251a:	60e2                	ld	ra,24(sp)
ffffffffc020251c:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc020251e:	4581                	li	a1,0
}
ffffffffc0202520:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0202522:	c79ff06f          	j	ffffffffc020219a <slob_free>
        intr_disable();
ffffffffc0202526:	922fe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc020252a:	000b0797          	auipc	a5,0xb0
ffffffffc020252e:	3567b783          	ld	a5,854(a5) # ffffffffc02b2880 <bigblocks>
        return 1;
ffffffffc0202532:	4605                	li	a2,1
ffffffffc0202534:	f7bd                	bnez	a5,ffffffffc02024a2 <kfree+0x26>
        intr_enable();
ffffffffc0202536:	90cfe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc020253a:	bfe9                	j	ffffffffc0202514 <kfree+0x98>
ffffffffc020253c:	906fe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0202540:	b741                	j	ffffffffc02024c0 <kfree+0x44>
ffffffffc0202542:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0202544:	00005617          	auipc	a2,0x5
ffffffffc0202548:	cec60613          	addi	a2,a2,-788 # ffffffffc0207230 <commands+0x9b0>
ffffffffc020254c:	06200593          	li	a1,98
ffffffffc0202550:	00005517          	auipc	a0,0x5
ffffffffc0202554:	d0050513          	addi	a0,a0,-768 # ffffffffc0207250 <commands+0x9d0>
ffffffffc0202558:	cb1fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    return pa2page(PADDR(kva));
ffffffffc020255c:	86a2                	mv	a3,s0
ffffffffc020255e:	00005617          	auipc	a2,0x5
ffffffffc0202562:	27a60613          	addi	a2,a2,634 # ffffffffc02077d8 <commands+0xf58>
ffffffffc0202566:	06e00593          	li	a1,110
ffffffffc020256a:	00005517          	auipc	a0,0x5
ffffffffc020256e:	ce650513          	addi	a0,a0,-794 # ffffffffc0207250 <commands+0x9d0>
ffffffffc0202572:	c97fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202576 <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0202576:	000ac797          	auipc	a5,0xac
ffffffffc020257a:	29278793          	addi	a5,a5,658 # ffffffffc02ae808 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc020257e:	f51c                	sd	a5,40(a0)
ffffffffc0202580:	e79c                	sd	a5,8(a5)
ffffffffc0202582:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0202584:	4501                	li	a0,0
ffffffffc0202586:	8082                	ret

ffffffffc0202588 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0202588:	4501                	li	a0,0
ffffffffc020258a:	8082                	ret

ffffffffc020258c <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc020258c:	4501                	li	a0,0
ffffffffc020258e:	8082                	ret

ffffffffc0202590 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0202590:	4501                	li	a0,0
ffffffffc0202592:	8082                	ret

ffffffffc0202594 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0202594:	711d                	addi	sp,sp,-96
ffffffffc0202596:	fc4e                	sd	s3,56(sp)
ffffffffc0202598:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc020259a:	00005517          	auipc	a0,0x5
ffffffffc020259e:	26650513          	addi	a0,a0,614 # ffffffffc0207800 <commands+0xf80>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02025a2:	698d                	lui	s3,0x3
ffffffffc02025a4:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc02025a6:	e0ca                	sd	s2,64(sp)
ffffffffc02025a8:	ec86                	sd	ra,88(sp)
ffffffffc02025aa:	e8a2                	sd	s0,80(sp)
ffffffffc02025ac:	e4a6                	sd	s1,72(sp)
ffffffffc02025ae:	f456                	sd	s5,40(sp)
ffffffffc02025b0:	f05a                	sd	s6,32(sp)
ffffffffc02025b2:	ec5e                	sd	s7,24(sp)
ffffffffc02025b4:	e862                	sd	s8,16(sp)
ffffffffc02025b6:	e466                	sd	s9,8(sp)
ffffffffc02025b8:	e06a                	sd	s10,0(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02025ba:	b13fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02025be:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x6bb8>
    assert(pgfault_num==4);
ffffffffc02025c2:	000b0917          	auipc	s2,0xb0
ffffffffc02025c6:	29e92903          	lw	s2,670(s2) # ffffffffc02b2860 <pgfault_num>
ffffffffc02025ca:	4791                	li	a5,4
ffffffffc02025cc:	14f91e63          	bne	s2,a5,ffffffffc0202728 <_fifo_check_swap+0x194>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02025d0:	00005517          	auipc	a0,0x5
ffffffffc02025d4:	27050513          	addi	a0,a0,624 # ffffffffc0207840 <commands+0xfc0>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02025d8:	6a85                	lui	s5,0x1
ffffffffc02025da:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02025dc:	af1fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc02025e0:	000b0417          	auipc	s0,0xb0
ffffffffc02025e4:	28040413          	addi	s0,s0,640 # ffffffffc02b2860 <pgfault_num>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02025e8:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8bb8>
    assert(pgfault_num==4);
ffffffffc02025ec:	4004                	lw	s1,0(s0)
ffffffffc02025ee:	2481                	sext.w	s1,s1
ffffffffc02025f0:	2b249c63          	bne	s1,s2,ffffffffc02028a8 <_fifo_check_swap+0x314>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02025f4:	00005517          	auipc	a0,0x5
ffffffffc02025f8:	27450513          	addi	a0,a0,628 # ffffffffc0207868 <commands+0xfe8>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02025fc:	6b91                	lui	s7,0x4
ffffffffc02025fe:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0202600:	acdfd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202604:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x5bb8>
    assert(pgfault_num==4);
ffffffffc0202608:	00042903          	lw	s2,0(s0)
ffffffffc020260c:	2901                	sext.w	s2,s2
ffffffffc020260e:	26991d63          	bne	s2,s1,ffffffffc0202888 <_fifo_check_swap+0x2f4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0202612:	00005517          	auipc	a0,0x5
ffffffffc0202616:	27e50513          	addi	a0,a0,638 # ffffffffc0207890 <commands+0x1010>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020261a:	6c89                	lui	s9,0x2
ffffffffc020261c:	4d2d                	li	s10,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc020261e:	aaffd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202622:	01ac8023          	sb	s10,0(s9) # 2000 <_binary_obj___user_faultread_out_size-0x7bb8>
    assert(pgfault_num==4);
ffffffffc0202626:	401c                	lw	a5,0(s0)
ffffffffc0202628:	2781                	sext.w	a5,a5
ffffffffc020262a:	23279f63          	bne	a5,s2,ffffffffc0202868 <_fifo_check_swap+0x2d4>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc020262e:	00005517          	auipc	a0,0x5
ffffffffc0202632:	28a50513          	addi	a0,a0,650 # ffffffffc02078b8 <commands+0x1038>
ffffffffc0202636:	a97fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc020263a:	6795                	lui	a5,0x5
ffffffffc020263c:	4739                	li	a4,14
ffffffffc020263e:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4bb8>
    assert(pgfault_num==5);
ffffffffc0202642:	4004                	lw	s1,0(s0)
ffffffffc0202644:	4795                	li	a5,5
ffffffffc0202646:	2481                	sext.w	s1,s1
ffffffffc0202648:	20f49063          	bne	s1,a5,ffffffffc0202848 <_fifo_check_swap+0x2b4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc020264c:	00005517          	auipc	a0,0x5
ffffffffc0202650:	24450513          	addi	a0,a0,580 # ffffffffc0207890 <commands+0x1010>
ffffffffc0202654:	a79fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202658:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==5);
ffffffffc020265c:	401c                	lw	a5,0(s0)
ffffffffc020265e:	2781                	sext.w	a5,a5
ffffffffc0202660:	1c979463          	bne	a5,s1,ffffffffc0202828 <_fifo_check_swap+0x294>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0202664:	00005517          	auipc	a0,0x5
ffffffffc0202668:	1dc50513          	addi	a0,a0,476 # ffffffffc0207840 <commands+0xfc0>
ffffffffc020266c:	a61fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202670:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0202674:	401c                	lw	a5,0(s0)
ffffffffc0202676:	4719                	li	a4,6
ffffffffc0202678:	2781                	sext.w	a5,a5
ffffffffc020267a:	18e79763          	bne	a5,a4,ffffffffc0202808 <_fifo_check_swap+0x274>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc020267e:	00005517          	auipc	a0,0x5
ffffffffc0202682:	21250513          	addi	a0,a0,530 # ffffffffc0207890 <commands+0x1010>
ffffffffc0202686:	a47fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020268a:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==7);
ffffffffc020268e:	401c                	lw	a5,0(s0)
ffffffffc0202690:	471d                	li	a4,7
ffffffffc0202692:	2781                	sext.w	a5,a5
ffffffffc0202694:	14e79a63          	bne	a5,a4,ffffffffc02027e8 <_fifo_check_swap+0x254>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0202698:	00005517          	auipc	a0,0x5
ffffffffc020269c:	16850513          	addi	a0,a0,360 # ffffffffc0207800 <commands+0xf80>
ffffffffc02026a0:	a2dfd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02026a4:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc02026a8:	401c                	lw	a5,0(s0)
ffffffffc02026aa:	4721                	li	a4,8
ffffffffc02026ac:	2781                	sext.w	a5,a5
ffffffffc02026ae:	10e79d63          	bne	a5,a4,ffffffffc02027c8 <_fifo_check_swap+0x234>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02026b2:	00005517          	auipc	a0,0x5
ffffffffc02026b6:	1b650513          	addi	a0,a0,438 # ffffffffc0207868 <commands+0xfe8>
ffffffffc02026ba:	a13fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02026be:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc02026c2:	401c                	lw	a5,0(s0)
ffffffffc02026c4:	4725                	li	a4,9
ffffffffc02026c6:	2781                	sext.w	a5,a5
ffffffffc02026c8:	0ee79063          	bne	a5,a4,ffffffffc02027a8 <_fifo_check_swap+0x214>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc02026cc:	00005517          	auipc	a0,0x5
ffffffffc02026d0:	1ec50513          	addi	a0,a0,492 # ffffffffc02078b8 <commands+0x1038>
ffffffffc02026d4:	9f9fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02026d8:	6795                	lui	a5,0x5
ffffffffc02026da:	4739                	li	a4,14
ffffffffc02026dc:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4bb8>
    assert(pgfault_num==10);
ffffffffc02026e0:	4004                	lw	s1,0(s0)
ffffffffc02026e2:	47a9                	li	a5,10
ffffffffc02026e4:	2481                	sext.w	s1,s1
ffffffffc02026e6:	0af49163          	bne	s1,a5,ffffffffc0202788 <_fifo_check_swap+0x1f4>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02026ea:	00005517          	auipc	a0,0x5
ffffffffc02026ee:	15650513          	addi	a0,a0,342 # ffffffffc0207840 <commands+0xfc0>
ffffffffc02026f2:	9dbfd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02026f6:	6785                	lui	a5,0x1
ffffffffc02026f8:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8bb8>
ffffffffc02026fc:	06979663          	bne	a5,s1,ffffffffc0202768 <_fifo_check_swap+0x1d4>
    assert(pgfault_num==11);
ffffffffc0202700:	401c                	lw	a5,0(s0)
ffffffffc0202702:	472d                	li	a4,11
ffffffffc0202704:	2781                	sext.w	a5,a5
ffffffffc0202706:	04e79163          	bne	a5,a4,ffffffffc0202748 <_fifo_check_swap+0x1b4>
}
ffffffffc020270a:	60e6                	ld	ra,88(sp)
ffffffffc020270c:	6446                	ld	s0,80(sp)
ffffffffc020270e:	64a6                	ld	s1,72(sp)
ffffffffc0202710:	6906                	ld	s2,64(sp)
ffffffffc0202712:	79e2                	ld	s3,56(sp)
ffffffffc0202714:	7a42                	ld	s4,48(sp)
ffffffffc0202716:	7aa2                	ld	s5,40(sp)
ffffffffc0202718:	7b02                	ld	s6,32(sp)
ffffffffc020271a:	6be2                	ld	s7,24(sp)
ffffffffc020271c:	6c42                	ld	s8,16(sp)
ffffffffc020271e:	6ca2                	ld	s9,8(sp)
ffffffffc0202720:	6d02                	ld	s10,0(sp)
ffffffffc0202722:	4501                	li	a0,0
ffffffffc0202724:	6125                	addi	sp,sp,96
ffffffffc0202726:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0202728:	00005697          	auipc	a3,0x5
ffffffffc020272c:	e5868693          	addi	a3,a3,-424 # ffffffffc0207580 <commands+0xd00>
ffffffffc0202730:	00004617          	auipc	a2,0x4
ffffffffc0202734:	56060613          	addi	a2,a2,1376 # ffffffffc0206c90 <commands+0x410>
ffffffffc0202738:	05100593          	li	a1,81
ffffffffc020273c:	00005517          	auipc	a0,0x5
ffffffffc0202740:	0ec50513          	addi	a0,a0,236 # ffffffffc0207828 <commands+0xfa8>
ffffffffc0202744:	ac5fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==11);
ffffffffc0202748:	00005697          	auipc	a3,0x5
ffffffffc020274c:	22068693          	addi	a3,a3,544 # ffffffffc0207968 <commands+0x10e8>
ffffffffc0202750:	00004617          	auipc	a2,0x4
ffffffffc0202754:	54060613          	addi	a2,a2,1344 # ffffffffc0206c90 <commands+0x410>
ffffffffc0202758:	07300593          	li	a1,115
ffffffffc020275c:	00005517          	auipc	a0,0x5
ffffffffc0202760:	0cc50513          	addi	a0,a0,204 # ffffffffc0207828 <commands+0xfa8>
ffffffffc0202764:	aa5fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0202768:	00005697          	auipc	a3,0x5
ffffffffc020276c:	1d868693          	addi	a3,a3,472 # ffffffffc0207940 <commands+0x10c0>
ffffffffc0202770:	00004617          	auipc	a2,0x4
ffffffffc0202774:	52060613          	addi	a2,a2,1312 # ffffffffc0206c90 <commands+0x410>
ffffffffc0202778:	07100593          	li	a1,113
ffffffffc020277c:	00005517          	auipc	a0,0x5
ffffffffc0202780:	0ac50513          	addi	a0,a0,172 # ffffffffc0207828 <commands+0xfa8>
ffffffffc0202784:	a85fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==10);
ffffffffc0202788:	00005697          	auipc	a3,0x5
ffffffffc020278c:	1a868693          	addi	a3,a3,424 # ffffffffc0207930 <commands+0x10b0>
ffffffffc0202790:	00004617          	auipc	a2,0x4
ffffffffc0202794:	50060613          	addi	a2,a2,1280 # ffffffffc0206c90 <commands+0x410>
ffffffffc0202798:	06f00593          	li	a1,111
ffffffffc020279c:	00005517          	auipc	a0,0x5
ffffffffc02027a0:	08c50513          	addi	a0,a0,140 # ffffffffc0207828 <commands+0xfa8>
ffffffffc02027a4:	a65fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==9);
ffffffffc02027a8:	00005697          	auipc	a3,0x5
ffffffffc02027ac:	17868693          	addi	a3,a3,376 # ffffffffc0207920 <commands+0x10a0>
ffffffffc02027b0:	00004617          	auipc	a2,0x4
ffffffffc02027b4:	4e060613          	addi	a2,a2,1248 # ffffffffc0206c90 <commands+0x410>
ffffffffc02027b8:	06c00593          	li	a1,108
ffffffffc02027bc:	00005517          	auipc	a0,0x5
ffffffffc02027c0:	06c50513          	addi	a0,a0,108 # ffffffffc0207828 <commands+0xfa8>
ffffffffc02027c4:	a45fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==8);
ffffffffc02027c8:	00005697          	auipc	a3,0x5
ffffffffc02027cc:	14868693          	addi	a3,a3,328 # ffffffffc0207910 <commands+0x1090>
ffffffffc02027d0:	00004617          	auipc	a2,0x4
ffffffffc02027d4:	4c060613          	addi	a2,a2,1216 # ffffffffc0206c90 <commands+0x410>
ffffffffc02027d8:	06900593          	li	a1,105
ffffffffc02027dc:	00005517          	auipc	a0,0x5
ffffffffc02027e0:	04c50513          	addi	a0,a0,76 # ffffffffc0207828 <commands+0xfa8>
ffffffffc02027e4:	a25fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==7);
ffffffffc02027e8:	00005697          	auipc	a3,0x5
ffffffffc02027ec:	11868693          	addi	a3,a3,280 # ffffffffc0207900 <commands+0x1080>
ffffffffc02027f0:	00004617          	auipc	a2,0x4
ffffffffc02027f4:	4a060613          	addi	a2,a2,1184 # ffffffffc0206c90 <commands+0x410>
ffffffffc02027f8:	06600593          	li	a1,102
ffffffffc02027fc:	00005517          	auipc	a0,0x5
ffffffffc0202800:	02c50513          	addi	a0,a0,44 # ffffffffc0207828 <commands+0xfa8>
ffffffffc0202804:	a05fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==6);
ffffffffc0202808:	00005697          	auipc	a3,0x5
ffffffffc020280c:	0e868693          	addi	a3,a3,232 # ffffffffc02078f0 <commands+0x1070>
ffffffffc0202810:	00004617          	auipc	a2,0x4
ffffffffc0202814:	48060613          	addi	a2,a2,1152 # ffffffffc0206c90 <commands+0x410>
ffffffffc0202818:	06300593          	li	a1,99
ffffffffc020281c:	00005517          	auipc	a0,0x5
ffffffffc0202820:	00c50513          	addi	a0,a0,12 # ffffffffc0207828 <commands+0xfa8>
ffffffffc0202824:	9e5fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==5);
ffffffffc0202828:	00005697          	auipc	a3,0x5
ffffffffc020282c:	0b868693          	addi	a3,a3,184 # ffffffffc02078e0 <commands+0x1060>
ffffffffc0202830:	00004617          	auipc	a2,0x4
ffffffffc0202834:	46060613          	addi	a2,a2,1120 # ffffffffc0206c90 <commands+0x410>
ffffffffc0202838:	06000593          	li	a1,96
ffffffffc020283c:	00005517          	auipc	a0,0x5
ffffffffc0202840:	fec50513          	addi	a0,a0,-20 # ffffffffc0207828 <commands+0xfa8>
ffffffffc0202844:	9c5fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==5);
ffffffffc0202848:	00005697          	auipc	a3,0x5
ffffffffc020284c:	09868693          	addi	a3,a3,152 # ffffffffc02078e0 <commands+0x1060>
ffffffffc0202850:	00004617          	auipc	a2,0x4
ffffffffc0202854:	44060613          	addi	a2,a2,1088 # ffffffffc0206c90 <commands+0x410>
ffffffffc0202858:	05d00593          	li	a1,93
ffffffffc020285c:	00005517          	auipc	a0,0x5
ffffffffc0202860:	fcc50513          	addi	a0,a0,-52 # ffffffffc0207828 <commands+0xfa8>
ffffffffc0202864:	9a5fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==4);
ffffffffc0202868:	00005697          	auipc	a3,0x5
ffffffffc020286c:	d1868693          	addi	a3,a3,-744 # ffffffffc0207580 <commands+0xd00>
ffffffffc0202870:	00004617          	auipc	a2,0x4
ffffffffc0202874:	42060613          	addi	a2,a2,1056 # ffffffffc0206c90 <commands+0x410>
ffffffffc0202878:	05a00593          	li	a1,90
ffffffffc020287c:	00005517          	auipc	a0,0x5
ffffffffc0202880:	fac50513          	addi	a0,a0,-84 # ffffffffc0207828 <commands+0xfa8>
ffffffffc0202884:	985fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==4);
ffffffffc0202888:	00005697          	auipc	a3,0x5
ffffffffc020288c:	cf868693          	addi	a3,a3,-776 # ffffffffc0207580 <commands+0xd00>
ffffffffc0202890:	00004617          	auipc	a2,0x4
ffffffffc0202894:	40060613          	addi	a2,a2,1024 # ffffffffc0206c90 <commands+0x410>
ffffffffc0202898:	05700593          	li	a1,87
ffffffffc020289c:	00005517          	auipc	a0,0x5
ffffffffc02028a0:	f8c50513          	addi	a0,a0,-116 # ffffffffc0207828 <commands+0xfa8>
ffffffffc02028a4:	965fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==4);
ffffffffc02028a8:	00005697          	auipc	a3,0x5
ffffffffc02028ac:	cd868693          	addi	a3,a3,-808 # ffffffffc0207580 <commands+0xd00>
ffffffffc02028b0:	00004617          	auipc	a2,0x4
ffffffffc02028b4:	3e060613          	addi	a2,a2,992 # ffffffffc0206c90 <commands+0x410>
ffffffffc02028b8:	05400593          	li	a1,84
ffffffffc02028bc:	00005517          	auipc	a0,0x5
ffffffffc02028c0:	f6c50513          	addi	a0,a0,-148 # ffffffffc0207828 <commands+0xfa8>
ffffffffc02028c4:	945fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02028c8 <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02028c8:	751c                	ld	a5,40(a0)
{
ffffffffc02028ca:	1141                	addi	sp,sp,-16
ffffffffc02028cc:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc02028ce:	cf91                	beqz	a5,ffffffffc02028ea <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc02028d0:	ee0d                	bnez	a2,ffffffffc020290a <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc02028d2:	679c                	ld	a5,8(a5)
}
ffffffffc02028d4:	60a2                	ld	ra,8(sp)
ffffffffc02028d6:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc02028d8:	6394                	ld	a3,0(a5)
ffffffffc02028da:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc02028dc:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc02028e0:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc02028e2:	e314                	sd	a3,0(a4)
ffffffffc02028e4:	e19c                	sd	a5,0(a1)
}
ffffffffc02028e6:	0141                	addi	sp,sp,16
ffffffffc02028e8:	8082                	ret
         assert(head != NULL);
ffffffffc02028ea:	00005697          	auipc	a3,0x5
ffffffffc02028ee:	08e68693          	addi	a3,a3,142 # ffffffffc0207978 <commands+0x10f8>
ffffffffc02028f2:	00004617          	auipc	a2,0x4
ffffffffc02028f6:	39e60613          	addi	a2,a2,926 # ffffffffc0206c90 <commands+0x410>
ffffffffc02028fa:	04100593          	li	a1,65
ffffffffc02028fe:	00005517          	auipc	a0,0x5
ffffffffc0202902:	f2a50513          	addi	a0,a0,-214 # ffffffffc0207828 <commands+0xfa8>
ffffffffc0202906:	903fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(in_tick==0);
ffffffffc020290a:	00005697          	auipc	a3,0x5
ffffffffc020290e:	07e68693          	addi	a3,a3,126 # ffffffffc0207988 <commands+0x1108>
ffffffffc0202912:	00004617          	auipc	a2,0x4
ffffffffc0202916:	37e60613          	addi	a2,a2,894 # ffffffffc0206c90 <commands+0x410>
ffffffffc020291a:	04200593          	li	a1,66
ffffffffc020291e:	00005517          	auipc	a0,0x5
ffffffffc0202922:	f0a50513          	addi	a0,a0,-246 # ffffffffc0207828 <commands+0xfa8>
ffffffffc0202926:	8e3fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020292a <_fifo_map_swappable>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc020292a:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc020292c:	cb91                	beqz	a5,ffffffffc0202940 <_fifo_map_swappable+0x16>
    __list_add(elm, listelm->prev, listelm);
ffffffffc020292e:	6394                	ld	a3,0(a5)
ffffffffc0202930:	02860713          	addi	a4,a2,40
    prev->next = next->prev = elm;
ffffffffc0202934:	e398                	sd	a4,0(a5)
ffffffffc0202936:	e698                	sd	a4,8(a3)
}
ffffffffc0202938:	4501                	li	a0,0
    elm->next = next;
ffffffffc020293a:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc020293c:	f614                	sd	a3,40(a2)
ffffffffc020293e:	8082                	ret
{
ffffffffc0202940:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0202942:	00005697          	auipc	a3,0x5
ffffffffc0202946:	05668693          	addi	a3,a3,86 # ffffffffc0207998 <commands+0x1118>
ffffffffc020294a:	00004617          	auipc	a2,0x4
ffffffffc020294e:	34660613          	addi	a2,a2,838 # ffffffffc0206c90 <commands+0x410>
ffffffffc0202952:	03200593          	li	a1,50
ffffffffc0202956:	00005517          	auipc	a0,0x5
ffffffffc020295a:	ed250513          	addi	a0,a0,-302 # ffffffffc0207828 <commands+0xfa8>
{
ffffffffc020295e:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0202960:	8a9fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202964 <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0202964:	000ac797          	auipc	a5,0xac
ffffffffc0202968:	eb478793          	addi	a5,a5,-332 # ffffffffc02ae818 <free_area>
ffffffffc020296c:	e79c                	sd	a5,8(a5)
ffffffffc020296e:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0202970:	0007a823          	sw	zero,16(a5)
}
ffffffffc0202974:	8082                	ret

ffffffffc0202976 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0202976:	000ac517          	auipc	a0,0xac
ffffffffc020297a:	eb256503          	lwu	a0,-334(a0) # ffffffffc02ae828 <free_area+0x10>
ffffffffc020297e:	8082                	ret

ffffffffc0202980 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0202980:	715d                	addi	sp,sp,-80
ffffffffc0202982:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc0202984:	000ac417          	auipc	s0,0xac
ffffffffc0202988:	e9440413          	addi	s0,s0,-364 # ffffffffc02ae818 <free_area>
ffffffffc020298c:	641c                	ld	a5,8(s0)
ffffffffc020298e:	e486                	sd	ra,72(sp)
ffffffffc0202990:	fc26                	sd	s1,56(sp)
ffffffffc0202992:	f84a                	sd	s2,48(sp)
ffffffffc0202994:	f44e                	sd	s3,40(sp)
ffffffffc0202996:	f052                	sd	s4,32(sp)
ffffffffc0202998:	ec56                	sd	s5,24(sp)
ffffffffc020299a:	e85a                	sd	s6,16(sp)
ffffffffc020299c:	e45e                	sd	s7,8(sp)
ffffffffc020299e:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02029a0:	2a878d63          	beq	a5,s0,ffffffffc0202c5a <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc02029a4:	4481                	li	s1,0
ffffffffc02029a6:	4901                	li	s2,0
ffffffffc02029a8:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02029ac:	8b09                	andi	a4,a4,2
ffffffffc02029ae:	2a070a63          	beqz	a4,ffffffffc0202c62 <default_check+0x2e2>
        count ++, total += p->property;
ffffffffc02029b2:	ff87a703          	lw	a4,-8(a5)
ffffffffc02029b6:	679c                	ld	a5,8(a5)
ffffffffc02029b8:	2905                	addiw	s2,s2,1
ffffffffc02029ba:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02029bc:	fe8796e3          	bne	a5,s0,ffffffffc02029a8 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc02029c0:	89a6                	mv	s3,s1
ffffffffc02029c2:	35b000ef          	jal	ra,ffffffffc020351c <nr_free_pages>
ffffffffc02029c6:	6f351e63          	bne	a0,s3,ffffffffc02030c2 <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02029ca:	4505                	li	a0,1
ffffffffc02029cc:	27f000ef          	jal	ra,ffffffffc020344a <alloc_pages>
ffffffffc02029d0:	8aaa                	mv	s5,a0
ffffffffc02029d2:	42050863          	beqz	a0,ffffffffc0202e02 <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02029d6:	4505                	li	a0,1
ffffffffc02029d8:	273000ef          	jal	ra,ffffffffc020344a <alloc_pages>
ffffffffc02029dc:	89aa                	mv	s3,a0
ffffffffc02029de:	70050263          	beqz	a0,ffffffffc02030e2 <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02029e2:	4505                	li	a0,1
ffffffffc02029e4:	267000ef          	jal	ra,ffffffffc020344a <alloc_pages>
ffffffffc02029e8:	8a2a                	mv	s4,a0
ffffffffc02029ea:	48050c63          	beqz	a0,ffffffffc0202e82 <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02029ee:	293a8a63          	beq	s5,s3,ffffffffc0202c82 <default_check+0x302>
ffffffffc02029f2:	28aa8863          	beq	s5,a0,ffffffffc0202c82 <default_check+0x302>
ffffffffc02029f6:	28a98663          	beq	s3,a0,ffffffffc0202c82 <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02029fa:	000aa783          	lw	a5,0(s5)
ffffffffc02029fe:	2a079263          	bnez	a5,ffffffffc0202ca2 <default_check+0x322>
ffffffffc0202a02:	0009a783          	lw	a5,0(s3)
ffffffffc0202a06:	28079e63          	bnez	a5,ffffffffc0202ca2 <default_check+0x322>
ffffffffc0202a0a:	411c                	lw	a5,0(a0)
ffffffffc0202a0c:	28079b63          	bnez	a5,ffffffffc0202ca2 <default_check+0x322>
    return page - pages + nbase;
ffffffffc0202a10:	000b0797          	auipc	a5,0xb0
ffffffffc0202a14:	e907b783          	ld	a5,-368(a5) # ffffffffc02b28a0 <pages>
ffffffffc0202a18:	40fa8733          	sub	a4,s5,a5
ffffffffc0202a1c:	00006617          	auipc	a2,0x6
ffffffffc0202a20:	29463603          	ld	a2,660(a2) # ffffffffc0208cb0 <nbase>
ffffffffc0202a24:	8719                	srai	a4,a4,0x6
ffffffffc0202a26:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0202a28:	000b0697          	auipc	a3,0xb0
ffffffffc0202a2c:	e706b683          	ld	a3,-400(a3) # ffffffffc02b2898 <npage>
ffffffffc0202a30:	06b2                	slli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202a32:	0732                	slli	a4,a4,0xc
ffffffffc0202a34:	28d77763          	bgeu	a4,a3,ffffffffc0202cc2 <default_check+0x342>
    return page - pages + nbase;
ffffffffc0202a38:	40f98733          	sub	a4,s3,a5
ffffffffc0202a3c:	8719                	srai	a4,a4,0x6
ffffffffc0202a3e:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202a40:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0202a42:	4cd77063          	bgeu	a4,a3,ffffffffc0202f02 <default_check+0x582>
    return page - pages + nbase;
ffffffffc0202a46:	40f507b3          	sub	a5,a0,a5
ffffffffc0202a4a:	8799                	srai	a5,a5,0x6
ffffffffc0202a4c:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202a4e:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0202a50:	30d7f963          	bgeu	a5,a3,ffffffffc0202d62 <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc0202a54:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202a56:	00043c03          	ld	s8,0(s0)
ffffffffc0202a5a:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0202a5e:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0202a62:	e400                	sd	s0,8(s0)
ffffffffc0202a64:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0202a66:	000ac797          	auipc	a5,0xac
ffffffffc0202a6a:	dc07a123          	sw	zero,-574(a5) # ffffffffc02ae828 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0202a6e:	1dd000ef          	jal	ra,ffffffffc020344a <alloc_pages>
ffffffffc0202a72:	2c051863          	bnez	a0,ffffffffc0202d42 <default_check+0x3c2>
    free_page(p0);
ffffffffc0202a76:	4585                	li	a1,1
ffffffffc0202a78:	8556                	mv	a0,s5
ffffffffc0202a7a:	263000ef          	jal	ra,ffffffffc02034dc <free_pages>
    free_page(p1);
ffffffffc0202a7e:	4585                	li	a1,1
ffffffffc0202a80:	854e                	mv	a0,s3
ffffffffc0202a82:	25b000ef          	jal	ra,ffffffffc02034dc <free_pages>
    free_page(p2);
ffffffffc0202a86:	4585                	li	a1,1
ffffffffc0202a88:	8552                	mv	a0,s4
ffffffffc0202a8a:	253000ef          	jal	ra,ffffffffc02034dc <free_pages>
    assert(nr_free == 3);
ffffffffc0202a8e:	4818                	lw	a4,16(s0)
ffffffffc0202a90:	478d                	li	a5,3
ffffffffc0202a92:	28f71863          	bne	a4,a5,ffffffffc0202d22 <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202a96:	4505                	li	a0,1
ffffffffc0202a98:	1b3000ef          	jal	ra,ffffffffc020344a <alloc_pages>
ffffffffc0202a9c:	89aa                	mv	s3,a0
ffffffffc0202a9e:	26050263          	beqz	a0,ffffffffc0202d02 <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202aa2:	4505                	li	a0,1
ffffffffc0202aa4:	1a7000ef          	jal	ra,ffffffffc020344a <alloc_pages>
ffffffffc0202aa8:	8aaa                	mv	s5,a0
ffffffffc0202aaa:	3a050c63          	beqz	a0,ffffffffc0202e62 <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202aae:	4505                	li	a0,1
ffffffffc0202ab0:	19b000ef          	jal	ra,ffffffffc020344a <alloc_pages>
ffffffffc0202ab4:	8a2a                	mv	s4,a0
ffffffffc0202ab6:	38050663          	beqz	a0,ffffffffc0202e42 <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc0202aba:	4505                	li	a0,1
ffffffffc0202abc:	18f000ef          	jal	ra,ffffffffc020344a <alloc_pages>
ffffffffc0202ac0:	36051163          	bnez	a0,ffffffffc0202e22 <default_check+0x4a2>
    free_page(p0);
ffffffffc0202ac4:	4585                	li	a1,1
ffffffffc0202ac6:	854e                	mv	a0,s3
ffffffffc0202ac8:	215000ef          	jal	ra,ffffffffc02034dc <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0202acc:	641c                	ld	a5,8(s0)
ffffffffc0202ace:	20878a63          	beq	a5,s0,ffffffffc0202ce2 <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc0202ad2:	4505                	li	a0,1
ffffffffc0202ad4:	177000ef          	jal	ra,ffffffffc020344a <alloc_pages>
ffffffffc0202ad8:	30a99563          	bne	s3,a0,ffffffffc0202de2 <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc0202adc:	4505                	li	a0,1
ffffffffc0202ade:	16d000ef          	jal	ra,ffffffffc020344a <alloc_pages>
ffffffffc0202ae2:	2e051063          	bnez	a0,ffffffffc0202dc2 <default_check+0x442>
    assert(nr_free == 0);
ffffffffc0202ae6:	481c                	lw	a5,16(s0)
ffffffffc0202ae8:	2a079d63          	bnez	a5,ffffffffc0202da2 <default_check+0x422>
    free_page(p);
ffffffffc0202aec:	854e                	mv	a0,s3
ffffffffc0202aee:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0202af0:	01843023          	sd	s8,0(s0)
ffffffffc0202af4:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0202af8:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0202afc:	1e1000ef          	jal	ra,ffffffffc02034dc <free_pages>
    free_page(p1);
ffffffffc0202b00:	4585                	li	a1,1
ffffffffc0202b02:	8556                	mv	a0,s5
ffffffffc0202b04:	1d9000ef          	jal	ra,ffffffffc02034dc <free_pages>
    free_page(p2);
ffffffffc0202b08:	4585                	li	a1,1
ffffffffc0202b0a:	8552                	mv	a0,s4
ffffffffc0202b0c:	1d1000ef          	jal	ra,ffffffffc02034dc <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0202b10:	4515                	li	a0,5
ffffffffc0202b12:	139000ef          	jal	ra,ffffffffc020344a <alloc_pages>
ffffffffc0202b16:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0202b18:	26050563          	beqz	a0,ffffffffc0202d82 <default_check+0x402>
ffffffffc0202b1c:	651c                	ld	a5,8(a0)
ffffffffc0202b1e:	8385                	srli	a5,a5,0x1
ffffffffc0202b20:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc0202b22:	54079063          	bnez	a5,ffffffffc0203062 <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0202b26:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202b28:	00043b03          	ld	s6,0(s0)
ffffffffc0202b2c:	00843a83          	ld	s5,8(s0)
ffffffffc0202b30:	e000                	sd	s0,0(s0)
ffffffffc0202b32:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0202b34:	117000ef          	jal	ra,ffffffffc020344a <alloc_pages>
ffffffffc0202b38:	50051563          	bnez	a0,ffffffffc0203042 <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0202b3c:	08098a13          	addi	s4,s3,128
ffffffffc0202b40:	8552                	mv	a0,s4
ffffffffc0202b42:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0202b44:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0202b48:	000ac797          	auipc	a5,0xac
ffffffffc0202b4c:	ce07a023          	sw	zero,-800(a5) # ffffffffc02ae828 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0202b50:	18d000ef          	jal	ra,ffffffffc02034dc <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0202b54:	4511                	li	a0,4
ffffffffc0202b56:	0f5000ef          	jal	ra,ffffffffc020344a <alloc_pages>
ffffffffc0202b5a:	4c051463          	bnez	a0,ffffffffc0203022 <default_check+0x6a2>
ffffffffc0202b5e:	0889b783          	ld	a5,136(s3)
ffffffffc0202b62:	8385                	srli	a5,a5,0x1
ffffffffc0202b64:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0202b66:	48078e63          	beqz	a5,ffffffffc0203002 <default_check+0x682>
ffffffffc0202b6a:	0909a703          	lw	a4,144(s3)
ffffffffc0202b6e:	478d                	li	a5,3
ffffffffc0202b70:	48f71963          	bne	a4,a5,ffffffffc0203002 <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0202b74:	450d                	li	a0,3
ffffffffc0202b76:	0d5000ef          	jal	ra,ffffffffc020344a <alloc_pages>
ffffffffc0202b7a:	8c2a                	mv	s8,a0
ffffffffc0202b7c:	46050363          	beqz	a0,ffffffffc0202fe2 <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc0202b80:	4505                	li	a0,1
ffffffffc0202b82:	0c9000ef          	jal	ra,ffffffffc020344a <alloc_pages>
ffffffffc0202b86:	42051e63          	bnez	a0,ffffffffc0202fc2 <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc0202b8a:	418a1c63          	bne	s4,s8,ffffffffc0202fa2 <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0202b8e:	4585                	li	a1,1
ffffffffc0202b90:	854e                	mv	a0,s3
ffffffffc0202b92:	14b000ef          	jal	ra,ffffffffc02034dc <free_pages>
    free_pages(p1, 3);
ffffffffc0202b96:	458d                	li	a1,3
ffffffffc0202b98:	8552                	mv	a0,s4
ffffffffc0202b9a:	143000ef          	jal	ra,ffffffffc02034dc <free_pages>
ffffffffc0202b9e:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0202ba2:	04098c13          	addi	s8,s3,64
ffffffffc0202ba6:	8385                	srli	a5,a5,0x1
ffffffffc0202ba8:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0202baa:	3c078c63          	beqz	a5,ffffffffc0202f82 <default_check+0x602>
ffffffffc0202bae:	0109a703          	lw	a4,16(s3)
ffffffffc0202bb2:	4785                	li	a5,1
ffffffffc0202bb4:	3cf71763          	bne	a4,a5,ffffffffc0202f82 <default_check+0x602>
ffffffffc0202bb8:	008a3783          	ld	a5,8(s4)
ffffffffc0202bbc:	8385                	srli	a5,a5,0x1
ffffffffc0202bbe:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0202bc0:	3a078163          	beqz	a5,ffffffffc0202f62 <default_check+0x5e2>
ffffffffc0202bc4:	010a2703          	lw	a4,16(s4)
ffffffffc0202bc8:	478d                	li	a5,3
ffffffffc0202bca:	38f71c63          	bne	a4,a5,ffffffffc0202f62 <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0202bce:	4505                	li	a0,1
ffffffffc0202bd0:	07b000ef          	jal	ra,ffffffffc020344a <alloc_pages>
ffffffffc0202bd4:	36a99763          	bne	s3,a0,ffffffffc0202f42 <default_check+0x5c2>
    free_page(p0);
ffffffffc0202bd8:	4585                	li	a1,1
ffffffffc0202bda:	103000ef          	jal	ra,ffffffffc02034dc <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202bde:	4509                	li	a0,2
ffffffffc0202be0:	06b000ef          	jal	ra,ffffffffc020344a <alloc_pages>
ffffffffc0202be4:	32aa1f63          	bne	s4,a0,ffffffffc0202f22 <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc0202be8:	4589                	li	a1,2
ffffffffc0202bea:	0f3000ef          	jal	ra,ffffffffc02034dc <free_pages>
    free_page(p2);
ffffffffc0202bee:	4585                	li	a1,1
ffffffffc0202bf0:	8562                	mv	a0,s8
ffffffffc0202bf2:	0eb000ef          	jal	ra,ffffffffc02034dc <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0202bf6:	4515                	li	a0,5
ffffffffc0202bf8:	053000ef          	jal	ra,ffffffffc020344a <alloc_pages>
ffffffffc0202bfc:	89aa                	mv	s3,a0
ffffffffc0202bfe:	48050263          	beqz	a0,ffffffffc0203082 <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc0202c02:	4505                	li	a0,1
ffffffffc0202c04:	047000ef          	jal	ra,ffffffffc020344a <alloc_pages>
ffffffffc0202c08:	2c051d63          	bnez	a0,ffffffffc0202ee2 <default_check+0x562>

    assert(nr_free == 0);
ffffffffc0202c0c:	481c                	lw	a5,16(s0)
ffffffffc0202c0e:	2a079a63          	bnez	a5,ffffffffc0202ec2 <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0202c12:	4595                	li	a1,5
ffffffffc0202c14:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0202c16:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0202c1a:	01643023          	sd	s6,0(s0)
ffffffffc0202c1e:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0202c22:	0bb000ef          	jal	ra,ffffffffc02034dc <free_pages>
    return listelm->next;
ffffffffc0202c26:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202c28:	00878963          	beq	a5,s0,ffffffffc0202c3a <default_check+0x2ba>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0202c2c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202c30:	679c                	ld	a5,8(a5)
ffffffffc0202c32:	397d                	addiw	s2,s2,-1
ffffffffc0202c34:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202c36:	fe879be3          	bne	a5,s0,ffffffffc0202c2c <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc0202c3a:	26091463          	bnez	s2,ffffffffc0202ea2 <default_check+0x522>
    assert(total == 0);
ffffffffc0202c3e:	46049263          	bnez	s1,ffffffffc02030a2 <default_check+0x722>
}
ffffffffc0202c42:	60a6                	ld	ra,72(sp)
ffffffffc0202c44:	6406                	ld	s0,64(sp)
ffffffffc0202c46:	74e2                	ld	s1,56(sp)
ffffffffc0202c48:	7942                	ld	s2,48(sp)
ffffffffc0202c4a:	79a2                	ld	s3,40(sp)
ffffffffc0202c4c:	7a02                	ld	s4,32(sp)
ffffffffc0202c4e:	6ae2                	ld	s5,24(sp)
ffffffffc0202c50:	6b42                	ld	s6,16(sp)
ffffffffc0202c52:	6ba2                	ld	s7,8(sp)
ffffffffc0202c54:	6c02                	ld	s8,0(sp)
ffffffffc0202c56:	6161                	addi	sp,sp,80
ffffffffc0202c58:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202c5a:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0202c5c:	4481                	li	s1,0
ffffffffc0202c5e:	4901                	li	s2,0
ffffffffc0202c60:	b38d                	j	ffffffffc02029c2 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0202c62:	00004697          	auipc	a3,0x4
ffffffffc0202c66:	77e68693          	addi	a3,a3,1918 # ffffffffc02073e0 <commands+0xb60>
ffffffffc0202c6a:	00004617          	auipc	a2,0x4
ffffffffc0202c6e:	02660613          	addi	a2,a2,38 # ffffffffc0206c90 <commands+0x410>
ffffffffc0202c72:	0f000593          	li	a1,240
ffffffffc0202c76:	00005517          	auipc	a0,0x5
ffffffffc0202c7a:	d5a50513          	addi	a0,a0,-678 # ffffffffc02079d0 <commands+0x1150>
ffffffffc0202c7e:	d8afd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0202c82:	00005697          	auipc	a3,0x5
ffffffffc0202c86:	dc668693          	addi	a3,a3,-570 # ffffffffc0207a48 <commands+0x11c8>
ffffffffc0202c8a:	00004617          	auipc	a2,0x4
ffffffffc0202c8e:	00660613          	addi	a2,a2,6 # ffffffffc0206c90 <commands+0x410>
ffffffffc0202c92:	0bd00593          	li	a1,189
ffffffffc0202c96:	00005517          	auipc	a0,0x5
ffffffffc0202c9a:	d3a50513          	addi	a0,a0,-710 # ffffffffc02079d0 <commands+0x1150>
ffffffffc0202c9e:	d6afd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0202ca2:	00005697          	auipc	a3,0x5
ffffffffc0202ca6:	dce68693          	addi	a3,a3,-562 # ffffffffc0207a70 <commands+0x11f0>
ffffffffc0202caa:	00004617          	auipc	a2,0x4
ffffffffc0202cae:	fe660613          	addi	a2,a2,-26 # ffffffffc0206c90 <commands+0x410>
ffffffffc0202cb2:	0be00593          	li	a1,190
ffffffffc0202cb6:	00005517          	auipc	a0,0x5
ffffffffc0202cba:	d1a50513          	addi	a0,a0,-742 # ffffffffc02079d0 <commands+0x1150>
ffffffffc0202cbe:	d4afd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0202cc2:	00005697          	auipc	a3,0x5
ffffffffc0202cc6:	dee68693          	addi	a3,a3,-530 # ffffffffc0207ab0 <commands+0x1230>
ffffffffc0202cca:	00004617          	auipc	a2,0x4
ffffffffc0202cce:	fc660613          	addi	a2,a2,-58 # ffffffffc0206c90 <commands+0x410>
ffffffffc0202cd2:	0c000593          	li	a1,192
ffffffffc0202cd6:	00005517          	auipc	a0,0x5
ffffffffc0202cda:	cfa50513          	addi	a0,a0,-774 # ffffffffc02079d0 <commands+0x1150>
ffffffffc0202cde:	d2afd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0202ce2:	00005697          	auipc	a3,0x5
ffffffffc0202ce6:	e5668693          	addi	a3,a3,-426 # ffffffffc0207b38 <commands+0x12b8>
ffffffffc0202cea:	00004617          	auipc	a2,0x4
ffffffffc0202cee:	fa660613          	addi	a2,a2,-90 # ffffffffc0206c90 <commands+0x410>
ffffffffc0202cf2:	0d900593          	li	a1,217
ffffffffc0202cf6:	00005517          	auipc	a0,0x5
ffffffffc0202cfa:	cda50513          	addi	a0,a0,-806 # ffffffffc02079d0 <commands+0x1150>
ffffffffc0202cfe:	d0afd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202d02:	00005697          	auipc	a3,0x5
ffffffffc0202d06:	ce668693          	addi	a3,a3,-794 # ffffffffc02079e8 <commands+0x1168>
ffffffffc0202d0a:	00004617          	auipc	a2,0x4
ffffffffc0202d0e:	f8660613          	addi	a2,a2,-122 # ffffffffc0206c90 <commands+0x410>
ffffffffc0202d12:	0d200593          	li	a1,210
ffffffffc0202d16:	00005517          	auipc	a0,0x5
ffffffffc0202d1a:	cba50513          	addi	a0,a0,-838 # ffffffffc02079d0 <commands+0x1150>
ffffffffc0202d1e:	ceafd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free == 3);
ffffffffc0202d22:	00005697          	auipc	a3,0x5
ffffffffc0202d26:	e0668693          	addi	a3,a3,-506 # ffffffffc0207b28 <commands+0x12a8>
ffffffffc0202d2a:	00004617          	auipc	a2,0x4
ffffffffc0202d2e:	f6660613          	addi	a2,a2,-154 # ffffffffc0206c90 <commands+0x410>
ffffffffc0202d32:	0d000593          	li	a1,208
ffffffffc0202d36:	00005517          	auipc	a0,0x5
ffffffffc0202d3a:	c9a50513          	addi	a0,a0,-870 # ffffffffc02079d0 <commands+0x1150>
ffffffffc0202d3e:	ccafd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202d42:	00005697          	auipc	a3,0x5
ffffffffc0202d46:	dce68693          	addi	a3,a3,-562 # ffffffffc0207b10 <commands+0x1290>
ffffffffc0202d4a:	00004617          	auipc	a2,0x4
ffffffffc0202d4e:	f4660613          	addi	a2,a2,-186 # ffffffffc0206c90 <commands+0x410>
ffffffffc0202d52:	0cb00593          	li	a1,203
ffffffffc0202d56:	00005517          	auipc	a0,0x5
ffffffffc0202d5a:	c7a50513          	addi	a0,a0,-902 # ffffffffc02079d0 <commands+0x1150>
ffffffffc0202d5e:	caafd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0202d62:	00005697          	auipc	a3,0x5
ffffffffc0202d66:	d8e68693          	addi	a3,a3,-626 # ffffffffc0207af0 <commands+0x1270>
ffffffffc0202d6a:	00004617          	auipc	a2,0x4
ffffffffc0202d6e:	f2660613          	addi	a2,a2,-218 # ffffffffc0206c90 <commands+0x410>
ffffffffc0202d72:	0c200593          	li	a1,194
ffffffffc0202d76:	00005517          	auipc	a0,0x5
ffffffffc0202d7a:	c5a50513          	addi	a0,a0,-934 # ffffffffc02079d0 <commands+0x1150>
ffffffffc0202d7e:	c8afd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(p0 != NULL);
ffffffffc0202d82:	00005697          	auipc	a3,0x5
ffffffffc0202d86:	dee68693          	addi	a3,a3,-530 # ffffffffc0207b70 <commands+0x12f0>
ffffffffc0202d8a:	00004617          	auipc	a2,0x4
ffffffffc0202d8e:	f0660613          	addi	a2,a2,-250 # ffffffffc0206c90 <commands+0x410>
ffffffffc0202d92:	0f800593          	li	a1,248
ffffffffc0202d96:	00005517          	auipc	a0,0x5
ffffffffc0202d9a:	c3a50513          	addi	a0,a0,-966 # ffffffffc02079d0 <commands+0x1150>
ffffffffc0202d9e:	c6afd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free == 0);
ffffffffc0202da2:	00004697          	auipc	a3,0x4
ffffffffc0202da6:	7ee68693          	addi	a3,a3,2030 # ffffffffc0207590 <commands+0xd10>
ffffffffc0202daa:	00004617          	auipc	a2,0x4
ffffffffc0202dae:	ee660613          	addi	a2,a2,-282 # ffffffffc0206c90 <commands+0x410>
ffffffffc0202db2:	0df00593          	li	a1,223
ffffffffc0202db6:	00005517          	auipc	a0,0x5
ffffffffc0202dba:	c1a50513          	addi	a0,a0,-998 # ffffffffc02079d0 <commands+0x1150>
ffffffffc0202dbe:	c4afd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202dc2:	00005697          	auipc	a3,0x5
ffffffffc0202dc6:	d4e68693          	addi	a3,a3,-690 # ffffffffc0207b10 <commands+0x1290>
ffffffffc0202dca:	00004617          	auipc	a2,0x4
ffffffffc0202dce:	ec660613          	addi	a2,a2,-314 # ffffffffc0206c90 <commands+0x410>
ffffffffc0202dd2:	0dd00593          	li	a1,221
ffffffffc0202dd6:	00005517          	auipc	a0,0x5
ffffffffc0202dda:	bfa50513          	addi	a0,a0,-1030 # ffffffffc02079d0 <commands+0x1150>
ffffffffc0202dde:	c2afd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0202de2:	00005697          	auipc	a3,0x5
ffffffffc0202de6:	d6e68693          	addi	a3,a3,-658 # ffffffffc0207b50 <commands+0x12d0>
ffffffffc0202dea:	00004617          	auipc	a2,0x4
ffffffffc0202dee:	ea660613          	addi	a2,a2,-346 # ffffffffc0206c90 <commands+0x410>
ffffffffc0202df2:	0dc00593          	li	a1,220
ffffffffc0202df6:	00005517          	auipc	a0,0x5
ffffffffc0202dfa:	bda50513          	addi	a0,a0,-1062 # ffffffffc02079d0 <commands+0x1150>
ffffffffc0202dfe:	c0afd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202e02:	00005697          	auipc	a3,0x5
ffffffffc0202e06:	be668693          	addi	a3,a3,-1050 # ffffffffc02079e8 <commands+0x1168>
ffffffffc0202e0a:	00004617          	auipc	a2,0x4
ffffffffc0202e0e:	e8660613          	addi	a2,a2,-378 # ffffffffc0206c90 <commands+0x410>
ffffffffc0202e12:	0b900593          	li	a1,185
ffffffffc0202e16:	00005517          	auipc	a0,0x5
ffffffffc0202e1a:	bba50513          	addi	a0,a0,-1094 # ffffffffc02079d0 <commands+0x1150>
ffffffffc0202e1e:	beafd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202e22:	00005697          	auipc	a3,0x5
ffffffffc0202e26:	cee68693          	addi	a3,a3,-786 # ffffffffc0207b10 <commands+0x1290>
ffffffffc0202e2a:	00004617          	auipc	a2,0x4
ffffffffc0202e2e:	e6660613          	addi	a2,a2,-410 # ffffffffc0206c90 <commands+0x410>
ffffffffc0202e32:	0d600593          	li	a1,214
ffffffffc0202e36:	00005517          	auipc	a0,0x5
ffffffffc0202e3a:	b9a50513          	addi	a0,a0,-1126 # ffffffffc02079d0 <commands+0x1150>
ffffffffc0202e3e:	bcafd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202e42:	00005697          	auipc	a3,0x5
ffffffffc0202e46:	be668693          	addi	a3,a3,-1050 # ffffffffc0207a28 <commands+0x11a8>
ffffffffc0202e4a:	00004617          	auipc	a2,0x4
ffffffffc0202e4e:	e4660613          	addi	a2,a2,-442 # ffffffffc0206c90 <commands+0x410>
ffffffffc0202e52:	0d400593          	li	a1,212
ffffffffc0202e56:	00005517          	auipc	a0,0x5
ffffffffc0202e5a:	b7a50513          	addi	a0,a0,-1158 # ffffffffc02079d0 <commands+0x1150>
ffffffffc0202e5e:	baafd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202e62:	00005697          	auipc	a3,0x5
ffffffffc0202e66:	ba668693          	addi	a3,a3,-1114 # ffffffffc0207a08 <commands+0x1188>
ffffffffc0202e6a:	00004617          	auipc	a2,0x4
ffffffffc0202e6e:	e2660613          	addi	a2,a2,-474 # ffffffffc0206c90 <commands+0x410>
ffffffffc0202e72:	0d300593          	li	a1,211
ffffffffc0202e76:	00005517          	auipc	a0,0x5
ffffffffc0202e7a:	b5a50513          	addi	a0,a0,-1190 # ffffffffc02079d0 <commands+0x1150>
ffffffffc0202e7e:	b8afd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202e82:	00005697          	auipc	a3,0x5
ffffffffc0202e86:	ba668693          	addi	a3,a3,-1114 # ffffffffc0207a28 <commands+0x11a8>
ffffffffc0202e8a:	00004617          	auipc	a2,0x4
ffffffffc0202e8e:	e0660613          	addi	a2,a2,-506 # ffffffffc0206c90 <commands+0x410>
ffffffffc0202e92:	0bb00593          	li	a1,187
ffffffffc0202e96:	00005517          	auipc	a0,0x5
ffffffffc0202e9a:	b3a50513          	addi	a0,a0,-1222 # ffffffffc02079d0 <commands+0x1150>
ffffffffc0202e9e:	b6afd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(count == 0);
ffffffffc0202ea2:	00005697          	auipc	a3,0x5
ffffffffc0202ea6:	e1e68693          	addi	a3,a3,-482 # ffffffffc0207cc0 <commands+0x1440>
ffffffffc0202eaa:	00004617          	auipc	a2,0x4
ffffffffc0202eae:	de660613          	addi	a2,a2,-538 # ffffffffc0206c90 <commands+0x410>
ffffffffc0202eb2:	12500593          	li	a1,293
ffffffffc0202eb6:	00005517          	auipc	a0,0x5
ffffffffc0202eba:	b1a50513          	addi	a0,a0,-1254 # ffffffffc02079d0 <commands+0x1150>
ffffffffc0202ebe:	b4afd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free == 0);
ffffffffc0202ec2:	00004697          	auipc	a3,0x4
ffffffffc0202ec6:	6ce68693          	addi	a3,a3,1742 # ffffffffc0207590 <commands+0xd10>
ffffffffc0202eca:	00004617          	auipc	a2,0x4
ffffffffc0202ece:	dc660613          	addi	a2,a2,-570 # ffffffffc0206c90 <commands+0x410>
ffffffffc0202ed2:	11a00593          	li	a1,282
ffffffffc0202ed6:	00005517          	auipc	a0,0x5
ffffffffc0202eda:	afa50513          	addi	a0,a0,-1286 # ffffffffc02079d0 <commands+0x1150>
ffffffffc0202ede:	b2afd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202ee2:	00005697          	auipc	a3,0x5
ffffffffc0202ee6:	c2e68693          	addi	a3,a3,-978 # ffffffffc0207b10 <commands+0x1290>
ffffffffc0202eea:	00004617          	auipc	a2,0x4
ffffffffc0202eee:	da660613          	addi	a2,a2,-602 # ffffffffc0206c90 <commands+0x410>
ffffffffc0202ef2:	11800593          	li	a1,280
ffffffffc0202ef6:	00005517          	auipc	a0,0x5
ffffffffc0202efa:	ada50513          	addi	a0,a0,-1318 # ffffffffc02079d0 <commands+0x1150>
ffffffffc0202efe:	b0afd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0202f02:	00005697          	auipc	a3,0x5
ffffffffc0202f06:	bce68693          	addi	a3,a3,-1074 # ffffffffc0207ad0 <commands+0x1250>
ffffffffc0202f0a:	00004617          	auipc	a2,0x4
ffffffffc0202f0e:	d8660613          	addi	a2,a2,-634 # ffffffffc0206c90 <commands+0x410>
ffffffffc0202f12:	0c100593          	li	a1,193
ffffffffc0202f16:	00005517          	auipc	a0,0x5
ffffffffc0202f1a:	aba50513          	addi	a0,a0,-1350 # ffffffffc02079d0 <commands+0x1150>
ffffffffc0202f1e:	aeafd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202f22:	00005697          	auipc	a3,0x5
ffffffffc0202f26:	d5e68693          	addi	a3,a3,-674 # ffffffffc0207c80 <commands+0x1400>
ffffffffc0202f2a:	00004617          	auipc	a2,0x4
ffffffffc0202f2e:	d6660613          	addi	a2,a2,-666 # ffffffffc0206c90 <commands+0x410>
ffffffffc0202f32:	11200593          	li	a1,274
ffffffffc0202f36:	00005517          	auipc	a0,0x5
ffffffffc0202f3a:	a9a50513          	addi	a0,a0,-1382 # ffffffffc02079d0 <commands+0x1150>
ffffffffc0202f3e:	acafd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0202f42:	00005697          	auipc	a3,0x5
ffffffffc0202f46:	d1e68693          	addi	a3,a3,-738 # ffffffffc0207c60 <commands+0x13e0>
ffffffffc0202f4a:	00004617          	auipc	a2,0x4
ffffffffc0202f4e:	d4660613          	addi	a2,a2,-698 # ffffffffc0206c90 <commands+0x410>
ffffffffc0202f52:	11000593          	li	a1,272
ffffffffc0202f56:	00005517          	auipc	a0,0x5
ffffffffc0202f5a:	a7a50513          	addi	a0,a0,-1414 # ffffffffc02079d0 <commands+0x1150>
ffffffffc0202f5e:	aaafd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0202f62:	00005697          	auipc	a3,0x5
ffffffffc0202f66:	cd668693          	addi	a3,a3,-810 # ffffffffc0207c38 <commands+0x13b8>
ffffffffc0202f6a:	00004617          	auipc	a2,0x4
ffffffffc0202f6e:	d2660613          	addi	a2,a2,-730 # ffffffffc0206c90 <commands+0x410>
ffffffffc0202f72:	10e00593          	li	a1,270
ffffffffc0202f76:	00005517          	auipc	a0,0x5
ffffffffc0202f7a:	a5a50513          	addi	a0,a0,-1446 # ffffffffc02079d0 <commands+0x1150>
ffffffffc0202f7e:	a8afd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0202f82:	00005697          	auipc	a3,0x5
ffffffffc0202f86:	c8e68693          	addi	a3,a3,-882 # ffffffffc0207c10 <commands+0x1390>
ffffffffc0202f8a:	00004617          	auipc	a2,0x4
ffffffffc0202f8e:	d0660613          	addi	a2,a2,-762 # ffffffffc0206c90 <commands+0x410>
ffffffffc0202f92:	10d00593          	li	a1,269
ffffffffc0202f96:	00005517          	auipc	a0,0x5
ffffffffc0202f9a:	a3a50513          	addi	a0,a0,-1478 # ffffffffc02079d0 <commands+0x1150>
ffffffffc0202f9e:	a6afd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0202fa2:	00005697          	auipc	a3,0x5
ffffffffc0202fa6:	c5e68693          	addi	a3,a3,-930 # ffffffffc0207c00 <commands+0x1380>
ffffffffc0202faa:	00004617          	auipc	a2,0x4
ffffffffc0202fae:	ce660613          	addi	a2,a2,-794 # ffffffffc0206c90 <commands+0x410>
ffffffffc0202fb2:	10800593          	li	a1,264
ffffffffc0202fb6:	00005517          	auipc	a0,0x5
ffffffffc0202fba:	a1a50513          	addi	a0,a0,-1510 # ffffffffc02079d0 <commands+0x1150>
ffffffffc0202fbe:	a4afd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202fc2:	00005697          	auipc	a3,0x5
ffffffffc0202fc6:	b4e68693          	addi	a3,a3,-1202 # ffffffffc0207b10 <commands+0x1290>
ffffffffc0202fca:	00004617          	auipc	a2,0x4
ffffffffc0202fce:	cc660613          	addi	a2,a2,-826 # ffffffffc0206c90 <commands+0x410>
ffffffffc0202fd2:	10700593          	li	a1,263
ffffffffc0202fd6:	00005517          	auipc	a0,0x5
ffffffffc0202fda:	9fa50513          	addi	a0,a0,-1542 # ffffffffc02079d0 <commands+0x1150>
ffffffffc0202fde:	a2afd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0202fe2:	00005697          	auipc	a3,0x5
ffffffffc0202fe6:	bfe68693          	addi	a3,a3,-1026 # ffffffffc0207be0 <commands+0x1360>
ffffffffc0202fea:	00004617          	auipc	a2,0x4
ffffffffc0202fee:	ca660613          	addi	a2,a2,-858 # ffffffffc0206c90 <commands+0x410>
ffffffffc0202ff2:	10600593          	li	a1,262
ffffffffc0202ff6:	00005517          	auipc	a0,0x5
ffffffffc0202ffa:	9da50513          	addi	a0,a0,-1574 # ffffffffc02079d0 <commands+0x1150>
ffffffffc0202ffe:	a0afd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0203002:	00005697          	auipc	a3,0x5
ffffffffc0203006:	bae68693          	addi	a3,a3,-1106 # ffffffffc0207bb0 <commands+0x1330>
ffffffffc020300a:	00004617          	auipc	a2,0x4
ffffffffc020300e:	c8660613          	addi	a2,a2,-890 # ffffffffc0206c90 <commands+0x410>
ffffffffc0203012:	10500593          	li	a1,261
ffffffffc0203016:	00005517          	auipc	a0,0x5
ffffffffc020301a:	9ba50513          	addi	a0,a0,-1606 # ffffffffc02079d0 <commands+0x1150>
ffffffffc020301e:	9eafd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0203022:	00005697          	auipc	a3,0x5
ffffffffc0203026:	b7668693          	addi	a3,a3,-1162 # ffffffffc0207b98 <commands+0x1318>
ffffffffc020302a:	00004617          	auipc	a2,0x4
ffffffffc020302e:	c6660613          	addi	a2,a2,-922 # ffffffffc0206c90 <commands+0x410>
ffffffffc0203032:	10400593          	li	a1,260
ffffffffc0203036:	00005517          	auipc	a0,0x5
ffffffffc020303a:	99a50513          	addi	a0,a0,-1638 # ffffffffc02079d0 <commands+0x1150>
ffffffffc020303e:	9cafd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203042:	00005697          	auipc	a3,0x5
ffffffffc0203046:	ace68693          	addi	a3,a3,-1330 # ffffffffc0207b10 <commands+0x1290>
ffffffffc020304a:	00004617          	auipc	a2,0x4
ffffffffc020304e:	c4660613          	addi	a2,a2,-954 # ffffffffc0206c90 <commands+0x410>
ffffffffc0203052:	0fe00593          	li	a1,254
ffffffffc0203056:	00005517          	auipc	a0,0x5
ffffffffc020305a:	97a50513          	addi	a0,a0,-1670 # ffffffffc02079d0 <commands+0x1150>
ffffffffc020305e:	9aafd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(!PageProperty(p0));
ffffffffc0203062:	00005697          	auipc	a3,0x5
ffffffffc0203066:	b1e68693          	addi	a3,a3,-1250 # ffffffffc0207b80 <commands+0x1300>
ffffffffc020306a:	00004617          	auipc	a2,0x4
ffffffffc020306e:	c2660613          	addi	a2,a2,-986 # ffffffffc0206c90 <commands+0x410>
ffffffffc0203072:	0f900593          	li	a1,249
ffffffffc0203076:	00005517          	auipc	a0,0x5
ffffffffc020307a:	95a50513          	addi	a0,a0,-1702 # ffffffffc02079d0 <commands+0x1150>
ffffffffc020307e:	98afd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0203082:	00005697          	auipc	a3,0x5
ffffffffc0203086:	c1e68693          	addi	a3,a3,-994 # ffffffffc0207ca0 <commands+0x1420>
ffffffffc020308a:	00004617          	auipc	a2,0x4
ffffffffc020308e:	c0660613          	addi	a2,a2,-1018 # ffffffffc0206c90 <commands+0x410>
ffffffffc0203092:	11700593          	li	a1,279
ffffffffc0203096:	00005517          	auipc	a0,0x5
ffffffffc020309a:	93a50513          	addi	a0,a0,-1734 # ffffffffc02079d0 <commands+0x1150>
ffffffffc020309e:	96afd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(total == 0);
ffffffffc02030a2:	00005697          	auipc	a3,0x5
ffffffffc02030a6:	c2e68693          	addi	a3,a3,-978 # ffffffffc0207cd0 <commands+0x1450>
ffffffffc02030aa:	00004617          	auipc	a2,0x4
ffffffffc02030ae:	be660613          	addi	a2,a2,-1050 # ffffffffc0206c90 <commands+0x410>
ffffffffc02030b2:	12600593          	li	a1,294
ffffffffc02030b6:	00005517          	auipc	a0,0x5
ffffffffc02030ba:	91a50513          	addi	a0,a0,-1766 # ffffffffc02079d0 <commands+0x1150>
ffffffffc02030be:	94afd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(total == nr_free_pages());
ffffffffc02030c2:	00004697          	auipc	a3,0x4
ffffffffc02030c6:	32e68693          	addi	a3,a3,814 # ffffffffc02073f0 <commands+0xb70>
ffffffffc02030ca:	00004617          	auipc	a2,0x4
ffffffffc02030ce:	bc660613          	addi	a2,a2,-1082 # ffffffffc0206c90 <commands+0x410>
ffffffffc02030d2:	0f300593          	li	a1,243
ffffffffc02030d6:	00005517          	auipc	a0,0x5
ffffffffc02030da:	8fa50513          	addi	a0,a0,-1798 # ffffffffc02079d0 <commands+0x1150>
ffffffffc02030de:	92afd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02030e2:	00005697          	auipc	a3,0x5
ffffffffc02030e6:	92668693          	addi	a3,a3,-1754 # ffffffffc0207a08 <commands+0x1188>
ffffffffc02030ea:	00004617          	auipc	a2,0x4
ffffffffc02030ee:	ba660613          	addi	a2,a2,-1114 # ffffffffc0206c90 <commands+0x410>
ffffffffc02030f2:	0ba00593          	li	a1,186
ffffffffc02030f6:	00005517          	auipc	a0,0x5
ffffffffc02030fa:	8da50513          	addi	a0,a0,-1830 # ffffffffc02079d0 <commands+0x1150>
ffffffffc02030fe:	90afd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0203102 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0203102:	1141                	addi	sp,sp,-16
ffffffffc0203104:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203106:	14058463          	beqz	a1,ffffffffc020324e <default_free_pages+0x14c>
    for (; p != base + n; p ++) {
ffffffffc020310a:	00659693          	slli	a3,a1,0x6
ffffffffc020310e:	96aa                	add	a3,a3,a0
ffffffffc0203110:	87aa                	mv	a5,a0
ffffffffc0203112:	02d50263          	beq	a0,a3,ffffffffc0203136 <default_free_pages+0x34>
ffffffffc0203116:	6798                	ld	a4,8(a5)
ffffffffc0203118:	8b05                	andi	a4,a4,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020311a:	10071a63          	bnez	a4,ffffffffc020322e <default_free_pages+0x12c>
ffffffffc020311e:	6798                	ld	a4,8(a5)
ffffffffc0203120:	8b09                	andi	a4,a4,2
ffffffffc0203122:	10071663          	bnez	a4,ffffffffc020322e <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc0203126:	0007b423          	sd	zero,8(a5)
    page->ref = val;
ffffffffc020312a:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020312e:	04078793          	addi	a5,a5,64
ffffffffc0203132:	fed792e3          	bne	a5,a3,ffffffffc0203116 <default_free_pages+0x14>
    base->property = n;
ffffffffc0203136:	2581                	sext.w	a1,a1
ffffffffc0203138:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc020313a:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020313e:	4789                	li	a5,2
ffffffffc0203140:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0203144:	000ab697          	auipc	a3,0xab
ffffffffc0203148:	6d468693          	addi	a3,a3,1748 # ffffffffc02ae818 <free_area>
ffffffffc020314c:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020314e:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0203150:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0203154:	9db9                	addw	a1,a1,a4
ffffffffc0203156:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0203158:	0ad78463          	beq	a5,a3,ffffffffc0203200 <default_free_pages+0xfe>
            struct Page* page = le2page(le, page_link);
ffffffffc020315c:	fe878713          	addi	a4,a5,-24
ffffffffc0203160:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0203164:	4581                	li	a1,0
            if (base < page) {
ffffffffc0203166:	00e56a63          	bltu	a0,a4,ffffffffc020317a <default_free_pages+0x78>
    return listelm->next;
ffffffffc020316a:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020316c:	04d70c63          	beq	a4,a3,ffffffffc02031c4 <default_free_pages+0xc2>
    for (; p != base + n; p ++) {
ffffffffc0203170:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0203172:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0203176:	fee57ae3          	bgeu	a0,a4,ffffffffc020316a <default_free_pages+0x68>
ffffffffc020317a:	c199                	beqz	a1,ffffffffc0203180 <default_free_pages+0x7e>
ffffffffc020317c:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203180:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc0203182:	e390                	sd	a2,0(a5)
ffffffffc0203184:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0203186:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203188:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc020318a:	00d70d63          	beq	a4,a3,ffffffffc02031a4 <default_free_pages+0xa2>
        if (p + p->property == base) {
ffffffffc020318e:	ff872583          	lw	a1,-8(a4) # ff8 <_binary_obj___user_faultread_out_size-0x8bc0>
        p = le2page(le, page_link);
ffffffffc0203192:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base) {
ffffffffc0203196:	02059813          	slli	a6,a1,0x20
ffffffffc020319a:	01a85793          	srli	a5,a6,0x1a
ffffffffc020319e:	97b2                	add	a5,a5,a2
ffffffffc02031a0:	02f50c63          	beq	a0,a5,ffffffffc02031d8 <default_free_pages+0xd6>
    return listelm->next;
ffffffffc02031a4:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc02031a6:	00d78c63          	beq	a5,a3,ffffffffc02031be <default_free_pages+0xbc>
        if (base + base->property == p) {
ffffffffc02031aa:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc02031ac:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p) {
ffffffffc02031b0:	02061593          	slli	a1,a2,0x20
ffffffffc02031b4:	01a5d713          	srli	a4,a1,0x1a
ffffffffc02031b8:	972a                	add	a4,a4,a0
ffffffffc02031ba:	04e68a63          	beq	a3,a4,ffffffffc020320e <default_free_pages+0x10c>
}
ffffffffc02031be:	60a2                	ld	ra,8(sp)
ffffffffc02031c0:	0141                	addi	sp,sp,16
ffffffffc02031c2:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02031c4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02031c6:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02031c8:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02031ca:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02031cc:	02d70763          	beq	a4,a3,ffffffffc02031fa <default_free_pages+0xf8>
    prev->next = next->prev = elm;
ffffffffc02031d0:	8832                	mv	a6,a2
ffffffffc02031d2:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02031d4:	87ba                	mv	a5,a4
ffffffffc02031d6:	bf71                	j	ffffffffc0203172 <default_free_pages+0x70>
            p->property += base->property;
ffffffffc02031d8:	491c                	lw	a5,16(a0)
ffffffffc02031da:	9dbd                	addw	a1,a1,a5
ffffffffc02031dc:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02031e0:	57f5                	li	a5,-3
ffffffffc02031e2:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02031e6:	01853803          	ld	a6,24(a0)
ffffffffc02031ea:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc02031ec:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc02031ee:	00b83423          	sd	a1,8(a6)
    return listelm->next;
ffffffffc02031f2:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc02031f4:	0105b023          	sd	a6,0(a1) # 1000 <_binary_obj___user_faultread_out_size-0x8bb8>
ffffffffc02031f8:	b77d                	j	ffffffffc02031a6 <default_free_pages+0xa4>
ffffffffc02031fa:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02031fc:	873e                	mv	a4,a5
ffffffffc02031fe:	bf41                	j	ffffffffc020318e <default_free_pages+0x8c>
}
ffffffffc0203200:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0203202:	e390                	sd	a2,0(a5)
ffffffffc0203204:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203206:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203208:	ed1c                	sd	a5,24(a0)
ffffffffc020320a:	0141                	addi	sp,sp,16
ffffffffc020320c:	8082                	ret
            base->property += p->property;
ffffffffc020320e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203212:	ff078693          	addi	a3,a5,-16
ffffffffc0203216:	9e39                	addw	a2,a2,a4
ffffffffc0203218:	c910                	sw	a2,16(a0)
ffffffffc020321a:	5775                	li	a4,-3
ffffffffc020321c:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203220:	6398                	ld	a4,0(a5)
ffffffffc0203222:	679c                	ld	a5,8(a5)
}
ffffffffc0203224:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0203226:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203228:	e398                	sd	a4,0(a5)
ffffffffc020322a:	0141                	addi	sp,sp,16
ffffffffc020322c:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020322e:	00005697          	auipc	a3,0x5
ffffffffc0203232:	aba68693          	addi	a3,a3,-1350 # ffffffffc0207ce8 <commands+0x1468>
ffffffffc0203236:	00004617          	auipc	a2,0x4
ffffffffc020323a:	a5a60613          	addi	a2,a2,-1446 # ffffffffc0206c90 <commands+0x410>
ffffffffc020323e:	08300593          	li	a1,131
ffffffffc0203242:	00004517          	auipc	a0,0x4
ffffffffc0203246:	78e50513          	addi	a0,a0,1934 # ffffffffc02079d0 <commands+0x1150>
ffffffffc020324a:	fbffc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(n > 0);
ffffffffc020324e:	00005697          	auipc	a3,0x5
ffffffffc0203252:	a9268693          	addi	a3,a3,-1390 # ffffffffc0207ce0 <commands+0x1460>
ffffffffc0203256:	00004617          	auipc	a2,0x4
ffffffffc020325a:	a3a60613          	addi	a2,a2,-1478 # ffffffffc0206c90 <commands+0x410>
ffffffffc020325e:	08000593          	li	a1,128
ffffffffc0203262:	00004517          	auipc	a0,0x4
ffffffffc0203266:	76e50513          	addi	a0,a0,1902 # ffffffffc02079d0 <commands+0x1150>
ffffffffc020326a:	f9ffc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020326e <default_alloc_pages>:
    assert(n > 0);
ffffffffc020326e:	c941                	beqz	a0,ffffffffc02032fe <default_alloc_pages+0x90>
    if (n > nr_free) {
ffffffffc0203270:	000ab597          	auipc	a1,0xab
ffffffffc0203274:	5a858593          	addi	a1,a1,1448 # ffffffffc02ae818 <free_area>
ffffffffc0203278:	0105a803          	lw	a6,16(a1)
ffffffffc020327c:	872a                	mv	a4,a0
ffffffffc020327e:	02081793          	slli	a5,a6,0x20
ffffffffc0203282:	9381                	srli	a5,a5,0x20
ffffffffc0203284:	00a7ee63          	bltu	a5,a0,ffffffffc02032a0 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0203288:	87ae                	mv	a5,a1
ffffffffc020328a:	a801                	j	ffffffffc020329a <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc020328c:	ff87a683          	lw	a3,-8(a5)
ffffffffc0203290:	02069613          	slli	a2,a3,0x20
ffffffffc0203294:	9201                	srli	a2,a2,0x20
ffffffffc0203296:	00e67763          	bgeu	a2,a4,ffffffffc02032a4 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc020329a:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc020329c:	feb798e3          	bne	a5,a1,ffffffffc020328c <default_alloc_pages+0x1e>
        return NULL;
ffffffffc02032a0:	4501                	li	a0,0
}
ffffffffc02032a2:	8082                	ret
    return listelm->prev;
ffffffffc02032a4:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02032a8:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc02032ac:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc02032b0:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc02032b4:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc02032b8:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc02032bc:	02c77863          	bgeu	a4,a2,ffffffffc02032ec <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc02032c0:	071a                	slli	a4,a4,0x6
ffffffffc02032c2:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc02032c4:	41c686bb          	subw	a3,a3,t3
ffffffffc02032c8:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02032ca:	00870613          	addi	a2,a4,8
ffffffffc02032ce:	4689                	li	a3,2
ffffffffc02032d0:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc02032d4:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc02032d8:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc02032dc:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc02032e0:	e290                	sd	a2,0(a3)
ffffffffc02032e2:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc02032e6:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc02032e8:	01173c23          	sd	a7,24(a4)
ffffffffc02032ec:	41c8083b          	subw	a6,a6,t3
ffffffffc02032f0:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02032f4:	5775                	li	a4,-3
ffffffffc02032f6:	17c1                	addi	a5,a5,-16
ffffffffc02032f8:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc02032fc:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc02032fe:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0203300:	00005697          	auipc	a3,0x5
ffffffffc0203304:	9e068693          	addi	a3,a3,-1568 # ffffffffc0207ce0 <commands+0x1460>
ffffffffc0203308:	00004617          	auipc	a2,0x4
ffffffffc020330c:	98860613          	addi	a2,a2,-1656 # ffffffffc0206c90 <commands+0x410>
ffffffffc0203310:	06200593          	li	a1,98
ffffffffc0203314:	00004517          	auipc	a0,0x4
ffffffffc0203318:	6bc50513          	addi	a0,a0,1724 # ffffffffc02079d0 <commands+0x1150>
default_alloc_pages(size_t n) {
ffffffffc020331c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020331e:	eebfc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0203322 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0203322:	1141                	addi	sp,sp,-16
ffffffffc0203324:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203326:	c5f1                	beqz	a1,ffffffffc02033f2 <default_init_memmap+0xd0>
    for (; p != base + n; p ++) {
ffffffffc0203328:	00659693          	slli	a3,a1,0x6
ffffffffc020332c:	96aa                	add	a3,a3,a0
ffffffffc020332e:	87aa                	mv	a5,a0
ffffffffc0203330:	00d50f63          	beq	a0,a3,ffffffffc020334e <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0203334:	6798                	ld	a4,8(a5)
ffffffffc0203336:	8b05                	andi	a4,a4,1
        assert(PageReserved(p));
ffffffffc0203338:	cf49                	beqz	a4,ffffffffc02033d2 <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc020333a:	0007a823          	sw	zero,16(a5)
ffffffffc020333e:	0007b423          	sd	zero,8(a5)
ffffffffc0203342:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0203346:	04078793          	addi	a5,a5,64
ffffffffc020334a:	fed795e3          	bne	a5,a3,ffffffffc0203334 <default_init_memmap+0x12>
    base->property = n;
ffffffffc020334e:	2581                	sext.w	a1,a1
ffffffffc0203350:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0203352:	4789                	li	a5,2
ffffffffc0203354:	00850713          	addi	a4,a0,8
ffffffffc0203358:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020335c:	000ab697          	auipc	a3,0xab
ffffffffc0203360:	4bc68693          	addi	a3,a3,1212 # ffffffffc02ae818 <free_area>
ffffffffc0203364:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0203366:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0203368:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc020336c:	9db9                	addw	a1,a1,a4
ffffffffc020336e:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0203370:	04d78a63          	beq	a5,a3,ffffffffc02033c4 <default_init_memmap+0xa2>
            struct Page* page = le2page(le, page_link);
ffffffffc0203374:	fe878713          	addi	a4,a5,-24
ffffffffc0203378:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020337c:	4581                	li	a1,0
            if (base < page) {
ffffffffc020337e:	00e56a63          	bltu	a0,a4,ffffffffc0203392 <default_init_memmap+0x70>
    return listelm->next;
ffffffffc0203382:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0203384:	02d70263          	beq	a4,a3,ffffffffc02033a8 <default_init_memmap+0x86>
    for (; p != base + n; p ++) {
ffffffffc0203388:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020338a:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020338e:	fee57ae3          	bgeu	a0,a4,ffffffffc0203382 <default_init_memmap+0x60>
ffffffffc0203392:	c199                	beqz	a1,ffffffffc0203398 <default_init_memmap+0x76>
ffffffffc0203394:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203398:	6398                	ld	a4,0(a5)
}
ffffffffc020339a:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020339c:	e390                	sd	a2,0(a5)
ffffffffc020339e:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02033a0:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02033a2:	ed18                	sd	a4,24(a0)
ffffffffc02033a4:	0141                	addi	sp,sp,16
ffffffffc02033a6:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02033a8:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02033aa:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02033ac:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02033ae:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02033b0:	00d70663          	beq	a4,a3,ffffffffc02033bc <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc02033b4:	8832                	mv	a6,a2
ffffffffc02033b6:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02033b8:	87ba                	mv	a5,a4
ffffffffc02033ba:	bfc1                	j	ffffffffc020338a <default_init_memmap+0x68>
}
ffffffffc02033bc:	60a2                	ld	ra,8(sp)
ffffffffc02033be:	e290                	sd	a2,0(a3)
ffffffffc02033c0:	0141                	addi	sp,sp,16
ffffffffc02033c2:	8082                	ret
ffffffffc02033c4:	60a2                	ld	ra,8(sp)
ffffffffc02033c6:	e390                	sd	a2,0(a5)
ffffffffc02033c8:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02033ca:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02033cc:	ed1c                	sd	a5,24(a0)
ffffffffc02033ce:	0141                	addi	sp,sp,16
ffffffffc02033d0:	8082                	ret
        assert(PageReserved(p));
ffffffffc02033d2:	00005697          	auipc	a3,0x5
ffffffffc02033d6:	93e68693          	addi	a3,a3,-1730 # ffffffffc0207d10 <commands+0x1490>
ffffffffc02033da:	00004617          	auipc	a2,0x4
ffffffffc02033de:	8b660613          	addi	a2,a2,-1866 # ffffffffc0206c90 <commands+0x410>
ffffffffc02033e2:	04900593          	li	a1,73
ffffffffc02033e6:	00004517          	auipc	a0,0x4
ffffffffc02033ea:	5ea50513          	addi	a0,a0,1514 # ffffffffc02079d0 <commands+0x1150>
ffffffffc02033ee:	e1bfc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(n > 0);
ffffffffc02033f2:	00005697          	auipc	a3,0x5
ffffffffc02033f6:	8ee68693          	addi	a3,a3,-1810 # ffffffffc0207ce0 <commands+0x1460>
ffffffffc02033fa:	00004617          	auipc	a2,0x4
ffffffffc02033fe:	89660613          	addi	a2,a2,-1898 # ffffffffc0206c90 <commands+0x410>
ffffffffc0203402:	04600593          	li	a1,70
ffffffffc0203406:	00004517          	auipc	a0,0x4
ffffffffc020340a:	5ca50513          	addi	a0,a0,1482 # ffffffffc02079d0 <commands+0x1150>
ffffffffc020340e:	dfbfc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0203412 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc0203412:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0203414:	00004617          	auipc	a2,0x4
ffffffffc0203418:	e1c60613          	addi	a2,a2,-484 # ffffffffc0207230 <commands+0x9b0>
ffffffffc020341c:	06200593          	li	a1,98
ffffffffc0203420:	00004517          	auipc	a0,0x4
ffffffffc0203424:	e3050513          	addi	a0,a0,-464 # ffffffffc0207250 <commands+0x9d0>
pa2page(uintptr_t pa) {
ffffffffc0203428:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc020342a:	ddffc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020342e <pte2page.part.0>:
pte2page(pte_t pte) {
ffffffffc020342e:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc0203430:	00004617          	auipc	a2,0x4
ffffffffc0203434:	18860613          	addi	a2,a2,392 # ffffffffc02075b8 <commands+0xd38>
ffffffffc0203438:	07400593          	li	a1,116
ffffffffc020343c:	00004517          	auipc	a0,0x4
ffffffffc0203440:	e1450513          	addi	a0,a0,-492 # ffffffffc0207250 <commands+0x9d0>
pte2page(pte_t pte) {
ffffffffc0203444:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0203446:	dc3fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020344a <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc020344a:	7139                	addi	sp,sp,-64
ffffffffc020344c:	f426                	sd	s1,40(sp)
ffffffffc020344e:	f04a                	sd	s2,32(sp)
ffffffffc0203450:	ec4e                	sd	s3,24(sp)
ffffffffc0203452:	e852                	sd	s4,16(sp)
ffffffffc0203454:	e456                	sd	s5,8(sp)
ffffffffc0203456:	e05a                	sd	s6,0(sp)
ffffffffc0203458:	fc06                	sd	ra,56(sp)
ffffffffc020345a:	f822                	sd	s0,48(sp)
ffffffffc020345c:	84aa                	mv	s1,a0
ffffffffc020345e:	000af917          	auipc	s2,0xaf
ffffffffc0203462:	44a90913          	addi	s2,s2,1098 # ffffffffc02b28a8 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0203466:	4a05                	li	s4,1
ffffffffc0203468:	000afa97          	auipc	s5,0xaf
ffffffffc020346c:	410a8a93          	addi	s5,s5,1040 # ffffffffc02b2878 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0203470:	0005099b          	sext.w	s3,a0
ffffffffc0203474:	000afb17          	auipc	s6,0xaf
ffffffffc0203478:	3e4b0b13          	addi	s6,s6,996 # ffffffffc02b2858 <check_mm_struct>
ffffffffc020347c:	a01d                	j	ffffffffc02034a2 <alloc_pages+0x58>
            page = pmm_manager->alloc_pages(n);
ffffffffc020347e:	00093783          	ld	a5,0(s2)
ffffffffc0203482:	6f9c                	ld	a5,24(a5)
ffffffffc0203484:	9782                	jalr	a5
ffffffffc0203486:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0203488:	4601                	li	a2,0
ffffffffc020348a:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc020348c:	ec0d                	bnez	s0,ffffffffc02034c6 <alloc_pages+0x7c>
ffffffffc020348e:	029a6c63          	bltu	s4,s1,ffffffffc02034c6 <alloc_pages+0x7c>
ffffffffc0203492:	000aa783          	lw	a5,0(s5)
ffffffffc0203496:	2781                	sext.w	a5,a5
ffffffffc0203498:	c79d                	beqz	a5,ffffffffc02034c6 <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc020349a:	000b3503          	ld	a0,0(s6)
ffffffffc020349e:	b6ffe0ef          	jal	ra,ffffffffc020200c <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02034a2:	100027f3          	csrr	a5,sstatus
ffffffffc02034a6:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc02034a8:	8526                	mv	a0,s1
ffffffffc02034aa:	dbf1                	beqz	a5,ffffffffc020347e <alloc_pages+0x34>
        intr_disable();
ffffffffc02034ac:	99cfd0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc02034b0:	00093783          	ld	a5,0(s2)
ffffffffc02034b4:	8526                	mv	a0,s1
ffffffffc02034b6:	6f9c                	ld	a5,24(a5)
ffffffffc02034b8:	9782                	jalr	a5
ffffffffc02034ba:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02034bc:	986fd0ef          	jal	ra,ffffffffc0200642 <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc02034c0:	4601                	li	a2,0
ffffffffc02034c2:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02034c4:	d469                	beqz	s0,ffffffffc020348e <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc02034c6:	70e2                	ld	ra,56(sp)
ffffffffc02034c8:	8522                	mv	a0,s0
ffffffffc02034ca:	7442                	ld	s0,48(sp)
ffffffffc02034cc:	74a2                	ld	s1,40(sp)
ffffffffc02034ce:	7902                	ld	s2,32(sp)
ffffffffc02034d0:	69e2                	ld	s3,24(sp)
ffffffffc02034d2:	6a42                	ld	s4,16(sp)
ffffffffc02034d4:	6aa2                	ld	s5,8(sp)
ffffffffc02034d6:	6b02                	ld	s6,0(sp)
ffffffffc02034d8:	6121                	addi	sp,sp,64
ffffffffc02034da:	8082                	ret

ffffffffc02034dc <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02034dc:	100027f3          	csrr	a5,sstatus
ffffffffc02034e0:	8b89                	andi	a5,a5,2
ffffffffc02034e2:	e799                	bnez	a5,ffffffffc02034f0 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc02034e4:	000af797          	auipc	a5,0xaf
ffffffffc02034e8:	3c47b783          	ld	a5,964(a5) # ffffffffc02b28a8 <pmm_manager>
ffffffffc02034ec:	739c                	ld	a5,32(a5)
ffffffffc02034ee:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc02034f0:	1101                	addi	sp,sp,-32
ffffffffc02034f2:	ec06                	sd	ra,24(sp)
ffffffffc02034f4:	e822                	sd	s0,16(sp)
ffffffffc02034f6:	e426                	sd	s1,8(sp)
ffffffffc02034f8:	842a                	mv	s0,a0
ffffffffc02034fa:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc02034fc:	94cfd0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203500:	000af797          	auipc	a5,0xaf
ffffffffc0203504:	3a87b783          	ld	a5,936(a5) # ffffffffc02b28a8 <pmm_manager>
ffffffffc0203508:	739c                	ld	a5,32(a5)
ffffffffc020350a:	85a6                	mv	a1,s1
ffffffffc020350c:	8522                	mv	a0,s0
ffffffffc020350e:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0203510:	6442                	ld	s0,16(sp)
ffffffffc0203512:	60e2                	ld	ra,24(sp)
ffffffffc0203514:	64a2                	ld	s1,8(sp)
ffffffffc0203516:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0203518:	92afd06f          	j	ffffffffc0200642 <intr_enable>

ffffffffc020351c <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020351c:	100027f3          	csrr	a5,sstatus
ffffffffc0203520:	8b89                	andi	a5,a5,2
ffffffffc0203522:	e799                	bnez	a5,ffffffffc0203530 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0203524:	000af797          	auipc	a5,0xaf
ffffffffc0203528:	3847b783          	ld	a5,900(a5) # ffffffffc02b28a8 <pmm_manager>
ffffffffc020352c:	779c                	ld	a5,40(a5)
ffffffffc020352e:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0203530:	1141                	addi	sp,sp,-16
ffffffffc0203532:	e406                	sd	ra,8(sp)
ffffffffc0203534:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0203536:	912fd0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc020353a:	000af797          	auipc	a5,0xaf
ffffffffc020353e:	36e7b783          	ld	a5,878(a5) # ffffffffc02b28a8 <pmm_manager>
ffffffffc0203542:	779c                	ld	a5,40(a5)
ffffffffc0203544:	9782                	jalr	a5
ffffffffc0203546:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203548:	8fafd0ef          	jal	ra,ffffffffc0200642 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc020354c:	60a2                	ld	ra,8(sp)
ffffffffc020354e:	8522                	mv	a0,s0
ffffffffc0203550:	6402                	ld	s0,0(sp)
ffffffffc0203552:	0141                	addi	sp,sp,16
ffffffffc0203554:	8082                	ret

ffffffffc0203556 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0203556:	01e5d793          	srli	a5,a1,0x1e
ffffffffc020355a:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc020355e:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0203560:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0203562:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0203564:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc0203568:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc020356a:	f04a                	sd	s2,32(sp)
ffffffffc020356c:	ec4e                	sd	s3,24(sp)
ffffffffc020356e:	e852                	sd	s4,16(sp)
ffffffffc0203570:	fc06                	sd	ra,56(sp)
ffffffffc0203572:	f822                	sd	s0,48(sp)
ffffffffc0203574:	e456                	sd	s5,8(sp)
ffffffffc0203576:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0203578:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc020357c:	892e                	mv	s2,a1
ffffffffc020357e:	89b2                	mv	s3,a2
ffffffffc0203580:	000afa17          	auipc	s4,0xaf
ffffffffc0203584:	318a0a13          	addi	s4,s4,792 # ffffffffc02b2898 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0203588:	e7b5                	bnez	a5,ffffffffc02035f4 <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc020358a:	12060b63          	beqz	a2,ffffffffc02036c0 <get_pte+0x16a>
ffffffffc020358e:	4505                	li	a0,1
ffffffffc0203590:	ebbff0ef          	jal	ra,ffffffffc020344a <alloc_pages>
ffffffffc0203594:	842a                	mv	s0,a0
ffffffffc0203596:	12050563          	beqz	a0,ffffffffc02036c0 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc020359a:	000afb17          	auipc	s6,0xaf
ffffffffc020359e:	306b0b13          	addi	s6,s6,774 # ffffffffc02b28a0 <pages>
ffffffffc02035a2:	000b3503          	ld	a0,0(s6)
ffffffffc02035a6:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02035aa:	000afa17          	auipc	s4,0xaf
ffffffffc02035ae:	2eea0a13          	addi	s4,s4,750 # ffffffffc02b2898 <npage>
ffffffffc02035b2:	40a40533          	sub	a0,s0,a0
ffffffffc02035b6:	8519                	srai	a0,a0,0x6
ffffffffc02035b8:	9556                	add	a0,a0,s5
ffffffffc02035ba:	000a3703          	ld	a4,0(s4)
ffffffffc02035be:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc02035c2:	4685                	li	a3,1
ffffffffc02035c4:	c014                	sw	a3,0(s0)
ffffffffc02035c6:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02035c8:	0532                	slli	a0,a0,0xc
ffffffffc02035ca:	14e7f263          	bgeu	a5,a4,ffffffffc020370e <get_pte+0x1b8>
ffffffffc02035ce:	000af797          	auipc	a5,0xaf
ffffffffc02035d2:	2e27b783          	ld	a5,738(a5) # ffffffffc02b28b0 <va_pa_offset>
ffffffffc02035d6:	6605                	lui	a2,0x1
ffffffffc02035d8:	4581                	li	a1,0
ffffffffc02035da:	953e                	add	a0,a0,a5
ffffffffc02035dc:	3cf020ef          	jal	ra,ffffffffc02061aa <memset>
    return page - pages + nbase;
ffffffffc02035e0:	000b3683          	ld	a3,0(s6)
ffffffffc02035e4:	40d406b3          	sub	a3,s0,a3
ffffffffc02035e8:	8699                	srai	a3,a3,0x6
ffffffffc02035ea:	96d6                	add	a3,a3,s5
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02035ec:	06aa                	slli	a3,a3,0xa
ffffffffc02035ee:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02035f2:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02035f4:	77fd                	lui	a5,0xfffff
ffffffffc02035f6:	068a                	slli	a3,a3,0x2
ffffffffc02035f8:	000a3703          	ld	a4,0(s4)
ffffffffc02035fc:	8efd                	and	a3,a3,a5
ffffffffc02035fe:	00c6d793          	srli	a5,a3,0xc
ffffffffc0203602:	0ce7f163          	bgeu	a5,a4,ffffffffc02036c4 <get_pte+0x16e>
ffffffffc0203606:	000afa97          	auipc	s5,0xaf
ffffffffc020360a:	2aaa8a93          	addi	s5,s5,682 # ffffffffc02b28b0 <va_pa_offset>
ffffffffc020360e:	000ab403          	ld	s0,0(s5)
ffffffffc0203612:	01595793          	srli	a5,s2,0x15
ffffffffc0203616:	1ff7f793          	andi	a5,a5,511
ffffffffc020361a:	96a2                	add	a3,a3,s0
ffffffffc020361c:	00379413          	slli	s0,a5,0x3
ffffffffc0203620:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0203622:	6014                	ld	a3,0(s0)
ffffffffc0203624:	0016f793          	andi	a5,a3,1
ffffffffc0203628:	e3ad                	bnez	a5,ffffffffc020368a <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc020362a:	08098b63          	beqz	s3,ffffffffc02036c0 <get_pte+0x16a>
ffffffffc020362e:	4505                	li	a0,1
ffffffffc0203630:	e1bff0ef          	jal	ra,ffffffffc020344a <alloc_pages>
ffffffffc0203634:	84aa                	mv	s1,a0
ffffffffc0203636:	c549                	beqz	a0,ffffffffc02036c0 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0203638:	000afb17          	auipc	s6,0xaf
ffffffffc020363c:	268b0b13          	addi	s6,s6,616 # ffffffffc02b28a0 <pages>
ffffffffc0203640:	000b3503          	ld	a0,0(s6)
ffffffffc0203644:	000809b7          	lui	s3,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0203648:	000a3703          	ld	a4,0(s4)
ffffffffc020364c:	40a48533          	sub	a0,s1,a0
ffffffffc0203650:	8519                	srai	a0,a0,0x6
ffffffffc0203652:	954e                	add	a0,a0,s3
ffffffffc0203654:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0203658:	4685                	li	a3,1
ffffffffc020365a:	c094                	sw	a3,0(s1)
ffffffffc020365c:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020365e:	0532                	slli	a0,a0,0xc
ffffffffc0203660:	08e7fa63          	bgeu	a5,a4,ffffffffc02036f4 <get_pte+0x19e>
ffffffffc0203664:	000ab783          	ld	a5,0(s5)
ffffffffc0203668:	6605                	lui	a2,0x1
ffffffffc020366a:	4581                	li	a1,0
ffffffffc020366c:	953e                	add	a0,a0,a5
ffffffffc020366e:	33d020ef          	jal	ra,ffffffffc02061aa <memset>
    return page - pages + nbase;
ffffffffc0203672:	000b3683          	ld	a3,0(s6)
ffffffffc0203676:	40d486b3          	sub	a3,s1,a3
ffffffffc020367a:	8699                	srai	a3,a3,0x6
ffffffffc020367c:	96ce                	add	a3,a3,s3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020367e:	06aa                	slli	a3,a3,0xa
ffffffffc0203680:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0203684:	e014                	sd	a3,0(s0)
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0203686:	000a3703          	ld	a4,0(s4)
ffffffffc020368a:	068a                	slli	a3,a3,0x2
ffffffffc020368c:	757d                	lui	a0,0xfffff
ffffffffc020368e:	8ee9                	and	a3,a3,a0
ffffffffc0203690:	00c6d793          	srli	a5,a3,0xc
ffffffffc0203694:	04e7f463          	bgeu	a5,a4,ffffffffc02036dc <get_pte+0x186>
ffffffffc0203698:	000ab503          	ld	a0,0(s5)
ffffffffc020369c:	00c95913          	srli	s2,s2,0xc
ffffffffc02036a0:	1ff97913          	andi	s2,s2,511
ffffffffc02036a4:	96aa                	add	a3,a3,a0
ffffffffc02036a6:	00391513          	slli	a0,s2,0x3
ffffffffc02036aa:	9536                	add	a0,a0,a3
}
ffffffffc02036ac:	70e2                	ld	ra,56(sp)
ffffffffc02036ae:	7442                	ld	s0,48(sp)
ffffffffc02036b0:	74a2                	ld	s1,40(sp)
ffffffffc02036b2:	7902                	ld	s2,32(sp)
ffffffffc02036b4:	69e2                	ld	s3,24(sp)
ffffffffc02036b6:	6a42                	ld	s4,16(sp)
ffffffffc02036b8:	6aa2                	ld	s5,8(sp)
ffffffffc02036ba:	6b02                	ld	s6,0(sp)
ffffffffc02036bc:	6121                	addi	sp,sp,64
ffffffffc02036be:	8082                	ret
            return NULL;
ffffffffc02036c0:	4501                	li	a0,0
ffffffffc02036c2:	b7ed                	j	ffffffffc02036ac <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02036c4:	00004617          	auipc	a2,0x4
ffffffffc02036c8:	b9c60613          	addi	a2,a2,-1124 # ffffffffc0207260 <commands+0x9e0>
ffffffffc02036cc:	0e300593          	li	a1,227
ffffffffc02036d0:	00004517          	auipc	a0,0x4
ffffffffc02036d4:	6a050513          	addi	a0,a0,1696 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc02036d8:	b31fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02036dc:	00004617          	auipc	a2,0x4
ffffffffc02036e0:	b8460613          	addi	a2,a2,-1148 # ffffffffc0207260 <commands+0x9e0>
ffffffffc02036e4:	0ee00593          	li	a1,238
ffffffffc02036e8:	00004517          	auipc	a0,0x4
ffffffffc02036ec:	68850513          	addi	a0,a0,1672 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc02036f0:	b19fc0ef          	jal	ra,ffffffffc0200208 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02036f4:	86aa                	mv	a3,a0
ffffffffc02036f6:	00004617          	auipc	a2,0x4
ffffffffc02036fa:	b6a60613          	addi	a2,a2,-1174 # ffffffffc0207260 <commands+0x9e0>
ffffffffc02036fe:	0eb00593          	li	a1,235
ffffffffc0203702:	00004517          	auipc	a0,0x4
ffffffffc0203706:	66e50513          	addi	a0,a0,1646 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc020370a:	afffc0ef          	jal	ra,ffffffffc0200208 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020370e:	86aa                	mv	a3,a0
ffffffffc0203710:	00004617          	auipc	a2,0x4
ffffffffc0203714:	b5060613          	addi	a2,a2,-1200 # ffffffffc0207260 <commands+0x9e0>
ffffffffc0203718:	0df00593          	li	a1,223
ffffffffc020371c:	00004517          	auipc	a0,0x4
ffffffffc0203720:	65450513          	addi	a0,a0,1620 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc0203724:	ae5fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0203728 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0203728:	1141                	addi	sp,sp,-16
ffffffffc020372a:	e022                	sd	s0,0(sp)
ffffffffc020372c:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020372e:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0203730:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0203732:	e25ff0ef          	jal	ra,ffffffffc0203556 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0203736:	c011                	beqz	s0,ffffffffc020373a <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0203738:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc020373a:	c511                	beqz	a0,ffffffffc0203746 <get_page+0x1e>
ffffffffc020373c:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc020373e:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0203740:	0017f713          	andi	a4,a5,1
ffffffffc0203744:	e709                	bnez	a4,ffffffffc020374e <get_page+0x26>
}
ffffffffc0203746:	60a2                	ld	ra,8(sp)
ffffffffc0203748:	6402                	ld	s0,0(sp)
ffffffffc020374a:	0141                	addi	sp,sp,16
ffffffffc020374c:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc020374e:	078a                	slli	a5,a5,0x2
ffffffffc0203750:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203752:	000af717          	auipc	a4,0xaf
ffffffffc0203756:	14673703          	ld	a4,326(a4) # ffffffffc02b2898 <npage>
ffffffffc020375a:	00e7ff63          	bgeu	a5,a4,ffffffffc0203778 <get_page+0x50>
ffffffffc020375e:	60a2                	ld	ra,8(sp)
ffffffffc0203760:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc0203762:	fff80537          	lui	a0,0xfff80
ffffffffc0203766:	97aa                	add	a5,a5,a0
ffffffffc0203768:	079a                	slli	a5,a5,0x6
ffffffffc020376a:	000af517          	auipc	a0,0xaf
ffffffffc020376e:	13653503          	ld	a0,310(a0) # ffffffffc02b28a0 <pages>
ffffffffc0203772:	953e                	add	a0,a0,a5
ffffffffc0203774:	0141                	addi	sp,sp,16
ffffffffc0203776:	8082                	ret
ffffffffc0203778:	c9bff0ef          	jal	ra,ffffffffc0203412 <pa2page.part.0>

ffffffffc020377c <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc020377c:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020377e:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0203782:	f486                	sd	ra,104(sp)
ffffffffc0203784:	f0a2                	sd	s0,96(sp)
ffffffffc0203786:	eca6                	sd	s1,88(sp)
ffffffffc0203788:	e8ca                	sd	s2,80(sp)
ffffffffc020378a:	e4ce                	sd	s3,72(sp)
ffffffffc020378c:	e0d2                	sd	s4,64(sp)
ffffffffc020378e:	fc56                	sd	s5,56(sp)
ffffffffc0203790:	f85a                	sd	s6,48(sp)
ffffffffc0203792:	f45e                	sd	s7,40(sp)
ffffffffc0203794:	f062                	sd	s8,32(sp)
ffffffffc0203796:	ec66                	sd	s9,24(sp)
ffffffffc0203798:	e86a                	sd	s10,16(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020379a:	17d2                	slli	a5,a5,0x34
ffffffffc020379c:	e3ed                	bnez	a5,ffffffffc020387e <unmap_range+0x102>
    assert(USER_ACCESS(start, end));
ffffffffc020379e:	002007b7          	lui	a5,0x200
ffffffffc02037a2:	842e                	mv	s0,a1
ffffffffc02037a4:	0ef5ed63          	bltu	a1,a5,ffffffffc020389e <unmap_range+0x122>
ffffffffc02037a8:	8932                	mv	s2,a2
ffffffffc02037aa:	0ec5fa63          	bgeu	a1,a2,ffffffffc020389e <unmap_range+0x122>
ffffffffc02037ae:	4785                	li	a5,1
ffffffffc02037b0:	07fe                	slli	a5,a5,0x1f
ffffffffc02037b2:	0ec7e663          	bltu	a5,a2,ffffffffc020389e <unmap_range+0x122>
ffffffffc02037b6:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc02037b8:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc02037ba:	000afc97          	auipc	s9,0xaf
ffffffffc02037be:	0dec8c93          	addi	s9,s9,222 # ffffffffc02b2898 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02037c2:	000afc17          	auipc	s8,0xaf
ffffffffc02037c6:	0dec0c13          	addi	s8,s8,222 # ffffffffc02b28a0 <pages>
ffffffffc02037ca:	fff80bb7          	lui	s7,0xfff80
        pmm_manager->free_pages(base, n);
ffffffffc02037ce:	000afd17          	auipc	s10,0xaf
ffffffffc02037d2:	0dad0d13          	addi	s10,s10,218 # ffffffffc02b28a8 <pmm_manager>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02037d6:	00200b37          	lui	s6,0x200
ffffffffc02037da:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc02037de:	4601                	li	a2,0
ffffffffc02037e0:	85a2                	mv	a1,s0
ffffffffc02037e2:	854e                	mv	a0,s3
ffffffffc02037e4:	d73ff0ef          	jal	ra,ffffffffc0203556 <get_pte>
ffffffffc02037e8:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc02037ea:	cd29                	beqz	a0,ffffffffc0203844 <unmap_range+0xc8>
        if (*ptep != 0) {
ffffffffc02037ec:	611c                	ld	a5,0(a0)
ffffffffc02037ee:	e395                	bnez	a5,ffffffffc0203812 <unmap_range+0x96>
        start += PGSIZE;
ffffffffc02037f0:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc02037f2:	ff2466e3          	bltu	s0,s2,ffffffffc02037de <unmap_range+0x62>
}
ffffffffc02037f6:	70a6                	ld	ra,104(sp)
ffffffffc02037f8:	7406                	ld	s0,96(sp)
ffffffffc02037fa:	64e6                	ld	s1,88(sp)
ffffffffc02037fc:	6946                	ld	s2,80(sp)
ffffffffc02037fe:	69a6                	ld	s3,72(sp)
ffffffffc0203800:	6a06                	ld	s4,64(sp)
ffffffffc0203802:	7ae2                	ld	s5,56(sp)
ffffffffc0203804:	7b42                	ld	s6,48(sp)
ffffffffc0203806:	7ba2                	ld	s7,40(sp)
ffffffffc0203808:	7c02                	ld	s8,32(sp)
ffffffffc020380a:	6ce2                	ld	s9,24(sp)
ffffffffc020380c:	6d42                	ld	s10,16(sp)
ffffffffc020380e:	6165                	addi	sp,sp,112
ffffffffc0203810:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0203812:	0017f713          	andi	a4,a5,1
ffffffffc0203816:	df69                	beqz	a4,ffffffffc02037f0 <unmap_range+0x74>
    if (PPN(pa) >= npage) {
ffffffffc0203818:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020381c:	078a                	slli	a5,a5,0x2
ffffffffc020381e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203820:	08e7ff63          	bgeu	a5,a4,ffffffffc02038be <unmap_range+0x142>
    return &pages[PPN(pa) - nbase];
ffffffffc0203824:	000c3503          	ld	a0,0(s8)
ffffffffc0203828:	97de                	add	a5,a5,s7
ffffffffc020382a:	079a                	slli	a5,a5,0x6
ffffffffc020382c:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020382e:	411c                	lw	a5,0(a0)
ffffffffc0203830:	fff7871b          	addiw	a4,a5,-1
ffffffffc0203834:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0203836:	cf11                	beqz	a4,ffffffffc0203852 <unmap_range+0xd6>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0203838:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020383c:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc0203840:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0203842:	bf45                	j	ffffffffc02037f2 <unmap_range+0x76>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0203844:	945a                	add	s0,s0,s6
ffffffffc0203846:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc020384a:	d455                	beqz	s0,ffffffffc02037f6 <unmap_range+0x7a>
ffffffffc020384c:	f92469e3          	bltu	s0,s2,ffffffffc02037de <unmap_range+0x62>
ffffffffc0203850:	b75d                	j	ffffffffc02037f6 <unmap_range+0x7a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203852:	100027f3          	csrr	a5,sstatus
ffffffffc0203856:	8b89                	andi	a5,a5,2
ffffffffc0203858:	e799                	bnez	a5,ffffffffc0203866 <unmap_range+0xea>
        pmm_manager->free_pages(base, n);
ffffffffc020385a:	000d3783          	ld	a5,0(s10)
ffffffffc020385e:	4585                	li	a1,1
ffffffffc0203860:	739c                	ld	a5,32(a5)
ffffffffc0203862:	9782                	jalr	a5
    if (flag) {
ffffffffc0203864:	bfd1                	j	ffffffffc0203838 <unmap_range+0xbc>
ffffffffc0203866:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203868:	de1fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc020386c:	000d3783          	ld	a5,0(s10)
ffffffffc0203870:	6522                	ld	a0,8(sp)
ffffffffc0203872:	4585                	li	a1,1
ffffffffc0203874:	739c                	ld	a5,32(a5)
ffffffffc0203876:	9782                	jalr	a5
        intr_enable();
ffffffffc0203878:	dcbfc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc020387c:	bf75                	j	ffffffffc0203838 <unmap_range+0xbc>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020387e:	00004697          	auipc	a3,0x4
ffffffffc0203882:	50268693          	addi	a3,a3,1282 # ffffffffc0207d80 <default_pmm_manager+0x48>
ffffffffc0203886:	00003617          	auipc	a2,0x3
ffffffffc020388a:	40a60613          	addi	a2,a2,1034 # ffffffffc0206c90 <commands+0x410>
ffffffffc020388e:	10f00593          	li	a1,271
ffffffffc0203892:	00004517          	auipc	a0,0x4
ffffffffc0203896:	4de50513          	addi	a0,a0,1246 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc020389a:	96ffc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc020389e:	00004697          	auipc	a3,0x4
ffffffffc02038a2:	51268693          	addi	a3,a3,1298 # ffffffffc0207db0 <default_pmm_manager+0x78>
ffffffffc02038a6:	00003617          	auipc	a2,0x3
ffffffffc02038aa:	3ea60613          	addi	a2,a2,1002 # ffffffffc0206c90 <commands+0x410>
ffffffffc02038ae:	11000593          	li	a1,272
ffffffffc02038b2:	00004517          	auipc	a0,0x4
ffffffffc02038b6:	4be50513          	addi	a0,a0,1214 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc02038ba:	94ffc0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc02038be:	b55ff0ef          	jal	ra,ffffffffc0203412 <pa2page.part.0>

ffffffffc02038c2 <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02038c2:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02038c4:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02038c8:	fc86                	sd	ra,120(sp)
ffffffffc02038ca:	f8a2                	sd	s0,112(sp)
ffffffffc02038cc:	f4a6                	sd	s1,104(sp)
ffffffffc02038ce:	f0ca                	sd	s2,96(sp)
ffffffffc02038d0:	ecce                	sd	s3,88(sp)
ffffffffc02038d2:	e8d2                	sd	s4,80(sp)
ffffffffc02038d4:	e4d6                	sd	s5,72(sp)
ffffffffc02038d6:	e0da                	sd	s6,64(sp)
ffffffffc02038d8:	fc5e                	sd	s7,56(sp)
ffffffffc02038da:	f862                	sd	s8,48(sp)
ffffffffc02038dc:	f466                	sd	s9,40(sp)
ffffffffc02038de:	f06a                	sd	s10,32(sp)
ffffffffc02038e0:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02038e2:	17d2                	slli	a5,a5,0x34
ffffffffc02038e4:	20079a63          	bnez	a5,ffffffffc0203af8 <exit_range+0x236>
    assert(USER_ACCESS(start, end));
ffffffffc02038e8:	002007b7          	lui	a5,0x200
ffffffffc02038ec:	24f5e463          	bltu	a1,a5,ffffffffc0203b34 <exit_range+0x272>
ffffffffc02038f0:	8ab2                	mv	s5,a2
ffffffffc02038f2:	24c5f163          	bgeu	a1,a2,ffffffffc0203b34 <exit_range+0x272>
ffffffffc02038f6:	4785                	li	a5,1
ffffffffc02038f8:	07fe                	slli	a5,a5,0x1f
ffffffffc02038fa:	22c7ed63          	bltu	a5,a2,ffffffffc0203b34 <exit_range+0x272>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc02038fe:	c00009b7          	lui	s3,0xc0000
ffffffffc0203902:	0135f9b3          	and	s3,a1,s3
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0203906:	ffe00937          	lui	s2,0xffe00
ffffffffc020390a:	400007b7          	lui	a5,0x40000
    return KADDR(page2pa(page));
ffffffffc020390e:	5cfd                	li	s9,-1
ffffffffc0203910:	8c2a                	mv	s8,a0
ffffffffc0203912:	0125f933          	and	s2,a1,s2
ffffffffc0203916:	99be                	add	s3,s3,a5
    if (PPN(pa) >= npage) {
ffffffffc0203918:	000afd17          	auipc	s10,0xaf
ffffffffc020391c:	f80d0d13          	addi	s10,s10,-128 # ffffffffc02b2898 <npage>
    return KADDR(page2pa(page));
ffffffffc0203920:	00ccdc93          	srli	s9,s9,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0203924:	000af717          	auipc	a4,0xaf
ffffffffc0203928:	f7c70713          	addi	a4,a4,-132 # ffffffffc02b28a0 <pages>
        pmm_manager->free_pages(base, n);
ffffffffc020392c:	000afd97          	auipc	s11,0xaf
ffffffffc0203930:	f7cd8d93          	addi	s11,s11,-132 # ffffffffc02b28a8 <pmm_manager>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc0203934:	c0000437          	lui	s0,0xc0000
ffffffffc0203938:	944e                	add	s0,s0,s3
ffffffffc020393a:	8079                	srli	s0,s0,0x1e
ffffffffc020393c:	1ff47413          	andi	s0,s0,511
ffffffffc0203940:	040e                	slli	s0,s0,0x3
ffffffffc0203942:	9462                	add	s0,s0,s8
ffffffffc0203944:	00043a03          	ld	s4,0(s0) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ed8>
        if (pde1&PTE_V){
ffffffffc0203948:	001a7793          	andi	a5,s4,1
ffffffffc020394c:	eb99                	bnez	a5,ffffffffc0203962 <exit_range+0xa0>
    } while (d1start != 0 && d1start < end);
ffffffffc020394e:	12098463          	beqz	s3,ffffffffc0203a76 <exit_range+0x1b4>
ffffffffc0203952:	400007b7          	lui	a5,0x40000
ffffffffc0203956:	97ce                	add	a5,a5,s3
ffffffffc0203958:	894e                	mv	s2,s3
ffffffffc020395a:	1159fe63          	bgeu	s3,s5,ffffffffc0203a76 <exit_range+0x1b4>
ffffffffc020395e:	89be                	mv	s3,a5
ffffffffc0203960:	bfd1                	j	ffffffffc0203934 <exit_range+0x72>
    if (PPN(pa) >= npage) {
ffffffffc0203962:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203966:	0a0a                	slli	s4,s4,0x2
ffffffffc0203968:	00ca5a13          	srli	s4,s4,0xc
    if (PPN(pa) >= npage) {
ffffffffc020396c:	1cfa7263          	bgeu	s4,a5,ffffffffc0203b30 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0203970:	fff80637          	lui	a2,0xfff80
ffffffffc0203974:	9652                	add	a2,a2,s4
    return page - pages + nbase;
ffffffffc0203976:	000806b7          	lui	a3,0x80
ffffffffc020397a:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc020397c:	0196f5b3          	and	a1,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc0203980:	061a                	slli	a2,a2,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0203982:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203984:	18f5fa63          	bgeu	a1,a5,ffffffffc0203b18 <exit_range+0x256>
ffffffffc0203988:	000af817          	auipc	a6,0xaf
ffffffffc020398c:	f2880813          	addi	a6,a6,-216 # ffffffffc02b28b0 <va_pa_offset>
ffffffffc0203990:	00083b03          	ld	s6,0(a6)
            free_pd0 = 1;
ffffffffc0203994:	4b85                	li	s7,1
    return &pages[PPN(pa) - nbase];
ffffffffc0203996:	fff80e37          	lui	t3,0xfff80
    return KADDR(page2pa(page));
ffffffffc020399a:	9b36                	add	s6,s6,a3
    return page - pages + nbase;
ffffffffc020399c:	00080337          	lui	t1,0x80
ffffffffc02039a0:	6885                	lui	a7,0x1
ffffffffc02039a2:	a819                	j	ffffffffc02039b8 <exit_range+0xf6>
                    free_pd0 = 0;
ffffffffc02039a4:	4b81                	li	s7,0
                d0start += PTSIZE;
ffffffffc02039a6:	002007b7          	lui	a5,0x200
ffffffffc02039aa:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc02039ac:	08090c63          	beqz	s2,ffffffffc0203a44 <exit_range+0x182>
ffffffffc02039b0:	09397a63          	bgeu	s2,s3,ffffffffc0203a44 <exit_range+0x182>
ffffffffc02039b4:	0f597063          	bgeu	s2,s5,ffffffffc0203a94 <exit_range+0x1d2>
                pde0 = pd0[PDX0(d0start)];
ffffffffc02039b8:	01595493          	srli	s1,s2,0x15
ffffffffc02039bc:	1ff4f493          	andi	s1,s1,511
ffffffffc02039c0:	048e                	slli	s1,s1,0x3
ffffffffc02039c2:	94da                	add	s1,s1,s6
ffffffffc02039c4:	609c                	ld	a5,0(s1)
                if (pde0&PTE_V) {
ffffffffc02039c6:	0017f693          	andi	a3,a5,1
ffffffffc02039ca:	dee9                	beqz	a3,ffffffffc02039a4 <exit_range+0xe2>
    if (PPN(pa) >= npage) {
ffffffffc02039cc:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc02039d0:	078a                	slli	a5,a5,0x2
ffffffffc02039d2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02039d4:	14b7fe63          	bgeu	a5,a1,ffffffffc0203b30 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc02039d8:	97f2                	add	a5,a5,t3
    return page - pages + nbase;
ffffffffc02039da:	006786b3          	add	a3,a5,t1
    return KADDR(page2pa(page));
ffffffffc02039de:	0196feb3          	and	t4,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc02039e2:	00679513          	slli	a0,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc02039e6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02039e8:	12bef863          	bgeu	t4,a1,ffffffffc0203b18 <exit_range+0x256>
ffffffffc02039ec:	00083783          	ld	a5,0(a6)
ffffffffc02039f0:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc02039f2:	011685b3          	add	a1,a3,a7
                        if (pt[i]&PTE_V){
ffffffffc02039f6:	629c                	ld	a5,0(a3)
ffffffffc02039f8:	8b85                	andi	a5,a5,1
ffffffffc02039fa:	f7d5                	bnez	a5,ffffffffc02039a6 <exit_range+0xe4>
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc02039fc:	06a1                	addi	a3,a3,8
ffffffffc02039fe:	fed59ce3          	bne	a1,a3,ffffffffc02039f6 <exit_range+0x134>
    return &pages[PPN(pa) - nbase];
ffffffffc0203a02:	631c                	ld	a5,0(a4)
ffffffffc0203a04:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203a06:	100027f3          	csrr	a5,sstatus
ffffffffc0203a0a:	8b89                	andi	a5,a5,2
ffffffffc0203a0c:	e7d9                	bnez	a5,ffffffffc0203a9a <exit_range+0x1d8>
        pmm_manager->free_pages(base, n);
ffffffffc0203a0e:	000db783          	ld	a5,0(s11)
ffffffffc0203a12:	4585                	li	a1,1
ffffffffc0203a14:	e032                	sd	a2,0(sp)
ffffffffc0203a16:	739c                	ld	a5,32(a5)
ffffffffc0203a18:	9782                	jalr	a5
    if (flag) {
ffffffffc0203a1a:	6602                	ld	a2,0(sp)
ffffffffc0203a1c:	000af817          	auipc	a6,0xaf
ffffffffc0203a20:	e9480813          	addi	a6,a6,-364 # ffffffffc02b28b0 <va_pa_offset>
ffffffffc0203a24:	fff80e37          	lui	t3,0xfff80
ffffffffc0203a28:	00080337          	lui	t1,0x80
ffffffffc0203a2c:	6885                	lui	a7,0x1
ffffffffc0203a2e:	000af717          	auipc	a4,0xaf
ffffffffc0203a32:	e7270713          	addi	a4,a4,-398 # ffffffffc02b28a0 <pages>
                        pd0[PDX0(d0start)] = 0;
ffffffffc0203a36:	0004b023          	sd	zero,0(s1)
                d0start += PTSIZE;
ffffffffc0203a3a:	002007b7          	lui	a5,0x200
ffffffffc0203a3e:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0203a40:	f60918e3          	bnez	s2,ffffffffc02039b0 <exit_range+0xee>
            if (free_pd0) {
ffffffffc0203a44:	f00b85e3          	beqz	s7,ffffffffc020394e <exit_range+0x8c>
    if (PPN(pa) >= npage) {
ffffffffc0203a48:	000d3783          	ld	a5,0(s10)
ffffffffc0203a4c:	0efa7263          	bgeu	s4,a5,ffffffffc0203b30 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0203a50:	6308                	ld	a0,0(a4)
ffffffffc0203a52:	9532                	add	a0,a0,a2
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203a54:	100027f3          	csrr	a5,sstatus
ffffffffc0203a58:	8b89                	andi	a5,a5,2
ffffffffc0203a5a:	efad                	bnez	a5,ffffffffc0203ad4 <exit_range+0x212>
        pmm_manager->free_pages(base, n);
ffffffffc0203a5c:	000db783          	ld	a5,0(s11)
ffffffffc0203a60:	4585                	li	a1,1
ffffffffc0203a62:	739c                	ld	a5,32(a5)
ffffffffc0203a64:	9782                	jalr	a5
ffffffffc0203a66:	000af717          	auipc	a4,0xaf
ffffffffc0203a6a:	e3a70713          	addi	a4,a4,-454 # ffffffffc02b28a0 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0203a6e:	00043023          	sd	zero,0(s0)
    } while (d1start != 0 && d1start < end);
ffffffffc0203a72:	ee0990e3          	bnez	s3,ffffffffc0203952 <exit_range+0x90>
}
ffffffffc0203a76:	70e6                	ld	ra,120(sp)
ffffffffc0203a78:	7446                	ld	s0,112(sp)
ffffffffc0203a7a:	74a6                	ld	s1,104(sp)
ffffffffc0203a7c:	7906                	ld	s2,96(sp)
ffffffffc0203a7e:	69e6                	ld	s3,88(sp)
ffffffffc0203a80:	6a46                	ld	s4,80(sp)
ffffffffc0203a82:	6aa6                	ld	s5,72(sp)
ffffffffc0203a84:	6b06                	ld	s6,64(sp)
ffffffffc0203a86:	7be2                	ld	s7,56(sp)
ffffffffc0203a88:	7c42                	ld	s8,48(sp)
ffffffffc0203a8a:	7ca2                	ld	s9,40(sp)
ffffffffc0203a8c:	7d02                	ld	s10,32(sp)
ffffffffc0203a8e:	6de2                	ld	s11,24(sp)
ffffffffc0203a90:	6109                	addi	sp,sp,128
ffffffffc0203a92:	8082                	ret
            if (free_pd0) {
ffffffffc0203a94:	ea0b8fe3          	beqz	s7,ffffffffc0203952 <exit_range+0x90>
ffffffffc0203a98:	bf45                	j	ffffffffc0203a48 <exit_range+0x186>
ffffffffc0203a9a:	e032                	sd	a2,0(sp)
        intr_disable();
ffffffffc0203a9c:	e42a                	sd	a0,8(sp)
ffffffffc0203a9e:	babfc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203aa2:	000db783          	ld	a5,0(s11)
ffffffffc0203aa6:	6522                	ld	a0,8(sp)
ffffffffc0203aa8:	4585                	li	a1,1
ffffffffc0203aaa:	739c                	ld	a5,32(a5)
ffffffffc0203aac:	9782                	jalr	a5
        intr_enable();
ffffffffc0203aae:	b95fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0203ab2:	6602                	ld	a2,0(sp)
ffffffffc0203ab4:	000af717          	auipc	a4,0xaf
ffffffffc0203ab8:	dec70713          	addi	a4,a4,-532 # ffffffffc02b28a0 <pages>
ffffffffc0203abc:	6885                	lui	a7,0x1
ffffffffc0203abe:	00080337          	lui	t1,0x80
ffffffffc0203ac2:	fff80e37          	lui	t3,0xfff80
ffffffffc0203ac6:	000af817          	auipc	a6,0xaf
ffffffffc0203aca:	dea80813          	addi	a6,a6,-534 # ffffffffc02b28b0 <va_pa_offset>
                        pd0[PDX0(d0start)] = 0;
ffffffffc0203ace:	0004b023          	sd	zero,0(s1)
ffffffffc0203ad2:	b7a5                	j	ffffffffc0203a3a <exit_range+0x178>
ffffffffc0203ad4:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc0203ad6:	b73fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203ada:	000db783          	ld	a5,0(s11)
ffffffffc0203ade:	6502                	ld	a0,0(sp)
ffffffffc0203ae0:	4585                	li	a1,1
ffffffffc0203ae2:	739c                	ld	a5,32(a5)
ffffffffc0203ae4:	9782                	jalr	a5
        intr_enable();
ffffffffc0203ae6:	b5dfc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0203aea:	000af717          	auipc	a4,0xaf
ffffffffc0203aee:	db670713          	addi	a4,a4,-586 # ffffffffc02b28a0 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0203af2:	00043023          	sd	zero,0(s0)
ffffffffc0203af6:	bfb5                	j	ffffffffc0203a72 <exit_range+0x1b0>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203af8:	00004697          	auipc	a3,0x4
ffffffffc0203afc:	28868693          	addi	a3,a3,648 # ffffffffc0207d80 <default_pmm_manager+0x48>
ffffffffc0203b00:	00003617          	auipc	a2,0x3
ffffffffc0203b04:	19060613          	addi	a2,a2,400 # ffffffffc0206c90 <commands+0x410>
ffffffffc0203b08:	12000593          	li	a1,288
ffffffffc0203b0c:	00004517          	auipc	a0,0x4
ffffffffc0203b10:	26450513          	addi	a0,a0,612 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc0203b14:	ef4fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203b18:	00003617          	auipc	a2,0x3
ffffffffc0203b1c:	74860613          	addi	a2,a2,1864 # ffffffffc0207260 <commands+0x9e0>
ffffffffc0203b20:	06900593          	li	a1,105
ffffffffc0203b24:	00003517          	auipc	a0,0x3
ffffffffc0203b28:	72c50513          	addi	a0,a0,1836 # ffffffffc0207250 <commands+0x9d0>
ffffffffc0203b2c:	edcfc0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0203b30:	8e3ff0ef          	jal	ra,ffffffffc0203412 <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc0203b34:	00004697          	auipc	a3,0x4
ffffffffc0203b38:	27c68693          	addi	a3,a3,636 # ffffffffc0207db0 <default_pmm_manager+0x78>
ffffffffc0203b3c:	00003617          	auipc	a2,0x3
ffffffffc0203b40:	15460613          	addi	a2,a2,340 # ffffffffc0206c90 <commands+0x410>
ffffffffc0203b44:	12100593          	li	a1,289
ffffffffc0203b48:	00004517          	auipc	a0,0x4
ffffffffc0203b4c:	22850513          	addi	a0,a0,552 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc0203b50:	eb8fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0203b54 <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0203b54:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0203b56:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0203b58:	ec26                	sd	s1,24(sp)
ffffffffc0203b5a:	f406                	sd	ra,40(sp)
ffffffffc0203b5c:	f022                	sd	s0,32(sp)
ffffffffc0203b5e:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0203b60:	9f7ff0ef          	jal	ra,ffffffffc0203556 <get_pte>
    if (ptep != NULL) {
ffffffffc0203b64:	c511                	beqz	a0,ffffffffc0203b70 <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0203b66:	611c                	ld	a5,0(a0)
ffffffffc0203b68:	842a                	mv	s0,a0
ffffffffc0203b6a:	0017f713          	andi	a4,a5,1
ffffffffc0203b6e:	e711                	bnez	a4,ffffffffc0203b7a <page_remove+0x26>
}
ffffffffc0203b70:	70a2                	ld	ra,40(sp)
ffffffffc0203b72:	7402                	ld	s0,32(sp)
ffffffffc0203b74:	64e2                	ld	s1,24(sp)
ffffffffc0203b76:	6145                	addi	sp,sp,48
ffffffffc0203b78:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0203b7a:	078a                	slli	a5,a5,0x2
ffffffffc0203b7c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203b7e:	000af717          	auipc	a4,0xaf
ffffffffc0203b82:	d1a73703          	ld	a4,-742(a4) # ffffffffc02b2898 <npage>
ffffffffc0203b86:	06e7f363          	bgeu	a5,a4,ffffffffc0203bec <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc0203b8a:	fff80537          	lui	a0,0xfff80
ffffffffc0203b8e:	97aa                	add	a5,a5,a0
ffffffffc0203b90:	079a                	slli	a5,a5,0x6
ffffffffc0203b92:	000af517          	auipc	a0,0xaf
ffffffffc0203b96:	d0e53503          	ld	a0,-754(a0) # ffffffffc02b28a0 <pages>
ffffffffc0203b9a:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0203b9c:	411c                	lw	a5,0(a0)
ffffffffc0203b9e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0203ba2:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0203ba4:	cb11                	beqz	a4,ffffffffc0203bb8 <page_remove+0x64>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0203ba6:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203baa:	12048073          	sfence.vma	s1
}
ffffffffc0203bae:	70a2                	ld	ra,40(sp)
ffffffffc0203bb0:	7402                	ld	s0,32(sp)
ffffffffc0203bb2:	64e2                	ld	s1,24(sp)
ffffffffc0203bb4:	6145                	addi	sp,sp,48
ffffffffc0203bb6:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203bb8:	100027f3          	csrr	a5,sstatus
ffffffffc0203bbc:	8b89                	andi	a5,a5,2
ffffffffc0203bbe:	eb89                	bnez	a5,ffffffffc0203bd0 <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc0203bc0:	000af797          	auipc	a5,0xaf
ffffffffc0203bc4:	ce87b783          	ld	a5,-792(a5) # ffffffffc02b28a8 <pmm_manager>
ffffffffc0203bc8:	739c                	ld	a5,32(a5)
ffffffffc0203bca:	4585                	li	a1,1
ffffffffc0203bcc:	9782                	jalr	a5
    if (flag) {
ffffffffc0203bce:	bfe1                	j	ffffffffc0203ba6 <page_remove+0x52>
        intr_disable();
ffffffffc0203bd0:	e42a                	sd	a0,8(sp)
ffffffffc0203bd2:	a77fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc0203bd6:	000af797          	auipc	a5,0xaf
ffffffffc0203bda:	cd27b783          	ld	a5,-814(a5) # ffffffffc02b28a8 <pmm_manager>
ffffffffc0203bde:	739c                	ld	a5,32(a5)
ffffffffc0203be0:	6522                	ld	a0,8(sp)
ffffffffc0203be2:	4585                	li	a1,1
ffffffffc0203be4:	9782                	jalr	a5
        intr_enable();
ffffffffc0203be6:	a5dfc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0203bea:	bf75                	j	ffffffffc0203ba6 <page_remove+0x52>
ffffffffc0203bec:	827ff0ef          	jal	ra,ffffffffc0203412 <pa2page.part.0>

ffffffffc0203bf0 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0203bf0:	7139                	addi	sp,sp,-64
ffffffffc0203bf2:	e852                	sd	s4,16(sp)
ffffffffc0203bf4:	8a32                	mv	s4,a2
ffffffffc0203bf6:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0203bf8:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0203bfa:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0203bfc:	85d2                	mv	a1,s4
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0203bfe:	f426                	sd	s1,40(sp)
ffffffffc0203c00:	fc06                	sd	ra,56(sp)
ffffffffc0203c02:	f04a                	sd	s2,32(sp)
ffffffffc0203c04:	ec4e                	sd	s3,24(sp)
ffffffffc0203c06:	e456                	sd	s5,8(sp)
ffffffffc0203c08:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0203c0a:	94dff0ef          	jal	ra,ffffffffc0203556 <get_pte>
    if (ptep == NULL) {
ffffffffc0203c0e:	c961                	beqz	a0,ffffffffc0203cde <page_insert+0xee>
    page->ref += 1;
ffffffffc0203c10:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0203c12:	611c                	ld	a5,0(a0)
ffffffffc0203c14:	89aa                	mv	s3,a0
ffffffffc0203c16:	0016871b          	addiw	a4,a3,1
ffffffffc0203c1a:	c018                	sw	a4,0(s0)
ffffffffc0203c1c:	0017f713          	andi	a4,a5,1
ffffffffc0203c20:	ef05                	bnez	a4,ffffffffc0203c58 <page_insert+0x68>
    return page - pages + nbase;
ffffffffc0203c22:	000af717          	auipc	a4,0xaf
ffffffffc0203c26:	c7e73703          	ld	a4,-898(a4) # ffffffffc02b28a0 <pages>
ffffffffc0203c2a:	8c19                	sub	s0,s0,a4
ffffffffc0203c2c:	000807b7          	lui	a5,0x80
ffffffffc0203c30:	8419                	srai	s0,s0,0x6
ffffffffc0203c32:	943e                	add	s0,s0,a5
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0203c34:	042a                	slli	s0,s0,0xa
ffffffffc0203c36:	8cc1                	or	s1,s1,s0
ffffffffc0203c38:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0203c3c:	0099b023          	sd	s1,0(s3) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ed8>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203c40:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc0203c44:	4501                	li	a0,0
}
ffffffffc0203c46:	70e2                	ld	ra,56(sp)
ffffffffc0203c48:	7442                	ld	s0,48(sp)
ffffffffc0203c4a:	74a2                	ld	s1,40(sp)
ffffffffc0203c4c:	7902                	ld	s2,32(sp)
ffffffffc0203c4e:	69e2                	ld	s3,24(sp)
ffffffffc0203c50:	6a42                	ld	s4,16(sp)
ffffffffc0203c52:	6aa2                	ld	s5,8(sp)
ffffffffc0203c54:	6121                	addi	sp,sp,64
ffffffffc0203c56:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0203c58:	078a                	slli	a5,a5,0x2
ffffffffc0203c5a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203c5c:	000af717          	auipc	a4,0xaf
ffffffffc0203c60:	c3c73703          	ld	a4,-964(a4) # ffffffffc02b2898 <npage>
ffffffffc0203c64:	06e7ff63          	bgeu	a5,a4,ffffffffc0203ce2 <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc0203c68:	000afa97          	auipc	s5,0xaf
ffffffffc0203c6c:	c38a8a93          	addi	s5,s5,-968 # ffffffffc02b28a0 <pages>
ffffffffc0203c70:	000ab703          	ld	a4,0(s5)
ffffffffc0203c74:	fff80937          	lui	s2,0xfff80
ffffffffc0203c78:	993e                	add	s2,s2,a5
ffffffffc0203c7a:	091a                	slli	s2,s2,0x6
ffffffffc0203c7c:	993a                	add	s2,s2,a4
        if (p == page) {
ffffffffc0203c7e:	01240c63          	beq	s0,s2,ffffffffc0203c96 <page_insert+0xa6>
    page->ref -= 1;
ffffffffc0203c82:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fccd72c>
ffffffffc0203c86:	fff7869b          	addiw	a3,a5,-1
ffffffffc0203c8a:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) ==
ffffffffc0203c8e:	c691                	beqz	a3,ffffffffc0203c9a <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203c90:	120a0073          	sfence.vma	s4
}
ffffffffc0203c94:	bf59                	j	ffffffffc0203c2a <page_insert+0x3a>
ffffffffc0203c96:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0203c98:	bf49                	j	ffffffffc0203c2a <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203c9a:	100027f3          	csrr	a5,sstatus
ffffffffc0203c9e:	8b89                	andi	a5,a5,2
ffffffffc0203ca0:	ef91                	bnez	a5,ffffffffc0203cbc <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc0203ca2:	000af797          	auipc	a5,0xaf
ffffffffc0203ca6:	c067b783          	ld	a5,-1018(a5) # ffffffffc02b28a8 <pmm_manager>
ffffffffc0203caa:	739c                	ld	a5,32(a5)
ffffffffc0203cac:	4585                	li	a1,1
ffffffffc0203cae:	854a                	mv	a0,s2
ffffffffc0203cb0:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc0203cb2:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203cb6:	120a0073          	sfence.vma	s4
ffffffffc0203cba:	bf85                	j	ffffffffc0203c2a <page_insert+0x3a>
        intr_disable();
ffffffffc0203cbc:	98dfc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203cc0:	000af797          	auipc	a5,0xaf
ffffffffc0203cc4:	be87b783          	ld	a5,-1048(a5) # ffffffffc02b28a8 <pmm_manager>
ffffffffc0203cc8:	739c                	ld	a5,32(a5)
ffffffffc0203cca:	4585                	li	a1,1
ffffffffc0203ccc:	854a                	mv	a0,s2
ffffffffc0203cce:	9782                	jalr	a5
        intr_enable();
ffffffffc0203cd0:	973fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0203cd4:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203cd8:	120a0073          	sfence.vma	s4
ffffffffc0203cdc:	b7b9                	j	ffffffffc0203c2a <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0203cde:	5571                	li	a0,-4
ffffffffc0203ce0:	b79d                	j	ffffffffc0203c46 <page_insert+0x56>
ffffffffc0203ce2:	f30ff0ef          	jal	ra,ffffffffc0203412 <pa2page.part.0>

ffffffffc0203ce6 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0203ce6:	00004797          	auipc	a5,0x4
ffffffffc0203cea:	05278793          	addi	a5,a5,82 # ffffffffc0207d38 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203cee:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0203cf0:	711d                	addi	sp,sp,-96
ffffffffc0203cf2:	ec5e                	sd	s7,24(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203cf4:	00004517          	auipc	a0,0x4
ffffffffc0203cf8:	0d450513          	addi	a0,a0,212 # ffffffffc0207dc8 <default_pmm_manager+0x90>
    pmm_manager = &default_pmm_manager;
ffffffffc0203cfc:	000afb97          	auipc	s7,0xaf
ffffffffc0203d00:	bacb8b93          	addi	s7,s7,-1108 # ffffffffc02b28a8 <pmm_manager>
void pmm_init(void) {
ffffffffc0203d04:	ec86                	sd	ra,88(sp)
ffffffffc0203d06:	e4a6                	sd	s1,72(sp)
ffffffffc0203d08:	fc4e                	sd	s3,56(sp)
ffffffffc0203d0a:	f05a                	sd	s6,32(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0203d0c:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc0203d10:	e8a2                	sd	s0,80(sp)
ffffffffc0203d12:	e0ca                	sd	s2,64(sp)
ffffffffc0203d14:	f852                	sd	s4,48(sp)
ffffffffc0203d16:	f456                	sd	s5,40(sp)
ffffffffc0203d18:	e862                	sd	s8,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203d1a:	bb2fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    pmm_manager->init();
ffffffffc0203d1e:	000bb783          	ld	a5,0(s7)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0203d22:	000af997          	auipc	s3,0xaf
ffffffffc0203d26:	b8e98993          	addi	s3,s3,-1138 # ffffffffc02b28b0 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc0203d2a:	000af497          	auipc	s1,0xaf
ffffffffc0203d2e:	b6e48493          	addi	s1,s1,-1170 # ffffffffc02b2898 <npage>
    pmm_manager->init();
ffffffffc0203d32:	679c                	ld	a5,8(a5)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0203d34:	000afb17          	auipc	s6,0xaf
ffffffffc0203d38:	b6cb0b13          	addi	s6,s6,-1172 # ffffffffc02b28a0 <pages>
    pmm_manager->init();
ffffffffc0203d3c:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0203d3e:	57f5                	li	a5,-3
ffffffffc0203d40:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0203d42:	00004517          	auipc	a0,0x4
ffffffffc0203d46:	09e50513          	addi	a0,a0,158 # ffffffffc0207de0 <default_pmm_manager+0xa8>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0203d4a:	00f9b023          	sd	a5,0(s3)
    cprintf("physcial memory map:\n");
ffffffffc0203d4e:	b7efc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0203d52:	46c5                	li	a3,17
ffffffffc0203d54:	06ee                	slli	a3,a3,0x1b
ffffffffc0203d56:	40100613          	li	a2,1025
ffffffffc0203d5a:	07e005b7          	lui	a1,0x7e00
ffffffffc0203d5e:	16fd                	addi	a3,a3,-1
ffffffffc0203d60:	0656                	slli	a2,a2,0x15
ffffffffc0203d62:	00004517          	auipc	a0,0x4
ffffffffc0203d66:	09650513          	addi	a0,a0,150 # ffffffffc0207df8 <default_pmm_manager+0xc0>
ffffffffc0203d6a:	b62fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0203d6e:	777d                	lui	a4,0xfffff
ffffffffc0203d70:	000b0797          	auipc	a5,0xb0
ffffffffc0203d74:	b6378793          	addi	a5,a5,-1181 # ffffffffc02b38d3 <end+0xfff>
ffffffffc0203d78:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0203d7a:	00088737          	lui	a4,0x88
ffffffffc0203d7e:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0203d80:	00fb3023          	sd	a5,0(s6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0203d84:	4701                	li	a4,0
ffffffffc0203d86:	4585                	li	a1,1
ffffffffc0203d88:	fff80837          	lui	a6,0xfff80
ffffffffc0203d8c:	a019                	j	ffffffffc0203d92 <pmm_init+0xac>
        SetPageReserved(pages + i);
ffffffffc0203d8e:	000b3783          	ld	a5,0(s6)
ffffffffc0203d92:	00671693          	slli	a3,a4,0x6
ffffffffc0203d96:	97b6                	add	a5,a5,a3
ffffffffc0203d98:	07a1                	addi	a5,a5,8
ffffffffc0203d9a:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0203d9e:	6090                	ld	a2,0(s1)
ffffffffc0203da0:	0705                	addi	a4,a4,1
ffffffffc0203da2:	010607b3          	add	a5,a2,a6
ffffffffc0203da6:	fef764e3          	bltu	a4,a5,ffffffffc0203d8e <pmm_init+0xa8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203daa:	000b3503          	ld	a0,0(s6)
ffffffffc0203dae:	079a                	slli	a5,a5,0x6
ffffffffc0203db0:	c0200737          	lui	a4,0xc0200
ffffffffc0203db4:	00f506b3          	add	a3,a0,a5
ffffffffc0203db8:	60e6e563          	bltu	a3,a4,ffffffffc02043c2 <pmm_init+0x6dc>
ffffffffc0203dbc:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc0203dc0:	4745                	li	a4,17
ffffffffc0203dc2:	076e                	slli	a4,a4,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203dc4:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc0203dc6:	4ae6e563          	bltu	a3,a4,ffffffffc0204270 <pmm_init+0x58a>
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0203dca:	00004517          	auipc	a0,0x4
ffffffffc0203dce:	05650513          	addi	a0,a0,86 # ffffffffc0207e20 <default_pmm_manager+0xe8>
ffffffffc0203dd2:	afafc0ef          	jal	ra,ffffffffc02000cc <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0203dd6:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0203dda:	000af917          	auipc	s2,0xaf
ffffffffc0203dde:	ab690913          	addi	s2,s2,-1354 # ffffffffc02b2890 <boot_pgdir>
    pmm_manager->check();
ffffffffc0203de2:	7b9c                	ld	a5,48(a5)
ffffffffc0203de4:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0203de6:	00004517          	auipc	a0,0x4
ffffffffc0203dea:	05250513          	addi	a0,a0,82 # ffffffffc0207e38 <default_pmm_manager+0x100>
ffffffffc0203dee:	adefc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0203df2:	00007697          	auipc	a3,0x7
ffffffffc0203df6:	20e68693          	addi	a3,a3,526 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc0203dfa:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0203dfe:	c02007b7          	lui	a5,0xc0200
ffffffffc0203e02:	5cf6ec63          	bltu	a3,a5,ffffffffc02043da <pmm_init+0x6f4>
ffffffffc0203e06:	0009b783          	ld	a5,0(s3)
ffffffffc0203e0a:	8e9d                	sub	a3,a3,a5
ffffffffc0203e0c:	000af797          	auipc	a5,0xaf
ffffffffc0203e10:	a6d7be23          	sd	a3,-1412(a5) # ffffffffc02b2888 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203e14:	100027f3          	csrr	a5,sstatus
ffffffffc0203e18:	8b89                	andi	a5,a5,2
ffffffffc0203e1a:	48079263          	bnez	a5,ffffffffc020429e <pmm_init+0x5b8>
        ret = pmm_manager->nr_free_pages();
ffffffffc0203e1e:	000bb783          	ld	a5,0(s7)
ffffffffc0203e22:	779c                	ld	a5,40(a5)
ffffffffc0203e24:	9782                	jalr	a5
ffffffffc0203e26:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203e28:	6098                	ld	a4,0(s1)
ffffffffc0203e2a:	c80007b7          	lui	a5,0xc8000
ffffffffc0203e2e:	83b1                	srli	a5,a5,0xc
ffffffffc0203e30:	5ee7e163          	bltu	a5,a4,ffffffffc0204412 <pmm_init+0x72c>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0203e34:	00093503          	ld	a0,0(s2)
ffffffffc0203e38:	5a050d63          	beqz	a0,ffffffffc02043f2 <pmm_init+0x70c>
ffffffffc0203e3c:	03451793          	slli	a5,a0,0x34
ffffffffc0203e40:	5a079963          	bnez	a5,ffffffffc02043f2 <pmm_init+0x70c>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0203e44:	4601                	li	a2,0
ffffffffc0203e46:	4581                	li	a1,0
ffffffffc0203e48:	8e1ff0ef          	jal	ra,ffffffffc0203728 <get_page>
ffffffffc0203e4c:	62051563          	bnez	a0,ffffffffc0204476 <pmm_init+0x790>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0203e50:	4505                	li	a0,1
ffffffffc0203e52:	df8ff0ef          	jal	ra,ffffffffc020344a <alloc_pages>
ffffffffc0203e56:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0203e58:	00093503          	ld	a0,0(s2)
ffffffffc0203e5c:	4681                	li	a3,0
ffffffffc0203e5e:	4601                	li	a2,0
ffffffffc0203e60:	85d2                	mv	a1,s4
ffffffffc0203e62:	d8fff0ef          	jal	ra,ffffffffc0203bf0 <page_insert>
ffffffffc0203e66:	5e051863          	bnez	a0,ffffffffc0204456 <pmm_init+0x770>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0203e6a:	00093503          	ld	a0,0(s2)
ffffffffc0203e6e:	4601                	li	a2,0
ffffffffc0203e70:	4581                	li	a1,0
ffffffffc0203e72:	ee4ff0ef          	jal	ra,ffffffffc0203556 <get_pte>
ffffffffc0203e76:	5c050063          	beqz	a0,ffffffffc0204436 <pmm_init+0x750>
    assert(pte2page(*ptep) == p1);
ffffffffc0203e7a:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203e7c:	0017f713          	andi	a4,a5,1
ffffffffc0203e80:	5a070963          	beqz	a4,ffffffffc0204432 <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc0203e84:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203e86:	078a                	slli	a5,a5,0x2
ffffffffc0203e88:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203e8a:	52e7fa63          	bgeu	a5,a4,ffffffffc02043be <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0203e8e:	000b3683          	ld	a3,0(s6)
ffffffffc0203e92:	fff80637          	lui	a2,0xfff80
ffffffffc0203e96:	97b2                	add	a5,a5,a2
ffffffffc0203e98:	079a                	slli	a5,a5,0x6
ffffffffc0203e9a:	97b6                	add	a5,a5,a3
ffffffffc0203e9c:	10fa16e3          	bne	s4,a5,ffffffffc02047a8 <pmm_init+0xac2>
    assert(page_ref(p1) == 1);
ffffffffc0203ea0:	000a2683          	lw	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb8>
ffffffffc0203ea4:	4785                	li	a5,1
ffffffffc0203ea6:	12f69de3          	bne	a3,a5,ffffffffc02047e0 <pmm_init+0xafa>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0203eaa:	00093503          	ld	a0,0(s2)
ffffffffc0203eae:	77fd                	lui	a5,0xfffff
ffffffffc0203eb0:	6114                	ld	a3,0(a0)
ffffffffc0203eb2:	068a                	slli	a3,a3,0x2
ffffffffc0203eb4:	8efd                	and	a3,a3,a5
ffffffffc0203eb6:	00c6d613          	srli	a2,a3,0xc
ffffffffc0203eba:	10e677e3          	bgeu	a2,a4,ffffffffc02047c8 <pmm_init+0xae2>
ffffffffc0203ebe:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203ec2:	96e2                	add	a3,a3,s8
ffffffffc0203ec4:	0006ba83          	ld	s5,0(a3)
ffffffffc0203ec8:	0a8a                	slli	s5,s5,0x2
ffffffffc0203eca:	00fafab3          	and	s5,s5,a5
ffffffffc0203ece:	00cad793          	srli	a5,s5,0xc
ffffffffc0203ed2:	62e7f263          	bgeu	a5,a4,ffffffffc02044f6 <pmm_init+0x810>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203ed6:	4601                	li	a2,0
ffffffffc0203ed8:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203eda:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203edc:	e7aff0ef          	jal	ra,ffffffffc0203556 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203ee0:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203ee2:	5f551a63          	bne	a0,s5,ffffffffc02044d6 <pmm_init+0x7f0>

    p2 = alloc_page();
ffffffffc0203ee6:	4505                	li	a0,1
ffffffffc0203ee8:	d62ff0ef          	jal	ra,ffffffffc020344a <alloc_pages>
ffffffffc0203eec:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0203eee:	00093503          	ld	a0,0(s2)
ffffffffc0203ef2:	46d1                	li	a3,20
ffffffffc0203ef4:	6605                	lui	a2,0x1
ffffffffc0203ef6:	85d6                	mv	a1,s5
ffffffffc0203ef8:	cf9ff0ef          	jal	ra,ffffffffc0203bf0 <page_insert>
ffffffffc0203efc:	58051d63          	bnez	a0,ffffffffc0204496 <pmm_init+0x7b0>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203f00:	00093503          	ld	a0,0(s2)
ffffffffc0203f04:	4601                	li	a2,0
ffffffffc0203f06:	6585                	lui	a1,0x1
ffffffffc0203f08:	e4eff0ef          	jal	ra,ffffffffc0203556 <get_pte>
ffffffffc0203f0c:	0e050ae3          	beqz	a0,ffffffffc0204800 <pmm_init+0xb1a>
    assert(*ptep & PTE_U);
ffffffffc0203f10:	611c                	ld	a5,0(a0)
ffffffffc0203f12:	0107f713          	andi	a4,a5,16
ffffffffc0203f16:	6e070d63          	beqz	a4,ffffffffc0204610 <pmm_init+0x92a>
    assert(*ptep & PTE_W);
ffffffffc0203f1a:	8b91                	andi	a5,a5,4
ffffffffc0203f1c:	6a078a63          	beqz	a5,ffffffffc02045d0 <pmm_init+0x8ea>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0203f20:	00093503          	ld	a0,0(s2)
ffffffffc0203f24:	611c                	ld	a5,0(a0)
ffffffffc0203f26:	8bc1                	andi	a5,a5,16
ffffffffc0203f28:	68078463          	beqz	a5,ffffffffc02045b0 <pmm_init+0x8ca>
    assert(page_ref(p2) == 1);
ffffffffc0203f2c:	000aa703          	lw	a4,0(s5)
ffffffffc0203f30:	4785                	li	a5,1
ffffffffc0203f32:	58f71263          	bne	a4,a5,ffffffffc02044b6 <pmm_init+0x7d0>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0203f36:	4681                	li	a3,0
ffffffffc0203f38:	6605                	lui	a2,0x1
ffffffffc0203f3a:	85d2                	mv	a1,s4
ffffffffc0203f3c:	cb5ff0ef          	jal	ra,ffffffffc0203bf0 <page_insert>
ffffffffc0203f40:	62051863          	bnez	a0,ffffffffc0204570 <pmm_init+0x88a>
    assert(page_ref(p1) == 2);
ffffffffc0203f44:	000a2703          	lw	a4,0(s4)
ffffffffc0203f48:	4789                	li	a5,2
ffffffffc0203f4a:	60f71363          	bne	a4,a5,ffffffffc0204550 <pmm_init+0x86a>
    assert(page_ref(p2) == 0);
ffffffffc0203f4e:	000aa783          	lw	a5,0(s5)
ffffffffc0203f52:	5c079f63          	bnez	a5,ffffffffc0204530 <pmm_init+0x84a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203f56:	00093503          	ld	a0,0(s2)
ffffffffc0203f5a:	4601                	li	a2,0
ffffffffc0203f5c:	6585                	lui	a1,0x1
ffffffffc0203f5e:	df8ff0ef          	jal	ra,ffffffffc0203556 <get_pte>
ffffffffc0203f62:	5a050763          	beqz	a0,ffffffffc0204510 <pmm_init+0x82a>
    assert(pte2page(*ptep) == p1);
ffffffffc0203f66:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203f68:	00177793          	andi	a5,a4,1
ffffffffc0203f6c:	4c078363          	beqz	a5,ffffffffc0204432 <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc0203f70:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203f72:	00271793          	slli	a5,a4,0x2
ffffffffc0203f76:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203f78:	44d7f363          	bgeu	a5,a3,ffffffffc02043be <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0203f7c:	000b3683          	ld	a3,0(s6)
ffffffffc0203f80:	fff80637          	lui	a2,0xfff80
ffffffffc0203f84:	97b2                	add	a5,a5,a2
ffffffffc0203f86:	079a                	slli	a5,a5,0x6
ffffffffc0203f88:	97b6                	add	a5,a5,a3
ffffffffc0203f8a:	6efa1363          	bne	s4,a5,ffffffffc0204670 <pmm_init+0x98a>
    assert((*ptep & PTE_U) == 0);
ffffffffc0203f8e:	8b41                	andi	a4,a4,16
ffffffffc0203f90:	6c071063          	bnez	a4,ffffffffc0204650 <pmm_init+0x96a>

    page_remove(boot_pgdir, 0x0);
ffffffffc0203f94:	00093503          	ld	a0,0(s2)
ffffffffc0203f98:	4581                	li	a1,0
ffffffffc0203f9a:	bbbff0ef          	jal	ra,ffffffffc0203b54 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0203f9e:	000a2703          	lw	a4,0(s4)
ffffffffc0203fa2:	4785                	li	a5,1
ffffffffc0203fa4:	68f71663          	bne	a4,a5,ffffffffc0204630 <pmm_init+0x94a>
    assert(page_ref(p2) == 0);
ffffffffc0203fa8:	000aa783          	lw	a5,0(s5)
ffffffffc0203fac:	74079e63          	bnez	a5,ffffffffc0204708 <pmm_init+0xa22>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0203fb0:	00093503          	ld	a0,0(s2)
ffffffffc0203fb4:	6585                	lui	a1,0x1
ffffffffc0203fb6:	b9fff0ef          	jal	ra,ffffffffc0203b54 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0203fba:	000a2783          	lw	a5,0(s4)
ffffffffc0203fbe:	72079563          	bnez	a5,ffffffffc02046e8 <pmm_init+0xa02>
    assert(page_ref(p2) == 0);
ffffffffc0203fc2:	000aa783          	lw	a5,0(s5)
ffffffffc0203fc6:	70079163          	bnez	a5,ffffffffc02046c8 <pmm_init+0x9e2>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0203fca:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203fce:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203fd0:	000a3683          	ld	a3,0(s4)
ffffffffc0203fd4:	068a                	slli	a3,a3,0x2
ffffffffc0203fd6:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203fd8:	3ee6f363          	bgeu	a3,a4,ffffffffc02043be <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0203fdc:	fff807b7          	lui	a5,0xfff80
ffffffffc0203fe0:	000b3503          	ld	a0,0(s6)
ffffffffc0203fe4:	96be                	add	a3,a3,a5
ffffffffc0203fe6:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc0203fe8:	00d507b3          	add	a5,a0,a3
ffffffffc0203fec:	4390                	lw	a2,0(a5)
ffffffffc0203fee:	4785                	li	a5,1
ffffffffc0203ff0:	6af61c63          	bne	a2,a5,ffffffffc02046a8 <pmm_init+0x9c2>
    return page - pages + nbase;
ffffffffc0203ff4:	8699                	srai	a3,a3,0x6
ffffffffc0203ff6:	000805b7          	lui	a1,0x80
ffffffffc0203ffa:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0203ffc:	00c69613          	slli	a2,a3,0xc
ffffffffc0204000:	8231                	srli	a2,a2,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0204002:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204004:	68e67663          	bgeu	a2,a4,ffffffffc0204690 <pmm_init+0x9aa>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0204008:	0009b603          	ld	a2,0(s3)
ffffffffc020400c:	96b2                	add	a3,a3,a2
    return pa2page(PDE_ADDR(pde));
ffffffffc020400e:	629c                	ld	a5,0(a3)
ffffffffc0204010:	078a                	slli	a5,a5,0x2
ffffffffc0204012:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204014:	3ae7f563          	bgeu	a5,a4,ffffffffc02043be <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0204018:	8f8d                	sub	a5,a5,a1
ffffffffc020401a:	079a                	slli	a5,a5,0x6
ffffffffc020401c:	953e                	add	a0,a0,a5
ffffffffc020401e:	100027f3          	csrr	a5,sstatus
ffffffffc0204022:	8b89                	andi	a5,a5,2
ffffffffc0204024:	2c079763          	bnez	a5,ffffffffc02042f2 <pmm_init+0x60c>
        pmm_manager->free_pages(base, n);
ffffffffc0204028:	000bb783          	ld	a5,0(s7)
ffffffffc020402c:	4585                	li	a1,1
ffffffffc020402e:	739c                	ld	a5,32(a5)
ffffffffc0204030:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0204032:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0204036:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204038:	078a                	slli	a5,a5,0x2
ffffffffc020403a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020403c:	38e7f163          	bgeu	a5,a4,ffffffffc02043be <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0204040:	000b3503          	ld	a0,0(s6)
ffffffffc0204044:	fff80737          	lui	a4,0xfff80
ffffffffc0204048:	97ba                	add	a5,a5,a4
ffffffffc020404a:	079a                	slli	a5,a5,0x6
ffffffffc020404c:	953e                	add	a0,a0,a5
ffffffffc020404e:	100027f3          	csrr	a5,sstatus
ffffffffc0204052:	8b89                	andi	a5,a5,2
ffffffffc0204054:	28079363          	bnez	a5,ffffffffc02042da <pmm_init+0x5f4>
ffffffffc0204058:	000bb783          	ld	a5,0(s7)
ffffffffc020405c:	4585                	li	a1,1
ffffffffc020405e:	739c                	ld	a5,32(a5)
ffffffffc0204060:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0204062:	00093783          	ld	a5,0(s2)
ffffffffc0204066:	0007b023          	sd	zero,0(a5) # fffffffffff80000 <end+0x3fccd72c>
  asm volatile("sfence.vma");
ffffffffc020406a:	12000073          	sfence.vma
ffffffffc020406e:	100027f3          	csrr	a5,sstatus
ffffffffc0204072:	8b89                	andi	a5,a5,2
ffffffffc0204074:	24079963          	bnez	a5,ffffffffc02042c6 <pmm_init+0x5e0>
        ret = pmm_manager->nr_free_pages();
ffffffffc0204078:	000bb783          	ld	a5,0(s7)
ffffffffc020407c:	779c                	ld	a5,40(a5)
ffffffffc020407e:	9782                	jalr	a5
ffffffffc0204080:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0204082:	71441363          	bne	s0,s4,ffffffffc0204788 <pmm_init+0xaa2>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0204086:	00004517          	auipc	a0,0x4
ffffffffc020408a:	09a50513          	addi	a0,a0,154 # ffffffffc0208120 <default_pmm_manager+0x3e8>
ffffffffc020408e:	83efc0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0204092:	100027f3          	csrr	a5,sstatus
ffffffffc0204096:	8b89                	andi	a5,a5,2
ffffffffc0204098:	20079d63          	bnez	a5,ffffffffc02042b2 <pmm_init+0x5cc>
        ret = pmm_manager->nr_free_pages();
ffffffffc020409c:	000bb783          	ld	a5,0(s7)
ffffffffc02040a0:	779c                	ld	a5,40(a5)
ffffffffc02040a2:	9782                	jalr	a5
ffffffffc02040a4:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02040a6:	6098                	ld	a4,0(s1)
ffffffffc02040a8:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02040ac:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02040ae:	00c71793          	slli	a5,a4,0xc
ffffffffc02040b2:	6a05                	lui	s4,0x1
ffffffffc02040b4:	02f47c63          	bgeu	s0,a5,ffffffffc02040ec <pmm_init+0x406>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02040b8:	00c45793          	srli	a5,s0,0xc
ffffffffc02040bc:	00093503          	ld	a0,0(s2)
ffffffffc02040c0:	2ee7f263          	bgeu	a5,a4,ffffffffc02043a4 <pmm_init+0x6be>
ffffffffc02040c4:	0009b583          	ld	a1,0(s3)
ffffffffc02040c8:	4601                	li	a2,0
ffffffffc02040ca:	95a2                	add	a1,a1,s0
ffffffffc02040cc:	c8aff0ef          	jal	ra,ffffffffc0203556 <get_pte>
ffffffffc02040d0:	2a050a63          	beqz	a0,ffffffffc0204384 <pmm_init+0x69e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02040d4:	611c                	ld	a5,0(a0)
ffffffffc02040d6:	078a                	slli	a5,a5,0x2
ffffffffc02040d8:	0157f7b3          	and	a5,a5,s5
ffffffffc02040dc:	28879463          	bne	a5,s0,ffffffffc0204364 <pmm_init+0x67e>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02040e0:	6098                	ld	a4,0(s1)
ffffffffc02040e2:	9452                	add	s0,s0,s4
ffffffffc02040e4:	00c71793          	slli	a5,a4,0xc
ffffffffc02040e8:	fcf468e3          	bltu	s0,a5,ffffffffc02040b8 <pmm_init+0x3d2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc02040ec:	00093783          	ld	a5,0(s2)
ffffffffc02040f0:	639c                	ld	a5,0(a5)
ffffffffc02040f2:	66079b63          	bnez	a5,ffffffffc0204768 <pmm_init+0xa82>

    struct Page *p;
    p = alloc_page();
ffffffffc02040f6:	4505                	li	a0,1
ffffffffc02040f8:	b52ff0ef          	jal	ra,ffffffffc020344a <alloc_pages>
ffffffffc02040fc:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02040fe:	00093503          	ld	a0,0(s2)
ffffffffc0204102:	4699                	li	a3,6
ffffffffc0204104:	10000613          	li	a2,256
ffffffffc0204108:	85d6                	mv	a1,s5
ffffffffc020410a:	ae7ff0ef          	jal	ra,ffffffffc0203bf0 <page_insert>
ffffffffc020410e:	62051d63          	bnez	a0,ffffffffc0204748 <pmm_init+0xa62>
    assert(page_ref(p) == 1);
ffffffffc0204112:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fd4c72c>
ffffffffc0204116:	4785                	li	a5,1
ffffffffc0204118:	60f71863          	bne	a4,a5,ffffffffc0204728 <pmm_init+0xa42>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020411c:	00093503          	ld	a0,0(s2)
ffffffffc0204120:	6405                	lui	s0,0x1
ffffffffc0204122:	4699                	li	a3,6
ffffffffc0204124:	10040613          	addi	a2,s0,256 # 1100 <_binary_obj___user_faultread_out_size-0x8ab8>
ffffffffc0204128:	85d6                	mv	a1,s5
ffffffffc020412a:	ac7ff0ef          	jal	ra,ffffffffc0203bf0 <page_insert>
ffffffffc020412e:	46051163          	bnez	a0,ffffffffc0204590 <pmm_init+0x8aa>
    assert(page_ref(p) == 2);
ffffffffc0204132:	000aa703          	lw	a4,0(s5)
ffffffffc0204136:	4789                	li	a5,2
ffffffffc0204138:	72f71463          	bne	a4,a5,ffffffffc0204860 <pmm_init+0xb7a>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc020413c:	00004597          	auipc	a1,0x4
ffffffffc0204140:	11c58593          	addi	a1,a1,284 # ffffffffc0208258 <default_pmm_manager+0x520>
ffffffffc0204144:	10000513          	li	a0,256
ffffffffc0204148:	01c020ef          	jal	ra,ffffffffc0206164 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020414c:	10040593          	addi	a1,s0,256
ffffffffc0204150:	10000513          	li	a0,256
ffffffffc0204154:	022020ef          	jal	ra,ffffffffc0206176 <strcmp>
ffffffffc0204158:	6e051463          	bnez	a0,ffffffffc0204840 <pmm_init+0xb5a>
    return page - pages + nbase;
ffffffffc020415c:	000b3683          	ld	a3,0(s6)
ffffffffc0204160:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0204164:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc0204166:	40da86b3          	sub	a3,s5,a3
ffffffffc020416a:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc020416c:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc020416e:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0204170:	8031                	srli	s0,s0,0xc
ffffffffc0204172:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0204176:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204178:	50f77c63          	bgeu	a4,a5,ffffffffc0204690 <pmm_init+0x9aa>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc020417c:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0204180:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0204184:	96be                	add	a3,a3,a5
ffffffffc0204186:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc020418a:	7a5010ef          	jal	ra,ffffffffc020612e <strlen>
ffffffffc020418e:	68051963          	bnez	a0,ffffffffc0204820 <pmm_init+0xb3a>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0204192:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0204196:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204198:	000a3683          	ld	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb8>
ffffffffc020419c:	068a                	slli	a3,a3,0x2
ffffffffc020419e:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc02041a0:	20f6ff63          	bgeu	a3,a5,ffffffffc02043be <pmm_init+0x6d8>
    return KADDR(page2pa(page));
ffffffffc02041a4:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02041a6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02041a8:	4ef47463          	bgeu	s0,a5,ffffffffc0204690 <pmm_init+0x9aa>
ffffffffc02041ac:	0009b403          	ld	s0,0(s3)
ffffffffc02041b0:	9436                	add	s0,s0,a3
ffffffffc02041b2:	100027f3          	csrr	a5,sstatus
ffffffffc02041b6:	8b89                	andi	a5,a5,2
ffffffffc02041b8:	18079b63          	bnez	a5,ffffffffc020434e <pmm_init+0x668>
        pmm_manager->free_pages(base, n);
ffffffffc02041bc:	000bb783          	ld	a5,0(s7)
ffffffffc02041c0:	4585                	li	a1,1
ffffffffc02041c2:	8556                	mv	a0,s5
ffffffffc02041c4:	739c                	ld	a5,32(a5)
ffffffffc02041c6:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02041c8:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02041ca:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02041cc:	078a                	slli	a5,a5,0x2
ffffffffc02041ce:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02041d0:	1ee7f763          	bgeu	a5,a4,ffffffffc02043be <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02041d4:	000b3503          	ld	a0,0(s6)
ffffffffc02041d8:	fff80737          	lui	a4,0xfff80
ffffffffc02041dc:	97ba                	add	a5,a5,a4
ffffffffc02041de:	079a                	slli	a5,a5,0x6
ffffffffc02041e0:	953e                	add	a0,a0,a5
ffffffffc02041e2:	100027f3          	csrr	a5,sstatus
ffffffffc02041e6:	8b89                	andi	a5,a5,2
ffffffffc02041e8:	14079763          	bnez	a5,ffffffffc0204336 <pmm_init+0x650>
ffffffffc02041ec:	000bb783          	ld	a5,0(s7)
ffffffffc02041f0:	4585                	li	a1,1
ffffffffc02041f2:	739c                	ld	a5,32(a5)
ffffffffc02041f4:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02041f6:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc02041fa:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02041fc:	078a                	slli	a5,a5,0x2
ffffffffc02041fe:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204200:	1ae7ff63          	bgeu	a5,a4,ffffffffc02043be <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0204204:	000b3503          	ld	a0,0(s6)
ffffffffc0204208:	fff80737          	lui	a4,0xfff80
ffffffffc020420c:	97ba                	add	a5,a5,a4
ffffffffc020420e:	079a                	slli	a5,a5,0x6
ffffffffc0204210:	953e                	add	a0,a0,a5
ffffffffc0204212:	100027f3          	csrr	a5,sstatus
ffffffffc0204216:	8b89                	andi	a5,a5,2
ffffffffc0204218:	10079363          	bnez	a5,ffffffffc020431e <pmm_init+0x638>
ffffffffc020421c:	000bb783          	ld	a5,0(s7)
ffffffffc0204220:	4585                	li	a1,1
ffffffffc0204222:	739c                	ld	a5,32(a5)
ffffffffc0204224:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0204226:	00093783          	ld	a5,0(s2)
ffffffffc020422a:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc020422e:	12000073          	sfence.vma
ffffffffc0204232:	100027f3          	csrr	a5,sstatus
ffffffffc0204236:	8b89                	andi	a5,a5,2
ffffffffc0204238:	0c079963          	bnez	a5,ffffffffc020430a <pmm_init+0x624>
        ret = pmm_manager->nr_free_pages();
ffffffffc020423c:	000bb783          	ld	a5,0(s7)
ffffffffc0204240:	779c                	ld	a5,40(a5)
ffffffffc0204242:	9782                	jalr	a5
ffffffffc0204244:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0204246:	3a8c1563          	bne	s8,s0,ffffffffc02045f0 <pmm_init+0x90a>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc020424a:	00004517          	auipc	a0,0x4
ffffffffc020424e:	08650513          	addi	a0,a0,134 # ffffffffc02082d0 <default_pmm_manager+0x598>
ffffffffc0204252:	e7bfb0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc0204256:	6446                	ld	s0,80(sp)
ffffffffc0204258:	60e6                	ld	ra,88(sp)
ffffffffc020425a:	64a6                	ld	s1,72(sp)
ffffffffc020425c:	6906                	ld	s2,64(sp)
ffffffffc020425e:	79e2                	ld	s3,56(sp)
ffffffffc0204260:	7a42                	ld	s4,48(sp)
ffffffffc0204262:	7aa2                	ld	s5,40(sp)
ffffffffc0204264:	7b02                	ld	s6,32(sp)
ffffffffc0204266:	6be2                	ld	s7,24(sp)
ffffffffc0204268:	6c42                	ld	s8,16(sp)
ffffffffc020426a:	6125                	addi	sp,sp,96
    kmalloc_init();
ffffffffc020426c:	93cfe06f          	j	ffffffffc02023a8 <kmalloc_init>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0204270:	6785                	lui	a5,0x1
ffffffffc0204272:	17fd                	addi	a5,a5,-1
ffffffffc0204274:	96be                	add	a3,a3,a5
ffffffffc0204276:	77fd                	lui	a5,0xfffff
ffffffffc0204278:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage) {
ffffffffc020427a:	00c7d693          	srli	a3,a5,0xc
ffffffffc020427e:	14c6f063          	bgeu	a3,a2,ffffffffc02043be <pmm_init+0x6d8>
    pmm_manager->init_memmap(base, n);
ffffffffc0204282:	000bb603          	ld	a2,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc0204286:	96c2                	add	a3,a3,a6
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0204288:	40f707b3          	sub	a5,a4,a5
    pmm_manager->init_memmap(base, n);
ffffffffc020428c:	6a10                	ld	a2,16(a2)
ffffffffc020428e:	069a                	slli	a3,a3,0x6
ffffffffc0204290:	00c7d593          	srli	a1,a5,0xc
ffffffffc0204294:	9536                	add	a0,a0,a3
ffffffffc0204296:	9602                	jalr	a2
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0204298:	0009b583          	ld	a1,0(s3)
}
ffffffffc020429c:	b63d                	j	ffffffffc0203dca <pmm_init+0xe4>
        intr_disable();
ffffffffc020429e:	baafc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02042a2:	000bb783          	ld	a5,0(s7)
ffffffffc02042a6:	779c                	ld	a5,40(a5)
ffffffffc02042a8:	9782                	jalr	a5
ffffffffc02042aa:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02042ac:	b96fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc02042b0:	bea5                	j	ffffffffc0203e28 <pmm_init+0x142>
        intr_disable();
ffffffffc02042b2:	b96fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc02042b6:	000bb783          	ld	a5,0(s7)
ffffffffc02042ba:	779c                	ld	a5,40(a5)
ffffffffc02042bc:	9782                	jalr	a5
ffffffffc02042be:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc02042c0:	b82fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc02042c4:	b3cd                	j	ffffffffc02040a6 <pmm_init+0x3c0>
        intr_disable();
ffffffffc02042c6:	b82fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc02042ca:	000bb783          	ld	a5,0(s7)
ffffffffc02042ce:	779c                	ld	a5,40(a5)
ffffffffc02042d0:	9782                	jalr	a5
ffffffffc02042d2:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc02042d4:	b6efc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc02042d8:	b36d                	j	ffffffffc0204082 <pmm_init+0x39c>
ffffffffc02042da:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02042dc:	b6cfc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02042e0:	000bb783          	ld	a5,0(s7)
ffffffffc02042e4:	6522                	ld	a0,8(sp)
ffffffffc02042e6:	4585                	li	a1,1
ffffffffc02042e8:	739c                	ld	a5,32(a5)
ffffffffc02042ea:	9782                	jalr	a5
        intr_enable();
ffffffffc02042ec:	b56fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc02042f0:	bb8d                	j	ffffffffc0204062 <pmm_init+0x37c>
ffffffffc02042f2:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02042f4:	b54fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc02042f8:	000bb783          	ld	a5,0(s7)
ffffffffc02042fc:	6522                	ld	a0,8(sp)
ffffffffc02042fe:	4585                	li	a1,1
ffffffffc0204300:	739c                	ld	a5,32(a5)
ffffffffc0204302:	9782                	jalr	a5
        intr_enable();
ffffffffc0204304:	b3efc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0204308:	b32d                	j	ffffffffc0204032 <pmm_init+0x34c>
        intr_disable();
ffffffffc020430a:	b3efc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc020430e:	000bb783          	ld	a5,0(s7)
ffffffffc0204312:	779c                	ld	a5,40(a5)
ffffffffc0204314:	9782                	jalr	a5
ffffffffc0204316:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0204318:	b2afc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc020431c:	b72d                	j	ffffffffc0204246 <pmm_init+0x560>
ffffffffc020431e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0204320:	b28fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0204324:	000bb783          	ld	a5,0(s7)
ffffffffc0204328:	6522                	ld	a0,8(sp)
ffffffffc020432a:	4585                	li	a1,1
ffffffffc020432c:	739c                	ld	a5,32(a5)
ffffffffc020432e:	9782                	jalr	a5
        intr_enable();
ffffffffc0204330:	b12fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0204334:	bdcd                	j	ffffffffc0204226 <pmm_init+0x540>
ffffffffc0204336:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0204338:	b10fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc020433c:	000bb783          	ld	a5,0(s7)
ffffffffc0204340:	6522                	ld	a0,8(sp)
ffffffffc0204342:	4585                	li	a1,1
ffffffffc0204344:	739c                	ld	a5,32(a5)
ffffffffc0204346:	9782                	jalr	a5
        intr_enable();
ffffffffc0204348:	afafc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc020434c:	b56d                	j	ffffffffc02041f6 <pmm_init+0x510>
        intr_disable();
ffffffffc020434e:	afafc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc0204352:	000bb783          	ld	a5,0(s7)
ffffffffc0204356:	4585                	li	a1,1
ffffffffc0204358:	8556                	mv	a0,s5
ffffffffc020435a:	739c                	ld	a5,32(a5)
ffffffffc020435c:	9782                	jalr	a5
        intr_enable();
ffffffffc020435e:	ae4fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0204362:	b59d                	j	ffffffffc02041c8 <pmm_init+0x4e2>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0204364:	00004697          	auipc	a3,0x4
ffffffffc0204368:	e1c68693          	addi	a3,a3,-484 # ffffffffc0208180 <default_pmm_manager+0x448>
ffffffffc020436c:	00003617          	auipc	a2,0x3
ffffffffc0204370:	92460613          	addi	a2,a2,-1756 # ffffffffc0206c90 <commands+0x410>
ffffffffc0204374:	22800593          	li	a1,552
ffffffffc0204378:	00004517          	auipc	a0,0x4
ffffffffc020437c:	9f850513          	addi	a0,a0,-1544 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc0204380:	e89fb0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0204384:	00004697          	auipc	a3,0x4
ffffffffc0204388:	dbc68693          	addi	a3,a3,-580 # ffffffffc0208140 <default_pmm_manager+0x408>
ffffffffc020438c:	00003617          	auipc	a2,0x3
ffffffffc0204390:	90460613          	addi	a2,a2,-1788 # ffffffffc0206c90 <commands+0x410>
ffffffffc0204394:	22700593          	li	a1,551
ffffffffc0204398:	00004517          	auipc	a0,0x4
ffffffffc020439c:	9d850513          	addi	a0,a0,-1576 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc02043a0:	e69fb0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc02043a4:	86a2                	mv	a3,s0
ffffffffc02043a6:	00003617          	auipc	a2,0x3
ffffffffc02043aa:	eba60613          	addi	a2,a2,-326 # ffffffffc0207260 <commands+0x9e0>
ffffffffc02043ae:	22700593          	li	a1,551
ffffffffc02043b2:	00004517          	auipc	a0,0x4
ffffffffc02043b6:	9be50513          	addi	a0,a0,-1602 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc02043ba:	e4ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc02043be:	854ff0ef          	jal	ra,ffffffffc0203412 <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02043c2:	00003617          	auipc	a2,0x3
ffffffffc02043c6:	41660613          	addi	a2,a2,1046 # ffffffffc02077d8 <commands+0xf58>
ffffffffc02043ca:	07f00593          	li	a1,127
ffffffffc02043ce:	00004517          	auipc	a0,0x4
ffffffffc02043d2:	9a250513          	addi	a0,a0,-1630 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc02043d6:	e33fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02043da:	00003617          	auipc	a2,0x3
ffffffffc02043de:	3fe60613          	addi	a2,a2,1022 # ffffffffc02077d8 <commands+0xf58>
ffffffffc02043e2:	0c100593          	li	a1,193
ffffffffc02043e6:	00004517          	auipc	a0,0x4
ffffffffc02043ea:	98a50513          	addi	a0,a0,-1654 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc02043ee:	e1bfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02043f2:	00004697          	auipc	a3,0x4
ffffffffc02043f6:	a8668693          	addi	a3,a3,-1402 # ffffffffc0207e78 <default_pmm_manager+0x140>
ffffffffc02043fa:	00003617          	auipc	a2,0x3
ffffffffc02043fe:	89660613          	addi	a2,a2,-1898 # ffffffffc0206c90 <commands+0x410>
ffffffffc0204402:	1eb00593          	li	a1,491
ffffffffc0204406:	00004517          	auipc	a0,0x4
ffffffffc020440a:	96a50513          	addi	a0,a0,-1686 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc020440e:	dfbfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0204412:	00004697          	auipc	a3,0x4
ffffffffc0204416:	a4668693          	addi	a3,a3,-1466 # ffffffffc0207e58 <default_pmm_manager+0x120>
ffffffffc020441a:	00003617          	auipc	a2,0x3
ffffffffc020441e:	87660613          	addi	a2,a2,-1930 # ffffffffc0206c90 <commands+0x410>
ffffffffc0204422:	1ea00593          	li	a1,490
ffffffffc0204426:	00004517          	auipc	a0,0x4
ffffffffc020442a:	94a50513          	addi	a0,a0,-1718 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc020442e:	ddbfb0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0204432:	ffdfe0ef          	jal	ra,ffffffffc020342e <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0204436:	00004697          	auipc	a3,0x4
ffffffffc020443a:	ad268693          	addi	a3,a3,-1326 # ffffffffc0207f08 <default_pmm_manager+0x1d0>
ffffffffc020443e:	00003617          	auipc	a2,0x3
ffffffffc0204442:	85260613          	addi	a2,a2,-1966 # ffffffffc0206c90 <commands+0x410>
ffffffffc0204446:	1f300593          	li	a1,499
ffffffffc020444a:	00004517          	auipc	a0,0x4
ffffffffc020444e:	92650513          	addi	a0,a0,-1754 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc0204452:	db7fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0204456:	00004697          	auipc	a3,0x4
ffffffffc020445a:	a8268693          	addi	a3,a3,-1406 # ffffffffc0207ed8 <default_pmm_manager+0x1a0>
ffffffffc020445e:	00003617          	auipc	a2,0x3
ffffffffc0204462:	83260613          	addi	a2,a2,-1998 # ffffffffc0206c90 <commands+0x410>
ffffffffc0204466:	1f000593          	li	a1,496
ffffffffc020446a:	00004517          	auipc	a0,0x4
ffffffffc020446e:	90650513          	addi	a0,a0,-1786 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc0204472:	d97fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0204476:	00004697          	auipc	a3,0x4
ffffffffc020447a:	a3a68693          	addi	a3,a3,-1478 # ffffffffc0207eb0 <default_pmm_manager+0x178>
ffffffffc020447e:	00003617          	auipc	a2,0x3
ffffffffc0204482:	81260613          	addi	a2,a2,-2030 # ffffffffc0206c90 <commands+0x410>
ffffffffc0204486:	1ec00593          	li	a1,492
ffffffffc020448a:	00004517          	auipc	a0,0x4
ffffffffc020448e:	8e650513          	addi	a0,a0,-1818 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc0204492:	d77fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0204496:	00004697          	auipc	a3,0x4
ffffffffc020449a:	afa68693          	addi	a3,a3,-1286 # ffffffffc0207f90 <default_pmm_manager+0x258>
ffffffffc020449e:	00002617          	auipc	a2,0x2
ffffffffc02044a2:	7f260613          	addi	a2,a2,2034 # ffffffffc0206c90 <commands+0x410>
ffffffffc02044a6:	1fc00593          	li	a1,508
ffffffffc02044aa:	00004517          	auipc	a0,0x4
ffffffffc02044ae:	8c650513          	addi	a0,a0,-1850 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc02044b2:	d57fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc02044b6:	00004697          	auipc	a3,0x4
ffffffffc02044ba:	b7a68693          	addi	a3,a3,-1158 # ffffffffc0208030 <default_pmm_manager+0x2f8>
ffffffffc02044be:	00002617          	auipc	a2,0x2
ffffffffc02044c2:	7d260613          	addi	a2,a2,2002 # ffffffffc0206c90 <commands+0x410>
ffffffffc02044c6:	20100593          	li	a1,513
ffffffffc02044ca:	00004517          	auipc	a0,0x4
ffffffffc02044ce:	8a650513          	addi	a0,a0,-1882 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc02044d2:	d37fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02044d6:	00004697          	auipc	a3,0x4
ffffffffc02044da:	a9268693          	addi	a3,a3,-1390 # ffffffffc0207f68 <default_pmm_manager+0x230>
ffffffffc02044de:	00002617          	auipc	a2,0x2
ffffffffc02044e2:	7b260613          	addi	a2,a2,1970 # ffffffffc0206c90 <commands+0x410>
ffffffffc02044e6:	1f900593          	li	a1,505
ffffffffc02044ea:	00004517          	auipc	a0,0x4
ffffffffc02044ee:	88650513          	addi	a0,a0,-1914 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc02044f2:	d17fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02044f6:	86d6                	mv	a3,s5
ffffffffc02044f8:	00003617          	auipc	a2,0x3
ffffffffc02044fc:	d6860613          	addi	a2,a2,-664 # ffffffffc0207260 <commands+0x9e0>
ffffffffc0204500:	1f800593          	li	a1,504
ffffffffc0204504:	00004517          	auipc	a0,0x4
ffffffffc0204508:	86c50513          	addi	a0,a0,-1940 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc020450c:	cfdfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0204510:	00004697          	auipc	a3,0x4
ffffffffc0204514:	ab868693          	addi	a3,a3,-1352 # ffffffffc0207fc8 <default_pmm_manager+0x290>
ffffffffc0204518:	00002617          	auipc	a2,0x2
ffffffffc020451c:	77860613          	addi	a2,a2,1912 # ffffffffc0206c90 <commands+0x410>
ffffffffc0204520:	20600593          	li	a1,518
ffffffffc0204524:	00004517          	auipc	a0,0x4
ffffffffc0204528:	84c50513          	addi	a0,a0,-1972 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc020452c:	cddfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0204530:	00004697          	auipc	a3,0x4
ffffffffc0204534:	b6068693          	addi	a3,a3,-1184 # ffffffffc0208090 <default_pmm_manager+0x358>
ffffffffc0204538:	00002617          	auipc	a2,0x2
ffffffffc020453c:	75860613          	addi	a2,a2,1880 # ffffffffc0206c90 <commands+0x410>
ffffffffc0204540:	20500593          	li	a1,517
ffffffffc0204544:	00004517          	auipc	a0,0x4
ffffffffc0204548:	82c50513          	addi	a0,a0,-2004 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc020454c:	cbdfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0204550:	00004697          	auipc	a3,0x4
ffffffffc0204554:	b2868693          	addi	a3,a3,-1240 # ffffffffc0208078 <default_pmm_manager+0x340>
ffffffffc0204558:	00002617          	auipc	a2,0x2
ffffffffc020455c:	73860613          	addi	a2,a2,1848 # ffffffffc0206c90 <commands+0x410>
ffffffffc0204560:	20400593          	li	a1,516
ffffffffc0204564:	00004517          	auipc	a0,0x4
ffffffffc0204568:	80c50513          	addi	a0,a0,-2036 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc020456c:	c9dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0204570:	00004697          	auipc	a3,0x4
ffffffffc0204574:	ad868693          	addi	a3,a3,-1320 # ffffffffc0208048 <default_pmm_manager+0x310>
ffffffffc0204578:	00002617          	auipc	a2,0x2
ffffffffc020457c:	71860613          	addi	a2,a2,1816 # ffffffffc0206c90 <commands+0x410>
ffffffffc0204580:	20300593          	li	a1,515
ffffffffc0204584:	00003517          	auipc	a0,0x3
ffffffffc0204588:	7ec50513          	addi	a0,a0,2028 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc020458c:	c7dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0204590:	00004697          	auipc	a3,0x4
ffffffffc0204594:	c7068693          	addi	a3,a3,-912 # ffffffffc0208200 <default_pmm_manager+0x4c8>
ffffffffc0204598:	00002617          	auipc	a2,0x2
ffffffffc020459c:	6f860613          	addi	a2,a2,1784 # ffffffffc0206c90 <commands+0x410>
ffffffffc02045a0:	23200593          	li	a1,562
ffffffffc02045a4:	00003517          	auipc	a0,0x3
ffffffffc02045a8:	7cc50513          	addi	a0,a0,1996 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc02045ac:	c5dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02045b0:	00004697          	auipc	a3,0x4
ffffffffc02045b4:	a6868693          	addi	a3,a3,-1432 # ffffffffc0208018 <default_pmm_manager+0x2e0>
ffffffffc02045b8:	00002617          	auipc	a2,0x2
ffffffffc02045bc:	6d860613          	addi	a2,a2,1752 # ffffffffc0206c90 <commands+0x410>
ffffffffc02045c0:	20000593          	li	a1,512
ffffffffc02045c4:	00003517          	auipc	a0,0x3
ffffffffc02045c8:	7ac50513          	addi	a0,a0,1964 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc02045cc:	c3dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(*ptep & PTE_W);
ffffffffc02045d0:	00004697          	auipc	a3,0x4
ffffffffc02045d4:	a3868693          	addi	a3,a3,-1480 # ffffffffc0208008 <default_pmm_manager+0x2d0>
ffffffffc02045d8:	00002617          	auipc	a2,0x2
ffffffffc02045dc:	6b860613          	addi	a2,a2,1720 # ffffffffc0206c90 <commands+0x410>
ffffffffc02045e0:	1ff00593          	li	a1,511
ffffffffc02045e4:	00003517          	auipc	a0,0x3
ffffffffc02045e8:	78c50513          	addi	a0,a0,1932 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc02045ec:	c1dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02045f0:	00004697          	auipc	a3,0x4
ffffffffc02045f4:	b1068693          	addi	a3,a3,-1264 # ffffffffc0208100 <default_pmm_manager+0x3c8>
ffffffffc02045f8:	00002617          	auipc	a2,0x2
ffffffffc02045fc:	69860613          	addi	a2,a2,1688 # ffffffffc0206c90 <commands+0x410>
ffffffffc0204600:	24300593          	li	a1,579
ffffffffc0204604:	00003517          	auipc	a0,0x3
ffffffffc0204608:	76c50513          	addi	a0,a0,1900 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc020460c:	bfdfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0204610:	00004697          	auipc	a3,0x4
ffffffffc0204614:	9e868693          	addi	a3,a3,-1560 # ffffffffc0207ff8 <default_pmm_manager+0x2c0>
ffffffffc0204618:	00002617          	auipc	a2,0x2
ffffffffc020461c:	67860613          	addi	a2,a2,1656 # ffffffffc0206c90 <commands+0x410>
ffffffffc0204620:	1fe00593          	li	a1,510
ffffffffc0204624:	00003517          	auipc	a0,0x3
ffffffffc0204628:	74c50513          	addi	a0,a0,1868 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc020462c:	bddfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0204630:	00004697          	auipc	a3,0x4
ffffffffc0204634:	92068693          	addi	a3,a3,-1760 # ffffffffc0207f50 <default_pmm_manager+0x218>
ffffffffc0204638:	00002617          	auipc	a2,0x2
ffffffffc020463c:	65860613          	addi	a2,a2,1624 # ffffffffc0206c90 <commands+0x410>
ffffffffc0204640:	20b00593          	li	a1,523
ffffffffc0204644:	00003517          	auipc	a0,0x3
ffffffffc0204648:	72c50513          	addi	a0,a0,1836 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc020464c:	bbdfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0204650:	00004697          	auipc	a3,0x4
ffffffffc0204654:	a5868693          	addi	a3,a3,-1448 # ffffffffc02080a8 <default_pmm_manager+0x370>
ffffffffc0204658:	00002617          	auipc	a2,0x2
ffffffffc020465c:	63860613          	addi	a2,a2,1592 # ffffffffc0206c90 <commands+0x410>
ffffffffc0204660:	20800593          	li	a1,520
ffffffffc0204664:	00003517          	auipc	a0,0x3
ffffffffc0204668:	70c50513          	addi	a0,a0,1804 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc020466c:	b9dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0204670:	00004697          	auipc	a3,0x4
ffffffffc0204674:	8c868693          	addi	a3,a3,-1848 # ffffffffc0207f38 <default_pmm_manager+0x200>
ffffffffc0204678:	00002617          	auipc	a2,0x2
ffffffffc020467c:	61860613          	addi	a2,a2,1560 # ffffffffc0206c90 <commands+0x410>
ffffffffc0204680:	20700593          	li	a1,519
ffffffffc0204684:	00003517          	auipc	a0,0x3
ffffffffc0204688:	6ec50513          	addi	a0,a0,1772 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc020468c:	b7dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc0204690:	00003617          	auipc	a2,0x3
ffffffffc0204694:	bd060613          	addi	a2,a2,-1072 # ffffffffc0207260 <commands+0x9e0>
ffffffffc0204698:	06900593          	li	a1,105
ffffffffc020469c:	00003517          	auipc	a0,0x3
ffffffffc02046a0:	bb450513          	addi	a0,a0,-1100 # ffffffffc0207250 <commands+0x9d0>
ffffffffc02046a4:	b65fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02046a8:	00004697          	auipc	a3,0x4
ffffffffc02046ac:	a3068693          	addi	a3,a3,-1488 # ffffffffc02080d8 <default_pmm_manager+0x3a0>
ffffffffc02046b0:	00002617          	auipc	a2,0x2
ffffffffc02046b4:	5e060613          	addi	a2,a2,1504 # ffffffffc0206c90 <commands+0x410>
ffffffffc02046b8:	21200593          	li	a1,530
ffffffffc02046bc:	00003517          	auipc	a0,0x3
ffffffffc02046c0:	6b450513          	addi	a0,a0,1716 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc02046c4:	b45fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02046c8:	00004697          	auipc	a3,0x4
ffffffffc02046cc:	9c868693          	addi	a3,a3,-1592 # ffffffffc0208090 <default_pmm_manager+0x358>
ffffffffc02046d0:	00002617          	auipc	a2,0x2
ffffffffc02046d4:	5c060613          	addi	a2,a2,1472 # ffffffffc0206c90 <commands+0x410>
ffffffffc02046d8:	21000593          	li	a1,528
ffffffffc02046dc:	00003517          	auipc	a0,0x3
ffffffffc02046e0:	69450513          	addi	a0,a0,1684 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc02046e4:	b25fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02046e8:	00004697          	auipc	a3,0x4
ffffffffc02046ec:	9d868693          	addi	a3,a3,-1576 # ffffffffc02080c0 <default_pmm_manager+0x388>
ffffffffc02046f0:	00002617          	auipc	a2,0x2
ffffffffc02046f4:	5a060613          	addi	a2,a2,1440 # ffffffffc0206c90 <commands+0x410>
ffffffffc02046f8:	20f00593          	li	a1,527
ffffffffc02046fc:	00003517          	auipc	a0,0x3
ffffffffc0204700:	67450513          	addi	a0,a0,1652 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc0204704:	b05fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0204708:	00004697          	auipc	a3,0x4
ffffffffc020470c:	98868693          	addi	a3,a3,-1656 # ffffffffc0208090 <default_pmm_manager+0x358>
ffffffffc0204710:	00002617          	auipc	a2,0x2
ffffffffc0204714:	58060613          	addi	a2,a2,1408 # ffffffffc0206c90 <commands+0x410>
ffffffffc0204718:	20c00593          	li	a1,524
ffffffffc020471c:	00003517          	auipc	a0,0x3
ffffffffc0204720:	65450513          	addi	a0,a0,1620 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc0204724:	ae5fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0204728:	00004697          	auipc	a3,0x4
ffffffffc020472c:	ac068693          	addi	a3,a3,-1344 # ffffffffc02081e8 <default_pmm_manager+0x4b0>
ffffffffc0204730:	00002617          	auipc	a2,0x2
ffffffffc0204734:	56060613          	addi	a2,a2,1376 # ffffffffc0206c90 <commands+0x410>
ffffffffc0204738:	23100593          	li	a1,561
ffffffffc020473c:	00003517          	auipc	a0,0x3
ffffffffc0204740:	63450513          	addi	a0,a0,1588 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc0204744:	ac5fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0204748:	00004697          	auipc	a3,0x4
ffffffffc020474c:	a6868693          	addi	a3,a3,-1432 # ffffffffc02081b0 <default_pmm_manager+0x478>
ffffffffc0204750:	00002617          	auipc	a2,0x2
ffffffffc0204754:	54060613          	addi	a2,a2,1344 # ffffffffc0206c90 <commands+0x410>
ffffffffc0204758:	23000593          	li	a1,560
ffffffffc020475c:	00003517          	auipc	a0,0x3
ffffffffc0204760:	61450513          	addi	a0,a0,1556 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc0204764:	aa5fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0204768:	00004697          	auipc	a3,0x4
ffffffffc020476c:	a3068693          	addi	a3,a3,-1488 # ffffffffc0208198 <default_pmm_manager+0x460>
ffffffffc0204770:	00002617          	auipc	a2,0x2
ffffffffc0204774:	52060613          	addi	a2,a2,1312 # ffffffffc0206c90 <commands+0x410>
ffffffffc0204778:	22c00593          	li	a1,556
ffffffffc020477c:	00003517          	auipc	a0,0x3
ffffffffc0204780:	5f450513          	addi	a0,a0,1524 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc0204784:	a85fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0204788:	00004697          	auipc	a3,0x4
ffffffffc020478c:	97868693          	addi	a3,a3,-1672 # ffffffffc0208100 <default_pmm_manager+0x3c8>
ffffffffc0204790:	00002617          	auipc	a2,0x2
ffffffffc0204794:	50060613          	addi	a2,a2,1280 # ffffffffc0206c90 <commands+0x410>
ffffffffc0204798:	21a00593          	li	a1,538
ffffffffc020479c:	00003517          	auipc	a0,0x3
ffffffffc02047a0:	5d450513          	addi	a0,a0,1492 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc02047a4:	a65fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02047a8:	00003697          	auipc	a3,0x3
ffffffffc02047ac:	79068693          	addi	a3,a3,1936 # ffffffffc0207f38 <default_pmm_manager+0x200>
ffffffffc02047b0:	00002617          	auipc	a2,0x2
ffffffffc02047b4:	4e060613          	addi	a2,a2,1248 # ffffffffc0206c90 <commands+0x410>
ffffffffc02047b8:	1f400593          	li	a1,500
ffffffffc02047bc:	00003517          	auipc	a0,0x3
ffffffffc02047c0:	5b450513          	addi	a0,a0,1460 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc02047c4:	a45fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02047c8:	00003617          	auipc	a2,0x3
ffffffffc02047cc:	a9860613          	addi	a2,a2,-1384 # ffffffffc0207260 <commands+0x9e0>
ffffffffc02047d0:	1f700593          	li	a1,503
ffffffffc02047d4:	00003517          	auipc	a0,0x3
ffffffffc02047d8:	59c50513          	addi	a0,a0,1436 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc02047dc:	a2dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02047e0:	00003697          	auipc	a3,0x3
ffffffffc02047e4:	77068693          	addi	a3,a3,1904 # ffffffffc0207f50 <default_pmm_manager+0x218>
ffffffffc02047e8:	00002617          	auipc	a2,0x2
ffffffffc02047ec:	4a860613          	addi	a2,a2,1192 # ffffffffc0206c90 <commands+0x410>
ffffffffc02047f0:	1f500593          	li	a1,501
ffffffffc02047f4:	00003517          	auipc	a0,0x3
ffffffffc02047f8:	57c50513          	addi	a0,a0,1404 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc02047fc:	a0dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0204800:	00003697          	auipc	a3,0x3
ffffffffc0204804:	7c868693          	addi	a3,a3,1992 # ffffffffc0207fc8 <default_pmm_manager+0x290>
ffffffffc0204808:	00002617          	auipc	a2,0x2
ffffffffc020480c:	48860613          	addi	a2,a2,1160 # ffffffffc0206c90 <commands+0x410>
ffffffffc0204810:	1fd00593          	li	a1,509
ffffffffc0204814:	00003517          	auipc	a0,0x3
ffffffffc0204818:	55c50513          	addi	a0,a0,1372 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc020481c:	9edfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0204820:	00004697          	auipc	a3,0x4
ffffffffc0204824:	a8868693          	addi	a3,a3,-1400 # ffffffffc02082a8 <default_pmm_manager+0x570>
ffffffffc0204828:	00002617          	auipc	a2,0x2
ffffffffc020482c:	46860613          	addi	a2,a2,1128 # ffffffffc0206c90 <commands+0x410>
ffffffffc0204830:	23a00593          	li	a1,570
ffffffffc0204834:	00003517          	auipc	a0,0x3
ffffffffc0204838:	53c50513          	addi	a0,a0,1340 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc020483c:	9cdfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0204840:	00004697          	auipc	a3,0x4
ffffffffc0204844:	a3068693          	addi	a3,a3,-1488 # ffffffffc0208270 <default_pmm_manager+0x538>
ffffffffc0204848:	00002617          	auipc	a2,0x2
ffffffffc020484c:	44860613          	addi	a2,a2,1096 # ffffffffc0206c90 <commands+0x410>
ffffffffc0204850:	23700593          	li	a1,567
ffffffffc0204854:	00003517          	auipc	a0,0x3
ffffffffc0204858:	51c50513          	addi	a0,a0,1308 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc020485c:	9adfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0204860:	00004697          	auipc	a3,0x4
ffffffffc0204864:	9e068693          	addi	a3,a3,-1568 # ffffffffc0208240 <default_pmm_manager+0x508>
ffffffffc0204868:	00002617          	auipc	a2,0x2
ffffffffc020486c:	42860613          	addi	a2,a2,1064 # ffffffffc0206c90 <commands+0x410>
ffffffffc0204870:	23300593          	li	a1,563
ffffffffc0204874:	00003517          	auipc	a0,0x3
ffffffffc0204878:	4fc50513          	addi	a0,a0,1276 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc020487c:	98dfb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204880 <copy_range>:
               bool share) {
ffffffffc0204880:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0204882:	00d667b3          	or	a5,a2,a3
               bool share) {
ffffffffc0204886:	f486                	sd	ra,104(sp)
ffffffffc0204888:	f0a2                	sd	s0,96(sp)
ffffffffc020488a:	eca6                	sd	s1,88(sp)
ffffffffc020488c:	e8ca                	sd	s2,80(sp)
ffffffffc020488e:	e4ce                	sd	s3,72(sp)
ffffffffc0204890:	e0d2                	sd	s4,64(sp)
ffffffffc0204892:	fc56                	sd	s5,56(sp)
ffffffffc0204894:	f85a                	sd	s6,48(sp)
ffffffffc0204896:	f45e                	sd	s7,40(sp)
ffffffffc0204898:	f062                	sd	s8,32(sp)
ffffffffc020489a:	ec66                	sd	s9,24(sp)
ffffffffc020489c:	e86a                	sd	s10,16(sp)
ffffffffc020489e:	e46e                	sd	s11,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02048a0:	17d2                	slli	a5,a5,0x34
ffffffffc02048a2:	1e079763          	bnez	a5,ffffffffc0204a90 <copy_range+0x210>
    assert(USER_ACCESS(start, end));
ffffffffc02048a6:	002007b7          	lui	a5,0x200
ffffffffc02048aa:	8432                	mv	s0,a2
ffffffffc02048ac:	16f66a63          	bltu	a2,a5,ffffffffc0204a20 <copy_range+0x1a0>
ffffffffc02048b0:	8936                	mv	s2,a3
ffffffffc02048b2:	16d67763          	bgeu	a2,a3,ffffffffc0204a20 <copy_range+0x1a0>
ffffffffc02048b6:	4785                	li	a5,1
ffffffffc02048b8:	07fe                	slli	a5,a5,0x1f
ffffffffc02048ba:	16d7e363          	bltu	a5,a3,ffffffffc0204a20 <copy_range+0x1a0>
ffffffffc02048be:	5b7d                	li	s6,-1
ffffffffc02048c0:	8aaa                	mv	s5,a0
ffffffffc02048c2:	89ae                	mv	s3,a1
        start += PGSIZE;
ffffffffc02048c4:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc02048c6:	000aec97          	auipc	s9,0xae
ffffffffc02048ca:	fd2c8c93          	addi	s9,s9,-46 # ffffffffc02b2898 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02048ce:	000aec17          	auipc	s8,0xae
ffffffffc02048d2:	fd2c0c13          	addi	s8,s8,-46 # ffffffffc02b28a0 <pages>
    return page - pages + nbase;
ffffffffc02048d6:	00080bb7          	lui	s7,0x80
    return KADDR(page2pa(page));
ffffffffc02048da:	00cb5b13          	srli	s6,s6,0xc
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc02048de:	4601                	li	a2,0
ffffffffc02048e0:	85a2                	mv	a1,s0
ffffffffc02048e2:	854e                	mv	a0,s3
ffffffffc02048e4:	c73fe0ef          	jal	ra,ffffffffc0203556 <get_pte>
ffffffffc02048e8:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc02048ea:	c175                	beqz	a0,ffffffffc02049ce <copy_range+0x14e>
        if (*ptep & PTE_V) {
ffffffffc02048ec:	611c                	ld	a5,0(a0)
ffffffffc02048ee:	8b85                	andi	a5,a5,1
ffffffffc02048f0:	e785                	bnez	a5,ffffffffc0204918 <copy_range+0x98>
        start += PGSIZE;
ffffffffc02048f2:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc02048f4:	ff2465e3          	bltu	s0,s2,ffffffffc02048de <copy_range+0x5e>
    return 0;
ffffffffc02048f8:	4501                	li	a0,0
}
ffffffffc02048fa:	70a6                	ld	ra,104(sp)
ffffffffc02048fc:	7406                	ld	s0,96(sp)
ffffffffc02048fe:	64e6                	ld	s1,88(sp)
ffffffffc0204900:	6946                	ld	s2,80(sp)
ffffffffc0204902:	69a6                	ld	s3,72(sp)
ffffffffc0204904:	6a06                	ld	s4,64(sp)
ffffffffc0204906:	7ae2                	ld	s5,56(sp)
ffffffffc0204908:	7b42                	ld	s6,48(sp)
ffffffffc020490a:	7ba2                	ld	s7,40(sp)
ffffffffc020490c:	7c02                	ld	s8,32(sp)
ffffffffc020490e:	6ce2                	ld	s9,24(sp)
ffffffffc0204910:	6d42                	ld	s10,16(sp)
ffffffffc0204912:	6da2                	ld	s11,8(sp)
ffffffffc0204914:	6165                	addi	sp,sp,112
ffffffffc0204916:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL) {
ffffffffc0204918:	4605                	li	a2,1
ffffffffc020491a:	85a2                	mv	a1,s0
ffffffffc020491c:	8556                	mv	a0,s5
ffffffffc020491e:	c39fe0ef          	jal	ra,ffffffffc0203556 <get_pte>
ffffffffc0204922:	c161                	beqz	a0,ffffffffc02049e2 <copy_range+0x162>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc0204924:	609c                	ld	a5,0(s1)
    if (!(pte & PTE_V)) {
ffffffffc0204926:	0017f713          	andi	a4,a5,1
ffffffffc020492a:	01f7f493          	andi	s1,a5,31
ffffffffc020492e:	14070563          	beqz	a4,ffffffffc0204a78 <copy_range+0x1f8>
    if (PPN(pa) >= npage) {
ffffffffc0204932:	000cb683          	ld	a3,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0204936:	078a                	slli	a5,a5,0x2
ffffffffc0204938:	00c7d713          	srli	a4,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020493c:	12d77263          	bgeu	a4,a3,ffffffffc0204a60 <copy_range+0x1e0>
    return &pages[PPN(pa) - nbase];
ffffffffc0204940:	000c3783          	ld	a5,0(s8)
ffffffffc0204944:	fff806b7          	lui	a3,0xfff80
ffffffffc0204948:	9736                	add	a4,a4,a3
ffffffffc020494a:	071a                	slli	a4,a4,0x6
            struct Page *npage = alloc_page();
ffffffffc020494c:	4505                	li	a0,1
ffffffffc020494e:	00e78db3          	add	s11,a5,a4
ffffffffc0204952:	af9fe0ef          	jal	ra,ffffffffc020344a <alloc_pages>
ffffffffc0204956:	8d2a                	mv	s10,a0
            assert(page != NULL);
ffffffffc0204958:	0a0d8463          	beqz	s11,ffffffffc0204a00 <copy_range+0x180>
            assert(npage != NULL);
ffffffffc020495c:	c175                	beqz	a0,ffffffffc0204a40 <copy_range+0x1c0>
    return page - pages + nbase;
ffffffffc020495e:	000c3703          	ld	a4,0(s8)
    return KADDR(page2pa(page));
ffffffffc0204962:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0204966:	40ed86b3          	sub	a3,s11,a4
ffffffffc020496a:	8699                	srai	a3,a3,0x6
ffffffffc020496c:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc020496e:	0166f7b3          	and	a5,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0204972:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204974:	06c7fa63          	bgeu	a5,a2,ffffffffc02049e8 <copy_range+0x168>
    return page - pages + nbase;
ffffffffc0204978:	40e507b3          	sub	a5,a0,a4
    return KADDR(page2pa(page));
ffffffffc020497c:	000ae717          	auipc	a4,0xae
ffffffffc0204980:	f3470713          	addi	a4,a4,-204 # ffffffffc02b28b0 <va_pa_offset>
ffffffffc0204984:	6308                	ld	a0,0(a4)
    return page - pages + nbase;
ffffffffc0204986:	8799                	srai	a5,a5,0x6
ffffffffc0204988:	97de                	add	a5,a5,s7
    return KADDR(page2pa(page));
ffffffffc020498a:	0167f733          	and	a4,a5,s6
ffffffffc020498e:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0204992:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0204994:	04c77963          	bgeu	a4,a2,ffffffffc02049e6 <copy_range+0x166>
            memcpy(kva_dst, kva_src, PGSIZE);
ffffffffc0204998:	6605                	lui	a2,0x1
ffffffffc020499a:	953e                	add	a0,a0,a5
ffffffffc020499c:	021010ef          	jal	ra,ffffffffc02061bc <memcpy>
            ret = page_insert(to, npage, start, perm);
ffffffffc02049a0:	86a6                	mv	a3,s1
ffffffffc02049a2:	8622                	mv	a2,s0
ffffffffc02049a4:	85ea                	mv	a1,s10
ffffffffc02049a6:	8556                	mv	a0,s5
ffffffffc02049a8:	a48ff0ef          	jal	ra,ffffffffc0203bf0 <page_insert>
            assert(ret == 0);
ffffffffc02049ac:	d139                	beqz	a0,ffffffffc02048f2 <copy_range+0x72>
ffffffffc02049ae:	00004697          	auipc	a3,0x4
ffffffffc02049b2:	96268693          	addi	a3,a3,-1694 # ffffffffc0208310 <default_pmm_manager+0x5d8>
ffffffffc02049b6:	00002617          	auipc	a2,0x2
ffffffffc02049ba:	2da60613          	addi	a2,a2,730 # ffffffffc0206c90 <commands+0x410>
ffffffffc02049be:	18c00593          	li	a1,396
ffffffffc02049c2:	00003517          	auipc	a0,0x3
ffffffffc02049c6:	3ae50513          	addi	a0,a0,942 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc02049ca:	83ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02049ce:	00200637          	lui	a2,0x200
ffffffffc02049d2:	9432                	add	s0,s0,a2
ffffffffc02049d4:	ffe00637          	lui	a2,0xffe00
ffffffffc02049d8:	8c71                	and	s0,s0,a2
    } while (start != 0 && start < end);
ffffffffc02049da:	dc19                	beqz	s0,ffffffffc02048f8 <copy_range+0x78>
ffffffffc02049dc:	f12461e3          	bltu	s0,s2,ffffffffc02048de <copy_range+0x5e>
ffffffffc02049e0:	bf21                	j	ffffffffc02048f8 <copy_range+0x78>
                return -E_NO_MEM;
ffffffffc02049e2:	5571                	li	a0,-4
ffffffffc02049e4:	bf19                	j	ffffffffc02048fa <copy_range+0x7a>
ffffffffc02049e6:	86be                	mv	a3,a5
ffffffffc02049e8:	00003617          	auipc	a2,0x3
ffffffffc02049ec:	87860613          	addi	a2,a2,-1928 # ffffffffc0207260 <commands+0x9e0>
ffffffffc02049f0:	06900593          	li	a1,105
ffffffffc02049f4:	00003517          	auipc	a0,0x3
ffffffffc02049f8:	85c50513          	addi	a0,a0,-1956 # ffffffffc0207250 <commands+0x9d0>
ffffffffc02049fc:	80dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
            assert(page != NULL);
ffffffffc0204a00:	00004697          	auipc	a3,0x4
ffffffffc0204a04:	8f068693          	addi	a3,a3,-1808 # ffffffffc02082f0 <default_pmm_manager+0x5b8>
ffffffffc0204a08:	00002617          	auipc	a2,0x2
ffffffffc0204a0c:	28860613          	addi	a2,a2,648 # ffffffffc0206c90 <commands+0x410>
ffffffffc0204a10:	17200593          	li	a1,370
ffffffffc0204a14:	00003517          	auipc	a0,0x3
ffffffffc0204a18:	35c50513          	addi	a0,a0,860 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc0204a1c:	fecfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0204a20:	00003697          	auipc	a3,0x3
ffffffffc0204a24:	39068693          	addi	a3,a3,912 # ffffffffc0207db0 <default_pmm_manager+0x78>
ffffffffc0204a28:	00002617          	auipc	a2,0x2
ffffffffc0204a2c:	26860613          	addi	a2,a2,616 # ffffffffc0206c90 <commands+0x410>
ffffffffc0204a30:	15e00593          	li	a1,350
ffffffffc0204a34:	00003517          	auipc	a0,0x3
ffffffffc0204a38:	33c50513          	addi	a0,a0,828 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc0204a3c:	fccfb0ef          	jal	ra,ffffffffc0200208 <__panic>
            assert(npage != NULL);
ffffffffc0204a40:	00004697          	auipc	a3,0x4
ffffffffc0204a44:	8c068693          	addi	a3,a3,-1856 # ffffffffc0208300 <default_pmm_manager+0x5c8>
ffffffffc0204a48:	00002617          	auipc	a2,0x2
ffffffffc0204a4c:	24860613          	addi	a2,a2,584 # ffffffffc0206c90 <commands+0x410>
ffffffffc0204a50:	17300593          	li	a1,371
ffffffffc0204a54:	00003517          	auipc	a0,0x3
ffffffffc0204a58:	31c50513          	addi	a0,a0,796 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc0204a5c:	facfb0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204a60:	00002617          	auipc	a2,0x2
ffffffffc0204a64:	7d060613          	addi	a2,a2,2000 # ffffffffc0207230 <commands+0x9b0>
ffffffffc0204a68:	06200593          	li	a1,98
ffffffffc0204a6c:	00002517          	auipc	a0,0x2
ffffffffc0204a70:	7e450513          	addi	a0,a0,2020 # ffffffffc0207250 <commands+0x9d0>
ffffffffc0204a74:	f94fb0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0204a78:	00003617          	auipc	a2,0x3
ffffffffc0204a7c:	b4060613          	addi	a2,a2,-1216 # ffffffffc02075b8 <commands+0xd38>
ffffffffc0204a80:	07400593          	li	a1,116
ffffffffc0204a84:	00002517          	auipc	a0,0x2
ffffffffc0204a88:	7cc50513          	addi	a0,a0,1996 # ffffffffc0207250 <commands+0x9d0>
ffffffffc0204a8c:	f7cfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0204a90:	00003697          	auipc	a3,0x3
ffffffffc0204a94:	2f068693          	addi	a3,a3,752 # ffffffffc0207d80 <default_pmm_manager+0x48>
ffffffffc0204a98:	00002617          	auipc	a2,0x2
ffffffffc0204a9c:	1f860613          	addi	a2,a2,504 # ffffffffc0206c90 <commands+0x410>
ffffffffc0204aa0:	15d00593          	li	a1,349
ffffffffc0204aa4:	00003517          	auipc	a0,0x3
ffffffffc0204aa8:	2cc50513          	addi	a0,a0,716 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc0204aac:	f5cfb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204ab0 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0204ab0:	12058073          	sfence.vma	a1
}
ffffffffc0204ab4:	8082                	ret

ffffffffc0204ab6 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0204ab6:	7179                	addi	sp,sp,-48
ffffffffc0204ab8:	e84a                	sd	s2,16(sp)
ffffffffc0204aba:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0204abc:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0204abe:	f022                	sd	s0,32(sp)
ffffffffc0204ac0:	ec26                	sd	s1,24(sp)
ffffffffc0204ac2:	e44e                	sd	s3,8(sp)
ffffffffc0204ac4:	f406                	sd	ra,40(sp)
ffffffffc0204ac6:	84ae                	mv	s1,a1
ffffffffc0204ac8:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0204aca:	981fe0ef          	jal	ra,ffffffffc020344a <alloc_pages>
ffffffffc0204ace:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0204ad0:	cd05                	beqz	a0,ffffffffc0204b08 <pgdir_alloc_page+0x52>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0204ad2:	85aa                	mv	a1,a0
ffffffffc0204ad4:	86ce                	mv	a3,s3
ffffffffc0204ad6:	8626                	mv	a2,s1
ffffffffc0204ad8:	854a                	mv	a0,s2
ffffffffc0204ada:	916ff0ef          	jal	ra,ffffffffc0203bf0 <page_insert>
ffffffffc0204ade:	ed0d                	bnez	a0,ffffffffc0204b18 <pgdir_alloc_page+0x62>
        if (swap_init_ok) {
ffffffffc0204ae0:	000ae797          	auipc	a5,0xae
ffffffffc0204ae4:	d987a783          	lw	a5,-616(a5) # ffffffffc02b2878 <swap_init_ok>
ffffffffc0204ae8:	c385                	beqz	a5,ffffffffc0204b08 <pgdir_alloc_page+0x52>
            if (check_mm_struct != NULL) {
ffffffffc0204aea:	000ae517          	auipc	a0,0xae
ffffffffc0204aee:	d6e53503          	ld	a0,-658(a0) # ffffffffc02b2858 <check_mm_struct>
ffffffffc0204af2:	c919                	beqz	a0,ffffffffc0204b08 <pgdir_alloc_page+0x52>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0204af4:	4681                	li	a3,0
ffffffffc0204af6:	8622                	mv	a2,s0
ffffffffc0204af8:	85a6                	mv	a1,s1
ffffffffc0204afa:	d06fd0ef          	jal	ra,ffffffffc0202000 <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc0204afe:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc0204b00:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc0204b02:	4785                	li	a5,1
ffffffffc0204b04:	04f71663          	bne	a4,a5,ffffffffc0204b50 <pgdir_alloc_page+0x9a>
}
ffffffffc0204b08:	70a2                	ld	ra,40(sp)
ffffffffc0204b0a:	8522                	mv	a0,s0
ffffffffc0204b0c:	7402                	ld	s0,32(sp)
ffffffffc0204b0e:	64e2                	ld	s1,24(sp)
ffffffffc0204b10:	6942                	ld	s2,16(sp)
ffffffffc0204b12:	69a2                	ld	s3,8(sp)
ffffffffc0204b14:	6145                	addi	sp,sp,48
ffffffffc0204b16:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204b18:	100027f3          	csrr	a5,sstatus
ffffffffc0204b1c:	8b89                	andi	a5,a5,2
ffffffffc0204b1e:	eb99                	bnez	a5,ffffffffc0204b34 <pgdir_alloc_page+0x7e>
        pmm_manager->free_pages(base, n);
ffffffffc0204b20:	000ae797          	auipc	a5,0xae
ffffffffc0204b24:	d887b783          	ld	a5,-632(a5) # ffffffffc02b28a8 <pmm_manager>
ffffffffc0204b28:	739c                	ld	a5,32(a5)
ffffffffc0204b2a:	8522                	mv	a0,s0
ffffffffc0204b2c:	4585                	li	a1,1
ffffffffc0204b2e:	9782                	jalr	a5
            return NULL;
ffffffffc0204b30:	4401                	li	s0,0
ffffffffc0204b32:	bfd9                	j	ffffffffc0204b08 <pgdir_alloc_page+0x52>
        intr_disable();
ffffffffc0204b34:	b15fb0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0204b38:	000ae797          	auipc	a5,0xae
ffffffffc0204b3c:	d707b783          	ld	a5,-656(a5) # ffffffffc02b28a8 <pmm_manager>
ffffffffc0204b40:	739c                	ld	a5,32(a5)
ffffffffc0204b42:	8522                	mv	a0,s0
ffffffffc0204b44:	4585                	li	a1,1
ffffffffc0204b46:	9782                	jalr	a5
            return NULL;
ffffffffc0204b48:	4401                	li	s0,0
        intr_enable();
ffffffffc0204b4a:	af9fb0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0204b4e:	bf6d                	j	ffffffffc0204b08 <pgdir_alloc_page+0x52>
                assert(page_ref(page) == 1);
ffffffffc0204b50:	00003697          	auipc	a3,0x3
ffffffffc0204b54:	7d068693          	addi	a3,a3,2000 # ffffffffc0208320 <default_pmm_manager+0x5e8>
ffffffffc0204b58:	00002617          	auipc	a2,0x2
ffffffffc0204b5c:	13860613          	addi	a2,a2,312 # ffffffffc0206c90 <commands+0x410>
ffffffffc0204b60:	1cb00593          	li	a1,459
ffffffffc0204b64:	00003517          	auipc	a0,0x3
ffffffffc0204b68:	20c50513          	addi	a0,a0,524 # ffffffffc0207d70 <default_pmm_manager+0x38>
ffffffffc0204b6c:	e9cfb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204b70 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204b70:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204b72:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204b74:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204b76:	9b3fb0ef          	jal	ra,ffffffffc0200528 <ide_device_valid>
ffffffffc0204b7a:	cd01                	beqz	a0,ffffffffc0204b92 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204b7c:	4505                	li	a0,1
ffffffffc0204b7e:	9b1fb0ef          	jal	ra,ffffffffc020052e <ide_device_size>
}
ffffffffc0204b82:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204b84:	810d                	srli	a0,a0,0x3
ffffffffc0204b86:	000ae797          	auipc	a5,0xae
ffffffffc0204b8a:	cea7b123          	sd	a0,-798(a5) # ffffffffc02b2868 <max_swap_offset>
}
ffffffffc0204b8e:	0141                	addi	sp,sp,16
ffffffffc0204b90:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204b92:	00003617          	auipc	a2,0x3
ffffffffc0204b96:	7a660613          	addi	a2,a2,1958 # ffffffffc0208338 <default_pmm_manager+0x600>
ffffffffc0204b9a:	45b5                	li	a1,13
ffffffffc0204b9c:	00003517          	auipc	a0,0x3
ffffffffc0204ba0:	7bc50513          	addi	a0,a0,1980 # ffffffffc0208358 <default_pmm_manager+0x620>
ffffffffc0204ba4:	e64fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204ba8 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204ba8:	1141                	addi	sp,sp,-16
ffffffffc0204baa:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204bac:	00855793          	srli	a5,a0,0x8
ffffffffc0204bb0:	cbb1                	beqz	a5,ffffffffc0204c04 <swapfs_read+0x5c>
ffffffffc0204bb2:	000ae717          	auipc	a4,0xae
ffffffffc0204bb6:	cb673703          	ld	a4,-842(a4) # ffffffffc02b2868 <max_swap_offset>
ffffffffc0204bba:	04e7f563          	bgeu	a5,a4,ffffffffc0204c04 <swapfs_read+0x5c>
    return page - pages + nbase;
ffffffffc0204bbe:	000ae617          	auipc	a2,0xae
ffffffffc0204bc2:	ce263603          	ld	a2,-798(a2) # ffffffffc02b28a0 <pages>
ffffffffc0204bc6:	8d91                	sub	a1,a1,a2
ffffffffc0204bc8:	4065d613          	srai	a2,a1,0x6
ffffffffc0204bcc:	00004717          	auipc	a4,0x4
ffffffffc0204bd0:	0e473703          	ld	a4,228(a4) # ffffffffc0208cb0 <nbase>
ffffffffc0204bd4:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204bd6:	00c61713          	slli	a4,a2,0xc
ffffffffc0204bda:	8331                	srli	a4,a4,0xc
ffffffffc0204bdc:	000ae697          	auipc	a3,0xae
ffffffffc0204be0:	cbc6b683          	ld	a3,-836(a3) # ffffffffc02b2898 <npage>
ffffffffc0204be4:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204be8:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204bea:	02d77963          	bgeu	a4,a3,ffffffffc0204c1c <swapfs_read+0x74>
}
ffffffffc0204bee:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204bf0:	000ae797          	auipc	a5,0xae
ffffffffc0204bf4:	cc07b783          	ld	a5,-832(a5) # ffffffffc02b28b0 <va_pa_offset>
ffffffffc0204bf8:	46a1                	li	a3,8
ffffffffc0204bfa:	963e                	add	a2,a2,a5
ffffffffc0204bfc:	4505                	li	a0,1
}
ffffffffc0204bfe:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c00:	935fb06f          	j	ffffffffc0200534 <ide_read_secs>
ffffffffc0204c04:	86aa                	mv	a3,a0
ffffffffc0204c06:	00003617          	auipc	a2,0x3
ffffffffc0204c0a:	76a60613          	addi	a2,a2,1898 # ffffffffc0208370 <default_pmm_manager+0x638>
ffffffffc0204c0e:	45d1                	li	a1,20
ffffffffc0204c10:	00003517          	auipc	a0,0x3
ffffffffc0204c14:	74850513          	addi	a0,a0,1864 # ffffffffc0208358 <default_pmm_manager+0x620>
ffffffffc0204c18:	df0fb0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0204c1c:	86b2                	mv	a3,a2
ffffffffc0204c1e:	06900593          	li	a1,105
ffffffffc0204c22:	00002617          	auipc	a2,0x2
ffffffffc0204c26:	63e60613          	addi	a2,a2,1598 # ffffffffc0207260 <commands+0x9e0>
ffffffffc0204c2a:	00002517          	auipc	a0,0x2
ffffffffc0204c2e:	62650513          	addi	a0,a0,1574 # ffffffffc0207250 <commands+0x9d0>
ffffffffc0204c32:	dd6fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204c36 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204c36:	1141                	addi	sp,sp,-16
ffffffffc0204c38:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c3a:	00855793          	srli	a5,a0,0x8
ffffffffc0204c3e:	cbb1                	beqz	a5,ffffffffc0204c92 <swapfs_write+0x5c>
ffffffffc0204c40:	000ae717          	auipc	a4,0xae
ffffffffc0204c44:	c2873703          	ld	a4,-984(a4) # ffffffffc02b2868 <max_swap_offset>
ffffffffc0204c48:	04e7f563          	bgeu	a5,a4,ffffffffc0204c92 <swapfs_write+0x5c>
    return page - pages + nbase;
ffffffffc0204c4c:	000ae617          	auipc	a2,0xae
ffffffffc0204c50:	c5463603          	ld	a2,-940(a2) # ffffffffc02b28a0 <pages>
ffffffffc0204c54:	8d91                	sub	a1,a1,a2
ffffffffc0204c56:	4065d613          	srai	a2,a1,0x6
ffffffffc0204c5a:	00004717          	auipc	a4,0x4
ffffffffc0204c5e:	05673703          	ld	a4,86(a4) # ffffffffc0208cb0 <nbase>
ffffffffc0204c62:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204c64:	00c61713          	slli	a4,a2,0xc
ffffffffc0204c68:	8331                	srli	a4,a4,0xc
ffffffffc0204c6a:	000ae697          	auipc	a3,0xae
ffffffffc0204c6e:	c2e6b683          	ld	a3,-978(a3) # ffffffffc02b2898 <npage>
ffffffffc0204c72:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204c76:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204c78:	02d77963          	bgeu	a4,a3,ffffffffc0204caa <swapfs_write+0x74>
}
ffffffffc0204c7c:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c7e:	000ae797          	auipc	a5,0xae
ffffffffc0204c82:	c327b783          	ld	a5,-974(a5) # ffffffffc02b28b0 <va_pa_offset>
ffffffffc0204c86:	46a1                	li	a3,8
ffffffffc0204c88:	963e                	add	a2,a2,a5
ffffffffc0204c8a:	4505                	li	a0,1
}
ffffffffc0204c8c:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c8e:	8cbfb06f          	j	ffffffffc0200558 <ide_write_secs>
ffffffffc0204c92:	86aa                	mv	a3,a0
ffffffffc0204c94:	00003617          	auipc	a2,0x3
ffffffffc0204c98:	6dc60613          	addi	a2,a2,1756 # ffffffffc0208370 <default_pmm_manager+0x638>
ffffffffc0204c9c:	45e5                	li	a1,25
ffffffffc0204c9e:	00003517          	auipc	a0,0x3
ffffffffc0204ca2:	6ba50513          	addi	a0,a0,1722 # ffffffffc0208358 <default_pmm_manager+0x620>
ffffffffc0204ca6:	d62fb0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0204caa:	86b2                	mv	a3,a2
ffffffffc0204cac:	06900593          	li	a1,105
ffffffffc0204cb0:	00002617          	auipc	a2,0x2
ffffffffc0204cb4:	5b060613          	addi	a2,a2,1456 # ffffffffc0207260 <commands+0x9e0>
ffffffffc0204cb8:	00002517          	auipc	a0,0x2
ffffffffc0204cbc:	59850513          	addi	a0,a0,1432 # ffffffffc0207250 <commands+0x9d0>
ffffffffc0204cc0:	d48fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204cc4 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0204cc4:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0204cc8:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0204ccc:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0204cce:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0204cd0:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0204cd4:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0204cd8:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0204cdc:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0204ce0:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0204ce4:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0204ce8:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0204cec:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0204cf0:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0204cf4:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0204cf8:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0204cfc:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0204d00:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0204d02:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0204d04:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0204d08:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0204d0c:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0204d10:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0204d14:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0204d18:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0204d1c:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0204d20:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0204d24:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0204d28:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0204d2c:	8082                	ret

ffffffffc0204d2e <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204d2e:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204d30:	9402                	jalr	s0

	jal do_exit
ffffffffc0204d32:	640000ef          	jal	ra,ffffffffc0205372 <do_exit>

ffffffffc0204d36 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204d36:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204d38:	10800513          	li	a0,264
alloc_proc(void) {
ffffffffc0204d3c:	e022                	sd	s0,0(sp)
ffffffffc0204d3e:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204d40:	e8cfd0ef          	jal	ra,ffffffffc02023cc <kmalloc>
ffffffffc0204d44:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204d46:	cd39                	beqz	a0,ffffffffc0204da4 <alloc_proc+0x6e>
     /*
     * below fields(add in LAB5) in proc_struct need to be initialized  
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
     */
    proc->state = PROC_UNINIT;              
ffffffffc0204d48:	57fd                	li	a5,-1
ffffffffc0204d4a:	1782                	slli	a5,a5,0x20
ffffffffc0204d4c:	e11c                	sd	a5,0(a0)
    proc->pid = -1;                        
    proc->runs = 0;                        
ffffffffc0204d4e:	00052423          	sw	zero,8(a0)
    proc->kstack = 0;
ffffffffc0204d52:	00053823          	sd	zero,16(a0)
    proc->need_resched = 0;                 
ffffffffc0204d56:	00053c23          	sd	zero,24(a0)
    proc->parent = NULL;                    
ffffffffc0204d5a:	02053023          	sd	zero,32(a0)
    proc->mm = NULL;                       
ffffffffc0204d5e:	02053423          	sd	zero,40(a0)
    memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204d62:	07000613          	li	a2,112
ffffffffc0204d66:	4581                	li	a1,0
ffffffffc0204d68:	03050513          	addi	a0,a0,48
ffffffffc0204d6c:	43e010ef          	jal	ra,ffffffffc02061aa <memset>
    proc->tf = NULL;                        
    proc->cr3 = boot_cr3;                   
ffffffffc0204d70:	000ae797          	auipc	a5,0xae
ffffffffc0204d74:	b187b783          	ld	a5,-1256(a5) # ffffffffc02b2888 <boot_cr3>
ffffffffc0204d78:	f45c                	sd	a5,168(s0)
    proc->tf = NULL;                        
ffffffffc0204d7a:	0a043023          	sd	zero,160(s0)
    proc->flags = 0;                        
ffffffffc0204d7e:	0a042823          	sw	zero,176(s0)
    for (int i = 0; i < PROC_NAME_LEN + 1; i++) {
ffffffffc0204d82:	0b440793          	addi	a5,s0,180
ffffffffc0204d86:	0c440713          	addi	a4,s0,196
    proc->name[i] =0; }
ffffffffc0204d8a:	00078023          	sb	zero,0(a5)
    for (int i = 0; i < PROC_NAME_LEN + 1; i++) {
ffffffffc0204d8e:	0785                	addi	a5,a5,1
ffffffffc0204d90:	fee79de3          	bne	a5,a4,ffffffffc0204d8a <alloc_proc+0x54>
    proc->wait_state = 0;
ffffffffc0204d94:	0e042623          	sw	zero,236(s0)
    proc->cptr =  NULL;
ffffffffc0204d98:	0e043823          	sd	zero,240(s0)
    proc->optr =  NULL;
ffffffffc0204d9c:	10043023          	sd	zero,256(s0)
    proc->yptr =  NULL;
ffffffffc0204da0:	0e043c23          	sd	zero,248(s0)
    }
    return proc;
}
ffffffffc0204da4:	60a2                	ld	ra,8(sp)
ffffffffc0204da6:	8522                	mv	a0,s0
ffffffffc0204da8:	6402                	ld	s0,0(sp)
ffffffffc0204daa:	0141                	addi	sp,sp,16
ffffffffc0204dac:	8082                	ret

ffffffffc0204dae <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204dae:	000ae797          	auipc	a5,0xae
ffffffffc0204db2:	b0a7b783          	ld	a5,-1270(a5) # ffffffffc02b28b8 <current>
ffffffffc0204db6:	73c8                	ld	a0,160(a5)
ffffffffc0204db8:	fbffb06f          	j	ffffffffc0200d76 <forkrets>

ffffffffc0204dbc <user_main>:

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204dbc:	000ae797          	auipc	a5,0xae
ffffffffc0204dc0:	afc7b783          	ld	a5,-1284(a5) # ffffffffc02b28b8 <current>
ffffffffc0204dc4:	43cc                	lw	a1,4(a5)
user_main(void *arg) {
ffffffffc0204dc6:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204dc8:	00003617          	auipc	a2,0x3
ffffffffc0204dcc:	5c860613          	addi	a2,a2,1480 # ffffffffc0208390 <default_pmm_manager+0x658>
ffffffffc0204dd0:	00003517          	auipc	a0,0x3
ffffffffc0204dd4:	5d050513          	addi	a0,a0,1488 # ffffffffc02083a0 <default_pmm_manager+0x668>
user_main(void *arg) {
ffffffffc0204dd8:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204dda:	af2fb0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0204dde:	3fe06797          	auipc	a5,0x3fe06
ffffffffc0204de2:	b9278793          	addi	a5,a5,-1134 # a970 <_binary_obj___user_forktest_out_size>
ffffffffc0204de6:	e43e                	sd	a5,8(sp)
ffffffffc0204de8:	00003517          	auipc	a0,0x3
ffffffffc0204dec:	5a850513          	addi	a0,a0,1448 # ffffffffc0208390 <default_pmm_manager+0x658>
ffffffffc0204df0:	00098797          	auipc	a5,0x98
ffffffffc0204df4:	bb878793          	addi	a5,a5,-1096 # ffffffffc029c9a8 <_binary_obj___user_forktest_out_start>
ffffffffc0204df8:	f03e                	sd	a5,32(sp)
ffffffffc0204dfa:	f42a                	sd	a0,40(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc0204dfc:	e802                	sd	zero,16(sp)
ffffffffc0204dfe:	330010ef          	jal	ra,ffffffffc020612e <strlen>
ffffffffc0204e02:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204e04:	4511                	li	a0,4
ffffffffc0204e06:	55a2                	lw	a1,40(sp)
ffffffffc0204e08:	4662                	lw	a2,24(sp)
ffffffffc0204e0a:	5682                	lw	a3,32(sp)
ffffffffc0204e0c:	4722                	lw	a4,8(sp)
ffffffffc0204e0e:	48a9                	li	a7,10
ffffffffc0204e10:	9002                	ebreak
ffffffffc0204e12:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204e14:	65c2                	ld	a1,16(sp)
ffffffffc0204e16:	00003517          	auipc	a0,0x3
ffffffffc0204e1a:	5b250513          	addi	a0,a0,1458 # ffffffffc02083c8 <default_pmm_manager+0x690>
ffffffffc0204e1e:	aaefb0ef          	jal	ra,ffffffffc02000cc <cprintf>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
ffffffffc0204e22:	00003617          	auipc	a2,0x3
ffffffffc0204e26:	5b660613          	addi	a2,a2,1462 # ffffffffc02083d8 <default_pmm_manager+0x6a0>
ffffffffc0204e2a:	34f00593          	li	a1,847
ffffffffc0204e2e:	00003517          	auipc	a0,0x3
ffffffffc0204e32:	5ca50513          	addi	a0,a0,1482 # ffffffffc02083f8 <default_pmm_manager+0x6c0>
ffffffffc0204e36:	bd2fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204e3a <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204e3a:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc0204e3c:	1141                	addi	sp,sp,-16
ffffffffc0204e3e:	e406                	sd	ra,8(sp)
ffffffffc0204e40:	c02007b7          	lui	a5,0xc0200
ffffffffc0204e44:	02f6ee63          	bltu	a3,a5,ffffffffc0204e80 <put_pgdir+0x46>
ffffffffc0204e48:	000ae517          	auipc	a0,0xae
ffffffffc0204e4c:	a6853503          	ld	a0,-1432(a0) # ffffffffc02b28b0 <va_pa_offset>
ffffffffc0204e50:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc0204e52:	82b1                	srli	a3,a3,0xc
ffffffffc0204e54:	000ae797          	auipc	a5,0xae
ffffffffc0204e58:	a447b783          	ld	a5,-1468(a5) # ffffffffc02b2898 <npage>
ffffffffc0204e5c:	02f6fe63          	bgeu	a3,a5,ffffffffc0204e98 <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0204e60:	00004517          	auipc	a0,0x4
ffffffffc0204e64:	e5053503          	ld	a0,-432(a0) # ffffffffc0208cb0 <nbase>
}
ffffffffc0204e68:	60a2                	ld	ra,8(sp)
ffffffffc0204e6a:	8e89                	sub	a3,a3,a0
ffffffffc0204e6c:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0204e6e:	000ae517          	auipc	a0,0xae
ffffffffc0204e72:	a3253503          	ld	a0,-1486(a0) # ffffffffc02b28a0 <pages>
ffffffffc0204e76:	4585                	li	a1,1
ffffffffc0204e78:	9536                	add	a0,a0,a3
}
ffffffffc0204e7a:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204e7c:	e60fe06f          	j	ffffffffc02034dc <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0204e80:	00003617          	auipc	a2,0x3
ffffffffc0204e84:	95860613          	addi	a2,a2,-1704 # ffffffffc02077d8 <commands+0xf58>
ffffffffc0204e88:	06e00593          	li	a1,110
ffffffffc0204e8c:	00002517          	auipc	a0,0x2
ffffffffc0204e90:	3c450513          	addi	a0,a0,964 # ffffffffc0207250 <commands+0x9d0>
ffffffffc0204e94:	b74fb0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204e98:	00002617          	auipc	a2,0x2
ffffffffc0204e9c:	39860613          	addi	a2,a2,920 # ffffffffc0207230 <commands+0x9b0>
ffffffffc0204ea0:	06200593          	li	a1,98
ffffffffc0204ea4:	00002517          	auipc	a0,0x2
ffffffffc0204ea8:	3ac50513          	addi	a0,a0,940 # ffffffffc0207250 <commands+0x9d0>
ffffffffc0204eac:	b5cfb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204eb0 <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204eb0:	7179                	addi	sp,sp,-48
ffffffffc0204eb2:	f026                	sd	s1,32(sp)
    if (proc != current) {
ffffffffc0204eb4:	000ae497          	auipc	s1,0xae
ffffffffc0204eb8:	a0448493          	addi	s1,s1,-1532 # ffffffffc02b28b8 <current>
ffffffffc0204ebc:	6098                	ld	a4,0(s1)
proc_run(struct proc_struct *proc) {
ffffffffc0204ebe:	f406                	sd	ra,40(sp)
ffffffffc0204ec0:	ec4a                	sd	s2,24(sp)
    if (proc != current) {
ffffffffc0204ec2:	02a70763          	beq	a4,a0,ffffffffc0204ef0 <proc_run+0x40>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204ec6:	100027f3          	csrr	a5,sstatus
ffffffffc0204eca:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204ecc:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204ece:	ef85                	bnez	a5,ffffffffc0204f06 <proc_run+0x56>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204ed0:	755c                	ld	a5,168(a0)
ffffffffc0204ed2:	56fd                	li	a3,-1
ffffffffc0204ed4:	16fe                	slli	a3,a3,0x3f
ffffffffc0204ed6:	83b1                	srli	a5,a5,0xc
        current = proc; 
ffffffffc0204ed8:	e088                	sd	a0,0(s1)
ffffffffc0204eda:	8fd5                	or	a5,a5,a3
ffffffffc0204edc:	18079073          	csrw	satp,a5
        switch_to(&(a->context), &(b->context)); 
ffffffffc0204ee0:	03050593          	addi	a1,a0,48
ffffffffc0204ee4:	03070513          	addi	a0,a4,48
ffffffffc0204ee8:	dddff0ef          	jal	ra,ffffffffc0204cc4 <switch_to>
    if (flag) {
ffffffffc0204eec:	00091763          	bnez	s2,ffffffffc0204efa <proc_run+0x4a>
}
ffffffffc0204ef0:	70a2                	ld	ra,40(sp)
ffffffffc0204ef2:	7482                	ld	s1,32(sp)
ffffffffc0204ef4:	6962                	ld	s2,24(sp)
ffffffffc0204ef6:	6145                	addi	sp,sp,48
ffffffffc0204ef8:	8082                	ret
ffffffffc0204efa:	70a2                	ld	ra,40(sp)
ffffffffc0204efc:	7482                	ld	s1,32(sp)
ffffffffc0204efe:	6962                	ld	s2,24(sp)
ffffffffc0204f00:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc0204f02:	f40fb06f          	j	ffffffffc0200642 <intr_enable>
ffffffffc0204f06:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0204f08:	f40fb0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        struct proc_struct *a = current , *b = proc; 
ffffffffc0204f0c:	6098                	ld	a4,0(s1)
        return 1;
ffffffffc0204f0e:	6522                	ld	a0,8(sp)
ffffffffc0204f10:	4905                	li	s2,1
ffffffffc0204f12:	bf7d                	j	ffffffffc0204ed0 <proc_run+0x20>

ffffffffc0204f14 <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204f14:	7159                	addi	sp,sp,-112
ffffffffc0204f16:	e8ca                	sd	s2,80(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204f18:	000ae917          	auipc	s2,0xae
ffffffffc0204f1c:	9b890913          	addi	s2,s2,-1608 # ffffffffc02b28d0 <nr_process>
ffffffffc0204f20:	00092703          	lw	a4,0(s2)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204f24:	f486                	sd	ra,104(sp)
ffffffffc0204f26:	f0a2                	sd	s0,96(sp)
ffffffffc0204f28:	eca6                	sd	s1,88(sp)
ffffffffc0204f2a:	e4ce                	sd	s3,72(sp)
ffffffffc0204f2c:	e0d2                	sd	s4,64(sp)
ffffffffc0204f2e:	fc56                	sd	s5,56(sp)
ffffffffc0204f30:	f85a                	sd	s6,48(sp)
ffffffffc0204f32:	f45e                	sd	s7,40(sp)
ffffffffc0204f34:	f062                	sd	s8,32(sp)
ffffffffc0204f36:	ec66                	sd	s9,24(sp)
ffffffffc0204f38:	e86a                	sd	s10,16(sp)
ffffffffc0204f3a:	e46e                	sd	s11,8(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204f3c:	6785                	lui	a5,0x1
ffffffffc0204f3e:	34f75063          	bge	a4,a5,ffffffffc020527e <do_fork+0x36a>
ffffffffc0204f42:	8a2a                	mv	s4,a0
ffffffffc0204f44:	89ae                	mv	s3,a1
ffffffffc0204f46:	8432                	mv	s0,a2
    proc = alloc_proc();    
ffffffffc0204f48:	defff0ef          	jal	ra,ffffffffc0204d36 <alloc_proc>
ffffffffc0204f4c:	84aa                	mv	s1,a0
    if (proc == NULL) { 
ffffffffc0204f4e:	2c050863          	beqz	a0,ffffffffc020521e <do_fork+0x30a>
    assert(current->wait_state == 0);
ffffffffc0204f52:	000aea97          	auipc	s5,0xae
ffffffffc0204f56:	966a8a93          	addi	s5,s5,-1690 # ffffffffc02b28b8 <current>
ffffffffc0204f5a:	000ab783          	ld	a5,0(s5)
ffffffffc0204f5e:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x8acc>
ffffffffc0204f62:	38071463          	bnez	a4,ffffffffc02052ea <do_fork+0x3d6>
    proc->parent = current;
ffffffffc0204f66:	f11c                	sd	a5,32(a0)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0204f68:	4509                	li	a0,2
ffffffffc0204f6a:	ce0fe0ef          	jal	ra,ffffffffc020344a <alloc_pages>
    if (page != NULL) {
ffffffffc0204f6e:	2c050763          	beqz	a0,ffffffffc020523c <do_fork+0x328>
    return page - pages + nbase;
ffffffffc0204f72:	000aed97          	auipc	s11,0xae
ffffffffc0204f76:	92ed8d93          	addi	s11,s11,-1746 # ffffffffc02b28a0 <pages>
ffffffffc0204f7a:	000db683          	ld	a3,0(s11)
    return KADDR(page2pa(page));
ffffffffc0204f7e:	000aed17          	auipc	s10,0xae
ffffffffc0204f82:	91ad0d13          	addi	s10,s10,-1766 # ffffffffc02b2898 <npage>
    return page - pages + nbase;
ffffffffc0204f86:	00004c97          	auipc	s9,0x4
ffffffffc0204f8a:	d2acbc83          	ld	s9,-726(s9) # ffffffffc0208cb0 <nbase>
ffffffffc0204f8e:	40d506b3          	sub	a3,a0,a3
ffffffffc0204f92:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204f94:	5c7d                	li	s8,-1
ffffffffc0204f96:	000d3783          	ld	a5,0(s10)
    return page - pages + nbase;
ffffffffc0204f9a:	96e6                	add	a3,a3,s9
    return KADDR(page2pa(page));
ffffffffc0204f9c:	00cc5c13          	srli	s8,s8,0xc
ffffffffc0204fa0:	0186f733          	and	a4,a3,s8
    return page2ppn(page) << PGSHIFT;
ffffffffc0204fa4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204fa6:	30f77963          	bgeu	a4,a5,ffffffffc02052b8 <do_fork+0x3a4>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0204faa:	000ab703          	ld	a4,0(s5)
ffffffffc0204fae:	000aea97          	auipc	s5,0xae
ffffffffc0204fb2:	902a8a93          	addi	s5,s5,-1790 # ffffffffc02b28b0 <va_pa_offset>
ffffffffc0204fb6:	000ab783          	ld	a5,0(s5)
ffffffffc0204fba:	02873b83          	ld	s7,40(a4)
ffffffffc0204fbe:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0204fc0:	e894                	sd	a3,16(s1)
    if (oldmm == NULL) {
ffffffffc0204fc2:	020b8863          	beqz	s7,ffffffffc0204ff2 <do_fork+0xde>
    if (clone_flags & CLONE_VM) {
ffffffffc0204fc6:	100a7a13          	andi	s4,s4,256
ffffffffc0204fca:	1c0a0163          	beqz	s4,ffffffffc020518c <do_fork+0x278>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc0204fce:	030ba703          	lw	a4,48(s7) # 80030 <_binary_obj___user_exit_out_size+0x74f08>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0204fd2:	018bb783          	ld	a5,24(s7)
ffffffffc0204fd6:	c02006b7          	lui	a3,0xc0200
ffffffffc0204fda:	2705                	addiw	a4,a4,1
ffffffffc0204fdc:	02eba823          	sw	a4,48(s7)
    proc->mm = mm;
ffffffffc0204fe0:	0374b423          	sd	s7,40(s1)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0204fe4:	2ed7e663          	bltu	a5,a3,ffffffffc02052d0 <do_fork+0x3bc>
ffffffffc0204fe8:	000ab703          	ld	a4,0(s5)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204fec:	6894                	ld	a3,16(s1)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0204fee:	8f99                	sub	a5,a5,a4
ffffffffc0204ff0:	f4dc                	sd	a5,168(s1)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204ff2:	6789                	lui	a5,0x2
ffffffffc0204ff4:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7cd8>
ffffffffc0204ff8:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc0204ffa:	8622                	mv	a2,s0
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204ffc:	f0d4                	sd	a3,160(s1)
    *(proc->tf) = *tf;
ffffffffc0204ffe:	87b6                	mv	a5,a3
ffffffffc0205000:	12040893          	addi	a7,s0,288
ffffffffc0205004:	00063803          	ld	a6,0(a2)
ffffffffc0205008:	6608                	ld	a0,8(a2)
ffffffffc020500a:	6a0c                	ld	a1,16(a2)
ffffffffc020500c:	6e18                	ld	a4,24(a2)
ffffffffc020500e:	0107b023          	sd	a6,0(a5)
ffffffffc0205012:	e788                	sd	a0,8(a5)
ffffffffc0205014:	eb8c                	sd	a1,16(a5)
ffffffffc0205016:	ef98                	sd	a4,24(a5)
ffffffffc0205018:	02060613          	addi	a2,a2,32
ffffffffc020501c:	02078793          	addi	a5,a5,32
ffffffffc0205020:	ff1612e3          	bne	a2,a7,ffffffffc0205004 <do_fork+0xf0>
    proc->tf->gpr.a0 = 0;
ffffffffc0205024:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1e>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0205028:	12098f63          	beqz	s3,ffffffffc0205166 <do_fork+0x252>
ffffffffc020502c:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0205030:	00000797          	auipc	a5,0x0
ffffffffc0205034:	d7e78793          	addi	a5,a5,-642 # ffffffffc0204dae <forkret>
ffffffffc0205038:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc020503a:	fc94                	sd	a3,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020503c:	100027f3          	csrr	a5,sstatus
ffffffffc0205040:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205042:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205044:	14079063          	bnez	a5,ffffffffc0205184 <do_fork+0x270>
    if (++ last_pid >= MAX_PID) {
ffffffffc0205048:	000a2817          	auipc	a6,0xa2
ffffffffc020504c:	32880813          	addi	a6,a6,808 # ffffffffc02a7370 <last_pid.1>
ffffffffc0205050:	00082783          	lw	a5,0(a6)
ffffffffc0205054:	6709                	lui	a4,0x2
ffffffffc0205056:	0017851b          	addiw	a0,a5,1
ffffffffc020505a:	00a82023          	sw	a0,0(a6)
ffffffffc020505e:	08e55d63          	bge	a0,a4,ffffffffc02050f8 <do_fork+0x1e4>
    if (last_pid >= next_safe) {
ffffffffc0205062:	000a2317          	auipc	t1,0xa2
ffffffffc0205066:	31230313          	addi	t1,t1,786 # ffffffffc02a7374 <next_safe.0>
ffffffffc020506a:	00032783          	lw	a5,0(t1)
ffffffffc020506e:	000ad417          	auipc	s0,0xad
ffffffffc0205072:	7c240413          	addi	s0,s0,1986 # ffffffffc02b2830 <proc_list>
ffffffffc0205076:	08f55963          	bge	a0,a5,ffffffffc0205108 <do_fork+0x1f4>
        proc->pid = get_pid();
ffffffffc020507a:	c0c8                	sw	a0,4(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc020507c:	45a9                	li	a1,10
ffffffffc020507e:	2501                	sext.w	a0,a0
ffffffffc0205080:	542010ef          	jal	ra,ffffffffc02065c2 <hash32>
ffffffffc0205084:	02051793          	slli	a5,a0,0x20
ffffffffc0205088:	01c7d513          	srli	a0,a5,0x1c
ffffffffc020508c:	000a9797          	auipc	a5,0xa9
ffffffffc0205090:	7a478793          	addi	a5,a5,1956 # ffffffffc02ae830 <hash_list>
ffffffffc0205094:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0205096:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0205098:	7094                	ld	a3,32(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc020509a:	0d848793          	addi	a5,s1,216
    prev->next = next->prev = elm;
ffffffffc020509e:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc02050a0:	6410                	ld	a2,8(s0)
    prev->next = next->prev = elm;
ffffffffc02050a2:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02050a4:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc02050a6:	0c848793          	addi	a5,s1,200
    elm->next = next;
ffffffffc02050aa:	f0ec                	sd	a1,224(s1)
    elm->prev = prev;
ffffffffc02050ac:	ece8                	sd	a0,216(s1)
    prev->next = next->prev = elm;
ffffffffc02050ae:	e21c                	sd	a5,0(a2)
ffffffffc02050b0:	e41c                	sd	a5,8(s0)
    elm->next = next;
ffffffffc02050b2:	e8f0                	sd	a2,208(s1)
    elm->prev = prev;
ffffffffc02050b4:	e4e0                	sd	s0,200(s1)
    proc->yptr = NULL;
ffffffffc02050b6:	0e04bc23          	sd	zero,248(s1)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02050ba:	10e4b023          	sd	a4,256(s1)
ffffffffc02050be:	c311                	beqz	a4,ffffffffc02050c2 <do_fork+0x1ae>
        proc->optr->yptr = proc;
ffffffffc02050c0:	ff64                	sd	s1,248(a4)
    nr_process ++;
ffffffffc02050c2:	00092783          	lw	a5,0(s2)
    proc->parent->cptr = proc;
ffffffffc02050c6:	fae4                	sd	s1,240(a3)
    nr_process ++;
ffffffffc02050c8:	2785                	addiw	a5,a5,1
ffffffffc02050ca:	00f92023          	sw	a5,0(s2)
    if (flag) {
ffffffffc02050ce:	14099a63          	bnez	s3,ffffffffc0205222 <do_fork+0x30e>
    wakeup_proc(proc);
ffffffffc02050d2:	8526                	mv	a0,s1
ffffffffc02050d4:	66f000ef          	jal	ra,ffffffffc0205f42 <wakeup_proc>
    ret = proc->pid;
ffffffffc02050d8:	40c8                	lw	a0,4(s1)
}
ffffffffc02050da:	70a6                	ld	ra,104(sp)
ffffffffc02050dc:	7406                	ld	s0,96(sp)
ffffffffc02050de:	64e6                	ld	s1,88(sp)
ffffffffc02050e0:	6946                	ld	s2,80(sp)
ffffffffc02050e2:	69a6                	ld	s3,72(sp)
ffffffffc02050e4:	6a06                	ld	s4,64(sp)
ffffffffc02050e6:	7ae2                	ld	s5,56(sp)
ffffffffc02050e8:	7b42                	ld	s6,48(sp)
ffffffffc02050ea:	7ba2                	ld	s7,40(sp)
ffffffffc02050ec:	7c02                	ld	s8,32(sp)
ffffffffc02050ee:	6ce2                	ld	s9,24(sp)
ffffffffc02050f0:	6d42                	ld	s10,16(sp)
ffffffffc02050f2:	6da2                	ld	s11,8(sp)
ffffffffc02050f4:	6165                	addi	sp,sp,112
ffffffffc02050f6:	8082                	ret
        last_pid = 1;
ffffffffc02050f8:	4785                	li	a5,1
ffffffffc02050fa:	00f82023          	sw	a5,0(a6)
        goto inside;
ffffffffc02050fe:	4505                	li	a0,1
ffffffffc0205100:	000a2317          	auipc	t1,0xa2
ffffffffc0205104:	27430313          	addi	t1,t1,628 # ffffffffc02a7374 <next_safe.0>
    return listelm->next;
ffffffffc0205108:	000ad417          	auipc	s0,0xad
ffffffffc020510c:	72840413          	addi	s0,s0,1832 # ffffffffc02b2830 <proc_list>
ffffffffc0205110:	00843e03          	ld	t3,8(s0)
        next_safe = MAX_PID;
ffffffffc0205114:	6789                	lui	a5,0x2
ffffffffc0205116:	00f32023          	sw	a5,0(t1)
ffffffffc020511a:	86aa                	mv	a3,a0
ffffffffc020511c:	4581                	li	a1,0
        while ((le = list_next(le)) != list) {
ffffffffc020511e:	6e89                	lui	t4,0x2
ffffffffc0205120:	108e0963          	beq	t3,s0,ffffffffc0205232 <do_fork+0x31e>
ffffffffc0205124:	88ae                	mv	a7,a1
ffffffffc0205126:	87f2                	mv	a5,t3
ffffffffc0205128:	6609                	lui	a2,0x2
ffffffffc020512a:	a811                	j	ffffffffc020513e <do_fork+0x22a>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc020512c:	00e6d663          	bge	a3,a4,ffffffffc0205138 <do_fork+0x224>
ffffffffc0205130:	00c75463          	bge	a4,a2,ffffffffc0205138 <do_fork+0x224>
ffffffffc0205134:	863a                	mv	a2,a4
ffffffffc0205136:	4885                	li	a7,1
ffffffffc0205138:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc020513a:	00878d63          	beq	a5,s0,ffffffffc0205154 <do_fork+0x240>
            if (proc->pid == last_pid) {
ffffffffc020513e:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_faultread_out_size-0x7c7c>
ffffffffc0205142:	fed715e3          	bne	a4,a3,ffffffffc020512c <do_fork+0x218>
                if (++ last_pid >= next_safe) {
ffffffffc0205146:	2685                	addiw	a3,a3,1
ffffffffc0205148:	0ec6d063          	bge	a3,a2,ffffffffc0205228 <do_fork+0x314>
ffffffffc020514c:	679c                	ld	a5,8(a5)
ffffffffc020514e:	4585                	li	a1,1
        while ((le = list_next(le)) != list) {
ffffffffc0205150:	fe8797e3          	bne	a5,s0,ffffffffc020513e <do_fork+0x22a>
ffffffffc0205154:	c581                	beqz	a1,ffffffffc020515c <do_fork+0x248>
ffffffffc0205156:	00d82023          	sw	a3,0(a6)
ffffffffc020515a:	8536                	mv	a0,a3
ffffffffc020515c:	f0088fe3          	beqz	a7,ffffffffc020507a <do_fork+0x166>
ffffffffc0205160:	00c32023          	sw	a2,0(t1)
ffffffffc0205164:	bf19                	j	ffffffffc020507a <do_fork+0x166>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0205166:	89b6                	mv	s3,a3
ffffffffc0205168:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc020516c:	00000797          	auipc	a5,0x0
ffffffffc0205170:	c4278793          	addi	a5,a5,-958 # ffffffffc0204dae <forkret>
ffffffffc0205174:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0205176:	fc94                	sd	a3,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205178:	100027f3          	csrr	a5,sstatus
ffffffffc020517c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020517e:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205180:	ec0784e3          	beqz	a5,ffffffffc0205048 <do_fork+0x134>
        intr_disable();
ffffffffc0205184:	cc4fb0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc0205188:	4985                	li	s3,1
ffffffffc020518a:	bd7d                	j	ffffffffc0205048 <do_fork+0x134>
    if ((mm = mm_create()) == NULL) {
ffffffffc020518c:	cbbfb0ef          	jal	ra,ffffffffc0200e46 <mm_create>
ffffffffc0205190:	8b2a                	mv	s6,a0
ffffffffc0205192:	c159                	beqz	a0,ffffffffc0205218 <do_fork+0x304>
    if ((page = alloc_page()) == NULL) {
ffffffffc0205194:	4505                	li	a0,1
ffffffffc0205196:	ab4fe0ef          	jal	ra,ffffffffc020344a <alloc_pages>
ffffffffc020519a:	cd25                	beqz	a0,ffffffffc0205212 <do_fork+0x2fe>
    return page - pages + nbase;
ffffffffc020519c:	000db683          	ld	a3,0(s11)
    return KADDR(page2pa(page));
ffffffffc02051a0:	000d3783          	ld	a5,0(s10)
    return page - pages + nbase;
ffffffffc02051a4:	40d506b3          	sub	a3,a0,a3
ffffffffc02051a8:	8699                	srai	a3,a3,0x6
ffffffffc02051aa:	96e6                	add	a3,a3,s9
    return KADDR(page2pa(page));
ffffffffc02051ac:	0186fc33          	and	s8,a3,s8
    return page2ppn(page) << PGSHIFT;
ffffffffc02051b0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02051b2:	10fc7363          	bgeu	s8,a5,ffffffffc02052b8 <do_fork+0x3a4>
ffffffffc02051b6:	000aba03          	ld	s4,0(s5)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc02051ba:	6605                	lui	a2,0x1
ffffffffc02051bc:	000ad597          	auipc	a1,0xad
ffffffffc02051c0:	6d45b583          	ld	a1,1748(a1) # ffffffffc02b2890 <boot_pgdir>
ffffffffc02051c4:	9a36                	add	s4,s4,a3
ffffffffc02051c6:	8552                	mv	a0,s4
ffffffffc02051c8:	7f5000ef          	jal	ra,ffffffffc02061bc <memcpy>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc02051cc:	038b8c13          	addi	s8,s7,56
    mm->pgdir = pgdir;
ffffffffc02051d0:	014b3c23          	sd	s4,24(s6)
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02051d4:	4785                	li	a5,1
ffffffffc02051d6:	40fc37af          	amoor.d	a5,a5,(s8)
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc02051da:	8b85                	andi	a5,a5,1
ffffffffc02051dc:	4a05                	li	s4,1
ffffffffc02051de:	c799                	beqz	a5,ffffffffc02051ec <do_fork+0x2d8>
        schedule();
ffffffffc02051e0:	5e3000ef          	jal	ra,ffffffffc0205fc2 <schedule>
ffffffffc02051e4:	414c37af          	amoor.d	a5,s4,(s8)
    while (!try_lock(lock)) {
ffffffffc02051e8:	8b85                	andi	a5,a5,1
ffffffffc02051ea:	fbfd                	bnez	a5,ffffffffc02051e0 <do_fork+0x2cc>
        ret = dup_mmap(mm, oldmm);
ffffffffc02051ec:	85de                	mv	a1,s7
ffffffffc02051ee:	855a                	mv	a0,s6
ffffffffc02051f0:	edffb0ef          	jal	ra,ffffffffc02010ce <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02051f4:	57f9                	li	a5,-2
ffffffffc02051f6:	60fc37af          	amoand.d	a5,a5,(s8)
ffffffffc02051fa:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc02051fc:	10078763          	beqz	a5,ffffffffc020530a <do_fork+0x3f6>
good_mm:
ffffffffc0205200:	8bda                	mv	s7,s6
    if (ret != 0) {
ffffffffc0205202:	dc0506e3          	beqz	a0,ffffffffc0204fce <do_fork+0xba>
    exit_mmap(mm);
ffffffffc0205206:	855a                	mv	a0,s6
ffffffffc0205208:	f61fb0ef          	jal	ra,ffffffffc0201168 <exit_mmap>
    put_pgdir(mm);
ffffffffc020520c:	855a                	mv	a0,s6
ffffffffc020520e:	c2dff0ef          	jal	ra,ffffffffc0204e3a <put_pgdir>
    mm_destroy(mm);
ffffffffc0205212:	855a                	mv	a0,s6
ffffffffc0205214:	db9fb0ef          	jal	ra,ffffffffc0200fcc <mm_destroy>
    kfree(proc);
ffffffffc0205218:	8526                	mv	a0,s1
ffffffffc020521a:	a62fd0ef          	jal	ra,ffffffffc020247c <kfree>
    ret = -E_NO_MEM;
ffffffffc020521e:	5571                	li	a0,-4
    return ret;
ffffffffc0205220:	bd6d                	j	ffffffffc02050da <do_fork+0x1c6>
        intr_enable();
ffffffffc0205222:	c20fb0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0205226:	b575                	j	ffffffffc02050d2 <do_fork+0x1be>
                    if (last_pid >= MAX_PID) {
ffffffffc0205228:	01d6c363          	blt	a3,t4,ffffffffc020522e <do_fork+0x31a>
                        last_pid = 1;
ffffffffc020522c:	4685                	li	a3,1
                    goto repeat;
ffffffffc020522e:	4585                	li	a1,1
ffffffffc0205230:	bdc5                	j	ffffffffc0205120 <do_fork+0x20c>
ffffffffc0205232:	c9a1                	beqz	a1,ffffffffc0205282 <do_fork+0x36e>
ffffffffc0205234:	00d82023          	sw	a3,0(a6)
    return last_pid;
ffffffffc0205238:	8536                	mv	a0,a3
ffffffffc020523a:	b581                	j	ffffffffc020507a <do_fork+0x166>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc020523c:	6894                	ld	a3,16(s1)
    return pa2page(PADDR(kva));
ffffffffc020523e:	c02007b7          	lui	a5,0xc0200
ffffffffc0205242:	04f6ef63          	bltu	a3,a5,ffffffffc02052a0 <do_fork+0x38c>
ffffffffc0205246:	000ad797          	auipc	a5,0xad
ffffffffc020524a:	66a7b783          	ld	a5,1642(a5) # ffffffffc02b28b0 <va_pa_offset>
ffffffffc020524e:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc0205252:	83b1                	srli	a5,a5,0xc
ffffffffc0205254:	000ad717          	auipc	a4,0xad
ffffffffc0205258:	64473703          	ld	a4,1604(a4) # ffffffffc02b2898 <npage>
ffffffffc020525c:	02e7f663          	bgeu	a5,a4,ffffffffc0205288 <do_fork+0x374>
    return &pages[PPN(pa) - nbase];
ffffffffc0205260:	00004717          	auipc	a4,0x4
ffffffffc0205264:	a5073703          	ld	a4,-1456(a4) # ffffffffc0208cb0 <nbase>
ffffffffc0205268:	8f99                	sub	a5,a5,a4
ffffffffc020526a:	079a                	slli	a5,a5,0x6
ffffffffc020526c:	000ad517          	auipc	a0,0xad
ffffffffc0205270:	63453503          	ld	a0,1588(a0) # ffffffffc02b28a0 <pages>
ffffffffc0205274:	4589                	li	a1,2
ffffffffc0205276:	953e                	add	a0,a0,a5
ffffffffc0205278:	a64fe0ef          	jal	ra,ffffffffc02034dc <free_pages>
}
ffffffffc020527c:	bf71                	j	ffffffffc0205218 <do_fork+0x304>
    int ret = -E_NO_FREE_PROC;
ffffffffc020527e:	556d                	li	a0,-5
ffffffffc0205280:	bda9                	j	ffffffffc02050da <do_fork+0x1c6>
    return last_pid;
ffffffffc0205282:	00082503          	lw	a0,0(a6)
ffffffffc0205286:	bbd5                	j	ffffffffc020507a <do_fork+0x166>
        panic("pa2page called with invalid pa");
ffffffffc0205288:	00002617          	auipc	a2,0x2
ffffffffc020528c:	fa860613          	addi	a2,a2,-88 # ffffffffc0207230 <commands+0x9b0>
ffffffffc0205290:	06200593          	li	a1,98
ffffffffc0205294:	00002517          	auipc	a0,0x2
ffffffffc0205298:	fbc50513          	addi	a0,a0,-68 # ffffffffc0207250 <commands+0x9d0>
ffffffffc020529c:	f6dfa0ef          	jal	ra,ffffffffc0200208 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02052a0:	00002617          	auipc	a2,0x2
ffffffffc02052a4:	53860613          	addi	a2,a2,1336 # ffffffffc02077d8 <commands+0xf58>
ffffffffc02052a8:	06e00593          	li	a1,110
ffffffffc02052ac:	00002517          	auipc	a0,0x2
ffffffffc02052b0:	fa450513          	addi	a0,a0,-92 # ffffffffc0207250 <commands+0x9d0>
ffffffffc02052b4:	f55fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc02052b8:	00002617          	auipc	a2,0x2
ffffffffc02052bc:	fa860613          	addi	a2,a2,-88 # ffffffffc0207260 <commands+0x9e0>
ffffffffc02052c0:	06900593          	li	a1,105
ffffffffc02052c4:	00002517          	auipc	a0,0x2
ffffffffc02052c8:	f8c50513          	addi	a0,a0,-116 # ffffffffc0207250 <commands+0x9d0>
ffffffffc02052cc:	f3dfa0ef          	jal	ra,ffffffffc0200208 <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc02052d0:	86be                	mv	a3,a5
ffffffffc02052d2:	00002617          	auipc	a2,0x2
ffffffffc02052d6:	50660613          	addi	a2,a2,1286 # ffffffffc02077d8 <commands+0xf58>
ffffffffc02052da:	16500593          	li	a1,357
ffffffffc02052de:	00003517          	auipc	a0,0x3
ffffffffc02052e2:	11a50513          	addi	a0,a0,282 # ffffffffc02083f8 <default_pmm_manager+0x6c0>
ffffffffc02052e6:	f23fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(current->wait_state == 0);
ffffffffc02052ea:	00003697          	auipc	a3,0x3
ffffffffc02052ee:	12668693          	addi	a3,a3,294 # ffffffffc0208410 <default_pmm_manager+0x6d8>
ffffffffc02052f2:	00002617          	auipc	a2,0x2
ffffffffc02052f6:	99e60613          	addi	a2,a2,-1634 # ffffffffc0206c90 <commands+0x410>
ffffffffc02052fa:	1b200593          	li	a1,434
ffffffffc02052fe:	00003517          	auipc	a0,0x3
ffffffffc0205302:	0fa50513          	addi	a0,a0,250 # ffffffffc02083f8 <default_pmm_manager+0x6c0>
ffffffffc0205306:	f03fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("Unlock failed.\n");
ffffffffc020530a:	00003617          	auipc	a2,0x3
ffffffffc020530e:	12660613          	addi	a2,a2,294 # ffffffffc0208430 <default_pmm_manager+0x6f8>
ffffffffc0205312:	03100593          	li	a1,49
ffffffffc0205316:	00003517          	auipc	a0,0x3
ffffffffc020531a:	12a50513          	addi	a0,a0,298 # ffffffffc0208440 <default_pmm_manager+0x708>
ffffffffc020531e:	eebfa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205322 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0205322:	7129                	addi	sp,sp,-320
ffffffffc0205324:	fa22                	sd	s0,304(sp)
ffffffffc0205326:	f626                	sd	s1,296(sp)
ffffffffc0205328:	f24a                	sd	s2,288(sp)
ffffffffc020532a:	84ae                	mv	s1,a1
ffffffffc020532c:	892a                	mv	s2,a0
ffffffffc020532e:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0205330:	4581                	li	a1,0
ffffffffc0205332:	12000613          	li	a2,288
ffffffffc0205336:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0205338:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020533a:	671000ef          	jal	ra,ffffffffc02061aa <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc020533e:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc0205340:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0205342:	100027f3          	csrr	a5,sstatus
ffffffffc0205346:	edd7f793          	andi	a5,a5,-291
ffffffffc020534a:	1207e793          	ori	a5,a5,288
ffffffffc020534e:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205350:	860a                	mv	a2,sp
ffffffffc0205352:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205356:	00000797          	auipc	a5,0x0
ffffffffc020535a:	9d878793          	addi	a5,a5,-1576 # ffffffffc0204d2e <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020535e:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205360:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205362:	bb3ff0ef          	jal	ra,ffffffffc0204f14 <do_fork>
}
ffffffffc0205366:	70f2                	ld	ra,312(sp)
ffffffffc0205368:	7452                	ld	s0,304(sp)
ffffffffc020536a:	74b2                	ld	s1,296(sp)
ffffffffc020536c:	7912                	ld	s2,288(sp)
ffffffffc020536e:	6131                	addi	sp,sp,320
ffffffffc0205370:	8082                	ret

ffffffffc0205372 <do_exit>:
do_exit(int error_code) {
ffffffffc0205372:	7179                	addi	sp,sp,-48
ffffffffc0205374:	f022                	sd	s0,32(sp)
    if (current == idleproc) {
ffffffffc0205376:	000ad417          	auipc	s0,0xad
ffffffffc020537a:	54240413          	addi	s0,s0,1346 # ffffffffc02b28b8 <current>
ffffffffc020537e:	601c                	ld	a5,0(s0)
do_exit(int error_code) {
ffffffffc0205380:	f406                	sd	ra,40(sp)
ffffffffc0205382:	ec26                	sd	s1,24(sp)
ffffffffc0205384:	e84a                	sd	s2,16(sp)
ffffffffc0205386:	e44e                	sd	s3,8(sp)
ffffffffc0205388:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc020538a:	000ad717          	auipc	a4,0xad
ffffffffc020538e:	53673703          	ld	a4,1334(a4) # ffffffffc02b28c0 <idleproc>
ffffffffc0205392:	0ce78c63          	beq	a5,a4,ffffffffc020546a <do_exit+0xf8>
    if (current == initproc) {
ffffffffc0205396:	000ad497          	auipc	s1,0xad
ffffffffc020539a:	53248493          	addi	s1,s1,1330 # ffffffffc02b28c8 <initproc>
ffffffffc020539e:	6098                	ld	a4,0(s1)
ffffffffc02053a0:	0ee78b63          	beq	a5,a4,ffffffffc0205496 <do_exit+0x124>
    struct mm_struct *mm = current->mm;
ffffffffc02053a4:	0287b983          	ld	s3,40(a5)
ffffffffc02053a8:	892a                	mv	s2,a0
    if (mm != NULL) {
ffffffffc02053aa:	02098663          	beqz	s3,ffffffffc02053d6 <do_exit+0x64>
ffffffffc02053ae:	000ad797          	auipc	a5,0xad
ffffffffc02053b2:	4da7b783          	ld	a5,1242(a5) # ffffffffc02b2888 <boot_cr3>
ffffffffc02053b6:	577d                	li	a4,-1
ffffffffc02053b8:	177e                	slli	a4,a4,0x3f
ffffffffc02053ba:	83b1                	srli	a5,a5,0xc
ffffffffc02053bc:	8fd9                	or	a5,a5,a4
ffffffffc02053be:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc02053c2:	0309a783          	lw	a5,48(s3)
ffffffffc02053c6:	fff7871b          	addiw	a4,a5,-1
ffffffffc02053ca:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc02053ce:	cb55                	beqz	a4,ffffffffc0205482 <do_exit+0x110>
        current->mm = NULL;
ffffffffc02053d0:	601c                	ld	a5,0(s0)
ffffffffc02053d2:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc02053d6:	601c                	ld	a5,0(s0)
ffffffffc02053d8:	470d                	li	a4,3
ffffffffc02053da:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc02053dc:	0f27a423          	sw	s2,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02053e0:	100027f3          	csrr	a5,sstatus
ffffffffc02053e4:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02053e6:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02053e8:	e3f9                	bnez	a5,ffffffffc02054ae <do_exit+0x13c>
        proc = current->parent;
ffffffffc02053ea:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD) {
ffffffffc02053ec:	800007b7          	lui	a5,0x80000
ffffffffc02053f0:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc02053f2:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc02053f4:	0ec52703          	lw	a4,236(a0)
ffffffffc02053f8:	0af70f63          	beq	a4,a5,ffffffffc02054b6 <do_exit+0x144>
        while (current->cptr != NULL) {
ffffffffc02053fc:	6018                	ld	a4,0(s0)
ffffffffc02053fe:	7b7c                	ld	a5,240(a4)
ffffffffc0205400:	c3a1                	beqz	a5,ffffffffc0205440 <do_exit+0xce>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205402:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205406:	490d                	li	s2,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205408:	0985                	addi	s3,s3,1
ffffffffc020540a:	a021                	j	ffffffffc0205412 <do_exit+0xa0>
        while (current->cptr != NULL) {
ffffffffc020540c:	6018                	ld	a4,0(s0)
ffffffffc020540e:	7b7c                	ld	a5,240(a4)
ffffffffc0205410:	cb85                	beqz	a5,ffffffffc0205440 <do_exit+0xce>
            current->cptr = proc->optr;
ffffffffc0205412:	1007b683          	ld	a3,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff4fd8>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205416:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc0205418:	fb74                	sd	a3,240(a4)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc020541a:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc020541c:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205420:	10e7b023          	sd	a4,256(a5)
ffffffffc0205424:	c311                	beqz	a4,ffffffffc0205428 <do_exit+0xb6>
                initproc->cptr->yptr = proc;
ffffffffc0205426:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205428:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc020542a:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc020542c:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020542e:	fd271fe3          	bne	a4,s2,ffffffffc020540c <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205432:	0ec52783          	lw	a5,236(a0)
ffffffffc0205436:	fd379be3          	bne	a5,s3,ffffffffc020540c <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc020543a:	309000ef          	jal	ra,ffffffffc0205f42 <wakeup_proc>
ffffffffc020543e:	b7f9                	j	ffffffffc020540c <do_exit+0x9a>
    if (flag) {
ffffffffc0205440:	020a1263          	bnez	s4,ffffffffc0205464 <do_exit+0xf2>
    schedule();
ffffffffc0205444:	37f000ef          	jal	ra,ffffffffc0205fc2 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc0205448:	601c                	ld	a5,0(s0)
ffffffffc020544a:	00003617          	auipc	a2,0x3
ffffffffc020544e:	02e60613          	addi	a2,a2,46 # ffffffffc0208478 <default_pmm_manager+0x740>
ffffffffc0205452:	20500593          	li	a1,517
ffffffffc0205456:	43d4                	lw	a3,4(a5)
ffffffffc0205458:	00003517          	auipc	a0,0x3
ffffffffc020545c:	fa050513          	addi	a0,a0,-96 # ffffffffc02083f8 <default_pmm_manager+0x6c0>
ffffffffc0205460:	da9fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        intr_enable();
ffffffffc0205464:	9defb0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0205468:	bff1                	j	ffffffffc0205444 <do_exit+0xd2>
        panic("idleproc exit.\n");
ffffffffc020546a:	00003617          	auipc	a2,0x3
ffffffffc020546e:	fee60613          	addi	a2,a2,-18 # ffffffffc0208458 <default_pmm_manager+0x720>
ffffffffc0205472:	1d900593          	li	a1,473
ffffffffc0205476:	00003517          	auipc	a0,0x3
ffffffffc020547a:	f8250513          	addi	a0,a0,-126 # ffffffffc02083f8 <default_pmm_manager+0x6c0>
ffffffffc020547e:	d8bfa0ef          	jal	ra,ffffffffc0200208 <__panic>
            exit_mmap(mm);
ffffffffc0205482:	854e                	mv	a0,s3
ffffffffc0205484:	ce5fb0ef          	jal	ra,ffffffffc0201168 <exit_mmap>
            put_pgdir(mm);
ffffffffc0205488:	854e                	mv	a0,s3
ffffffffc020548a:	9b1ff0ef          	jal	ra,ffffffffc0204e3a <put_pgdir>
            mm_destroy(mm);
ffffffffc020548e:	854e                	mv	a0,s3
ffffffffc0205490:	b3dfb0ef          	jal	ra,ffffffffc0200fcc <mm_destroy>
ffffffffc0205494:	bf35                	j	ffffffffc02053d0 <do_exit+0x5e>
        panic("initproc exit.\n");
ffffffffc0205496:	00003617          	auipc	a2,0x3
ffffffffc020549a:	fd260613          	addi	a2,a2,-46 # ffffffffc0208468 <default_pmm_manager+0x730>
ffffffffc020549e:	1dc00593          	li	a1,476
ffffffffc02054a2:	00003517          	auipc	a0,0x3
ffffffffc02054a6:	f5650513          	addi	a0,a0,-170 # ffffffffc02083f8 <default_pmm_manager+0x6c0>
ffffffffc02054aa:	d5ffa0ef          	jal	ra,ffffffffc0200208 <__panic>
        intr_disable();
ffffffffc02054ae:	99afb0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc02054b2:	4a05                	li	s4,1
ffffffffc02054b4:	bf1d                	j	ffffffffc02053ea <do_exit+0x78>
            wakeup_proc(proc);
ffffffffc02054b6:	28d000ef          	jal	ra,ffffffffc0205f42 <wakeup_proc>
ffffffffc02054ba:	b789                	j	ffffffffc02053fc <do_exit+0x8a>

ffffffffc02054bc <do_wait.part.0>:
do_wait(int pid, int *code_store) {
ffffffffc02054bc:	715d                	addi	sp,sp,-80
ffffffffc02054be:	f84a                	sd	s2,48(sp)
ffffffffc02054c0:	f44e                	sd	s3,40(sp)
        current->wait_state = WT_CHILD;
ffffffffc02054c2:	80000937          	lui	s2,0x80000
    if (0 < pid && pid < MAX_PID) {
ffffffffc02054c6:	6989                	lui	s3,0x2
do_wait(int pid, int *code_store) {
ffffffffc02054c8:	fc26                	sd	s1,56(sp)
ffffffffc02054ca:	f052                	sd	s4,32(sp)
ffffffffc02054cc:	ec56                	sd	s5,24(sp)
ffffffffc02054ce:	e85a                	sd	s6,16(sp)
ffffffffc02054d0:	e45e                	sd	s7,8(sp)
ffffffffc02054d2:	e486                	sd	ra,72(sp)
ffffffffc02054d4:	e0a2                	sd	s0,64(sp)
ffffffffc02054d6:	84aa                	mv	s1,a0
ffffffffc02054d8:	8a2e                	mv	s4,a1
        proc = current->cptr;
ffffffffc02054da:	000adb97          	auipc	s7,0xad
ffffffffc02054de:	3deb8b93          	addi	s7,s7,990 # ffffffffc02b28b8 <current>
    if (0 < pid && pid < MAX_PID) {
ffffffffc02054e2:	00050b1b          	sext.w	s6,a0
ffffffffc02054e6:	fff50a9b          	addiw	s5,a0,-1
ffffffffc02054ea:	19f9                	addi	s3,s3,-2
        current->wait_state = WT_CHILD;
ffffffffc02054ec:	0905                	addi	s2,s2,1
    if (pid != 0) {
ffffffffc02054ee:	ccbd                	beqz	s1,ffffffffc020556c <do_wait.part.0+0xb0>
    if (0 < pid && pid < MAX_PID) {
ffffffffc02054f0:	0359e863          	bltu	s3,s5,ffffffffc0205520 <do_wait.part.0+0x64>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02054f4:	45a9                	li	a1,10
ffffffffc02054f6:	855a                	mv	a0,s6
ffffffffc02054f8:	0ca010ef          	jal	ra,ffffffffc02065c2 <hash32>
ffffffffc02054fc:	02051793          	slli	a5,a0,0x20
ffffffffc0205500:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0205504:	000a9797          	auipc	a5,0xa9
ffffffffc0205508:	32c78793          	addi	a5,a5,812 # ffffffffc02ae830 <hash_list>
ffffffffc020550c:	953e                	add	a0,a0,a5
ffffffffc020550e:	842a                	mv	s0,a0
        while ((le = list_next(le)) != list) {
ffffffffc0205510:	a029                	j	ffffffffc020551a <do_wait.part.0+0x5e>
            if (proc->pid == pid) {
ffffffffc0205512:	f2c42783          	lw	a5,-212(s0)
ffffffffc0205516:	02978163          	beq	a5,s1,ffffffffc0205538 <do_wait.part.0+0x7c>
ffffffffc020551a:	6400                	ld	s0,8(s0)
        while ((le = list_next(le)) != list) {
ffffffffc020551c:	fe851be3          	bne	a0,s0,ffffffffc0205512 <do_wait.part.0+0x56>
    return -E_BAD_PROC;
ffffffffc0205520:	5579                	li	a0,-2
}
ffffffffc0205522:	60a6                	ld	ra,72(sp)
ffffffffc0205524:	6406                	ld	s0,64(sp)
ffffffffc0205526:	74e2                	ld	s1,56(sp)
ffffffffc0205528:	7942                	ld	s2,48(sp)
ffffffffc020552a:	79a2                	ld	s3,40(sp)
ffffffffc020552c:	7a02                	ld	s4,32(sp)
ffffffffc020552e:	6ae2                	ld	s5,24(sp)
ffffffffc0205530:	6b42                	ld	s6,16(sp)
ffffffffc0205532:	6ba2                	ld	s7,8(sp)
ffffffffc0205534:	6161                	addi	sp,sp,80
ffffffffc0205536:	8082                	ret
        if (proc != NULL && proc->parent == current) {
ffffffffc0205538:	000bb683          	ld	a3,0(s7)
ffffffffc020553c:	f4843783          	ld	a5,-184(s0)
ffffffffc0205540:	fed790e3          	bne	a5,a3,ffffffffc0205520 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205544:	f2842703          	lw	a4,-216(s0)
ffffffffc0205548:	478d                	li	a5,3
ffffffffc020554a:	0ef70b63          	beq	a4,a5,ffffffffc0205640 <do_wait.part.0+0x184>
        current->state = PROC_SLEEPING;
ffffffffc020554e:	4785                	li	a5,1
ffffffffc0205550:	c29c                	sw	a5,0(a3)
        current->wait_state = WT_CHILD;
ffffffffc0205552:	0f26a623          	sw	s2,236(a3)
        schedule();
ffffffffc0205556:	26d000ef          	jal	ra,ffffffffc0205fc2 <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc020555a:	000bb783          	ld	a5,0(s7)
ffffffffc020555e:	0b07a783          	lw	a5,176(a5)
ffffffffc0205562:	8b85                	andi	a5,a5,1
ffffffffc0205564:	d7c9                	beqz	a5,ffffffffc02054ee <do_wait.part.0+0x32>
            do_exit(-E_KILLED);
ffffffffc0205566:	555d                	li	a0,-9
ffffffffc0205568:	e0bff0ef          	jal	ra,ffffffffc0205372 <do_exit>
        proc = current->cptr;
ffffffffc020556c:	000bb683          	ld	a3,0(s7)
ffffffffc0205570:	7ae0                	ld	s0,240(a3)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc0205572:	d45d                	beqz	s0,ffffffffc0205520 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205574:	470d                	li	a4,3
ffffffffc0205576:	a021                	j	ffffffffc020557e <do_wait.part.0+0xc2>
        for (; proc != NULL; proc = proc->optr) {
ffffffffc0205578:	10043403          	ld	s0,256(s0)
ffffffffc020557c:	d869                	beqz	s0,ffffffffc020554e <do_wait.part.0+0x92>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020557e:	401c                	lw	a5,0(s0)
ffffffffc0205580:	fee79ce3          	bne	a5,a4,ffffffffc0205578 <do_wait.part.0+0xbc>
    if (proc == idleproc || proc == initproc) {
ffffffffc0205584:	000ad797          	auipc	a5,0xad
ffffffffc0205588:	33c7b783          	ld	a5,828(a5) # ffffffffc02b28c0 <idleproc>
ffffffffc020558c:	0c878963          	beq	a5,s0,ffffffffc020565e <do_wait.part.0+0x1a2>
ffffffffc0205590:	000ad797          	auipc	a5,0xad
ffffffffc0205594:	3387b783          	ld	a5,824(a5) # ffffffffc02b28c8 <initproc>
ffffffffc0205598:	0cf40363          	beq	s0,a5,ffffffffc020565e <do_wait.part.0+0x1a2>
    if (code_store != NULL) {
ffffffffc020559c:	000a0663          	beqz	s4,ffffffffc02055a8 <do_wait.part.0+0xec>
        *code_store = proc->exit_code;
ffffffffc02055a0:	0e842783          	lw	a5,232(s0)
ffffffffc02055a4:	00fa2023          	sw	a5,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb8>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02055a8:	100027f3          	csrr	a5,sstatus
ffffffffc02055ac:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02055ae:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02055b0:	e7c1                	bnez	a5,ffffffffc0205638 <do_wait.part.0+0x17c>
    __list_del(listelm->prev, listelm->next);
ffffffffc02055b2:	6c70                	ld	a2,216(s0)
ffffffffc02055b4:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc02055b6:	10043703          	ld	a4,256(s0)
        proc->optr->yptr = proc->yptr;
ffffffffc02055ba:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc02055bc:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02055be:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02055c0:	6470                	ld	a2,200(s0)
ffffffffc02055c2:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc02055c4:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02055c6:	e290                	sd	a2,0(a3)
    if (proc->optr != NULL) {
ffffffffc02055c8:	c319                	beqz	a4,ffffffffc02055ce <do_wait.part.0+0x112>
        proc->optr->yptr = proc->yptr;
ffffffffc02055ca:	ff7c                	sd	a5,248(a4)
    if (proc->yptr != NULL) {
ffffffffc02055cc:	7c7c                	ld	a5,248(s0)
ffffffffc02055ce:	c3b5                	beqz	a5,ffffffffc0205632 <do_wait.part.0+0x176>
        proc->yptr->optr = proc->optr;
ffffffffc02055d0:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc02055d4:	000ad717          	auipc	a4,0xad
ffffffffc02055d8:	2fc70713          	addi	a4,a4,764 # ffffffffc02b28d0 <nr_process>
ffffffffc02055dc:	431c                	lw	a5,0(a4)
ffffffffc02055de:	37fd                	addiw	a5,a5,-1
ffffffffc02055e0:	c31c                	sw	a5,0(a4)
    if (flag) {
ffffffffc02055e2:	e5a9                	bnez	a1,ffffffffc020562c <do_wait.part.0+0x170>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02055e4:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc02055e6:	c02007b7          	lui	a5,0xc0200
ffffffffc02055ea:	04f6ee63          	bltu	a3,a5,ffffffffc0205646 <do_wait.part.0+0x18a>
ffffffffc02055ee:	000ad797          	auipc	a5,0xad
ffffffffc02055f2:	2c27b783          	ld	a5,706(a5) # ffffffffc02b28b0 <va_pa_offset>
ffffffffc02055f6:	8e9d                	sub	a3,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc02055f8:	82b1                	srli	a3,a3,0xc
ffffffffc02055fa:	000ad797          	auipc	a5,0xad
ffffffffc02055fe:	29e7b783          	ld	a5,670(a5) # ffffffffc02b2898 <npage>
ffffffffc0205602:	06f6fa63          	bgeu	a3,a5,ffffffffc0205676 <do_wait.part.0+0x1ba>
    return &pages[PPN(pa) - nbase];
ffffffffc0205606:	00003517          	auipc	a0,0x3
ffffffffc020560a:	6aa53503          	ld	a0,1706(a0) # ffffffffc0208cb0 <nbase>
ffffffffc020560e:	8e89                	sub	a3,a3,a0
ffffffffc0205610:	069a                	slli	a3,a3,0x6
ffffffffc0205612:	000ad517          	auipc	a0,0xad
ffffffffc0205616:	28e53503          	ld	a0,654(a0) # ffffffffc02b28a0 <pages>
ffffffffc020561a:	9536                	add	a0,a0,a3
ffffffffc020561c:	4589                	li	a1,2
ffffffffc020561e:	ebffd0ef          	jal	ra,ffffffffc02034dc <free_pages>
    kfree(proc);
ffffffffc0205622:	8522                	mv	a0,s0
ffffffffc0205624:	e59fc0ef          	jal	ra,ffffffffc020247c <kfree>
    return 0;
ffffffffc0205628:	4501                	li	a0,0
ffffffffc020562a:	bde5                	j	ffffffffc0205522 <do_wait.part.0+0x66>
        intr_enable();
ffffffffc020562c:	816fb0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0205630:	bf55                	j	ffffffffc02055e4 <do_wait.part.0+0x128>
       proc->parent->cptr = proc->optr;
ffffffffc0205632:	701c                	ld	a5,32(s0)
ffffffffc0205634:	fbf8                	sd	a4,240(a5)
ffffffffc0205636:	bf79                	j	ffffffffc02055d4 <do_wait.part.0+0x118>
        intr_disable();
ffffffffc0205638:	810fb0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc020563c:	4585                	li	a1,1
ffffffffc020563e:	bf95                	j	ffffffffc02055b2 <do_wait.part.0+0xf6>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0205640:	f2840413          	addi	s0,s0,-216
ffffffffc0205644:	b781                	j	ffffffffc0205584 <do_wait.part.0+0xc8>
    return pa2page(PADDR(kva));
ffffffffc0205646:	00002617          	auipc	a2,0x2
ffffffffc020564a:	19260613          	addi	a2,a2,402 # ffffffffc02077d8 <commands+0xf58>
ffffffffc020564e:	06e00593          	li	a1,110
ffffffffc0205652:	00002517          	auipc	a0,0x2
ffffffffc0205656:	bfe50513          	addi	a0,a0,-1026 # ffffffffc0207250 <commands+0x9d0>
ffffffffc020565a:	baffa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("wait idleproc or initproc.\n");
ffffffffc020565e:	00003617          	auipc	a2,0x3
ffffffffc0205662:	e3a60613          	addi	a2,a2,-454 # ffffffffc0208498 <default_pmm_manager+0x760>
ffffffffc0205666:	2fd00593          	li	a1,765
ffffffffc020566a:	00003517          	auipc	a0,0x3
ffffffffc020566e:	d8e50513          	addi	a0,a0,-626 # ffffffffc02083f8 <default_pmm_manager+0x6c0>
ffffffffc0205672:	b97fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0205676:	00002617          	auipc	a2,0x2
ffffffffc020567a:	bba60613          	addi	a2,a2,-1094 # ffffffffc0207230 <commands+0x9b0>
ffffffffc020567e:	06200593          	li	a1,98
ffffffffc0205682:	00002517          	auipc	a0,0x2
ffffffffc0205686:	bce50513          	addi	a0,a0,-1074 # ffffffffc0207250 <commands+0x9d0>
ffffffffc020568a:	b7ffa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020568e <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc020568e:	1141                	addi	sp,sp,-16
ffffffffc0205690:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0205692:	e8bfd0ef          	jal	ra,ffffffffc020351c <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc0205696:	d33fc0ef          	jal	ra,ffffffffc02023c8 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc020569a:	4601                	li	a2,0
ffffffffc020569c:	4581                	li	a1,0
ffffffffc020569e:	fffff517          	auipc	a0,0xfffff
ffffffffc02056a2:	71e50513          	addi	a0,a0,1822 # ffffffffc0204dbc <user_main>
ffffffffc02056a6:	c7dff0ef          	jal	ra,ffffffffc0205322 <kernel_thread>
    if (pid <= 0) {
ffffffffc02056aa:	00a04563          	bgtz	a0,ffffffffc02056b4 <init_main+0x26>
ffffffffc02056ae:	a071                	j	ffffffffc020573a <init_main+0xac>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
ffffffffc02056b0:	113000ef          	jal	ra,ffffffffc0205fc2 <schedule>
    if (code_store != NULL) {
ffffffffc02056b4:	4581                	li	a1,0
ffffffffc02056b6:	4501                	li	a0,0
ffffffffc02056b8:	e05ff0ef          	jal	ra,ffffffffc02054bc <do_wait.part.0>
    while (do_wait(0, NULL) == 0) {
ffffffffc02056bc:	d975                	beqz	a0,ffffffffc02056b0 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc02056be:	00003517          	auipc	a0,0x3
ffffffffc02056c2:	e1a50513          	addi	a0,a0,-486 # ffffffffc02084d8 <default_pmm_manager+0x7a0>
ffffffffc02056c6:	a07fa0ef          	jal	ra,ffffffffc02000cc <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc02056ca:	000ad797          	auipc	a5,0xad
ffffffffc02056ce:	1fe7b783          	ld	a5,510(a5) # ffffffffc02b28c8 <initproc>
ffffffffc02056d2:	7bf8                	ld	a4,240(a5)
ffffffffc02056d4:	e339                	bnez	a4,ffffffffc020571a <init_main+0x8c>
ffffffffc02056d6:	7ff8                	ld	a4,248(a5)
ffffffffc02056d8:	e329                	bnez	a4,ffffffffc020571a <init_main+0x8c>
ffffffffc02056da:	1007b703          	ld	a4,256(a5)
ffffffffc02056de:	ef15                	bnez	a4,ffffffffc020571a <init_main+0x8c>
    assert(nr_process == 2);
ffffffffc02056e0:	000ad697          	auipc	a3,0xad
ffffffffc02056e4:	1f06a683          	lw	a3,496(a3) # ffffffffc02b28d0 <nr_process>
ffffffffc02056e8:	4709                	li	a4,2
ffffffffc02056ea:	0ae69463          	bne	a3,a4,ffffffffc0205792 <init_main+0x104>
    return listelm->next;
ffffffffc02056ee:	000ad697          	auipc	a3,0xad
ffffffffc02056f2:	14268693          	addi	a3,a3,322 # ffffffffc02b2830 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02056f6:	6698                	ld	a4,8(a3)
ffffffffc02056f8:	0c878793          	addi	a5,a5,200
ffffffffc02056fc:	06f71b63          	bne	a4,a5,ffffffffc0205772 <init_main+0xe4>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0205700:	629c                	ld	a5,0(a3)
ffffffffc0205702:	04f71863          	bne	a4,a5,ffffffffc0205752 <init_main+0xc4>

    cprintf("init check memory pass.\n");
ffffffffc0205706:	00003517          	auipc	a0,0x3
ffffffffc020570a:	eba50513          	addi	a0,a0,-326 # ffffffffc02085c0 <default_pmm_manager+0x888>
ffffffffc020570e:	9bffa0ef          	jal	ra,ffffffffc02000cc <cprintf>
    return 0;
}
ffffffffc0205712:	60a2                	ld	ra,8(sp)
ffffffffc0205714:	4501                	li	a0,0
ffffffffc0205716:	0141                	addi	sp,sp,16
ffffffffc0205718:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc020571a:	00003697          	auipc	a3,0x3
ffffffffc020571e:	de668693          	addi	a3,a3,-538 # ffffffffc0208500 <default_pmm_manager+0x7c8>
ffffffffc0205722:	00001617          	auipc	a2,0x1
ffffffffc0205726:	56e60613          	addi	a2,a2,1390 # ffffffffc0206c90 <commands+0x410>
ffffffffc020572a:	36200593          	li	a1,866
ffffffffc020572e:	00003517          	auipc	a0,0x3
ffffffffc0205732:	cca50513          	addi	a0,a0,-822 # ffffffffc02083f8 <default_pmm_manager+0x6c0>
ffffffffc0205736:	ad3fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("create user_main failed.\n");
ffffffffc020573a:	00003617          	auipc	a2,0x3
ffffffffc020573e:	d7e60613          	addi	a2,a2,-642 # ffffffffc02084b8 <default_pmm_manager+0x780>
ffffffffc0205742:	35a00593          	li	a1,858
ffffffffc0205746:	00003517          	auipc	a0,0x3
ffffffffc020574a:	cb250513          	addi	a0,a0,-846 # ffffffffc02083f8 <default_pmm_manager+0x6c0>
ffffffffc020574e:	abbfa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0205752:	00003697          	auipc	a3,0x3
ffffffffc0205756:	e3e68693          	addi	a3,a3,-450 # ffffffffc0208590 <default_pmm_manager+0x858>
ffffffffc020575a:	00001617          	auipc	a2,0x1
ffffffffc020575e:	53660613          	addi	a2,a2,1334 # ffffffffc0206c90 <commands+0x410>
ffffffffc0205762:	36500593          	li	a1,869
ffffffffc0205766:	00003517          	auipc	a0,0x3
ffffffffc020576a:	c9250513          	addi	a0,a0,-878 # ffffffffc02083f8 <default_pmm_manager+0x6c0>
ffffffffc020576e:	a9bfa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0205772:	00003697          	auipc	a3,0x3
ffffffffc0205776:	dee68693          	addi	a3,a3,-530 # ffffffffc0208560 <default_pmm_manager+0x828>
ffffffffc020577a:	00001617          	auipc	a2,0x1
ffffffffc020577e:	51660613          	addi	a2,a2,1302 # ffffffffc0206c90 <commands+0x410>
ffffffffc0205782:	36400593          	li	a1,868
ffffffffc0205786:	00003517          	auipc	a0,0x3
ffffffffc020578a:	c7250513          	addi	a0,a0,-910 # ffffffffc02083f8 <default_pmm_manager+0x6c0>
ffffffffc020578e:	a7bfa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_process == 2);
ffffffffc0205792:	00003697          	auipc	a3,0x3
ffffffffc0205796:	dbe68693          	addi	a3,a3,-578 # ffffffffc0208550 <default_pmm_manager+0x818>
ffffffffc020579a:	00001617          	auipc	a2,0x1
ffffffffc020579e:	4f660613          	addi	a2,a2,1270 # ffffffffc0206c90 <commands+0x410>
ffffffffc02057a2:	36300593          	li	a1,867
ffffffffc02057a6:	00003517          	auipc	a0,0x3
ffffffffc02057aa:	c5250513          	addi	a0,a0,-942 # ffffffffc02083f8 <default_pmm_manager+0x6c0>
ffffffffc02057ae:	a5bfa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02057b2 <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02057b2:	7171                	addi	sp,sp,-176
ffffffffc02057b4:	e4ee                	sd	s11,72(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02057b6:	000add97          	auipc	s11,0xad
ffffffffc02057ba:	102d8d93          	addi	s11,s11,258 # ffffffffc02b28b8 <current>
ffffffffc02057be:	000db783          	ld	a5,0(s11)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02057c2:	e54e                	sd	s3,136(sp)
ffffffffc02057c4:	ed26                	sd	s1,152(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02057c6:	0287b983          	ld	s3,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02057ca:	e94a                	sd	s2,144(sp)
ffffffffc02057cc:	f4de                	sd	s7,104(sp)
ffffffffc02057ce:	892a                	mv	s2,a0
ffffffffc02057d0:	8bb2                	mv	s7,a2
ffffffffc02057d2:	84ae                	mv	s1,a1
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc02057d4:	862e                	mv	a2,a1
ffffffffc02057d6:	4681                	li	a3,0
ffffffffc02057d8:	85aa                	mv	a1,a0
ffffffffc02057da:	854e                	mv	a0,s3
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02057dc:	f506                	sd	ra,168(sp)
ffffffffc02057de:	f122                	sd	s0,160(sp)
ffffffffc02057e0:	e152                	sd	s4,128(sp)
ffffffffc02057e2:	fcd6                	sd	s5,120(sp)
ffffffffc02057e4:	f8da                	sd	s6,112(sp)
ffffffffc02057e6:	f0e2                	sd	s8,96(sp)
ffffffffc02057e8:	ece6                	sd	s9,88(sp)
ffffffffc02057ea:	e8ea                	sd	s10,80(sp)
ffffffffc02057ec:	f05e                	sd	s7,32(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc02057ee:	810fc0ef          	jal	ra,ffffffffc02017fe <user_mem_check>
ffffffffc02057f2:	40050a63          	beqz	a0,ffffffffc0205c06 <do_execve+0x454>
    memset(local_name, 0, sizeof(local_name));
ffffffffc02057f6:	4641                	li	a2,16
ffffffffc02057f8:	4581                	li	a1,0
ffffffffc02057fa:	1808                	addi	a0,sp,48
ffffffffc02057fc:	1af000ef          	jal	ra,ffffffffc02061aa <memset>
    memcpy(local_name, name, len);
ffffffffc0205800:	47bd                	li	a5,15
ffffffffc0205802:	8626                	mv	a2,s1
ffffffffc0205804:	1e97e263          	bltu	a5,s1,ffffffffc02059e8 <do_execve+0x236>
ffffffffc0205808:	85ca                	mv	a1,s2
ffffffffc020580a:	1808                	addi	a0,sp,48
ffffffffc020580c:	1b1000ef          	jal	ra,ffffffffc02061bc <memcpy>
    if (mm != NULL) {
ffffffffc0205810:	1e098363          	beqz	s3,ffffffffc02059f6 <do_execve+0x244>
        cputs("mm != NULL");
ffffffffc0205814:	00002517          	auipc	a0,0x2
ffffffffc0205818:	81450513          	addi	a0,a0,-2028 # ffffffffc0207028 <commands+0x7a8>
ffffffffc020581c:	8e9fa0ef          	jal	ra,ffffffffc0200104 <cputs>
ffffffffc0205820:	000ad797          	auipc	a5,0xad
ffffffffc0205824:	0687b783          	ld	a5,104(a5) # ffffffffc02b2888 <boot_cr3>
ffffffffc0205828:	577d                	li	a4,-1
ffffffffc020582a:	177e                	slli	a4,a4,0x3f
ffffffffc020582c:	83b1                	srli	a5,a5,0xc
ffffffffc020582e:	8fd9                	or	a5,a5,a4
ffffffffc0205830:	18079073          	csrw	satp,a5
ffffffffc0205834:	0309a783          	lw	a5,48(s3) # 2030 <_binary_obj___user_faultread_out_size-0x7b88>
ffffffffc0205838:	fff7871b          	addiw	a4,a5,-1
ffffffffc020583c:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205840:	2c070463          	beqz	a4,ffffffffc0205b08 <do_execve+0x356>
        current->mm = NULL;
ffffffffc0205844:	000db783          	ld	a5,0(s11)
ffffffffc0205848:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc020584c:	dfafb0ef          	jal	ra,ffffffffc0200e46 <mm_create>
ffffffffc0205850:	84aa                	mv	s1,a0
ffffffffc0205852:	1c050d63          	beqz	a0,ffffffffc0205a2c <do_execve+0x27a>
    if ((page = alloc_page()) == NULL) {
ffffffffc0205856:	4505                	li	a0,1
ffffffffc0205858:	bf3fd0ef          	jal	ra,ffffffffc020344a <alloc_pages>
ffffffffc020585c:	3a050963          	beqz	a0,ffffffffc0205c0e <do_execve+0x45c>
    return page - pages + nbase;
ffffffffc0205860:	000adc97          	auipc	s9,0xad
ffffffffc0205864:	040c8c93          	addi	s9,s9,64 # ffffffffc02b28a0 <pages>
ffffffffc0205868:	000cb683          	ld	a3,0(s9)
    return KADDR(page2pa(page));
ffffffffc020586c:	000adc17          	auipc	s8,0xad
ffffffffc0205870:	02cc0c13          	addi	s8,s8,44 # ffffffffc02b2898 <npage>
    return page - pages + nbase;
ffffffffc0205874:	00003717          	auipc	a4,0x3
ffffffffc0205878:	43c73703          	ld	a4,1084(a4) # ffffffffc0208cb0 <nbase>
ffffffffc020587c:	40d506b3          	sub	a3,a0,a3
ffffffffc0205880:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205882:	5afd                	li	s5,-1
ffffffffc0205884:	000c3783          	ld	a5,0(s8)
    return page - pages + nbase;
ffffffffc0205888:	96ba                	add	a3,a3,a4
ffffffffc020588a:	e83a                	sd	a4,16(sp)
    return KADDR(page2pa(page));
ffffffffc020588c:	00cad713          	srli	a4,s5,0xc
ffffffffc0205890:	ec3a                	sd	a4,24(sp)
ffffffffc0205892:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0205894:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205896:	38f77063          	bgeu	a4,a5,ffffffffc0205c16 <do_execve+0x464>
ffffffffc020589a:	000adb17          	auipc	s6,0xad
ffffffffc020589e:	016b0b13          	addi	s6,s6,22 # ffffffffc02b28b0 <va_pa_offset>
ffffffffc02058a2:	000b3903          	ld	s2,0(s6)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc02058a6:	6605                	lui	a2,0x1
ffffffffc02058a8:	000ad597          	auipc	a1,0xad
ffffffffc02058ac:	fe85b583          	ld	a1,-24(a1) # ffffffffc02b2890 <boot_pgdir>
ffffffffc02058b0:	9936                	add	s2,s2,a3
ffffffffc02058b2:	854a                	mv	a0,s2
ffffffffc02058b4:	109000ef          	jal	ra,ffffffffc02061bc <memcpy>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc02058b8:	7782                	ld	a5,32(sp)
ffffffffc02058ba:	4398                	lw	a4,0(a5)
ffffffffc02058bc:	464c47b7          	lui	a5,0x464c4
    mm->pgdir = pgdir;
ffffffffc02058c0:	0124bc23          	sd	s2,24(s1)
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc02058c4:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b9457>
ffffffffc02058c8:	14f71863          	bne	a4,a5,ffffffffc0205a18 <do_execve+0x266>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc02058cc:	7682                	ld	a3,32(sp)
ffffffffc02058ce:	0386d703          	lhu	a4,56(a3)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc02058d2:	0206b983          	ld	s3,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc02058d6:	00371793          	slli	a5,a4,0x3
ffffffffc02058da:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc02058dc:	99b6                	add	s3,s3,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc02058de:	078e                	slli	a5,a5,0x3
ffffffffc02058e0:	97ce                	add	a5,a5,s3
ffffffffc02058e2:	f43e                	sd	a5,40(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc02058e4:	00f9fc63          	bgeu	s3,a5,ffffffffc02058fc <do_execve+0x14a>
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc02058e8:	0009a783          	lw	a5,0(s3)
ffffffffc02058ec:	4705                	li	a4,1
ffffffffc02058ee:	14e78163          	beq	a5,a4,ffffffffc0205a30 <do_execve+0x27e>
    for (; ph < ph_end; ph ++) {
ffffffffc02058f2:	77a2                	ld	a5,40(sp)
ffffffffc02058f4:	03898993          	addi	s3,s3,56
ffffffffc02058f8:	fef9e8e3          	bltu	s3,a5,ffffffffc02058e8 <do_execve+0x136>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc02058fc:	4701                	li	a4,0
ffffffffc02058fe:	46ad                	li	a3,11
ffffffffc0205900:	00100637          	lui	a2,0x100
ffffffffc0205904:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0205908:	8526                	mv	a0,s1
ffffffffc020590a:	f14fb0ef          	jal	ra,ffffffffc020101e <mm_map>
ffffffffc020590e:	8a2a                	mv	s4,a0
ffffffffc0205910:	1e051263          	bnez	a0,ffffffffc0205af4 <do_execve+0x342>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205914:	6c88                	ld	a0,24(s1)
ffffffffc0205916:	467d                	li	a2,31
ffffffffc0205918:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc020591c:	99aff0ef          	jal	ra,ffffffffc0204ab6 <pgdir_alloc_page>
ffffffffc0205920:	38050363          	beqz	a0,ffffffffc0205ca6 <do_execve+0x4f4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205924:	6c88                	ld	a0,24(s1)
ffffffffc0205926:	467d                	li	a2,31
ffffffffc0205928:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc020592c:	98aff0ef          	jal	ra,ffffffffc0204ab6 <pgdir_alloc_page>
ffffffffc0205930:	34050b63          	beqz	a0,ffffffffc0205c86 <do_execve+0x4d4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205934:	6c88                	ld	a0,24(s1)
ffffffffc0205936:	467d                	li	a2,31
ffffffffc0205938:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc020593c:	97aff0ef          	jal	ra,ffffffffc0204ab6 <pgdir_alloc_page>
ffffffffc0205940:	32050363          	beqz	a0,ffffffffc0205c66 <do_execve+0x4b4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205944:	6c88                	ld	a0,24(s1)
ffffffffc0205946:	467d                	li	a2,31
ffffffffc0205948:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc020594c:	96aff0ef          	jal	ra,ffffffffc0204ab6 <pgdir_alloc_page>
ffffffffc0205950:	2e050b63          	beqz	a0,ffffffffc0205c46 <do_execve+0x494>
    mm->mm_count += 1;
ffffffffc0205954:	589c                	lw	a5,48(s1)
    current->mm = mm;
ffffffffc0205956:	000db603          	ld	a2,0(s11)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc020595a:	6c94                	ld	a3,24(s1)
ffffffffc020595c:	2785                	addiw	a5,a5,1
ffffffffc020595e:	d89c                	sw	a5,48(s1)
    current->mm = mm;
ffffffffc0205960:	f604                	sd	s1,40(a2)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205962:	c02007b7          	lui	a5,0xc0200
ffffffffc0205966:	2cf6e463          	bltu	a3,a5,ffffffffc0205c2e <do_execve+0x47c>
ffffffffc020596a:	000b3783          	ld	a5,0(s6)
ffffffffc020596e:	577d                	li	a4,-1
ffffffffc0205970:	177e                	slli	a4,a4,0x3f
ffffffffc0205972:	8e9d                	sub	a3,a3,a5
ffffffffc0205974:	00c6d793          	srli	a5,a3,0xc
ffffffffc0205978:	f654                	sd	a3,168(a2)
ffffffffc020597a:	8fd9                	or	a5,a5,a4
ffffffffc020597c:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0205980:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205982:	4581                	li	a1,0
ffffffffc0205984:	12000613          	li	a2,288
ffffffffc0205988:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc020598a:	10043483          	ld	s1,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc020598e:	01d000ef          	jal	ra,ffffffffc02061aa <memset>
    tf->epc = elf->e_entry;
ffffffffc0205992:	7782                	ld	a5,32(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205994:	000db903          	ld	s2,0(s11)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0205998:	edf4f493          	andi	s1,s1,-289
    tf->epc = elf->e_entry;
ffffffffc020599c:	6f98                	ld	a4,24(a5)
    tf->gpr.sp = USTACKTOP;
ffffffffc020599e:	4785                	li	a5,1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02059a0:	0b490913          	addi	s2,s2,180 # ffffffff800000b4 <_binary_obj___user_exit_out_size+0xffffffff7fff4f8c>
    tf->gpr.sp = USTACKTOP;
ffffffffc02059a4:	07fe                	slli	a5,a5,0x1f
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc02059a6:	0204e493          	ori	s1,s1,32
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02059aa:	4641                	li	a2,16
ffffffffc02059ac:	4581                	li	a1,0
    tf->gpr.sp = USTACKTOP;
ffffffffc02059ae:	e81c                	sd	a5,16(s0)
    tf->epc = elf->e_entry;
ffffffffc02059b0:	10e43423          	sd	a4,264(s0)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc02059b4:	10943023          	sd	s1,256(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02059b8:	854a                	mv	a0,s2
ffffffffc02059ba:	7f0000ef          	jal	ra,ffffffffc02061aa <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02059be:	463d                	li	a2,15
ffffffffc02059c0:	180c                	addi	a1,sp,48
ffffffffc02059c2:	854a                	mv	a0,s2
ffffffffc02059c4:	7f8000ef          	jal	ra,ffffffffc02061bc <memcpy>
}
ffffffffc02059c8:	70aa                	ld	ra,168(sp)
ffffffffc02059ca:	740a                	ld	s0,160(sp)
ffffffffc02059cc:	64ea                	ld	s1,152(sp)
ffffffffc02059ce:	694a                	ld	s2,144(sp)
ffffffffc02059d0:	69aa                	ld	s3,136(sp)
ffffffffc02059d2:	7ae6                	ld	s5,120(sp)
ffffffffc02059d4:	7b46                	ld	s6,112(sp)
ffffffffc02059d6:	7ba6                	ld	s7,104(sp)
ffffffffc02059d8:	7c06                	ld	s8,96(sp)
ffffffffc02059da:	6ce6                	ld	s9,88(sp)
ffffffffc02059dc:	6d46                	ld	s10,80(sp)
ffffffffc02059de:	6da6                	ld	s11,72(sp)
ffffffffc02059e0:	8552                	mv	a0,s4
ffffffffc02059e2:	6a0a                	ld	s4,128(sp)
ffffffffc02059e4:	614d                	addi	sp,sp,176
ffffffffc02059e6:	8082                	ret
    memcpy(local_name, name, len);
ffffffffc02059e8:	463d                	li	a2,15
ffffffffc02059ea:	85ca                	mv	a1,s2
ffffffffc02059ec:	1808                	addi	a0,sp,48
ffffffffc02059ee:	7ce000ef          	jal	ra,ffffffffc02061bc <memcpy>
    if (mm != NULL) {
ffffffffc02059f2:	e20991e3          	bnez	s3,ffffffffc0205814 <do_execve+0x62>
    if (current->mm != NULL) {
ffffffffc02059f6:	000db783          	ld	a5,0(s11)
ffffffffc02059fa:	779c                	ld	a5,40(a5)
ffffffffc02059fc:	e40788e3          	beqz	a5,ffffffffc020584c <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0205a00:	00003617          	auipc	a2,0x3
ffffffffc0205a04:	be060613          	addi	a2,a2,-1056 # ffffffffc02085e0 <default_pmm_manager+0x8a8>
ffffffffc0205a08:	20f00593          	li	a1,527
ffffffffc0205a0c:	00003517          	auipc	a0,0x3
ffffffffc0205a10:	9ec50513          	addi	a0,a0,-1556 # ffffffffc02083f8 <default_pmm_manager+0x6c0>
ffffffffc0205a14:	ff4fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    put_pgdir(mm);
ffffffffc0205a18:	8526                	mv	a0,s1
ffffffffc0205a1a:	c20ff0ef          	jal	ra,ffffffffc0204e3a <put_pgdir>
    mm_destroy(mm);
ffffffffc0205a1e:	8526                	mv	a0,s1
ffffffffc0205a20:	dacfb0ef          	jal	ra,ffffffffc0200fcc <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc0205a24:	5a61                	li	s4,-8
    do_exit(ret);
ffffffffc0205a26:	8552                	mv	a0,s4
ffffffffc0205a28:	94bff0ef          	jal	ra,ffffffffc0205372 <do_exit>
    int ret = -E_NO_MEM;
ffffffffc0205a2c:	5a71                	li	s4,-4
ffffffffc0205a2e:	bfe5                	j	ffffffffc0205a26 <do_execve+0x274>
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc0205a30:	0289b603          	ld	a2,40(s3)
ffffffffc0205a34:	0209b783          	ld	a5,32(s3)
ffffffffc0205a38:	1cf66d63          	bltu	a2,a5,ffffffffc0205c12 <do_execve+0x460>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205a3c:	0049a783          	lw	a5,4(s3)
ffffffffc0205a40:	0017f693          	andi	a3,a5,1
ffffffffc0205a44:	c291                	beqz	a3,ffffffffc0205a48 <do_execve+0x296>
ffffffffc0205a46:	4691                	li	a3,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205a48:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205a4c:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205a4e:	e779                	bnez	a4,ffffffffc0205b1c <do_execve+0x36a>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205a50:	4d45                	li	s10,17
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205a52:	c781                	beqz	a5,ffffffffc0205a5a <do_execve+0x2a8>
ffffffffc0205a54:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205a58:	4d4d                	li	s10,19
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205a5a:	0026f793          	andi	a5,a3,2
ffffffffc0205a5e:	e3f1                	bnez	a5,ffffffffc0205b22 <do_execve+0x370>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc0205a60:	0046f793          	andi	a5,a3,4
ffffffffc0205a64:	c399                	beqz	a5,ffffffffc0205a6a <do_execve+0x2b8>
ffffffffc0205a66:	008d6d13          	ori	s10,s10,8
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc0205a6a:	0109b583          	ld	a1,16(s3)
ffffffffc0205a6e:	4701                	li	a4,0
ffffffffc0205a70:	8526                	mv	a0,s1
ffffffffc0205a72:	dacfb0ef          	jal	ra,ffffffffc020101e <mm_map>
ffffffffc0205a76:	8a2a                	mv	s4,a0
ffffffffc0205a78:	ed35                	bnez	a0,ffffffffc0205af4 <do_execve+0x342>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205a7a:	0109bb83          	ld	s7,16(s3)
ffffffffc0205a7e:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0205a80:	0209ba03          	ld	s4,32(s3)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205a84:	0089b903          	ld	s2,8(s3)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205a88:	00fbfab3          	and	s5,s7,a5
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205a8c:	7782                	ld	a5,32(sp)
        end = ph->p_va + ph->p_filesz;
ffffffffc0205a8e:	9a5e                	add	s4,s4,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205a90:	993e                	add	s2,s2,a5
        while (start < end) {
ffffffffc0205a92:	054be963          	bltu	s7,s4,ffffffffc0205ae4 <do_execve+0x332>
ffffffffc0205a96:	aa95                	j	ffffffffc0205c0a <do_execve+0x458>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205a98:	6785                	lui	a5,0x1
ffffffffc0205a9a:	415b8533          	sub	a0,s7,s5
ffffffffc0205a9e:	9abe                	add	s5,s5,a5
ffffffffc0205aa0:	417a8633          	sub	a2,s5,s7
            if (end < la) {
ffffffffc0205aa4:	015a7463          	bgeu	s4,s5,ffffffffc0205aac <do_execve+0x2fa>
                size -= la - end;
ffffffffc0205aa8:	417a0633          	sub	a2,s4,s7
    return page - pages + nbase;
ffffffffc0205aac:	000cb683          	ld	a3,0(s9)
ffffffffc0205ab0:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205ab2:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0205ab6:	40d406b3          	sub	a3,s0,a3
ffffffffc0205aba:	8699                	srai	a3,a3,0x6
ffffffffc0205abc:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205abe:	67e2                	ld	a5,24(sp)
ffffffffc0205ac0:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205ac4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205ac6:	14b87863          	bgeu	a6,a1,ffffffffc0205c16 <do_execve+0x464>
ffffffffc0205aca:	000b3803          	ld	a6,0(s6)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205ace:	85ca                	mv	a1,s2
            start += size, from += size;
ffffffffc0205ad0:	9bb2                	add	s7,s7,a2
ffffffffc0205ad2:	96c2                	add	a3,a3,a6
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205ad4:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0205ad6:	e432                	sd	a2,8(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205ad8:	6e4000ef          	jal	ra,ffffffffc02061bc <memcpy>
            start += size, from += size;
ffffffffc0205adc:	6622                	ld	a2,8(sp)
ffffffffc0205ade:	9932                	add	s2,s2,a2
        while (start < end) {
ffffffffc0205ae0:	054bf363          	bgeu	s7,s4,ffffffffc0205b26 <do_execve+0x374>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205ae4:	6c88                	ld	a0,24(s1)
ffffffffc0205ae6:	866a                	mv	a2,s10
ffffffffc0205ae8:	85d6                	mv	a1,s5
ffffffffc0205aea:	fcdfe0ef          	jal	ra,ffffffffc0204ab6 <pgdir_alloc_page>
ffffffffc0205aee:	842a                	mv	s0,a0
ffffffffc0205af0:	f545                	bnez	a0,ffffffffc0205a98 <do_execve+0x2e6>
        ret = -E_NO_MEM;
ffffffffc0205af2:	5a71                	li	s4,-4
    exit_mmap(mm);
ffffffffc0205af4:	8526                	mv	a0,s1
ffffffffc0205af6:	e72fb0ef          	jal	ra,ffffffffc0201168 <exit_mmap>
    put_pgdir(mm);
ffffffffc0205afa:	8526                	mv	a0,s1
ffffffffc0205afc:	b3eff0ef          	jal	ra,ffffffffc0204e3a <put_pgdir>
    mm_destroy(mm);
ffffffffc0205b00:	8526                	mv	a0,s1
ffffffffc0205b02:	ccafb0ef          	jal	ra,ffffffffc0200fcc <mm_destroy>
    return ret;
ffffffffc0205b06:	b705                	j	ffffffffc0205a26 <do_execve+0x274>
            exit_mmap(mm);
ffffffffc0205b08:	854e                	mv	a0,s3
ffffffffc0205b0a:	e5efb0ef          	jal	ra,ffffffffc0201168 <exit_mmap>
            put_pgdir(mm);
ffffffffc0205b0e:	854e                	mv	a0,s3
ffffffffc0205b10:	b2aff0ef          	jal	ra,ffffffffc0204e3a <put_pgdir>
            mm_destroy(mm);
ffffffffc0205b14:	854e                	mv	a0,s3
ffffffffc0205b16:	cb6fb0ef          	jal	ra,ffffffffc0200fcc <mm_destroy>
ffffffffc0205b1a:	b32d                	j	ffffffffc0205844 <do_execve+0x92>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205b1c:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205b20:	fb95                	bnez	a5,ffffffffc0205a54 <do_execve+0x2a2>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205b22:	4d5d                	li	s10,23
ffffffffc0205b24:	bf35                	j	ffffffffc0205a60 <do_execve+0x2ae>
        end = ph->p_va + ph->p_memsz;
ffffffffc0205b26:	0109b683          	ld	a3,16(s3)
ffffffffc0205b2a:	0289b903          	ld	s2,40(s3)
ffffffffc0205b2e:	9936                	add	s2,s2,a3
        if (start < la) {
ffffffffc0205b30:	075bfd63          	bgeu	s7,s5,ffffffffc0205baa <do_execve+0x3f8>
            if (start == end) {
ffffffffc0205b34:	db790fe3          	beq	s2,s7,ffffffffc02058f2 <do_execve+0x140>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205b38:	6785                	lui	a5,0x1
ffffffffc0205b3a:	00fb8533          	add	a0,s7,a5
ffffffffc0205b3e:	41550533          	sub	a0,a0,s5
                size -= la - end;
ffffffffc0205b42:	41790a33          	sub	s4,s2,s7
            if (end < la) {
ffffffffc0205b46:	0b597d63          	bgeu	s2,s5,ffffffffc0205c00 <do_execve+0x44e>
    return page - pages + nbase;
ffffffffc0205b4a:	000cb683          	ld	a3,0(s9)
ffffffffc0205b4e:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205b50:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc0205b54:	40d406b3          	sub	a3,s0,a3
ffffffffc0205b58:	8699                	srai	a3,a3,0x6
ffffffffc0205b5a:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205b5c:	67e2                	ld	a5,24(sp)
ffffffffc0205b5e:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205b62:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205b64:	0ac5f963          	bgeu	a1,a2,ffffffffc0205c16 <do_execve+0x464>
ffffffffc0205b68:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205b6c:	8652                	mv	a2,s4
ffffffffc0205b6e:	4581                	li	a1,0
ffffffffc0205b70:	96c2                	add	a3,a3,a6
ffffffffc0205b72:	9536                	add	a0,a0,a3
ffffffffc0205b74:	636000ef          	jal	ra,ffffffffc02061aa <memset>
            start += size;
ffffffffc0205b78:	017a0733          	add	a4,s4,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205b7c:	03597463          	bgeu	s2,s5,ffffffffc0205ba4 <do_execve+0x3f2>
ffffffffc0205b80:	d6e909e3          	beq	s2,a4,ffffffffc02058f2 <do_execve+0x140>
ffffffffc0205b84:	00003697          	auipc	a3,0x3
ffffffffc0205b88:	a8468693          	addi	a3,a3,-1404 # ffffffffc0208608 <default_pmm_manager+0x8d0>
ffffffffc0205b8c:	00001617          	auipc	a2,0x1
ffffffffc0205b90:	10460613          	addi	a2,a2,260 # ffffffffc0206c90 <commands+0x410>
ffffffffc0205b94:	26400593          	li	a1,612
ffffffffc0205b98:	00003517          	auipc	a0,0x3
ffffffffc0205b9c:	86050513          	addi	a0,a0,-1952 # ffffffffc02083f8 <default_pmm_manager+0x6c0>
ffffffffc0205ba0:	e68fa0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0205ba4:	ff5710e3          	bne	a4,s5,ffffffffc0205b84 <do_execve+0x3d2>
ffffffffc0205ba8:	8bd6                	mv	s7,s5
        while (start < end) {
ffffffffc0205baa:	d52bf4e3          	bgeu	s7,s2,ffffffffc02058f2 <do_execve+0x140>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205bae:	6c88                	ld	a0,24(s1)
ffffffffc0205bb0:	866a                	mv	a2,s10
ffffffffc0205bb2:	85d6                	mv	a1,s5
ffffffffc0205bb4:	f03fe0ef          	jal	ra,ffffffffc0204ab6 <pgdir_alloc_page>
ffffffffc0205bb8:	842a                	mv	s0,a0
ffffffffc0205bba:	dd05                	beqz	a0,ffffffffc0205af2 <do_execve+0x340>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205bbc:	6785                	lui	a5,0x1
ffffffffc0205bbe:	415b8533          	sub	a0,s7,s5
ffffffffc0205bc2:	9abe                	add	s5,s5,a5
ffffffffc0205bc4:	417a8633          	sub	a2,s5,s7
            if (end < la) {
ffffffffc0205bc8:	01597463          	bgeu	s2,s5,ffffffffc0205bd0 <do_execve+0x41e>
                size -= la - end;
ffffffffc0205bcc:	41790633          	sub	a2,s2,s7
    return page - pages + nbase;
ffffffffc0205bd0:	000cb683          	ld	a3,0(s9)
ffffffffc0205bd4:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205bd6:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0205bda:	40d406b3          	sub	a3,s0,a3
ffffffffc0205bde:	8699                	srai	a3,a3,0x6
ffffffffc0205be0:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205be2:	67e2                	ld	a5,24(sp)
ffffffffc0205be4:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205be8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205bea:	02b87663          	bgeu	a6,a1,ffffffffc0205c16 <do_execve+0x464>
ffffffffc0205bee:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205bf2:	4581                	li	a1,0
            start += size;
ffffffffc0205bf4:	9bb2                	add	s7,s7,a2
ffffffffc0205bf6:	96c2                	add	a3,a3,a6
            memset(page2kva(page) + off, 0, size);
ffffffffc0205bf8:	9536                	add	a0,a0,a3
ffffffffc0205bfa:	5b0000ef          	jal	ra,ffffffffc02061aa <memset>
ffffffffc0205bfe:	b775                	j	ffffffffc0205baa <do_execve+0x3f8>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205c00:	417a8a33          	sub	s4,s5,s7
ffffffffc0205c04:	b799                	j	ffffffffc0205b4a <do_execve+0x398>
        return -E_INVAL;
ffffffffc0205c06:	5a75                	li	s4,-3
ffffffffc0205c08:	b3c1                	j	ffffffffc02059c8 <do_execve+0x216>
        while (start < end) {
ffffffffc0205c0a:	86de                	mv	a3,s7
ffffffffc0205c0c:	bf39                	j	ffffffffc0205b2a <do_execve+0x378>
    int ret = -E_NO_MEM;
ffffffffc0205c0e:	5a71                	li	s4,-4
ffffffffc0205c10:	bdc5                	j	ffffffffc0205b00 <do_execve+0x34e>
            ret = -E_INVAL_ELF;
ffffffffc0205c12:	5a61                	li	s4,-8
ffffffffc0205c14:	b5c5                	j	ffffffffc0205af4 <do_execve+0x342>
ffffffffc0205c16:	00001617          	auipc	a2,0x1
ffffffffc0205c1a:	64a60613          	addi	a2,a2,1610 # ffffffffc0207260 <commands+0x9e0>
ffffffffc0205c1e:	06900593          	li	a1,105
ffffffffc0205c22:	00001517          	auipc	a0,0x1
ffffffffc0205c26:	62e50513          	addi	a0,a0,1582 # ffffffffc0207250 <commands+0x9d0>
ffffffffc0205c2a:	ddefa0ef          	jal	ra,ffffffffc0200208 <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205c2e:	00002617          	auipc	a2,0x2
ffffffffc0205c32:	baa60613          	addi	a2,a2,-1110 # ffffffffc02077d8 <commands+0xf58>
ffffffffc0205c36:	27f00593          	li	a1,639
ffffffffc0205c3a:	00002517          	auipc	a0,0x2
ffffffffc0205c3e:	7be50513          	addi	a0,a0,1982 # ffffffffc02083f8 <default_pmm_manager+0x6c0>
ffffffffc0205c42:	dc6fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205c46:	00003697          	auipc	a3,0x3
ffffffffc0205c4a:	ada68693          	addi	a3,a3,-1318 # ffffffffc0208720 <default_pmm_manager+0x9e8>
ffffffffc0205c4e:	00001617          	auipc	a2,0x1
ffffffffc0205c52:	04260613          	addi	a2,a2,66 # ffffffffc0206c90 <commands+0x410>
ffffffffc0205c56:	27a00593          	li	a1,634
ffffffffc0205c5a:	00002517          	auipc	a0,0x2
ffffffffc0205c5e:	79e50513          	addi	a0,a0,1950 # ffffffffc02083f8 <default_pmm_manager+0x6c0>
ffffffffc0205c62:	da6fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205c66:	00003697          	auipc	a3,0x3
ffffffffc0205c6a:	a7268693          	addi	a3,a3,-1422 # ffffffffc02086d8 <default_pmm_manager+0x9a0>
ffffffffc0205c6e:	00001617          	auipc	a2,0x1
ffffffffc0205c72:	02260613          	addi	a2,a2,34 # ffffffffc0206c90 <commands+0x410>
ffffffffc0205c76:	27900593          	li	a1,633
ffffffffc0205c7a:	00002517          	auipc	a0,0x2
ffffffffc0205c7e:	77e50513          	addi	a0,a0,1918 # ffffffffc02083f8 <default_pmm_manager+0x6c0>
ffffffffc0205c82:	d86fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205c86:	00003697          	auipc	a3,0x3
ffffffffc0205c8a:	a0a68693          	addi	a3,a3,-1526 # ffffffffc0208690 <default_pmm_manager+0x958>
ffffffffc0205c8e:	00001617          	auipc	a2,0x1
ffffffffc0205c92:	00260613          	addi	a2,a2,2 # ffffffffc0206c90 <commands+0x410>
ffffffffc0205c96:	27800593          	li	a1,632
ffffffffc0205c9a:	00002517          	auipc	a0,0x2
ffffffffc0205c9e:	75e50513          	addi	a0,a0,1886 # ffffffffc02083f8 <default_pmm_manager+0x6c0>
ffffffffc0205ca2:	d66fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205ca6:	00003697          	auipc	a3,0x3
ffffffffc0205caa:	9a268693          	addi	a3,a3,-1630 # ffffffffc0208648 <default_pmm_manager+0x910>
ffffffffc0205cae:	00001617          	auipc	a2,0x1
ffffffffc0205cb2:	fe260613          	addi	a2,a2,-30 # ffffffffc0206c90 <commands+0x410>
ffffffffc0205cb6:	27700593          	li	a1,631
ffffffffc0205cba:	00002517          	auipc	a0,0x2
ffffffffc0205cbe:	73e50513          	addi	a0,a0,1854 # ffffffffc02083f8 <default_pmm_manager+0x6c0>
ffffffffc0205cc2:	d46fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205cc6 <do_yield>:
    current->need_resched = 1;
ffffffffc0205cc6:	000ad797          	auipc	a5,0xad
ffffffffc0205cca:	bf27b783          	ld	a5,-1038(a5) # ffffffffc02b28b8 <current>
ffffffffc0205cce:	4705                	li	a4,1
ffffffffc0205cd0:	ef98                	sd	a4,24(a5)
}
ffffffffc0205cd2:	4501                	li	a0,0
ffffffffc0205cd4:	8082                	ret

ffffffffc0205cd6 <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205cd6:	1101                	addi	sp,sp,-32
ffffffffc0205cd8:	e822                	sd	s0,16(sp)
ffffffffc0205cda:	e426                	sd	s1,8(sp)
ffffffffc0205cdc:	ec06                	sd	ra,24(sp)
ffffffffc0205cde:	842e                	mv	s0,a1
ffffffffc0205ce0:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205ce2:	c999                	beqz	a1,ffffffffc0205cf8 <do_wait+0x22>
    struct mm_struct *mm = current->mm;
ffffffffc0205ce4:	000ad797          	auipc	a5,0xad
ffffffffc0205ce8:	bd47b783          	ld	a5,-1068(a5) # ffffffffc02b28b8 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205cec:	7788                	ld	a0,40(a5)
ffffffffc0205cee:	4685                	li	a3,1
ffffffffc0205cf0:	4611                	li	a2,4
ffffffffc0205cf2:	b0dfb0ef          	jal	ra,ffffffffc02017fe <user_mem_check>
ffffffffc0205cf6:	c909                	beqz	a0,ffffffffc0205d08 <do_wait+0x32>
ffffffffc0205cf8:	85a2                	mv	a1,s0
}
ffffffffc0205cfa:	6442                	ld	s0,16(sp)
ffffffffc0205cfc:	60e2                	ld	ra,24(sp)
ffffffffc0205cfe:	8526                	mv	a0,s1
ffffffffc0205d00:	64a2                	ld	s1,8(sp)
ffffffffc0205d02:	6105                	addi	sp,sp,32
ffffffffc0205d04:	fb8ff06f          	j	ffffffffc02054bc <do_wait.part.0>
ffffffffc0205d08:	60e2                	ld	ra,24(sp)
ffffffffc0205d0a:	6442                	ld	s0,16(sp)
ffffffffc0205d0c:	64a2                	ld	s1,8(sp)
ffffffffc0205d0e:	5575                	li	a0,-3
ffffffffc0205d10:	6105                	addi	sp,sp,32
ffffffffc0205d12:	8082                	ret

ffffffffc0205d14 <do_kill>:
do_kill(int pid) {
ffffffffc0205d14:	1141                	addi	sp,sp,-16
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205d16:	6789                	lui	a5,0x2
do_kill(int pid) {
ffffffffc0205d18:	e406                	sd	ra,8(sp)
ffffffffc0205d1a:	e022                	sd	s0,0(sp)
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205d1c:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205d20:	17f9                	addi	a5,a5,-2
ffffffffc0205d22:	02e7e963          	bltu	a5,a4,ffffffffc0205d54 <do_kill+0x40>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205d26:	842a                	mv	s0,a0
ffffffffc0205d28:	45a9                	li	a1,10
ffffffffc0205d2a:	2501                	sext.w	a0,a0
ffffffffc0205d2c:	097000ef          	jal	ra,ffffffffc02065c2 <hash32>
ffffffffc0205d30:	02051793          	slli	a5,a0,0x20
ffffffffc0205d34:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0205d38:	000a9797          	auipc	a5,0xa9
ffffffffc0205d3c:	af878793          	addi	a5,a5,-1288 # ffffffffc02ae830 <hash_list>
ffffffffc0205d40:	953e                	add	a0,a0,a5
ffffffffc0205d42:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list) {
ffffffffc0205d44:	a029                	j	ffffffffc0205d4e <do_kill+0x3a>
            if (proc->pid == pid) {
ffffffffc0205d46:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0205d4a:	00870b63          	beq	a4,s0,ffffffffc0205d60 <do_kill+0x4c>
ffffffffc0205d4e:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205d50:	fef51be3          	bne	a0,a5,ffffffffc0205d46 <do_kill+0x32>
    return -E_INVAL;
ffffffffc0205d54:	5475                	li	s0,-3
}
ffffffffc0205d56:	60a2                	ld	ra,8(sp)
ffffffffc0205d58:	8522                	mv	a0,s0
ffffffffc0205d5a:	6402                	ld	s0,0(sp)
ffffffffc0205d5c:	0141                	addi	sp,sp,16
ffffffffc0205d5e:	8082                	ret
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205d60:	fd87a703          	lw	a4,-40(a5)
ffffffffc0205d64:	00177693          	andi	a3,a4,1
ffffffffc0205d68:	e295                	bnez	a3,ffffffffc0205d8c <do_kill+0x78>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205d6a:	4bd4                	lw	a3,20(a5)
            proc->flags |= PF_EXITING;
ffffffffc0205d6c:	00176713          	ori	a4,a4,1
ffffffffc0205d70:	fce7ac23          	sw	a4,-40(a5)
            return 0;
ffffffffc0205d74:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205d76:	fe06d0e3          	bgez	a3,ffffffffc0205d56 <do_kill+0x42>
                wakeup_proc(proc);
ffffffffc0205d7a:	f2878513          	addi	a0,a5,-216
ffffffffc0205d7e:	1c4000ef          	jal	ra,ffffffffc0205f42 <wakeup_proc>
}
ffffffffc0205d82:	60a2                	ld	ra,8(sp)
ffffffffc0205d84:	8522                	mv	a0,s0
ffffffffc0205d86:	6402                	ld	s0,0(sp)
ffffffffc0205d88:	0141                	addi	sp,sp,16
ffffffffc0205d8a:	8082                	ret
        return -E_KILLED;
ffffffffc0205d8c:	545d                	li	s0,-9
ffffffffc0205d8e:	b7e1                	j	ffffffffc0205d56 <do_kill+0x42>

ffffffffc0205d90 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205d90:	1101                	addi	sp,sp,-32
ffffffffc0205d92:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0205d94:	000ad797          	auipc	a5,0xad
ffffffffc0205d98:	a9c78793          	addi	a5,a5,-1380 # ffffffffc02b2830 <proc_list>
ffffffffc0205d9c:	ec06                	sd	ra,24(sp)
ffffffffc0205d9e:	e822                	sd	s0,16(sp)
ffffffffc0205da0:	e04a                	sd	s2,0(sp)
ffffffffc0205da2:	000a9497          	auipc	s1,0xa9
ffffffffc0205da6:	a8e48493          	addi	s1,s1,-1394 # ffffffffc02ae830 <hash_list>
ffffffffc0205daa:	e79c                	sd	a5,8(a5)
ffffffffc0205dac:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0205dae:	000ad717          	auipc	a4,0xad
ffffffffc0205db2:	a8270713          	addi	a4,a4,-1406 # ffffffffc02b2830 <proc_list>
ffffffffc0205db6:	87a6                	mv	a5,s1
ffffffffc0205db8:	e79c                	sd	a5,8(a5)
ffffffffc0205dba:	e39c                	sd	a5,0(a5)
ffffffffc0205dbc:	07c1                	addi	a5,a5,16
ffffffffc0205dbe:	fef71de3          	bne	a4,a5,ffffffffc0205db8 <proc_init+0x28>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0205dc2:	f75fe0ef          	jal	ra,ffffffffc0204d36 <alloc_proc>
ffffffffc0205dc6:	000ad917          	auipc	s2,0xad
ffffffffc0205dca:	afa90913          	addi	s2,s2,-1286 # ffffffffc02b28c0 <idleproc>
ffffffffc0205dce:	00a93023          	sd	a0,0(s2)
ffffffffc0205dd2:	0e050f63          	beqz	a0,ffffffffc0205ed0 <proc_init+0x140>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205dd6:	4789                	li	a5,2
ffffffffc0205dd8:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205dda:	00003797          	auipc	a5,0x3
ffffffffc0205dde:	22678793          	addi	a5,a5,550 # ffffffffc0209000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205de2:	0b450413          	addi	s0,a0,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205de6:	e91c                	sd	a5,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205de8:	4785                	li	a5,1
ffffffffc0205dea:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205dec:	4641                	li	a2,16
ffffffffc0205dee:	4581                	li	a1,0
ffffffffc0205df0:	8522                	mv	a0,s0
ffffffffc0205df2:	3b8000ef          	jal	ra,ffffffffc02061aa <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205df6:	463d                	li	a2,15
ffffffffc0205df8:	00003597          	auipc	a1,0x3
ffffffffc0205dfc:	98858593          	addi	a1,a1,-1656 # ffffffffc0208780 <default_pmm_manager+0xa48>
ffffffffc0205e00:	8522                	mv	a0,s0
ffffffffc0205e02:	3ba000ef          	jal	ra,ffffffffc02061bc <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process ++;
ffffffffc0205e06:	000ad717          	auipc	a4,0xad
ffffffffc0205e0a:	aca70713          	addi	a4,a4,-1334 # ffffffffc02b28d0 <nr_process>
ffffffffc0205e0e:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc0205e10:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e14:	4601                	li	a2,0
    nr_process ++;
ffffffffc0205e16:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e18:	4581                	li	a1,0
ffffffffc0205e1a:	00000517          	auipc	a0,0x0
ffffffffc0205e1e:	87450513          	addi	a0,a0,-1932 # ffffffffc020568e <init_main>
    nr_process ++;
ffffffffc0205e22:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc0205e24:	000ad797          	auipc	a5,0xad
ffffffffc0205e28:	a8d7ba23          	sd	a3,-1388(a5) # ffffffffc02b28b8 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e2c:	cf6ff0ef          	jal	ra,ffffffffc0205322 <kernel_thread>
ffffffffc0205e30:	842a                	mv	s0,a0
    if (pid <= 0) {
ffffffffc0205e32:	08a05363          	blez	a0,ffffffffc0205eb8 <proc_init+0x128>
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205e36:	6789                	lui	a5,0x2
ffffffffc0205e38:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205e3c:	17f9                	addi	a5,a5,-2
ffffffffc0205e3e:	2501                	sext.w	a0,a0
ffffffffc0205e40:	02e7e363          	bltu	a5,a4,ffffffffc0205e66 <proc_init+0xd6>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205e44:	45a9                	li	a1,10
ffffffffc0205e46:	77c000ef          	jal	ra,ffffffffc02065c2 <hash32>
ffffffffc0205e4a:	02051793          	slli	a5,a0,0x20
ffffffffc0205e4e:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0205e52:	96a6                	add	a3,a3,s1
ffffffffc0205e54:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0205e56:	a029                	j	ffffffffc0205e60 <proc_init+0xd0>
            if (proc->pid == pid) {
ffffffffc0205e58:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x7c8c>
ffffffffc0205e5c:	04870b63          	beq	a4,s0,ffffffffc0205eb2 <proc_init+0x122>
    return listelm->next;
ffffffffc0205e60:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205e62:	fef69be3          	bne	a3,a5,ffffffffc0205e58 <proc_init+0xc8>
    return NULL;
ffffffffc0205e66:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205e68:	0b478493          	addi	s1,a5,180
ffffffffc0205e6c:	4641                	li	a2,16
ffffffffc0205e6e:	4581                	li	a1,0
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205e70:	000ad417          	auipc	s0,0xad
ffffffffc0205e74:	a5840413          	addi	s0,s0,-1448 # ffffffffc02b28c8 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205e78:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc0205e7a:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205e7c:	32e000ef          	jal	ra,ffffffffc02061aa <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205e80:	463d                	li	a2,15
ffffffffc0205e82:	00003597          	auipc	a1,0x3
ffffffffc0205e86:	92658593          	addi	a1,a1,-1754 # ffffffffc02087a8 <default_pmm_manager+0xa70>
ffffffffc0205e8a:	8526                	mv	a0,s1
ffffffffc0205e8c:	330000ef          	jal	ra,ffffffffc02061bc <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205e90:	00093783          	ld	a5,0(s2)
ffffffffc0205e94:	cbb5                	beqz	a5,ffffffffc0205f08 <proc_init+0x178>
ffffffffc0205e96:	43dc                	lw	a5,4(a5)
ffffffffc0205e98:	eba5                	bnez	a5,ffffffffc0205f08 <proc_init+0x178>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205e9a:	601c                	ld	a5,0(s0)
ffffffffc0205e9c:	c7b1                	beqz	a5,ffffffffc0205ee8 <proc_init+0x158>
ffffffffc0205e9e:	43d8                	lw	a4,4(a5)
ffffffffc0205ea0:	4785                	li	a5,1
ffffffffc0205ea2:	04f71363          	bne	a4,a5,ffffffffc0205ee8 <proc_init+0x158>
}
ffffffffc0205ea6:	60e2                	ld	ra,24(sp)
ffffffffc0205ea8:	6442                	ld	s0,16(sp)
ffffffffc0205eaa:	64a2                	ld	s1,8(sp)
ffffffffc0205eac:	6902                	ld	s2,0(sp)
ffffffffc0205eae:	6105                	addi	sp,sp,32
ffffffffc0205eb0:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0205eb2:	f2878793          	addi	a5,a5,-216
ffffffffc0205eb6:	bf4d                	j	ffffffffc0205e68 <proc_init+0xd8>
        panic("create init_main failed.\n");
ffffffffc0205eb8:	00003617          	auipc	a2,0x3
ffffffffc0205ebc:	8d060613          	addi	a2,a2,-1840 # ffffffffc0208788 <default_pmm_manager+0xa50>
ffffffffc0205ec0:	38500593          	li	a1,901
ffffffffc0205ec4:	00002517          	auipc	a0,0x2
ffffffffc0205ec8:	53450513          	addi	a0,a0,1332 # ffffffffc02083f8 <default_pmm_manager+0x6c0>
ffffffffc0205ecc:	b3cfa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc0205ed0:	00003617          	auipc	a2,0x3
ffffffffc0205ed4:	89860613          	addi	a2,a2,-1896 # ffffffffc0208768 <default_pmm_manager+0xa30>
ffffffffc0205ed8:	37700593          	li	a1,887
ffffffffc0205edc:	00002517          	auipc	a0,0x2
ffffffffc0205ee0:	51c50513          	addi	a0,a0,1308 # ffffffffc02083f8 <default_pmm_manager+0x6c0>
ffffffffc0205ee4:	b24fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205ee8:	00003697          	auipc	a3,0x3
ffffffffc0205eec:	8f068693          	addi	a3,a3,-1808 # ffffffffc02087d8 <default_pmm_manager+0xaa0>
ffffffffc0205ef0:	00001617          	auipc	a2,0x1
ffffffffc0205ef4:	da060613          	addi	a2,a2,-608 # ffffffffc0206c90 <commands+0x410>
ffffffffc0205ef8:	38c00593          	li	a1,908
ffffffffc0205efc:	00002517          	auipc	a0,0x2
ffffffffc0205f00:	4fc50513          	addi	a0,a0,1276 # ffffffffc02083f8 <default_pmm_manager+0x6c0>
ffffffffc0205f04:	b04fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205f08:	00003697          	auipc	a3,0x3
ffffffffc0205f0c:	8a868693          	addi	a3,a3,-1880 # ffffffffc02087b0 <default_pmm_manager+0xa78>
ffffffffc0205f10:	00001617          	auipc	a2,0x1
ffffffffc0205f14:	d8060613          	addi	a2,a2,-640 # ffffffffc0206c90 <commands+0x410>
ffffffffc0205f18:	38b00593          	li	a1,907
ffffffffc0205f1c:	00002517          	auipc	a0,0x2
ffffffffc0205f20:	4dc50513          	addi	a0,a0,1244 # ffffffffc02083f8 <default_pmm_manager+0x6c0>
ffffffffc0205f24:	ae4fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205f28 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0205f28:	1141                	addi	sp,sp,-16
ffffffffc0205f2a:	e022                	sd	s0,0(sp)
ffffffffc0205f2c:	e406                	sd	ra,8(sp)
ffffffffc0205f2e:	000ad417          	auipc	s0,0xad
ffffffffc0205f32:	98a40413          	addi	s0,s0,-1654 # ffffffffc02b28b8 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0205f36:	6018                	ld	a4,0(s0)
ffffffffc0205f38:	6f1c                	ld	a5,24(a4)
ffffffffc0205f3a:	dffd                	beqz	a5,ffffffffc0205f38 <cpu_idle+0x10>
            schedule();
ffffffffc0205f3c:	086000ef          	jal	ra,ffffffffc0205fc2 <schedule>
ffffffffc0205f40:	bfdd                	j	ffffffffc0205f36 <cpu_idle+0xe>

ffffffffc0205f42 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205f42:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc0205f44:	1101                	addi	sp,sp,-32
ffffffffc0205f46:	ec06                	sd	ra,24(sp)
ffffffffc0205f48:	e822                	sd	s0,16(sp)
ffffffffc0205f4a:	e426                	sd	s1,8(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205f4c:	478d                	li	a5,3
ffffffffc0205f4e:	04f70b63          	beq	a4,a5,ffffffffc0205fa4 <wakeup_proc+0x62>
ffffffffc0205f52:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205f54:	100027f3          	csrr	a5,sstatus
ffffffffc0205f58:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205f5a:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205f5c:	ef9d                	bnez	a5,ffffffffc0205f9a <wakeup_proc+0x58>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0205f5e:	4789                	li	a5,2
ffffffffc0205f60:	02f70163          	beq	a4,a5,ffffffffc0205f82 <wakeup_proc+0x40>
            proc->state = PROC_RUNNABLE;
ffffffffc0205f64:	c01c                	sw	a5,0(s0)
            proc->wait_state = 0;
ffffffffc0205f66:	0e042623          	sw	zero,236(s0)
    if (flag) {
ffffffffc0205f6a:	e491                	bnez	s1,ffffffffc0205f76 <wakeup_proc+0x34>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205f6c:	60e2                	ld	ra,24(sp)
ffffffffc0205f6e:	6442                	ld	s0,16(sp)
ffffffffc0205f70:	64a2                	ld	s1,8(sp)
ffffffffc0205f72:	6105                	addi	sp,sp,32
ffffffffc0205f74:	8082                	ret
ffffffffc0205f76:	6442                	ld	s0,16(sp)
ffffffffc0205f78:	60e2                	ld	ra,24(sp)
ffffffffc0205f7a:	64a2                	ld	s1,8(sp)
ffffffffc0205f7c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205f7e:	ec4fa06f          	j	ffffffffc0200642 <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0205f82:	00003617          	auipc	a2,0x3
ffffffffc0205f86:	8b660613          	addi	a2,a2,-1866 # ffffffffc0208838 <default_pmm_manager+0xb00>
ffffffffc0205f8a:	45c9                	li	a1,18
ffffffffc0205f8c:	00003517          	auipc	a0,0x3
ffffffffc0205f90:	89450513          	addi	a0,a0,-1900 # ffffffffc0208820 <default_pmm_manager+0xae8>
ffffffffc0205f94:	adcfa0ef          	jal	ra,ffffffffc0200270 <__warn>
ffffffffc0205f98:	bfc9                	j	ffffffffc0205f6a <wakeup_proc+0x28>
        intr_disable();
ffffffffc0205f9a:	eaefa0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0205f9e:	4018                	lw	a4,0(s0)
        return 1;
ffffffffc0205fa0:	4485                	li	s1,1
ffffffffc0205fa2:	bf75                	j	ffffffffc0205f5e <wakeup_proc+0x1c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205fa4:	00003697          	auipc	a3,0x3
ffffffffc0205fa8:	85c68693          	addi	a3,a3,-1956 # ffffffffc0208800 <default_pmm_manager+0xac8>
ffffffffc0205fac:	00001617          	auipc	a2,0x1
ffffffffc0205fb0:	ce460613          	addi	a2,a2,-796 # ffffffffc0206c90 <commands+0x410>
ffffffffc0205fb4:	45a5                	li	a1,9
ffffffffc0205fb6:	00003517          	auipc	a0,0x3
ffffffffc0205fba:	86a50513          	addi	a0,a0,-1942 # ffffffffc0208820 <default_pmm_manager+0xae8>
ffffffffc0205fbe:	a4afa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205fc2 <schedule>:

void
schedule(void) {
ffffffffc0205fc2:	1141                	addi	sp,sp,-16
ffffffffc0205fc4:	e406                	sd	ra,8(sp)
ffffffffc0205fc6:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205fc8:	100027f3          	csrr	a5,sstatus
ffffffffc0205fcc:	8b89                	andi	a5,a5,2
ffffffffc0205fce:	4401                	li	s0,0
ffffffffc0205fd0:	efbd                	bnez	a5,ffffffffc020604e <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0205fd2:	000ad897          	auipc	a7,0xad
ffffffffc0205fd6:	8e68b883          	ld	a7,-1818(a7) # ffffffffc02b28b8 <current>
ffffffffc0205fda:	0008bc23          	sd	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205fde:	000ad517          	auipc	a0,0xad
ffffffffc0205fe2:	8e253503          	ld	a0,-1822(a0) # ffffffffc02b28c0 <idleproc>
ffffffffc0205fe6:	04a88e63          	beq	a7,a0,ffffffffc0206042 <schedule+0x80>
ffffffffc0205fea:	0c888693          	addi	a3,a7,200
ffffffffc0205fee:	000ad617          	auipc	a2,0xad
ffffffffc0205ff2:	84260613          	addi	a2,a2,-1982 # ffffffffc02b2830 <proc_list>
        le = last;
ffffffffc0205ff6:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0205ff8:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205ffa:	4809                	li	a6,2
ffffffffc0205ffc:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0205ffe:	00c78863          	beq	a5,a2,ffffffffc020600e <schedule+0x4c>
                if (next->state == PROC_RUNNABLE) {
ffffffffc0206002:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0206006:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc020600a:	03070163          	beq	a4,a6,ffffffffc020602c <schedule+0x6a>
                    break;
                }
            }
        } while (le != last);
ffffffffc020600e:	fef697e3          	bne	a3,a5,ffffffffc0205ffc <schedule+0x3a>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0206012:	ed89                	bnez	a1,ffffffffc020602c <schedule+0x6a>
            next = idleproc;
        }
        next->runs ++;
ffffffffc0206014:	451c                	lw	a5,8(a0)
ffffffffc0206016:	2785                	addiw	a5,a5,1
ffffffffc0206018:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc020601a:	00a88463          	beq	a7,a0,ffffffffc0206022 <schedule+0x60>
            proc_run(next);
ffffffffc020601e:	e93fe0ef          	jal	ra,ffffffffc0204eb0 <proc_run>
    if (flag) {
ffffffffc0206022:	e819                	bnez	s0,ffffffffc0206038 <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0206024:	60a2                	ld	ra,8(sp)
ffffffffc0206026:	6402                	ld	s0,0(sp)
ffffffffc0206028:	0141                	addi	sp,sp,16
ffffffffc020602a:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc020602c:	4198                	lw	a4,0(a1)
ffffffffc020602e:	4789                	li	a5,2
ffffffffc0206030:	fef712e3          	bne	a4,a5,ffffffffc0206014 <schedule+0x52>
ffffffffc0206034:	852e                	mv	a0,a1
ffffffffc0206036:	bff9                	j	ffffffffc0206014 <schedule+0x52>
}
ffffffffc0206038:	6402                	ld	s0,0(sp)
ffffffffc020603a:	60a2                	ld	ra,8(sp)
ffffffffc020603c:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc020603e:	e04fa06f          	j	ffffffffc0200642 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0206042:	000ac617          	auipc	a2,0xac
ffffffffc0206046:	7ee60613          	addi	a2,a2,2030 # ffffffffc02b2830 <proc_list>
ffffffffc020604a:	86b2                	mv	a3,a2
ffffffffc020604c:	b76d                	j	ffffffffc0205ff6 <schedule+0x34>
        intr_disable();
ffffffffc020604e:	dfafa0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc0206052:	4405                	li	s0,1
ffffffffc0206054:	bfbd                	j	ffffffffc0205fd2 <schedule+0x10>

ffffffffc0206056 <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc0206056:	000ad797          	auipc	a5,0xad
ffffffffc020605a:	8627b783          	ld	a5,-1950(a5) # ffffffffc02b28b8 <current>
}
ffffffffc020605e:	43c8                	lw	a0,4(a5)
ffffffffc0206060:	8082                	ret

ffffffffc0206062 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0206062:	4501                	li	a0,0
ffffffffc0206064:	8082                	ret

ffffffffc0206066 <sys_putc>:
    cputchar(c);
ffffffffc0206066:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0206068:	1141                	addi	sp,sp,-16
ffffffffc020606a:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc020606c:	896fa0ef          	jal	ra,ffffffffc0200102 <cputchar>
}
ffffffffc0206070:	60a2                	ld	ra,8(sp)
ffffffffc0206072:	4501                	li	a0,0
ffffffffc0206074:	0141                	addi	sp,sp,16
ffffffffc0206076:	8082                	ret

ffffffffc0206078 <sys_kill>:
    return do_kill(pid);
ffffffffc0206078:	4108                	lw	a0,0(a0)
ffffffffc020607a:	c9bff06f          	j	ffffffffc0205d14 <do_kill>

ffffffffc020607e <sys_yield>:
    return do_yield();
ffffffffc020607e:	c49ff06f          	j	ffffffffc0205cc6 <do_yield>

ffffffffc0206082 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc0206082:	6d14                	ld	a3,24(a0)
ffffffffc0206084:	6910                	ld	a2,16(a0)
ffffffffc0206086:	650c                	ld	a1,8(a0)
ffffffffc0206088:	6108                	ld	a0,0(a0)
ffffffffc020608a:	f28ff06f          	j	ffffffffc02057b2 <do_execve>

ffffffffc020608e <sys_wait>:
    return do_wait(pid, store);
ffffffffc020608e:	650c                	ld	a1,8(a0)
ffffffffc0206090:	4108                	lw	a0,0(a0)
ffffffffc0206092:	c45ff06f          	j	ffffffffc0205cd6 <do_wait>

ffffffffc0206096 <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc0206096:	000ad797          	auipc	a5,0xad
ffffffffc020609a:	8227b783          	ld	a5,-2014(a5) # ffffffffc02b28b8 <current>
ffffffffc020609e:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc02060a0:	4501                	li	a0,0
ffffffffc02060a2:	6a0c                	ld	a1,16(a2)
ffffffffc02060a4:	e71fe06f          	j	ffffffffc0204f14 <do_fork>

ffffffffc02060a8 <sys_exit>:
    return do_exit(error_code);
ffffffffc02060a8:	4108                	lw	a0,0(a0)
ffffffffc02060aa:	ac8ff06f          	j	ffffffffc0205372 <do_exit>

ffffffffc02060ae <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc02060ae:	715d                	addi	sp,sp,-80
ffffffffc02060b0:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc02060b2:	000ad497          	auipc	s1,0xad
ffffffffc02060b6:	80648493          	addi	s1,s1,-2042 # ffffffffc02b28b8 <current>
ffffffffc02060ba:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc02060bc:	e0a2                	sd	s0,64(sp)
ffffffffc02060be:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc02060c0:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc02060c2:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02060c4:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc02060c6:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02060ca:	0327ee63          	bltu	a5,s2,ffffffffc0206106 <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc02060ce:	00391713          	slli	a4,s2,0x3
ffffffffc02060d2:	00002797          	auipc	a5,0x2
ffffffffc02060d6:	7ce78793          	addi	a5,a5,1998 # ffffffffc02088a0 <syscalls>
ffffffffc02060da:	97ba                	add	a5,a5,a4
ffffffffc02060dc:	639c                	ld	a5,0(a5)
ffffffffc02060de:	c785                	beqz	a5,ffffffffc0206106 <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc02060e0:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc02060e2:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc02060e4:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc02060e6:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc02060e8:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc02060ea:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc02060ec:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc02060ee:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc02060f0:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc02060f2:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc02060f4:	0028                	addi	a0,sp,8
ffffffffc02060f6:	9782                	jalr	a5
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc02060f8:	60a6                	ld	ra,72(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc02060fa:	e828                	sd	a0,80(s0)
}
ffffffffc02060fc:	6406                	ld	s0,64(sp)
ffffffffc02060fe:	74e2                	ld	s1,56(sp)
ffffffffc0206100:	7942                	ld	s2,48(sp)
ffffffffc0206102:	6161                	addi	sp,sp,80
ffffffffc0206104:	8082                	ret
    print_trapframe(tf);
ffffffffc0206106:	8522                	mv	a0,s0
ffffffffc0206108:	f2efa0ef          	jal	ra,ffffffffc0200836 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc020610c:	609c                	ld	a5,0(s1)
ffffffffc020610e:	86ca                	mv	a3,s2
ffffffffc0206110:	00002617          	auipc	a2,0x2
ffffffffc0206114:	74860613          	addi	a2,a2,1864 # ffffffffc0208858 <default_pmm_manager+0xb20>
ffffffffc0206118:	43d8                	lw	a4,4(a5)
ffffffffc020611a:	06200593          	li	a1,98
ffffffffc020611e:	0b478793          	addi	a5,a5,180
ffffffffc0206122:	00002517          	auipc	a0,0x2
ffffffffc0206126:	76650513          	addi	a0,a0,1894 # ffffffffc0208888 <default_pmm_manager+0xb50>
ffffffffc020612a:	8defa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020612e <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc020612e:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0206132:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0206134:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0206136:	cb81                	beqz	a5,ffffffffc0206146 <strlen+0x18>
        cnt ++;
ffffffffc0206138:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc020613a:	00a707b3          	add	a5,a4,a0
ffffffffc020613e:	0007c783          	lbu	a5,0(a5)
ffffffffc0206142:	fbfd                	bnez	a5,ffffffffc0206138 <strlen+0xa>
ffffffffc0206144:	8082                	ret
    }
    return cnt;
}
ffffffffc0206146:	8082                	ret

ffffffffc0206148 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0206148:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc020614a:	e589                	bnez	a1,ffffffffc0206154 <strnlen+0xc>
ffffffffc020614c:	a811                	j	ffffffffc0206160 <strnlen+0x18>
        cnt ++;
ffffffffc020614e:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0206150:	00f58863          	beq	a1,a5,ffffffffc0206160 <strnlen+0x18>
ffffffffc0206154:	00f50733          	add	a4,a0,a5
ffffffffc0206158:	00074703          	lbu	a4,0(a4)
ffffffffc020615c:	fb6d                	bnez	a4,ffffffffc020614e <strnlen+0x6>
ffffffffc020615e:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0206160:	852e                	mv	a0,a1
ffffffffc0206162:	8082                	ret

ffffffffc0206164 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0206164:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0206166:	0005c703          	lbu	a4,0(a1)
ffffffffc020616a:	0785                	addi	a5,a5,1
ffffffffc020616c:	0585                	addi	a1,a1,1
ffffffffc020616e:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0206172:	fb75                	bnez	a4,ffffffffc0206166 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0206174:	8082                	ret

ffffffffc0206176 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206176:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020617a:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020617e:	cb89                	beqz	a5,ffffffffc0206190 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0206180:	0505                	addi	a0,a0,1
ffffffffc0206182:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206184:	fee789e3          	beq	a5,a4,ffffffffc0206176 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0206188:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020618c:	9d19                	subw	a0,a0,a4
ffffffffc020618e:	8082                	ret
ffffffffc0206190:	4501                	li	a0,0
ffffffffc0206192:	bfed                	j	ffffffffc020618c <strcmp+0x16>

ffffffffc0206194 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0206194:	00054783          	lbu	a5,0(a0)
ffffffffc0206198:	c799                	beqz	a5,ffffffffc02061a6 <strchr+0x12>
        if (*s == c) {
ffffffffc020619a:	00f58763          	beq	a1,a5,ffffffffc02061a8 <strchr+0x14>
    while (*s != '\0') {
ffffffffc020619e:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc02061a2:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02061a4:	fbfd                	bnez	a5,ffffffffc020619a <strchr+0x6>
    }
    return NULL;
ffffffffc02061a6:	4501                	li	a0,0
}
ffffffffc02061a8:	8082                	ret

ffffffffc02061aa <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02061aa:	ca01                	beqz	a2,ffffffffc02061ba <memset+0x10>
ffffffffc02061ac:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02061ae:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02061b0:	0785                	addi	a5,a5,1
ffffffffc02061b2:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02061b6:	fec79de3          	bne	a5,a2,ffffffffc02061b0 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02061ba:	8082                	ret

ffffffffc02061bc <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02061bc:	ca19                	beqz	a2,ffffffffc02061d2 <memcpy+0x16>
ffffffffc02061be:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02061c0:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02061c2:	0005c703          	lbu	a4,0(a1)
ffffffffc02061c6:	0585                	addi	a1,a1,1
ffffffffc02061c8:	0785                	addi	a5,a5,1
ffffffffc02061ca:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02061ce:	fec59ae3          	bne	a1,a2,ffffffffc02061c2 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02061d2:	8082                	ret

ffffffffc02061d4 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02061d4:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02061d8:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02061da:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02061de:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02061e0:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02061e4:	f022                	sd	s0,32(sp)
ffffffffc02061e6:	ec26                	sd	s1,24(sp)
ffffffffc02061e8:	e84a                	sd	s2,16(sp)
ffffffffc02061ea:	f406                	sd	ra,40(sp)
ffffffffc02061ec:	e44e                	sd	s3,8(sp)
ffffffffc02061ee:	84aa                	mv	s1,a0
ffffffffc02061f0:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02061f2:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02061f6:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc02061f8:	03067e63          	bgeu	a2,a6,ffffffffc0206234 <printnum+0x60>
ffffffffc02061fc:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02061fe:	00805763          	blez	s0,ffffffffc020620c <printnum+0x38>
ffffffffc0206202:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0206204:	85ca                	mv	a1,s2
ffffffffc0206206:	854e                	mv	a0,s3
ffffffffc0206208:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020620a:	fc65                	bnez	s0,ffffffffc0206202 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020620c:	1a02                	slli	s4,s4,0x20
ffffffffc020620e:	00002797          	auipc	a5,0x2
ffffffffc0206212:	79278793          	addi	a5,a5,1938 # ffffffffc02089a0 <syscalls+0x100>
ffffffffc0206216:	020a5a13          	srli	s4,s4,0x20
ffffffffc020621a:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc020621c:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020621e:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0206222:	70a2                	ld	ra,40(sp)
ffffffffc0206224:	69a2                	ld	s3,8(sp)
ffffffffc0206226:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206228:	85ca                	mv	a1,s2
ffffffffc020622a:	87a6                	mv	a5,s1
}
ffffffffc020622c:	6942                	ld	s2,16(sp)
ffffffffc020622e:	64e2                	ld	s1,24(sp)
ffffffffc0206230:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206232:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0206234:	03065633          	divu	a2,a2,a6
ffffffffc0206238:	8722                	mv	a4,s0
ffffffffc020623a:	f9bff0ef          	jal	ra,ffffffffc02061d4 <printnum>
ffffffffc020623e:	b7f9                	j	ffffffffc020620c <printnum+0x38>

ffffffffc0206240 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0206240:	7119                	addi	sp,sp,-128
ffffffffc0206242:	f4a6                	sd	s1,104(sp)
ffffffffc0206244:	f0ca                	sd	s2,96(sp)
ffffffffc0206246:	ecce                	sd	s3,88(sp)
ffffffffc0206248:	e8d2                	sd	s4,80(sp)
ffffffffc020624a:	e4d6                	sd	s5,72(sp)
ffffffffc020624c:	e0da                	sd	s6,64(sp)
ffffffffc020624e:	fc5e                	sd	s7,56(sp)
ffffffffc0206250:	f06a                	sd	s10,32(sp)
ffffffffc0206252:	fc86                	sd	ra,120(sp)
ffffffffc0206254:	f8a2                	sd	s0,112(sp)
ffffffffc0206256:	f862                	sd	s8,48(sp)
ffffffffc0206258:	f466                	sd	s9,40(sp)
ffffffffc020625a:	ec6e                	sd	s11,24(sp)
ffffffffc020625c:	892a                	mv	s2,a0
ffffffffc020625e:	84ae                	mv	s1,a1
ffffffffc0206260:	8d32                	mv	s10,a2
ffffffffc0206262:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206264:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0206268:	5b7d                	li	s6,-1
ffffffffc020626a:	00002a97          	auipc	s5,0x2
ffffffffc020626e:	762a8a93          	addi	s5,s5,1890 # ffffffffc02089cc <syscalls+0x12c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206272:	00003b97          	auipc	s7,0x3
ffffffffc0206276:	976b8b93          	addi	s7,s7,-1674 # ffffffffc0208be8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020627a:	000d4503          	lbu	a0,0(s10)
ffffffffc020627e:	001d0413          	addi	s0,s10,1
ffffffffc0206282:	01350a63          	beq	a0,s3,ffffffffc0206296 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0206286:	c121                	beqz	a0,ffffffffc02062c6 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0206288:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020628a:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020628c:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020628e:	fff44503          	lbu	a0,-1(s0)
ffffffffc0206292:	ff351ae3          	bne	a0,s3,ffffffffc0206286 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206296:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020629a:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020629e:	4c81                	li	s9,0
ffffffffc02062a0:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02062a2:	5c7d                	li	s8,-1
ffffffffc02062a4:	5dfd                	li	s11,-1
ffffffffc02062a6:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02062aa:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02062ac:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02062b0:	0ff5f593          	zext.b	a1,a1
ffffffffc02062b4:	00140d13          	addi	s10,s0,1
ffffffffc02062b8:	04b56263          	bltu	a0,a1,ffffffffc02062fc <vprintfmt+0xbc>
ffffffffc02062bc:	058a                	slli	a1,a1,0x2
ffffffffc02062be:	95d6                	add	a1,a1,s5
ffffffffc02062c0:	4194                	lw	a3,0(a1)
ffffffffc02062c2:	96d6                	add	a3,a3,s5
ffffffffc02062c4:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02062c6:	70e6                	ld	ra,120(sp)
ffffffffc02062c8:	7446                	ld	s0,112(sp)
ffffffffc02062ca:	74a6                	ld	s1,104(sp)
ffffffffc02062cc:	7906                	ld	s2,96(sp)
ffffffffc02062ce:	69e6                	ld	s3,88(sp)
ffffffffc02062d0:	6a46                	ld	s4,80(sp)
ffffffffc02062d2:	6aa6                	ld	s5,72(sp)
ffffffffc02062d4:	6b06                	ld	s6,64(sp)
ffffffffc02062d6:	7be2                	ld	s7,56(sp)
ffffffffc02062d8:	7c42                	ld	s8,48(sp)
ffffffffc02062da:	7ca2                	ld	s9,40(sp)
ffffffffc02062dc:	7d02                	ld	s10,32(sp)
ffffffffc02062de:	6de2                	ld	s11,24(sp)
ffffffffc02062e0:	6109                	addi	sp,sp,128
ffffffffc02062e2:	8082                	ret
            padc = '0';
ffffffffc02062e4:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02062e6:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02062ea:	846a                	mv	s0,s10
ffffffffc02062ec:	00140d13          	addi	s10,s0,1
ffffffffc02062f0:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02062f4:	0ff5f593          	zext.b	a1,a1
ffffffffc02062f8:	fcb572e3          	bgeu	a0,a1,ffffffffc02062bc <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc02062fc:	85a6                	mv	a1,s1
ffffffffc02062fe:	02500513          	li	a0,37
ffffffffc0206302:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0206304:	fff44783          	lbu	a5,-1(s0)
ffffffffc0206308:	8d22                	mv	s10,s0
ffffffffc020630a:	f73788e3          	beq	a5,s3,ffffffffc020627a <vprintfmt+0x3a>
ffffffffc020630e:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0206312:	1d7d                	addi	s10,s10,-1
ffffffffc0206314:	ff379de3          	bne	a5,s3,ffffffffc020630e <vprintfmt+0xce>
ffffffffc0206318:	b78d                	j	ffffffffc020627a <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc020631a:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc020631e:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206322:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0206324:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0206328:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020632c:	02d86463          	bltu	a6,a3,ffffffffc0206354 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0206330:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0206334:	002c169b          	slliw	a3,s8,0x2
ffffffffc0206338:	0186873b          	addw	a4,a3,s8
ffffffffc020633c:	0017171b          	slliw	a4,a4,0x1
ffffffffc0206340:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0206342:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0206346:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0206348:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc020634c:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0206350:	fed870e3          	bgeu	a6,a3,ffffffffc0206330 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0206354:	f40ddce3          	bgez	s11,ffffffffc02062ac <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0206358:	8de2                	mv	s11,s8
ffffffffc020635a:	5c7d                	li	s8,-1
ffffffffc020635c:	bf81                	j	ffffffffc02062ac <vprintfmt+0x6c>
            if (width < 0)
ffffffffc020635e:	fffdc693          	not	a3,s11
ffffffffc0206362:	96fd                	srai	a3,a3,0x3f
ffffffffc0206364:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206368:	00144603          	lbu	a2,1(s0)
ffffffffc020636c:	2d81                	sext.w	s11,s11
ffffffffc020636e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206370:	bf35                	j	ffffffffc02062ac <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0206372:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206376:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020637a:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020637c:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc020637e:	bfd9                	j	ffffffffc0206354 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0206380:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0206382:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0206386:	01174463          	blt	a4,a7,ffffffffc020638e <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc020638a:	1a088e63          	beqz	a7,ffffffffc0206546 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc020638e:	000a3603          	ld	a2,0(s4)
ffffffffc0206392:	46c1                	li	a3,16
ffffffffc0206394:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0206396:	2781                	sext.w	a5,a5
ffffffffc0206398:	876e                	mv	a4,s11
ffffffffc020639a:	85a6                	mv	a1,s1
ffffffffc020639c:	854a                	mv	a0,s2
ffffffffc020639e:	e37ff0ef          	jal	ra,ffffffffc02061d4 <printnum>
            break;
ffffffffc02063a2:	bde1                	j	ffffffffc020627a <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02063a4:	000a2503          	lw	a0,0(s4)
ffffffffc02063a8:	85a6                	mv	a1,s1
ffffffffc02063aa:	0a21                	addi	s4,s4,8
ffffffffc02063ac:	9902                	jalr	s2
            break;
ffffffffc02063ae:	b5f1                	j	ffffffffc020627a <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02063b0:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02063b2:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02063b6:	01174463          	blt	a4,a7,ffffffffc02063be <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc02063ba:	18088163          	beqz	a7,ffffffffc020653c <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc02063be:	000a3603          	ld	a2,0(s4)
ffffffffc02063c2:	46a9                	li	a3,10
ffffffffc02063c4:	8a2e                	mv	s4,a1
ffffffffc02063c6:	bfc1                	j	ffffffffc0206396 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02063c8:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02063cc:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02063ce:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02063d0:	bdf1                	j	ffffffffc02062ac <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc02063d2:	85a6                	mv	a1,s1
ffffffffc02063d4:	02500513          	li	a0,37
ffffffffc02063d8:	9902                	jalr	s2
            break;
ffffffffc02063da:	b545                	j	ffffffffc020627a <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02063dc:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc02063e0:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02063e2:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02063e4:	b5e1                	j	ffffffffc02062ac <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02063e6:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02063e8:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02063ec:	01174463          	blt	a4,a7,ffffffffc02063f4 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02063f0:	14088163          	beqz	a7,ffffffffc0206532 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02063f4:	000a3603          	ld	a2,0(s4)
ffffffffc02063f8:	46a1                	li	a3,8
ffffffffc02063fa:	8a2e                	mv	s4,a1
ffffffffc02063fc:	bf69                	j	ffffffffc0206396 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02063fe:	03000513          	li	a0,48
ffffffffc0206402:	85a6                	mv	a1,s1
ffffffffc0206404:	e03e                	sd	a5,0(sp)
ffffffffc0206406:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0206408:	85a6                	mv	a1,s1
ffffffffc020640a:	07800513          	li	a0,120
ffffffffc020640e:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0206410:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0206412:	6782                	ld	a5,0(sp)
ffffffffc0206414:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0206416:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc020641a:	bfb5                	j	ffffffffc0206396 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020641c:	000a3403          	ld	s0,0(s4)
ffffffffc0206420:	008a0713          	addi	a4,s4,8
ffffffffc0206424:	e03a                	sd	a4,0(sp)
ffffffffc0206426:	14040263          	beqz	s0,ffffffffc020656a <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc020642a:	0fb05763          	blez	s11,ffffffffc0206518 <vprintfmt+0x2d8>
ffffffffc020642e:	02d00693          	li	a3,45
ffffffffc0206432:	0cd79163          	bne	a5,a3,ffffffffc02064f4 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206436:	00044783          	lbu	a5,0(s0)
ffffffffc020643a:	0007851b          	sext.w	a0,a5
ffffffffc020643e:	cf85                	beqz	a5,ffffffffc0206476 <vprintfmt+0x236>
ffffffffc0206440:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206444:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206448:	000c4563          	bltz	s8,ffffffffc0206452 <vprintfmt+0x212>
ffffffffc020644c:	3c7d                	addiw	s8,s8,-1
ffffffffc020644e:	036c0263          	beq	s8,s6,ffffffffc0206472 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0206452:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206454:	0e0c8e63          	beqz	s9,ffffffffc0206550 <vprintfmt+0x310>
ffffffffc0206458:	3781                	addiw	a5,a5,-32
ffffffffc020645a:	0ef47b63          	bgeu	s0,a5,ffffffffc0206550 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc020645e:	03f00513          	li	a0,63
ffffffffc0206462:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206464:	000a4783          	lbu	a5,0(s4)
ffffffffc0206468:	3dfd                	addiw	s11,s11,-1
ffffffffc020646a:	0a05                	addi	s4,s4,1
ffffffffc020646c:	0007851b          	sext.w	a0,a5
ffffffffc0206470:	ffe1                	bnez	a5,ffffffffc0206448 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0206472:	01b05963          	blez	s11,ffffffffc0206484 <vprintfmt+0x244>
ffffffffc0206476:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0206478:	85a6                	mv	a1,s1
ffffffffc020647a:	02000513          	li	a0,32
ffffffffc020647e:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0206480:	fe0d9be3          	bnez	s11,ffffffffc0206476 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0206484:	6a02                	ld	s4,0(sp)
ffffffffc0206486:	bbd5                	j	ffffffffc020627a <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0206488:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020648a:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc020648e:	01174463          	blt	a4,a7,ffffffffc0206496 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0206492:	08088d63          	beqz	a7,ffffffffc020652c <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0206496:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc020649a:	0a044d63          	bltz	s0,ffffffffc0206554 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc020649e:	8622                	mv	a2,s0
ffffffffc02064a0:	8a66                	mv	s4,s9
ffffffffc02064a2:	46a9                	li	a3,10
ffffffffc02064a4:	bdcd                	j	ffffffffc0206396 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02064a6:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02064aa:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc02064ac:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02064ae:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02064b2:	8fb5                	xor	a5,a5,a3
ffffffffc02064b4:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02064b8:	02d74163          	blt	a4,a3,ffffffffc02064da <vprintfmt+0x29a>
ffffffffc02064bc:	00369793          	slli	a5,a3,0x3
ffffffffc02064c0:	97de                	add	a5,a5,s7
ffffffffc02064c2:	639c                	ld	a5,0(a5)
ffffffffc02064c4:	cb99                	beqz	a5,ffffffffc02064da <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc02064c6:	86be                	mv	a3,a5
ffffffffc02064c8:	00000617          	auipc	a2,0x0
ffffffffc02064cc:	13860613          	addi	a2,a2,312 # ffffffffc0206600 <etext+0x28>
ffffffffc02064d0:	85a6                	mv	a1,s1
ffffffffc02064d2:	854a                	mv	a0,s2
ffffffffc02064d4:	0ce000ef          	jal	ra,ffffffffc02065a2 <printfmt>
ffffffffc02064d8:	b34d                	j	ffffffffc020627a <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02064da:	00002617          	auipc	a2,0x2
ffffffffc02064de:	4e660613          	addi	a2,a2,1254 # ffffffffc02089c0 <syscalls+0x120>
ffffffffc02064e2:	85a6                	mv	a1,s1
ffffffffc02064e4:	854a                	mv	a0,s2
ffffffffc02064e6:	0bc000ef          	jal	ra,ffffffffc02065a2 <printfmt>
ffffffffc02064ea:	bb41                	j	ffffffffc020627a <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02064ec:	00002417          	auipc	s0,0x2
ffffffffc02064f0:	4cc40413          	addi	s0,s0,1228 # ffffffffc02089b8 <syscalls+0x118>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02064f4:	85e2                	mv	a1,s8
ffffffffc02064f6:	8522                	mv	a0,s0
ffffffffc02064f8:	e43e                	sd	a5,8(sp)
ffffffffc02064fa:	c4fff0ef          	jal	ra,ffffffffc0206148 <strnlen>
ffffffffc02064fe:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0206502:	01b05b63          	blez	s11,ffffffffc0206518 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0206506:	67a2                	ld	a5,8(sp)
ffffffffc0206508:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020650c:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc020650e:	85a6                	mv	a1,s1
ffffffffc0206510:	8552                	mv	a0,s4
ffffffffc0206512:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206514:	fe0d9ce3          	bnez	s11,ffffffffc020650c <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206518:	00044783          	lbu	a5,0(s0)
ffffffffc020651c:	00140a13          	addi	s4,s0,1
ffffffffc0206520:	0007851b          	sext.w	a0,a5
ffffffffc0206524:	d3a5                	beqz	a5,ffffffffc0206484 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206526:	05e00413          	li	s0,94
ffffffffc020652a:	bf39                	j	ffffffffc0206448 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc020652c:	000a2403          	lw	s0,0(s4)
ffffffffc0206530:	b7ad                	j	ffffffffc020649a <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0206532:	000a6603          	lwu	a2,0(s4)
ffffffffc0206536:	46a1                	li	a3,8
ffffffffc0206538:	8a2e                	mv	s4,a1
ffffffffc020653a:	bdb1                	j	ffffffffc0206396 <vprintfmt+0x156>
ffffffffc020653c:	000a6603          	lwu	a2,0(s4)
ffffffffc0206540:	46a9                	li	a3,10
ffffffffc0206542:	8a2e                	mv	s4,a1
ffffffffc0206544:	bd89                	j	ffffffffc0206396 <vprintfmt+0x156>
ffffffffc0206546:	000a6603          	lwu	a2,0(s4)
ffffffffc020654a:	46c1                	li	a3,16
ffffffffc020654c:	8a2e                	mv	s4,a1
ffffffffc020654e:	b5a1                	j	ffffffffc0206396 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0206550:	9902                	jalr	s2
ffffffffc0206552:	bf09                	j	ffffffffc0206464 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0206554:	85a6                	mv	a1,s1
ffffffffc0206556:	02d00513          	li	a0,45
ffffffffc020655a:	e03e                	sd	a5,0(sp)
ffffffffc020655c:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020655e:	6782                	ld	a5,0(sp)
ffffffffc0206560:	8a66                	mv	s4,s9
ffffffffc0206562:	40800633          	neg	a2,s0
ffffffffc0206566:	46a9                	li	a3,10
ffffffffc0206568:	b53d                	j	ffffffffc0206396 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc020656a:	03b05163          	blez	s11,ffffffffc020658c <vprintfmt+0x34c>
ffffffffc020656e:	02d00693          	li	a3,45
ffffffffc0206572:	f6d79de3          	bne	a5,a3,ffffffffc02064ec <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0206576:	00002417          	auipc	s0,0x2
ffffffffc020657a:	44240413          	addi	s0,s0,1090 # ffffffffc02089b8 <syscalls+0x118>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020657e:	02800793          	li	a5,40
ffffffffc0206582:	02800513          	li	a0,40
ffffffffc0206586:	00140a13          	addi	s4,s0,1
ffffffffc020658a:	bd6d                	j	ffffffffc0206444 <vprintfmt+0x204>
ffffffffc020658c:	00002a17          	auipc	s4,0x2
ffffffffc0206590:	42da0a13          	addi	s4,s4,1069 # ffffffffc02089b9 <syscalls+0x119>
ffffffffc0206594:	02800513          	li	a0,40
ffffffffc0206598:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020659c:	05e00413          	li	s0,94
ffffffffc02065a0:	b565                	j	ffffffffc0206448 <vprintfmt+0x208>

ffffffffc02065a2 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02065a2:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02065a4:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02065a8:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02065aa:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02065ac:	ec06                	sd	ra,24(sp)
ffffffffc02065ae:	f83a                	sd	a4,48(sp)
ffffffffc02065b0:	fc3e                	sd	a5,56(sp)
ffffffffc02065b2:	e0c2                	sd	a6,64(sp)
ffffffffc02065b4:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02065b6:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02065b8:	c89ff0ef          	jal	ra,ffffffffc0206240 <vprintfmt>
}
ffffffffc02065bc:	60e2                	ld	ra,24(sp)
ffffffffc02065be:	6161                	addi	sp,sp,80
ffffffffc02065c0:	8082                	ret

ffffffffc02065c2 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc02065c2:	9e3707b7          	lui	a5,0x9e370
ffffffffc02065c6:	2785                	addiw	a5,a5,1
ffffffffc02065c8:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc02065cc:	02000793          	li	a5,32
ffffffffc02065d0:	9f8d                	subw	a5,a5,a1
}
ffffffffc02065d2:	00f5553b          	srlw	a0,a0,a5
ffffffffc02065d6:	8082                	ret
