FROM openjdk:8-jdk

LABEL maintainer="hydrz <n.haoyuan@gmail.com>"

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 修改aliyun源镜像
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/' /etc/apt/sources.list

WORKDIR /opt

COPY wait-for-it.bash ./
COPY docker-entrypoint.bash ./
COPY setup-env.d ./setup-env.d/
COPY shutdown ./shutdown/
ADD app.jar ./app.jar

# arthas
COPY --from=hengyunabc/arthas:3.1.3-no-jdk /opt/arthas ./arthas

ENTRYPOINT ["./docker-entrypoint.bash"]

CMD ["java", "-jar", "app.jar"]