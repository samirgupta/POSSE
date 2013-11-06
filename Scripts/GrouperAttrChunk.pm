#! /usr/bin/perl -w


package GrouperAttrChunk;

use warnings;
use strict;

### MAIN GROUPING FUNCTION
# Parameters: array of words and their tags
#    as parsed by parser()
# Returns: phrase grouped as string
#####################################################
sub group {
  my $file = shift;
  my $isCons = shift;
  my @phrase = @_;

  # get only phrase without tags
  my $name = "";
	for my $i (0 .. $#phrase) {
		$name .= "$phrase[$i][0] ";
	}
	chomp($name);
  
  my $output = "";

  if (($output = NP(@phrase)) ne "") {
  }
  elsif (($output = adjP(@phrase)) ne "") {
  }
  elsif (($output = NPVP(@phrase)) ne "") {
  }
  elsif (($output = prepP(@phrase)) ne "") {
  }
  elsif (($output = PP(@phrase)) ne "") {
  }
  elsif (($output = VPNP(@phrase)) ne "") {
  }
  elsif (($output = VPNM(@phrase)) ne "") {
  }
  elsif (($output = VPPP(@phrase)) ne "") { # Following order based on sample output
  }
  elsif (($output = VPp(@phrase)) ne "") {
  }
  elsif (($output = VP(@phrase)) ne "") {
  }
  elsif (($output = VPNPprepP(@phrase)) ne "") {
  }
  elsif (($output = VPprepP(@phrase)) ne "") {
  }
  elsif (($output = VPadjP(@phrase)) ne "") {
  }
  elsif (($output = VPNPp(@phrase)) ne "") {
  }
  return "$output";
}

### HELPER FUNCTIONS
########################################################
## HAS FIELD NAME
# Checks if a phrase has a field name in it
# Parameters: file name, tagged & parsed phrase
# Returns: -1, or indices of split
#####
sub hasFieldName {
	my $file = shift;
	$file =~ s/-.*//;
	my $name = shift;
	my @phrase = split(' ',$name);
	
	open FIELDS,"<../9-Names/$file.multifield-names" or die "Error opening ../9-Names/$file.multifield-names\n";
	chomp(my @fields = <FIELDS>);
	close FIELDS;

	my $start = -1;
	my $end = -1;
	for my $field (@fields) {
		if ($name =~ /^(.* )?($field)( .*)?$/) {
			for (my $i=0; $i<@phrase; $i++) {
			  if ($field =~ /^$phrase[$i]/) {
			    $start = $i;
			  }
			  elsif ($field =~ /$phrase[$i]$/ and $i > $start) {
			    $end = $i;
			  }
			  if ($end > 0) {
			    return "$start $end"; 
			  }
			}
		}
	}
	return "-1";
}

### TAGGERS
# Parameters: phrase parsed by parser()
# Returns: grouping as a string
########################################################

## VERB PHRASE
# VP = (baseV|irrV|3PS|ingV|pastV)
# VP = VM+VP
#####
sub VP {
  my @phrase = @_;
  my $size = @phrase;
  if ($size == 1 and isSomeVerb(@{$phrase[0]})) {
    return "[$phrase[0][0]]:VP";
  }
  my $last = pop(@phrase);
  if ($size > 1 and isSomeVerb(@{$last}) and (my $vm = VM(@phrase)) ne "") {return "[$vm @$last[0]]:VP";}
  return "";
}

sub cons {
	my @phrase = @_;
	my $size = @phrase;
	if ($size == 1) {return "[$phrase[0][0]]:NP";}
	my $out = "[$phrase[0][0]";
	for my $i (1 .. $size-2) {
		$out = "$out $phrase[$i][0]";
	}
	$out = "$out]:NM";
	return "[$out $phrase[$size-1][0]]:NP";
}

## NOUN PHRASE
# NP = (noun|plN|ingV)
# NP = NM+NP
# NP = NP+prepP (if prepP starts with "of")
#####
sub NP {
  my @phrase = @_;
  if (!@phrase) { return ""; }
  my @NP;
  my $size = @phrase;
  while (!contains(@{$phrase[0]},"prep") and $size) {
    push @NP, shift(@phrase);
    $size--;
  }
  if (!@NP) { return ""; };
  my $nps = @NP;
  my $np = "";
  if (isSomeNoun(@{$NP[$nps-1]}) or contains(@{$NP[$nps-1]},"ingV")) {
    my $noun = pop(@NP);
    if ($nps == 1) { $np = @$noun[0]; }
    elsif ((my $nm = NM(@NP)) ne "") { $np = "$nm @$noun[0]"; }
  }
  if ($size and $np ne "") {
    if ((my $pP = prepP(@phrase)) ne "" and ($phrase[0][0] eq "of")) { return "[$np $pP]:NP" }
    else { return ""; }
  }
  elsif ($np ne "") { return "[$np]:NP" }
  return "";
}

