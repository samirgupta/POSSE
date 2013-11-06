#! /usr/bin/perl -w

use strict;
use warnings;

use lib './lib';
use Java::JVM::;

my $ast = Parse::Java->parse_file('./src/associations/Apriori.java');
print $ast;
