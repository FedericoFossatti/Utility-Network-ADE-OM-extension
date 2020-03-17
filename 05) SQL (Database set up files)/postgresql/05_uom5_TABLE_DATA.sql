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
-- ***************** 05_uom5_TABLE_DATA.sql *******************
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
-- 		uom5_lu_network_class
-- 		uom5_lu_network_function_and_usage
-- 		uom5_lu_network_feature_function
-- 		uom5_lu_spatial_quality
-- 		uom5_lu_status
-- 		uom5_lu_relative_to_terrain
-- 		uom5_lu_depth_point_of_measurement
-- 		uom5_lu_depth_reference_level
-- 		uom5_lu_depth_accuracy_value
-- 		uom5_lu_location_accuracy_value
-- 		uom5_lu_commodity_supply
-- 		uom5_lu_signal_word
-- 		uom5_lu_optical_mode
-- 		uom5_lu_function_of_line
-- 		uom5_lu_pipe_type
-- 		uom5_lu_cable_type
-- 		uom5_lu_network_feature_class
-- 		uom5_lu_material
-- 		uom5_lu_party_role
-- 		uom5_lu_soil
-- 		uom5_lu_shape
-- 		uom5_lu_groundwater_reference
-- 		uom5_lu_identifier_type
-- 		uom5_lu_cost_type
-- 		uom5_lu_maintenance_timeline_type
-- 		uom5_lu_maintenance_activity_type
-- 		uom5_lu_maintenance_type
-- 		uom5_lu_performance_type
-- ***************************************************************************


-- Add entry into table ADE
DELETE FROM citydb.ade WHERE db_prefix='uom5'; 
INSERT INTO citydb.ade (name, description, version, db_prefix)
VALUES
('UtilityNetworks Operation & Maintenance ADE', 'UtilityNetworks Operation & Maintenance Application Domain Extension v. 0.5.8', '0.5.8', 'uom5');

-- Add entry into table SCHEMA
WITH a AS (SELECT id FROM citydb.ade WHERE db_prefix='uom5')
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
(1000,    3, 3, 1, 'Network'                      	, 'uom5_network'             	),
(1001,    3, 3, 1, 'AbstractNetworkFeature'       	, 'uom5_network_feature'     	),
(1002,    2, 2, 1, 'NetworkGraph'                 	, 'uom5_network_graph'       	),
(1003,    2, 2, 1, 'FeatureGraph'                 	, 'uom5_feature_graph'       	),
(1004,    2, 2, 1, 'Node'                         	, 'uom5_node'                	),
(1005,    2, 2, 1, 'AbstractLink'                 	, 'uom5_link'                	),
(1006, 1005, 2, 1, 'InteriorFeatureLink'          	, 'uom5_link'                	),
(1007, 1005, 2, 1, 'InterFeatureLink'             	, 'uom5_link'                	),
(1008, 1005, 2, 1, 'NetworkLink'                  	, 'uom5_link'                	),

-- 02) Functional characteristics                                                                        
(1020,   23, 3, 1, 'SupplyArea'                   	, 'cityobjectgroup'           	),	-- like CityObjectGroup
(1021,    2, 2, 1, 'RoleInNetwork'                	, 'uom5_role_in_network'     	),
(1022,    3, 3, 1, 'AbstractCityObject'           	, 'uom5_city_object'		 	),	-- No longer necessary.
(1023,   26, 3, 1, 'AbstractBuilding'             	, 'uom5_building'     		 	),	-- New. 
---- commodity supply
(1040,    1, 1, 1, 'AbstractCommoditySupply'      	, 'uom5_commodity_supply'      ),
(1041, 1040, 1, 1, 'LiquidCommoditySupply'        	, 'uom5_commodity_supply'      ),
(1042, 1040, 1, 1, 'GaseousCommoditySupply'       	, 'uom5_commodity_supply'      ),
(1043, 1040, 1, 1, 'SolidCommoditySupply'         	, 'uom5_commodity_supply'      ),
(1044, 1040, 1, 1, 'ElectricalCommoditySupply'    	, 'uom5_commodity_supply'      ),
(1045, 1040, 1, 1, 'OpticalCommoditySupply'       	, 'uom5_commodity_supply'      ),

