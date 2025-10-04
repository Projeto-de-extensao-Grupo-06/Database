DROP DATABASE IF EXISTS db_solarize;
CREATE DATABASE IF NOT EXISTS db_solarize;
USE db_solarize;

#--- ADDRESS ---
CREATE TABLE IF NOT EXISTS address (
    id_address INT AUTO_INCREMENT PRIMARY KEY,
    postal_code CHAR(8) NOT NULL,
    street_name VARCHAR(45) NOT NULL,
    number VARCHAR(45),
    neighborhood VARCHAR(45),
    city VARCHAR(45) NOT NULL,
    state CHAR(2) NOT NULL,
    type ENUM('residential', 'commercial', 'building', 'other') NOT NULL
);

#--- SUPPLY ---
CREATE TABLE IF NOT EXISTS material_catalog (
    id_material INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(45) NOT NULL,
    price DOUBLE NOT NULL,
    metric ENUM('unit', 'meter', 'centimeter') NOT NULL,
    supplier VARCHAR(45),
    url VARCHAR(255)
);

#--- PEOPLE ---
CREATE TABLE IF NOT EXISTS permission (
    id_permision INT AUTO_INCREMENT PRIMARY KEY,
    role VARCHAR(50) NOT NULL,
    main_screen VARCHAR(45) NOT NULL,
    access_client TINYINT UNSIGNED NOT NULL,
    access_project TINYINT UNSIGNED NOT NULL,
    access_budget TINYINT UNSIGNED NOT NULL
);

CREATE TABLE IF NOT EXISTS coworker (
    id_coworker INT AUTO_INCREMENT PRIMARY KEY,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    fk_permission INT NOT NULL,
    recovery_code VARCHAR(10),
    recovery_deadline DATETIME,
    phone VARCHAR(11),
    email VARCHAR(255) UNIQUE NOT NULL,
    FOREIGN KEY (fk_permission) REFERENCES permission(id_permision)
);

CREATE TABLE IF NOT EXISTS client (
    id_client INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(45) NOT NULL,
    last_name VARCHAR(45),
    document_number VARCHAR(45) UNIQUE,
    document_type VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fk_coworker_last_update INT,
    cnpj VARCHAR(14) UNIQUE,
    fk_main_address INT,
    note VARCHAR(45),
    phone VARCHAR(11),
    email VARCHAR(255) UNIQUE NOT NULL,
    FOREIGN KEY (fk_coworker_last_update) REFERENCES coworker(id_coworker),
    FOREIGN KEY (fk_main_address) REFERENCES address(id_address)
);

#--- BUDGET ---
CREATE TABLE IF NOT EXISTS budget (
    id_budget INT AUTO_INCREMENT PRIMARY KEY,
    total_cost DOUBLE,
    discount DOUBLE DEFAULT 0.0,
    material_cost DOUBLE,
    service_cost DOUBLE
);

CREATE TABLE IF NOT EXISTS budget_material (
    fk_budget INT NOT NULL,
    fk_material INT NOT NULL,
    quantity DOUBLE NOT NULL,
    price DOUBLE NOT NULL,
    PRIMARY KEY (fk_budget, fk_material),
    FOREIGN KEY (fk_budget) REFERENCES budget(id_budget),
    FOREIGN KEY (fk_material) REFERENCES material_catalog(id_material)
);

CREATE TABLE IF NOT EXISTS parameter_option (
    id_service_option INT AUTO_INCREMENT PRIMARY KEY,
    type VARCHAR(45) NOT NULL,
    addition_tax DOUBLE DEFAULT 0.0,
    fixed_cost DOUBLE DEFAULT 0.0,
    fk_service INT 
);

CREATE TABLE IF NOT EXISTS budget_parameter (
    id_parameter INT AUTO_INCREMENT PRIMARY KEY,
    fk_budget INT NOT NULL,
    name VARCHAR(45) NOT NULL,
    description VARCHAR(45),
    metric VARCHAR(45),
    is_pre_budget TINYINT DEFAULT 0,
    fixed_value DOUBLE,
    FOREIGN KEY (fk_budget) REFERENCES budget(id_budget)
);

CREATE TABLE IF NOT EXISTS parameter_cost (
    fk_parameter INT NOT NULL,
    fk_option INT NOT NULL,
    cost DOUBLE NOT NULL,
    PRIMARY KEY (fk_parameter, fk_option),
    FOREIGN KEY (fk_parameter) REFERENCES budget_parameter(id_parameter),
    FOREIGN KEY (fk_option) REFERENCES parameter_option(id_service_option)
);

#--- PROJECT ---
CREATE TABLE IF NOT EXISTS project (
    id_project INT AUTO_INCREMENT PRIMARY KEY,
    status ENUM('pre_budget', 'scheduled_technical_visit', 'visiting', 'final_budget', 'instaling', 'installing and homologating', 'homologated', 'finished') NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    fk_client INT NOT NULL,
    fk_budget INT,
    fk_address INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    system_type ENUM('on-grid', 'off-grid') NOT NULL,
    deadline DATETIME,
    name VARCHAR(45) NOT NULL,
    description VARCHAR(100),
    FOREIGN KEY (fk_client) REFERENCES client(id_client),
    FOREIGN KEY (fk_address) REFERENCES address(id_address),
    FOREIGN KEY (fk_budget) REFERENCES budget(id_budget)
);

