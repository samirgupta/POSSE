#! /usr/bin/perl 


package Tagger;

use warnings;
use strict;
use File::Basename;

##### SOURCE AND OUTPUT FILES
our $FILENAME = shift;
my $base = basename($FILENAME);
my $DICTIONARY = "../Dictionaries/dictionary-allwords";
my $PREPOSITIONS = "../Dictionaries/preposition";
my $QUANTIFIERS = "../Dictionaries/quant";
my $IRREGULARV = "../Dictionaries/irregV";
my $ADJECTIVES = "../Dictionaries/adjective";
my $ADVERBS = "../Dictionaries/adverb";
my $PARTICIPLES = "../Dictionaries/participle";
my $NOUNS = "../Dictionaries/noun";
my $VERBS = "../Dictionaries/verb";
my $PRONOUNS = "../Dictionaries/pronoun";
my $DEPENDS = "../Dictionaries/dlist";
my $NORULE = "../Dictionaries/norule";
my $NABBRS = "../Dictionaries/n-abbr";

##### CLOSED LISTS

open SOURCE,"<$FILENAME" or die "Error opening $$FILENAME\n";
my ($line, @split, $SOURCE);
foreach $line (<SOURCE>) {
  @split = split(/ \| /,$line);
  $SOURCE .= pop @split;
}
close SOURCE;

open DICTIONARY,"<$DICTIONARY" or die "Error opening $DICTIONARY\n";
my $DICT = join('',<DICTIONARY>);
close DICTIONARY;

open PREP,"<$PREPOSITIONS" or die "Error opening $PREPOSITIONS\n";
my $PREP = join('',<PREP>);
close PREP;

open QUANT,"<$QUANTIFIERS" or die "Error opening $QUANTIFIERS\n";
my $QUANT = join('',<QUANT>);
close QUANT;

open IRRV,"<$IRREGULARV" or die "Error opening $IRREGULARV\n";
my $IRRV = join('',<IRRV>);
close IRRV;

open PRON,"<$PRONOUNS" or die "Error opening $PRONOUNS\n";
my $PRON = join('',<PRON>);
close PRON;

open NABBR,"<$NABBRS" or die "Error opening $NABBRS\n";
my $NABBR = join('',<NABBR>);
close NABBR;

# Irregular past participles
open PP,"<$PARTICIPLES" or die "Error opening $PARTICIPLES\n";
my $PP = join('',<PP>);
close PP;

##### OPEN LISTS
# Reading
open NOUN,"$NOUNS" or die "Error opening $NOUNS\n";
chomp(my @NOUN = <NOUN>);
close NOUN;

open VERB,"$VERBS" or die "Error opening $VERBS\n";
chomp(my @VERB = <VERB>);
close VERB;

open ADJ,"$ADJECTIVES" or die "Error opening $ADJECTIVES\n";
chomp(my @ADJ = <ADJ>);
close ADJ;

open ADV,"$ADVERBS" or die "Error opening $ADVERBS\n";
chomp(my @ADV = <ADV>);
close ADV;



open NORULE,">>$NORULE" or die "Error opening $NORULE\n";
chomp(my @NORULE = <NORULE>);
close NORULE;

##### HELPER FUNCTIONS
sub isWord {
  my $word = shift;
  if ($SOURCE =~ /\s$word\s/) {
    return 1;
  }
 elsif ($DICT =~ /\s$word\s/) {
    return 1;
  }
  else {
    return 0;
  }
}

sub isWordInFile {
  my $word = shift;
  my @list = @_;
  for my $entry (@list) {
    if ($entry eq $word) {
      return 1;
    }
  }
  return 0;
}

sub tag {
  my ($tagged, $label, $output) = @_;
  if ($tagged) { $output .= ", "; }
  else { $tagged = 1; }
  $output .= $label;
  return ($tagged, $output);
}

