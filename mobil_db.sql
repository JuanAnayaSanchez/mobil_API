-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 25-04-2024 a las 04:41:59
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `mobil_db`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `check_code_exist` (IN `prmname` VARCHAR(50), OUT `prmexists` INT)   BEGIN
    DECLARE code_count INT;

    SELECT COUNT(*) INTO code_count FROM codes WHERE name = prmname;

    IF code_count > 0 THEN
        SET prmexists = 1;
    ELSE
        SET prmexists = 0;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `check_user_exist` (IN `identification_number_input` INT)   BEGIN
  
  SELECT id, name, mail, phone, city, identification_number, date
  FROM users
  WHERE identification_number = identification_number_input;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `create_user` (IN `prmname` VARCHAR(100), IN `prmmail` VARCHAR(100), IN `prmphone` INT, IN `prmcity` VARCHAR(50), IN `prmidentification_number` INT, OUT `prmmail_exist` TINYINT, OUT `prmidentification_number_exist` TINYINT, OUT `prmuser_id` INT)   BEGIN
    -- Inicializar las variables de salida
    SET prmmail_exist = 0;
    SET prmidentification_number_exist = 0;
    
    -- Verificar si el correo electrónico ya existe en la tabla
    SELECT COUNT(*) INTO prmmail_exist FROM users WHERE mail = prmmail;
    
    -- Verificar si el número de identificación ya existe en la tabla
    SELECT COUNT(*) INTO prmidentification_number_exist FROM users WHERE identification_number = prmidentification_number;
    
    -- Si el correo existe o el número de identificación existe, establecer ambas variables de salida en 1
    IF prmmail_exist > 0 OR prmidentification_number_exist > 0 THEN
        IF prmmail_exist > 0 THEN
            SET prmmail_exist = 1;
        END IF;
        
        IF prmidentification_number_exist > 0 THEN
            SET prmidentification_number_exist = 1;
        END IF;
    ELSE
        -- Insertar el nuevo usuario en la tabla users
        INSERT INTO users (name, mail, phone, city, identification_number, date) 
        VALUES (prmname, prmmail, prmphone, prmcity, prmidentification_number, CURDATE());
        
        -- Obtener el ID del usuario recién insertado
        SET prmuser_id = LAST_INSERT_ID();
    END IF;
    
    -- Devolver los datos del usuario insertado
    IF prmuser_id IS NOT NULL THEN
        SELECT * FROM users WHERE id = prmuser_id;
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `codes`
--

CREATE TABLE `codes` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `used` tinyint(1) DEFAULT 0,
  `date` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `codes`
--

INSERT INTO `codes` (`id`, `user_id`, `name`, `used`, `date`) VALUES
(1, NULL, 'ABC123', 0, '2024-04-24 21:04:16');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `mail` varchar(100) NOT NULL,
  `phone` int(11) DEFAULT NULL,
  `city` varchar(50) NOT NULL,
  `identification_number` int(11) NOT NULL,
  `date` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `users`
--

INSERT INTO `users` (`id`, `name`, `mail`, `phone`, `city`, `identification_number`, `date`) VALUES
(1, 'JUAN PABLO', 'JUAN@MAIL.COM', 2147483647, 'BOGOTA', 1000179085, '2024-04-21 14:59:39'),
(2, 'Nombre del usuario', 'correo@example.com', 123456789, 'Ciudad', 123456789, '2024-04-23 00:00:00');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `codes`
--
ALTER TABLE `codes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indices de la tabla `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `codes`
--
ALTER TABLE `codes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `codes`
--
ALTER TABLE `codes`
  ADD CONSTRAINT `codes_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
