FROM openjdk:8u232-jdk-slim-buster

LABEL maintainer="hydrz <n.haoyuan@gmail.com>"

# 修改aliyun源镜像
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/' /etc/apt/sources.list
RUN sed -i 's/security.debian.org/mirrors.aliyun.com/' /etc/apt/sources.list

# 安装一些常用软件
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    \
    # java.lang.UnsatisfiedLinkError: /usr/local/openjdk-11/lib/libfontmanager.so: libfreetype.so.6: cannot open shared object file: No such file or directory
    # java.lang.NoClassDefFoundError: Could not initialize class sun.awt.X11FontManager
    # https://github.com/docker-library/openjdk/pull/235#issuecomment-424466077
    fontconfig libfreetype6 \
    iputils-ping \
    netcat \
    wget \
    tcpdump \
    net-tools \
    telnet \
    vim \
    ntp \
    ; \
    rm -rf /var/lib/apt/lists/*

# 时区
ENV TZ Asia/Shanghai

# NTP
ADD ntp.conf /etc/ntp.conf

WORKDIR /opt

ENV APP_DESTINATION app.jar

COPY docker-entrypoint.bash /
COPY setup-env.d /setup-env.d/
COPY shutdown/ /shutdown/

ADD app.jar $APP_DESTINATION

# arthas
COPY --from=hengyunabc/arthas:3.1.3-no-jdk /opt/arthas ./arthas

# skywalking
COPY --from=apache/skywalking-base:6.5.0 /skywalking/agent ./skywalking

RUN chmod +x /docker-entrypoint.bash /shutdown/*.bash /setup-env.d/*.bash ./arthas/*.sh

ENTRYPOINT ["/docker-entrypoint.bash"]