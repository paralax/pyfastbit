#!/usr/bin/env python

def ip2dec(ip):
    ip = [ int(x) for x in ip.split('.') ]
    return (ip[0] * 2**24) + (ip[1] * 2**16) + (ip[2] * 2**8) + (ip[3] * 2**0)

from fastbit import FastBit, Query, ResultSet

fast = FastBit()
print 'set_logfile', fast.set_logfile('testlog')
print 'set_verbose_level', fast.set_verbose_level(10)
print 'get_logfile', fast.get_logfile()
ips = ['24.126.104.55', '63.254.155.34', '64.189.104.238', 
       '69.232.196.114', '71.17.178.96', '76.176.158.239', 
       '81.222.80.217', '98.230.97.172', '157.252.179.242', 
       '208.102.79.212']
print 'add', fast.add_values('ip', 'uI', [ ip2dec(x) for x in ips], 0)
# names = [ '0' for x in ips ]
names = [ x for x in  xrange(0, len(ips)) ]
print 'add', fast.add_values('host', 'uI', names, 0)
print 'flush', fast.flush_buffer('foodir')
print 'cols', fast.columns_in_partition('foodir')
print 'rows', fast.rows_in_partition('foodir')
print 'build_index', fast.build_index('foodir', 'ip')
print 'build_index', fast.build_index('foodir', 'host')
print 'build_indexes', fast.build_indexes('foodir', '')

print '----[ Query'
qh = Query('ip, host', 'foodir', 'ip < %d' % ip2dec('127.0.0.0'))
print 'build_query\n', qh
print 'from clause', qh.get_from_clause()
print 'select clause', qh.get_select_clause()
print 'n_rows', qh.get_result_rows()
print 'len', len(qh)
print 'qualified doubles', qh.get_qualified_doubles('ip')
print 'qualified ints', qh.get_qualified_uints('ip')

print '----[ Results'
rh = ResultSet(qh)
ncols = qh.get_result_columns()
print 'getInt', rh.getInt(0)
print 'getUnsigned', rh.getUnsigned(0)
print 'getString', rh.getString(0)
for i in xrange(1, ncols):
    print 'getInt %d' % i, rh.getInt(i)
    print 'getUnsigned %d' % i, rh.getUnsigned(i)
    print 'getString %d' % i, rh.getString(i)

del(rh)
del(qh)

print 'cleanup() hangs (thread lock?)'
print 'cleanup', fast.cleanup()
