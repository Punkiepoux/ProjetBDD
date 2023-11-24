-- Active: 1700824964365@@127.0.0.1@5432@postgres_user
--CREATE DATABASE ma_base_BDE
CREATE DOMAIN PROMOTION AS VARCHAR(20) CHECK (VALUE IN ('A1', 'A2', 'A3', 'ALUMNI'));
CREATE DOMAIN TYPE_PRODUIT_BDE AS VARCHAR(20) CHECK (
    VALUE IN (
        'MATERIEL',
        'SNACK',
        'GOODIES',
        'SORTIE'
    )
);
CREATE DOMAIN TYPE_TRANSACTION_BDE AS VARCHAR(20) CHECK (
    VALUE IN (
        'VENTEBDE',
        'ACHATBDE',
        'AUTRE'
    )
);
CREATE DOMAIN METHODE_PAIEMENT_BDE AS VARCHAR(20) CHECK (VALUE IN ('CB', 'ESPECES', 'ARDOISE'));
-- Création de la table ADHERENT
CREATE TABLE ADHERENT (
    numAdherent SERIAL PRIMARY KEY,
    nomAdherent VARCHAR(255) NOT NULL,
    prenomAdherent VARCHAR(255) NOT NULL,
    promotionAdherent PROMOTION NOT NULL,
    roleAdherent VARCHAR(255) NOT NULL,
    telAdherent VARCHAR(255),
    mailAdherent VARCHAR(255),
    adresseAdherent VARCHAR(255),
    ardoiseAdherent INT
);
-- Création de la table PRODUIT
CREATE TABLE PRODUIT (
    idProduit SERIAL PRIMARY KEY,
    nomProduit VARCHAR(255) NOT NULL,
    qteProduitEnStock INT NOT NULL,
    prixAchatProduit INT CHECK (prixAchatProduit > 0),
    prixVenteProduit INT CHECK (prixVenteProduit > 0),
    typeProduit TYPE_PRODUIT_BDE
);
-- Création de la table SORTIE
CREATE TABLE SORTIE (
    idSortie SERIAL PRIMARY KEY,
    nomSortie VARCHAR(255) NOT NULL,
    dateSortie DATE,
    prixSortie DECIMAL(10, 2),
    nbParticipants INT,
    lieuSortie VARCHAR(255),
    idProduit INT REFERENCES PRODUIT(idProduit) NOT NULL
);
-- Création de la table TRANSACTION
CREATE TABLE TRANSACTION (
    idTransaction SERIAL PRIMARY KEY,
    typeTransaction TYPE_TRANSACTION_BDE,
    dateTransaction DATE,
    methodePaiement METHODE_PAIEMENT_BDE,
    numAdherent INT REFERENCES ADHERENT(numAdherent) NOT NULL,
    montantTransaction DECIMAL(10, 2)
);
-- Création de la table CONTENU_TRANSACTION
CREATE TABLE CONTENU_TRANSACTION (
    idTransaction INT REFERENCES TRANSACTION(idTransaction) NOT NULL,
    idProduit INT REFERENCES PRODUIT(idProduit) NOT NULL,
    qteProduitTransaction INT,
    PRIMARY KEY(idTransaction, idProduit)
);
-- Création de la table PARTICIPANTS_SORTIE
CREATE TABLE PARTICIPANTS_SORTIE (
    numAdherent INT REFERENCES ADHERENT(numAdherent) NOT NULL,
    idSortie INT REFERENCES SORTIE(idSortie) NOT NULL,
    PRIMARY KEY(numAdherent, idSortie)
);
--TRIGGERS
CREATE OR REPLACE FUNCTION VERIFCONTACTADHERENT() RETURNS TRIGGER AS $$ BEGIN IF (
        new.telAdherent IS NULL
        OR new.telAdherent = ''
    )
    AND (
        new.mailAdherent IS NULL
        OR new.mailAdherent = ''
    )
    AND (
        new.adresseAdherent IS NULL
        OR new.adresseAdherent = ''
    ) THEN RAISE EXCEPTION 'Un moyen de contact est obligatoire';
