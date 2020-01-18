--3D City Database extension for the Utility Network ADE Operation & 
--Maintenance Extension v. 5.6 (unom5); based on UN_ADE v. 0.9.2
--
--					  Federico Fossatti
--					University of Twente
--                     January 2020
--
-- 3D City Database: http://www.3dcitydb.org/ 
-- 
-- BASED ON THE WORK BY GIORGIO AGUGIARO FOR UN_ADE v. 0.9.2
-- https://github.com/gioagu/3dcitydb_utility_network_ade
--
-- ***************************************************************************
--
--ATTENTION, BEFORE RUNNING 'unom5' SCRIPTS:
--1) Create a new database in PostgreSQL
--2) Excecute PostGIS extension (and PostGIS raster extension too). 
--	Execute "CREATE EXTENSION IF NOT EXISTS "uuid-ossp";".
--3) Use 3DCityDB v. 3.3.1 to create CityGML database
--	3.1) Install:
--		https://www.3dcitydb.org/3dcitydb/fileadmin/downloaddata/3DCityDB-3.3.1.zip
--	3.2) Edit: 'CREATE_DB.bat', located at 
--		C:\Program Files\3DCityDB-Importer-Exporter\V3.3\3dcitydb\postgresql
--		Specify Host, Port, User, Password, Database and Bin
--	3.3) Run: CREATE_DB.bat, and enter SRID and SRS name
--4) Install the metadata module from 3DCityDB+
--	4.1) Retrieve: https://github.com/gioagu/3dcitydb_metadata_module
--	4.2) Edit: 'CREATE_DB_Metadata_module.bat' from download directory
--		Specify Host, Port, User, Password, Database and Bin
--	4.3) Run: CREATE_DB_Metadata_module.bat'
--5) unom5 has now all prerquisites to either run .bat or excecute SQL scripts
--manually from pgAdmin
--
-- ***************************************************************************
-- ************************** 01_unom5_FUNCTIONS.sql *************************
--
-- This script adds the stored procedures to the citydb_pkg schema.
-- They are all prefixed with "unom5_".
--
-- ***************************************************************************
-- ***************************************************************************
-- ***************************************************************************
-- ***************************************************************************
-- ***************************************************************************


-- ***************************************************************************
-- Contents
-- 		Function UNOM5_SET_ADE_COLUMN_SRID
-- 		Function UNOM5_CLEANUP_SCHEMA
-- 		Function UNOM5_INTERN_DELETE_CITYOBJECT
-- 		Function UNOM5_DELETE_CITYOBJECT 
-- 		Function UNOM5_GET_ENVELOPE_CITYOBJECT
-- ***************************************************************************


-- FF: The first two functions make sure that there is no info on the database and no previous installation of unom5.
--
-- A) Deletes all entries in the database. 
SELECT citydb_pkg.cleanup_schema('citydb');

-- B) Uninstall unom5 in case there is a previous installation with the same db_prefix
WITH a AS (
	SELECT id FROM citydb.ade WHERE db_prefix='unom5'
	)
SELECT citydb_pkg.drop_ade(a.id) FROM a; 


----------------------------------------------------------------
-- Function UNOM5_SET_ADE_COLUMN_SRID
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    citydb_pkg.unom5_set_ade_columns_srid(varchar);
CREATE OR REPLACE FUNCTION citydb_pkg.unom5_set_ade_columns_srid(
	schema_name varchar DEFAULT 'citydb'::varchar
)
RETURNS void AS $$
DECLARE
BEGIN
-- execute the stored procedure to set the srid of the new geometry columns
PERFORM citydb_pkg.change_ade_column_srid('unom5_network_feature', 'geom', 'GEOMETRYZ', schema_name);
PERFORM citydb_pkg.change_ade_column_srid('unom5_node', 'point_geom', 'POINTZ', schema_name);
PERFORM citydb_pkg.change_ade_column_srid('unom5_link', 'line_geom', 'LINESTRINGZ', schema_name);
PERFORM citydb_pkg.change_ade_column_srid('unom5_measured_depth', 'location_of_measurement', 'POINTZ', schema_name);

RAISE NOTICE 'Geometry columns of Utility Networks ADE set to current database SRID';
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.unom5_set_ade_columns_srid (schema: %): %', schema_name, SQLERRM;
END;
$$
LANGUAGE plpgsql;


