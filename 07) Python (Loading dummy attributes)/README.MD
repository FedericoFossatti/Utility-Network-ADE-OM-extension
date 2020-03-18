### Notes
This directory contains two python scripts and one excel file.
* The data in the excel file is not real, and not inspired in any way by an existing network. It's purpose is to add more information to some database tables for the tests used to validate the model. In order to understand the color scheme of the excel sheets it is useful to keep at hand the related [entity-relationship diagram](https://github.com/FedericoFossatti/Utility-Network-ADE-OM-extension/blob/master/05%29%20Database/ER%20diagram%20UN_O%26M_56_with%20hierarchy.pdf).  
* Excel_to_postgresql_function.py: Function to read excel file 'dummy attributes' and to write to postgreSQL. The function is generic and can handle all the tables in the database. It uses the 'INSERT' stored procedure associated to each table.
* Import.py: Calls the Excel_to_postgresql function for each of the tables in the database where data is inserted. Can be edited to cover only specific tables.
* Use your preferred IDE to run the scripts
