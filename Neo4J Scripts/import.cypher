CALL apoc.periodic.iterate(
"CALL apoc.load.json(\"file://litcovid2BioCJSON.json\") YIELD value as documents
UNWIND documents AS document
RETURN document",
"MERGE (a:Document {id:document._id})",
{batchSize: 1, parallel: true}
)