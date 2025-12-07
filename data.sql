SET FOREIGN_KEY_CHECKS = 0;
SET NAMES 'utf8mb4';

-- Senhas (Hash BCrypt)
SET @PASS_ADMIN = '$2a$12$Vo6eqzPrUo/lvyD7j7SA5OnX3vHNiXUom2xasN27LBDqK.eZOrTku';
SET @PASS_USER  = '$2a$12$Vo6eqzPrUo/lvyD7j7SA5OnX3vHNiXUom2xasN27LBDqK.eZOrTku';

INSERT INTO permission_group (id_permission_group, role, main_module, access_client, access_project, access_budget, access_schedule) VALUES
(1, 'ADMIN', 'PROJECT_LIST', 15, 15, 15, 15),
(2, 'TECHNICAL', 'SCHEDULE', 1, 7, 1, 15),
(3, 'SALES', 'CLIENT_LIST', 15, 3, 15, 1);

INSERT INTO coworker (id_coworker, first_name, last_name, email, phone, password, is_active, fk_permission_group) VALUES
(1, 'Sálvio', 'Nobrega', 'salvio.admin@solarize.com.br', '11987654321', @PASS_ADMIN, 1, 1),
(2, 'Cristiano', 'Ribeiro', 'cristiano.eng@solarize.com.br', '11912345678', @PASS_USER, 1, 2),
(3, 'Maria', 'Gomes', 'maria.tec@solarize.com.br', '11998765432', @PASS_USER, 1, 2),
(4, 'Ana', 'Vendas', 'ana.sales@solarize.com.br', '11955554444', @PASS_USER, 1, 3);

INSERT INTO address (id_address, postal_code, street_name, number, neighborhood, city, state, type) VALUES
(1, '13010-050', 'Rua XV de Novembro', '123', 'Centro', 'Campinas', 'SP', 'RESIDENTIAL'),
(2, '01311-000', 'Av. Paulista', '2000', 'Bela Vista', 'São Paulo', 'SP', 'BUILDING'),
(3, '88015-000', 'Rua Bocaiúva', '90', 'Centro', 'Florianópolis', 'SC', 'COMMERCIAL'),
(4, '22021-001', 'Av. Atlântica', '500', 'Copacabana', 'Rio de Janeiro', 'RJ', 'RESIDENTIAL'),
(5, '30130-000', 'Rua da Bahia', '1000', 'Centro', 'Belo Horizonte', 'MG', 'COMMERCIAL'),
(6, '70000-000', 'Asa Norte', 'SQN 102', 'Plano Piloto', 'Brasília', 'DF', 'RESIDENTIAL');

INSERT INTO client (id_client, first_name, last_name, document_number, document_type, created_at, phone, email, fk_main_address) VALUES
(1, 'João', 'Silva', '12345678901', 'CPF', '2025-08-01 10:00:00', '1933233431', 'joao.silva@example.com', 1),
(2, 'Maria', 'Oliveira', '12345678902', 'CPF', '2025-09-10 14:30:00', '2199865432', 'maria.oliveira@example.com', 2),
(3, 'Pedro', 'Santos', '11222333000144', 'CNPJ', '2025-10-05 09:00:00', '4899123456', 'pedro.santos@example.com', 3),
(4, 'Lucia', 'Ferreira', '98765432100', 'CPF', '2025-10-20 11:00:00', '21988887777', 'lucia.ferreira@example.com', 4),
(5, 'Empresa Tech', 'Solar', '55666777000199', 'CNPJ', '2025-11-01 15:45:00', '3133334444', 'contato@techsolar.com', 5);

INSERT INTO material_catalog (id_material, name, metric, price) VALUES
(1, 'Painel Solar 550W (Solar Center)', 'UNIT', 900.00),
(2, 'Inversor On-Grid 5kW (Painel Forte)', 'UNIT', 3500.00),
(3, 'Cabo Solar 6mm', 'METER', 12.00),
(4, 'Bateria 5kWh (EcoSolar)', 'UNIT', 2800.00),
(5, 'Estrutura de Fixação Telhado', 'UNIT', 450.00);

INSERT INTO material_url (id_material_url, description, url, fk_material) VALUES
(1, 'Ficha Técnica Painel', 'https://solarcenter.com/fichas/painel550w.pdf', 1),
(2, 'Manual Inversor', 'https://painelforte.com.br/manual/inversor5kw.pdf', 2),
(3, 'Certificação Bateria', 'https://ecosolar.com.br/docs/bateria5kwh.pdf', 4);

INSERT INTO budget (id_budget, total_cost, discount, material_cost, service_cost, final_budget) VALUES
(1, 18000.00, 500.00, 10000.00, 5000.00, TRUE),   -- Lucro: 3k
(2, 45000.00, 2000.00, 25000.00, 12000.00, TRUE), -- Lucro: 8k
(3, 8500.00, 0.00, 5000.00, 2000.00, FALSE),      -- Pré-orçamento
(4, 22000.00, 1000.00, 12000.00, 6000.00, TRUE),  -- Lucro: 4k
(5, 50000.00, 0.00, 30000.00, 10000.00, TRUE),    -- Lucro: 10k
(6, 12000.00, 0.00, 8000.00, 4000.00, FALSE),     -- Ponto de equilíbrio (Lucro 0)
(7, 30000.00, 1500.00, 15000.00, 8000.00, TRUE),  -- Lucro: 7k
(8, 0.00, 0.00, 0.00, 0.00, FALSE);               -- Sem valores definidos

