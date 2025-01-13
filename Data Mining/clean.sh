echo "Récupération des PMID et MESH du fichier"
sed -e '/MESH:/!d' -r -e 's/^([[:digit:]]*).*MESH:([A-Z][[:digit:]]*).*/\1 \2/' bioconcepts2pubtatorcentral > result

echo "Regroupement des MESH par PMID"
awk -F' ' '$1==last {printf " %s",$2; next} NR>1 {print "";} {last=$1; printf "%s",$0;} END{print "";}' result > result_final

echo "Récupération des noms de MESH"
awk -F' ' '{print $2}' result_final | sort | uniq > mesh

echo "Nombre de MESH différents : " `wc -l mesh`

echo "Nombre complet d'instances de MESH: " `wc -l result`

echo "Récupération du nombre d'instances par MESH, triées par ordre décroissant"
awk -F' ' '{print $2}' result_final | sort | uniq -c | sort -nr > mesh_count

echo "Suppression des MESH ayant un support inférieur à 0.2%"
total_instances=$(wc -l < result_final)
awk -F' ' '{print $2}' result_final | sort | uniq -c | sort -nr | awk -v total="$total_instances" '$1>0.002*total {print $2}' > mesh_01

echo "Nombre de MESH gardés : " `wc -l mesh_01`

echo "Tri des MESH par ordre alphabétique"
sort mesh_01 > mesh_01_sorted

echo "Suppression des MESH de result_final n'étant pas dans mesh_01"
awk -F' ' 'NR==FNR{a[$1];next} {out=$1;for (i = 2; i <= NF; i++) {if ($i in a) {out=out" "$i;}};print out}' mesh_01 result_final > result_final_01

echo "Suppression des PMID n'ayant plus de MESH"
awk -F' ' '{if (NF > 1) print $0}' result_final_01 > pmid_01

echo "Tri des MESH par ordre alphabétique dans result_final_01"
awk -F' ' '{printf "%s", $1; for (i = 2; i <= NF; i++) {mesh[i - 2]=$i}; asort(mesh); for (m in mesh){printf " %s",mesh[m]}; print ""; delete mesh}' pmid_01 > result_final_01_sorted

echo "Création du fichier final CSV ayant pour entête PMID,MESH1,MESH2,... (en utilisant les MESH de mesh_01). Un 1 dans la colonne signifie que le PMID possède le MESH correspondant."
echo -n "PMID" > result_final_01.csv
awk -F' ' '{printf ",%s", $1}' mesh_01_sorted >> result_final_01.csv
echo "" >> result_final_01.csv
awk -F' ' 'NR==FNR{meshs[NR]=$1;next} {printf "%s", $1;current_field=2; for(mesh in meshs) {if ($current_field == meshs[mesh]) {printf ",1"; current_field=current_field + 1} else {printf ",?"}};print ""}' mesh_01_sorted result_final_01_sorted >> result_final_01.csv

echo "Suppression des fichiers temporaires"
rm result result_final mesh mesh_count mesh_01 mesh_01_sorted result_final_01 pmid_01 result_final_01_sorted