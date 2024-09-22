<?php
    //Conectarse a la base de datos
    function dbConect() {
        //conexion DB
        $dbHost = "104.248.235.244";
        $dbName = "Masterlub";
        $dbUser = "admin";
        $dbPass = "49aad59c920c86760cf2c60fd5e486952bd67a9ebe3fba36";

        try {
          $dbConn = new PDO("mysql:host=$dbHost;dbname=$dbName", $dbUser, $dbPass);
          $dbConn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
          return $dbConn;
        } catch (PDOException $e) {
          echo "Error to conect to db" . $e->getMessage();
          exit;
        }
    }
?>
