#!/usr/bin/env bash
cd base-notebook
./build_cpu.sh
cd ..

cd minimal-notebook
./build_cpu.sh
cd ..

cd machine-learning-notebook
./build_cpu.sh
cd ..

cd geomatics-notebook
./build_cpu.sh
cd ..

cd r-studio
./build_cpu.sh
cd ..