RETURN NULL;
ELSE RETURN new;
END IF;
END;
$$ LANGUAGE PLPGSQL;
CREATE TRIGGER VerifContactAdherent BEFORE
INSERT
    OR
UPDATE ON ADHERENT FOR EACH ROW EXECUTE PROCEDURE VerifContactAdherent();
CREATE OR REPLACE FUNCTION VERIFDATESORTIE() RETURNS TRIGGER AS $$
DECLARE dates_nok boolean := false;
sortie_ok boolean := false;
BEGIN
SELECT P.typeProduit = 'SORTIE' INTO sortie_ok
FROM produit P
WHERE P.idProduit = new.idProduit;
SELECT T.dateTransaction >= S.dateSortie INTO dates_nok
FROM SORTIE S,
    TRANSACTION T
WHERE S.idProduit = new.idProduit
    AND T.idTransaction = new.idTransaction;
IF (
    sortie_ok
    AND dates_nok
) THEN
DELETE FROM TRANSACTION
WHERE idTransaction = new.idTransaction;
RAISE EXCEPTION 'date de la sortie anterieur a la reservation, transaction annulée!';
RETURN NULL;
-- ne renvoie rien, insertion abandonnée --
ELSE RETURN new;
END IF;
END;
$$ LANGUAGE PLPGSQL;
CREATE TRIGGER VerifDateSortie BEFORE
INSERT
    OR
UPDATE ON CONTENU_TRANSACTION FOR EACH ROW EXECUTE PROCEDURE VerifDateSortie();

CREATE OR REPLACE FUNCTION removeContenu() RETURNS TRIGGER AS $$
BEGIN
DELETE FROM CONTENU_TRANSACTION
WHERE idTransaction = old.idTransaction;
RETURN OLD;
END;
$$ LANGUAGE PLPGSQL;
CREATE TRIGGER removeContenu
BEFORE DELETE ON TRANSACTION FOR EACH ROW EXECUTE PROCEDURE removeContenu();


CREATE OR REPLACE FUNCTION restoreStock() RETURNS TRIGGER AS $$
DECLARE 
l_typeTransaction TYPE_TRANSACTION_BDE := 'AUTRE';
BEGIN
SELECT T.typeTransaction INTO l_typeTransaction
FROM TRANSACTION T
WHERE T.idTransaction = old.idTransaction;
IF l_typeTransaction = 'VENTEBDE' THEN
UPDATE PRODUIT
SET qteProduitEnStock = qteProduitEnStock + old.qteProduitTransaction
WHERE PRODUIT.idProduit = old.idProduit;
ELSE
UPDATE PRODUIT
SET qteProduitEnStock = qteProduitEnStock - old.qteProduitTransaction
WHERE  PRODUIT.idProduit = old.idProduit;
END IF;
RETURN OLD;
END;
$$ LANGUAGE PLPGSQL;
CREATE TRIGGER restoreStock
AFTER DELETE ON CONTENU_TRANSACTION FOR EACH ROW EXECUTE PROCEDURE restoreStock();
CREATE OR REPLACE FUNCTION VERIFSTOCKPRODUIT() RETURNS TRIGGER AS $$
DECLARE stock int := 0;
l_typeTransaction TYPE_TRANSACTION_BDE := 'AUTRE';
BEGIN
SELECT T.typeTransaction INTO l_typeTransaction
FROM TRANSACTION T
WHERE T.idTransaction = new.idTransaction;
SELECT P.qteProduitEnStock - new.qteProduitTransaction INTO stock
FROM PRODUIT P
WHERE P.idProduit = new.idProduit;
IF l_typeTransaction = 'VENTEBDE' THEN IF (stock >= 0) THEN
UPDATE PRODUIT
SET qteProduitEnStock = stock
WHERE idProduit = new.idProduit;
RETURN new;
ELSE
DELETE FROM TRANSACTION T
WHERE T.idTransaction = new.idTransaction;
RAISE EXCEPTION 'stock produit insuffisant, transaction annulée!';
RETURN NULL;
-- ne renvoie rien, insertion abandonnée --
END IF;
ELSE
UPDATE PRODUIT
SET qteProduitEnStock = qteProduitEnStock + new.qteProduitTransaction
WHERE idProduit = new.idProduit;
RETURN new;
END IF;
END;
$$ LANGUAGE PLPGSQL;
CREATE TRIGGER VerifStockProduit BEFORE
INSERT ON CONTENU_TRANSACTION FOR EACH ROW EXECUTE PROCEDURE VerifStockProduit();
CREATE OR REPLACE FUNCTION VERIFARDOISE() RETURNS TRIGGER AS $$
DECLARE ardoise_ok boolean := false;
BEGIN
SELECT A.ardoiseAdherent - new.montantTransaction > -50 INTO ardoise_ok
FROM ADHERENT A
WHERE A.numAdherent = new.numAdherent;
IF new.methodePaiement = 'ARDOISE' THEN IF (ardoise_ok) THEN
UPDATE ADHERENT
SET ardoiseAdherent = ardoiseAdherent - new.montantTransaction
WHERE numAdherent = new.numAdherent;
RETURN new;
ELSE RAISE EXCEPTION 'plafond ardoise atteint';
RETURN NULL;
END IF;
ELSE RETURN new;
END IF;
END;
$$ LANGUAGE PLPGSQL;
CREATE TRIGGER VerifArdoise BEFORE
INSERT
    OR