## PAST PARTICIPLE PHRASE
# PP = pp
# PP = NP+PP
# PP = NP+is+PP
#####
sub PP {
  my @phrase = @_;
  my $size = @phrase;
  my $is = 0;
  if ($size == 0) { return ""; }
  if (contains(@{$phrase[$size-1]},"pp")) {
    if ($size == 1) { return "[$phrase[0][0]]:VP-PP";}
    else {
      my $last = pop(@phrase);
      if ($phrase[$size-2][0] eq "is") {
        $is = 1; 
        pop(@phrase);
      }
      if ((my $out = NP(@phrase)) ne "") {
        if ($is) {return "[$out is @$last[0]]:VP-PP";}
        else {return "[$out @$last[0]]:VP-PP";}
      }
      else { return ""; }
    }
  }
  else { return ""; }
}

## ADJECTIVAL PHRASE
# adjP = adj
# adjP = NP+adjP
######
sub adjP {
  my @phrase = @_;
  my $size = @phrase;
  if ($size == 0) { return ""; }
  elsif (contains(@{$phrase[$size-1]},"adj")) {
    if ($size == 1) { return "[$phrase[0][0]]:adjP";}
    else {
      my $last = pop(@phrase);
      if ((my $out = NP(@phrase)) ne "") {return "[$out @$last[0]]:adjP";}
      else { return ""; }
    }
  }
  else { return ""; }
}

## PREPOSITIONAL PHRASE
# prepP = prep+NP
# prepp = prep+PP
#####
sub prepP {
  my $out;
  my @phrase = @_;
  my $size = @phrase;
  if ($size <= 1) { return ""; }
  my $first = shift(@phrase);
  if (contains(@{$first},"prep") and (($out = NP(@phrase)) ne "" or ($out = PP(@phrase)) ne "")) {return "[@$first[0] $out]:prepP";}
  else { return ""; }
}

## NOUN MODIFIER
# NM = (noun|verb|adj|pp|ingV|quant|pro)*
#####
sub NM {
  my @phrase = @_;
  my $size = @phrase;
  my $tagged = 0;
  my $out = "[";
  if ($size == 0) {return "";}
  for my $k (0 .. $size-1) {
    if (isSomeNoun(@{$phrase[$k]}) or isSomeVerb(@{$phrase[$k]}) or contains(@{$phrase[$k]},"adj") or contains(@{$phrase[$k]},"pp") or contains(@{$phrase[$k]},"ingV") or contains(@{$phrase[$k]},"quant") or contains(@{$phrase[$k]},"pro") or contains(@{$phrase[$k]},"prep")) { 
      if ($tagged) {$out = "$out ";}
      $out = "$out$phrase[$k][0]";
      $tagged = 1;
    }
    else {return "";}
  }
  return "$out]:NM";
}

## VERB MODIFIER
# VM = adv*
#####
sub VM {
  my @phrase = @_;
  my $size = @phrase;
  my $tagged = 0;
  my $out = "[";
  if ($size == 0) {return "";}
  for my $k (0 .. $size-1) {
    if (contains(@{$phrase[$k]},"adv")) { 
      if ($tagged) {$out = "$out ";}
      $out = "$out$phrase[$k][0]";
      $tagged = 1;
    }
    else {return "";}
  }
  return "$out]:VM";
}

### COMBINATIONS
# Combinations of the simple groupings
#####
sub VPNP {
  my @phrase = @_;
  my @vp;
  my $index = -1;
  do {
    push @vp, shift(@phrase);
    $index++
  } while (!isSomeVerb(@{$vp[$index]}) and @phrase);
  if ((my $v = VP(@vp)) ne "" and (my $n = NP(@phrase)) ne "") {
    return "$v $n";
  }
  return "";
}

sub NPVP {
  my @phrase = @_;
  my @vp;
  my $index = @phrase-1;
  do {
    unshift @vp, pop(@phrase);
	$index--;
  } while (@phrase and !isSomeNoun(@{$phrase[@phrase-1]}));
  if ((my $v = VP(@vp)) ne "" and (my $n = NP(@phrase)) ne "") {
    return "$n $v";
  }
  return "";
}

sub VPadjP {
  my @phrase = @_;
  my @vp;
  my $index = -1;
  do {
    push @vp, shift(@phrase);
    $index++
  } while (!isSomeVerb(@{$vp[$index]}) and @phrase);

  if ((my $v = VP(@vp)) ne "" and (my $a = adjP(@phrase)) ne "") {
    return "$v $a";
  }
  return "";
}

sub VPNM {
  my @phrase = @_;
  my @vp;
  my $index = -1;
  my $size = @phrase;
  if ($size == 0) {return "";}
  if (isSomeNoun(@{$phrase[$size-1]})) {return "";}
  do {
    push @vp, shift(@phrase);
    $index++
  } while (!isSomeVerb(@{$vp[$index]}) and @phrase);

  if ((my $v = VP(@vp)) ne "" and (my $n = NM(@phrase)) ne "") {
    return "$v $n";
  }
  return "";
}