sub hasVerbPrefix { 
  my $word = $_[0];
  if ($word =~ m/^(re|en)(.*)/) {
    return 1;
  }
  else {
    return 0;
  }
}

sub hasVerbSuffix {
  my $word = $_[0];
  if ($word =~ m/(.*)(ize|ify)$/ and length($1) > 2) {
    return 1;
  }
  else {
    return 0;
  }
}

##### TAGGER
sub tagPhrase {
  my $toSplit = shift;
  chomp($toSplit);
  my @phrase = split(" ",$toSplit);
  chomp @phrase;
  my $tagged;
  my $output = "";
  foreach my $word (@phrase) {
    $word = lc($word);	
    $tagged = 0;
    $output .= "$word (";
    if (isArticle($word)) {
      $output .= ") ";
      next;
    }
    if (isPreposition($word)) {
      ($tagged, $output) = tag($tagged, "prep", $output);
      $output .= ") ";
      next;
    }
    if (isQuantifier($word)) {
      ($tagged, $output) = tag($tagged, "quant", $output);
      $output .= ") ";
      next;
    }
    if (isIrregularV($word)) {
      ($tagged, $output) = tag($tagged, "irV", $output);
   #   $output .= ") ";
    #  next;
    }
    if (isAdverb($word)) {
      ($tagged, $output) = tag($tagged, "adv", $output);
    }
    if (isPronoun($word)) {
      ($tagged, $output) = tag($tagged, "pro", $output);
    }
    if (isAdjective($word)) {
      ($tagged, $output) = tag($tagged, "adj", $output);
    }
    if (isNoun($word)) {
      ($tagged, $output) = tag($tagged, "noun", $output);
    }
    if (isPlNoun($word)) {
      ($tagged, $output) = tag($tagged, "plN", $output);
    }
    if (is3PS($word)) {
      ($tagged, $output) = tag($tagged, "3PS", $output);
    }
    if (isBaseVerb($word)) {
      ($tagged, $output) = tag($tagged, "baseV", $output);
    }
    if (isIngVerb($word)) {
      ($tagged, $output) = tag($tagged, "ingV", $output);
    }
    if (isPastVerb($word)) {
      ($tagged, $output) = tag($tagged, "pastV", $output);
    }
    if (isPP($word)) {
      ($tagged, $output) = tag($tagged, "pp", $output);
    }
    if (!$tagged) {
      ($tagged, $output) = tag($tagged, "noun", $output);
      if (!isWordInFile($word, @NORULE)) {
		push @NORULE, $word;
      }
    }
    $output .= ") ";
  }
  return $output;
}

##### POS IDENTIFIERS
# closed
sub isArticle {
  my $word = shift;
  if ($word =~ /^(the|an?)$/) {
    return 1;
  }
  else {
    return 0;
  }
}
sub isPreposition {
  if ($PREP =~ /\s$_[0]\s/) {
    return 1;
  }
  else {
    return 0;
  }
}

sub isPronoun {
  if ($PRON =~ /\s$_[0]\s/) {
    return 1;
  }
  else {
    return 0;
  }
}

sub isQuantifier {
  if ($QUANT =~ /\s$_[0]\s/) {
    return 1;
  }
  else {
    return 0;
  }
}

####WordNetTypeCheck#####
sub isWordNetType {
  my $word = $_[0];
  my @output = `./getWordNetType.sh $word`;
  foreach my $out (@output)
  {
    if($out =~ m/adj|noun|verb|adv/) {
        return 1;
    }
  }
  return 0;
}
####ADJECTIVE####

####ADJECTIVE####
sub isWordNetTypeAdj {
  my $word = $_[0];
  my @output = `./getWordNetType.sh $word`;
  foreach my $out (@output)
  {
    if($out =~ m/adj/) {
        push @ADJ, $word;
        return 1;
    }
  }
  return 0;
}
####ADJECTIVE####

