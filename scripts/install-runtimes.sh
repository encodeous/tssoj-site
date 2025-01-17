apt-get update && \
 echo deb http://deb.debian.org/debian/ stretch main > /etc/apt/sources.list.d/stretch.list && \
    echo deb http://security.debian.org/debian-security stretch/updates main >> /etc/apt/sources.list.d/stretch.list && \
    echo deb http://deb.debian.org/debian/ experimental main > /etc/apt/sources.list.d/experimental.list && \
    echo deb http://ftp.de.debian.org/debian sid main >> /etc/apt/sources.list && \
    apt-get install -y --no-install-recommends \
        curl file gcc g++ python3-pip python3-dev python3-setuptools python3-wheel cython3 libseccomp-dev bzip2 gzip \
        python2 fp-compiler libxtst6 libffi8 tini $([ "$(arch)" = aarch64 ] && echo binutils-arm-linux-gnueabihf) && \
    apt-get install -y -t stretch --no-install-recommends openjdk-8-jdk-headless openjdk-8-jre-headless && \
    apt-get install -y -t experimental --no-install-recommends g++-11 && \
    useradd -m judge && \
    apt-get install -y --no-install-recommends \
        jq apt-transport-https dirmngr gnupg ca-certificates \
        openjdk-17-jdk-headless clang ghc golang racket ruby scala nasm $([ "$(arch)" = x86_64 ] && echo libc6-dev-i386) && \
    ( \
        apt-get install -y --no-install-recommends make m4 patch unzip libgmp-dev && \
        bash -c 'echo | sh <(curl -sL https://raw.githubusercontent.com/ocaml/opam/master/shell/install.sh) --no-backup' && \
        runuser -u judge -- opam init --shell-setup --disable-sandboxing -j$(nproc) && \
        runuser -u judge -- opam install -y -j$(nproc) base core stdio zarith && \
        runuser -u judge -- opam clean && rm -rf ~judge/.opam/repo \
    ) && \
    if [ "$(arch)" = x86_64 ]; then PYPY_ARCH=linux64; else PYPY_ARCH="$(arch)"; fi && \
    mkdir /opt/pypy2 && curl -L "$(curl https://www.pypy.org/download.html | grep "/pypy2.*$PYPY_ARCH" | head -n1 | cut -d'"' -f4)" | \
        tar xj -C /opt/pypy2 --strip-components=1 && /opt/pypy2/bin/pypy -mcompileall && \
    rm -f /opt/pypy2/bin/python* && \
    mkdir /opt/pypy3 && curl -L "$(curl https://www.pypy.org/download.html | grep "/pypy3.*$PYPY_ARCH" | head -n1 | cut -d'"' -f4)" | \
        tar xj -C /opt/pypy3 --strip-components=1 && /opt/pypy3/bin/pypy -mcompileall && \
    rm -f /opt/pypy3/bin/python* && \
    runuser judge -c 'curl https://sh.rustup.rs -sSf | sh -s -- -y' && \
        mkdir rust && ( \
            cd rust && \
            curl -sL https://raw.githubusercontent.com/DMOJ/judge/master/dmoj/executors/RUST.py | \
                sed '/^CARGO_TOML/,/^"""/!d;//d' > Cargo.toml && \
            curl -sL https://raw.githubusercontent.com/DMOJ/judge/master/dmoj/executors/RUST.py | \
                sed '/^CARGO_LOCK/,/^"""/!d;//d' > Cargo.lock && \
            mkdir src && \
            curl -sL https://raw.githubusercontent.com/DMOJ/judge/master/dmoj/executors/RUST.py | \
                sed '/^HELLO_WORLD_PROGRAM/,/^"""/!d;//d' > src/main.rs && \
            chown -R judge: . && \
            runuser -u judge /home/judge/.cargo/bin/cargo fetch \
        ) && \
        rm -rf rust && \
    if [ "$(arch)" = x86_64 ]; then curl -L -odmd.deb "$(curl -s https://dlang.org/download.html | perl -ne 'if(/"([^"~]*_amd64.deb)/){print $1;exit}')" && \
        apt install ./dmd.deb && rm dmd.deb; fi && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
    echo "deb https://download.mono-project.com/repo/debian stable-buster main" > \
        /etc/apt/sources.list.d/mono-official-stable.list && \
    curl https://dmoj.ca/dmoj-apt.key | apt-key add - && \
    echo 'deb https://apt.dmoj.ca/ bullseye main' > /etc/apt/sources.list.d/dmoj.list && \
    (echo 'Package: *'; echo 'Pin: origin download.mono-project.com'; echo 'Pin-Priority: 990') > /etc/apt/preferences.d/mono && \
    apt-get update && \
    (cd /tmp && \
        apt download mono-roslyn && \
        dpkg-deb -R mono-roslyn_*.deb roslyn/ && \
        sed -i -e '/^Conflicts: chicken-bin/d' roslyn/DEBIAN/control && \
        dpkg-deb -b roslyn mono-roslyn_no_conflict.deb && \
        apt-get install -y --no-install-recommends mono-devel && \
        dpkg -i mono-roslyn_no_conflict.deb) && \
    apt-get install -y --no-install-recommends mono-vbnc fsharp v8dmoj && \
    dpkg-divert --package mono-roslyn --divert /usr/bin/chicken-csc --rename /usr/bin/csc && \
    dpkg-divert --package mono-roslyn --divert /usr/bin/chicken-csi --rename /usr/bin/csi && \
    apt-get install -y --no-install-recommends chicken-bin