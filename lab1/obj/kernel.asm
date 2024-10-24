
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp
    80200008:	a009                	j	8020000a <kern_init>

000000008020000a <kern_init>:
    8020000a:	00004517          	auipc	a0,0x4
    8020000e:	00650513          	addi	a0,a0,6 # 80204010 <ticks>
    80200012:	00004617          	auipc	a2,0x4
    80200016:	01660613          	addi	a2,a2,22 # 80204028 <end>
    8020001a:	1141                	addi	sp,sp,-16
    8020001c:	8e09                	sub	a2,a2,a0
    8020001e:	4581                	li	a1,0
    80200020:	e406                	sd	ra,8(sp)
    80200022:	598000ef          	jal	ra,802005ba <memset>
    80200026:	14a000ef          	jal	ra,80200170 <cons_init>
    8020002a:	00001597          	auipc	a1,0x1
    8020002e:	9de58593          	addi	a1,a1,-1570 # 80200a08 <etext>
    80200032:	00001517          	auipc	a0,0x1
    80200036:	9f650513          	addi	a0,a0,-1546 # 80200a28 <etext+0x20>
    8020003a:	030000ef          	jal	ra,8020006a <cprintf>
    8020003e:	062000ef          	jal	ra,802000a0 <print_kerninfo>
    80200042:	13e000ef          	jal	ra,80200180 <idt_init>
    80200046:	0e8000ef          	jal	ra,8020012e <clock_init>
    8020004a:	130000ef          	jal	ra,8020017a <intr_enable>
    8020004e:	a001                	j	8020004e <kern_init+0x44>

0000000080200050 <cputch>:
    80200050:	1141                	addi	sp,sp,-16
    80200052:	e022                	sd	s0,0(sp)
    80200054:	e406                	sd	ra,8(sp)
    80200056:	842e                	mv	s0,a1
    80200058:	11a000ef          	jal	ra,80200172 <cons_putc>
    8020005c:	401c                	lw	a5,0(s0)
    8020005e:	60a2                	ld	ra,8(sp)
    80200060:	2785                	addiw	a5,a5,1
    80200062:	c01c                	sw	a5,0(s0)
    80200064:	6402                	ld	s0,0(sp)
    80200066:	0141                	addi	sp,sp,16
    80200068:	8082                	ret

000000008020006a <cprintf>:
    8020006a:	711d                	addi	sp,sp,-96
    8020006c:	02810313          	addi	t1,sp,40 # 80204028 <end>
    80200070:	8e2a                	mv	t3,a0
    80200072:	f42e                	sd	a1,40(sp)
    80200074:	f832                	sd	a2,48(sp)
    80200076:	fc36                	sd	a3,56(sp)
    80200078:	00000517          	auipc	a0,0x0
    8020007c:	fd850513          	addi	a0,a0,-40 # 80200050 <cputch>
    80200080:	004c                	addi	a1,sp,4
    80200082:	869a                	mv	a3,t1
    80200084:	8672                	mv	a2,t3
    80200086:	ec06                	sd	ra,24(sp)
    80200088:	e0ba                	sd	a4,64(sp)
    8020008a:	e4be                	sd	a5,72(sp)
    8020008c:	e8c2                	sd	a6,80(sp)
    8020008e:	ecc6                	sd	a7,88(sp)
    80200090:	e41a                	sd	t1,8(sp)
    80200092:	c202                	sw	zero,4(sp)
    80200094:	5a4000ef          	jal	ra,80200638 <vprintfmt>
    80200098:	60e2                	ld	ra,24(sp)
    8020009a:	4512                	lw	a0,4(sp)
    8020009c:	6125                	addi	sp,sp,96
    8020009e:	8082                	ret

00000000802000a0 <print_kerninfo>:
    802000a0:	1141                	addi	sp,sp,-16
    802000a2:	00001517          	auipc	a0,0x1
    802000a6:	98e50513          	addi	a0,a0,-1650 # 80200a30 <etext+0x28>
    802000aa:	e406                	sd	ra,8(sp)
    802000ac:	fbfff0ef          	jal	ra,8020006a <cprintf>
    802000b0:	00000597          	auipc	a1,0x0
    802000b4:	f5a58593          	addi	a1,a1,-166 # 8020000a <kern_init>
    802000b8:	00001517          	auipc	a0,0x1
    802000bc:	99850513          	addi	a0,a0,-1640 # 80200a50 <etext+0x48>
    802000c0:	fabff0ef          	jal	ra,8020006a <cprintf>
    802000c4:	00001597          	auipc	a1,0x1
    802000c8:	94458593          	addi	a1,a1,-1724 # 80200a08 <etext>
    802000cc:	00001517          	auipc	a0,0x1
    802000d0:	9a450513          	addi	a0,a0,-1628 # 80200a70 <etext+0x68>
    802000d4:	f97ff0ef          	jal	ra,8020006a <cprintf>
    802000d8:	00004597          	auipc	a1,0x4
    802000dc:	f3858593          	addi	a1,a1,-200 # 80204010 <ticks>
    802000e0:	00001517          	auipc	a0,0x1
    802000e4:	9b050513          	addi	a0,a0,-1616 # 80200a90 <etext+0x88>
    802000e8:	f83ff0ef          	jal	ra,8020006a <cprintf>
    802000ec:	00004597          	auipc	a1,0x4
    802000f0:	f3c58593          	addi	a1,a1,-196 # 80204028 <end>
    802000f4:	00001517          	auipc	a0,0x1
    802000f8:	9bc50513          	addi	a0,a0,-1604 # 80200ab0 <etext+0xa8>
    802000fc:	f6fff0ef          	jal	ra,8020006a <cprintf>
    80200100:	00004597          	auipc	a1,0x4
    80200104:	32758593          	addi	a1,a1,807 # 80204427 <end+0x3ff>
    80200108:	00000797          	auipc	a5,0x0
    8020010c:	f0278793          	addi	a5,a5,-254 # 8020000a <kern_init>
    80200110:	40f587b3          	sub	a5,a1,a5
    80200114:	43f7d593          	srai	a1,a5,0x3f
    80200118:	60a2                	ld	ra,8(sp)
    8020011a:	3ff5f593          	andi	a1,a1,1023
    8020011e:	95be                	add	a1,a1,a5
    80200120:	85a9                	srai	a1,a1,0xa
    80200122:	00001517          	auipc	a0,0x1
    80200126:	9ae50513          	addi	a0,a0,-1618 # 80200ad0 <etext+0xc8>
    8020012a:	0141                	addi	sp,sp,16
    8020012c:	bf3d                	j	8020006a <cprintf>

000000008020012e <clock_init>:
    8020012e:	1141                	addi	sp,sp,-16
    80200130:	e406                	sd	ra,8(sp)
    80200132:	02000793          	li	a5,32
    80200136:	1047a7f3          	csrrs	a5,sie,a5
    8020013a:	c0102573          	rdtime	a0
    8020013e:	67e1                	lui	a5,0x18
    80200140:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    80200144:	953e                	add	a0,a0,a5
    80200146:	08f000ef          	jal	ra,802009d4 <sbi_set_timer>
    8020014a:	60a2                	ld	ra,8(sp)
    8020014c:	00004797          	auipc	a5,0x4
    80200150:	ec07b223          	sd	zero,-316(a5) # 80204010 <ticks>
    80200154:	00001517          	auipc	a0,0x1
    80200158:	9ac50513          	addi	a0,a0,-1620 # 80200b00 <etext+0xf8>
    8020015c:	0141                	addi	sp,sp,16
    8020015e:	b731                	j	8020006a <cprintf>

