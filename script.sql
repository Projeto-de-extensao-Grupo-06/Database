DROP DATABASE IF EXISTS db_solarize;
CREATE DATABASE IF NOT EXISTS db_solarize;
USE db_solarize;

SET FOREIGN_KEY_CHECKS = 0;

-- Drop tables para garantir a limpeza em caso de reexecução
DROP TABLE IF EXISTS parameter_cost;
DROP TABLE IF EXISTS budget_material;
DROP TABLE IF EXISTS coworker_project;
DROP TABLE IF EXISTS project_file;
DROP TABLE IF EXISTS project_comment;
DROP TABLE IF EXISTS portfolio;
DROP TABLE IF EXISTS schedule;
DROP TABLE IF EXISTS retry_queue;
DROP TABLE IF EXISTS project;
DROP TABLE IF EXISTS budget_parameter;
DROP TABLE IF EXISTS parameter_option;
DROP TABLE IF EXISTS material_url;
DROP TABLE IF EXISTS material_catalog;
DROP TABLE IF EXISTS budget;
DROP TABLE IF EXISTS client;
DROP TABLE IF EXISTS address;
DROP TABLE IF EXISTS coworker;
DROP TABLE IF EXISTS permission_group;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE permission_group (
    id_permission_group BIGINT NOT NULL AUTO_INCREMENT,
    role VARCHAR(255) NOT NULL,
    main_module VARCHAR(255) NULL,
    access_client INT NULL,
    access_project INT NULL,
    access_budget INT NULL,
    access_schedule INT NULL,
    PRIMARY KEY (id_permission_group),
    UNIQUE KEY uk_permission_group_role (role)
);

CREATE TABLE coworker (
    id_coworker BIGINT NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(255) NULL,
    last_name VARCHAR(255) NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(255) NULL,
    password VARCHAR(255) NOT NULL,
    is_active TINYINT(1) DEFAULT 1,
    fk_permission_group BIGINT NULL,
    PRIMARY KEY (id_coworker),
    UNIQUE KEY uk_coworker_email (email),
    INDEX idx_coworker_email (email),
    CONSTRAINT fk_coworker_permission_group
        FOREIGN KEY (fk_permission_group)
        REFERENCES permission_group (id_permission_group)
);

CREATE TABLE address (
    id_address BIGINT NOT NULL AUTO_INCREMENT,
    postal_code VARCHAR(255) NULL,
    street_name VARCHAR(255) NULL,
    number VARCHAR(255) NULL,
    neighborhood VARCHAR(255) NULL,
    city VARCHAR(255) NULL,
    state VARCHAR(255) NULL,
    type VARCHAR(255) NULL, 
    PRIMARY KEY (id_address)
);

CREATE TABLE client (
    id_client BIGINT NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(255) NULL,
    last_name VARCHAR(255) NULL,
    document_number VARCHAR(255) NULL,
    document_type VARCHAR(255) NULL, 
    created_at DATETIME NULL,
    updated_at DATETIME NULL,
    note VARCHAR(255) NULL,
    phone VARCHAR(255) NULL,
    email VARCHAR(255) NULL,
    fk_coworker_last_update BIGINT NULL,
    fk_main_address BIGINT NULL,
    PRIMARY KEY (id_client),
    UNIQUE KEY uk_client_document_number (document_number),
    UNIQUE KEY uk_client_email (email),
    UNIQUE KEY uk_client_phone (phone),
    CONSTRAINT fk_client_coworker
        FOREIGN KEY (fk_coworker_last_update)
        REFERENCES coworker (id_coworker),
    CONSTRAINT fk_client_main_address
        FOREIGN KEY (fk_main_address)
        REFERENCES address (id_address)
);

CREATE TABLE budget (
    id_budget BIGINT NOT NULL AUTO_INCREMENT,
    total_cost DOUBLE NULL,
    discount DOUBLE NULL,
    material_cost DOUBLE NULL,
    service_cost DOUBLE NULL,
    final_budget TINYINT(1) NULL,
    PRIMARY KEY (id_budget)
);

