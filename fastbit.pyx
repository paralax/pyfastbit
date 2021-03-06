#PyEval_InitThreads()
#
cimport python_string as ps

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

    def add_values(self, colname, coltype, invals, int start=0):
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
        cdef int i, n = len(invals)

        cdef int16_t *svals
        cdef int32_t *ivals
        cdef float *fvals
        cdef int64_t *lvals
        cdef char **bvals
        cdef uint16_t *usvals
        cdef uint32_t *uivals
        cdef uint64_t *ulvals
        cdef unsigned char **ubvals

        cdef Py_ssize_t size
        cdef char *holder
        col = coltype.lower()

        if col.startswith('i'):
            ivals = <int32_t *>malloc(sizeof(int32_t) * (n + 1))
            for i in range(n): ivals[i] = invals[i]
            r = fastbit_add_values (colname, coltype, ivals, n, start)
            free(ivals)
            return r

        elif col.startswith('s'):
            svals = <int16_t *>malloc(sizeof(int16_t) * (n + 1))
            for i in range(n): svals[i] = invals[i]
            r = fastbit_add_values (colname, coltype, svals, n, start)
            free(svals)
            return r

        elif col.startswith('f'):
            fvals = <float *>malloc(sizeof(float) * (n + 1))
            for i in range(n): fvals[i] = invals[i]
            r = fastbit_add_values (colname, coltype, fvals, n, start)
            free(fvals)
            return r
        elif col.startswith('l'):
            lvals = <int64_t *>malloc(sizeof(int64_t) * (n + 1))
            for i in range(n): lvals[i] = invals[i]
            r = fastbit_add_values (colname, coltype, lvals, n, start)
            free(lvals)
            return r
        elif col.startswith('t'):
            # TODO: check this.
            bvals = <char **>malloc(sizeof(char *) * (n + 1))
            for i in range(n):
                bvals[i] = invals[i]
            r = fastbit_add_values (colname, coltype, bvals, n, start)
            free(bvals)
            return r
        elif col.startswith('b'):
            # TODO: check this.
            bvals = <char **>malloc(sizeof(char) * (n + 1))
            for i in range(n): bvals[i] = invals[i]
            r = fastbit_add_values (colname, coltype, bvals, n, start)
            free(bvals)
            return r

        elif col.startswith('u'):
            if col[1] == 'i':
                uivals = <uint32_t *>malloc(sizeof(uint32_t) * (n + 1))
                for i in range(n): uivals[i] = invals[i]
                r = fastbit_add_values (colname, coltype, uivals, n, start)
                free(uivals)
                return r
            elif col[1] == 's':
                usvals = <uint16_t *>malloc(sizeof(uint16_t) * (n + 1))
                for i in range(n): usvals[i] = invals[i]
                r = fastbit_add_values (colname, coltype, usvals, n, start)
                free(usvals)
                return r
            elif col[1] == 'l':
                ulvals = <uint64_t *>malloc(sizeof(uint64_t) * (n + 1))
                for i in range(n): ulvals[i] = invals[i]
                r = fastbit_add_values (colname, coltype, ulvals, n, start)
                free(ulvals)
                return r
            elif col[1] == 'b':
                ubvals = <unsigned char **>malloc(sizeof(unsigned char *) * (n + 1))
                for i in range(n): 
                    # TODO: should we just use char * from teh start and ditch the unsigned?
                    #ubvals[i] = <unsigned char *>malloc(sizeof(unsigned char *) * len(invals[i]))
                    #ubvals[i] = <unsigned char *>ps.PyString_AsString(invals[i])
                    ps.PyString_AsStringAndSize(invals[i], <char **>(&ubvals[i]), &size)
                r = fastbit_add_values (colname, coltype, ubvals, n, start)
                free(ubvals)
                return r
        else:
            raise Exception, 'unsupported coltype %s' % coltype

    @classmethod
    def build_index(cls, datadir, colname, options):
        """build_index(self, indexLocation, cname) Build an index for the named attribute. """
        return fastbit_build_index (datadir,  colname, options)

    @classmethod
    def build_indexes(cls, datadir, options):
        """build_indexes(self, indexLocation, indexOptions)
            Build indexes for all columns in the named directory. """
        return fastbit_build_indexes(datadir, options)

    @classmethod
    def purge_index(self, datadir, colname):
        """purge_index(self, indexLocation, cname)
        Purge the index of the named attribute. """
        return fastbit_purge_index(datadir, colname)

    @classmethod
    def purge_indexes(self, datadir):
        """purge_indexes(self, indexLocation) Purge all index files. """
        return fastbit_purge_indexes(datadir)

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




