from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

setup(
    name = 'fastbit',
    ext_modules = [
        Extension('fastbit', ['fastbit.pyx'],
        include_dirs = ["../src"],
        libraries = ["fastbit"],
        library_dirs = ["/usr/local/lib"],
        )
    ],
    cmdclass = {'build_ext': build_ext},
)
