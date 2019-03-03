# oom-report
Summarize RAM consumption per process from syslog OOM reports

```
Usage: perl oom_report.pl < file.txt
```
where file.txt contains an OOM listing extracted from /var/log/syslog. You must include the column header row.


Here's an example of running oom_report.pl on a 16 GB server:

```
$ perl oom_report.pl < myoom.txt

[..]
    salt-minion =         264,981
        dockerd =         297,009
docker-containe =         442,017
          agent =         584,720
          java3 =         877,946
          java1 =       1,205,023
          nginx =       2,926,052
          java2 =       5,608,659

          total =      13,427,264
```
Notes:

* Current kernels kill the largest user of RAM by default, so in this case the process named java2.
* Note that 13 GB is accounted from 16 GB. Likely the remainder is used by the kernel itself.

License: Apache 2

