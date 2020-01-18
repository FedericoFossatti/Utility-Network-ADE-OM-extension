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
-- ***************** 05_unom5_TABLE_DATA.sql *******************
--
-- This script add entries to the ADE, SCHEMA, OBJECTCLASS and
-- SCHEMA_TO_OBJECTCLASS tables.
--
-- ***************************************************************************
-- ***************************************************************************
-- ***************************************************************************
-- ***************************************************************************
-- ***************************************************************************


-- ***************************************************************************
-- Contents: tables & data
-- 		ade
-- 		schema
-- 		schema_referencing
-- 		objectclass
-- 		schema_to_objectclass
-- 		unom5_lu_network_class
-- 		unom5_lu_network_function_and_usage
-- 		unom5_lu_network_feature_function
-- 		unom5_lu_spatial_quality
-- 		unom5_lu_status
-- 		unom5_lu_relative_to_terrain
-- 		unom5_lu_depth_point_of_measurement
-- 		unom5_lu_depth_reference_level
-- 		unom5_lu_depth_accuracy_value
-- 		unom5_lu_location_accuracy_value
-- 		unom5_lu_commodity_supply
-- 		unom5_lu_signal_word
-- 		unom5_lu_optical_mode
-- 		unom5_lu_function_of_line
-- 		unom5_lu_pipe_type
-- 		unom5_lu_cable_type
-- 		unom5_lu_network_feature_class
-- 		unom5_lu_material
-- 		unom5_lu_party_role
-- 		unom5_lu_soil
-- 		unom5_lu_shape
-- 		unom5_lu_groundwater_reference
-- 		unom5_lu_identifier_type
-- 		unom5_lu_cost_type
-- 		unom5_lu_maintenance_timeline_type
-- 		unom5_lu_maintenance_activity_type
-- 		unom5_lu_maintenance_type
-- 		unom5_lu_performance_type
-- ***************************************************************************


-- Add entry into table ADE
DELETE FROM citydb.ade WHERE db_prefix='unom5'; 
INSERT INTO citydb.ade (name, description, version, db_prefix)
VALUES
('UtilityNetworks Operation & Maintenance ADE', 'UtilityNetworks Operation & Maintenance Application Domain Extension v. 5.6', '5.6', 'unom5');

-- Add entry into table SCHEMA
WITH a AS (SELECT id FROM citydb.ade WHERE db_prefix='unom5')
INSERT INTO citydb.schema
(ade_id, is_ade_root, citygml_version, xml_namespace_prefix, xml_namespace_uri, xml_schema_location)
SELECT
a.id, 1, '2.0','utilitynetworks_om', '_utilitynetworks_om_ade_placeholder_','_utilitynetworks_om_ade_placeholder_'
FROM a;

-- Add entry into table SCHEMA_REFERENCING
WITH unom AS (SELECT id FROM citydb.schema WHERE xml_namespace_uri='_utilitynetworks_om_ade_placeholder_' AND citygml_version='2.0'),
     c AS (SELECT id FROM citydb.schema WHERE xml_namespace_uri='http://schemas.opengis.net/citygml/2.0')
INSERT INTO citydb.schema_referencing (referenced_id, referencing_id) 
SELECT c.id, unom.id FROM unom, c;

-- Add entries into table OBJECTCLASS
DELETE FROM citydb.objectclass WHERE id BETWEEN 1000 AND 1300;
INSERT INTO citydb.objectclass (id, superclass_id, baseclass_id, is_ade_class, classname, tablename) VALUES

-- 01) Core and geometry
(1000,    3, 3, 1, 'Network'                      	, 'unom5_network'             	),
(1001,    3, 3, 1, 'AbstractNetworkFeature'       	, 'unom5_network_feature'     	),
(1002,    2, 2, 1, 'NetworkGraph'                 	, 'unom5_network_graph'       	),
(1003,    2, 2, 1, 'FeatureGraph'                 	, 'unom5_feature_graph'       	),
(1004,    2, 2, 1, 'Node'                         	, 'unom5_node'                	),
(1005,    2, 2, 1, 'AbstractLink'                 	, 'unom5_link'                	),
(1006, 1005, 2, 1, 'InteriorFeatureLink'          	, 'unom5_link'                	),
(1007, 1005, 2, 1, 'InterFeatureLink'             	, 'unom5_link'                	),
(1008, 1005, 2, 1, 'NetworkLink'                  	, 'unom5_link'                	),

-- 02) Functional characteristics                                                                        
(1020,   23, 3, 1, 'SupplyArea'                   	, 'cityobjectgroup'           	),	-- like CityObjectGroup
(1021,    2, 2, 1, 'RoleInNetwork'                	, 'unom5_role_in_network'     	),
(1022,    3, 3, 1, 'AbstractCityObject'           	, 'unom5_city_object'		 	),	-- No longer necessary.
(1023,   26, 3, 1, 'AbstractBuilding'             	, 'unom5_building'     		 	),	-- New. 
---- commodity supply
(1040,    1, 1, 1, 'AbstractCommoditySupply'      	, 'unom5_commodity_supply'      ),
(1041, 1040, 1, 1, 'LiquidCommoditySupply'        	, 'unom5_commodity_supply'      ),
(1042, 1040, 1, 1, 'GaseousCommoditySupply'       	, 'unom5_commodity_supply'      ),
(1043, 1040, 1, 1, 'SolidCommoditySupply'         	, 'unom5_commodity_supply'      ),
(1044, 1040, 1, 1, 'ElectricalCommoditySupply'    	, 'unom5_commodity_supply'      ),
(1045, 1040, 1, 1, 'OpticalCommoditySupply'       	, 'unom5_commodity_supply'      ),

-- 03) Network properties
---- commodity
(1060,    2, 2, 1, 'AbstractCommodity'            	, 'unom5_commodity'           	),
(1061, 1060, 2, 1, 'LiquidCommodity'              	, 'unom5_commodity'           	),
(1062, 1060, 2, 1, 'GaseousCommodity'             	, 'unom5_commodity'           	),
(1063, 1060, 2, 1, 'SolidCommodity'               	, 'unom5_commodity'           	),
(1064, 1060, 2, 1, 'ElectricalCommodity'          	, 'unom5_commodity'           	),
(1065, 1060, 2, 1, 'OpticalCommodity'             	, 'unom5_commodity'           	),
---- commodity classifier
(1080,    2, 2, 1, 'AbstractCommodityClassifier'  	, 'unom5_commodity_classifier'	),
(1081, 1080, 2, 1, 'ChemicalClassifier'           	, 'unom5_commodity_classifier'	),
(1082, 1080, 2, 1, 'GHSClassifier'                	, 'unom5_commodity_classifier'	),
(1083, 1080, 2, 1, 'GenericClassifier'            	, 'unom5_commodity_classifier'	),