CREATE TABLE project (
    id_project BIGINT NOT NULL AUTO_INCREMENT,
    status VARCHAR(255) NULL, 
    status_weight INT NULL,
    preview_status VARCHAR(255) NULL,
    is_active TINYINT(1) DEFAULT 1,
    created_at DATETIME NULL,
    deadline DATETIME NULL,
    system_type VARCHAR(255) NULL, 
    project_from VARCHAR(255) NULL, 
    name VARCHAR(255) NULL,
    description TEXT NULL,
    fk_client BIGINT NOT NULL,
    fk_responsible BIGINT NULL,
    fk_budget BIGINT NULL,
    fk_address BIGINT NULL,
    PRIMARY KEY (id_project),
    UNIQUE KEY uk_project_name (name),
    UNIQUE KEY uk_project_budget (fk_budget),
    CONSTRAINT fk_project_client
        FOREIGN KEY (fk_client)
        REFERENCES client (id_client),
    CONSTRAINT fk_project_responsible
        FOREIGN KEY (fk_responsible)
        REFERENCES coworker (id_coworker),
    CONSTRAINT fk_project_budget
        FOREIGN KEY (fk_budget)
        REFERENCES budget (id_budget),
    CONSTRAINT fk_project_address
        FOREIGN KEY (fk_address)
        REFERENCES address (id_address)
);

CREATE TABLE retry_queue (
    id BIGINT NOT NULL AUTO_INCREMENT,
    scheduled_date DATETIME NULL,
    retrying TINYINT(1) NULL,
    fk_project BIGINT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_retry_queue_project (fk_project),
    CONSTRAINT fk_retry_queue_project
        FOREIGN KEY (fk_project)
        REFERENCES project (id_project)
);

CREATE TABLE material_catalog (
    id_material BIGINT NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) NULL,
    price DOUBLE NULL,
    metric VARCHAR(255) NULL, 
    PRIMARY KEY (id_material)
);

CREATE TABLE material_url (
    id_material_url BIGINT NOT NULL AUTO_INCREMENT,
    description VARCHAR(255) NULL,
    url VARCHAR(255) NULL,
    fk_material BIGINT NULL,
    PRIMARY KEY (id_material_url),
    CONSTRAINT fk_material_url_material
        FOREIGN KEY (fk_material)
        REFERENCES material_catalog (id_material)
);

CREATE TABLE schedule (
    id_schedule BIGINT NOT NULL AUTO_INCREMENT,
    notification_alert_time TIME NULL,
    start_date DATETIME NULL,
    end_date DATETIME NULL,
    is_active TINYINT(1) NULL,
    type VARCHAR(255) NULL, 
    status VARCHAR(255) DEFAULT 'MARKED' NULL, 
    title VARCHAR(255) NULL,
    description VARCHAR(255) NULL,
    fk_project BIGINT NULL,
    fk_coworker BIGINT NOT NULL,
    PRIMARY KEY (id_schedule),
    CONSTRAINT fk_schedule_project
        FOREIGN KEY (fk_project)
        REFERENCES project (id_project),
    CONSTRAINT fk_schedule_coworker
        FOREIGN KEY (fk_coworker)
        REFERENCES coworker (id_coworker)
);

CREATE TABLE project_file (
    id_project_file BIGINT NOT NULL AUTO_INCREMENT,
    filename VARCHAR(255) NULL,
    original_filename VARCHAR(255) NULL,
    created_at DATETIME NULL,
    mb_size INT NULL,
    check_sum VARCHAR(255) NULL,
    homologation_doc TINYINT(1) NULL,
    content_type VARCHAR(255) NULL,
    fk_project BIGINT NULL,
    fk_coworker BIGINT NULL,
    PRIMARY KEY (id_project_file),
    CONSTRAINT fk_project_file_project
        FOREIGN KEY (fk_project)
        REFERENCES project (id_project),
    CONSTRAINT fk_project_file_uploader
        FOREIGN KEY (fk_coworker)
        REFERENCES coworker (id_coworker)
);

