Definitions.

% Helper Regexes (non-token)

ValidInTagName = [A-Za-z0-9]
ValidTagAttributeName = [A-Za-z\-]
ValidTagAttributeValue = [A-Za-z0-9\s="\-/:;,\.?\(\)@]
ValidTagAttribute = {ValidTagAttributeName}+=("|')?{ValidTagAttributeValue}+("|')?
ValidTags = (\s{ValidTagAttribute})*
ValidInsideTag = [A-Za-z0-9\w\s="\-/@#:;,\.\'{}\(\)\[\]&\|\*]

% Core HTML tokens
META_TAG  = \<meta{ValidTags}\>
LINK_TAG  = \<link{ValidTags}\>
START_TAG = \<{ValidInTagName}+{ValidTags}\>
END_TAG   = \<\/{ValidInTagName}+\>
CHARACTER = {ValidInsideTag}
DOCTYPE   = \<!(DOCTYPE|doctype)\s+[A-Za-z]+\>\s*

% Useful tokens
NEW_LINE  = [\r\n]\s*
SELF_CLOSING_TAG = \<{ValidInTagName}+{ValidTags}\s\/\>

Rules.

{META_TAG}  : skip_token.
{LINK_TAG}  : skip_token.
{SELF_CLOSING_TAG} : skip_token.
{START_TAG} : {token, {start_tag, TokenLine, TokenChars}}.
{END_TAG}   : {token, {end_tag, TokenLine, TokenChars}}.
{CHARACTER} : {token, {char, TokenLine, TokenChars}}.
{DOCTYPE}   : skip_token.

{NEW_LINE}  : skip_token.

Erlang code.
