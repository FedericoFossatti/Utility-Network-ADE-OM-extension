from Excel_to_postgresql_function import excel_to_postgresql

# Call function to load the data in PostgreSQL
pg_dbname = 'Write the name of your database'
pg_password = 'Write your password'
pg_user = 'postgres' # Default user or write your username.
pg_host = 'localhost' # Default host or write your own.
pg_port = '5432' # Default port or write your own.
xls_book_name = '/Users/FF/UT/03_Dummy_Attributes/DummyAttributes.xlsx' # Example of how the path to the file should be written.

# NO MORE INPUTS NEEDED
#------------------------------------------------------------------------------------------------------------------------------------------------------------
# Hierarchy level 1
# Insert cityobject
xls_sheet_name = 'cob'
pg_function_name = 'citydb_pkg.insert_cityobject'
excel_to_postgresql(pg_dbname, pg_password, xls_book_name, xls_sheet_name, pg_function_name, pg_user, pg_host, pg_port)

# Insert address
xls_sheet_name = 'add'
pg_function_name = 'citydb_pkg.insert_address'
excel_to_postgresql(pg_dbname, pg_password, xls_book_name, xls_sheet_name, pg_function_name, pg_user, pg_host, pg_port)

# Insert commodity
xls_sheet_name = 'comm'
pg_function_name = 'citydb_pkg.unom5_insert_commodity'
excel_to_postgresql(pg_dbname, pg_password, xls_book_name, xls_sheet_name, pg_function_name, pg_user, pg_host, pg_port)

# Insert material
xls_sheet_name = 'mat'
pg_function_name = 'citydb_pkg.unom5_insert_material'
excel_to_postgresql(pg_dbname, pg_password, xls_book_name, xls_sheet_name, pg_function_name, pg_user, pg_host, pg_port)

# Insert maintenance_activity
xls_sheet_name = 'ma_act'
pg_function_name = 'citydb_pkg.unom5_insert_maintenance_activity'
excel_to_postgresql(pg_dbname, pg_password, xls_book_name, xls_sheet_name, pg_function_name, pg_user, pg_host, pg_port)

# Insert impact
xls_sheet_name = 'imp'
pg_function_name = 'citydb_pkg.unom5_insert_impact'
excel_to_postgresql(pg_dbname, pg_password, xls_book_name, xls_sheet_name, pg_function_name, pg_user, pg_host, pg_port)

#------------------------------------------------------------------------------------------------------------------------------------------------------------
# Hierarchy level 2

# Insert network
xls_sheet_name = 'net'
pg_function_name = 'citydb_pkg.unom5_insert_network'
excel_to_postgresql(pg_dbname, pg_password, xls_book_name, xls_sheet_name, pg_function_name, pg_user, pg_host, pg_port)

# Insert network_feature
xls_sheet_name = 'net_ftr'
pg_function_name = 'citydb_pkg.unom5_insert_network_feature'
excel_to_postgresql(pg_dbname, pg_password, xls_book_name, xls_sheet_name, pg_function_name, pg_user, pg_host, pg_port)

# Insert commodity_supply
xls_sheet_name = 'com_sup'
pg_function_name = 'citydb_pkg.unom5_insert_commodity_supply'
excel_to_postgresql(pg_dbname, pg_password, xls_book_name, xls_sheet_name, pg_function_name, pg_user, pg_host, pg_port)

# Insert related_party
xls_sheet_name = 'rel_par'
pg_function_name = 'citydb_pkg.unom5_insert_related_party'
excel_to_postgresql(pg_dbname, pg_password, xls_book_name, xls_sheet_name, pg_function_name, pg_user, pg_host, pg_port)

#------------------------------------------------------------------------------------------------------------------------------------------------------------
# Hierarchy level 3

# Insert related_party_to_maintenance_activity
xls_sheet_name = 'rel_par_maint'
pg_function_name = 'citydb_pkg.unom5_insert_party_to_maintenance'
excel_to_postgresql(pg_dbname, pg_password, xls_book_name, xls_sheet_name, pg_function_name, pg_user, pg_host, pg_port)

# Insert network_to_network
xls_sheet_name = 'net_to_net'
pg_function_name = 'citydb_pkg.unom5_insert_network_to_network'
excel_to_postgresql(pg_dbname, pg_password, xls_book_name, xls_sheet_name, pg_function_name, pg_user, pg_host, pg_port)

# Insert party_to_network
xls_sheet_name = 'party_to_net'
pg_function_name = 'citydb_pkg.unom5_insert_party_to_network'
excel_to_postgresql(pg_dbname, pg_password, xls_book_name, xls_sheet_name, pg_function_name, pg_user, pg_host, pg_port)

# Insert network_to_network_feature
xls_sheet_name = 'net_to_feat'
pg_function_name = 'citydb_pkg.unom5_insert_network_to_network_feature'
excel_to_postgresql(pg_dbname, pg_password, xls_book_name, xls_sheet_name, pg_function_name, pg_user, pg_host, pg_port)

# Insert party_to_network_feature
xls_sheet_name = 'party_to_feat'
pg_function_name = 'citydb_pkg.unom5_insert_party_to_network_feature'
excel_to_postgresql(pg_dbname, pg_password, xls_book_name, xls_sheet_name, pg_function_name, pg_user, pg_host, pg_port)

# Insert feature_to_maintenance
xls_sheet_name = 'feat_to_maint'
pg_function_name = 'citydb_pkg.unom5_insert_feature_to_maintenance'
excel_to_postgresql(pg_dbname, pg_password, xls_book_name, xls_sheet_name, pg_function_name, pg_user, pg_host, pg_port)

