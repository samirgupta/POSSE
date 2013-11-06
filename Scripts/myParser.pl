#! /usr/bin/perl 

use strict;
use warnings;
use File::Basename;

use Tagger;
use Grouper;

my $FILENAME = $Tagger::FILENAME;
my $basename = basename($FILENAME);

open(SOURCE,'<',$FILENAME) or die "Error opening \"$FILENAME\": $!";
open(OUTPUT,'>',"../SampleOutput/$basename") or die "Error opening \"../8-Output/$basename\": $!\n";
open(PHRASES,'>',"../SampleNames/$basename.class-names") or die "Error opening \"../9-Names/$basename.class-names\": $!\n";

my ($line, $fullName, $splitName, $taggedName, $groupedName, @phrase);

while ($line = <SOURCE>) {
	chomp($line);
	$line =~ /^(.*) \| (.*)$/;
	$fullName = $1;
	$splitName = $2;
	my $isCons = ($fullName =~ m/^CONS /) ? 1 : 0;
	if ($isCons) { print PHRASES "$splitName\n"; }
	$taggedName = Tagger::tagPhrase($splitName);
	@phrase = Grouper::parsePhrase($taggedName);
	$groupedName = Grouper::group($basename,$isCons,@phrase);
	print OUTPUT "/--- $fullName\n";
	print OUTPUT "| $taggedName \n";
	print OUTPUT "| $groupedName \n";
	print OUTPUT "\\---\n\n";
	#$taggedName = Tagger::tagPhrase($line);
	#print OUTPUT "$taggedName\n";
}

close SOURCE;
close OUTPUT;
