<?php
    //Conectarse a la base de datos
    function dbConect() {
        //conexion DB
        $dbHost = "srv725.hstgr.io";
        $dbName = "u326127156_terpel";
        $dbUser = "u326127156_terpel";
        $dbPass = "Terpel2023@";

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