-- 04) Network Components
---- distribution
(1100, 1001, 3, 1, 'AbstractDistributionComponent'  , '-'    						),	-- Newish. IT IS NOT IN ANY TABLE.
(1101, 1100, 3, 1, 'AbstractCable'   				, 'unom5_cable'    				),	-- Newish.
(1102, 1101, 3, 1, 'ElectricityCable'  				, 'unom5_cable'     			),	-- Newish.
(1103, 1101, 3, 1, 'TelecommunicationCable'   		, 'unom5_cable'     			),	-- Newish.
(1104, 1100, 3, 1, 'AbstractPipe'   			   	, 'unom5_pipe'     				),	-- Newish.
(1105, 1104, 3, 1, 'OilGasChemicalsPipe'   			, 'unom5_pipe'     				),	-- Newish.
(1106, 1104, 3, 1, 'WaterPipe'   			   		, 'unom5_pipe'     				),	-- Newish.
(1107, 1104, 3, 1, 'ThermalPipe'   			   		, 'unom5_pipe'     				),	-- Newish.
(1108, 1104, 3, 1, 'SewerPipe'   			   		, 'unom5_pipe'     				),	-- Newish.
---- functional
(1120, 1001, 3, 1, 'AbstractFunctionalComponent'   	, 'unom5_functional_component'  ),	-- Newish.
(1121, 1120, 3, 1, 'ComplexFunctionalComponent'   	, 'unom5_functional_component'  ),	-- Newish.
(1122, 1120, 3, 1, 'SimpleFunctionalComponent'   	, 'unom5_functional_component'  ),	-- Newish.
(1123, 1122, 3, 1, 'ConnectionComponent'   			, 'unom5_functional_component'  ),	-- Newish.
(1124, 1122, 3, 1, 'MeasurementComponent'   		, 'unom5_functional_component'  ),	-- Newish.
(1125, 1122, 3, 1, 'StorageComponent'   			, 'unom5_functional_component'  ),	-- Newish.
(1126, 1122, 3, 1, 'TerminalComponent'   			, 'unom5_functional_component'  ),	-- Newish.
(1127, 1122, 3, 1, 'ControllerComponent'   			, 'unom5_functional_component'  ),	-- Newish.
(1128, 1122, 3, 1, 'OtherComponent'   				, 'unom5_functional_component'  ),	-- Newish.
---- protective
(1140, 1001, 3, 1, 'AbstractProtectiveComponent'    , 'unom5_protective_element'  	),
(1141, 1140, 3, 1, 'Bedding'                       	, 'unom5_protective_element'  	),
(1142, 1140, 3, 1, 'ProtectiveShell'       			, 'unom5_protective_element'  	),
(1143, 1142, 3, 1, 'RectangularShell'              	, 'unom5_protective_element'  	),
(1144, 1142, 3, 1, 'RoundShell'                    	, 'unom5_protective_element'  	),
(1145, 1142, 3, 1, 'OtherShell'                    	, 'unom5_protective_element'  	),

-- 05) Component Properties
---- material & related party
(1160,    2, 2, 1, 'AbstractMaterialProperties'     , 'unom5_material'            	),
(1161, 1160, 2, 1, 'InteriorMaterial'              	, 'unom5_material'            	),
(1162, 1160, 2, 1, 'ExteriorMaterial'              	, 'unom5_material'            	),
(1163, 1160, 2, 1, 'FillingMaterial'               	, 'unom5_material'            	),
(1164,    2, 2, 1, 'RelatedParty'     				, 'unom5_related_party'         ),	-- New

-- 06) Maintenance and Operations Properties
(1180,    2, 2, 1, 'MaintenanceActivity'     		, 'unom5_maintenance_activity'  ),	-- New

-- 07) Performance Properties
(1200,    2, 2, 1, 'Impact'     					, 'unom5_impact'  				),	-- New
(1201,    2, 2, 1, 'Performance'     				, 'unom5_performance'  			),	-- New

-- 08) Hollow Space
(1220,    2, 2, 1, 'AbstractHollowSpace'            , 'unom5_hollow_space'        ),
(1221, 1220, 2, 1, 'HollowSpace'                   	, 'unom5_hollow_space'        ),
(1222, 1220, 2, 1, 'HollowSpacePart'               	, 'unom5_hollow_space'        )
;


-- Add entry into table SCHEMA_TO_OBJECTCLASS
WITH r AS (SELECT id FROM citydb.schema WHERE (xml_namespace_uri='_utilitynetworks_om_ade_placeholder_' AND citygml_version='2.0')
OR (xml_namespace_uri='_utilitynetworks_om_ade_placeholder_' AND citygml_version='1.0')
),
     s AS (SELECT id FROM citydb.objectclass WHERE id BETWEEN 1000 AND 1299 ORDER BY id)
INSERT INTO citydb.schema_to_objectclass (schema_id,objectclass_id) SELECT r.id, s.id FROM s, r ORDER BY s.id;


--***********************************************************************************************************************************************************************************
-- Add entries into Lookup tables (Codelists and Enumerations)

--**********************
-- 01) Core and geometry
INSERT INTO citydb.unom5_lu_network_class
(id, name, name_codespace, description)
VALUES
('unknown'   			,'Unknown Network'   				, NULL, NULL),
('electricity' 			,'Electricity Network' 				, NULL, NULL),
('oilGasChemicals'   	,'Oil, Gas and Chemicals Network'   , NULL, NULL),
('sewage'  				,'Sewage Network'  					, NULL, NULL),
('water'				,'Water Network'					, NULL, NULL),
('thermal'				,'Thermal Network'   				, NULL, NULL),
('telecommunications'	,'Telecommunications Network'   	, NULL, NULL)
;

INSERT INTO citydb.unom5_lu_network_function_and_usage
(id, name, name_codespace, description)
VALUES
('unknown'      ,'Unknown'      , NULL, NULL),
('supply'       ,'Supply'       , NULL, NULL),
('disposal'     ,'Disposal'     , NULL, NULL),
('communication','Communication', NULL, NULL)
;

INSERT INTO citydb.unom5_lu_network_feature_function
(id, name, name_codespace, description)
VALUES
('unknown'     ,'Unknown'      ,NULL, NULL),
('abstraction' ,'Abstraction'  ,NULL, NULL),
('branch'      ,'Branch'       ,NULL, NULL),
('control'     ,'Control'      ,NULL, NULL),
('distribution','Distribution' ,NULL, NULL),
('draining'    ,'Draining'     ,NULL, NULL),
('feeding'     ,'Feeding'      ,NULL, NULL),
('measurement' ,'Measurement'  ,NULL, NULL),
('observer'    ,'Observer'     ,NULL, NULL),
('protection'  ,'Protection'   ,NULL, NULL),
('shortCircuit','Short circuit',NULL, NULL),
('shutOff'     ,'ShutOff'      ,NULL, NULL),
('storage'     ,'Storage'      ,NULL, NULL),
('venting'     ,'Venting'      ,NULL, NULL),
('other'       ,'Other'        ,NULL, NULL)
;

