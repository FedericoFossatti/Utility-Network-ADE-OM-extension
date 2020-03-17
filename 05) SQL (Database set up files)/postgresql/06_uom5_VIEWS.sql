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
-- ***************** 06_uom5_VIEWS.sql *******************
--
-- This script creates views for the O%M database
-- ***************************************************************************
-- ***************************************************************************
-- ***************************************************************************
-- ***************************************************************************
-- ***************************************************************************


-- ***************************************************************************
-- Contents:
--  uom5_view_pipes
--  uom5_view_appurtenances
--  uom5_view_pipe_maintenance_history
--  uom5_view_pipe_performance
--  uom5_view_pipe_topology
--  uom5_view_appurtenance_topology

-- ***************************************************************************


-- ***************************************************************************
--This is a simple demonstration. This join works well because only 1 material, measured_depth, dimensions, network, soil_and_groundwater, and identification referrs back to 1 single network feature each.
--For example, if a network feature had more than 1 measured_depth, a different approach would need to be taken to present the results.
DROP VIEW IF EXISTS    citydb_view.uom5_view_pipes CASCADE;
CREATE OR REPLACE VIEW citydb_view.uom5_view_pipes AS
SELECT
  co.id,
  co.objectclass_id,
  co.gmlid,
  co.name,
  co.description,
  co.relative_to_terrain,
  nf.status,
  nf.function,
  nf.usage,
  nf.location_quality,
  nf.location_accuracy,
  nf.elevation_quality,
  nf.standard_depth,
  nf.standard_depth_unit,
  nf.date_of_installation,
  nf.date_in_use,
  nf.date_of_location_measuring,
  nf.date_of_registration,
  nf.date_of_abandonment,
  nf.date_of_removal,
  p.class,
  p.function_of_line,
  p.is_gravity,
  p.slope,
  p.slope_unit,
  p.is_directional_drilling,
  p.has_cathodic_protection,
  p.pressure_grade,
  p.pressure_grade_unit,
  p.max_capacity,
  p.max_capacity_unit,
  ciob.name AS network_name,
  m.type AS material_type,
  d.shape,
  d.wall_thickness,
  d.wall_thinkness_unit,
  d.exterior_diameter,
  d.exterior_diameter_unit,
  mdepth.depth_quality,
  mdepth.depth_level_measurement,
  mdepth.depth_level_measurement_unit,
  mdepth.depth_reference_level,
  mdepth.depth_point_of_measurement,
  mdepth.depth_accuracy,
  mdepth.date_of_depth_measurement,
  sgw.type AS soil_type,
  sgw.moisture_content AS soil_moisture_content,
  sgw.permeability AS soil_permeability,
  sgw.permeability_unit AS soil_permeability_unit,
  sgw.groundwater_level,
  sgw.groundwater_level_unit,
  sgw.groundwater_reference_level,
  ident.identifier,
  ident.identifier_type,
  ident.is_label_visible,
  ident.label_location,
  ident.colour,
  nf.geom
FROM 
  citydb.cityobject AS co
JOIN citydb.uom5_network_feature 					AS nf 		ON nf.id = co.id
JOIN citydb.uom5_pipe 								AS p 		ON p.id = co.id
LEFT JOIN citydb.uom5_network_feat_to_material 		AS nfm 		ON nfm.network_feature_id = co.id
LEFT JOIN citydb.uom5_material 						AS m 		ON m.id = nfm.material_id
LEFT JOIN citydb.uom5_dimensions 					AS d 		ON d.feature_id = co.id
LEFT JOIN citydb.uom5_network_to_network_feature 	AS ntonf 	ON ntonf.network_feature_id = nf.id
LEFT JOIN citydb.uom5_network 						AS ntw 		ON ntw.id = ntonf.network_id
LEFT JOIN citydb.cityobject							AS ciob 	ON ciob.id = ntw.id
LEFT JOIN citydb.uom5_measured_depth 				AS mdepth 	ON mdepth.ntw_feature_id = nf.id
LEFT JOIN citydb.uom5_soil_and_groundwater			AS sgw		ON sgw.ntw_feature_id = nf.id
LEFT JOIN citydb.uom5_identification				AS ident	ON ident.feature_id = nf.id
WHERE 
  ciob.name != 'District Heating'
ORDER BY
  co.id ASC;