----------------------------------------------------------------
-- Function UNOM5_CLEANUP_SCHEMA
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    citydb_pkg.unom5_cleanup_schema(varchar);
CREATE OR REPLACE FUNCTION citydb_pkg.unom5_cleanup_schema(
	schema_name varchar DEFAULT 'citydb'::varchar
)
RETURNS void AS $BODY$
DECLARE
BEGIN
---- Truncate the tables ----
-- LookUp
EXECUTE format('TRUNCATE TABLE %I.unom5_lu_network_class CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_lu_network_function_and_usage CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_lu_network_feature_class CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_lu_network_feature_function CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_lu_spatial_quality CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_lu_material CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_lu_status CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_lu_commodity_supply CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_lu_function_of_line CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_lu_signal_word CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_lu_optical_mode CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_lu_relative_to_terrain CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_lu_depth_point_of_measurement CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_lu_depth_reference_level CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_lu_depth_accuracy_value CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_lu_location_accuracy_value CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_lu_pipe_type CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_lu_cable_type CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_lu_party_role CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_lu_soil CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_lu_shape CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_lu_groundwater_reference CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_lu_identifier_type CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_lu_cost_type CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_lu_maintenance_timeline_type CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_lu_maintenance_activity_type CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_lu_maintenance_type CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_lu_performance_type CASCADE', schema_name);
-- Miscelaneous
EXECUTE format('TRUNCATE TABLE %I.unom5_storage CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_building CASCADE', schema_name);
--EXECUTE format('TRUNCATE TABLE %I.unom5_city_object CASCADE', schema_name); -- Deleted
EXECUTE format('TRUNCATE TABLE %I.unom5_role_in_network CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_dimensions CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_hollow_space CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_commodity_supply CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_commodity CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_commodity_classifier CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_comm_class_to_comm_class CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_network_feat_to_material CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_material CASCADE', schema_name);
-- Network Components
EXECUTE format('TRUNCATE TABLE %I.unom5_protective_element CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_pipe CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_cable CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_functional_component CASCADE', schema_name);
-- O&M specific
EXECUTE format('TRUNCATE TABLE %I.unom5_soil_and_groundwater CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_measured_depth CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_performance CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_impact CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_related_party_to_maintenance_activity CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_related_party_to_network_feature CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_related_party_to_network CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_related_party CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_network_feature_to_maintenance_activity CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_maintenance_activity CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_cost CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_identification CASCADE', schema_name);
-- Core module: Topology
EXECUTE format('TRUNCATE TABLE %I.unom5_node CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_link CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_feature_graph CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_network_graph CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_feature_graph_to_network_graph CASCADE', schema_name);
-- Core module: Geography          
EXECUTE format('TRUNCATE TABLE %I.unom5_network_to_network_feature CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_network_to_supply_area CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_network_to_network CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_network_feature CASCADE', schema_name);
EXECUTE format('TRUNCATE TABLE %I.unom5_network CASCADE', schema_name);                                   
---- Restart sequences ----
EXECUTE format('ALTER SEQUENCE %I.unom5_commodity_classifier_id_seq RESTART', schema_name);
EXECUTE format('ALTER SEQUENCE %I.unom5_commodity_id_seq RESTART', schema_name);
EXECUTE format('ALTER SEQUENCE %I.unom5_commodity_supply_id_seq RESTART', schema_name);
EXECUTE format('ALTER SEQUENCE %I.unom5_cost_id_seq RESTART', schema_name);
EXECUTE format('ALTER SEQUENCE %I.unom5_dimensions_id_seq RESTART', schema_name);
EXECUTE format('ALTER SEQUENCE %I.unom5_feature_graph_id_seq RESTART', schema_name);
EXECUTE format('ALTER SEQUENCE %I.unom5_hollow_space_id_seq RESTART', schema_name);
EXECUTE format('ALTER SEQUENCE %I.unom5_identification_id_seq RESTART', schema_name);
EXECUTE format('ALTER SEQUENCE %I.unom5_impact_id_seq RESTART', schema_name);
EXECUTE format('ALTER SEQUENCE %I.unom5_link_id_seq RESTART', schema_name);
EXECUTE format('ALTER SEQUENCE %I.unom5_maintenance_activity_id_seq RESTART', schema_name);
EXECUTE format('ALTER SEQUENCE %I.unom5_material_id_seq RESTART', schema_name);
EXECUTE format('ALTER SEQUENCE %I.unom5_measured_depth_id_seq RESTART', schema_name);
EXECUTE format('ALTER SEQUENCE %I.unom5_network_graph_id_seq RESTART', schema_name);
EXECUTE format('ALTER SEQUENCE %I.unom5_node_id_seq RESTART', schema_name);
EXECUTE format('ALTER SEQUENCE %I.unom5_performance_id_seq RESTART', schema_name);
EXECUTE format('ALTER SEQUENCE %I.unom5_related_party_id_seq RESTART', schema_name);
EXECUTE format('ALTER SEQUENCE %I.unom5_role_in_network_id_seq RESTART', schema_name);
EXECUTE format('ALTER SEQUENCE %I.unom5_soil_and_groundwater_id_seq RESTART', schema_name);
EXECUTE format('ALTER SEQUENCE %I.unom5_storage_id_seq RESTART', schema_name);
-- Finished, now call the standard clear_schema function(s).
EXCEPTION
    WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.unom5_cleanup_schema: %', SQLERRM;
