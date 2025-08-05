

--|	Procedure principal que calcula    							|
--|	e realiza a delecao de linhas ou particoes					|
--|	com base nos parametros p_periodo_hist e p_periodo_tempo	|
--|					AUTOR: Guilherme Dias						|
CREATE OR REPLACE PROCEDURE GESTAO_HISTORICO(
		p_table_owner  	   IN VARCHAR2,
		p_table_name       IN VARCHAR2,
		p_periodo_hist     IN NUMBER,
		p_periodo_tempo    IN VARCHAR2,
		p_flag_val		   IN VARCHAR2
) IS
		first_entry 		NUMBER;	
		lowest_valid_entry  NUMBER; -- last valid value to remain in bd
		is_partitioned 		VARCHAR2(1);
		field_name			VARCHAR2(100);
	BEGIN						
	IF (p_flag_val = '1') THEN
		is_partitioned := is_table_partitioned(p_table_name, p_table_owner);	--check se tabela eh particionada
		
		--TODO if table is not partitioned
		IF is_partitioned = 'F' THEN	
			field_name := field_name_f(p_periodo_tempo);	--captura de nome da coluna a usar

			first_entry := first_entry_calc(p_table_name, p_table_owner, field_name, is_partitioned);	--calculo do elemento mais recente na tabela
							
			IF first_entry IS NULL THEN
				RAISE_APPLICATION_ERROR(-20001, 'No data found in table ' || p_table_name);
			END IF;
			lowest_valid_entry := lowest_valid_entry_f(first_entry, p_periodo_hist, p_periodo_tempo);	--calculo do ultimo elemento a permanecer na tabela

			delete_rows(p_table_name, field_name, lowest_valid_entry);	--processo de deleção de linhas que nao sao consideradas válida
			
		--TODO if table is partitioned
		ELSE
			field_name := 'HIGH_VALUE';	--atribuiçao assumida de coluna HIGH_VALUE quando particionada
			first_entry := first_entry_calc(p_table_name, p_table_owner, field_name, is_partitioned); --calculo do elemento mais recente na tabela
			
			IF first_entry IS NULL THEN
				RAISE_APPLICATION_ERROR(-20001, 'No data found in table ' || p_table_name);
			END IF;
		
			lowest_valid_entry := lowest_valid_entry_f(first_entry, p_periodo_hist, p_periodo_tempo);	--calculo do ultimo elemento a permanecer na tabela

			partition_drop_logic(p_table_name, p_table_owner, lowest_valid_entry);	--processo de deleção de partiçoes que nao sao consideradas validas
		END IF;
	END IF;
END GESTAO_HISTORICO;