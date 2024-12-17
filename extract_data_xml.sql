CREATE OR REPLACE FUNCTION extract_xml_data()
RETURNS text AS $$
DECLARE
    result text;
BEGIN
    SELECT array_to_string(xpath('/collection/document/passage/infon[@key="article-id_pmid"]/text()', content), '')
    || '/' ||
    array_to_string(xpath('/collection/document/passage/infon[@key=''section_type'' and text()="TITLE"]/../text/text()',
                          content), '')
    || ' ' ||
    array_to_string(xpath('/collection/document/passage/infon[@key=''section_type'' and text()="ABSTRACT"]/../text/text()',
                          content), '')
INTO result
FROM xml_data;
RETURN result;
END;
$$ LANGUAGE plpgsql;