Terminals start_tag end_tag char.
Nonterminals tag tag_contents chars.
Rootsymbol tag.

tag -> start_tag end_tag : {unwrap('$1'), []}.
tag -> start_tag tag_contents end_tag : {unwrap('$1'), '$2'}.

tag_contents -> tag : ['$1'].
tag_contents -> tag tag_contents : ['$1'|'$2'].
tag_contents -> chars tag_contents : ['$1'|'$2'].
tag_contents -> chars : ['$1'].

chars -> char chars : unicode:characters_to_binary([unwrap('$1')|'$2']).
chars -> char : unwrap('$1').

Erlang code.

unwrap({_,_,V}) -> V.