-- 03) Network properties
---- commodity
(1060,    2, 2, 1, 'AbstractCommodity'            	, 'uom5_commodity'           	),
(1061, 1060, 2, 1, 'LiquidCommodity'              	, 'uom5_commodity'           	),
(1062, 1060, 2, 1, 'GaseousCommodity'             	, 'uom5_commodity'           	),
(1063, 1060, 2, 1, 'SolidCommodity'               	, 'uom5_commodity'           	),
(1064, 1060, 2, 1, 'ElectricalCommodity'          	, 'uom5_commodity'           	),
(1065, 1060, 2, 1, 'OpticalCommodity'             	, 'uom5_commodity'           	),
---- commodity classifier
(1080,    2, 2, 1, 'AbstractCommodityClassifier'  	, 'uom5_commodity_classifier'	),
(1081, 1080, 2, 1, 'ChemicalClassifier'           	, 'uom5_commodity_classifier'	),
(1082, 1080, 2, 1, 'GHSClassifier'                	, 'uom5_commodity_classifier'	),
(1083, 1080, 2, 1, 'GenericClassifier'            	, 'uom5_commodity_classifier'	),

-- 04) Network Components
---- distribution
(1100, 1001, 3, 1, 'AbstractDistributionComponent'  , '-'    						),	-- Newish. IT IS NOT IN ANY TABLE.
(1101, 1100, 3, 1, 'AbstractCable'   				, 'uom5_cable'    				),	-- Newish.
(1102, 1101, 3, 1, 'ElectricityCable'  				, 'uom5_cable'     			),	-- Newish.
(1103, 1101, 3, 1, 'TelecommunicationCable'   		, 'uom5_cable'     			),	-- Newish.
(1104, 1100, 3, 1, 'AbstractPipe'   			   	, 'uom5_pipe'     				),	-- Newish.
(1105, 1104, 3, 1, 'OilGasChemicalsPipe'   			, 'uom5_pipe'     				),	-- Newish.
(1106, 1104, 3, 1, 'WaterPipe'   			   		, 'uom5_pipe'     				),	-- Newish.
(1107, 1104, 3, 1, 'ThermalPipe'   			   		, 'uom5_pipe'     				),	-- Newish.
(1108, 1104, 3, 1, 'SewerPipe'   			   		, 'uom5_pipe'     				),	-- Newish.
---- functional
(1120, 1001, 3, 1, 'AbstractFunctionalComponent'   	, 'uom5_functional_component'  ),	-- Newish.
(1121, 1120, 3, 1, 'ComplexFunctionalComponent'   	, 'uom5_functional_component'  ),	-- Newish.
(1122, 1120, 3, 1, 'SimpleFunctionalComponent'   	, 'uom5_functional_component'  ),	-- Newish.
(1123, 1122, 3, 1, 'ConnectionComponent'   			, 'uom5_functional_component'  ),	-- Newish.
(1124, 1122, 3, 1, 'MeasurementComponent'   		, 'uom5_functional_component'  ),	-- Newish.
(1125, 1122, 3, 1, 'StorageComponent'   			, 'uom5_functional_component'  ),	-- Newish.
(1126, 1122, 3, 1, 'TerminalComponent'   			, 'uom5_functional_component'  ),	-- Newish.
(1127, 1122, 3, 1, 'ControllerComponent'   			, 'uom5_functional_component'  ),	-- Newish.
(1128, 1122, 3, 1, 'OtherComponent'   				, 'uom5_functional_component'  ),	-- Newish.
---- protective
(1140, 1001, 3, 1, 'AbstractProtectiveComponent'    , 'uom5_protective_element'  	),
(1141, 1140, 3, 1, 'Bedding'                       	, 'uom5_protective_element'  	),
(1142, 1140, 3, 1, 'ProtectiveShell'       			, 'uom5_protective_element'  	),
(1143, 1142, 3, 1, 'RectangularShell'              	, 'uom5_protective_element'  	),
(1144, 1142, 3, 1, 'RoundShell'                    	, 'uom5_protective_element'  	),
(1145, 1142, 3, 1, 'OtherShell'                    	, 'uom5_protective_element'  	),

