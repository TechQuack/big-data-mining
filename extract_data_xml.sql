-- Procédure pour extraire les données

CREATE OR REPLACE FUNCTION extract_xml_data(xml_content xml)
RETURNS text AS $$
DECLARE
    result text;
BEGIN
    SELECT array_to_string(xpath('/document/passage/infon[@key="article-id_pmid"]/text()', xml_content), '') ||
           '/' ||
           array_to_string(xpath('/document/passage/infon[@key="section_type" and text()="TITLE"]/../text/text()', xml_content), '') ||
           ' ' ||
           array_to_string(xpath('/document/passage/infon[@key="section_type" and text()="ABSTRACT"]/../text/text()', xml_content), '')
    INTO result;

    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Création de la table

DROP TABLE IF EXISTS xml_data;
CREATE TABLE xml_data(content xml);

-- Pour insérer un fichier dans notre table
COPY xml_data(content)
FROM '/tmp/covid2.xml'
WITH (FORMAT text);

-- Appeler la procédure et envoyer le résultat dans result.txt

COPY (
    SELECT result
    FROM (
        SELECT extract_xml_data(content) AS result
        FROM xml_data
    ) subquery
    WHERE trim(result) != '/'
) TO '/tmp/result.txt';