UPDATE ON TRANSACTION FOR EACH ROW EXECUTE PROCEDURE VerifArdoise();
-- Sample data for ADHERENT table
INSERT INTO ADHERENT (
        nomAdherent,
        prenomAdherent,
        promotionAdherent,
        roleAdherent,
        telAdherent,
        mailAdherent,
        adresseAdherent,
        ardoiseAdherent
    )
VALUES (
        'Smith',
        'John',
        'A1',
        'Member',
        '123456789',
        'john@example.com',
        '123 Main St',
        0
    ),
    (
        'Doe',
        'Jane',
        'A2',
        'Treasurer',
        '987654321',
        'jane@example.com',
        '456 Elm St',
        0
    ),
    (
        'Johnson',
        'Robert',
        'ALUMNI',
        'Alumni',
        '555555555',
        'robert@example.com',
        '789 Oak St',
        0
    );
-- Sample data for PRODUIT table
INSERT INTO PRODUIT (
        nomProduit,
        qteProduitEnStock,
        prixAchatProduit,
        prixVenteProduit,
        typeProduit
    )
VALUES (
        'Pen',
        100,
        50,
        100,
        'MATERIEL'
    ),
    ('Chips', 50, 20, 50, 'SNACK'),
    (
        'Keychain',
        30,
        80,
        150,
        'GOODIES'
    );
-- Sample data for SORTIE table
INSERT INTO SORTIE (
        nomSortie,
        dateSortie,
        prixSortie,
        nbParticipants,
        lieuSortie,
        idProduit
    )
VALUES (
        'Hiking Trip',
        '2023-05-10',
        250.00,
        20,
        'Mountain Trail',
        3
    ),
    (
        'Movie Night',
        '2023-06-20',
        100.00,
        50,
        'Cinema Hall',
        2
    );
-- Sample data for TRANSACTION table
INSERT INTO TRANSACTION (
        typeTransaction,
        dateTransaction,
        methodePaiement,
        numAdherent,
        montantTransaction
    )
VALUES (
        'VENTEBDE',
        '2023-05-12',
        'CB',
        1,
        75.00
    ),
    (
        'ACHATBDE',
        '2023-06-25',
        'ESPECES',
        2,
        120.00
    ),
    (
        'AUTRE',
        '2023-07-05',
        'ARDOISE',
        3,
        30.00
    );
-- Sample data for CONTENU_TRANSACTION table
INSERT INTO CONTENU_TRANSACTION (
        idTransaction,
        idProduit,
        qteProduitTransaction
    )
VALUES (1, 1, 5),
    (2, 2, 3),
    (3, 3, 2);
-- Sample data for PARTICIPANTS_SORTIE table
INSERT INTO PARTICIPANTS_SORTIE (numAdherent, idSortie)
VALUES (1, 1),
    (2, 2),
    (3, 1);