#!/vendor/bin/sh
# Copyright (c) 2014-2017, The Linux Foundation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of The Linux Foundation nor
#       the names of its contributors may be used to endorse or promote
#       products derived from this software without specific prior written
#       permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NON-INFRINGEMENT ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

enable=`getprop persist.service.crash.enable`

enable_trace_events()
{
    # rtb filter
    echo 0x237 > /sys/module/msm_rtb/parameters/filter

    # ftrace
    echo 1 > /sys/kernel/debug/tracing/tracing_on

    #enble FTRACE for softirq events
    echo 1 > /sys/kernel/debug/tracing/events/irq/enable
    echo 1 > /sys/kernel/debug/tracing/events/irq/filter
    echo 1 > /sys/kernel/debug/tracing/events/irq/softirq_entry/enable
    echo 1 > /sys/kernel/debug/tracing/events/irq/softirq_exit/enable
    echo 1 > /sys/kernel/debug/tracing/events/irq/softirq_raise/enable
    echo 1 > /sys/kernel/debug/tracing/events/irq/irq_handler_entry/enable

    #enble FTRACE for Workqueue events
    echo 1 > /sys/kernel/debug/tracing/events/workqueue/enable
    echo 1 > /sys/kernel/debug/tracing/events/workqueue/filter
    echo 1 > /sys/kernel/debug/tracing/events/workqueue/workqueue_activate_work/enable
    echo 1 > /sys/kernel/debug/tracing/events/workqueue/workqueue_execute_end/enable
    echo 1 > /sys/kernel/debug/tracing/events/workqueue/workqueue_execute_start/enable
    echo 1 > /sys/kernel/debug/tracing/events/workqueue/workqueue_queue_work/enable

    # schedular
    echo 1 > /sys/kernel/debug/tracing/events/sched/sched_cpu_hotplug/enable
    echo 1 > /sys/kernel/debug/tracing/events/sched/sched_cpu_load/enable
    echo 1 > /sys/kernel/debug/tracing/events/sched/sched_enq_deq_task/enable
    echo 1 > /sys/kernel/debug/tracing/events/sched/sched_load_balance/enable
    echo 1 > /sys/kernel/debug/tracing/events/sched/sched_migrate_task/enable
    echo 1 > /sys/kernel/debug/tracing/events/sched/sched_switch/enable
    echo 1 > /sys/kernel/debug/tracing/events/sched/sched_task_load/enable
    echo 1 > /sys/kernel/debug/tracing/events/sched/sched_wakeup/enable
    echo 1 > /sys/kernel/debug/tracing/events/sched/sched_wakeup_new/enable

    # power
    echo 1 > /sys/kernel/debug/tracing/events/msm_low_power/enable

    # scm call
    echo 1 > /sys/kernel/debug/tracing/events/scm/scm_call_start/enable
    echo 1 > /sys/kernel/debug/tracing/events/scm/scm_call_end/enable

    # size
    echo 16384 > /sys/kernel/debug/tracing/buffer_size_kb
}

disable_trace_events()
{
    # rtb filter
    echo 0 > /sys/module/msm_rtb/parameters/filter

    # ftrace
    echo 0 > /sys/kernel/debug/tracing/tracing_on

    # size
    echo 0 > /sys/kernel/debug/tracing/buffer_size_kb

    # free buffer
    echo > /sys/kernel/debug/tracing/free_buffer
}

