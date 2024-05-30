-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: May 30, 2024 at 05:09 AM
-- Server version: 10.11.7-MariaDB-cll-lve
-- PHP Version: 7.2.34

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `u326127156_terpel`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`u326127156_terpel`@`127.0.0.1` PROCEDURE `check_code_exist` (IN `prmname` VARCHAR(50), OUT `prmexists` INT)  BEGIN
    DECLARE code_count INT;

SELECT COUNT(*) INTO code_count FROM codes WHERE used = 0 AND name COLLATE utf8mb4_general_ci = prmname COLLATE utf8mb4_general_ci;

    IF code_count > 0 THEN
        SET prmexists = 1;
    ELSE
        SET prmexists = 0;
    END IF;
END$$

CREATE DEFINER=`u326127156_terpel`@`127.0.0.1` PROCEDURE `check_user_exist` (IN `prmphone` VARCHAR(15))  BEGIN
    SELECT id, name, mail, phone, city, identification_number, date
    FROM users
    WHERE phone = prmphone;
END$$

CREATE DEFINER=`u326127156_terpel`@`127.0.0.1` PROCEDURE `insert_referrals` (IN `prmuser_id` INT, IN `prmreferal_id` INT, IN `prmlocate` VARCHAR(50), OUT `prmuserexist` TINYINT)  BEGIN
	DECLARE user_count INT;
    DECLARE referal_count INT;
	-- VALIDAR SI EL USUARIO EXISTE
	SELECT COUNT(*) INTO user_count FROM users WHERE id = prmuser_id;
	-- VALIDAR SI EL REFERIDO EXISTE
	SELECT COUNT(*) INTO referal_count FROM users WHERE id = prmreferal_id;

	IF user_count > 0 AND referal_count > 0 THEN
	-- INSERTAR REFERIDO
	INSERT INTO referrals (points,user_id,date,locale,user_id_referral) VALUES (10,prmuser_id,NOW(),prmlocate,prmreferal_id);
	SET prmuserexist = 1;
    ELSE
    SET prmuserexist = 0;
    END IF;
END$$

CREATE DEFINER=`u326127156_terpel`@`127.0.0.1` PROCEDURE `insert_scores` (IN `prmnewpoints` INT, IN `prmuser_id` INT, IN `prmlocate` VARCHAR(50), IN `prmcodename` VARCHAR(50), OUT `prmuserexist` TINYINT)  BEGIN
    DECLARE user_count INT;
    DECLARE code_count INT;
    
    -- VALIDAR SI EL USUARIO EXISTE
    SELECT COUNT(*) INTO user_count FROM users WHERE id = prmuser_id;
    
    -- VALIDAR SI EL CODIGO EXISTE
    SELECT COUNT(*) INTO code_count FROM codes WHERE name = prmcodename AND used = 0;
    
    IF user_count > 0 AND code_count > 0 THEN
        -- INSERTAR PUNTAJE
        INSERT INTO scores (points, user_id, date, locale) VALUES (prmnewpoints, prmuser_id, NOW(), prmlocate);
        UPDATE codes SET used = 1, date = NOW(), user_id = prmuser_id WHERE name = prmcodename;
        SET prmuserexist = 1;
        SELECT points, user_id, date, locale FROM scores WHERE id = LAST_INSERT_ID();
    ELSE
        SET prmuserexist = 0;
    END IF;
END$$

CREATE DEFINER=`u326127156_terpel`@`127.0.0.1` PROCEDURE `insert_user` (IN `prmname` VARCHAR(255), IN `prmmail` VARCHAR(255), IN `prmcity` VARCHAR(255), IN `prmphone` VARCHAR(50), IN `prmidentification_number` INT, OUT `phone_exist` INT, OUT `new_user_id` INT)  BEGIN
    DECLARE user_count INT;

    -- Comprobar si el número de teléfono ya existe en la tabla de usuarios
    SELECT COUNT(*) INTO user_count FROM users WHERE phone = prmphone;

    IF user_count > 0 THEN
        -- El número de teléfono ya existe
        SET phone_exist = 1;
        SET new_user_id = NULL;
    ELSE
        -- Insertar nuevo usuario
        INSERT INTO users (name, mail, city, phone, identification_number, date)
        VALUES (prmname, prmmail, prmcity, prmphone, prmidentification_number, NOW());

        -- Obtener el ID del nuevo usuario insertado
        SET new_user_id = LAST_INSERT_ID();
        SET phone_exist = 0;
        
    END IF;
END$$

