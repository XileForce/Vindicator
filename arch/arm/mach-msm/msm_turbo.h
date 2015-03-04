/* arch/arm/mach-msm/msm_turbo.c
 *
 * MSM architecture cpufreq turbo boost driver
 *
 * Copyright (c) 2012-2014, Paul Reioux. All rights reserved.
 * Author: Paul Reioux <reioux@gmail.com>
 *
 * This software is licensed under the terms of the GNU General Public
 * License version 2, as published by the Free Software Foundation, and
 * may be copied, distributed, and modified under those terms.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 */

#include <linux/kernel.h>
#include <linux/cpufreq.h>
#include <linux/module.h>
#include <linux/cpumask.h>

#define DEFAULT_MIN_FREQUENCY		35800
#ifdef CONFIG_TURBO_BOOST
#ifdef CONFIG_OC_ULTIMATE
#define STOCK_CPU_MAX_SPEED	1512000
#else
#define STOCK_CPU_MAX_SPEED	1728000
#endif
#endif

int msm_turbo(int cpufreq)
{
	if (num_online_cpus() > 2) {
		if (cpufreq > STOCK_CPU_MAX_SPEED)
		for(int i=0;i<4;i++){	
cpufreq_set_freq(STOCK_CPU_MAX_SPEED, DEFAULT_MIN_FREQUENCY, i);
}
        }
	return cpufreq;
}

static int msm_turbo_boost_init(void)
{
	return 0;
}

static void msm_turbo_boost_exit(void)
{

}

module_init(msm_turbo_boost_init);
module_exit(msm_turbo_boost_exit);

MODULE_LICENSE("GPL V2");
MODULE_AUTHOR("Paul Reioux <reioux@gmail.com>");
MODULE_DESCRIPTION("MSM turbo boost module");
