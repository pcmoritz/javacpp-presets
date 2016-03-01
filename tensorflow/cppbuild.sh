#!/bin/bash
# This file is meant to be included by the parent cppbuild.sh script
if [[ -z "$PLATFORM" ]]; then
    pushd ..
    bash cppbuild.sh "$@" tensorflow
    popd
    exit
fi

case $PLATFORM in
    linux-x86)
        export BUILDFLAGS="--copt=-m32 --linkopt=-m32"
        ;;
    linux-x86_64)
        export BUILDFLAGS="--copt=-m64 --linkopt=-m64"
        ;;
    macosx-*)
        export BUILDFLAGS="--linkopt=-install_name --linkopt=@rpath/libtensorflow.so"
        ;;
    *)
        echo "Error: Platform \"$PLATFORM\" is not supported"
        return 0
        ;;
esac

mkdir -p $PLATFORM
cd $PLATFORM

rm -rf tensorflow
git clone --recurse-submodules https://github.com/tensorflow/tensorflow

# Assumes Bazel is available in the path: http://bazel.io/docs/install.html
cd tensorflow
patch -Np1 < ../../../tensorflow-master.patch
./configure
bazel build -c opt --config=cuda //tensorflow/cc:libtensorflow.so $BUILDFLAGS

cd ../..
