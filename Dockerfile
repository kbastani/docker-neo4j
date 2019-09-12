#
# Dockerizing Neo4j graph database (http://www.github.com/kbastani/docker-neo4j)
#
FROM neo4j:3.5.9
MAINTAINER K.B. Name <kb@socialmoon.com>

ADD plugins /plugins
ADD conf/neo4j /var/lib/neo4j/conf

ENV NEO4J_AUTH=none
ENV HDFS_HOST=hdfs://hdfs:9000

EXPOSE 7474
EXPOSE 7687
EXPOSE 1337

COPY sbin/bootstrap.sh /etc/bootstrap.sh
RUN chown root:root /etc/bootstrap.sh && \
    chmod 777 /etc/bootstrap.sh

RUN mkdir /import

# Mount a volume for persistent data
VOLUME /opt/data

# Set the bootstrap script on container run
ENV BOOTSTRAP /etc/bootstrap.sh
ENTRYPOINT ["/etc/bootstrap.sh"]