END; 
$BODY$
  LANGUAGE plpgsql VOLATILE;


----------------------------------------------------------------
-- Function UNOM5_INTERN_DELETE_CITYOBJECT
----------------------------------------------------------------
-- FF: This function deletes the MEDIUM SUPPLY, ROLE IN NETWORK and INTERNAL UNOM5 CITY OBJECTS that are associated to a CityObject stored in the 3DCityDB table.
-- The intern city objects are deleted separately using vanilla "intern_delete_cityobject()"
DROP FUNCTION IF EXISTS citydb_pkg.unom5_intern_delete_cityobject(integer, varchar);
CREATE OR REPLACE FUNCTION citydb_pkg.unom5_intern_delete_cityobject(
	co_id integer,
	schema_name varchar DEFAULT 'citydb'::varchar
)
RETURNS void AS
$BODY$
DECLARE
	ms_id integer;
	unom5_co_id integer;
	rin_id integer;
	deleted_id integer;
BEGIN

--// START PRE DELETE ADE CITYOBJECT //--
-- delete all commodity_suppl(ies) related to this object
FOR ms_id IN EXECUTE format('SELECT id FROM %I.unom5_commodity_supply WHERE cityobject_id = %L', schema_name, co_id) LOOP
	IF ms_id IS NOT NULL THEN
		-- delete dependent commodity_supplies
		EXECUTE 'SELECT citydb_pkg.unom5_delete_commodity_supply($1, $2)' USING ms_id, schema_name; -- FF: changed ws_id to ms_id. I think it was a typo.
	END IF;
END LOOP;
-- NEW delete all unom5_city_object(s) related to this object. Deleted, 'unom5_city_objects' table is not necessary
--FOR unom5_co_id IN EXECUTE format('SELECT id FROM %I.unom5_city_object WHERE id = %L', schema_name, co_id) LOOP
--	IF unom5_co_id IS NOT NULL THEN
--		EXECUTE 'SELECT citydb_pkg.unom5_delete_city_object($1, $2)' USING unom5_co_id, schema_name;
--	END IF;
--END LOOP;
-- NEW delete all role(s)_in_network related to this object
FOR rin_id IN EXECUTE format('SELECT id FROM %I.unom5_role_in_network WHERE cityobject_id = %L', schema_name, co_id) LOOP
	IF rin_id IS NOT NULL THEN
		EXECUTE 'SELECT citydb_pkg.unom5_delete_role_in_network($1, $2)' USING rin_id, schema_name;
	END IF;
END LOOP;
--// END PRE DELETE ADE CITYOBJECT //--
-- NO NEED TO DELETE CITYOBJECT, it is taken care in the vanilla intern_delete_cityobject() function.
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.unom5_intern_delete_cityobject (id: %): %', co_id, SQLERRM;
END; 
$BODY$ LANGUAGE plpgsql VOLATILE;


----------------------------------------------------------------
-- Function UNOM5_DELETE_CITYOBJECT 
----------------------------------------------------------------
DROP FUNCTION IF EXISTS citydb_pkg.unom5_delete_cityobject(integer, integer, integer, varchar);
CREATE OR REPLACE FUNCTION citydb_pkg.unom5_delete_cityobject(
	co_id integer,
	delete_members integer DEFAULT 0,
	cleanup integer DEFAULT 0,	-- doesn't do anything
	schema_name varchar DEFAULT 'citydb'::text)
  RETURNS integer AS
$BODY$
DECLARE
	class_id INTEGER;
	classname varchar;
	deleted_id INTEGER;
