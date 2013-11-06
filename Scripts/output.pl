#! /usr/bin/perl

use strict;
use warnings;

my $FILENAME = shift;
my $SOURCEFILE = $FILENAME;
my $OUTFILE = "$FILENAME.out";

open SOURCE,"<$SOURCEFILE" or die "Error opening $SOURCEFILE\n";
open OUTPUT,">$OUTFILE" or die "Error opening $OUTFILE\n";

my $line;
while ($line = <SOURCE>) {
	#$line = <SOURCE>;
	chomp($line);
	print OUTPUT clean($line) . "\n";
	#$line = <SOURCE>;
}

close OUTPUT;
close SOURCE;

sub clean {
	my $line = $_[0];
	$line =~ s/ \(.*?\)//g;
	$line =~ s/:[a-zA-Z\-]*//g;
	return $line;
}
