from setuptools import Extension, setup
from Cython.Build import cythonize
from Cython.Compiler import Options
import sys

Options.fast_fail = True

XEQ_BASE_DIR = '../../equilibria'

extensions = [Extension(
    "equilibria.wallet",
    ["src/equilibria/*.pyx"],

    define_macros=[#('FLTK_HAVE_CAIRO', '1'),      
                    #('CYTHON_METH_FASTCALL', '1'),
        # ('CYTHON_LIMITED_API', '1'),               
    ],                                             
    # py_limited_api = True,                         

        include_dirs = [
            '../external/build/build/boost/include',
            '../external/build/build/libsodium/x86_64/include',
            '../external/build/build/openssl/include',
            '../external/build/build/equilibria/include',
            #'../../equilibria/src/wallet/api',
            ],

        extra_compile_args=['-g0'],

        # extra_compile_args=["-static-libgcc",
        #                     '-Wunused-variable',
        #                     '-Wreorder'
        #                     ],
        # cannot use "-static-libgcc", "-static-libstdc++"
        # because ca throws a std:bad_cast exception
        # extra_link_args=["-static-libgcc", "-static-libstdc++"],

        extra_objects=[
            #'-Wl,-Bstatic',
            #'-lssl',
            #'-lhidapi-libusb',
            #'-Wl,-Bdynamic',
            ],

        libraries = [
                    'wallet_api',
                    'wallet',
                    'multisig',
                    'cryptonote_core',
                    'cryptonote_basic',
                    'blockchain_db',
                    'hardforks',
                    'net',
                    'cncrypto',
                    'blocks',
                    'lmdb',
                    'ringct',
                    'ringct_basic',
                    'common',
                    'epee',
                    'easylogging',
                    'mnemonics',
                    'boost_system',
                    'boost_filesystem',
                    'boost_thread',
                    'boost_chrono',
                    'boost_regex',
                    'boost_serialization',
                    'boost_program_options',
                    ##'pthread',
                    'unbound',
                    'sodium',
                    #'usb',
                    'device',
                    'device_trezor',
                    'hidapi-libusb',  # Comment this one to create a wheel
                    'ssl',
                    'crypto',
                    'checkpoints',
                    'version',
            ],
        library_dirs = [
            '../external/build/build/boost/x86_64/lib',
            '../external/build/build/libsodium/x86_64/lib',
            '../external/build/build/openssl/x86_64/lib',
            '../external/build/build/equilibria/x86_64/lib',
            #'../../equilibria/bld/lib',
                ],
        ),
        ]

setup(
    name="python-equilibria",
    # version=versioneer.get_version(),
    version="0.99.3",
    # cmdclass=versioneer.get_cmdclass(),
    author="Ricardo Pedroso",
    author_email="rmdpedroso@gmail.com",
    description="Python bindings to equilibria wallet_api",
    # long_description=long_description,
    # long_description_content_type="text/markdown",
    url="https://github.com/rpedroso/pyequilibria",
    # include_package_data=True,
    packages=['equilibria',
              #'equilibria.wallet',
    ],
    package_dir={'': 'src'},
    # ext_modules = cythonize(extensions),
    classifiers=[
        'Programming Language :: Python :: 3.8',
        'Programming Language :: Python :: 3.9',
        'Programming Language :: Python :: 3.10',
        'Programming Language :: Python :: 3.11',
        'Operating System :: Unix',
        'Operating System :: POSIX',
        'Operating System :: Microsoft :: Windows',        
        'Development Status :: 5 - Production/Stable',
        'Intended Audience :: Developers',
    ],
    install_requires=[],
    python_requires='>=3.8',

    ext_modules = cythonize(extensions,
        language_level="3",
        annotate=True,
        include_path=[
            #'/home/rp/.local/lib/python3.10/site-packages',
            #cyFLTK_BASE_DIR + '/include',
            ],
        )
)
