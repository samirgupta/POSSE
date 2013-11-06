#! /usr/bin/perl

use strict;
use warnings;
use Switch;

my $SOURCEFOLDER = "../1-Source/Source Code/";
#my $SOURCEFILE = shift;
my $OUTFOLDER = "../1-Source/";

opendir SOURCEDIR,"$SOURCEFOLDER" or die "Error opening $SOURCEFOLDER\n";
my @FILES = grep(/\.all-methods/,readdir(SOURCEDIR));
close SOURCEDIR;

my ($line, $method, $piece);

sub getGiriType {
  my $str = $_[0];
  my $ret = "";
  while ($str =~ m/^\[/) { $ret = "[]$ret"; $str =~ s/^\[//;}
  if ($str =~ m/Q(.*);/) { return "$1$ret"; }
  elsif ($str eq "Z") {return "boolean$ret";}
  elsif ($str eq "I") {return "int$ret"; }
  elsif ($str eq "V") {return "void$ret"; }
  elsif ($str eq "B") {return "byte$ret"; }
  elsif ($str eq "F") {return "float$ret"; }
  elsif ($str eq "D") {return "double$ret"; }
  elsif ($str eq "J") {return "long$ret"; }
  elsif ($str eq "S") {return "short$ret"; }
  elsif ($str eq "C") {return "char$ret"; }
  else { return "UNKNOWN$ret"; }
}

foreach my $filename (@FILES) {
  open SOURCE,"<$SOURCEFOLDER$filename" or die "Error opening $SOURCEFOLDER$filename\n";
  $filename =~ /(.*).all-methods/;
  open OUTPUT,">$OUTFOLDER$1" or die "Error opening $OUTFOLDER$1\n";
  while ( $line = <SOURCE> ) {
    chomp($line);
    # SPLIT
 	  #$line =~ s/([\(\)A-Z\|]+|\[.*\])//g;
    #$line =~ /.*: (.*)/;

    # UNSPLIT
  	#$line =~ /.*? (\w+?)\(/;
  
    # GIRI 
    if ($line =~ m/^-----/) {
      $line =~ /^(.*\.)?(.*)\.(\S*\(.*\)\S*)\s*C-Units/;
      my $classname = $2;
      my $fullsig = $3;
      $fullsig =~ /(.*\))(.*)/;
      my $methodsig = $1;
      my $ret = $2;
      $methodsig =~ /^(.*)\(/;
      my $methodname = $1;
      if ($classname eq $methodname) { $ret = "CONS" }
      else { $ret = getGiriType($ret); }
      print OUTPUT "$ret $methodsig\n";
    }
    
    # EMILY
    #if ($line =~ m/^.*:.*:.*? (.*):.*$/) {
    #  print OUTPUT "$1\n";
    #}
  }
  close SOURCE;
  close OUTPUT;
}
