
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
ffffffffc0200000:	c02042b7          	lui	t0,0xc0204
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
ffffffffc020001c:	18029073          	csrw	satp,t0
ffffffffc0200020:	12000073          	sfence.vma
ffffffffc0200024:	c0204137          	lui	sp,0xc0204
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
ffffffffc0200032:	00005517          	auipc	a0,0x5
ffffffffc0200036:	fde50513          	addi	a0,a0,-34 # ffffffffc0205010 <page_pool>
ffffffffc020003a:	0000f617          	auipc	a2,0xf
ffffffffc020003e:	4c660613          	addi	a2,a2,1222 # ffffffffc020f500 <end>
ffffffffc0200042:	1141                	addi	sp,sp,-16
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
ffffffffc0200048:	e406                	sd	ra,8(sp)
ffffffffc020004a:	45f000ef          	jal	ra,ffffffffc0200ca8 <memset>
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
ffffffffc0200052:	00001517          	auipc	a0,0x1
ffffffffc0200056:	15e50513          	addi	a0,a0,350 # ffffffffc02011b0 <etext+0x4>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>
ffffffffc020005e:	138000ef          	jal	ra,ffffffffc0200196 <print_kerninfo>
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>
ffffffffc0200066:	79c000ef          	jal	ra,ffffffffc0200802 <pmm_init>
ffffffffc020006a:	3fa000ef          	jal	ra,ffffffffc0200464 <idt_init>
ffffffffc020006e:	39a000ef          	jal	ra,ffffffffc0200408 <clock_init>
ffffffffc0200072:	3e6000ef          	jal	ra,ffffffffc0200458 <intr_enable>
ffffffffc0200076:	a001                	j	ffffffffc0200076 <kern_init+0x44>

ffffffffc0200078 <cputch>:
ffffffffc0200078:	1141                	addi	sp,sp,-16
ffffffffc020007a:	e022                	sd	s0,0(sp)
ffffffffc020007c:	e406                	sd	ra,8(sp)
ffffffffc020007e:	842e                	mv	s0,a1
ffffffffc0200080:	3cc000ef          	jal	ra,ffffffffc020044c <cons_putc>
ffffffffc0200084:	401c                	lw	a5,0(s0)
ffffffffc0200086:	60a2                	ld	ra,8(sp)
ffffffffc0200088:	2785                	addiw	a5,a5,1
ffffffffc020008a:	c01c                	sw	a5,0(s0)
ffffffffc020008c:	6402                	ld	s0,0(sp)
ffffffffc020008e:	0141                	addi	sp,sp,16
ffffffffc0200090:	8082                	ret

ffffffffc0200092 <vcprintf>:
ffffffffc0200092:	1101                	addi	sp,sp,-32
ffffffffc0200094:	862a                	mv	a2,a0
ffffffffc0200096:	86ae                	mv	a3,a1
ffffffffc0200098:	00000517          	auipc	a0,0x0
ffffffffc020009c:	fe050513          	addi	a0,a0,-32 # ffffffffc0200078 <cputch>
ffffffffc02000a0:	006c                	addi	a1,sp,12
ffffffffc02000a2:	ec06                	sd	ra,24(sp)
ffffffffc02000a4:	c602                	sw	zero,12(sp)
ffffffffc02000a6:	481000ef          	jal	ra,ffffffffc0200d26 <vprintfmt>
ffffffffc02000aa:	60e2                	ld	ra,24(sp)
ffffffffc02000ac:	4532                	lw	a0,12(sp)
ffffffffc02000ae:	6105                	addi	sp,sp,32
ffffffffc02000b0:	8082                	ret

ffffffffc02000b2 <cprintf>:
ffffffffc02000b2:	711d                	addi	sp,sp,-96
ffffffffc02000b4:	02810313          	addi	t1,sp,40 # ffffffffc0204028 <boot_page_table_sv39+0x28>
ffffffffc02000b8:	8e2a                	mv	t3,a0
ffffffffc02000ba:	f42e                	sd	a1,40(sp)
ffffffffc02000bc:	f832                	sd	a2,48(sp)
ffffffffc02000be:	fc36                	sd	a3,56(sp)
ffffffffc02000c0:	00000517          	auipc	a0,0x0
ffffffffc02000c4:	fb850513          	addi	a0,a0,-72 # ffffffffc0200078 <cputch>
ffffffffc02000c8:	004c                	addi	a1,sp,4
ffffffffc02000ca:	869a                	mv	a3,t1
ffffffffc02000cc:	8672                	mv	a2,t3
ffffffffc02000ce:	ec06                	sd	ra,24(sp)
ffffffffc02000d0:	e0ba                	sd	a4,64(sp)
ffffffffc02000d2:	e4be                	sd	a5,72(sp)
ffffffffc02000d4:	e8c2                	sd	a6,80(sp)
ffffffffc02000d6:	ecc6                	sd	a7,88(sp)
ffffffffc02000d8:	e41a                	sd	t1,8(sp)
ffffffffc02000da:	c202                	sw	zero,4(sp)
ffffffffc02000dc:	44b000ef          	jal	ra,ffffffffc0200d26 <vprintfmt>
ffffffffc02000e0:	60e2                	ld	ra,24(sp)
ffffffffc02000e2:	4512                	lw	a0,4(sp)
ffffffffc02000e4:	6125                	addi	sp,sp,96
ffffffffc02000e6:	8082                	ret

ffffffffc02000e8 <cputchar>:
ffffffffc02000e8:	a695                	j	ffffffffc020044c <cons_putc>

ffffffffc02000ea <cputs>:
ffffffffc02000ea:	1101                	addi	sp,sp,-32
ffffffffc02000ec:	e822                	sd	s0,16(sp)
ffffffffc02000ee:	ec06                	sd	ra,24(sp)
ffffffffc02000f0:	e426                	sd	s1,8(sp)
ffffffffc02000f2:	842a                	mv	s0,a0
ffffffffc02000f4:	00054503          	lbu	a0,0(a0)
ffffffffc02000f8:	c51d                	beqz	a0,ffffffffc0200126 <cputs+0x3c>
ffffffffc02000fa:	0405                	addi	s0,s0,1
ffffffffc02000fc:	4485                	li	s1,1
ffffffffc02000fe:	9c81                	subw	s1,s1,s0
ffffffffc0200100:	34c000ef          	jal	ra,ffffffffc020044c <cons_putc>
ffffffffc0200104:	00044503          	lbu	a0,0(s0)
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	f96d                	bnez	a0,ffffffffc0200100 <cputs+0x16>
ffffffffc0200110:	0017841b          	addiw	s0,a5,1
ffffffffc0200114:	4529                	li	a0,10
ffffffffc0200116:	336000ef          	jal	ra,ffffffffc020044c <cons_putc>
ffffffffc020011a:	60e2                	ld	ra,24(sp)
ffffffffc020011c:	8522                	mv	a0,s0
ffffffffc020011e:	6442                	ld	s0,16(sp)
ffffffffc0200120:	64a2                	ld	s1,8(sp)
ffffffffc0200122:	6105                	addi	sp,sp,32
ffffffffc0200124:	8082                	ret
ffffffffc0200126:	4405                	li	s0,1
ffffffffc0200128:	b7f5                	j	ffffffffc0200114 <cputs+0x2a>

ffffffffc020012a <getchar>:
ffffffffc020012a:	1141                	addi	sp,sp,-16
ffffffffc020012c:	e406                	sd	ra,8(sp)
ffffffffc020012e:	326000ef          	jal	ra,ffffffffc0200454 <cons_getc>
ffffffffc0200132:	dd75                	beqz	a0,ffffffffc020012e <getchar+0x4>
ffffffffc0200134:	60a2                	ld	ra,8(sp)
ffffffffc0200136:	0141                	addi	sp,sp,16
ffffffffc0200138:	8082                	ret

ffffffffc020013a <__panic>:
ffffffffc020013a:	0000f317          	auipc	t1,0xf
ffffffffc020013e:	37630313          	addi	t1,t1,886 # ffffffffc020f4b0 <is_panic>
ffffffffc0200142:	00032e03          	lw	t3,0(t1)
ffffffffc0200146:	715d                	addi	sp,sp,-80
ffffffffc0200148:	ec06                	sd	ra,24(sp)
ffffffffc020014a:	e822                	sd	s0,16(sp)
ffffffffc020014c:	f436                	sd	a3,40(sp)
ffffffffc020014e:	f83a                	sd	a4,48(sp)
ffffffffc0200150:	fc3e                	sd	a5,56(sp)
ffffffffc0200152:	e0c2                	sd	a6,64(sp)
ffffffffc0200154:	e4c6                	sd	a7,72(sp)
ffffffffc0200156:	020e1a63          	bnez	t3,ffffffffc020018a <__panic+0x50>
ffffffffc020015a:	4785                	li	a5,1
ffffffffc020015c:	00f32023          	sw	a5,0(t1)
ffffffffc0200160:	8432                	mv	s0,a2
ffffffffc0200162:	103c                	addi	a5,sp,40
ffffffffc0200164:	862e                	mv	a2,a1
ffffffffc0200166:	85aa                	mv	a1,a0
ffffffffc0200168:	00001517          	auipc	a0,0x1
ffffffffc020016c:	06850513          	addi	a0,a0,104 # ffffffffc02011d0 <etext+0x24>
ffffffffc0200170:	e43e                	sd	a5,8(sp)
ffffffffc0200172:	f41ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200176:	65a2                	ld	a1,8(sp)
ffffffffc0200178:	8522                	mv	a0,s0
ffffffffc020017a:	f19ff0ef          	jal	ra,ffffffffc0200092 <vcprintf>
ffffffffc020017e:	00001517          	auipc	a0,0x1
ffffffffc0200182:	13a50513          	addi	a0,a0,314 # ffffffffc02012b8 <etext+0x10c>
ffffffffc0200186:	f2dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020018a:	2d4000ef          	jal	ra,ffffffffc020045e <intr_disable>
ffffffffc020018e:	4501                	li	a0,0
ffffffffc0200190:	130000ef          	jal	ra,ffffffffc02002c0 <kmonitor>
ffffffffc0200194:	bfed                	j	ffffffffc020018e <__panic+0x54>

ffffffffc0200196 <print_kerninfo>:
ffffffffc0200196:	1141                	addi	sp,sp,-16
ffffffffc0200198:	00001517          	auipc	a0,0x1
ffffffffc020019c:	05850513          	addi	a0,a0,88 # ffffffffc02011f0 <etext+0x44>
ffffffffc02001a0:	e406                	sd	ra,8(sp)
ffffffffc02001a2:	f11ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02001a6:	00000597          	auipc	a1,0x0
ffffffffc02001aa:	e8c58593          	addi	a1,a1,-372 # ffffffffc0200032 <kern_init>
ffffffffc02001ae:	00001517          	auipc	a0,0x1
ffffffffc02001b2:	06250513          	addi	a0,a0,98 # ffffffffc0201210 <etext+0x64>
ffffffffc02001b6:	efdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02001ba:	00001597          	auipc	a1,0x1
ffffffffc02001be:	ff258593          	addi	a1,a1,-14 # ffffffffc02011ac <etext>
ffffffffc02001c2:	00001517          	auipc	a0,0x1
ffffffffc02001c6:	06e50513          	addi	a0,a0,110 # ffffffffc0201230 <etext+0x84>
ffffffffc02001ca:	ee9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02001ce:	00005597          	auipc	a1,0x5
ffffffffc02001d2:	e4258593          	addi	a1,a1,-446 # ffffffffc0205010 <page_pool>
ffffffffc02001d6:	00001517          	auipc	a0,0x1
ffffffffc02001da:	07a50513          	addi	a0,a0,122 # ffffffffc0201250 <etext+0xa4>
ffffffffc02001de:	ed5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02001e2:	0000f597          	auipc	a1,0xf
ffffffffc02001e6:	31e58593          	addi	a1,a1,798 # ffffffffc020f500 <end>
ffffffffc02001ea:	00001517          	auipc	a0,0x1
ffffffffc02001ee:	08650513          	addi	a0,a0,134 # ffffffffc0201270 <etext+0xc4>
ffffffffc02001f2:	ec1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02001f6:	0000f597          	auipc	a1,0xf
ffffffffc02001fa:	70958593          	addi	a1,a1,1801 # ffffffffc020f8ff <end+0x3ff>
ffffffffc02001fe:	00000797          	auipc	a5,0x0
ffffffffc0200202:	e3478793          	addi	a5,a5,-460 # ffffffffc0200032 <kern_init>
ffffffffc0200206:	40f587b3          	sub	a5,a1,a5
ffffffffc020020a:	43f7d593          	srai	a1,a5,0x3f
ffffffffc020020e:	60a2                	ld	ra,8(sp)
ffffffffc0200210:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200214:	95be                	add	a1,a1,a5
ffffffffc0200216:	85a9                	srai	a1,a1,0xa
ffffffffc0200218:	00001517          	auipc	a0,0x1
ffffffffc020021c:	07850513          	addi	a0,a0,120 # ffffffffc0201290 <etext+0xe4>
ffffffffc0200220:	0141                	addi	sp,sp,16
ffffffffc0200222:	bd41                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200224 <print_stackframe>:
ffffffffc0200224:	1141                	addi	sp,sp,-16
ffffffffc0200226:	00001617          	auipc	a2,0x1
ffffffffc020022a:	09a60613          	addi	a2,a2,154 # ffffffffc02012c0 <etext+0x114>
ffffffffc020022e:	04e00593          	li	a1,78
ffffffffc0200232:	00001517          	auipc	a0,0x1
ffffffffc0200236:	0a650513          	addi	a0,a0,166 # ffffffffc02012d8 <etext+0x12c>
ffffffffc020023a:	e406                	sd	ra,8(sp)
ffffffffc020023c:	effff0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0200240 <mon_help>:
ffffffffc0200240:	1141                	addi	sp,sp,-16
ffffffffc0200242:	00001617          	auipc	a2,0x1
ffffffffc0200246:	0ae60613          	addi	a2,a2,174 # ffffffffc02012f0 <etext+0x144>
ffffffffc020024a:	00001597          	auipc	a1,0x1
ffffffffc020024e:	0c658593          	addi	a1,a1,198 # ffffffffc0201310 <etext+0x164>
ffffffffc0200252:	00001517          	auipc	a0,0x1
ffffffffc0200256:	0c650513          	addi	a0,a0,198 # ffffffffc0201318 <etext+0x16c>
ffffffffc020025a:	e406                	sd	ra,8(sp)
ffffffffc020025c:	e57ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200260:	00001617          	auipc	a2,0x1
ffffffffc0200264:	0c860613          	addi	a2,a2,200 # ffffffffc0201328 <etext+0x17c>
ffffffffc0200268:	00001597          	auipc	a1,0x1
ffffffffc020026c:	0e858593          	addi	a1,a1,232 # ffffffffc0201350 <etext+0x1a4>
ffffffffc0200270:	00001517          	auipc	a0,0x1
ffffffffc0200274:	0a850513          	addi	a0,a0,168 # ffffffffc0201318 <etext+0x16c>
ffffffffc0200278:	e3bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020027c:	00001617          	auipc	a2,0x1
ffffffffc0200280:	0e460613          	addi	a2,a2,228 # ffffffffc0201360 <etext+0x1b4>
ffffffffc0200284:	00001597          	auipc	a1,0x1
ffffffffc0200288:	0fc58593          	addi	a1,a1,252 # ffffffffc0201380 <etext+0x1d4>
ffffffffc020028c:	00001517          	auipc	a0,0x1
ffffffffc0200290:	08c50513          	addi	a0,a0,140 # ffffffffc0201318 <etext+0x16c>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200298:	60a2                	ld	ra,8(sp)
ffffffffc020029a:	4501                	li	a0,0
ffffffffc020029c:	0141                	addi	sp,sp,16
ffffffffc020029e:	8082                	ret