-- 8. PROJECT (Dados críticos para Funil, Canais e Status)
INSERT INTO project (id_project, name, description, status, status_weight, preview_status, is_active, system_type, project_from, created_at, fk_client, fk_responsible, fk_budget, fk_address) VALUES
-- Q3 (Dados fora do filtro de Out-Nov para comparação)
(1, 'Residência João Silva', 'Instalação 5kWp', 'SCHEDULED_TECHNICAL_VISIT', 5, 'CLIENT_AWAITING_CONTACT', 1, 'ON_GRID', 'SITE_BUDGET_FORM', '2025-09-15 09:00:00', 1, 2, 1, 1),
(2, 'Clínica Maria Oliveira', 'Backup Off-grid', 'INSTALLED', 10, 'SCHEDULED_INSTALLING_VISIT', 1, 'OFF_GRID', 'WHATSAPP_BOT', '2025-09-20 10:30:00', 2, 3, 2, 2),

-- Q4 - OUTUBRO (Dentro do período de análise)
(3, 'Comércio Pedro Santos', 'Sistema Comercial', 'COMPLETED', 13, 'INSTALLED', 1, 'ON_GRID', 'INTERNAL_MANUAL_ENTRY', '2025-10-02 14:00:00', 3, 1, 4, 3),
(4, 'Casa de Praia Lucia', 'Off-grid simples', 'FINAL_BUDGET', 7, 'TECHNICAL_VISIT_COMPLETED', 1, 'OFF_GRID', 'SITE_BUDGET_FORM', '2025-10-15 11:00:00', 4, 4, 3, 4),
(5, 'Tech Solar Sede', 'Alta demanda', 'NEW', 3, NULL, 1, 'ON_GRID', 'INTERNAL_MANUAL_ENTRY', '2025-10-28 16:00:00', 5, 2, 8, 5),

-- Q4 - NOVEMBRO (Dentro do período de análise)
(6, 'Expansão João Silva', 'Adição de painéis', 'PRE_BUDGET', 4, 'NEW', 1, 'ON_GRID', 'WHATSAPP_BOT', '2025-11-05 08:30:00', 1, 2, 6, 1),
(7, 'Estacionamento Shopping', 'Carport Solar', 'SCHEDULED_INSTALLING_VISIT', 6, 'AWAITING_MATERIALS', 1, 'ON_GRID', 'SITE_BUDGET_FORM', '2025-11-10 13:00:00', 3, 3, 5, 3),
(8, 'Sítio Recanto', 'Bombeamento Solar', 'NEGOTIATION_FAILED', 12, 'FINAL_BUDGET', 1, 'OFF_GRID', 'WHATSAPP_BOT', '2025-11-12 09:00:00', 2, 4, 7, 2),
(9, 'Condomínio Flores', 'Área comum', 'CLIENT_AWAITING_CONTACT', 1, 'PRE_BUDGET', 1, 'ON_GRID', 'SITE_BUDGET_FORM', '2025-11-20 15:00:00', 4, 1, 8, 4);

INSERT INTO coworker_project (fk_coworker, fk_project, is_responsible) VALUES
(2, 1, 1),
(3, 2, 1),
(1, 3, 1),
(4, 4, 1),
(2, 5, 1),
(2, 6, 0),
(3, 7, 1);

INSERT INTO budget_material (fk_budget, fk_material, quantity, price) VALUES
(1, 1, 10, 900.00),
(1, 3, 50, 12.00),
(2, 2, 2, 3500.00),
(2, 4, 4, 2800.00),
(4, 1, 20, 900.00);

INSERT INTO schedule (id_schedule, title, description, start_date, end_date, type, status, is_active, fk_project, fk_coworker) VALUES
(1, 'Visita Técnica João', 'Medição de telhado', '2025-09-25 10:00:00', '2025-09-25 12:00:00', 'TECHNICAL_VISIT', 'FINISHED', 1, 1, 2),
(2, 'Instalação Maria', 'Instalação Off-grid', '2025-10-01 08:00:00', '2025-10-03 18:00:00', 'INSTALL_VISIT', 'FINISHED', 1, 2, 3),
(3, 'Visita Técnica Lucia', 'Avaliação local', '2025-10-18 14:00:00', '2025-10-18 16:00:00', 'TECHNICAL_VISIT', 'FINISHED', 1, 4, 4),
(4, 'Instalação Shopping', 'Montagem Carport', '2025-12-05 08:00:00', '2025-12-10 18:00:00', 'INSTALL_VISIT', 'MARKED', 1, 7, 3);

INSERT INTO portfolio (id_portfolio, title, description, image_path, fk_project) VALUES
(1, 'Residência Sustentável', 'Sistema 5kWp em telhado cerâmico', '/images/portfolio/joao_v1.jpg', 1),
(2, 'Backup Hospitalar', 'Sistema de segurança energética', '/images/portfolio/maria_clinic.jpg', 2);

SET FOREIGN_KEY_CHECKS = 1;