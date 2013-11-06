#!/usr/bin/perl -w
#
# Perl implementation of the porter stemming algorithm
# described in the paper: "An algorithm for suffix stripping, M F Porter"
# http://www.muscat.com/~martin/stem.html
#
# Daniel van Balen (vdaniel@ldc.usb.ve)
#
# October-1999
#
# To Use:
#
# Put the line "use porter;" in your code. This will import the subroutine 
# porter into your current name space (by default this is Main:: ). Make 
# sure this file, "porter.pm" is in your @INC path (it includes the current
# directory).
# Afterwards use by calling "porter(<word>)" where <word> is the word to strip.
# The stripped word will be the returned value.
#
# REMEMBER TO CHANGE THE FIRST LINE TO POINT TO THE PATH TO YOUR PERL 
# BINARY
#



# We need the lookbehind re operator "(?<= ... )" and "(?<! ... )" only in
# >= perl5.005
require 5.005;



sub porter{
  # First and only argument. The word to be stemmed. should be lower-case
  # an "i" could be apended to the regular expresions to make them case
  # insensitive.
  my $word=shift;

  if(length($word)>2){
    # This is a consonant. Not "aiueo" and "y" only if preceded by a vowel
    my $c='(?:[^aiueoy]|(?:(?<=[aiueo])y)|\by)'; #reconoce una consonante
    
    # This is a vowel. "aiueo" and "y" if preceded by a consonant
    my $v='(?:[aiueo]|(?:(?<![aiueo])y))';   #reconoce una vocal

    my $extra=0;
    
    # The re "/^(?:$c+)?(?:$v+$c+){m}(?:$v+)?$/" is [C](VC)**m[V] in perl
    # Matches if (m > 0)
    my $m_gt_0 = "^(?:$c+)?(?:$v+$c+){1,}(?:$v+)?\$";
    # Matches if (m > 1)
    my $m_gt_1 = "^(?:$c+)?(?:$v+$c+){2,}(?:$v+)?\$";
    # Matches if (m = 1)
    my $m_eq_1="^(?:$c+)?(?:$v+$c+){1}(?:$v+)?\$";

    # Matches *o
    my $o="$c$v(?:[^aiueowxy])\$";

    # Matches *d
    my $d="($c)\\1\$";

    #STEP 1a
    if($word =~ /(.+)sses$/){
      $word=$1."ss";
    }
    elsif($word =~ /(.+)ies$/){
      $word=$1."i";
    }
    elsif($word =~ /(.+[^s])s$/){              # engloba 2 ultimas reglas de 1a
      $word=$1;                                # Same as last 2 rules of 1a
    }
    
    #STEP 1b
    if($word =~ /(.+)eed$/) {
      if (($w=$1) =~ /$m_gt_0/o){
	$word=$w."ee";
      }
    }
    elsif($word =~ /(.+)ed$/) {
      if (($w=$1) =~ /$v/o) {
	$word=$w;
	$extra=1;
      }
    }
    elsif($word =~ /(.+)ing$/){
      if(($w=$1) =~ /$v/o) {
	$word=$w;
	$extra=1;
      }
    }
    
    # If 2nd or 3rd of the previous rules was successful try the extra rules...
    
    #Si aplicaron alguna de las dos ultimas reglas de "1b" hacemos las siguientes
    if($extra){
      if($word =~ /(.+)at$/){
	$word=$1."ate";
      }
      elsif($word =~ /(.+)bl$/){
	$word=$1."ble";
      }
      elsif($word =~ /(.+)iz$/){
	$word=$1."ize";
      }
      # (*d and not (*L or *S or *Z)) --> single letter
      elsif(($word =~ /$d/o) and ($word !~ /[lsz]$/)){
	$word=substr($word,0,-1);
      }
      # (m=1 and *o) --> E
      elsif(($word =~ /$m_eq_1/o) and ($word =~ /$o/o)){
	$word.='e';
      }
    }
    
    # STEP 1c
    if($word =~ /(.+)y$/){
      if (($w=$1) =~ /$v/o){
	$word=$w."i";
      }
    }
    
    #STEP 2 con crazy performance hack descrito en paper
    
    # To speed up the algorithm we do a switch on the penultimate letter of the
    # word being tested. Same for steps 3 and  4.
    
    my $letter=substr($word,-2,1);
    if($letter eq "a"){
      if($word =~ /(.+)ational$/){ 
	if(($w=$1) =~ /$m_gt_0/o){
	  $word=$w."ate";
	}
      }
      elsif($word =~ /(.+)tional$/){
	if(($w=$1) =~ /$m_gt_0/o){
	  $word=$w."tion";
	}
      }
    }
    elsif($letter eq "c"){
      if($word =~ /(.+)enci$/) {
	if(($w=$1) =~ /$m_gt_0/o){
	  $word=$w."ence";
	}
      }
      elsif($word =~ /(.+)anci$/) {
	if(($w=$1) =~ /$m_gt_0/o){
	  $word=$w."ance";
	}
      }
    }
    elsif($letter eq "e"){
      if($word =~ /(.+)izer$/) { 
	if(($w=$1) =~ /$m_gt_0/o){
	  $word=$w."ize";
	}
      }
    }
    #NEW RULE SEE "http://www.muscat.com/~martin/stem.html"
    elsif($letter eq "g"){
      if($word =~ /(.+)logi$/) {
	if(($w=$1) =~ /$m_gt_0/o){
	  $word=$w."log";
	}
      }
    }
    elsif($letter eq "l"){
      #RULE CHANGED SEE "http://www.muscat.com/~martin/stem.html"
      if($word =~ /(.+)bli$/) {
	if(($w=$1) =~ /$m_gt_0/o){
	  $word=$w."ble";
	}
      }
      elsif($word =~ /(.+)alli$/) {
	if(($w=$1) =~ /$m_gt_0/o){
	  $word=$w."al";
	}
      }
      elsif($word =~ /(.+)entli$/) {
	if(($w=$1) =~ /$m_gt_0/o){
	  $word=$w."ent";
	}
      }
      elsif($word =~ /(.+)eli$/) {
	if(($w=$1) =~ /$m_gt_0/o){
	  $word=$w."e";
	}
      }
      elsif($word =~ /(.+)ousli$/) {
	if(($w=$1) =~ /$m_gt_0/o){
	  $word=$w."ous";
	}
      }
    }
    elsif($letter eq "o"){
      if($word =~ /(.+)ization$/) {
	if(($w=$1) =~ /$m_gt_0/o){
	  $word=$w."ize";
	}
      }
      elsif($word =~ /(.+)ation$/) {
	if(($w=$1) =~ /$m_gt_0/o){
	  $word=$w."ate";
	}
      }
      elsif($word =~ /(.+)ator$/) {
	if(($w=$1) =~ /$m_gt_0/o){
	  $word=$w."ate";
	}
      }
    }
    elsif($letter eq "s"){
      if($word =~ /(.+)alism$/) {
	if(($w=$1) =~ /$m_gt_0/o){
	  $word=$w."al";
	}
      }
      elsif($word =~ /(.+)iveness$/) {
	if(($w=$1) =~ /$m_gt_0/o){
	  $word=$w."ive";
	}
      }
      elsif($word =~ /(.+)fulness$/) {
	if(($w=$1) =~ /$m_gt_0/o){
	  $word=$w."ful";
	}
      }
      elsif($word =~ /(.+)ousness$/) {
	if(($w=$1) =~ /$m_gt_0/o){
	  $word=$w."ous";
	}
      }
    }
    elsif($letter eq "t"){
      if($word =~ /(.+)aliti$/) {
	if(($w=$1) =~ /$m_gt_0/o){
	  $word=$w."al";
	}
      }
      elsif($word =~ /(.+)iviti$/) {
	if(($w=$1) =~ /$m_gt_0/o){
	  $word=$w."ive";
	}
      }
      elsif($word =~ /(.+)biliti$/) {
	if(($w=$1) =~ /$m_gt_0/o){
	  $word=$w."ble";
	}
      }
    }
    
    
    #STEP 3
    $letter=substr($word,-1,1);
    if($letter eq "e"){
      if($word =~ /(.+)icate$/) {
	if(($w=$1) =~ /$m_gt_0/o){
	  $word=$w."ic";
	}
      }
      elsif($word =~ /(.+)ative$/) {
	if(($w=$1) =~ /$m_gt_0/o){
	  $word=$w;
	}
      }
      elsif($word =~ /(.+)alize$/) {
	if(($w=$1) =~ /$m_gt_0/o){
	  $word=$w."al";
	}
      }
    }
    elsif($letter eq "i"){
      if($word =~ /(.+)iciti$/) {
	if(($w=$1) =~ /$m_gt_0/o){
	  $word=$w."ic";
	}
      }
    }
    elsif($letter eq "l"){
      if($word =~ /(.+)ical$/) {
	if(($w=$1) =~ /$m_gt_0/o){
	  $word=$w."ic";
	}
      }
      elsif($word =~ /(.+)ful$/) {
	if(($w=$1) =~ /$m_gt_0/o){
	  $word=$w;
	}
      }
    }
    elsif($letter eq "s"){
      if($word =~ /(.+)ness$/) {
	if(($w=$1) =~ /$m_gt_0/o){
	  $word=$w;
	}
      }
    }
    
    #STEP 4
    $letter=substr($word,-2,1);
    if($letter eq "a"){
      if($word =~ /(.+)al$/) {
	if(($w=$1) =~ /$m_gt_1/o){
	  $word=$w;
	}
      }
    }
    elsif($letter eq "c"){
      if($word =~ /(.+)ance$/) {
	if(($w=$1) =~ /$m_gt_1/o){
	  $word=$w;
	}
      }
      elsif($word =~ /(.+)ence$/) {
	if(($w=$1) =~ /$m_gt_1/o){
	  $word=$w;
	}
      }
    }
    elsif($letter eq "e"){
      if($word =~ /(.+)er$/) {
	if(($w=$1) =~ /$m_gt_1/o){
	  $word=$w;
	}
      }
    }
    elsif($letter eq "i"){
      if($word =~ /(.+)ic$/) {
	if(($w=$1) =~ /$m_gt_1/o){
	  $word=$w;
	}
      }
    }
    elsif($letter eq "l"){
      if($word =~ /(.+)able$/) {
	if(($w=$1) =~ /$m_gt_1/o){
	  $word=$w;
	}
      }
      elsif($word =~ /(.+)ible$/) {
	if(($w=$1) =~ /$m_gt_1/o){
	  $word=$w;
	}
      }
    }
    elsif($letter eq "n"){
      if($word =~ /(.+)ant$/) {
	if(($w=$1) =~ /$m_gt_1/o){
	  $word=$w;
	}
      }
      elsif($word =~ /(.+)ement$/) {
	if(($w=$1) =~ /$m_gt_1/o){
	  $word=$w;
	}
      }
      elsif($word =~ /(.+)ment$/) {
	if(($w=$1) =~ /$m_gt_1/o){
	  $word=$w;
	}
      }
      elsif($word =~ /(.+)ent$/) {
	if(($w=$1) =~ /$m_gt_1/o){
	  $word=$w;
	}
      }
    }
    elsif($letter eq "o"){
      if($word =~ /(.+)ion$/) { 
	if((($w=$1) =~ /[st]$/) and ($w =~ /$m_gt_1/o)){
	  $word=$w;
	}
      }
      elsif($word =~ /(.+)ou$/) {
	if(($w=$1) =~ /$m_gt_1/o){
	  $word=$w;
	}
      }
    }
    elsif($letter eq "s"){
      if($word =~ /(.+)ism$/) {
	if(($w=$1) =~ /$m_gt_1/o){
	  $word=$w;
	}
      }
    }
    elsif($letter eq "t"){
      if($word =~ /(.+)ate$/) {
	if(($w=$1) =~ /$m_gt_1/o){
	  $word=$w;
	}
      }
      elsif($word =~ /(.+)iti$/) {
	if(($w=$1) =~ /$m_gt_1/o){
	  $word=$w;
	}
      }
    }
    elsif($letter eq "u"){
      if($word =~ /(.+)ous$/) {
	if(($w=$1) =~ /$m_gt_1/o){
	  $word=$w;
	}
      }
    }
    elsif($letter eq "v"){
      if($word =~ /(.+)ive$/) {
	if(($w=$1) =~ /$m_gt_1/o){
	  $word=$w;
	}
      }
    }
    elsif($letter eq "z"){
      if($word =~ /(.+)ize$/) {
	if(($w=$1) =~ /$m_gt_1/o){
	  $word=$w;
	}
      }
    }
    
    #STEP 5a
    if($word =~ /(.+)e$/) {
      if((($w=$1) =~ /$m_gt_1/o) or (($w =~ /$m_eq_1/o) and ($w !~ /$o/o))){
	$word=$w;
      }
    }

    
    #STEP 5b
    #(m>1 and *d and *L) -->
    if($word =~ /ll$/) {
      if($word =~ /$m_gt_1/o){
	$word=substr($word,0,length($word)-1);
      }
    }
    # It's stemmed so I guess we can give it back :-)
  }
  return $word;
}