ffffffffc02002a0 <mon_kerninfo>:
ffffffffc02002a0:	1141                	addi	sp,sp,-16
ffffffffc02002a2:	e406                	sd	ra,8(sp)
ffffffffc02002a4:	ef3ff0ef          	jal	ra,ffffffffc0200196 <print_kerninfo>
ffffffffc02002a8:	60a2                	ld	ra,8(sp)
ffffffffc02002aa:	4501                	li	a0,0
ffffffffc02002ac:	0141                	addi	sp,sp,16
ffffffffc02002ae:	8082                	ret

ffffffffc02002b0 <mon_backtrace>:
ffffffffc02002b0:	1141                	addi	sp,sp,-16
ffffffffc02002b2:	e406                	sd	ra,8(sp)
ffffffffc02002b4:	f71ff0ef          	jal	ra,ffffffffc0200224 <print_stackframe>
ffffffffc02002b8:	60a2                	ld	ra,8(sp)
ffffffffc02002ba:	4501                	li	a0,0
ffffffffc02002bc:	0141                	addi	sp,sp,16
ffffffffc02002be:	8082                	ret

ffffffffc02002c0 <kmonitor>:
ffffffffc02002c0:	7115                	addi	sp,sp,-224
ffffffffc02002c2:	ed5e                	sd	s7,152(sp)
ffffffffc02002c4:	8baa                	mv	s7,a0
ffffffffc02002c6:	00001517          	auipc	a0,0x1
ffffffffc02002ca:	0ca50513          	addi	a0,a0,202 # ffffffffc0201390 <etext+0x1e4>
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
ffffffffc02002e4:	dcfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02002e8:	00001517          	auipc	a0,0x1
ffffffffc02002ec:	0d050513          	addi	a0,a0,208 # ffffffffc02013b8 <etext+0x20c>
ffffffffc02002f0:	dc3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02002f4:	000b8563          	beqz	s7,ffffffffc02002fe <kmonitor+0x3e>
ffffffffc02002f8:	855e                	mv	a0,s7
ffffffffc02002fa:	348000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002fe:	00001c17          	auipc	s8,0x1
ffffffffc0200302:	12ac0c13          	addi	s8,s8,298 # ffffffffc0201428 <commands>
ffffffffc0200306:	00001917          	auipc	s2,0x1
ffffffffc020030a:	0da90913          	addi	s2,s2,218 # ffffffffc02013e0 <etext+0x234>
ffffffffc020030e:	00001497          	auipc	s1,0x1
ffffffffc0200312:	0da48493          	addi	s1,s1,218 # ffffffffc02013e8 <etext+0x23c>
ffffffffc0200316:	49bd                	li	s3,15
ffffffffc0200318:	00001b17          	auipc	s6,0x1
ffffffffc020031c:	0d8b0b13          	addi	s6,s6,216 # ffffffffc02013f0 <etext+0x244>
ffffffffc0200320:	00001a17          	auipc	s4,0x1
ffffffffc0200324:	ff0a0a13          	addi	s4,s4,-16 # ffffffffc0201310 <etext+0x164>
ffffffffc0200328:	4a8d                	li	s5,3
ffffffffc020032a:	854a                	mv	a0,s2
ffffffffc020032c:	57d000ef          	jal	ra,ffffffffc02010a8 <readline>
ffffffffc0200330:	842a                	mv	s0,a0
ffffffffc0200332:	dd65                	beqz	a0,ffffffffc020032a <kmonitor+0x6a>
ffffffffc0200334:	00054583          	lbu	a1,0(a0)
ffffffffc0200338:	4c81                	li	s9,0
ffffffffc020033a:	e1bd                	bnez	a1,ffffffffc02003a0 <kmonitor+0xe0>
ffffffffc020033c:	fe0c87e3          	beqz	s9,ffffffffc020032a <kmonitor+0x6a>
ffffffffc0200340:	6582                	ld	a1,0(sp)
ffffffffc0200342:	00001d17          	auipc	s10,0x1
ffffffffc0200346:	0e6d0d13          	addi	s10,s10,230 # ffffffffc0201428 <commands>
ffffffffc020034a:	8552                	mv	a0,s4
ffffffffc020034c:	4401                	li	s0,0
ffffffffc020034e:	0d61                	addi	s10,s10,24
ffffffffc0200350:	125000ef          	jal	ra,ffffffffc0200c74 <strcmp>
ffffffffc0200354:	c919                	beqz	a0,ffffffffc020036a <kmonitor+0xaa>
ffffffffc0200356:	2405                	addiw	s0,s0,1
ffffffffc0200358:	0b540063          	beq	s0,s5,ffffffffc02003f8 <kmonitor+0x138>
ffffffffc020035c:	000d3503          	ld	a0,0(s10)
ffffffffc0200360:	6582                	ld	a1,0(sp)
ffffffffc0200362:	0d61                	addi	s10,s10,24
ffffffffc0200364:	111000ef          	jal	ra,ffffffffc0200c74 <strcmp>
ffffffffc0200368:	f57d                	bnez	a0,ffffffffc0200356 <kmonitor+0x96>
ffffffffc020036a:	00141793          	slli	a5,s0,0x1
ffffffffc020036e:	97a2                	add	a5,a5,s0
ffffffffc0200370:	078e                	slli	a5,a5,0x3
ffffffffc0200372:	97e2                	add	a5,a5,s8
ffffffffc0200374:	6b9c                	ld	a5,16(a5)
ffffffffc0200376:	865e                	mv	a2,s7
ffffffffc0200378:	002c                	addi	a1,sp,8
ffffffffc020037a:	fffc851b          	addiw	a0,s9,-1
ffffffffc020037e:	9782                	jalr	a5
ffffffffc0200380:	fa0555e3          	bgez	a0,ffffffffc020032a <kmonitor+0x6a>
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
ffffffffc02003a0:	8526                	mv	a0,s1
ffffffffc02003a2:	0f1000ef          	jal	ra,ffffffffc0200c92 <strchr>
ffffffffc02003a6:	c901                	beqz	a0,ffffffffc02003b6 <kmonitor+0xf6>
ffffffffc02003a8:	00144583          	lbu	a1,1(s0)
ffffffffc02003ac:	00040023          	sb	zero,0(s0)
ffffffffc02003b0:	0405                	addi	s0,s0,1
ffffffffc02003b2:	d5c9                	beqz	a1,ffffffffc020033c <kmonitor+0x7c>
ffffffffc02003b4:	b7f5                	j	ffffffffc02003a0 <kmonitor+0xe0>
ffffffffc02003b6:	00044783          	lbu	a5,0(s0)
ffffffffc02003ba:	d3c9                	beqz	a5,ffffffffc020033c <kmonitor+0x7c>
ffffffffc02003bc:	033c8963          	beq	s9,s3,ffffffffc02003ee <kmonitor+0x12e>
ffffffffc02003c0:	003c9793          	slli	a5,s9,0x3
ffffffffc02003c4:	0118                	addi	a4,sp,128
ffffffffc02003c6:	97ba                	add	a5,a5,a4
ffffffffc02003c8:	f887b023          	sd	s0,-128(a5)
ffffffffc02003cc:	00044583          	lbu	a1,0(s0)
ffffffffc02003d0:	2c85                	addiw	s9,s9,1
ffffffffc02003d2:	e591                	bnez	a1,ffffffffc02003de <kmonitor+0x11e>
ffffffffc02003d4:	b7b5                	j	ffffffffc0200340 <kmonitor+0x80>
ffffffffc02003d6:	00144583          	lbu	a1,1(s0)
ffffffffc02003da:	0405                	addi	s0,s0,1
ffffffffc02003dc:	d1a5                	beqz	a1,ffffffffc020033c <kmonitor+0x7c>
ffffffffc02003de:	8526                	mv	a0,s1
ffffffffc02003e0:	0b3000ef          	jal	ra,ffffffffc0200c92 <strchr>
ffffffffc02003e4:	d96d                	beqz	a0,ffffffffc02003d6 <kmonitor+0x116>
ffffffffc02003e6:	00044583          	lbu	a1,0(s0)
ffffffffc02003ea:	d9a9                	beqz	a1,ffffffffc020033c <kmonitor+0x7c>
ffffffffc02003ec:	bf55                	j	ffffffffc02003a0 <kmonitor+0xe0>
ffffffffc02003ee:	45c1                	li	a1,16
ffffffffc02003f0:	855a                	mv	a0,s6
ffffffffc02003f2:	cc1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02003f6:	b7e9                	j	ffffffffc02003c0 <kmonitor+0x100>
ffffffffc02003f8:	6582                	ld	a1,0(sp)
ffffffffc02003fa:	00001517          	auipc	a0,0x1
ffffffffc02003fe:	01650513          	addi	a0,a0,22 # ffffffffc0201410 <etext+0x264>
ffffffffc0200402:	cb1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200406:	b715                	j	ffffffffc020032a <kmonitor+0x6a>

ffffffffc0200408 <clock_init>:
ffffffffc0200408:	1141                	addi	sp,sp,-16
ffffffffc020040a:	e406                	sd	ra,8(sp)
ffffffffc020040c:	02000793          	li	a5,32
ffffffffc0200410:	1047a7f3          	csrrs	a5,sie,a5
ffffffffc0200414:	c0102573          	rdtime	a0
ffffffffc0200418:	67e1                	lui	a5,0x18
ffffffffc020041a:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020041e:	953e                	add	a0,a0,a5
ffffffffc0200420:	557000ef          	jal	ra,ffffffffc0201176 <sbi_set_timer>
ffffffffc0200424:	60a2                	ld	ra,8(sp)
ffffffffc0200426:	0000f797          	auipc	a5,0xf
ffffffffc020042a:	0807b923          	sd	zero,146(a5) # ffffffffc020f4b8 <ticks>
ffffffffc020042e:	00001517          	auipc	a0,0x1
ffffffffc0200432:	04250513          	addi	a0,a0,66 # ffffffffc0201470 <commands+0x48>
ffffffffc0200436:	0141                	addi	sp,sp,16
ffffffffc0200438:	b9ad                	j	ffffffffc02000b2 <cprintf>

ffffffffc020043a <clock_set_next_event>:
ffffffffc020043a:	c0102573          	rdtime	a0
ffffffffc020043e:	67e1                	lui	a5,0x18
ffffffffc0200440:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200444:	953e                	add	a0,a0,a5
ffffffffc0200446:	5310006f          	j	ffffffffc0201176 <sbi_set_timer>

ffffffffc020044a <cons_init>:
ffffffffc020044a:	8082                	ret

