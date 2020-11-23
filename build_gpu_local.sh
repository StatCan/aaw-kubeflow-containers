#!/usr/bin/env bash
cd upstream-equivalent-notebook-gpu
./build.sh
cd ..

cd base-notebook
./build_gpu.sh
cd ..

cd minimal-notebook
./build_gpu.sh
cd ..

cd machine-learning-notebook
./build_gpu.sh
cd ..