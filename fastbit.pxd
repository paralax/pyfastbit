cdef extern from "stdlib.h":
    ctypedef unsigned long size_t
    void free(void *ptr)
    void *malloc(size_t size)
    void *realloc(void *ptr, size_t size)
    size_t strlen(char *s)
    char *strcpy(char *dest, char *src)

cdef extern from "stdint.h":
    ctypedef unsigned char uint8_t
    ctypedef unsigned short uint16_t
    ctypedef unsigned int uint32_t
    ctypedef unsigned long long uint64_t
    ctypedef signed char int8_t
    ctypedef signed short int16_t
    ctypedef signed int int32_t
    ctypedef signed long long int64_t

cdef extern from "Python.h":
    int PyString_AsStringAndSize(object string, char **buffer, Py_ssize_t *length) except -1
    object PyString_FromStringAndSize(char *v, int len)
    Py_ssize_t PyString_Size(object string)
    char *PyString_AsString(object string)
    void Py_INCREF(object)
    void Py_DECREF(object)
    void PyEval_InitThreads()
    int PyErr_CheckSignals()
    int PyErr_ExceptionMatches(object)
    object PyCObject_FromVoidPtr(void *cobj, void (*destruct)(void*))
        


cdef extern from "../src/capi.h":
    struct FastBitQueryHandle:
           pass
    struct FastBitQuery:
        pass
    struct FastBitResultSetHandle:
        pass
    struct FastBitResultSet:
        pass


    void     fastbit_init(char *rcfile)
    int      fastbit_add_values(char *colname, char *coltype, void *vals, uint32_t nelem, uint32_t start)

    int      fastbit_build_index (char *indexLocation, char *cname, char *indexOptions)
    int      fastbit_build_indexes (char *indexLocation, char *indexOptions)
    int      fastbit_purge_index(char *indexLocation, char *cname)
    int      fastbit_purge_indexes(char *indexLocation)

    void     fastbit_cleanup()
    int      fastbit_columns_in_partition (char *datadir)
    int      fastbit_rows_in_partition(char *datadir)
    int      fastbit_flush_buffer (char *datadir)
    char *   fastbit_get_logfile()
    int      fastbit_set_logfile(char *filename)
    int      fastbit_get_verbose_level()
    int      fastbit_set_verbose_level(int v)

    # Query class  
    FastBitQuery* fastbit_build_query(char *selectClause, char *indexLocation, char *queryConditions)
    int      fastbit_destroy_query(FastBitQuery* query)
    int      fastbit_get_result_columns(FastBitQuery* query)
    int      fastbit_get_result_rows(FastBitQuery* query)
    char *   fastbit_get_select_clause(FastBitQuery* query)
    char *   fastbit_get_from_clause(FastBitQuery* query)
    char *   fastbit_get_where_clause(FastBitQuery* query)
    char *   fastbit_get_qualified_bytes (FastBitQuery* query, char *cname)
    double * fastbit_get_qualified_doubles (FastBitQuery* query, char *cname)
    float *  fastbit_get_qualified_floats (FastBitQuery* query, char *cname)
    int32_t * fastbit_get_qualified_ints (FastBitQuery* query, char *cname)
    int64_t * fastbit_get_qualified_longs (FastBitQuery* query, char *cname)
    int16_t * fastbit_get_qualified_shorts (FastBitQuery* query, char *cname)
    unsigned char *    fastbit_get_qualified_ubytes (FastBitQuery* query, char *cname)
    uint32_t *    fastbit_get_qualified_uints (FastBitQuery* query, char *cname)
    uint64_t *    fastbit_get_qualified_ulongs (FastBitQuery* query, char *cname)
    uint16_t *    fastbit_get_qualified_ushorts (FastBitQuery* query, char *cname)


    # Result class
    FastBitResultSet *fastbit_build_result_set(FastBitQuery* query)
    int      fastbit_destroy_result_set(FastBitResultSet *rset)
    int      fastbit_result_set_next(FastBitResultSet *rset)
    double   fastbit_result_set_get_double(FastBitResultSet *rset, char *cname)
    float    fastbit_result_set_get_float(FastBitResultSet *rset, char *cname)
    int      fastbit_result_set_get_int(FastBitResultSet *rset, char *cname)
    char *   fastbit_result_set_get_string(FastBitResultSet *rset, char *cname)
    unsigned int fastbit_result_set_get_unsigned(FastBitResultSet *rset, char *cname)
    double   fastbit_result_set_getDouble(FastBitResultSet *rset, unsigned position)
    float    fastbit_result_set_getFloat(FastBitResultSet *rset, unsigned position)
    int32_t  fastbit_result_set_getInt(FastBitResultSet *rset, unsigned position)
    char *   fastbit_result_set_getString(FastBitResultSet *rset, unsigned position)
    uint32_t fastbit_result_set_getUnsigned(FastBitResultSet *rset, unsigned position)

