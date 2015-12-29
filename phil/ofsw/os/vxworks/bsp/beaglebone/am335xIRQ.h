/* am335xIRQ.h - Interrupt IRQ definitions for AM335X */

/*
 * Copyright (c) 2012 Wind River Systems, Inc.
 *
 * The right to copy, distribute, modify or otherwise make use
 * of this software may be licensed only pursuant to the terms
 * of an applicable Wind River license agreement.
 */

/*
modification history
--------------------
01b,12oct12,my_  add timer capture event definitions
01a,12may12,my_  created from ti_dm81xx_evm BSP 01e.
*/

/*
This file contains definitions for mapping Interrupts on the TI AM335X
board.

See also AM335x ARM Cortex-A8 Microprocessors (MPUs) Technical Reference Manual.
*/

#ifndef __INCam335xIRQh
#define __INCam335xIRQh

#ifdef __cplusplus
extern "C" {
#endif

/* Interrupt proirity */

#define AM335XINT_PRI_UART_0          3 /* UART 1 */
#define AM335XINT_PRI_UART_1          3 /* UART 2 */
#define AM335XINT_PRI_UART_2          3 /* UART 3 */
#define AM335XINT_PRI_TIMER_2         0 /* timer 2 */
#define AM335XINT_PRI_TIMER_3         8 /* timer 3 */
#define AM335XINT_PRI_TIMER_4         6 /* timer 4 */
#define AM335XINT_PRI_TIMER_5         8 /* timer 5 */
#define AM335XINT_PRI_TIMER_6         8 /* timer 6 */
#define AM335XINT_PRI_GPIO0B          6 /* gpio 0b */
#define AM335XINT_PRI_ENET            4 /* ethernet interrupt(GPIO-E) */
#define AM335XINT_PRI_MAIL_U0_MPU     9 /* mailbox interrupt */
#define AM335XINT_PRI_IVA2_MMU        9 /* iva2 subsystem interrupt */
#define AM335XINT_PRI_MHCI            10 /* mhci */
#define AM335XINT_PRI_EHCI            7 /* ehci */
#define AM335XINT_PRI_SGX             7 /* SGX */
#define AM335XINT_PRI_DSS             7 /* DSS */
#define AM335XINT_PRI_NIRQ            7 /* NIRQ */
#define AM335XINT_PRI_MMC             8 /* MMC1 */
#define AM335XINT_PRI_SATA            8 /* SATA */
#define AM335XINT_PRI_EDMACOMP        5 /* EDMA Completion */
#define AM335XINT_PRI_EDMAMAPERR      6 /* EDMA memory protection */
#define AM335XINT_PRI_EDMAERRINT      6 /* EDMA error */
#define AM335XINT_PRI_MASP2           6 /* MCASP2 */
#define AM335XINT_PRI_I2C             6 /* I2C */
#define AM335XINT_PRI_RTC             1 /* I2C */

/* IRQ numbers */

#define AM335XM_IRQ_0 0
#define AM335XM_IRQ_1 1
#define AM335XM_IRQ_2 2
#define AM335XM_IRQ_3 3
#define AM335XM_IRQ_4 4
#define AM335XM_IRQ_5 5
#define AM335XM_IRQ_6 6
#define AM335XM_IRQ_7 7
#define AM335XM_IRQ_8 8
#define AM335XM_IRQ_9 9
#define AM335XM_IRQ_10 10
#define AM335XM_IRQ_11 11
#define AM335XM_IRQ_12 12
#define AM335XM_IRQ_13 13
#define AM335XM_IRQ_14 14
#define AM335XM_IRQ_15 15
#define AM335XM_IRQ_16 16
#define AM335XM_IRQ_17 17
#define AM335XM_IRQ_18 18
#define AM335XM_IRQ_19 19
#define AM335XM_IRQ_20 20
#define AM335XM_IRQ_21 21
#define AM335XM_IRQ_22 22
#define AM335XM_IRQ_23 23
#define AM335XM_IRQ_24 24
#define AM335XM_IRQ_25 25
#define AM335XM_IRQ_26 26
#define AM335XM_IRQ_27 27
#define AM335XM_IRQ_28 28
#define AM335XM_IRQ_29 29
#define AM335XM_IRQ_30 30
#define AM335XM_IRQ_31 31
#define AM335XM_IRQ_32 32
#define AM335XM_IRQ_33 33
#define AM335XM_IRQ_34 34
#define AM335XM_IRQ_35 35
#define AM335XM_IRQ_36 36
#define AM335XM_IRQ_37 37
#define AM335XM_IRQ_38 38
#define AM335XM_IRQ_39 39
#define AM335XM_IRQ_40 40
#define AM335XM_IRQ_41 41
#define AM335XM_IRQ_42 42
#define AM335XM_IRQ_43 43
#define AM335XM_IRQ_44 44
#define AM335XM_IRQ_45 45
#define AM335XM_IRQ_46 46
#define AM335XM_IRQ_47 47
#define AM335XM_IRQ_48 48
#define AM335XM_IRQ_49 49
#define AM335XM_IRQ_50 50
#define AM335XM_IRQ_51 51
#define AM335XM_IRQ_52 52
#define AM335XM_IRQ_53 53
#define AM335XM_IRQ_54 54
#define AM335XM_IRQ_55 55
#define AM335XM_IRQ_56 56
#define AM335XM_IRQ_57 57
#define AM335XM_IRQ_58 58
#define AM335XM_IRQ_59 59
#define AM335XM_IRQ_60 60
#define AM335XM_IRQ_61 61
#define AM335XM_IRQ_62 62
#define AM335XM_IRQ_63 63
#define AM335XM_IRQ_64 64
#define AM335XM_IRQ_65 65
#define AM335XM_IRQ_66 66
#define AM335XM_IRQ_67 67
#define AM335XM_IRQ_68 68
#define AM335XM_IRQ_69 69
#define AM335XM_IRQ_70 70
#define AM335XM_IRQ_71 71
#define AM335XM_IRQ_72 72
#define AM335XM_IRQ_73 73
#define AM335XM_IRQ_74 74
#define AM335XM_IRQ_75 75
#define AM335XM_IRQ_76 76
#define AM335XM_IRQ_77 77
#define AM335XM_IRQ_78 78
#define AM335XM_IRQ_79 79
#define AM335XM_IRQ_80 80
#define AM335XM_IRQ_81 81
#define AM335XM_IRQ_82 82
#define AM335XM_IRQ_83 83
#define AM335XM_IRQ_84 84
#define AM335XM_IRQ_85 85
#define AM335XM_IRQ_86 86
#define AM335XM_IRQ_87 87
#define AM335XM_IRQ_88 88
#define AM335XM_IRQ_89 89
#define AM335XM_IRQ_90 90
#define AM335XM_IRQ_91 91
#define AM335XM_IRQ_92 92
#define AM335XM_IRQ_93 93
#define AM335XM_IRQ_94 94
#define AM335XM_IRQ_95 95
#define AM335XM_IRQ_96 96
#define AM335XM_IRQ_97 97
#define AM335XM_IRQ_98 98
#define AM335XM_IRQ_99 99
#define AM335XM_IRQ_100 100
#define AM335XM_IRQ_101 101
#define AM335XM_IRQ_102 102
#define AM335XM_IRQ_103 103
#define AM335XM_IRQ_104 104
#define AM335XM_IRQ_105 105
#define AM335XM_IRQ_106 106
#define AM335XM_IRQ_107 107
#define AM335XM_IRQ_108 108
#define AM335XM_IRQ_109 109
#define AM335XM_IRQ_110 110
#define AM335XM_IRQ_111 111
#define AM335XM_IRQ_112 112
#define AM335XM_IRQ_113 113
#define AM335XM_IRQ_114 114
#define AM335XM_IRQ_115 115
#define AM335XM_IRQ_116 116
#define AM335XM_IRQ_117 117
#define AM335XM_IRQ_118 118
#define AM335XM_IRQ_119 119
#define AM335XM_IRQ_120 120
#define AM335XM_IRQ_121 121
#define AM335XM_IRQ_122 122
#define AM335XM_IRQ_123 123
#define AM335XM_IRQ_124 124
#define AM335XM_IRQ_125 125
#define AM335XM_IRQ_126 126
#define AM335XM_IRQ_127 127

/* Interrupt Mappings to the MPU Subsystem */

#define AM335X_EMUINT        AM335XM_IRQ_0    /* MPU emulation(2) */
#define AM335X_COMMTX        AM335XM_IRQ_1    /* MPU emulation(2) */
#define AM335X_COMMRX        AM335XM_IRQ_2    /* MPU emulation(2) */
#define AM335X_BENCH         AM335XM_IRQ_3    /* MPU emulation(2) */
#define AM335X_ELM_IRQ       AM335XM_IRQ_4    /* ELM */

#define AM335X_NMI           AM335XM_IRQ_7    /* NMIn Pin */

#define AM335X_L3DEBUG       AM335XM_IRQ_9    /* L3 Interconnect */
#define AM335X_L3APPINT      AM335XM_IRQ_10   /* L3 Interconnect */
#define AM335X_EDMACOMPINT   AM335XM_IRQ_12   /* EDMA CC Completion */
#define AM335X_EDMAMAPERR    AM335XM_IRQ_13   /* EDMA Memory Protection Error */
#define AM335X_EDMAERRINT    AM335XM_IRQ_14   /* EDMA CC Error */
#define AM335X_WDTINT0       AM335XM_IRQ_15   /* Watchdog Timer 0 */
#define AM335X_SATAINT       AM335XM_IRQ_16   /* SATA */
#define AM335X_USBSSINT      AM335XM_IRQ_17   /* USB Subsystem */
#define AM335X_USBINT0       AM335XM_IRQ_18   /* USB0 */
#define AM335X_USBINT1       AM335XM_IRQ_19   /* USB1 */

#define AM335X_SDINT1        AM335XM_IRQ_28   /* MMC/SD1 */
#define AM335X_SDINT2        AM335XM_IRQ_29   /* MMC/SD2 */
#define AM335X_I2CINT2       AM335XM_IRQ_30   /* I2C2 */
#define AM335X_GPIOINT2A     AM335XM_IRQ_32   /* GPIO2 A */
#define AM335X_GPIOINT2B     AM335XM_IRQ_33   /* GPIO2 B */
#define AM335X_USBWAKEUP     AM335XM_IRQ_34   /* USB Subsystem Wakeup */
#define AM335X_PCIEWAKEUP    AM335XM_IRQ_35   /* PCIe Wakeup */
#define AM335X_DSSINT        AM335XM_IRQ_36   /* HDVPSS */
#define AM335X_SGXINT        AM335XM_IRQ_37   /* SGX530 */
#define AM335X_HDMINT        AM335XM_IRQ_38   /* HDMI */
#define AM335X_ISS_IRQ_5     AM335XM_IRQ_39   /* ISS */
#define AM335X_3PGSWRXTHR0   AM335XM_IRQ_40   /* EMAC Switch RX Threshold */
#define AM335X_3PGSWRXINT0   AM335XM_IRQ_41   /* EMAC Switch Receive */
#define AM335X_3PGSWTXINT0   AM335XM_IRQ_42   /* EMAC Switch Transmit */
#define AM335X_3PGSWMISC0    AM335XM_IRQ_43   /* EMAC Switch Miscellaneous */
#define AM335X_UARTINT3      AM335XM_IRQ_44   /* UART3 */
#define AM335X_UARTINT4      AM335XM_IRQ_45   /* UART4 */
#define AM335X_UARTINT5      AM335XM_IRQ_46   /* UART5 */

#define AM335X_DCAN0_INT0    AM335XM_IRQ_52   /* DCAN0 */
#define AM335X_DCAN0_INT1    AM335XM_IRQ_53   /* DCAN0 */
#define AM335X_DCAN0_PARITY  AM335XM_IRQ_54   /* DCAN0 Parity */
#define AM335X_DCAN1_INT0    AM335XM_IRQ_55   /* DCAN1 */
#define AM335X_DCAN1_INT1    AM335XM_IRQ_56   /* DCAN1 */
#define AM335X_DCAN1_PARITY  AM335XM_IRQ_57   /* DCAN1 Parity */

#define AM335X_GPIOINT3A     AM335XM_IRQ_62   /* GPIO3 */
#define AM335X_GPIOINT3B     AM335XM_IRQ_63   /* GPIO3 */
#define AM335X_SDINT0        AM335XM_IRQ_64   /* MMC/SD0 */
#define AM335X_SPIINT0       AM335XM_IRQ_65   /* SPI0 */

#define AM335X_TINT0         AM335XM_IRQ_66   /* TIMER0 */
#define AM335X_TINT1         AM335XM_IRQ_67   /* TIMER1 */
#define AM335X_TINT2         AM335XM_IRQ_68   /* TIMER2 */
#define AM335X_TINT3         AM335XM_IRQ_69   /* TIMER3 */
#define AM335X_I2CINT0       AM335XM_IRQ_70   /* I2C0 */
#define AM335X_I2CINT1       AM335XM_IRQ_71   /* I2C1 */
#define AM335X_UARTINT0      AM335XM_IRQ_72   /* UART0 */
#define AM335X_UARTINT1      AM335XM_IRQ_73   /* UART1 */
#define AM335X_UARTINT2      AM335XM_IRQ_74   /* UART2 */
#define AM335X_RTCINT        AM335XM_IRQ_75   /* RTC */
#define AM335X_RTCALARMINT   AM335XM_IRQ_76   /* RTC Alarm */
#define AM335X_MBINT         AM335XM_IRQ_77   /* Mailbox */

#define AM335X_MCATXINT0     AM335XM_IRQ_80   /* McASP0 Transmit */
#define AM335X_MCARXINT0     AM335XM_IRQ_81   /* McASP0 Receive */
#define AM335X_MCATXINT1     AM335XM_IRQ_82   /* McASP1 Transmit */
#define AM335X_MCARXINT1     AM335XM_IRQ_83   /* McASP1 Receive */
#define AM335X_MCATXINT2     AM335XM_IRQ_84   /* McASP2 Transmit */
#define AM335X_MCARXINT2     AM335XM_IRQ_85   /* McASP2 Receive */
#define AM335X_MCBSPINT      AM335XM_IRQ_86   /* McBSP */

#define AM335X_TINT4         AM335XM_IRQ_92   /* TIMER4 */
#define AM335X_TINT5         AM335XM_IRQ_93   /* TIMER5 */
#define AM335X_TINT6         AM335XM_IRQ_94   /* TIMER6 */
#define AM335X_TINT7         AM335XM_IRQ_95   /* TIMER7 */
#define AM335X_GPIOINT0A     AM335XM_IRQ_96   /* GPIO0 */
#define AM335X_GPIOINT0B     AM335XM_IRQ_97   /* GPIO0 */
#define AM335X_GPIOINT1A     AM335XM_IRQ_98   /* GPIO1 */
#define AM335X_GPIOINT1B     AM335XM_IRQ_99   /* GPIO1 */
#define AM335X_GPMCINT       AM335XM_IRQ_100   /* GPMC */
#define AM335X_DDRERR0       AM335XM_IRQ_101   /* DDR0 */
#define AM335X_DDRERR1       AM335XM_IRQ_102   /* DDR1 */

#define AM335X_MCATXINT3     AM335XM_IRQ_105   /* McASP3 Transmit */
#define AM335X_MCARXINT3     AM335XM_IRQ_106   /* McASP3 Receive */

#define AM335X_MCATXINT4     AM335XM_IRQ_108   /* McASP4 Transmit */
#define AM335X_MCARXINT4     AM335XM_IRQ_109   /* McASP4 Receive */
#define AM335X_MCATXINT5     AM335XM_IRQ_110   /* McASP5 Transmit */
#define AM335X_MCARXINT5     AM335XM_IRQ_111   /* McASP5 Receive */

#define AM335X_TCERRINT0     AM335XM_IRQ_112   /* EDMA TC 0 Error */
#define AM335X_TCERRINT1     AM335XM_IRQ_113   /* EDMA TC 1 Error */
#define AM335X_TCERRINT2     AM335XM_IRQ_114   /* EDMA TC 2 Error */
#define AM335X_TCERRINT3     AM335XM_IRQ_115   /* EDMA TC 3 Error */

#define AM335X_SMRFLX_ARM    AM335XM_IRQ_120   /* SmartReflex ARM Domain */
#define AM335X_SMRFLX_CORE   AM335XM_IRQ_121   /* SmartReflex CORE Domain */

#define AM335X_MMUINT        AM335XM_IRQ_122   /* System MMU */
#define AM335X_MCMMUINT      AM335XM_IRQ_123   /* Media Controller */
#define AM335X_DMMINT        AM335XM_IRQ_124   /* DMM */
#define AM335X_SPIINT1       AM335XM_IRQ_125   /* SPI1 */
#define AM335X_SPIINT2       AM335XM_IRQ_126   /* SPI2 */
#define AM335X_SPIINT3       AM335XM_IRQ_127   /* SPI3 */

#define AM335X_IRQ_NUMS      128
#define AM335X_LVL_NUMS      8

/* timer capture event */

#define PWM_EVENT_UART0        1
#define PWM_EVENT_UART1        2
#define PWM_EVENT_UART2        3
#define PWM_EVENT_UART3        4
#define PWM_EVENT_UART4        5
#define PWM_EVENT_UART5        6
#define PWM_EVENT_3PGSWRXTHR0  7
#define PWM_EVENT_3PGSWRXINT0  8
#define PWM_EVENT_3PGSWTXINT0  9
#define PWM_EVENT_3PGSWMISC0   10
#define PWM_EVENT_MCATXINT0    11
#define PWM_EVENT_MCARXINT0    12
#define PWM_EVENT_MCATXINT1    13
#define PWM_EVENT_MCARXINT1    14
#define PWM_EVENT_GPIOINT0A    17
#define PWM_EVENT_GPIOINT0B    18
#define PWM_EVENT_GPIOINT1A    19
#define PWM_EVENT_GPIOINT1B    20
#define PWM_EVENT_GPIOINT2A    21
#define PWM_EVENT_GPIOINT2B    22
#define PWM_EVENT_GPIOINT3A    23
#define PWM_EVENT_GPIOINT3B    24
#define PWM_EVENT_DCAN0_INT0   25
#define PWM_EVENT_DCAN0_INT1   26
#define PWM_EVENT_DCAN0_PARITY 27
#define PWM_EVENT_DCAN1_INT0   28
#define PWM_EVENT_DCAN1_INT1   29
#define PWM_EVENT_DCAN1_PARITY 30

#ifdef __cplusplus
}
#endif

#endif /* __INCam335xIRQh */
