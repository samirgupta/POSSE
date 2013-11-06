#! /usr/bin/perl 

use strict;
use warnings;
use File::Basename;

use Tagger;
use Grouper;
use GrouperAttr;

my $FILENAME = $Tagger::FILENAME;
my $basename = basename($FILENAME);
my $nameID = shift;

open(SOURCE,'<',$FILENAME) or die "Error opening \"$FILENAME\": $!";
open(OUTPUT,'>',"../Output/$basename.pos") or die "Error opening \"../Output/$basename\": $!\n";

my ($line, $fullName, $splitName, $taggedName, $groupedName, @phrase);
while ($line = <SOURCE>) {
    chomp($line);
    $line =~ /^(.*) \| (.*)$/;
    $fullName = $1;
    $splitName = $2;
    my $isCons = ($fullName =~ m/^CONS /) ? 1 : 0;
    my $isboolean = ($fullName =~ m/^boolean /) ? 1 : 0;
    my $isbool = ($fullName =~ m/^bool /) ? 1 : 0;
    $taggedName = Tagger::tagPhrase($splitName);
    @phrase = Grouper::parsePhrase($taggedName);
    if($nameID eq "M")
    {
        print "Method Name: $fullName\n";
        $groupedName = Grouper::group($basename,$isCons,@phrase);
    }
    elsif($nameID eq "C")
    {
        print "Class Name: $fullName\n";
        $groupedName = GrouperAttr::group($basename,$isCons,@phrase);
    }
    elsif($nameID eq "A" )
    {
         if($isbool == 1 or $isboolean == 1)
         {
             print "Bool Attr Name: $fullName\n";
             $groupedName = Grouper::group($basename,$isCons,@phrase);
         }
        else
        {
            print "Non-Bool Attr Name: $fullName\n";
            $groupedName = GrouperAttr::group($basename,$isCons,@phrase);
        }
    
    }
    print OUTPUT "$fullName | ";
    #print OUTPUT "| $taggedName \n";
    print OUTPUT "$groupedName\n";
    #print OUTPUT "\\---\n\n";
    #$taggedName = Tagger::tagPhrase($line);
    #print OUTPUT "$taggedName\n";
    #print OUTPUT "\n";
    #print OUTPUT "\\---\n\n";
}

close SOURCE;
close OUTPUT;
