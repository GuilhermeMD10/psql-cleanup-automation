--Controlo de Historico de Dados


--|	Procedure de recorrencia que itera sobre o procedure   |
--|	GESTAO_HISTORICO tantas vezes quanto numero de colunas |
--| na tabela com nome == TABLE_NAME					   |
--|					AUTOR: Guilherme Dias				   |
CREATE OR REPLACE PROCEDURE RECORRENCIA_HISTORICO AS
    CURSOR c_config IS
        SELECT TABLE_NAME, PERIODO_HIST, PERIODO_TEMPO, TABLE_OWNER, FLAG_ATIVO
        FROM CTRL_HIST_TABELAS;
        
        c_row c_config%ROWTYPE;	
BEGIN
    OPEN c_config;
			LOOP
				FETCH c_config INTO c_row;
				EXIT WHEN c_config%NOTFOUND;
                    GESTAO_HISTORICO(
                    c_row.TABLE_OWNER,
                    c_row.TABLE_NAME,
                    c_row.PERIODO_HIST,
                    c_row.PERIODO_TEMPO,
                    c_row.FLAG_ATIVO
                    );
			END LOOP;
			
	CLOSE c_config;
END RECORRENCIA_HISTORICO;
/