-- 05) Component Properties
---- material & related party
(1160,    2, 2, 1, 'AbstractMaterialProperties'     , 'uom5_material'            	),
(1161, 1160, 2, 1, 'InteriorMaterial'              	, 'uom5_material'            	),
(1162, 1160, 2, 1, 'ExteriorMaterial'              	, 'uom5_material'            	),
(1163, 1160, 2, 1, 'FillingMaterial'               	, 'uom5_material'            	),
(1164,    2, 2, 1, 'RelatedParty'     				, 'uom5_related_party'         ),	-- New

-- 06) Maintenance and Operations Properties
(1180,    2, 2, 1, 'MaintenanceActivity'     		, 'uom5_maintenance_activity'  ),	-- New

-- 07) Performance Properties
(1200,    2, 2, 1, 'Impact'     					, 'uom5_impact'  				),	-- New
(1201,    2, 2, 1, 'Performance'     				, 'uom5_performance'  			)	-- New

---- 08) Hollow Space
--(1220,    2, 2, 1, 'AbstractHollowSpace'            , 'uom5_hollow_space'        ),
--(1221, 1220, 2, 1, 'HollowSpace'                   	, 'uom5_hollow_space'        ),
--(1222, 1220, 2, 1, 'HollowSpacePart'               	, 'uom5_hollow_space'        )
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
INSERT INTO citydb.uom5_lu_EN_network_class
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

INSERT INTO citydb.uom5_lu_EN_network_function_and_usage
(id, name, name_codespace, description)
VALUES
('unknown'      ,'Unknown'      , NULL, NULL),
('supply'       ,'Supply'       , NULL, NULL),
('disposal'     ,'Disposal'     , NULL, NULL),
('communication','Communication', NULL, NULL)
;

INSERT INTO citydb.uom5_lu_CL_network_feature_function
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

INSERT INTO citydb.uom5_lu_EN_spatial_quality
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

INSERT INTO citydb.uom5_lu_EN_status
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


INSERT INTO citydb.uom5_lu_CL_depth_point_of_measurement
(id, name, name_codespace, description)
VALUES
('unknown'      	,'Unknown'          , NULL, NULL),
('top'      		,'Top'         		, NULL, NULL),
('center'      		,'Center'        	, NULL, NULL),
('bottom'      		,'Bottom'      		, NULL, NULL),
('other'      		,'Other'       		, NULL, NULL)
;

INSERT INTO citydb.uom5_lu_CL_depth_reference_level
(id, name, name_codespace, description)
VALUES
('unknown'      	,'Unknown'          , NULL, NULL),
('groundLevel'      ,'Ground Level'     , NULL, NULL),
('seaLevel'      	,'Sea Level'        , NULL, NULL),
('other'      		,'Other'          	, NULL, NULL)
;

INSERT INTO citydb.uom5_lu_CL_depth_accuracy_value
(id, name, name_codespace, description)
VALUES
('unknown'      ,'Unknown'        , NULL, NULL),
('30cm'      	,'30 cm'          , NULL, NULL),
('50cm'      	,'50 cm'          , NULL, NULL),
('100cm'      	,'100 cm'         , NULL, NULL)
;

INSERT INTO citydb.uom5_lu_CL_location_accuracy_value
(id, name, name_codespace, description)
VALUES
('unknown'      ,'Unknown'        , NULL, NULL),
('30cm'      	,'30 cm'          , NULL, NULL),
('50cm'      	,'50 cm'          , NULL, NULL),
('100cm'      	,'100 cm'         , NULL, NULL)
;


--**********************
-- 02) Functional Characteristics

