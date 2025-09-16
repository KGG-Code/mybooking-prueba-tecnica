-- MySQL dump 10.13  Distrib 5.7.23, for macos10.13 (x86_64)
--
-- Host: dbdev    Database: prueba_tecnica
-- ------------------------------------------------------
-- Server version	5.5.5-10.6.15-MariaDB-1:10.6.15+maria~ubu2004

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `categories` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `code` varchar(20) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES (1,'A','Scooter 125cc'),(2,'B','Turismo'),(3,'C','Furgoneta'),(4,'A1','Scooter 300cc');
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `category_rental_location_rate_types`
--

DROP TABLE IF EXISTS `category_rental_location_rate_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `category_rental_location_rate_types` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `category_id` bigint(20) DEFAULT NULL,
  `rental_location_id` bigint(20) DEFAULT NULL,
  `rate_type_id` bigint(20) DEFAULT NULL,
  `price_definition_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `category_rental_location_rate_types`
--

LOCK TABLES `category_rental_location_rate_types` WRITE;
/*!40000 ALTER TABLE `category_rental_location_rate_types` DISABLE KEYS */;
INSERT INTO `category_rental_location_rate_types` VALUES (1,1,1,1,1),(2,2,1,1,2),(3,3,1,1,3),(4,1,2,1,4),(5,2,2,1,5),(6,3,2,1,6);
/*!40000 ALTER TABLE `category_rental_location_rate_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `price_definitions`
--

DROP TABLE IF EXISTS `price_definitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `price_definitions` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  `rate_type_id` bigint(20) DEFAULT NULL,
  `season_definition_id` bigint(20) DEFAULT NULL,
  `excess` decimal(10,2) DEFAULT NULL,
  `deposit` decimal(10,2) DEFAULT NULL,
  `time_measurement_months` tinyint(4) DEFAULT NULL,
  `time_measurement_days` tinyint(4) DEFAULT NULL,
  `time_measurement_hours` tinyint(4) DEFAULT NULL,
  `time_measurement_minutes` tinyint(4) DEFAULT NULL,
  `units_management_days` int(11) DEFAULT NULL,
  `units_management_hours` int(11) DEFAULT NULL,
  `units_management_minutes` int(11) DEFAULT NULL,
  `units_management_value_months_list` varchar(255) DEFAULT NULL,
  `units_management_value_days_list` varchar(255) DEFAULT NULL,
  `units_management_value_hours_list` varchar(255) DEFAULT NULL,
  `units_management_value_minutes_list` varchar(255) DEFAULT NULL,
  `units_value_limit_hours_day` int(11) DEFAULT NULL,
  `units_value_limit_min_hours` int(11) DEFAULT NULL,
  `apply_price_by_kms` tinyint(4) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `price_definitions`
--

LOCK TABLES `price_definitions` WRITE;
/*!40000 ALTER TABLE `price_definitions` DISABLE KEYS */;
INSERT INTO `price_definitions` VALUES (1,'A - Barcelona - Estándar',1,1,1,1500.00,400.00,0,1,0,0,1,1,1,'1','1,2,4,15','1','1',5,60,NULL),(2,'B - Barcelona - Estándar',1,1,2,2100.00,500.00,0,1,0,0,1,1,1,'1','1,2,4,8,15,30','1','1',5,60,NULL),(3,'C - Barcelona - Estándar',2,1,NULL,2400.00,550.00,0,1,0,0,1,1,1,'1','1','1','1',5,60,NULL),(4,'A - Menorca - Estándar',1,1,1,1500.00,400.00,0,1,0,0,1,1,1,'1','1,2,4,15','1','1',5,60,NULL),(5,'B - Menorca - Estándar',1,1,2,2100.00,500.00,0,1,0,0,1,1,1,'1','1,2,4,8,15,30','1','1',5,60,NULL),(6,'C - Menorca - Estándar',2,1,NULL,2400.00,550.00,0,1,0,0,1,1,1,'1','1','1','1',5,60,NULL),(7,'A1 - Barcelona - Estándar',1,1,1,1500.00,400.00,0,1,0,0,1,1,1,'1','1,2,4,8,15,30','1','1',5,60,NULL);
/*!40000 ALTER TABLE `price_definitions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prices`
--

DROP TABLE IF EXISTS `prices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `prices` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `price_definition_id` bigint(20) DEFAULT NULL,
  `season_id` bigint(20) DEFAULT NULL,
  `time_measurement` int(11) DEFAULT NULL,
  `units` int(11) DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `included_km` int(11) DEFAULT NULL,
  `extra_km_price` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=69 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prices`
--

LOCK TABLES `prices` WRITE;
/*!40000 ALTER TABLE `prices` DISABLE KEYS */;
INSERT INTO `prices` VALUES (1,1,1,2,1,60.00,0,0.00),(2,1,1,2,2,55.00,0,0.00),(3,1,1,2,4,45.00,0,0.00),(4,1,1,2,15,40.00,0,0.00),(5,1,2,2,1,50.00,0,0.00),(6,1,2,2,2,40.00,0,0.00),(7,1,2,2,4,35.00,0,0.00),(8,1,2,2,15,30.00,0,0.00),(9,1,3,2,1,40.00,0,0.00),(10,1,3,2,2,35.00,0,0.00),(11,1,3,2,4,30.00,0,0.00),(12,1,3,2,15,25.00,0,0.00),(13,2,4,2,1,90.00,0,0.00),(14,2,4,2,2,80.00,0,0.00),(15,2,4,2,4,75.00,0,0.00),(16,2,4,2,8,70.00,0,0.00),(17,2,4,2,15,60.00,0,0.00),(18,2,4,2,30,50.00,0,0.00),(19,2,5,2,1,70.00,0,0.00),(20,2,5,2,2,65.00,0,0.00),(21,2,5,2,4,60.00,0,0.00),(22,2,5,2,8,50.00,0,0.00),(23,2,5,2,15,45.00,0,0.00),(24,2,5,2,30,40.00,0,0.00),(25,3,NULL,2,1,110.00,0,0.00),(26,4,1,2,1,70.00,0,0.00),(27,4,1,2,2,65.00,0,0.00),(28,4,1,2,4,55.00,0,0.00),(29,4,1,2,15,50.00,0,0.00),(30,4,2,2,1,60.00,0,0.00),(31,4,2,2,2,50.00,0,0.00),(32,4,2,2,4,45.00,0,0.00),(33,4,2,2,15,40.00,0,0.00),(34,4,3,2,1,50.00,0,0.00),(35,4,3,2,2,45.00,0,0.00),(36,4,3,2,4,40.00,0,0.00),(37,4,3,2,15,35.00,0,0.00),(38,5,4,2,1,100.00,0,0.00),(39,5,4,2,2,90.00,0,0.00),(40,5,4,2,4,85.00,0,0.00),(41,5,4,2,8,80.00,0,0.00),(42,5,4,2,15,70.00,0,0.00),(43,5,4,2,30,60.00,0,0.00),(44,5,5,2,1,80.00,0,0.00),(45,5,5,2,2,75.00,0,0.00),(46,5,5,2,4,70.00,0,0.00),(47,5,5,2,8,60.00,0,0.00),(48,5,5,2,15,55.00,0,0.00),(49,5,5,2,30,50.00,0,0.00),(50,6,NULL,2,1,120.00,0,0.00),(51,7,1,2,1,50.00,0,0.00),(52,7,1,2,2,45.00,0,0.00),(53,7,1,2,4,40.00,0,0.00),(54,7,1,2,8,35.00,0,0.00),(55,7,1,2,15,30.00,0,0.00),(56,7,1,2,30,25.00,0,0.00),(57,7,2,2,1,40.00,0,0.00),(58,7,2,2,2,35.00,0,0.00),(59,7,2,2,4,30.00,0,0.00),(60,7,2,2,8,25.00,0,0.00),(61,7,2,2,15,20.00,0,0.00),(62,7,2,2,30,15.00,0,0.00),(63,7,3,2,1,35.00,0,0.00),(64,7,3,2,2,30.00,0,0.00),(65,7,3,2,4,25.00,0,0.00),(66,7,3,2,8,20.00,0,0.00),(67,7,3,2,15,15.00,0,0.00),(68,7,3,2,30,10.00,0,0.00);
/*!40000 ALTER TABLE `prices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rate_types`
--

DROP TABLE IF EXISTS `rate_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rate_types` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rate_types`
--

LOCK TABLES `rate_types` WRITE;
/*!40000 ALTER TABLE `rate_types` DISABLE KEYS */;
INSERT INTO `rate_types` VALUES (1,'Estándar'),(2,'Premium');
/*!40000 ALTER TABLE `rate_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rental_locations`
--

DROP TABLE IF EXISTS `rental_locations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rental_locations` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rental_locations`
--

LOCK TABLES `rental_locations` WRITE;
/*!40000 ALTER TABLE `rental_locations` DISABLE KEYS */;
INSERT INTO `rental_locations` VALUES (1,'Barcelona'),(2,'Menorca');
/*!40000 ALTER TABLE `rental_locations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `season_definition_rental_locations`
--

DROP TABLE IF EXISTS `season_definition_rental_locations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `season_definition_rental_locations` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `season_definition_id` bigint(20) DEFAULT NULL,
  `rental_location_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `season_definition_rental_locations`
--

LOCK TABLES `season_definition_rental_locations` WRITE;
/*!40000 ALTER TABLE `season_definition_rental_locations` DISABLE KEYS */;
INSERT INTO `season_definition_rental_locations` VALUES (1,1,1),(2,1,2),(3,2,1),(4,2,2);
/*!40000 ALTER TABLE `season_definition_rental_locations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `season_definitions`
--

DROP TABLE IF EXISTS `season_definitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `season_definitions` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `season_definitions`
--

LOCK TABLES `season_definitions` WRITE;
/*!40000 ALTER TABLE `season_definitions` DISABLE KEYS */;
INSERT INTO `season_definitions` VALUES (1,'Temporadas scooters'),(2,'Temporadas turismos');
/*!40000 ALTER TABLE `season_definitions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `season_periods`
--

DROP TABLE IF EXISTS `season_periods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `season_periods` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `season_id` bigint(20) NOT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `season_periods`
--

LOCK TABLES `season_periods` WRITE;
/*!40000 ALTER TABLE `season_periods` DISABLE KEYS */;
/*!40000 ALTER TABLE `season_periods` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seasons`
--

DROP TABLE IF EXISTS `seasons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `seasons` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `season_definition_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seasons`
--

LOCK TABLES `seasons` WRITE;
/*!40000 ALTER TABLE `seasons` DISABLE KEYS */;
INSERT INTO `seasons` VALUES (1,'Alta',1),(2,'Media',1),(3,'Baja',1),(4,'Alta',2),(5,'Media-Baja',2);
/*!40000 ALTER TABLE `seasons` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'prueba_tecnica'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-08-22 23:00:10
