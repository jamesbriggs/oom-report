#!/usr/bin/perl

# Program: oom_report.pl
# Author: James Briggs, USA
# Date: 2019 02 02
# Purpose: parse syslog for first OOM and report on memory use
# License: Apache 2.0
# Link: https://github.com/jamesbriggs/oom-report
# Env: Perl5
# Usage: perl oom_report.pl <oom.txt
# Note:

use strict;
use warnings;

   my $DEBUG = 0;

   my $VERSION = 0.1;

   my $hdr = ' tgid ';

   my %ps;

   my $i = -1;

   while (<>) { # scan for syslog OOM columm header
      chomp;
      next if /^$/;

      $i = index($_, $hdr);

      last if $i > -1;
   }

   if ($i == -1) {
      print STDERR "info: header '$hdr' not found.\n";
      exit 1;
   }

   my $n = 1;
   while (<>) { # scan for processes in OOM listing
      next if /^$/;

      if (/Out of memory:/) { # end of OOM listing processes
         print;
         $_ = <>;
         print;
         last;
      }

      chomp;

# Mar 10 18:36:05 vpc-prod2-external-013 kernel: [11311855.321286] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
# Mar 10 18:36:05 vpc-prod2-external-013 kernel: [11311855.321291] [  505]     0   505    18155     9776      41       3        0             0 systemd-journal


      if (my ($pid, $vm, $rss, $ps) = $_ =~ /\[ *(\d+)\] +\d+ +\d+ +(\d+) +(\d+).+ ([()\w-]+)$/) {
         if ($ps eq 'java') { # uniqify the process name 'java'
            $ps .= "$n";
            $n++;
         }

         $ps{$ps} += $vm + $rss;
      }
      else {
         print "NF: $_\n";
      }
   }

   report();

   exit;

sub report {
   my $total = 0;

   for my $ps (sort { $ps{$a} <=> $ps{$b} } keys %ps) {
      print leftpad($ps) . " = " . leftpad(commify($ps{$ps})) . "\n";
      $total += $ps{$ps};
   }

   if ($total > 0.001) {
      print "\n" . leftpad("total (vm+rss)") . " = " . leftpad(commify($total)) . " KB\n";
   }
}

sub commify {
    my $text = reverse $_[0];
    $text =~ s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;
    return scalar reverse $text;
}

sub leftpad {
   sprintf("%15s", shift);
}
