-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema miter_bbdd
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema miter_bbdd
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `miter_bbdd` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
USE `miter_bbdd` ;

-- -----------------------------------------------------
-- Table `miter_bbdd`.`comunidad_autonoma`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `miter_bbdd`.`comunidad_autonoma` (
  `comunidad_id` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`comunidad_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `miter_bbdd`.`empresa`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `miter_bbdd`.`empresa` (
  `empresa_id` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(150) NOT NULL,
  `cif` VARCHAR(20) NULL DEFAULT NULL,
  `web` VARCHAR(150) NULL DEFAULT NULL,
  PRIMARY KEY (`empresa_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `miter_bbdd`.`provincia`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `miter_bbdd`.`provincia` (
  `provincia_id` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(100) NOT NULL,
  `comunidad_id` INT NOT NULL,
  PRIMARY KEY (`provincia_id`),
  INDEX `comunidad_id` (`comunidad_id` ASC) VISIBLE,
  CONSTRAINT `provincia_ibfk_1`
    FOREIGN KEY (`comunidad_id`)
    REFERENCES `miter_bbdd`.`comunidad_autonoma` (`comunidad_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `miter_bbdd`.`municipio`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `miter_bbdd`.`municipio` (
  `municipio_id` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(100) NOT NULL,
  `provincia_id` INT NOT NULL,
  PRIMARY KEY (`municipio_id`),
  INDEX `provincia_id` (`provincia_id` ASC) VISIBLE,
  CONSTRAINT `municipio_ibfk_1`
    FOREIGN KEY (`provincia_id`)
    REFERENCES `miter_bbdd`.`provincia` (`provincia_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `miter_bbdd`.`localidad`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `miter_bbdd`.`localidad` (
  `localidad_id` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(100) NOT NULL,
  `municipio_id` INT NOT NULL,
  PRIMARY KEY (`localidad_id`),
  INDEX `municipio_id` (`municipio_id` ASC) VISIBLE,
  CONSTRAINT `localidad_ibfk_1`
    FOREIGN KEY (`municipio_id`)
    REFERENCES `miter_bbdd`.`municipio` (`municipio_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `miter_bbdd`.`estacion_servicio`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `miter_bbdd`.`estacion_servicio` (
  `estacion_id` INT NOT NULL AUTO_INCREMENT,
  `empresa_id` INT NOT NULL,
  `localidad_id` INT NOT NULL,
  `cod_postal` VARCHAR(10) NULL DEFAULT NULL,
  `direccion` VARCHAR(255) NOT NULL,
  `margen` VARCHAR(5) NULL DEFAULT NULL,
  `latitud` DECIMAL(10,6) NULL DEFAULT NULL,
  `longitud` DECIMAL(10,6) NULL DEFAULT NULL,
  `tipo_estacion` ENUM('TERRESTRE', 'MARITIMA') NOT NULL,
  `horario` VARCHAR(150) NULL DEFAULT NULL,
  `fecha_ultima_actualizacion` DATE NULL DEFAULT NULL,
  PRIMARY KEY (`estacion_id`),
  INDEX `empresa_id` (`empresa_id` ASC) VISIBLE,
  INDEX `localidad_id` (`localidad_id` ASC) VISIBLE,
  CONSTRAINT `estacion_servicio_ibfk_1`
    FOREIGN KEY (`empresa_id`)
    REFERENCES `miter_bbdd`.`empresa` (`empresa_id`),
  CONSTRAINT `estacion_servicio_ibfk_2`
    FOREIGN KEY (`localidad_id`)
    REFERENCES `miter_bbdd`.`localidad` (`localidad_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `miter_bbdd`.`tipo_carburante`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `miter_bbdd`.`tipo_carburante` (
  `carburante_id` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(50) NOT NULL,
  `unidad` VARCHAR(20) NULL DEFAULT '€/litro',
  PRIMARY KEY (`carburante_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `miter_bbdd`.`precio_carburante`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `miter_bbdd`.`precio_carburante` (
  `estacion_id` INT NOT NULL,
  `carburante_id` INT NOT NULL,
  `fecha_actualizacion` DATE NOT NULL,
  `precio` DECIMAL(5,3) NOT NULL,
  PRIMARY KEY (`estacion_id`, `carburante_id`, `fecha_actualizacion`),
  INDEX `carburante_id` (`carburante_id` ASC) VISIBLE,
  CONSTRAINT `precio_carburante_ibfk_1`
    FOREIGN KEY (`estacion_id`)
    REFERENCES `miter_bbdd`.`estacion_servicio` (`estacion_id`),
  CONSTRAINT `precio_carburante_ibfk_2`
    FOREIGN KEY (`carburante_id`)
    REFERENCES `miter_bbdd`.`tipo_carburante` (`carburante_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