INSERT INTO citydb.uom5_lu_EN_commodity
(id, name, name_codespace, description)
VALUES
-- General
('unknown'             		,'Unknown'                   , NULL, NULL),
('other'             		,'Other'                     , NULL, NULL),
-- Liquid Commodity
('potableWater'            	,'Potable Water'             , NULL, NULL),
('rawWater'             	,'Raw Water'                 , NULL, NULL),
('stormWater'             	,'Storm Water'               , NULL, NULL),
('sanitaryWater'           	,'Sanitary Water'            , NULL, NULL),
('wasteWater'             	,'Waste Water'               , NULL, NULL),
('combinedWater'           	,'Combined Water'            , NULL, NULL),
('reclaimedWater'          	,'Reclaimed Water'           , NULL, NULL),
('districtHeatingWater'    	,'District Heating Water'    , NULL, NULL),
('saltWater'             	,'Salt Water'                , NULL, NULL),
('gasoline'             	,'Gasoline'                  , NULL, NULL),
('oil'             			,'Oil'                       , NULL, NULL),
('gasohol'             		,'Gasohol'                   , NULL, NULL),
('acid'             		,'Acid'                      , NULL, NULL),
('kerosine'             	,'Kerosine'                  , NULL, NULL),
('liquefiedNaturalGas'     	,'Liquefied Natural Gas'     , NULL, NULL),
('liquefiedPetroleumGas'   	,'Liquefied Petroleum Gas'   , NULL, NULL),
('acetone'             		,'Acetone'                   , NULL, NULL),
('crude'            		,'Crude'                     , NULL, NULL),
('dichloroethane'          	,'Dichloroethane'            , NULL, NULL),
('gasoil'             		,'Gasoil'                 	 , NULL, NULL),
('liquidAmmonia'           	,'Liquid Ammonia'            , NULL, NULL),
('liquidHydrocarbon'       	,'Liquid Hydrocarbon'        , NULL, NULL),
('tetrachloroethane'       	,'Tetrachloroethane'         , NULL, NULL),
-- Gaseous Commodity
('naturalGas'  						,'Natural gas'                          , NULL, NULL),
('petroleumGas'						,'Petroleum gas'                        , NULL, NULL),
('helium'      						,'Helium'                               , NULL, NULL),
('air'         						,'Air'                                  , NULL, NULL),
('dioxygen'    						,'Dioxygen'                             , NULL, NULL),
('nitrogen'    						,'Nitrogen'                             , NULL, NULL),
('naturalGasAndTetrahydrothiophene' ,'Natural Gas And Tetrahydrothiophene'  , NULL, NULL),
('hydrogen'    						,'Hydrogen'                             , NULL, NULL),
('carbon'      						,'Carbon'                               , NULL, NULL),
('methane'      					,'Methane'                              , NULL, NULL),
('residualGas'      				,'Residual Gas'                         , NULL, NULL),
('argon'      						,'Argon'                           	    , NULL, NULL),
('butadiene'      					,'Butadiene'                            , NULL, NULL),
('butadiene1,3'      				,'Butadiene 1,3'                        , NULL, NULL),
('butane'      						,'Butane'                               , NULL, NULL),
('propane'      					,'Propane'                              , NULL, NULL),
('compressedAir'      				,'Compressed Air'                       , NULL, NULL),
('ethylene'      					,'Ethylene'                             , NULL, NULL),
('isobutane'      					,'Isobutane'                            , NULL, NULL),
('vinylChloride'      				,'Vinyl Chloride'                       , NULL, NULL),
('oxygen'      						,'Oxygen'                               , NULL, NULL),
('propylene'      					,'Propylene'               	            , NULL, NULL),
-- Solid Commodity
('carbonDust'						,'Carbon dust' 						, NULL, NULL),
('stone'     						,'Stone'       						, NULL, NULL),
('ore'       						,'Ore'         						, NULL, NULL),
('sand'      						,'Sand'        						, NULL, NULL),
('phenol'    						,'Phenol'      						, NULL, NULL),
-- Electrical Commodity
('directCurrent'                	,'Direct current'                  , NULL, NULL),
('singlePhaseAlternatingCurrent'	,'Single-phase alternating current', NULL, NULL),
('threePhaseAlternatingCurrent' 	,'Three-phase alternating current' , NULL, NULL),
('undulatoryCurrent'            	,'Undulatory current'              , NULL, NULL),
('telephone'                    	,'Telephone'                       , NULL, NULL),
('data'                    	 		,'Data'                       	   , NULL, NULL),
-- Optical Commodity
('light'  							,'Light'        				   , NULL, NULL)
;


--**********************
-- 03) Network Properties

