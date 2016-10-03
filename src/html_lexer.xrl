Definitions.

% Helper Regexes (non-token)
ValidInTagName = [A-Za-z0-9]
ValidTagAttributeName = [A-Za-z\-]
ValidTagAttributeValue = [A-Za-z0-9\s="\-/:;,\.]
ValidTagAttribute = {ValidTagAttributeName}+="{ValidTagAttributeValue}+"
ValidInsideTag = [A-Za-z0-9\w\s="\-/@#:;,\.\'{}\(\)]

% Core HTML tokens
START_TAG = \<{ValidInTagName}+(\s{ValidTagAttribute})*\>
END_TAG   = \<\/{ValidInTagName}+\>
CHARACTER = {ValidInsideTag}
DOCTYPE   = \<!(DOCTYPE|doctype)\s+[A-Za-z]+\>

% Useful tokens
NEW_LINE  = [\n\r]\s*
SELF_CLOSING_TAG = \<{ValidInTagName}+(\s{ValidTagAttribute})*\s\/\>

Rules.

{START_TAG} : {token, {start_tag, TokenLine, TokenChars}}.
{END_TAG}   : {token, {end_tag, TokenLine, TokenChars}}.
{CHARACTER} : {token, {char, TokenLine, TokenChars}}.
{DOCTYPE}   : skip_token.

{NEW_LINE}  : skip_token.
{SELF_CLOSING_TAG} : skip_token.

Erlang code.