CREATE DEFINER=`u326127156_terpel`@`127.0.0.1` PROCEDURE `select_scores_referrals` (IN `prmUserId` INT)  BEGIN
    SELECT users.name, scores.user_id, scores.points, scores.date 
    FROM scores 
    INNER JOIN users ON scores.user_id = users.id
    WHERE scores.user_id = prmUserId
    
    UNION ALL
    
    SELECT users.name, referrals.user_id_referral AS user_id, referrals.points, referrals.date 
    FROM referrals 
    INNER JOIN users ON referrals.user_id_referral = users.id
    WHERE referrals.user_id_referral = prmUserId;
END$$

CREATE DEFINER=`u326127156_terpel`@`127.0.0.1` PROCEDURE `select_users` ()  BEGIN
    SELECT u.id, u.name, u.mail, u.phone, u.city, u.identification_number, u.date,
           (COALESCE(scores_sum.total_scores, 0) + COALESCE(referrals_sum.total_referrals, 0)) AS total_points
    FROM users u
    LEFT JOIN (
        SELECT s.user_id, SUM(s.points) AS total_scores
        FROM scores s
        GROUP BY s.user_id
    ) scores_sum ON u.id = scores_sum.user_id
    LEFT JOIN (
        SELECT r.user_id, SUM(r.points) AS total_referrals
        FROM referrals r
        GROUP BY r.user_id
    ) referrals_sum ON u.id = referrals_sum.user_id;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `codes`
--

CREATE TABLE `codes` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `used` tinyint(1) DEFAULT 0,
  `date` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `codes`
--

INSERT INTO `codes` (`id`, `user_id`, `name`, `used`, `date`) VALUES
(1, 85, 'ABC123', 1, '2024-05-24 16:39:41');

-- --------------------------------------------------------

--
-- Table structure for table `referrals`
--

