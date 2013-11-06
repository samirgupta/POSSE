#! /usr/bin/perl

use strict;
use warnings;

my $SOURCEFOLDER = "../5-Tagged/";
my $OUTFOLDER = "../5-Tagged/";
my $RULE = "baseV";

# entire dir
#opendir SOURCEDIR,"$SOURCEFOLDER" or die "Error opening $SOURCEFOLDER\n";
#my @FILES = readdir(SOURCEDIR);
#close SOURCEDIR;

# certain files
my @FILES = ("fieldnames");

open OUTPUT,">$OUTFOLDER$RULE-starts" or die "Error opening $OUTFOLDER$RULE-starts\n";

my ($line, $phrase);
my $filename;
foreach $filename (@FILES) {
  open SOURCE,"<$SOURCEFOLDER$filename" or die "Error opening $SOURCEFOLDER$filename\n";
  while ( $line = <SOURCE> ) {
    chomp($line);
    if ($line =~ m/^set \(noun, baseV\) [^\(]*\([^\)]*$RULE[^\)]*\)/) {
    	print OUTPUT "$line\n";
    }
  }
  close SOURCE;
}

close OUTPUT;
