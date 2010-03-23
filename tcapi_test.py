#!/usr/bin/env python

import sys
import os
from fastbit import FastBit, Query

datadir = 'tcapi_test_dir'
if os.path.exists(datadir):
    import shutil
    shutil.rmtree(datadir)

nvals = int(3 * 1e6)

conditions = ("a<5", "a+a>150", "a < 60 and c < 60", "c > 90", "c > a")
counts = (5, nvals - 76, 19, 10, 50)

import time
t = time.time()

fb = FastBit()
fb.add_values('a', 'int', range(nvals), 0)
fb.add_values('b', 'short', [x % 128 for x in range(nvals)] , 0)
fb.add_values('c', 'float', [float(1e2 -i) for i in xrange(nvals)], 0)
fb.flush_buffer(datadir)

print "time to add %iK values (* 3): %.3f" % (nvals / 1000., time.time() - t)

mult = fb.rows_in_partition(datadir)
if mult != nvals:
    print 'Directory %d contains %d rows, expected %i' % (datadir, mult, nvals)
    sys.exit(1)
#FastBit.build_index(datadir, 'a', '0')
#FastBit.build_index(datadir, 'b', '0')
#FastBit.build_index(datadir, 'c', '0')

nerrors = 0
# NOTE runs faster second time.
for rep in range(2):
    if rep == 1:
        print "\nafter indexes (automatically) created...\n"
    for i in xrange(0, 5):
        t = time.time()
        q = Query('', datadir, conditions[i])
        nhits = q.rows
        if nhits != counts[i]:
            print i, 'query "%s" on %d built-in records found %d hits, but %d were expected' % (str(q), nvals, nhits, counts[i])
            nerrors += 1
        del(q)
        print "time to query '%s': %.3f. results: %i" % (conditions[i], time.time() - t, nhits)

print 'built in tests finished with %d errors' % nerrors

