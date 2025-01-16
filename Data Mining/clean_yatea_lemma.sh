echo "récupération de la liste des termes candidats les plus fréquents"

# On récupère les termes candidats les plus fréquents
# On utilise la commande sort pour trier les termes par ordre alphabétique
# On utilise la commande uniq pour ne garder qu'une seule occurrence de chaque terme
# On utilise la commande sort -n pour trier les termes par ordre numérique
# On utilise la commande tail -n 150 pour ne garder que les 150 termes les plus fréquents
# On ne récupère que la 3ème colonne (le terme) avec la commande awk
# On redirige le résultat dans un fichier
tail -n +2 termList.txt | head -n 150 | awk -F'\t' '{gsub(/^[ \t]+|[ \t]+$/, "", $3); print $3}' | sort | uniq > frequent_terms_lemmatised.txt
sed -i 's/^INFunknownSUP//g' frequent_terms_lemmatised.txt
sed -i 's/INFunknownSUP$//g' frequent_terms_lemmatised.txt
sed -i 's/[[:space:]]//g' frequent_terms_lemmatised.txt

# Supprimer les termes égaux à INFunknown et les lignes vides
sed -i '/^INFunknown$/d' frequent_terms_lemmatised.txt
sed -i '/^$/d' frequent_terms_lemmatised.txt  

# On écrit un fichier sortie avec comme en-tête "PMID", Term1, Term2, ..., TermN issue du fichier frequent_terms.txt
# Lire les termes fréquents dans un tableau et supprimer les doublons
# Lire les termes fréquents dans un tableau et supprimer les doublons
mapfile -t terms <  frequent_terms_lemmatised.txt

clean_terms=()
for term in "${terms[@]}"
do
    clean_term=$(echo "$term" | tr -d '":')
    clean_term=$(echo "$clean_term" | sed 's/[[:space:]]//g')
    clean_terms+=("$clean_term")
done

# Écrire l'en-tête dans frequent_terms_lemmatised.csv
echo -n "PMID" > frequent_terms_lemmatised.csv
for term in "${clean_terms[@]}"
do
    echo -n ",$term" >> frequent_terms_lemmatised.csv
done
echo "" >> frequent_terms_lemmatised.csv

# Pour chaque ligne dans le fichier result.txt, on écrit le PMID
# On regarde si chaque terme de l'en-tête est contenu dans la ligne, si oui on écrit 1, sinon 0
# On redirige le résultat dans le fichier frequent_terms_lemmatised.csv
while read line
do
    pmid=$(echo "$line" | cut -d'/' -f1)
    echo -n "$pmid" >> frequent_terms_lemmatised.csv
    for term in "${terms[@]}"
    do
        if echo "$line" | grep -q "$term"
        then
            echo -n ",1" >> frequent_terms_lemmatised.csv
        else
            echo -n ",?" >> frequent_terms_lemmatised.csv
        fi
    done
    echo "" >> frequent_terms_lemmatised.csv
done < result.txt