0000000080200160 <clock_set_next_event>:
    80200160:	c0102573          	rdtime	a0
    80200164:	67e1                	lui	a5,0x18
    80200166:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    8020016a:	953e                	add	a0,a0,a5
    8020016c:	0690006f          	j	802009d4 <sbi_set_timer>

0000000080200170 <cons_init>:
    80200170:	8082                	ret

0000000080200172 <cons_putc>:
    80200172:	0ff57513          	andi	a0,a0,255
    80200176:	0450006f          	j	802009ba <sbi_console_putchar>

000000008020017a <intr_enable>:
    8020017a:	100167f3          	csrrsi	a5,sstatus,2
    8020017e:	8082                	ret

0000000080200180 <idt_init>:
    80200180:	14005073          	csrwi	sscratch,0
    80200184:	00000797          	auipc	a5,0x0
    80200188:	36478793          	addi	a5,a5,868 # 802004e8 <__alltraps>
    8020018c:	10579073          	csrw	stvec,a5
    80200190:	8082                	ret

0000000080200192 <print_regs>:
    80200192:	610c                	ld	a1,0(a0)
    80200194:	1141                	addi	sp,sp,-16
    80200196:	e022                	sd	s0,0(sp)
    80200198:	842a                	mv	s0,a0
    8020019a:	00001517          	auipc	a0,0x1
    8020019e:	98650513          	addi	a0,a0,-1658 # 80200b20 <etext+0x118>
    802001a2:	e406                	sd	ra,8(sp)
    802001a4:	ec7ff0ef          	jal	ra,8020006a <cprintf>
    802001a8:	640c                	ld	a1,8(s0)
    802001aa:	00001517          	auipc	a0,0x1
    802001ae:	98e50513          	addi	a0,a0,-1650 # 80200b38 <etext+0x130>
    802001b2:	eb9ff0ef          	jal	ra,8020006a <cprintf>
    802001b6:	680c                	ld	a1,16(s0)
    802001b8:	00001517          	auipc	a0,0x1
    802001bc:	99850513          	addi	a0,a0,-1640 # 80200b50 <etext+0x148>
    802001c0:	eabff0ef          	jal	ra,8020006a <cprintf>
    802001c4:	6c0c                	ld	a1,24(s0)
    802001c6:	00001517          	auipc	a0,0x1
    802001ca:	9a250513          	addi	a0,a0,-1630 # 80200b68 <etext+0x160>
    802001ce:	e9dff0ef          	jal	ra,8020006a <cprintf>
    802001d2:	700c                	ld	a1,32(s0)
    802001d4:	00001517          	auipc	a0,0x1
    802001d8:	9ac50513          	addi	a0,a0,-1620 # 80200b80 <etext+0x178>
    802001dc:	e8fff0ef          	jal	ra,8020006a <cprintf>
    802001e0:	740c                	ld	a1,40(s0)
    802001e2:	00001517          	auipc	a0,0x1
    802001e6:	9b650513          	addi	a0,a0,-1610 # 80200b98 <etext+0x190>
    802001ea:	e81ff0ef          	jal	ra,8020006a <cprintf>
    802001ee:	780c                	ld	a1,48(s0)
    802001f0:	00001517          	auipc	a0,0x1
    802001f4:	9c050513          	addi	a0,a0,-1600 # 80200bb0 <etext+0x1a8>
    802001f8:	e73ff0ef          	jal	ra,8020006a <cprintf>
    802001fc:	7c0c                	ld	a1,56(s0)
    802001fe:	00001517          	auipc	a0,0x1
    80200202:	9ca50513          	addi	a0,a0,-1590 # 80200bc8 <etext+0x1c0>
    80200206:	e65ff0ef          	jal	ra,8020006a <cprintf>
    8020020a:	602c                	ld	a1,64(s0)
    8020020c:	00001517          	auipc	a0,0x1
    80200210:	9d450513          	addi	a0,a0,-1580 # 80200be0 <etext+0x1d8>
    80200214:	e57ff0ef          	jal	ra,8020006a <cprintf>
    80200218:	642c                	ld	a1,72(s0)
    8020021a:	00001517          	auipc	a0,0x1
    8020021e:	9de50513          	addi	a0,a0,-1570 # 80200bf8 <etext+0x1f0>
    80200222:	e49ff0ef          	jal	ra,8020006a <cprintf>
    80200226:	682c                	ld	a1,80(s0)
    80200228:	00001517          	auipc	a0,0x1
    8020022c:	9e850513          	addi	a0,a0,-1560 # 80200c10 <etext+0x208>
    80200230:	e3bff0ef          	jal	ra,8020006a <cprintf>
    80200234:	6c2c                	ld	a1,88(s0)
    80200236:	00001517          	auipc	a0,0x1
    8020023a:	9f250513          	addi	a0,a0,-1550 # 80200c28 <etext+0x220>
    8020023e:	e2dff0ef          	jal	ra,8020006a <cprintf>
    80200242:	702c                	ld	a1,96(s0)
    80200244:	00001517          	auipc	a0,0x1
    80200248:	9fc50513          	addi	a0,a0,-1540 # 80200c40 <etext+0x238>
    8020024c:	e1fff0ef          	jal	ra,8020006a <cprintf>
    80200250:	742c                	ld	a1,104(s0)
    80200252:	00001517          	auipc	a0,0x1
    80200256:	a0650513          	addi	a0,a0,-1530 # 80200c58 <etext+0x250>
    8020025a:	e11ff0ef          	jal	ra,8020006a <cprintf>
    8020025e:	782c                	ld	a1,112(s0)
    80200260:	00001517          	auipc	a0,0x1
    80200264:	a1050513          	addi	a0,a0,-1520 # 80200c70 <etext+0x268>
    80200268:	e03ff0ef          	jal	ra,8020006a <cprintf>
    8020026c:	7c2c                	ld	a1,120(s0)
    8020026e:	00001517          	auipc	a0,0x1
    80200272:	a1a50513          	addi	a0,a0,-1510 # 80200c88 <etext+0x280>
    80200276:	df5ff0ef          	jal	ra,8020006a <cprintf>
    8020027a:	604c                	ld	a1,128(s0)
    8020027c:	00001517          	auipc	a0,0x1
    80200280:	a2450513          	addi	a0,a0,-1500 # 80200ca0 <etext+0x298>
    80200284:	de7ff0ef          	jal	ra,8020006a <cprintf>
    80200288:	644c                	ld	a1,136(s0)
    8020028a:	00001517          	auipc	a0,0x1
    8020028e:	a2e50513          	addi	a0,a0,-1490 # 80200cb8 <etext+0x2b0>
    80200292:	dd9ff0ef          	jal	ra,8020006a <cprintf>
    80200296:	684c                	ld	a1,144(s0)
    80200298:	00001517          	auipc	a0,0x1
    8020029c:	a3850513          	addi	a0,a0,-1480 # 80200cd0 <etext+0x2c8>
    802002a0:	dcbff0ef          	jal	ra,8020006a <cprintf>
    802002a4:	6c4c                	ld	a1,152(s0)
    802002a6:	00001517          	auipc	a0,0x1
    802002aa:	a4250513          	addi	a0,a0,-1470 # 80200ce8 <etext+0x2e0>
    802002ae:	dbdff0ef          	jal	ra,8020006a <cprintf>
    802002b2:	704c                	ld	a1,160(s0)
    802002b4:	00001517          	auipc	a0,0x1
    802002b8:	a4c50513          	addi	a0,a0,-1460 # 80200d00 <etext+0x2f8>
    802002bc:	dafff0ef          	jal	ra,8020006a <cprintf>
    802002c0:	744c                	ld	a1,168(s0)
    802002c2:	00001517          	auipc	a0,0x1
    802002c6:	a5650513          	addi	a0,a0,-1450 # 80200d18 <etext+0x310>
    802002ca:	da1ff0ef          	jal	ra,8020006a <cprintf>
    802002ce:	784c                	ld	a1,176(s0)
    802002d0:	00001517          	auipc	a0,0x1
    802002d4:	a6050513          	addi	a0,a0,-1440 # 80200d30 <etext+0x328>
    802002d8:	d93ff0ef          	jal	ra,8020006a <cprintf>
    802002dc:	7c4c                	ld	a1,184(s0)
    802002de:	00001517          	auipc	a0,0x1
    802002e2:	a6a50513          	addi	a0,a0,-1430 # 80200d48 <etext+0x340>
    802002e6:	d85ff0ef          	jal	ra,8020006a <cprintf>
    802002ea:	606c                	ld	a1,192(s0)
    802002ec:	00001517          	auipc	a0,0x1
    802002f0:	a7450513          	addi	a0,a0,-1420 # 80200d60 <etext+0x358>
    802002f4:	d77ff0ef          	jal	ra,8020006a <cprintf>
    802002f8:	646c                	ld	a1,200(s0)
    802002fa:	00001517          	auipc	a0,0x1
    802002fe:	a7e50513          	addi	a0,a0,-1410 # 80200d78 <etext+0x370>
    80200302:	d69ff0ef          	jal	ra,8020006a <cprintf>
    80200306:	686c                	ld	a1,208(s0)
    80200308:	00001517          	auipc	a0,0x1
    8020030c:	a8850513          	addi	a0,a0,-1400 # 80200d90 <etext+0x388>
    80200310:	d5bff0ef          	jal	ra,8020006a <cprintf>
    80200314:	6c6c                	ld	a1,216(s0)
    80200316:	00001517          	auipc	a0,0x1
    8020031a:	a9250513          	addi	a0,a0,-1390 # 80200da8 <etext+0x3a0>
    8020031e:	d4dff0ef          	jal	ra,8020006a <cprintf>
    80200322:	706c                	ld	a1,224(s0)
    80200324:	00001517          	auipc	a0,0x1
    80200328:	a9c50513          	addi	a0,a0,-1380 # 80200dc0 <etext+0x3b8>
    8020032c:	d3fff0ef          	jal	ra,8020006a <cprintf>
    80200330:	746c                	ld	a1,232(s0)
    80200332:	00001517          	auipc	a0,0x1
    80200336:	aa650513          	addi	a0,a0,-1370 # 80200dd8 <etext+0x3d0>
    8020033a:	d31ff0ef          	jal	ra,8020006a <cprintf>
    8020033e:	786c                	ld	a1,240(s0)
    80200340:	00001517          	auipc	a0,0x1
    80200344:	ab050513          	addi	a0,a0,-1360 # 80200df0 <etext+0x3e8>
    80200348:	d23ff0ef          	jal	ra,8020006a <cprintf>
    8020034c:	7c6c                	ld	a1,248(s0)
    8020034e:	6402                	ld	s0,0(sp)
    80200350:	60a2                	ld	ra,8(sp)
    80200352:	00001517          	auipc	a0,0x1
    80200356:	ab650513          	addi	a0,a0,-1354 # 80200e08 <etext+0x400>
    8020035a:	0141                	addi	sp,sp,16
    8020035c:	b339                	j	8020006a <cprintf>

