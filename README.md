# Big Data Mining

## Récupération des données JSON

La première étape va être de récupérer le fichier JSON prétraité à l'url suivante : https://drive.google.com/file/d/1ya0e-FJfEMK_2kTK3k0oMU-YFl48tFbD/view?usp=sharing
Ce fichier peut ensuite être extrait, afin de copier le fichier JSON dans le dossier LitCovid2, qui est à la racine du projet.

## Utilisation de BaseX

Pour utiliser BaseX avec les scripts fournis, il est nécessaire de créer une base de nom BIOC. De plus, il est nécessaire d'utiliser le parseur intégré à BaseX (options use XML internal parser à la création de la BDD dans l'onglet parsing) pour éviter une erreur Java du fait de la taille de la base de données.

## Utilisation de MongoDB

Pour importer les données dans MongoDB, il est nécessaire d'exécuter la commande suivante dans le conteneur MongoDB : 
```
mongoimport --db big-data-mining --collection BIOC --file /import/litcovid2BioCJSON.json --username root --password password --authenticationDatabase admin --jsonArray
```