INSERT INTO citydb.unom5_lu_spatial_quality
(id, name, name_codespace, description)
VALUES
('unknown'     ,'Unknown'     , NULL, NULL),
('surveyed'    ,'Surveyed'    , NULL, NULL),
('calculated'  ,'Calculated'  , NULL, NULL),
('interpolated','Interpolated', NULL, NULL),
('estimated'   ,'Estimated'   , NULL, NULL),
('standard'    ,'Standard'    , NULL, NULL),
('assumed'     ,'Assumed'     , NULL, NULL)
;

INSERT INTO citydb.unom5_lu_status
(id, name, name_codespace, description)
VALUES
('functional'      		,'Functional'                   , NULL, NULL),
('tempOutOfService'		,'Temporarily out of service'	, NULL, NULL),
('outOfService'    		,'Out of service'            	, NULL, NULL),
('decomissioned'   		,'Decomissioned'                , NULL, NULL),
('destroyed'   			,'Destroyed'                	, NULL, NULL),
('blocked'   			,'Blocked'                		, NULL, NULL),
('projected'   			,'Projected'                 	, NULL, NULL),
('underConstruction'   	,'Under Construction'           , NULL, NULL),
('other'       	   		,'Other'          		   	 	, NULL, NULL),
('unknown'         		,'Unknown'                   	, NULL, NULL)
;

INSERT INTO citydb.unom5_lu_relative_to_terrain
(id, name, name_codespace, description)
VALUES
('unknown'      						,'Unknown'                   				, NULL, NULL),
('entirelyAboveTerrain'      			,'Entirely Above Terrain'                   , NULL, NULL),
('substantiallyAboveTerrain'      		,'Substantially Above Terrain'              , NULL, NULL),
('substantiallyAboveAndBelowTerrain'  	,'Substantially Above And Below Terrain'    , NULL, NULL),
('substantiallyBelowTerrain'      		,'Substantially Below Terrain'              , NULL, NULL),
('entirelyBelowTerrain'      			,'Entirely Below Terrain'                   , NULL, NULL)
;

INSERT INTO citydb.unom5_lu_depth_point_of_measurement
(id, name, name_codespace, description)
VALUES
('unknown'      	,'Unknown'          , NULL, NULL),
('top'      		,'Top'         		, NULL, NULL),
('center'      		,'Center'        	, NULL, NULL),
('bottom'      		,'Bottom'      		, NULL, NULL),
('other'      		,'Other'       		, NULL, NULL)
;

INSERT INTO citydb.unom5_lu_depth_reference_level
(id, name, name_codespace, description)
VALUES
('unknown'      	,'Unknown'          , NULL, NULL),
('groundLevel'      ,'Ground Level'     , NULL, NULL),
('seaLevel'      	,'Sea Level'        , NULL, NULL),
('other'      		,'Other'          	, NULL, NULL)
;

INSERT INTO citydb.unom5_lu_depth_accuracy_value
(id, name, name_codespace, description)
VALUES
('unknown'      ,'Unknown'        , NULL, NULL),
('30cm'      	,'30 cm'          , NULL, NULL),
('50cm'      	,'50 cm'          , NULL, NULL),
('100cm'      	,'100 cm'         , NULL, NULL)
;

INSERT INTO citydb.unom5_lu_location_accuracy_value
(id, name, name_codespace, description)
VALUES
('unknown'      ,'Unknown'        , NULL, NULL),
('30cm'      	,'30 cm'          , NULL, NULL),
('50cm'      	,'50 cm'          , NULL, NULL),
('100cm'      	,'100 cm'         , NULL, NULL)
;


--**********************
-- 02) Functional Characteristics

