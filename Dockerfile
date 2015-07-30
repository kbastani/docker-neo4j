#
# Dockerizing Neo4j graph database (http://www.github.com/kbastani/docker-neo4j)
#
FROM       java:openjdk-8-jdk
MAINTAINER K.B. Name <kb@socialmoon.com>

ENV HDFS_HOST hdfs://hdfs:9000

ENV NEO4j_VERSION community-2.2.3
#ENV NEO4j_VERSION enterprise-2.2.3

# Install Neo4j
RUN apt-get update && \
    apt-get install -y wget
RUN wget -q -O /tmp/neo4j-$NEO4j_VERSION-unix.tar.gz http://dist.neo4j.org/neo4j-$NEO4j_VERSION-unix.tar.gz && \
    tar -zxf /tmp/neo4j-$NEO4j_VERSION-unix.tar.gz -C /var/lib && \
    ln -s /var/lib/neo4j-$NEO4j_VERSION /var/lib/neo4j && \
    wget -q -O /var/lib/neo4j/lib/gson-2.2.4.jar http://search.maven.org/remotecontent?filepath=com/google/code/gson/gson/2.2.4/gson-2.2.4.jar

WORKDIR /var/lib/neo4j

# Copy graph analytics plugin
COPY plugins /var/lib/neo4j/plugins

# Copy configurations
COPY conf/neo4j /var/lib/neo4j/conf

# Copy the bootstrap shell script and set permissions
COPY sbin/bootstrap.sh /etc/bootstrap.sh
RUN chown root:root /etc/bootstrap.sh && \
    chmod 700 /etc/bootstrap.sh

# Customize configurations
RUN apt-get clean && \
    sed -i "s|data/graph.db|/opt/data/graph.db|g" /var/lib/neo4j/conf/neo4j-server.properties && \
    sed -i "s|dbms.security.auth_enabled=true|dbms.security.auth_enabled=false|g" /var/lib/neo4j/conf/neo4j-server.properties && \
    sed -i "s|#org.neo4j.server.webserver.address|org.neo4j.server.webserver.address|g" /var/lib/neo4j/conf/neo4j-server.properties && \
    sed -i "s|#org.neo4j.server.thirdparty_jaxrs_classes=org.neo4j.examples.server.unmanaged=/examples/unmanaged|org.neo4j.server.thirdparty_jaxrs_classes=extension=/service|g" /var/lib/neo4j/conf/neo4j-server.properties

# Expose the Neo4j browser to the host OS on port 7474 and 1337
EXPOSE 7474
EXPOSE 1337

# Mount a volume for persistent data
VOLUME /opt/data

# Set the bootstrap script on container run
ENV BOOTSTRAP /etc/bootstrap.sh
CMD ["/etc/bootstrap.sh", "-d"]