000000008020035e <print_trapframe>:
    8020035e:	1141                	addi	sp,sp,-16
    80200360:	e022                	sd	s0,0(sp)
    80200362:	85aa                	mv	a1,a0
    80200364:	842a                	mv	s0,a0
    80200366:	00001517          	auipc	a0,0x1
    8020036a:	aba50513          	addi	a0,a0,-1350 # 80200e20 <etext+0x418>
    8020036e:	e406                	sd	ra,8(sp)
    80200370:	cfbff0ef          	jal	ra,8020006a <cprintf>
    80200374:	8522                	mv	a0,s0
    80200376:	e1dff0ef          	jal	ra,80200192 <print_regs>
    8020037a:	10043583          	ld	a1,256(s0)
    8020037e:	00001517          	auipc	a0,0x1
    80200382:	aba50513          	addi	a0,a0,-1350 # 80200e38 <etext+0x430>
    80200386:	ce5ff0ef          	jal	ra,8020006a <cprintf>
    8020038a:	10843583          	ld	a1,264(s0)
    8020038e:	00001517          	auipc	a0,0x1
    80200392:	ac250513          	addi	a0,a0,-1342 # 80200e50 <etext+0x448>
    80200396:	cd5ff0ef          	jal	ra,8020006a <cprintf>
    8020039a:	11043583          	ld	a1,272(s0)
    8020039e:	00001517          	auipc	a0,0x1
    802003a2:	aca50513          	addi	a0,a0,-1334 # 80200e68 <etext+0x460>
    802003a6:	cc5ff0ef          	jal	ra,8020006a <cprintf>
    802003aa:	11843583          	ld	a1,280(s0)
    802003ae:	6402                	ld	s0,0(sp)
    802003b0:	60a2                	ld	ra,8(sp)
    802003b2:	00001517          	auipc	a0,0x1
    802003b6:	ace50513          	addi	a0,a0,-1330 # 80200e80 <etext+0x478>
    802003ba:	0141                	addi	sp,sp,16
    802003bc:	b17d                	j	8020006a <cprintf>

