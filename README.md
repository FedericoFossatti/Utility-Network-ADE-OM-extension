# Utility Network ADE. Operation and Maintenance extension
##Master's thesis project at the University of Twente. Implementation and validation of the O&M extension of Utility Network ADE

The Operation & Maintenance Extension of UtilityNetwork ADE (an extension of CityGML) was developed by Ramon ter Huurne to expand the original data model to cover concepts in the domain of O&M.



This repository contains the following folders:
00) Raw data - Contains the utility network used for the validation of the data model
01) UML - Contains the Universal Markup Language diagram of the data model
02) ShapeChange - Contains the configuration file for deriving the .XSD schema from the UML diagrams
03) XSD - Contains the .XSD derived from UML using ShapeChange 
04) Database - Contains the database encoding of the UML data model
05) FME - Contains workspaces for manipulating spatial data
06) Python - Contains routines to interact between Excel and the databse implementation in PostgreSQL