-- ***************************************************************************
--This is a simple demonstration. This join works well because only 1 material, measured_depth, dimensions, network, soil_and_groundwater, and identification referrs back to 1 single network feature each.
--For example, if a network feature had more than 1 measured_depth, a different approach would need to be taken to present the results.
DROP VIEW IF EXISTS    citydb_view.uom5_view_appurtenances CASCADE;
CREATE OR REPLACE VIEW citydb_view.uom5_view_appurtenances AS
SELECT
  co.id,
  co.objectclass_id,
  co.gmlid,
  co.name,
  co.description,
  co.relative_to_terrain,
  nf.status,
  nf.function,
  nf.usage,
  nf.location_quality,
  nf.location_accuracy,
  nf.elevation_quality,
  nf.standard_depth,
  nf.standard_depth_unit,
  nf.date_of_installation,
  nf.date_in_use,
  nf.date_of_location_measuring,
  nf.date_of_registration,
  nf.date_of_abandonment,
  nf.date_of_removal,
  fc.class,
  fc.is_accesible, 
  ciob.name AS network_name,
  m.type AS material_type,
  d.shape,
  d.wall_thickness,
  d.wall_thinkness_unit,
  d.exterior_diameter,
  d.exterior_diameter_unit,
  mdepth.depth_quality,
  mdepth.depth_level_measurement,
  mdepth.depth_level_measurement_unit,
  mdepth.depth_reference_level,
  mdepth.depth_point_of_measurement,
  mdepth.depth_accuracy,
  mdepth.date_of_depth_measurement,
  sgw.type AS soil_type,
  sgw.moisture_content AS soil_moisture_content,
  sgw.permeability AS soil_permeability,
  sgw.permeability_unit AS soil_permeability_unit,
  sgw.groundwater_level,
  sgw.groundwater_level_unit,
  sgw.groundwater_reference_level,
  ident.identifier,
  ident.identifier_type,
  ident.is_label_visible,
  ident.label_location,
  ident.colour,
  nf.geom
FROM 
  citydb.cityobject AS co
JOIN citydb.uom5_network_feature 					AS nf 		ON nf.id = co.id
JOIN citydb.uom5_functional_component 				AS fc 		ON fc.id = co.id
LEFT JOIN citydb.uom5_network_feat_to_material 		AS nfm 		ON nfm.network_feature_id = co.id
LEFT JOIN citydb.uom5_material 						AS m 		ON m.id = nfm.material_id
LEFT JOIN citydb.uom5_dimensions 					AS d 		ON d.feature_id = co.id
LEFT JOIN citydb.uom5_network_to_network_feature 	AS ntonf 	ON ntonf.network_feature_id = nf.id
LEFT JOIN citydb.uom5_network 						AS ntw 		ON ntw.id = ntonf.network_id
LEFT JOIN citydb.cityobject							AS ciob 	ON ciob.id = ntw.id
LEFT JOIN citydb.uom5_measured_depth 				AS mdepth 	ON mdepth.ntw_feature_id = nf.id
LEFT JOIN citydb.uom5_soil_and_groundwater			AS sgw		ON sgw.ntw_feature_id = nf.id
LEFT JOIN citydb.uom5_identification				AS ident	ON ident.feature_id = nf.id
WHERE 
  ciob.name != 'District Heating'
ORDER BY
  co.id ASC;


-- ***************************************************************************
DROP VIEW IF EXISTS    citydb_view.uom5_view_pipe_maintenance_history CASCADE;
CREATE OR REPLACE VIEW citydb_view.uom5_view_pipe_maintenance_history AS
SELECT
  co.id,
  co.objectclass_id,
  co.gmlid,
  co.name,
  co.description,
  nf.status,
  nf.function,
  nf.usage,
  p.class,
  p.function_of_line,
  p.is_directional_drilling,
  p.has_cathodic_protection,
  p.pressure_grade,
  p.pressure_grade_unit,
  p.max_capacity,
  p.max_capacity_unit,
  ciob.name AS network_name,
  maint.maintenance_timeline,
  maint.maintenance_type,
  maint.activity_type AS maint_activity_type,
  maint.extra_information AS maint_extra_information,
  maint.start_date AS maint_start_date,
  maint.end_date AS maint_end_date,
  rp.id AS maint_related_party_id,
  rp.role AS maint_related_party_role,
  rp.organisation_name AS maint_related_party_organisation_name,
  nf.geom
FROM 
  citydb.cityobject AS co
JOIN citydb.uom5_network_feature 							AS nf 		ON nf.id = co.id
JOIN citydb.uom5_pipe 										AS p 		ON p.id = co.id
JOIN citydb.uom5_network_feature_to_maintenance_activity	AS nftoma	ON nftoma.network_feature_id = nf.id
JOIN citydb.uom5_maintenance_activity						AS maint	ON maint.id = nftoma.maintenance_activity_id
LEFT JOIN citydb.uom5_network_to_network_feature 			AS ntonf 	ON ntonf.network_feature_id = nf.id
LEFT JOIN citydb.uom5_network 								AS ntw 		ON ntw.id = ntonf.network_id
LEFT JOIN citydb.cityobject									AS ciob 	ON ciob.id = ntw.id
LEFT JOIN citydb.uom5_related_party_to_maintenance_activity AS rptoma	ON rptoma.maintenance_activity_id = maint.id
LEFT JOIN citydb.uom5_related_party							AS rp		ON rp.id = rptoma.party_id
WHERE 
  ciob.name != 'District Heating'
ORDER BY
  co.id ASC;


