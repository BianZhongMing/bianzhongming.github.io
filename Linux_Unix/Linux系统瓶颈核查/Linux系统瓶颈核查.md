## 1. 系统概览--TOP

- 命令：top
- 主要信息：进程情况，CPU，内存，SWAP
- 常用快捷键：在TOP命令状态下输入**大写P，则结果按CPU占用降序排序**。输入**大写M，结果按内存占用降序排序。**（注：大写P可以在capslock状态输入p，或者按Shift+p）
- DEMO：

1. Mysql吃光CPU

   ![MysqlALLCpu](MysqlALLCpu.png)

2. 根据进程PID确定进程明细信息

   ![2](2.png)



## 2. 系统资源监控--dstat

- 安装：\# sudo apt-get install dstat	      	  # yum install dstat

- 命令：

  - dstat

  - dstat 3 10

  - dstat -c --top-cpu -d --top-bio --top-latency【查看当前占用I/O、cpu、内存等最高的进程信息】

  - dstat -t --proc-count --top-cpu --top-mem --top-io --net-packets -lpmsa --output /tmp/sampleoutput.csv  【分别显示统计时间/进程数量/占用cpu最多的进程名/占用内存最多的进程名/网络包发送量等等信息.输出一个csv格式的文件】

    ![3](3.png)

  ![4](4.png)

  ​

- 方法

  - CPU状态：当CPU的状态处在"waits"时，那是因为它正在等待I/O设备（例如内存，磁盘或者网络）的响应而且还没有收到。CPU状态：当CPU的状态处在"waits"时，那是因为它正在等待I/O设备（例如内存，磁盘或者网络）的响应而且还没有收到。
  - cpu：hiq，siq分别为硬中断和软中断次数。
  - system：int，csw分别为系统的中断次数（interrupt）和上下文切换（context switch）
  - 参数： 

    - -l ：显示负载统计量
    - -m ：显示内存使用率（包括used，buffer，cache，free值）
    - -r ：显示I/O统计
    - -d：磁盘读写
    - -s ：显示交换分区使用情况
    - -t ：将当前时间显示在第一行
    - –fs ：显示文件系统统计数据（包括文件总数量和inodes值）
    - –nocolor ：不显示颜色（有时候有用）
    - –socket ：显示网络统计数据
    - –tcp ：显示常用的TCP统计
    - –udp ：显示监听的UDP接口及其当前用量的一些动态数据
  - 当然不止这些用法，dstat附带了一些插件很大程度地扩展了它的功能。你可以通过查看/usr/share/dstat目录来查看它们的一些使用方法，常用的有这些：
    - -–disk-util ：显示某一时间磁盘的忙碌状况
    - -–freespace ：显示当前磁盘空间使用率
    - -–proc-count ：显示正在运行的程序数量
    - -–top-bio ：指出块I/O最大的进程
    - -–top-cpu ：图形化显示CPU占用最大的进程
    - -–top-io ：显示正常I/O最大的进程
    - -–top-mem ：显示占用最多内存的进程


- 特性

  - 结合了vmstat，iostat，ifstat，netstat以及更多的信息
  - 实时显示统计情况
  - 在分析和排障时可以通过启用监控项并排序
  - 模块化设计
  - 使用python编写的，更方便扩展现有的工作任务
  - 容易扩展和添加你的计数器（请为此做出贡献）
  - 包含的许多扩展插件充分说明了增加新的监控项目是很方便的
  - 可以分组统计块设备/网络设备，并给出总数
  - 可以显示每台设备的当前状态
  - 极准确的时间精度，即便是系统负荷较高也不会延迟显示
  - 显示准确地单位和和限制转换误差范围
  - 用不同的颜色显示不同的单位
  - 显示中间结果延时小于1秒
  - 支持输出CSV格式报表，并能导入到Gnumeric和Excel以生成图形






## 3. 查看系统IO占用情况--iostat

- 安装：yum install sysstat
- 基本查询

```
# iostat -d -k 1 10
Device:            tps    kB_read/s    kB_wrtn/s    kB_read    kB_wrtn
sda              39.29        21.14         1.44  441339807   29990031
sda1              0.00         0.00         0.00       1623        523

tps：该设备每秒的传输次数（Indicate the number of transfers per second that were issued to the device.）。"一次传输"意思是"一次I/O请求"。多个逻辑请求可能会被合并为"一次I/O请求"。"一次传输"请求的大小是未知的。
kB_read/s：每秒从设备（drive expressed）读取的数据量；
kB_wrtn/s：每秒向设备（drive expressed）写入的数据量；
kB_read：读取的总数据量；
kB_wrtn：写入的总数量数据量；这些单位都为Kilobytes。
```
- 查询扩展信息

