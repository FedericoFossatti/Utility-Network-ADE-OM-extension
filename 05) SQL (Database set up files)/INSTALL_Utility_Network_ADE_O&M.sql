-- This script is called from CREATE_DB_UtilityNetwork_ADE_O&M.bat
\pset footer off
SET client_min_messages TO WARNING;
\set ON_ERROR_STOP ON

\echo
\echo 'Installing the UtilityNetwork ADE Operation & Maintenance general functions'
\i postgresql/01_uom5_FUNCTIONS.sql

\echo
\echo 'Installing the UtilityNetwork ADE Operation & Maintenance DML functions'
\i postgresql/02_uom5_DML_FUNCTIONS.sql

\echo
\echo 'Installing the UtilityNetwork ADE Operation & Maintenance tables'
\i postgresql/03_uom5_TABLES.sql

\echo
\echo 'Installing the UtilityNetwork ADE Operation & Maintenance table data'
\i postgresql/05_uom5_TABLE_DATA.sql

\echo
\echo 'Installing the UtilityNetwork ADE Operation & Maintenance views'
\i postgresql/06_uom5_VIEWS.sql



\echo
\echo '***********************************************************'
\echo
\echo 'Installation of UtilityNetwork ADE Operation & Maintenance extension for 3DCityDB complete!'
\echo
\echo '***********************************************************'
\echo