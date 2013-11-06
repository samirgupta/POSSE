#! /bin/tcsh
/usa/sgupta/software/WordNet/bin/wn $1 | grep "Information available for \(noun\|verb\|adj\|adv\) $1" | cut -d " " -f4
