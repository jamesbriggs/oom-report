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
   my $hdr_len = length($hdr);

   my %ps;

   my $i = -1;

   while (<>) { # scan for syslog OOM columm header
      chomp;
      next if /^$/;

      $i = index($_, $hdr);

      last if $i > -1;
   }

   if ($i == -1) {
      print STDERR "error: header '$hdr' not found.\n";
      exit 1;
   }

   my $n = 1;
   while (<>) { # scan for processes in OOM listing
      next if /^$/;

      if (/Out of memory:/) { # end of OOM listing processes
         print;
         print <>;
         last;
      }

      chomp;

      # skip over to columns of interest
      $_ = substr($_, $i+$hdr_len);

      print substr($_, $i+$hdr_len) if $DEBUG;

      my ($vm, $rss, undef, undef, undef, undef, $ps) = split;

      if ($ps eq 'java') { # uniqify the process name 'java'
         $ps .= "$n";
         $n++;
      }

      $ps{$ps} += $vm + $rss;
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
      print "\n" . leftpad("total") . " = " . leftpad(commify($total)) . "\n";
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

