#
# Dockerizing Neo4j graph database (http://www.github.com/neo4j-contrib/docker-neo4j)
#
FROM       dockerfile/ubuntu
MAINTAINER K.B. Name <kb@socialmoon.com>

# Install Java.
RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# Update apt-get
RUN apt-get update
RUN apt-get upgrade -y

# Install wget
RUN echo "Installing wget..."
RUN apt-get -y -qq install wget

# Install Neo4j
RUN echo "Installing Neo4j..."
RUN wget -O - http://debian.neo4j.org/neotechnology.gpg.key| apt-key add - # Import our signing key
RUN echo 'deb http://debian.neo4j.org/repo stable/' > /etc/apt/sources.list.d/neo4j.list # Create an Apt sources.list file
RUN apt-get -qq update # Find out about the files in our repository
RUN apt-get -qq -y install neo4j # Install Neo4j, community edition

# Override Neo4j configuration files
WORKDIR /etc/neo4j

# Configure to enable connection requests from outside container
RUN cat neo4j-server.properties | sed "s/#org.neo4j.server.webserver.address/org.neo4j.server.webserver.address/g" > neo4j-server.properties.open && mv neo4j-server.properties.open neo4j-server.properties

# Set the default graph.db database location to the docker share from local user `neo4j-community-2.1.5/data` to container `/opt/data`
# To run app container: $ docker run -d -P --name neo4j -v /neo4j/neo4j-community-2.1.5/data:/opt/data kbastani/docker-neo4j
RUN cat neo4j-server.properties | sed "s/org.neo4j.server.database.location=data\/graph.db/org.neo4j.server.database.location=\/opt\/data\/graph.db/g" > neo4j-server.properties.open && mv neo4j-server.properties.open neo4j-server.properties

# Copy the bootstrap shell script and set permissions
COPY sbin/bootstrap.sh /etc/bootstrap.sh
RUN chown root:root /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh

# Expose the Neo4j browser to the host OS on port 7474
EXPOSE 7474

# Set the bootstrap script on container run
ENV BOOTSTRAP /etc/bootstrap.sh
CMD ["/etc/bootstrap.sh", "-d"]
