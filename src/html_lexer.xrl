Definitions.

START_TAG = \<[A-Za-z0-9\w\s]+\>
END_TAG   = \<\/[A-Za-z0-9\w\s]+\>
CHARACTER = [A-Za-z0-9\w\s\.\,\']
NEW_LINE  = [\n]

Rules.

{START_TAG} : {token, {start_tag, TokenLine, TokenChars}}.
{END_TAG}   : {token, {end_tag, TokenLine, TokenChars}}.
{CHARACTER} : {token, {char, TokenLine, TokenChars}}.
{NEW_LINE}  : skip_token.

Erlang code.
