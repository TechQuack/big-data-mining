echo "Récupération du texte de chaque PMID"
sed -E 's/[[:digit:]]+\///' result.txt > pmid_text.txt

echo "Mise en forme du texte en mettant chaque phrase sur une nouvelle ligne"
sed -E 's/\./\.\n/g' pmid_text.txt > pmid_text_sentences.txt

echo "Suppression des lignes vides et espaces en début de ligne"
sed -E -e 's/\r//g' -e '/^$/d' -e 's/^[[:space:]]+//' pmid_text_sentences.txt > pmid_text_sentences_cleaned.txt