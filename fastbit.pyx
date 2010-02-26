#PyEval_InitThreads()
#
class FastBit:
    def __init__(self, rcfile=None):
        """May pass in None as rcfile if one is expected to use use the 
default configuartion files listed in the documentation of 
ibis::resources::read. One may call this function multiple times 
to read multiple configuration files to modify the parameters."""

        if rcfile: fastbit_init(rcfile)
        else: fastbit_init(NULL)

    def __del__(self):
        self.cleanup()

    def add_values(self, colname, coltype, vals, start):
        """add_values(self, colname, coltype, vals, start)

Add values of the specified column (colname) to the in-memory buffer.
 
  colname Name of the column. Must start with an alphabet and 
   followed by a combination of alphanumerical characters. Following 
   the SQL standard, the column name is not case sensitive.
  coltype The type of the values for the column. The support types 
   are: "double", "float", "long", "int", "short", "byte", "ulong", 
   "uint", "ushort", and "ubyte". Only the first non-space character 
   is checked for the first six types and only the first two characters 
   are checked for the remaining types. This string is not case sensitive.
  vals The array containing the values. 
  start The position (row number) of the first element of the array. 
   Normally, this argument is zero (0) if all values are valid. One may 
   use this argument to skip some rows and indicate to FastBit that the 
   skipped rows contain NULL values."""
        return fastbit_add_values (colname, coltype, <void *>vals, len(vals), start)

    def build_index(self, indexLocation, cname):
        """build_index(self, indexLocation, cname)

Build an index for the named attribute. """
        return fastbit_build_index (indexLocation,  cname, NULL)

    def build_indexes(self, indexLocation, indexOptions):
        """build_indexes(self, indexLocation, indexOptions)

Build indexes for all columns in the named directory. """
        return fastbit_build_indexes(indexLocation, indexOptions)


    def cleanup(self):
        """cleanup(self)

Clean up resources hold by FastBit file manager."""
        fastbit_cleanup()

    def columns_in_partition(self, datadir):
        """columns_in_partition(self, datadir)

Return the number of columns in the data partition. """
        return fastbit_columns_in_partition (datadir)

    def rows_in_partition(self, datadir):
        """rows_in_partition(self, datadir)

Return the number of rows in the data partition. """
        return fastbit_rows_in_partition(datadir)

    def flush_buffer(self, datadir):
        """flush_buffer(self, datadir)

Flush the in-memory data to the named directory. 

In addition, if the new records contain columns that are not already 
in the directory, then the new columns are automatically added with 
existing records assumed to contain NULL values. This set of functions 
are intended for a user to append some number of rows in one operation. 
It is clear that writing one row as a time is slow because of the 
overhead involved in writing the files. On the other hand, since the 
new rows are stored in memory, it can not store too many rows."""
        return fastbit_flush_buffer(datadir)

    def get_logfile(self):
        """get_logfile(self)

Find out the name of the current log file. """
        return fastbit_get_logfile()

    def set_logfile(self, filename):
        """set_logfile(self, filename)

Change the name of the log file. A blank string indicates stdout."""
        return fastbit_set_logfile(filename)

    def get_verbose_level(self):
        """get_verbose_level(self)

Return the current verboseness level. """
        return fastbit_get_verbose_level()

    def set_verbose_level(self, v):
        """set_verbose_level(self, v)

Change the verboseness of FastBit functions. """
        return fastbit_set_verbose_level(v)
   
    def purge_index(self, indexLocation, cname):
        """purge_index(self, indexLocation, cname)

Purge the index of the named attribute. """
        return fastbit_purge_index(indexLocation, cname)

    def purge_indexes(self, indexLocation):
        """purge_indexes(self, indexLocation)

Purge all index files. """
        return fastbit_purge_indexes(indexLocation)




cdef class Query:
    # The Query class holds queries over the FastBit data set
    cdef FastBitQuery* qh
    def __cinit__(self, char *selectClause, char *indexLocation, char *queryConditions):
        self.qh = fastbit_build_query(selectClause, indexLocation, queryConditions)    

    def __del__(self):
        self.destroy_query()

    def __repr__(self):
        select = self.get_select_clause()
        if select.strip() == '': select = 'count(*)'
        from_clause = self.get_from_clause()
        where = self.get_where_clause()
        return 'Query(SELECT "%s" FROM "%s" WHERE (%s))' % (select, from_clause, where)

    def __len__(self): return self.get_result_rows()

    def destroy_query(self):
        """destroy_query(self)

Free all resource associated with the handle. """
        fastbit_destroy_query(self.qh)

    def get_from_clause(self):
        """get_from_clause(self)

Return the table name. """
        return fastbit_get_from_clause(self.qh)

    def get_where_clause(self):
        """get_where_clause(self)

Return the query conditions. """
        return fastbit_get_where_clause(self.qh)

    def get_result_columns(self):
        """get_result_columns(self)

Count the number of columns selected in the select clause of the query. """
        return fastbit_get_result_columns(<FastBitQuery*>(self.qh))

    def get_result_rows(self):
        """get_result_rows(self)

Return the number of hits in the query. """
        return fastbit_get_result_rows(<FastBitQuery*>(self.qh))

    def get_select_clause(self):
        """get_select_clause(self)

Return the string form of the select clause. """
        return fastbit_get_select_clause (<FastBitQuery*>(self.qh))

