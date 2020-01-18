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
--See notes on file 01_unom5_FUNCTIONS.
--
-- ***************************************************************************
-- ************************** 03_unom5_TABLES.sql ****************************
--
-- This script creates all Utility Network O&M tables in the citydb 
-- schema. All new tables are prefixed with "unom5".
-- At the end, the function citydb_pkg.unom5.set_ade_columns_srid() is executed
-- to set the SRID of the newly added geometry columns.
--
-- ***************************************************************************
-- ***************************************************************************
-- ***************************************************************************
-- ***************************************************************************
-- ***************************************************************************


-- ***************************************************************************
--Contents: tables and foreign keys
-- A1) ORIGINAL LOOK UP TABLES (CODELISTS AND ENUMERATIONS)
--		unom5_lu_network_class
--		unom5_lu_network_function_and_usage
--		unom5_lu_network_feature_class
--		unom5_lu_network_feature_function
--		unom5_lu_spatial_quality
--		unom5_lu_material
--		unom5_lu_status
--		unom5_lu_commodity_supply
--		unom5_lu_function_of_line
--		unom5_lu_signal_word
-- A2) NEW LOOK UP TABLES FOR O&M EXTENSION
--		unom5_lu_optical_mode
--		unom5_lu_relative_to_terrain
--		unom5_lu_depth_point_of_measurement
--		unom5_lu_depth_reference_level
--		unom5_lu_depth_accuracy_value
--		unom5_lu_location_accuracy_value
--		unom5_lu_pipe_type
--		unom5_lu_cable_type
--		unom5_lu_party_role
--		unom5_lu_soil
--		unom5_lu_shape
--		unom5_lu_groundwater_reference
--		unom5_lu_identifier_type
--		unom5_lu_cost_type
--		unom5_lu_maintenance_timeline_type
--		unom5_lu_maintenance_activity_type
--		unom5_lu_maintenance_type
--		unom5_lu_performance_type
-- B1) ORIGINAL MAIN TABLES (UML featureTypes, dataTypes, relations and geometries)
--		unom5_network
--		unom5_network_to_network
--		unom5_network_to_supply_area
--		unom5_network_feature
--		unom5_cable
--		unom5_pipe
--		unom5_protective_element
--		unom5_network_to_network_feature
--		unom5_network_graph
--		unom5_feature_graph
--		unom5_node
--		unom5_link
--		unom5_building
--		unom5_commodity_supply
--		unom5_storage
--		unom5_role_in_network
--		unom5_commodity
--		unom5_commodity_classifier
--		unom5_comm_class_to_comm_class
--		unom5_network_feat_to_material
--		unom5_hollow_space
-- B2) NEW MAIN TABLES FOR O&M EXTENSION
--		unom5_feature_graph_to_network_graph
--		unom5_measured_depth
--		unom5_city_object
--		unom5_functional_component
--		unom5_related_party
--		unom5_address
--		unom5_related_party_to_network
--		unom5_related_party_to_network_feature
--		unom5_related_party_to_maintenance_activity
--		unom5_soil_and_groundwater
--		unom5_maintenance_activity
--		unom5_network_feature_to_maintenance_activity
--		unom5_cost
--		unom5_impact
--		unom5_performance
--		unom5_dimensions
--		unom5_identification
-- C) FOREIGN KEY(S) CONSTRAINTS ON MAIN TABLES

-- ***************************************************************************


-- A1) ORIGINAL LOOK UP TABLES (CODELISTS AND ENUMERATIONS)

----------------------------------------------------------------
-- Table LU_NETWORK_CLASS
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_lu_network_class CASCADE;
CREATE TABLE         citydb.unom5_lu_network_class (
	id                   varchar PRIMARY KEY,
	name                 varchar,
	name_codespace       varchar,
	description          text
);
CREATE INDEX unom5_lu_ntw_class_name_inx ON citydb.unom5_lu_network_class USING btree (name, name_codespace);

----------------------------------------------------------------
-- Table LU_NETWORK_FUNCTION_AND_USAGE
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_lu_network_function_and_usage CASCADE;
CREATE TABLE         citydb.unom5_lu_network_function_and_usage (
	id                   varchar PRIMARY KEY,
	name                 varchar,
	name_codespace       varchar,
	description          text
);
CREATE INDEX unom5_lu_ntw_function_and_usage_name_inx ON citydb.unom5_lu_network_function_and_usage USING btree (name, name_codespace);

----------------------------------------------------------------
-- Table LU_NETWORK_FEATURE_CLASS
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_lu_network_feature_class CASCADE;
CREATE TABLE         citydb.unom5_lu_network_feature_class (
	objectclass_id       integer NOT NULL,	 --FK citydb.objectclass (id)
	id                   varchar NOT NULL,
	name                 varchar,
	name_codespace       varchar,
	description          text,
	PRIMARY KEY (objectclass_id, id)
);
CREATE INDEX unom5_lu_ntw_feat_class_objclass_id_fkx ON citydb.unom5_lu_network_feature_class USING btree (objectclass_id);
CREATE INDEX unom5_lu_ntw_feat_class_name_inx        ON citydb.unom5_lu_network_feature_class USING btree (name, name_codespace);

----------------------------------------------------------------
-- Table LU_NETWORK_FEATURE_FUNCTION
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_lu_network_feature_function CASCADE;
CREATE TABLE         citydb.unom5_lu_network_feature_function (
	id                   varchar PRIMARY KEY,
	name                 varchar,
	name_codespace       varchar,
	description          text
);
CREATE INDEX unom5_lu_ntw_feat_function_name_inx ON citydb.unom5_lu_network_feature_function USING btree (name, name_codespace);

----------------------------------------------------------------
-- Table LU_SPATIAL_QUALITY
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_lu_spatial_quality CASCADE;
CREATE TABLE         citydb.unom5_lu_spatial_quality (
	id                   varchar PRIMARY KEY,
	name                 varchar,
	name_codespace       varchar,
	description          text
);
CREATE INDEX unom5_lu_spat_qual_name_inx ON citydb.unom5_lu_spatial_quality USING btree (name, name_codespace);

----------------------------------------------------------------
-- Table LU_MATERIAL
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_lu_material CASCADE;
CREATE TABLE         citydb.unom5_lu_material (
	id                   varchar PRIMARY KEY,
	name                 varchar,
	name_codespace       varchar,
	description          text
);
CREATE INDEX unom5_lu_material_name_inx ON citydb.unom5_lu_material USING btree (name, name_codespace);

----------------------------------------------------------------
-- Table LU_STATUS
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_lu_status CASCADE;
CREATE TABLE         citydb.unom5_lu_status (
	id                   varchar PRIMARY KEY,
	name                 varchar,
	name_codespace       varchar,
	description          text
);
CREATE INDEX unom5_lu_status_name_inx ON citydb.unom5_lu_status USING btree (name, name_codespace);

----------------------------------------------------------------
-- Table LU_COMMODITY_SUPPLY
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_lu_commodity_supply CASCADE;
CREATE TABLE         citydb.unom5_lu_commodity_supply (
	objectclass_id       integer NOT NULL,		--FK citydb.objectclass (id)
	id                   varchar NOT NULL,
	name                 varchar,
	name_codespace       varchar,
	description          text,
	PRIMARY KEY (objectclass_id, id)
);
CREATE INDEX unom5_lu_commodity_supply_objclass_id_fkx ON citydb.unom5_lu_commodity_supply USING btree (objectclass_id);
CREATE INDEX unom5_lu_commodity_supply_inx             ON citydb.unom5_lu_commodity_supply USING btree (name, name_codespace);

----------------------------------------------------------------
-- Table LU_FUNCTION_OF_LINE
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_lu_function_of_line CASCADE;
CREATE TABLE         citydb.unom5_lu_function_of_line (
	id                   varchar PRIMARY KEY,
	name                 varchar,
	name_codespace       varchar,
	description          text
);
CREATE INDEX unom5_lu_function_of_line_name_inx ON citydb.unom5_lu_function_of_line USING btree (name, name_codespace);

----------------------------------------------------------------
-- Table LU_SIGNAL_WORD
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_lu_signal_word CASCADE;
CREATE TABLE         citydb.unom5_lu_signal_word (
	id                   varchar PRIMARY KEY,
	name                 varchar,
	name_codespace       varchar,
	description          text
);
CREATE INDEX unom5_lu_signal_word_name_inx ON citydb.unom5_lu_signal_word USING btree (name, name_codespace);

-- ******************************************************************************************************************************************************************************************************************************
-- ******************************************************************************************************************************************************************************************************************************
-- A2) NEW LOOK UP TABLES FOR O&M EXTENSION

----------------------------------------------------------------
-- Table LU_OPTICAL_MODE
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_lu_optical_mode CASCADE;
CREATE TABLE         citydb.unom5_lu_optical_mode (
	id                   varchar PRIMARY KEY,
	name                 varchar,
	name_codespace       varchar,
	description          text
);
CREATE INDEX unom5_lu_optical_mode_name_inx ON citydb.unom5_lu_optical_mode USING btree (name, name_codespace);

----------------------------------------------------------------
-- Table LU_RELATIVE_TO_TERRAIN
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_lu_relative_to_terrain CASCADE;
CREATE TABLE         citydb.unom5_lu_relative_to_terrain (
	id                   varchar PRIMARY KEY,
	name                 varchar,
	name_codespace       varchar,
	description          text
);
CREATE INDEX unom5_lu_relative_to_terrain_name_inx ON citydb.unom5_lu_relative_to_terrain USING btree (name, name_codespace);

----------------------------------------------------------------
-- Table LU_DEPTH_POINT_OF_MEASUREMENT
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_lu_depth_point_of_measurement CASCADE;
CREATE TABLE         citydb.unom5_lu_depth_point_of_measurement (
	id                   varchar PRIMARY KEY,
	name                 varchar,
	name_codespace       varchar,
	description          text
);
CREATE INDEX unom5_lu_depth_point_of_measurement_name_inx ON citydb.unom5_lu_depth_point_of_measurement USING btree (name, name_codespace);

----------------------------------------------------------------
-- Table LU_DEPTH_REFERENCE_LEVEL
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_lu_depth_reference_level CASCADE;
CREATE TABLE         citydb.unom5_lu_depth_reference_level (
	id                   varchar PRIMARY KEY,
	name                 varchar,
	name_codespace       varchar,
	description          text
);
CREATE INDEX unom5_lu_depth_reference_level_name_inx ON citydb.unom5_lu_depth_reference_level USING btree (name, name_codespace);

----------------------------------------------------------------
-- Table LU_DEPTH_ACCURACY VALUE
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_lu_depth_accuracy_value CASCADE;
CREATE TABLE         citydb.unom5_lu_depth_accuracy_value (
	id                   varchar PRIMARY KEY,
	name                 varchar,
	name_codespace       varchar,
	description          text
);
CREATE INDEX unom5_lu_depth_accuracy_value_name_inx ON citydb.unom5_lu_depth_accuracy_value USING btree (name, name_codespace);

----------------------------------------------------------------
-- Table LU_LOCATION_ACCURACY VALUE
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_lu_location_accuracy_value CASCADE;
CREATE TABLE         citydb.unom5_lu_location_accuracy_value (
	id                   varchar PRIMARY KEY,
	name                 varchar,
	name_codespace       varchar,
	description          text
);
CREATE INDEX unom5_lu_location_accuracy_value_name_inx ON citydb.unom5_lu_location_accuracy_value USING btree (name, name_codespace);

----------------------------------------------------------------
-- Table LU_PIPE_TYPE
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_lu_pipe_type CASCADE;
CREATE TABLE         citydb.unom5_lu_pipe_type (
	objectclass_id       integer NOT NULL,		--FK citydb.objectclass (id)
	id                   varchar NOT NULL,
	name                 varchar,
	name_codespace       varchar,
	description          text,
	PRIMARY KEY (objectclass_id, id)
);
CREATE INDEX unom5_lu_pipe_type_objclass_id_fkx ON citydb.unom5_lu_pipe_type USING btree (objectclass_id);
CREATE INDEX unom5_lu_pipe_type_inx             ON citydb.unom5_lu_pipe_type USING btree (name, name_codespace);

----------------------------------------------------------------
-- Table LU_cable_TYPE
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_lu_cable_type CASCADE;
CREATE TABLE         citydb.unom5_lu_cable_type (
	objectclass_id       integer NOT NULL,		--FK citydb.objectclass (id)
	id                   varchar NOT NULL,
	name                 varchar,
	name_codespace       varchar,
	description          text,
	PRIMARY KEY (objectclass_id, id)
);
CREATE INDEX unom5_lu_cable_type_objclass_id_fkx ON citydb.unom5_lu_cable_type USING btree (objectclass_id);
CREATE INDEX unom5_lu_cable_type_inx             ON citydb.unom5_lu_cable_type USING btree (name, name_codespace);

----------------------------------------------------------------
-- Table LU_PARTY_ROLE
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_lu_party_role CASCADE;
CREATE TABLE         citydb.unom5_lu_party_role (
	id                   varchar PRIMARY KEY,
	name                 varchar,
	name_codespace       varchar,
	description          text
);
CREATE INDEX unom5_lu_party_role_name_inx ON citydb.unom5_lu_party_role USING btree (name, name_codespace);

----------------------------------------------------------------
-- Table LU_SOIL
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_lu_soil CASCADE;
CREATE TABLE         citydb.unom5_lu_soil (
	id                   varchar PRIMARY KEY,
	name                 varchar,
	name_codespace       varchar,
	description          text
);
CREATE INDEX unom5_lu_soil_name_inx ON citydb.unom5_lu_soil USING btree (name, name_codespace);

----------------------------------------------------------------
-- Table LU_SHAPE
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_lu_shape CASCADE;
CREATE TABLE         citydb.unom5_lu_shape (
	id                   varchar PRIMARY KEY,
	name                 varchar,
	name_codespace       varchar,
	description          text
);
CREATE INDEX unom5_lu_shape_name_inx ON citydb.unom5_lu_shape USING btree (name, name_codespace);

----------------------------------------------------------------
-- Table LU_GROUNDWATER_REFERENCE
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_lu_groundwater_reference CASCADE;
CREATE TABLE         citydb.unom5_lu_groundwater_reference (
	id                   varchar PRIMARY KEY,
	name                 varchar,
	name_codespace       varchar,
	description          text
);
CREATE INDEX unom5_lu_groundwater_reference_name_inx ON citydb.unom5_lu_groundwater_reference USING btree (name, name_codespace);

----------------------------------------------------------------
-- Table LU_IDENTIFIER_TYPE
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_lu_identifier_type CASCADE;
CREATE TABLE         citydb.unom5_lu_identifier_type (
	id                   varchar PRIMARY KEY,
	name                 varchar,
	name_codespace       varchar,
	description          text
);
CREATE INDEX unom5_lu_identifier_type_name_inx ON citydb.unom5_lu_identifier_type USING btree (name, name_codespace);

----------------------------------------------------------------
-- Table LU_COST_TYPE
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_lu_cost_type CASCADE;
CREATE TABLE         citydb.unom5_lu_cost_type (
	id                   varchar PRIMARY KEY,
	name                 varchar,
	name_codespace       varchar,
	description          text
);
CREATE INDEX unom5_lu_cost_type_name_inx ON citydb.unom5_lu_cost_type USING btree (name, name_codespace);

----------------------------------------------------------------
-- Table LU_MAINTENANCE_TIMELINE_TYPE
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_lu_maintenance_timeline_type CASCADE;
CREATE TABLE         citydb.unom5_lu_maintenance_timeline_type (
	id                   varchar PRIMARY KEY,
	name                 varchar,
	name_codespace       varchar,
	description          text
);
CREATE INDEX unom5_lu_maintenance_timeline_type_name_inx ON citydb.unom5_lu_maintenance_timeline_type USING btree (name, name_codespace);

----------------------------------------------------------------
-- Table LU_MAINTENANCE_ACTIVITY_TYPE
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_lu_maintenance_activity_type CASCADE;
CREATE TABLE         citydb.unom5_lu_maintenance_activity_type (
	id                   varchar PRIMARY KEY,
	name                 varchar,
	name_codespace       varchar,
	description          text
);
CREATE INDEX unom5_lu_maintenance_activity_type_name_inx ON citydb.unom5_lu_maintenance_activity_type USING btree (name, name_codespace);

----------------------------------------------------------------
-- Table LU_MAINTENANCE_TYPE
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_lu_maintenance_type CASCADE;
CREATE TABLE         citydb.unom5_lu_maintenance_type (
	id                   varchar PRIMARY KEY,
	name                 varchar,
	name_codespace       varchar,
	description          text
);
CREATE INDEX unom5_lu_maintenance_type_name_inx ON citydb.unom5_lu_maintenance_type USING btree (name, name_codespace);