00000000802003be <interrupt_handler>:
    802003be:	11853783          	ld	a5,280(a0)
    802003c2:	472d                	li	a4,11
    802003c4:	0786                	slli	a5,a5,0x1
    802003c6:	8385                	srli	a5,a5,0x1
    802003c8:	06f76a63          	bltu	a4,a5,8020043c <interrupt_handler+0x7e>
    802003cc:	00001717          	auipc	a4,0x1
    802003d0:	b7c70713          	addi	a4,a4,-1156 # 80200f48 <etext+0x540>
    802003d4:	078a                	slli	a5,a5,0x2
    802003d6:	97ba                	add	a5,a5,a4
    802003d8:	439c                	lw	a5,0(a5)
    802003da:	97ba                	add	a5,a5,a4
    802003dc:	8782                	jr	a5
    802003de:	00001517          	auipc	a0,0x1
    802003e2:	b1a50513          	addi	a0,a0,-1254 # 80200ef8 <etext+0x4f0>
    802003e6:	b151                	j	8020006a <cprintf>
    802003e8:	00001517          	auipc	a0,0x1
    802003ec:	af050513          	addi	a0,a0,-1296 # 80200ed8 <etext+0x4d0>
    802003f0:	b9ad                	j	8020006a <cprintf>
    802003f2:	00001517          	auipc	a0,0x1
    802003f6:	aa650513          	addi	a0,a0,-1370 # 80200e98 <etext+0x490>
    802003fa:	b985                	j	8020006a <cprintf>
    802003fc:	00001517          	auipc	a0,0x1
    80200400:	abc50513          	addi	a0,a0,-1348 # 80200eb8 <etext+0x4b0>
    80200404:	b19d                	j	8020006a <cprintf>
    80200406:	1141                	addi	sp,sp,-16
    80200408:	e022                	sd	s0,0(sp)
    8020040a:	e406                	sd	ra,8(sp)
    8020040c:	00004417          	auipc	s0,0x4
    80200410:	c0c40413          	addi	s0,s0,-1012 # 80204018 <num>
    80200414:	d4dff0ef          	jal	ra,80200160 <clock_set_next_event>
    80200418:	601c                	ld	a5,0(s0)
    8020041a:	06400713          	li	a4,100
    8020041e:	0785                	addi	a5,a5,1
    80200420:	e01c                	sd	a5,0(s0)
    80200422:	601c                	ld	a5,0(s0)
    80200424:	02e7f7b3          	remu	a5,a5,a4
    80200428:	cb99                	beqz	a5,8020043e <interrupt_handler+0x80>
    8020042a:	60a2                	ld	ra,8(sp)
    8020042c:	6402                	ld	s0,0(sp)
    8020042e:	0141                	addi	sp,sp,16
    80200430:	8082                	ret
    80200432:	00001517          	auipc	a0,0x1
    80200436:	af650513          	addi	a0,a0,-1290 # 80200f28 <etext+0x520>
    8020043a:	b905                	j	8020006a <cprintf>
    8020043c:	b70d                	j	8020035e <print_trapframe>
    8020043e:	06400593          	li	a1,100
    80200442:	00001517          	auipc	a0,0x1
    80200446:	ad650513          	addi	a0,a0,-1322 # 80200f18 <etext+0x510>
    8020044a:	c21ff0ef          	jal	ra,8020006a <cprintf>
    8020044e:	6018                	ld	a4,0(s0)
    80200450:	3e700793          	li	a5,999
    80200454:	fce7fbe3          	bgeu	a5,a4,8020042a <interrupt_handler+0x6c>
    80200458:	6402                	ld	s0,0(sp)
    8020045a:	60a2                	ld	ra,8(sp)
    8020045c:	0141                	addi	sp,sp,16
    8020045e:	ab41                	j	802009ee <sbi_shutdown>

0000000080200460 <exception_handler>:
    80200460:	11853783          	ld	a5,280(a0)
    80200464:	1141                	addi	sp,sp,-16
    80200466:	e022                	sd	s0,0(sp)
    80200468:	e406                	sd	ra,8(sp)
    8020046a:	470d                	li	a4,3
    8020046c:	842a                	mv	s0,a0
    8020046e:	04e78363          	beq	a5,a4,802004b4 <exception_handler+0x54>
    80200472:	02f76963          	bltu	a4,a5,802004a4 <exception_handler+0x44>
    80200476:	4709                	li	a4,2
    80200478:	02e79263          	bne	a5,a4,8020049c <exception_handler+0x3c>
    8020047c:	00001517          	auipc	a0,0x1
    80200480:	afc50513          	addi	a0,a0,-1284 # 80200f78 <etext+0x570>
    80200484:	be7ff0ef          	jal	ra,8020006a <cprintf>
    80200488:	10843583          	ld	a1,264(s0)
    8020048c:	00001517          	auipc	a0,0x1
    80200490:	b1450513          	addi	a0,a0,-1260 # 80200fa0 <etext+0x598>
    80200494:	bd7ff0ef          	jal	ra,8020006a <cprintf>
    80200498:	10043423          	sd	zero,264(s0)
    8020049c:	60a2                	ld	ra,8(sp)
    8020049e:	6402                	ld	s0,0(sp)
    802004a0:	0141                	addi	sp,sp,16
    802004a2:	8082                	ret
    802004a4:	17f1                	addi	a5,a5,-4
    802004a6:	471d                	li	a4,7
    802004a8:	fef77ae3          	bgeu	a4,a5,8020049c <exception_handler+0x3c>
    802004ac:	6402                	ld	s0,0(sp)
    802004ae:	60a2                	ld	ra,8(sp)
    802004b0:	0141                	addi	sp,sp,16
    802004b2:	b575                	j	8020035e <print_trapframe>
    802004b4:	00001517          	auipc	a0,0x1
    802004b8:	b1450513          	addi	a0,a0,-1260 # 80200fc8 <etext+0x5c0>
    802004bc:	bafff0ef          	jal	ra,8020006a <cprintf>
    802004c0:	10843583          	ld	a1,264(s0)
    802004c4:	00001517          	auipc	a0,0x1
    802004c8:	b2450513          	addi	a0,a0,-1244 # 80200fe8 <etext+0x5e0>
    802004cc:	b9fff0ef          	jal	ra,8020006a <cprintf>
    802004d0:	60a2                	ld	ra,8(sp)
    802004d2:	10043423          	sd	zero,264(s0)
    802004d6:	6402                	ld	s0,0(sp)
    802004d8:	0141                	addi	sp,sp,16
    802004da:	8082                	ret

00000000802004dc <trap>:
    802004dc:	11853783          	ld	a5,280(a0)
    802004e0:	0007c363          	bltz	a5,802004e6 <trap+0xa>
    802004e4:	bfb5                	j	80200460 <exception_handler>
    802004e6:	bde1                	j	802003be <interrupt_handler>

00000000802004e8 <__alltraps>:
    802004e8:	14011073          	csrw	sscratch,sp
    802004ec:	712d                	addi	sp,sp,-288
    802004ee:	e002                	sd	zero,0(sp)
    802004f0:	e406                	sd	ra,8(sp)
    802004f2:	ec0e                	sd	gp,24(sp)
    802004f4:	f012                	sd	tp,32(sp)
    802004f6:	f416                	sd	t0,40(sp)
    802004f8:	f81a                	sd	t1,48(sp)
    802004fa:	fc1e                	sd	t2,56(sp)
    802004fc:	e0a2                	sd	s0,64(sp)
    802004fe:	e4a6                	sd	s1,72(sp)
    80200500:	e8aa                	sd	a0,80(sp)
    80200502:	ecae                	sd	a1,88(sp)
    80200504:	f0b2                	sd	a2,96(sp)
    80200506:	f4b6                	sd	a3,104(sp)
    80200508:	f8ba                	sd	a4,112(sp)
    8020050a:	fcbe                	sd	a5,120(sp)
    8020050c:	e142                	sd	a6,128(sp)
    8020050e:	e546                	sd	a7,136(sp)
    80200510:	e94a                	sd	s2,144(sp)
    80200512:	ed4e                	sd	s3,152(sp)
    80200514:	f152                	sd	s4,160(sp)
    80200516:	f556                	sd	s5,168(sp)
    80200518:	f95a                	sd	s6,176(sp)
    8020051a:	fd5e                	sd	s7,184(sp)
    8020051c:	e1e2                	sd	s8,192(sp)
    8020051e:	e5e6                	sd	s9,200(sp)
    80200520:	e9ea                	sd	s10,208(sp)
    80200522:	edee                	sd	s11,216(sp)
    80200524:	f1f2                	sd	t3,224(sp)
    80200526:	f5f6                	sd	t4,232(sp)
    80200528:	f9fa                	sd	t5,240(sp)
    8020052a:	fdfe                	sd	t6,248(sp)
    8020052c:	14001473          	csrrw	s0,sscratch,zero
    80200530:	100024f3          	csrr	s1,sstatus
    80200534:	14102973          	csrr	s2,sepc
    80200538:	143029f3          	csrr	s3,stval
    8020053c:	14202a73          	csrr	s4,scause
    80200540:	e822                	sd	s0,16(sp)
    80200542:	e226                	sd	s1,256(sp)
    80200544:	e64a                	sd	s2,264(sp)
    80200546:	ea4e                	sd	s3,272(sp)
    80200548:	ee52                	sd	s4,280(sp)
    8020054a:	850a                	mv	a0,sp
    8020054c:	f91ff0ef          	jal	ra,802004dc <trap>

