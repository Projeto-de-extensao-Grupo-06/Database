DROP DATABASE IF EXISTS db_solarize;
CREATE DATABASE IF NOT EXISTS db_solarize;
USE db_solarize;

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

CREATE TABLE IF NOT EXISTS supplier (
    id_supplier INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(45) NOT NULL,
    registration_number CHAR(14) UNIQUE,
    phone VARCHAR(45),
    email VARCHAR(255),
    url VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS material (
    id_material INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(45) NOT NULL,
    metric ENUM('unit', 'meter', 'centimeter') NOT NULL,
    description VARCHAR(100),
    supplier VARCHAR(45)
);

CREATE TABLE IF NOT EXISTS material_url (
    id_material_url INT AUTO_INCREMENT PRIMARY KEY,
    description VARCHAR(45),
    url VARCHAR(255),
    fk_material INT,
    FOREIGN KEY (fk_material) REFERENCES material(id_material)
);

CREATE TABLE IF NOT EXISTS permission_group (
    id_permission_group INT AUTO_INCREMENT PRIMARY KEY,
    role VARCHAR(45) NOT NULL,
    main_screen VARCHAR(45),
    access_client TINYINT,
    access_project TINYINT,
    access_budget TINYINT,
    access_schedule TINYINT
);

CREATE TABLE IF NOT EXISTS coworker (
    id_coworker INT AUTO_INCREMENT PRIMARY KEY,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(45) NOT NULL,
    last_name VARCHAR(45),
    fk_permission INT NOT NULL,
    recovery_code VARCHAR(10),
    recovery_deadline DATETIME,
    phone VARCHAR(11),
    email VARCHAR(255) UNIQUE NOT NULL,
    FOREIGN KEY (fk_permission) REFERENCES permission_group(id_permission_group)
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
    FOREIGN KEY (fk_material) REFERENCES material(id_material)
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

CREATE TABLE IF NOT EXISTS parameter_option (
    id_service_option INT AUTO_INCREMENT PRIMARY KEY,
    service_option VARCHAR(45) NOT NULL,
    addition_tax DOUBLE DEFAULT 0.0,
    fixed_cost DOUBLE DEFAULT 0.0,
    fk_parameter INT,
    FOREIGN KEY (fk_parameter) REFERENCES budget_parameter(id_parameter)
);

CREATE TABLE IF NOT EXISTS parameter_cost (
    fk_parameter INT NOT NULL,
    fk_option INT NOT NULL,
    cost DOUBLE NOT NULL,
    PRIMARY KEY (fk_parameter, fk_option),
    FOREIGN KEY (fk_parameter) REFERENCES budget_parameter(id_parameter),
    FOREIGN KEY (fk_option) REFERENCES parameter_option(id_service_option)
);

CREATE TABLE IF NOT EXISTS project (
    id_project INT AUTO_INCREMENT PRIMARY KEY,
    status ENUM(
        'pre_budget',
        'scheduled_technical_visit',
        'visiting',
        'final_budget',
        'installing',
        'installing_and_homologating',
        'homologated',
        'finished'
    ) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    fk_client INT NOT NULL,
    fk_budget INT,
    fk_address INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    system_type ENUM('on-grid', 'off-grid') NOT NULL,
    deadline DATETIME,
    name VARCHAR(45) NOT NULL,
    description VARCHAR(100),
    created_from ENUM('site', 'bot'),
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

CREATE TABLE IF NOT EXISTS portfolio (
    id_portfolio SMALLINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(50) NOT NULL,
    description VARCHAR(50) NOT NULL,
    image_path VARCHAR(20) NOT NULL,
    fk_project INT NOT NULL,
    FOREIGN KEY (fk_project) REFERENCES project(id_project)
);