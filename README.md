PSQL Cleanup Automation – MEO Internship Project

This project automates the cleanup of registry tables in OracleDB using PostgreSQL scripting, developed during my internship at MEO (Altice Portugal – B2B Segment Management). It dynamically deletes outdated entries based on customizable rules such as storage limits and record age, adapting to different table update frequencies (daily, weekly, monthly).

---

Key Features

- Automatic deletion of older rows from registry tables
- Dynamic rules based on time or amount of data to retain
- Support for multiple update intervals (daily, weekly, monthly)
- Handling of partitioned tables and index partitions
- Formatted in Portuguese.

Compile in the following order:

-- 1. functions1_GH
-- 2. functions2_GH
-- 3. functions3_GH
-- 4. procedure_principal_GH
-- 5. CTRL_HIST_TABELAS
-- 6. procedure_recorrente_GH