INSERT INTO citydb.unom5_lu_commodity_supply
(objectclass_id, id, name, name_codespace, description)
VALUES
-- Liquid Commodity Supply
(1041,'unknown'             	,'Unknown'                   , NULL, NULL),
(1041,'potableWater'            ,'Potable Water'             , NULL, NULL),
(1041,'rawWater'             	,'Raw Water'                 , NULL, NULL),
(1041,'stormWater'             	,'Storm Water'               , NULL, NULL),
(1041,'sanitaryWater'           ,'Sanitary Water'            , NULL, NULL),
(1041,'wasteWater'             	,'Waste Water'               , NULL, NULL),
(1041,'combinedWater'           ,'Combined Water'            , NULL, NULL),
(1041,'reclaimedWater'          ,'Reclaimed Water'           , NULL, NULL),
(1041,'districtHeatingWater'    ,'District Heating Water'    , NULL, NULL),
(1041,'saltWater'             	,'Salt Water'                , NULL, NULL),
(1041,'gasoline'             	,'Gasoline'                  , NULL, NULL),
(1041,'oil'             		,'Oil'                       , NULL, NULL),
(1041,'gasohol'             	,'Gasohol'                   , NULL, NULL),
(1041,'acid'             		,'Acid'                      , NULL, NULL),
(1041,'kerosine'             	,'Kerosine'                  , NULL, NULL),
(1041,'liquefiedNaturalGas'     ,'Liquefied Natural Gas'     , NULL, NULL),
(1041,'liquefiedPetroleumGas'   ,'Liquefied Petroleum Gas'   , NULL, NULL),
(1041,'acetone'             	,'Acetone'                   , NULL, NULL),
(1041,'crude'            		,'Crude'                     , NULL, NULL),
(1041,'dichloroethane'          ,'Dichloroethane'            , NULL, NULL),
(1041,'gasoil'             		,'Gasoil'                 	 , NULL, NULL),
(1041,'liquidAmmonia'           ,'Liquid Ammonia'            , NULL, NULL),
(1041,'liquidHydrocarbon'       ,'Liquid Hydrocarbon'        , NULL, NULL),
(1041,'tetrachloroethane'       ,'Tetrachloroethane'         , NULL, NULL),
(1041,'other'             		,'Other'                     , NULL, NULL),
-- Liquid Commodity
(1061,'unknown'             	,'Unknown'                   , NULL, NULL),
(1061,'potableWater'            ,'Potable Water'             , NULL, NULL),
(1061,'rawWater'             	,'Raw Water'                 , NULL, NULL),
(1061,'stormWater'             	,'Storm Water'               , NULL, NULL),
(1061,'sanitaryWater'           ,'Sanitary Water'            , NULL, NULL),
(1061,'wasteWater'             	,'Waste Water'               , NULL, NULL),
(1061,'combinedWater'           ,'Combined Water'            , NULL, NULL),
(1061,'reclaimedWater'          ,'Reclaimed Water'           , NULL, NULL),
(1061,'districtHeatingWater'    ,'District Heating Water'    , NULL, NULL),
(1061,'saltWater'             	,'Salt Water'                , NULL, NULL),
(1061,'gasoline'             	,'Gasoline'                  , NULL, NULL),
(1061,'oil'             		,'Oil'                       , NULL, NULL),
(1061,'gasohol'             	,'Gasohol'                   , NULL, NULL),
(1061,'acid'             		,'Acid'                      , NULL, NULL),
(1061,'kerosine'             	,'Kerosine'                  , NULL, NULL),
(1061,'liquefiedNaturalGas'     ,'Liquefied Natural Gas'     , NULL, NULL),
(1061,'liquefiedPetroleumGas'   ,'Liquefied Petroleum Gas'   , NULL, NULL),
(1061,'acetone'             	,'Acetone'                   , NULL, NULL),
(1061,'crude'            		,'Crude'                     , NULL, NULL),
(1061,'dichloroethane'          ,'Dichloroethane'            , NULL, NULL),
(1061,'gasoil'             		,'Gasoil'                 	 , NULL, NULL),
(1061,'liquidAmmonia'           ,'Liquid Ammonia'            , NULL, NULL),
(1061,'liquidHydrocarbon'       ,'Liquid Hydrocarbon'        , NULL, NULL),
(1061,'tetrachloroethane'       ,'Tetrachloroethane'         , NULL, NULL),
(1061,'other'             		,'Other'                     , NULL, NULL),
-- Gaseous Commodity Supply
(1042,'unknown'     						,'Unknown'                              , NULL, NULL),
(1042,'naturalGas'  						,'Natural gas'                          , NULL, NULL),
(1042,'petroleumGas'						,'Petroleum gas'                        , NULL, NULL),
(1042,'helium'      						,'Helium'                               , NULL, NULL),
(1042,'air'         						,'Air'                                  , NULL, NULL),
(1042,'dioxygen'    						,'Dioxygen'                             , NULL, NULL),
(1042,'nitrogen'    						,'Nitrogen'                             , NULL, NULL),
(1042,'naturalGasAndTetrahydrothiophene'    ,'Natural Gas And Tetrahydrothiophene'  , NULL, NULL),
(1042,'hydrogen'    						,'Hydrogen'                             , NULL, NULL),
(1042,'carbon'      						,'Carbon'                               , NULL, NULL),
(1042,'methane'      						,'Methane'                              , NULL, NULL),
(1042,'residualGas'      					,'Residual Gas'                         , NULL, NULL),
(1042,'argon'      							,'Argon'                           	    , NULL, NULL),
(1042,'butadiene'      						,'Butadiene'                            , NULL, NULL),
(1042,'butadiene1,3'      					,'Butadiene 1,3'                        , NULL, NULL),
(1042,'butane'      						,'Butane'                               , NULL, NULL),
(1042,'propane'      						,'Propane'                              , NULL, NULL),
(1042,'compressedAir'      					,'Compressed Air'                       , NULL, NULL),
(1042,'ethylene'      						,'Ethylene'                             , NULL, NULL),
(1042,'isobutane'      						,'Isobutane'                            , NULL, NULL),
(1042,'vinylChloride'      					,'Vinyl Chloride'                       , NULL, NULL),
(1042,'oxygen'      						,'Oxygen'                               , NULL, NULL),
(1042,'propylene'      						,'Propylene'               	            , NULL, NULL),
(1042,'other'      							,'Other'                                , NULL, NULL),
-- Gaseous Commodity
(1062,'unknown'     						,'Unknown'                              , NULL, NULL),
(1062,'naturalGas'  						,'Natural gas'                          , NULL, NULL),
(1062,'petroleumGas'						,'Petroleum gas'                        , NULL, NULL),
(1062,'helium'      						,'Helium'                               , NULL, NULL),
(1062,'air'         						,'Air'                                  , NULL, NULL),
(1062,'dioxygen'    						,'Dioxygen'                             , NULL, NULL),
(1062,'nitrogen'    						,'Nitrogen'                             , NULL, NULL),
(1062,'naturalGasAndTetrahydrothiophene'    ,'Natural Gas And Tetrahydrothiophene'  , NULL, NULL),
(1062,'hydrogen'    						,'Hydrogen'                             , NULL, NULL),
(1062,'carbon'      						,'Carbon'                               , NULL, NULL),
(1062,'methane'      						,'Methane'                              , NULL, NULL),
(1062,'residualGas'      					,'Residual Gas'                         , NULL, NULL),
(1062,'argon'      							,'Argon'                           	    , NULL, NULL),
(1062,'butadiene'      						,'Butadiene'                            , NULL, NULL),
(1062,'butadiene1,3'      					,'Butadiene 1,3'                        , NULL, NULL),
(1062,'butane'      						,'Butane'                               , NULL, NULL),
(1062,'propane'      						,'Propane'                              , NULL, NULL),
(1062,'compressedAir'      					,'Compressed Air'                       , NULL, NULL),
(1062,'ethylene'      						,'Ethylene'                             , NULL, NULL),
(1062,'isobutane'      						,'Isobutane'                            , NULL, NULL),
(1062,'vinylChloride'      					,'Vinyl Chloride'                       , NULL, NULL),
(1062,'oxygen'      						,'Oxygen'                               , NULL, NULL),
(1062,'propylene'      						,'Propylene'               	            , NULL, NULL),
(1062,'other'      							,'Other'                                , NULL, NULL),
-- Solid Commodity Supply
(1043,'unknown'   ,'Unknown'     , NULL, NULL),
(1043,'carbonDust','Carbon dust' , NULL, NULL),
(1043,'stone'     ,'Stone'       , NULL, NULL),
(1043,'ore'       ,'Ore'         , NULL, NULL),
(1043,'sand'      ,'Sand'        , NULL, NULL),
(1043,'phenol'    ,'Phenol'      , NULL, NULL),
(1043,'other'     ,'Other'       , NULL, NULL),
-- Solid Commodity
(1063,'unknown'   ,'Unknown'     , NULL, NULL),
(1063,'carbonDust','Carbon dust' , NULL, NULL),
(1063,'stone'     ,'Stone'       , NULL, NULL),
(1063,'ore'       ,'Ore'         , NULL, NULL),
(1063,'sand'      ,'Sand'        , NULL, NULL),
(1063,'phenol'    ,'Phenol'      , NULL, NULL),
(1063,'other'     ,'Other'       , NULL, NULL),
-- Electrical Commodity Supply
(1044,'unknown'                      ,'Unknown'                         , NULL, NULL),
(1044,'directCurrent'                ,'Direct current'                  , NULL, NULL),
(1044,'singlePhaseAlternatingCurrent','Single-phase alternating current', NULL, NULL),
(1044,'threePhaseAlternatingCurrent' ,'Three-phase alternating current' , NULL, NULL),
(1044,'undulatoryCurrent'            ,'Undulatory current'              , NULL, NULL),
(1044,'telephone'                    ,'Telephone'                       , NULL, NULL),
(1044,'data'                    	 ,'Data'                       	    , NULL, NULL),
(1044,'other'                    	 ,'Other'                       	, NULL, NULL),
-- Electrical Commodity
(1064,'unknown'                      ,'Unknown'                         , NULL, NULL),
(1064,'directCurrent'                ,'Direct current'                  , NULL, NULL),
(1064,'singlePhaseAlternatingCurrent','Single-phase alternating current', NULL, NULL),
(1064,'threePhaseAlternatingCurrent' ,'Three-phase alternating current' , NULL, NULL),
(1064,'undulatoryCurrent'            ,'Undulatory current'              , NULL, NULL),
(1064,'telephone'                    ,'Telephone'                       , NULL, NULL),
(1064,'data'                    	 ,'Data'                       	    , NULL, NULL),
(1064,'other'                    	 ,'Other'                       	, NULL, NULL),
-- Optical Commodity Supply & Commodity
(1045,'unknown'	,'Unknown'      , NULL, NULL),
(1045,'light'  	,'Light'        , NULL, NULL),
(1045,'other'  	,'Other'        , NULL, NULL),
-- Optical Commodity Supply & Commodity
(1065,'unknown'	,'Unknown'      , NULL, NULL),
(1065,'light'  	,'Light'        , NULL, NULL),
(1065,'other'  	,'Other'        , NULL, NULL)
;


