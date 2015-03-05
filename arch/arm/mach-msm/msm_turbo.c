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
#include <linux/init.h>
#include <linux/fs.h>
#include <linux/slab.h>
#include <linux/workqueue.h>


#define DEFAULT_MIN_FREQUENCY		35800
#ifdef CONFIG_TURBO_BOOST
#define STOCK_CPU_MAX_SPEED	1574400
#endif

struct my_attr {
    struct attribute attr;
    int value;
};
int on=0;
static struct my_attr my_first = {
    .attr.name="turbo_boost",
    .attr.mode = 0644,
    .value = 0,
};

static struct attribute * myattr[] = {
    &my_first.attr,
    NULL
};

static void turboboost_work_handler(struct work_struct *w);
 
static struct workqueue_struct *wq = 0;
static DECLARE_WORK(turboboost_work, turboboost_work_handler);
static unsigned long onesec;
 
static void
turboboost_work_handler(struct work_struct *w)
{
if(on==1){
struct cpufreq_policy policy;
cpufreq_get_policy(&policy, 0);
struct cpufreq_policy policy1;
cpufreq_get_policy(&policy1, 1);
struct cpufreq_policy policy2;
cpufreq_get_policy(&policy2, 2);
struct cpufreq_policy policy3;
cpufreq_get_policy(&policy3, 3);

        while(num_online_cpus() > 2) {
		if (cpufreq_quick_get(0) > STOCK_CPU_MAX_SPEED)
		policy->cur=STOCK_CPU_MAX_SPEED;
policy->cur=STOCK_CPU_MAX_SPEED;
cpufreq_update_policy(0);
policy1->cur=STOCK_CPU_MAX_SPEED;
cpufreq_update_policy(1);
policy2->cur=STOCK_CPU_MAX_SPEED;
cpufreq_update_policy(2);
policy3->cur=STOCK_CPU_MAX_SPEED;
cpufreq_update_policy(3);

        }
	}
}

static struct sysfs_ops myops = {
    .show = default_show,
    .store = default_store,
};

static struct kobj_type mytype = {
    .sysfs_ops = &myops,
    .default_attrs = myattr,
};

static ssize_t default_show(struct kobject *kobj, struct attribute *attr,
        char *buf)
{
    struct my_attr *a = container_of(attr, struct my_attr, attr);
    return scnprintf(buf, PAGE_SIZE, "%d\n", a->value);
}

static ssize_t default_store(struct kobject *kobj, struct attribute *attr,
        const char *buf, size_t len)
{
    struct my_attr *a = container_of(attr, struct my_attr, attr);
    sscanf(buf, "%d", &a->value);
on=&a->value;
    return sizeof(int);
}


struct kobject *mykobj;

static int msm_turbo_boost_init(void)
{
 mykobj = kzalloc(sizeof(*mykobj), GFP_KERNEL);
    if (mykobj) {
        kobject_init(mykobj, &mytype);
        if (kobject_add(mykobj, NULL, "%s", "turbo_boost")) {
             err = -1;
             printk("Sysfs creation failed\n");
             kobject_put(mykobj);
             mykobj = NULL;
        }
}
        if (!wq)
                wq = create_singlethread_workqueue("msm_turbo");
        if (wq)
                queue_work(wc, &turboboost_work);
 

	return 0;
}

static void msm_turbo_boost_exit(void)
{
if (wq)
                destroy_workqueue(wq);
}

module_init(msm_turbo_boost_init);
module_exit(msm_turbo_boost_exit);

MODULE_LICENSE("GPL V2");
MODULE_AUTHOR("Paul Reioux <reioux@gmail.com>");
MODULE_DESCRIPTION("MSM turbo boost module");
