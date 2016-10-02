Terminals start_tag end_tag char.
Nonterminals tag_contents tag chars.
Rootsymbol tag.

tag -> start_tag end_tag : ['$1', '$2'].
tag -> start_tag tag_contents end_tag : ['$1', {'children', '$2'}, '$3'].

tag_contents -> tag : ['$1'].
tag_contents -> tag tag_contents : ['$1'|'$2'].
tag_contents -> chars tag_contents : ['$1'|'$2'].
tag_contents -> chars : ['$1'].

chars -> char : '$1'.
chars -> char chars : ['$1'|'$2'].
