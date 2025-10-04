USE db_solarize;

CREATE OR REPLACE VIEW v_project_summary AS
SELECT
    p.id_project,
    p.name AS project_title,
    p.status AS project_status,
    c.id_client,
    CONCAT(c.first_name, ' ', c.last_name) AS client_name,
    CONCAT(cw_resp.first_name, ' ', cw_resp.last_name) AS responsible_name,
    p.deadline AS project_deadline,
    (
        SELECT
            MIN(s.date)
        FROM schedule s
        WHERE s.fk_project = p.id_project
              AND s.status = 'marked'
              AND s.date >= NOW()
    ) AS next_schedule_date
FROM project p
JOIN client c ON p.fk_client = c.id_client
LEFT JOIN coworker_project cp ON p.id_project = cp.fk_project 
          AND cp.isResponsible = 1
LEFT JOIN coworker cw_resp ON cp.fk_coworker = cw_resp.id_coworker
ORDER BY p.created_at DESC;

CREATE OR REPLACE VIEW v_schedule_details AS
    SELECT
        s.id_schedule,
        s.date AS schedule_datetime,
        s.type AS schedule_type,
        s.status AS schedule_status,
        p.name AS project_name,
        CONCAT(cl.first_name, ' ', cl.last_name) AS client_name,
        CONCAT(cw.first_name, ' ', cw.last_name) AS coworker_responsible
    FROM schedule s
    JOIN project p ON s.fk_project = p.id_project
    JOIN client cl ON p.fk_client = cl.id_client
    JOIN coworker cw ON s.fk_coworker = cw.id_coworker
    ORDER BY
        s.date DESC;

CREATE OR REPLACE VIEW v_client_summary AS
    SELECT
        c.id_client,
        CONCAT(c.first_name, ' ', c.last_name) AS client_name,
        c.phone AS client_phone,
        c.email AS client_email,
        CASE
            WHEN EXISTS (SELECT 1 FROM project p WHERE p.fk_client = c.id_client AND p.status NOT IN ('finished', 'canceled')) THEN 'Active Project'
            ELSE 'Finished'
        END AS client_project_status,
        COALESCE(c.cnpj, c.document_number) AS client_document
    FROM client c
    ORDER BY c.first_name ASC;