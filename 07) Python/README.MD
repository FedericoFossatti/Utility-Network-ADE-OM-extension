### Notes
* The data in 'dummy' files is not real, and not inspired in any network. It's purpose at this moment is to debug the Python scripts.
* Excel_to_postgresql_function.py: Function to read excel file 'dummy attributes' and to write to postgreSQL. The function is generic and can handle all the tables in the database. It uses the 'INSERT' stored procedure associated to each table.
* Import.py: Calls the Excel_to_postgresql function for each of the tables in the database where data is inserted. Can be edited to cover only specific tables.
* Use your preferred IDE to run the scripts