0000000080200550 <__trapret>:
    80200550:	6492                	ld	s1,256(sp)
    80200552:	6932                	ld	s2,264(sp)
    80200554:	10049073          	csrw	sstatus,s1
    80200558:	14191073          	csrw	sepc,s2
    8020055c:	60a2                	ld	ra,8(sp)
    8020055e:	61e2                	ld	gp,24(sp)
    80200560:	7202                	ld	tp,32(sp)
    80200562:	72a2                	ld	t0,40(sp)
    80200564:	7342                	ld	t1,48(sp)
    80200566:	73e2                	ld	t2,56(sp)
    80200568:	6406                	ld	s0,64(sp)
    8020056a:	64a6                	ld	s1,72(sp)
    8020056c:	6546                	ld	a0,80(sp)
    8020056e:	65e6                	ld	a1,88(sp)
    80200570:	7606                	ld	a2,96(sp)
    80200572:	76a6                	ld	a3,104(sp)
    80200574:	7746                	ld	a4,112(sp)
    80200576:	77e6                	ld	a5,120(sp)
    80200578:	680a                	ld	a6,128(sp)
    8020057a:	68aa                	ld	a7,136(sp)
    8020057c:	694a                	ld	s2,144(sp)
    8020057e:	69ea                	ld	s3,152(sp)
    80200580:	7a0a                	ld	s4,160(sp)
    80200582:	7aaa                	ld	s5,168(sp)
    80200584:	7b4a                	ld	s6,176(sp)
    80200586:	7bea                	ld	s7,184(sp)
    80200588:	6c0e                	ld	s8,192(sp)
    8020058a:	6cae                	ld	s9,200(sp)
    8020058c:	6d4e                	ld	s10,208(sp)
    8020058e:	6dee                	ld	s11,216(sp)
    80200590:	7e0e                	ld	t3,224(sp)
    80200592:	7eae                	ld	t4,232(sp)
    80200594:	7f4e                	ld	t5,240(sp)
    80200596:	7fee                	ld	t6,248(sp)
    80200598:	6142                	ld	sp,16(sp)
    8020059a:	10200073          	sret

000000008020059e <strnlen>:
    8020059e:	4781                	li	a5,0
    802005a0:	e589                	bnez	a1,802005aa <strnlen+0xc>
    802005a2:	a811                	j	802005b6 <strnlen+0x18>
    802005a4:	0785                	addi	a5,a5,1
    802005a6:	00f58863          	beq	a1,a5,802005b6 <strnlen+0x18>
    802005aa:	00f50733          	add	a4,a0,a5
    802005ae:	00074703          	lbu	a4,0(a4)
    802005b2:	fb6d                	bnez	a4,802005a4 <strnlen+0x6>
    802005b4:	85be                	mv	a1,a5
    802005b6:	852e                	mv	a0,a1
    802005b8:	8082                	ret

00000000802005ba <memset>:
    802005ba:	ca01                	beqz	a2,802005ca <memset+0x10>
    802005bc:	962a                	add	a2,a2,a0
    802005be:	87aa                	mv	a5,a0
    802005c0:	0785                	addi	a5,a5,1
    802005c2:	feb78fa3          	sb	a1,-1(a5)
    802005c6:	fec79de3          	bne	a5,a2,802005c0 <memset+0x6>
    802005ca:	8082                	ret

00000000802005cc <printnum>:
    802005cc:	02069813          	slli	a6,a3,0x20
    802005d0:	7179                	addi	sp,sp,-48
    802005d2:	02085813          	srli	a6,a6,0x20
    802005d6:	e052                	sd	s4,0(sp)
    802005d8:	03067a33          	remu	s4,a2,a6
    802005dc:	f022                	sd	s0,32(sp)
    802005de:	ec26                	sd	s1,24(sp)
    802005e0:	e84a                	sd	s2,16(sp)
    802005e2:	f406                	sd	ra,40(sp)
    802005e4:	e44e                	sd	s3,8(sp)
    802005e6:	84aa                	mv	s1,a0
    802005e8:	892e                	mv	s2,a1
    802005ea:	fff7041b          	addiw	s0,a4,-1
    802005ee:	2a01                	sext.w	s4,s4
    802005f0:	03067e63          	bgeu	a2,a6,8020062c <printnum+0x60>
    802005f4:	89be                	mv	s3,a5
    802005f6:	00805763          	blez	s0,80200604 <printnum+0x38>
    802005fa:	347d                	addiw	s0,s0,-1
    802005fc:	85ca                	mv	a1,s2
    802005fe:	854e                	mv	a0,s3
    80200600:	9482                	jalr	s1
    80200602:	fc65                	bnez	s0,802005fa <printnum+0x2e>
    80200604:	1a02                	slli	s4,s4,0x20
    80200606:	00001797          	auipc	a5,0x1
    8020060a:	9fa78793          	addi	a5,a5,-1542 # 80201000 <etext+0x5f8>
    8020060e:	020a5a13          	srli	s4,s4,0x20
    80200612:	9a3e                	add	s4,s4,a5
    80200614:	7402                	ld	s0,32(sp)
    80200616:	000a4503          	lbu	a0,0(s4)
    8020061a:	70a2                	ld	ra,40(sp)
    8020061c:	69a2                	ld	s3,8(sp)
    8020061e:	6a02                	ld	s4,0(sp)
    80200620:	85ca                	mv	a1,s2
    80200622:	87a6                	mv	a5,s1
    80200624:	6942                	ld	s2,16(sp)
    80200626:	64e2                	ld	s1,24(sp)
    80200628:	6145                	addi	sp,sp,48
    8020062a:	8782                	jr	a5
    8020062c:	03065633          	divu	a2,a2,a6
    80200630:	8722                	mv	a4,s0
    80200632:	f9bff0ef          	jal	ra,802005cc <printnum>
    80200636:	b7f9                	j	80200604 <printnum+0x38>