```
# iostat -d -x -k 1 10
Device:    rrqm/s wrqm/s   r/s   w/s  rsec/s  wsec/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
sda          1.56  28.31  7.80 31.49   42.51    2.92    21.26     1.46     1.16     0.03    0.79   2.62  10.28
Device:    rrqm/s wrqm/s   r/s   w/s  rsec/s  wsec/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
sda          2.00  20.00 381.00  7.00 12320.00  216.00  6160.00   108.00    32.31     1.75    4.50   2.17  84.20

rrqm/s: 每秒对该设备的读请求被合并次数，文件系统会对读取同块(block)的请求进行合并
wrqm/s: 每秒对该设备的写请求被合并次数
r/s: 每秒完成的读次数
w/s: 每秒完成的写次数
rkB/s: 每秒读数据量(kB为单位)
wkB/s: 每秒写数据量(kB为单位)
avgrq-sz:平均每次IO操作的数据量(扇区数为单位)
avgqu-sz: 平均等待处理的IO请求队列长度
await: 平均每次IO请求等待时间(包括等待时间和处理时间，毫秒为单位)
svctm: 平均每次IO请求的处理时间(毫秒为单位)
%util: 采用周期内用于IO操作的时间比率，即IO队列非空的时间比率，所以该参数暗示了设备的繁忙程度。
```

- 常见用法

```
iostat -d -k 1 10         #查看TPS和吞吐量信息(磁盘读写速度单位为KB,参数-m 单位为MB)
iostat -d -x -k 1 10      #查看设备使用率（%util）、响应时间（await） iostat -c 1 10 #查看cpu状态
```

- DEMO ：

```
# iostat -d -k 1 |grep sda10
Device:            tps    kB_read/s    kB_wrtn/s    kB_read    kB_wrtn
sda10            60.72        18.95        71.53  395637647 1493241908
sda10           299.02      4266.67       129.41       4352        132
sda10           483.84      4589.90      4117.17       4544       4076
sda10           218.00      3360.00       100.00       3360        100
sda10           546.00      8784.00       124.00       8784        124
sda10           827.00     13232.00       136.00      13232        136
上面看到，磁盘每秒传输次数平均约400；每秒磁盘读取约5MB，写入约1MB。

# iostat -d -x -k 1
Device:    rrqm/s wrqm/s   r/s   w/s  rsec/s  wsec/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
sda          1.56  28.31  7.84 31.50   43.65    3.16    21.82     1.58     1.19     0.03    0.80   2.61  10.29
sda          1.98  24.75 419.80  6.93 13465.35  253.47  6732.67   126.73    32.15     2.00    4.70   2.00  85.25
sda          3.06  41.84 444.90 54.08 14204.08 2048.98  7102.04  1024.49    32.57     2.10    4.21   1.85  92.24
可以看到磁盘的平均响应时间<5ms，磁盘使用率>80。磁盘响应正常，但是已经很繁忙了。
```
一般地**系统IO响应时间await应该低于5ms**，如果大于10ms就比较大了。

若**svctm的值与await很接近，表示几乎没有I/O等待，磁盘性能很好**，如果**await的值远高于svctm的值，则表示I/O队列等待太长，系统上运行的应用程序将变慢**。

**%util一般地，如果该参数是100%表示设备已经接近满负荷运行了**（当然如果是多磁盘，即使%util是100%，因为磁盘的并发能力，所以磁盘使用未必就到了瓶颈）。



## 4.内存占用--vmstat
```
# vmstat
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 1  5 861712 280288 496656 19368480    0    0    12   124    1    0  3  1 95  2  0
输出信息简介
r: 运行的和等待运行的进程数，这个值也可以判断是否需要增加CPU(长期大于1) 
b: 处于不可中断状态的进程数，常见的情况是由IO引起的
w: 被交换出去的可运行的进程数。此数由 linux 计算得出，但 linux 并不耗尽交换空间

Memory 
swpd: 虚拟内存使用情况(默认以KB为单位)，如果 swpd 的值不为0，或者还比较大，比如超过100M了，但是 si, so 的值长期为 0，这种情况我们可以不用担心，不会影响系统性能。
free: 空闲的内存，单位KB
buff: 被用来做为缓存的内存数，单位：KB
cache: 作为page cache的内存, 文件系统的cache，如果 cache 的值大的时候，说明cache住的文件数多，如果频繁访问到的文件都能被cache住，那么磁盘的读IO bi 会非常小。

Swap 
si: 从磁盘交换到内存的交换页数量，单位：KB/秒
so: 从内存交换到磁盘的交换页数量，单位：KB/秒 
内存够用的时候，这2个值都是0，如果这2个值长期大于0时，系统性能会受到影响。磁盘IO和CPU资源都会被消耗。(常有人看到空闲内存(free)很少或接近于0时，就认为内存不够用了，实际上不能光看这一点的，还要结合si,so，如果free很少，但是si,so也很少(大多时候是0)，那么不用担心，系统性能这时不会受到影响的。)

IO 
bi: 发送到块设备的块数，单位：块/秒
随机磁盘读写的时候，这2个值越大（如超出1M），能看到CPU在IO等待的值也会越大bo: 从块设备接收到的块数，单位：块/秒 

System 
in: 每秒的中断数，包括时钟中断
cs: 每秒的环境（上下文）切换次数
上面这2个值越大，会看到由内核消耗的CPU时间会越多.

CPU 按 CPU 的总使用百分比来显示 
us:用户进程消耗的CPU时间百分比，值比较高时，说明用户进程消耗的CPU时间多，但是如果长期超过50% 的使用，那么我们就该考虑优化程序算法或者进行加速了
sy: CPU 系统使用时间，内核进程消耗的CPU时间百分比，值高时，说明系统内核消耗的CPU资源多，这并不是良性的表现，我们应该检查原因。
id: 闲置时间
wa: IO等待消耗的CPU时间百分比，值高时，说明IO等待比较严重，这可能是由于磁盘大量作随机访问造成，也有可能是磁盘的带宽出现瓶颈(块操作)。
```
## 5. 网络带宽查询

