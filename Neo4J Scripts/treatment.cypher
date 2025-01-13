MATCH (n:Document)-[:REFERENCES]->(pmid:Passage)-[:INFONS]->(section:Infons)
WHERE n.pmid IS NOT NULL AND section.article_pmid IS NOT NULL
WITH apoc.text.join(COLLECT {
    MATCH (n)-[:REFERENCES]->(title:Passage)-[:INFONS]->(i:Infons)
    WHERE i.section_type = "TITLE"
    RETURN title.text
}, " ") AS title, apoc.text.join(COLLECT {
    MATCH (n)-[:REFERENCES]->(resume:Passage)-[:INFONS]->(resume_data:Infons)
    WHERE resume_data.section_type = "ABSTRACT"
    RETURN resume.text
}, " ") AS resume, n
RETURN n.pmid + "/" + title + " " + resume