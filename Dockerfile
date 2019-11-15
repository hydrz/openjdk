FROM buildpack-deps:stretch-scm

LABEL maintainer="hydrz <n.haoyuan@gmail.com>"

RUN echo "Asia/Shanghai" > /etc/timezone
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 修改aliyun源镜像
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/' /etc/apt/sources.list
RUN sed -i 's/security.debian.org/mirrors.aliyun.com/' /etc/apt/sources.list

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    bzip2 \
    unzip \
    xz-utils \
    \
    # utilities for keeping Debian and OpenJDK CA certificates in sync
    ca-certificates p11-kit \
    \
    # java.lang.UnsatisfiedLinkError: /usr/local/openjdk-11/lib/libfontmanager.so: libfreetype.so.6: cannot open shared object file: No such file or directory
    # java.lang.NoClassDefFoundError: Could not initialize class sun.awt.X11FontManager
    # https://github.com/docker-library/openjdk/pull/235#issuecomment-424466077
    fontconfig libfreetype6 \
    tcpdump \
    net-tools \
    telnet \
    vim \
    ; \
    rm -rf /var/lib/apt/lists/*

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

ENV JAVA_HOME /usr/local/openjdk-8
ENV PATH $JAVA_HOME/bin:$PATH

# backwards compatibility shim
RUN { echo '#/bin/sh'; echo 'echo "$JAVA_HOME"'; } > /usr/local/bin/docker-java-home && chmod +x /usr/local/bin/docker-java-home && [ "$JAVA_HOME" = "$(docker-java-home)" ]


ENV JAVA_URL https://nan-files.oss-cn-hangzhou.aliyuncs.com/jdk-8u231-linux-x64.tar.gz

RUN set -eux; \
    \
    wget -O openjdk.tgz "${JAVA_URL}" --progress=dot:giga; \
    \
    mkdir -p "$JAVA_HOME"; \
    tar --extract \
    --file openjdk.tgz \
    --directory "$JAVA_HOME" \
    --strip-components 1 \
    --no-same-owner \
    ; \
    rm openjdk.tgz*; \
    \
    # https://github.com/docker-library/openjdk/issues/331#issuecomment-498834472
    find "$JAVA_HOME/lib" -name '*.so' -exec dirname '{}' ';' | sort -u > /etc/ld.so.conf.d/docker-openjdk.conf; \
    ldconfig; \
    \
    # basic smoke test
    javac -version; \
    java -version

WORKDIR /root

COPY wait-for-it.bash ./
COPY docker-entrypoint.bash ./
COPY setup-env.d ./setup-env.d/
COPY shutdown ./shutdown/
ADD app.jar ./app.jar

# arthas
COPY --from=hengyunabc/arthas:3.1.3-no-jdk /opt/arthas ./arthas

RUN chmod +x ./docker-entrypoint.bash ./shutdown/*.bash ./setup-env.d/*.bash ./arthas/*.sh

ENTRYPOINT ["./docker-entrypoint.bash"]

CMD ["java", "-jar", "app.jar"]