# Insert network_feature_to_material
xls_sheet_name = 'feat_to_mat'
pg_function_name = 'citydb_pkg.unom5_insert_network_feature_to_material'
excel_to_postgresql(pg_dbname, pg_password, xls_book_name, xls_sheet_name, pg_function_name, pg_user, pg_host, pg_port)

# Insert network_graph
xls_sheet_name = 'net_graph'
pg_function_name = 'citydb_pkg.unom5_insert_network_graph'
excel_to_postgresql(pg_dbname, pg_password, xls_book_name, xls_sheet_name, pg_function_name, pg_user, pg_host, pg_port)

# Insert feature_graph
xls_sheet_name = 'feat_graph'
pg_function_name = 'citydb_pkg.unom5_insert_feature_graph'
excel_to_postgresql(pg_dbname, pg_password, xls_book_name, xls_sheet_name, pg_function_name, pg_user, pg_host, pg_port)

# Insert performance
xls_sheet_name = 'perf'
pg_function_name = 'citydb_pkg.unom5_insert_performance'
excel_to_postgresql(pg_dbname, pg_password, xls_book_name, xls_sheet_name, pg_function_name, pg_user, pg_host, pg_port)

# Insert cost
xls_sheet_name = 'cost'
pg_function_name = 'citydb_pkg.unom5_insert_cost'
excel_to_postgresql(pg_dbname, pg_password, xls_book_name, xls_sheet_name, pg_function_name, pg_user, pg_host, pg_port)

# Insert identification
xls_sheet_name = 'ident'
pg_function_name = 'citydb_pkg.unom5_insert_identification'
excel_to_postgresql(pg_dbname, pg_password, xls_book_name, xls_sheet_name, pg_function_name, pg_user, pg_host, pg_port)

# Insert dimensions
xls_sheet_name = 'dim'
pg_function_name = 'citydb_pkg.unom5_insert_dimensions'
excel_to_postgresql(pg_dbname, pg_password, xls_book_name, xls_sheet_name, pg_function_name, pg_user, pg_host, pg_port)

# Insert measured_depth
xls_sheet_name = 'depth'
pg_function_name = 'citydb_pkg.unom5_insert_measured_depth'
excel_to_postgresql(pg_dbname, pg_password, xls_book_name, xls_sheet_name, pg_function_name, pg_user, pg_host, pg_port)

# Insert soil_and_groundwater
xls_sheet_name = 'soil'
pg_function_name = 'citydb_pkg.unom5_insert_soil_and_groundwater'
excel_to_postgresql(pg_dbname, pg_password, xls_book_name, xls_sheet_name, pg_function_name, pg_user, pg_host, pg_port)

# Insert protective_element
xls_sheet_name = 'prot_el'
pg_function_name = 'citydb_pkg.unom5_insert_protective_element'
excel_to_postgresql(pg_dbname, pg_password, xls_book_name, xls_sheet_name, pg_function_name, pg_user, pg_host, pg_port)

# Insert pipe
xls_sheet_name = 'pipe'
pg_function_name = 'citydb_pkg.unom5_insert_pipe'
excel_to_postgresql(pg_dbname, pg_password, xls_book_name, xls_sheet_name, pg_function_name, pg_user, pg_host, pg_port)

# Insert cable
xls_sheet_name = 'cable'
pg_function_name = 'citydb_pkg.unom5_insert_cable'
excel_to_postgresql(pg_dbname, pg_password, xls_book_name, xls_sheet_name, pg_function_name, pg_user, pg_host, pg_port)

# Insert functional_component
xls_sheet_name = 'func_com'
pg_function_name = 'citydb_pkg.unom5_insert_functional_component'
excel_to_postgresql(pg_dbname, pg_password, xls_book_name, xls_sheet_name, pg_function_name, pg_user, pg_host, pg_port)

#------------------------------------------------------------------------------------------------------------------------------------------------------------
# Hierarchy level 4

# Insert storage
xls_sheet_name = 'sto'
pg_function_name = 'citydb_pkg.unom5_insert_storage'
excel_to_postgresql(pg_dbname, pg_password, xls_book_name, xls_sheet_name, pg_function_name, pg_user, pg_host, pg_port)

# Insert feature_graph_to_network_graph
xls_sheet_name = 'ft_gr_to_nt_gr'
pg_function_name = 'citydb_pkg.unom5_insert_feature_graph_to_network_graph'
excel_to_postgresql(pg_dbname, pg_password, xls_book_name, xls_sheet_name, pg_function_name, pg_user, pg_host, pg_port)

# Insert feature_graph_to_network_graph
xls_sheet_name = 'node'
pg_function_name = 'citydb_pkg.unom5_insert_node'
excel_to_postgresql(pg_dbname, pg_password, xls_book_name, xls_sheet_name, pg_function_name, pg_user, pg_host, pg_port)

# Insert commodity_classifier
xls_sheet_name = 'com_clas'
pg_function_name = 'citydb_pkg.unom5_insert_commodity_classifier'
excel_to_postgresql(pg_dbname, pg_password, xls_book_name, xls_sheet_name, pg_function_name, pg_user, pg_host, pg_port)
# """
#------------------------------------------------------------------------------------------------------------------------------------------------------------
# Hierarchy level 5

# Insert link
xls_sheet_name = 'link'
pg_function_name = 'citydb_pkg.unom5_insert_link'
excel_to_postgresql(pg_dbname, pg_password, xls_book_name, xls_sheet_name, pg_function_name, pg_user, pg_host, pg_port)

print('--All data uploaded to PostgreSQL--')