-- ***************************************************************************
DROP VIEW IF EXISTS    citydb_view.uom5_view_pipe_performance CASCADE;
CREATE OR REPLACE VIEW citydb_view.uom5_view_pipe_performance AS
SELECT
  co.id,
  co.objectclass_id,
  co.gmlid,
  co.name,
  co.description,
  nf.status,
  nf.function,
  nf.usage,
  nf.date_of_installation,
  nf.date_in_use,
  nf.date_of_location_measuring,
  nf.date_of_registration,
  nf.date_of_abandonment,
  nf.date_of_removal, 
  p.class,
  p.function_of_line,
  p.is_directional_drilling,
  p.has_cathodic_protection,
  p.pressure_grade,
  p.pressure_grade_unit,
  p.max_capacity,
  p.max_capacity_unit,
  ciob.name AS network_name,
  perf.performance_type,
  perf.performance_requirement,
  perf.performance_score,
  perf.is_sufficient AS performance_is_sufficient,
  perf.date_of_performance_measuring AS performance_date_measurement,
  perf.extra_information AS performance_extra_information,
  nf.geom
FROM 
  citydb.cityobject AS co
JOIN citydb.uom5_network_feature 							AS nf 		ON nf.id = co.id
JOIN citydb.uom5_pipe 										AS p 		ON p.id = co.id
JOIN citydb.uom5_performance								AS perf		ON perf.feature_id = nf.id
LEFT JOIN citydb.uom5_network_to_network_feature 			AS ntonf 	ON ntonf.network_feature_id = nf.id
LEFT JOIN citydb.uom5_network 								AS ntw 		ON ntw.id = ntonf.network_id
LEFT JOIN citydb.cityobject									AS ciob 	ON ciob.id = ntw.id
WHERE 
  ciob.name != 'District Heating'
ORDER BY
  performance_date_measurement ASC;


-- ***************************************************************************
DROP VIEW IF EXISTS    citydb_view.uom5_view_pipe_topology CASCADE;
CREATE OR REPLACE VIEW citydb_view.uom5_view_pipe_topology AS
SELECT co.id,
  co.objectclass_id,
  co.name,
  co.description,
  p.class AS pipe_class,
  n.id AS network_id,
  ciob.name AS network_name,
  fg.id AS feature_graph_id,
  link.id AS link_id,
  link.start_node_id,
  link.end_node_id,
  link2.id AS start_connected_inter_feature_link,
  link3.id AS end_connected_inter_feature_link
FROM citydb.cityobject co
JOIN citydb.uom5_network_feature 					AS nf 		ON nf.id = co.id
JOIN citydb.uom5_pipe 								AS p 		ON p.id = nf.id
JOIN citydb.uom5_network_to_network_feature 		AS ntonf 	ON ntonf.network_feature_id = nf.id
LEFT JOIN citydb.uom5_network 						AS n 		ON n.id = ntonf.network_id
LEFT JOIN citydb.cityobject					AS ciob 	ON ciob.id = n.id
JOIN citydb.uom5_feature_graph 					AS fg 		ON fg.ntw_feature_id = nf.id
JOIN citydb.uom5_link 								AS link 	ON link.feat_graph_id = fg.id
JOIN citydb.uom5_link 								AS link2 	ON link2.start_node_id = link.start_node_id AND link2.objectclass_id = 1007 --1007 are interFeatureLinks
JOIN citydb.uom5_link 								AS link3 	ON link3.start_node_id = link.end_node_id AND link3.objectclass_id = 1007
WHERE 
  co.objectclass_id = ANY (ARRAY[1104, 1105, 1106, 1107, 1108]) AND 
  ciob.name != 'District Heating'
ORDER BY
  co.id ASC;


-- ***************************************************************************
DROP VIEW IF EXISTS    citydb_view.uom5_view_appurtenance_topology CASCADE;
CREATE OR REPLACE VIEW citydb_view.uom5_view_appurtenance_topology AS
SELECT 
  co.id AS appurtenance_id,
  co.objectclass_id,
  co.name,
  co.description,
  fc.class AS funct_comp_class,
  n.id AS network_id,
  ciob.name AS network_name,  
  fg.id AS feature_graph_id,
  node.id AS node_id
FROM citydb.cityobject co
LEFT JOIN citydb.uom5_network_feature 				AS nf 		ON nf.id = co.id
LEFT JOIN citydb.uom5_network_to_network_feature 	AS ntonf 	ON ntonf.network_feature_id = nf.id
LEFT JOIN citydb.uom5_network 						AS n 		ON n.id = ntonf.network_id
LEFT JOIN citydb.cityobject					AS ciob 	ON ciob.id = n.id
LEFT JOIN citydb.uom5_functional_component 		AS fc 		ON fc.id = nf.id
LEFT JOIN citydb.uom5_feature_graph 				AS fg 		ON fg.ntw_feature_id = nf.id
LEFT JOIN citydb.uom5_node 						AS node 	ON node.feat_graph_id = fg.id
WHERE 
  co.objectclass_id >= 1120 AND 
  co.objectclass_id <= 1128 AND 
  ciob.name != 'District Heating'
ORDER BY
  co.id ASC;






-- ***********************************************************************
-- ***********************************************************************

DO
$$
BEGIN
RAISE NOTICE '

********************************

Utility Network O&M views installation complete!

********************************

';
END
$$;
SELECT 'Utility Network O&M views installed correctly!'::varchar AS installation_result;


-- ***********************************************************************
-- ***********************************************************************
--
-- END OF FILE
--
-- ***********************************************************************
-- ***********************************************************************