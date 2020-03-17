REM Shell script to install the Utility Network ADE Operation & Maintenance for the 3DCityDB
REM on PostgreSQL/PostGIS

REM Provide your database details here
set PGPORT=5432
set PGHOST=localhost
set PGUSER=postgres
set CITYDB=Test6_UOM_058
set PGBIN=C:\Program Files\PostgreSQL\12\bin

REM cd to path of the shell script
cd /d %~dp0

REM Run INSTALL_Utility_Network_ADE_O&M.sql to install the Utility Network ADE Operation & Maintenance extension into the 3DCityDB instance
REM "%PGBIN%\psql" -h %PGHOST% -p %PGPORT% -d "%CITYDB%" -U %PGUSER% -c "ALTER DATABASE "%CITYDB%" SET search_path TO citydb, citydb_pkg, public" FF: does not work due to capitalization! Do it manually from the query tool.
"%PGBIN%\psql" -h %PGHOST% -p %PGPORT% -d "%CITYDB%" -U %PGUSER% -f "INSTALL_Utility_Network_ADE_O&M.sql"
pause