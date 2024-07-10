#!/bin/bash

# SPDX-FileCopyrightText: Copyright (c) 2024 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

export CXX_PATH=/usr
export PATH=${CXX_PATH}/bin:${PATH}

if [[ -z "${MPI_PATH}" ]]; then
    export MPI_PATH=/opt/nvidia/hpc_sdk/Linux_x86_64/24.5/comm_libs/12.4/hpcx/hpcx-2.19/ompi #Change this to correct MPI path
fi

if [[ -z "${MATHLIBS_PATH}" ]]; then
    export MATHLIBS_PATH=/opt/nvidia/hpc_sdk/Linux_x86_64/24.5/math_libs #Change this to correct CUDA mathlibs
fi

if [[ -z "${NCCL_PATH}" ]]; then
    export NCCL_PATH=/opt/nvidia/hpc_sdk/Linux_x86_64/24.5/comm_libs/nccl #Change to correct NCCL path
fi

if [[ -z "${CUDA_PATH}" ]]; then
    export CUDA_PATH=/opt/nvidia/hpc_sdk/Linux_x86_64/24.5/cuda #Change this to correct CUDA path
fi

if [[ -z "${NVPL_SPARSE_PATH}" ]]; then
    export NVPL_SPARSE_PATH=/opt/nvidia/hpc_sdk/Linux_x86_64/24.5/math_libs/12.4/targets/x86_64-linux #Change this to correct NVPL mathlibs
fi

#Please fix, if needed
export CUDA_BLAS_VERSION=${CUDA_BUILD_VERSION:-12.2}
export LD_LIBRARY_PATH=${MATHLIBS_PATH}/${CUDA_BLAS_VERSION}/lib64/:${LD_LIBRARY_PATH}
export PATH=${CUDA_PATH}/bin:${PATH}
export LD_LIBRARY_PATH=${CUDA_PATH}/lib64:${LD_LIBRARY_PATH}
export LD_LIBRARY_PATH=${NCCL_PATH}/lib:${LD_LIBRARY_PATH}
export LD_LIBRARY_PATH=${NVPL_SPARSE}/lib:${LD_LIBRARY_PATH}

ext="--mca pml ^ucx --mca btl ^openib,smcuda -mca coll_hcoll_enable 0 -x coll_hcoll_np=0 --bind-to none"

#Directory to xhpcg binary
dir="bin/"

#Sample on Grace Hopper x4
###########################
#Local problem size
nx=256 #Large problem size x, assumed for the GPU
ny=1024 #Large problem size y, assumed for the GPU
nz=288 #Large problem size z, assumed for the GPU

module load nvhpc

#1 GPUOnly
#---------#
np=16  #Total number of ranks
mpirun --oversubscribe ${ext} -np $np ${dir}/hpcg.sh  --exec-name ${dir}/xhpcg \
 --nx $nx --ny $ny --nz $nz --rt 10 --b 0 --exm 0 --p2p 0 \
 --mem-affinity 0:1:2:3 --cpu-affinity 0-71:72-143:144-215:216-287
