--functions part 2

--first_entry_calc
--lowest_valid_entry_f


--|	Retorna primeira entrada na tabela  		|
--|	passada por parametro						|
--|	AUTOR: Guilherme Dias						|
--|	DEPENDENCIAS:	funcao max_longs compilada  |

create or replace FUNCTION first_entry_calc(
        p_table_name    IN VARCHAR2,
        p_table_owner   IN VARCHAR2,
        p_field_name    IN VARCHAR2,
        is_partitioned  IN VARCHAR2
) RETURN NUMBER
IS
    first_entry NUMBER;
    sql_max VARCHAR2(1000); 

    v_code  NUMBER;
    v_errm  VARCHAR2(64);
BEGIN
    CASE is_partitioned
        WHEN 'F' THEN
            sql_max := 'SELECT MAX(' || p_field_name || ') FROM ' || p_table_name;	
            EXECUTE IMMEDIATE sql_max INTO first_entry;
        WHEN 'T' THEN
            first_entry := max_longs(p_table_name, p_table_owner);
    END CASE;

    RETURN first_entry;
EXCEPTION
    WHEN OTHERS THEN
    RETURN NULL;
END first_entry_calc;
/


--|	Retorna ultima data valida  				|
--|	com coluna == field_name(p_periodo_tempo)	|
--|	AUTOR: Guilherme Dias						|
--|	DEPENDENCIAS:	funcoes: trataDia, trataMes, trataSemana, trataAno	compiladas	|

CREATE OR REPLACE FUNCTION lowest_valid_entry_f(
	first_entry  	IN NUMBER,
	p_periodo_hist  IN NUMBER,
	p_periodo_tempo IN VARCHAR2
) RETURN NUMBER 
IS 
	lowest_valid_entry NUMBER;

BEGIN
	--Logic cases to dispose or not each entry
    CASE p_periodo_tempo
        WHEN 'D' THEN	--
            lowest_valid_entry := trataDia(first_entry, p_periodo_hist);
        WHEN 'S' THEN
			lowest_valid_entry := trataSemana(first_entry, p_periodo_hist);
        WHEN 'M' THEN
            lowest_valid_entry := trataMes(first_entry, p_periodo_hist);
        WHEN 'A' THEN
            lowest_valid_entry := trataAno(first_entry, p_periodo_hist);
        ELSE															
            RAISE_APPLICATION_ERROR(-20002, 'PerÃ­odo de tempo invÃ¡lido: ' || p_periodo_tempo);
    END CASE;
	  RETURN lowest_valid_entry;

END lowest_valid_entry_f;
/
