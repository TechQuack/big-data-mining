xquery version "3.1";

declare function local:http-download($file-url as xs:string, $collection as xs:string) as item()* {
    let $request := <http:request href="{$file-url}" method="GET"/>
    let $response := http:send-request($request)
    let $head := $response[1]
    
    return
        if ($head/@status = '200') then
            let $filename := 
                if (contains($head/http:header[@name='content-disposition']/@value, 'filename=')) then 
                    $head/http:header[@name='content-disposition']/@value/substring-after(., 'filename=')
                else 
                    replace($file-url, '^.*/([^/]*)$', '$1')
            let $media-type := $head/http:body/@media-type
            let $mime-type := 
                if (ends-with($file-url, '.xml') and $media-type = 'text/plain') then
                    'application/xml'
                else 
                    $media-type
            let $content-transfer-encoding := $head/http:body[@name = 'content-transfer-encoding']/@value
            let $body := $response[2]
            let $file := 
                if (ends-with($file-url, '.xml') and $content-transfer-encoding = 'binary') then 
                    convert:binary-to-string($body) 
                else
                    $body
            let $result := 
                if (ends-with($file-url, '.zip') or ends-with($file-url, '.gz')) then 
                    archive:extract-to($collection, $body)
                else
                    db:put($collection, $file, $filename)
            return
                $result
        else
            <error>
                <message>Oops, something went wrong:</message>
                {$head}
            </error>
};

let $url := 'https://ftp.ncbi.nlm.nih.gov/pub/lu/NLM-Chem-BC7-corpus/NLMChem-BC7-indexing.BioC.xml.gz'
let $collection := '/db/bioc'
return 
    local:http-download($url, $collection)