--**********************
-- 03) Network Properties

INSERT INTO citydb.unom5_lu_signal_word
(id, name, name_codespace, description)
VALUES
('unknown'      	,'Unknown'        , NULL, NULL),
('nonHazardous'     ,'Non Hazardous'  , NULL, NULL),
('attention'      	,'Attention'      , NULL, NULL),
('hazardous'      	,'Hazardous'      , NULL, NULL)
;

INSERT INTO citydb.unom5_lu_optical_mode
(id, name, name_codespace, description)
VALUES
('unknown'      ,'Unknown'        , NULL, NULL),
('singleMode'   ,'Single Mode'    , NULL, NULL),
('multiMode'    ,'Multi Mode'     , NULL, NULL)
;


--**********************
-- 04) Network Components

INSERT INTO citydb.unom5_lu_function_of_line
(id, name, name_codespace, description)
VALUES
('unknown'      	,'Unknown'         , NULL, NULL),
('coolingLine'      ,'Cooling Line'    , NULL, NULL),
('constantLine'     ,'Constant Line'   , NULL, NULL),
('flowLine'      	,'Flow Line'       , NULL, NULL),
('returnLine'      	,'Return Line'     , NULL, NULL),
('steamLine'      	,'Steam Line'      , NULL, NULL),
('condensateLine'   ,'Condensate Line' , NULL, NULL)
;

INSERT INTO citydb.unom5_lu_pipe_type
(objectclass_id, id, name, name_codespace, description)
VALUES
-- Oil, gas and chemicals pipe
(1105, 'unknown'          ,'Unknown'             , NULL, NULL),
(1105, 'distributionPipe' ,'Distribution Pipe'   , NULL, NULL),
(1105, 'pressuredPipe'    ,'Pressured Pipe'      , NULL, NULL),
(1105, 'other'         	  ,'Other'               , NULL, NULL),
-- Water pipe
(1106, 'unknown'          ,'Unknown'             , NULL, NULL),
(1106, 'distributionPipe' ,'Distribution Pipe'   , NULL, NULL),
(1106, 'pressuredPipe'    ,'Pressured Pipe'      , NULL, NULL),
(1106, 'other'         	  ,'Other'               , NULL, NULL),
-- Thermal pipe
(1107, 'unknown'          ,'Unknown'             , NULL, NULL),
(1107, 'distributionPipe' ,'Distribution Pipe'   , NULL, NULL),
(1107, 'pressuredPipe'    ,'Pressured Pipe'      , NULL, NULL),
(1107, 'other'        	  ,'Other'               , NULL, NULL),
-- Sewer pipe
(1108, 'unknown'         	,'Unknown'           , NULL, NULL),
(1108, 'distributionPipe'   ,'distributionPipe'  , NULL, NULL),
(1108, 'openChannelPipe'    ,'openChannelPipe'   , NULL, NULL),
(1108, 'vacuumPipe'         ,'vacuumPipe'        , NULL, NULL),
(1108, 'pressuredPipe'      ,'pressuredPipe'     , NULL, NULL),
(1108, 'other'         		,'other'             , NULL, NULL)
;

INSERT INTO citydb.unom5_lu_cable_type
(objectclass_id, id, name, name_codespace, description)
VALUES
-- Electricity cable
(1102, 'unknown'      	    ,'Unknown'              , NULL, NULL),
(1102, 'beltedCable'        ,'Belted Cable'         , NULL, NULL),
(1102, 'H_typeCable'        ,'H Type Cable'         , NULL, NULL),
(1102, 'SL_typeCable'       ,'SL Type Cable'        , NULL, NULL),
(1102, 'oilFilledCable'     ,'Oil Filled Cable'     , NULL, NULL),
(1102, 'gasPressuredCable'  ,'Gas Pressured Cable'  , NULL, NULL),
(1102, 'other'          	,'Other'             	, NULL, NULL),
-- Telecommunications cable
(1103, 'unknown'          		,'Unknown'             		, NULL, NULL),
(1103, 'coaxial'          		,'Coaxial'             		, NULL, NULL),
(1103, 'unshieldedTwistedPair'  ,'Unshielded Twisted Pair'  , NULL, NULL),
(1103, 'shieldedTwistedPair'    ,'Shielded Twisted Pair'    , NULL, NULL),
(1103, 'opticalFiber'           ,'Optical Fiber'            , NULL, NULL),
(1103, 'other'          		,'Other'             		, NULL, NULL)
;

