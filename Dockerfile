FROM debian:stretch AS buildImage

ENV HADOOP_VERSION=3.0.3
ENV HADOOP_PACKAGE=hadoop-${HADOOP_VERSION}
ENV SPARK_VERSION=2.4.0
ENV SCALA_VERSION=-scala-2.12
ENV SPARK_PACKAGE=spark-${SPARK_VERSION}-bin-without-hadoop${SCALA_VERSION}

RUN apt-get update \
    && apt-get install -y curl \
    && echo "get hadoop from http://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/${HADOOP_PACKAGE}.tar.gz" \
    && curl -sL --retry 3 "http://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/${HADOOP_PACKAGE}.tar.gz" | gunzip | tar -x -C /tmp \
    && echo "get spark from https://www.apache.org/dyn/mirrors/mirrors.cgi?action=download&filename=spark/spark-${SPARK_VERSION}/${SPARK_PACKAGE}.tgz" \
    && curl -sL --retry 3 "https://www.apache.org/dyn/mirrors/mirrors.cgi?action=download&filename=spark/spark-${SPARK_VERSION}/${SPARK_PACKAGE}.tgz" | gunzip | tar -x -C /tmp
    

FROM openjdk:8-alpine
MAINTAINER Previmedical

ENV HADOOP_VERSION=3.0.3
ENV HADOOP_PACKAGE=hadoop-${HADOOP_VERSION}
ENV SPARK_VERSION=2.4.0
ENV SCALA_VERSION=-scala-2.12
ENV SPARK_PACKAGE=spark-${SPARK_VERSION}-bin-without-hadoop${SCALA_VERSION}

RUN apk add --no-cache bash tini libc6-compat \
    && mkdir -p /opt/spark/work-dir

COPY --from=buildImage /tmp/${SPARK_PACKAGE}/bin /opt/spark/bin/
COPY --from=buildImage /tmp/${SPARK_PACKAGE}/sbin /opt/spark/sbin/
COPY --from=buildImage /tmp/${SPARK_PACKAGE}/jars /opt/spark/jars/
COPY --from=buildImage /tmp/${SPARK_PACKAGE}/kubernetes/dockerfiles/spark/entrypoint.sh /opt/entrypoint.sh
COPY --from=buildImage /tmp/${HADOOP_PACKAGE}/share/hadoop/common/lib /opt/spark/jars/
COPY --from=buildImage /tmp/${HADOOP_PACKAGE}/share/hadoop/common/*.jar /opt/spark/jars/
COPY --from=buildImage /tmp/${HADOOP_PACKAGE}/share/hadoop/hdfs/lib /opt/spark/jars/
COPY --from=buildImage /tmp/${HADOOP_PACKAGE}/share/hadoop/hdfs/*.jar /opt/spark/jars/
COPY --from=buildImage /tmp/${HADOOP_PACKAGE}/share/hadoop/yarn/lib /opt/spark/jars/
COPY --from=buildImage /tmp/${HADOOP_PACKAGE}/share/hadoop/yarn/*.jar /opt/spark/jars/
COPY --from=buildImage /tmp/${HADOOP_PACKAGE}/share/hadoop/mapreduce/lib /opt/spark/jars/
COPY --from=buildImage /tmp/${HADOOP_PACKAGE}/share/hadoop/mapreduce/*.jar /opt/spark/jars/
COPY --from=buildImage /tmp/${HADOOP_PACKAGE}/share/hadoop/tools/lib /opt/spark/jars/

ENV SPARK_HOME=/opt/spark
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$SPARK_HOME/sbin:$SPARK_HOME/bin

VOLUME /opt/spark/work-dir

WORKDIR /opt/spark/work-dir

EXPOSE 4040
EXPOSE 8080
EXPOSE 8081
EXPOSE 7077
EXPOSE 6066

ENTRYPOINT [ "/opt/entrypoint.sh" ]