INSERT INTO citydb.uom5_lu_EN_signal_word
(id, name, name_codespace, description)
VALUES
('unknown'      	,'Unknown'        , NULL, NULL),
('nonHazardous'     ,'Non Hazardous'  , NULL, NULL),
('attention'      	,'Attention'      , NULL, NULL),
('hazardous'      	,'Hazardous'      , NULL, NULL)
;

INSERT INTO citydb.uom5_lu_EN_optical_mode
(id, name, name_codespace, description)
VALUES
('unknown'      ,'Unknown'        , NULL, NULL),
('singleMode'   ,'Single Mode'    , NULL, NULL),
('multiMode'    ,'Multi Mode'     , NULL, NULL)
;


--**********************
-- 04) Network Components

INSERT INTO citydb.uom5_lu_CL_function_of_line
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

INSERT INTO citydb.uom5_lu_CL_sewer_pipe_type
(id, name, name_codespace, description)
VALUES
-- Sewer pipe
('unknown'         		,'Unknown'           , NULL, NULL),
('distributionPipe'   	,'distributionPipe'  , NULL, NULL),
('openChannelPipe'    	,'openChannelPipe'   , NULL, NULL),
('vacuumPipe'         	,'vacuumPipe'        , NULL, NULL),
('pressuredPipe'      	,'pressuredPipe'     , NULL, NULL),
('other'         		,'other'             , NULL, NULL)
;

INSERT INTO citydb.uom5_lu_CL_cable_type
(id, name, name_codespace, description)
VALUES
-- General
('unknown'      	    ,'Unknown'              , NULL, NULL),
('other'          		,'Other'             	, NULL, NULL),
-- Electricity cable
('beltedCable'        	,'Belted Cable'         , NULL, NULL),
('H_typeCable'        	,'H Type Cable'         , NULL, NULL),
('SL_typeCable'       	,'SL Type Cable'        , NULL, NULL),
('oilFilledCable'     	,'Oil Filled Cable'     , NULL, NULL),
('gasPressuredCable'  	,'Gas Pressured Cable'  , NULL, NULL),
-- Telecommunications cable
('coaxial'          	  ,'Coaxial'             	  , NULL, NULL),
('unshieldedTwistedPair'  ,'Unshielded Twisted Pair'  , NULL, NULL),
('shieldedTwistedPair'    ,'Shielded Twisted Pair'    , NULL, NULL),
('opticalFiber'           ,'Optical Fiber'            , NULL, NULL)
;


INSERT INTO citydb.uom5_lu_CL_line_value
(id, name, name_codespace, description)
VALUES
('unknown'         ,'Unknown'                     , NULL, NULL), 
('mainLine'        ,'Main line'                   , NULL, NULL),
('transportLine'   ,'Transport line'              , NULL, NULL),
('supplyLine'      ,'Supply line'                 , NULL, NULL),
('houseServiceLine','House-service line'          , NULL, NULL)
;

