# ISSM Installation
As a prerequisite, you'll need an installation of Matlab on your system that can be run from the command line. After installation you may need to add MATLAB to your path in `.bashrc`. For example:

```
export PATH=$PATH:/usr/local/MATLAB/R2022b/bin
```

After unzipping trunk-jpl, add the following to your `.bashrc`. where ISSM_PATH is the full file path to the trunk-jpl directory:

```
export ISSM_DIR=<ISSM_PATH>
source $ISSM_DIR/etc/environment.sh
```

Next, create and activate a new `issm` environment in Conda using the `environment.yml` file in the repo. 

```
conda env create --name envname --file=environments.yml
conda activate issm
```

Add a CONDA_DIR variable to your `.bashrc` that points to the Conda environment you just created. 

```
export CONDA_DIR=<ANAACONDA-PATH>/envs/issm
```

Most of the ISSM dependencies are installed in the Conda environment, but a couple need to be installed manually. 

```
cd $ISSM_DIR/externalpackages/m1qn3
./install.sh
cd $ISSM_DIR/externalpackages/triangle
./install-linux.sh
```

After installing all dependencies, source the ISSM environment:

```
source $ISSM_DIR/etc/environment.sh 
```

Now you can configure and install ISSM. 

```
 ./configure \
    --prefix="$ISSM_DIR" \
    --disable-static \
    --enable-development \
    --with-numthreads=8 \
    -with-matlab-dir="/usr/local/MATLAB/R2022b/" \
    --with-python-version=3.8 \
    --with-python-dir="$CONDA_DIR" \
    --with-python-numpy-dir="$CONDA_DIR/lib/python3.8/site-packages/numpy/core/include/numpy" \
    --with-fortran-lib="-L$CONDA_DIR/lib -lgfortran" \
    --with-mpi-include="$CONDA_DIR/lib/include" \
    --with-mpi-libflags="-L$CONDA_DIR/lib -lmpi -lmpicxx -lmpifort" \
    --with-metis-dir="$CONDA_DIR/lib" \
    --with-scalapack-dir="$CONDA_DIR/lib" \
    --with-mumps-dir="$CONDA_DIR/lib" \
    --with-petsc-dir="$CONDA_DIR" \
    --with-triangle-dir="$ISSM_DIR/externalpackages/triangle/install" \
    --with-m1qn3-dir="$ISSM_DIR/externalpackages/m1qn3/install"
```
```
make -j4
make install -j4
```
