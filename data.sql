INSERT INTO permission_group (role, main_screen, access_client, access_project, access_budget, access_schedule) VALUES
('admin', 'dashboard', 15, 15, 15, 15),
('technical', 'schedule', 1, 7, 15, 7),
('engineer', 'project_list', 1, 1, 1, 1);

INSERT INTO coworker (password, first_name, last_name, fk_permission, phone, email) VALUES
('$2a$12$Vo6eqzPrUo/lvyD7j7SA5OnX3vHNiXUom2xasN27LBDqK.eZOrTku', 'Sálvio', 'Nobrega', 1, '11987654321', 'salvio.admin@solarize.com.br'),
('$2a$12$Vo6eqzPrUo/lvyD7j7SA5OnX3vHNiXUom2xasN27LBDqK.eZOrTku', 'Cristiano', 'Ribeiro', 3, '11912345678', 'cristiano.eng@solarize.com.br'),
('$2a$12$Vo6eqzPrUo/lvyD7j7SA5OnX3vHNiXUom2xasN27LBDqK.eZOrTku', 'Maria', 'Gomes', 2, '11998765432', 'maria.tec@solarize.com.br');

INSERT INTO address (postal_code, street_name, number, neighborhood, city, state, type) VALUES
('13010050', 'Rua XV de Novembro', '123', 'Centro', 'Campinas', 'SP', 'residential'),
('01311000', 'Av. Paulista', '2000', 'Bela Vista', 'São Paulo', 'SP', 'building'),
('88015000', 'Rua Bocaiúva', '90', 'Centro', 'Florianópolis', 'SC', 'commercial');

INSERT INTO client (first_name, last_name, document_number, fk_main_address, phone, email, fk_coworker_last_update) VALUES
('João', 'Silva', '12345678901', 1, '1933233431', 'joao.silva@example.com', 1),
('Maria', 'Oliveira', '12345678902', 2, '2199865432', 'maria.oliveira@example.com', 2),
('Pedro', 'Santos', '12345678903', 3, '4899123456', 'pedro.santos@example.com', 3);

INSERT INTO supplier (name, registration_number, phone, email, url) VALUES
('Solar Center', '11222333000144', '1933445566', 'contato@solarcenter.com', 'https://solarcenter.com'),
('Painel Forte', '44555666000177', '1133112233', 'vendas@painelforte.com.br', 'https://painelforte.com.br'),
('EcoSolar', '77888999000111', '11988887777', 'contato@ecosolar.com.br', 'https://ecosolar.com.br');

INSERT INTO material (name, metric, description, supplier) VALUES
('Painel Solar 550W', 'unit', 'Painel monocristalino de alta eficiência', 'Solar Center'),
('Inversor On-Grid 5kW', 'unit', 'Inversor para sistemas conectados à rede', 'Painel Forte'),
('Cabo Solar 6mm', 'meter', 'Cabo flexível para conexões fotovoltaicas', 'Solar Center'),
('Bateria 5kWh', 'unit', 'Bateria de lítio de alta durabilidade', 'EcoSolar');

INSERT INTO material_url (description, url, fk_material) VALUES
('Ficha técnica Painel 550W', 'https://solarcenter.com/fichas/painel550w.pdf', 1),
('Manual Inversor 5kW', 'https://painelforte.com.br/manual/inversor5kw.pdf', 2),
('Ficha técnica Cabo 6mm', 'https://solarcenter.com/fichas/cabo6mm.pdf', 3),
('Ficha técnica Bateria 5kWh', 'https://ecosolar.com.br/docs/bateria5kwh.pdf', 4);

INSERT INTO budget (total_cost, discount, material_cost, service_cost) VALUES
(15000.00, 0.0, 9000.00, 6000.00),
(35000.00, 2000.00, 22000.00, 11000.00),
(5000.00, 0.0, 3000.00, 2000.00);

INSERT INTO budget_material (fk_budget, fk_material, quantity, price) VALUES
(1, 1, 10, 900.00),
(1, 3, 50, 12.00),
(2, 2, 2, 4500.00),
(2, 4, 4, 2800.00),
(3, 1, 4, 850.00);

INSERT INTO budget_parameter (fk_budget, name, description, metric, is_pre_budget, fixed_value) VALUES
(1, 'Taxa de Instalação', 'Serviço de instalação completa', 'unit', 0, 1500.00),
(1, 'Cabo Extra', 'Adicional de cabeamento', 'meter', 1, 200.00),
(2, 'Suporte Estrutural', 'Estrutura metálica de fixação', 'unit', 0, 800.00),
(3, 'Transporte', 'Custo de transporte', 'unit', 0, 500.00);

INSERT INTO parameter_option (service_option, addition_tax, fixed_cost, fk_parameter) VALUES
('Padrão', 0.00, 0.00, 1),
('Premium', 0.05, 200.00, 1),
('Longo Alcance', 0.10, 150.00, 2);

INSERT INTO parameter_cost (fk_parameter, fk_option, cost) VALUES
(1, 1, 1500.00),
(1, 2, 1700.00),
(2, 3, 220.00);

INSERT INTO project (name, description, status, fk_client, fk_budget, fk_address, system_type, created_from, deadline) VALUES
('Projeto João Silva', 'Instalação residencial de 5kWp com 10 painéis.', 'scheduled_technical_visit', 1, 1, 1, 'on-grid', 'site', '2025-11-01'),
('Projeto Maria Oliveira', 'Sistema de backup off-grid 10kWh.', 'installing', 2, 2, 2, 'off-grid', 'bot', '2025-12-10'),
('Projeto Pedro Santos', 'Instalação comercial de 3kWp.', 'finished', 3, 3, 3, 'on-grid', 'site', '2025-10-01');

INSERT INTO coworker_project (fk_coworker, fk_project, isResponsible) VALUES
(2, 1, 1),
(3, 2, 1),
(2, 3, 1);

INSERT INTO schedule (date, fk_project, type, fk_coworker, status, title, description) VALUES
('2025-09-07 10:00:00', 1, 'visit', 3, 'finished', 'Visita Técnica', 'Vistoria inicial para medição do telhado'),
('2025-10-21 14:00:00', 1, 'visit', 3, 'marked', 'Instalação Inicial', 'Entrega dos painéis e preparação da estrutura'),
('2025-10-23 09:00:00', 2, 'visit', 2, 'in_progress', 'Instalação Inversor', 'Conexão dos módulos e testes elétricos');

INSERT INTO portfolio (title, description, image_path, fk_project) VALUES
('Casa João Silva', 'Sistema on-grid residencial, 5kWp', 'joao_1.jpg', 1),
('Clínica Maria Oliveira', 'Backup off-grid 10kWh', 'maria_clinic.jpg', 2),
('Comércio Pedro Santos', 'Instalação comercial 3kWp', 'pedro_com.jpg', 3);