CREATE TABLE project_comment (
    id_project_comment BIGINT NOT NULL AUTO_INCREMENT,
    comment TEXT NULL,
    created_at DATETIME NULL,
    fk_coworker BIGINT NULL,
    fk_project BIGINT NULL,
    PRIMARY KEY (id_project_comment),
    CONSTRAINT fk_project_comment_author
        FOREIGN KEY (fk_coworker)
        REFERENCES coworker (id_coworker),
    CONSTRAINT fk_project_comment_project
        FOREIGN KEY (fk_project)
        REFERENCES project (id_project)
);

CREATE TABLE portfolio (
    id_portfolio BIGINT NOT NULL AUTO_INCREMENT,
    title VARCHAR(255) NULL,
    description VARCHAR(255) NULL,
    image_path VARCHAR(255) NULL,
    fk_project BIGINT NOT NULL,
    PRIMARY KEY (id_portfolio),
    UNIQUE KEY uk_portfolio_project (fk_project),
    CONSTRAINT fk_portfolio_project
        FOREIGN KEY (fk_project)
        REFERENCES project (id_project)
);

CREATE TABLE budget_parameter (
    id_parameter BIGINT NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) NULL,
    description VARCHAR(255) NULL,
    metric VARCHAR(255) NULL,
    is_pre_budget TINYINT(1) NULL,
    fixed_value DOUBLE NULL,
    id_budget BIGINT NOT NULL,
    PRIMARY KEY (id_parameter),
    CONSTRAINT fk_budget_parameter_budget
        FOREIGN KEY (id_budget)
        REFERENCES budget (id_budget)
);

CREATE TABLE parameter_option (
    id_service_option BIGINT NOT NULL AUTO_INCREMENT,
    type VARCHAR(255) NULL,
    addition_tax DOUBLE NULL,
    fixed_cost DOUBLE NULL,
    fk_parameter BIGINT NULL,
    PRIMARY KEY (id_service_option),
    CONSTRAINT fk_parameter_option_parameter
        FOREIGN KEY (fk_parameter)
        REFERENCES budget_parameter (id_parameter)
);

CREATE TABLE coworker_project (
    fk_coworker BIGINT NOT NULL,
    fk_project BIGINT NOT NULL,
    is_responsible TINYINT(1) NULL,
    PRIMARY KEY (fk_coworker, fk_project),
    CONSTRAINT fk_coworker_project_coworker
        FOREIGN KEY (fk_coworker)
        REFERENCES coworker (id_coworker),
    CONSTRAINT fk_coworker_project_project
        FOREIGN KEY (fk_project)
        REFERENCES project (id_project)
);

CREATE TABLE budget_material (
    fk_budget BIGINT NOT NULL,
    fk_material BIGINT NOT NULL,
    quantity DOUBLE NULL,
    price DOUBLE NULL,
    PRIMARY KEY (fk_budget, fk_material),
    CONSTRAINT fk_budget_material_budget
        FOREIGN KEY (fk_budget)
        REFERENCES budget (id_budget),
    CONSTRAINT fk_budget_material_material
        FOREIGN KEY (fk_material)
        REFERENCES material_catalog (id_material)
);

CREATE TABLE parameter_cost (
    fk_parameter BIGINT NOT NULL,
    fk_option BIGINT NOT NULL,
    cost DOUBLE NULL,
    PRIMARY KEY (fk_parameter, fk_option),
    CONSTRAINT fk_parameter_cost_parameter
        FOREIGN KEY (fk_parameter)
        REFERENCES budget_parameter (id_parameter),
    CONSTRAINT fk_parameter_cost_option
        FOREIGN KEY (fk_option)
        REFERENCES parameter_option (id_service_option)
);