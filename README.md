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
The workflow is for creating a spatial-relational database and loading the raw data into it after transforming it to comply with the O&M conceptual shcema.

### A) Conceptual schema / Data model (Sparx Systems Enterprise Architect)
This step is optional, the O&M conceptual schema is ready, the ShapeChange configuration file too, and the .XSD schema file has been derived.
1. Open UML model and alter classes / codelists / relations
2. Add changes to ShapeChange configuration file (if any)
3. Downlaod and use [ShapeChange](https://shapechange.net/get-started/)
New .XSD schema has been derived. The output of ShapeChange (.XSD) is one of the inputs for part C).

### B) Database setup (PostgreSQL + PostGIS)


### C) Transformation of raw data into database encoding (Safe Sodtware FME)


### D) Loading 'dummy' attributes from Excel into PostgreSQL (Python)
