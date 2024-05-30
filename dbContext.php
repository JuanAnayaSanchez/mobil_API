<?php
    //Conectarse a la base de datos
    function dbConect() {
        //conexion DB
                $dbHost = "localhost";
        $dbName = "mobil_db";
        $dbUser = "root";
        $dbPass = "";

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