0000000080200638 <vprintfmt>:
    80200638:	7119                	addi	sp,sp,-128
    8020063a:	f4a6                	sd	s1,104(sp)
    8020063c:	f0ca                	sd	s2,96(sp)
    8020063e:	ecce                	sd	s3,88(sp)
    80200640:	e8d2                	sd	s4,80(sp)
    80200642:	e4d6                	sd	s5,72(sp)
    80200644:	e0da                	sd	s6,64(sp)
    80200646:	fc5e                	sd	s7,56(sp)
    80200648:	f06a                	sd	s10,32(sp)
    8020064a:	fc86                	sd	ra,120(sp)
    8020064c:	f8a2                	sd	s0,112(sp)
    8020064e:	f862                	sd	s8,48(sp)
    80200650:	f466                	sd	s9,40(sp)
    80200652:	ec6e                	sd	s11,24(sp)
    80200654:	892a                	mv	s2,a0
    80200656:	84ae                	mv	s1,a1
    80200658:	8d32                	mv	s10,a2
    8020065a:	8a36                	mv	s4,a3
    8020065c:	02500993          	li	s3,37
    80200660:	5b7d                	li	s6,-1
    80200662:	00001a97          	auipc	s5,0x1
    80200666:	9d2a8a93          	addi	s5,s5,-1582 # 80201034 <etext+0x62c>
    8020066a:	00001b97          	auipc	s7,0x1
    8020066e:	ba6b8b93          	addi	s7,s7,-1114 # 80201210 <error_string>
    80200672:	000d4503          	lbu	a0,0(s10)
    80200676:	001d0413          	addi	s0,s10,1
    8020067a:	01350a63          	beq	a0,s3,8020068e <vprintfmt+0x56>
    8020067e:	c121                	beqz	a0,802006be <vprintfmt+0x86>
    80200680:	85a6                	mv	a1,s1
    80200682:	0405                	addi	s0,s0,1
    80200684:	9902                	jalr	s2
    80200686:	fff44503          	lbu	a0,-1(s0)
    8020068a:	ff351ae3          	bne	a0,s3,8020067e <vprintfmt+0x46>
    8020068e:	00044603          	lbu	a2,0(s0)
    80200692:	02000793          	li	a5,32
    80200696:	4c81                	li	s9,0
    80200698:	4881                	li	a7,0
    8020069a:	5c7d                	li	s8,-1
    8020069c:	5dfd                	li	s11,-1
    8020069e:	05500513          	li	a0,85
    802006a2:	4825                	li	a6,9
    802006a4:	fdd6059b          	addiw	a1,a2,-35
    802006a8:	0ff5f593          	andi	a1,a1,255
    802006ac:	00140d13          	addi	s10,s0,1
    802006b0:	04b56263          	bltu	a0,a1,802006f4 <vprintfmt+0xbc>
    802006b4:	058a                	slli	a1,a1,0x2
    802006b6:	95d6                	add	a1,a1,s5
    802006b8:	4194                	lw	a3,0(a1)
    802006ba:	96d6                	add	a3,a3,s5
    802006bc:	8682                	jr	a3
    802006be:	70e6                	ld	ra,120(sp)
    802006c0:	7446                	ld	s0,112(sp)
    802006c2:	74a6                	ld	s1,104(sp)
    802006c4:	7906                	ld	s2,96(sp)
    802006c6:	69e6                	ld	s3,88(sp)
    802006c8:	6a46                	ld	s4,80(sp)
    802006ca:	6aa6                	ld	s5,72(sp)
    802006cc:	6b06                	ld	s6,64(sp)
    802006ce:	7be2                	ld	s7,56(sp)
    802006d0:	7c42                	ld	s8,48(sp)
    802006d2:	7ca2                	ld	s9,40(sp)
    802006d4:	7d02                	ld	s10,32(sp)
    802006d6:	6de2                	ld	s11,24(sp)
    802006d8:	6109                	addi	sp,sp,128
    802006da:	8082                	ret
    802006dc:	87b2                	mv	a5,a2
    802006de:	00144603          	lbu	a2,1(s0)
    802006e2:	846a                	mv	s0,s10
    802006e4:	00140d13          	addi	s10,s0,1
    802006e8:	fdd6059b          	addiw	a1,a2,-35
    802006ec:	0ff5f593          	andi	a1,a1,255
    802006f0:	fcb572e3          	bgeu	a0,a1,802006b4 <vprintfmt+0x7c>
    802006f4:	85a6                	mv	a1,s1
    802006f6:	02500513          	li	a0,37
    802006fa:	9902                	jalr	s2
    802006fc:	fff44783          	lbu	a5,-1(s0)
    80200700:	8d22                	mv	s10,s0
    80200702:	f73788e3          	beq	a5,s3,80200672 <vprintfmt+0x3a>
    80200706:	ffed4783          	lbu	a5,-2(s10)
    8020070a:	1d7d                	addi	s10,s10,-1
    8020070c:	ff379de3          	bne	a5,s3,80200706 <vprintfmt+0xce>
    80200710:	b78d                	j	80200672 <vprintfmt+0x3a>
    80200712:	fd060c1b          	addiw	s8,a2,-48
    80200716:	00144603          	lbu	a2,1(s0)
    8020071a:	846a                	mv	s0,s10
    8020071c:	fd06069b          	addiw	a3,a2,-48
    80200720:	0006059b          	sext.w	a1,a2
    80200724:	02d86463          	bltu	a6,a3,8020074c <vprintfmt+0x114>
    80200728:	00144603          	lbu	a2,1(s0)
    8020072c:	002c169b          	slliw	a3,s8,0x2
    80200730:	0186873b          	addw	a4,a3,s8
    80200734:	0017171b          	slliw	a4,a4,0x1
    80200738:	9f2d                	addw	a4,a4,a1
    8020073a:	fd06069b          	addiw	a3,a2,-48
    8020073e:	0405                	addi	s0,s0,1
    80200740:	fd070c1b          	addiw	s8,a4,-48
    80200744:	0006059b          	sext.w	a1,a2
    80200748:	fed870e3          	bgeu	a6,a3,80200728 <vprintfmt+0xf0>
    8020074c:	f40ddce3          	bgez	s11,802006a4 <vprintfmt+0x6c>
    80200750:	8de2                	mv	s11,s8
    80200752:	5c7d                	li	s8,-1
    80200754:	bf81                	j	802006a4 <vprintfmt+0x6c>
    80200756:	fffdc693          	not	a3,s11
    8020075a:	96fd                	srai	a3,a3,0x3f
    8020075c:	00ddfdb3          	and	s11,s11,a3
    80200760:	00144603          	lbu	a2,1(s0)
    80200764:	2d81                	sext.w	s11,s11
    80200766:	846a                	mv	s0,s10
    80200768:	bf35                	j	802006a4 <vprintfmt+0x6c>
    8020076a:	000a2c03          	lw	s8,0(s4)
    8020076e:	00144603          	lbu	a2,1(s0)
    80200772:	0a21                	addi	s4,s4,8
    80200774:	846a                	mv	s0,s10
    80200776:	bfd9                	j	8020074c <vprintfmt+0x114>
    80200778:	4705                	li	a4,1
    8020077a:	008a0593          	addi	a1,s4,8
    8020077e:	01174463          	blt	a4,a7,80200786 <vprintfmt+0x14e>
    80200782:	1a088e63          	beqz	a7,8020093e <vprintfmt+0x306>
    80200786:	000a3603          	ld	a2,0(s4)
    8020078a:	46c1                	li	a3,16
    8020078c:	8a2e                	mv	s4,a1
    8020078e:	2781                	sext.w	a5,a5
    80200790:	876e                	mv	a4,s11
    80200792:	85a6                	mv	a1,s1
    80200794:	854a                	mv	a0,s2
    80200796:	e37ff0ef          	jal	ra,802005cc <printnum>
    8020079a:	bde1                	j	80200672 <vprintfmt+0x3a>
    8020079c:	000a2503          	lw	a0,0(s4)
    802007a0:	85a6                	mv	a1,s1
    802007a2:	0a21                	addi	s4,s4,8
    802007a4:	9902                	jalr	s2
    802007a6:	b5f1                	j	80200672 <vprintfmt+0x3a>
    802007a8:	4705                	li	a4,1
    802007aa:	008a0593          	addi	a1,s4,8
    802007ae:	01174463          	blt	a4,a7,802007b6 <vprintfmt+0x17e>
    802007b2:	18088163          	beqz	a7,80200934 <vprintfmt+0x2fc>
    802007b6:	000a3603          	ld	a2,0(s4)
    802007ba:	46a9                	li	a3,10
    802007bc:	8a2e                	mv	s4,a1
    802007be:	bfc1                	j	8020078e <vprintfmt+0x156>
    802007c0:	00144603          	lbu	a2,1(s0)
    802007c4:	4c85                	li	s9,1
    802007c6:	846a                	mv	s0,s10
    802007c8:	bdf1                	j	802006a4 <vprintfmt+0x6c>
    802007ca:	85a6                	mv	a1,s1
    802007cc:	02500513          	li	a0,37
    802007d0:	9902                	jalr	s2
    802007d2:	b545                	j	80200672 <vprintfmt+0x3a>
    802007d4:	00144603          	lbu	a2,1(s0)
    802007d8:	2885                	addiw	a7,a7,1
    802007da:	846a                	mv	s0,s10
    802007dc:	b5e1                	j	802006a4 <vprintfmt+0x6c>
    802007de:	4705                	li	a4,1
    802007e0:	008a0593          	addi	a1,s4,8
    802007e4:	01174463          	blt	a4,a7,802007ec <vprintfmt+0x1b4>
    802007e8:	14088163          	beqz	a7,8020092a <vprintfmt+0x2f2>
    802007ec:	000a3603          	ld	a2,0(s4)
    802007f0:	46a1                	li	a3,8
    802007f2:	8a2e                	mv	s4,a1
    802007f4:	bf69                	j	8020078e <vprintfmt+0x156>
    802007f6:	03000513          	li	a0,48
    802007fa:	85a6                	mv	a1,s1
    802007fc:	e03e                	sd	a5,0(sp)
    802007fe:	9902                	jalr	s2
    80200800:	85a6                	mv	a1,s1
    80200802:	07800513          	li	a0,120
    80200806:	9902                	jalr	s2
    80200808:	0a21                	addi	s4,s4,8
    8020080a:	6782                	ld	a5,0(sp)
    8020080c:	46c1                	li	a3,16
    8020080e:	ff8a3603          	ld	a2,-8(s4)
    80200812:	bfb5                	j	8020078e <vprintfmt+0x156>
    80200814:	000a3403          	ld	s0,0(s4)
    80200818:	008a0713          	addi	a4,s4,8
    8020081c:	e03a                	sd	a4,0(sp)
    8020081e:	14040263          	beqz	s0,80200962 <vprintfmt+0x32a>
    80200822:	0fb05763          	blez	s11,80200910 <vprintfmt+0x2d8>
    80200826:	02d00693          	li	a3,45
    8020082a:	0cd79163          	bne	a5,a3,802008ec <vprintfmt+0x2b4>
    8020082e:	00044783          	lbu	a5,0(s0)
    80200832:	0007851b          	sext.w	a0,a5
    80200836:	cf85                	beqz	a5,8020086e <vprintfmt+0x236>
    80200838:	00140a13          	addi	s4,s0,1
    8020083c:	05e00413          	li	s0,94
    80200840:	000c4563          	bltz	s8,8020084a <vprintfmt+0x212>
    80200844:	3c7d                	addiw	s8,s8,-1
    80200846:	036c0263          	beq	s8,s6,8020086a <vprintfmt+0x232>
    8020084a:	85a6                	mv	a1,s1
    8020084c:	0e0c8e63          	beqz	s9,80200948 <vprintfmt+0x310>
    80200850:	3781                	addiw	a5,a5,-32
    80200852:	0ef47b63          	bgeu	s0,a5,80200948 <vprintfmt+0x310>
    80200856:	03f00513          	li	a0,63
    8020085a:	9902                	jalr	s2
    8020085c:	000a4783          	lbu	a5,0(s4)
    80200860:	3dfd                	addiw	s11,s11,-1
    80200862:	0a05                	addi	s4,s4,1
    80200864:	0007851b          	sext.w	a0,a5
    80200868:	ffe1                	bnez	a5,80200840 <vprintfmt+0x208>
    8020086a:	01b05963          	blez	s11,8020087c <vprintfmt+0x244>
    8020086e:	3dfd                	addiw	s11,s11,-1
    80200870:	85a6                	mv	a1,s1
    80200872:	02000513          	li	a0,32
    80200876:	9902                	jalr	s2
    80200878:	fe0d9be3          	bnez	s11,8020086e <vprintfmt+0x236>
    8020087c:	6a02                	ld	s4,0(sp)
    8020087e:	bbd5                	j	80200672 <vprintfmt+0x3a>
    80200880:	4705                	li	a4,1
    80200882:	008a0c93          	addi	s9,s4,8
    80200886:	01174463          	blt	a4,a7,8020088e <vprintfmt+0x256>
    8020088a:	08088d63          	beqz	a7,80200924 <vprintfmt+0x2ec>
    8020088e:	000a3403          	ld	s0,0(s4)
    80200892:	0a044d63          	bltz	s0,8020094c <vprintfmt+0x314>
    80200896:	8622                	mv	a2,s0
    80200898:	8a66                	mv	s4,s9
    8020089a:	46a9                	li	a3,10
    8020089c:	bdcd                	j	8020078e <vprintfmt+0x156>
    8020089e:	000a2783          	lw	a5,0(s4)
    802008a2:	4719                	li	a4,6
    802008a4:	0a21                	addi	s4,s4,8
    802008a6:	41f7d69b          	sraiw	a3,a5,0x1f
    802008aa:	8fb5                	xor	a5,a5,a3
    802008ac:	40d786bb          	subw	a3,a5,a3
    802008b0:	02d74163          	blt	a4,a3,802008d2 <vprintfmt+0x29a>
    802008b4:	00369793          	slli	a5,a3,0x3
    802008b8:	97de                	add	a5,a5,s7
    802008ba:	639c                	ld	a5,0(a5)
    802008bc:	cb99                	beqz	a5,802008d2 <vprintfmt+0x29a>
    802008be:	86be                	mv	a3,a5
    802008c0:	00000617          	auipc	a2,0x0
    802008c4:	77060613          	addi	a2,a2,1904 # 80201030 <etext+0x628>
    802008c8:	85a6                	mv	a1,s1
    802008ca:	854a                	mv	a0,s2
    802008cc:	0ce000ef          	jal	ra,8020099a <printfmt>
    802008d0:	b34d                	j	80200672 <vprintfmt+0x3a>
    802008d2:	00000617          	auipc	a2,0x0
    802008d6:	74e60613          	addi	a2,a2,1870 # 80201020 <etext+0x618>
    802008da:	85a6                	mv	a1,s1
    802008dc:	854a                	mv	a0,s2
    802008de:	0bc000ef          	jal	ra,8020099a <printfmt>
    802008e2:	bb41                	j	80200672 <vprintfmt+0x3a>
    802008e4:	00000417          	auipc	s0,0x0
    802008e8:	73440413          	addi	s0,s0,1844 # 80201018 <etext+0x610>
    802008ec:	85e2                	mv	a1,s8
    802008ee:	8522                	mv	a0,s0
    802008f0:	e43e                	sd	a5,8(sp)
    802008f2:	cadff0ef          	jal	ra,8020059e <strnlen>
    802008f6:	40ad8dbb          	subw	s11,s11,a0
    802008fa:	01b05b63          	blez	s11,80200910 <vprintfmt+0x2d8>
    802008fe:	67a2                	ld	a5,8(sp)
    80200900:	00078a1b          	sext.w	s4,a5
    80200904:	3dfd                	addiw	s11,s11,-1
    80200906:	85a6                	mv	a1,s1
    80200908:	8552                	mv	a0,s4
    8020090a:	9902                	jalr	s2
    8020090c:	fe0d9ce3          	bnez	s11,80200904 <vprintfmt+0x2cc>
    80200910:	00044783          	lbu	a5,0(s0)
    80200914:	00140a13          	addi	s4,s0,1
    80200918:	0007851b          	sext.w	a0,a5
    8020091c:	d3a5                	beqz	a5,8020087c <vprintfmt+0x244>
    8020091e:	05e00413          	li	s0,94
    80200922:	bf39                	j	80200840 <vprintfmt+0x208>
    80200924:	000a2403          	lw	s0,0(s4)
    80200928:	b7ad                	j	80200892 <vprintfmt+0x25a>
    8020092a:	000a6603          	lwu	a2,0(s4)
    8020092e:	46a1                	li	a3,8
    80200930:	8a2e                	mv	s4,a1
    80200932:	bdb1                	j	8020078e <vprintfmt+0x156>
    80200934:	000a6603          	lwu	a2,0(s4)
    80200938:	46a9                	li	a3,10
    8020093a:	8a2e                	mv	s4,a1
    8020093c:	bd89                	j	8020078e <vprintfmt+0x156>
    8020093e:	000a6603          	lwu	a2,0(s4)
    80200942:	46c1                	li	a3,16
    80200944:	8a2e                	mv	s4,a1
    80200946:	b5a1                	j	8020078e <vprintfmt+0x156>
    80200948:	9902                	jalr	s2
    8020094a:	bf09                	j	8020085c <vprintfmt+0x224>
    8020094c:	85a6                	mv	a1,s1
    8020094e:	02d00513          	li	a0,45
    80200952:	e03e                	sd	a5,0(sp)
    80200954:	9902                	jalr	s2
    80200956:	6782                	ld	a5,0(sp)
    80200958:	8a66                	mv	s4,s9
    8020095a:	40800633          	neg	a2,s0
    8020095e:	46a9                	li	a3,10
    80200960:	b53d                	j	8020078e <vprintfmt+0x156>
    80200962:	03b05163          	blez	s11,80200984 <vprintfmt+0x34c>
    80200966:	02d00693          	li	a3,45
    8020096a:	f6d79de3          	bne	a5,a3,802008e4 <vprintfmt+0x2ac>
    8020096e:	00000417          	auipc	s0,0x0
    80200972:	6aa40413          	addi	s0,s0,1706 # 80201018 <etext+0x610>
    80200976:	02800793          	li	a5,40
    8020097a:	02800513          	li	a0,40
    8020097e:	00140a13          	addi	s4,s0,1
    80200982:	bd6d                	j	8020083c <vprintfmt+0x204>
    80200984:	00000a17          	auipc	s4,0x0
    80200988:	695a0a13          	addi	s4,s4,1685 # 80201019 <etext+0x611>
    8020098c:	02800513          	li	a0,40
    80200990:	02800793          	li	a5,40
    80200994:	05e00413          	li	s0,94
    80200998:	b565                	j	80200840 <vprintfmt+0x208>