####ADVERB####
sub isWordNetTypeAdv {
  my $word = $_[0];
  my @output = `./getWordNetType.sh $word`;
  foreach my $out (@output)
  {
    if($out =~ m/adv/) {
        push @ADV, $word;
        return 1;
    }
  }
  return 0;
}
####ADVERB####

####VERB####
sub isWordNetTypeBaseVerb {
  my $word = $_[0];
  my @output = `./getWordNetType.sh $word`;
  foreach my $out (@output)
  {
    if($out =~ m/verb/) {
        push @VERB, $word;
        return 1;
    }
  }
  return 0;
}
####VERB####

####NOUN####
sub isWordNetTypeNoun {
  my $word = $_[0];
  my @output = `./getWordNetType.sh $word`;
  foreach my $out (@output)
  {
    if($out =~ m/noun/) {
        push @NOUN, $word;
        return 1;
    }
  }
  return 0;
}
####NOUN####

####WordNetTypeCheck#####

# adjectives
sub isAdjective {
  my $word = $_[0];
  my $original = $word;

  if (isWordInFile($word, @ADJ)) {
    return 1;
  }

  ##WORDNET CHECK####
  if (isWordNetTypeAdj($word)) {
    return 1;
  }
  if (isWordNetType($word)) {
    return 0;
  }
  ##WORDNET CHECK####
  
  if ($word =~ m/(.*)able$/ and length($1) > 3) {
    push @ADJ, $original;
    return 1;
  }
  if ($word =~ m/^(.*)er$/ or $word =~ m/^(.*)est$/) {
    my $base = $1;
    $base =~ s/i$/y/;
    $base =~ s/(.)\1$/$1/; # double letter
    if (isAdjective($base)) { return 1; }
  }
  $word =~ s/([^aeiou])y$/$1i/;
  if (isWord($word . "ly") or isWord($word . "ness")) {
    push @ADJ, $original;
    return 1;
  }
  else {
    return 0;
  }
}

# nouns
sub isNoun {
  my $word = $_[0];
  my $original = $word;
  
  if (isWordInFile($original, @NOUN)) {return 1;}
  #if (length($word) == 1) { return 1; }  

  ##WORDNET CHECK####
  if (isWordNetTypeNoun($word)) {
    return 1;
  }
  if (isWordNetType($word)) {
    return 0;
  }
  ##WORDNET CHECK####
  

  #if (!isWord($word)) { return 0; }
  if (isWord($word . "ence") or isWord($word . "ance")) {return 0;}
  if ($NABBR =~ /\s$word\s/) { return 1;}
  elsif (isIrregularV($word)) {return 0;}
  #if (hasVerbPrefix($word) or hasVerbSuffix($word)) { return 0;	}
  
  if ($word =~ /(.+)(ity|tion|is[tm]|ness|or)$/) {
    push @NOUN, $original;
    return 1;
  }
  $word =~ s/([^aeiou])y$/$1i/;
  if ($word =~ /(i|s|ch|x|z|sh)$/ and isWord($word . "es")) {
    push @NOUN, $original;
    return 1;
  }
  if (isWord($original . "s")) {
    push @NOUN, $original;
    return 1;
  }
  else {
    return 0;
  }
}


sub isPlNoun {
  my $word = $_[0];
  my $base;
  if ($word =~ m/(.*)es$/) {
    $base = $1;
    $base =~ s/([^aeiou])i$/$1y/;
    if (isNoun($base) and $base =~ /(y|s|ch|x|z|sh)$/) {
      return 1;
    }
  }
  ##CHANGED
  if ($word =~ m/(.*[^sui])s$/ and length($1) > 2 and isWordNetTypeNoun($1)) {
    return 1;
  }
  ##CHANGED
  if ($word =~ m/(.*[^sui])s$/ and length($1) > 3) {
    $base = $1;
    if (isNoun($base)) {
      return 1;
    }
  }
  else {
    return 0;
  }
}

