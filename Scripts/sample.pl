#! /usr/bin/perl
# from http://www.perlmonks.org/?node_id=716109
# usage: ./sample numlines file

my $wanted = shift || 10;
my @got;

die "Invalid number of lines!\n" if $wanted < 1;
open OUTPUT,">$ARGV[0]-sample$wanted" or die "Error opening output file\n";

while (<>) {
  if (@got < $wanted) {
      push @got, $_;
  } elsif (rand($.) < $wanted) {
      splice @got, rand(@got), 1;
      push @got, $_;
  }
}

die "Not enough lines!\n" if @got < $wanted;
print OUTPUT @got;

