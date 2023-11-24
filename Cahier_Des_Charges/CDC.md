# Cahier des charges

## Titre 

Développement d'une application web pour gérer l'organisation d'un BDE.

## Contexte (ou Introduction)

Le BDE Immersion est le bureau des etudiants ingénieurs en alternance du CNAM.
Suite à de nombreuses années de mauvaise gestion, le BDE Immersion se trouve dans une situation très difficile. Ses comptes sont déficitaires, et l'image du BDE en pâti. Cependant, la nouvelle équipe du BDE est déterminée à redresser la barre. Cela devra passer par une nouvelle gestion modernisée du BDE.  
Le BDE gère un snack/buvette, organise des soirees et autres évènements en groupes, et vends des produits à l'éfigie du BDE.
Le contexte est celui de la mise en place d'un système gestion organisationnelle du BDE, à destination de l'équipe gérant le BDE.


## Problématiques

Le BDE ne possède pas de système pour recenser ses adhérents, effectuer des pré-inscriptions aux évènements, suivre ses stocks de nourritures/boissons et de produits dérivés, ce qui entraîne des pertes potentielles de ventes et conduit à un réapprovisionnement non optimal des stocks.
Le BDE propose aussi un système d'ardoise pour les differentes transactions qu'il réalise auprès de ses adhérents, mais il est de plus en plus compliqué de suivre cette information afin de procéder au recouvrement des dettes des étudiants, ce qui risque de nuir encore plus  à la santé financière du BDE.
De plus, l'équipe du BDE est relativement restreinte (~5 étudiants), et doit régulièrement s'absenter pour des périodes prolongées d'alternance, ce qui limite grandement la gestion continue du BDE. 
Enfin, il n'y a pas d'annuaire des anciens élèves, faute de recensement automatisé, nuisant à l'attractivité de l'adhésion au BDE.

## Besoins

### Besoins Fonctionnels:

Au vu des problématiques du BDE, les besoins du système sont les suivants:

* On doit pouvoir facilement ajouter ou modifier les informations relatives à un ou plusieurs adhérents.
* On doit pouvoir récupérer toutes les informations relatives à 1 ou plusieurs adhérents.
* On va avoir besoin de constituer un annuaire des alumni avec les informations des anciens adhérents
* On doit pouvoir créer des évenements et sorties de groupes avec les données associées à l'activité.
* On doit pouvoir inscrire des adhérents aux sorties et événements du BDE.
* On doit pouvoir savoir qui est inscrit à chaque évenement.
* On doit pouvoir consulter et mettre à jour le stock et l'équipement du snack du BDE.
* On doit pouvoir consulter et mettre à jour le stock merchandising du BDE.
* On doit pouvoir consulter et effectuer des commandes pour le BDE.
* On doit pouvoir mettre à jour les ardoises 
	
### Contraintes Fonctionnelles:

Le BDE impose les contraintes suivantes au système:

* Les adhérents ne peuvent pas dépasser un seuil 50€ d'ardoise.
* La gestion du BDE doit pouvoir s'effectuer à distance durant les périodes d'alternance.

### Contraintes Techniques:

* Le système doit être accéssible depuis une interface web.
* Le système doit générer une alerte lorsqu'une transaction.
* Le déploiment du système doit s'appuyer sur des conteneurs DOCKER.


## Livrables

Les livrables attendus sont:

* Un conteneur DOCKER packageant le système
* La documentation d'installation.
* La documentation de déploiement.
* La documentation d'utilisation


# Réponse au besoin

## Solutions

Pour répondre à ce besoin, notre société a la solution ! Fort de la fougue de la jeunesse ainsi que d'une formation intensive dans les bases de données et les applications web, nous savons précisément quelles solutions mettre en place pour transformer votre BDE en une véritable machine digitale.

### Solutions fonctionnelles

Voici les fonctionnalités qui seront offertes par l'application :

* Pouvoir visualiser et gérer la liste des adhérents au BDE
* Gérer les finances du BDE
* Gérer les commandes et les stocks de produits entrant et sortant, que ça soit des produits du snack ou du merch
* Gérer les ardoises des adhérents du BDE, bloquer leur accès aux services du BDE si leur ardoises atteint le seuil de 50€
* Gérer les recouvrements
* Pouvoir gérer les sorties, leurs prix, les adhérents y allant, leurs dates
* Pouvoir accéder à la liste des sorties organisées par le BDE pour les adhérents non membre du BDE

### Solutions techniques

D'un point de vue technique, nous proposons d'intégrer des technologies éprouvées, performantes et peu onéreuses : 

* Une base de données PostgreSQL pour la gestion et la manipulation des données. PostgreSQL est une base de données libre, sans coût de licence, et elle existe depuis plus de 20 ans
* La plateforme JavaScript côté serveur Node.js offre une performance exceptionnelle et une flexibilité sans pareille pour développer des applications web évolutives et rapides.
* Express, un framework minimaliste, robuste et hautement personnalisable pour Node.js, et EJS un système de templates simple et flexible pour générer des vues dynamiques côté serveur pour la génération dynamique de pages web. 
* Docker pour le packaging de l'application dans un environnement maîtrisée et cloisonné.

# Livrables

Le livrable sera sous la forme d'un environnement Docker combinant un fichier .yaml pour l'orchestration des conteneurs et un dockerfile pour l'initialisation de l'image du serveur web. 