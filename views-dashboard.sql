CREATE OR REPLACE VIEW VIEW_ANALYSIS_PROJECT_FINANCE AS
SELECT
    p.id_project,
    p.project_from AS acquisition_channel,
    p.created_at,
    p.status,
    COALESCE(b.total_cost, 0) AS total_revenue,
    COALESCE(b.material_cost, 0) + COALESCE(b.service_cost, 0) AS total_project_cost,
    COALESCE(b.total_cost, 0) - (COALESCE(b.material_cost, 0) + COALESCE(b.service_cost, 0)) AS profit_margin
FROM
    project p
LEFT JOIN
    budget b ON p.fk_budget = b.id_budget
WHERE
    p.is_active = 1;

-- KPIS
CREATE OR REPLACE VIEW VIEW_ANALYSIS_KPIS AS
WITH ProjectCounts AS (
    SELECT
        COUNT(id_project) AS total_projects,
        SUM(CASE WHEN status = 'COMPLETED' THEN 1 ELSE 0 END) AS completed_projects,
        SUM(CASE WHEN status = 'NEW' THEN 1 ELSE 0 END) AS new_projects,
        SUM(CASE WHEN status IN ('FINAL_BUDGET', 'INSTALLED', 'COMPLETED') THEN 1 ELSE 0 END) AS contracts_signed_projects
    FROM
        project
    WHERE
        is_active = 1
),
FinancialSummary AS (
    SELECT
        acquisition_channel,
        SUM(total_project_cost) AS total_cost_by_channel,
        ROW_NUMBER() OVER (ORDER BY SUM(total_project_cost) DESC) as rn
    FROM
        VIEW_ANALYSIS_PROJECT_FINANCE
    GROUP BY
        acquisition_channel
)
SELECT
    (SELECT SUM(profit_margin) FROM VIEW_ANALYSIS_PROJECT_FINANCE) AS total_profit_margin,
    (SELECT acquisition_channel FROM FinancialSummary WHERE rn = 1) AS most_costly_channel,
    (PC.completed_projects * 100.0 / PC.total_projects) AS project_completion_rate,
    (PC.contracts_signed_projects * 100.0 / PC.new_projects) AS funnel_conversion_rate
FROM
    ProjectCounts PC;

-- Canais de aquisição
CREATE OR REPLACE VIEW VIEW_ANALYSIS_ACQUISITION_CHANNELS AS
WITH ChannelCounts AS (
    SELECT
        acquisition_channel,
        COUNT(id_project) AS channel_project_count
    FROM
        VIEW_ANALYSIS_PROJECT_FINANCE
    GROUP BY
        acquisition_channel
),
TotalProjects AS (
    SELECT COUNT(id_project) AS total_projects FROM project WHERE is_active = 1
)
SELECT
    CC.acquisition_channel AS nome,
    CC.channel_project_count,
    (CC.channel_project_count * 100.0 / (SELECT total_projects FROM TotalProjects)) AS percentual
FROM
    ChannelCounts CC
ORDER BY
    percentual DESC;

-- analise custo vs ganho
CREATE OR REPLACE VIEW VIEW_ANALYSIS_PROFIT_COST_MONTHLY AS
SELECT
    YEAR(created_at) AS ano,
    MONTH(created_at) AS mes,
    SUM(total_project_cost) AS total_cost,
    SUM(profit_margin) AS total_profit
FROM
    VIEW_ANALYSIS_PROJECT_FINANCE
GROUP BY
    YEAR(created_at), MONTH(created_at)
ORDER BY
    ano ASC, mes ASC;


-- status do projeto
CREATE OR REPLACE VIEW VIEW_ANALYSIS_PROJECTS_STATUS_SUMMARY AS
SELECT
    CASE p.status
        WHEN 'COMPLETED' THEN 'Finalizado'
        WHEN 'NEGOTIATION_FAILED' THEN 'Finalizado'
        WHEN 'SCHEDULED_TECHNICAL_VISIT' THEN 'Agendado'
        WHEN 'SCHEDULED_INSTALLING_VISIT' THEN 'Agendado'
        WHEN 'NEW' THEN 'Novo'
        ELSE 'Em andamento'
    END AS status_group,
    COUNT(p.id_project) AS quantidade
FROM
    project p
WHERE
    p.is_active = 1
GROUP BY
    status_group;


-- dados funil de vendas
CREATE OR REPLACE VIEW VIEW_ANALYSIS_SALES_FUNNEL_STAGES AS
SELECT
    CASE p.status
        WHEN 'PRE_BUDGET' THEN 'Pré-Orçamento'
        WHEN 'FINAL_BUDGET' THEN 'Proposta Enviada' 
        WHEN 'INSTALLED' THEN 'Instalado'
        WHEN 'COMPLETED' THEN 'Finalizado/Entregue'
        ELSE 'Outras Etapas'
    END AS etapa,
    COUNT(p.id_project) AS valor
FROM
    project p
WHERE
    p.is_active = 1 AND p.status IN ('PRE_BUDGET', 'FINAL_BUDGET', 'INSTALLED', 'COMPLETED')
GROUP BY
    etapa;


