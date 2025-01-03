xquery version "3.1";

declare function local:http-download($file-url as xs:string, $collection as xs:string) as item()* {
    let $request := <hc:request href="{$file-url}" method="GET"/>
    let $response := hc:send-request($request)
    let $head := $response[1]
    
    return
        if ($head/@status = '200') then
            let $filename := 
                if (contains($head/hc:header[@name='content-disposition']/@value, 'filename=')) then 
                    $head/hc:header[@name='content-disposition']/@value/substring-after(., 'filename=')
                else 
                    replace($file-url, '^.*/([^/]*)$', '$1')
            let $media-type := $head/hc:body/@media-type
            let $mime-type := 
                if (ends-with($file-url, '.xml') and $media-type = 'text/plain') then
                    'application/xml'
                else 
                    $media-type
            let $content-transfer-encoding := $head/hc:body[@name = 'content-transfer-encoding']/@value
            let $body := $response[2]
            let $log-in := xmldb:login("/db", "admin", "")
            let $file := 
                if (ends-with($file-url, '.xml') and $content-transfer-encoding = 'binary') then 
                    util:binary-to-string($body) 
                else  if(ends-with($file-url, '.gz')) then
                    if ($content-transfer-encoding = 'binary') then
                        compression:ungzip($body)
                    else
                        compression:ungzip(util:string-to-binary($body))
                else
                    $body
            let $result := 
                if (ends-with($file-url, '.zip')) then 
                    compression:unzip($body, util:function(QName("local", "local:filter"), 3), (), util:function(QName("local", "local:process"), 4), <param collection="{$collection}"/>)
                else
                    xmldb:store($collection, $filename, $file, $mime-type)
            return
                $result
        else
            <error>
                <message>Oops, something went wrong:</message>
                {$head}
            </error>
};

declare function local:filter($path as xs:string, $type as xs:string, $param as item()*) as xs:boolean {
    true()
};

declare function local:process($path as xs:string,$type as xs:string, $data as item()? , $param as item()*) {
    let $collection := $param[@name="collection"]/@value/string()
    let $filename := if (contains($path, '/')) then fn:substring-after($path, '/') else $path
    let $filename := xmldb:encode($filename)
    let $store := 
            if (ends-with($filename, '.xml')) then 
                xmldb:store('/db/bioc', $filename, $data, 'application/xml')
            else if (fn:not(fn:empty($data))) then
                xmldb:store('/db/bioc', $filename, $data)
            else 
                ""
    return $store
};

let $url := 'https://ftp.ncbi.nlm.nih.gov/pub/lu/LitVar/litvar_variants.json.gz'
let $collection := '/db/bioc'
return 
    local:http-download($url, $collection)