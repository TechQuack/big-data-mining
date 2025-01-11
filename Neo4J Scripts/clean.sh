while read line; do
  echo $line | sed -e 's/^"//' -e 's/"$//' >> result_neo4j.txt
done < export.csv
