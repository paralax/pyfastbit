all: fastbit.c
	python setup.py build

fastbit.c: fastbit.pyx
	pyrexc fastbit.pyx

test: test.py 
	cp build/lib.freebsd-7.0-RELEASE-amd64-2.5/fastbit.so . 
	python test.py

clean:
	rm -rf build
	rm -f *.o *.so *.pyc *.pyo fastbit.c
	rm -f *.core
	rm -rf ipidx foodir
	rm -f testlog