INSERT INTO citydb.unom5_lu_network_feature_class
(objectclass_id, id, name, name_codespace, description)
VALUES
/*
THE REPETITION IN THE NEXT LINES -CONCERNING LINE VALUE OF PIPES AND CABLES- IS NOT ELEGANT, 
BUT I DON'T KNOW HOW TO WORK WITH INHERITANCE IN ANOTHER WAY. I CAN'T SIMPLY USE THE 
OBJECTCLASS_ID OF 'ABSTRACT DISTRIBUTION ELEMENT', SINCE IT WILL NOT BE USED IN THE ACTUAL TABLES. 
THEREFORE, I CAN ONLY USE THE OBJECTCLASS_ID OF NON-ABSTRACT (CONCRETE) NETWORK FEATURES IN THE 
LOOKUP TABLES.
*/
-- Electricity Cable Line Value
(1102, 'unknown'         ,'Unknown'                     , NULL, NULL), 
(1102, 'mainLine'        ,'Main line'                   , NULL, NULL),
(1102, 'transportLine'   ,'Transport line'              , NULL, NULL),
(1102, 'supplyLine'      ,'Supply line'                 , NULL, NULL),
(1102, 'houseServiceLine','House-service line'          , NULL, NULL),
-- Telecommunications Cable Line Value
(1103, 'unknown'         ,'Unknown'                     , NULL, NULL),
(1103, 'mainLine'        ,'Main line'                   , NULL, NULL),
(1103, 'transportLine'   ,'Transport line'              , NULL, NULL),
(1103, 'supplyLine'      ,'Supply line'                 , NULL, NULL),
(1103, 'houseServiceLine','House-service line'          , NULL, NULL),
-- Oil, gas and chemicals pipe Line Value
(1105, 'unknown'         ,'Unknown'                     , NULL, NULL),
(1105, 'mainLine'        ,'Main line'                   , NULL, NULL),
(1105, 'transportLine'   ,'Transport line'              , NULL, NULL),
(1105, 'supplyLine'      ,'Supply line'                 , NULL, NULL),
(1105, 'houseServiceLine','House-service line'          , NULL, NULL),
-- Water pipe Line Value
(1106, 'unknown'         ,'Unknown'                     , NULL, NULL),
(1106, 'mainLine'        ,'Main line'                   , NULL, NULL),
(1106, 'transportLine'   ,'Transport line'              , NULL, NULL),
(1106, 'supplyLine'      ,'Supply line'                 , NULL, NULL),
(1106, 'houseServiceLine','House-service line'          , NULL, NULL),
-- Thermal pipe Line Value
(1107, 'unknown'         ,'Unknown'                     , NULL, NULL),
(1107, 'mainLine'        ,'Main line'                   , NULL, NULL),
(1107, 'transportLine'   ,'Transport line'              , NULL, NULL),
(1107, 'supplyLine'      ,'Supply line'                 , NULL, NULL),
(1107, 'houseServiceLine','House-service line'          , NULL, NULL),
-- Sewer pipe Line Value
(1108, 'unknown'         ,'Unknown'                     , NULL, NULL),
(1108, 'mainLine'        ,'Main line'                   , NULL, NULL),
(1108, 'transportLine'   ,'Transport line'              , NULL, NULL),
(1108, 'supplyLine'      ,'Supply line'                 , NULL, NULL),
(1108, 'houseServiceLine','House-service line'          , NULL, NULL),
-- What follows here is OK:
-- ComplexFunctionalComponent
(1121, 'unknown'       			,'Unknown'            		, NULL, NULL),
(1121, 'mainStation'    		,'Main Station'       		, NULL, NULL),
(1121, 'netStation'     		,'Net Station'        		, NULL, NULL),
(1121, 'subStation'				,'Sub Station'        		, NULL, NULL),
(1121, 'pumpingStation'			,'Pumping station'    		, NULL, NULL),
(1121, 'samplingStation'    	,'Sampling Station'   		, NULL, NULL),
(1121, 'cabinet'     			,'Cabinet'            		, NULL, NULL),
(1121, 'factory'       			,'Factory'            		, NULL, NULL),
(1121, 'waterWork'     			,'Waterwork'          		, NULL, NULL),
(1121, 'treatmentPlant'			,'Treatment plant'    		, NULL, NULL),
(1121, 'heatingPlant'  			,'Heating plant'      		, NULL, NULL),
(1121, 'powerPlant'    			,'Power plant'        		, NULL, NULL),
(1121, 'transformer'    		,'Transformer'        		, NULL, NULL),
(1121, 'tideGate'    			,'Tide Gate'          		, NULL, NULL),
(1121, 'storageFacility'    	,'Storage Facility'   		, NULL, NULL),
(1121, 'other'   				,'other'              		, NULL, NULL),
-- Simple: ConnectionComponent
(1123, 'unknown'         		,'Unknown'             		, NULL, NULL),
(1123, 'flange'         		,'Flange'              		, NULL, NULL),
(1123, 'coupling'         		,'Coupling'            		, NULL, NULL),
(1123, 'adapter'         		,'Adapter'             		, NULL, NULL),
(1123, 'teeFitting'         	,'Tee Fitting'         		, NULL, NULL),
(1123, 'crossFitting'       	,'Cross Fitting'       		, NULL, NULL),
(1123, 'compressionFitting' 	,'compressionFitting'  		, NULL, NULL),
(1123, 'manhole'         		,'manhole'             		, NULL, NULL),
(1123, 'connectionBox'      	,'connectionBox'       		, NULL, NULL),
(1123, 'spliceCassette'     	,'spliceCassette'      		, NULL, NULL),
(1123, 'patchPanel'         	,'patchPanel'          		, NULL, NULL),
(1123, 'culvert'         		,'culvert'             		, NULL, NULL),
(1123, 'expansionJoint'     	,'expansionJoint'      		, NULL, NULL),
(1123, 'insulationJoint'    	,'insulationJoint'     		, NULL, NULL),
(1123, 'other'         			,'Other'               		, NULL, NULL),
-- Simple: MeasurementComponent
(1124, 'unknown'          		,'Unknown'              	, NULL, NULL),
(1124, 'anode'            		,'Anode'                	, NULL, NULL),
(1124, 'corrosionDetector'		,'Corrosion detector'   	, NULL, NULL),
(1124, 'pressureSensor'   		,'Pressure sensor'      	, NULL, NULL),
(1124, 'meter'            		,'Meter'                	, NULL, NULL),	
(1124, 'scadaSensor'      		,'Scada Sensor'         	, NULL, NULL),	
(1124, 'other'            		,'Other'                	, NULL, NULL),	
-- Simple: StorageComponent
(1125, 'unknown'     			,'Unknown'              	, NULL, NULL),
(1125, 'storageBasin'			,'Storage basin'        	, NULL, NULL),
(1125, 'battery'     			,'Battery'              	, NULL, NULL),
(1125, 'tank'        			,'Tank'                 	, NULL, NULL),
(1125, 'cistern'     			,'Cistern'              	, NULL, NULL),
(1125, 'clearWell'     			,'Clear Well'           	, NULL, NULL),
(1125, 'inLineStoragePipe'  	,'In Line Storage Pipe' 	, NULL, NULL),
(1125, 'other'     				,'Other'                	, NULL, NULL),
-- Simple: TerminalComponent
(1126, 'unknown'    			,'Unknown'                	, NULL, NULL),
(1126, 'lamp'       			,'Lamp'                   	, NULL, NULL),
(1126, 'clock'      			,'Clock'                  	, NULL, NULL),
(1126, 'hydrant'    			,'Hydrant'                	, NULL, NULL),
(1126, 'streetLight'			,'Street Light'           	, NULL, NULL),
(1126, 'trafficLight'			,'Traffic Light'          	, NULL, NULL),
(1126, 'barrier'    			,'Barrier'                	, NULL, NULL),
(1126, 'solarCell'    			,'Solar Cell'             	, NULL, NULL),
(1126, 'advertismColumn'    	,'Advertisment Column'    	, NULL, NULL),
(1126, 'beacon'    				,'Beacon'                 	, NULL, NULL),
(1126, 'waterExhaustPoint'  	,'Water Exhaust Point'    	, NULL, NULL),
(1126, 'waterServicePoint'  	,'Water Service Point'    	, NULL, NULL),
(1126, 'waterDischargePoint'	,'Water Discharge Point'  	, NULL, NULL),
(1126, 'fountain'    			,'Fountain'               	, NULL, NULL),
(1126, 'other'    				,'Other'                  	, NULL, NULL),
-- Simple: ControllerComponent
(1127, 'unknown'         				,'Unknown'                    	 , NULL, NULL),
(1127, 'switch'         				,'Switch'                     	 , NULL, NULL),
(1127, 'valve'         					,'Valve'                    	 , NULL, NULL),
(1127, 'blowOffValve'         			,'Blow Off Valve'                , NULL, NULL),
(1127, 'slideValve'         			,'Slide Valve'                   , NULL, NULL),
(1127, 'shutOffValve'         			,'Shut Off Valve'                , NULL, NULL),
(1127, 'pump'         					,'Pump'                     	 , NULL, NULL),
(1127, 'generator'         				,'Generator'                     , NULL, NULL),
(1127, 'turbine'         				,'Turbine'                     	 , NULL, NULL),
(1127, 'voltageRegulator'         		,'Voltage Regulator'             , NULL, NULL),
(1127, 'pressureRegulator'         		,'Pressure Regulator'            , NULL, NULL),
(1127, 'grounding'         				,'Grounding'                     , NULL, NULL),
(1127, 'tap'         					,'Tap'                     		 , NULL, NULL),
(1127, 'fuse'         					,'Fuse'                     	 , NULL, NULL),
(1127, 'loadTapCharger'         		,'Load Tap Charger'              , NULL, NULL),
(1127, 'capacitorControl'         		,'Capacitor Control'             , NULL, NULL),
(1127, 'recloserElectricControl'     	,'Recloser Electric Control'     , NULL, NULL),
(1127, 'recloserHydraulicControl'       ,'Recloser Hydraulic Control'    , NULL, NULL),
(1127, 'regulatorControl'       	  	,'Regulator Control'             , NULL, NULL),
(1127, 'relayControl'         			,'Relay Control'                 , NULL, NULL),
(1127, 'sectionizerElectricControl'     ,'Sectionizer Electric Control'  , NULL, NULL),
(1127, 'sectionizerHydraulicControl'	,'Sectionizer Hydraulic Control' , NULL, NULL),
(1127, 'flowRegulator'         			,'Flow Regulator'                , NULL, NULL),
(1127, 'surgeReliefTank'         		,'Surge Relief Tank'             , NULL, NULL),
(1127, 'invertedSyphon'         		,'Inverted Syphon'               , NULL, NULL),
(1127, 'overflow'         				,'Overflow'                      , NULL, NULL),
(1127, 'other'         					,'Other'                     	 , NULL, NULL),
-- Simple: OtherComponent
(1128, 'unknown'         	,'Unknown'           , NULL, NULL),
(1128, 'transformerEnd'    	,'Transformer End'   , NULL, NULL),
(1128, 'deliveryPoint'      ,'Delivery Point'    , NULL, NULL),
(1128, 'vent'         		,'Vent'              , NULL, NULL),
(1128, 'endCap'         	,'End Cap'           , NULL, NULL),
(1128, 'other'         		,'Other'             , NULL, NULL),
---- Protective elements. Necessary for fk constrain of network feature: unom5_ntw_feat_class_fk
(1141, 'bedding'            , 'Bedding'				, NULL, NULL),
(1142, 'protectiveShell'   	, 'Protective Shell'  	, NULL, NULL),
(1143, 'rectangularShell'   , 'Rectangular Shell'  	, NULL, NULL),
(1144, 'roundShell'         , 'Round Shell'  		, NULL, NULL),
(1145, 'otherShell'         , 'Other Shell'  		, NULL, NULL)
;


