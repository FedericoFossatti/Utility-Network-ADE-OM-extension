--3D City Database extension for the Utility Network ADE Operation & 
--Maintenance Extension v. 0.5.8 (uom5); based on UN_ADE v. 0.9.2
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
--ATTENTION, BEFORE RUNNING 'uom5' SCRIPTS:
--See notes on file 01_uom5_FUNCTIONS.
--
-- ***************************************************************************
-- ************************** 02_uom5_DML_FUNCTIONS.sql *********************
--
-- This script adds stored procedures for delete and insert operations
-- to the citydb_pkg schema. They are all prefixed with "uom5_".
--
-- ***************************************************************************
-- ***************************************************************************
-- ***************************************************************************
-- ***************************************************************************
-- ***************************************************************************


-- ***************************************************************************
--Contents

--Delete functions
--	Level 5
-- 		Function uom5_DELETE_LINK
--	Level 4
-- 		Function uom5_DELETE_COMMODITY_CLASSIFIER
-- 		Function uom5_DELETE_NODE
-- 		Function uom5_DELETE_STORAGE
--	Level 3
-- 		Function uom5_DELETE_FUNCTIONAL_COMPONENT
-- 		Function uom5_DELETE_CABLE
-- 		Function uom5_DELETE_PIPE
-- 		Function uom5_DELETE_PROTECTIVE_ELEMENT
--		Function uom5_DELETE_SOIL_AND_GROUNDWATER
-- 		Function uom5_DELETE_MEASURED_DEPTH
-- 		Function uom5_DELETE_DIMENSIONS
-- 		Function uom5_DELETE_IDENTIFICATION
-- 		Function uom5_DELETE_COST
-- 		Function uom5_DELETE_PERFORMANCE
-- 		Function uom5_DELETE_FEATURE_GRAPH
-- 		Function uom5_DELETE_NETWORK_GRAPH
--	Level 2
-- 		Function uom5_DELETE_RELATED_PARTY
-- 		Function uom5_DELETE_NETWORK_FEATURE
-- 		Function uom5_DELETE_NETWORK
--	Level 1
-- 		Function uom5_DELETE_MATERIAL
-- 		Function uom5_DELETE_ADDRESS
-- 		Function uom5_DELETE_COMMODITY

--Insert functions
--	Level 1
-- 		Function INSERT_CITYOBJECT (copied from 3DCityDB+ - utilities)
-- 		Function INSERT_ADDRESS (copied from 3DCityDB+ - utilities)
-- 		Function uom5_INSERT_COMMODITY
-- 		Function uom5_INSERT_MATERIAL
-- 		Function uom5_INSERT_MAINTENANCE_ACTIVITY
--		Function uom5_INSERT_IMPACT
--	Level 2 
-- 		Function uom5_INSERT_NETWORK
-- 		Function uom5_INSERT_NETWORK_FEATURE
-- 		Function uom5_INSERT_COMMODITY_SUPPLY
-- 		Function uom5_INSERT_RELATED_PARTY
--	Level 3
-- 		Function uom5_INSERT_RELATED_PARTY_TO_MAINTENANCE_ACTIVITY
-- 		Function uom5_INSERT_NETWORK_TO_NETWORK
-- 		Function uom5_INSERT_RELATED_PARTY_TO_NETWORK
-- 		Function uom5_INSERT_NETWORK_TO_NETWORK_FEATURE
-- 		Function uom5_INSERT_RELATED_PARTY_TO_NETWORK_FEATURE
-- 		Function uom5_INSERT_NETWORK_FEATURE_TO_MAINTENANCE_ACTIVITY
-- 		Function uom5_INSERT_NETWORK_FEATURE_TO_MATERIAL
-- 		Function uom5_INSERT_NETWORK_GRAPH
-- 		Function uom5_INSERT_FEATURE_GRAPH
-- 		Function uom5_INSERT_PERFORMANCE
-- 		Function uom5_INSERT_COST
-- 		Function uom5_INSERT_IDENTIFICATION
-- 		Function uom5_INSERT_DIMENSIONS
-- 		Function uom5_INSERT_MEASURED_DEPTH
-- 		Function uom5_INSERT_SOIL_AND_GROUNDWATER
-- 		Function uom5_INSERT_PROTECTIVE_ELEMENT
-- 		Function uom5_INSERT_PIPE
-- 		Function uom5_INSERT_CABLE
-- 		Function uom5_INSERT_FUNCTIONAL_COMPONENT
--	Level 4
-- 		Function uom5_INSERT_STORAGE
-- 		Function uom5_INSERT_FEATURE_GRAPH_TO_NETWORK_GRAPH
-- 		Function uom5_INSERT_NODE
-- 		Function uom5_INSERT_COMMODITY_CLASSIFIER
--	Level 5
-- 		Function uom5_INSERT_COMM_CLASS_TO_COMM_CLASS
-- 		Function uom5_INSERT_LINK

-- ***************************************************************************



-- ********************************************************************************************************************************************************************************************************************************************************************************************************************************************************************

-- DELETE FUNCTIONS

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Hierchy level 5: Independent from other tables
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

