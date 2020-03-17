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
-- ***************** 06_uom5_QUERIES.sql *******************
--
-- This script stores the queries performed on the database
-- It is merely a compilation of SQL queries to be run independently from each other.

-- ***************************************************************************
-- ***************************************************************************
-- ***************************************************************************
-- ***************************************************************************
-- ***************************************************************************


-- ***************************************************************************
-- Contents:
-- Phase I - PLANNING OF STREET WORK
--		Query 1: Identifying pipes
--		Query 2: Identifying appurtenances
-- Phase II - DDETERMINING PERFORMANCE AND MAINTENANCE HISTORY
--		Query 3: Maintenance history
--		Query 4: Component performance
-- Phase III - Execution of street work
--		Query 5: Site conditions
--		Query 6: Valves Gas Low Pressure
--		Query 7: Valves District Heating Supply
--		Query 8: Valves District Heating Return
-- ***************************************************************************


-- *************************************************************************************************************************
-- *************************************************************************************************************************
-- PHASE I - PLANNING OF STREET WORK

-- ***************************************************************************
-- Identify all pipes in polygon corresponding to De Knepse straat (street polygon saved in 'queries' schema, 'excavation_polygon' table)
SELECT vp.id, vp.class, vp.function_of_line, vp.status, vp.network_name, vp.geom
FROM citydb_view.uom5_view_pipes AS vp, 
	(SELECT geom FROM queries.excavation_polygon WHERE id=1) AS area
WHERE st_intersects(vp.geom, area.geom);


-- ***************************************************************************
-- Identify all appurtenances in polygon corresponding to De Knepse straat (street polygon saved in 'queries' schema, 'excavation_polygon' table)
SELECT vapp.id, vapp.class, vapp.status, vapp.is_accesible, vapp.network_name, vapp.geom 
FROM citydb_view.uom5_view_appurtenances AS vapp, 
	(SELECT geom FROM queries.excavation_polygon WHERE id=1) AS area
WHERE st_intersects(vapp.geom, area.geom);


-- *************************************************************************************************************************
-- *************************************************************************************************************************
-- PHASE II - DETERMINING PERFORMANCE AND MAINTENANCE HISTORY

-- ***************************************************************************
-- Extract from the database the matinenance data from the pipes in the polygon from phase 1
SELECT id, name, status, network_name, maintenance_timeline, maintenance_type, maint_activity_type, maint_extra_information, maint_start_date, maint_end_date, maint_related_party_id, maint_related_party_role, maint_related_party_organisation_name, geom
FROM citydb_view.uom5_view_pipe_maintenance_history
WHERE id IN (
	SELECT vp.id
	FROM citydb_view.uom5_view_pipes AS vp, 
		(SELECT geom FROM queries.excavation_polygon WHERE id=1) AS area
	WHERE st_intersects(vp.geom, area.geom));


-- ***************************************************************************
-- Extract from the database the performance data from the pipes in the polygon from phase 1
SELECT id, name, status, network_name, date_of_installation, date_of_abandonment, class, has_cathodic_protection, pressure_grade, pressure_grade_unit, max_capacity, max_capacity_unit, performance_type, performance_requirement,  performance_score, performance_is_sufficient, performance_date_measurement, performance_extra_information, geom
FROM citydb_view.uom5_view_pipe_performance
WHERE id IN (
	SELECT vp.id
	FROM citydb_view.uom5_view_pipes AS vp, 
		(SELECT geom FROM queries.excavation_polygon WHERE id=1) AS area
	WHERE st_intersects(vp.geom, area.geom));



-- *************************************************************************************************************************
-- *************************************************************************************************************************
-- PHASE III - CONSTRUCTION

-- Site conditions
SELECT id, status, network_name, location_quality, location_accuracy, exterior_diameter, depth_quality, depth_level_measurement, depth_level_measurement_unit, depth_reference_level, depth_accuracy, date_of_depth_measurement, soil_type, groundwater_level,groundwater_level_unit, groundwater_reference_level, colour, geom
FROM citydb_view.uom5_view_pipes
WHERE id IN (
	SELECT vp.id
	FROM citydb_view.uom5_view_pipes AS vp, 
		(SELECT geom FROM queries.excavation_polygon WHERE id=1) AS area
	WHERE st_intersects(vp.geom, area.geom));

