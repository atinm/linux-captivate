/* linux/arch/arm/mach-s5pc100/include/mach/tick.h
 *
 * Copyright 2008 Openmoko, Inc.
 * Copyright 2008 Simtec Electronics
 *	http://armlinux.simtec.co.uk/
 *	Ben Dooks <ben@simtec.co.uk>
 *
 * S5PC1XX - Timer tick support definitions
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
*/

#ifndef __ASM_ARCH_TICK_H
#define __ASM_ARCH_TICK_H __FILE__

/* note, the timer interrutps turn up in 2 places, the vic and then
 * the timer block. We take the VIC as the base at the moment.
 */
static inline u32 s5pc1xx_ostimer_pending(void)
{
	u32 pend = __raw_readl(S3C_VA_VIC0 + VIC_RAW_STATUS);
	return pend & 1 << (IRQ_SYSTIMER - S5PC1XX_IRQ_VIC0(0));
}

#define TICK_MAX	(0xffffffff)

#endif /* __ASM_ARCH_6400_TICK_H */
