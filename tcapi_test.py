#!/usr/bin/env python

import sys
import os
from fastbit import FastBit, Query

counts = (5, 24, 19, 10, 50)
conditions = ("a<5", "a+b>150", "a < 60 and c < 60", "c > 90", "c > a")
datadir = 'tcapi_test_dir'
if os.path.exists(datadir):
    import shutil
    shutil.rmtree(datadir)

ivals = []
svals = []
fvals = []
for i in xrange(0, 100):
    ivals.append(i)
    svals.append(i)
    fvals.append(float(1e2-i))

fb = FastBit()
fb.add_values('a', 'int', ivals, 0)
fb.add_values('b', 'short', svals, 0)
fb.add_values('c', 'float', fvals, 0)
fb.flush_buffer(datadir)
mult = fb.rows_in_partition(datadir)
if mult%100 != 0:
    print 'Directory %d contains %d rows, expected 100' % (datadir, mult)
    sys.exit(1)

mult /= 100
nerrors = 0
for i in xrange(0, 5):
    q = Query('', datadir, conditions[i])
    nhits = q.get_result_rows()
    if nhits != (mult * counts[i]):
        print 'query "%s" on %d built-in records found %d hits, but %d were expected' % (str(q), mult+100, nhits, mult*counts[i])
        nerrors += 1
    del(q)

print 'built in tests finished with %d errors' % nerrors
