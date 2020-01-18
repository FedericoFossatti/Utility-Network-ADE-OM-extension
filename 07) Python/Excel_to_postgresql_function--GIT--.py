def excel_to_postgresql(pg_dbname, pg_password, xls_book_name, xls_sheet_name, pg_function_name, pg_user='postgres',
                        pg_host='localhost', pg_port='5432'):
    import psycopg2
    import xlrd

    # PostgreSQL database
    database = psycopg2.connect(database=pg_dbname, user=pg_user, password=pg_password, host=pg_host, port=pg_port)
    cursor = database.cursor()

    # Excel file
    book = xlrd.open_workbook(xls_book_name)
    sheet = book.sheet_by_name(xls_sheet_name)

    # Find the column names of the specified table from the excel file. Assign to list 'titles'.
    titles = []
    values = []
    for c in range(0, sheet.ncols):
        titles.append(sheet.cell_value(0, c))
        values.append(None)

    # Find the column types of the specified table from the excel file. Assign to list 'col_types'.
    col_types = []
    for c in range(0, sheet.ncols):
        col_types.append(sheet.cell_value(1, c))

    # Find all cell values in excel table and replace each value in the previous list (values) with the value of the corresponding cell
    print('******')
    print('Function: "' + pg_function_name + '". Insertion in process...')
    for r in range(2, sheet.nrows):
        for i, v in enumerate(values):
            values[i] = sheet.cell(r, i).value
            if values[i] == '':
                values[i] = None
            # Cast excel 'value types' into python 'value types' also recognized by SQL.
            if col_types[i] == 'integer' and values[i] != None:
                values[i] = int(values[i])
            elif col_types[i] == 'numeric' and values[i] != None:
                values[i] = float(values[i])
            elif (col_types[i] == 'varchar' or col_types[i] == 'varchar(256)' or col_types[i] == 'varchar(1000)' or
                  col_types[i] == 'varchar(4000)' or col_types[i] == 'text' or col_types[i] == 'character') and values[i] != None:
                values[i] = str(values[i])
            elif (col_types[i] == 'date') and values[i] != None:
                values[i] = xlrd.xldate.xldate_as_datetime(sheet.cell(r, i).value, book.datemode).date()
            elif values[i] == None:
                values[i] = values[i]
        # Apparently, psycopg2 doesn't get along with lists. Convert to tuple.
        tuple(values)
        # Call function in PostgreSQL using psycopg2
        cursor.callproc(pg_function_name, values)
        print(values)
    print('')
    print('Finished insertion')
    print('')

    cursor.close()
    database.commit()
    database.close()