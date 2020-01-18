# CityGML - UtilityNetwork ADE - Operation and Maintenance extension
Master's thesis project at the University of Twente. Implementation and validation of the O&M extension of Utility Network ADE

## Background
The Operation & Maintenance Extension of UtilityNetwork ADE (an extension of CityGML) was developed by Ramon ter Huurne to expand the original data model to cover concepts in the domain of O&M.


## Resources & Related Work
- [Tatjana Kutzner - UtilityNetwork ADE](https://github.com/TatjanaKutzner/CityGML-UtilityNetwork-ADE#citygml-utilitynetwork-ade)
- [Ramon ter Huurne - PDEng Project - O&M Conceptual Schema](https://github.com/RamonTerHuurne/UtilityNetwork-OperationsAndMaintenance)
- [3D City DB - The database implementation of CityGML](https://www.3dcitydb.org/3dcitydb/)
- [Giorgio Agugiaro - Database Implementation of UN ADE 0.9.2](https://github.com/gioagu/3dcitydb_utility_network_ade)
- [Giorgio Agugiaro - 3DCityDB metadata module](https://github.com/gioagu/3dcitydb_metadata_module)
- [Xander den Duijn - Master's Project](https://github.com/XanderdenDuijn/CityGML-Utility-Network-ADE)
- [Isaac Boates - Master's Project](https://github.com/iboates/UtilityNetwork-ADE-3DCityDB-Manager)


## Contents of the repository
This repository contains the following folders:
1. Raw data - Contains the utility network used for the validation of the data model
2. UML - Contains the Universal Markup Language diagram of the data model
3. ShapeChange - Contains the configuration file for deriving the .XSD schema from the UML diagrams
4. XSD - Contains the .XSD derived from UML using ShapeChange 
5. Database - Contains the database encoding of the UML data model
6. FME - Contains workspaces for manipulating spatial data
7. Python - Contains routines to interact between Excel and the databse implementation in PostgreSQL


## Quickstart guide

The folders in the respository are numbered in approximate chronological order related to when they need to be used in the workflow.
The complete workflow presented here is for:  
A) Deriving from the data model the XSD file necessary for the data transformation with FME.  
B) Setting up a spatial-relational database compliant with the O&M schema, on top of the database encoding of CityGML (3D City DB).  
C) Transforming the raw data (a utility network in XX format) to (a) become topologically correct and (b) comply with the O&M data model. Also loading this data into the spatial-relational database
D) Loading 'dummy' attributes to the spatial-spatial relational database using Python. Dummy attributes are used to compensate for the sparce attribute information contianed in the raw data.  

### A) Conceptual schema / Data model (Sparx Systems Enterprise Architect)
This step is optional: the O&M conceptual schema is ready, the ShapeChange configuration file too, and the .XSD schema file has already been derived.  
1. Open UML model and alter classes / codelists / relations
2. Add changes to ShapeChange configuration file (if any)
3. Downlaod and use [ShapeChange](https://shapechange.net/get-started/)  

A new .XSD schema has been derived. The schema is one of the inputs for the transformation in part C).


### B) O&M Database setup (PostgreSQL + PostGIS)
This step is mandatory.  
1. Download and install PostgreSQL
2. Download and install PostGIS
3. Set up new database in PostgreSQL. Open query tool in new database and excecute:  
     3.1. CREATE EXTENSION postgis;  
     3.2. CREATE EXTENSION postgis_raster;  
     3.3. CREATE EXTENSION IF NOT EXISTS "uuid-ossp";  
4. [Download 3D City DB v3.3.1](https://www.3dcitydb.org/3dcitydb/d3ddatabase/). Read installation guide of 3D City DB.  
     4.1. Edit the .BAT file: 'CREATE_DB.bat', located at C:\Program Files\3DCityDB-Importer-Exporter\V3.3\3dcitydb\postgresql and specify Host, Port, User, Password, Database and Bin.  
     4.2. Run .BAT and when prompter enter the SRID and SRS name associated to the spatial data that will be input. 3D City DB installed.   
5. [Download 3D City DB metadata module](https://github.com/gioagu/3dcitydb_metadata_module).  
     5.1. Edit the .BAT file: 'CREATE_DB_Metadata_module.bat', located at download directory and specify Host, Port, User, Password, Database and Bin.  
     5.2. Run bat file. Metadata module installed.  
6. Download O&M database configuration files, located in folder "05) Database" of this repository. Excecute the files in sequential order from PostgreSQL, using the query tool.

<UtilityNetwork ADE - O&M extension database installation complete>



### C) Transformation of raw data into database encoding (Safe Sodtware FME)


### D) Loading 'dummy' attributes from Excel into PostgreSQL (Python)