--**********************
-- 05) Component Properties

INSERT INTO citydb.unom5_lu_material
(id, name, name_codespace, description)
VALUES
('unknown'              			,'Unknown'                			, NULL, NULL),
('air'                  			,'Air'                    			, NULL, NULL),
('jute'                				,'Jute'                  			, NULL, NULL),
('paper'                			,'Paper'                  			, NULL, NULL),
('wood'                				,'Wood'                  			, NULL, NULL),
('asbestos'                			,'Asbestos'                  		, NULL, NULL),
('asbestosCement'                	,'Asbestos Cement'                  , NULL, NULL),
('pitchFibre'                		,'Pitch Fibre'                  	, NULL, NULL),
('brick'                			,'Brick'                  			, NULL, NULL),
('concrete'                			,'Concrete'                  		, NULL, NULL),
('compositeConcrete'                ,'Composite Concrete'               , NULL, NULL),
('fiberReinforcedConcrete'          ,'Fiber Reinforced Concrete'        , NULL, NULL),
('permeableConcrete'                ,'Permeable Concrete'               , NULL, NULL),
('prestressedReinforcedConcrete'    ,'Prestressed Reinforced Concrete'  , NULL, NULL),
('reinforcedConcrete'               ,'Reinforced Concrete'              , NULL, NULL),
('sprayedConcrete'                	,'Sprayed Concrete'                 , NULL, NULL),
('reinforcedPolymerMortar'          ,'Reinforced Polymer Mortar'        , NULL, NULL),
('stoneware'                		,'Stoneware'                  		, NULL, NULL),
('clay'                				,'Clay'                  			, NULL, NULL),
('vitrifiedClay'                	,'Vitrified Clay'                  	, NULL, NULL),
('quartzSilica'                		,'Quartz Silica'                  	, NULL, NULL),
('sand'                				,'Sand'                  			, NULL, NULL),
('terracotta'                		,'Terracotta'                  		, NULL, NULL),
('aluminium'                		,'Aluminium'                  		, NULL, NULL),
('brass'                			,'Brass'                  			, NULL, NULL),
('copper'                			,'Copper'                  			, NULL, NULL),
('blackIron'                		,'Black Iron'                  		, NULL, NULL),
('castIron'                			,'Cast Iron'                  		, NULL, NULL),
('ductileCastIron'                	,'Ductile Cast Iron'                , NULL, NULL),
('lead'                				,'Lead'                  			, NULL, NULL),
('steel'                			,'Steel'                  			, NULL, NULL),
('blackSteel'                		,'BlackSteel'                  		, NULL, NULL),
('galvanizedSteel'                	,'Galvanized Steel'                 , NULL, NULL),
('stainlessSteel'               	,'Stainless Steel'                  , NULL, NULL),
('bitumen'                			,'Bitumen'                  		, NULL, NULL),
('carbon'                			,'Carbon'                  			, NULL, NULL),
('polyButylene'                		,'Poly Butylene'                  	, NULL, NULL),
('polyEthylene'                		,'Poly Ethylene'                  	, NULL, NULL),
('polyPropylene'                	,'Poly Propylene'                  	, NULL, NULL),
('polyVinylChloride'                ,'Poly Vinyl Chloride'              , NULL, NULL),
('chlorinatedPolyVinylChloride'     ,'Chlorinated Poly Vinyl Chloride'  , NULL, NULL),
('lowDensityPolyEthylene'           ,'Low Density Poly Ethylene'        , NULL, NULL),
('mediumDensityPolyEthylene'        ,'Medium Density Poly Ethylene'     , NULL, NULL),
('highDensityPolyEthylene'          ,'High Density Poly Ethylene'       , NULL, NULL),
('crossLinkedPolyEthylene'          ,'Cross Linked Poly Ethylene'       , NULL, NULL),
('polyEthyleneRaisedTemperature'	,'Poly Ethylene Raised Temperature' , NULL, NULL),
('fiberReinforcedPlastic'           ,'Fiber Reinforced Plastic'         , NULL, NULL),
('ethyleneVinylAlcohol'             ,'Ethylene Vinyl Alcohol'           , NULL, NULL),
('polymericOpticalFibre'            ,'Polymeric Optical Fibre'          , NULL, NULL),
('acrylonitrileButadieneStyrene'    ,'Acrylonitrile Butadiene Styrene'  , NULL, NULL),
('epoxy'                			,'Epoxy'             				, NULL, NULL),
('paint'             			   	,'Paint'                 			, NULL, NULL),
('hostalite'                		,'Hostalite'             			, NULL, NULL),
('rubber'                			,'Rubber'                			, NULL, NULL),
('other'                			,'Other'                 			, NULL, NULL)
;

