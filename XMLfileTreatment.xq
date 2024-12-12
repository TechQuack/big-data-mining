xquery version "3.1";

declare variable $bioc := collection("/db/bioc");

file:serialize(text {
    for $file in $bioc
    let $passage := $file/collection/document/passage
    let $pmid := $passage/infon[@key='article-id_pmid']/text()
    let $title := $passage/infon[@key='section_type' and text()="TITLE"]/../text/text()
    let $resume := fn:string-join($passage/infon[@key='section_type' and text()="ABSTRACT"]/../text/text(), " ")
    return concat($pmid, '/', $title, ' ', $resume)
}, "/data/result.txt", map{})
