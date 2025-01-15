echo "Récupération des instances de MH"
awk '{
  match($0, /[0-9]+ /)
  pmid = substr($0, RSTART, RLENGTH)
  rest = substr($0, RSTART + RLENGTH)
  while (match(rest, /"[^"]+"/)) {
    mh_name = substr(rest, RSTART + 1, RLENGTH - 2)
    print mh_name
    rest = substr(rest, RSTART + RLENGTH + 1)
  }
}' pmid_litcovid_mh_ftp | pv > pmid_mh

echo "Récupération des noms des MH"
cat pmid_mh | sort -u > mh

echo "Nombre de MH différents : " `wc -l mh`

echo "Récupération du nombre d'instances par MH, triées par ordre décroissant"
cat pmid_mh | sort | uniq -c | sort -nr > mh_count

echo "Suppression des MH ayant un support inférieur à 0.05%"
total_instances=$(wc -l < pmid_mh)
awk -v total="$total_instances" '{
    match($0, /[0-9]+ /)
    number = substr($0, RSTART, RLENGTH) + 0;
    rest = substr($0, RSTART + RLENGTH)
    if (number > 0.0005*total) {
        print rest
    }
}' mh_count > mh_support_005

echo "Nombre de MH gardés : " `wc -l mh_support_005`

echo "Tri des MH par ordre alphabétique"
sort mh_support_005 > mh_support_005_sorted

echo "Suppression des MH de pmid_mh n'étant pas dans mh_support_005"
awk 'NR==FNR{a[$1];next} 
{
    match($0, /[0-9]+ /)
    out = substr($0, RSTART, RLENGTH);
    rest = substr($0, RSTART + RLENGTH)
    while (match(rest, /"[^"]+"/)) {
        mh_name = substr(rest, RSTART + 1, RLENGTH - 2)
        if (mh_name in a) {
            out=out " " "\"" mh_name "\"";
        }
        rest = substr(rest, RSTART + RLENGTH + 1)
    }
    print out
}' mh_support_005 pmid_litcovid_mh_ftp > pmid_mh_ftp_support_005

echo "Suppression des PMID n'ayant plus de MH"
awk -F' ' '{if (NF > 1) print $0}' pmid_mh_ftp_support_005 > pmid_005

echo "Tri des MH par ordre alphabétique dans pmid_mh_ftp_support_005"
awk '
{
    match($0, /[0-9]+ /)
    pmid = substr($0, RSTART, RLENGTH);
    rest = substr($0, RSTART + RLENGTH)
    printf "%s", pmid;
    i = 0;
    while (match(rest, /"[^"]+"/)) {
        mh[i] = substr(rest, RSTART + 1, RLENGTH - 2);
        i = i + 1;
        rest = substr(rest, RSTART + RLENGTH + 1)
    }
    asort(mh);
    for (m in mh){
        printf " \"%s\"", mh[m]
    };
    print "";
    delete mh
}' pmid_005 > pmid_mh_ftp_support_005_sorted

echo "Création du fichier final CSV ayant pour entête PMID,MH1,MH2,... (en utilisant les MH de mh_support_005). Un 1 dans la colonne signifie que le PMID possède le MH correspondant."
echo -n "PMID" > pmid_mh_ftp_support_005_tab.csv
awk '{printf "\t\"%s\"", $0}' mh_support_005_sorted >> pmid_mh_ftp_support_005_tab.csv
echo "" >> pmid_mh_ftp_support_005_tab.csv
awk 'NR==FNR{mh[NR]=$1;next} {
    match($0, /[0-9]+ /);
    pmid = substr($0, RSTART, RLENGTH - 1);
    rest = substr($0, RSTART + RLENGTH)
    printf "%s", pmid;
    if (match(rest, /"[^"]+"/)) {
        current_field=substr(rest, RSTART + 1, RLENGTH - 2);
        rest = substr(rest, RSTART + RLENGTH + 1)
    } else {
        current_field=""
    }
    for(mesh in mh) {
        if (current_field == mh[mesh]) {
            printf "\t1";
            if (match(rest, /"[^"]+"/)) {
                current_field=substr(rest, RSTART + 1, RLENGTH - 2);
                rest = substr(rest, RSTART + RLENGTH + 1)
            } else {
                current_field=""
            }
        } else {
            printf "\t?"
        }
    };
    print ""
}' mh_support_005_sorted pmid_mh_ftp_support_005_sorted >> pmid_mh_ftp_support_005_tab.csv

echo "Utilisation de JClose pour extraire les règles d'association"
java -jar JClose_1.0.jar pmid_mh_ftp_support_005_tab.csv -s=0.1 -c=0.7 -g -i -t