----------------------------------------------------------------
-- Table LU_PERFORMANCE_TYPE
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_lu_performance_type CASCADE;
CREATE TABLE         citydb.unom5_lu_performance_type (
	id                   varchar PRIMARY KEY,
	name                 varchar,
	name_codespace       varchar,
	description          text
);
CREATE INDEX unom5_lu_performance_type_name_inx ON citydb.unom5_lu_performance_type USING btree (name, name_codespace);

-- ******************************************************************************************************************************************************************************************************************************
-- ******************************************************************************************************************************************************************************************************************************
-- ******************************************************************************************************************************************************************************************************************************
-- ******************************************************************************************************************************************************************************************************************************
-- B1) ORIGINAL MAIN TABLES (UML featureTypes, dataTypes, relations and geometries)

----------------------------------------------------------------
-- Table NETWORK (_CityObject)
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_network CASCADE;
CREATE TABLE         citydb.unom5_network (
	id                   integer PRIMARY KEY,	-- FK citydb.cityobject (id)
	objectclass_id       integer NOT NULL, 	    -- FK citydb.objectclass (id)
	network_parent_id    integer,				-- FK unom5_network (id)
	network_root_id      integer,				-- FK unom5_network (id)
	class                varchar,				-- FK unom5_lu_network_class (id)
	function             varchar,				-- No FK. Use delimiters.
	usage                varchar,				-- No FK. Use delimiters.
	commodity_id         integer,				-- FK unom5_commodity (id)
	impact_id			 integer				-- FK unom5_impact (id)
);
CREATE INDEX unom5_ntw_objclass_id_fkx 		ON citydb.unom5_network USING btree (objectclass_id);
CREATE INDEX unom5_ntw_ntw_parent_id_fkx 	ON citydb.unom5_network USING btree (network_parent_id);
CREATE INDEX unom5_ntw_ntw_root_id_fkx 		ON citydb.unom5_network USING btree (network_root_id);
CREATE INDEX unom5_ntw_comm_id_fkx 			ON citydb.unom5_network USING btree (commodity_id);
CREATE INDEX unom5_ntw_impact_id_fkx 		ON citydb.unom5_network USING btree (impact_id);

--lookup
CREATE INDEX unom5_ntw_class_fkx 			ON citydb.unom5_network USING btree (class);

COMMENT ON TABLE citydb.unom5_network IS 'Geographical representation of the network';

COMMENT ON COLUMN citydb.unom5_network.objectclass_id 		IS 'Objectclass ID of the network';
COMMENT ON COLUMN citydb.unom5_network.network_parent_id    IS 'Parent network';
COMMENT ON COLUMN citydb.unom5_network.network_root_id   	IS 'Root network';
COMMENT ON COLUMN citydb.unom5_network.class          		IS 'Class of the network feature';
COMMENT ON COLUMN citydb.unom5_network.function       		IS 'Function(s) of the network feature';
COMMENT ON COLUMN citydb.unom5_network.usage         		IS 'Usage(s) of the network feature';
COMMENT ON COLUMN citydb.unom5_network.commodity_id         IS 'ID of the associated commodity';
COMMENT ON COLUMN citydb.unom5_network.impact_id         	IS 'ID of the associated impact';


----------------------------------------------------------------
-- Table NETWORK_TO_NETWORK
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_network_to_network CASCADE;
CREATE TABLE         citydb.unom5_network_to_network(
	superordinate_network_id   integer NOT NULL,		-- FK unom5_network (id)
	subordinate_network_id     integer NOT NULL,		-- FK unom5_network (id)
	CONSTRAINT unom5_network_to_network_pk PRIMARY KEY (superordinate_network_id, subordinate_network_id)
);
CREATE INDEX unom5_ntw_to_ntw_superntw_id_fkx ON citydb.unom5_network_to_network USING btree (superordinate_network_id);
CREATE INDEX unom5_ntw_to_ntw_subntw_id_fkx   ON citydb.unom5_network_to_network USING btree (subordinate_network_id);


----------------------------------------------------------------
-- Table NETWORK_TO_SUPPLY_AREA
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_network_to_supply_area CASCADE;
CREATE TABLE         citydb.unom5_network_to_supply_area(
	network_id       integer NOT NULL,		-- FK unom5_network (id)
	supply_area_id   integer NOT NULL,		-- FK citydb.cityobjectgroup (id)
	CONSTRAINT unom5_network_to_supply_area_pk PRIMARY KEY (network_id, supply_area_id)
);
CREATE INDEX unom5_ntw_to_supply_area_ntw_id_fkx  ON citydb.unom5_network_to_supply_area USING btree (network_id);
CREATE INDEX unom5_ntw_to_supply_area_area_id_fkx ON citydb.unom5_network_to_supply_area USING btree (supply_area_id);


----------------------------------------------------------------
-- Table NETWORK_FEATURE (_CityObject)
-- FF: Heaviliy edited
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_network_feature CASCADE;
CREATE TABLE         citydb.unom5_network_feature (
	id                      	integer PRIMARY KEY,	-- FK citydb.cityobject (id)
	objectclass_id          	integer NOT NULL, 	    -- FK citydb.objectclass (id)
	ntw_feature_parent_id   	integer,				-- FK unom5_network_feature (id)
	ntw_feature_root_id      	integer,				-- FK unom5_network_feature (id)
	class                    	varchar,				-- COMPOSITE FK unom5_lu_network_feature_class (objectclass_id, id)
	function                 	varchar,				-- FK unom5_lu_network_feature_function (id)
	usage                   	varchar,				-- No FK. Use delimiters.
	conn_cityobject_id      	integer,				-- FK citydb.cityobject (id)
	status                  	varchar,				-- FK unom5_lu_status (id)
	location_quality        	varchar,				-- FK unom5_lu_spatial_quality (id)
	elevation_quality       	varchar,				-- FK unom5_lu_spatial_quality (id)
	location_accuracy			varchar,				-- FK unom5_lu_location_accuracy_value (id)
--	relative_to_terrain			varchar,				-- FK unom5_lu_relative_to_terrain (id). REPEATED. CHECK CITYOBJECT.
	standard_depth				numeric,
	standard_depth_uom			varchar,
	prot_element_id      	    integer,				-- FK unom5_protective_element (id)
	geom                   		geometry(GeometryZ),
	date_of_installation		date,
	date_in_use					date,
	date_of_location_measuring	date,
	date_of_registration		date,
	date_of_abandonment			date,
	date_of_removal				date,
	impact_id					integer					-- FK unom5_impact (id)
--	performance_id				integer					-- FF: Referenced in performance table
--	measured_depth										-- FF: [ 0..*] means that it can't be referenced here. 
--	surrounding_soil									-- FF: [ 0..*] means that it can't be referenced here. 
--	cost												-- FF: [ 0..*] means that it can't be referenced here. 
);
CREATE INDEX unom5_ntw_feat_objclass_id_fkx 		ON citydb.unom5_network_feature USING btree (objectclass_id);
CREATE INDEX unom5_ntw_feat_ntw_feat_parent_id_fkx 	ON citydb.unom5_network_feature USING btree (ntw_feature_parent_id);
CREATE INDEX unom5_ntw_feat_ntw_feat_root_id_fkx 	ON citydb.unom5_network_feature USING btree (ntw_feature_root_id);
CREATE INDEX unom5_ntw_feat_conn_cto_id_fkx 		ON citydb.unom5_network_feature USING btree (conn_cityobject_id);
CREATE INDEX unom5_ntw_feat_prot_elem_id_fkx 		ON citydb.unom5_network_feature USING btree (prot_element_id);
CREATE INDEX unom5_ntw_feat_geom_spx 				ON citydb.unom5_network_feature USING gist (geom gist_geometry_ops_nd);
CREATE INDEX unom5_ntw_feat_impact_id_fkx	 		ON citydb.unom5_network_feature USING btree (impact_id);
--lookup
CREATE INDEX unom5_ntw_feat_function_fkx 			ON citydb.unom5_network_feature USING btree (function);
CREATE INDEX unom5_ntw_feat_status_fkx 				ON citydb.unom5_network_feature USING btree (status);
CREATE INDEX unom5_ntw_feat_loc_qual_fkx 			ON citydb.unom5_network_feature USING btree (location_quality);
CREATE INDEX unom5_ntw_feat_ele_qual_fkx 			ON citydb.unom5_network_feature USING btree (elevation_quality);
CREATE INDEX unom5_ntw_feat_loc_acc_fkx 			ON citydb.unom5_network_feature USING btree (location_accuracy);
--CREATE INDEX unom5_ntw_feat_rel_to_terr_fkx 		ON citydb.unom5_network_feature USING btree (relative_to_terrain);

COMMENT ON TABLE citydb.unom5_network_feature IS 'Geographical representation of the network feature';

COMMENT ON COLUMN citydb.unom5_network_feature.objectclass_id       		IS 'Objectclass ID of the network feature';
COMMENT ON COLUMN citydb.unom5_network_feature.class               			IS 'Class of the network feature';
COMMENT ON COLUMN citydb.unom5_network_feature.function             		IS 'Function of the network feature';
COMMENT ON COLUMN citydb.unom5_network_feature.usage                		IS 'Usage of the network feature';
COMMENT ON COLUMN citydb.unom5_network_feature.status               		IS 'Current status';
COMMENT ON COLUMN citydb.unom5_network_feature.location_quality     		IS 'Location quality';
COMMENT ON COLUMN citydb.unom5_network_feature.elevation_quality    		IS 'Elevation quality';
COMMENT ON COLUMN citydb.unom5_network_feature.location_accuracy    		IS 'Location accuracy';
--COMMENT ON COLUMN citydb.unom5_network_feature.relative_to_terrain  		IS 'Position relative to terrain';
COMMENT ON COLUMN citydb.unom5_network_feature.standard_depth  				IS 'Standard depth of the feature';
COMMENT ON COLUMN citydb.unom5_network_feature.prot_element_id	    		IS 'Protective elements can contain other features';
COMMENT ON COLUMN citydb.unom5_network_feature.date_of_installation			IS 'Date of installation';
COMMENT ON COLUMN citydb.unom5_network_feature.date_in_use					IS 'Date since first use';
COMMENT ON COLUMN citydb.unom5_network_feature.date_of_location_measuring	IS 'Date of location measuring';
COMMENT ON COLUMN citydb.unom5_network_feature.date_of_registration			IS 'Date of registration';
COMMENT ON COLUMN citydb.unom5_network_feature.date_of_abandonment			IS 'Date of abandonment';
COMMENT ON COLUMN citydb.unom5_network_feature.date_of_removal				IS 'Date of removal';
COMMENT ON COLUMN citydb.unom5_network_feature.impact_id					IS 'ID of the associated impact';


----------------------------------------------------------------
-- Table CABLE (_CityObject)
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_cable CASCADE;
CREATE TABLE         citydb.unom5_cable (
	id                     	 		integer PRIMARY KEY,		-- FK unom5_network_feature (id) -> which is a FK to citydb.cityobject (id)
	objectclass_id          		integer NOT NULL, 	 		-- FK citydb.objectclass (id)
	function_of_line        		varchar,					-- FK unom5_lu_function_of_line (id)
	cable_type						varchar,					-- COMPOSITE FK unom5_lu_cable_type (objectclass_id, id)
	number_of_conductors			integer,
	conductor_cross_section			numeric,
	conductor_cross_section_uom		varchar,	
	electr_voltage_grade			numeric,
	electr_voltage_grade_uom		varchar,
	electr_ampacity					numeric,
	electr_ampacity_uom				varchar,
	telecom_bandwith_range_from		numeric,
	telecom_bandwith_range_to		numeric,
	telecom_bandwith_uom			varchar,
	telecom_impedance				numeric,
	telecom_impedance_uom			varchar,
	telecom_attenuation				numeric,
	telecom_attenuation_uom			varchar
);
CREATE INDEX unom5_cable_objclass_id_fkx ON citydb.unom5_cable USING btree (objectclass_id);
CREATE INDEX unom5_cable_line_funct_fkx ON citydb.unom5_cable USING btree (function_of_line);

COMMENT ON TABLE citydb.unom5_cable IS 'Network distribution element: cable';

COMMENT ON COLUMN citydb.unom5_cable.objectclass_id					IS 'Objectclass ID of the distribution element';
COMMENT ON COLUMN citydb.unom5_cable.function_of_line				IS 'Cooling, flow, return, steam';
COMMENT ON COLUMN citydb.unom5_cable.cable_type						IS 'Type of cable';
COMMENT ON COLUMN citydb.unom5_cable.number_of_conductors			IS 'Number of conductors in the cable';
COMMENT ON COLUMN citydb.unom5_cable.conductor_cross_section		IS 'Cross section of the conductors';
COMMENT ON COLUMN citydb.unom5_cable.electr_voltage_grade			IS 'Voltage grade of electricity cable';
COMMENT ON COLUMN citydb.unom5_cable.electr_ampacity				IS 'Ampacity of electricity cable';
COMMENT ON COLUMN citydb.unom5_cable.telecom_bandwith_range_from	IS 'Minnimum bandwith';
COMMENT ON COLUMN citydb.unom5_cable.telecom_bandwith_range_to		IS 'Maximum bandwith';
COMMENT ON COLUMN citydb.unom5_cable.telecom_impedance				IS 'Impedance';
COMMENT ON COLUMN citydb.unom5_cable.telecom_attenuation			IS 'Attenuation';


----------------------------------------------------------------
-- Table PIPE (_CityObject)
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_pipe CASCADE;
CREATE TABLE         citydb.unom5_pipe (
	id                     		 	integer PRIMARY KEY,		-- FK unom5_network_feature (id) -> which is a FK to citydb.cityobject (id)
	objectclass_id          		integer NOT NULL, 	 		-- FK citydb.objectclass (id)
	function_of_line        		varchar,					-- FK unom5_lu_function_of_line (id)
	pipe_type						varchar,					-- COMPOSITE FK unom5_lu_pipe_type (objectclass_id, id)
	is_gravity						numeric(1),
	slope							numeric,
	slope_uom			         	varchar,	
	directional_drilling			numeric(1),
	cathodic_protection				numeric(1),
	pressure_grade					numeric,
	pressure_grade_uom				varchar,
	max_capacity					numeric,
	max_capacity_uom				varchar
);
CREATE INDEX unom5_pipe_objclass_id_fkx ON citydb.unom5_pipe USING btree (objectclass_id);
CREATE INDEX unom5_pipe_line_funct_fkx ON citydb.unom5_pipe USING btree (function_of_line);

COMMENT ON TABLE citydb.unom5_pipe IS 'Network distribution element: pipe';

COMMENT ON COLUMN citydb.unom5_pipe.objectclass_id			IS 'Objectclass ID of the distribution element';
COMMENT ON COLUMN citydb.unom5_pipe.function_of_line		IS 'Cooling, flow, return, steam';
COMMENT ON COLUMN citydb.unom5_pipe.pipe_type				IS 'Type of pipe';
COMMENT ON COLUMN citydb.unom5_pipe.is_gravity				IS 'Is flow gravitational?';
COMMENT ON COLUMN citydb.unom5_pipe.slope					IS 'Slope of the pipe';
COMMENT ON COLUMN citydb.unom5_pipe.directional_drilling	IS 'Is pipe executed with directional drilling';
COMMENT ON COLUMN citydb.unom5_pipe.cathodic_protection		IS 'Does the pipe have cathodic protection';
COMMENT ON COLUMN citydb.unom5_pipe.pressure_grade			IS 'Pressure grade / class';
COMMENT ON COLUMN citydb.unom5_pipe.max_capacity			IS 'Volume';


----------------------------------------------------------------
-- Table PROTECTIVE_ELEMENT (_CityObject)
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_protective_element CASCADE;
CREATE TABLE         citydb.unom5_protective_element (
	id             integer PRIMARY KEY, 	-- FK unom5_network_feature (id) -> which is a FK to citydb.cityobject (id)
	objectclass_id integer NOT NULL 	  	-- FK citydb.objectclass (id)
);
CREATE INDEX unom5_prot_elem_objclass_id_fkx ON citydb.unom5_protective_element USING btree (objectclass_id);

COMMENT ON TABLE citydb.unom5_protective_element IS 'Network protective element (shell, bedding, etc.)';

COMMENT ON COLUMN citydb.unom5_protective_element.objectclass_id       IS 'Objectclass ID of the distribution element';


----------------------------------------------------------------
-- Table NETWORK_TO_NETWORK_FEATURE
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_network_to_network_feature CASCADE;
CREATE TABLE         citydb.unom5_network_to_network_feature(
	network_id             integer NOT NULL,		-- FK unom5_network (id)
	network_feature_id     integer NOT NULL,		-- FK unom5_network_feature (id)
	CONSTRAINT unom5_network_to_network_feature_pk PRIMARY KEY (network_id, network_feature_id)
);
CREATE INDEX unom5_ntw_to_ntw_feat_ntw_id_fkx      ON citydb.unom5_network_to_network_feature USING btree (network_id);
CREATE INDEX unom5_ntw_to_ntw_feat_ntw_feat_id_fkx ON citydb.unom5_network_to_network_feature USING btree (network_feature_id);


