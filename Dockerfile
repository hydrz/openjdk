FROM openjdk:8-jdk

LABEL maintainer="hydrz <n.haoyuan@gmail.com>"

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 修改aliyun源镜像
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/' /etc/apt/sources.list
RUN sed -i 's/security.debian.org/mirrors.aliyun.com/' /etc/apt/sources.list

RUN \
    apt-get -q update \
    && apt-get -y -q --no-install-recommends install \
    net-tools \
    telnet \
    vim \

    # cleanup package manager caches
    && apt-get clean \
    && rm /var/lib/apt/lists/*_*

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