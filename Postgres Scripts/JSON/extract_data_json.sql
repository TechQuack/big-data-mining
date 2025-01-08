-- Fonction d'extraction 

CREATE OR REPLACE FUNCTION extract_json_data(json_content jsonb)
RETURNS text AS $$
DECLARE
    article_id integer;
    title text;
    passage_text text;
    result text := '';
BEGIN
    SELECT (json_content->>'pmid')::integer
    INTO article_id;

    SELECT json_content->'passages'->0->'text'
    INTO title;
    title := trim(both '"' from title);

    FOR passage_text IN
        SELECT passage->>'text'
        FROM jsonb_array_elements(json_content->'passages') AS passage
        WHERE passage->'infons'->>'section' = 'Abstract'
    LOOP
        passage_text := trim(both '"' from passage_text);
        result := result || passage_text;
    END LOOP;

    RETURN  article_id || '/' || title || ' ' || result;
END;
$$ LANGUAGE plpgsql;

-- Création table 

DROP TABLE json_data;
CREATE TABLE json_data(content jsonb);

-- Appel procédure

COPY (
    SELECT result
    FROM (
        SELECT extract_json_data(content) AS result
        FROM json_data
    ) subquery
    WHERE trim(result) != '/'
) TO '/tmp/result_json.txt';

-- Insertion de données (demande des fichiers pas très grands (pas plus de 500 Mo))

DO $$
DECLARE
    line TEXT;
BEGIN
    FOR line IN
        SELECT unnest(string_to_array(pg_read_file('/tmp/covid16.json'), E'\n'))
    LOOP
        BEGIN
            INSERT INTO json_data(content)
            VALUES (line::jsonb);
        EXCEPTION
            WHEN others THEN
                RAISE NOTICE 'Ligne ignorée : %', line;
        END;
    END LOOP;
END $$;