----------------------------------------------------------------
-- Table NETWORK_GRAPH (FEATURE prototype)
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_network_graph CASCADE;
CREATE TABLE         citydb.unom5_network_graph (
	id              	serial PRIMARY KEY,
	objectclass_id  	integer NOT NULL, 	  	-- FK citydb.objectclass (id)
	gmlid           	varchar,
	gmlid_codespace 	varchar,
	name            	varchar,
	name_codespace  	varchar,
	description     	text,
	network_id     		integer					-- FK unom5_network (id)
);
CREATE INDEX unom5_ntw_graph_gmlid_inx       ON citydb.unom5_network_graph USING btree (gmlid, gmlid_codespace);
CREATE INDEX unom5_ntw_graph_objclass_id_fkx ON citydb.unom5_network_graph USING btree (objectclass_id);
CREATE INDEX unom5_ntw_graph_ntw_id_fkx      ON citydb.unom5_network_graph USING btree (network_id);

COMMENT ON TABLE citydb.unom5_network_graph IS 'Topological representation of the network';

COMMENT ON COLUMN citydb.unom5_network_graph.id              IS 'ID';
COMMENT ON COLUMN citydb.unom5_network_graph.objectclass_id  IS 'Objectclass ID of the network graph';
COMMENT ON COLUMN citydb.unom5_network_graph.gmlid           IS 'Gml ID';
COMMENT ON COLUMN citydb.unom5_network_graph.gmlid_codespace IS 'Gml ID codespace';
COMMENT ON COLUMN citydb.unom5_network_graph.name            IS 'Name';
COMMENT ON COLUMN citydb.unom5_network_graph.name_codespace  IS 'Name codespace';
COMMENT ON COLUMN citydb.unom5_network_graph.description     IS 'Description';


----------------------------------------------------------------
-- Table FEATURE_GRAPH (FEATURE prototype)
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_feature_graph CASCADE;
CREATE TABLE         citydb.unom5_feature_graph (
	id              	serial PRIMARY KEY,
	objectclass_id  	integer NOT NULL, 	  	-- FK citydb.objectclass (id)
	gmlid           	varchar,
	gmlid_codespace 	varchar,
	name            	varchar,
	name_codespace  	varchar,
	description     	text,
	ntw_feature_id  	integer					-- FK unom5_network_feature (id)
--	ntw_graph_id		integer					-- FF: this is now a many-to-many table! UN ADE 0.9.4 and UNOM5	
);
CREATE INDEX unom5_feat_graph_gmlid_inx       	ON citydb.unom5_feature_graph USING btree (gmlid, gmlid_codespace);
CREATE INDEX unom5_feat_graph_objclass_id_fkx 	ON citydb.unom5_feature_graph USING btree (objectclass_id);
CREATE INDEX unom5_feat_graph_ntw_feat_id_fkx 	ON citydb.unom5_feature_graph USING btree (ntw_feature_id);
--CREATE INDEX unom5_feat_graph_ntw_graph_id_fkx	ON citydb.unom5_feature_graph USING btree (ntw_graph_id);   -- THIS IS NOW A MANY TO MANY TABLE

COMMENT ON TABLE  citydb.unom5_feature_graph IS 'Topological representation of the network feature';

COMMENT ON COLUMN citydb.unom5_feature_graph.id              IS 'ID';
COMMENT ON COLUMN citydb.unom5_feature_graph.objectclass_id  IS 'Objectclass ID of the network graph';
COMMENT ON COLUMN citydb.unom5_feature_graph.gmlid           IS 'Gml ID';
COMMENT ON COLUMN citydb.unom5_feature_graph.gmlid_codespace IS 'Gml ID codespace';
COMMENT ON COLUMN citydb.unom5_feature_graph.name            IS 'Name';
COMMENT ON COLUMN citydb.unom5_feature_graph.name_codespace  IS 'Name codespace';
COMMENT ON COLUMN citydb.unom5_feature_graph.description     IS 'Description';


----------------------------------------------------------------
-- Table NODE (FEATURE prototype)
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_node CASCADE;
CREATE TABLE         citydb.unom5_node (
	id                   serial PRIMARY KEY,
	objectclass_id       integer NOT NULL, 	  	-- FK citydb.objectclass (id)
	gmlid                varchar,
	gmlid_codespace      varchar,
	name                 varchar,
	name_codespace       varchar,
	description          text,
	type                 varchar CHECK (type IN ('interior', 'exterior')),
	connection_signature varchar,
	link_control         varchar,
	feat_graph_id        integer,				-- FK unom5_feature_graph (id)
	point_geom           geometry(POINTZ)		
);
CREATE INDEX unom5_node_gmlid_inx       	ON citydb.unom5_node USING btree (gmlid, gmlid_codespace);
CREATE INDEX unom5_node_objclass_id_fkx 	ON citydb.unom5_node USING btree (objectclass_id);
CREATE INDEX unom5_node_feat_graph_id_fkx 	ON citydb.unom5_node USING btree (feat_graph_id);
CREATE INDEX unom5_node_geom_spx 			ON citydb.unom5_node USING gist (point_geom gist_geometry_ops_nd);

COMMENT ON TABLE citydb.unom5_node IS 'Topological node';

COMMENT ON COLUMN citydb.unom5_node.id                   IS 'ID';
COMMENT ON COLUMN citydb.unom5_node.objectclass_id       IS 'Objectclass ID of the node';
COMMENT ON COLUMN citydb.unom5_node.gmlid                IS 'Gml ID';
COMMENT ON COLUMN citydb.unom5_node.gmlid_codespace      IS 'Gml ID codespace';
COMMENT ON COLUMN citydb.unom5_node.name                 IS 'Name';
COMMENT ON COLUMN citydb.unom5_node.name_codespace       IS 'Name codespace';
COMMENT ON COLUMN citydb.unom5_node.description          IS 'Description';
COMMENT ON COLUMN citydb.unom5_node.type                 IS 'Type of node';
COMMENT ON COLUMN citydb.unom5_node.connection_signature IS 'Connection signature';
COMMENT ON COLUMN citydb.unom5_node.link_control         IS 'Link control';


----------------------------------------------------------------
-- Table LINK (FEATURE prototype)
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_link CASCADE;
CREATE TABLE         citydb.unom5_link (
	id                     	serial PRIMARY KEY,
	objectclass_id         	integer NOT NULL, 	  	-- FK citydb.objectclass (id)
	gmlid                 	varchar,
	gmlid_codespace        	varchar,
	name                  	varchar,
	name_codespace        	varchar,
	description           	text,
	direction             	char CHECK (direction IN ('+', '-')),
	link_control          	varchar,
	type 					varchar CHECK (type IN ('connects', 'contains')),
	start_node_id          	integer NOT NULL, 	  	-- FK unom5_node (id)
	end_node_id            	integer NOT NULL, 	  	-- FK unom5_node (id)
	feat_graph_id          	integer,		 	  	-- FK unom5_feature_graph (id)
	ntw_graph_id           	integer,				-- FK unom5_network_graph (id)
	line_geom              	geometry(LINESTRINGZ)
);
CREATE INDEX unom5_link_gmlid_inx         	ON citydb.unom5_link USING btree (gmlid, gmlid_codespace);
CREATE INDEX unom5_link_objclass_id_fkx   	ON citydb.unom5_link USING btree (objectclass_id);
CREATE INDEX unom5_link_start_node_id_fkx 	ON citydb.unom5_link USING btree (start_node_id);
CREATE INDEX unom5_link_end_node_id_fkx   	ON citydb.unom5_link USING btree (end_node_id);
CREATE INDEX unom5_link_feat_graph_id_fkx 	ON citydb.unom5_link USING btree (feat_graph_id);
CREATE INDEX unom5_link_ntw_graph_id_fkx 	ON citydb.unom5_link USING btree (ntw_graph_id);
CREATE INDEX unom5_link_geom_spx 			ON citydb.unom5_link USING gist (line_geom gist_geometry_ops_nd);

COMMENT ON TABLE citydb.unom5_link IS 'Topological link';

COMMENT ON COLUMN citydb.unom5_link.id                  IS 'ID';
COMMENT ON COLUMN citydb.unom5_link.objectclass_id      IS 'Objectclass ID of the link';
COMMENT ON COLUMN citydb.unom5_link.gmlid               IS 'Gml ID';
COMMENT ON COLUMN citydb.unom5_link.gmlid_codespace     IS 'Gml ID codespace';
COMMENT ON COLUMN citydb.unom5_link.name                IS 'Name';
COMMENT ON COLUMN citydb.unom5_link.name_codespace      IS 'Name codespace';
COMMENT ON COLUMN citydb.unom5_link.description         IS 'Description';
COMMENT ON COLUMN citydb.unom5_link.direction           IS 'Link direction (+ or -)';
COMMENT ON COLUMN citydb.unom5_link.link_control        IS 'Link control';
COMMENT ON COLUMN citydb.unom5_link.type 				IS 'Interfeature link type';


----------------------------------------------------------------
-- Table UNOM_BUILDING (_CityObject)
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_building CASCADE;
CREATE TABLE         citydb.unom5_building (
	id                   integer PRIMARY KEY,		-- FK citydb.building (id)
	objectclass_id       integer NOT NULL, 	  		-- FK citydb.objectclass (id)
	nbr_occupants        integer
);
CREATE INDEX unom5_bdg_objclass_id_fkx ON citydb.unom5_building USING btree (objectclass_id);

COMMENT ON TABLE citydb.unom5_building IS 'Extension of the BUILDING table for the UtilityNetworks ADE';

COMMENT ON COLUMN citydb.unom5_building.objectclass_id  IS 'Objectclass ID of the building';
COMMENT ON COLUMN citydb.unom5_building.nbr_occupants 	IS 'Number of occupants';


----------------------------------------------------------------
-- Table COMMODITY_SUPPLY (electrical, gaseous, liquid, optical, solid)
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_commodity_supply CASCADE;
CREATE TABLE         citydb.unom5_commodity_supply (
 id                 		serial PRIMARY KEY,
 objectclass_id     		integer NOT NULL, 	  	-- FK citydb.objectclass (id)
 type               		varchar NOT NULL,		-- FK COMPOSITE unom5_lu_commodity_supply (objectclass_id, id)
 current_flow_rate      	numeric,
 current_flow_rate_uom	 	varchar,
 current_status         	varchar,	     		-- FK unom5_lu_status (id)
 potential_flow_rate      	numeric,
 potential_flow_rate_uom	varchar,
 potential_status         	varchar,         		-- FK unom5_lu_status (id)
 cityobject_id      		integer	         		-- FK citydb.cityobject (id)
);
CREATE INDEX unom5_commodity_supply_objclass_id_fkx 		ON citydb.unom5_commodity_supply USING btree (objectclass_id);
CREATE INDEX unom5_commodity_supply_type_fkx        		ON citydb.unom5_commodity_supply USING btree (type);
CREATE INDEX unom5_commodity_supply_ctyobj_id_fkx   		ON citydb.unom5_commodity_supply USING btree (cityobject_id);

CREATE INDEX unom5_commodity_supply_current_status_fkx   	ON citydb.unom5_commodity_supply USING btree (current_status);
CREATE INDEX unom5_commodity_supply_potential_status_fkx  	ON citydb.unom5_commodity_supply USING btree (potential_status);

COMMENT ON TABLE citydb.unom5_commodity_supply IS 'Commodity supply';

COMMENT ON COLUMN citydb.unom5_commodity_supply.objectclass_id      	IS 'Objectclass ID of the commodity supply';
COMMENT ON COLUMN citydb.unom5_commodity_supply.type                	IS 'Type of the commodity supply';
COMMENT ON COLUMN citydb.unom5_commodity_supply.current_flow_rate       IS 'Current supply flow rate';
COMMENT ON COLUMN citydb.unom5_commodity_supply.current_flow_rate_uom  	IS 'Unit of current supply flow rate';
COMMENT ON COLUMN citydb.unom5_commodity_supply.current_status          IS 'Current supply status';
COMMENT ON COLUMN citydb.unom5_commodity_supply.potential_flow_rate     IS 'Potential supply flow rate';
COMMENT ON COLUMN citydb.unom5_commodity_supply.potential_flow_rate_uom IS 'Unit of potential supply flow rate';
COMMENT ON COLUMN citydb.unom5_commodity_supply.potential_status        IS 'Potential supply status';
COMMENT ON COLUMN citydb.unom5_commodity_supply.cityobject_id        	IS 'A city object that has this commodity supply associated to it (i.e. id of hydrant)';


----------------------------------------------------------------
-- Table STORAGE (dataType)
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_storage CASCADE;
CREATE TABLE         citydb.unom5_storage (
 id                		serial PRIMARY KEY,
 type_objectclass_id	integer,		-- Composite FK unom5_lu_network_feature_class (objectclass_id, id)
 type_id              	varchar,		-- Composite FK unom5_lu_network_feature_class (objectclass_id, id)
 max_capacity      		numeric,	
 max_capacity_uom 		varchar,
 fill_level        		numeric CHECK (fill_level BETWEEN 0 AND 1),
 inflow_rate       		numeric,
 inflow_rate_uom  		varchar,
 outflow_rate      		numeric,
 outflow_rate_uom 		varchar,	
 commodity_supply_id  	integer,		-- FK unom5_commodity_supply (id)
 funct_component_id  	integer			-- FK unom5_functional_component (id) 
);
CREATE INDEX unom5_storage_commodity_supply_id_fkx   ON citydb.unom5_storage USING btree (commodity_supply_id);
CREATE INDEX unom5_storage_funct_component_id_fkx    ON citydb.unom5_storage USING btree (funct_component_id);

COMMENT ON TABLE citydb.unom5_storage IS 'Storage';

COMMENT ON COLUMN citydb.unom5_storage.id                    	IS 'ID';
COMMENT ON COLUMN citydb.unom5_storage.type_id                  IS 'Type of storage (ID)';
COMMENT ON COLUMN citydb.unom5_storage.type_objectclass_id      IS 'Type of storage (Objectclass ID)';
COMMENT ON COLUMN citydb.unom5_storage.max_capacity          	IS 'Maximum capacity';
COMMENT ON COLUMN citydb.unom5_storage.max_capacity_uom      	IS 'Unit of maximum capacity';
COMMENT ON COLUMN citydb.unom5_storage.fill_level            	IS 'Fill level';
COMMENT ON COLUMN citydb.unom5_storage.inflow_rate          	IS 'Inflow rate';
COMMENT ON COLUMN citydb.unom5_storage.inflow_rate_uom      	IS 'Unit of inflow rate';
COMMENT ON COLUMN citydb.unom5_storage.outflow_rate          	IS 'Outflow rate';
COMMENT ON COLUMN citydb.unom5_storage.outflow_rate_uom      	IS 'Unit of outflow rate';
COMMENT ON COLUMN citydb.unom5_storage.commodity_supply_id     	IS 'Commodity supply ID in storage';
COMMENT ON COLUMN citydb.unom5_storage.funct_component_id     	IS 'Related functional component ID';


----------------------------------------------------------------
-- Table ROLE_IN_NETWORK (FEATURE prototype)
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_role_in_network CASCADE;
CREATE TABLE         citydb.unom5_role_in_network (
 id              serial PRIMARY KEY,
 objectclass_id  integer NOT NULL, 		-- FK citydb.objectclass (id)
 gmlid           varchar,
 gmlid_codespace varchar,
 name            varchar,
 name_codespace  varchar,
 description     text,
 function        varchar,				-- FK unom5_lu_network_feature_function (id)
 usage           varchar,				-- No FK. Use delimiters.
 cityobject_id   integer,	      		-- FK citydb.cityobject (id)
 network_id      integer           		-- FK unom5_network (id)
);
CREATE INDEX unom5_role_in_network_gmlid_inx       ON citydb.unom5_role_in_network USING btree (gmlid, gmlid_codespace);
CREATE INDEX unom5_role_in_network_objclass_id_fkx ON citydb.unom5_role_in_network USING btree (objectclass_id);
CREATE INDEX unom5_role_in_network_ctyobj_id_fkx   ON citydb.unom5_role_in_network USING btree (cityobject_id);
CREATE INDEX unom5_role_in_network_ntw_id_fkx      ON citydb.unom5_role_in_network USING btree (network_id);

COMMENT ON TABLE citydb.unom5_role_in_network IS 'Role in network';