- 命令：
  - ipconfig
  - sudo ethtool NetLinkName
  - dstat


- DEMO：

  1. 查询网络连接信息

     ```
     # ifconfig
     em1       Link encap:Ethernet  HWaddr F8:BC:12:35:F6:2C  
               inet addr:10.9.0.131  Bcast:10.9.0.255  Mask:255.255.255.128
               UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
               RX packets:1116917733 errors:0 dropped:0 overruns:0 frame:0
               TX packets:815842469 errors:0 dropped:0 overruns:0 carrier:0
               collisions:0 txqueuelen:1000 
               RX bytes:797177933386 (742.4 GiB)  TX bytes:260586066489 (242.6 GiB)
               Interrupt:35 

     lo        Link encap:Local Loopback  
               inet addr:127.0.0.1  Mask:255.0.0.0
               UP LOOPBACK RUNNING  MTU:16436  Metric:1
               RX packets:5090043 errors:0 dropped:0 overruns:0 frame:0
               TX packets:5090043 errors:0 dropped:0 overruns:0 carrier:0
               collisions:0 txqueuelen:0 
               RX bytes:246346809 (234.9 MiB)  TX bytes:246346809 (234.9 MiB)
     ```

  2. 查询带宽
     ```
     	#  sudo ethtool em1
     	
     	Settings for em1:
     	Supported ports: [ TP ]
     	Supported link modes:   10baseT/Half 10baseT/Full 
     	                        100baseT/Half 100baseT/Full 
     	                        1000baseT/Half 1000baseT/Full 
     	Supported pause frame use: No
     	Supports auto-negotiation: Yes
     	Advertised link modes:  10baseT/Half 10baseT/Full 
     	                        100baseT/Half 100baseT/Full 
     	                        1000baseT/Half 1000baseT/Full 
     	Advertised pause frame use: Symmetric
     	Advertised auto-negotiation: Yes
     	Link partner advertised link modes:  10baseT/Half 10baseT/Full 
     	                                     100baseT/Half 100baseT/Full 
     	                                     1000baseT/Full 
     	Link partner advertised pause frame use: No
     	Link partner advertised auto-negotiation: Yes
     	Speed: 1000Mb/s
     	Duplex: Full
     	Port: Twisted Pair
     	PHYAD: 1
     	Transceiver: internal
     	Auto-negotiation: on
     	MDI-X: off
     	Supports Wake-on: g
     	Wake-on: d
     	Current message level: 0x000000ff (255)
     			       drv probe link timer ifdown ifup rx_err tx_err
     	Link detected: yes
     ```
  3. 压测监控

     ```
     #dstat

     ----total-cpu-usage---- -dsk/total- -net/total- ---paging-- ---system--
     usr sys idl wai hiq siq| read  writ| recv  send|  in   out | int   csw 
      10   0  89   0   0   0|   0     0 |1160k  118M|   0     0 |  28k 2433 
      10   0  90   0   0   0|   0     0 |1158k  118M|   0     0 |  28k 2480 
      10   0  89   0   0   0|   0     0 |1159k  118M|   0     0 |  28k 2547 
      10   0  89   0   0   0|   0     0 |1130k  118M|   0     0 |  28k 2469 
      10   0  89   0   0   0|   0     0 |1132k  118M|   0     0 |  28k 2310 
      10   0  90   0   0   0|   0    12k|1147k  118M|   0     0 |  28k 2275 
      10   0  90   0   0   0|   0     0 |1124k  118M|   0     0 |  28k 2308 
      10   0  89   0   0   0|   0     0 |1026k  118M|   0     0 |  26k 2257 
      10   0  90   0   0   0|   0    16k| 911k  118M|   0     0 |  22k 1961 
     ```

     Speed: 1000Mb/s=*1000*M /8 = 125M/s

     下载速度：118M，接近满速，网络瓶颈场景。
