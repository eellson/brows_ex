Definitions.

START_TAG = \<[A-Za-z\w\d\s]+\>
END_TAG = \<\/[A-Za-z\w\d\s]+\>
CHARACTER = [A-Za-z\w\d\s]

Rules.

{START_TAG} : {token, {start_tag, TokenLine, TokenChars}}.
{END_TAG}   : {token, {end_tag, TokenLine, TokenChars}}.
{CHARACTER} : {token, {char, TokenLine, TokenChars}}.

Erlang code.
