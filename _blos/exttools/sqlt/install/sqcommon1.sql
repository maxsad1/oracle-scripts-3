REM $Header: 215187.1 sqcommon1.sql 12.1.05 2013/12/11 carlos.sierra mauro.pagano $

WHENEVER SQLERROR EXIT SQL.SQLCODE;

-- set rdbms_version
VAR rdbms_release NUMBER;
VAR rdbms_version VARCHAR2(17);
DECLARE
  dot1 NUMBER;
  dot2 NUMBER;
BEGIN
  EXECUTE IMMEDIATE 'SELECT version FROM v$instance' INTO :rdbms_version;
  dot1 := INSTR(:rdbms_version, '.');
  dot2 := INSTR(:rdbms_version, '.', dot1 + 1);
  :rdbms_release :=
  TO_NUMBER(SUBSTR(:rdbms_version, 1, dot1 - 1)) +
  (TO_NUMBER(SUBSTR(:rdbms_version, dot1 + 1, dot2 - dot1 - 1)) / POWER(10, (dot2 - dot1 - 1)));
  IF :rdbms_release < 10 OR :rdbms_version < '10.2' THEN
    RAISE_APPLICATION_ERROR(-20200, 'SQLT installation failed. Install in 10.2 or higher, not in '||:rdbms_release);
  END IF;
END;
/
PRINT rdbms_release;
PRINT rdbms_version;

-- use NATIVE or INTERPRETED (NATIVE performs better. INTERPRETED avoids some errors in some systems.)
COL plsql_code_type NEW_V plsql_code_type;
SELECT CASE WHEN :rdbms_version BETWEEN '11' AND '20' THEN 'NATIVE' ELSE 'INTERPRETED' END plsql_code_type FROM DUAL;
--DEF plsql_code_type = 'INTERPRETED';

-- begin common
SET TERM OFF;

WHENEVER SQLERROR CONTINUE;

SELECT USER FROM DUAL;
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') current_time FROM DUAL;
SELECT * FROM product_component_version;
SELECT * FROM v$version;
SELECT * FROM v$instance;
SELECT name, value FROM v$parameter2 WHERE name LIKE '%dump_dest';
SELECT directory_name||' '||directory_path directories FROM sys.dba_directories WHERE directory_name LIKE 'SQLT$%' OR directory_name LIKE 'TRCA$%' ORDER BY 1;

DEF _SQLPLUS_RELEASE

SHO parameters NLS
SHO parameters PLSQL
SHO parameters OPTIMIZER
SHO parameters DUMP_DEST

DEF tool_repository_schema = 'SQLTXPLAIN';
DEF tool_administer_schema = 'SQLTXADMIN';
DEF tool_version           = '12.1.05';
DEF tool_date              = '2013-12-11';
DEF tool_note              = '215187.1';
DEF tool_name              = 'SQLT';
DEF role_name              = 'SQLT_USER_ROLE';
-- tool trace level: 1, 4, 8, 12
DEF tool_trace             = '8';
DEF temporary_or_permanent = 'T';

ALTER SESSION SET PLSQL_CODE_TYPE = &&plsql_code_type;
ALTER SESSION SET NLS_LENGTH_SEMANTICS = CHAR;

WHENEVER SQLERROR EXIT SQL.SQLCODE;
SET ECHO OFF TERM ON;

BEGIN
  IF USER <> 'SYS' THEN
    RAISE_APPLICATION_ERROR(-20100, 'SQLT packages creation failed. Connect as SYS, not as '||USER);
  END IF;
END;
/

SET TERM OFF;

-- need to set "skip_if_prior_to_112" so we can comment out code lines that would fail on releases prior to 11.2
-- this variable gets a value of NULL if executed on 11.2 or higher, but it becomes a comment if executed on pre 11.2
COL skip_if_prior_to_112 NEW_V skip_if_prior_to_112;
SELECT '-- skip_if_prior_to_112: ' skip_if_prior_to_112 FROM DUAL WHERE :rdbms_version < '11.2';

DEF
-- end common