INSERT INTO citydb.unom5_lu_party_role
(id, name, name_codespace, description)
VALUES
('unknown'           ,'Unknown'                	, NULL, NULL),
('supplier'          ,'Supplier'                , NULL, NULL),
('owner'             ,'Owner'                	, NULL, NULL),
('operator'          ,'Operator'                , NULL, NULL),
('contractor'        ,'Contractor'              , NULL, NULL),
('manufacturer'      ,'Manufacturer'           	, NULL, NULL),
('other'             ,'Other'                	, NULL, NULL)
;

INSERT INTO citydb.unom5_lu_soil
(id, name, name_codespace, description)
VALUES
('unknown'           ,'Unknown'                	, NULL, NULL),
('sand'              ,'Sand'                	, NULL, NULL),
('peat'              ,'Peat'                	, NULL, NULL),
('seaClay'           ,'Sea Clay'                , NULL, NULL),
('riverClay'         ,'River Clay'             	, NULL, NULL),
('other'             ,'Other'                	, NULL, NULL)
;

INSERT INTO citydb.unom5_lu_shape
(id, name, name_codespace, description)
VALUES
('unknown'           ,'Unknown'                	, NULL, NULL),
('circular'          ,'Circular'               	, NULL, NULL),
('rectangular'       ,'Rectangular'            	, NULL, NULL),
('ellipsoidal'       ,'Ellipsoidal'            	, NULL, NULL),
('trapezoid'         ,'Trapezoid'             	, NULL, NULL),
('irregular'         ,'Irregular'              	, NULL, NULL)
;

INSERT INTO citydb.unom5_lu_groundwater_reference
(id, name, name_codespace, description)
VALUES
('unknown'           ,'Unknown'                	, NULL, NULL),
('groundLevel'       ,'Ground Level'            , NULL, NULL),
('seaLevel'          ,'Sea Level'               , NULL, NULL),
('other'             ,'Other'                	, NULL, NULL)
;

INSERT INTO citydb.unom5_lu_identifier_type
(id, name, name_codespace, description)
VALUES
('unknown'           ,'Unknown'                	, NULL, NULL),
('EAN'               ,'EAN'                		, NULL, NULL),
('CPID'              ,'CPID'                	, NULL, NULL),
('other'             ,'Other'                	, NULL, NULL)
;


--**********************
-- 06) Maintenance and operations Properties

INSERT INTO citydb.unom5_lu_cost_type
(id, name, name_codespace, description)
VALUES
('unknown'           			,'Unknown'                	, NULL, NULL),
('capitalCost'          		,'Capital Cost'             , NULL, NULL),
('rehabilitationCost'   		,'RehabilitationCost'       , NULL, NULL),
('replacementCost'      		,'Replacement Cost'         , NULL, NULL),
('maintenanceCost'      		,'Maintenance Cost'         , NULL, NULL),
('operatingCost'        		,'Operating Cost'           , NULL, NULL),
('other'           				,'Other'                	, NULL, NULL)

;

INSERT INTO citydb.unom5_lu_maintenance_timeline_type
(id, name, name_codespace, description)
VALUES
('unknown'           			,'Unknown'                	, NULL, NULL),
('lastMaintenance'      		,'Last Maintenance'         , NULL, NULL),
('currentMaintenance'   		,'Current Maintenance'      , NULL, NULL),
('plannedMaintenance'   		,'Planned Maintenance'      , NULL, NULL)
;

INSERT INTO citydb.unom5_lu_maintenance_activity_type
(id, name, name_codespace, description)
VALUES
('unknown'           			,'Unknown'                	, NULL, NULL),
('inspection'           		,'Inspection'               , NULL, NULL),
('surveillance'         		,'Surveillance'             , NULL, NULL),
('rehabilitation'       		,'Rehabilitation'           , NULL, NULL),
('replacement'          		,'Replacement'              , NULL, NULL),
('other'           				,'Other'                	, NULL, NULL)
;

INSERT INTO citydb.unom5_lu_maintenance_type
(id, name, name_codespace, description)
VALUES
('unknown'           			,'Unknown'                	, NULL, NULL),
('correctiveMaintenance'        ,'Corrective Maintenance'   , NULL, NULL),
('preventiveMaintenance'        ,'Preventive Maintenance'   , NULL, NULL),
('predictiveMaintenance'        ,'Predictive Maintenance'   , NULL, NULL),
('prescriptiveMaintenance'      ,'Prescriptive Maintenance' , NULL, NULL)
;


--**********************
-- 07) Performance Properties

INSERT INTO citydb.unom5_lu_performance_type
(id, name, name_codespace, description)
VALUES
('unknown'           			,'Unknown'                		, NULL, NULL),
('engineeringPerformance'       ,'Engineering Performance'      , NULL, NULL),
('serviceabilityPerformance'    ,'Serviceability Performance'   , NULL, NULL),
('safetyPerformance'            ,'Safety Performance'           , NULL, NULL),
('financialPerformance'         ,'Financial Performance'        , NULL, NULL),
('sustainabilityPerformance'    ,'Sustainability Performance'   , NULL, NULL)
;

-- ***********************************************************************
-- ***********************************************************************

DO
$$
BEGIN
RAISE NOTICE '

********************************

Utility Network O&M table data installation complete!

********************************

';
END
$$;
SELECT 'Utility Network O&M table data installed correctly!'::varchar AS installation_result;


-- ***********************************************************************
-- ***********************************************************************
--
-- END OF FILE
--
-- ***********************************************************************
-- ***********************************************************************