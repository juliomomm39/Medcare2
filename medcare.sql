CREATE TABLE pacientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    cpf CHAR(11) UNIQUE NOT NULL,
    data_nascimento DATE NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (LENGTH(cpf) = 11)
);

CREATE TABLE especialidades (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE medicos (
    id SERIAL PRIMARY KEY,
    especialidade_id INTEGER NOT NULL,
    nome VARCHAR(100) NOT NULL,
    crm VARCHAR(30) UNIQUE NOT NULL,
    valor_consulta DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (especialidade_id) REFERENCES especialidades(id),
    CHECK (valor_consulta > 0)
);

CREATE TABLE consultas (
    id SERIAL PRIMARY KEY,
    medico_id INTEGER NOT NULL,
    paciente_id INTEGER NOT NULL,
    data_hora TIMESTAMP NOT NULL,
    status VARCHAR(20) DEFAULT 'Agendada',
    FOREIGN KEY (medico_id) REFERENCES medicos(id),
    FOREIGN KEY (paciente_id) REFERENCES pacientes(id),
    CHECK (status IN ('Agendada', 'Realizada', 'Cancelada'))
);

CREATE TABLE exames_consulta (
    id SERIAL PRIMARY KEY,
    consulta_id INTEGER NOT NULL,
    nome_exame VARCHAR(150) NOT NULL,
    valor_exame DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (consulta_id) REFERENCES consultas(id),
    CHECK (valor_exame >= 0)
);

INSERT INTO especialidades (nome) VALUES
('Cardiologia'),
('Pediatria'),
('Dermatologia');

INSERT INTO medicos (especialidade_id, nome, crm, valor_consulta) VALUES
(1, 'Dr. Roberto Almeida', 'CRM12345', 450.00),
(2, 'Dra. Fernanda Costa', 'CRM23456', 250.00),
(3, 'Dr. Marcelo Santos', 'CRM34567', 350.00);

INSERT INTO pacientes (nome, email, cpf, data_nascimento) VALUES
('Carlos Silva', 'carlos@email.com', '12345678901', '1990-05-15'),
('Ana Souza', 'ana@email.com', '23456789012', '1985-08-20'),
('Pedro Oliveira', 'pedro@email.com', '34567890123', '2000-02-10');

INSERT INTO consultas (medico_id, paciente_id, data_hora, status) VALUES
(1, 1, '2026-09-10 09:00:00', 'Realizada'),
(2, 1, '2026-09-11 14:00:00', 'Agendada'),
(3, 2, '2026-09-12 10:30:00', 'Realizada'),
(1, 3, '2026-09-13 16:00:00', 'Cancelada');

INSERT INTO exames_consulta (consulta_id, nome_exame, valor_exame) VALUES
(1, 'Eletrocardiograma', 120.00),
(1, 'Hemograma Completo', 80.00),
(3, 'Exame Dermatológico', 150.00),
(4, 'Hemograma Completo', 80.00);

SELECT 
    m.nome AS medico,
    m.crm,
    e.nome AS especialidade,
    m.valor_consulta
FROM medicos m
JOIN especialidades e 
    ON m.especialidade_id = e.id
ORDER BY m.valor_consulta DESC;

SELECT 
    c.id AS id_consulta,
    c.data_hora,
    m.nome AS medico,
    e.nome AS especialidade,
    c.status
FROM consultas c
JOIN pacientes p 
    ON c.paciente_id = p.id
JOIN medicos m 
    ON c.medico_id = m.id
JOIN especialidades e 
    ON m.especialidade_id = e.id
WHERE p.nome = 'Carlos Silva'
ORDER BY c.data_hora;

SELECT 
    c.id AS id_consulta,
    p.nome AS paciente,
    m.nome AS medico,
    m.valor_consulta + COALESCE(SUM(ec.valor_exame), 0) AS valor_total
FROM consultas c
JOIN pacientes p 
    ON c.paciente_id = p.id
JOIN medicos m 
    ON c.medico_id = m.id
LEFT JOIN exames_consulta ec 
    ON c.id = ec.consulta_id
GROUP BY c.id, p.nome, m.nome, m.valor_consulta
ORDER BY c.id;

SELECT 
    nome AS medico,
    crm,
    valor_consulta
FROM medicos
WHERE valor_consulta > 300.00
ORDER BY valor_consulta DESC;

SELECT 
    e.nome AS especialidade,
    SUM(
        m.valor_consulta + 
        COALESCE(ex.total_exames, 0)
    ) AS total_faturado
FROM consultas c
JOIN medicos m 
    ON c.medico_id = m.id
JOIN especialidades e 
    ON m.especialidade_id = e.id
LEFT JOIN (
    SELECT 
        consulta_id,
        SUM(valor_exame) AS total_exames
    FROM exames_consulta
    GROUP BY consulta_id
) ex 
    ON c.id = ex.consulta_id
WHERE c.status = 'Realizada'
GROUP BY e.nome
ORDER BY total_faturado DESC;