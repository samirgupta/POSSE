#! /usr/bin/perl

use strict;
use warnings;
use File::Basename;

open(SOURCE,'<',"./words.txt") or die "Read File Opening Error!!";
open(OUTPUT,'>',"./analysis.txt") or die "Write File Opening Error!!";

my $word;
print OUTPUT "WORD,SCORE,METHOD.START,METHOD.START.TUPLE\n";
while ($word = <SOURCE>) {
    $word =~ s/\n//;

    my $methodStart = `wc -l normal-top/$word.methods.start |cut -d " " -f 1`;
    my $methodStartTuple = `wc -l SampleOutput/$word.methods.start |cut -d " " -f 1`;
    
    $methodStart =~ s/\n//;
    $methodStartTuple =~ s/\n//;
    my $score = 0;
    if ($methodStartTuple > 0)
    {
        $score = $methodStartTuple/$methodStart;
    }
    print OUTPUT "$word,$score,$methodStart,$methodStartTuple\n";
}

close SOURCE;
close OUTPUT;

