<?php

    include 'dbContext.php';
    include 'models.php';

    $url = $_SERVER['REQUEST_URI'];
    

    $dbConn = dbConect();

    if ($_SERVER['REQUEST_METHOD'] === 'POST' && $url === '/mobil_API/ValidateUserExist') {
    
        try{
            $requestData = json_decode(file_get_contents('php://input'), true);
            $phone_input = $requestData['phone_input'] ?? null;
            if ($phone_input !== null) {
                // Ejecutar procedimiento almacenado
                $stmt = $dbConn->prepare("CALL check_user_exist(:prmphone)");
                $stmt->bindParam(':prmphone', $phone_input, PDO::PARAM_INT);
                $stmt->execute();
    
                // Recoger registros como un arreglo asociativo
                $registros = $stmt->fetch(PDO::FETCH_ASSOC);
                if($registros == false) $registros = null;
                // Codificar y retornar respuesta
                $response = new APIResponse(200,'Success',$registros);

                header('Content-Type: application/json');
                echo json_encode($response);
            } else {
                http_response_code(400);
                $response = new APIResponse(400,'Missing parameter phone_input parameter',[]);
                header('Content-Type: application/json');
                echo json_encode($response);
            }
        }catch(PDOException $e){
            http_response_code(500);
            $response = new APIResponse(500,'Internal Server Error',[]);
            header('Content-Type: application/json');
            echo json_encode($response);
        }
    }

    if($_SERVER['REQUEST_METHOD'] === 'POST' && $url === '/mobil_API/ValidateCodeExist'){
        try{
            $requestData = json_decode(file_get_contents('php://input'), true);
            $code_name_input = $requestData['code_name_input'] ?? null;
            if($code_name_input !== null){
                // Ejecutar procedimiento almacenado
                $stmt = $dbConn->prepare("CALL check_code_exist(:prmname, @prmexists)");
                $stmt->bindParam(':prmname', $code_name_input, PDO::PARAM_STR);
                $stmt->execute();
    
                // Obtener el resultado de la variable de salida
                $stmt = $dbConn->prepare("SELECT @prmexists AS prmexists");
                $stmt->execute();
                $result = $stmt->fetch(PDO::FETCH_ASSOC);
    
                // Interpretar el resultado
                $exists = $result['prmexists'] ?? 0; // Si no hay resultado, se asume falso (0)
            
                // Codificar y retornar respuesta
                $response = new APIResponse(200, 'Success', ['exists' => (bool)$exists]);
                header('Content-Type: application/json');
                echo json_encode($response);
            }else{
                http_response_code(400);
                $response = new APIResponse(400, 'Missing parameter code_name_input', []);
                header('Content-Type: application/json');
                echo json_encode($response);
            }
        }catch (PDOException $e){
            http_response_code(500);
            $response = new APIResponse(500, 'Internal Server Error', $e);
            header('Content-Type: application/json');
            echo json_encode($response);
        }
    }

    if ($_SERVER['REQUEST_METHOD'] === 'POST' && $url === '/mobil_API/InsertUser') {
        try {
            $requestData = json_decode(file_get_contents('php://input'), true);
            $name = $requestData['name_input'] ?? null;
            $mail = $requestData['mail_input'] ?? null;
            $city = $requestData['city_input'] ?? null;
            $phone = $requestData['phone_input'] ?? null;
            $identification_number = $requestData['identification_number_input'] ?? null;
    
            if ($name !== null && $mail !== null && $city !== null && $phone !== null && $identification_number !== null) {
                // Ejecutar procedimiento almacenado para validar si el número de teléfono ya existe
                $stmt = $dbConn->prepare("CALL insert_user(:prmname, :prmmail, :prmcity, :prmphone, :prmidentification_number, @phone_exist, @new_user_id)");
                $stmt->bindParam(':prmname', $name, PDO::PARAM_STR);
                $stmt->bindParam(':prmmail', $mail, PDO::PARAM_STR);
                $stmt->bindParam(':prmcity', $city, PDO::PARAM_STR);
                $stmt->bindParam(':prmphone', $phone, PDO::PARAM_INT);
                $stmt->bindParam(':prmidentification_number', $identification_number, PDO::PARAM_INT);
                $stmt->execute();
    
                // Obtener el resultado de las variables de salida
                $stmt = $dbConn->prepare("SELECT @phone_exist AS phone_exist, @new_user_id AS new_user_id");
                $stmt->execute();
                $result = $stmt->fetch(PDO::FETCH_ASSOC);
    
                // Obtener los datos del usuario insertado utilizando el nuevo ID
                $newUserId = $result['new_user_id'];
                $userQuery = $dbConn->prepare("SELECT id, name, mail, city, phone, identification_number, date FROM users WHERE id = :newUserId");
                $userQuery->bindParam(':newUserId', $newUserId, PDO::PARAM_INT);
                $userQuery->execute();
                $userData = $userQuery->fetch(PDO::FETCH_ASSOC);
    
                // Interpretar el resultado
                $phoneExist = $result['phone_exist'] ?? 0; // Si no hay resultado, se asume falso (0)
    
                // Construir y retornar respuesta
                $response = new APIResponse(200, 'Success', [
                    'user' => $userData,
                    'phone_exist' => (bool)$phoneExist
                ]);
                header('Content-Type: application/json');
                echo json_encode($response);
            } else {
                // Si falta algún parámetro en la solicitud, responder con un código de estado 400 y un mensaje de error
                http_response_code(400);
                $response = new APIResponse(400, 'Missing parameters', []);
                header('Content-Type: application/json');
                echo json_encode($response);
            }
        } catch (PDOException $e) {
            // Si ocurre un error en la base de datos, responder con un código de estado 500 y un mensaje de error
            http_response_code(500);
            $response = new APIResponse(500, 'Database Error', []);
            header('Content-Type: application/json');
            echo json_encode($response);
        }
    }
?>