CREATE TABLE IF NOT EXISTS coworker_project (
    fk_coworker INT NOT NULL,
    fk_project INT NOT NULL,
    isResponsible TINYINT,
    PRIMARY KEY (fk_coworker, fk_project),
    FOREIGN KEY (fk_coworker) REFERENCES coworker(id_coworker),
    FOREIGN KEY (fk_project) REFERENCES project(id_project)
);

#--- SCHEDULE ---
CREATE TABLE IF NOT EXISTS schedule (
    id_schedule INT AUTO_INCREMENT PRIMARY KEY,
    notification_alert_time TIME,
    date DATETIME NOT NULL,
    is_active TINYINT DEFAULT 1,
    fk_project INT NOT NULL,
    type ENUM('visit', 'note') NOT NULL,
    fk_coworker INT NOT NULL,
    status ENUM('marked', 'in_progress', 'finished') NOT NULL DEFAULT 'marked',
    title VARCHAR(45) NOT NULL,
    description VARCHAR(100),
    FOREIGN KEY (fk_project) REFERENCES project(id_project),
    FOREIGN KEY (fk_coworker) REFERENCES coworker(id_coworker)
);

#--- PORTIFOLIO ---
CREATE TABLE IF NOT EXISTS portfolio (
    id_portfolio SMALLINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(50) NOT NULL,
    description VARCHAR(50) NOT NULL,
    image_path VARCHAR(20) NOT NULL,
    fk_project INT NOT NULL,
    FOREIGN KEY (fk_project) REFERENCES project(id_project)
);

#--- INSERTS ---
INSERT INTO permission (role, main_screen, access_client, access_project, access_budget) VALUES
('admin', 'dashboard', 15, 15, 15),
('technical', 'schedule', 1, 7, 15),
('engineer', 'project_list', 1, 1, 1);

INSERT INTO coworker (password, first_name, last_name, fk_permission, phone, email) VALUES
('$2a$12$Vo6eqzPrUo/lvyD7j7SA5OnX3vHNiXUom2xasN27LBDqK.eZOrTku', 'Sálvio', 'Nobrega', 1, '11987654321', 'salvio.admin@solarize.com.br'),
('$2a$12$Vo6eqzPrUo/lvyD7j7SA5OnX3vHNiXUom2xasN27LBDqK.eZOrTku', 'Cristiano', 'Ribeiro', 3, '11912345678', 'cristiano.eng@solarize.com.br'),
('$2a$12$Vo6eqzPrUo/lvyD7j7SA5OnX3vHNiXUom2xasN27LBDqK.eZOrTku', 'Maria', 'Gomes', 2, '11998765432', 'maria.tec@solarize.com.br');

INSERT INTO address (postal_code, street_name, number, neighborhood, city, state, type) VALUES
('13010050', 'Rua XV de Novembro', '123', 'Centro', 'Campinas', 'SP', 'residential'),
('01311000', 'Av. Paulista', '2000', 'Bela Vista', 'São Paulo', 'SP', 'building');

INSERT INTO client (first_name, last_name, document_number, fk_main_address, phone, email, fk_coworker_last_update) VALUES
('João', 'Silva', '12345678901', 1, '1933233431', 'joao.silva@example.com', 1),
('Maria', 'Oliveira', '12345678902', 2, '2199865432', 'maria.oliveira@example.com', 2),
('Pedro', 'Santos', '12345678903', 1, '1933233431', 'pedro.santos@example.com', 3);

INSERT INTO budget (total_cost) VALUES
(15000.00),
(35000.00),
(5000.00);

INSERT INTO project (name, description, status, fk_client, fk_budget, fk_address, system_type) VALUES
('Projeto João Silva', 'Instalação residencial para 5kWp.', 'scheduled_technical_visit', 1, 1, 1, 'on-grid'),
('Projeto Maria Oliveira', 'Sistema de backup para clínica.', 'instaling', 2, 2, 2, 'off-grid'),
('Projeto Pedro Santos', 'Pequena instalação comercial.', 'finished', 3, 3, 1, 'on-grid');

INSERT INTO coworker_project (fk_coworker, fk_project, isResponsible) VALUES
(2, 1, 1),
(2, 2, 1),
(2, 3, 1);

INSERT INTO schedule (date, fk_project, type, fk_coworker, status, title) VALUES
('2025-09-07 10:00:00', 1, 'visit', 3, 'finished', 'Visita Técnica Projeto Pedro'),
('2025-10-21 14:00:00', 1, 'visit', 3, 'marked', 'Visita Instalação Projeto Pedro'),
('2025-10-23 09:00:00', 1, 'visit', 3, 'marked', 'Visita Instalação Projeto Pedro');

INSERT INTO portfolio (title, description, image_path, fk_project) VALUES
('Casa João Silva', 'Sistema residencial on-grid, 5kWp.', 'joao_1.jpg', 1),
('Clínica Maria Oliveira', 'Sistema de backup off-grid, 10kWp.', 'maria_clinic.jpg', 2),
('Comércio Pedro Santos', 'Pequena instalação comercial, 3kWp.', 'pedro_com.jpg', 3);