CREATE TABLE `referrals` (
  `id` int(11) NOT NULL,
  `points` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `date` date DEFAULT NULL,
  `locale` varchar(50) DEFAULT NULL,
  `user_id_referral` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `referrals`
--

INSERT INTO `referrals` (`id`, `points`, `user_id`, `date`, `locale`, `user_id_referral`) VALUES
(6, 10, 31, '2024-05-23', 'BOGOTA', 37),
(7, 10, 31, '2024-05-23', 'BOGOTA', 37),
(8, 10, 31, '2024-05-23', 'BOGOTA', 37);

-- --------------------------------------------------------

--
-- Table structure for table `scores`
--

CREATE TABLE `scores` (
  `id` int(11) NOT NULL,
  `points` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `date` date DEFAULT NULL,
  `locale` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `scores`
--

INSERT INTO `scores` (`id`, `points`, `user_id`, `date`, `locale`) VALUES
(1, 0, 69, '2024-05-08', NULL),
(2, 2, 31, '2024-05-11', 'BOGOTA'),
(3, 1000, 37, '2024-05-11', 'BOGOTA'),
(4, 5, 31, '2024-05-11', 'BOGOTA'),
(5, 5, 31, '2024-05-11', 'BOGOTA'),
(6, 5, 31, '2024-05-11', 'BOGOTA'),
(7, 5, 31, '2024-05-11', 'BOGOTA'),
(8, 5, 31, '2024-05-11', 'BOGOTA'),
(9, 5, 31, '2024-05-12', 'BOGOTA'),
(10, 5, 31, '2024-05-12', 'BOGOTA'),
(11, 2500, 35, '2024-05-16', 'Verbenal'),
(12, 2500, 35, '2024-05-16', 'Bosa Porvenir'),
(13, 2500, 39, '2024-05-16', 'Bosa Porvenir'),
(14, 2500, 68, '2024-05-17', 'Bosa Porvenir'),
(15, 5, 31, '2024-05-20', 'BOGOTA'),
(16, 5, 31, '2024-05-20', 'BOGOTA'),
(17, 5, 31, '2024-05-20', 'BOGOTA'),
(18, 5, 31, '2024-05-20', 'BOGOTA'),
(19, 2500, 34, '2024-05-21', 'Bosa Porvenir'),
(20, 2500, 77, '2024-05-21', 'Bosa Porvenir'),
(21, 2500, 35, '2024-05-21', 'Bosa Porvenir'),
(22, 2500, 78, '2024-05-21', 'Bosa Porvenir'),
(23, 400, 79, '2024-05-22', 'Bosa Porvenir'),
(24, 400, 80, '2024-05-22', 'Bosa Porvenir'),
(25, 300, 81, '2024-05-22', 'Bosa Porvenir'),
(26, 400, 82, '2024-05-22', 'Bosa Porvenir'),
(27, 300, 83, '2024-05-22', 'Bosa Porvenir'),
(28, 200, 84, '2024-05-22', 'Bosa Porvenir'),
(29, 400, 85, '2024-05-22', 'Bosa Porvenir'),
(30, 400, 85, '2024-05-22', 'Bosa Porvenir'),
(31, 300, 85, '2024-05-22', 'Bosa Porvenir'),
(32, 5, 31, '2024-05-24', 'BOGOTA'),
(33, 500, 39, '2024-05-24', 'Bosa Porvenir'),
(34, 300, 85, '2024-05-24', 'Bosa Porvenir');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `mail` varchar(100) NOT NULL,
  `phone` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `city` varchar(50) NOT NULL,
  `identification_number` bigint(15) NOT NULL,
  `date` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `mail`, `phone`, `city`, `identification_number`, `date`) VALUES
(31, 'TEST2', 'TEST2@example.com', '541251', 'MEDELLIN', 54545, '2024-05-03 20:03:40'),
(32, 'Kamilo', 'kas@hotmail.com', '2147483647', 'bogota', 21321321, '2024-05-03 20:42:03'),
(33, 'Pedro', 'kamilo.arias1206@gmail.com', '2147483647', 'bogota', 2147483647, '2024-05-03 20:45:31'),
(34, 'Pedro', 'kamilo.arias1206@gmail.com', '0', 'bogota', 2147483647, '2024-05-03 20:45:50'),
(35, 'Steve ', 'kamklo', '123', 'vali', 1015431752, '2024-05-03 20:48:05'),
(36, 'Pepe Perez Loco', 'pepe@lo.com', '2147483647', 'ba', 1015431753, '2024-05-03 23:10:59'),
(37, 'Kamilo', 'kas12@hotmail.com', '2147483647', 'bogota', 123456, '2024-05-03 23:29:19'),
(38, 'Kamilo', 'as@12.com', '2147483647', 'bogota', 122050, '2024-05-03 23:31:19'),
(39, 'Prueba', '1234@hotmail.com', '1234', 'bogota', 1234, '2024-05-03 23:37:32'),
(40, 'Pedrolara', 'kas@hotmail.com', '3132123', 'bogota', 123456, '2024-05-03 23:48:05'),
(41, 'Maria', 'kas@locoso.com', '2147483647', 'bogotas', 1040, '2024-05-03 23:53:30'),
(42, 'Kas', 'kaslo@', '1520', 'bogota', 987654, '2024-05-03 23:55:18'),
(43, 'Kamilo', '1223@hotymailc.om', '121221', 'bogota', 321312, '2024-05-04 00:03:40'),
(44, 'Kamilo', 'kas@hotmail.com', '2147483647', 'bogota', 1015431753, '2024-05-04 00:14:07'),
(45, 'Prueba', '232133@hotmail.com', '3213213', 'bogota', 213213, '2024-05-04 00:16:32'),
(46, 'Kams', '123213', '123123', '21312312', 232131, '2024-05-04 00:20:16'),
(47, 'Kas', '123213', '12321321', '213213', 23213, '2024-05-04 00:27:31'),
(48, 'Asdasdsa', 'asdasd', '321313', 'adasd', 0, '2024-05-04 00:30:52'),
(49, 'Asdasd', 'asdasdas', '213123213', 'asdasda', 0, '2024-05-04 00:36:35'),
(50, 'Adasd', 'sadadas', '213213', 'dasdas', 0, '2024-05-04 00:37:41'),
(51, 'Asdasd', 'sdasds', '2321321', 'asdsa', 0, '2024-05-04 00:37:59'),
(52, 'Loco', '213123@hotmail.com', '212112', 'bogota', 123123, '2024-05-06 13:34:42'),
(53, 'Kamilo', '213@hotmail.com', '2147483647', 'bogota', 213123, '2024-05-06 13:40:45'),
(54, 'Kamilo', '12312321', '2147483647', '12312321', 123123123, '2024-05-06 13:42:01'),
(55, 'Asdasds', '123123', '2147483647', '1231232', 23213123, '2024-05-06 13:42:23'),
(56, 'Adsadasdas', '1231232112', '2147483647', '12312312', 213122231, '2024-05-06 13:42:46'),
(57, 'Error', '21321', '2147483647', '123213213', 1, '2024-05-06 13:43:09'),
(58, 'Qqwewqe', 'qwqwew', '2147483647', 'qweqwew', 0, '2024-05-06 13:46:13'),
(59, 'Qweqweqw', 'qweqweqw', '2147483647', 'qweqweqw', 0, '2024-05-06 13:46:49'),
(60, 'Error', 'kasman@hotmail.com', '2147483647', 'bogota', 1015431754, '2024-05-06 13:49:45'),
(61, 'Juanganta', 'pruebaderror@hotmail.com', '2147483647', 'bogota', 2024, '2024-05-06 13:52:23'),
(62, 'Qeqwewqe', '12321321', '2147483647', '21321321', 13123213, '2024-05-06 14:01:42'),
(63, 'Adadasd', '123123', '123211321', '123123213', 21312321, '2024-05-06 14:03:23'),
(64, 'TEST2', 'TEST2@example.com', '2147483647', 'MEDELLIN', 54545, '2024-05-06 14:03:43'),
(65, 'TEST2', 'TEST2@example.com', '3', 'MEDELLIN', 54545, '2024-05-06 14:10:55'),
(66, 'TEST2', 'TEST2@example.com', '3134418952', 'MEDELLIN', 54545, '2024-05-06 14:17:48'),
(67, 'Juanganta', 'ratonero', '3213121678', 'deverdad', 0, '2024-05-06 14:18:42'),
(68, 'Kas', '123123@hotmail.com', '3213121674', 'bogota', 123123, '2024-05-06 14:34:42'),
(69, 'TEST3', 'TEST3@example.com', '3134418752', 'MEDELLIN', 54545, '2024-05-08 01:50:18'),
(70, 'Pedro Perezx', 'kasmaland@hotmail.com', '3213121688', 'bogota', 1015431759, '2024-05-21 14:49:47'),
(71, 'Kamilo', '12@ho.com', '32131216798', 'bogota', 1015431752, '2024-05-21 15:05:25'),
(72, 'Aasdsa', '123123', '21323', '12321321', 1232132, '2024-05-21 15:06:11'),
(73, 'Kas', '213@hotmail.com', '3213121680', 'bogota', 123, '2024-05-21 15:13:03'),
(74, 'Kamilo', 'lol@g.com', '8080', 'usaquen', 8081, '2024-05-21 15:20:10'),
(75, 'Asdas', '123213', '8081', '123123', 12321, '2024-05-21 15:21:57'),
(76, 'Pedro', '21@hotmail.com', '8082', 'bogota', 123213, '2024-05-21 15:24:48'),
(77, 'Asdas', '123213', '131232', 'dsad', 0, '2024-05-21 15:34:02'),
(78, 'Kamilo', 'kas@hotmail.com', '8089', 'bogota', 2147483647, '2024-05-21 15:54:56'),
(79, 'Test De Puntaje', 'kamilo.arias@gmail.com', '3124936501', 'bogota', 1015431752, '2024-05-22 22:23:04'),
(80, 'Juanganta Anaya', 'sponja@hotmail.com', '3131544885', 'bosa', 2147483647, '2024-05-22 22:26:21'),
(81, 'Kamilo', 'kas@.com', '32131216789', 'bogota', 1234567890, '2024-05-22 22:34:04'),
(82, 'Prueba', 'kas@hotmail.com', '23132123121212', 'bogota', 1234567890, '2024-05-22 22:36:46'),
(83, 'Asdas', 'kas@hotmail.com', '123456789012345', 'bogota', 2147483647, '2024-05-22 22:39:26'),
(84, 'Kamilo', 'kas@hotmail.com', '32131216748590', 'bogota', 2147483647, '2024-05-22 22:47:35'),
(85, 'Camilo', 'kas@hotmail.com', '3213121673', 'bogota', 2222, '2024-05-22 23:09:51');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `codes`
--
ALTER TABLE `codes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `referrals`
--
ALTER TABLE `referrals`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `fk_user_id_referrals` (`user_id_referral`);

--
-- Indexes for table `scores`
--
ALTER TABLE `scores`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `codes`
--
ALTER TABLE `codes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `referrals`
--
ALTER TABLE `referrals`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `scores`
--
ALTER TABLE `scores`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=86;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `codes`
--
ALTER TABLE `codes`
  ADD CONSTRAINT `codes_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `referrals`
--
ALTER TABLE `referrals`
  ADD CONSTRAINT `fk_user_id_referrals` FOREIGN KEY (`user_id_referral`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `referrals_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `scores`
--
ALTER TABLE `scores`
  ADD CONSTRAINT `scores_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