#    def get_qualified_bytes(self, cname):
#        """get_qualified_bytes(self, cname)
#
#Return the bytes from the qualified selection by column. """
#        return [x for x in
#                fastbit_get_qualified_bytes(<FastBitQuery*>(self.qh),
#                                            cname)]
#
#    def get_qualified_doubles(self, cname):
#        """get_qualified_doubles(self, cname)
#
#Return the doubles from the qualified selection by column. """
#        return [x for x in
#                fastbit_get_qualified_doubles(<FastBitQuery*>(self.qh),
#                                              cname)]
#
#    def get_qualified_floats(self, cname):
#        """get_qualified_floats(self, cname)
#
#Return the floats from the qualified selection by column. """
#        return [x for x in
#                fastbit_get_qualified_floats(<FastBitQuery*>(self.qh),
#                                             cname)]
#
#    def get_qualified_ints(self, cname):
#        """get_qualified_ints(self, cname)
#
#Return the ints from the qualified selection by column. """
#        cdef int32_t *data
#        cdef int nhits
#        res = []
#        data = fastbit_get_qualified_ints(<FastBitQuery*>(self.qh), <char *>cname)
#        nhits = fastbit_get_result_rows(<FastBitQuery*>(self.qh))
#        print 'get_qualified_ints', cname, nhits
#        for j in range(0, nhits):
#            print data[j]
#        return res
#
#    def get_qualified_longs(self, cname):
#        """get_qualified_longs(self, cname)
#
#Return the longs from the  qualified selection by column. """
#        return [x for x in
#                fastbit_get_qualified_longs(<FastBitQuery*>(self.qh),
#                                            cname)]
#
#    def get_qualified_shorts(self, cname):
#        """get_qualified_shorts(self, cname)
#Return the shorts from the  qualified selection by column. """
#        return [x for x in
#                fastbit_get_qualified_shorts(<FastBitQuery*>(self.qh),
#                                             cname)]
#
#    def get_qualified_ubytes(self, cname):
#        """get_qualified_ubytes(self, cname)
#
#Return the unsigned bytes from the  qualified selection by column. """
#        return <object>fastbit_get_qualified_ubytes(<FastBitQuery*>(self.qh), cname)
#
#    def get_qualified_uints(self, cname):
#        """get_qualified_uints(self, cname)
#
#Return the unsigned ints from the  qualified selection by column. """
#        return fastbit_get_qualified_uints(<FastBitQuery*>(self.qh), cname)[0]
#
#    def get_qualified_ulongs(self, cname):
#        """get_qualified_ulongs(self, cname)
#
#Return the unsigned longs from the  qualified selection by column. """
#        return <object>fastbit_get_qualified_ulongs(<FastBitQuery*>(self.qh), cname)
#
#    def get_qualified_ushorts(self, cname):
#        """get_qualified_ushorts(self, cname)
#
#Return the unsigned shorts from the  qualified selection by column. """
#        return <object>fastbit_get_qualified_ushorts(<FastBitQuery*>(self.qh), cname)
#
#
#
#
#
cdef class ResultSet:
    cdef FastBitResultSet *rh
    def __init__(self, Query query):
        """__init__(self, query)

Build a new result set from a Query object. """
        self.rh = fastbit_build_result_set(query.qh)

    def __del__(self):
        fastbit_destroy_result_set(<FastBitResultSet *>(self.rh))

    def has_next(self):
        """has_next(self)

#Returns 0 if there are more results, otherwise returns -1. """
        return fastbit_result_set_next(<FastBitResultSet *>(self.rh))

    def get_double(self, cname):
        """get_double(self, cname)

Get the value of the named column as a double-precision floating-point number. """
        return   fastbit_result_set_get_double(<FastBitResultSet *>(self.rh), cname)

    def get_float(self, cname):
        """get_float(self, cname)

Get the value of the named column as a single-precision floating-point number. """
        return fastbit_result_set_get_float(<FastBitResultSet *>(self.rh), cname)

    def get_int(self, cname):
        """get_int(self, cname)

Get the value of the named column as an integer. """
        return fastbit_result_set_get_int(<FastBitResultSet *>(self.rh), cname)

    def get_string(self, cname):
        """get_string(self, cname)

Get the value of the named column as a string. """
        return fastbit_result_set_get_string(<FastBitResultSet *>(self.rh), cname)

    def get_unsigned(self, cname):
        """get_unsigned(self, cname)

Get the value of the named column as an unsigned integer. """
        return fastbit_result_set_get_unsigned(<FastBitResultSet *>(self.rh), cname)

    def getString(self, position):
        """getString(self, position)

Get the value of the named column as a string. """
        return <object>fastbit_result_set_getString(<FastBitResultSet *>(self.rh), position)