CALL apoc.periodic.iterate(
"CALL apoc.load.jsonArray(\"file://litcovid2BioCJSON.json\") YIELD value as document",
"MERGE (doc:Document {_id: document._id}) ON CREATE
    SET id = document.id, pmid = document.pmid, pmcid = document.pmcid, journal = document.journal, year = document.year
FOREACH (passage IN document.passages | 
    CREATE (document)-[:REFERENCES]->(pas:Passage {offset: passage.offset, text: passage.text})
    CREATE (pas)-[:INFONS]->(data:Infons {section: passage.infons.section, type: passage.infons.type})
)",
{batchSize: 1000, parallel: true}
)