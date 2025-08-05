--functions part 1

--long_to_number
--max_longs
--is_table_partitioned
--field_name_f
--trataDias
--trataMes
--trataAno
--trataSemana



--|	 Conversor de long type 	|
--|	para number para tratamento |
--|								|
--|	AUTOR: Guilherme Dias		|

CREATE OR REPLACE FUNCTION long_to_number(p_long IN LONG)
RETURN NUMBER
IS
  	long_to_char VARCHAR2(4000);
	char_to_num NUMBER;
BEGIN
		long_to_char := SUBSTR(p_long, 1, 4000);       
        char_to_num := to_number(long_to_char);
		RETURN char_to_num;
  
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END long_to_number;
/

--|	funcao que retorna max 	|
--| de coluna de longs		|
--|	AUTOR: Guilherme Dias	|

CREATE OR REPLACE FUNCTION max_longs(
	p_table_name VARCHAR2,
	p_table_owner  VARCHAR2
)RETURN NUMBER
IS
    v_max_value   NUMBER := -1; -- Inicialize com um valor muito baixo
    v_current_value NUMBER;
BEGIN

    FOR rec IN (
        SELECT HIGH_VALUE
        FROM all_tab_partitions
        WHERE TABLE_OWNER = p_table_owner
          AND TABLE_NAME = p_table_name
    ) LOOP
        BEGIN
            v_current_value := long_to_number(rec.HIGH_VALUE);
            IF v_current_value > v_max_value THEN
                v_max_value := v_current_value;
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
    END LOOP;
	RETURN v_max_value;
END max_longs;
/

--|	funcao que distingue tabela particionada e simples		|
--|	Return: 'T' se particionada, 'F' caso contrario			|
--|				AUTOR: Guilherme Dias									|

CREATE OR REPLACE FUNCTION is_table_partitioned (
    p_table_name  IN VARCHAR2,
    p_table_owner IN VARCHAR2
) RETURN VARCHAR2 
IS 
    partitions_num NUMBER;
    retorno        VARCHAR2(1);
BEGIN
    SELECT COUNT(*)
    INTO partitions_num
    FROM all_tab_partitions
    WHERE table_name = p_table_name
    AND table_owner = p_table_owner;	
	

    IF partitions_num > 0 THEN
        retorno := 'T'; -- A tabela eh particionada
    ELSE
        retorno := 'F'; -- A tabela nao eh particionada
    END IF;
    
    RETURN retorno; -- Retorno final
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'F';
END is_table_partitioned;
/
		
--|	Retorna nome da coluna 										|
--|	com base no campo em parametro								|
--|	AUTOR: Guilherme Dias										|
--|	Requires:	p_periodo_tempo == 'D' ou 'S' ou 'M' ou 'A'		|

CREATE OR REPLACE FUNCTION field_name_f(
	p_periodo_tempo  IN VARCHAR2
) RETURN VARCHAR2
IS 
	field_name VARCHAR2(100);
BEGIN
    CASE UPPER(p_periodo_tempo)
        WHEN 'D' THEN	
			field_name := 'COD_DIA';
		WHEN 'S' THEN
			field_name := 'COD_SEMANA';
        WHEN 'M' THEN
			field_name := 'COD_MES'; 
        WHEN 'A' THEN
			field_name := 'COD_ANO';
        ELSE															
            RAISE_APPLICATION_ERROR(-20002, 'PerÃƒÂ­odo de tempo invÃƒÂ¡lido: ' || p_periodo_tempo);
    END CASE;
	  RETURN field_name;

END field_name_f;
/


--|	Retorna ultima data valida  			|
--|	com coluna de anos						|
--|	AUTOR: Guilherme Dias					|
--|	DEPENDENCIAS:	p_ano do tipo YYYY		|

CREATE OR REPLACE FUNCTION trataAno(		
	p_ano IN NUMBER,
	p_perio_histor IN NUMBER 
) RETURN NUMBER 
IS n_ano NUMBER;
BEGIN
    n_ano := p_ano - (p_perio_histor - 1);
	RETURN n_ano;
END trataAno;
/


--|	Retorna ultima data valida  			|
--|	com coluna de meses						|
--|	AUTOR: Guilherme Dias					|
--|	DEPENDENCIAS:	p_ano do tipo YYYYMM	|

CREATE OR REPLACE FUNCTION trataMes(
    p_data IN NUMBER,
    p_perio_histor IN NUMBER
) RETURN NUMBER 
IS
    v_data DATE;
    v_result DATE;
BEGIN
    v_data := TO_DATE(TO_CHAR(p_data), 'YYYYMM');
    v_result := ADD_MONTHS(v_data, (- p_perio_histor + 1));
    RETURN TO_NUMBER(TO_CHAR(v_result, 'YYYYMM'));
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'Erro ao calcular o mes: ' || SQLERRM);
END trataMes;
/

--|	Retorna ultima data valida  			|
--|	com coluna de dias						|
--|	AUTOR: Guilherme Dias					|
--|	DEPENDENCIAS:	p_ano do tipo YYYYMMDD	|

CREATE OR REPLACE FUNCTION trataDia(
    p_data IN NUMBER,
    p_perio_histor IN NUMBER
) RETURN NUMBER 
IS
    v_data DATE;
    v_result DATE;
BEGIN
    v_data := TO_DATE(p_data, 'YYYYMMDD');
    v_result := v_data - p_perio_histor + 1;
    RETURN TO_NUMBER(TO_CHAR(v_result, 'YYYYMMDD'));
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'Erro ao calcular a data: ' || SQLERRM);
END trataDia;
/


--|	Retorna ultima data valida  			|
--|	com coluna de semanas					|
--|	AUTOR: Guilherme Dias					|
--|	DEPENDENCIAS:	p_ano do tipo YYYYWW	|

CREATE OR REPLACE FUNCTION trataSemana (
    p_data  	   IN NUMBER,
    p_perio_histor IN NUMBER
) RETURN NUMBER
IS
    final_cod_semana NUMBER;
    sql_sel	VARCHAR2(1000);
BEGIN
    sql_sel := 'WITH filtered_tab AS (
                    SELECT COD_SEMANA, ROW_NUMBER() OVER (ORDER BY COD_SEMANA DESC) row_num
                    FROM gcn_prt_rrp.dmr_ref_semana
                    WHERE COD_SEMANA <= ' || p_data || '
                )
                SELECT COD_SEMANA
                FROM filtered_tab
                WHERE row_num = ' || p_perio_histor;

    EXECUTE IMMEDIATE sql_sel INTO final_cod_semana;

    RETURN final_cod_semana;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    WHEN OTHERS THEN
        RAISE;
END trataSemana;
/