CALL apoc.periodic.iterate(
"CALL apoc.load.json(\"file://litcovid2BioCJSON.json\") YIELD value as documents
UNWIND documents AS document
RETURN document",
"MERGE (doc:Document {_id: document._id}) ON CREATE
    SET doc.id = document.id, doc.pmid = document.pmid, doc.pmcid = document.pmcid, doc.journal = document.journal, doc.year = document.year
FOREACH (passage IN document.passages | 
    CREATE (doc)-[:REFERENCES]->(pas:Passage {offset: passage.offset, text: passage.text})
    CREATE (pas)-[:INFONS]->(data:Infons {section: passage.infons.section, type: passage.infons.type, section_type: passage.infons.section_type, article_pmid: passage.infons.`article-id_pmid`})
)",
{batchSize: 1, parallel: true}
)