ffffffffc020044c <cons_putc>:
ffffffffc020044c:	0ff57513          	andi	a0,a0,255
ffffffffc0200450:	50d0006f          	j	ffffffffc020115c <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
ffffffffc0200454:	53d0006f          	j	ffffffffc0201190 <sbi_console_getchar>

ffffffffc0200458 <intr_enable>:
ffffffffc0200458:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020045c:	8082                	ret

ffffffffc020045e <intr_disable>:
ffffffffc020045e:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <idt_init>:
ffffffffc0200464:	14005073          	csrwi	sscratch,0
ffffffffc0200468:	00000797          	auipc	a5,0x0
ffffffffc020046c:	2e478793          	addi	a5,a5,740 # ffffffffc020074c <__alltraps>
ffffffffc0200470:	10579073          	csrw	stvec,a5
ffffffffc0200474:	8082                	ret

ffffffffc0200476 <print_regs>:
ffffffffc0200476:	610c                	ld	a1,0(a0)
ffffffffc0200478:	1141                	addi	sp,sp,-16
ffffffffc020047a:	e022                	sd	s0,0(sp)
ffffffffc020047c:	842a                	mv	s0,a0
ffffffffc020047e:	00001517          	auipc	a0,0x1
ffffffffc0200482:	01250513          	addi	a0,a0,18 # ffffffffc0201490 <commands+0x68>
ffffffffc0200486:	e406                	sd	ra,8(sp)
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00001517          	auipc	a0,0x1
ffffffffc0200492:	01a50513          	addi	a0,a0,26 # ffffffffc02014a8 <commands+0x80>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00001517          	auipc	a0,0x1
ffffffffc02004a0:	02450513          	addi	a0,a0,36 # ffffffffc02014c0 <commands+0x98>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00001517          	auipc	a0,0x1
ffffffffc02004ae:	02e50513          	addi	a0,a0,46 # ffffffffc02014d8 <commands+0xb0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00001517          	auipc	a0,0x1
ffffffffc02004bc:	03850513          	addi	a0,a0,56 # ffffffffc02014f0 <commands+0xc8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00001517          	auipc	a0,0x1
ffffffffc02004ca:	04250513          	addi	a0,a0,66 # ffffffffc0201508 <commands+0xe0>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00001517          	auipc	a0,0x1
ffffffffc02004d8:	04c50513          	addi	a0,a0,76 # ffffffffc0201520 <commands+0xf8>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00001517          	auipc	a0,0x1
ffffffffc02004e6:	05650513          	addi	a0,a0,86 # ffffffffc0201538 <commands+0x110>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00001517          	auipc	a0,0x1
ffffffffc02004f4:	06050513          	addi	a0,a0,96 # ffffffffc0201550 <commands+0x128>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00001517          	auipc	a0,0x1
ffffffffc0200502:	06a50513          	addi	a0,a0,106 # ffffffffc0201568 <commands+0x140>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00001517          	auipc	a0,0x1
ffffffffc0200510:	07450513          	addi	a0,a0,116 # ffffffffc0201580 <commands+0x158>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00001517          	auipc	a0,0x1
ffffffffc020051e:	07e50513          	addi	a0,a0,126 # ffffffffc0201598 <commands+0x170>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00001517          	auipc	a0,0x1
ffffffffc020052c:	08850513          	addi	a0,a0,136 # ffffffffc02015b0 <commands+0x188>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00001517          	auipc	a0,0x1
ffffffffc020053a:	09250513          	addi	a0,a0,146 # ffffffffc02015c8 <commands+0x1a0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00001517          	auipc	a0,0x1
ffffffffc0200548:	09c50513          	addi	a0,a0,156 # ffffffffc02015e0 <commands+0x1b8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00001517          	auipc	a0,0x1
ffffffffc0200556:	0a650513          	addi	a0,a0,166 # ffffffffc02015f8 <commands+0x1d0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00001517          	auipc	a0,0x1
ffffffffc0200564:	0b050513          	addi	a0,a0,176 # ffffffffc0201610 <commands+0x1e8>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00001517          	auipc	a0,0x1
ffffffffc0200572:	0ba50513          	addi	a0,a0,186 # ffffffffc0201628 <commands+0x200>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00001517          	auipc	a0,0x1
ffffffffc0200580:	0c450513          	addi	a0,a0,196 # ffffffffc0201640 <commands+0x218>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00001517          	auipc	a0,0x1
ffffffffc020058e:	0ce50513          	addi	a0,a0,206 # ffffffffc0201658 <commands+0x230>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00001517          	auipc	a0,0x1
ffffffffc020059c:	0d850513          	addi	a0,a0,216 # ffffffffc0201670 <commands+0x248>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00001517          	auipc	a0,0x1
ffffffffc02005aa:	0e250513          	addi	a0,a0,226 # ffffffffc0201688 <commands+0x260>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00001517          	auipc	a0,0x1
ffffffffc02005b8:	0ec50513          	addi	a0,a0,236 # ffffffffc02016a0 <commands+0x278>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00001517          	auipc	a0,0x1
ffffffffc02005c6:	0f650513          	addi	a0,a0,246 # ffffffffc02016b8 <commands+0x290>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00001517          	auipc	a0,0x1
ffffffffc02005d4:	10050513          	addi	a0,a0,256 # ffffffffc02016d0 <commands+0x2a8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00001517          	auipc	a0,0x1
ffffffffc02005e2:	10a50513          	addi	a0,a0,266 # ffffffffc02016e8 <commands+0x2c0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00001517          	auipc	a0,0x1
ffffffffc02005f0:	11450513          	addi	a0,a0,276 # ffffffffc0201700 <commands+0x2d8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00001517          	auipc	a0,0x1
ffffffffc02005fe:	11e50513          	addi	a0,a0,286 # ffffffffc0201718 <commands+0x2f0>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00001517          	auipc	a0,0x1
ffffffffc020060c:	12850513          	addi	a0,a0,296 # ffffffffc0201730 <commands+0x308>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00001517          	auipc	a0,0x1
ffffffffc020061a:	13250513          	addi	a0,a0,306 # ffffffffc0201748 <commands+0x320>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00001517          	auipc	a0,0x1
ffffffffc0200628:	13c50513          	addi	a0,a0,316 # ffffffffc0201760 <commands+0x338>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
ffffffffc0200636:	00001517          	auipc	a0,0x1
ffffffffc020063a:	14250513          	addi	a0,a0,322 # ffffffffc0201778 <commands+0x350>
ffffffffc020063e:	0141                	addi	sp,sp,16
ffffffffc0200640:	bc8d                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200642 <print_trapframe>:
ffffffffc0200642:	1141                	addi	sp,sp,-16
ffffffffc0200644:	e022                	sd	s0,0(sp)
ffffffffc0200646:	85aa                	mv	a1,a0
ffffffffc0200648:	842a                	mv	s0,a0
ffffffffc020064a:	00001517          	auipc	a0,0x1
ffffffffc020064e:	14650513          	addi	a0,a0,326 # ffffffffc0201790 <commands+0x368>
ffffffffc0200652:	e406                	sd	ra,8(sp)
ffffffffc0200654:	a5fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200658:	8522                	mv	a0,s0
ffffffffc020065a:	e1dff0ef          	jal	ra,ffffffffc0200476 <print_regs>
ffffffffc020065e:	10043583          	ld	a1,256(s0)
ffffffffc0200662:	00001517          	auipc	a0,0x1
ffffffffc0200666:	14650513          	addi	a0,a0,326 # ffffffffc02017a8 <commands+0x380>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00001517          	auipc	a0,0x1
ffffffffc0200676:	14e50513          	addi	a0,a0,334 # ffffffffc02017c0 <commands+0x398>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00001517          	auipc	a0,0x1
ffffffffc0200686:	15650513          	addi	a0,a0,342 # ffffffffc02017d8 <commands+0x3b0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020068e:	11843583          	ld	a1,280(s0)
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
ffffffffc0200696:	00001517          	auipc	a0,0x1
ffffffffc020069a:	15a50513          	addi	a0,a0,346 # ffffffffc02017f0 <commands+0x3c8>
ffffffffc020069e:	0141                	addi	sp,sp,16
ffffffffc02006a0:	bc09                	j	ffffffffc02000b2 <cprintf>

ffffffffc02006a2 <interrupt_handler>:
ffffffffc02006a2:	11853783          	ld	a5,280(a0)
ffffffffc02006a6:	472d                	li	a4,11
ffffffffc02006a8:	0786                	slli	a5,a5,0x1
ffffffffc02006aa:	8385                	srli	a5,a5,0x1
ffffffffc02006ac:	06f76c63          	bltu	a4,a5,ffffffffc0200724 <interrupt_handler+0x82>
ffffffffc02006b0:	00001717          	auipc	a4,0x1
ffffffffc02006b4:	22070713          	addi	a4,a4,544 # ffffffffc02018d0 <commands+0x4a8>
ffffffffc02006b8:	078a                	slli	a5,a5,0x2
ffffffffc02006ba:	97ba                	add	a5,a5,a4
ffffffffc02006bc:	439c                	lw	a5,0(a5)
ffffffffc02006be:	97ba                	add	a5,a5,a4
ffffffffc02006c0:	8782                	jr	a5
ffffffffc02006c2:	00001517          	auipc	a0,0x1
ffffffffc02006c6:	1a650513          	addi	a0,a0,422 # ffffffffc0201868 <commands+0x440>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
ffffffffc02006cc:	00001517          	auipc	a0,0x1
ffffffffc02006d0:	17c50513          	addi	a0,a0,380 # ffffffffc0201848 <commands+0x420>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
ffffffffc02006d6:	00001517          	auipc	a0,0x1
ffffffffc02006da:	13250513          	addi	a0,a0,306 # ffffffffc0201808 <commands+0x3e0>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
ffffffffc02006e0:	00001517          	auipc	a0,0x1
ffffffffc02006e4:	1a850513          	addi	a0,a0,424 # ffffffffc0201888 <commands+0x460>
ffffffffc02006e8:	b2e9                	j	ffffffffc02000b2 <cprintf>
ffffffffc02006ea:	1141                	addi	sp,sp,-16
ffffffffc02006ec:	e406                	sd	ra,8(sp)
ffffffffc02006ee:	d4dff0ef          	jal	ra,ffffffffc020043a <clock_set_next_event>
ffffffffc02006f2:	0000f697          	auipc	a3,0xf
ffffffffc02006f6:	dc668693          	addi	a3,a3,-570 # ffffffffc020f4b8 <ticks>
ffffffffc02006fa:	629c                	ld	a5,0(a3)
ffffffffc02006fc:	06400713          	li	a4,100
ffffffffc0200700:	0785                	addi	a5,a5,1
ffffffffc0200702:	02e7f733          	remu	a4,a5,a4
ffffffffc0200706:	e29c                	sd	a5,0(a3)
ffffffffc0200708:	cf19                	beqz	a4,ffffffffc0200726 <interrupt_handler+0x84>
ffffffffc020070a:	60a2                	ld	ra,8(sp)
ffffffffc020070c:	0141                	addi	sp,sp,16
ffffffffc020070e:	8082                	ret
ffffffffc0200710:	00001517          	auipc	a0,0x1
ffffffffc0200714:	1a050513          	addi	a0,a0,416 # ffffffffc02018b0 <commands+0x488>
ffffffffc0200718:	ba69                	j	ffffffffc02000b2 <cprintf>
ffffffffc020071a:	00001517          	auipc	a0,0x1
ffffffffc020071e:	10e50513          	addi	a0,a0,270 # ffffffffc0201828 <commands+0x400>
ffffffffc0200722:	ba41                	j	ffffffffc02000b2 <cprintf>
ffffffffc0200724:	bf39                	j	ffffffffc0200642 <print_trapframe>
ffffffffc0200726:	60a2                	ld	ra,8(sp)
ffffffffc0200728:	06400593          	li	a1,100
ffffffffc020072c:	00001517          	auipc	a0,0x1
ffffffffc0200730:	17450513          	addi	a0,a0,372 # ffffffffc02018a0 <commands+0x478>
ffffffffc0200734:	0141                	addi	sp,sp,16
ffffffffc0200736:	bab5                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200738 <trap>:
ffffffffc0200738:	11853783          	ld	a5,280(a0)
ffffffffc020073c:	0007c763          	bltz	a5,ffffffffc020074a <trap+0x12>
ffffffffc0200740:	472d                	li	a4,11
ffffffffc0200742:	00f76363          	bltu	a4,a5,ffffffffc0200748 <trap+0x10>
ffffffffc0200746:	8082                	ret
ffffffffc0200748:	bded                	j	ffffffffc0200642 <print_trapframe>
ffffffffc020074a:	bfa1                	j	ffffffffc02006a2 <interrupt_handler>

ffffffffc020074c <__alltraps>:
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
ffffffffc02007ae:	850a                	mv	a0,sp
ffffffffc02007b0:	f89ff0ef          	jal	ra,ffffffffc0200738 <trap>

ffffffffc02007b4 <__trapret>:
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
ffffffffc02007fe:	10200073          	sret

ffffffffc0200802 <pmm_init>:

static void check_alloc_page(void);