INSERT INTO citydb.uom5_lu_CL_functional_component
(id, name, name_codespace, description)
VALUES
-- General
('unknown'       		,'Unknown'            		, NULL, NULL),
('other'   				,'other'              		, NULL, NULL),
-- ComplexFunctionalComponent
('mainStation'    		,'Main Station'       		, NULL, NULL),
('netStation'     		,'Net Station'        		, NULL, NULL),
('subStation'			,'Sub Station'        		, NULL, NULL),
('pumpingStation'		,'Pumping station'    		, NULL, NULL),
('samplingStation'    	,'Sampling Station'   		, NULL, NULL),
('cabinet'     			,'Cabinet'            		, NULL, NULL),
('factory'       		,'Factory'            		, NULL, NULL),
('waterWork'     		,'Waterwork'          		, NULL, NULL),
('treatmentPlant'		,'Treatment plant'    		, NULL, NULL),
('heatingPlant'  		,'Heating plant'      		, NULL, NULL),
('powerPlant'    		,'Power plant'        		, NULL, NULL),
('transformer'    		,'Transformer'        		, NULL, NULL),
('tideGate'    			,'Tide Gate'          		, NULL, NULL),
('storageFacility'    	,'Storage Facility'   		, NULL, NULL),
-- Simple: ConnectionComponent
('flange'         		,'Flange'              		, NULL, NULL),
('coupling'         	,'Coupling'            		, NULL, NULL),
('adapter'         		,'Adapter'             		, NULL, NULL),
('teeFitting'         	,'Tee Fitting'         		, NULL, NULL),
('crossFitting'       	,'Cross Fitting'       		, NULL, NULL),
('compressionFitting' 	,'compressionFitting'  		, NULL, NULL),
('manhole'         		,'manhole'             		, NULL, NULL),
('connectionBox'      	,'connectionBox'       		, NULL, NULL),
('spliceCassette'     	,'spliceCassette'      		, NULL, NULL),
('patchPanel'         	,'patchPanel'          		, NULL, NULL),
('culvert'         		,'culvert'             		, NULL, NULL),
('expansionJoint'     	,'expansionJoint'      		, NULL, NULL),
('insulationJoint'    	,'insulationJoint'     		, NULL, NULL),
-- Simple: MeasurementComponent
('anode'            	,'Anode'                	, NULL, NULL),
('corrosionDetector'	,'Corrosion detector'   	, NULL, NULL),
('pressureSensor'   	,'Pressure sensor'      	, NULL, NULL),
('meter'            	,'Meter'                	, NULL, NULL),	
('scadaSensor'      	,'Scada Sensor'         	, NULL, NULL),	
-- Simple: StorageComponent
('storageBasin'			,'Storage basin'        	, NULL, NULL),
('battery'     			,'Battery'              	, NULL, NULL),
('tank'        			,'Tank'                 	, NULL, NULL),
('cistern'     			,'Cistern'              	, NULL, NULL),
('clearWell'     		,'Clear Well'           	, NULL, NULL),
('inLineStoragePipe'  	,'In Line Storage Pipe' 	, NULL, NULL),
-- Simple: TerminalComponent
('lamp'       			,'Lamp'                   	, NULL, NULL),
('clock'      			,'Clock'                  	, NULL, NULL),
('hydrant'    			,'Hydrant'                	, NULL, NULL),
('streetLight'			,'Street Light'           	, NULL, NULL),
('trafficLight'			,'Traffic Light'          	, NULL, NULL),
('barrier'    			,'Barrier'                	, NULL, NULL),
('solarCell'    		,'Solar Cell'             	, NULL, NULL),
('advertismColumn'    	,'Advertisment Column'    	, NULL, NULL),
('beacon'    			,'Beacon'                 	, NULL, NULL),
('waterExhaustPoint'  	,'Water Exhaust Point'    	, NULL, NULL),
('waterServicePoint'  	,'Water Service Point'    	, NULL, NULL),
('waterDischargePoint'	,'Water Discharge Point'  	, NULL, NULL),
('fountain'    			,'Fountain'               	, NULL, NULL),
-- Simple: ControllerComponent
('switch'         				,'Switch'                     	 , NULL, NULL),
('valve'         				,'Valve'                    	 , NULL, NULL),
('blowOffValve'         		,'Blow Off Valve'                , NULL, NULL),
('slideValve'         			,'Slide Valve'                   , NULL, NULL),
('shutOffValve'         		,'Shut Off Valve'                , NULL, NULL),
('pump'         				,'Pump'                     	 , NULL, NULL),
('generator'         			,'Generator'                     , NULL, NULL),
('turbine'         				,'Turbine'                     	 , NULL, NULL),
('voltageRegulator'         	,'Voltage Regulator'             , NULL, NULL),
('pressureRegulator'         	,'Pressure Regulator'            , NULL, NULL),
('grounding'         			,'Grounding'                     , NULL, NULL),
('tap'         					,'Tap'                     		 , NULL, NULL),
('fuse'         				,'Fuse'                     	 , NULL, NULL),
('loadTapCharger'         		,'Load Tap Charger'              , NULL, NULL),
('capacitorControl'         	,'Capacitor Control'             , NULL, NULL),
('recloserElectricControl'     	,'Recloser Electric Control'     , NULL, NULL),
('recloserHydraulicControl'     ,'Recloser Hydraulic Control'    , NULL, NULL),
('regulatorControl'       	  	,'Regulator Control'             , NULL, NULL),
('relayControl'         		,'Relay Control'                 , NULL, NULL),
('sectionizerElectricControl'   ,'Sectionizer Electric Control'  , NULL, NULL),
('sectionizerHydraulicControl'	,'Sectionizer Hydraulic Control' , NULL, NULL),
('flowRegulator'         		,'Flow Regulator'                , NULL, NULL),
('surgeReliefTank'         		,'Surge Relief Tank'             , NULL, NULL),
('invertedSyphon'         		,'Inverted Syphon'               , NULL, NULL),
('overflow'         			,'Overflow'                      , NULL, NULL),
-- Simple: OtherComponent
('transformerEnd'    	,'Transformer End'   , NULL, NULL),
('deliveryPoint'     	,'Delivery Point'    , NULL, NULL),
('vent'         		,'Vent'              , NULL, NULL),
('endCap'         		,'End Cap'           , NULL, NULL)
;


