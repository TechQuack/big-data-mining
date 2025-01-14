echo "Récupération des PMID du fichier"
awk -F' ' '{print $1}' bioconcepts2pubtatorcentral_cleaned_grouped_support | uniq > pmid

echo "Nombre de PMID différents : " `wc -l pmid`

#echo "Récupération des MH de chaque PMID"
#while read pmid; do
#  echo "$pmid " $(curl -s https://pubmed.ncbi.nlm.nih.gov/$pmid/?format=pubmed | sed -e '/MH /!d' -e 's/MH  - //g' -e 's/\/.*//g' | tr -d "\r")
#done < pmid > pmid_mh

echo "Récupération des MH de chaque PMID en utilisant le FTP"
for i in {1..1274}; do
    echo "Téléchargement du fichier $i"
    number=$(printf "%04d" $i)
    wget -q https://ftp.ncbi.nlm.nih.gov/pubmed/baseline/pubmed25n$number.xml.gz
    gzip -d pubmed25n$number.xml.gz

    echo "Extraction des MH du fichier $i"
    awk '
    BEGIN { RS="</PubmedArticle>"; FS="\n" }
    /<PMID Version="1">[0-9]+<\/PMID>/ {
        pmid=gensub(/.*<PMID Version="1">([0-9]+)<\/PMID>.*/,"\\1","g",$0)
        mesh=$0
        if (index(mesh,"<MeshHeadingList>")==0) {
            mesh=""
        } else {
            sub(/.*<MeshHeadingList>/,"",mesh)
            sub(/<\/MeshHeadingList>.*/,"",mesh)
            mesh=gensub(/<MeshHeading>|<\/MeshHeading>/,"","g",mesh)
            mesh=gensub(/<DescriptorName[^>]*>([^<]+)<\/DescriptorName>/,"\"\\1\"","g",mesh)
            mesh=gensub(/<QualifierName[^>]*>[^<]*<\/QualifierName>/,"","g",mesh)
            gsub(/\s+/," ",mesh)
        }
        if (pmid && mesh) print pmid" "mesh
    }
    ' pubmed25n$number.xml >> pmid_mh_ftp

    rm pubmed25n$number.xml
done