#!/usr/bin/env bash
# train from scratch

../../build/tools/caffe train -solver MRI_solver.prototxt  -gpu 0   2>&1 | tee AF_S2_64.log