000000008020099a <printfmt>:
    8020099a:	715d                	addi	sp,sp,-80
    8020099c:	02810313          	addi	t1,sp,40
    802009a0:	f436                	sd	a3,40(sp)
    802009a2:	869a                	mv	a3,t1
    802009a4:	ec06                	sd	ra,24(sp)
    802009a6:	f83a                	sd	a4,48(sp)
    802009a8:	fc3e                	sd	a5,56(sp)
    802009aa:	e0c2                	sd	a6,64(sp)
    802009ac:	e4c6                	sd	a7,72(sp)
    802009ae:	e41a                	sd	t1,8(sp)
    802009b0:	c89ff0ef          	jal	ra,80200638 <vprintfmt>
    802009b4:	60e2                	ld	ra,24(sp)
    802009b6:	6161                	addi	sp,sp,80
    802009b8:	8082                	ret

00000000802009ba <sbi_console_putchar>:
    802009ba:	4781                	li	a5,0
    802009bc:	00003717          	auipc	a4,0x3
    802009c0:	64473703          	ld	a4,1604(a4) # 80204000 <SBI_CONSOLE_PUTCHAR>
    802009c4:	88ba                	mv	a7,a4
    802009c6:	852a                	mv	a0,a0
    802009c8:	85be                	mv	a1,a5
    802009ca:	863e                	mv	a2,a5
    802009cc:	00000073          	ecall
    802009d0:	87aa                	mv	a5,a0
    802009d2:	8082                	ret

00000000802009d4 <sbi_set_timer>:
    802009d4:	4781                	li	a5,0
    802009d6:	00003717          	auipc	a4,0x3
    802009da:	64a73703          	ld	a4,1610(a4) # 80204020 <SBI_SET_TIMER>
    802009de:	88ba                	mv	a7,a4
    802009e0:	852a                	mv	a0,a0
    802009e2:	85be                	mv	a1,a5
    802009e4:	863e                	mv	a2,a5
    802009e6:	00000073          	ecall
    802009ea:	87aa                	mv	a5,a0
    802009ec:	8082                	ret

00000000802009ee <sbi_shutdown>:
    802009ee:	4781                	li	a5,0
    802009f0:	00003717          	auipc	a4,0x3
    802009f4:	61873703          	ld	a4,1560(a4) # 80204008 <SBI_SHUTDOWN>
    802009f8:	88ba                	mv	a7,a4
    802009fa:	853e                	mv	a0,a5
    802009fc:	85be                	mv	a1,a5
    802009fe:	863e                	mv	a2,a5
    80200a00:	00000073          	ecall
    80200a04:	87aa                	mv	a5,a0
    80200a06:	8082                	ret