COMMENT ON COLUMN citydb.unom5_role_in_network.id              IS 'ID';
COMMENT ON COLUMN citydb.unom5_role_in_network.objectclass_id  IS 'Objectclass ID of the role in network';
COMMENT ON COLUMN citydb.unom5_role_in_network.gmlid           IS 'Gml ID';
COMMENT ON COLUMN citydb.unom5_role_in_network.gmlid_codespace IS 'Gml ID codespace';
COMMENT ON COLUMN citydb.unom5_role_in_network.name            IS 'Name';
COMMENT ON COLUMN citydb.unom5_role_in_network.name_codespace  IS 'Name codespace';
COMMENT ON COLUMN citydb.unom5_role_in_network.description     IS 'Description';
COMMENT ON COLUMN citydb.unom5_role_in_network.function        IS 'Function in network';
COMMENT ON COLUMN citydb.unom5_role_in_network.usage           IS 'Usage in network';


----------------------------------------------------------------
-- Table COMMODITY (FEATURE prototype)
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_commodity CASCADE;
CREATE TABLE         citydb.unom5_commodity (
	id                           serial PRIMARY KEY,
	objectclass_id               integer NOT NULL, 		-- FK citydb.objectclass (id)
	gmlid                        varchar,
	gmlid_codespace              varchar,
	name                         varchar,
	name_codespace               varchar,
	description                  text,
	owner                        varchar,
	type                         varchar NOT NULL,		-- COMPOSITE FK unom5_lu_commodity_supply (objectclass_id, id)
	is_corrosive                 numeric(1),
	is_explosive                 numeric(1),
	is_lighter_than_air          numeric(1),
	is_flammable				 numeric(1),
	flammability_ratio           numeric CHECK (flammability_ratio BETWEEN 0 AND 1),
	elec_conductivity_range_from numeric,
	elec_conductivity_range_to   numeric,	
	elec_conductivity_range_uom  varchar,
	concentration                numeric,
	concentration_uom            varchar,	
	ph_value_range_from          numeric,
	ph_value_range_to            numeric,
	ph_value_range_uom           varchar,	
	temperature_range_from       numeric,
	temperature_range_to         numeric,
	temperature_range_uom        varchar,	
	flow_rate_range_from         numeric,
	flow_rate_range_to           numeric,
	flow_rate_range_uom          varchar,		
	pressure_range_from          numeric,
	pressure_range_to            numeric,
	pressure_range_uom           varchar,
	pressure_nominal             numeric,
	pressure_nominal_uom         varchar,
	pressure_operating           numeric,
	pressure_operating_uom       varchar,
	pressure_maximum             numeric,
	pressure_maximum_uom         varchar,
	voltage_range_from           numeric,
	voltage_range_to             numeric,
	voltage_range_uom            varchar,
	voltage_nominal              numeric,
	voltage_nominal_uom          varchar,
	voltage_operating            numeric,
	voltage_operating_uom        varchar,
	amperage_range_from          numeric,
	amperage_range_to            numeric,
	amperage_range_uom           varchar,
	bandwidth_range_from         numeric,
	bandwidth_range_to           numeric,
	bandwidth_range_uom          varchar,
	optical_mode	             varchar,			-- FK unom5_lu_optical_mode (id)
	phase_value					 integer
);
CREATE INDEX unom5_commodity_gmlid_inx       ON citydb.unom5_commodity USING btree (gmlid, gmlid_codespace);
CREATE INDEX unom5_commodity_objclass_id_fkx ON citydb.unom5_commodity USING btree (objectclass_id);

COMMENT ON TABLE citydb.unom5_commodity IS 'Commodity';

COMMENT ON COLUMN citydb.unom5_commodity.id                           IS 'ID';
COMMENT ON COLUMN citydb.unom5_commodity.objectclass_id               IS 'Objectclass ID of the commodity';
COMMENT ON COLUMN citydb.unom5_commodity.gmlid                        IS 'Gml ID';
COMMENT ON COLUMN citydb.unom5_commodity.gmlid_codespace              IS 'Gml ID codespace';
COMMENT ON COLUMN citydb.unom5_commodity.name                         IS 'Name';
COMMENT ON COLUMN citydb.unom5_commodity.name_codespace               IS 'Name codespace';
COMMENT ON COLUMN citydb.unom5_commodity.description                  IS 'Description';
COMMENT ON COLUMN citydb.unom5_commodity.owner                        IS 'Owner';
COMMENT ON COLUMN citydb.unom5_commodity.type                         IS 'Type of commodity';
COMMENT ON COLUMN citydb.unom5_commodity.is_corrosive                 IS 'Is corrosive?';
COMMENT ON COLUMN citydb.unom5_commodity.is_explosive                 IS 'Is explosive?';
COMMENT ON COLUMN citydb.unom5_commodity.is_lighter_than_air          IS 'Is lighter than air?';
COMMENT ON COLUMN citydb.unom5_commodity.is_flammable          		  IS 'Is flammable?';
COMMENT ON COLUMN citydb.unom5_commodity.flammability_ratio           IS 'Flammability ratio, value in [0,1]';
COMMENT ON COLUMN citydb.unom5_commodity.elec_conductivity_range_from IS 'Electrical conductivity rage: min value';
COMMENT ON COLUMN citydb.unom5_commodity.elec_conductivity_range_to   IS 'Electrical conductivity rage: max value';
COMMENT ON COLUMN citydb.unom5_commodity.elec_conductivity_range_uom  IS 'Unit of electrical conductivity';
COMMENT ON COLUMN citydb.unom5_commodity.concentration                IS 'Concentration';
COMMENT ON COLUMN citydb.unom5_commodity.concentration_uom            IS 'Unit of concentration';
COMMENT ON COLUMN citydb.unom5_commodity.ph_value_range_from          IS 'Ph value range: min value';
COMMENT ON COLUMN citydb.unom5_commodity.ph_value_range_to            IS 'Ph value range: max value';
COMMENT ON COLUMN citydb.unom5_commodity.ph_value_range_uom           IS 'Unit of Ph value';
COMMENT ON COLUMN citydb.unom5_commodity.temperature_range_from       IS 'Temperature range: min value';
COMMENT ON COLUMN citydb.unom5_commodity.temperature_range_to         IS 'Temperature range: max value';
COMMENT ON COLUMN citydb.unom5_commodity.temperature_range_uom        IS 'Unit of temperature';
COMMENT ON COLUMN citydb.unom5_commodity.flow_rate_range_from         IS 'Flow_rate range: min value';
COMMENT ON COLUMN citydb.unom5_commodity.flow_rate_range_to           IS 'Flow_rate range: max value';
COMMENT ON COLUMN citydb.unom5_commodity.flow_rate_range_uom          IS 'Unit of flow_rate';
COMMENT ON COLUMN citydb.unom5_commodity.pressure_range_from          IS 'Pressure range: min value';
COMMENT ON COLUMN citydb.unom5_commodity.pressure_range_to            IS 'Pressure range: max value';
COMMENT ON COLUMN citydb.unom5_commodity.pressure_range_uom           IS 'Unit of pressure';
COMMENT ON COLUMN citydb.unom5_commodity.pressure_nominal         	  IS 'Nominal pressure';
COMMENT ON COLUMN citydb.unom5_commodity.pressure_nominal_uom         IS 'Unit of measurement nominal pressure';
COMMENT ON COLUMN citydb.unom5_commodity.pressure_operating           IS 'Operating pressure';
COMMENT ON COLUMN citydb.unom5_commodity.pressure_operating_uom       IS 'Unit of measurementoperating pressure';
COMMENT ON COLUMN citydb.unom5_commodity.pressure_maximum         	  IS 'Maximum pressure';
COMMENT ON COLUMN citydb.unom5_commodity.pressure_maximum_uom         IS 'Unit of measurement maximum pressure';
COMMENT ON COLUMN citydb.unom5_commodity.voltage_range_from           IS 'Voltage range: min value';
COMMENT ON COLUMN citydb.unom5_commodity.voltage_range_to             IS 'Voltage range: max value';
COMMENT ON COLUMN citydb.unom5_commodity.voltage_range_uom            IS 'Unit of voltage';
COMMENT ON COLUMN citydb.unom5_commodity.voltage_nominal         	  IS 'Nominal voltage';
COMMENT ON COLUMN citydb.unom5_commodity.voltage_nominal_uom          IS 'Unit of measurement nominal voltage';
COMMENT ON COLUMN citydb.unom5_commodity.voltage_operating         	  IS 'Operating voltage';
COMMENT ON COLUMN citydb.unom5_commodity.voltage_operating_uom        IS 'Unit of measurement operating voltage';
COMMENT ON COLUMN citydb.unom5_commodity.amperage_range_from          IS 'Amperage range: min value';
COMMENT ON COLUMN citydb.unom5_commodity.amperage_range_to            IS 'Amperage range: max value';
COMMENT ON COLUMN citydb.unom5_commodity.amperage_range_uom           IS 'Unit of measurement amperage range';
COMMENT ON COLUMN citydb.unom5_commodity.bandwidth_range_from         IS 'Bandwidth range: min value';
COMMENT ON COLUMN citydb.unom5_commodity.bandwidth_range_to           IS 'Bandwidth range: max value';
COMMENT ON COLUMN citydb.unom5_commodity.bandwidth_range_uom          IS 'Unit of bandwidth';
COMMENT ON COLUMN citydb.unom5_commodity.optical_mode                 IS 'Optical mode';
COMMENT ON COLUMN citydb.unom5_commodity.phase_value                  IS 'Integer: single-phase, two-phase or three-phase';


----------------------------------------------------------------
-- Table COMMODITY_CLASSIFIER (FEATURE prototype)
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_commodity_classifier CASCADE;
CREATE TABLE         citydb.unom5_commodity_classifier (
	id                          serial PRIMARY KEY,
	objectclass_id              integer NOT NULL, 		-- FK citydb.objectclass (id)
	gmlid                       varchar,
	gmlid_codespace             varchar,
	name                        varchar,
	name_codespace              varchar,
	description                 text,
	mol_formula                 varchar,
	mol_weight                  numeric,
	mol_weight_unit             numeric,
	physical_form               varchar,
	signal_word                 varchar,  				-- FK unom5_lu_signal_word (id)
	is_chemical_complex         numeric(1),
	haz_class                   varchar,
	haz_class_category_code     varchar,
	haz_class_statement_code    varchar,
	haz_class_pictogram_code    varchar,
	haz_class_pictogram_uri     varchar,
	ec_number                   varchar,
	cas_number                  varchar,
	iuclid_chem_datasheet       varchar,
	commodity_id                integer,  				-- FK unom5_commodity (id)
	material_id                 integer,  				-- FK unom5_material (id)
	hollow_space_id             integer  				-- FK unom5_hollow_space (id)
);
CREATE INDEX unom5_comm_class_gmlid_inx         ON citydb.unom5_commodity_classifier USING btree (gmlid, gmlid_codespace);
CREATE INDEX unom5_comm_class_objclass_id_fkx   ON citydb.unom5_commodity_classifier USING btree (objectclass_id);
CREATE INDEX unom5_comm_class_comm_id_fkx       ON citydb.unom5_commodity_classifier USING btree (commodity_id);
CREATE INDEX unom5_comm_class_mat_id_fkx        ON citydb.unom5_commodity_classifier USING btree (material_id);
CREATE INDEX unom5_comm_class_hollow_spc_id_fkx ON citydb.unom5_commodity_classifier USING btree (hollow_space_id);

CREATE INDEX unom5_comm_class_signal_word_fkx ON citydb.unom5_commodity_classifier USING btree (signal_word);

COMMENT ON TABLE citydb.unom5_commodity_classifier IS 'Commodity classifier';

COMMENT ON COLUMN citydb.unom5_commodity_classifier.id                        IS 'ID';
COMMENT ON COLUMN citydb.unom5_commodity_classifier.objectclass_id            IS 'Objectclass ID of the commodity classifier';
COMMENT ON COLUMN citydb.unom5_commodity_classifier.gmlid                     IS 'Gml ID';
COMMENT ON COLUMN citydb.unom5_commodity_classifier.gmlid_codespace           IS 'Gml ID codespace';
COMMENT ON COLUMN citydb.unom5_commodity_classifier.name                      IS 'Name';
COMMENT ON COLUMN citydb.unom5_commodity_classifier.name_codespace            IS 'Name codespace';
COMMENT ON COLUMN citydb.unom5_commodity_classifier.description               IS 'Description';
COMMENT ON COLUMN citydb.unom5_commodity_classifier.mol_formula               IS 'Molecular formula';
COMMENT ON COLUMN citydb.unom5_commodity_classifier.mol_weight                IS 'Molecular weigth';
COMMENT ON COLUMN citydb.unom5_commodity_classifier.mol_weight_unit           IS 'Unit of molecular weight';
COMMENT ON COLUMN citydb.unom5_commodity_classifier.physical_form             IS 'Phisical form';
COMMENT ON COLUMN citydb.unom5_commodity_classifier.signal_word               IS 'Signal word';
COMMENT ON COLUMN citydb.unom5_commodity_classifier.is_chemical_complex       IS 'Is a chemical complex?	';
COMMENT ON COLUMN citydb.unom5_commodity_classifier.haz_class                 IS 'Hazard class';
COMMENT ON COLUMN citydb.unom5_commodity_classifier.haz_class_category_code   IS 'Hazard class: category code';
COMMENT ON COLUMN citydb.unom5_commodity_classifier.haz_class_statement_code  IS 'Hazard class: statement code';
COMMENT ON COLUMN citydb.unom5_commodity_classifier.haz_class_pictogram_code  IS 'Hazard class: pictogram code';
COMMENT ON COLUMN citydb.unom5_commodity_classifier.haz_class_pictogram_uri   IS 'Hazard class: pictogram URI';
COMMENT ON COLUMN citydb.unom5_commodity_classifier.ec_number                 IS 'EC number';
COMMENT ON COLUMN citydb.unom5_commodity_classifier.cas_number                IS 'Cas number';
COMMENT ON COLUMN citydb.unom5_commodity_classifier.iuclid_chem_datasheet     IS 'IUCLID Chemical Datasheet';


----------------------------------------------------------------
-- Table COMM_CLASS_TO_COMM_CLASS
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_comm_class_to_comm_class CASCADE;
CREATE TABLE         citydb.unom5_comm_class_to_comm_class(
	comm_class_parent_id   integer NOT NULL,		-- FK unom5_commodity_classifier (id)
	comm_class_id          integer NOT NULL,		-- FK unom5_commodity_classifier (id)
	CONSTRAINT unom5_comm_class_to_comm_class_pk PRIMARY KEY (comm_class_parent_id, comm_class_id)
);
CREATE INDEX unom5_comm_class_to_comm_class_parent_class_id_fkx ON citydb.unom5_comm_class_to_comm_class USING btree (comm_class_parent_id);
CREATE INDEX unom5_comm_class_to_comm_class_class_id_fkx        ON citydb.unom5_comm_class_to_comm_class USING btree (comm_class_id);


----------------------------------------------------------------
-- Table MATERIAL (FEATURE prototype)
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_material CASCADE;
CREATE TABLE         citydb.unom5_material (
	id                			serial PRIMARY KEY,
	objectclass_id     			integer NOT NULL, 		-- FK citydb.objectclass (id)
	gmlid              			varchar,
	gmlid_codespace    			varchar,
	name               			varchar,
	name_codespace     			varchar,
	description        			text,
	type               			varchar,				--FK unom5_lu_material (id)
	specific_class				varchar,
	compressive_strength		numeric,
	compressive_strength_uom	varchar,
	ductility					numeric,
	ductility_uom				varchar,
	conductivity				numeric,
	conductivity_uom			varchar
);
CREATE INDEX unom5_mat_gmlid_inx         ON citydb.unom5_material USING btree (gmlid, gmlid_codespace);
CREATE INDEX unom5_mat_objclass_id_fkx   ON citydb.unom5_material USING btree (objectclass_id);

COMMENT ON TABLE citydb.unom5_material IS 'Material';

COMMENT ON COLUMN citydb.unom5_material.id                        IS 'ID';
COMMENT ON COLUMN citydb.unom5_material.objectclass_id            IS 'Objectclass ID of the material';
COMMENT ON COLUMN citydb.unom5_material.gmlid                     IS 'Gml ID';
COMMENT ON COLUMN citydb.unom5_material.gmlid_codespace           IS 'Gml ID codespace';
COMMENT ON COLUMN citydb.unom5_material.name                      IS 'Name';
COMMENT ON COLUMN citydb.unom5_material.name_codespace            IS 'Name codespace';
COMMENT ON COLUMN citydb.unom5_material.description               IS 'Description';
COMMENT ON COLUMN citydb.unom5_material.type                      IS 'Type of material';
COMMENT ON COLUMN citydb.unom5_material.specific_class            IS 'Specific subclass of the type of material chosen';
COMMENT ON COLUMN citydb.unom5_material.compressive_strength      IS 'Compressive strength of the material';
COMMENT ON COLUMN citydb.unom5_material.ductility                 IS 'Ductility measured in its yield strength';
COMMENT ON COLUMN citydb.unom5_material.conductivity              IS 'Ability of the material to conduct an electric current';


