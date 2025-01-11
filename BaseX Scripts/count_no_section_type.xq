xquery version "3.1";

declare variable $bioc := collection("BaseX");

count(
  for $document in $bioc//document
  let $infons := $document//infon
  where not(some $infon in $infons satisfies $infon/@key = "section_type")
  return 1
)