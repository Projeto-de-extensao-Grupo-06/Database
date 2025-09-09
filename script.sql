CREATE DATABASE IF NOT EXISTS db_solarize;
USE db_solarize;

# Teste de utilização HEX no Banco de Dados PARA PERMISSÃO
-- Nenhuma - 0x0
-- Leitura - 0x1
-- Criar/Escrever - 0x2
-- Atualizar - 0x4
-- Deletar - 0x8
CREATE TABLE IF NOT EXISTS permission (
    id_permision INT AUTO_INCREMENT PRIMARY KEY,
    role VARCHAR(50) NOT NULL,
    access_client_data TINYINT UNSIGNED NOT NULL,
    access_project_data TINYINT UNSIGNED NOT NULL
);

INSERT INTO permission (role, access_client_data, access_project_data) VALUES
('admin', 0xF, 0xF), 
('user', 0x1, 0x3), 
('guest', 0x1, 0x1); 

# Validar se tem uma permissão específica
SELECT (access_client_data & 0x8) > 0 AS can_delete
FROM permission;