// init_pmm_manager - initialize a pmm_manager instance
static void init_pmm_manager(void) {
    pmm_manager = &slub_pmm_manager;
ffffffffc0200802:	00001797          	auipc	a5,0x1
ffffffffc0200806:	2c678793          	addi	a5,a5,710 # ffffffffc0201ac8 <slub_pmm_manager>
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
ffffffffc0200814:	0f050513          	addi	a0,a0,240 # ffffffffc0201900 <commands+0x4d8>
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
ffffffffc0200840:	0dc50513          	addi	a0,a0,220 # ffffffffc0201918 <commands+0x4f0>
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
ffffffffc020085e:	0d650513          	addi	a0,a0,214 # ffffffffc0201930 <commands+0x508>
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
ffffffffc02008e0:	0ec50513          	addi	a0,a0,236 # ffffffffc02019c8 <commands+0x5a0>
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
ffffffffc0200918:	0d450513          	addi	a0,a0,212 # ffffffffc02019e8 <commands+0x5c0>
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
ffffffffc0200950:	04c60613          	addi	a2,a2,76 # ffffffffc0201998 <commands+0x570>
ffffffffc0200954:	06900593          	li	a1,105
ffffffffc0200958:	00001517          	auipc	a0,0x1
ffffffffc020095c:	06050513          	addi	a0,a0,96 # ffffffffc02019b8 <commands+0x590>
ffffffffc0200960:	fdaff0ef          	jal	ra,ffffffffc020013a <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200964:	00001617          	auipc	a2,0x1
ffffffffc0200968:	ffc60613          	addi	a2,a2,-4 # ffffffffc0201960 <commands+0x538>
ffffffffc020096c:	07000593          	li	a1,112
ffffffffc0200970:	00001517          	auipc	a0,0x1
ffffffffc0200974:	01850513          	addi	a0,a0,24 # ffffffffc0201988 <commands+0x560>
ffffffffc0200978:	fc2ff0ef          	jal	ra,ffffffffc020013a <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc020097c:	86ae                	mv	a3,a1
ffffffffc020097e:	00001617          	auipc	a2,0x1
ffffffffc0200982:	fe260613          	addi	a2,a2,-30 # ffffffffc0201960 <commands+0x538>
ffffffffc0200986:	08b00593          	li	a1,139
ffffffffc020098a:	00001517          	auipc	a0,0x1
ffffffffc020098e:	ffe50513          	addi	a0,a0,-2 # ffffffffc0201988 <commands+0x560>
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
ffffffffc020099e:	0000e597          	auipc	a1,0xe
ffffffffc02009a2:	68a58593          	addi	a1,a1,1674 # ffffffffc020f028 <slab_caches+0x18>
ffffffffc02009a6:	0000e617          	auipc	a2,0xe
ffffffffc02009aa:	6aa60613          	addi	a2,a2,1706 # ffffffffc020f050 <slab_caches+0x40>
ffffffffc02009ae:	0000e697          	auipc	a3,0xe
ffffffffc02009b2:	6ca68693          	addi	a3,a3,1738 # ffffffffc020f078 <slab_caches+0x68>
ffffffffc02009b6:	0000e717          	auipc	a4,0xe
ffffffffc02009ba:	6ea70713          	addi	a4,a4,1770 # ffffffffc020f0a0 <slab_caches+0x90>
ffffffffc02009be:	f38c                	sd	a1,32(a5)
ffffffffc02009c0:	ef8c                	sd	a1,24(a5)

// 初始化 SLUB 分配器
void slub_init(void) {
    for (int i = 0; i < SLAB_MAX_ORDER - SLAB_MIN_ORDER + 1; i++) {
        list_init(&slab_caches[i].free_list);
        slab_caches[i].free_count = 0;
ffffffffc02009c2:	0007b823          	sd	zero,16(a5)
ffffffffc02009c6:	e7b0                	sd	a2,72(a5)
ffffffffc02009c8:	e3b0                	sd	a2,64(a5)
ffffffffc02009ca:	0207bc23          	sd	zero,56(a5)
ffffffffc02009ce:	fbb4                	sd	a3,112(a5)
ffffffffc02009d0:	f7b4                	sd	a3,104(a5)
ffffffffc02009d2:	0607b023          	sd	zero,96(a5)
ffffffffc02009d6:	efd8                	sd	a4,152(a5)
ffffffffc02009d8:	ebd8                	sd	a4,144(a5)
ffffffffc02009da:	0807b423          	sd	zero,136(a5)
    }
    allocated_pages = 0;
ffffffffc02009de:	0000f797          	auipc	a5,0xf
ffffffffc02009e2:	b007b923          	sd	zero,-1262(a5) # ffffffffc020f4f0 <allocated_pages>
}
ffffffffc02009e6:	8082                	ret

ffffffffc02009e8 <slub_init_memmap>:

// 初始化内存映射，分配 slab 缓存
void slub_init_memmap(struct Page *base, size_t n) {
    for (int order = SLAB_MIN_ORDER; order <= SLAB_MAX_ORDER; order++) {
ffffffffc02009e8:	00259793          	slli	a5,a1,0x2
ffffffffc02009ec:	97ae                	add	a5,a5,a1
ffffffffc02009ee:	0561                	addi	a0,a0,24
ffffffffc02009f0:	078e                	slli	a5,a5,0x3
ffffffffc02009f2:	0000e717          	auipc	a4,0xe
ffffffffc02009f6:	63670713          	addi	a4,a4,1590 # ffffffffc020f028 <slab_caches+0x18>
ffffffffc02009fa:	00f50633          	add	a2,a0,a5
ffffffffc02009fe:	480d                	li	a6,3
        size_t slab_size = 1 << order; // slab 对象大小为 2^order 字节
ffffffffc0200a00:	4e05                	li	t3,1
        struct slab_cache *cache = &slab_caches[order - SLAB_MIN_ORDER];
        cache->objsize = slab_size;
        cache->total_objects = PGSIZE / slab_size; // 每页的对象数量
ffffffffc0200a02:	6305                	lui	t1,0x1
    for (int order = SLAB_MIN_ORDER; order <= SLAB_MAX_ORDER; order++) {
ffffffffc0200a04:	489d                	li	a7,7
        size_t slab_size = 1 << order; // slab 对象大小为 2^order 字节
ffffffffc0200a06:	010e16bb          	sllw	a3,t3,a6
        cache->total_objects = PGSIZE / slab_size; // 每页的对象数量
ffffffffc0200a0a:	010357b3          	srl	a5,t1,a6
        size_t slab_size = 1 << order; // slab 对象大小为 2^order 字节
ffffffffc0200a0e:	fed73423          	sd	a3,-24(a4)
        cache->total_objects = PGSIZE / slab_size; // 每页的对象数量
ffffffffc0200a12:	fef73823          	sd	a5,-16(a4)

        // 初始化 slab 内存区域
        for (size_t i = 0; i < n; i++) {
ffffffffc0200a16:	c185                	beqz	a1,ffffffffc0200a36 <slub_init_memmap+0x4e>
ffffffffc0200a18:	87aa                	mv	a5,a0
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
ffffffffc0200a1a:	6714                	ld	a3,8(a4)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200a1c:	e29c                	sd	a5,0(a3)
ffffffffc0200a1e:	e71c                	sd	a5,8(a4)
    elm->next = next;
ffffffffc0200a20:	e794                	sd	a3,8(a5)
    elm->prev = prev;
ffffffffc0200a22:	e398                	sd	a4,0(a5)
            struct Page *page = base + i;
            list_add(&cache->free_list, &page->page_link);  // 将所有页加入空闲链表
            cache->free_count++;
ffffffffc0200a24:	ff873683          	ld	a3,-8(a4)
        for (size_t i = 0; i < n; i++) {
ffffffffc0200a28:	02878793          	addi	a5,a5,40
            cache->free_count++;
ffffffffc0200a2c:	0685                	addi	a3,a3,1
ffffffffc0200a2e:	fed73c23          	sd	a3,-8(a4)
        for (size_t i = 0; i < n; i++) {
ffffffffc0200a32:	fec794e3          	bne	a5,a2,ffffffffc0200a1a <slub_init_memmap+0x32>
    for (int order = SLAB_MIN_ORDER; order <= SLAB_MAX_ORDER; order++) {
ffffffffc0200a36:	2805                	addiw	a6,a6,1
ffffffffc0200a38:	02870713          	addi	a4,a4,40
ffffffffc0200a3c:	fd1815e3          	bne	a6,a7,ffffffffc0200a06 <slub_init_memmap+0x1e>
        }
    }
}
ffffffffc0200a40:	8082                	ret

ffffffffc0200a42 <slub_nr_free_pages>:
// 获取剩余的空闲页数
size_t slub_nr_free_pages(void) {
    size_t total_free_pages = 0;
    for (int order = SLAB_MIN_ORDER; order <= SLAB_MAX_ORDER; order++) {
        struct slab_cache *cache = &slab_caches[order - SLAB_MIN_ORDER];
        total_free_pages += cache->free_count;
ffffffffc0200a42:	0000e717          	auipc	a4,0xe
ffffffffc0200a46:	5ce70713          	addi	a4,a4,1486 # ffffffffc020f010 <slab_caches>
ffffffffc0200a4a:	6b1c                	ld	a5,16(a4)
ffffffffc0200a4c:	7f10                	ld	a2,56(a4)
ffffffffc0200a4e:	7334                	ld	a3,96(a4)
ffffffffc0200a50:	6748                	ld	a0,136(a4)
ffffffffc0200a52:	97b2                	add	a5,a5,a2
ffffffffc0200a54:	97b6                	add	a5,a5,a3
    }
    return total_free_pages;
}
ffffffffc0200a56:	953e                	add	a0,a0,a5
ffffffffc0200a58:	8082                	ret

ffffffffc0200a5a <slub_alloc_pages>:
    if (n == 1) {
ffffffffc0200a5a:	4785                	li	a5,1
ffffffffc0200a5c:	08f51363          	bne	a0,a5,ffffffffc0200ae2 <slub_alloc_pages+0x88>
    return list->next == list;
ffffffffc0200a60:	0000e797          	auipc	a5,0xe
ffffffffc0200a64:	5b078793          	addi	a5,a5,1456 # ffffffffc020f010 <slab_caches>
ffffffffc0200a68:	7388                	ld	a0,32(a5)
            if (!list_empty(&cache->free_list)) {
ffffffffc0200a6a:	0000e697          	auipc	a3,0xe
ffffffffc0200a6e:	5be68693          	addi	a3,a3,1470 # ffffffffc020f028 <slab_caches+0x18>
ffffffffc0200a72:	08d51963          	bne	a0,a3,ffffffffc0200b04 <slub_alloc_pages+0xaa>
ffffffffc0200a76:	67a8                	ld	a0,72(a5)
ffffffffc0200a78:	0000e717          	auipc	a4,0xe
ffffffffc0200a7c:	5d870713          	addi	a4,a4,1496 # ffffffffc020f050 <slab_caches+0x40>
ffffffffc0200a80:	06e51363          	bne	a0,a4,ffffffffc0200ae6 <slub_alloc_pages+0x8c>
ffffffffc0200a84:	7ba8                	ld	a0,112(a5)
ffffffffc0200a86:	0000e717          	auipc	a4,0xe
ffffffffc0200a8a:	5f270713          	addi	a4,a4,1522 # ffffffffc020f078 <slab_caches+0x68>
ffffffffc0200a8e:	06e51d63          	bne	a0,a4,ffffffffc0200b08 <slub_alloc_pages+0xae>
ffffffffc0200a92:	6fc8                	ld	a0,152(a5)
ffffffffc0200a94:	0000e717          	auipc	a4,0xe
ffffffffc0200a98:	60c70713          	addi	a4,a4,1548 # ffffffffc020f0a0 <slab_caches+0x90>
ffffffffc0200a9c:	06e51863          	bne	a0,a4,ffffffffc0200b0c <slub_alloc_pages+0xb2>
    if (allocated_pages + n > MAX_PAGES) {
ffffffffc0200aa0:	0000f597          	auipc	a1,0xf
ffffffffc0200aa4:	a5058593          	addi	a1,a1,-1456 # ffffffffc020f4f0 <allocated_pages>
ffffffffc0200aa8:	6198                	ld	a4,0(a1)
ffffffffc0200aaa:	40000613          	li	a2,1024
ffffffffc0200aae:	00170813          	addi	a6,a4,1
ffffffffc0200ab2:	03066863          	bltu	a2,a6,ffffffffc0200ae2 <slub_alloc_pages+0x88>
    struct Page* page = &page_pool[allocated_pages];
ffffffffc0200ab6:	00271513          	slli	a0,a4,0x2
                cache->free_count++;
ffffffffc0200aba:	6b90                	ld	a2,16(a5)
ffffffffc0200abc:	953a                	add	a0,a0,a4
ffffffffc0200abe:	050e                	slli	a0,a0,0x3
    struct Page* page = &page_pool[allocated_pages];
ffffffffc0200ac0:	00004897          	auipc	a7,0x4
ffffffffc0200ac4:	55088893          	addi	a7,a7,1360 # ffffffffc0205010 <page_pool>
                list_add(&cache->free_list, &new_page->page_link);
ffffffffc0200ac8:	01850713          	addi	a4,a0,24
ffffffffc0200acc:	9746                	add	a4,a4,a7
    struct Page* page = &page_pool[allocated_pages];
ffffffffc0200ace:	9546                	add	a0,a0,a7
                cache->free_count++;
ffffffffc0200ad0:	0605                	addi	a2,a2,1
    allocated_pages += n;
ffffffffc0200ad2:	0105b023          	sd	a6,0(a1)
    prev->next = next->prev = elm;
ffffffffc0200ad6:	ef98                	sd	a4,24(a5)
ffffffffc0200ad8:	f398                	sd	a4,32(a5)
    elm->next = next;
ffffffffc0200ada:	f114                	sd	a3,32(a0)
    elm->prev = prev;
ffffffffc0200adc:	ed14                	sd	a3,24(a0)
                cache->free_count++;
ffffffffc0200ade:	eb90                	sd	a2,16(a5)
                return new_page;  // 返回新分配的页
ffffffffc0200ae0:	8082                	ret
    return NULL;  // 如果找不到合适的 slab 或静态分配失败，返回 NULL
ffffffffc0200ae2:	4501                	li	a0,0
}
ffffffffc0200ae4:	8082                	ret
            struct slab_cache *cache = &slab_caches[order - SLAB_MIN_ORDER];
ffffffffc0200ae6:	4685                	li	a3,1
    __list_del(listelm->prev, listelm->next);
ffffffffc0200ae8:	610c                	ld	a1,0(a0)
ffffffffc0200aea:	6510                	ld	a2,8(a0)
                cache->free_count--;
ffffffffc0200aec:	00269713          	slli	a4,a3,0x2
ffffffffc0200af0:	9736                	add	a4,a4,a3
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200af2:	e590                	sd	a2,8(a1)
ffffffffc0200af4:	070e                	slli	a4,a4,0x3
    next->prev = prev;
ffffffffc0200af6:	e20c                	sd	a1,0(a2)
ffffffffc0200af8:	97ba                	add	a5,a5,a4
ffffffffc0200afa:	6b98                	ld	a4,16(a5)
                struct Page *page = le2page(list_next(&cache->free_list), page_link);
ffffffffc0200afc:	1521                	addi	a0,a0,-24
                cache->free_count--;
ffffffffc0200afe:	177d                	addi	a4,a4,-1
ffffffffc0200b00:	eb98                	sd	a4,16(a5)
                return page;
ffffffffc0200b02:	8082                	ret
            struct slab_cache *cache = &slab_caches[order - SLAB_MIN_ORDER];
ffffffffc0200b04:	4681                	li	a3,0
ffffffffc0200b06:	b7cd                	j	ffffffffc0200ae8 <slub_alloc_pages+0x8e>
ffffffffc0200b08:	4689                	li	a3,2
ffffffffc0200b0a:	bff9                	j	ffffffffc0200ae8 <slub_alloc_pages+0x8e>
ffffffffc0200b0c:	468d                	li	a3,3
ffffffffc0200b0e:	bfe9                	j	ffffffffc0200ae8 <slub_alloc_pages+0x8e>

ffffffffc0200b10 <slub_free_pages>:
    if (n == 1) {
ffffffffc0200b10:	4785                	li	a5,1
ffffffffc0200b12:	00f58363          	beq	a1,a5,ffffffffc0200b18 <slub_free_pages+0x8>
}
ffffffffc0200b16:	8082                	ret
    __list_add(elm, listelm, listelm->next);
ffffffffc0200b18:	0000e797          	auipc	a5,0xe
ffffffffc0200b1c:	4f878793          	addi	a5,a5,1272 # ffffffffc020f010 <slab_caches>
ffffffffc0200b20:	7394                	ld	a3,32(a5)
            cache->free_count++;
ffffffffc0200b22:	6b98                	ld	a4,16(a5)
            list_add(&cache->free_list, &base->page_link);  // 加入空闲链表
ffffffffc0200b24:	01850613          	addi	a2,a0,24
    prev->next = next->prev = elm;
ffffffffc0200b28:	e290                	sd	a2,0(a3)
ffffffffc0200b2a:	f390                	sd	a2,32(a5)
            cache->free_count++;
ffffffffc0200b2c:	0705                	addi	a4,a4,1
    elm->next = next;
ffffffffc0200b2e:	f114                	sd	a3,32(a0)
    elm->prev = prev;
ffffffffc0200b30:	0000e697          	auipc	a3,0xe
ffffffffc0200b34:	4f868693          	addi	a3,a3,1272 # ffffffffc020f028 <slab_caches+0x18>
ffffffffc0200b38:	ed14                	sd	a3,24(a0)
ffffffffc0200b3a:	eb98                	sd	a4,16(a5)
}
ffffffffc0200b3c:	8082                	ret

ffffffffc0200b3e <slub_check>:

// 验证 SLUB 分配器的正确性
void slub_check(void) {
ffffffffc0200b3e:	7179                	addi	sp,sp,-48
ffffffffc0200b40:	f022                	sd	s0,32(sp)
        total_free_pages += cache->free_count;
ffffffffc0200b42:	0000e417          	auipc	s0,0xe
ffffffffc0200b46:	4ce40413          	addi	s0,s0,1230 # ffffffffc020f010 <slab_caches>
ffffffffc0200b4a:	681c                	ld	a5,16(s0)
ffffffffc0200b4c:	7c14                	ld	a3,56(s0)
ffffffffc0200b4e:	7038                	ld	a4,96(s0)
void slub_check(void) {
ffffffffc0200b50:	e44e                	sd	s3,8(sp)
        total_free_pages += cache->free_count;
ffffffffc0200b52:	08843983          	ld	s3,136(s0)
ffffffffc0200b56:	97b6                	add	a5,a5,a3
ffffffffc0200b58:	97ba                	add	a5,a5,a4
    size_t all_pages = slub_nr_free_pages();
    struct Page *p0, *p1, *p2;

    // 测试分配和释放
    p0 = slub_alloc_pages(1);
ffffffffc0200b5a:	4505                	li	a0,1
void slub_check(void) {
ffffffffc0200b5c:	f406                	sd	ra,40(sp)
ffffffffc0200b5e:	ec26                	sd	s1,24(sp)
ffffffffc0200b60:	e84a                	sd	s2,16(sp)
        total_free_pages += cache->free_count;
ffffffffc0200b62:	99be                	add	s3,s3,a5
    p0 = slub_alloc_pages(1);
ffffffffc0200b64:	ef7ff0ef          	jal	ra,ffffffffc0200a5a <slub_alloc_pages>
    assert(p0 != NULL);
ffffffffc0200b68:	c925                	beqz	a0,ffffffffc0200bd8 <slub_check+0x9a>
ffffffffc0200b6a:	84aa                	mv	s1,a0
    p1 = slub_alloc_pages(1);
ffffffffc0200b6c:	4505                	li	a0,1
ffffffffc0200b6e:	eedff0ef          	jal	ra,ffffffffc0200a5a <slub_alloc_pages>
ffffffffc0200b72:	892a                	mv	s2,a0
    assert(p1 != NULL);
ffffffffc0200b74:	c171                	beqz	a0,ffffffffc0200c38 <slub_check+0xfa>
    p2 = slub_alloc_pages(1);
ffffffffc0200b76:	4505                	li	a0,1
ffffffffc0200b78:	ee3ff0ef          	jal	ra,ffffffffc0200a5a <slub_alloc_pages>
    assert(p2 != NULL);
ffffffffc0200b7c:	cd51                	beqz	a0,ffffffffc0200c18 <slub_check+0xda>
    __list_add(elm, listelm, listelm->next);
ffffffffc0200b7e:	7018                	ld	a4,32(s0)
            list_add(&cache->free_list, &base->page_link);  // 加入空闲链表
ffffffffc0200b80:	01848693          	addi	a3,s1,24
    elm->prev = prev;
ffffffffc0200b84:	0000e797          	auipc	a5,0xe
ffffffffc0200b88:	4a478793          	addi	a5,a5,1188 # ffffffffc020f028 <slab_caches+0x18>
    prev->next = next->prev = elm;
ffffffffc0200b8c:	e314                	sd	a3,0(a4)
ffffffffc0200b8e:	f014                	sd	a3,32(s0)
    elm->next = next;
ffffffffc0200b90:	f098                	sd	a4,32(s1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200b92:	7014                	ld	a3,32(s0)
ffffffffc0200b94:	01890613          	addi	a2,s2,24
    elm->prev = prev;
ffffffffc0200b98:	ec9c                	sd	a5,24(s1)
            cache->free_count++;
ffffffffc0200b9a:	6818                	ld	a4,16(s0)
    prev->next = next->prev = elm;
ffffffffc0200b9c:	e290                	sd	a2,0(a3)
ffffffffc0200b9e:	f010                	sd	a2,32(s0)
    elm->next = next;
ffffffffc0200ba0:	02d93023          	sd	a3,32(s2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200ba4:	7014                	ld	a3,32(s0)
            list_add(&cache->free_list, &base->page_link);  // 加入空闲链表
ffffffffc0200ba6:	01850613          	addi	a2,a0,24
    elm->prev = prev;
ffffffffc0200baa:	00f93c23          	sd	a5,24(s2)
    prev->next = next->prev = elm;
ffffffffc0200bae:	e290                	sd	a2,0(a3)
ffffffffc0200bb0:	f010                	sd	a2,32(s0)
    elm->next = next;
ffffffffc0200bb2:	f114                	sd	a3,32(a0)
    elm->prev = prev;
ffffffffc0200bb4:	ed1c                	sd	a5,24(a0)
        total_free_pages += cache->free_count;
ffffffffc0200bb6:	7c1c                	ld	a5,56(s0)
ffffffffc0200bb8:	7030                	ld	a2,96(s0)
ffffffffc0200bba:	6454                	ld	a3,136(s0)
            cache->free_count++;
ffffffffc0200bbc:	070d                	addi	a4,a4,3
        total_free_pages += cache->free_count;
ffffffffc0200bbe:	97b2                	add	a5,a5,a2
ffffffffc0200bc0:	97b6                	add	a5,a5,a3
            cache->free_count++;
ffffffffc0200bc2:	e818                	sd	a4,16(s0)
        total_free_pages += cache->free_count;
ffffffffc0200bc4:	97ba                	add	a5,a5,a4
    slub_free_pages(p0, 1);
    slub_free_pages(p1, 1);
    slub_free_pages(p2, 1);

    // 确认所有页数都正确释放
    assert(slub_nr_free_pages() == all_pages);
ffffffffc0200bc6:	03379963          	bne	a5,s3,ffffffffc0200bf8 <slub_check+0xba>

    // cprintf("SLUB allocator test passed.\n");
}
ffffffffc0200bca:	70a2                	ld	ra,40(sp)
ffffffffc0200bcc:	7402                	ld	s0,32(sp)
ffffffffc0200bce:	64e2                	ld	s1,24(sp)
ffffffffc0200bd0:	6942                	ld	s2,16(sp)
ffffffffc0200bd2:	69a2                	ld	s3,8(sp)
ffffffffc0200bd4:	6145                	addi	sp,sp,48
ffffffffc0200bd6:	8082                	ret
    assert(p0 != NULL);
ffffffffc0200bd8:	00001697          	auipc	a3,0x1
ffffffffc0200bdc:	e5068693          	addi	a3,a3,-432 # ffffffffc0201a28 <commands+0x600>
ffffffffc0200be0:	00001617          	auipc	a2,0x1
ffffffffc0200be4:	e5860613          	addi	a2,a2,-424 # ffffffffc0201a38 <commands+0x610>
ffffffffc0200be8:	07b00593          	li	a1,123
ffffffffc0200bec:	00001517          	auipc	a0,0x1
ffffffffc0200bf0:	e6450513          	addi	a0,a0,-412 # ffffffffc0201a50 <commands+0x628>
ffffffffc0200bf4:	d46ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(slub_nr_free_pages() == all_pages);
ffffffffc0200bf8:	00001697          	auipc	a3,0x1
ffffffffc0200bfc:	e9068693          	addi	a3,a3,-368 # ffffffffc0201a88 <commands+0x660>
ffffffffc0200c00:	00001617          	auipc	a2,0x1
ffffffffc0200c04:	e3860613          	addi	a2,a2,-456 # ffffffffc0201a38 <commands+0x610>
ffffffffc0200c08:	08700593          	li	a1,135
ffffffffc0200c0c:	00001517          	auipc	a0,0x1
ffffffffc0200c10:	e4450513          	addi	a0,a0,-444 # ffffffffc0201a50 <commands+0x628>
ffffffffc0200c14:	d26ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(p2 != NULL);
ffffffffc0200c18:	00001697          	auipc	a3,0x1
ffffffffc0200c1c:	e6068693          	addi	a3,a3,-416 # ffffffffc0201a78 <commands+0x650>
ffffffffc0200c20:	00001617          	auipc	a2,0x1
ffffffffc0200c24:	e1860613          	addi	a2,a2,-488 # ffffffffc0201a38 <commands+0x610>
ffffffffc0200c28:	07f00593          	li	a1,127
ffffffffc0200c2c:	00001517          	auipc	a0,0x1
ffffffffc0200c30:	e2450513          	addi	a0,a0,-476 # ffffffffc0201a50 <commands+0x628>
ffffffffc0200c34:	d06ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(p1 != NULL);
ffffffffc0200c38:	00001697          	auipc	a3,0x1
ffffffffc0200c3c:	e3068693          	addi	a3,a3,-464 # ffffffffc0201a68 <commands+0x640>
ffffffffc0200c40:	00001617          	auipc	a2,0x1
ffffffffc0200c44:	df860613          	addi	a2,a2,-520 # ffffffffc0201a38 <commands+0x610>
ffffffffc0200c48:	07d00593          	li	a1,125
ffffffffc0200c4c:	00001517          	auipc	a0,0x1
ffffffffc0200c50:	e0450513          	addi	a0,a0,-508 # ffffffffc0201a50 <commands+0x628>
ffffffffc0200c54:	ce6ff0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0200c58 <strnlen>:
ffffffffc0200c58:	4781                	li	a5,0
ffffffffc0200c5a:	e589                	bnez	a1,ffffffffc0200c64 <strnlen+0xc>
ffffffffc0200c5c:	a811                	j	ffffffffc0200c70 <strnlen+0x18>
ffffffffc0200c5e:	0785                	addi	a5,a5,1
ffffffffc0200c60:	00f58863          	beq	a1,a5,ffffffffc0200c70 <strnlen+0x18>
ffffffffc0200c64:	00f50733          	add	a4,a0,a5
ffffffffc0200c68:	00074703          	lbu	a4,0(a4)
ffffffffc0200c6c:	fb6d                	bnez	a4,ffffffffc0200c5e <strnlen+0x6>
ffffffffc0200c6e:	85be                	mv	a1,a5
ffffffffc0200c70:	852e                	mv	a0,a1
ffffffffc0200c72:	8082                	ret

ffffffffc0200c74 <strcmp>:
ffffffffc0200c74:	00054783          	lbu	a5,0(a0)
ffffffffc0200c78:	0005c703          	lbu	a4,0(a1)
ffffffffc0200c7c:	cb89                	beqz	a5,ffffffffc0200c8e <strcmp+0x1a>
ffffffffc0200c7e:	0505                	addi	a0,a0,1
ffffffffc0200c80:	0585                	addi	a1,a1,1
ffffffffc0200c82:	fee789e3          	beq	a5,a4,ffffffffc0200c74 <strcmp>
ffffffffc0200c86:	0007851b          	sext.w	a0,a5
ffffffffc0200c8a:	9d19                	subw	a0,a0,a4
ffffffffc0200c8c:	8082                	ret
ffffffffc0200c8e:	4501                	li	a0,0
ffffffffc0200c90:	bfed                	j	ffffffffc0200c8a <strcmp+0x16>

ffffffffc0200c92 <strchr>:
ffffffffc0200c92:	00054783          	lbu	a5,0(a0)
ffffffffc0200c96:	c799                	beqz	a5,ffffffffc0200ca4 <strchr+0x12>
ffffffffc0200c98:	00f58763          	beq	a1,a5,ffffffffc0200ca6 <strchr+0x14>
ffffffffc0200c9c:	00154783          	lbu	a5,1(a0)
ffffffffc0200ca0:	0505                	addi	a0,a0,1
ffffffffc0200ca2:	fbfd                	bnez	a5,ffffffffc0200c98 <strchr+0x6>
ffffffffc0200ca4:	4501                	li	a0,0
ffffffffc0200ca6:	8082                	ret

ffffffffc0200ca8 <memset>:
ffffffffc0200ca8:	ca01                	beqz	a2,ffffffffc0200cb8 <memset+0x10>
ffffffffc0200caa:	962a                	add	a2,a2,a0
ffffffffc0200cac:	87aa                	mv	a5,a0
ffffffffc0200cae:	0785                	addi	a5,a5,1
ffffffffc0200cb0:	feb78fa3          	sb	a1,-1(a5)
ffffffffc0200cb4:	fec79de3          	bne	a5,a2,ffffffffc0200cae <memset+0x6>
ffffffffc0200cb8:	8082                	ret

ffffffffc0200cba <printnum>:
ffffffffc0200cba:	02069813          	slli	a6,a3,0x20
ffffffffc0200cbe:	7179                	addi	sp,sp,-48
ffffffffc0200cc0:	02085813          	srli	a6,a6,0x20
ffffffffc0200cc4:	e052                	sd	s4,0(sp)
ffffffffc0200cc6:	03067a33          	remu	s4,a2,a6
ffffffffc0200cca:	f022                	sd	s0,32(sp)
ffffffffc0200ccc:	ec26                	sd	s1,24(sp)
ffffffffc0200cce:	e84a                	sd	s2,16(sp)
ffffffffc0200cd0:	f406                	sd	ra,40(sp)
ffffffffc0200cd2:	e44e                	sd	s3,8(sp)
ffffffffc0200cd4:	84aa                	mv	s1,a0
ffffffffc0200cd6:	892e                	mv	s2,a1
ffffffffc0200cd8:	fff7041b          	addiw	s0,a4,-1
ffffffffc0200cdc:	2a01                	sext.w	s4,s4
ffffffffc0200cde:	03067e63          	bgeu	a2,a6,ffffffffc0200d1a <printnum+0x60>
ffffffffc0200ce2:	89be                	mv	s3,a5
ffffffffc0200ce4:	00805763          	blez	s0,ffffffffc0200cf2 <printnum+0x38>
ffffffffc0200ce8:	347d                	addiw	s0,s0,-1
ffffffffc0200cea:	85ca                	mv	a1,s2
ffffffffc0200cec:	854e                	mv	a0,s3
ffffffffc0200cee:	9482                	jalr	s1
ffffffffc0200cf0:	fc65                	bnez	s0,ffffffffc0200ce8 <printnum+0x2e>
ffffffffc0200cf2:	1a02                	slli	s4,s4,0x20
ffffffffc0200cf4:	00001797          	auipc	a5,0x1
ffffffffc0200cf8:	e0c78793          	addi	a5,a5,-500 # ffffffffc0201b00 <slub_pmm_manager+0x38>
ffffffffc0200cfc:	020a5a13          	srli	s4,s4,0x20
ffffffffc0200d00:	9a3e                	add	s4,s4,a5
ffffffffc0200d02:	7402                	ld	s0,32(sp)
ffffffffc0200d04:	000a4503          	lbu	a0,0(s4)
ffffffffc0200d08:	70a2                	ld	ra,40(sp)
ffffffffc0200d0a:	69a2                	ld	s3,8(sp)
ffffffffc0200d0c:	6a02                	ld	s4,0(sp)
ffffffffc0200d0e:	85ca                	mv	a1,s2
ffffffffc0200d10:	87a6                	mv	a5,s1
ffffffffc0200d12:	6942                	ld	s2,16(sp)
ffffffffc0200d14:	64e2                	ld	s1,24(sp)
ffffffffc0200d16:	6145                	addi	sp,sp,48
ffffffffc0200d18:	8782                	jr	a5
ffffffffc0200d1a:	03065633          	divu	a2,a2,a6
ffffffffc0200d1e:	8722                	mv	a4,s0
ffffffffc0200d20:	f9bff0ef          	jal	ra,ffffffffc0200cba <printnum>
ffffffffc0200d24:	b7f9                	j	ffffffffc0200cf2 <printnum+0x38>

ffffffffc0200d26 <vprintfmt>:
ffffffffc0200d26:	7119                	addi	sp,sp,-128
ffffffffc0200d28:	f4a6                	sd	s1,104(sp)
ffffffffc0200d2a:	f0ca                	sd	s2,96(sp)
ffffffffc0200d2c:	ecce                	sd	s3,88(sp)
ffffffffc0200d2e:	e8d2                	sd	s4,80(sp)
ffffffffc0200d30:	e4d6                	sd	s5,72(sp)
ffffffffc0200d32:	e0da                	sd	s6,64(sp)
ffffffffc0200d34:	fc5e                	sd	s7,56(sp)
ffffffffc0200d36:	f06a                	sd	s10,32(sp)
ffffffffc0200d38:	fc86                	sd	ra,120(sp)
ffffffffc0200d3a:	f8a2                	sd	s0,112(sp)
ffffffffc0200d3c:	f862                	sd	s8,48(sp)
ffffffffc0200d3e:	f466                	sd	s9,40(sp)
ffffffffc0200d40:	ec6e                	sd	s11,24(sp)
ffffffffc0200d42:	892a                	mv	s2,a0
ffffffffc0200d44:	84ae                	mv	s1,a1
ffffffffc0200d46:	8d32                	mv	s10,a2
ffffffffc0200d48:	8a36                	mv	s4,a3
ffffffffc0200d4a:	02500993          	li	s3,37
ffffffffc0200d4e:	5b7d                	li	s6,-1
ffffffffc0200d50:	00001a97          	auipc	s5,0x1
ffffffffc0200d54:	de4a8a93          	addi	s5,s5,-540 # ffffffffc0201b34 <slub_pmm_manager+0x6c>
ffffffffc0200d58:	00001b97          	auipc	s7,0x1
ffffffffc0200d5c:	fb8b8b93          	addi	s7,s7,-72 # ffffffffc0201d10 <error_string>
ffffffffc0200d60:	000d4503          	lbu	a0,0(s10)
ffffffffc0200d64:	001d0413          	addi	s0,s10,1
ffffffffc0200d68:	01350a63          	beq	a0,s3,ffffffffc0200d7c <vprintfmt+0x56>
ffffffffc0200d6c:	c121                	beqz	a0,ffffffffc0200dac <vprintfmt+0x86>
ffffffffc0200d6e:	85a6                	mv	a1,s1
ffffffffc0200d70:	0405                	addi	s0,s0,1
ffffffffc0200d72:	9902                	jalr	s2
ffffffffc0200d74:	fff44503          	lbu	a0,-1(s0)
ffffffffc0200d78:	ff351ae3          	bne	a0,s3,ffffffffc0200d6c <vprintfmt+0x46>
ffffffffc0200d7c:	00044603          	lbu	a2,0(s0)
ffffffffc0200d80:	02000793          	li	a5,32
ffffffffc0200d84:	4c81                	li	s9,0
ffffffffc0200d86:	4881                	li	a7,0
ffffffffc0200d88:	5c7d                	li	s8,-1
ffffffffc0200d8a:	5dfd                	li	s11,-1
ffffffffc0200d8c:	05500513          	li	a0,85
ffffffffc0200d90:	4825                	li	a6,9
ffffffffc0200d92:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0200d96:	0ff5f593          	andi	a1,a1,255
ffffffffc0200d9a:	00140d13          	addi	s10,s0,1
ffffffffc0200d9e:	04b56263          	bltu	a0,a1,ffffffffc0200de2 <vprintfmt+0xbc>
ffffffffc0200da2:	058a                	slli	a1,a1,0x2
ffffffffc0200da4:	95d6                	add	a1,a1,s5
ffffffffc0200da6:	4194                	lw	a3,0(a1)
ffffffffc0200da8:	96d6                	add	a3,a3,s5
ffffffffc0200daa:	8682                	jr	a3
ffffffffc0200dac:	70e6                	ld	ra,120(sp)
ffffffffc0200dae:	7446                	ld	s0,112(sp)
ffffffffc0200db0:	74a6                	ld	s1,104(sp)
ffffffffc0200db2:	7906                	ld	s2,96(sp)
ffffffffc0200db4:	69e6                	ld	s3,88(sp)
ffffffffc0200db6:	6a46                	ld	s4,80(sp)
ffffffffc0200db8:	6aa6                	ld	s5,72(sp)
ffffffffc0200dba:	6b06                	ld	s6,64(sp)
ffffffffc0200dbc:	7be2                	ld	s7,56(sp)
ffffffffc0200dbe:	7c42                	ld	s8,48(sp)
ffffffffc0200dc0:	7ca2                	ld	s9,40(sp)
ffffffffc0200dc2:	7d02                	ld	s10,32(sp)
ffffffffc0200dc4:	6de2                	ld	s11,24(sp)
ffffffffc0200dc6:	6109                	addi	sp,sp,128
ffffffffc0200dc8:	8082                	ret
ffffffffc0200dca:	87b2                	mv	a5,a2
ffffffffc0200dcc:	00144603          	lbu	a2,1(s0)
ffffffffc0200dd0:	846a                	mv	s0,s10
ffffffffc0200dd2:	00140d13          	addi	s10,s0,1
ffffffffc0200dd6:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0200dda:	0ff5f593          	andi	a1,a1,255
ffffffffc0200dde:	fcb572e3          	bgeu	a0,a1,ffffffffc0200da2 <vprintfmt+0x7c>
ffffffffc0200de2:	85a6                	mv	a1,s1
ffffffffc0200de4:	02500513          	li	a0,37
ffffffffc0200de8:	9902                	jalr	s2
ffffffffc0200dea:	fff44783          	lbu	a5,-1(s0)
ffffffffc0200dee:	8d22                	mv	s10,s0
ffffffffc0200df0:	f73788e3          	beq	a5,s3,ffffffffc0200d60 <vprintfmt+0x3a>
ffffffffc0200df4:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0200df8:	1d7d                	addi	s10,s10,-1
ffffffffc0200dfa:	ff379de3          	bne	a5,s3,ffffffffc0200df4 <vprintfmt+0xce>
ffffffffc0200dfe:	b78d                	j	ffffffffc0200d60 <vprintfmt+0x3a>
ffffffffc0200e00:	fd060c1b          	addiw	s8,a2,-48
ffffffffc0200e04:	00144603          	lbu	a2,1(s0)
ffffffffc0200e08:	846a                	mv	s0,s10
ffffffffc0200e0a:	fd06069b          	addiw	a3,a2,-48
ffffffffc0200e0e:	0006059b          	sext.w	a1,a2
ffffffffc0200e12:	02d86463          	bltu	a6,a3,ffffffffc0200e3a <vprintfmt+0x114>
ffffffffc0200e16:	00144603          	lbu	a2,1(s0)
ffffffffc0200e1a:	002c169b          	slliw	a3,s8,0x2
ffffffffc0200e1e:	0186873b          	addw	a4,a3,s8
ffffffffc0200e22:	0017171b          	slliw	a4,a4,0x1
ffffffffc0200e26:	9f2d                	addw	a4,a4,a1
ffffffffc0200e28:	fd06069b          	addiw	a3,a2,-48
ffffffffc0200e2c:	0405                	addi	s0,s0,1
ffffffffc0200e2e:	fd070c1b          	addiw	s8,a4,-48
ffffffffc0200e32:	0006059b          	sext.w	a1,a2
ffffffffc0200e36:	fed870e3          	bgeu	a6,a3,ffffffffc0200e16 <vprintfmt+0xf0>
ffffffffc0200e3a:	f40ddce3          	bgez	s11,ffffffffc0200d92 <vprintfmt+0x6c>
ffffffffc0200e3e:	8de2                	mv	s11,s8
ffffffffc0200e40:	5c7d                	li	s8,-1
ffffffffc0200e42:	bf81                	j	ffffffffc0200d92 <vprintfmt+0x6c>
ffffffffc0200e44:	fffdc693          	not	a3,s11
ffffffffc0200e48:	96fd                	srai	a3,a3,0x3f
ffffffffc0200e4a:	00ddfdb3          	and	s11,s11,a3
ffffffffc0200e4e:	00144603          	lbu	a2,1(s0)
ffffffffc0200e52:	2d81                	sext.w	s11,s11
ffffffffc0200e54:	846a                	mv	s0,s10
ffffffffc0200e56:	bf35                	j	ffffffffc0200d92 <vprintfmt+0x6c>
ffffffffc0200e58:	000a2c03          	lw	s8,0(s4)
ffffffffc0200e5c:	00144603          	lbu	a2,1(s0)
ffffffffc0200e60:	0a21                	addi	s4,s4,8
ffffffffc0200e62:	846a                	mv	s0,s10
ffffffffc0200e64:	bfd9                	j	ffffffffc0200e3a <vprintfmt+0x114>
ffffffffc0200e66:	4705                	li	a4,1
ffffffffc0200e68:	008a0593          	addi	a1,s4,8
ffffffffc0200e6c:	01174463          	blt	a4,a7,ffffffffc0200e74 <vprintfmt+0x14e>
ffffffffc0200e70:	1a088e63          	beqz	a7,ffffffffc020102c <vprintfmt+0x306>
ffffffffc0200e74:	000a3603          	ld	a2,0(s4)
ffffffffc0200e78:	46c1                	li	a3,16
ffffffffc0200e7a:	8a2e                	mv	s4,a1
ffffffffc0200e7c:	2781                	sext.w	a5,a5
ffffffffc0200e7e:	876e                	mv	a4,s11
ffffffffc0200e80:	85a6                	mv	a1,s1
ffffffffc0200e82:	854a                	mv	a0,s2
ffffffffc0200e84:	e37ff0ef          	jal	ra,ffffffffc0200cba <printnum>
ffffffffc0200e88:	bde1                	j	ffffffffc0200d60 <vprintfmt+0x3a>
ffffffffc0200e8a:	000a2503          	lw	a0,0(s4)
ffffffffc0200e8e:	85a6                	mv	a1,s1
ffffffffc0200e90:	0a21                	addi	s4,s4,8
ffffffffc0200e92:	9902                	jalr	s2
ffffffffc0200e94:	b5f1                	j	ffffffffc0200d60 <vprintfmt+0x3a>
ffffffffc0200e96:	4705                	li	a4,1
ffffffffc0200e98:	008a0593          	addi	a1,s4,8
ffffffffc0200e9c:	01174463          	blt	a4,a7,ffffffffc0200ea4 <vprintfmt+0x17e>
ffffffffc0200ea0:	18088163          	beqz	a7,ffffffffc0201022 <vprintfmt+0x2fc>
ffffffffc0200ea4:	000a3603          	ld	a2,0(s4)
ffffffffc0200ea8:	46a9                	li	a3,10
ffffffffc0200eaa:	8a2e                	mv	s4,a1
ffffffffc0200eac:	bfc1                	j	ffffffffc0200e7c <vprintfmt+0x156>
ffffffffc0200eae:	00144603          	lbu	a2,1(s0)
ffffffffc0200eb2:	4c85                	li	s9,1
ffffffffc0200eb4:	846a                	mv	s0,s10
ffffffffc0200eb6:	bdf1                	j	ffffffffc0200d92 <vprintfmt+0x6c>
ffffffffc0200eb8:	85a6                	mv	a1,s1
ffffffffc0200eba:	02500513          	li	a0,37
ffffffffc0200ebe:	9902                	jalr	s2
ffffffffc0200ec0:	b545                	j	ffffffffc0200d60 <vprintfmt+0x3a>
ffffffffc0200ec2:	00144603          	lbu	a2,1(s0)
ffffffffc0200ec6:	2885                	addiw	a7,a7,1
ffffffffc0200ec8:	846a                	mv	s0,s10
ffffffffc0200eca:	b5e1                	j	ffffffffc0200d92 <vprintfmt+0x6c>
ffffffffc0200ecc:	4705                	li	a4,1
ffffffffc0200ece:	008a0593          	addi	a1,s4,8
ffffffffc0200ed2:	01174463          	blt	a4,a7,ffffffffc0200eda <vprintfmt+0x1b4>
ffffffffc0200ed6:	14088163          	beqz	a7,ffffffffc0201018 <vprintfmt+0x2f2>
ffffffffc0200eda:	000a3603          	ld	a2,0(s4)
ffffffffc0200ede:	46a1                	li	a3,8
ffffffffc0200ee0:	8a2e                	mv	s4,a1
ffffffffc0200ee2:	bf69                	j	ffffffffc0200e7c <vprintfmt+0x156>
ffffffffc0200ee4:	03000513          	li	a0,48
ffffffffc0200ee8:	85a6                	mv	a1,s1
ffffffffc0200eea:	e03e                	sd	a5,0(sp)
ffffffffc0200eec:	9902                	jalr	s2
ffffffffc0200eee:	85a6                	mv	a1,s1
ffffffffc0200ef0:	07800513          	li	a0,120
ffffffffc0200ef4:	9902                	jalr	s2
ffffffffc0200ef6:	0a21                	addi	s4,s4,8
ffffffffc0200ef8:	6782                	ld	a5,0(sp)
ffffffffc0200efa:	46c1                	li	a3,16
ffffffffc0200efc:	ff8a3603          	ld	a2,-8(s4)
ffffffffc0200f00:	bfb5                	j	ffffffffc0200e7c <vprintfmt+0x156>
ffffffffc0200f02:	000a3403          	ld	s0,0(s4)
ffffffffc0200f06:	008a0713          	addi	a4,s4,8
ffffffffc0200f0a:	e03a                	sd	a4,0(sp)
ffffffffc0200f0c:	14040263          	beqz	s0,ffffffffc0201050 <vprintfmt+0x32a>
ffffffffc0200f10:	0fb05763          	blez	s11,ffffffffc0200ffe <vprintfmt+0x2d8>
ffffffffc0200f14:	02d00693          	li	a3,45
ffffffffc0200f18:	0cd79163          	bne	a5,a3,ffffffffc0200fda <vprintfmt+0x2b4>
ffffffffc0200f1c:	00044783          	lbu	a5,0(s0)
ffffffffc0200f20:	0007851b          	sext.w	a0,a5
ffffffffc0200f24:	cf85                	beqz	a5,ffffffffc0200f5c <vprintfmt+0x236>
ffffffffc0200f26:	00140a13          	addi	s4,s0,1
ffffffffc0200f2a:	05e00413          	li	s0,94
ffffffffc0200f2e:	000c4563          	bltz	s8,ffffffffc0200f38 <vprintfmt+0x212>
ffffffffc0200f32:	3c7d                	addiw	s8,s8,-1
ffffffffc0200f34:	036c0263          	beq	s8,s6,ffffffffc0200f58 <vprintfmt+0x232>
ffffffffc0200f38:	85a6                	mv	a1,s1
ffffffffc0200f3a:	0e0c8e63          	beqz	s9,ffffffffc0201036 <vprintfmt+0x310>
ffffffffc0200f3e:	3781                	addiw	a5,a5,-32
ffffffffc0200f40:	0ef47b63          	bgeu	s0,a5,ffffffffc0201036 <vprintfmt+0x310>
ffffffffc0200f44:	03f00513          	li	a0,63
ffffffffc0200f48:	9902                	jalr	s2
ffffffffc0200f4a:	000a4783          	lbu	a5,0(s4)
ffffffffc0200f4e:	3dfd                	addiw	s11,s11,-1
ffffffffc0200f50:	0a05                	addi	s4,s4,1
ffffffffc0200f52:	0007851b          	sext.w	a0,a5
ffffffffc0200f56:	ffe1                	bnez	a5,ffffffffc0200f2e <vprintfmt+0x208>
ffffffffc0200f58:	01b05963          	blez	s11,ffffffffc0200f6a <vprintfmt+0x244>
ffffffffc0200f5c:	3dfd                	addiw	s11,s11,-1
ffffffffc0200f5e:	85a6                	mv	a1,s1
ffffffffc0200f60:	02000513          	li	a0,32
ffffffffc0200f64:	9902                	jalr	s2
ffffffffc0200f66:	fe0d9be3          	bnez	s11,ffffffffc0200f5c <vprintfmt+0x236>
ffffffffc0200f6a:	6a02                	ld	s4,0(sp)
ffffffffc0200f6c:	bbd5                	j	ffffffffc0200d60 <vprintfmt+0x3a>
ffffffffc0200f6e:	4705                	li	a4,1
ffffffffc0200f70:	008a0c93          	addi	s9,s4,8
ffffffffc0200f74:	01174463          	blt	a4,a7,ffffffffc0200f7c <vprintfmt+0x256>
ffffffffc0200f78:	08088d63          	beqz	a7,ffffffffc0201012 <vprintfmt+0x2ec>
ffffffffc0200f7c:	000a3403          	ld	s0,0(s4)
ffffffffc0200f80:	0a044d63          	bltz	s0,ffffffffc020103a <vprintfmt+0x314>
ffffffffc0200f84:	8622                	mv	a2,s0
ffffffffc0200f86:	8a66                	mv	s4,s9
ffffffffc0200f88:	46a9                	li	a3,10
ffffffffc0200f8a:	bdcd                	j	ffffffffc0200e7c <vprintfmt+0x156>
ffffffffc0200f8c:	000a2783          	lw	a5,0(s4)
ffffffffc0200f90:	4719                	li	a4,6
ffffffffc0200f92:	0a21                	addi	s4,s4,8
ffffffffc0200f94:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0200f98:	8fb5                	xor	a5,a5,a3
ffffffffc0200f9a:	40d786bb          	subw	a3,a5,a3
ffffffffc0200f9e:	02d74163          	blt	a4,a3,ffffffffc0200fc0 <vprintfmt+0x29a>
ffffffffc0200fa2:	00369793          	slli	a5,a3,0x3
ffffffffc0200fa6:	97de                	add	a5,a5,s7
ffffffffc0200fa8:	639c                	ld	a5,0(a5)
ffffffffc0200faa:	cb99                	beqz	a5,ffffffffc0200fc0 <vprintfmt+0x29a>
ffffffffc0200fac:	86be                	mv	a3,a5
ffffffffc0200fae:	00001617          	auipc	a2,0x1
ffffffffc0200fb2:	b8260613          	addi	a2,a2,-1150 # ffffffffc0201b30 <slub_pmm_manager+0x68>
ffffffffc0200fb6:	85a6                	mv	a1,s1
ffffffffc0200fb8:	854a                	mv	a0,s2
ffffffffc0200fba:	0ce000ef          	jal	ra,ffffffffc0201088 <printfmt>
ffffffffc0200fbe:	b34d                	j	ffffffffc0200d60 <vprintfmt+0x3a>
ffffffffc0200fc0:	00001617          	auipc	a2,0x1
ffffffffc0200fc4:	b6060613          	addi	a2,a2,-1184 # ffffffffc0201b20 <slub_pmm_manager+0x58>
ffffffffc0200fc8:	85a6                	mv	a1,s1
ffffffffc0200fca:	854a                	mv	a0,s2
ffffffffc0200fcc:	0bc000ef          	jal	ra,ffffffffc0201088 <printfmt>
ffffffffc0200fd0:	bb41                	j	ffffffffc0200d60 <vprintfmt+0x3a>
ffffffffc0200fd2:	00001417          	auipc	s0,0x1
ffffffffc0200fd6:	b4640413          	addi	s0,s0,-1210 # ffffffffc0201b18 <slub_pmm_manager+0x50>
ffffffffc0200fda:	85e2                	mv	a1,s8
ffffffffc0200fdc:	8522                	mv	a0,s0
ffffffffc0200fde:	e43e                	sd	a5,8(sp)
ffffffffc0200fe0:	c79ff0ef          	jal	ra,ffffffffc0200c58 <strnlen>
ffffffffc0200fe4:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0200fe8:	01b05b63          	blez	s11,ffffffffc0200ffe <vprintfmt+0x2d8>
ffffffffc0200fec:	67a2                	ld	a5,8(sp)
ffffffffc0200fee:	00078a1b          	sext.w	s4,a5
ffffffffc0200ff2:	3dfd                	addiw	s11,s11,-1
ffffffffc0200ff4:	85a6                	mv	a1,s1
ffffffffc0200ff6:	8552                	mv	a0,s4
ffffffffc0200ff8:	9902                	jalr	s2
ffffffffc0200ffa:	fe0d9ce3          	bnez	s11,ffffffffc0200ff2 <vprintfmt+0x2cc>
ffffffffc0200ffe:	00044783          	lbu	a5,0(s0)
ffffffffc0201002:	00140a13          	addi	s4,s0,1
ffffffffc0201006:	0007851b          	sext.w	a0,a5
ffffffffc020100a:	d3a5                	beqz	a5,ffffffffc0200f6a <vprintfmt+0x244>
ffffffffc020100c:	05e00413          	li	s0,94
ffffffffc0201010:	bf39                	j	ffffffffc0200f2e <vprintfmt+0x208>
ffffffffc0201012:	000a2403          	lw	s0,0(s4)
ffffffffc0201016:	b7ad                	j	ffffffffc0200f80 <vprintfmt+0x25a>
ffffffffc0201018:	000a6603          	lwu	a2,0(s4)
ffffffffc020101c:	46a1                	li	a3,8
ffffffffc020101e:	8a2e                	mv	s4,a1
ffffffffc0201020:	bdb1                	j	ffffffffc0200e7c <vprintfmt+0x156>
ffffffffc0201022:	000a6603          	lwu	a2,0(s4)
ffffffffc0201026:	46a9                	li	a3,10
ffffffffc0201028:	8a2e                	mv	s4,a1
ffffffffc020102a:	bd89                	j	ffffffffc0200e7c <vprintfmt+0x156>
ffffffffc020102c:	000a6603          	lwu	a2,0(s4)
ffffffffc0201030:	46c1                	li	a3,16
ffffffffc0201032:	8a2e                	mv	s4,a1
ffffffffc0201034:	b5a1                	j	ffffffffc0200e7c <vprintfmt+0x156>
ffffffffc0201036:	9902                	jalr	s2
ffffffffc0201038:	bf09                	j	ffffffffc0200f4a <vprintfmt+0x224>
ffffffffc020103a:	85a6                	mv	a1,s1
ffffffffc020103c:	02d00513          	li	a0,45
ffffffffc0201040:	e03e                	sd	a5,0(sp)
ffffffffc0201042:	9902                	jalr	s2
ffffffffc0201044:	6782                	ld	a5,0(sp)
ffffffffc0201046:	8a66                	mv	s4,s9
ffffffffc0201048:	40800633          	neg	a2,s0
ffffffffc020104c:	46a9                	li	a3,10
ffffffffc020104e:	b53d                	j	ffffffffc0200e7c <vprintfmt+0x156>
ffffffffc0201050:	03b05163          	blez	s11,ffffffffc0201072 <vprintfmt+0x34c>
ffffffffc0201054:	02d00693          	li	a3,45
ffffffffc0201058:	f6d79de3          	bne	a5,a3,ffffffffc0200fd2 <vprintfmt+0x2ac>
ffffffffc020105c:	00001417          	auipc	s0,0x1
ffffffffc0201060:	abc40413          	addi	s0,s0,-1348 # ffffffffc0201b18 <slub_pmm_manager+0x50>
ffffffffc0201064:	02800793          	li	a5,40
ffffffffc0201068:	02800513          	li	a0,40
ffffffffc020106c:	00140a13          	addi	s4,s0,1
ffffffffc0201070:	bd6d                	j	ffffffffc0200f2a <vprintfmt+0x204>
ffffffffc0201072:	00001a17          	auipc	s4,0x1
ffffffffc0201076:	aa7a0a13          	addi	s4,s4,-1369 # ffffffffc0201b19 <slub_pmm_manager+0x51>
ffffffffc020107a:	02800513          	li	a0,40
ffffffffc020107e:	02800793          	li	a5,40
ffffffffc0201082:	05e00413          	li	s0,94
ffffffffc0201086:	b565                	j	ffffffffc0200f2e <vprintfmt+0x208>

ffffffffc0201088 <printfmt>:
ffffffffc0201088:	715d                	addi	sp,sp,-80
ffffffffc020108a:	02810313          	addi	t1,sp,40
ffffffffc020108e:	f436                	sd	a3,40(sp)
ffffffffc0201090:	869a                	mv	a3,t1
ffffffffc0201092:	ec06                	sd	ra,24(sp)
ffffffffc0201094:	f83a                	sd	a4,48(sp)
ffffffffc0201096:	fc3e                	sd	a5,56(sp)
ffffffffc0201098:	e0c2                	sd	a6,64(sp)
ffffffffc020109a:	e4c6                	sd	a7,72(sp)
ffffffffc020109c:	e41a                	sd	t1,8(sp)
ffffffffc020109e:	c89ff0ef          	jal	ra,ffffffffc0200d26 <vprintfmt>
ffffffffc02010a2:	60e2                	ld	ra,24(sp)
ffffffffc02010a4:	6161                	addi	sp,sp,80
ffffffffc02010a6:	8082                	ret

ffffffffc02010a8 <readline>:
ffffffffc02010a8:	715d                	addi	sp,sp,-80
ffffffffc02010aa:	e486                	sd	ra,72(sp)
ffffffffc02010ac:	e0a6                	sd	s1,64(sp)
ffffffffc02010ae:	fc4a                	sd	s2,56(sp)
ffffffffc02010b0:	f84e                	sd	s3,48(sp)
ffffffffc02010b2:	f452                	sd	s4,40(sp)
ffffffffc02010b4:	f056                	sd	s5,32(sp)
ffffffffc02010b6:	ec5a                	sd	s6,24(sp)
ffffffffc02010b8:	e85e                	sd	s7,16(sp)
ffffffffc02010ba:	c901                	beqz	a0,ffffffffc02010ca <readline+0x22>
ffffffffc02010bc:	85aa                	mv	a1,a0
ffffffffc02010be:	00001517          	auipc	a0,0x1
ffffffffc02010c2:	a7250513          	addi	a0,a0,-1422 # ffffffffc0201b30 <slub_pmm_manager+0x68>
ffffffffc02010c6:	fedfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02010ca:	4481                	li	s1,0
ffffffffc02010cc:	497d                	li	s2,31
ffffffffc02010ce:	49a1                	li	s3,8
ffffffffc02010d0:	4aa9                	li	s5,10
ffffffffc02010d2:	4b35                	li	s6,13
ffffffffc02010d4:	0000eb97          	auipc	s7,0xe
ffffffffc02010d8:	fdcb8b93          	addi	s7,s7,-36 # ffffffffc020f0b0 <buf>
ffffffffc02010dc:	3fe00a13          	li	s4,1022
ffffffffc02010e0:	84aff0ef          	jal	ra,ffffffffc020012a <getchar>
ffffffffc02010e4:	00054a63          	bltz	a0,ffffffffc02010f8 <readline+0x50>
ffffffffc02010e8:	00a95a63          	bge	s2,a0,ffffffffc02010fc <readline+0x54>
ffffffffc02010ec:	029a5263          	bge	s4,s1,ffffffffc0201110 <readline+0x68>
ffffffffc02010f0:	83aff0ef          	jal	ra,ffffffffc020012a <getchar>
ffffffffc02010f4:	fe055ae3          	bgez	a0,ffffffffc02010e8 <readline+0x40>
ffffffffc02010f8:	4501                	li	a0,0
ffffffffc02010fa:	a091                	j	ffffffffc020113e <readline+0x96>
ffffffffc02010fc:	03351463          	bne	a0,s3,ffffffffc0201124 <readline+0x7c>
ffffffffc0201100:	e8a9                	bnez	s1,ffffffffc0201152 <readline+0xaa>
ffffffffc0201102:	828ff0ef          	jal	ra,ffffffffc020012a <getchar>
ffffffffc0201106:	fe0549e3          	bltz	a0,ffffffffc02010f8 <readline+0x50>
ffffffffc020110a:	fea959e3          	bge	s2,a0,ffffffffc02010fc <readline+0x54>
ffffffffc020110e:	4481                	li	s1,0
ffffffffc0201110:	e42a                	sd	a0,8(sp)
ffffffffc0201112:	fd7fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
ffffffffc0201116:	6522                	ld	a0,8(sp)
ffffffffc0201118:	009b87b3          	add	a5,s7,s1
ffffffffc020111c:	2485                	addiw	s1,s1,1
ffffffffc020111e:	00a78023          	sb	a0,0(a5)
ffffffffc0201122:	bf7d                	j	ffffffffc02010e0 <readline+0x38>
ffffffffc0201124:	01550463          	beq	a0,s5,ffffffffc020112c <readline+0x84>
ffffffffc0201128:	fb651ce3          	bne	a0,s6,ffffffffc02010e0 <readline+0x38>
ffffffffc020112c:	fbdfe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
ffffffffc0201130:	0000e517          	auipc	a0,0xe
ffffffffc0201134:	f8050513          	addi	a0,a0,-128 # ffffffffc020f0b0 <buf>
ffffffffc0201138:	94aa                	add	s1,s1,a0
ffffffffc020113a:	00048023          	sb	zero,0(s1)
ffffffffc020113e:	60a6                	ld	ra,72(sp)
ffffffffc0201140:	6486                	ld	s1,64(sp)
ffffffffc0201142:	7962                	ld	s2,56(sp)
ffffffffc0201144:	79c2                	ld	s3,48(sp)
ffffffffc0201146:	7a22                	ld	s4,40(sp)
ffffffffc0201148:	7a82                	ld	s5,32(sp)
ffffffffc020114a:	6b62                	ld	s6,24(sp)
ffffffffc020114c:	6bc2                	ld	s7,16(sp)
ffffffffc020114e:	6161                	addi	sp,sp,80
ffffffffc0201150:	8082                	ret
ffffffffc0201152:	4521                	li	a0,8
ffffffffc0201154:	f95fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
ffffffffc0201158:	34fd                	addiw	s1,s1,-1
ffffffffc020115a:	b759                	j	ffffffffc02010e0 <readline+0x38>

ffffffffc020115c <sbi_console_putchar>:
ffffffffc020115c:	4781                	li	a5,0
ffffffffc020115e:	00004717          	auipc	a4,0x4
ffffffffc0201162:	eaa73703          	ld	a4,-342(a4) # ffffffffc0205008 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201166:	88ba                	mv	a7,a4
ffffffffc0201168:	852a                	mv	a0,a0
ffffffffc020116a:	85be                	mv	a1,a5
ffffffffc020116c:	863e                	mv	a2,a5
ffffffffc020116e:	00000073          	ecall
ffffffffc0201172:	87aa                	mv	a5,a0
ffffffffc0201174:	8082                	ret

ffffffffc0201176 <sbi_set_timer>:
ffffffffc0201176:	4781                	li	a5,0
ffffffffc0201178:	0000e717          	auipc	a4,0xe
ffffffffc020117c:	38073703          	ld	a4,896(a4) # ffffffffc020f4f8 <SBI_SET_TIMER>
ffffffffc0201180:	88ba                	mv	a7,a4
ffffffffc0201182:	852a                	mv	a0,a0
ffffffffc0201184:	85be                	mv	a1,a5
ffffffffc0201186:	863e                	mv	a2,a5
ffffffffc0201188:	00000073          	ecall
ffffffffc020118c:	87aa                	mv	a5,a0
ffffffffc020118e:	8082                	ret

ffffffffc0201190 <sbi_console_getchar>:
ffffffffc0201190:	4501                	li	a0,0
ffffffffc0201192:	00004797          	auipc	a5,0x4
ffffffffc0201196:	e6e7b783          	ld	a5,-402(a5) # ffffffffc0205000 <SBI_CONSOLE_GETCHAR>
ffffffffc020119a:	88be                	mv	a7,a5
ffffffffc020119c:	852a                	mv	a0,a0
ffffffffc020119e:	85aa                	mv	a1,a0
ffffffffc02011a0:	862a                	mv	a2,a0
ffffffffc02011a2:	00000073          	ecall
ffffffffc02011a6:	852a                	mv	a0,a0
ffffffffc02011a8:	2501                	sext.w	a0,a0
ffffffffc02011aa:	8082                	ret