-- ***************************************************************************
-- This query finds the valves to shut off in case of activities near the gas low pressure pipe with id= 1611 (location: De Knepse straat). The network is supplied from a single point, appurtenance_id = 560.
SELECT DISTINCT sq.appurtenance_id, sq.geom
FROM
  (SELECT DISTINCT ON (pgr_KSP.path_id)
	  pgr_KSP.path_id,
	  pgr_KSP.seq,
	  pgr_KSP.node AS node_id,
	  pgr_KSP.edge AS link_id,
	  appt.appurtenance_id AS appurtenance_id,
	  app.class,
	  app.network_name,
   	  app.geom AS geom
  FROM 
	  pgr_KSP('
			SELECT id, start_node_id::int4 AS source, end_node_id::int4 AS target, 1 AS cost
			FROM citydb.uom5_link',
			(SELECT start_node_id FROM citydb_view.uom5_view_pipe_topology WHERE id=1611),
			(SELECT node_id FROM citydb_view.uom5_view_appurtenance_topology WHERE appurtenance_id=560),
			100,
			directed := FALSE)
  LEFT JOIN citydb_view.uom5_view_appurtenance_topology AS appt ON appt.node_id = pgr_KSP.node	
  LEFT JOIN citydb_view.uom5_view_appurtenances AS app  ON app.id = appt.appurtenance_id
  WHERE app.class = 'valve'
  ORDER BY pgr_KSP.path_id, pgr_KSP.seq) AS sq;
  
  
-- ***************************************************************************
-- This query finds the valves to shut down in case of activities near the district heating supply pipe with id=1205 (location: De Knepse straat)
-- The network is supplied from a single point, appurtenance_id = 303. Please note, the district heating supply network ends at appurtenance_id= 239 & 303 (have to try all)
SELECT DISTINCT
  sq.appurtenance_id, sq.geom
FROM
  (SELECT DISTINCT ON (pgr_KSP.path_id)
	  pgr_KSP.path_id,
	  pgr_KSP.seq,
	  pgr_KSP.node AS node_id,
	  pgr_KSP.edge AS link_id,
	  appt.appurtenance_id AS appurtenance_id,
	  app.class,
	  app.network_name,
   	  app.geom AS geom
  FROM 
	  pgr_KSP('
			SELECT
			   id,
			   start_node_id::int4 AS source,
			   end_node_id::int4 AS target,
			   1 AS cost
			FROM
			   citydb.uom5_link',
			(SELECT start_node_id FROM citydb_view.uom5_view_pipe_topology WHERE id=1205),
			(SELECT node_id FROM citydb_view.uom5_view_appurtenance_topology WHERE appurtenance_id=303),
			100,
			directed := FALSE)
  LEFT JOIN citydb_view.uom5_view_appurtenance_topology 	AS appt ON appt.node_id = pgr_KSP.node	
  LEFT JOIN citydb_view.uom5_view_appurtenances 			AS app  ON app.id = appt.appurtenance_id
  WHERE app.class = 'valve'
  ORDER BY pgr_KSP.path_id, pgr_KSP.seq) AS sq; 


-- ***************************************************************************
-- This query finds the valves to shut down in case of activities near the district heating return pipe with id=1136 (location: De Knepse straat)
-- The network is supplied from a single point, appurtenance_id = 84. Please note, the district heating return network ends at appurtenance_id= 84, 151 & 154  (have to try all)
SELECT DISTINCT
  sq.appurtenance_id, sq.geom
FROM
  (SELECT DISTINCT ON (pgr_KSP.path_id)
	  pgr_KSP.path_id,
	  pgr_KSP.seq,
	  pgr_KSP.node AS node_id,
	  pgr_KSP.edge AS link_id,
	  appt.appurtenance_id AS appurtenance_id,
	  app.class,
	  app.network_name,
   	  app.geom AS geom
  FROM 
	  pgr_KSP('
			SELECT
			   id,
			   start_node_id::int4 AS source,
			   end_node_id::int4 AS target,
			   1 AS cost
			FROM
			   citydb.uom5_link',
			(SELECT start_node_id FROM citydb_view.uom5_view_pipe_topology WHERE id=1136),
			(SELECT node_id FROM citydb_view.uom5_view_appurtenance_topology WHERE appurtenance_id=84),
			100,
			directed := FALSE)
  LEFT JOIN citydb_view.uom5_view_appurtenance_topology 	AS appt ON appt.node_id = pgr_KSP.node	
  LEFT JOIN citydb_view.uom5_view_appurtenances 			AS app  ON app.id = appt.appurtenance_id
  WHERE app.class = 'valve'
  ORDER BY pgr_KSP.path_id, pgr_KSP.seq) AS sq;



