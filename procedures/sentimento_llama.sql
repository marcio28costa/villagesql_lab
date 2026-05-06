
DELIMITER $$

CREATE PROCEDURE prc_sentimento_llama()
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE v_id INT;
  DECLARE v_texto TEXT;
  DECLARE v_sentimento VARCHAR(50);

  DECLARE cur CURSOR FOR
    SELECT id, texto FROM avaliacoes_llama WHERE sentimento IS NULL;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN cur;

  loop1: LOOP
    FETCH cur INTO v_id, v_texto;
    IF done THEN LEAVE loop1; END IF;

    CALL ollama_prompt(
      CONCAT('Classifique positivo, negativo ou neutro: ', v_texto),
      v_sentimento
    );

    UPDATE avaliacoes_llama
    SET sentimento = LOWER(v_sentimento)
    WHERE id = v_id;

  END LOOP;

  CLOSE cur;
END$$

DELIMITER ;
