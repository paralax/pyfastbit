all: fastbit.c
	python setup.py build

fastbit.c: fastbit.pyx
	cython fastbit.pyx

test: test.py 
	cp build/lib.*/fastbit.so . 
	python test.py

clean:
	rm -rf build
	rm -f *.o *.so *.pyc *.pyo fastbit.c
	rm -f *.core
	rm -rf foodir
	rm -f testlog
