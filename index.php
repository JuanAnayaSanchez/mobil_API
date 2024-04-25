<?php

    include 'dbContext.php';
    include 'models.php';

    $url = $_SERVER['REQUEST_URI'];
    

    $dbConn = dbConect();

    if ($_SERVER['REQUEST_METHOD'] === 'GET' && $url === '/mobil_API/ValidateUserExist') {
    
        try{
            $requestData = json_decode(file_get_contents('php://input'), true);
            $identification_number_input = $requestData['identification_number_input'] ?? null;
            if ($identification_number_input !== null) {
                // Ejecutar procedimiento almacenado
                $stmt = $dbConn->prepare("CALL check_user_exist(:identification_number_input)");
                $stmt->bindParam(':identification_number_input', $identification_number_input, PDO::PARAM_INT);
                $stmt->execute();
    
                // Recoger registros como un arreglo asociativo
                $registros = $stmt->fetch(PDO::FETCH_ASSOC);
    
                // Codificar y retornar respuesta
                $response = new APIResponse(200,'Success',$registros);

                header('Content-Type: application/json');
                echo json_encode($response);
            } else {
                http_response_code(400);
                $response = new APIResponse(400,'Missing parameter identification_number_input parameter',[]);
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

    if($_SERVER['REQUEST_METHOD'] === 'GET' && $url === '/mobil_API/ValidateCodeExist'){
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
            $response = new APIResponse(500, 'Internal Server Error', []);
            header('Content-Type: application/json');
            echo json_encode($response);
        }
    }
?>