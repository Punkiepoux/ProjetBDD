# Dictionnaire des données

## Dictionnaire

1. numAdherent 
1. nomAdherent
1. prenomAdherent 
1. promotionAdherent 
1. roleAdherent 
1. ardoiseAdherent 
1. telAdherent 
1. mailAdherent 
1. adresseAdherent 
1. idSortie 
1. nomSortie 
1. dateSortie 
1. prixSortie 
1. nbParticipants 
1. lieuSortie 
1. idProduit 
1. nomProduit 
1. qteProduitEnStock 
1. prixVenteProduit 
1. prixAchatProduit 
1. typeProduit 
1. idTransaction 
1. typeTransaction 
1. dateTransaction 
1. qteProduitTransaction 
1. methodePaiement 
1. montantTransaction

## Matrice des dépendances fonctionnelles

| | 1-numAdherent | 9-idSortie | 15-idProduit | 21-idTransaction | 16+22 |
|:----------|:-------------:|:------:|:------:|:------:|:------:|
| 1 - numAdherent | X | | | | | 
| 2 - nomAdherent | X | | | | | 
| 3 - prenomAdherent | X | | | | |
| 4 - promotionAdherent | X | | | | |
| 5 - roleAdherent | X | | | | | 
| 6 - ardoiseAdherent | X | | | | |
| 7 - telAdherent | X | | | | | 
| 8 - mailAdherent | X | | | | |
| 9 - adresseAdherent | X | | | | |
| 10 - idSortie | | X | | | | 
| 11 - nomSortie | | X | | | |
| 12 - dateSortie | | X | | | |
| 13 - prixSortie | | X | | | |
| 14 - nbParticipants | | X | | | |
| 15 - lieuSortie | | X | | | |
| 16 - idProduit | | X | X | | |
| 17 - nomProduit | | X | X | | |
| 18 - qteProduitEnStock | | X | X | | |
| 19 - prixVenteProduit | | X | X | | |
| 20 - prixAchatProduit | | X | X | | |
| 21 - typeProduit | | X | X | | |
| 22 - idTransaction | | | | X | |
| 23 - typeTransaction | | | | X | |
| 24 - dateTransaction | | | | X | |
| 25 - qteProduitTransaction | | | | | X |
| 26 - methodePaiement | | | | X | | |
| 27 - montantTransaction | | | | X | | |
## Dépendances fonctionnelles

* 1 -> 2
* 1 -> 3
* 1 -> 4
* 1 -> 5
* 1 -> 6
* 1 -> 7
* 1 -> 8
* 1 -> 9
* 10 -> 11
* 10 -> 12
* 10 -> 13
* 10 -> 14
* 10 -> 15
* 10 -> 16
* 16 -> 17
* 16 -> 18
* 16 -> 19
* 16 -> 20
* 16 -> 21
* 22 -> 23
* 22 -> 24
* 22 -> 26
* 22 -> 27
* 16+22 -> 25


# Modèle Entité Association et schéma relationnel

![Modèle Entité Association et schéma relationnel](/Cahier_Des_Charges/Modèle%20Entité%20Association%20et%20schéma%20relationnel.png)

# Contraintes particulières
	* Le numero de l'adhérent, son nom, son prénom doivent impérativement être renseignés
	* Un adhérent fait obligatoirement parti d'une promotion (1ère, 2ème ou 3ème année)
	* Un role doit être assigné à chaque étudiant
	* Un adhérent doit nécessairement fournir un moyen de contact (mail, téléphone ou adresse)
	* Une sortie a toujours un identifiant et un nom 
	* Une sortie est toujours associée à un produit particulier du catalogue du BDE
	* On ne peut pas s'inscrire à une sortie après la date de la sortie
	* Le nombre de participants à une sortie ne peut pas dépasser le stock du produit associé 
	* Une produit a un identifiant unique en plus de son nom
	* La quantité d'un produit disponible dans les stocks du BDE doit toujours être accessible
	* La boutique du BDE propose des goodies, des snacks, ou encore la reservation de sorties
    * Le BDE doit aussi pouvoir gérer son stock de materiel
	* Les prix d'achats et de vente, même pour une transaction à crédit, doivent être renseignés
	* Une transaction donné est identifiée par un numéro unique, une date donnée et un type de transaction selon que le BDE achète ou vende.
	* Le BDE accepte uniquement les transactions par carte bancaire, espèces ou à crédit via les ardoises
	* Une transaction implique nécessairement un unique adhérent
	* On ne peut pas vendre un produit dont le stock est vide 
	* Un adherent ne peut pas utiliser son ardoise pour regler une transaction si cette dernière ferait depasser le seuil de -50€ 