----------------------------------------------------------------
-- Table NETWORK_FEAT_TO_MATERIAL
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_network_feat_to_material CASCADE;
CREATE TABLE         citydb.unom5_network_feat_to_material (
	network_feature_id integer NOT NULL,		--FK unom5_network_feature (id)
	material_id integer NOT NULL,				--FK unom5_material (id)
	CONSTRAINT unom5_network_feat_to_material_pk PRIMARY KEY (network_feature_id, material_id)
);
CREATE INDEX unom5_ntw_feat_to_mat_ntw_feat_id_fkx ON citydb.unom5_network_feat_to_material USING btree (network_feature_id);
CREATE INDEX unom5_ntw_feat_to_mat_mat_id_fkx ON citydb.unom5_network_feat_to_material USING btree (material_id);


----------------------------------------------------------------
-- Table HOLLOW_SPACE (FEATURE prototype)
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_hollow_space CASCADE;
CREATE TABLE         citydb.unom5_hollow_space (
	id                 serial PRIMARY KEY,
	objectclass_id     integer NOT NULL,  		-- FK citydb.objectclass (id)
	hol_spc_parent_id  integer,  				-- FK unom5_hollow_Space (id)
	hol_spc_root_id    integer,  				-- FK unom5_hollow_Space (id)
	gmlid              varchar,
	gmlid_codespace    varchar,
	name               varchar,
	name_codespace     varchar,
	description        text,
-- OTHER ATTRIBUTES ?	
	ntw_feature_id     integer  				-- FK unom5_network_feature (id)
);
CREATE INDEX unom5_hollow_spc_gmlid_inx         ON citydb.unom5_hollow_space USING btree (gmlid, gmlid_codespace);
CREATE INDEX unom5_hollow_spc_objclass_id_fkx   ON citydb.unom5_hollow_space USING btree (objectclass_id);
CREATE INDEX unom5_hollow_spc_ntw_feat_id_fkx   ON citydb.unom5_hollow_space USING btree (ntw_feature_id);

COMMENT ON TABLE citydb.unom5_hollow_space IS 'Hollow space';

COMMENT ON COLUMN citydb.unom5_hollow_space.id              IS 'ID';
COMMENT ON COLUMN citydb.unom5_hollow_space.objectclass_id  IS 'Objectclass ID of the hollow space';
COMMENT ON COLUMN citydb.unom5_hollow_space.gmlid           IS 'Gml ID';
COMMENT ON COLUMN citydb.unom5_hollow_space.gmlid_codespace IS 'Gml ID codespace';
COMMENT ON COLUMN citydb.unom5_hollow_space.name            IS 'Name';
COMMENT ON COLUMN citydb.unom5_hollow_space.name_codespace  IS 'Name codespace';
COMMENT ON COLUMN citydb.unom5_hollow_space.description     IS 'Description';


-- ******************************************************************************************************************************************************************************************************************************
-- ******************************************************************************************************************************************************************************************************************************
-- B2) NEW MAIN TABLES FOR O&M EXTENSION

----------------------------------------------------------------
-- Table FEATURE_GRAPH_TO_NETWORK_GRAPH
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_feature_graph_to_network_graph CASCADE;
CREATE TABLE         citydb.unom5_feature_graph_to_network_graph (
	feature_graph_id   		integer NOT NULL,		-- FK unom5_feature_graph (id)
	network_graph_id        integer NOT NULL,		-- FK unom5_network_graph (id)
	CONSTRAINT unom5_feature_graph_to_network_graph_pk PRIMARY KEY (feature_graph_id, network_graph_id)
);
CREATE INDEX unom5_feature_graph_to_network_graph_feature_graph_id_fkx ON citydb.unom5_feature_graph_to_network_graph 	USING btree (feature_graph_id);
CREATE INDEX unom5_feature_graph_to_network_graph_network_graph_id_fkx ON citydb.unom5_feature_graph_to_network_graph 	USING btree (network_graph_id);


----------------------------------------------------------------
-- Table MEASURED_DEPTH  (dataType)
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_measured_depth CASCADE;
CREATE TABLE         citydb.unom5_measured_depth (
	id								serial PRIMARY KEY,
	depth_level_measurement			numeric,
	depth_level_measurement_uom		varchar,
	depth_reference_level			varchar,			-- FK unom5_lu_depth_reference_level (id)
	depth_point_of_measurement		varchar,			-- FK unom5_lu_depth_point_of_measurement (id)
	depth_quality					varchar,			-- FK unom5_lu_spatial_quality (id)
	depth_accuracy					varchar,			-- FK unom5_lu_depth_accuracy_value (id)
	location_of_measurement			geometry(POINTZ),
	date_of_depth_measurement		date,
	ntw_feature_id					integer				-- FK unom5_network_feature (id)
);
CREATE INDEX unom5_measured_depth_ntw_feature_id_fkx    ON citydb.unom5_measured_depth USING btree (ntw_feature_id);
CREATE INDEX unom5_measured_depth_location_spx 			ON citydb.unom5_measured_depth USING gist (location_of_measurement gist_geometry_ops_nd);

COMMENT ON TABLE citydb.unom5_measured_depth IS 'Measured depth of the feature';

COMMENT ON COLUMN citydb.unom5_measured_depth.depth_level_measurement		IS 'Quantity';
COMMENT ON COLUMN citydb.unom5_measured_depth.depth_reference_level			IS 'Reference level used';
COMMENT ON COLUMN citydb.unom5_measured_depth.depth_point_of_measurement	IS 'Part of the feature where the depth was measured';
COMMENT ON COLUMN citydb.unom5_measured_depth.depth_quality					IS 'Quality of measurement';
COMMENT ON COLUMN citydb.unom5_measured_depth.depth_accuracy				IS 'Accuracy of measurement';
COMMENT ON COLUMN citydb.unom5_measured_depth.location_of_measurement		IS 'Point location (coordinates)';
COMMENT ON COLUMN citydb.unom5_measured_depth.date_of_depth_measurement		IS 'Date';
COMMENT ON COLUMN citydb.unom5_measured_depth.ntw_feature_id				IS 'Associated to a network feature';


----------------------------------------------------------------
-- Table UNOM_CITY_OBJECT (_CityObject)
----------------------------------------------------------------

-- FF: NO LONGER NECESSARY. IT WAS HERE ONLY BECAUSE OF RELATIVE TO TERRAIN 
-- BUT THAT ATTRIBUTE WAS IN FACT REPEATED. IT IS ORIGINALLY IN CITYOBJECT.

--DROP TABLE IF EXISTS citydb.unom5_city_object CASCADE;
--CREATE TABLE         citydb.unom5_city_object (
--	id                  	integer PRIMARY KEY,		-- FK citydb.cityobject (id)
--	objectclass_id      	integer NOT NULL, 	  		-- FK citydb.objectclass (id)
--	relative_to_terrain     varchar						-- FK unom5_lu_relative_to_terrain (id)
--);
--CREATE INDEX unom5_city_object_objclass_id_fkx ON citydb.unom5_city_object USING btree (objectclass_id);
--
--COMMENT ON TABLE citydb.unom5_city_object IS 'Extension of the CITY_OBJECT table for the UtilityNetworks ADE';
--
--COMMENT ON COLUMN citydb.unom5_city_object.relative_to_terrain 	IS 'Position relative to the terrain';


----------------------------------------------------------------
-- Table FUNCTIONAL_COMPONENT (_CityObject)
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_functional_component CASCADE;
CREATE TABLE         citydb.unom5_functional_component (
	id							integer PRIMARY KEY,		-- FK unom5_network_feature (id) -> which is a FK to citydb.cityobject (id)
	objectclass_id				integer NOT NULL, 	  		-- FK citydb.objectclass (id)
	func_comp_parent_id			integer,					-- FK unom5_functional_component (id)
	func_comp_root_id			integer,					-- FK unom5_functional_component (id)
	is_active					numeric(1),
	neutral_earth_connection	numeric(1),
	connection_mode				varchar,
	preferred_mode				varchar,
	actual_mode					varchar,
	rotational_direction		varchar,
	number_of_rotations			integer		
--	storage_id					integer						-- FK unom5_storage (id). Reversed the relation for dependency's sake.
);			
CREATE INDEX unom5_functional_component_objectclass_id_fkx    ON citydb.unom5_functional_component USING btree (objectclass_id);
--CREATE INDEX unom5_functional_component_storage_id_fkx  	  ON citydb.unom5_functional_component USING btree (storage_id);

COMMENT ON TABLE citydb.unom5_functional_component IS 'Functional components (appurtenances, devices, stations, etc.)';

COMMENT ON COLUMN citydb.unom5_functional_component.func_comp_parent_id			IS 'Complex functional components can have components';
COMMENT ON COLUMN citydb.unom5_functional_component.func_comp_root_id			IS 'Root element';
COMMENT ON COLUMN citydb.unom5_functional_component.is_active					IS 'Boolean: is the component active?';
COMMENT ON COLUMN citydb.unom5_functional_component.neutral_earth_connection	IS 'Boolean: does the component have an earth connection?';
COMMENT ON COLUMN citydb.unom5_functional_component.connection_mode				IS '';
COMMENT ON COLUMN citydb.unom5_functional_component.preferred_mode				IS 'Open, closed, on or off';
COMMENT ON COLUMN citydb.unom5_functional_component.actual_mode					IS 'Open, closed, on or off';
COMMENT ON COLUMN citydb.unom5_functional_component.rotational_direction		IS 'Opening direction of the rotating element (flow control)';
COMMENT ON COLUMN citydb.unom5_functional_component.number_of_rotations			IS 'Number of rotations to fully open control element (flow control)';
--COMMENT ON COLUMN citydb.unom5_functional_component.storage_id					IS 'Reference to storage dataType';


----------------------------------------------------------------
-- Table RELATED_PARTY
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_related_party CASCADE;
CREATE TABLE         citydb.unom5_related_party (
	id								serial PRIMARY KEY,
	objectclass_id					integer NOT NULL,		-- FK citydb.objectclass (id)
	gmlid							varchar,
	gmlid_codespace					varchar,
	name							varchar,
	name_codespace					varchar,
	description						text,
	individual_name					varchar,
	organisation_name				varchar,
	role							varchar,				-- FK unom5_lu_party_role (id)
	contact_instruction				varchar,
	email_address					varchar,
	hours_of_service				varchar,
	telephone_facsimile				varchar,
	telephone_voice_organisation	varchar,
	telephone_voice_individual		varchar,
	website							varchar,
	coc_number						varchar,
	address_id						integer					--FK unom5_address (id)
);	
CREATE INDEX unom5_related_party_gmlid_inx         		ON citydb.unom5_related_party USING btree (gmlid, gmlid_codespace);
CREATE INDEX unom5_related_party_objectclass_id_fkx     ON citydb.unom5_related_party USING btree (objectclass_id);
CREATE INDEX unom5_related_party_role_fkx    			ON citydb.unom5_related_party USING btree (role);
CREATE INDEX unom5_related_party_address_id_fkx     	ON citydb.unom5_related_party USING btree (address_id);

COMMENT ON TABLE citydb.unom5_related_party IS 'Related party';

COMMENT ON COLUMN citydb.unom5_related_party.individual_name				IS 'Name of associated individual within the related party';
COMMENT ON COLUMN citydb.unom5_related_party.organisation_name				IS 'Name of the organisation (related party)';
COMMENT ON COLUMN citydb.unom5_related_party.role							IS 'Role in the network of the related party';
COMMENT ON COLUMN citydb.unom5_related_party.contact_instruction			IS 'Instruction when contacting related party';
COMMENT ON COLUMN citydb.unom5_related_party.email_address					IS 'Email';
COMMENT ON COLUMN citydb.unom5_related_party.hours_of_service				IS 'Hours of service';
COMMENT ON COLUMN citydb.unom5_related_party.telephone_facsimile			IS 'Fax number';
COMMENT ON COLUMN citydb.unom5_related_party.telephone_voice_organisation	IS 'Organisational telephone number';
COMMENT ON COLUMN citydb.unom5_related_party.telephone_voice_individual		IS 'Individual telephone number';
COMMENT ON COLUMN citydb.unom5_related_party.website						IS 'Website';
COMMENT ON COLUMN citydb.unom5_related_party.coc_number						IS 'Chamber of Commerce number';
COMMENT ON COLUMN citydb.unom5_related_party.address_id						IS 'The associated address of the related party';


