FROM openjdk:8u232-jdk-slim-buster

LABEL maintainer="hydrz <n.haoyuan@gmail.com>"

# 修改aliyun源镜像
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/' /etc/apt/sources.list
RUN sed -i 's/security.debian.org/mirrors.aliyun.com/' /etc/apt/sources.list

# 安装一些常用软件
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    bash \
    libc6 \
    libc-bin \
    openssl \
    wget \
    tcpdump \
    net-tools \
    telnet \
    ntp \
    ; \
    rm -rf /var/lib/apt/lists/*

# 时区
ENV TZ Asia/Shanghai

# NTP
ADD ntp.conf /etc/ntp.conf

WORKDIR /opt

ENV APP_DESTINATION app.jar

ADD docker-entrypoint.bash ./
ADD setup-env.d ./setup-env.d/
ADD shutdown ./shutdown/
ADD app.jar $APP_DESTINATION

# arthas
COPY --from=hengyunabc/arthas:3.1.3-no-jdk /opt/arthas ./arthas

RUN chmod +x ./docker-entrypoint.bash ./shutdown/*.bash ./setup-env.d/*.bash ./arthas/*.sh

ENTRYPOINT ["./docker-entrypoint.bash"]

CMD ["java", "-jar", "app.jar"]