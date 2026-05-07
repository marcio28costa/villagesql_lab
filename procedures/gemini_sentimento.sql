DELIMITER $$

CREATE PROCEDURE prc_sentimento_gemini(
  IN p_api_key TEXT
)
BEGIN

  DECLARE done INT DEFAULT FALSE;

  DECLARE v_id INT;
  DECLARE v_texto TEXT;

  DECLARE v_resposta TEXT;
  DECLARE v_sentimento VARCHAR(20);

  DECLARE cur CURSOR FOR
    SELECT id, texto
    FROM avaliacoes_gemini
    WHERE sentimento IS NULL;

  DECLARE CONTINUE HANDLER FOR NOT FOUND
    SET done = TRUE;

  OPEN cur;

  loop1: LOOP

    FETCH cur INTO v_id, v_texto;

    IF done THEN
      LEAVE loop1;
    END IF;

    -- chamada Gemini
    SET v_resposta = ai_prompt(
      'google',
      'gemini-2.5-flash',
      p_api_key,
      CONCAT(
        'Responda SOMENTE com uma palavra: ',
        'positivo, negativo ou neutro. ',
        'Nao explique. ',
        'Texto: ', v_texto
      )
    );

    -- limpeza
    SET v_resposta = LOWER(TRIM(v_resposta));

    SET v_resposta = REPLACE(v_resposta, CHAR(10), '');
    SET v_resposta = REPLACE(v_resposta, CHAR(13), '');

    -- validação final
    SET v_sentimento =
      CASE

        WHEN v_resposta LIKE '%positivo%'
          THEN 'positivo'

        WHEN v_resposta LIKE '%negativo%'
          THEN 'negativo'

        WHEN v_resposta LIKE '%neutro%'
          THEN 'neutro'

        ELSE 'indefinido'

      END;

    UPDATE avaliacoes_gemini
    SET sentimento = v_sentimento
    WHERE id = v_id;

    SELECT CONCAT(
      'ID ', v_id,
      ' | ',
      v_texto,
      ' -> ',
      v_sentimento
    ) AS resultado;

  END LOOP;

  CLOSE cur;

END$$

DELIMITER ;
