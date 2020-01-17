# CityGML - UtilityNetwork ADE - Operation and Maintenance extension
## Master's thesis project at the University of Twente. Implementation and validation of the O&M extension of Utility Network ADE

The Operation & Maintenance Extension of UtilityNetwork ADE (an extension of CityGML) was developed by Ramon ter Huurne to expand the original data model to cover concepts in the domain of O&M.

## Resources
[UtilityNetwork ADE](https://github.com/TatjanaKutzner/CityGML-UtilityNetwork-ADE#citygml-utilitynetwork-ade)
[Ramon ter Huurne - PDEng Project](https://github.com/RamonTerHuurne/UtilityNetwork-OperationsAndMaintenance)
[Giorgio Agugiaro - Database Implementation of UN ADE 0.9.2](https://github.com/gioagu/3dcitydb_utility_network_ade)
[Giorgio Agugiaro - 3DCityDB metadata](https://github.com/gioagu/3dcitydb_metadata_module)
[Xander den Duijn - Master's Project](https://github.com/XanderdenDuijn/CityGML-Utility-Network-ADE)
[Isaac Boates - Master's Project](https://github.com/iboates/UtilityNetwork-ADE-3DCityDB-Manager)



This repository contains the following folders:
00) Raw data - Contains the utility network used for the validation of the data model
01) UML - Contains the Universal Markup Language diagram of the data model
02) ShapeChange - Contains the configuration file for deriving the .XSD schema from the UML diagrams
03) XSD - Contains the .XSD derived from UML using ShapeChange 
04) Database - Contains the database encoding of the UML data model
05) FME - Contains workspaces for manipulating spatial data
06) Python - Contains routines to interact between Excel and the databse implementation in PostgreSQL

