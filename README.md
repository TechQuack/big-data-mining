# Big Data Mining

## Récupération des données

### Récupération des données JSON

La première étape va être de récupérer le fichier JSON prétraité à l'url suivante : https://drive.google.com/file/d/1ya0e-FJfEMK_2kTK3k0oMU-YFl48tFbD/view?usp=sharing
Ce fichier peut ensuite être extrait, afin de copier le fichier JSON dans le dossier LitCovid2, qui est à la racine du projet.

### Récupération des données Neo4J

Il existe deux manières de récupérer les données sur Neo4J.\
Tout d'abord, il est possible d'exécuter le script import.cypher. Attention, cela nécessite un ordi puissant et une importante quantité de RAM pour éviter les erreurs d'imports. Pour le faire fonctionner, il est nécessaire de placer dans le dossier import du DBMS où l'on souhaite importer notre fichier le fichier litcovid2BioCJSON.json. Ensuite, il est possible d'exécuter le script import.cypher pour importer les données. L'important peut être très longue.\
L'autre solution est d'utiliser le dump de la BDD accessible à l'URL suivante : https://drive.google.com/file/d/1KwpiuvCsLlTHAltGXlhX4ePAWHLUU9qs/view?usp=sharing\
Il est possible ensuite d'importer ce fichier dans Neo4J Desktop puis de créer un DBMS à partir de celui-ci.

## Exécution des scripts

### Utilisation de BaseX

Pour utiliser BaseX avec les scripts fournis, il est nécessaire de créer une base de nom BIOC. De plus, il est nécessaire d'utiliser le parseur intégré à BaseX (options use XML internal parser à la création de la BDD dans l'onglet parsing) pour éviter une erreur Java du fait de la taille de la base de données.

### Utilisation de MongoDB

Pour importer les données dans MongoDB, il est nécessaire d'exécuter la commande suivante dans le conteneur MongoDB : 
```
mongoimport --db big-data-mining --collection BIOC --file /import/litcovid2BioCJSON.json --username root --password password --authenticationDatabase admin --jsonArray
```

### Utilisation de Neo4J

Une fois les données importées dans Neo4J, il est possible d'utiliser le script treatment.cypher. Celui-ci affichera dans la console l'ensemble des résultats lignes par ligne. Il est ensuite possible de l'exporter au format CSV. Une fois le fichier CSV obtenu, un script est disponible pour le transformer au fichier TXT, clean.sh. Celui-ci se chargera d'enlever les " au début et à la fin de chaque ligne. Une fois le script exécuté, il n'y a plus qu'à enlever la première ligne du fichier (le header) pour obtenir le fichier txt final.