--=====================================
-- SELEÇÕES DAS VIEWS
--=====================================

SELECT
    (
        SELECT SUM(profit_margin)
        FROM VIEW_ANALYSIS_PROJECT_FINANCE
        WHERE created_at >= '2025-10-01 00:00:00' AND created_at < '2025-12-01 00:00:00'
    ) AS total_profit_margin,
    (
        SELECT acquisition_channel
        FROM VIEW_ANALYSIS_PROJECT_FINANCE
        WHERE created_at >= '2025-10-01 00:00:00' AND created_at < '2025-12-01 00:00:00'
        GROUP BY acquisition_channel
        ORDER BY SUM(total_project_cost) DESC
        LIMIT 1
    ) AS most_costly_channel,
    (
        SELECT
            (SUM(CASE WHEN status = 'COMPLETED' THEN 1 ELSE 0 END) * 100.0 / COUNT(id_project))
        FROM VIEW_ANALYSIS_PROJECT_FINANCE
        WHERE created_at >= '2025-10-01 00:00:00' AND created_at < '2025-12-01 00:00:00'
    ) AS project_completion_rate,
    (
        SELECT
            (SUM(CASE WHEN status IN ('FINAL_BUDGET', 'INSTALLED', 'COMPLETED') THEN 1 ELSE 0 END) * 100.0 /
             SUM(CASE WHEN status = 'NEW' THEN 1 ELSE 0 END))
        FROM VIEW_ANALYSIS_PROJECT_FINANCE
        WHERE created_at >= '2025-10-01 00:00:00' AND created_at < '2025-12-01 00:00:00'
    ) AS funnel_conversion_rate;


SELECT
    CASE FD.acquisition_channel
        WHEN 'SITE_BUDGET_FORM' THEN 'Site'
        WHEN 'INTERNAL_MANUAL_ENTRY' THEN 'Boca a Boca'
        WHEN 'WHATSAPP_BOT' THEN 'Rede Social'
        ELSE FD.acquisition_channel
        END AS nome,
    (
        COUNT(FD.id_project) * 100.0 / (
            SELECT COUNT(id_project)
            FROM VIEW_ANALYSIS_PROJECT_FINANCE
            WHERE created_at >= '2025-10-01 00:00:00' AND created_at < '2025-12-01 00:00:00'
        )
        ) AS percentual
FROM
    VIEW_ANALYSIS_PROJECT_FINANCE FD
WHERE
    FD.created_at >= '2025-10-01 00:00:00' AND FD.created_at < '2025-12-01 00:00:00'
GROUP BY
    FD.acquisition_channel
ORDER BY
    percentual DESC;


SELECT
    ano,
    mes,
    total_cost,
    total_profit
FROM
    VIEW_ANALYSIS_PROFIT_COST_MONTHLY
WHERE
    STR_TO_DATE(CONCAT(ano, '-', mes, '-01'), '%Y-%m-%d') >= '2025-10-01'
  AND STR_TO_DATE(CONCAT(ano, '-', mes, '-01'), '%Y-%m-%d') < '2025-12-01'
ORDER BY
    ano ASC, mes ASC;


SELECT
    CASE p.status
        WHEN 'COMPLETED' THEN 'Finalizado'
        WHEN 'NEGOTIATION_FAILED' THEN 'Finalizado'
        WHEN 'SCHEDULED_TECHNICAL_VISIT' THEN 'Agendado'
        WHEN 'SCHEDULED_INSTALLING_VISIT' THEN 'Agendado'
        WHEN 'NEW' THEN 'Novo'
        ELSE 'Em andamento'
        END AS status_group,

    COUNT(p.id_project) AS quantidade
FROM
    project p
WHERE
    p.is_active = 1
  AND p.created_at >= '2025-10-01 00:00:00'
  AND p.created_at < '2025-12-01 00:00:00'
GROUP BY
    CASE p.status
        WHEN 'COMPLETED' THEN 'Finalizado'
        WHEN 'NEGOTIATION_FAILED' THEN 'Finalizado'
        WHEN 'SCHEDULED_TECHNICAL_VISIT' THEN 'Agendado'
        WHEN 'SCHEDULED_INSTALLING_VISIT' THEN 'Agendado'
        WHEN 'NEW' THEN 'Novo'
        ELSE 'Em andamento'
        END;


SELECT
    CASE p.status
        WHEN 'PRE_BUDGET' THEN 'Pré-Orçamento'
        WHEN 'FINAL_BUDGET' THEN 'Contrato Assinado'
        WHEN 'INSTALLED' THEN 'Instalado'
        WHEN 'COMPLETED' THEN 'Finalizado/Entregue'
        ELSE 'Outras Etapas'
        END AS etapa,
    COUNT(p.id_project) AS valor
FROM
    project p
WHERE
    p.is_active = 1
  AND p.created_at >= '2025-10-01 00:00:00' AND p.created_at < '2025-12-01 00:00:00'
  AND p.status IN ('PRE_BUDGET', 'FINAL_BUDGET', 'INSTALLED', 'COMPLETED')
GROUP BY
    etapa
ORDER BY
    valor DESC;