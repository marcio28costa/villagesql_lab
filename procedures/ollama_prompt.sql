DELIMITER $$

CREATE PROCEDURE ollama_prompt(
  IN p_prompt TEXT,
  OUT p_result TEXT
)
BEGIN
  DECLARE v_payload TEXT;
  DECLARE v_response TEXT;
  DECLARE v_content TEXT;

  SET v_payload = JSON_OBJECT(
    'model','phi3:mini',
    'prompt',p_prompt,
    'stream',FALSE
  );

  SET v_response = CONVERT(
    vsql_http.http_post(
      'http://ollama:11434/api/generate',
      'application/json',
      v_payload
    ) USING utf8mb4
  );

  SET v_content = JSON_UNQUOTE(JSON_EXTRACT(v_response,'$.content'));

  SET p_result = TRIM(
    SUBSTRING_INDEX(
      JSON_UNQUOTE(JSON_EXTRACT(v_content,'$.response')),
      CHAR(10),1
    )
  );
END$$

DELIMITER ;
