#! /usr/bin/perl

use strict;
use warnings;
use File::Basename;

my $line;
my $filename;

foreach $filename (@ARGV) {
#	print "$filename\n";
	my $base = basename($filename);
	$base =~ s/\.methods$//;
	$base =~ s/\.fields$//;

  open SOURCE,"<$filename" or die "Error opening $filename.\n";
  open START,">$filename.start" or die "Error opening $filename.start.\n";
  open END,">$filename.end" or die "Error opening $filename.end.\n";
  open SINGLE,">$filename.single" or die "Error opening $filename.single.\n";
  open OTHER,">$filename.other" or die "Error opening $filename.other.\n";

  while ( $line = <SOURCE> ) {
    chomp($line);
    if ($line =~ m/\| $base ?$/) {
		  print SINGLE "$line\n";
	  }
	  elsif ($line =~ m/\| $base /) {
    	print START "$line\n";
    }
	  elsif ($line =~ m/ $base ?$/) {
		  print END "$line\n";
	  }
	  elsif ($line =~ m/ $base /) {
		  print OTHER "$line\n";
	  }
  }
  close SOURCE;
  close START;
  close END;
  close SINGLE;
  close OTHER;
}

