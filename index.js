const express = require("express");
const path = require("path");
var moment = require("moment");
const { Pool } = require("pg");

// Création du serveur Express
const app = express();

// Configuration du serveur
app.set("view engine", "ejs");
app.set("views", path.join(__dirname, "views"));
app.use(express.static(path.join(__dirname, "public")));
app.use(express.urlencoded({ extended: false }));

const pool = new Pool({
    user: "dba",
    host: "localhost",
    database: "scamdb",
    password: "mysecretpassword",
    port: 5432
  });
  console.log("Connexion réussie à la base de données");


    // Alimentation de la table
    const sql_insert = `INSERT INTO TRANSACTION (idTransaction, typeTransaction, dateTransaction, methodePaiement, numAdherent, montantTransaction)
    VALUES 
        (1, 'VENTEBDE', '2023-05-12', 'CB', 1, 75.00),
        (2, 'ACHATBDE', '2023-06-25', 'ESPECES', 2, 120.00),
        (3, 'AUTRE', '2023-07-05', 'ARDOISE', 3, 30.00);`;
    pool.query(sql_insert, [], (err, result) => {
      if (err) {
        return console.error(err.message);
      }

        console.log("Alimentation réussie de la table 'Adherents'");
  });
  
  // Démarrage du serveur
  app.listen(3000, () => {
    console.log("Serveur démarré (http://localhost:3000/) !");
  });
  
  // GET /
  app.get("/", (req, res) => {
    // res.send("Bonjour le monde...");
    res.render("index");
  });
  
  // GET /about
  app.get("/about", (req, res) => {
    res.render("about");
  });
  
  // GET /data
  app.get("/data", (req, res) => {
    const test = {
      titre: "Test",
      items: ["un", "deux", "trois"]
    };
    res.render("data", { model: test });
  });
  