--**********************
-- 05) Component Properties

INSERT INTO citydb.uom5_lu_CL_material
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

INSERT INTO citydb.uom5_lu_EN_party_role
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

INSERT INTO citydb.uom5_lu_CL_soil
(id, name, name_codespace, description)
VALUES
('unknown'           ,'Unknown'                	, NULL, NULL),
('sand'              ,'Sand'                	, NULL, NULL),
('peat'              ,'Peat'                	, NULL, NULL),
('seaClay'           ,'Sea Clay'                , NULL, NULL),
('riverClay'         ,'River Clay'             	, NULL, NULL),
('other'             ,'Other'                	, NULL, NULL)
;

INSERT INTO citydb.uom5_lu_EN_shape
(id, name, name_codespace, description)
VALUES
('unknown'           ,'Unknown'                	, NULL, NULL),
('circular'          ,'Circular'               	, NULL, NULL),
('rectangular'       ,'Rectangular'            	, NULL, NULL),
('ellipsoidal'       ,'Ellipsoidal'            	, NULL, NULL),
('trapezoid'         ,'Trapezoid'             	, NULL, NULL),
('irregular'         ,'Irregular'              	, NULL, NULL)
;

INSERT INTO citydb.uom5_lu_CL_groundwater_reference
(id, name, name_codespace, description)
VALUES
('unknown'           ,'Unknown'                	, NULL, NULL),
('groundLevel'       ,'Ground Level'            , NULL, NULL),
('seaLevel'          ,'Sea Level'               , NULL, NULL),
('other'             ,'Other'                	, NULL, NULL)
;

INSERT INTO citydb.uom5_lu_CL_identifier_type
(id, name, name_codespace, description)
VALUES
('unknown'           ,'Unknown'                	, NULL, NULL),
('EAN'               ,'EAN'                		, NULL, NULL),
('CPID'              ,'CPID'                	, NULL, NULL),
('other'             ,'Other'                	, NULL, NULL)
;


--**********************
-- 06) Maintenance and operations Properties

INSERT INTO citydb.uom5_lu_CL_cost_type
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

INSERT INTO citydb.uom5_lu_EN_maintenance_timeline_type
(id, name, name_codespace, description)
VALUES
('unknown'           			,'Unknown'                	, NULL, NULL),
('lastMaintenance'      		,'Last Maintenance'         , NULL, NULL),
('currentMaintenance'   		,'Current Maintenance'      , NULL, NULL),
('plannedMaintenance'   		,'Planned Maintenance'      , NULL, NULL)
;

INSERT INTO citydb.uom5_lu_CL_maintenance_activity_type
(id, name, name_codespace, description)
VALUES
('unknown'           			,'Unknown'                	, NULL, NULL),
('inspection'           		,'Inspection'               , NULL, NULL),
('surveillance'         		,'Surveillance'             , NULL, NULL),
('rehabilitation'       		,'Rehabilitation'           , NULL, NULL),
('replacement'          		,'Replacement'              , NULL, NULL),
('other'           				,'Other'                	, NULL, NULL)
;

INSERT INTO citydb.uom5_lu_EN_maintenance_type
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

INSERT INTO citydb.uom5_lu_EN_performance_type
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