sub VPPP {
  my @phrase = @_;
  my @vp;
  my $index = -1;
  do {
    push @vp, shift(@phrase);
    $index++
  } while (!isSomeVerb(@{$vp[$index]}) and @phrase);

  if ((my $v = VP(@vp)) ne "" and (my $p = PP(@phrase)) ne "") {
    return "$v $p";
  }
  return "";
}

sub VPprepP {
  my @phrase = @_;
  my @vp;
  my $index = -1;
  my $prep;
  do {
    push @vp, shift(@phrase);
    $index++
  } while (!isSomeVerb(@{$vp[$index]}) and @phrase);
  
  if ((my $v = VP(@vp)) ne "" and (my $p = prepP(@phrase)) ne "") {
    return "$v $p";
  }
  return "";
}

sub VPNPprepP {
  my @phrase = @_;
  my @vp;
  my @np;
  my $index = -1;
  do {
    push @vp, shift(@phrase);
    $index++
  } while (!isSomeVerb(@{$vp[$index]}) and @phrase);
  my $size = @phrase;
  while (!contains(@{$phrase[0]},"prep") and $size) {
    push @np, shift(@phrase);
    $size--;
  }

  if ((my $v = VP(@vp)) ne "" and (my $n = NP(@np)) ne "" and (my $p = prepP(@phrase)) ne "") {
    return "$v $n $p";
  }
  return "";
}

sub VPp {
  my @phrase = @_;
  my $prep = pop @phrase;
  
  if ((my $v = VP(@phrase)) ne "" and contains(@{$prep},"prep")) {
    return "$v @$prep[0]";
  }
  return "";
}

sub VPNPp {
  my @phrase = @_;
  my @vp;
  my $index = -1;
  my $prep = pop @phrase;
  do {
    push @vp, shift(@phrase);
    $index++
  } while (!isSomeVerb(@{$vp[$index]}) and @phrase);

  if ((my $v = VP(@vp)) ne "" and (my $n = NP(@phrase)) ne "" and contains(@{$prep},"prep")) {
    return "$v $n @$prep[0]";
  }
  return "";
}

# CATEGORIES
sub startsWithIsOrCan {
  my @phrase = @_;
  my $size = @phrase;
  my $second;
  if ($size == 0) { return "";}
  if ($phrase[0][0] ne "is" and $phrase[0][0] ne "can") { return "" };
  my $first = shift(@phrase);
  if (contains(@{$phrase[0]},"ingV") and @$first[0] eq "is") {
    if ($size==2) { return "[is $phrase[0][0]]:VP-ingV"; }
    else {
      my $ing = shift(@phrase);
      if (($second = NP(@phrase)) ne "") {
        return "[is @$ing[0]]:VP-ing $second";
      }
      if (($second = prepP(@phrase)) ne "") {
        return "[is @$ing[0]]:VP-ing $second";
      }
    }
  }
  if (contains(@{$phrase[0]},"baseV") and @$first[0] eq "can") {
    if ($size==2) { return "[can $phrase[0][0]]:VP"; }
    else {
      my $base = shift(@phrase);
      if (($second = NP(@phrase)) ne "") {
        return "[can @$base[0]]:VP $second";
      }
      if (($second = prepP(@phrase)) ne "") {
        return "[can @$base[0]]:VP $second";
      }
    }
  }
  if (($second = PP(@phrase)) ne "") {
    return "[@$first[0]]:VP $second";
  }
  if (($second = adjP(@phrase)) ne "") {
    return "[@$first[0]]:VP $second";
  }
  if (($second = NP(@phrase)) ne "") {
    return "[@$first[0]]:VP $second";
  }
  if (($second = NM(@phrase)) ne "") {
    return "[@$first[0]]:VP $second";
  }
  return "";
}

### HELPER FUNCTIONS
# 
#####

## CONTAINS
# Parameters: array of word and its tags, and a tag
#   to check for
# Returns: true if tag is in list of tags, false otherwise
######
sub contains {
  my $word = pop @_;
  for (@_) {
    if ($_ eq $word) {return 1;}
  }
  return 0;
}

## IS SOME VERB
# Parameters: word and its tags
# Returns: true of word is baseV, irV, or 3PS
#####
sub isSomeVerb {
  if (contains(@_, "baseV") or contains(@_, "irV") or contains(@_, "3PS")) {
    return 1;
  }
  return 0;
}

## IS SOME NOUN
# Parameters: word and its tags
# Returns: true if word is noun or plN
#####
sub isSomeNoun {
  if (contains(@_, "noun") or contains(@_, "plN") or contains(@_,"quant") or contains(@_,"pro")) {
    return 1;
  }
  return 0;
}

## PARSE PHRASE
# Parameters: phrase in form "word (tag, tag, tag) word (tag, tag, tag)"
# Returns: an array in form [[word tag tag tag] [word tag tag tag]]  
#####
sub parsePhrase {
  my $line = $_[0];
  my (@words, @word);
  while ($line) {
    $line =~ /(.*?) \((.*?)\) (.*)/;
    @word = ($1,split(', ',$2));
    push @words, [ @word ];
    $line = $3;
  }	
  return @words;
}

1;
__END__
