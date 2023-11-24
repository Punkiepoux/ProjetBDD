--CREATE DATABASE ma_base_BDE

CREATE DOMAIN PROMOTION
AS VARCHAR(20)
CHECK (VALUE IN ('A1', 'A2', 'A3', 'ALUMNI'));

CREATE DOMAIN TYPE_PRODUIT_BDE
AS VARCHAR(20)
CHECK (VALUE IN ('MATERIEL', 'SNACK', 'GOODIES', 'SORTIE'));

CREATE DOMAIN TYPE_TRANSACTION_BDE
AS VARCHAR(20)
CHECK (VALUE IN ('VENTEBDE', 'ACHATBDE', 'AUTRE'));

CREATE DOMAIN METHODE_PAIEMENT_BDE 
AS VARCHAR(20)
CHECK (VALUE IN ('CB', 'ESPECES', 'ARDOISE'));


-- Création de la table ADHERENT
CREATE TABLE ADHERENT (
    numAdherent INT PRIMARY KEY,
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
    idProduit INT PRIMARY KEY,
    nomProduit VARCHAR(255) NOT NULL,
    qteProduitEnStock INT NOT NULL,
    prixAchatProduit INT CHECK (prixAchatProduit > 0),
    prixVenteProduit INT CHECK (prixVenteProduit > 0),
    typeProduit TYPE_PRODUIT_BDE
);

-- Création de la table SORTIE

CREATE TABLE SORTIE (
    idSortie INT PRIMARY KEY,
    nomSortie VARCHAR(255) NOT NULL,
    dateSortie DATE,
    prixSortie DECIMAL(10,2),
    nbParticipants INT,
    lieuSortie VARCHAR(255),
    idProduit INT REFERENCES PRODUIT(idProduit) NOT NULL
);