----------------------------------------------------------------
-- Function uom5_DELETE_LINK
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    citydb_pkg.uom5_delete_link(integer,varchar);
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_delete_link(
	o_id integer,
	schema_name varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
	deleted_id integer;
BEGIN
EXECUTE format('DELETE FROM %I.uom5_link WHERE id=%L RETURNING id', schema_name, o_id) INTO deleted_id;
RETURN deleted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_delete_link (id: %): %', o_id, SQLERRM;
END;
$$ LANGUAGE plpgsql;


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Hierchy level 4
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

----------------------------------------------------------------
-- Function uom5_DELETE_COMMODITY_CLASSIFIER
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    citydb_pkg.uom5_delete_commodity_classifier(integer,varchar);
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_delete_commodity_classifier(
	o_id integer,
	schema_name varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
	cc_id integer;
	deleted_id integer;
BEGIN
-- Delete the depending commodity_classifier (if not referenced anymore)
FOR cc_id IN EXECUTE format('SELECT comm_class_id FROM %I.uom5_comm_class_to_comm_class WHERE comm_class_parent_id=%L ORDER BY comm_class_parent_id', schema_name, o_id) LOOP
	IF cc_id IS NOT NULL THEN
	  IF citydb_pkg.is_not_referenced('uom5_comm_class_to_comm_class','comm_class_id', cc_id, 'comm_class_parent_id', o_id, schema_name) IS TRUE THEN
		  EXECUTE 'SELECT citydb_pkg.uom5_delete_commodity_classifier($1, $2)' USING cc_id, schema_name;
		END IF;	
	END IF;
END LOOP;

-- Delete the commodity_classifier itself
EXECUTE format('DELETE FROM %I.uom5_commodity_classifier WHERE id=%L RETURNING id', schema_name, o_id) INTO deleted_id;
RETURN deleted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_delete_commodity_classifier (id: %): %', o_id, SQLERRM;
END;
$$ LANGUAGE plpgsql;


----------------------------------------------------------------
-- Function uom5_DELETE_NODE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    citydb_pkg.uom5_delete_node(integer,varchar);
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_delete_node(
	o_id integer,
	schema_name varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
	l_id integer;
	deleted_id integer;
BEGIN
-- DELETE first all referencing Links
FOR l_id IN EXECUTE format('SELECT id FROM %I.uom5_link WHERE start_node_id = %L OR end_node_id=%L', schema_name, o_id, o_id) LOOP
  IF l_id IS NOT NULL THEN
    EXECUTE 'SELECT citydb_pkg.uom5_delete_link($1, $2)' USING l_id, schema_name;
  END IF;
END LOOP;
-- Delete node itself
EXECUTE format('DELETE FROM %I.uom5_node WHERE id = %L RETURNING id', schema_name, o_id) INTO deleted_id;
RETURN deleted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_delete_node (id: %): %', o_id, SQLERRM;
END;
$$ LANGUAGE plpgsql;


----------------------------------------------------------------
-- Function uom5_DELETE_STORAGE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    citydb_pkg.uom5_delete_storage(integer,varchar);
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_delete_storage(
	o_id integer,
	schema_name varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
	deleted_id integer;
BEGIN
-- Delete the storage itself
EXECUTE format('DELETE FROM %I.uom5_storage WHERE id=%L RETURNING id', schema_name, o_id) INTO deleted_id;
RETURN deleted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_delete_storage (id: %): %', o_id, SQLERRM;
END;
$$ LANGUAGE plpgsql;


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Hierchy level 3
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

----------------------------------------------------------------
-- Function uom5_DELETE_FUNCTIONAL_COMPONENT
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    citydb_pkg.uom5_delete_functional_component(integer,varchar);
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_delete_functional_component(
	o_id integer,
	schema_name varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
  deleted_id integer;
BEGIN
--No need to delete storage. FK constraint on storage table takes care of that (on delete cascade)
EXECUTE format('DELETE FROM %I.uom5_functional_component WHERE id=%L RETURNING id', schema_name, o_id) INTO deleted_id;
RETURN deleted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_delete_functional_component (id: %): %', o_id, SQLERRM;
END;
$$ LANGUAGE plpgsql;


----------------------------------------------------------------
-- Function uom5_DELETE_CABLE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    citydb_pkg.uom5_delete_cable(integer,varchar);
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_delete_cable(
	o_id integer,
	schema_name varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
  deleted_id integer;
BEGIN
EXECUTE format('DELETE FROM %I.uom5_cable WHERE id=%L RETURNING id', schema_name, o_id) INTO deleted_id;
RETURN deleted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_delete_cable (id: %): %', o_id, SQLERRM;
END;
$$ LANGUAGE plpgsql;


----------------------------------------------------------------
-- Function uom5_DELETE_PIPE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    citydb_pkg.uom5_delete_pipe(integer,varchar);
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_delete_pipe(
	o_id integer,
	schema_name varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
  deleted_id integer;
BEGIN
EXECUTE format('DELETE FROM %I.uom5_pipe WHERE id=%L RETURNING id', schema_name, o_id) INTO deleted_id;
RETURN deleted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_delete_pipe (id: %): %', o_id, SQLERRM;
END;
$$ LANGUAGE plpgsql;


----------------------------------------------------------------
-- Function uom5_DELETE_PROTECTIVE_ELEMENT
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    citydb_pkg.uom5_delete_protective_element(integer,varchar);
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_delete_protective_element(
	o_id integer,
	schema_name varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
  deleted_id integer;
BEGIN
--If another network_feature uses this protective element, the reference in the table 'uom5_network_feature' will be set to NULL automatically by the FK
EXECUTE format('DELETE FROM %I.uom5_protective_element WHERE id=%L RETURNING id', schema_name, o_id) INTO deleted_id;
RETURN deleted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_delete_protective_element (id: %): %', o_id, SQLERRM;
END;
$$ LANGUAGE plpgsql;


----------------------------------------------------------------
-- Function uom5_DELETE_SOIL_AND_GROUNDWATER
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    citydb_pkg.uom5_delete_soil_and_groundwater(integer,varchar);
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_delete_soil_and_groundwater(
	o_id integer,
	schema_name varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
  deleted_id integer;
BEGIN
EXECUTE format('DELETE FROM %I.uom5_soil_and_groundwater WHERE id=%L RETURNING id', schema_name, o_id) INTO deleted_id;
RETURN deleted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_delete_soil_and_groundwater (id: %): %', o_id, SQLERRM;
END;
$$ LANGUAGE plpgsql;


----------------------------------------------------------------
-- Function uom5_DELETE_MEASURED_DEPTH
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    citydb_pkg.uom5_delete_measured_depth(integer,varchar);
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_delete_measured_depth(
	o_id integer,
	schema_name varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
  deleted_id integer;
BEGIN
EXECUTE format('DELETE FROM %I.uom5_measured_depth WHERE id=%L RETURNING id', schema_name, o_id) INTO deleted_id;
RETURN deleted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_delete_measured_depth (id: %): %', o_id, SQLERRM;
END;
$$ LANGUAGE plpgsql;


----------------------------------------------------------------
-- Function uom5_DELETE_DIMENSIONS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    citydb_pkg.uom5_delete_dimensions(integer,varchar);
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_delete_dimensions(
	o_id integer,
	schema_name varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
  deleted_id integer;
BEGIN
EXECUTE format('DELETE FROM %I.uom5_dimensions WHERE id=%L RETURNING id', schema_name, o_id) INTO deleted_id;
RETURN deleted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_delete_dimensions (id: %): %', o_id, SQLERRM;
END;
$$ LANGUAGE plpgsql;


----------------------------------------------------------------
-- Function uom5_DELETE_IDENTIFICATION
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    citydb_pkg.uom5_delete_identification(integer,varchar);
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_delete_identification(
	o_id integer,
	schema_name varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
	add_id integer;
	deleted_id integer;
BEGIN
-- Delete the identification
EXECUTE format('DELETE FROM %I.uom5_identification WHERE id=%L RETURNING id', schema_name, o_id) INTO deleted_id;

-- Delete the depending address if not referenced by other table.
FOR add_id IN EXECUTE format('SELECT address_id FROM %I.uom5_identification WHERE id=%L ORDER BY id', schema_name, o_id) LOOP ---------------------- check this out later
	IF add_id IS NOT NULL THEN
		IF citydb_pkg.is_not_referenced('uom5_identification','address_id', add_id, 'id', o_id, schema_name) IS TRUE THEN
			EXECUTE 'SELECT citydb_pkg.delete_address($1, $2)' USING add_id, schema_name;
		END IF;
	END IF;
END LOOP;

RETURN deleted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_delete_identification (id: %): %', o_id, SQLERRM;
END;
$$ LANGUAGE plpgsql;


----------------------------------------------------------------
-- Function uom5_DELETE_COST
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    citydb_pkg.uom5_delete_cost(integer,varchar);
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_delete_cost(
	o_id integer,
	schema_name varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
  deleted_id integer;
BEGIN
EXECUTE format('DELETE FROM %I.uom5_cost WHERE id=%L RETURNING id', schema_name, o_id) INTO deleted_id;
RETURN deleted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_delete_cost (id: %): %', o_id, SQLERRM;
END;
$$ LANGUAGE plpgsql;


----------------------------------------------------------------
-- Function uom5_DELETE_PERFORMANCE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    citydb_pkg.uom5_delete_performance(integer,varchar);
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_delete_performance(
	o_id integer,
	schema_name varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
  deleted_id integer;
BEGIN
EXECUTE format('DELETE FROM %I.uom5_performance WHERE id=%L RETURNING id', schema_name, o_id) INTO deleted_id;
RETURN deleted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_delete_performance (id: %): %', o_id, SQLERRM;
END;
$$ LANGUAGE plpgsql;


----------------------------------------------------------------
-- Function uom5_DELETE_FEATURE_GRAPH
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    citydb_pkg.uom5_delete_feature_graph(integer,varchar);
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_delete_feature_graph(
	o_id integer,
	schema_name varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
  n_id integer;
  l_id integer;
  deleted_id integer;
BEGIN
-- Delete the depending links
FOR l_id IN EXECUTE format('SELECT id FROM %I.uom5_link WHERE feat_graph_id = %L', schema_name, o_id) LOOP
  IF l_id IS NOT NULL THEN
    EXECUTE 'SELECT citydb_pkg.uom5_delete_link($1, $2)' USING l_id, schema_name;
  END IF;
END LOOP;
-- Delete the depending nodes
FOR n_id IN EXECUTE format('SELECT id FROM %I.uom5_node WHERE feat_graph_id = %L', schema_name, o_id) LOOP
  IF n_id IS NOT NULL THEN
    EXECUTE 'SELECT citydb_pkg.uom5_delete_node($1, $2)' USING n_id, schema_name;
  END IF;
END LOOP;
-- Delete the feature_graph itself
EXECUTE format('DELETE FROM %I.uom5_feature_graph WHERE id=%L RETURNING id', schema_name, o_id) INTO deleted_id;
RETURN deleted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_delete_feature_graph (id: %): %', o_id, SQLERRM;
END;
$$ LANGUAGE plpgsql;


----------------------------------------------------------------
-- Function uom5_DELETE_NETWORK_GRAPH
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    citydb_pkg.uom5_delete_network_graph(integer,varchar);
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_delete_network_graph(
	o_id integer,
	schema_name varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
  l_id integer;
	fg_id integer;
	deleted_id integer;
BEGIN
-- Delete the depending InterFeatureLink(s)
FOR l_id IN EXECUTE format('SELECT id FROM %I.uom5_link WHERE ntw_graph_id=%L', schema_name, o_id) LOOP
	IF l_id IS NOT NULL THEN
		EXECUTE 'SELECT citydb_pkg.uom5_delete_link($1, $2)' USING l_id, schema_name;
	END IF;
END LOOP;
-- Delete the network_graph itself
EXECUTE format('DELETE FROM %I.uom5_network_graph WHERE id=%L RETURNING id', schema_name, o_id) INTO deleted_id;
RETURN deleted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_delete_network_graph (id: %): %', o_id, SQLERRM;
END;
$$ LANGUAGE plpgsql;


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Hierchy level 2
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

----------------------------------------------------------------
-- Function uom5_DELETE_RELATED_PARTY
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    citydb_pkg.uom5_delete_related_party(integer,varchar);
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_delete_related_party(
	o_id integer,
	schema_name varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
	add_id integer;
	deleted_id integer;
BEGIN
-- Delete the related_party
EXECUTE format('DELETE FROM %I.uom5_related_party WHERE id=%L RETURNING id', schema_name, o_id) INTO deleted_id;

-- Delete the depending address if not referenced by other table.
FOR add_id IN EXECUTE format('SELECT address_id FROM %I.uom5_related_party WHERE id=%L ORDER BY id', schema_name, o_id) LOOP ---------------------- check this out later
	IF add_id IS NOT NULL THEN
		IF citydb_pkg.is_not_referenced('uom5_related_party','address_id', add_id, 'id', o_id, schema_name) IS TRUE THEN
			EXECUTE 'SELECT citydb_pkg.delete_address($1, $2)' USING add_id, schema_name;
		END IF;
	END IF;
END LOOP;

RETURN deleted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_delete_related_party (id: %): %', o_id, SQLERRM;
END;
$$ LANGUAGE plpgsql;


----------------------------------------------------------------
-- Function uom5_DELETE_NETWORK_FEATURE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    citydb_pkg.uom5_delete_network_feature(integer,varchar);
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_delete_network_feature(
	o_id integer,
	schema_name varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
	class_id integer;
	classname varchar;
	nf_id integer;
	fg_id integer;
	hs_id integer;
	deleted_id integer;
BEGIN

--Foreign Key ON DELETE CASCADE => No need to delete functional_componenet
--Foreign Key ON DELETE CASCADE => No need to delete cable
--Foreign Key ON DELETE CASCADE => No need to delete pipe
--Foreign Key ON DELETE CASCADE => No need to delete protective_element
--Foreign Key ON DELETE CASCADE => No need to delete soil_and_groundwater
--Foreign Key ON DELETE CASCADE => No need to delete measured_depth
--Foreign Key ON DELETE CASCADE => No need to delete dimensions
--Foreign Key ON DELETE CASCADE => No need to delete identification
--Foreign Key ON DELETE CASCADE => No need to delete cost
--Foreign Key ON DELETE CASCADE => No need to delete functional_componenet
--Foreign Key ON DELETE CASCADE => No need to delete performance
-- No need to delete reference to material (on delete cascade in m:n table)
-- No need to delete reference to network (on delete cascade in m:n table)
-- No need to delete reference to maintenance_activity (on delete cascade in m:n table)
-- No need to delete reference to related_party (on delete cascade in m:n table)

EXECUTE format('SELECT objectclass_id FROM %I.cityobject WHERE id=%L', schema_name, o_id) INTO class_id;
EXECUTE format('SELECT citydb_pkg.get_classname(%L, %L)', class_id, schema_name) INTO classname;
RAISE NOTICE 'class id %, classname %', class_id, classname;
IF classname IS NOT NULL THEN

-- Delete the depending (sub)network_feature(s)
EXECUTE format('SELECT citydb_pkg.uom5_delete_network_feature(id, %L) FROM %I.uom5_network_feature WHERE id != %L AND ntw_feature_parent_id = %L', schema_name, schema_name, o_id, o_id);

---- Delete the depending hollow_spaces(s). Not used in this thesis.
--EXECUTE format('SELECT id FROM %I.uom5_hollow_space WHERE ntw_feature_id=%L', schema_name, o_id) INTO hs_id;
--IF hs_id IS NOT NULL THEN
--  EXECUTE 'SELECT citydb_pkg.uom5_delete_hollow_space($1, $2)' USING hs_id, schema_name;
--END IF;

-- Delete the depending feature_graph (topology)
EXECUTE format('SELECT id FROM %I.uom5_feature_graph WHERE ntw_feature_id=%L', schema_name, o_id) INTO fg_id;
IF fg_id IS NOT NULL THEN
  EXECUTE 'SELECT citydb_pkg.uom5_delete_feature_graph($1, $2)' USING fg_id, schema_name;
END IF;

-- Delete the network_feature itself
EXECUTE format('DELETE FROM %I.uom5_network_feature WHERE id=%L RETURNING id', schema_name, o_id) INTO deleted_id;
-- conduct general cleaning of cityobject
EXECUTE 'SELECT citydb_pkg.intern_delete_cityobject($1, $2)' USING o_id, schema_name;
RETURN deleted_id;

END IF;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_delete_network_graph (id: %): %', o_id, SQLERRM;
END;
$$ LANGUAGE plpgsql;


----------------------------------------------------------------
-- Function uom5_DELETE_NETWORK
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    citydb_pkg.uom5_delete_network(integer,varchar);
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_delete_network(
  o_id integer,
  schema_name varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
--  nf_id integer;
  ng_id integer;
  co_id integer;
  deleted_id integer;
BEGIN
--Foreign Key ON DELETE CASCADE => No need to delete supply_area
--Foreign Key ON DELETE CASCADE => No need to delete network_to_network
--Foreign Key ON DELETE CASCADE => No need to delete related_party_to_network
--Foreign Key ON DELETE CASCADE => No need to delete network_to_network_feature
--Foreign Key ON DELETE CASCADE => No need to delete performance
--Foreign Key ON DELETE CASCADE => No need to delete role_in_network

-- Delete subnetworks (if there are any)
EXECUTE format('SELECT citydb_pkg.uom5_delete_network(id, %L) FROM %I.uom5_network WHERE id != %L AND network_parent_id = %L', schema_name, schema_name, o_id, o_id);

-- Delete the depending network_features (if they are not referenced by some other network). NOT IMPLEMENTED.
EXECUTE format('SELECT citydb_pkg.uom5_delete_network_feature(nf.id, %L) FROM %I.uom5_network_feature AS nf, %I.uom5_network_to_network_feature AS n2nf WHERE
nf.id=n2nf.network_feature_id AND n2nf.network_id=%L AND citydb_pkg.is_not_referenced(''uom5_network_to_network_feature'', ''network_feature_id'', nf.id, ''network_id'', %L, %L)',
schema_name, schema_name, schema_name, o_id, o_id, schema_name);
--FOR nf_id IN EXECUTE format('SELECT network_feature_id FROM %I.uom5_network_to_network_feature WHERE network_id=%L ORDER BY network_feature_id', schema_name, o_id) LOOP
--	IF nf_id IS NOT NULL THEN
--	  IF citydb_pkg.is_not_referenced('uom5_network_to_network_feature','network_feature_id', nf_id, 'network_id', o_id, schema_name) IS TRUE THEN
--		  EXECUTE 'SELECT citydb_pkg.uom5_delete_network_feature($1, $2)' USING nf_id, schema_name;
--		END IF;	
--	END IF;
--END LOOP;

-- Delete the depending network_graph
EXECUTE format('SELECT id FROM %I.uom5_network_graph WHERE network_id=%L', schema_name, o_id) INTO ng_id;
IF ng_id IS NOT NULL THEN
  EXECUTE 'SELECT citydb_pkg.uom5_delete_network_graph($1, $2)' USING ng_id, schema_name;
END IF;
-- Delete the network itself
EXECUTE format('SELECT commodity_id FROM %I.uom5_network WHERE id=%L', schema_name, o_id) INTO co_id; -- first save this info for later
EXECUTE format('DELETE FROM %I.uom5_network WHERE id=%L RETURNING id', schema_name, o_id) INTO deleted_id;
-- Delete the depending commodity (if not referenced by another network). 
-- Deleting depending commodity here regardless that it is lower in the hierarchy, otherwise would have to remember to delete the commodity afterwards.
IF co_id IS NOT NULL THEN -- reuse saved info
	IF citydb_pkg.is_not_referenced('uom5_network','commodity_id', co_id, 'id', o_id, schema_name) IS TRUE THEN
    EXECUTE 'SELECT citydb_pkg.uom5_delete_commodity($1, $2)' USING co_id, schema_name;
  END IF;
END IF;
-- conduct general cleaning of cityobject
EXECUTE 'SELECT citydb_pkg.intern_delete_cityobject($1, $2)' USING o_id, schema_name;
RETURN deleted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_delete_network (id: %): %', o_id, SQLERRM;
END;
$$ LANGUAGE plpgsql;


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Hierchy level 1
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

----------------------------------------------------------------
-- Function uom5_DELETE_MATERIAL
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    citydb_pkg.uom5_delete_material(integer,varchar);
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_delete_material(
	o_id integer,
	schema_name varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
  cc_id integer;
	deleted_id integer;
BEGIN
-- Delete the material itself
EXECUTE format('DELETE FROM %I.uom5_material WHERE id=%L RETURNING id', schema_name, o_id) INTO deleted_id;
RETURN deleted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_delete_material (id: %): %', o_id, SQLERRM;
END;
$$ LANGUAGE plpgsql;


----------------------------------------------------------------
-- Function uom5_DELETE_ADDRESS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    citydb_pkg.delete_address (integer,varchar);
CREATE OR REPLACE FUNCTION citydb_pkg.delete_address (
	o_id integer,
	schema_name varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
	deleted_id integer;
BEGIN
-- Delete the storage itself
EXECUTE format('DELETE FROM %I.address WHERE id=%L RETURNING id', schema_name, o_id) INTO deleted_id;
RETURN deleted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.delete_address (id: %): %', o_id, SQLERRM;
END;
$$ LANGUAGE plpgsql;


----------------------------------------------------------------
-- Function uom5_DELETE_COMMODITY
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    citydb_pkg.uom5_delete_commodity (integer,varchar);
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_delete_commodity (
	o_id integer,
	schema_name varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
	cc_id integer;
	deleted_id integer;
BEGIN
-- Delete the depending commodity_classifier
FOR cc_id IN EXECUTE format('SELECT id FROM %I.uom5_commodity_classifier WHERE commodity_id=%L ORDER BY id', schema_name, o_id) LOOP
	IF cc_id IS NOT NULL THEN
	  EXECUTE 'SELECT citydb_pkg.uom5_delete_commodity_classifier($1, $2)' USING cc_id, schema_name;
	END IF;
END LOOP;

-- Delete the commodity itself
EXECUTE format('DELETE FROM %I.uom5_commodity WHERE id=%L RETURNING id', schema_name, o_id) INTO deleted_id;
RETURN deleted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_delete_commodity (id: %): %', o_id, SQLERRM;
END;
$$ LANGUAGE plpgsql;



-- ********************************************************************************************************************************************************************************************************************************************************************************************************************************************************************
-- INSERT FUNCTIONS FROM UTILITY PACKAGE (NECESSARY FOR uom5). Copied from "02_citydb_util_DML_FUNCTIONS.sql"

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Hierchy level 1: Independent from other tables
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

----------------------------------------------------------------
-- Function INSERT_CITYOBJECT
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    citydb_pkg.insert_cityobject(integer, integer, character varying, character varying, character varying, character varying, character varying, geometry, timestamp with time zone, timestamp with time zone, character varying, character varying, timestamp with time zone, character varying, character varying, character varying, character varying) CASCADE;
CREATE OR REPLACE FUNCTION citydb_pkg.insert_cityobject (
	objectclass_id         integer,
	id                     integer DEFAULT NULL,
	gmlid                  varchar(256) DEFAULT NULL,
	gmlid_codespace        varchar(1000) DEFAULT NULL,
	name                   varchar(1000) DEFAULT NULL,
	name_codespace         varchar(4000) DEFAULT NULL,
	description            varchar(4000) DEFAULT NULL,
	envelope               geometry DEFAULT NULL,
	creation_date          timestamp(0) with time zone DEFAULT NULL,
	termination_date       timestamp(0) with time zone DEFAULT NULL,
	relative_to_terrain    varchar(256) DEFAULT NULL,
	relative_to_water      varchar(256) DEFAULT NULL,
	last_modification_date timestamp with time zone DEFAULT NULL,
	updating_person        varchar(256) DEFAULT NULL,
	reason_for_update      varchar(4000) DEFAULT NULL,
	lineage                varchar(256) DEFAULT NULL,
--
	schema_name            varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS
$$
DECLARE
	p_id                     integer                     := id                    ;
	p_objectclass_id         integer	                 := objectclass_id        ;
	p_gmlid                  varchar(256)                := gmlid                 ;
	p_gmlid_codespace        varchar(1000)               := gmlid_codespace       ;
	p_name                   varchar(1000)               := name                  ;
	p_name_codespace         varchar(4000)               := name_codespace        ;
	p_description            varchar(4000)               := description           ;
	p_envelope               geometry                    := envelope              ;
	p_creation_date          timestamp(0) with time zone := creation_date         ;
	p_termination_date       timestamp(0) with time zone := termination_date      ;
	p_relative_to_terrain    varchar(256)                := relative_to_terrain   ;
	p_relative_to_water      varchar(256)                := relative_to_water     ;
	p_last_modification_date timestamp with time zone    := last_modification_date;
	p_updating_person        varchar(256)                := updating_person       ;
	p_reason_for_update      varchar(4000)               := reason_for_update     ;
	p_lineage                varchar(256)                := lineage               ;
--
	p_schema_name 			varchar 					 := schema_name			  ;
	seq_name 				varchar;
	inserted_id 			integer;
BEGIN
-- IF the ID is not given, then generate a new one.
IF p_id IS NULL THEN
	seq_name=schema_name||'.cityobject_seq';
	p_id=nextval(seq_name::regclass);
END IF;
-- IF the GmlID is not given, then generate a new one.
IF p_gmlid IS NULL THEN
	p_gmlid='UUID_'||uuid_generate_v4();
END IF;
-- IF the creation_date is not given, then generate a new one.
IF p_creation_date IS NULL THEN
	p_creation_date=now()::timestamp(0) with time zone;
END IF;

EXECUTE format('INSERT INTO %I.cityobject (
	id,
	objectclass_id,
	gmlid,
	gmlid_codespace,
	name,
	name_codespace,
	description,
	envelope,
	creation_date,
	termination_date,
	relative_to_terrain,
	relative_to_water,
	last_modification_date,
	updating_person,
	reason_for_update,
	lineage
) VALUES (
%L, %L, %L, %L, %L, %L, %L, %L, %L, %L,
%L, %L, %L, %L, %L, %L
) RETURNING id',
	p_schema_name,		-- ADD schema_name,
	p_id,						-- ADD p_id
	p_objectclass_id,
	p_gmlid,
	p_gmlid_codespace,
	p_name,
	p_name_codespace,
	p_description,
	p_envelope,
	p_creation_date,
	p_termination_date,
	p_relative_to_terrain,
	p_relative_to_water,
	p_last_modification_date,
	p_updating_person,
	p_reason_for_update,
	p_lineage
) INTO inserted_id;
RETURN inserted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.insert_cityobject (id: %): %', p_id, SQLERRM;
END;
$$
LANGUAGE 'plpgsql';

----------------------------------------------------------------
-- Function INSERT_ADDRESS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS citydb_pkg.insert_address (integer, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, geometry, text, varchar) CASCADE;
CREATE OR REPLACE FUNCTION citydb_pkg.insert_address (
	id              integer  DEFAULT NULL,
	gmlid           varchar  DEFAULT NULL,
	gmlid_codespace varchar  DEFAULT NULL,
	street          varchar  DEFAULT NULL,
	house_number    varchar  DEFAULT NULL,
	po_box          varchar  DEFAULT NULL,
	zip_code        varchar  DEFAULT NULL,
	city            varchar  DEFAULT NULL,
	state           varchar  DEFAULT NULL,
	country         varchar  DEFAULT NULL,
	multi_point     geometry DEFAULT NULL,
	xal_source      text     DEFAULT NULL,
--
	schema_name 	varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS
$$
DECLARE
	p_id              integer  := id;
	p_gmlid           varchar  := gmlid;
	p_gmlid_codespace varchar  := gmlid_codespace;
	p_street          varchar  := street;
	p_house_number    varchar  := house_number;
	p_po_box          varchar  := po_box;
	p_zip_code        varchar  := zip_code;
	p_city            varchar  := city;
	p_state           varchar  := state;
	p_country         varchar  := country;
	p_multi_point     geometry := multi_point;
	p_xal_source      text     := xal_source;
--
	p_schema_name     varchar  := schema_name;
	seq_name          varchar;
	inserted_id       integer;
BEGIN
-- IF the ID is not given, then generate a new one.
IF p_id IS NULL THEN
  seq_name=schema_name||'.address_seq';
  p_id=nextval(seq_name::regclass);
END IF;
-- IF the GmlID is not given, then generate a new one.
IF p_gmlid IS NULL THEN
  p_gmlid='UUID_'||uuid_generate_v4();
END IF;

EXECUTE format('
INSERT INTO %I.address (
	id,
	gmlid,
	gmlid_codespace,
	street,
	house_number,
	po_box,
	zip_code,
	city,
	state,
	country,
	multi_point,
	xal_source
) VALUES (
%L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L
) RETURNING id',
	p_schema_name,
	p_id,
	p_gmlid,
	p_gmlid_codespace,
	p_street,
	p_house_number,
	p_po_box,
	p_zip_code,
	p_city,
	p_state,
	p_country,
	p_multi_point,
	p_xal_source
) INTO inserted_id;
RETURN inserted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.insert_address (id: %): %', p_id, SQLERRM;
END;
$$
LANGUAGE 'plpgsql';


-- ****************************************************************************************************************************************************************
-- INSERT FUNCTIONS FROM uom5

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Hierchy level 1: Independent from other tables
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

----------------------------------------------------------------
-- Function uom5_INSERT_COMMODITY
----------------------------------------------------------------
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_insert_commodity (
	objectclass_id   				integer,
	id   							integer DEFAULT NULL,
	gmlid 							varchar DEFAULT NULL,
	gmlid_codespace  				varchar DEFAULT NULL,
	name 							varchar DEFAULT NULL,
	name_codespace   				varchar DEFAULT NULL,
	description  					text 	DEFAULT NULL,
	owner 							varchar DEFAULT NULL,
	type 							varchar DEFAULT NULL,
	is_corrosive 					numeric DEFAULT NULL,
	is_explosive 					numeric DEFAULT NULL,
	is_lighter_than_air  			numeric DEFAULT NULL,
	is_flammable 					numeric DEFAULT NULL,
	flammability_ratio   			numeric DEFAULT NULL,
	elec_conductivity_range_from 	numeric DEFAULT NULL,
	elec_conductivity_range_to 		numeric DEFAULT NULL,
	elec_conductivity_range_unit 	varchar DEFAULT NULL,
	concentration 					numeric DEFAULT NULL,
	concentration_unit   			varchar DEFAULT NULL,
	ph_value_range_from  			numeric DEFAULT NULL,
	ph_value_range_to 				numeric DEFAULT NULL,
	ph_value_range_unit  			varchar DEFAULT NULL,
	temperature_range_from 			numeric DEFAULT NULL,
	temperature_range_to 			numeric DEFAULT NULL,
	temperature_range_unit 			varchar DEFAULT NULL,
	flow_rate_range_from 			numeric DEFAULT NULL,
	flow_rate_range_to   			numeric DEFAULT NULL,
	flow_rate_range_unit 			varchar DEFAULT NULL,
	pressure_range_from  			numeric DEFAULT NULL,
	pressure_range_to 				numeric DEFAULT NULL,
	pressure_range_unit  			varchar DEFAULT NULL,
	pressure_nominal 				numeric DEFAULT NULL,
	pressure_nominal_unit 			varchar DEFAULT NULL,
	pressure_operating 				numeric DEFAULT NULL,
	pressure_operating_unit 		varchar DEFAULT NULL,
	pressure_maximum 				numeric DEFAULT NULL,
	pressure_maximum_unit 			varchar DEFAULT NULL,  
	voltage_range_from  			numeric DEFAULT NULL,
	voltage_range_to 				numeric DEFAULT NULL,
	voltage_range_unit   			varchar DEFAULT NULL,
	voltage_nominal 				numeric DEFAULT NULL,
	voltage_nominal_unit 			varchar DEFAULT NULL,
	voltage_operating 				numeric DEFAULT NULL,
	voltage_operating_unit 			varchar DEFAULT NULL,
	amperage_range_from  			numeric DEFAULT NULL,
	amperage_range_to 				numeric DEFAULT NULL,
	amperage_range_unit  			varchar DEFAULT NULL,
	bandwidth_range_from 			numeric DEFAULT NULL,
	bandwidth_range_to   			numeric DEFAULT NULL,
	bandwidth_range_unit   			varchar DEFAULT NULL,
	optical_mode 					varchar DEFAULT NULL, 
	phase_value 					integer DEFAULT NULL,
--	
	schema_name 					varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
	p_id   							integer := id  ;
	p_objectclass_id   				integer := objectclass_id  ;
	p_gmlid 						varchar := gmlid   ;
	p_gmlid_codespace  				varchar := gmlid_codespace ;
	p_name 							varchar := name;
	p_name_codespace   				varchar := name_codespace  ;
	p_description  					text	:= description ;
	p_owner 						varchar := owner   ;
	p_type 							varchar := type;
	p_is_corrosive 					numeric := is_corrosive;
	p_is_explosive 					numeric := is_explosive;
	p_is_lighter_than_air  			numeric := is_lighter_than_air ;
	p_is_flammable 					numeric := is_flammable ;
	p_flammability_ratio   			numeric := flammability_ratio  ;
	p_elec_conductivity_range_from	numeric := elec_conductivity_range_from;
	p_elec_conductivity_range_to	numeric := elec_conductivity_range_to  ;
	p_elec_conductivity_range_unit  varchar := elec_conductivity_range_unit  ;
	p_concentration 				numeric := concentration   ;
	p_concentration_unit   			varchar := concentration_unit  ;
	p_ph_value_range_from  			numeric := ph_value_range_from ;
	p_ph_value_range_to 			numeric := ph_value_range_to   ;
	p_ph_value_range_unit  			varchar := ph_value_range_unit ;
	p_temperature_range_from   		numeric := temperature_range_from  ;
	p_temperature_range_to 			numeric := temperature_range_to;
	p_temperature_range_unit   		varchar := temperature_range_unit  ;
	p_flow_rate_range_from 			numeric := flow_rate_range_from;
	p_flow_rate_range_to   			numeric := flow_rate_range_to  ;
	p_flow_rate_range_unit 			varchar := flow_rate_range_unit;
	p_pressure_range_from  			numeric := pressure_range_from ;
	p_pressure_range_to 			numeric := pressure_range_to   ;
	p_pressure_range_unit  			varchar := pressure_range_unit ;
	p_pressure_nominal 				numeric := pressure_nominal  ;
	p_pressure_nominal_unit 		varchar := pressure_nominal_unit ;
	p_pressure_operating 			numeric := pressure_operating ;
	p_pressure_operating_unit 		varchar := pressure_operating_unit ;
	p_pressure_maximum 				numeric := pressure_maximum ;
	p_pressure_maximum_unit 		varchar := pressure_maximum_unit ;
	p_voltage_range_from   			numeric := voltage_range_from  ;
	p_voltage_range_to 				numeric := voltage_range_to;
	p_voltage_range_unit   			varchar := voltage_range_unit  ;
	p_voltage_nominal 				numeric := voltage_nominal  ;
	p_voltage_nominal_unit 			varchar := voltage_nominal_unit  ;
	p_voltage_operating 			numeric := voltage_operating  ;
	p_voltage_operating_unit 		varchar := voltage_operating_unit  ;
	p_amperage_range_from  			numeric := amperage_range_from ;
	p_amperage_range_to 			numeric := amperage_range_to   ;
	p_amperage_range_unit  			varchar := amperage_range_unit ;
	p_bandwidth_range_from 			numeric := bandwidth_range_from;
	p_bandwidth_range_to   			numeric := bandwidth_range_to  ;
	p_bandwidth_range_unit   		varchar := bandwidth_range_unit  ;
	p_optical_mode 					varchar := optical_mode  ;
	p_phase_value 					integer := phase_value ;
--	
	p_schema_name 					varchar := schema_name;
	seq_name 						varchar;
	inserted_id 					integer;
BEGIN
-- IF the ID is not given, then generate a new one.
IF p_id IS NULL THEN
  seq_name=schema_name||'.uom5_commodity_id_seq';
  p_id=nextval(seq_name::regclass);
END IF;
-- IF the GmlID is not given, then generate a new one.
IF p_gmlid IS NULL THEN
  p_gmlid='UUID_'||uuid_generate_v4();
END IF;

EXECUTE format('
INSERT INTO %I.uom5_commodity (
	id,
	objectclass_id,
	gmlid,
	gmlid_codespace,
	name,
	name_codespace,
	description,
	owner,
	type,
	is_corrosive,
	is_explosive,
	is_lighter_than_air,
	is_flammable,
	flammability_ratio,
	elec_conductivity_range_from,
	elec_conductivity_range_to,
	elec_conductivity_range_unit,
	concentration,
	concentration_unit,
	ph_value_range_from,
	ph_value_range_to,
	ph_value_range_unit,
	temperature_range_from,
	temperature_range_to,
	temperature_range_unit,
	flow_rate_range_from,
	flow_rate_range_to,
	flow_rate_range_unit,
	pressure_range_from,
	pressure_range_to,
	pressure_range_unit,
	pressure_nominal,
	pressure_nominal_unit,
	pressure_operating,
	pressure_operating_unit,
	pressure_maximum,
	pressure_maximum_unit,
	voltage_range_from,
	voltage_range_to,
	voltage_range_unit,
	voltage_nominal,
	voltage_nominal_unit,
	voltage_operating,
	voltage_operating_unit,
	amperage_range_from,
	amperage_range_to,
	amperage_range_unit,
	bandwidth_range_from,
	bandwidth_range_to,
	bandwidth_range_unit,
	optical_mode,
	phase_value
) VALUES (
%L, %L, %L, %L, %L, %L, %L, %L, %L, %L,
%L, %L, %L, %L, %L, %L, %L, %L, %L, %L, 
%L, %L, %L, %L, %L, %L, %L, %L, %L, %L, 
%L, %L, %L, %L, %L, %L, %L, %L, %L, %L,
%L, %L, %L, %L, %L, %L, %L, %L, %L, %L,
%L, %L
) RETURNING id',
	p_schema_name,
	p_id, 
	p_objectclass_id, 
	p_gmlid, 
	p_gmlid_codespace, 
	p_name, 
	p_name_codespace, 
	p_description, 
	p_owner, 
	p_type, 
	p_is_corrosive, 
	p_is_explosive, 
	p_is_flammable,
	p_is_lighter_than_air, 
	p_flammability_ratio, 
	p_elec_conductivity_range_from, 
	p_elec_conductivity_range_to, 
	p_elec_conductivity_range_unit, 
	p_concentration, 
	p_concentration_unit, 
	p_ph_value_range_from, 
	p_ph_value_range_to, 
	p_ph_value_range_unit, 
	p_temperature_range_from, 
	p_temperature_range_to, 
	p_temperature_range_unit, 
	p_flow_rate_range_from, 
	p_flow_rate_range_to, 
	p_flow_rate_range_unit, 
	p_pressure_range_from, 
	p_pressure_range_to, 
	p_pressure_range_unit, 
	p_pressure_nominal,
	p_pressure_nominal_unit,
	p_pressure_operating,
	p_pressure_operating_unit,
	p_pressure_maximum,
	pressure_maximum_unit,
	p_voltage_range_from, 
	p_voltage_range_to, 
	p_voltage_range_unit, 
	p_voltage_nominal,
	p_voltage_nominal_unit,
	p_voltage_operating,
	p_voltage_operating_unit,
	p_amperage_range_from, 
	p_amperage_range_to, 
	p_amperage_range_unit, 
	p_bandwidth_range_from, 
	p_bandwidth_range_to, 
	p_bandwidth_range_unit, 
	p_optical_mode,
	p_phase_value
) INTO inserted_id;
RETURN inserted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_insert_commodity (id: %): %', p_id, SQLERRM;
END;
$$ LANGUAGE 'plpgsql';


----------------------------------------------------------------
-- Function uom5_INSERT_MATERIAL
----------------------------------------------------------------
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_insert_material (
	objectclass_id     			integer,
	id                 			integer DEFAULT NULL,
	gmlid              			varchar DEFAULT NULL,
	gmlid_codespace    			varchar DEFAULT NULL,
	name               			varchar DEFAULT NULL,
	name_codespace     			varchar DEFAULT NULL,
	description        			text    DEFAULT NULL,
	type               			varchar DEFAULT NULL,
	specific_class				varchar DEFAULT NULL,
	compressive_strength		numeric DEFAULT NULL,
	compressive_strength_unit	varchar DEFAULT NULL,
	ductility					numeric DEFAULT NULL,
	ductility_unit				varchar DEFAULT NULL,
	conductivity				numeric DEFAULT NULL,
	conductivity_unit			varchar DEFAULT NULL,
--	
	schema_name 				varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
	p_id                 		integer := id;
	p_objectclass_id     		integer := objectclass_id;
	p_gmlid              		varchar := gmlid;
	p_gmlid_codespace    		varchar := gmlid_codespace;
	p_name               		varchar := name;
	p_name_codespace     		varchar := name_codespace;
	p_description        		text    := description;
	p_type               		varchar := type;
	p_specific_class			varchar	:= specific_class;
	p_compressive_strength		numeric	:= compressive_strength;
	p_compressive_strength_unit	varchar	:= compressive_strength_unit;
	p_ductility					numeric	:= ductility;
	p_ductility_unit			varchar	:= ductility_unit;
	p_conductivity				numeric	:= conductivity;
	p_conductivity_unit			varchar	:= conductivity_unit;
--
	p_schema_name 				varchar := schema_name;
	seq_name 					varchar;
	inserted_id 				integer;
	
BEGIN
-- IF the ID is not given, then generate a new one.
IF p_id IS NULL THEN
  seq_name=schema_name||'.uom5_material_id_seq';
  p_id=nextval(seq_name::regclass);
END IF;
-- IF the GmlID is not given, then generate a new one.
IF p_gmlid IS NULL THEN
  p_gmlid='UUID_'||uuid_generate_v4();
END IF;

EXECUTE format('INSERT INTO %I.uom5_material (
	id,
	objectclass_id,
	gmlid,
	gmlid_codespace,
	name,
	name_codespace,
	description,
	type,
	specific_class,
	compressive_strength,
	compressive_strength_unit,
	ductility,
	ductility_unit,
	conductivity,
	conductivity_unit
) VALUES (
%L, %L, %L, %L, %L, %L, %L, %L, %L, %L,
%L, %L, %L, %L, %L
) RETURNING id',
	p_schema_name,
	p_id, 
	p_objectclass_id, 
	p_gmlid, 
	p_gmlid_codespace, 
	p_name, 
	p_name_codespace, 
	p_description, 
	p_type, 
	p_specific_class,
	p_compressive_strength,
	p_compressive_strength_unit,
	p_ductility,
	p_ductility_unit,
	p_conductivity,
	p_conductivity_unit
) INTO inserted_id;
RETURN inserted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_insert_material (id: %): %', p_id, SQLERRM;
END;
$$ LANGUAGE 'plpgsql';


----------------------------------------------------------------
-- Function uom5_INSERT_MAINTENANCE_ACTIVITY
----------------------------------------------------------------
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_insert_maintenance_activity (
	objectclass_id					integer,
	id								integer DEFAULT NULL,
	gmlid							varchar DEFAULT NULL,
	gmlid_codespace					varchar DEFAULT NULL,
	name							varchar DEFAULT NULL,
	name_codespace					varchar DEFAULT NULL,
	description						text 	DEFAULT NULL,
	maintenance_timeline			varchar DEFAULT NULL,
	maintenance_type				varchar DEFAULT NULL,
	activity_type					varchar DEFAULT NULL,
	extra_information				varchar DEFAULT NULL,
	start_date						date 	DEFAULT NULL,
	end_date						date 	DEFAULT NULL,
	schema_name 					varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
	p_id   							integer := id  ;
	p_objectclass_id   				integer := objectclass_id  ;
	p_gmlid 						varchar := gmlid   ;
	p_gmlid_codespace  				varchar := gmlid_codespace ;
	p_name 							varchar := name;
	p_name_codespace   				varchar := name_codespace  ;
	p_description  					text	:= description ;
	p_maintenance_timeline			varchar := maintenance_timeline ;
	p_maintenance_type				varchar := maintenance_type ;
	p_activity_type					varchar := activity_type ;
	p_extra_information				varchar := extra_information ;
	p_start_date					date	:= start_date ;
	p_end_date						date	:= end_date ;
--	
	p_schema_name 					varchar := schema_name;
	seq_name 						varchar;
	inserted_id 					integer;
	
BEGIN
-- IF the ID is not given, then generate a new one.
IF p_id IS NULL THEN
  seq_name=schema_name||'.uom5_maintenance_activity_id_seq';
  p_id=nextval(seq_name::regclass);
END IF;
-- IF the GmlID is not given, then generate a new one.
IF p_gmlid IS NULL THEN
  p_gmlid='UUID_'||uuid_generate_v4();
END IF;

EXECUTE format('
INSERT INTO %I.uom5_maintenance_activity (
	id,
	objectclass_id,
	gmlid,
	gmlid_codespace,
	name,
	name_codespace,
	description,
	maintenance_timeline,
	maintenance_type,
	activity_type,
	extra_information,
	start_date,
	end_date
) VALUES (
%L, %L, %L, %L, %L, %L, %L, %L, %L, %L,
%L, %L, %L
) RETURNING id',
	p_schema_name,
	p_id, 
	p_objectclass_id, 
	p_gmlid, 
	p_gmlid_codespace, 
	p_name, 
	p_name_codespace, 
	p_description, 
	p_maintenance_timeline,
	p_maintenance_type,
	p_activity_type,
	p_extra_information,
	p_start_date,
	p_end_date
) INTO inserted_id;
RETURN inserted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_insert_maintenance_activity (id: %): %', p_id, SQLERRM;
END;
$$ LANGUAGE 'plpgsql';


----------------------------------------------------------------
-- Function uom5_INSERT_IMPACT
----------------------------------------------------------------
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_insert_impact (
	objectclass_id					integer,
	id								integer DEFAULT NULL,
	gmlid							varchar DEFAULT NULL,
	gmlid_codespace					varchar DEFAULT NULL,
	name							varchar DEFAULT NULL,
	name_codespace					varchar DEFAULT NULL,
	description						text 	DEFAULT NULL,
	environm_impact_score			numeric DEFAULT NULL,
	environm_impact_extra_info		varchar DEFAULT NULL,
	social_impact_score				numeric DEFAULT NULL,
	social_impact_extra_info		varchar DEFAULT NULL,
	economic_impact_score			numeric DEFAULT NULL,
	economic_impact_extra_info		varchar DEFAULT NULL,	
--
	schema_name 					varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
	p_id   							integer := id  ;
	p_objectclass_id   				integer := objectclass_id  ;
	p_gmlid 						varchar := gmlid   ;
	p_gmlid_codespace  				varchar := gmlid_codespace ;
	p_name 							varchar := name;
	p_name_codespace   				varchar := name_codespace  ;
	p_description  					text	:= description ;
	p_environm_impact_score			numeric	:= environm_impact_score ;
	p_environm_impact_extra_info	varchar	:= environm_impact_extra_info ;
	p_social_impact_score			numeric	:= social_impact_score ;
	p_social_impact_extra_info		varchar	:= social_impact_extra_info ;
	p_economic_impact_score			numeric	:= economic_impact_score ;
	p_economic_impact_extra_info	varchar	:= economic_impact_extra_info ;
--	
	p_schema_name 					varchar := schema_name;
	seq_name 						varchar;
	inserted_id 					integer;
	
BEGIN
-- IF the ID is not given, then generate a new one.
IF p_id IS NULL THEN
  seq_name=schema_name||'.uom5_impact_id_seq';
  p_id=nextval(seq_name::regclass);
END IF;
-- IF the GmlID is not given, then generate a new one.
IF p_gmlid IS NULL THEN
  p_gmlid='UUID_'||uuid_generate_v4();
END IF;

EXECUTE format('
INSERT INTO %I.uom5_impact (
	id,
	objectclass_id,
	gmlid,
	gmlid_codespace,
	name,
	name_codespace,
	description,
	environm_impact_score,
	environm_impact_extra_info,
	social_impact_score,
	social_impact_extra_info,
	economic_impact_score,
	economic_impact_extra_info
) VALUES (
%L, %L, %L, %L, %L, %L, %L, %L, %L, %L,
%L, %L, %L
) RETURNING id',
	p_schema_name,
	p_id, 
	p_objectclass_id, 
	p_gmlid, 
	p_gmlid_codespace, 
	p_name, 
	p_name_codespace, 
	p_description, 
	p_environm_impact_score,
	p_environm_impact_extra_info,
	p_social_impact_score,
	p_social_impact_extra_info,
	p_economic_impact_score,
	p_economic_impact_extra_info
) INTO inserted_id;
RETURN inserted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_insert_impact (id: %): %', p_id, SQLERRM;
END;
$$ LANGUAGE 'plpgsql';


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Hierchy level 2
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

----------------------------------------------------------------
-- Function uom5_INSERT_NETWORK
----------------------------------------------------------------
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_insert_network (
	objectclass_id  	integer,
	id              	integer,				-- citydb.cityobject (id)
	network_parent_id 	integer DEFAULT NULL,
	network_root_id 	integer DEFAULT NULL,
	class           	varchar DEFAULT NULL,
	function        	varchar DEFAULT NULL,
	usage           	varchar DEFAULT NULL,
	commodity_id    	integer DEFAULT NULL,
	impact_id			integer DEFAULT NULL,
--	
	schema_name       	varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
	p_id               	integer := id;
	p_objectclass_id   	integer := objectclass_id;
	p_network_parent_id	integer := network_parent_id;
	p_network_root_id  	integer := network_root_id;
	p_class            	varchar := class;
	p_function         	varchar := function;
	p_usage            	varchar := usage;
	p_commodity_id     	integer := commodity_id;
	p_impact_id     	integer := impact_id;
--	
	p_schema_name 		varchar := schema_name;
	inserted_id 		integer;
BEGIN
EXECUTE format('
INSERT INTO %I.uom5_network (
	id,
	objectclass_id,
	network_parent_id,
	network_root_id,
	class,
	function,
	usage,
	commodity_id,
	impact_id
) VALUES (
%L, %L, %L, %L, %L, %L, %L, %L, %L
) RETURNING id',
	p_schema_name,
	p_id, 
	p_objectclass_id, 
	p_network_parent_id, 
	p_network_root_id, 
	p_class, 
	p_function, 
	p_usage, 
	p_commodity_id,
	p_impact_id
) INTO inserted_id;
RETURN inserted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_insert_network (id: %): %', p_id, SQLERRM;
END;
$$ LANGUAGE 'plpgsql';


----------------------------------------------------------------
-- Function uom5_INSERT_NETWORK_FEATURE
----------------------------------------------------------------
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_insert_network_feature (
	objectclass_id        		integer,
	id                    		integer,
	ntw_feature_parent_id 		integer	 DEFAULT NULL,
	ntw_feature_root_id   		integer	 DEFAULT NULL,
	function              		varchar	 DEFAULT NULL,
	usage                 		varchar	 DEFAULT NULL,
	conn_cityobject_id    		integer	 DEFAULT NULL,
	status                		varchar	 DEFAULT NULL,
	location_quality      		varchar	 DEFAULT NULL,
	elevation_quality     		varchar	 DEFAULT NULL,
	standard_depth				numeric	 DEFAULT NULL,
	standard_depth_unit			varchar	 DEFAULT NULL,
	prot_element_id       		integer	 DEFAULT NULL,
	geom                  		geometry DEFAULT NULL,
	date_of_installation		date 	 DEFAULT NULL,
	date_in_use					date 	 DEFAULT NULL,
	date_of_location_measuring	date 	 DEFAULT NULL,
	date_of_registration		date 	 DEFAULT NULL,
	date_of_abandonment			date 	 DEFAULT NULL,
	date_of_removal				date 	 DEFAULT NULL,
	impact_id					integer	 DEFAULT NULL,
--	
	schema_name 				varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
	p_id                     	 integer  := id;
	p_objectclass_id         	 integer  := objectclass_id;
	p_ntw_feature_parent_id  	 integer  := ntw_feature_parent_id;
	p_ntw_feature_root_id    	 integer  := ntw_feature_root_id;
	p_function               	 varchar  := function;
	p_usage                  	 varchar  := usage;
	p_conn_cityobject_id     	 integer  := conn_cityobject_id;
	p_status                 	 varchar  := status;
	p_location_quality       	 varchar  := location_quality;
	p_elevation_quality      	 varchar  := elevation_quality;
	p_standard_depth			 numeric  := standard_depth;
	p_standard_depth_unit		 varchar  := standard_depth_unit;
	p_prot_element_id        	 integer  := prot_element_id;
	p_geom                   	 geometry := geom;	
	p_date_of_installation		 date	  := date_of_installation;
	p_date_in_use				 date	  := date_in_use;
	p_date_of_location_measuring date	  := date_of_location_measuring;
	p_date_of_registration		 date	  := date_of_registration;
	p_date_of_abandonment		 date	  := date_of_abandonment;
	p_date_of_removal			 date	  := date_of_removal;
	p_impact_id					 integer  := impact_id;
--	
	p_schema_name 				varchar  := schema_name;
	inserted_id 				integer;
BEGIN
EXECUTE format('
INSERT INTO %I.uom5_network_feature (
	id,
	objectclass_id,
	ntw_feature_parent_id,
	ntw_feature_root_id,
	function,
	usage,
	conn_cityobject_id,
	status,
	location_quality,
	elevation_quality,
	standard_depth,
	standard_depth_unit,
	prot_element_id,
	geom,
	date_of_installation,
	date_in_use,
	date_of_location_measuring,
	date_of_registration,
	date_of_abandonment,
	date_of_removal,
	impact_id
) VALUES (
%L, %L, %L, %L, %L, %L, %L, %L, %L, %L,
%L, %L, %L, %L, %L, %L, %L, %L, %L, %L, 
%L
) RETURNING id',
	p_schema_name,
	p_id,
	p_objectclass_id,
	p_ntw_feature_parent_id,
	p_ntw_feature_root_id,
	p_function,
	p_usage,
	p_conn_cityobject_id,
	p_status,
	p_location_quality,
	p_elevation_quality,
	p_standard_depth,
	p_standard_depth_unit,
	p_prot_element_id, 
	p_geom,
	p_date_of_installation,
	p_date_in_use,
	p_date_of_location_measuring,
	p_date_of_registration,
	p_date_of_abandonment,
	p_date_of_removal,
	p_impact_id
) INTO inserted_id;
RETURN inserted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_insert_network_feature (id: %): %', p_id, SQLERRM;
END;
$$ LANGUAGE 'plpgsql';


----------------------------------------------------------------
-- Function uom5_INSERT_COMMODITY_SUPPLY
----------------------------------------------------------------
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_insert_commodity_supply (
	objectclass_id          	integer,
	id                      	integer DEFAULT NULL,
	type                    	varchar DEFAULT NULL,
	current_flow_rate      		numeric DEFAULT NULL,
	current_flow_rate_unit		varchar DEFAULT NULL,
	current_status         		varchar DEFAULT NULL,
	potential_flow_rate      	numeric DEFAULT NULL,
	potential_flow_rate_unit 	varchar DEFAULT NULL,
	potential_status         	varchar DEFAULT NULL,
	cityobject_id           	integer DEFAULT NULL,
--	
	schema_name 				varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
	p_id                    	integer := id;
	p_objectclass_id        	integer := objectclass_id;
	p_type                  	varchar := type;
	p_current_flow_rate     	numeric := current_flow_rate;
	p_current_flow_rate_unit 	varchar := current_flow_rate_unit;
	p_current_status        	varchar := current_status;
	p_potential_flow_rate      	numeric := potential_flow_rate;
	p_potential_flow_rate_unit 	varchar := potential_flow_rate_unit;
	p_potential_status         	varchar := potential_status;
	p_cityobject_id         	integer := cityobject_id;
--	
	p_schema_name 				varchar := schema_name;
	seq_name 					varchar;
	inserted_id 				integer;
BEGIN
-- IF the ID is not given, then generate a new one.
IF p_id IS NULL THEN
  seq_name=schema_name||'.uom5_commodity_supply_id_seq';
  p_id=nextval(seq_name::regclass);
END IF;

EXECUTE format('
INSERT INTO %I.uom5_commodity_supply (
	id,
	objectclass_id,
	type,
	current_flow_rate,
	current_flow_rate_unit,
	current_status,
	potential_flow_rate,
	potential_flow_rate_unit,
	potential_status,
	cityobject_id
) VALUES (
%L, %L, %L, %L, %L, %L, %L, %L, %L, %L
) RETURNING id',
	p_schema_name,
	p_id, 
	p_objectclass_id, 
	p_type, 
	p_current_flow_rate, 
	p_current_flow_rate_unit, 
	p_current_status, 
	p_potential_flow_rate, 
	p_potential_flow_rate_unit, 
	p_potential_status, 
	p_cityobject_id
) INTO inserted_id;
RETURN inserted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_insert_commodity_supply (id: %): %', p_id, SQLERRM;
END;
$$ LANGUAGE 'plpgsql';


----------------------------------------------------------------
-- Function uom5_INSERT_RELATED_PARTY
----------------------------------------------------------------
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_insert_related_party (
	objectclass_id					integer,
	id								integer DEFAULT NULL,
	gmlid							varchar DEFAULT NULL,
	gmlid_codespace					varchar DEFAULT NULL,
	name							varchar DEFAULT NULL,
	name_codespace					varchar DEFAULT NULL,
	description						text 	DEFAULT NULL,
	individual_name					varchar DEFAULT NULL,
	organisation_name				varchar DEFAULT NULL,
	role							varchar DEFAULT NULL,
	contact_instruction				varchar DEFAULT NULL,
	email_address					varchar DEFAULT NULL,
	hours_of_service				varchar DEFAULT NULL,
	telephone_facsimile				varchar DEFAULT NULL,
	telephone_voice_organisation	varchar DEFAULT NULL,
	telephone_voice_individual		varchar DEFAULT NULL,
	website							varchar DEFAULT NULL,
	coc_number						varchar DEFAULT NULL,
	address_id						integer DEFAULT NULL,
--
	schema_name 					varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
	p_id   							integer := id  ;
	p_objectclass_id   				integer := objectclass_id  ;
	p_gmlid 						varchar := gmlid   ;
	p_gmlid_codespace  				varchar := gmlid_codespace ;
	p_name 							varchar := name;
	p_name_codespace   				varchar := name_codespace  ;
	p_description  					text	:= description ;
	p_individual_name				varchar := individual_name ;
	p_organisation_name				varchar := organisation_name ;
	p_role							varchar := role ;
	p_contact_instruction			varchar := contact_instruction ;
	p_email_address					varchar := email_address ;
	p_hours_of_service				varchar := hours_of_service ;
	p_telephone_facsimile			varchar := telephone_facsimile ;
	p_telephone_voice_organisation	varchar := telephone_voice_organisation ;
	p_telephone_voice_individual	varchar := telephone_voice_individual ;
	p_website						varchar := website ;
	p_coc_number					varchar := coc_number ;
	p_address_id 					integer := address_id ;
--	
	p_schema_name 					varchar := schema_name;
	seq_name 						varchar;
	inserted_id 					integer;
	
BEGIN
-- IF the ID is not given, then generate a new one.
IF p_id IS NULL THEN
  seq_name=schema_name||'.uom5_related_party_id_seq';
  p_id=nextval(seq_name::regclass);
END IF;
-- IF the GmlID is not given, then generate a new one.
IF p_gmlid IS NULL THEN
  p_gmlid='UUID_'||uuid_generate_v4();
END IF;

EXECUTE format('
INSERT INTO %I.uom5_related_party (
	id,
	objectclass_id,
	gmlid,
	gmlid_codespace,
	name,
	name_codespace,
	description,
	individual_name,
	organisation_name,
	role,
	contact_instruction,
	email_address,
	hours_of_service,	
	telephone_facsimile,
	telephone_voice_organisation,
	telephone_voice_individual,
	website,
	coc_number,
	address_id
) VALUES (
%L, %L, %L, %L, %L, %L, %L, %L, %L, %L,
%L, %L, %L, %L, %L, %L, %L, %L, %L
) RETURNING id',
	p_schema_name,
	p_id, 
	p_objectclass_id, 
	p_gmlid, 
	p_gmlid_codespace, 
	p_name, 
	p_name_codespace, 
	p_description, 
	p_individual_name,
	p_organisation_name,
	p_role,
	p_contact_instruction,
	p_email_address,
	p_hours_of_service,	
	p_telephone_facsimile,
	p_telephone_voice_organisation,
	p_telephone_voice_individual,
	p_website,
	p_coc_number,
	p_address_id
) INTO inserted_id;
RETURN inserted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_insert_related_party (id: %): %', p_id, SQLERRM;
END;
$$ LANGUAGE 'plpgsql';


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Hierchy level 3
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

----------------------------------------------------------------
-- Function uom5_INSERT_RELATED_PARTY_TO_MAINTENANCE_ACTIVITY
----------------------------------------------------------------
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_insert_party_to_maintenance (
	party_id					integer,
	maintenance_activity_id		integer,
--
	schema_name 				varchar DEFAULT 'citydb'::varchar
)
RETURNS void
AS $$
DECLARE
	p_party_id 					integer := party_id;
	p_maintenance_activity_id 	integer := maintenance_activity_id;
--	
	p_schema_name 				varchar := schema_name;
BEGIN
EXECUTE format('
INSERT INTO %I.uom5_related_party_to_maintenance_activity (
	party_id,
	maintenance_activity_id
) VALUES (
%L, %L
)',
	p_schema_name,
	p_party_id,
	p_maintenance_activity_id
) ;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_insert_party_to_maintenance (party_id: %, maintenance_activity_id: %): %', party_id, maintenance_activity_id, SQLERRM;
END;
$$ LANGUAGE 'plpgsql';


----------------------------------------------------------------
-- Function uom5_NETWORK_TO_NETWORK
----------------------------------------------------------------
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_insert_network_to_network (
	superordinate_network_id		integer,
	subordinate_network_id			integer,
--
	schema_name 					varchar DEFAULT 'citydb'::varchar
)
RETURNS void
AS $$
DECLARE
	p_superordinate_network_id 		integer  := superordinate_network_id;
	p_subordinate_network_id 		integer  := subordinate_network_id;
--	
	p_schema_name 					varchar  := schema_name;
BEGIN
EXECUTE format('
INSERT INTO %I.uom5_network_to_network (
	superordinate_network_id,
	subordinate_network_id
) VALUES (
%L, %L
)',
	p_schema_name,
	p_superordinate_network_id,
	p_subordinate_network_id
) ;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_insert_network_to_network (superordinate_network_id: %, subordinate_network_id: %): %', superordinate_network_id, subordinate_network_id, SQLERRM;
END;
$$ LANGUAGE 'plpgsql';


----------------------------------------------------------------
-- Function uom5_INSERT_RELATED_PARTY_TO_NETWORK
----------------------------------------------------------------
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_insert_party_to_network (
	party_id					integer,
	network_id					integer,
--
	schema_name 				varchar DEFAULT 'citydb'::varchar
)
RETURNS void
AS $$
DECLARE
	p_party_id 					integer  := party_id;
	p_network_id 				integer  := network_id;
--	
	p_schema_name 				varchar  := schema_name;
BEGIN
EXECUTE format('
INSERT INTO %I.uom5_related_party_to_network (
	party_id,
	network_id
) VALUES (
%L, %L
)',
	p_schema_name,
	p_party_id,
	p_network_id
) ;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_insert_party_to_network (party_id: %, network_id: %): %', party_id, network_id, SQLERRM;
END;
$$ LANGUAGE 'plpgsql';


----------------------------------------------------------------
-- Function uom5_INSERT_NETWORK_TO_NETWORK_FEATURE
----------------------------------------------------------------
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_insert_network_to_network_feature (
	network_id					integer,
	network_feature_id			integer,
--
	schema_name 				varchar DEFAULT 'citydb'::varchar
)
RETURNS void
AS $$
DECLARE
	p_network_id 				integer  := network_id;
	p_network_feature_id 		integer  := network_feature_id;
--	
	p_schema_name 				varchar  := schema_name;
BEGIN
EXECUTE format('
INSERT INTO %I.uom5_network_to_network_feature (
	network_id,
	network_feature_id
) VALUES (
%L, %L
)',
	p_schema_name,
	p_network_id,
	p_network_feature_id
) ;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_insert_network_to_network_feature (network_id: %, network_feature_id: %): %', network_id, network_feature_id, SQLERRM;
END;
$$ LANGUAGE 'plpgsql';


----------------------------------------------------------------
-- Function uom5_INSERT_RELATED_PARTY_TO_NETWORK_FEATURE
----------------------------------------------------------------
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_insert_party_to_network_feature (
	party_id					integer,
	network_feature_id			integer,
--
	schema_name 				varchar DEFAULT 'citydb'::varchar
)
RETURNS void
AS $$
DECLARE
	p_party_id 					integer  := party_id;
	p_network_feature_id 		integer  := network_feature_id;
--	
	p_schema_name 				varchar  := schema_name;
BEGIN
EXECUTE format('
INSERT INTO %I.uom5_related_party_to_network_feature (
	party_id,
	network_feature_id
) VALUES (
%L, %L
)',
	p_schema_name,
	p_party_id,
	p_network_feature_id
) ;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_insert_party_to_network_feature (party_id: %, network_feature_id: %): %', party_id, network_feature_id, SQLERRM;
END;
$$ LANGUAGE 'plpgsql';


----------------------------------------------------------------
-- Function uom5_INSERT_NETWORK_FEATURE_TO_MAINTENANCE_ACTIVITY
----------------------------------------------------------------
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_insert_feature_to_maintenance (
	network_feature_id			integer,
	maintenance_activity_id		integer,
--
	schema_name 				varchar DEFAULT 'citydb'::varchar
)
RETURNS void
AS $$
DECLARE
	p_network_feature_id 		integer  := network_feature_id;
	p_maintenance_activity_id 	integer  := maintenance_activity_id;
--	
	p_schema_name 				varchar  := schema_name;
BEGIN
EXECUTE format('
INSERT INTO %I.uom5_network_feature_to_maintenance_activity (
	network_feature_id,
	maintenance_activity_id
) VALUES (
%L, %L
)',
	p_schema_name,
	p_network_feature_id,
	p_maintenance_activity_id
) ;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_insert_feature_to_maintenance (network_feature_id: %, maintenance_activity_id: %): %', network_feature_id, maintenance_activity_id, SQLERRM;
END;
$$ LANGUAGE 'plpgsql';


----------------------------------------------------------------
-- Function uom5_INSERT_NETWORK_FEATURE_TO_MATERIAL
----------------------------------------------------------------
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_insert_network_feature_to_material (
	network_feature_id			integer,
	material_id					integer,
--
	schema_name 				varchar DEFAULT 'citydb'::varchar
)
RETURNS void
AS $$
DECLARE
	p_network_feature_id		integer  := network_feature_id;
	p_material_id 				integer  := material_id;
--	
	p_schema_name 				varchar  := schema_name;
BEGIN
EXECUTE format('
INSERT INTO %I.uom5_network_feat_to_material (
	network_feature_id,
	material_id
) VALUES (
%L, %L
)',
	p_schema_name,
	p_network_feature_id,
	p_material_id
) ;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_insert_network_feature_to_material (network_feature_id: %, material_id: %): %', network_feature_id, material_id, SQLERRM;
END;
$$ LANGUAGE 'plpgsql';


----------------------------------------------------------------
-- Function uom5_INSERT_NETWORK_GRAPH
----------------------------------------------------------------
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_insert_network_graph (
	objectclass_id  integer,
	id              integer DEFAULT NULL,
	gmlid           varchar DEFAULT NULL,
	gmlid_codespace varchar DEFAULT NULL,
	name            varchar DEFAULT NULL,
	name_codespace  varchar DEFAULT NULL,
	description     text 	DEFAULT NULL,
	network_id      integer DEFAULT NULL,
--	
	schema_name 	varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
	p_id              integer := id;
	p_objectclass_id  integer := objectclass_id;
	p_gmlid           varchar := gmlid;
	p_gmlid_codespace varchar := gmlid_codespace;
	p_name            varchar := name;
	p_name_codespace  varchar := name_codespace;
	p_description     text	  := description;
	p_network_id      integer := network_id;
--	
	p_schema_name 	varchar := schema_name;
	seq_name 		varchar;
	inserted_id 	integer;
BEGIN
-- IF the ID is not given, then generate a new one.
IF p_id IS NULL THEN
	seq_name=schema_name||'.uom5_network_graph_id_seq';
	p_id=nextval(seq_name::regclass);
END IF;
-- IF the GmlID is not given, then generate a new one.
IF p_gmlid IS NULL THEN
	p_gmlid='UUID_'||uuid_generate_v4();
END IF;

EXECUTE format('
INSERT INTO %I.uom5_network_graph (
	id,
	objectclass_id,
	gmlid,
	gmlid_codespace,
	name,
	name_codespace,
	description,
	network_id
) VALUES (
%L, %L, %L, %L, %L, %L, %L, %L
) RETURNING id',
	p_schema_name,
	p_id, 
	p_objectclass_id, 
	p_gmlid, 
	p_gmlid_codespace, 
	p_name, 
	p_name_codespace, 
	p_description, 
	p_network_id
) INTO inserted_id;
RETURN inserted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_insert_network_graph (id: %): %', p_id, SQLERRM;
END;
$$ LANGUAGE 'plpgsql';


----------------------------------------------------------------
-- Function uom5_INSERT_FEATURE_GRAPH
----------------------------------------------------------------
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_insert_feature_graph (
	objectclass_id   	integer,
	id   				integer DEFAULT NULL,
	gmlid 				varchar DEFAULT NULL,
	gmlid_codespace  	varchar DEFAULT NULL,
	name 				varchar DEFAULT NULL,
	name_codespace   	varchar DEFAULT NULL,
	description  		text 	DEFAULT NULL,
	ntw_feature_id   	integer DEFAULT NULL,
--
	schema_name 		varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
	p_id 				integer := id;
	p_objectclass_id 	integer := objectclass_id;
	p_gmlid  			varchar := gmlid;
	p_gmlid_codespace 	varchar := gmlid_codespace;
	p_name   			varchar := name;
	p_name_codespace 	varchar := name_codespace;
	p_description 		text	:= description;
	p_ntw_feature_id 	integer := ntw_feature_id;
--	
	p_schema_name 		varchar := schema_name;
	seq_name 			varchar;
	inserted_id 		integer;
BEGIN
-- IF the ID is not given, then generate a new one.
IF p_id IS NULL THEN
	seq_name=schema_name||'.uom5_feature_graph_id_seq';
	p_id=nextval(seq_name::regclass);
END IF;
-- IF the GmlID is not given, then generate a new one.
IF p_gmlid IS NULL THEN
	p_gmlid='UUID_'||uuid_generate_v4();
END IF;

EXECUTE format('
INSERT INTO %I.uom5_feature_graph (
	id,
	objectclass_id,
	gmlid,
	gmlid_codespace,
	name,
	name_codespace,
	description,
	ntw_feature_id
) VALUES (
%L, %L, %L, %L, %L, %L, %L, %L
) RETURNING id',
	p_schema_name,
	p_id, 
	p_objectclass_id, 
	p_gmlid, 
	p_gmlid_codespace, 
	p_name, 
	p_name_codespace, 
	p_description, 
	p_ntw_feature_id 
) INTO inserted_id;
RETURN inserted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_insert_feature_graph (id: %): %', p_id, SQLERRM;
END;
$$ LANGUAGE 'plpgsql';


----------------------------------------------------------------
-- Function uom5_INSERT_PERFORMANCE
----------------------------------------------------------------
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_insert_performance (
	objectclass_id						integer,
	id									integer 	DEFAULT NULL,
	gmlid								varchar 	DEFAULT NULL,
	gmlid_codespace						varchar 	DEFAULT NULL,
	name								varchar 	DEFAULT NULL,
	name_codespace						varchar 	DEFAULT NULL,
	description							text 		DEFAULT NULL,
	performance_type					varchar 	DEFAULT NULL,
	performance_requirement				varchar 	DEFAULT NULL,
	performance_score					numeric 	DEFAULT NULL,
	is_sufficient						numeric 	DEFAULT NULL,
	date_of_performance_measuring		date		DEFAULT NULL,
	extra_information					varchar 	DEFAULT NULL,
	network_id							integer 	DEFAULT NULL,
	feature_id							integer 	DEFAULT NULL,
--
	schema_name 						varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
	p_id   								integer 	:= id  ;
	p_objectclass_id   					integer 	:= objectclass_id  ;
	p_gmlid 							varchar 	:= gmlid   ;
	p_gmlid_codespace  					varchar 	:= gmlid_codespace ;
	p_name 								varchar 	:= name;
	p_name_codespace   					varchar 	:= name_codespace  ;
	p_description  						text		:= description ;
	p_performance_type					varchar		:= performance_type ;
	p_performance_requirement			varchar		:= performance_requirement ;
	p_performance_score					numeric		:= performance_score ;
	p_is_sufficient						numeric		:= is_sufficient ;
	p_date_of_performance_measuring		date		:= date_of_performance_measuring ;
	p_extra_information					varchar		:= extra_information ;
	p_network_id						integer		:= network_id ;
	p_feature_id						integer		:= feature_id ;
--	
	p_schema_name 						varchar 	:= schema_name;
	seq_name 							varchar;
	inserted_id 						integer;
	
BEGIN
-- IF the ID is not given, then generate a new one.
IF p_id IS NULL THEN
  seq_name=schema_name||'.uom5_performance_id_seq';
  p_id=nextval(seq_name::regclass);
END IF;
-- IF the GmlID is not given, then generate a new one.
IF p_gmlid IS NULL THEN
  p_gmlid='UUID_'||uuid_generate_v4();
END IF;

EXECUTE format('
INSERT INTO %I.uom5_performance (
	id,
	objectclass_id,
	gmlid,
	gmlid_codespace,
	name,
	name_codespace,
	description,
	performance_type,
	performance_requirement,
	performance_score,
	is_sufficient,
	date_of_performance_measuring,
	extra_information,
	network_id,
	feature_id
) VALUES (
%L, %L, %L, %L, %L, %L, %L, %L, %L, %L,
%L, %L, %L, %L, %L
) RETURNING id',
	p_schema_name,
	p_id, 
	p_objectclass_id, 
	p_gmlid, 
	p_gmlid_codespace, 
	p_name, 
	p_name_codespace, 
	p_description, 
	p_performance_type,
	p_performance_requirement,
	p_performance_score,
	p_is_sufficient,
	p_date_of_performance_measuring,
	p_extra_information,
	p_network_id,
	p_feature_id
) INTO inserted_id;
RETURN inserted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_insert_performance (id: %): %', p_id, SQLERRM;
END;
$$ LANGUAGE 'plpgsql';


----------------------------------------------------------------
-- Function uom5_INSERT_COST
----------------------------------------------------------------
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_insert_cost (
	id									integer,
	cost_type							varchar 	DEFAULT NULL,
	currency							varchar 	DEFAULT NULL,
	total_costs							numeric 	DEFAULT NULL,
	costs_per_unit						numeric 	DEFAULT NULL,
	unit_of_measurement					varchar 	DEFAULT NULL,
	network_feature_id					integer 	DEFAULT NULL,
	maintenance_activity_id				integer 	DEFAULT NULL,
--
	schema_name 						varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
	p_id   								integer 	:= id  ;
	p_cost_type							varchar 	:= cost_type ;
	p_currency							varchar 	:= currency ;
	p_total_costs						numeric 	:= total_costs ;
	p_costs_per_unit					numeric 	:= costs_per_unit ;
	p_unit_of_measurement				varchar 	:= unit_of_measurement ;
	p_network_feature_id				integer 	:= network_feature_id ;
	p_maintenance_activity_id			integer 	:= maintenance_activity_id ;
--	
	p_schema_name 						varchar 	:= schema_name;
	seq_name 							varchar;
	inserted_id 						integer;
	
BEGIN
-- IF the ID is not given, then generate a new one.
IF p_id IS NULL THEN
  seq_name=schema_name||'.uom5_performance_id_seq';
  p_id=nextval(seq_name::regclass);
END IF;

EXECUTE format('
INSERT INTO %I.uom5_cost (
	id,
	cost_type,
	currency,
	total_costs,
	costs_per_unit,
	unit_of_measurement,
	network_feature_id,
	maintenance_activity_id
) VALUES (
%L, %L, %L, %L, %L, %L, %L, %L
) RETURNING id',
	p_schema_name,
	p_id, 
	p_cost_type,
	p_currency,
	p_total_costs,
	p_costs_per_unit,
	p_unit_of_measurement,
	p_network_feature_id,
	p_maintenance_activity_id
) INTO inserted_id;
RETURN inserted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_insert_cost (id: %): %', p_id, SQLERRM;
END;
$$ LANGUAGE 'plpgsql';


----------------------------------------------------------------
-- Function uom5_INSERT_IDENTIFICATION
----------------------------------------------------------------
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_insert_identification (
	id							integer,
	feature_id					integer 	DEFAULT NULL,
	identifier					varchar 	DEFAULT NULL,
	identifier_type				varchar 	DEFAULT NULL,
	colour						varchar 	DEFAULT NULL,
	address_id					integer 	DEFAULT NULL,
	is_label_visible			numeric 	DEFAULT NULL,
	label_location				varchar 	DEFAULT NULL,
--
	schema_name 				varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
	p_id   						integer 	:= id  ;
	p_feature_id				integer 	:= feature_id ;
	p_identifier				varchar 	:= identifier ;
	p_identifier_type			varchar 	:= identifier_type ;
	p_colour					varchar 	:= colour ;
	p_address_id				integer 	:= address_id ;
	p_is_label_visible			numeric 	:= is_label_visible ;
	p_label_location			varchar 	:= label_location ;
--	
	p_schema_name 				varchar 	:= schema_name;
	seq_name 					varchar;
	inserted_id 				integer;
	
BEGIN
-- IF the ID is not given, then generate a new one.
IF p_id IS NULL THEN
  seq_name=schema_name||'.uom5_identification_id_seq';
  p_id=nextval(seq_name::regclass);
END IF;

EXECUTE format('
INSERT INTO %I.uom5_identification (
	id,
	feature_id,
	identifier,
	identifier_type,
	colour,
	address_id,
	is_label_visible,
	label_location
) VALUES (
%L, %L, %L, %L, %L, %L, %L, %L
) RETURNING id',
	p_schema_name,
	p_id, 
	p_feature_id,
	p_identifier,
	p_identifier_type,
	p_colour,
	p_address_id,
	p_is_label_visible,
	p_label_location
) INTO inserted_id;
RETURN inserted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_insert_identification (id: %): %', p_id, SQLERRM;
END;
$$ LANGUAGE 'plpgsql';


----------------------------------------------------------------
-- Function uom5_INSERT_DIMENSIONS
----------------------------------------------------------------
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_insert_dimensions (
	id						integer,
	feature_id				integer 	DEFAULT NULL,
	shape					varchar 	DEFAULT NULL,
	wall_thickness			numeric 	DEFAULT NULL,
	wall_thinkness_unit		varchar 	DEFAULT NULL,
	exterior_width			numeric 	DEFAULT NULL,
	exterior_width_unit		varchar 	DEFAULT NULL,
	exterior_height			numeric 	DEFAULT NULL,
	exterior_height_unit	varchar 	DEFAULT NULL,
	exterior_diameter		numeric 	DEFAULT NULL,
	exterior_diameter_unit	varchar 	DEFAULT NULL,
	exterior_length			numeric 	DEFAULT NULL,
	exterior_length_unit	varchar 	DEFAULT NULL,
	interior_width			numeric 	DEFAULT NULL,
	interior_width_unit		varchar 	DEFAULT NULL,
	interior_height			numeric 	DEFAULT NULL,
	interior_height_unit	varchar 	DEFAULT NULL,
	interior_diameter		numeric 	DEFAULT NULL,
	interior_diameter_unit	varchar 	DEFAULT NULL,
	interior_length			numeric 	DEFAULT NULL,
	interior_length_unit	varchar 	DEFAULT NULL,
--
	schema_name 			varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
	p_id   						integer 	:= id  ;
	p_feature_id				integer 	:= feature_id ;
	p_shape						varchar 	:= shape ;
	p_wall_thickness			numeric 	:= wall_thickness ;
	p_wall_thinkness_unit		varchar 	:= wall_thinkness_unit ;
	p_exterior_width			numeric 	:= exterior_width ;
	p_exterior_width_unit		varchar 	:= exterior_width_unit ;
	p_exterior_height			numeric 	:= exterior_height ;
	p_exterior_height_unit		varchar 	:= exterior_height_unit ;
	p_exterior_diameter			numeric 	:= exterior_diameter ;
	p_exterior_diameter_unit	varchar 	:= exterior_diameter_unit ;
	p_exterior_length			numeric 	:= exterior_length ;
	p_exterior_length_unit		varchar 	:= exterior_length_unit ;
	p_interior_width			numeric 	:= interior_width ;
	p_interior_width_unit		varchar 	:= interior_width_unit ;
	p_interior_height			numeric 	:= interior_height ;
	p_interior_height_unit		varchar 	:= interior_height_unit ;
	p_interior_diameter			numeric 	:= interior_diameter ;
	p_interior_diameter_unit	varchar 	:= interior_diameter_unit ;
	p_interior_length			numeric 	:= interior_length ;
	p_interior_length_unit		varchar 	:= interior_length_unit ;
--	
	p_schema_name 				varchar 	:= schema_name;
	seq_name 					varchar;
	inserted_id 				integer;
	
BEGIN
-- IF the ID is not given, then generate a new one.
IF p_id IS NULL THEN
  seq_name=schema_name||'.uom5_dimensions_id_seq';
  p_id=nextval(seq_name::regclass);
END IF;

EXECUTE format('
INSERT INTO %I.uom5_dimensions (
	id,
	feature_id,
	shape,
	wall_thickness,
	wall_thinkness_unit,
	exterior_width,
	exterior_width_unit,
	exterior_height,
	exterior_height_unit,
	exterior_diameter,
	exterior_diameter_unit,
	exterior_length,
	exterior_length_unit,
	interior_width,
	interior_width_unit,
	interior_height,
	interior_height_unit,
	interior_diameter,
	interior_diameter_unit,
	interior_length,
	interior_length_unit
) VALUES (
%L, %L, %L, %L, %L, %L, %L, %L, %L, %L,
%L, %L, %L, %L, %L, %L, %L, %L, %L, %L,
%L
) RETURNING id',
	p_schema_name,
	p_id, 
	p_feature_id,
	p_shape,
	p_wall_thickness,
	p_wall_thinkness_unit,
	p_exterior_width,
	p_exterior_width_unit,
	p_exterior_height,
	p_exterior_height_unit,
	p_exterior_diameter,
	p_exterior_diameter_unit,
	p_exterior_length,
	p_exterior_length_unit,
	p_interior_width,
	p_interior_width_unit,
	p_interior_height,
	p_interior_height_unit,
	p_interior_diameter,
	p_interior_diameter_unit,
	p_interior_length,
	p_interior_length_unit
) INTO inserted_id;
RETURN inserted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_insert_dimensions (id: %): %', p_id, SQLERRM;
END;
$$ LANGUAGE 'plpgsql';


----------------------------------------------------------------
-- Function uom5_INSERT_MEASURED_DEPTH
----------------------------------------------------------------
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_insert_measured_depth (
	id								integer,
	depth_level_measurement			numeric 	DEFAULT NULL,
	depth_level_measurement_unit	varchar 	DEFAULT NULL,
	depth_reference_level			varchar 	DEFAULT NULL,
	depth_point_of_measurement		varchar 	DEFAULT NULL,
	depth_quality					varchar 	DEFAULT NULL,
	depth_accuracy					varchar 	DEFAULT NULL,
	location_of_measurement			geometry 	DEFAULT NULL,
	date_of_depth_measurement		date 		DEFAULT NULL,
	ntw_feature_id					integer 	DEFAULT NULL,
--
	schema_name 					varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
	p_id   							integer 	:= id  ;
	p_depth_level_measurement		numeric 	:= depth_level_measurement ;
	p_depth_level_measurement_unit	varchar 	:= depth_level_measurement_unit ;
	p_depth_reference_level			varchar 	:= depth_reference_level ;
	p_depth_point_of_measurement	varchar 	:= depth_point_of_measurement ;
	p_depth_quality					varchar 	:= depth_quality ;
	p_depth_accuracy				varchar 	:= depth_accuracy ;
	p_location_of_measurement		geometry 	:= location_of_measurement ;
	p_date_of_depth_measurement		date 		:= date_of_depth_measurement ;
	p_ntw_feature_id				integer 	:= ntw_feature_id ;
--	
	p_schema_name 					varchar 	:= schema_name;
	seq_name 						varchar;
	inserted_id 					integer;
	
BEGIN
-- IF the ID is not given, then generate a new one.
IF p_id IS NULL THEN
  seq_name=schema_name||'.uom5_measured_depth_id_seq';
  p_id=nextval(seq_name::regclass);
END IF;

EXECUTE format('
INSERT INTO %I.uom5_measured_depth (
	id,
	depth_level_measurement,
	depth_level_measurement_unit,
	depth_reference_level,
	depth_point_of_measurement,
	depth_quality,
	depth_accuracy,
	location_of_measurement,
	date_of_depth_measurement,
	ntw_feature_id
) VALUES (
%L, %L, %L, %L, %L, %L, %L, %L, %L, %L
) RETURNING id',
	p_schema_name,
	p_id, 
	p_depth_level_measurement,
	p_depth_level_measurement_unit,
	p_depth_reference_level,
	p_depth_point_of_measurement,
	p_depth_quality,
	p_depth_accuracy,
	p_location_of_measurement,
	p_date_of_depth_measurement,
	p_ntw_feature_id
) INTO inserted_id;
RETURN inserted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_insert_measured_depth (id: %): %', p_id, SQLERRM;
END;
$$ LANGUAGE 'plpgsql';


----------------------------------------------------------------
-- Function uom5_INSERT_SOIL_AND_GROUNDWATER
----------------------------------------------------------------
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_insert_soil_and_groundwater (
	id								integer,
	type							varchar 	DEFAULT NULL,
	reactivity						numeric 	DEFAULT NULL,
	reactivity_unit					varchar 	DEFAULT NULL,
	permeability					numeric 	DEFAULT NULL,
	permeability_unit				varchar 	DEFAULT NULL,
	strength						numeric 	DEFAULT NULL,
	strength_unit					varchar 	DEFAULT NULL,
	density							numeric 	DEFAULT NULL,
	density_unit					varchar 	DEFAULT NULL,
	moisture_content				numeric 	DEFAULT NULL,
	groundwater_real_time			numeric 	DEFAULT NULL,
	groundwater_level				numeric 	DEFAULT NULL,
	groundwater_level_unit			varchar 	DEFAULT NULL,
	groundwater_reference_level		varchar 	DEFAULT NULL,
	ntw_feature_id					integer 	DEFAULT NULL,
--
	schema_name 					varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
	p_id   							integer 	:= id  ;
	p_type							varchar 	:= type ;
	p_reactivity					numeric 	:= reactivity ;
	p_reactivity_unit				varchar 	:= reactivity_unit ;
	p_permeability					numeric 	:= permeability ;
	p_permeability_unit				varchar 	:= permeability_unit ;
	p_strength						numeric 	:= strength ;
	p_strength_unit					varchar 	:= strength_unit ;
	p_density						numeric 	:= density ;
	p_density_unit					varchar 	:= density_unit ;
	p_moisture_content				numeric 	:= moisture_content ;
	p_groundwater_real_time			numeric 	:= groundwater_real_time ;
	p_groundwater_level				numeric 	:= groundwater_level ;
	p_groundwater_level_unit		varchar 	:= groundwater_level_unit ;
	p_groundwater_reference_level	varchar 	:= groundwater_reference_level ;
	p_ntw_feature_id				integer 	:= ntw_feature_id ;
--	
	p_schema_name 					varchar 	:= schema_name;
	seq_name 						varchar;
	inserted_id 					integer;
	
BEGIN
-- IF the ID is not given, then generate a new one.
IF p_id IS NULL THEN
  seq_name=schema_name||'.uom5_soil_and_groundwater_id_seq';
  p_id=nextval(seq_name::regclass);
END IF;

EXECUTE format('
INSERT INTO %I.uom5_soil_and_groundwater (
	id,
	type,
	reactivity,
	reactivity_unit,
	permeability,
	permeability_unit,
	strength,
	strength_unit,
	density,
	density_unit,
	moisture_content,
	groundwater_real_time,
	groundwater_level,
	groundwater_level_unit,
	groundwater_reference_level,
	ntw_feature_id
) VALUES (
%L, %L, %L, %L, %L, %L, %L, %L, %L, %L,
%L, %L, %L, %L, %L, %L
) RETURNING id',
	p_schema_name,
	p_id, 
	p_type,
	p_reactivity,
	p_reactivity_unit,
	p_permeability,
	p_permeability_unit,
	p_strength,
	p_strength_unit,
	p_density,
	p_density_unit,
	p_moisture_content,
	p_groundwater_real_time,
	p_groundwater_level,
	p_groundwater_level_unit,
	p_groundwater_reference_level,
	p_ntw_feature_id
) INTO inserted_id;
RETURN inserted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_insert_soil_and_groundwater (id: %): %', p_id, SQLERRM;
END;
$$ LANGUAGE 'plpgsql';


----------------------------------------------------------------
-- Function uom5_INSERT_PROTECTIVE_ELEMENT
----------------------------------------------------------------
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_insert_protective_element (
	objectclass_id		integer,
	id					integer,	
--
	schema_name 		varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
	p_objectclass_id   	integer 	:= objectclass_id  ;
	p_id				integer 	:= id ;
--	
	p_schema_name 		varchar 	:= schema_name;
	inserted_id 		integer;

BEGIN
EXECUTE format('
INSERT INTO %I.uom5_protective_element (
	objectclass_id,
	id
) VALUES (
%L, %L
) RETURNING id',
	p_schema_name,
	p_objectclass_id, 
	p_id
	
) INTO inserted_id;
RETURN inserted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_insert_protective_element (id: %): %', p_id, SQLERRM;
END;
$$ LANGUAGE 'plpgsql';


----------------------------------------------------------------
-- Function uom5_INSERT_PIPE
----------------------------------------------------------------
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_insert_pipe (
	objectclass_id			integer,
	id						integer,
	class					varchar 	DEFAULT NULL,
	function_of_line		varchar 	DEFAULT NULL,
	sewer_pipe_type				varchar 	DEFAULT NULL,
	is_gravity				numeric 	DEFAULT NULL,
	slope					numeric 	DEFAULT NULL,
	slope_unit				varchar 	DEFAULT NULL,
	is_directional_drilling	numeric 	DEFAULT NULL,
	has_cathodic_protection	numeric 	DEFAULT NULL,
	pressure_grade			numeric 	DEFAULT NULL,
	pressure_grade_unit		varchar 	DEFAULT NULL,
	max_capacity			numeric 	DEFAULT NULL,
	max_capacity_unit		varchar 	DEFAULT NULL,
--
	schema_name 			varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
	p_objectclass_id   			integer 	:= objectclass_id  ;
	p_id						integer 	:= id ;
	p_class						varchar 	:= class ;
	p_function_of_line			varchar 	:= function_of_line ;
	p_sewer_pipe_type					varchar 	:= sewer_pipe_type ;
	p_is_gravity				numeric 	:= is_gravity ;
	p_slope						numeric 	:= slope ;
	p_slope_unit				varchar 	:= slope_unit ;
	p_is_directional_drilling	numeric 	:= is_directional_drilling ;
	p_has_cathodic_protection	numeric 	:= has_cathodic_protection ;
	p_pressure_grade			numeric 	:= pressure_grade ;
	p_pressure_grade_unit		varchar 	:= pressure_grade_unit ;
	p_max_capacity				numeric 	:= max_capacity ;
	p_max_capacity_unit			varchar 	:= max_capacity_unit ;
--	
	p_schema_name 			varchar 	:= schema_name ;
	inserted_id 			integer ;
	
BEGIN
EXECUTE format('
INSERT INTO %I.uom5_pipe (
	objectclass_id,
	id,
	class,
	function_of_line,
	sewer_pipe_type,
	is_gravity,
	slope,
	slope_unit,
	is_directional_drilling,
	has_cathodic_protection,
	pressure_grade,
	pressure_grade_unit,
	max_capacity,
	max_capacity_unit
) VALUES (
%L, %L, %L, %L, %L, %L, %L, %L, %L, %L,
%L, %L, %L, %L
) RETURNING id',
	p_schema_name,
	p_objectclass_id, 
	p_id,
	p_class,
	p_function_of_line,
	p_sewer_pipe_type,
	p_is_gravity,
	p_slope,
	p_slope_unit,
	p_is_directional_drilling,
	p_has_cathodic_protection,
	p_pressure_grade,
	p_pressure_grade_unit,
	p_max_capacity,
	p_max_capacity_unit	
) INTO inserted_id;
RETURN inserted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_insert_pipe (id: %): %', p_id, SQLERRM;
END;
$$ LANGUAGE 'plpgsql';


----------------------------------------------------------------
-- Function uom5_INSERT_CABLE
----------------------------------------------------------------
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_insert_cable (
	objectclass_id					integer,
	id								integer,
	class							varchar 	DEFAULT NULL,
	function_of_line				varchar 	DEFAULT NULL,
	cable_type						varchar 	DEFAULT NULL,
	number_of_conductors			integer 	DEFAULT NULL,
	conductor_cross_section			numeric 	DEFAULT NULL,
	conductor_cross_section_unit	varchar 	DEFAULT NULL,
	electr_voltage_grade			numeric 	DEFAULT NULL,
	electr_voltage_grade_unit		varchar 	DEFAULT NULL,
	electr_ampacity					numeric 	DEFAULT NULL,
	electr_ampacity_unit			varchar 	DEFAULT NULL,
	telecom_bandwith_range_from		numeric 	DEFAULT NULL,
	telecom_bandwith_range_to		numeric 	DEFAULT NULL,
	telecom_bandwith_unit			varchar 	DEFAULT NULL,
	telecom_impedance				numeric 	DEFAULT NULL,
	telecom_impedance_unit			varchar 	DEFAULT NULL,
	telecom_attenuation				numeric 	DEFAULT NULL,
	telecom_attenuation_unit		varchar 	DEFAULT NULL,
--
	schema_name 					varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
	p_objectclass_id   				integer 	:= objectclass_id  ;
	p_id							integer 	:= id ;
	p_class							varchar 	:= class ;
	p_function_of_line				varchar 	:= function_of_line ;
	p_cable_type					varchar 	:= cable_type ;
	p_number_of_conductors			integer 	:= number_of_conductors ;
	p_conductor_cross_section		numeric 	:= conductor_cross_section ;
	p_conductor_cross_section_unit	varchar 	:= conductor_cross_section_unit ;
	p_electr_voltage_grade			numeric 	:= electr_voltage_grade ;
	p_electr_voltage_grade_unit		varchar 	:= electr_voltage_grade_unit ;
	p_electr_ampacity				numeric 	:= electr_ampacity ;
	p_electr_ampacity_unit			varchar 	:= electr_ampacity_unit ;
	p_telecom_bandwith_range_from	numeric 	:= telecom_bandwith_range_from ;
	p_telecom_bandwith_range_to		numeric 	:= telecom_bandwith_range_to ;
	p_telecom_bandwith_unit			varchar 	:= telecom_bandwith_unit ;
	p_telecom_impedance				numeric 	:= telecom_impedance ;
	p_telecom_impedance_unit		varchar 	:= telecom_impedance_unit ;
	p_telecom_attenuation			numeric 	:= telecom_attenuation ;
	p_telecom_attenuation_unit		varchar 	:= telecom_attenuation_unit ;
--	
	p_schema_name 					varchar 	:= schema_name;
	inserted_id 					integer;
	
BEGIN

EXECUTE format('
INSERT INTO %I.uom5_cable (
	objectclass_id,
	id,
	class,
	function_of_line,
	cable_type,
	number_of_conductors,
	conductor_cross_section,
	conductor_cross_section_unit,
	electr_voltage_grade,
	electr_voltage_grade_unit,
	electr_ampacity,
	electr_ampacity_unit,
	telecom_bandwith_range_from,
	telecom_bandwith_range_to,
	telecom_bandwith_unit,
	telecom_impedance,
	telecom_impedance_unit,
	telecom_attenuation,
	telecom_attenuation_unit
) VALUES (
%L, %L, %L, %L, %L, %L, %L, %L, %L, %L,
%L, %L, %L, %L, %L, %L, %L, %L, %L
) RETURNING id',
	p_schema_name,
	p_objectclass_id, 
	p_id,
	p_class,
	p_function_of_line,
	p_cable_type,
	p_number_of_conductors,
	p_conductor_cross_section,
	p_conductor_cross_section_unit,
	p_electr_voltage_grade,
	p_electr_voltage_grade_unit,
	p_electr_ampacity,
	p_electr_ampacity_unit,
	p_telecom_bandwith_range_from,
	p_telecom_bandwith_range_to,
	p_telecom_bandwith_unit,
	p_telecom_impedance,
	p_telecom_impedance_unit,
	p_telecom_attenuation,
	p_telecom_attenuation_unit
) INTO inserted_id;
RETURN inserted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_insert_cable (id: %): %', p_id, SQLERRM;
END;
$$ LANGUAGE 'plpgsql';


----------------------------------------------------------------
-- Function uom5_INSERT_FUNCTIONAL_COMPONENT
----------------------------------------------------------------
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_insert_functional_component (
	objectclass_id					integer,
	id								integer,
	func_comp_parent_id				integer 	DEFAULT NULL,
	func_comp_root_id				integer 	DEFAULT NULL,
	class							varchar 	DEFAULT NULL,
	is_accesible					numeric 	DEFAULT NULL,
	is_active						numeric 	DEFAULT NULL,
	neutral_earth_connection		numeric 	DEFAULT NULL,
	connection_mode					varchar 	DEFAULT NULL,
	preferred_mode					varchar 	DEFAULT NULL,
	actual_mode						varchar 	DEFAULT NULL,
	rotational_direction			varchar 	DEFAULT NULL,
	number_of_rotations				integer 	DEFAULT NULL,
--
	schema_name 					varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
	p_objectclass_id   				integer 	:= objectclass_id  ;
	p_id							integer 	:= id ;
	p_func_comp_parent_id			integer 	:= func_comp_parent_id ;
	p_func_comp_root_id				integer 	:= func_comp_root_id ;
	p_class							varchar 	:= class ;
	p_is_accesible					numeric 	:= is_accesible ;
	p_is_active						numeric 	:= is_active ;
	p_neutral_earth_connection		numeric 	:= neutral_earth_connection ;
	p_connection_mode				varchar 	:= connection_mode ;
	p_preferred_mode				varchar 	:= preferred_mode ;
	p_actual_mode					varchar 	:= actual_mode ;
	p_rotational_direction			varchar 	:= rotational_direction ;
	p_number_of_rotations			integer 	:= number_of_rotations ;
--	
	p_schema_name 					varchar 	:= schema_name;
	inserted_id 					integer;
	
BEGIN


EXECUTE format('
INSERT INTO %I.uom5_functional_component (
	objectclass_id,
	id,
	func_comp_parent_id,
	func_comp_root_id,
	class,
	is_accesible,
	is_active,
	neutral_earth_connection,
	connection_mode,
	preferred_mode,
	actual_mode,
	rotational_direction,
	number_of_rotations
) VALUES (
%L, %L, %L, %L, %L, %L, %L, %L, %L, %L,
%L, %L, %L
) RETURNING id',
	p_schema_name,
	p_objectclass_id, 
	p_id,
	p_func_comp_parent_id,
	p_func_comp_root_id,
	p_class,
	p_is_active,
	p_is_accesible,
	p_neutral_earth_connection,
	p_connection_mode,
	p_preferred_mode,
	p_actual_mode,
	p_rotational_direction,
	p_number_of_rotations
) INTO inserted_id;
RETURN inserted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_insert_functional_component (id: %): %', p_id, SQLERRM;
END;
$$ LANGUAGE 'plpgsql';


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Hierchy level 4
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

----------------------------------------------------------------
-- Function uom5_INSERT_STORAGE
----------------------------------------------------------------
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_insert_storage (
	id						integer DEFAULT NULL,
	type					varchar DEFAULT NULL,
	max_capacity			numeric DEFAULT NULL,
	max_capacity_unit		varchar DEFAULT NULL,
	fill_level				numeric DEFAULT NULL,
	inflow_rate				numeric DEFAULT NULL,
	inflow_rate_unit		varchar DEFAULT NULL,
	outflow_rate			numeric DEFAULT NULL,
	outflow_rate_unit		varchar DEFAULT NULL,
	commodity_supply_id		integer DEFAULT NULL,
	funct_component_id		integer DEFAULT NULL, 
--	
	schema_name varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
	p_id					integer := id;
	p_type					varchar := type;
	p_max_capacity			numeric := max_capacity;
	p_max_capacity_unit		varchar := max_capacity_unit;
	p_fill_level			numeric := fill_level;
	p_inflow_rate			numeric := inflow_rate;
	p_inflow_rate_unit		varchar := inflow_rate_unit;
	p_outflow_rate			numeric := outflow_rate;
	p_outflow_rate_unit		varchar := outflow_rate_unit;
	p_commodity_supply_id	integer := commodity_supply_id;
	p_funct_component_id	integer := funct_component_id;
--
	p_schema_name varchar := schema_name;
	seq_name varchar;
	inserted_id integer;
BEGIN
-- IF the ID is not given, then generate a new one.
IF p_id IS NULL THEN
	seq_name=schema_name||'.uom5_storage_id_seq';
	p_id=nextval(seq_name::regclass);
END IF;

EXECUTE format('
INSERT INTO %I.uom5_storage (
	id,
	type,
	max_capacity,
	max_capacity_unit,
	fill_level,
	inflow_rate,
	inflow_rate_unit,
	outflow_rate,
	outflow_rate_unit,
	commodity_supply_id,
	funct_component_id
) VALUES (
%L, %L, %L, %L, %L, %L, %L, %L, %L, %L, 
%L
) RETURNING id',
	p_schema_name, 
	p_id, 
	p_type,
	p_max_capacity, 
	p_max_capacity_unit, 
	p_fill_level, 
	p_inflow_rate, 
	p_inflow_rate_unit, 
	p_outflow_rate, 
	p_outflow_rate_unit, 
	p_commodity_supply_id, 
	p_funct_component_id
) INTO inserted_id;
RETURN inserted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_insert_storage (id: %): %', p_id, SQLERRM;
END;
$$ LANGUAGE 'plpgsql';


----------------------------------------------------------------
-- Function uom5_INSERT_FEATURE_GRAPH_TO_NETWORK_GRAPH
----------------------------------------------------------------
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_insert_feature_graph_to_network_graph (
	feature_graph_id		integer,
	network_graph_id		integer,
--
	schema_name 			varchar DEFAULT 'citydb'::varchar
)
RETURNS void
AS $$
DECLARE
	p_feature_graph_id 		integer := feature_graph_id;
	p_network_graph_id 		integer := network_graph_id;
--	
	p_schema_name 			varchar := schema_name;
BEGIN
EXECUTE format('
INSERT INTO %I.uom5_feature_graph_to_network_graph (
	feature_graph_id,
	network_graph_id
) VALUES (
%L, %L
)',
	p_schema_name,
	p_feature_graph_id,
	p_network_graph_id
) ;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_insert_feature_graph_to_network_graph (feature_graph_id: %, network_graph_id: %): %', feature_graph_id, network_graph_id, SQLERRM;
END;
$$ LANGUAGE 'plpgsql';


----------------------------------------------------------------
-- Function uom5_INSERT_NODE
----------------------------------------------------------------
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_insert_node (
	objectclass_id   		integer,
	id   					integer DEFAULT NULL,
	gmlid 					varchar DEFAULT NULL,
	gmlid_codespace  		varchar DEFAULT NULL,
	name 					varchar DEFAULT NULL,
	name_codespace   		varchar DEFAULT NULL,
	description  			text 	DEFAULT NULL,
	type 					varchar DEFAULT NULL,
	connection_signature 	varchar DEFAULT NULL,
	link_control 			varchar DEFAULT NULL,
	feat_graph_id 			integer DEFAULT NULL,
	point_geom   			geometry DEFAULT NULL,
--  
  schema_name 				varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
	p_id                   integer  := id;
	p_objectclass_id       integer  := objectclass_id;
	p_gmlid                varchar  := gmlid;
	p_gmlid_codespace      varchar  := gmlid_codespace;
	p_name                 varchar  := name;
	p_name_codespace       varchar  := name_codespace;
	p_description          text     := description;
	p_type                 varchar  := type;
	p_connection_signature varchar  := connection_signature;
	p_link_control         varchar  := link_control;
	p_feat_graph_id        integer  := feat_graph_id;
	p_point_geom           geometry := point_geom;
--	
	p_schema_name varchar := schema_name;
	seq_name varchar;
	inserted_id integer;
BEGIN
-- IF the ID is not given, then generate a new one.
IF p_id IS NULL THEN
	seq_name=schema_name||'.uom5_node_id_seq';
	p_id=nextval(seq_name::regclass);
END IF;
-- IF the GmlID is not given, then generate a new one.
IF p_gmlid IS NULL THEN
	p_gmlid='UUID_'||uuid_generate_v4();
END IF;

EXECUTE format('
INSERT INTO %I.uom5_node (
	id,
	objectclass_id,
	gmlid,
	gmlid_codespace,
	name,
	name_codespace,
	description,
	type,
	connection_signature,
	link_control,
	feat_graph_id,
	point_geom
) VALUES (
%L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L
) RETURNING id',
	p_schema_name,
	p_id, 
	p_objectclass_id, 
	p_gmlid, 
	p_gmlid_codespace, 
	p_name, 
	p_name_codespace, 
	p_description, 
	p_type, 
	p_connection_signature, 
	p_link_control, 
	p_feat_graph_id, 
	p_point_geom
) INTO inserted_id;
RETURN inserted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_insert_node (id: %): %', p_id, SQLERRM;
END;
$$ LANGUAGE 'plpgsql';


----------------------------------------------------------------
-- Function uom5_INSERT_COMMODITY_CLASSIFIER
----------------------------------------------------------------
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_insert_commodity_classifier (
	objectclass_id				integer,
	id							integer DEFAULT NULL,
	gmlid						varchar DEFAULT NULL,
	gmlid_codespace				varchar DEFAULT NULL,
	name						varchar DEFAULT NULL,
	name_codespace				varchar DEFAULT NULL,
	description					text 	DEFAULT NULL,
	mol_formula					varchar DEFAULT NULL,
	mol_weight					numeric DEFAULT NULL,
	mol_weight_unit				numeric DEFAULT NULL,
	physical_form				varchar DEFAULT NULL,
	signal_word					varchar DEFAULT NULL,
	is_chemical_complex			numeric DEFAULT NULL,
	haz_class 					varchar DEFAULT NULL,
	haz_class_category_code		varchar DEFAULT NULL,
	haz_class_statement_code	varchar DEFAULT NULL,
	haz_class_pictogram_code	varchar DEFAULT NULL,
	haz_class_pictogram_uri		varchar DEFAULT NULL,
	ec_number 					varchar DEFAULT NULL,
	cas_number   				varchar DEFAULT NULL,
	iuclid_chem_datasheet 		varchar DEFAULT NULL,
	commodity_id 				integer DEFAULT NULL,
--
	schema_name 				varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
	p_id						integer := id;
	p_objectclass_id			integer := objectclass_id;
	p_gmlid						varchar := gmlid;
	p_gmlid_codespace			varchar := gmlid_codespace;
	p_name						varchar := name;
	p_name_codespace			varchar := name_codespace;
	p_description  				text:= description;
	p_mol_formula				varchar := mol_formula;
	p_mol_weight				numeric := mol_weight;
	p_mol_weight_unit			numeric := mol_weight_unit;
	p_physical_form				varchar := physical_form;
	p_signal_word				varchar := signal_word;
	p_is_chemical_complex		numeric := is_chemical_complex;
	p_haz_class					varchar := haz_class;
	p_haz_class_category_code  	varchar := haz_class_category_code;
	p_haz_class_statement_code 	varchar := haz_class_statement_code;
	p_haz_class_pictogram_code 	varchar := haz_class_pictogram_code;
	p_haz_class_pictogram_uri  	varchar := haz_class_pictogram_uri;
	p_ec_number 				varchar := ec_number;
	p_cas_number   				varchar := cas_number;
	p_iuclid_chem_datasheet 	varchar := iuclid_chem_datasheet;
	p_commodity_id 				integer := commodity_id;
--	
  p_schema_name 				varchar := schema_name;
  seq_name 						varchar;
  inserted_id 					integer;
BEGIN
-- IF the ID is not given, then generate a new one.
IF p_id IS NULL THEN
	seq_name=schema_name||'.uom5_commodity_classifier_id_seq';
	p_id=nextval(seq_name::regclass);
END IF;
-- IF the GmlID is not given, then generate a new one.
IF p_gmlid IS NULL THEN
	p_gmlid='UUID_'||uuid_generate_v4();
END IF;

EXECUTE format('
INSERT INTO %I.uom5_commodity_classifier (
	id,
	objectclass_id,
	gmlid,
	gmlid_codespace,
	name,
	name_codespace,
	description,
	mol_formula,
	mol_weight,
	mol_weight_unit,
	physical_form,
	signal_word,
	is_chemical_complex,
	haz_class,
	haz_class_category_code,
	haz_class_statement_code,
	haz_class_pictogram_code,
	haz_class_pictogram_uri,
	ec_number,
	cas_number,
	iuclid_chem_datasheet,
	commodity_id
) VALUES (
%L, %L, %L, %L, %L, %L, %L, %L, %L, %L, 
%L, %L, %L, %L, %L, %L, %L, %L, %L, %L, 
%L, %L
) RETURNING id',
	p_schema_name,
	p_id, 
	p_objectclass_id, 
	p_gmlid, 
	p_gmlid_codespace, 
	p_name, 
	p_name_codespace, 
	p_description, 
	p_mol_formula, 
	p_mol_weight, 
	p_mol_weight_unit, 
	p_physical_form, 
	p_signal_word, 
	p_is_chemical_complex, 
	p_haz_class, 
	p_haz_class_category_code, 
	p_haz_class_statement_code, 
	p_haz_class_pictogram_code, 
	p_haz_class_pictogram_uri, 
	p_ec_number, 
	p_cas_number, 
	p_iuclid_chem_datasheet, 
	p_commodity_id
) INTO inserted_id;
RETURN inserted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_insert_commodity_classifier (id: %): %', p_id, SQLERRM;
END;
$$ LANGUAGE 'plpgsql';


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Hierchy level 5: Lowest level
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

----------------------------------------------------------------
-- Function uom5_INSERT_COMM_CLASS_TO_COMM_CLASS
----------------------------------------------------------------
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_insert_comm_class_to_comm_class (
	comm_class_parent_id 	integer,
	comm_class_id 			integer,
--	
	schema_name 			varchar DEFAULT 'citydb'::varchar
)
RETURNS void
AS $$
DECLARE
	p_comm_class_parent_id 	integer := comm_class_parent_id;
	p_comm_class_id 		integer := comm_class_id;
--	
	p_schema_name 			varchar := schema_name;
BEGIN
EXECUTE format('
INSERT INTO %I.uom5_comm_class_to_comm_class (
	comm_class_parent_id,
	comm_class_id
) VALUES (
%L, %L
)',
	p_schema_name,
	p_comm_class_parent_id, 
	p_comm_class_id
) ;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_insert_comm_class_to_comm_class (comm_class_parent_id: %, comm_class_id: %): %', comm_class_parent_id, comm_class_id, SQLERRM;
END;
$$ LANGUAGE 'plpgsql';


----------------------------------------------------------------
-- Function uom5_INSERT_LINK
----------------------------------------------------------------
CREATE OR REPLACE FUNCTION citydb_pkg.uom5_insert_link (
	objectclass_id  	integer,
	id              	integer DEFAULT NULL,
	gmlid           	varchar DEFAULT NULL,
	gmlid_codespace 	varchar DEFAULT NULL,
	name            	varchar DEFAULT NULL,
	name_codespace  	varchar DEFAULT NULL,
	description     	text DEFAULT NULL,
	direction       	character DEFAULT NULL,
	link_control    	varchar DEFAULT NULL,
	type            	varchar DEFAULT NULL,
	start_node_id   	integer DEFAULT NULL,
	end_node_id     	integer DEFAULT NULL,
	feat_graph_id   	integer DEFAULT NULL,
	ntw_graph_id    	integer DEFAULT NULL,
	line_geom       	geometry DEFAULT NULL,
--  
	schema_name 		varchar DEFAULT 'citydb'::varchar
)
RETURNS integer
AS $$
DECLARE
	p_id				integer := id;
	p_objectclass_id	integer := objectclass_id;
	p_gmlid				varchar := gmlid;
	p_gmlid_codespace 	varchar := gmlid_codespace;
	p_name				varchar := name;
	p_name_codespace 	varchar := name_codespace;
	p_description 		text:= description;
	p_direction  		character := direction;
	p_link_control   	varchar := link_control;
	p_type 				varchar := type;
	p_start_node_id  	integer := start_node_id;
	p_end_node_id 		integer := end_node_id;
	p_feat_graph_id  	integer := feat_graph_id;
	p_ntw_graph_id   	integer := ntw_graph_id;
	p_line_geom  		geometry:= line_geom;
--
	p_schema_name 		varchar := schema_name;
	seq_name 			varchar;
	inserted_id 		integer;
BEGIN
-- IF the ID is not given, then generate a new one.
IF p_id IS NULL THEN
	seq_name=schema_name||'.uom5_link_id_seq';
	p_id=nextval(seq_name::regclass);
END IF;
-- IF the GmlID is not given, then generate a new one.
IF p_gmlid IS NULL THEN
	p_gmlid='UUID_'||uuid_generate_v4();
END IF;
EXECUTE format('
INSERT INTO %I.uom5_link (
	id,
	objectclass_id,
	gmlid,
	gmlid_codespace,
	name,
	name_codespace,
	description,
	direction,
	link_control,
	type,
	start_node_id,
	end_node_id,
	feat_graph_id,
	ntw_graph_id,
	line_geom
) VALUES (
%L, %L, %L, %L, %L, %L, %L, %L, %L, %L, 
%L, %L, %L, %L, %L
) RETURNING id',
	p_schema_name,
	p_id, 
	p_objectclass_id, 
	p_gmlid, 
	p_gmlid_codespace, 
	p_name, 
	p_name_codespace, 
	p_description, 
	p_direction, 
	p_link_control, 
	p_type, 
	p_start_node_id, 
	p_end_node_id, 
	p_feat_graph_id, 
	p_ntw_graph_id, 
	p_line_geom
) INTO inserted_id;
RETURN inserted_id;
EXCEPTION
	WHEN OTHERS THEN RAISE NOTICE 'citydb_pkg.uom5_insert_link (id: %): %', p_id, SQLERRM;
END;
$$ LANGUAGE 'plpgsql';



-- ***********************************************************************
-- ***********************************************************************

DO
$$
BEGIN
RAISE NOTICE '

********************************

Utility Network O&M DML functions installation complete!

********************************

';
END
$$;
SELECT 'Utility Network O&M DML functions installation complete!'::varchar AS installation_result;

-- ***********************************************************************
-- ***********************************************************************
--
-- END OF FILE
--
-- ***********************************************************************
-- ***********************************************************************
