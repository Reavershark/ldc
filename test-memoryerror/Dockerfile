# syntax=docker.io/docker/dockerfile:1.12.1-labs

ARG HOST_PLATFORM
ARG TARGET_PLATFORM


FROM --platform="${HOST_PLATFORM}" debian:bookworm AS builder

# Build host ldc
RUN apt-get update
RUN apt-get install -y build-essential cmake ninja-build llvm-15-dev gdc gdmd
WORKDIR /ldc
COPY --exclude=test-memoryerror . . 
RUN cmake -S . -B build -G Ninja \
    -DCMAKE_C_COMPILER=gcc \
    -DCMAKE_CXX_COMPILER=g++ \
    -DLLVM_ROOT_DIR=/usr/lib/llvm15
RUN cmake --build build

# Build target druntime and phobos
ARG TARGET_CC_PACKAGE
RUN apt-get install -y "${TARGET_CC_PACKAGE}"
ARG TARGET_CC
ENV CC="${TARGET_CC}"
ARG TARGET_TRIPLE
RUN ./build/bin/ldc-build-runtime \
    --buildDir="build-runtime" \
    --ninja \
    --ldcSrcDir="." \
    --dflags="--mtriple=${TARGET_TRIPLE}"

# Build test file
WORKDIR /test
COPY test-memoryerror/*.d .
ARG TEST_FILE
ARG TEST_DFLAGS
RUN /ldc/build/bin/ldc2 \
    --conf= \
    -I/ldc/runtime/druntime/src \
    -I/ldc/build/runtime/import \
    -I/ldc/runtime/jit-rt/d \
    -I/ldc/runtime/phobos \
    --mtriple="${TARGET_TRIPLE}" \
    /ldc/build-runtime/lib/libdruntime-ldc.a \
    /ldc/build-runtime/lib/libphobos2-ldc.a \
    "${TEST_FILE}" \
    ${TEST_DFLAGS} \
    --of=a.out


FROM --platform="${TARGET_PLATFORM}" debian:bookworm AS runner
COPY --from=builder /test/a.out /a.out
RUN /a.out 1>stdout.log 2>stderr.log ; echo $? > exitcode.log


FROM scratch AS artifact
COPY --from=runner /*.log /