BEGIN
EXECUTE format('SELECT objectclass_id FROM %I.cityobject WHERE id=%L', schema_name, co_id) INTO class_id;
EXECUTE format('SELECT citydb_pkg.get_classname(%L,%L)', class_id, schema_name) INTO classname;
--RAISE NOTICE 'class id %, classname %',class_id, classname;
-- classname can be NULL if object has already been deleted
IF classname IS NOT NULL THEN
  CASE
    WHEN classname = 'Network'        THEN deleted_id := citydb_pkg.unom5_delete_network(co_id, schema_name);
    WHEN classname = 'SupplyArea'     THEN deleted_id := citydb_pkg.unom5_delete_supply_area(co_id, delete_members, schema_name);
    WHEN classname IN 
				('ElectricityCable', 'TelecommunicationCable', 'OilGasChemicalsPipe', 'WaterPipe', 'ThermalPipe', 'SewerPipe',  -- concrete distribution elements
				'Bedding', 'ProtectiveShell', 'RectangularShell', 'RoundShell', 'OtherShell', 									-- concrete protective elements 
				'ComplexFunctionalComponent', 'SimpleFunctionalComponent', 'ConnectionComponent', 'MeasurementComponent',		-- concrete functional element 1/2
				'StorageComponent', 'TerminalComponent', 'ControllerComponent', 'OtherComponent') 								-- concrete functional element 2/2
			THEN deleted_id := citydb_pkg.unom5_delete_network_feature(co_id, schema_name);
    ELSE
     RAISE NOTICE 'Cannot delete chosen object with ID % and classname %', co_id, classname;
  END CASE;
END IF;
RETURN deleted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.unom5_delete_cityobject (id: %): %', co_id, SQLERRM;
END; 
$BODY$ LANGUAGE plpgsql;


----------------------------------------------------------------
-- Function UNOM5_GET_ENVELOPE_CITYOBJECT
----------------------------------------------------------------
DROP FUNCTION IF EXISTS citydb_pkg.unom5_get_envelope_cityobject(integer, integer, integer, varchar);
CREATE OR REPLACE FUNCTION citydb_pkg.unom5_get_envelope_cityobject(
	co_id integer,
	objclass_id integer DEFAULT 0,  -- not used anymore, but kept for compatibility
	set_envelope integer DEFAULT 0,
	schema_name varchar DEFAULT 'citydb'::varchar)
  RETURNS geometry AS
$BODY$
DECLARE
	class_id INTEGER;
	classname varchar;
	envelope GEOMETRY;
BEGIN
EXECUTE format('SELECT objectclass_id FROM %I.cityobject WHERE id=%L', schema_name, co_id) INTO class_id;
EXECUTE format('SELECT citydb_pkg.get_classname(%L,%L)', class_id, schema_name) INTO classname;
-- class_name can be NULL if object has already been deleted
IF classname IS NOT NULL THEN
	CASE
		WHEN classname = 'Network'    THEN envelope := citydb_pkg.unom5_get_envelope_network(co_id, set_envelope, schema_name);
		WHEN classname = 'SupplyArea' THEN envelope := citydb_pkg.unom5_get_envelope_supply_area(co_id, set_envelope, 1, schema_name);
		WHEN classname IN 
				('ElectricityCable', 'TelecommunicationCable', 'OilGasChemicalsPipe', 'WaterPipe', 'ThermalPipe', 'SewerPipe',  -- concrete distribution elements
				'Bedding', 'ProtectiveShell', 'RectangularShell', 'RoundShell', 'OtherShell', 									-- concrete protective elements 
				'ComplexFunctionalComponent', 'SimpleFunctionalComponent', 'ConnectionComponent', 'MeasurementComponent',		-- concrete functional element 1/2
				'StorageComponent', 'TerminalComponent', 'ControllerComponent', 'OtherComponent') 								-- concrete functional element 2/2
		  THEN envelope := citydb_pkg.unom5_get_envelope_network_feature(co_id, set_envelope, schema_name);
	ELSE
		RAISE NOTICE 'Cannot get envelope of object with ID % class_name %', co_id, classname;
	END CASE;
END IF;
RETURN envelope;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.unom5_get_envelope_cityobject (id: %): %', co_id, SQLERRM;
END;
$BODY$
LANGUAGE plpgsql VOLATILE;

-- ***********************************************************************
-- ***********************************************************************

DO
$$
BEGIN
RAISE NOTICE '

********************************

Utility Network ADE O&M functions installation complete!

********************************

';
END
$$;
SELECT 'Utility Network ADE O&M functions installation complete!'::varchar AS installation_result;

-- ***********************************************************************
-- ***********************************************************************
--
-- END OF FILE
--
-- ***********************************************************************
-- ***********************************************************************