# Function SDM845 DCC configuration
enable_sdm845_dcc_config()
{
    DCC_PATH="/sys/bus/platform/devices/10a2000.dcc_v2"
    soc_version=`cat /sys/devices/soc0/revision`
    soc_version=${soc_version/./}

    if [ ! -d $DCC_PATH ]; then
        echo "DCC does not exist on this build."
        return
    fi

    echo 0 > $DCC_PATH/enable
    echo cap > $DCC_PATH/func_type
    echo sram > $DCC_PATH/data_sink
    echo 1 > $DCC_PATH/config_reset
    echo 2 > $DCC_PATH/curr_list

    echo 0x00151004 1 > $DCC_PATH/config
    echo 0x1 0x1 > $DCC_PATH/rd_mod_wr
    echo 0x00151004 1 > $DCC_PATH/config
    echo 0x013E7E00 124 > $DCC_PATH/config

    #Use for address change between V1 vs V2
    if [ "$soc_version" -eq 20 ]
    then
        #V2
        echo 0x17D41920  > $DCC_PATH/config
        echo 0x17D43920  > $DCC_PATH/config
        echo 0x17D46120  > $DCC_PATH/config
    else
        #V1
        echo 0x17D41780 1 > $DCC_PATH/config
        echo 0x17D43780 1 > $DCC_PATH/config
        echo 0x17D45F80 1 > $DCC_PATH/config
    fi

    echo 0x01740300 6 > $DCC_PATH/config
    echo 0x01620500 4 > $DCC_PATH/config
    echo 0x01620700 5 > $DCC_PATH/config
    echo 0x7840000 1 > $DCC_PATH/config
    echo 0x7842500 1 > $DCC_PATH/config
    echo 0x7842504 1 > $DCC_PATH/config
    echo 0x7841010 12 > $DCC_PATH/config
    echo 0x7842000 16 > $DCC_PATH/config
    echo 7 > $DCC_PATH/loop
    echo 0x7841000 1 > $DCC_PATH/config
    echo 1 > $DCC_PATH/loop
    echo 165 > $DCC_PATH/loop
    echo 0x7841008 1 > $DCC_PATH/config
    echo 0x784100C 1 > $DCC_PATH/config
    echo 1 > $DCC_PATH/loop

    echo 0x17DC3A84 2 > $DCC_PATH/config
    echo 0x17DB3A84 1 > $DCC_PATH/config
    echo 0x17840C18 1 > $DCC_PATH/config
    echo 0x17830C18 1 > $DCC_PATH/config
    echo 0x17D20000 1 > $DCC_PATH/config
    echo 0x17D2000C 1 > $DCC_PATH/config
    echo 0x17D20018 1 > $DCC_PATH/config

    echo 0x17E00024 1 > $DCC_PATH/config
    echo 0x17E00040 1 > $DCC_PATH/config
    echo 0x17E10024 1 > $DCC_PATH/config
    echo 0x17E10040 1 > $DCC_PATH/config
    echo 0x17E20024 1 > $DCC_PATH/config
    echo 0x17E20040 1 > $DCC_PATH/config
    echo 0x17E30024 1 > $DCC_PATH/config
    echo 0x17E30040 1 > $DCC_PATH/config
    echo 0x17E40024 1 > $DCC_PATH/config
    echo 0x17E40040 1 > $DCC_PATH/config
    echo 0x17E50024 1 > $DCC_PATH/config
    echo 0x17E50040 1 > $DCC_PATH/config
    echo 0x17E60024 1 > $DCC_PATH/config
    echo 0x17E60040 1 > $DCC_PATH/config
    echo 0x17E70024 1 > $DCC_PATH/config
    echo 0x17E70040 1 > $DCC_PATH/config
    echo 0x17810024 1 > $DCC_PATH/config
    echo 0x17810040 1 > $DCC_PATH/config
    echo 0x17810104 1 > $DCC_PATH/config
    echo 0x17810118 1 > $DCC_PATH/config
    echo 0x17810128 1 > $DCC_PATH/config
    echo 0x178100F4 1 > $DCC_PATH/config
    echo 0x179C0400 1 > $DCC_PATH/config
    echo 0x179C0404 1 > $DCC_PATH/config
    echo 0x179C0408 1 > $DCC_PATH/config
    echo 0x179C0038 1 > $DCC_PATH/config
    echo 0x179C0040 1 > $DCC_PATH/config
    echo 0x179C0048 1 > $DCC_PATH/config
    echo 0x0B201020 1 > $DCC_PATH/config
    echo 0x0B201024 1 > $DCC_PATH/config
    echo 0x01301000 1 > $DCC_PATH/config
    echo 0x01301004 1 > $DCC_PATH/config

    echo 0x1781012C 4 > $DCC_PATH/config
    echo 0x17E00048 2 > $DCC_PATH/config
    echo 0x17E10048 2 > $DCC_PATH/config
    echo 0x17E20048 2 > $DCC_PATH/config
    echo 0x17E30048 2 > $DCC_PATH/config
    echo 0x17E40048 2 > $DCC_PATH/config
    echo 0x17E50048 2 > $DCC_PATH/config
    echo 0x17E60048 2 > $DCC_PATH/config
    echo 0x17E70048 2 > $DCC_PATH/config
    echo 0x17810048 2 > $DCC_PATH/config
    echo 0x17990044 1 > $DCC_PATH/config

    echo 0x179E0D14 1 > $DCC_PATH/config
    echo 0x179E0D18 1 > $DCC_PATH/config
    echo 0x179E0D1C 1 > $DCC_PATH/config
    echo 0x179E0D30 1 > $DCC_PATH/config
    echo 0x179E0D34 1 > $DCC_PATH/config
    echo 0x179E0D38 1 > $DCC_PATH/config
    echo 0x179E0D3C 1 > $DCC_PATH/config
    echo 0x179E0D44 1 > $DCC_PATH/config
    echo 0x179E0D48 1 > $DCC_PATH/config
    echo 0x179E0D4C 1 > $DCC_PATH/config
    echo 0x179E0D50 1 > $DCC_PATH/config
    echo 0x179E0D58 1 > $DCC_PATH/config
    echo 0x179E0D5C 1 > $DCC_PATH/config
    echo 0x179E0D60 1 > $DCC_PATH/config
    echo 0x179E0D64 1 > $DCC_PATH/config
    echo 0x179E0FB4 1 > $DCC_PATH/config
    echo 0x179E0FB8 1 > $DCC_PATH/config
    echo 0x179E0FBC 1 > $DCC_PATH/config
    echo 0x179E0FD0 1 > $DCC_PATH/config
    echo 0x179E0FD4 1 > $DCC_PATH/config
    echo 0x179E0FD8 1 > $DCC_PATH/config
    echo 0x179E0FDC 1 > $DCC_PATH/config
    echo 0x179E0FE4 1 > $DCC_PATH/config
    echo 0x179E0FE8 1 > $DCC_PATH/config
    echo 0x179E0FEC 1 > $DCC_PATH/config
    echo 0x179E0FF0 1 > $DCC_PATH/config
    echo 0x179E0FF8 1 > $DCC_PATH/config
    echo 0x179E0FFC 1 > $DCC_PATH/config
    echo 0x179E1000 1 > $DCC_PATH/config
    echo 0x179E1004 1 > $DCC_PATH/config

    echo 0x179E1A5C 1 > $DCC_PATH/config
    echo 0x179E1A70 1 > $DCC_PATH/config
    echo 0x179E1A84 1 > $DCC_PATH/config
    echo 0x179E1A98 1 > $DCC_PATH/config
    echo 0x179E1AAC 1 > $DCC_PATH/config
    echo 0x179E1AC0 1 > $DCC_PATH/config
    echo 0x179E1AD4 1 > $DCC_PATH/config
    echo 0x179E1AE8 1 > $DCC_PATH/config
    echo 0x179E1AFC 1 > $DCC_PATH/config
    echo 0x179E1B10 1 > $DCC_PATH/config
    echo 0x179E1B24 1 > $DCC_PATH/config
    echo 0x179E1B38 1 > $DCC_PATH/config
    echo 0x179E1B4C 1 > $DCC_PATH/config
    echo 0x179E1B60 1 > $DCC_PATH/config
    echo 0x179E1B74 1 > $DCC_PATH/config
    echo 0x179E1B88 1 > $DCC_PATH/config

    echo 0x17D45F00 1 > $DCC_PATH/config
    echo 0x17D45F08 1 > $DCC_PATH/config
    echo 0x17D45F0C 1 > $DCC_PATH/config
    echo 0x17D45F10 1 > $DCC_PATH/config
    echo 0x17D45F14 1 > $DCC_PATH/config
    echo 0x17D45F18 1 > $DCC_PATH/config
    echo 0x17D45F1C 1 > $DCC_PATH/config
    echo 0x17D47414 1 > $DCC_PATH/config
    echo 0x17D47418 1 > $DCC_PATH/config
    echo 0x17D47570 1 > $DCC_PATH/config
    echo 0x17D47588 1 > $DCC_PATH/config
    echo 0x17D43700 1 > $DCC_PATH/config
    echo 0x17D43708 1 > $DCC_PATH/config
    echo 0x17D4370C 1 > $DCC_PATH/config
    echo 0x17D43710 1 > $DCC_PATH/config
    echo 0x17D43714 1 > $DCC_PATH/config
    echo 0x17D43718 1 > $DCC_PATH/config
    echo 0x17D4371C 1 > $DCC_PATH/config
    echo 0x17D44C14 1 > $DCC_PATH/config
    echo 0x17D44C18 1 > $DCC_PATH/config
    echo 0x17D44D70 1 > $DCC_PATH/config
    echo 0x17D44D88 1 > $DCC_PATH/config
    echo 0x17D41700 1 > $DCC_PATH/config
    echo 0x17D41708 1 > $DCC_PATH/config
    echo 0x17D4170C 1 > $DCC_PATH/config
    echo 0x17D41710 1 > $DCC_PATH/config
    echo 0x17D41714 1 > $DCC_PATH/config
    echo 0x17D41718 1 > $DCC_PATH/config
    echo 0x17D4171C 1 > $DCC_PATH/config
    echo 0x17D42C14 1 > $DCC_PATH/config
    echo 0x17D42C18 1 > $DCC_PATH/config
    echo 0x17D42D70 1 > $DCC_PATH/config
    echo 0x17D42D88 1 > $DCC_PATH/config

   # DDR_SS
    echo 0x01132100 1 > $DCC_PATH/config
    echo 0x01136044 1 > $DCC_PATH/config
    echo 0x01136048 1 > $DCC_PATH/config
    echo 0x0113604C 1 > $DCC_PATH/config
    echo 0x01136050 1 > $DCC_PATH/config
    echo 0x011360B0 1 > $DCC_PATH/config
    echo 0x0113E030 1 > $DCC_PATH/config
    echo 0x0113E034 1 > $DCC_PATH/config
    echo 0x01141000 1 > $DCC_PATH/config
    echo 0x01148058 1 > $DCC_PATH/config
    echo 0x0114805C 1 > $DCC_PATH/config
    echo 0x01148060 1 > $DCC_PATH/config
    echo 0x01148064 1 > $DCC_PATH/config
    echo 0x01160410 1 > $DCC_PATH/config
    echo 0x01160414 1 > $DCC_PATH/config
    echo 0x01160418 1 > $DCC_PATH/config
    echo 0x01160420 1 > $DCC_PATH/config
    echo 0x01160424 1 > $DCC_PATH/config
    echo 0x01160430 1 > $DCC_PATH/config
    echo 0x01160440 1 > $DCC_PATH/config
    echo 0x01160448 1 > $DCC_PATH/config
    echo 0x011604A0 1 > $DCC_PATH/config
    echo 0x011B2100 1 > $DCC_PATH/config
    echo 0x011B6044 1 > $DCC_PATH/config
    echo 0x011B6048 1 > $DCC_PATH/config
    echo 0x011B604C 1 > $DCC_PATH/config
    echo 0x011B6050 1 > $DCC_PATH/config
    echo 0x011B60B0 1 > $DCC_PATH/config
    echo 0x011BE030 1 > $DCC_PATH/config
    echo 0x011BE034 1 > $DCC_PATH/config
    echo 0x011C1000 1 > $DCC_PATH/config
    echo 0x011C8058 1 > $DCC_PATH/config
    echo 0x011C805C 1 > $DCC_PATH/config
    echo 0x011C8060 1 > $DCC_PATH/config
    echo 0x011C8064 1 > $DCC_PATH/config
    echo 0x011E0410 1 > $DCC_PATH/config
    echo 0x011E0414 1 > $DCC_PATH/config
    echo 0x011E0418 1 > $DCC_PATH/config
    echo 0x011E0420 1 > $DCC_PATH/config
    echo 0x011E0424 1 > $DCC_PATH/config
    echo 0x011E0430 1 > $DCC_PATH/config
    echo 0x011E0440 1 > $DCC_PATH/config
    echo 0x011E0448 1 > $DCC_PATH/config
    echo 0x011E04A0 1 > $DCC_PATH/config
    echo 0x01232100 1 > $DCC_PATH/config
    echo 0x01236044 1 > $DCC_PATH/config
    echo 0x01236048 1 > $DCC_PATH/config
    echo 0x0123604C 1 > $DCC_PATH/config
    echo 0x01236050 1 > $DCC_PATH/config
    echo 0x012360B0 1 > $DCC_PATH/config
    echo 0x0123E030 1 > $DCC_PATH/config
    echo 0x0123E034 1 > $DCC_PATH/config
    echo 0x01241000 1 > $DCC_PATH/config
    echo 0x01248058 1 > $DCC_PATH/config
    echo 0x0124805C 1 > $DCC_PATH/config
    echo 0x01248060 1 > $DCC_PATH/config
    echo 0x01248064 1 > $DCC_PATH/config
    echo 0x01260410 1 > $DCC_PATH/config
    echo 0x01260414 1 > $DCC_PATH/config
    echo 0x01260418 1 > $DCC_PATH/config
    echo 0x01260420 1 > $DCC_PATH/config
    echo 0x01260424 1 > $DCC_PATH/config
    echo 0x01260430 1 > $DCC_PATH/config
    echo 0x01260440 1 > $DCC_PATH/config
    echo 0x01260448 1 > $DCC_PATH/config
    echo 0x012604A0 1 > $DCC_PATH/config
    echo 0x012B2100 1 > $DCC_PATH/config
    echo 0x012B6044 1 > $DCC_PATH/config
    echo 0x012B6048 1 > $DCC_PATH/config
    echo 0x012B604C 1 > $DCC_PATH/config
    echo 0x012B6050 1 > $DCC_PATH/config
    echo 0x012B60B0 1 > $DCC_PATH/config
    echo 0x012BE030 1 > $DCC_PATH/config
    echo 0x012BE034 1 > $DCC_PATH/config
    echo 0x012C1000 1 > $DCC_PATH/config
    echo 0x012C8058 1 > $DCC_PATH/config
    echo 0x012C805C 1 > $DCC_PATH/config
    echo 0x012C8060 1 > $DCC_PATH/config
    echo 0x012C8064 1 > $DCC_PATH/config
    echo 0x012E0410 1 > $DCC_PATH/config
    echo 0x012E0414 1 > $DCC_PATH/config
    echo 0x012E0418 1 > $DCC_PATH/config
    echo 0x012E0420 1 > $DCC_PATH/config
    echo 0x012E0424 1 > $DCC_PATH/config
    echo 0x012E0430 1 > $DCC_PATH/config
    echo 0x012E0440 1 > $DCC_PATH/config
    echo 0x012E0448 1 > $DCC_PATH/config
    echo 0x012E04A0 1 > $DCC_PATH/config
    echo 0x01380900 1 > $DCC_PATH/config
    echo 0x01380904 1 > $DCC_PATH/config
    echo 0x01380908 1 > $DCC_PATH/config
    echo 0x0138090c 1 > $DCC_PATH/config
    echo 0x01380910 1 > $DCC_PATH/config
    echo 0x01380914 1 > $DCC_PATH/config
    echo 0x01380918 1 > $DCC_PATH/config
    echo 0x0138091c 1 > $DCC_PATH/config
    echo 0x01380d00 1 > $DCC_PATH/config
    echo 0x01380d04 1 > $DCC_PATH/config
    echo 0x01380d08 1 > $DCC_PATH/config
    echo 0x01380d0c 1 > $DCC_PATH/config
    echo 0x01380d10 1 > $DCC_PATH/config
    echo 0x01430280 1 > $DCC_PATH/config
    echo 0x01430288 1 > $DCC_PATH/config
    echo 0x0143028c 1 > $DCC_PATH/config
    echo 0x01430290 1 > $DCC_PATH/config
    echo 0x01430294 1 > $DCC_PATH/config
    echo 0x01430298 1 > $DCC_PATH/config
    echo 0x0143029c 1 > $DCC_PATH/config
    echo 0x014302a0 1 > $DCC_PATH/config

    echo 0x01132100 1 > $DCC_PATH/config
    echo 0x01136044 1 > $DCC_PATH/config
    echo 0x01136048 1 > $DCC_PATH/config
    echo 0x0113604C 1 > $DCC_PATH/config
    echo 0x01136050 1 > $DCC_PATH/config
    echo 0x011360B0 1 > $DCC_PATH/config
    echo 0x0113E030 1 > $DCC_PATH/config
    echo 0x0113E034 1 > $DCC_PATH/config
    echo 0x01141000 1 > $DCC_PATH/config
    echo 0x01148058 1 > $DCC_PATH/config
    echo 0x0114805C 1 > $DCC_PATH/config
    echo 0x01148060 1 > $DCC_PATH/config
    echo 0x01148064 1 > $DCC_PATH/config
    echo 0x01160410 1 > $DCC_PATH/config
    echo 0x01160414 1 > $DCC_PATH/config
    echo 0x01160418 1 > $DCC_PATH/config
    echo 0x01160420 1 > $DCC_PATH/config
    echo 0x01160424 1 > $DCC_PATH/config
    echo 0x01160430 1 > $DCC_PATH/config
    echo 0x01160440 1 > $DCC_PATH/config
    echo 0x01160448 1 > $DCC_PATH/config
    echo 0x011604A0 1 > $DCC_PATH/config
    echo 0x011B2100 1 > $DCC_PATH/config
    echo 0x011B6044 1 > $DCC_PATH/config
    echo 0x011B6048 1 > $DCC_PATH/config
    echo 0x011B604C 1 > $DCC_PATH/config
    echo 0x011B6050 1 > $DCC_PATH/config
    echo 0x011B60B0 1 > $DCC_PATH/config
    echo 0x011BE030 1 > $DCC_PATH/config
    echo 0x011BE034 1 > $DCC_PATH/config
    echo 0x011C1000 1 > $DCC_PATH/config
    echo 0x011C8058 1 > $DCC_PATH/config
    echo 0x011C805C 1 > $DCC_PATH/config
    echo 0x011C8060 1 > $DCC_PATH/config
    echo 0x011C8064 1 > $DCC_PATH/config
    echo 0x011E0410 1 > $DCC_PATH/config
    echo 0x011E0414 1 > $DCC_PATH/config
    echo 0x011E0418 1 > $DCC_PATH/config
    echo 0x011E0420 1 > $DCC_PATH/config
    echo 0x011E0424 1 > $DCC_PATH/config
    echo 0x011E0430 1 > $DCC_PATH/config
    echo 0x011E0440 1 > $DCC_PATH/config
    echo 0x011E0448 1 > $DCC_PATH/config
    echo 0x011E04A0 1 > $DCC_PATH/config
    echo 0x01232100 1 > $DCC_PATH/config
    echo 0x01236044 1 > $DCC_PATH/config
    echo 0x01236048 1 > $DCC_PATH/config
    echo 0x0123604C 1 > $DCC_PATH/config
    echo 0x01236050 1 > $DCC_PATH/config
    echo 0x012360B0 1 > $DCC_PATH/config
    echo 0x0123E030 1 > $DCC_PATH/config
    echo 0x0123E034 1 > $DCC_PATH/config
    echo 0x01241000 1 > $DCC_PATH/config
    echo 0x01248058 1 > $DCC_PATH/config
    echo 0x0124805C 1 > $DCC_PATH/config
    echo 0x01248060 1 > $DCC_PATH/config
    echo 0x01248064 1 > $DCC_PATH/config
    echo 0x01260410 1 > $DCC_PATH/config
    echo 0x01260414 1 > $DCC_PATH/config
    echo 0x01260418 1 > $DCC_PATH/config
    echo 0x01260420 1 > $DCC_PATH/config
    echo 0x01260424 1 > $DCC_PATH/config
    echo 0x01260430 1 > $DCC_PATH/config
    echo 0x01260440 1 > $DCC_PATH/config
    echo 0x01260448 1 > $DCC_PATH/config
    echo 0x012604A0 1 > $DCC_PATH/config
    echo 0x012B2100 1 > $DCC_PATH/config
    echo 0x012B6044 1 > $DCC_PATH/config
    echo 0x012B6048 1 > $DCC_PATH/config
    echo 0x012B604C 1 > $DCC_PATH/config
    echo 0x012B6050 1 > $DCC_PATH/config
    echo 0x012B60B0 1 > $DCC_PATH/config
    echo 0x012BE030 1 > $DCC_PATH/config
    echo 0x012BE034 1 > $DCC_PATH/config
    echo 0x012C1000 1 > $DCC_PATH/config
    echo 0x012C8058 1 > $DCC_PATH/config
    echo 0x012C805C 1 > $DCC_PATH/config
    echo 0x012C8060 1 > $DCC_PATH/config
    echo 0x012C8064 1 > $DCC_PATH/config
    echo 0x012E0410 1 > $DCC_PATH/config
    echo 0x012E0414 1 > $DCC_PATH/config
    echo 0x012E0418 1 > $DCC_PATH/config
    echo 0x012E0420 1 > $DCC_PATH/config
    echo 0x012E0424 1 > $DCC_PATH/config
    echo 0x012E0430 1 > $DCC_PATH/config
    echo 0x012E0440 1 > $DCC_PATH/config
    echo 0x012E0448 1 > $DCC_PATH/config
    echo 0x012E04A0 1 > $DCC_PATH/config
    echo 0x01380900 1 > $DCC_PATH/config
    echo 0x01380904 1 > $DCC_PATH/config
    echo 0x01380908 1 > $DCC_PATH/config
    echo 0x0138090c 1 > $DCC_PATH/config
    echo 0x01380910 1 > $DCC_PATH/config
    echo 0x01380914 1 > $DCC_PATH/config
    echo 0x01380918 1 > $DCC_PATH/config
    echo 0x0138091c 1 > $DCC_PATH/config
    echo 0x01380d00 1 > $DCC_PATH/config
    echo 0x01380d04 1 > $DCC_PATH/config
    echo 0x01380d08 1 > $DCC_PATH/config
    echo 0x01380d0c 1 > $DCC_PATH/config
    echo 0x01380d10 1 > $DCC_PATH/config
    echo 0x01430280 1 > $DCC_PATH/config
    echo 0x01430288 1 > $DCC_PATH/config
    echo 0x0143028c 1 > $DCC_PATH/config
    echo 0x01430290 1 > $DCC_PATH/config
    echo 0x01430294 1 > $DCC_PATH/config
    echo 0x01430298 1 > $DCC_PATH/config
    echo 0x0143029c 1 > $DCC_PATH/config
    echo 0x014302a0 1 > $DCC_PATH/config

    echo 0x01301000 1 > $DCC_PATH/config
    echo 0x01301004 1 > $DCC_PATH/config
    echo 0x01302000 1 > $DCC_PATH/config
    echo 0x01302004 1 > $DCC_PATH/config
    echo 0x01303000 1 > $DCC_PATH/config
    echo 0x01303004 1 > $DCC_PATH/config
    echo 0x01304000 1 > $DCC_PATH/config
    echo 0x01304004 1 > $DCC_PATH/config
    echo 0x01305000 1 > $DCC_PATH/config
    echo 0x01305004 1 > $DCC_PATH/config
    echo 0x01306000 1 > $DCC_PATH/config
    echo 0x01306004 1 > $DCC_PATH/config
    echo 0x01307000 1 > $DCC_PATH/config
    echo 0x01307004 1 > $DCC_PATH/config
    echo 0x01308000 1 > $DCC_PATH/config
    echo 0x01308004 1 > $DCC_PATH/config
    echo 0x01309000 1 > $DCC_PATH/config
    echo 0x01309004 1 > $DCC_PATH/config
    echo 0x0130A000 1 > $DCC_PATH/config
    echo 0x0130A004 1 > $DCC_PATH/config
    echo 0x0130B000 1 > $DCC_PATH/config
    echo 0x0130B004 1 > $DCC_PATH/config
    echo 0x0130C000 1 > $DCC_PATH/config
    echo 0x0130C004 1 > $DCC_PATH/config
    echo 0x0130D000 1 > $DCC_PATH/config
    echo 0x0130D004 1 > $DCC_PATH/config
    echo 0x0130E000 1 > $DCC_PATH/config
    echo 0x0130E004 1 > $DCC_PATH/config
    echo 0x0130F000 1 > $DCC_PATH/config
    echo 0x0130F004 1 > $DCC_PATH/config
    echo 0x01310000 1 > $DCC_PATH/config
    echo 0x01310004 1 > $DCC_PATH/config
    echo 0x01311000 1 > $DCC_PATH/config
    echo 0x01311004 1 > $DCC_PATH/config
    echo 0x01312000 1 > $DCC_PATH/config
    echo 0x01312004 1 > $DCC_PATH/config
    echo 0x01313000 1 > $DCC_PATH/config
    echo 0x01313004 1 > $DCC_PATH/config
    echo 0x01314000 1 > $DCC_PATH/config
    echo 0x01314004 1 > $DCC_PATH/config
    echo 0x01315000 1 > $DCC_PATH/config
    echo 0x01315004 1 > $DCC_PATH/config
    echo 0x01316000 1 > $DCC_PATH/config
    echo 0x01316004 1 > $DCC_PATH/config
    echo 0x01317000 1 > $DCC_PATH/config
    echo 0x01317004 1 > $DCC_PATH/config
    echo 0x01318000 1 > $DCC_PATH/config
    echo 0x01318004 1 > $DCC_PATH/config
    echo 0x01319000 1 > $DCC_PATH/config
    echo 0x01319004 1 > $DCC_PATH/config
    echo 0x0131A000 1 > $DCC_PATH/config
    echo 0x0131A004 1 > $DCC_PATH/config
    echo 0x0131B000 1 > $DCC_PATH/config
    echo 0x0131B004 1 > $DCC_PATH/config
    echo 0x0131C000 1 > $DCC_PATH/config
    echo 0x0131C004 1 > $DCC_PATH/config
    echo 0x0131D000 1 > $DCC_PATH/config
    echo 0x0131D004 1 > $DCC_PATH/config
    echo 0x0131E000 1 > $DCC_PATH/config
    echo 0x0131E004 1 > $DCC_PATH/config
    echo 0x0131F000 1 > $DCC_PATH/config
    echo 0x0131F004 1 > $DCC_PATH/config
    echo 0x0C201244 1 > $DCC_PATH/config
    echo 0x0C202244 1 > $DCC_PATH/config
    echo 0x013D0008 1 > $DCC_PATH/config
    echo 0x013D0068 1 > $DCC_PATH/config
    echo 0x013D0078 1 > $DCC_PATH/config
    echo 0x013D1000 1 > $DCC_PATH/config

    # add dump corehang counter registers
    echo 0x17E0005C 1 > $DCC_PATH/config
    echo 0x17E1005C 1 > $DCC_PATH/config
    echo 0x17E2005C 1 > $DCC_PATH/config
    echo 0x17E3005C 1 > $DCC_PATH/config
    echo 0x17E4005C 1 > $DCC_PATH/config
    echo 0x17E5005C 1 > $DCC_PATH/config
    echo 0x17E6005C 1 > $DCC_PATH/config
    echo 0x17E7005C 1 > $DCC_PATH/config
    
    echo 0x069EA00C 0x00600007 1 > $DCC_PATH/config_write
    echo 0x069EA01C 0x00136800 1 > $DCC_PATH/config_write
    echo 0x069EA014 1 1 > $DCC_PATH/config
    echo 0x069EA01C 0x00136810 1 > $DCC_PATH/config_write
    echo 0x069EA014 1 1 > $DCC_PATH/config
    echo 0x069EA01C 0x00136820 1 > $DCC_PATH/config_write
    echo 0x069EA014 1 1 > $DCC_PATH/config
    echo 0x069EA01C 0x00136830 1 > $DCC_PATH/config_write
    echo 0x069EA014 1 1 > $DCC_PATH/config
    echo 0x069EA01C 0x00136840 1 > $DCC_PATH/config_write
    echo 0x069EA014 1 1 > $DCC_PATH/config
    echo 0x069EA01C 0x00136850 1 > $DCC_PATH/config_write
    echo 0x069EA014 1 1 > $DCC_PATH/config
    echo 0x069EA01C 0x00136860 1 > $DCC_PATH/config_write
    echo 0x069EA014 1 1 > $DCC_PATH/config
    echo 0x069EA01C 0x00136870 1 > $DCC_PATH/config_write
    echo 0x069EA014 1 1 > $DCC_PATH/config
    echo 0x069EA01C 0x0003e9a0 1 > $DCC_PATH/config_write
    echo 0x069EA01C 0x001368a0 1 > $DCC_PATH/config_write
    echo 0x069EA014 1 1 > $DCC_PATH/config
    echo 0x069EA01C 0x0003c0a0 1 > $DCC_PATH/config_write
    echo 0x069EA01C 0x001368a0 1 > $DCC_PATH/config_write
    echo 0x069EA014 1 1 > $DCC_PATH/config
    echo 0x069EA01C 0x0003d1a0 1 > $DCC_PATH/config_write
    echo 0x069EA01C 0x001368a0 1 > $DCC_PATH/config_write
    echo 0x069EA014 1 1 > $DCC_PATH/config
    echo 0x069EA01C 0x0003d2a0 1 > $DCC_PATH/config_write
    echo 0x069EA01C 0x001368a0 1 > $DCC_PATH/config_write
    echo 0x069EA014 1 1 > $DCC_PATH/config
    echo 0x069EA01C 0x0003d5a0 1 > $DCC_PATH/config_write
    echo 0x069EA01C 0x001368a0 1 > $DCC_PATH/config_write
    echo 0x069EA014 1 1 > $DCC_PATH/config
    echo 0x069EA01C 0x0003d6a0 1 > $DCC_PATH/config_write
    echo 0x069EA01C 0x001368a0 1 > $DCC_PATH/config_write
    echo 0x069EA014 1 1 > $DCC_PATH/config
    echo 0x069EA01C 0x0003e8a0 1 > $DCC_PATH/config_write
    echo 0x069EA01C 0x001368a0 1 > $DCC_PATH/config_write
    echo 0x069EA014 1 1 > $DCC_PATH/config
    echo 0x069EA01C 0x0003eea0 1 > $DCC_PATH/config_write
    echo 0x069EA01C 0x001368a0 1 > $DCC_PATH/config_write
    echo 0x069EA014 1 1 > $DCC_PATH/config
    echo 0x069EA01C 0x0003b1a0 1 > $DCC_PATH/config_write
    echo 0x069EA01C 0x001368a0 1 > $DCC_PATH/config_write
    echo 0x069EA014 1 1 > $DCC_PATH/config
    echo 0x069EA01C 0x0003b2a0 1 > $DCC_PATH/config_write
    echo 0x069EA01C 0x001368a0 1 > $DCC_PATH/config_write
    echo 0x069EA014 1 1 > $DCC_PATH/config
    echo 0x069EA01C 0x0003b5a0 1 > $DCC_PATH/config_write
    echo 0x069EA01C 0x001368a0 1 > $DCC_PATH/config_write
    echo 0x069EA014 1 1 > $DCC_PATH/config
    echo 0x069EA01C 0x0003b6a0 1 > $DCC_PATH/config_write
    echo 0x069EA01C 0x001368a0 1 > $DCC_PATH/config_write
    echo 0x069EA014 1 1 > $DCC_PATH/config
    echo 0x069EA01C 0x0003c2a0 1 > $DCC_PATH/config_write
    echo 0x069EA01C 0x001368a0 1 > $DCC_PATH/config_write
    echo 0x069EA014 1 1 > $DCC_PATH/config
    echo 0x069EA01C 0x0003c5a0 1 > $DCC_PATH/config_write
    echo 0x069EA01C 0x001368a0 1 > $DCC_PATH/config_write
    echo 0x069EA014 1 1 > $DCC_PATH/config
    echo 0x069EA01C 0x0003c6a0 1 > $DCC_PATH/config_write
    echo 0x069EA01C 0x001368a0 1 > $DCC_PATH/config_write
    echo 0x069EA014 1 1 > $DCC_PATH/config
    echo 0x069EA01C 0x00f1e000 1 > $DCC_PATH/config_write
    echo 0x069EA008 0x00000007 1 > $DCC_PATH/config_write

    #Modem
    echo 0x01F63000 5 > $DCC_PATH/config
    echo 0x01F64000 3 > $DCC_PATH/config
    echo 0x01F65000 3 > $DCC_PATH/config
    echo 0x0018A008 1 > $DCC_PATH/config
    echo 0x04082028 1 > $DCC_PATH/config
    echo 0x04180040 1 > $DCC_PATH/config
    echo 0x04080044 1 > $DCC_PATH/config
    echo 0x04130400 1 > $DCC_PATH/config
    echo 0x04130408 1 > $DCC_PATH/config
    echo 0x04200400 1 > $DCC_PATH/config
    echo 0x04200408 1 > $DCC_PATH/config
    echo 0x0B2B1024 1 > $DCC_PATH/config
    echo 0x04130208 2 > $DCC_PATH/config
    echo 0x04130228 2 > $DCC_PATH/config
    echo 0x04130248 2 > $DCC_PATH/config
    echo 0x04130268 2 > $DCC_PATH/config
    echo 0x04200208 2 > $DCC_PATH/config
    echo 0x04200228 2 > $DCC_PATH/config
    echo 0x04200248 2 > $DCC_PATH/config
    echo 0x04200268 2 > $DCC_PATH/config
    echo 0x0B2B1204 3 > $DCC_PATH/config
    echo 0x0B2B122C 2 > $DCC_PATH/config
    echo 0x0B2B1240 2 > $DCC_PATH/config
    echo 0x0B2B1218 2 > $DCC_PATH/config
    echo 0x04104000 8 > $DCC_PATH/config

    #TCS status
    echo 0x04200D00 2 > $DCC_PATH/config
    #TCS config
    echo 0x04201798 2 > $DCC_PATH/config
    echo 0x04201A38 2 > $DCC_PATH/config
    #CMD config
    echo 0x042017B0 4 > $DCC_PATH/config
    echo 0x042017C4 4 > $DCC_PATH/config
    echo 0x042017D8 4 > $DCC_PATH/config
    echo 0x042017EC 4 > $DCC_PATH/config
    echo 0x04201800 4 > $DCC_PATH/config
    echo 0x04201814 4 > $DCC_PATH/config
    echo 0x04201828 4 > $DCC_PATH/config
    echo 0x0420183C 4 > $DCC_PATH/config
    echo 0x04201850 4 > $DCC_PATH/config
    echo 0x04201864 4 > $DCC_PATH/config
    echo 0x04201878 4 > $DCC_PATH/config
    echo 0x0420188C 4 > $DCC_PATH/config
    echo 0x042018A0 4 > $DCC_PATH/config
    echo 0x042018B4 4 > $DCC_PATH/config
    echo 0x042018C8 4 > $DCC_PATH/config
    echo 0x042018DC 4 > $DCC_PATH/config
    echo 0x04201A50 4 > $DCC_PATH/config
    echo 0x04201A64 4 > $DCC_PATH/config
    echo 0x04201A78 4 > $DCC_PATH/config
    echo 0x04201A8C 4 > $DCC_PATH/config
    echo 0x04201AA0 4 > $DCC_PATH/config
    echo 0x04201AB4 4 > $DCC_PATH/config
    echo 0x04201AC8 4 > $DCC_PATH/config
    echo 0x04201ADC 4 > $DCC_PATH/config
    echo 0x04201AF0 4 > $DCC_PATH/config
    echo 0x04201B04 4 > $DCC_PATH/config
    echo 0x04201B18 4 > $DCC_PATH/config
    echo 0x04201B2C 4 > $DCC_PATH/config
    echo 0x04201B40 4 > $DCC_PATH/config
    echo 0x04201B54 4 > $DCC_PATH/config
    echo 0x04201B68 4 > $DCC_PATH/config
    echo 0x04201B7C 4 > $DCC_PATH/config

    #Apply configuration and enable DCC
    echo  1 > $DCC_PATH/enable
}



enable_sdm845_core_hang_config()
{
    CORE_PATH_SILVER="/sys/devices/system/cpu/hang_detect_silver"
    CORE_PATH_GOLD="/sys/devices/system/cpu/hang_detect_gold"
    if [ ! -d $CORE_PATH ]; then
        echo "CORE hang does not exist on this build."
        return
    fi

    #set the threshold to around 100 milli-second
    #echo 0x1d4c01 > $CORE_PATH_SILVER/threshold
    #echo 0x1d4c01 > $CORE_PATH_GOLD/threshold
    echo 0xffffffff > $CORE_PATH_SILVER/threshold
    echo 0xffffffff > $CORE_PATH_GOLD/threshold

    #To the enable core hang detection
    echo 0x1 > $CORE_PATH_SILVER/enable
    echo 0x1 > $CORE_PATH_GOLD/enable
}


case "$enable" in
    "1")
        echo "enable"
        enable_trace_events
        enable_sdm845_dcc_config
        enable_sdm845_core_hang_config
        ;;
    "0")
        echo "disable"
        disable_trace_events
        ;;
esac

