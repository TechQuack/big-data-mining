xquery version "3.1";

declare variable $bioc := collection("bioc");

file:write-text-lines("data/result.txt", for $file in $bioc
  for $document in $file/collection/document[fn:exists(passage/infon[@key='article-id_pmid'])]
    let $passage := $document/passage
    let $pmid := $passage/infon[@key='article-id_pmid']/text()
    let $title := $passage/infon[@key='section_type' and text()="TITLE"]/../text/text()
    let $resume := fn:string-join($passage/infon[@key='section_type' and text()="ABSTRACT"]/../text/text(), " ")
    return concat($pmid, '/', $title, ' ', $resume))