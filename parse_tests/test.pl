#!/usr/bin/perl -w

use strict;
use FindBin qw($Bin);
use File::Find;
use File::Slurp;
use File::Which;

# If -f is specified, re-run failures even if we already recorded a failure
my $force = @ARGV && $ARGV[0] eq '-f' && shift; 

my $filter = shift;

## Pick a folder full of .java files to try to parse
my $javadir = "$Bin/openjdk/jdk/src/share/classes";

if (! -e $javadir) {
   die "No OpenJDK source code found at\n" .
       "    $javadir\n" .
       "Download and unpack code from http://openjdk.java.net/ and try again\n";
}

my $parrotexe = File::Which::which 'parrot';
if (!$parrotexe) {
   for my $i (1..5) {
      my $candidate = $Bin . ('/..' x $i) . '/parrot';
      if (-x $candidate) {
         $parrotexe = $candidate;
         last;
      }
   }
   if (!$parrotexe) {
      die "Can't find parrot\n";
   }
}

my $outdir = "$Bin/testout";
mkdir $outdir;
mkdir "$outdir/bad";
mkdir "$outdir/good";
my $perkcode = "$Bin/../perk.pbc";
find({wanted => sub {
   return if ! m/\.java\z/;
   return if m/-/; # can't handle invalid Java files with dashes in the file names
   return if $filter && !m{\A$javadir/$filter};
   #if (m{sun/nio/cs/ext/(GB18030|EUC_TW|IBM\d+|Johab|HKSCS_2001|MS\d+).java\z}xms) {
   if (m{sun/nio/cs/ext/\w+.java\z}xms) {
      print "SKIPPED $_\n";
      return;
   }
   print "$_\n";
   my $esc = $_;
   $esc =~ s{\A $javadir/}{}xms;
   $esc =~ s{/}{.}gxms;
   $esc =~ s{\.java\z}{}xms;
   my $goodfile = "$outdir/good/$esc";
   my $badfile = "$outdir/bad/$esc";
   if (-e $badfile) {
      return if !$force && ! -z $badfile && -M $badfile < -M $perkcode;
      unlink $badfile;
      unlink $badfile . '.java';
   }
   return if -e $goodfile;
   my $ret = system("'$parrotexe' '$perkcode' $_ > '$badfile'");
   my $exit = $?;
   if ( $ret == 0 ) {
      rename($badfile, $goodfile);
   } else {
      print "Returned error: $ret\n";
      if ($exit == -1) {
         print "Failed to launch\n";
         unlink $badfile;
         exit -1;
      } elsif ($exit & 127) {
         print "died with signal ", ($exit & 127), "\n";
         unlink $badfile;
         exit -1;
      } else {
         print "exit value: ", ($exit >> 8), "\n";
         #sleep 1;
         write_file($badfile . '.java', scalar read_file($_));
      }
   }
   return;
}, no_chdir => 1}, $javadir);
