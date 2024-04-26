-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 26-04-2024 a las 05:59:03
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
CREATE  PROCEDURE `check_code_exist` (IN `prmname` VARCHAR(50), OUT `prmexists` INT)   BEGIN
    DECLARE code_count INT;

    SELECT COUNT(*) INTO code_count FROM codes WHERE name = prmname;

    IF code_count > 0 THEN
        SET prmexists = 1;
    ELSE
        SET prmexists = 0;
    END IF;
END$$

CREATE  PROCEDURE `check_user_exist` (IN `prmphone` INT)   BEGIN
  
  SELECT id, name, mail, phone, city, identification_number, date
  FROM users
  WHERE phone = prmphone;
END$$

CREATE  PROCEDURE `insert_user` (IN `prmname` VARCHAR(50), IN `prmmail` VARCHAR(100), IN `prmcity` VARCHAR(50), IN `prmphone` INT, IN `prmidentification_number` INT, OUT `phone_exist` TINYINT, OUT `new_user_id` INT)   BEGIN
    -- Verificar si el número de teléfono ya existe en la tabla usuarios
    SELECT COUNT(*) INTO phone_exist FROM users WHERE phone = prmphone;
    
    -- Si el número de teléfono ya existe, no insertar y devolver valor indicando que ya existe
    IF phone_exist > 0 THEN
		SET phone_exist = 1;
        SET new_user_id = 0; -- Establecer un valor negativo para indicar que no se insertó ningún nuevo usuario
    ELSE
        -- Insertar el nuevo usuario en la tabla usuarios
        INSERT INTO users (name, mail, city, phone, identification_number, date) 
        VALUES (prmname, prmmail, prmcity, prmphone, prmidentification_number, NOW());
        
        -- Obtener el ID del usuario insertado
        SET new_user_id = LAST_INSERT_ID();
        SELECT id, name, mail, city, phone, identification_number, date FROM users WHERE id = new_user_id;
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
(7, 'CAMILO', 'CAMILO@example.com', 1234567589, 'MEDELLIN', 1234568, '2024-04-25 22:07:18'),
(8, 'Juan', 'juan@example.com', 2414141, 'Ciudad', 123456, '2024-04-25 22:23:49'),
(9, 'STEVEN', 'STEVEN@example.com', 24141415, 'CALI', 12345688, '2024-04-25 22:42:49'),
(10, 'STEVEN', 'STEVEN@example.com', 2147483647, 'CALI', 12345688, '2024-04-25 22:57:38');

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

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