----------------------------------------------------------------
-- Table ADDRESS => REPLACED BY THE CITYGML TABLE!
----------------------------------------------------------------
--ROP TABLE IF EXISTS citydb.unom5_address CASCADE;
--REATE TABLE         citydb.unom5_address (
--	id						serial PRIMARY KEY,
--	country_code			varchar,
--	post_name				varchar,
--	post_code				varchar,
--	house_number			varchar,
--	house_letter			varchar,
--	house_number_addition	varchar
--;	
--
--OMMENT ON TABLE citydb.unom5_address IS 'Address representation';


----------------------------------------------------------------
-- Table RELATED_PARTY_TO_NETWORK
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_related_party_to_network CASCADE;
CREATE TABLE         citydb.unom5_related_party_to_network (
	party_id   		integer NOT NULL,		-- FK unom5_related_party (id)
	network_id      integer NOT NULL,		-- FK unom5_network (id)
	CONSTRAINT unom5_related_party_to_network_pk PRIMARY KEY (party_id, network_id)
);
CREATE INDEX unom5_related_party_to_network_party_id_fkx 	ON citydb.unom5_related_party_to_network 	USING btree (party_id);
CREATE INDEX unom5_related_party_to_network_network_id_fkx  ON citydb.unom5_related_party_to_network 	USING btree (network_id);


----------------------------------------------------------------
-- Table RELATED_PARTY_TO_NETWORK_FEATURE
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_related_party_to_network_feature CASCADE;
CREATE TABLE         citydb.unom5_related_party_to_network_feature (
	party_id   				integer NOT NULL,		-- FK unom5_related_party (id)
	network_feature_id      integer NOT NULL,		-- FK unom5_network_feature (id)
	CONSTRAINT unom5_related_party_to_network_feature_pk PRIMARY KEY (party_id, network_feature_id)
);
CREATE INDEX unom5_related_party_to_network_feature_party_id_fkx			ON citydb.unom5_related_party_to_network_feature 	USING btree (party_id);
CREATE INDEX unom5_related_party_to_network_feature_network_feature_id_fkx  ON citydb.unom5_related_party_to_network_feature 	USING btree (network_feature_id);


----------------------------------------------------------------
-- Table RELATED_PARTY_TO_MAINTENANCE_ACTIVITY
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_related_party_to_maintenance_activity CASCADE;
CREATE TABLE         citydb.unom5_related_party_to_maintenance_activity (
	 party_id  						integer NOT NULL,		-- FK unom5_related_party (id)
	 maintenance_activity_id        integer NOT NULL,		-- FK unom5_maintenance_activity (id)
	CONSTRAINT unom5_related_party_to_maintenance_activity_pk PRIMARY KEY (party_id, maintenance_activity_id)
);
CREATE INDEX unom5_related_party_to_maint_activity_party_id_fkx 			ON citydb.unom5_related_party_to_maintenance_activity 	USING btree (party_id);
CREATE INDEX unom5_related_party_to_maint_activity_maint_activity_id_fkx 	ON citydb.unom5_related_party_to_maintenance_activity 	USING btree (maintenance_activity_id);


----------------------------------------------------------------
-- Table SOIL_AND_GROUNDWATER  (dataType)
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_soil_and_groundwater CASCADE;
CREATE TABLE         citydb.unom5_soil_and_groundwater (
	id								serial PRIMARY KEY,
	type							varchar,				-- FK unom5_lu_soil (id)
	reactivity						numeric,
	reactivity_uom					varchar,
	permeability					numeric,
	permeability_uom				varchar,
	strength						numeric,
	strength_uom					varchar,
	density							numeric,
	density_uom						varchar,
	moisture_content				numeric CHECK (moisture_content BETWEEN 0 AND 1),
	groundwater_real_time			numeric(1),
	groundwater_level				numeric,
	groundwater_level_uom			varchar,
	groundwater_reference_level		varchar,					-- FK unom5_lu_groundwater_reference (id)
	ntw_feature_id					integer						-- FK unom5_network_feature (id)	
);	
CREATE INDEX unom5_soil_and_groundwater_type_fkx				ON citydb.unom5_soil_and_groundwater USING btree (type);
CREATE INDEX unom5_soil_and_groundwater_ntw_feature_id_fkx		ON citydb.unom5_soil_and_groundwater USING btree (ntw_feature_id);

COMMENT ON TABLE citydb.unom5_soil_and_groundwater IS 'Soil and groundwater';

COMMENT ON COLUMN citydb.unom5_soil_and_groundwater.type							IS 'Type of soil';
COMMENT ON COLUMN citydb.unom5_soil_and_groundwater.reactivity						IS 'Rate at which substances tend to undergo a chemical reaction';
COMMENT ON COLUMN citydb.unom5_soil_and_groundwater.permeability					IS 'Ability of the material (such as soil) to transmit fluids';
COMMENT ON COLUMN citydb.unom5_soil_and_groundwater.strength						IS 'Strength of material measured in its compressive strength';
COMMENT ON COLUMN citydb.unom5_soil_and_groundwater.density							IS 'Mass of particles of the material divided by the volume they occupy';
COMMENT ON COLUMN citydb.unom5_soil_and_groundwater.moisture_content				IS 'Quantity of water contained in a material (such as soil)';
COMMENT ON COLUMN citydb.unom5_soil_and_groundwater.groundwater_real_time			IS 'Indicating whether the groundwater level is real time';
COMMENT ON COLUMN citydb.unom5_soil_and_groundwater.groundwater_level				IS 'Level of the groundwater';
COMMENT ON COLUMN citydb.unom5_soil_and_groundwater.groundwater_reference_level		IS 'Reference level to which the ground water level is measured perpendicular to';
COMMENT ON COLUMN citydb.unom5_soil_and_groundwater.ntw_feature_id					IS 'Associated network feature';


----------------------------------------------------------------
-- Table MAINTENANCE_ACTIVITY
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_maintenance_activity CASCADE;
CREATE TABLE         citydb.unom5_maintenance_activity (
	id						serial PRIMARY KEY,
	objectclass_id			integer NOT NULL,		-- FK citydb.objectclass (id)
	gmlid					varchar,
	gmlid_codespace			varchar,
	name					varchar,
	name_codespace			varchar,
	description				text,
	maintenance_timeline	varchar,				-- FK unom5_lu_maintenance_timeline_type (id)
	maintenance_type		varchar,				-- FK unom5_lu_maintenance_type (id)
	activity_type			varchar,				-- FK unom5_lu_maintenance_activity_type (id)
	extra_information		varchar,
	start_date				date,
	end_date				date
);
CREATE INDEX unom5_maintenance_activity_gmlid_inx     			    ON citydb.unom5_maintenance_activity USING btree (gmlid, gmlid_codespace);
CREATE INDEX unom5_maintenance_activity_objectclass_id_fkx			ON citydb.unom5_maintenance_activity USING btree (objectclass_id);
CREATE INDEX unom5_maintenance_activity_maintenance_timeline_fkx	ON citydb.unom5_maintenance_activity USING btree (maintenance_timeline);
CREATE INDEX unom5_maintenance_activity_maintenance_type_fkx		ON citydb.unom5_maintenance_activity USING btree (maintenance_type);
CREATE INDEX unom5_maintenance_activity_activity_type_fkx			ON citydb.unom5_maintenance_activity USING btree (activity_type);

COMMENT ON TABLE citydb.unom5_maintenance_activity IS 'Maintenance activity';

COMMENT ON COLUMN citydb.unom5_maintenance_activity.maintenance_timeline	IS 'Last / current / planned maintenance';
COMMENT ON COLUMN citydb.unom5_maintenance_activity.maintenance_type		IS 'Corrective / preventive / predictive / prescriptive maintenance';
COMMENT ON COLUMN citydb.unom5_maintenance_activity.activity_type			IS 'Inspection / surveilance / rehabilitation / replacement / other activity';
COMMENT ON COLUMN citydb.unom5_maintenance_activity.extra_information		IS 'Reference to documents';


----------------------------------------------------------------
-- Table NETWORK_FEATURE_TO_MAINTENANCE_ACTIVITY
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_network_feature_to_maintenance_activity CASCADE;
CREATE TABLE         citydb.unom5_network_feature_to_maintenance_activity (
	 network_feature_id  			integer NOT NULL,		-- FK unom5_network_feature (id)
	 maintenance_activity_id        integer NOT NULL,		-- FK unom5_maintenance_activity (id)
	CONSTRAINT unom5_network_feature_to_maintenance_activity_pk PRIMARY KEY (network_feature_id, maintenance_activity_id)
);
CREATE INDEX unom5_ntw_feat_to_maint_activity_network_feature_id_fkx 	ON citydb.unom5_network_feature_to_maintenance_activity 	USING btree (network_feature_id);
CREATE INDEX unom5_ntw_feat_to_maint_activity_maint_activity_id_fkx 	ON citydb.unom5_network_feature_to_maintenance_activity 	USING btree (maintenance_activity_id);


----------------------------------------------------------------
-- Table COST  (dataType)
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_cost CASCADE;
CREATE TABLE         citydb.unom5_cost (
	id								serial PRIMARY KEY,
	cost_type						varchar,				-- FK unom5_lu_cost_type (id)
	currency						varchar,
	total_costs						numeric,
	costs_per_unit					numeric,
	unit_of_measurement				varchar,
	network_feature_id				integer,				-- FK unom5_network_feature (id)
	maintenance_activity_id			integer					-- FK unom5_maintenance_activity (id)
);
CREATE INDEX unom5_cost_cost_type_fkx					ON citydb.unom5_cost USING btree (cost_type);
CREATE INDEX unom5_cost_network_feature_id_fkx			ON citydb.unom5_cost USING btree (network_feature_id);
CREATE INDEX unom5_cost_maintenance_activity_id_fkx		ON citydb.unom5_cost USING btree (maintenance_activity_id);

COMMENT ON TABLE citydb.unom5_cost IS 'Costs';

COMMENT ON COLUMN citydb.unom5_cost.cost_type				IS 'Type of cost';
COMMENT ON COLUMN citydb.unom5_cost.currency				IS 'Currency';
COMMENT ON COLUMN citydb.unom5_cost.total_costs				IS 'Total costs for the component as a whole';
COMMENT ON COLUMN citydb.unom5_cost.costs_per_unit			IS 'Coosts for a single unit of the component (unitary cost)';
COMMENT ON COLUMN citydb.unom5_cost.unit_of_measurement		IS 'Unit against which the (unitary) costs are measured and calculated';
COMMENT ON COLUMN citydb.unom5_cost.network_feature_id		IS 'Associated network feature';
COMMENT ON COLUMN citydb.unom5_cost.maintenance_activity_id	IS 'Associated maintenance activity';


----------------------------------------------------------------
-- Table IMPACT
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_impact CASCADE;
CREATE TABLE         citydb.unom5_impact (
	id								serial PRIMARY KEY,
	objectclass_id					integer NOT NULL,		-- FK citydb.objectclass (id)
	gmlid							varchar,
	gmlid_codespace					varchar,
	name							varchar,
	name_codespace					varchar,
	description						text,
	environm_impact_score			numeric,
	environm_impact_extra_info		varchar,
	social_impact_score				numeric,
	social_impact_extra_info		varchar,
	economic_impact_score			numeric,
	economic_impact_extra_info		varchar
--	network_id						integer,  				-- FK unom5_network (id) . Referenced in network instead.
--	feature_id						integer					-- FK unom5_network_feature (id) Referenced in network_feaature instead.
);
CREATE INDEX unom5_impact_gmlid_inx       			ON citydb.unom5_impact USING btree (gmlid, gmlid_codespace);
CREATE INDEX unom5_impact_objectclass_id_fkx		ON citydb.unom5_impact USING btree (objectclass_id);
-- CREATE INDEX unom5_impact_network_id_fkx			ON citydb.unom5_impact USING btree (network_id);
-- CREATE INDEX unom5_impact_feature_id_fkx 			ON citydb.unom5_impact USING btree (feature_id);

COMMENT ON TABLE citydb.unom5_impact IS 'Impact of the network and network features';

COMMENT ON COLUMN citydb.unom5_impact.environm_impact_score			IS 'Relative score of the environmental impact';
COMMENT ON COLUMN citydb.unom5_impact.environm_impact_extra_info	IS 'Repository with additional information';
COMMENT ON COLUMN citydb.unom5_impact.social_impact_score			IS 'Relative score of the social impact';
COMMENT ON COLUMN citydb.unom5_impact.social_impact_extra_info		IS 'Repository with additional information';
COMMENT ON COLUMN citydb.unom5_impact.economic_impact_score			IS 'Relative score of the economic impact';
COMMENT ON COLUMN citydb.unom5_impact.economic_impact_extra_info	IS 'Repository with additional information';
--COMMENT ON COLUMN citydb.unom5_impact.network_id					IS 'Associated network';
--COMMENT ON COLUMN citydb.unom5_impact.feature_id					IS 'Associated feature';


----------------------------------------------------------------
-- Table PERFORMANCE
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_performance CASCADE;
CREATE TABLE         citydb.unom5_performance (
	id								serial PRIMARY KEY,
	objectclass_id					integer NOT NULL,		-- FK citydb.objectclass (id)
	gmlid							varchar,
	gmlid_codespace					varchar,
	name							varchar,
	name_codespace					varchar,
	description						text,
	performance_type				varchar,				-- FK unom5_lu_performance_type (id)
	performance_requirement			varchar,
	performance_score				numeric,
	is_sufficient					numeric(1),
	date_of_performance_measuring	date,
	extra_information				varchar,
	network_id						integer,				-- FK unom5_network (id)
	feature_id						integer					-- FK unom5_network_feature (id)
);
CREATE INDEX unom5_performance_gmlid_inx         	ON citydb.unom5_performance USING btree (gmlid, gmlid_codespace);
CREATE INDEX unom5_performance_objectclass_id_fkx	ON citydb.unom5_performance USING btree (objectclass_id);
CREATE INDEX unom5_performance_performance_type_fkx	ON citydb.unom5_performance USING btree (performance_type);
CREATE INDEX unom5_performance_network_id_fkx		ON citydb.unom5_performance USING btree (network_id);
CREATE INDEX unom5_performance_feature_id_fkx		ON citydb.unom5_performance USING btree (feature_id);

COMMENT ON TABLE citydb.unom5_performance IS 'Performance of the network and network features';

COMMENT ON COLUMN citydb.unom5_performance.performance_type					IS 'Engineering / serviceability / safety / financial / sustainability performance';
COMMENT ON COLUMN citydb.unom5_performance.performance_requirement			IS 'Required performance score';
COMMENT ON COLUMN citydb.unom5_performance.performance_score				IS 'Actual performance score';
COMMENT ON COLUMN citydb.unom5_performance.is_sufficient					IS 'Boolean: Is performance sufficient?';
COMMENT ON COLUMN citydb.unom5_performance.date_of_performance_measuring	IS 'Date';
COMMENT ON COLUMN citydb.unom5_performance.extra_information				IS 'Repository with additional information';
COMMENT ON COLUMN citydb.unom5_performance.network_id						IS 'Associated network';
COMMENT ON COLUMN citydb.unom5_performance.feature_id						IS 'Associated feature';


----------------------------------------------------------------
-- Table DIMENSIONS  (dataType)
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_dimensions CASCADE;
CREATE TABLE         citydb.unom5_dimensions (
	id						serial PRIMARY KEY,
	feature_id				integer,				-- FK unom5_network_feature (id)
	shape					varchar,				-- FK unom5_lu_shape (id)
	wall_thickness			numeric,
	wall_thinkness_uom		varchar,
	exterior_width			numeric,
	exterior_width_uom		varchar,
	exterior_height			numeric,
	exterior_height_uom		varchar,
	exterior_diameter		numeric,
	exterior_diameter_uom	varchar,
	exterior_length			numeric,
	exterior_length_uom		varchar,
	interior_width			numeric,
	interior_width_uom		varchar,
	interior_height			numeric,
	interior_height_uom		varchar,
	interior_diameter		numeric,
	interior_diameter_uom	varchar,
	interior_length			numeric,
	interior_length_uom		varchar
);
CREATE INDEX unom5_dimensions_feature_id_fkx ON citydb.unom5_dimensions USING btree (feature_id);
CREATE INDEX unom5_dimensions_shape_fkx		 ON citydb.unom5_dimensions USING btree (shape);

COMMENT ON TABLE citydb.unom5_dimensions IS 'Dimensions of the network features';

COMMENT ON COLUMN citydb.unom5_dimensions.shape		    		IS 'Shape';
COMMENT ON COLUMN citydb.unom5_dimensions.wall_thickness   		IS 'Wall thickness';
COMMENT ON COLUMN citydb.unom5_dimensions.exterior_width	   	IS 'Exterior width';
COMMENT ON COLUMN citydb.unom5_dimensions.exterior_height	   	IS 'Exterior height';
COMMENT ON COLUMN citydb.unom5_dimensions.exterior_diameter   	IS 'Exterior diameter';
COMMENT ON COLUMN citydb.unom5_dimensions.exterior_length		IS 'Exterior length';
COMMENT ON COLUMN citydb.unom5_dimensions.interior_width	    IS 'Interior width';
COMMENT ON COLUMN citydb.unom5_dimensions.interior_height	   	IS 'Interior height';
COMMENT ON COLUMN citydb.unom5_dimensions.interior_diameter   	IS 'Interior diameter';
COMMENT ON COLUMN citydb.unom5_dimensions.interior_length		IS 'Interior length';


----------------------------------------------------------------
-- Table IDENTIFICATION  (dataType)
----------------------------------------------------------------
DROP TABLE IF EXISTS citydb.unom5_identification CASCADE;
CREATE TABLE         citydb.unom5_identification (
	id					serial PRIMARY KEY,
	feature_id			integer,				-- FK unom5_network_feature (id)
	identifier			varchar,
	identifier_type		varchar,				-- FK unom5_lu_identifier_type (id) 
	colour				varchar,
	address_id			integer,				-- FK unom5_address (id)
	is_label_visible	numeric(1),
	label_location		varchar
);
CREATE INDEX unom5_identification_feature_id_fkx ON citydb.unom5_identification USING btree (feature_id);
CREATE INDEX unom5_identification_ident_type_fkx ON citydb.unom5_identification USING btree (identifier_type);
CREATE INDEX unom5_identification_address_id_fkx ON citydb.unom5_identification USING btree (address_id);

COMMENT ON TABLE citydb.unom5_dimensions IS 'Identification of the network features';

COMMENT ON COLUMN citydb.unom5_identification.identifier		    IS 'Unique identifier';
COMMENT ON COLUMN citydb.unom5_identification.identifier_type		IS 'Identifier type';
COMMENT ON COLUMN citydb.unom5_identification.colour				IS 'Colour';
COMMENT ON COLUMN citydb.unom5_identification.address_id			IS 'Some features (like stations) can have an address';
COMMENT ON COLUMN citydb.unom5_identification.is_label_visible		IS 'Is label visible?';
COMMENT ON COLUMN citydb.unom5_identification.label_location		IS 'Location of the label';


-- ******************************************************************************************************************************************************************************************************************************
-- ******************************************************************************************************************************************************************************************************************************
-- ******************************************************************************************************************************************************************************************************************************
-- ******************************************************************************************************************************************************************************************************************************
-- C) FOREIGN KEY(S) CONSTRAINTS ON MAIN TABLES

