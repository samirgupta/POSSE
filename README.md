POSSE
=====

Part of Speech Tagger for Software Engineering


Based on the paper published in ICPC 2013:

Part-of-Speech Tagging of Program Identifiers for Improved Text-Based Software Engineering Tool
Gupta, Samir; Malik, Sana; Pollock, Lori; Vijay-Shanker, K.. 
21st Annual International Conference on Program Comprehension, IEEE, May 2013.

==================================================
For any questions please contact me 

Author:
Samir Gupta
Graduate Student, University of Delware, USA
contact: sgupta@udel.edu

==================================================
Dependencies:

1. Perl required 
   Tested on v5.14.2 

2.WordNet should be installed.
Please provide the path to the WordNet binary in the script:

./Scripts/getWordNetType.sh

Change line#2 

/usa/sgupta/software/WordNet/bin/wn $1 | grep "Information available for \(noun\|verb\|adj\|adv\) $1" | cut -d " " -f4

TO

pathToWordNetBinary $1 | grep "Information available for \(noun\|verb\|adj\|adv\) $1" | cut -d " " -f4


==================================================
Usage:
======


Two main binaries:

./Scripts/mainParser.pl  and ./Scripts/mainParserChunk.pl


1. Getting Part of Speech information

cd Scripts
./mainParser.pl <inputFile> <type>

Output is generated in ./Output/<inputFile>.pos

2. Getting Chunk Information

cd Scripts
./mainParser.pl <inputFile> <type>

Output is generated in ./Output/<inputFile>.chunk


Parameter Information:
=====================

inputFile: The input file to tagged (description below)

<type> : Specify the input is methods, attributes or class name

Can take 3 values: M (for method name)
                   C (for class name)
                   A (for attribute name)


Sample Usage:
============

cd Scripts;
./mainParser.pl ../Input/method100.input "M"

Output File Generated In: ./Output/method100.input.pos

=========================================================================

Format of input/output Files:
==============================


Sample Input Files can be found in ./Input

Example: (from ./Input/method100.input)

void resolveJumpJetAttack(QPhysicalResult;I) | resolve jump jet attack

So a line in Input file corresponds to the program identifier (here a method name) of format:


<methodSignature> | <splitted method name>



Please refer the ./Output directory for output format.






