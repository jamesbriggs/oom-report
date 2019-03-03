#!/usr/bin/perl

# Program: oom_report.pl
# Author: James Briggs, USA
# Purpose: parse syslog OOM and report on memory use
# License: Apache 2.0
# Env: Perl5
# Date: 2019 02 02
# Usage: perl oom_report.pl <oom.txt
# Note:

   my $DEBUG = 0;

   my $hdr = ' tgid ';

   my %ps;

   my $i = 0;

   while (<>) { # scan for syslog OOM columm headers
      chomp;
      next if /^$/;

      $i = index($_, $hdr);

      last if $i > -1;
   }

   if (!$i) {
      print STDERR "error: header $hdr not founnd.\n";
      exit 1;
   }

   my $n = 1;
   while (<>) { # scan for processes in OOM listing
      next if /^$/;

      if (/Out of memory:/) { # end of OOM listing processes
         print;
         <>;
         print;
         last;
      }

      chomp;

      # skip over to columns of interest ...
      $_ = substr($_, $i+length($hdr));

      print substr($_, $i+length($hdr)) if $DEBUG;

      my ($vm, $rss, undef, undef, undef, undef, $ps) = split;

      if ($ps eq 'java') { # uniqify the process name 'java'
         $ps .= $n;
         $n++;
      }

      $ps{$ps} += $vm + $rss;
   }

   for my $ps (sort { $ps{$a} <=> $ps{$b} } keys %ps) {
      print leftpad($ps) . " = " . leftpad(commify($ps{$ps})) . "\n";
      $total += $ps{$ps};
   }

   print "\n";
   print leftpad("total") . " = " . leftpad(commify($total)) . "\n";

   exit;

sub commify {
    my $text = reverse $_[0];
    $text =~ s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;
    return scalar reverse $text;
}

sub leftpad {
   sprintf("%15s", shift);
}

