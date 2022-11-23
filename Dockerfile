ARG MINIZINCVERSION=2.6.4

FROM ubuntu:20.04 as base
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y \
    build-essential \
    cmake

FROM base AS with_built_libminizinc
# Install MiniZinc
ARG MINIZINCVERSION
ARG MINIZINC_DIR="/MiniZincIDE-${MINIZINCVERSION}-bundle-linux-x86_64/"
ADD https://github.com/MiniZinc/MiniZincIDE/releases/download/${MINIZINCVERSION}/MiniZincIDE-${MINIZINCVERSION}-bundle-linux-x86_64.tgz MiniZincIDE-${MINIZINCVERSION}-bundle-linux-x86_64.tgz
RUN tar xf MiniZincIDE-${MINIZINCVERSION}-bundle-linux-x86_64.tgz && \
    rm MiniZincIDE-${MINIZINCVERSION}-bundle-linux-x86_64.tgz && \
    rm "${MINIZINC_DIR}/share/minizinc/solvers/chuffed.msc"

FROM base AS with_built_chuffed
COPY ./chuffed /chuffed
WORKDIR /
RUN mkdir chuffed/build
WORKDIR /chuffed/build
# Install prefix can also be ex: /usr/local/share/minizinc/solvers
RUN cmake .. && \
    cmake --build . -j $(nproc)

FROM base AS with_installed_mz_chuffed_with_problems
ARG MINIZINCVERSION
ARG MINIZINC_DIR="/MiniZincIDE-${MINIZINCVERSION}-bundle-linux-x86_64/"
COPY --from=with_built_libminizinc ${MINIZINC_DIR} ${MINIZINC_DIR}
ENV PATH="/${MINIZINC_DIR}/bin:${PATH}"

COPY --from=with_built_chuffed /chuffed /chuffed
WORKDIR /chuffed/build
RUN cmake --build . --target install

COPY ./problems /problems
WORKDIR /problems
CMD [ "minizinc", "sugiyama2.mzn", "g4_7_7_7_7.dzn", "--solver", "org.chuffed.chuffed" ]
