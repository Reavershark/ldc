#!/usr/bin/env bash

set -e

HOST_PLATFORM="linux/amd64"
declare -a TARGET_ARRAY=(
    # "docker_platform triple cc_package cc"
    "linux/386 i686-linux-gnu gcc-i686-linux-gnu i686-linux-gnu-gcc"
    "linux/amd64 x86_64-pc-linux-gnu gcc gcc"
    "linux/arm/v7 arm-linux-gnueabihf gcc-arm-linux-gnueabihf arm-linux-gnueabihf-gcc"
    "linux/arm64/v8 aarch64-linux-gnu gcc-aarch64-linux-gnu aarch64-linux-gnu-gcc"
    "linux/ppc64le powerpc64le-linux-gnu gcc-powerpc64le-linux-gnu powerpc64le-linux-gnu-gcc"
)
declare -a TEST_FILES_ARRAY=(
    "memoryerror_null.d"
    "memoryerror_stackoverflow.d"
)
declare -a DFLAGS_ARRAY=(
    "-g"
    "-g --checkaction=C"
    "-g --release -O3 --enable-asserts"
    "-g --release -O3 --enable-asserts --checkaction=C"
)

function clean
{
    [[ -e stdout.log ]] && rm -f stdout.log || true
    [[ -e stderr.log ]] && rm -f stderr.log || true
    [[ -e exitcode.log ]] && rm -f exitcode.log || true
}

for target in "${TARGET_ARRAY[@]}"; do
    read -a target_split <<< "${target}"
    target_platform="${target_split[0]}"
    target_triple="${target_split[1]}"
    target_cc_package="${target_split[2]}"
    target_cc="${target_split[3]}"
    for test_file in "${TEST_FILES_ARRAY[@]}"; do
        for test_dflags in "${DFLAGS_ARRAY[@]}"; do
            clear
            clean
            echo "Platform ${target_platform}: Testing ${test_file} with flags ${test_dflags}:"
            docker build .. -f Dockerfile \
               --build-arg="HOST_PLATFORM=${HOST_PLATFORM}" \
               --build-arg="TARGET_PLATFORM=${target_platform}" \
               --build-arg="TARGET_TRIPLE=${target_triple}" \
               --build-arg="TARGET_CC_PACKAGE=${target_cc_package}" \
               --build-arg="TARGET_CC=${target_cc}" \
               --build-arg="TEST_FILE=${test_file}" \
               --build-arg="TEST_DFLAGS=${test_dflags}" \
               -o . #-q &>/dev/null
               #--target=builder -t temp

            # "${LDC}" --conf=../build/bin/ldc -c --mtriple="${triple}" ${dflags} "${target}.d" --of=a.o
            bat -P stdout.log stderr.log exitcode.log
            echo "Press enter to run the next test"
            read
            clear
            clean
        done
    done
done
