<?php
    header("Access-Control-Allow-Origin: *");
    header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
    header("Access-Control-Allow-Headers: Content-Type, Authorization");

    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        http_response_code(204);
        exit;
    }

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
                $stmt = $dbConn->prepare("CALL insert_user(:prmname, :prmmail, :prmcity, :prmphone, :prmidentification_number, @phone_exist, @new_user_id)");
                $stmt->bindParam(':prmname', $name, PDO::PARAM_STR);
                $stmt->bindParam(':prmmail', $mail, PDO::PARAM_STR);
                $stmt->bindParam(':prmcity', $city, PDO::PARAM_STR);
                $stmt->bindParam(':prmphone', $phone, PDO::PARAM_STR);
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
                if(!$userData) $userData = null;
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

    if($_SERVER['REQUEST_METHOD'] === 'POST' && $url === '/mobil_API/InsertUserPoints'){
        try{
            $requestData = json_decode(file_get_contents('php://input'), true);
            $newpoints = $requestData['prmnewpoints_input'] ?? null;
            $user_id = $requestData['prmuser_id_input'] ?? null;
            $locate = $requestData['prmlocate_input'] ?? null;
            $code_name = $requestData['prmcode_name_input'] ?? null;

            if($newpoints != null && $user_id != null && $locate != null && $code_name != null){
                $stmt = $dbConn->prepare("CALL insert_scores(:prmnewpoints, :prmuser_id, :prmlocate,:prmcodename, @prmuserexist)");
                $stmt->bindParam(':prmnewpoints', $newpoints, PDO::PARAM_INT);
                $stmt->bindParam(':prmuser_id', $user_id, PDO::PARAM_INT);
                $stmt->bindParam(':prmlocate', $locate, PDO::PARAM_STR);
                $stmt->bindParam(':prmcodename',$code_name,PDO::PARAM_STR);
                $stmt->execute();

                // Capturar el valor de prmuserexist
                $stmt->closeCursor();
                $stmt = $dbConn->query("SELECT @prmuserexist AS prmuserexist");
                $result = $stmt->fetch(PDO::FETCH_ASSOC);
                $prmuserexist = $result['prmuserexist'];

                // Capturar el resultado del procedimiento almacenado
                $stmt = $dbConn->query("SELECT id, points, user_id, date, locale FROM scores WHERE id = LAST_INSERT_ID()");
                $result = $stmt->fetch(PDO::FETCH_ASSOC);
                if($result == false) $result = null;

                $response = new APIResponse(200, 'Success', [
                    'score' => $result,
                    'user_exist' => (bool)$prmuserexist
                ]);
                header('Content-Type: application/json');
                echo json_encode($response);
            }else {
                // Si falta algún parámetro en la solicitud, responder con un código de estado 400 y un mensaje de error
                http_response_code(400);
                $response = new APIResponse(400, 'Missing parameters', []);
                header('Content-Type: application/json');
                echo json_encode($response);
            }
        }catch(PDOException $e){
            // Si ocurre un error en la base de datos, responder con un código de estado 500 y un mensaje de error
            http_response_code(500);
            $response = new APIResponse(500, 'Database Error', [$e]);
            header('Content-Type: application/json');
            echo json_encode($response);
        }
    }

    if($_SERVER['REQUEST_METHOD'] === 'POST' && $url === '/mobil_API/InsertReferralsPoints'){
        try{
            $requestData = json_decode(file_get_contents('php://input'), true);
            $user_id = $requestData['prmuser_id_input'] ?? null;
            $referal_id = $requestData['prmreferal_id_input'] ?? null;
            $locate = $requestData['prmlocate_input'] ?? null;

            if($user_id != null && $locate != null && $referal_id != null){
                $stmt = $dbConn->prepare("CALL insert_referrals(:prmuser_id, :prmreferal_id, :prmlocate, @prmuserexist)");
                $stmt->bindParam(':prmuser_id', $user_id, PDO::PARAM_INT);
                $stmt->bindParam(':prmlocate', $locate, PDO::PARAM_STR);
                $stmt->bindParam(':prmreferal_id',$referal_id,PDO::PARAM_INT);
                $stmt->execute();

                // Capturar el valor de prmuserexist
                $stmt->closeCursor();
                $stmt = $dbConn->query("SELECT @prmuserexist AS prmuserexist");
                $result = $stmt->fetch(PDO::FETCH_ASSOC);
                $prmuserexist = $result['prmuserexist'];

                // Capturar el resultado del procedimiento almacenado
                $stmt = $dbConn->query("SELECT id, points, user_id, date, locale FROM referrals WHERE id = LAST_INSERT_ID()");
                $result = $stmt->fetch(PDO::FETCH_ASSOC);
                if($result == false) $result = null;

                $response = new APIResponse(200, 'Success', [
                    'score' => $result,
                    'user_exist' => (bool)$prmuserexist
                ]);
                header('Content-Type: application/json');
                echo json_encode($response);
            }else{
                // Si falta algún parámetro en la solicitud, responder con un código de estado 400 y un mensaje de error
                http_response_code(400);
                $response = new APIResponse(400, 'Missing parameters', []);
                header('Content-Type: application/json');
                echo json_encode($response);
            }
        }catch(PDOException $e){
            // Si ocurre un error en la base de datos, responder con un código de estado 500 y un mensaje de error
            http_response_code(500);
            $response = new APIResponse(500, 'Database Error', [$e]);
            header('Content-Type: application/json');
            echo json_encode($response);
        }
    }

    if($_SERVER['REQUEST_METHOD'] === 'GET' && $url === '/mobil_API/SelectUsers'){
        try{
            $stmt = $dbConn->prepare("CALL select_users()");
            $stmt->execute();
            $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

            // Interpretar el resultado
            $result = $result ?? null; // Si no hay resultado, se asume falso (0)
        
            // Codificar y retornar respuesta
            $response = new APIResponse(200, 'Success', ['data' => $result]);
            header('Content-Type: application/json');
            echo json_encode($response);
        }catch (PDOException $e){
            http_response_code(500);
            $response = new APIResponse(500, 'Internal Server Error', $e);
            header('Content-Type: application/json');
            echo json_encode($response);
        }
    }

    if ($_SERVER['REQUEST_METHOD'] === 'POST' && $url === '/mobil_API/SelectScoreReferrals') {
        try {
            $requestData = json_decode(file_get_contents('php://input'), true);
            $user_id = $requestData['prmuser_id_input'] ?? null;
    
            if ($user_id !== null) {
                $stmt = $dbConn->prepare("CALL select_scores_referrals(:prmUserId)");
                $stmt->bindParam(':prmUserId', $user_id, PDO::PARAM_INT);
                $stmt->execute();
                $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
                // Interpretar el resultado
                $result = $result ?: []; // Si no hay resultado, retorna un array vacío
    
                // Codificar y retornar respuesta
                $response = new APIResponse(200, 'Success', $result);
                header('Content-Type: application/json');
                echo json_encode($response);
            } else {
                http_response_code(400);
                $response = new APIResponse(400, 'Missing parameters', []);
                header('Content-Type: application/json');
                echo json_encode($response);
            }
        } catch (PDOException $e) {
            http_response_code(500);
            $response = new APIResponse(500, 'Internal Server Error', ['error' => $e->getMessage()]);
            header('Content-Type: application/json');
            echo json_encode($response);
        }
    }
?>