//ADHERENTS
  // GET /adherent
  app.get("/adherents", (req, res) => {
    const sql = "SELECT * FROM adherent ORDER BY nomAdherent";
    pool.query(sql, [], (err, result) => {
      if (err) {
        return console.error(err.message);
      }
      res.render("adherents/index", { model: result.rows });
    });
  });
  

  // GET /createadherent
  app.get("/adherents/create", (req, res) => {
    res.render("adherents/create", { model: {} });
  });


  // POST /create
  app.post("/adherents/create", (req, res) => {
    const sql = "INSERT INTO ADHERENT (numAdherent, nomAdherent, prenomAdherent, promotionAdherent, roleAdherent, telAdherent, mailAdherent, adresseAdherent, ardoiseAdherent) VALUES($1, $2, $3, $4, $5, $6, $7, $8, $9)";
    const book = [req.body.num, req.body.nom, req.body.prenom, req.body.promo, req.body.role, req.body.tel, req.body.mail, req.body.adresse, req.body.ardoise];
    pool.query(sql, book, (err, result) => {
      if (err) {
        console.error(err.message);
        res.render("adherent/createerror", { message: 'Erreur 500 : erreur lors de la création' });
        return;
      }
      res.redirect("/adherents");
    });
  });
  
  
  // GET /edit
  app.get("/adherents/edit/:id", (req, res) => {
    const id = req.params.id;
    const sql = "SELECT * FROM ADHERENT WHERE numAdherent = $1";
    pool.query(sql, [id], (err, result) => {
      if (err) {
        console.error(err.message);
        res.render("adherent/editerror", { message: 'Erreur 500 : erreur lors de la modification' });
        return;
      }
      res.render("adherents/edit", { model: result.rows[0] });
    });
  });

    // POST /edit
    app.post("/adherents/edit/:id", (req, res) => {
        const id = req.params.id;
        const book = [req.body.nom, req.body.prenom, req.body.promo, req.body.role, req.body.tel, req.body.mail, req.body.adresse, req.body.ardoise, id];
        const sql = "UPDATE ADHERENT SET nomAdherent  = $1, prenomAdherent  = $2, promotionAdherent   = $3, roleAdherent  =$4, telAdherent =$5, mailAdherent  =$6, adresseAdherent =$7, ardoiseAdherent =$8 WHERE numAdherent = $9";
        pool.query(sql, book, (err, result) => {
          if (err) {
            console.error(err.message);
            res.render("adherent/editerror", { message: 'Erreur 500 : erreur lors de la modification' });
            return;
          }
          res.redirect("/adherents");
        });
      });


  // GET /delete
  app.get("/adherents/delete/:id", (req, res) => {
    const id = req.params.id;
    const sql = "SELECT * FROM ADHERENT WHERE numAdherent = $1";
    pool.query(sql, [id], (err, result) => {
      if (err) {
        console.error(err.message);
        res.render("adherent/editerror", { message: 'Erreur 500 : erreur lors de la suppression' });
        return;
      }
      res.render("adherents/delete", { model: result.rows[0] });
    });
  });
  
  // POST /delete
  app.post("/adherents/delete/:id", (req, res) => {
    const id = req.params.id;
    const sql = "DELETE FROM ADHERENT WHERE numAdherent = $1";
    pool.query(sql, [id], (err, result) => {
      if (err) {s
        console.error(err.message);
        res.render("adherent/editerror", { message: 'Erreur 500 : erreur lors de la suppression' });
        return;
      }
      res.redirect("/adherents");
    });
  });

  //PRODUITS
  // GET /produits
  app.get("/produits", (req, res) => {
    const sql = "SELECT * FROM produit ORDER BY idproduit";
    pool.query(sql, [], (err, result) => {
      if (err) {
        return console.error(err.message);
      }
      res.render("produits/index", { model: result.rows });
    });
  });
  

  // GET /create
  app.get("/produits/create", (req, res) => {
    res.render("produits/create", { model: {} });
  });


  // POST /create
  app.post("/produits/create", (req, res) => {
    const sql = "INSERT INTO PRODUIT (idProduit , nomProduit , qteProduitEnStock , prixAchatProduit , prixVenteProduit , typeProduit) VALUES($1, $2, $3, $4, $5, $6)";
    const book = [req.body.id, req.body.nom, req.body.stock, req.body.achat, req.body.vente, req.body.type];
    pool.query(sql, book, (err, result) => {
      if (err) {
        return console.error(err.message);
      }
      res.redirect("/produits");
    });
  });
  
  
  // GET /edit
  app.get("/produits/edit/:id", (req, res) => {
    const id = req.params.id;
    const sql = "SELECT * FROM PRODUIT WHERE idproduit = $1";
    pool.query(sql, [id], (err, result) => {
      if (err) {
        return console.error(err.message);
      }
      res.render("produits/edit", { model: result.rows[0] });
    });
  });

    // POST /edit
    app.post("/produits/edit/:id", (req, res) => {
        const id = req.params.id;
        const book = [req.body.nom, req.body.stock, req.body.achat, req.body.vente, req.body.type, id];
        const sql = "UPDATE PRODUIT SET nomProduit  = $1, qteProduitEnStock   = $2, prixAchatProduit  =$3, prixVenteProduit =$4, typeProduit  =$5 WHERE idProduit = $6";
        pool.query(sql, book, (err, result) => {
          if (err) {
            return console.error(err.message);
          }
          res.redirect("/produits");
        });
      });


  // GET /delete
  app.get("/adheproduitsrents/delete/:id", (req, res) => {
    const id = req.params.id;
    const sql = "SELECT * FROM PRODUIT WHERE idProduit = $1";
    pool.query(sql, [id], (err, result) => {
      if (err) {
        return console.error(err.message);
      }
      res.render("produits/delete", { model: result.rows[0] });
    });
  });
  
  // POST /delete
  app.post("/produits/delete/:id", (req, res) => {
    const id = req.params.id;
    const sql = "DELETE FROM PRODUIT WHERE idProduit = $1";
    pool.query(sql, [id], (err, result) => {
      if (err) {s
        return console.error(err.message);
      }
      res.redirect("/produits");
    });
  });

  //Sorties
  // GET /sorties
  app.get("/sorties", (req, res) => {
    const sql = "SELECT * FROM SORTIE ORDER BY dateSortie";
    pool.query(sql, [], (err, result) => {
      if (err) {
        return console.error(err.message);
      }
      res.render("sorties/index", { model: result.rows , moment: moment });
    });
  });
  

  // GET /create
  app.get("/sorties/create", (req, res) => {
    res.render("sorties/create", { model: {} , moment: moment });
  });


  // POST /create
  app.post("/sorties/create", (req, res) => {
    const sql = "INSERT INTO SORTIE (idSortie, nomSortie, dateSortie, prixSortie, nbParticipants, lieuSortie, idProduit) VALUES($1, $2, $3, $4, $5, $6, $7)";
    const book = [req.body.id, req.body.nom, req.body.date, req.body.prix, req.body.nb, req.body.lieu, req.body.prod];
    pool.query(sql, book, (err, result) => {
      if (err) {
        return console.error(err.message);
      }
      res.redirect("/sorties");
    });
  });
  
  
  // GET /edit
  app.get("/sorties/edit/:id", (req, res) => {
    const id = req.params.id;
    const sql = "SELECT * FROM SORTIE WHERE idSortie = $1";
    pool.query(sql, [id], (err, result) => {
      if (err) {
        return console.error(err.message);
      }
      res.render("sorties/edit", { model: result.rows[0] , moment: moment  });
    });
  });

    // POST /edit
    app.post("/sorties/edit/:id", (req, res) => {
        const id = req.params.id;
        const book = [req.body.nom, req.body.date, req.body.prix, req.body.nb, req.body.lieu, req.body.prod, id];
        const sql = "UPDATE SORTIE SET nomSortie  = $1, dateSortie  = $2, prixSortie   = $3, nbParticipants  =$4, lieuSortie =$5, idProduit  =$6 WHERE idSortie = $7";
        pool.query(sql, book, (err, result) => {
          if (err) {
            return console.error(err.message);
          }
          res.redirect("/sorties");
        });
      });


  // GET /delete
  app.get("/sorties/delete/:id", (req, res) => {
    const id = req.params.id;
    const sql = "SELECT * FROM SORTIE WHERE idSortie = $1";
    pool.query(sql, [id], (err, result) => {
      if (err) {
        return console.error(err.message);
      }
      res.render("sorties/delete", { model: result.rows[0] , moment: moment });
    });
  });
  
  // POST /delete
  app.post("/sorties/delete/:id", (req, res) => {
    const id = req.params.id;
    const sql = "DELETE FROM SORTIE WHERE idSortie = $1";
    pool.query(sql, [id], (err, result) => {
      if (err) {s
        return console.error(err.message);
      }
      res.redirect("/sorties");
    });
  });

    //Transactions
  // GET /transactions
  app.get("/transactions", (req, res) => {
    const sql = "SELECT * FROM TRANSACTION ORDER BY dateTransaction";
    pool.query(sql, [], (err, result) => {
      if (err) {
        return console.error(err.message);
      }
      res.render("transactions/index", { model: result.rows , moment: moment });
    });
  });
  

  // GET /create
  app.get("/transactions/create", (req, res) => {
    res.render("transactions/create", { model: {} , moment: moment });
  });


  // POST /create
  app.post("/transactions/create", (req, res) => {
    const sql = "INSERT INTO TRANSACTION (idTransaction, typeTransaction, dateTransaction, methodePaiement, numAdherent, montantTransaction) VALUES($1, $2, $3, $4, $5, $6)";
    const book = [req.body.id, req.body.type, req.body.date, req.body.methode, req.body.num, req.body.montant];
    pool.query(sql, book, (err, result) => {
      if (err) {
        return console.error(err.message);
      }
      res.redirect("/transactions");
    });
  });
  
  
  // GET /edit
  app.get("/transactions/edit/:id", (req, res) => {
    const id = req.params.id;
    const sql = "SELECT * FROM TRANSACTION WHERE idTransaction = $1";
    pool.query(sql, [id], (err, result) => {
      if (err) {
        return console.error(err.message);
      }
      res.render("transactions/edit", { model: result.rows[0] , moment: moment  });
    });
  });

    // POST /edit
    app.post("/transactions/edit/:id", (req, res) => {
        const id = req.params.id;
        const book = [req.body.type, req.body.date, req.body.methode, req.body.num, req.body.montant, id];
        const sql = "UPDATE TRANSACTION SET typeTransaction   = $1, dateTransaction   = $2, methodePaiement    = $3, numAdherent   =$4, montantTransaction  =$5 WHERE idTransaction = $6";
        pool.query(sql, book, (err, result) => {
          if (err) {
            return console.error(err.message);
          }
          res.redirect("/transactions");
        });
      });


  // GET /delete
  app.get("/transactions/delete/:id", (req, res) => {
    const id = req.params.id;
    const sql = "SELECT * FROM TRANSACTION WHERE idTransaction = $1";
    pool.query(sql, [id], (err, result) => {
      if (err) {
        return console.error(err.message);
      }
      res.render("transactions/delete", { model: result.rows[0] , moment: moment });
    });
  });
  
  // POST /delete
  app.post("/transactions/delete/:id", (req, res) => {
    const id = req.params.id;
    const sql = "DELETE FROM TRANSACTION WHERE idTransaction = $1";
    pool.query(sql, [id], (err, result) => {
      if (err) {s
        return console.error(err.message);
      }
      res.redirect("/transactions");
    });
  });