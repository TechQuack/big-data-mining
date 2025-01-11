MATCH (n:Document)
WHERE n.pmid IS NOT NULL
WITH apoc.text.join(COLLECT {
    MATCH (n)-[:REFERENCES]->(title:Passage)-[:INFONS]->(i:Infons)
    WHERE i.type = "title"
    RETURN title.text
}, " ") AS title, apoc.text.join(COLLECT {
    MATCH (n)-[:REFERENCES]->(resume:Passage)-[:INFONS]->(resume_data:Infons)
    WHERE resume_data.type = "abstract"
    RETURN resume.text
}, " ") AS resume, n
RETURN n.pmid + "/" + title + " " + resume