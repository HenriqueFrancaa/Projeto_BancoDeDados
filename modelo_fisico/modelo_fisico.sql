USE drive;

CREATE TABLE plano(
	id INT AUTO_INCREMENT,
    nome VARCHAR(100),
    duracao INT,
    data_aquisicao DATE,
    espaco_usuario INT,
    PRIMARY KEY(id)
);

CREATE TABLE instituicao(
	id INT AUTO_INCREMENT,
    nome VARCHAR(100),
    causa_social VARCHAR(100),
    endereco VARCHAR(100),
    id_plano INT,
    PRIMARY KEY(id),
    FOREIGN KEY(id_plano) REFERENCES plano(id)
);

CREATE TABLE usuario(
	id INT AUTO_INCREMENT,
    login VARCHAR(100),
    email VARCHAR(100),
    senha VARCHAR(100),
    data_ingresso DATE,
    id_instituicao INT,
    PRIMARY KEY(id),
    FOREIGN KEY(id_instituicao) REFERENCES instituicao(id)
);

CREATE TABLE administrador(
	id INT AUTO_INCREMENT,
    login VARCHAR(100),
    email VARCHAR(100),
    senha VARCHAR(100),
    data_ingresso DATE,
    PRIMARY KEY(id)
);

CREATE TABLE suporta(
	id INT AUTO_INCREMENT,
    dia DATE,
    hora TIME,
    descricao VARCHAR(255),
    id_usuario INT,
    id_administrador INT,
    PRIMARY KEY(id),
    FOREIGN KEY(id_usuario) REFERENCES usuario(id),
    FOREIGN KEY(id_administrador) REFERENCES administrador(id)
);

CREATE TABLE arquivo(
	id INT AUTO_INCREMENT,
    nome VARCHAR(255),
    tipo VARCHAR(100),
    URL VARCHAR(100),
    Permissoes_acesso VARCHAR(100),
    localizacao VARCHAR(100),
    tamanho INT,
    data_modificacao DATE,
    id_usuario INT,
    PRIMARY KEY(id),
    FOREIGN KEY(id_usuario) REFERENCES usuario(id)
);

CREATE TABLE opera(
	id INT AUTO_INCREMENT,
	hora TIME,
    tipo_operacao VARCHAR(100),
    data_operacao DATE,
    id_usuario INT,
    id_arquivo INT,
    PRIMARY KEY(id),
    FOREIGN KEY(id_usuario) REFERENCES usuario(id),
    FOREIGN KEY(id_arquivo) REFERENCES arquivo(id)
);

CREATE TABLE historico(
	id INT AUTO_INCREMENT,
    operacao VARCHAR(100),
    data_operacao DATE,
    hora TIME,
    conteudo_alterado VARCHAR(100),
    id_usuario INT,
    id_arquivo INT,
    PRIMARY KEY(id),
    FOREIGN KEY(id_usuario) REFERENCES usuario(id),
    FOREIGN KEY(id_arquivo)  REFERENCES arquivo(id)
);

CREATE TABLE comentario(
	id INT AUTO_INCREMENT,
    conteudo VARCHAR(150),
    data_comentario DATE,
    hora TIME,
    id_usuario INT,
    id_arquivo INT,
    PRIMARY KEY(id),
    FOREIGN KEY(id_usuario) REFERENCES usuario(id),
    FOREIGN KEY(id_arquivo) REFERENCES arquivo(id)
);

CREATE TABLE compartilhamento(
	id INT AUTO_INCREMENT,
    id_dono INT,
    id_arquivo INT,
    id_usercompartilhado INT,
    data_compartilhamento DATE,
    PRIMARY KEY(id),
    FOREIGN KEY(id_dono) REFERENCES usuario(id),
    FOREIGN KEY(id_arquivo) REFERENCES arquivo(id),
    FOREIGN KEY(id_usercompartilhado) REFERENCES usuario(id)
);

CREATE TABLE Atividades_recentes (
    id_arquivo INT,
    ultima_versao DATE,
    acesso ENUM('prioritário', 'não prioritário') DEFAULT 'não prioritário',
    PRIMARY KEY (id_arquivo),
    FOREIGN KEY (id_arquivo) REFERENCES arquivo(id)
);

DELIMITER //

CREATE TRIGGER Registrar_operacao
AFTER INSERT ON arquivo
FOR EACH ROW
BEGIN
    IF EXISTS(SELECT 1 FROM Atividades_recentes WHERE id_arquivo = NEW.id) THEN
        UPDATE Atividades_recentes
        SET ultima_versao = CURDATE()
        WHERE id_arquivo = NEW.id;
    ELSE
        INSERT INTO Atividades_recentes (id_arquivo, ultima_versao, acesso)
        VALUES(NEW.id, CURDATE(), 'default');
    END IF;
END;
//


CREATE TRIGGER Atualizar_acesso
AFTER INSERT ON compartilhamento
FOR EACH ROW
BEGIN
    DECLARE perm_at VARCHAR(100);
    
    SELECT Permissoes_acesso INTO perm_at 
    FROM arquivo 
    WHERE id = NEW.id_arquivo;

    IF perm_at = 'privado' THEN
        UPDATE arquivo
        SET Permissoes_acesso = 'privado/compartilhado'
        WHERE id = NEW.id_arquivo;
    ELSEIF perm_at = 'público' THEN
        UPDATE arquivo
        SET Permissoes_acesso = 'público/compartilhado'
        WHERE id = NEW.id_arquivo;
    END IF;

    INSERT INTO historico (operacao, data_operacao, hora, conteudo_alterado, id_usuario, id_arquivo)
    VALUES ('compartilhamento', CURDATE(), CURTIME(), 'arquivo compartilhado', NEW.id_dono, NEW.id_arquivo);
END;
//

DELIMITER ;

INSERT INTO administrador(id,login,email,senha,data_ingresso)VALUES(1,"Joao2303","joao.lucas@gmail.com","joao123", 23/03/2005);
INSERT INTO administrador(login,email,senha,data_ingresso)VALUES("Felipezz","felipe@gmail.com","felipezz", 18/02/1999);
SELECT * FROM administrador WHERE administrador.email = "joao.lucas@gmail.com";
SELECT * FROM administrador;