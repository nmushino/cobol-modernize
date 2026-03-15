FROM registry.access.redhat.com/ubi9/ubi

RUN dnf install -y \
 gcc \
 make \
 wget \
 tar \
 ncurses-devel \
 gmp-devel \
 libtool \
 diffutils \
 libdb-devel \
 && dnf clean all

WORKDIR /tmp

RUN wget https://ftp.gnu.org/gnu/gnucobol/gnucobol-3.2.tar.gz \
 && tar xzf gnucobol-3.2.tar.gz \
 && cd gnucobol-3.2 \
 && ./configure \
 && make -j4 \
 && make install

ENV LD_LIBRARY_PATH=/usr/local/lib

WORKDIR /app

COPY hello.cbl .

RUN cobc -x hello.cbl -o hello

CMD ["./hello"]