# verbs
sub isBaseVerb {
  my $word = $_[0];
  my $original = $word;
  if (isWordInFile($original, @VERB)) { return 1; }
  if (isIrregularV($word)) { return 0; }
  

  ##WORDNET CHECK####
  if (isWordNetTypeBaseVerb($word)) {
    return 1;
  }
  if (isWordNetType($word)) {
    return 0;
  }
  ##WORDNET CHECK####
  
  if (!isWord($original) or length($original) < 2) {return 0;}
  if (hasVerbPrefix($word) and isBaseVerb(substr($word,2))) { return 1; }
  if (hasVerbSuffix($word)) { return 1;}
  my $double = $word;
  if ($word =~ m/[aeiou][ngdtlp]$/){$double = $word . substr($word,-1);}
  elsif ($word =~ /([^ey])e$/) {$word =~ s/e$//;}
  elsif ($word =~ m/y$/) {$word =~ s/y$/i/;}
  if (isWord($word . "s") or isWord($word. "es") or isWord($double . "es")) {
    if (isWord($word . "ing") or isWord($double . "ing")) {
		push @VERB, $original;
      return 1;
    }
    if (isWord($word . "ed") or isWord($double . "ed")) {
      push @VERB, $original;
      return 1;
    }
  }
  else {
    return 0;
  }
}

sub is3PS {
  my $word = $_[0];
  my $base;
  if ($word =~ m/(.*[^sui])s$/) {
    $base = $1;
    $base =~ s/ie$/y/;
    if (isBaseVerb($base)) {
      return 1;
    }
  }
  else {
    return 0;
  }
}

sub isIngVerb {
	my $word = $_[0];
	if ($word =~ /(.*)ing$/ and isBaseVerb($1)) {
	  return 1;
	}
	else {
		return 0;
	}
}

sub isIrregularV {
	if ($IRRV =~ /\s$_[0]\s/) {
		return 1;
	}
	else {
		return 0;
	}
}

sub isPP {
  my $word = $_[0];
  if ($word =~ m/(.*)e[nd]$/) {
    my $base = $1;
    $base =~ s/i$/y/;
    if (isBaseVerb($base) or isBaseVerb($base . "e") or isBaseVerb(substr($base,0,-1))) {
	return 1;
    }
  }
  elsif ($PP =~ m/\s$word\s/) {
    return 1;
  }
  else {
    return 0;
  }
}

sub isPastVerb {
 	my $word = $_[0];
	if ($word =~ /(.*)ed$/ and isBaseVerb($1)) {
		return 1;
  }
	else {
		return 0;
	}
}

# adverbs
sub isAdverb {
  my $word = $_[0];
  
  if (isWordInFile($word, @ADV)) {
	  return 1;
  }
  

  ##WORDNET CHECK####
  if (isWordNetTypeAdv($word)) {
    return 1;
  }
  if (isWordNetType($word)) {
    return 0;
  }
  ##WORDNET CHECK####
  

  if ($word =~ m/(.*)ly$/) {
    my $base = $1;
    $base =~ s/i$/y/;
    if (isWord($base)) {
      push @ADV, $word;
      return 1;
    }
  }
  return 0;
}

##### CLOSING
#close OUTPUT;
#close SOURCE;

# Writing
open NOUN,">$NOUNS" or die "Error opening $NOUNS\n";
print NOUN join("\n",@NOUN);
close NOUN;

open VERB,">$VERBS" or die "Error opening $VERBS\n";
print VERB join("\n",@VERB);
close VERB;

open ADJ,">$ADJECTIVES" or die "Error opening $ADJECTIVES\n";
print ADJ join("\n",@ADJ);
close ADJ;

open ADV,">$ADVERBS" or die "Error opening $ADVERBS\n";
print ADV join("\n",@ADV);
close ADV;

open NORULE,">$NORULE" or die "Error opening $NORULE\n";
print NORULE join("\n",@NORULE);
close NORULE;


1;
__END__
