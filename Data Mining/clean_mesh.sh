echo "Récupération des PMID et MESH du fichier"
sed -e '/MESH:/!d' -r -e 's/^([[:digit:]]*).*MESH:([A-Z][[:digit:]]*).*/\1 \2/' bioconcepts2pubtatorcentral > bioconcepts2pubtatorcentral_cleaned

echo "Regroupement des MESH par PMID"
awk -F' ' '$1==last {printf " %s",$2; next} NR>1 {print "";} {last=$1; printf "%s",$0;} END{print "";}' bioconcepts2pubtatorcentral_cleaned > bioconcepts2pubtatorcentral_cleaned_grouped

echo "Récupération des noms de MESH"
awk -F' ' '{print $2}' bioconcepts2pubtatorcentral_cleaned | sort -u > mesh

echo "Nombre de MESH différents : " `wc -l mesh`

echo "Nombre complet d'instances de MESH: " `wc -l bioconcepts2pubtatorcentral_cleaned`

echo "Récupération du nombre d'instances par MESH, triées par ordre décroissant"
awk -F' ' '{print $2}' bioconcepts2pubtatorcentral_cleaned_grouped | sort | uniq -c | sort -nr > mesh_count

echo "Suppression des MESH ayant un support inférieur à 0.1%"
total_instances=$(wc -l < bioconcepts2pubtatorcentral_cleaned_grouped)
cat mesh_count | awk -v total="$total_instances" '$1>0.001*total {print $2}' > mesh_support_01

echo "Nombre de MESH gardés : " `wc -l mesh_support_01`

echo "Tri des MESH par ordre alphabétique"
sort mesh_support_01 > mesh_support_01_sorted

echo "Suppression des MESH de bioconcepts2pubtatorcentral_cleaned_grouped n'étant pas dans mesh_support_01"
awk -F' ' 'NR==FNR{a[$1];next} {out=$1;for (i = 2; i <= NF; i++) {if ($i in a) {out=out" "$i;}};print out}' mesh_support_01 bioconcepts2pubtatorcentral_cleaned_grouped > bioconcepts2pubtatorcentral_cleaned_grouped_support

echo "Suppression des PMID n'ayant plus de MESH"
awk -F' ' '{if (NF > 1) print $0}' bioconcepts2pubtatorcentral_cleaned_grouped_support > pmid_01

echo "Tri des MESH par ordre alphabétique dans bioconcepts2pubtatorcentral_cleaned_grouped_support"
awk -F' ' '{printf "%s", $1; for (i = 2; i <= NF; i++) {mesh[i - 2]=$i}; asort(mesh); for (m in mesh){printf " %s",mesh[m]}; print ""; delete mesh}' pmid_01 > bioconcepts2pubtatorcentral_cleaned_grouped_support_sorted

echo "Création du fichier final CSV ayant pour entête PMID,MESH1,MESH2,... (en utilisant les MESH de mesh_support_01). Un 1 dans la colonne signifie que le PMID possède le MESH correspondant."
echo -n "PMID" > bioconcepts2pubtatorcentral_cleaned.csv
awk -F' ' '{printf ",%s", $1}' mesh_support_01_sorted >> bioconcepts2pubtatorcentral_cleaned.csv
echo "" >> bioconcepts2pubtatorcentral_cleaned.csv
awk -F' ' 'NR==FNR{meshs[NR]=$1;next} {printf "%s", $1;current_field=2; for(mesh in meshs) {if ($current_field == meshs[mesh]) {printf ",1"; current_field=current_field + 1} else {printf ",?"}};print ""}' mesh_support_01_sorted bioconcepts2pubtatorcentral_cleaned_grouped_support_sorted >> bioconcepts2pubtatorcentral_cleaned.csv