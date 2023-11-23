const express = require("express");
const path = require("path");
const { Pool } = require("pg");

// Création du serveur Express
const app = express();

// Configuration du serveur
app.set("view engine", "ejs");
app.set("views", path.join(__dirname, "views"));
app.use(express.static(path.join(__dirname, "public")));
app.use(express.urlencoded({ extended: false }));

const pool = new Pool({
    user: "postgres",
    host: "localhost",
    database: "scamdb",
    password: "mysecretpassword",
    port: 5432
  });
  console.log("Connexion réussie à la base de données");


    // Alimentation de la table
    const sql_insert = `INSERT INTO ADHERENT (numAdherent, nomAdherent, prenomAdherent, promotionAdherent, roleAdherent, telAdherent, mailAdherent, adresseAdherent, ardoiseAdherent)
    VALUES
    (1, 'Doe', 'John', 'A1', 'Membre', '123456789', 'john.doe@example.com', '123 Street, City', 0),
    (2, 'Smith', 'Jane', 'A2', 'Président', '987654321', 'jane.smith@example.com', '456 Avenue, Town', 0),
    (3, 'Johnson', 'Bob', 'ALUMNIE', 'Ancien', '555555555', 'bob.johnson@example.com', '789 Road, Village', 0);`;
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
  
  // GET /adherent
  app.get("/adherents", (req, res) => {
    const sql = "SELECT * FROM adherent ORDER BY nomAdherent";
    pool.query(sql, [], (err, result) => {
      if (err) {
        return console.error(err.message);
      }
      res.render("adherents", { model: result.rows });
    });
  });
  
  // GET /create
  app.get("/create", (req, res) => {
    res.render("create", { model: {} });
  });

  // GET /createadherent
  app.get("/createadherent", (req, res) => {
    res.render("createadherent", { model: {} });
  });
  
  // POST /create
  app.post("/create", (req, res) => {
    const sql = "INSERT INTO Livres (Titre, Auteur, Commentaires) VALUES ($1, $2, $3)";
    const book = [req.body.Titre, req.body.Auteur, req.body.Commentaires];
    pool.query(sql, book, (err, result) => {
      if (err) {
        return console.error(err.message);
      }
      res.redirect("/livres");
    });
  });

  // POST /createadherent
  app.post("/createadherent", (req, res) => {
    const sql = "INSERT INTO ADHERENT (numAdherent, nomAdherent, prenomAdherent, promotionAdherent, roleAdherent, telAdherent, mailAdherent, adresseAdherent, ardoiseAdherent) VALUES($1, $2, $3, $4, $5, $6, $7, $8, $9)";
    const book = [req.body.num, req.body.nom, req.body.prenom, req.body.promo, req.body.role, req.body.tel, req.body.mail, req.body.adresse, req.body.ardoise];
    pool.query(sql, book, (err, result) => {
      if (err) {
        return console.error(err.message);
      }
      res.redirect("/adherents");
    });
  });
  
  // GET /edit/5
  app.get("/edit/:id", (req, res) => {
    const id = req.params.id;
    const sql = "SELECT * FROM Livres WHERE Livre_ID = $1";
    pool.query(sql, [id], (err, result) => {
      if (err) {
        return console.error(err.message);
      }
      res.render("edit", { model: result.rows[0] });
    });
  });
  
  // GET /edit/5
  app.get("/editadherent/:id", (req, res) => {
    const id = req.params.id;
    const sql = "SELECT * FROM ADHERENT WHERE numAdherent = $1";
    pool.query(sql, [id], (err, result) => {
      if (err) {
        return console.error(err.message);
      }
      res.render("editadherent", { model: result.rows[0] });
    });
  });

  // POST /edit/5
  app.post("/edit/:id", (req, res) => {
    const id = req.params.id;
    const book = [req.body.Titre, req.body.Auteur, req.body.Commentaires, id];
    const sql = "UPDATE Livres SET Titre = $1, Auteur = $2, Commentaires = $3 WHERE (Livre_ID = $4)";
    pool.query(sql, book, (err, result) => {
      if (err) {
        return console.error(err.message);
      }
      res.redirect("/livres");
    });
  });
  
    // POST /edit/5
    app.post("/editadherent/:id", (req, res) => {
        const id = req.params.id;
        const book = [req.body.nom, req.body.prenom, req.body.promo, req.body.role, req.body.tel, req.body.mail, req.body.adresse, req.body.ardoise, id];
        const sql = "UPDATE ADHERENT SET nomAdherent  = $1, prenomAdherent  = $2, promotionAdherent   = $3, roleAdherent  =$4, telAdherent =$5, mailAdherent  =$6, adresseAdherent =$7, ardoiseAdherent =$8 WHERE numAdherent = $9";
        pool.query(sql, book, (err, result) => {
          if (err) {
            return console.error(err.message);
          }
          res.redirect("/adherents");
        });
      });


  // GET /delete/5
  app.get("/delete/:id", (req, res) => {
    const id = req.params.id;
    const sql = "SELECT * FROM Livres WHERE Livre_ID = $1";
    pool.query(sql, [id], (err, result) => {
      if (err) {
        return console.error(err.message);
      }
      res.render("delete", { model: result.rows[0] });
    });
  });
  
  // POST /delete/5
  app.post("/delete/:id", (req, res) => {
    const id = req.params.id;
    const sql = "DELETE FROM Livres WHERE Livre_ID = $1";
    pool.query(sql, [id], (err, result) => {
      if (err) {
        return console.error(err.message);
      }
      res.redirect("/livres");
    });
  });

  // GET /delete/5
  app.get("/deleteadherent/:id", (req, res) => {
    const id = req.params.id;
    const sql = "SELECT * FROM ADHERENT WHERE numAdherent = $1";
    pool.query(sql, [id], (err, result) => {
      if (err) {
        return console.error(err.message);
      }
      res.render("deleteadherent", { model: result.rows[0] });
    });
  });
  
  // POST /delete/5
  app.post("/deleteadherent/:id", (req, res) => {
    const id = req.params.id;
    const sql = "DELETE FROM ADHERENT WHERE numAdherent = $1";
    pool.query(sql, [id], (err, result) => {
      if (err) {s
        return console.error(err.message);
      }
      res.redirect("/adherents");
    });
  });