CALL apoc.periodic.iterate(
"CALL apoc.load.json(\"file://litcovid2BioCJSON.json\") YIELD value as documents
UNWIND documents AS document
RETURN document",
"CREATE (doc:Document {_id: document._id, id: document.id, pmid: document.pmid, pmcid: document.pmcid, journal: document.journal, year: document.year})
WITH document.passages as passages
UNWIND passages AS passage
CREATE (doc)-[:REFERENCES]->(pas:Passage {offset: passage.offset, text: passage.text})-[:INFONS]->(data:Infons {section: passage.infons.section, type: passage.infons.type})",
{batchSize: 1, parallel: true}
)