#5.1.3.ps1

#"\b" says the pattern must match at a word boundary.
#"\p{name}" is a way to check for a specific Unicode Named Block.
#"?" says match zero or one time. 
#"+" says match one or more times.
#
#?<NAME> allows us to refer to a match block by name instead of index.

$pattern="\b(?<GREEK>(\p{IsGreek}+(\s)?)+) - (?<LATIN>\p{IsBasicLatin}+)"

$string="Μία γλώσσα δεν είναι ποτέ αρκετή - One language is never enough"

$Matches=''
$string -Match $pattern
write-output '----'
$Matches.GREEK
$Matches.LATIN
