--functions part 3

--delete_rows
--drop_partition
--partition_drop_logic

--|	Deleta  linhas da tabela que estejam    |
--|	abaixo do valor lowest_valid_entry 		|
--|	na coluna p_field_name					|
--|	AUTOR: Guilherme Dias					|

CREATE OR REPLACE PROCEDURE delete_rows(
    p_table_name  	 	IN VARCHAR2,
	p_field_name 		IN VARCHAR2,
	lowest_valid_entry	NUMBER
)
IS
   del_rows VARCHAR2(1000);

BEGIN
	del_rows := ' DELETE FROM ' || p_table_name || ' WHERE ' || p_field_name || ' < ' || lowest_valid_entry;
    EXECUTE IMMEDIATE del_rows;

END delete_rows;
/

--|	Dropa particao com nome == p_partition_name |
--|	da tabela com nome == table_name			|
--|	AUTOR: Guilherme Dias						|
--|	DEPENDENCIAS:	funcao max_longs compilada	|

CREATE OR REPLACE PROCEDURE drop_partition(
    p_table_name  	 IN VARCHAR2,
	p_partition_name IN VARCHAR2
)
IS
   drop_part VARCHAR2(1000);
BEGIN
    drop_part := 'ALTER TABLE ' || p_table_name || ' DROP PARTITION ' || p_partition_name || ' UPDATE INDEXES';
    EXECUTE IMMEDIATE drop_part;
END drop_partition;
/


--|	 Funcao que determina que particoes 	   |
--|	 devem ser dropadas						   |
--|	AUTOR: Guilherme Dias					   |
--|	DEPENDENCIAS:	funcao max_longs compilada |

CREATE OR REPLACE PROCEDURE partition_drop_logic(
    p_table_name  	 IN VARCHAR2,
    p_table_owner 	 IN VARCHAR2,
	lowest_valid_entry	NUMBER
)
IS
	CURSOR parts_cursor IS 
		SELECT PARTITION_NAME, HIGH_VALUE		
			FROM all_tab_partitions
			WHERE table_owner = UPPER(p_table_owner)
			AND table_name = UPPER(p_table_name);	
				
	part parts_cursor%ROWTYPE;
	high_value_char VARCHAR2(4000);
	high_value_num NUMBER;

BEGIN
    OPEN parts_cursor;
			LOOP
				FETCH parts_cursor INTO part;
				EXIT WHEN parts_cursor%NOTFOUND;
				
                high_value_char := SUBSTR(part.HIGH_VALUE, 1, 4000);       
                high_value_num := to_number(high_value_char);
				
				IF ( high_value_num < lowest_valid_entry) 
				THEN
					drop_partition(p_table_name, part.PARTITION_NAME);
					--possibilidade de um print para um log de operaÃ§oes.
				END IF;
			END LOOP;
			
	CLOSE parts_cursor;
	--error catching
END;
/