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
#define STOCK_CPU_MAX_SPEED	1574400
#endif

int msm_turbo(int cpufreq){
struct *cpufreq_policy policy;
cpufreq_get_policy(&policy, 0);
struct *cpufreq_policy policy1;
cpufreq_get_policy(&policy1, 1);
struct *cpufreq_policy policy2;
cpufreq_get_policy(&policy2, 2);
struct *cpufreq_policy policy3;
cpufreq_get_policy(&policy3, 3);


	if (num_online_cpus() > 2) {
		if (policy->cur > STOCK_CPU_MAX_SPEED)
		policy->cur=STOCK_CPU_MAX_SPEED;
cpufreq_update_policy(0);
policy1->cur=STOCK_CPU_MAX_SPEED;
cpufreq_update_policy(1);
policy2->cur=STOCK_CPU_MAX_SPEED;
cpufreq_update_policy(2);
policy3->cur=STOCK_CPU_MAX_SPEED;
cpufreq_update_policy(3);


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
