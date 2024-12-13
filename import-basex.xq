xquery version "3.1";

declare %updating function local:http-download($file-url as xs:string, $collection as xs:string) {
    let $binary := fetch:binary($file-url)
    let $filename := replace(replace($file-url, '.*/', ''), '\.[a-z, A-Z, 0-9]+$', '')
    let $file := 
        if (ends-with($file-url, '.xml')) then 
            convert:binary-to-string($binary) 
        else
            $binary
    return
        if (ends-with($file-url, '.zip')) then 
            (archive:extract-to('data/bioc/', $file), db:add($collection, 'data/bioc'))
        else if ( ends-with($file-url, '.gz')) then 
            db:put($collection, archive:extract-binary($file), $filename)
        else
            db:put($collection, $file, $filename)
    
};

let $url := 'https://ftp.ncbi.nlm.nih.gov/pub/lu/LitCovid/litcovid2pubtator.xml.gz'
let $collection := 'BIOC'
return 
    local:http-download($url, $collection)