-- Création de la table TRANSACTION
CREATE TABLE TRANSACTION (
    idTransaction INT PRIMARY KEY,
    typeTransaction TYPE_TRANSACTION_BDE,
    dateTransaction DATE,
    methodePaiement METHODE_PAIEMENT_BDE,
    numAdherent INT REFERENCES ADHERENT(numAdherent) NOT NULL,
    montantTransaction DECIMAL(10,2)
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

CREATE OR REPLACE FUNCTION VerifContactAdherent()
RETURNS TRIGGER
AS $$
BEGIN
    IF new.telAdherent IS NULL AND new.mailAdherent IS NULL AND new.adresseAdherent IS NULL THEN
        RAISE INFO 'Un moyen de contact est obligatoire' ;
        RETURN NULL;
    ELSE
        RETURN new;

    END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER VerifContactAdherent
	BEFORE INSERT OR UPDATE ON ADHERENT
	FOR EACH ROW 
	EXECUTE PROCEDURE VerifContactAdherent();

CREATE OR REPLACE FUNCTION VerifDateSortie()
RETURNS TRIGGER
AS $$
DECLARE
    dates_nok boolean := false;
    sortie_ok boolean := false;
    l_typeTransaction TYPE_TRANSACTION_BDE := 'AUTRE';
BEGIN
 SELECT P.typeProduit = 'SORTIE'
 INTO sortie_ok
 FROM produit P
 WHERE P.idProduit = new.idProduit;
 SELECT T.dateTransaction >= S.dateSortie
    INTO dates_nok
    FROM SORTIE S, TRANSACTION T  
    WHERE S.idProduit = new.idProduit
    AND T.idTransaction = new.idTransaction;
    IF (sortie_ok AND dates_nok)  THEN
         RAISE INFO 'date de la sortie anterieur a la reservation, transaction annulée!' ;
             SELECT T.typeTransaction
             INTO l_typeTransaction
             FROM TRANSACTION T
             WHERE T.idTransaction = new.idTransaction;
                IF l_typeTransaction = 'VENTEBDE' THEN
                    UPDATE PRODUIT   
                    SET qteProduitEnStock = qteProduitEnStock + CONTENU_TRANSACTION.qteProduitTransaction
                    FROM CONTENU_TRANSACTION
                    WHERE  PRODUIT.idProduit = CONTENU_TRANSACTION.idProduit
                    AND     CONTENU_TRANSACTION.idTransaction = new.idTransaction;
                ELSE
                  UPDATE PRODUIT   
                    SET qteProduitEnStock = qteProduitEnStock - CONTENU_TRANSACTION.qteProduitTransaction
                    FROM CONTENU_TRANSACTION
                    WHERE  PRODUIT.idProduit = CONTENU_TRANSACTION.idProduit
                    AND     CONTENU_TRANSACTION.idTransaction = new.idTransaction; 
                 END IF;
            DELETE FROM CONTENU_TRANSACTION
            WHERE idTransaction = new.idTransaction;
            DELETE FROM TRANSACTION
            WHERE idTransaction = new.idTransaction;
            RETURN NULL; -- ne renvoie rien, insertion abandonnée --
    ELSE 
            RETURN new;
        
    END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER VerifDateSortie
	BEFORE INSERT OR UPDATE ON CONTENU_TRANSACTION
	FOR EACH ROW 
	EXECUTE PROCEDURE VerifDateSortie();

CREATE OR REPLACE FUNCTION VerifStockProduit()
RETURNS TRIGGER
AS $$
DECLARE
    stock int :=0;
    l_typeTransaction TYPE_TRANSACTION_BDE := 'AUTRE';
BEGIN
 SELECT T.typeTransaction
 INTO l_typeTransaction
 FROM TRANSACTION T
 WHERE T.idTransaction = new.idTransaction;
 SELECT P.qteProduitEnStock -  new.qteProduitTransaction
    INTO stock
    FROM PRODUIT P
    WHERE  P.idProduit = new.idProduit;
    IF l_typeTransaction = 'VENTEBDE' THEN
        IF (stock >= 0) THEN
            UPDATE PRODUIT   
            SET qteProduitEnStock =stock
            WHERE  idProduit = new.idProduit;
            RETURN new;
        ELSE
            RAISE INFO 'stock produit insuffisant, transaction annulée!' ;
            IF l_typeTransaction = 'VENTEBDE' THEN
                    UPDATE PRODUIT   
                    SET qteProduitEnStock = qteProduitEnStock + CONTENU_TRANSACTION.qteProduitTransaction
                    FROM CONTENU_TRANSACTION
                    WHERE  PRODUIT.idProduit = CONTENU_TRANSACTION.idProduit
                    AND     CONTENU_TRANSACTION.idTransaction = new.idTransaction;
                ELSE
                  UPDATE PRODUIT   
                    SET qteProduitEnStock = qteProduitEnStock - CONTENU_TRANSACTION.qteProduitTransaction
                    FROM CONTENU_TRANSACTION
                    WHERE  PRODUIT.idProduit = CONTENU_TRANSACTION.idProduit
                    AND     CONTENU_TRANSACTION.idTransaction = new.idTransaction; 
                 END IF;
            DELETE FROM CONTENU_TRANSACTION CT
            WHERE CT.idTransaction = new.idTransaction;
            DELETE FROM TRANSACTION T
            WHERE T.idTransaction = new.idTransaction;
            
            RETURN NULL; -- ne renvoie rien, insertion abandonnée --
        END IF;
    ELSE
            UPDATE PRODUIT 
            SET qteProduitEnStock = qteProduitEnStock + new.qteProduitTransaction
            WHERE idProduit = new.idProduit;
            RETURN new;
    END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER VerifStockProduit
	BEFORE INSERT ON CONTENU_TRANSACTION
	FOR EACH ROW 
	EXECUTE PROCEDURE VerifStockProduit();

CREATE OR REPLACE FUNCTION VerifArdoise()
RETURNS TRIGGER
AS $$
DECLARE
    ardoise_ok boolean := false;
BEGIN
SELECT A.ardoiseAdherent  - new.montantTransaction > -50 
INTO ardoise_ok
FROM ADHERENT A  
WHERE A.numAdherent = new.numAdherent;
IF new.methodePaiement = 'ARDOISE' THEN
    IF (ardoise_ok) THEN
        UPDATE ADHERENT
        SET ardoiseAdherent = ardoiseAdherent - new.montantTransaction
        WHERE numAdherent = new.numAdherent;
        RETURN new;
    ELSE
        RAISE INFO 'plafond ardoise atteint' ;
        RETURN NULL; 
    END IF;
ELSE
    RETURN new;
END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER VerifArdoise
	BEFORE INSERT OR UPDATE ON TRANSACTION
	FOR EACH ROW 
	EXECUTE PROCEDURE VerifArdoise();
