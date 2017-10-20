-- 【Mysql】自定义函数：实现oracle instr() 函数功能
DELIMITER $$  
  
  
USE `bzmtestenv`$$   -- localDB
  
  
DROP FUNCTION IF EXISTS `func_instr_oracle`$$  
  
  
CREATE DEFINER=`root`@`localhost` FUNCTION `func_instr_oracle`(  
    f_str VARCHAR(1000), -- Parameter 1  
    f_substr VARCHAR(100),  -- Parameter 2  
    f_str_pos INT, -- Postion  
    f_count INT UNSIGNED -- Times  
    ) RETURNS INT(10) UNSIGNED  
BEGIN  
      -- Created by ytt. Simulating Oracle instr function.  
      -- Date 2015/12/5.  
      DECLARE i INT DEFAULT 0; -- Postion iterator  
      DECLARE j INT DEFAULT 0; -- Times compare.  
      DECLARE v_substr_len INT UNSIGNED DEFAULT 0; -- Length for Parameter 1.  
      DECLARE v_str_len INT UNSIGNED DEFAULT 0;  -- Length for Parameter 2.  
      SET v_str_len = LENGTH(f_str);   
      SET v_substr_len = LENGTH(f_substr);  
      -- Unsigned.  
      IF f_str_pos > 0 THEN  
        SET i = f_str_pos;  
        SET j = 0;  
        WHILE i <= v_str_len  
        DO  
          IF INSTR(LEFT(SUBSTR(f_str,i),v_substr_len),f_substr) > 0 THEN  
            SET j = j + 1;  
            IF j = f_count THEN  
              RETURN i;  
            END IF;  
          END IF;  
          SET i = i + 1;  
        END WHILE;  
      -- Signed.  
      ELSEIF f_str_pos <0 THEN  
        SET i = v_str_len + f_str_pos+1;  
        SET j = 0;  
        WHILE i <= v_str_len AND i > 0   
        DO  
          IF INSTR(RIGHT(SUBSTR(f_str,1,i),v_substr_len),f_substr) > 0 THEN  
            SET j = j + 1;  
            IF j = f_count THEN  
              RETURN i - v_substr_len + 1;  
            END IF;  
          END IF;  
          SET i = i - 1;  
        END WHILE;  
      -- Equal to 0.  
      ELSE  
        RETURN 0;  
      END IF;  
      RETURN 0;  
    END$$  
  
  
DELIMITER ;  