cdef class Query:
    # The Query class holds queries over the FastBit data set
    """Query(self, selectClause, indexLocation, queryConditions)

    Build a new FastBit query. 

    This is logically equivalent to the SQL statement 
      "SELECT selectClause 
       FROM indexLocation 
       WHERE queryConditions." 
    A blank selectClause is equivalent to "count(*)".

    Must call destroy_query or __del__() to free the resources.
    """
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
        return fastbit_get_result_rows(self.qh)
    rows = property(get_result_rows)

    def get_select_clause(self):
        """get_select_clause(self)

Return the string form of the select clause. """
        return fastbit_get_select_clause (<FastBitQuery*>(self.qh))


    def get_qualified_bytes(self, cname):
        """get_qualified_bytes(self, cname)
        Return the bytes from the qualified selection by column. """
        cdef char *d = fastbit_get_qualified_bytes(self.qh, cname)
        cdef int i, rows = fastbit_get_result_rows(self.qh)
        return [d[i] for i in range(rows)]
                
    def get_qualified_doubles(self, cname):
        """get_qualified_doubles(self, cname)
Return the doubles from the qualified selection by column. """
        cdef double *d = fastbit_get_qualified_doubles(self.qh, cname)
        cdef int i, rows = fastbit_get_result_rows(self.qh)
        return [long(d[i]) for i in range(rows)]


    def get_qualified_floats(self, cname):
        """get_qualified_doubles(self, cname)
Return the floats from the qualified selection by column. """
        cdef float *d = fastbit_get_qualified_floats(self.qh, cname)
        cdef int i, rows = fastbit_get_result_rows(self.qh)
        return [d[i] for i in range(rows)]

    def get_qualified_ints(self, cname):
        """get_qualified_doubles(self, cname)
Return the floats from the qualified selection by column. """
        cdef int32_t *d = fastbit_get_qualified_ints(self.qh, cname)
        cdef int i, rows = fastbit_get_result_rows(self.qh)
        return [int(d[i]) for i in range(rows)]

    def get_qualified_longs(self, cname):
        """get_qualified_longs(self, cname)
Return the floats from the qualified selection by column. """
        cdef int64_t *d = fastbit_get_qualified_longs(self.qh, cname)
        cdef int i, rows = fastbit_get_result_rows(self.qh)
        return [d[i] for i in range(rows)]

    def get_qualified_shorts(self, cname):
        """get_qualified_shorts(self, cname)
Return the floats from the qualified selection by column. """
        cdef int16_t *d = fastbit_get_qualified_shorts(self.qh, cname)
        cdef int i, rows = fastbit_get_result_rows(self.qh)
        return [d[i] for i in range(rows)]

    def get_qualified_ubytes(self, cname):
        """get_qualified_ubytes(self, cname)

Return the unsigned bytes from the  qualified selection by column. """
        cdef unsigned char *d = fastbit_get_qualified_ubytes(<FastBitQuery*>(self.qh),<char *>cname)
        cdef int i, rows = fastbit_get_result_rows(self.qh)
        return [d[i] for i in range(rows)]

    def get_qualified_uints(self, cname):
        """get_qualified_uints(self, cname)

Return the unsigned ints from the  qualified selection by column. """
        cdef uint32_t *d = fastbit_get_qualified_uints(<FastBitQuery*>(self.qh),<char *>cname)
        cdef int i, rows = fastbit_get_result_rows(self.qh)
        return [d[i] for i in range(rows)]
                
    def get_qualified_ulongs(self, cname):
        """get_qualified_ulongs(self, cname)

Return the unsigned longs from the  qualified selection by column. """
        cdef uint64_t *d = fastbit_get_qualified_ulongs(<FastBitQuery*>(self.qh),<char *>cname)
        cdef int i, rows = fastbit_get_result_rows(self.qh)
        return [d[i] for i in range(rows)]

    def get_qualified_ushorts(self, cname):
        """get_qualified_ushorts(self, cname)

Return the unsigned shorts from the  qualified selection by column. """
        cdef uint16_t *d = fastbit_get_qualified_ushorts(<FastBitQuery*>(self.qh),<char *>cname)
        cdef int i, rows = fastbit_get_result_rows(self.qh)
        return [d[i] for i in range(rows)]
        
                
                
                
cdef class ResultSet:
    # A handle to identify a set of query results. 
    """ResultSet(self, query)

Build a new result set from a Query object. """
    cdef FastBitResultSet *rh
    def __init__(self, Query query):
        self.rh = fastbit_build_result_set(query.qh)

    def __del__(self):
        fastbit_destroy_result_set(<FastBitResultSet *>(self.rh))

    def has_next(self):
        """has_next(self)

Returns 0 if there are more results, otherwise returns -1. """
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
        
    def getDouble(self, position):
        """getDouble(self, position)
        Get the value of the named column as a double-precision floating-point number."""
        return fastbit_result_set_getDouble(<FastBitResultSet *>(self.rh), position)
    
    def getFloat(self, position):
        """getFloat(self, position)
        
Get the value of the named column as a single-precision floating-point number. """
        return fastbit_result_set_getFloat(<FastBitResultSet *>(self.rh), position)
        
    def getInt(self, position):
        """getInt(self, position)
        
Get the value of the named column as an integer. """
        return fastbit_result_set_getInt(<FastBitResultSet *>(self.rh), position)
        
    def getString(self, position):
        """getString(self, position)

Get the value of the named column as a string. """
        return <object>fastbit_result_set_getString(<FastBitResultSet *>(self.rh), position)

    def getUnsigned(self, position):
        """getUnsigned(self, position)
        
        Get the value of the named column as an unsigned integer. """
        return fastbit_result_set_getUnsigned(<FastBitResultSet *>(self.rh), position)
        
