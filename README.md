# Neo4j Community Edition 2.2.3

This repository contains a Docker image of the latest version (2.2.3) of the [Neo4j community server](http://www.neo4j.com/download). This Docker image of Neo4j provides instructions on how to map a Docker data volume to an already existing `data/graph.db` store file located on your host machine.

# What is Neo4j?

Sponsored by Neo Technology, Neo4j is an open-source NoSQL graph database implemented in Java and Scala. With development starting in 2003, it has been publicly available since 2007. The source code and issue tracking are available on GitHub, with support readily available on Stack Overflow and the Neo4j Google group. Limited only by hardware, Neo4j is used today by hundreds of thousands of users in almost all industries. Use cases include matchmaking, network management, software analytics, scientific research, routing, organizational and project management, recommendations, social networks, and more.

# Build Docker Image

To build the source from the Dockerfile as an image:

```
docker build -t kbastani/docker-neo4j .
```

# Pull Docker Image

This image is automatically built and is available from the Docker registry. Use the following `pull` command to download the image to your local Docker server.

```
docker pull kbastani/docker-neo4j
```

# Start Neo4j Container

To run the Neo4j image inside a container after either building it or pulling it, run the following docker command.

```
docker run -d -p 7474:7474 -v /Users/<user>/path/to/neo4j/data:/opt/data --name graphdb kbastani/docker-neo4j
```

Make sure to replace the `<user>` with the user directory that contains your Neo4j `graph.db` data store files.

Keep in mind that store upgrades are not enabled in the Neo4j configuration by default. The data store version of your Neo4j files on your host machine must be equal to the latest release of Neo4j at the time of building this image.

The `/path/to/neo4j/data` should be the relative path from your host machine's user home directory to `neo4j-community-#.#.#/data` directory that has the `graph.db` database you want to mount to the docker container as a volume.

## boot2docker

If you're using `boot2docker` on Mac OS X then you'll need to do the following steps to access the Neo4j browser on the host machine.

### Add a route to the container

```
$ sudo route add -net 172.17.0.0/16 $(boot2docker ip 2> /dev/null)
```

This command adds a route from the `graphdb` container's IP (internal), to the VirtualBox `boot2docker` VM server IP (external).

Now we need to get the internal IP of the container. Run the following command:

```
$ docker inspect --format="{{.NetworkSettings.IPAddress}}" graphdb
172.17.0.16
```

Now that we know what the internal IP address is of the `graphdb` container, we can access it from the browser or via `curl`.

```
$ curl 172.17.0.16:7474
{
  "management" : "http://172.17.0.16:7474/db/manage/",
  "data" : "http://172.17.0.16:7474/db/data/"
}%
```

### Add a host name

All that is left now is to map the container's IP to a host name on the host machine. I've chosen `graphdb`, however, you're free to map it to whatever host name you'd prefer (except for localhost).

```
echo 172.17.0.16 graphdb | sudo tee -a /etc/hosts
```

The Neo4j server container is now accessible on your host machine with the following URL.

```
http://graphdb:7474/browser
```

### Alternative approach for Mac OS X: Use boot2docker ip

If you don't want to set up a route, you can just use the boot2docker ip to connect to the container.

```bash
boot2docker ip  # usually returns 192.168.59.103
```

The container can be reached from the host via the IP above. Try to access neo4j via your browser `http://192.168.59.103:7474` or via `curl`
```bash
$ curl 192.168.59.103:7474
{
  "management" : "http://172.17.0.16:7474/db/manage/",
  "data" : "http://172.17.0.16:7474/db/data/"
}%
```
