FROM ubuntu:20.04 as base
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y \
    build-essential \
    cmake

FROM base AS with_built_libminizinc
COPY ./libminizinc /libminizinc
RUN mkdir libminizinc/build
WORKDIR /libminizinc/build
RUN cmake -DCMAKE_BUILD_TYPE=Release .. && \
    cmake --build . -j $(nproc)

FROM base AS with_built_chuffed
COPY ./chuffed /chuffed
WORKDIR /
RUN mkdir chuffed/build
WORKDIR /chuffed/build
# Install prefix can also be ex: /usr/local/share/minizinc/solvers
RUN cmake -DCMAKE_INSTALL_PREFIX=/usr/share/minizinc/solvers .. && \
    cmake --build . -j $(nproc)

FROM base AS with_problems
COPY ./problems /problems

FROM base AS with_installed_mz_chuffed_with_problems
COPY --from=with_built_libminizinc /libminizinc /libminizinc
WORKDIR /libminizinc/build
RUN cmake --build . --target install

COPY --from=with_built_chuffed /chuffed /chuffed
WORKDIR /chuffed/build
RUN cmake --build . --target install

COPY --from=with_problems /problems /problems
WORKDIR /problems
CMD [ "minizinc", "sugiyama2.mzn", "g4_7_7_7_7.dzn", "--solver", "org.chuffed.chuffed" ]