--**************
--NETWORK
--CityGML
ALTER TABLE IF EXISTS citydb.unom5_network ADD CONSTRAINT unom5_ntw_cityobj_fk FOREIGN KEY (id) REFERENCES citydb.cityobject (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;
ALTER TABLE IF EXISTS citydb.unom5_network ADD CONSTRAINT unom5_ntw_objclass_fk FOREIGN KEY (objectclass_id) REFERENCES citydb.objectclass (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;
--UNOM5_Main
ALTER TABLE IF EXISTS citydb.unom5_network ADD CONSTRAINT unom5_ntw_ntw_fk1 FOREIGN KEY (network_parent_id) REFERENCES citydb.unom5_network (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;
ALTER TABLE IF EXISTS citydb.unom5_network ADD CONSTRAINT unom5_ntw_ntw_fk2 FOREIGN KEY (network_root_id) REFERENCES citydb.unom5_network (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;
ALTER TABLE IF EXISTS citydb.unom5_network ADD CONSTRAINT unom5_ntw_comm_fk FOREIGN KEY (commodity_id) REFERENCES citydb.unom5_commodity (id) MATCH FULL ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE IF EXISTS citydb.unom5_network ADD CONSTRAINT unom5_ntw_impact_fk FOREIGN KEY (impact_id) REFERENCES citydb.unom5_impact (id) MATCH FULL ON UPDATE CASCADE ON DELETE SET NULL;

--UNOM5_LookUp
ALTER TABLE IF EXISTS citydb.unom5_network ADD CONSTRAINT unom5_ntw_ntw_class_fk FOREIGN KEY (class) REFERENCES citydb.unom5_lu_network_class (id) MATCH FULL ON UPDATE CASCADE ON DELETE SET NULL;


--**************
--NETWORK_TO_NETWORK
--UNOM5_Main
ALTER TABLE IF EXISTS citydb.unom5_network_to_network ADD CONSTRAINT unom5_ntw_to_ntw_super_fk FOREIGN KEY (superordinate_network_id) REFERENCES citydb.unom5_network (id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE IF EXISTS citydb.unom5_network_to_network ADD CONSTRAINT unom5_ntw_to_ntw_sub_fk FOREIGN KEY (subordinate_network_id) REFERENCES citydb.unom5_network (id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--**************
--NETWORK_TO_SUPPLY_AREA
--CityGML
ALTER TABLE IF EXISTS citydb.unom5_network_to_supply_area ADD CONSTRAINT unom5_ntw_to_supp_area_sup_fk FOREIGN KEY (supply_area_id) REFERENCES citydb.cityobjectgroup (id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;
--UNOM5_Main
ALTER TABLE IF EXISTS citydb.unom5_network_to_supply_area ADD CONSTRAINT unom5_ntw_to_supp_area_ntw_fk FOREIGN KEY (network_id) REFERENCES citydb.unom5_network (id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--**************
--NETWORK_FEATURE
--CityGML
ALTER TABLE IF EXISTS citydb.unom5_network_feature ADD CONSTRAINT unom5_ntw_feat_cityobj_fk1 FOREIGN KEY (id) REFERENCES citydb.cityobject (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;
ALTER TABLE IF EXISTS citydb.unom5_network_feature ADD CONSTRAINT unom5_ntw_feat_cityobj_fk2 FOREIGN KEY (conn_cityobject_id) REFERENCES citydb.cityobject (id) MATCH FULL ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE IF EXISTS citydb.unom5_network_feature ADD CONSTRAINT unom5_ntw_feat_objclass_fk FOREIGN KEY (objectclass_id) REFERENCES citydb.objectclass (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;
--UNOM5_Main
ALTER TABLE IF EXISTS citydb.unom5_network_feature ADD CONSTRAINT unom5_ntw_feat_ntw_feat_fk1 FOREIGN KEY (ntw_feature_parent_id) REFERENCES citydb.unom5_network_feature (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;
ALTER TABLE IF EXISTS citydb.unom5_network_feature ADD CONSTRAINT unom5_ntw_feat_ntw_feat_fk2 FOREIGN KEY (ntw_feature_root_id) REFERENCES citydb.unom5_network_feature (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;
ALTER TABLE IF EXISTS citydb.unom5_network_feature ADD CONSTRAINT unom5_ntw_feat_prot_elem_fk FOREIGN KEY (prot_element_id) REFERENCES citydb.unom5_protective_element (id) MATCH FULL ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE IF EXISTS citydb.unom5_network_feature ADD CONSTRAINT unom5_ntw_feat_impact_fk FOREIGN KEY (impact_id) REFERENCES citydb.unom5_impact (id) MATCH FULL ON UPDATE CASCADE ON DELETE SET NULL;
--UNOM5_LookUp
ALTER TABLE IF EXISTS citydb.unom5_network_feature ADD CONSTRAINT unom5_ntw_feat_function_fk FOREIGN KEY (function) REFERENCES citydb.unom5_lu_network_feature_function (id) MATCH FULL ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE IF EXISTS citydb.unom5_network_feature ADD CONSTRAINT unom5_ntw_feat_status_fk FOREIGN KEY (status) REFERENCES citydb.unom5_lu_status (id) MATCH FULL ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE IF EXISTS citydb.unom5_network_feature ADD CONSTRAINT unom5_ntw_feat_locat_qual_fk FOREIGN KEY (location_quality) REFERENCES citydb.unom5_lu_spatial_quality (id) MATCH FULL ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE IF EXISTS citydb.unom5_network_feature ADD CONSTRAINT unom5_ntw_feat_elev_qual_fk FOREIGN KEY (elevation_quality) REFERENCES citydb.unom5_lu_spatial_quality (id) MATCH FULL ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE IF EXISTS citydb.unom5_network_feature ADD CONSTRAINT unom5_ntw_feat_locat_acc_fk FOREIGN KEY (location_accuracy) REFERENCES citydb.unom5_lu_location_accuracy_value (id) MATCH FULL ON UPDATE CASCADE ON DELETE SET NULL;
--ALTER TABLE IF EXISTS citydb.unom5_network_feature ADD CONSTRAINT unom5_ntw_feat_rel_to_terrain_fk FOREIGN KEY (relative_to_terrain) REFERENCES citydb.unom5_lu_relative_to_terrain (id) MATCH FULL ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE IF EXISTS citydb.unom5_network_feature ADD CONSTRAINT unom5_ntw_feat_class_fk FOREIGN KEY (objectclass_id, class) REFERENCES citydb.unom5_lu_network_feature_class (objectclass_id, id) MATCH FULL ON UPDATE CASCADE ON DELETE SET NULL;


--**************
--CABLE
--CityGML
ALTER TABLE IF EXISTS citydb.unom5_cable ADD CONSTRAINT unom5_cable_objclass_fk FOREIGN KEY (objectclass_id) REFERENCES citydb.objectclass (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;
--UNOM5_Main
ALTER TABLE IF EXISTS citydb.unom5_cable ADD CONSTRAINT unom5_cable_utn_ntw_feat_fk FOREIGN KEY (id) REFERENCES citydb.unom5_network_feature (id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;
--UNOM5_LookUp
ALTER TABLE IF EXISTS citydb.unom5_cable ADD CONSTRAINT unom5_cable_line_function_fk FOREIGN KEY (function_of_line) REFERENCES citydb.unom5_lu_function_of_line (id) MATCH FULL ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE IF EXISTS citydb.unom5_cable ADD CONSTRAINT unom5_cable_pipe_type_fk FOREIGN KEY (objectclass_id, cable_type) REFERENCES citydb.unom5_lu_cable_type (objectclass_id, id) MATCH FULL ON UPDATE CASCADE ON DELETE SET NULL;


--**************
--PIPE
--CityGML
ALTER TABLE IF EXISTS citydb.unom5_pipe ADD CONSTRAINT unom5_pipe_objclass_fk FOREIGN KEY (objectclass_id) REFERENCES citydb.objectclass (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;
--UNOM5_Main
ALTER TABLE IF EXISTS citydb.unom5_pipe ADD CONSTRAINT unom5_pipe_utn_ntw_feat_fk FOREIGN KEY (id) REFERENCES citydb.unom5_network_feature (id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;
--UNOM5_LookUp
ALTER TABLE IF EXISTS citydb.unom5_pipe ADD CONSTRAINT unom5_pipe_line_function_fk FOREIGN KEY (function_of_line) REFERENCES citydb.unom5_lu_function_of_line (id) MATCH FULL ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE IF EXISTS citydb.unom5_pipe ADD CONSTRAINT unom5_pipe_pipe_type_fk FOREIGN KEY (objectclass_id, pipe_type) REFERENCES citydb.unom5_lu_pipe_type (objectclass_id, id) MATCH FULL ON UPDATE CASCADE ON DELETE SET NULL;


--**************
--PROTECTIVE_ELEMENT
--CityGML
ALTER TABLE IF EXISTS citydb.unom5_protective_element ADD CONSTRAINT unom5_prot_elem_objclass_fk FOREIGN KEY (objectclass_id) REFERENCES citydb.objectclass (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;
--UNOM5_Main
ALTER TABLE IF EXISTS citydb.unom5_protective_element ADD CONSTRAINT unom5_prot_elem_utn_ntw_feat_fk FOREIGN KEY (id) REFERENCES citydb.unom5_network_feature (id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--**************
--NETWORK_TO_NETWORK_FEATURE
--UNOM5_Main
ALTER TABLE IF EXISTS citydb.unom5_network_to_network_feature ADD CONSTRAINT unom5_ntw_to_ntw_feat_ntw_fk FOREIGN KEY (network_id) REFERENCES citydb.unom5_network (id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE IF EXISTS citydb.unom5_network_to_network_feature ADD CONSTRAINT unom5_ntw_to_ntw_feat_feat_fk FOREIGN KEY (network_feature_id) REFERENCES citydb.unom5_network_feature (id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--**************
--NETWORK_GRAPH
--CityGML
ALTER TABLE IF EXISTS citydb.unom5_network_graph ADD CONSTRAINT unom5_ntw_graph_objclass_fk FOREIGN KEY (objectclass_id) REFERENCES citydb.objectclass (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;
--UNOM5_Main
ALTER TABLE IF EXISTS citydb.unom5_network_graph ADD CONSTRAINT unom5_ntw_graph_ontw_fk FOREIGN KEY (network_id) REFERENCES citydb.unom5_network (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;


--**************
--FEATURE_GRAPH
--CityGML
ALTER TABLE IF EXISTS citydb.unom5_feature_graph ADD CONSTRAINT unom5_feat_graph_objclass_fk FOREIGN KEY (objectclass_id) REFERENCES citydb.objectclass (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;
--UNOM5_Main
ALTER TABLE IF EXISTS citydb.unom5_feature_graph ADD CONSTRAINT unom5_feat_graph_feat_fk FOREIGN KEY (ntw_feature_id) REFERENCES citydb.unom5_network_feature (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;


--**************
--NODE
--CityGML
ALTER TABLE IF EXISTS citydb.unom5_node ADD CONSTRAINT unom5_node_objclass_fk FOREIGN KEY (objectclass_id) REFERENCES citydb.objectclass (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;
--UNOM5_Main
ALTER TABLE IF EXISTS citydb.unom5_node ADD CONSTRAINT unom5_node_feat_graph_fk FOREIGN KEY (feat_graph_id) REFERENCES citydb.unom5_feature_graph (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;


--**************
--LINK
--CityGML
ALTER TABLE IF EXISTS citydb.unom5_link ADD CONSTRAINT unom5_link_objclass_fk FOREIGN KEY (objectclass_id) REFERENCES citydb.objectclass (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;
--UNOM5_Main
ALTER TABLE IF EXISTS citydb.unom5_link ADD CONSTRAINT unom5_link_node_fk1 FOREIGN KEY (start_node_id) REFERENCES citydb.unom5_node (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;
ALTER TABLE IF EXISTS citydb.unom5_link ADD CONSTRAINT unom5_link_node_fk2 FOREIGN KEY (end_node_id) REFERENCES citydb.unom5_node (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;
ALTER TABLE IF EXISTS citydb.unom5_link ADD CONSTRAINT unom5_link_feat_graph_fk FOREIGN KEY (feat_graph_id) REFERENCES citydb.unom5_feature_graph (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;
ALTER TABLE IF EXISTS citydb.unom5_link ADD CONSTRAINT unom5_link_nte_graph_fk FOREIGN KEY (ntw_graph_id) REFERENCES citydb.unom5_network_graph (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;


--**************
--UNOM_BUILDING
--CityGML
ALTER TABLE IF EXISTS citydb.unom5_building ADD CONSTRAINT unom5_building_objclass_fk FOREIGN KEY (objectclass_id) REFERENCES citydb.objectclass (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;
--UNOM5_Main
ALTER TABLE IF EXISTS citydb.unom5_building ADD CONSTRAINT unom5_building_bdg_fk FOREIGN KEY (id) REFERENCES citydb.building (id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--**************
--COMMODITY_SUPPLY
--CityGML
ALTER TABLE IF EXISTS citydb.unom5_commodity_supply ADD CONSTRAINT unom5_comm_supl_cityobject_id_fk FOREIGN KEY (cityobject_id) REFERENCES citydb.cityobject (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;
ALTER TABLE IF EXISTS citydb.unom5_commodity_supply ADD CONSTRAINT unom5_comm_supl_objectclass_id_fk FOREIGN KEY (objectclass_id) REFERENCES citydb.objectclass (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;
--UNOM5_LookUp
ALTER TABLE IF EXISTS citydb.unom5_commodity_supply ADD CONSTRAINT unom5_comm_supl_type_fk FOREIGN KEY (objectclass_id, type) REFERENCES citydb.unom5_lu_commodity_supply (objectclass_id, id) MATCH FULL ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE IF EXISTS citydb.unom5_commodity_supply ADD CONSTRAINT unom5_comm_supl_curr_status_fk FOREIGN KEY (current_status) REFERENCES citydb.unom5_lu_status (id) MATCH FULL ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE IF EXISTS citydb.unom5_commodity_supply ADD CONSTRAINT unom5_comm_supl_pot_status_fk FOREIGN KEY (potential_status) REFERENCES citydb.unom5_lu_status (id) MATCH FULL ON UPDATE CASCADE ON DELETE SET NULL;


--**************
--STORAGE
--UNOM5_Main
ALTER TABLE IF EXISTS citydb.unom5_storage ADD CONSTRAINT unom5_storage_commodity_supply_fk FOREIGN KEY (commodity_supply_id) REFERENCES citydb.unom5_commodity_supply (id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE IF EXISTS citydb.unom5_storage ADD CONSTRAINT unom5_storage_funct_component_fk  FOREIGN KEY (funct_component_id)  REFERENCES citydb.unom5_functional_component (id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;
--UNOM5_LookUp
ALTER TABLE IF EXISTS citydb.unom5_storage ADD CONSTRAINT unom5_storage_type_fk FOREIGN KEY (type_objectclass_id, type_id) REFERENCES citydb.unom5_lu_network_feature_class (objectclass_id, id) MATCH FULL ON UPDATE CASCADE ON DELETE SET NULL;


--**************
--ROLE_IN_NETWORK
--CityGML
ALTER TABLE IF EXISTS citydb.unom5_role_in_network ADD CONSTRAINT unom5_role_in_ntw_cityobject_id_fk FOREIGN KEY (cityobject_id) REFERENCES citydb.cityobject (id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE IF EXISTS citydb.unom5_role_in_network ADD CONSTRAINT unom5_role_in_ntw_objclass_fk FOREIGN KEY (objectclass_id) REFERENCES citydb.objectclass (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;
--UNOM5_Main
ALTER TABLE IF EXISTS citydb.unom5_role_in_network ADD CONSTRAINT unom5_role_in_ntw_ntw_id_fk FOREIGN KEY (network_id) REFERENCES citydb.unom5_network (id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;
--UNOM5_LookUp
ALTER TABLE IF EXISTS citydb.unom5_role_in_network ADD CONSTRAINT unom5_role_in_ntw_function_fk FOREIGN KEY (function) REFERENCES citydb.unom5_lu_network_feature_function (id) MATCH FULL ON UPDATE CASCADE ON DELETE SET NULL;


--**************
--COMMODITY
--CityGML
ALTER TABLE IF EXISTS citydb.unom5_commodity ADD CONSTRAINT unom5_comm_objclass_fk FOREIGN KEY (objectclass_id) REFERENCES citydb.objectclass (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;
--UNOM5_LookUp
ALTER TABLE IF EXISTS citydb.unom5_commodity ADD CONSTRAINT unom5_comm_opt_mode_fk FOREIGN KEY (optical_mode) REFERENCES citydb.unom5_lu_optical_mode (id) MATCH FULL ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE IF EXISTS citydb.unom5_commodity ADD CONSTRAINT unom5_comm_type_fk FOREIGN KEY (objectclass_id, type) REFERENCES citydb.unom5_lu_commodity_supply (objectclass_id, id) MATCH FULL ON UPDATE CASCADE ON DELETE SET NULL;


--**************
--COMMODITY_CLASSIFIER
--CityGML
ALTER TABLE IF EXISTS citydb.unom5_commodity_classifier ADD CONSTRAINT unom5_comm_class_objclass_fk FOREIGN KEY (objectclass_id) REFERENCES citydb.objectclass (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;
--UNOM5_Main
ALTER TABLE IF EXISTS citydb.unom5_commodity_classifier ADD CONSTRAINT unom5_comm_class_comm_id_fk FOREIGN KEY (commodity_id) REFERENCES citydb.unom5_commodity (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;
ALTER TABLE IF EXISTS citydb.unom5_commodity_classifier ADD CONSTRAINT unom5_comm_class_material_fk FOREIGN KEY (material_id) REFERENCES citydb.unom5_material (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;
ALTER TABLE IF EXISTS citydb.unom5_commodity_classifier ADD CONSTRAINT unom5_comm_class_hollow_space_fk FOREIGN KEY (hollow_space_id) REFERENCES citydb.unom5_hollow_space (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;
--UNOM5_LookUp
ALTER TABLE IF EXISTS citydb.unom5_commodity_classifier ADD CONSTRAINT unom5_comm_class_signal_word_fk FOREIGN KEY (signal_word) REFERENCES citydb.unom5_lu_signal_word (id) MATCH FULL ON UPDATE CASCADE ON DELETE SET NULL;


--**************
--COMM_CLASS_TO_COMM_CLASS
--UNOM5_Main
ALTER TABLE IF EXISTS citydb.unom5_comm_class_to_comm_class ADD CONSTRAINT unom5_comm_class_to_comm_class_parent_fk FOREIGN KEY (comm_class_parent_id) REFERENCES citydb.unom5_commodity_classifier (id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE IF EXISTS citydb.unom5_comm_class_to_comm_class ADD CONSTRAINT unom5_comm_class_to_comm_class_root_fk FOREIGN KEY (comm_class_id) REFERENCES citydb.unom5_commodity_classifier (id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--**************
--MATERIAL
--CityGML
ALTER TABLE IF EXISTS citydb.unom5_material ADD CONSTRAINT unom5_material_objclass_fk FOREIGN KEY (objectclass_id) REFERENCES citydb.objectclass (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;
--UNOM5_LookUp
ALTER TABLE IF EXISTS citydb.unom5_material ADD CONSTRAINT unom5_material_type_fk FOREIGN KEY (type) REFERENCES citydb.unom5_lu_material (id) MATCH FULL ON UPDATE CASCADE ON DELETE SET NULL;


--**************
--NETWORK_FEAT_TO_MATERIAL
--UNOM5_Main
ALTER TABLE IF EXISTS citydb.unom5_network_feat_to_material ADD CONSTRAINT unom5_ntw_feat_to_material_ntw_feat_fk FOREIGN KEY (network_feature_id) REFERENCES citydb.unom5_network_feature (id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE IF EXISTS citydb.unom5_network_feat_to_material ADD CONSTRAINT unom5_ntw_feat_to_material_mat_fk FOREIGN KEY (material_id) REFERENCES citydb.unom5_material (id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--**************
--HOLLOW_SPACE
--CityGML
ALTER TABLE IF EXISTS citydb.unom5_hollow_space ADD CONSTRAINT unom5_hollow_space_objclass_fk FOREIGN KEY (objectclass_id) REFERENCES citydb.objectclass (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;
--UNOM5_Main
ALTER TABLE IF EXISTS citydb.unom5_hollow_space ADD CONSTRAINT unom5_hollow_space_parent_fk FOREIGN KEY (hol_spc_parent_id) REFERENCES citydb.unom5_hollow_Space (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;
ALTER TABLE IF EXISTS citydb.unom5_hollow_space ADD CONSTRAINT unom5_hollow_space_root_fk FOREIGN KEY (hol_spc_root_id) REFERENCES citydb.unom5_hollow_Space (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;
ALTER TABLE IF EXISTS citydb.unom5_hollow_space ADD CONSTRAINT unom5_hollow_space_ntw_feat_fk FOREIGN KEY (ntw_feature_id) REFERENCES citydb.unom5_network_feature (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;


--**************
--FEATURE_GRAPH_TO_NETWORK_GRAPH
--UNOM5_Main
ALTER TABLE IF EXISTS citydb.unom5_feature_graph_to_network_graph ADD CONSTRAINT unom5_feat_graph_to_ntw_graph_feat_fk FOREIGN KEY (feature_graph_id) REFERENCES citydb.unom5_feature_graph (id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE IF EXISTS citydb.unom5_feature_graph_to_network_graph ADD CONSTRAINT unom5_feat_graph_to_ntw_graph_ntw_fk FOREIGN KEY (network_graph_id) REFERENCES citydb.unom5_network_graph (id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--**************
--MEASURED_DEPTH
--UNOM5_Main
ALTER TABLE IF EXISTS citydb.unom5_measured_depth ADD CONSTRAINT unom5_measured_depth_ntw_feature_id_fk FOREIGN KEY (ntw_feature_id) REFERENCES citydb.unom5_network_feature (id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;
--UNOM5_LookUp
ALTER TABLE IF EXISTS citydb.unom5_measured_depth ADD CONSTRAINT unom5_measured_depth_depth_reference_fk FOREIGN KEY (depth_reference_level) REFERENCES citydb.unom5_lu_depth_reference_level (id) MATCH FULL ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE IF EXISTS citydb.unom5_measured_depth ADD CONSTRAINT unom5_measured_depth_depth_qual_fk FOREIGN KEY (depth_quality) REFERENCES citydb.unom5_lu_spatial_quality (id) MATCH FULL ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE IF EXISTS citydb.unom5_measured_depth ADD CONSTRAINT unom5_measured_depth_depth_accu_fk FOREIGN KEY (depth_accuracy) REFERENCES citydb.unom5_lu_depth_accuracy_value (id) MATCH FULL ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE IF EXISTS citydb.unom5_measured_depth ADD CONSTRAINT unom5_measured_depth_depth_point_of_measure_fk FOREIGN KEY (depth_point_of_measurement) REFERENCES citydb.unom5_lu_depth_point_of_measurement (id) MATCH FULL ON UPDATE CASCADE ON DELETE SET NULL;


--**************
--UNOM_CITY_OBJECT
--CityGML

-- FF: NO LONGER NECESSARY. IT WAS HERE ONLY BECAUSE OF RELATIVE TO TERRAIN 
-- BUT THAT ATTRIBUTE WAS IN FACT REPEATED. IT IS ORIGINALLY IN CITYOBJECT.

--ALTER TABLE IF EXISTS citydb.unom5_city_object ADD CONSTRAINT unom5_cityobject_ctyobj_fk FOREIGN KEY (id) REFERENCES citydb.cityobject (id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;
--ALTER TABLE IF EXISTS citydb.unom5_city_object ADD CONSTRAINT unom5_city0bject_objclass_fk FOREIGN KEY (objectclass_id) REFERENCES citydb.objectclass (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;
----UNOM5_LookUp
--ALTER TABLE IF EXISTS citydb.unom5_city_object ADD CONSTRAINT unom5_cityobject_rel_to_terr_fk FOREIGN KEY (relative_to_terrain) REFERENCES citydb.unom5_lu_relative_to_terrain (id) MATCH FULL ON UPDATE CASCADE ON DELETE SET NULL;


--**************
--FUNCTIONAL_COMPONENT
--CityGML
ALTER TABLE IF EXISTS citydb.unom5_functional_component ADD CONSTRAINT unom5_funct_comp_objclass_fk FOREIGN KEY (objectclass_id) REFERENCES citydb.objectclass (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;
--UNOM5_Main
ALTER TABLE IF EXISTS citydb.unom5_functional_component ADD CONSTRAINT unom5_funct_comp_utn_ntw_feat_fk FOREIGN KEY (id) REFERENCES citydb.unom5_network_feature (id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE IF EXISTS citydb.unom5_functional_component ADD CONSTRAINT unom5_funct_comp_parent_fk FOREIGN KEY (func_comp_parent_id) REFERENCES citydb.unom5_functional_component (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;
ALTER TABLE IF EXISTS citydb.unom5_functional_component ADD CONSTRAINT unom5_funct_comp_root_fk FOREIGN KEY (func_comp_root_id) REFERENCES citydb.unom5_functional_component (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;
--ALTER TABLE IF EXISTS citydb.unom5_functional_component ADD CONSTRAINT unom5_funct_comp_storage_fk FOREIGN KEY (storage_id) REFERENCES citydb.unom5_storage (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;


--**************
--RELATED_PARTY
--CityGML
ALTER TABLE IF EXISTS citydb.unom5_related_party ADD CONSTRAINT unom5_rel_party_objclass_fk FOREIGN KEY (objectclass_id) REFERENCES citydb.objectclass (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;
ALTER TABLE IF EXISTS citydb.unom5_related_party ADD CONSTRAINT unom5_rel_party_address_fk FOREIGN KEY (address_id) REFERENCES citydb.address (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;
--UNOM5_LookUp
ALTER TABLE IF EXISTS citydb.unom5_related_party ADD CONSTRAINT unom5_rel_party_role_fk FOREIGN KEY (role) REFERENCES citydb.unom5_lu_party_role (id) MATCH FULL ON UPDATE CASCADE ON DELETE SET NULL;


--**************
--RELATED_PARTY_TO_NETWORK
--UNOM5_Main
ALTER TABLE IF EXISTS citydb.unom5_related_party_to_network ADD CONSTRAINT unom5_rel_party_to_ntw_party_fk FOREIGN KEY (party_id) REFERENCES citydb.unom5_related_party (id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE IF EXISTS citydb.unom5_related_party_to_network ADD CONSTRAINT unom5_rel_party_to_ntw_ntw_fk FOREIGN KEY (network_id) REFERENCES citydb.unom5_network (id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--**************
--RELATED_PARTY_TO_NETWORK_FEATURE
--UNOM5_Main
ALTER TABLE IF EXISTS citydb.unom5_related_party_to_network_feature ADD CONSTRAINT unom5_rel_party_to_ntw_feat_party_fk FOREIGN KEY (party_id) REFERENCES citydb.unom5_related_party (id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE IF EXISTS citydb.unom5_related_party_to_network_feature ADD CONSTRAINT unom5_rel_party_to_ntw_feat_feat_fk FOREIGN KEY (network_feature_id) REFERENCES citydb.unom5_network_feature (id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--**************
--RELATED_PARTY_TO_MAINTENANCE_ACTIVITY
--UNOM5_Main
ALTER TABLE IF EXISTS citydb.unom5_related_party_to_maintenance_activity ADD CONSTRAINT unom5_rel_party_to_maint_party_fk FOREIGN KEY (party_id) REFERENCES citydb.unom5_related_party (id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE IF EXISTS citydb.unom5_related_party_to_maintenance_activity ADD CONSTRAINT unom5_rel_party_to_maint_maint_fk FOREIGN KEY (maintenance_activity_id) REFERENCES citydb.unom5_maintenance_activity (id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--**************
--SOIL_AND_GROUNDWATER
--UNOM5_MAIN
ALTER TABLE IF EXISTS citydb.unom5_soil_and_groundwater ADD CONSTRAINT unom5_soil_and_gwater_ntw_feature_id_fk FOREIGN KEY (ntw_feature_id) REFERENCES citydb.unom5_network_feature (id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;
--UNOM5_LookUp
ALTER TABLE IF EXISTS citydb.unom5_soil_and_groundwater ADD CONSTRAINT unom5_soil_and_gwater_type_fk FOREIGN KEY (type) REFERENCES citydb.unom5_lu_soil (id) MATCH FULL ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE IF EXISTS citydb.unom5_soil_and_groundwater ADD CONSTRAINT unom5_soil_and_gwater_gwater_ref_lev_fk FOREIGN KEY (groundwater_reference_level) REFERENCES citydb.unom5_lu_groundwater_reference (id) MATCH FULL ON UPDATE CASCADE ON DELETE SET NULL;


--**************
--MAINTENANCE_ACTIVITY
--CityGML
ALTER TABLE IF EXISTS citydb.unom5_maintenance_activity ADD CONSTRAINT unom5_maint_act_objclass_fk FOREIGN KEY (objectclass_id) REFERENCES citydb.objectclass (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;
--UNOM5_LookUp
ALTER TABLE IF EXISTS citydb.unom5_maintenance_activity ADD CONSTRAINT unom5_maint_act_timeline_fk FOREIGN KEY (maintenance_timeline) REFERENCES citydb.unom5_lu_maintenance_timeline_type (id) MATCH FULL ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE IF EXISTS citydb.unom5_maintenance_activity ADD CONSTRAINT unom5_maint_act_maint_type_fk FOREIGN KEY (maintenance_type) REFERENCES citydb.unom5_lu_maintenance_type (id) MATCH FULL ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE IF EXISTS citydb.unom5_maintenance_activity ADD CONSTRAINT unom5_maint_act__activity_type_fk FOREIGN KEY (activity_type) REFERENCES citydb.unom5_lu_maintenance_activity_type (id) MATCH FULL ON UPDATE CASCADE ON DELETE SET NULL;


--**************
--NETWORK_FEATURE_TO_MAINTENANCE_ACTIVITY
--UNOM5_Main
ALTER TABLE IF EXISTS citydb.unom5_network_feature_to_maintenance_activity ADD CONSTRAINT unom5_ntw_feat_to_maint_act_feat_fk FOREIGN KEY (network_feature_id) REFERENCES citydb.unom5_network_feature (id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE IF EXISTS citydb.unom5_network_feature_to_maintenance_activity ADD CONSTRAINT unom5_ntw_feat_to_maint_act_maint_fk FOREIGN KEY (maintenance_activity_id) REFERENCES citydb.unom5_maintenance_activity (id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--**************
--COST
--UNOM5_Main
ALTER TABLE IF EXISTS citydb.unom5_cost ADD CONSTRAINT unom5_cost_ntw_feature_fk FOREIGN KEY (network_feature_id) REFERENCES citydb.unom5_network_feature (id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE IF EXISTS citydb.unom5_cost ADD CONSTRAINT unom5_cost_maint_act_fk FOREIGN KEY (maintenance_activity_id) REFERENCES citydb.unom5_maintenance_activity (id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;
--UNOM5_LookUp
ALTER TABLE IF EXISTS citydb.unom5_cost ADD CONSTRAINT unom5_cost_type_fk FOREIGN KEY (cost_type) REFERENCES citydb.unom5_lu_cost_type (id) MATCH FULL ON UPDATE CASCADE ON DELETE SET NULL;


--**************
--IMPACT
--CityGML
ALTER TABLE IF EXISTS citydb.unom5_impact ADD CONSTRAINT unom5_impact_objclass_fk FOREIGN KEY (objectclass_id) REFERENCES citydb.objectclass (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;
--UNOM5_Main
--ALTER TABLE IF EXISTS citydb.unom5_impact ADD CONSTRAINT unom5_impact_ntw_fk FOREIGN KEY (network_id) REFERENCES citydb.unom5_network (id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;
--ALTER TABLE IF EXISTS citydb.unom5_impact ADD CONSTRAINT unom5_impact_feat_fk FOREIGN KEY (feature_id) REFERENCES citydb.unom5_network_feature (id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--**************
--PERFORMANCE
--CityGML
ALTER TABLE IF EXISTS citydb.unom5_performance ADD CONSTRAINT unom5_performance_objclass_fk FOREIGN KEY (objectclass_id) REFERENCES citydb.objectclass (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;
--UNOM5_Main
ALTER TABLE IF EXISTS citydb.unom5_performance ADD CONSTRAINT unom5_performance_ntw_fk FOREIGN KEY (network_id) REFERENCES citydb.unom5_network (id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE IF EXISTS citydb.unom5_performance ADD CONSTRAINT unom5_performance_feat_fk FOREIGN KEY (feature_id) REFERENCES citydb.unom5_network_feature (id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;
--UNOM5_LookUp
ALTER TABLE IF EXISTS citydb.unom5_performance ADD CONSTRAINT unom5_performance_type_fk FOREIGN KEY (performance_type) REFERENCES citydb.unom5_lu_performance_type (id) MATCH FULL ON UPDATE CASCADE ON DELETE SET NULL;


--**************
--DIMENSIONS
--UNOM5_Main
ALTER TABLE IF EXISTS citydb.unom5_dimensions ADD CONSTRAINT unom5_dimensions_feature_id_fk FOREIGN KEY (feature_id) REFERENCES citydb.unom5_network_feature (id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;
--UNOM5_LookUp
ALTER TABLE IF EXISTS citydb.unom5_dimensions ADD CONSTRAINT unom5_dimensions_shape_fk FOREIGN KEY (shape) REFERENCES citydb.unom5_lu_shape (id) MATCH FULL ON UPDATE CASCADE ON DELETE SET NULL;


--**************
--IDENTIFICATION
--CityGML
ALTER TABLE IF EXISTS citydb.unom5_identification ADD CONSTRAINT unom5_identification_address_fk FOREIGN KEY (address_id) REFERENCES citydb.address (id) MATCH FULL ON UPDATE CASCADE ON DELETE NO ACTION;
--UNOM5_Main
ALTER TABLE IF EXISTS citydb.unom5_identification ADD CONSTRAINT unom5_identification_feature_id_fk FOREIGN KEY (feature_id) REFERENCES citydb.unom5_network_feature (id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;
--UNOM5_LookUp
ALTER TABLE IF EXISTS citydb.unom5_identification ADD CONSTRAINT unom5_identification_ident_type_fk FOREIGN KEY (identifier_type) REFERENCES citydb.unom5_lu_identifier_type (id) MATCH FULL ON UPDATE CASCADE ON DELETE SET NULL;


-- ******************************************************************************************************************************************************************************************************************************
-- ******************************************************************************************************************************************************************************************************************************
-- ******************************************************************************************************************************************************************************************************************************



-- ***********************************************************************
-- EXECUTE THE STORED PROCEDURE TO SET THE SRID OF THE NEW GEOMETRY COLUMNS TO THE CURRENT ONE ON THE DATABASE
-- ***********************************************************************

--SELECT citydb_pkg.utn9_set_ade_columns_srid('citydb');

-- ***********************************************************************
-- ***********************************************************************

DO
$$
BEGIN
RAISE NOTICE '

********************************

Utility Network O&M tables installation complete!

********************************

';
END
$$;
SELECT 'Utility Network O&M tables installation complete!'::varchar AS installation_result;

-- ***********************************************************************
-- ***********************************************************************
--
-- END OF FILE
--
-- ***********************************************************************
-- ***********************************************************************