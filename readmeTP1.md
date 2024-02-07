# TP1

# Build : 
```docker build . -t tp1_bdd```

run : 
```
docker run -p 15432:5432 --name tp1_bdd tp1_bdd

create network
docker network create app-network
```

## restart the admiter:
```
docker run \
    -p "8088:8080" \
    --net=app-network \
    --name=adminer \
    -d \
    adminer
```

Thanks to admiter, I can administrate the db by login in using : 
- Postgres
- tp1_bdd:5432
- usr
- pwd
- db

## Update dockerfile to initiate DB with data : 
```COPY *.sql /docker-entrypoint-initdb.d```

then restart the db : 
```docker run -p 15432:5432 --name tp1_bdd --network app-network tp1_bdd```

## Volume : 
```sudo docker run -p 15432:5432 -v /opt/data-save:/var/lib/postgresql/data --network app-network -d --name tp1_bdd tp1_bdd```

# JAVA : 

## Write another docker file :
```
FROM maven:latest

COPY Main.class .
RUN java Main 
```

then build with the dockerfile

```docker build -t tp1_java . -f java.dockerfile```

## Compile/Run : 
Compile:

```javac Main.java```

then run with:

```docker run --name tp1_java tp1_java```

You should see "Hello world"

## Spring project: 
after generating the project and build it with the dockerfile in

we can run it with the command below in the simpleapi folder:

```docker run -p 8088:8080 --name tp1_java tp1_java```

## Why do we need a multistage build? And explain each step of this dockerfile.
It's important to multistage build to save more ressources. Using a java project as an exemple, multistage build will take a jdk and a jre, use the jdk to compile and then get rid of it to keep only the essential part witch is the .jar and the jre to execute it so it save space.

Contrary to a basic build that will keep all the resources from the build for the execution. 

## Backend API
To link the database, we need to edit application.yml:

```yaml
spring:
  jpa:
    properties:
      hibernate:
        jdbc:
          lob:
            non_contextual_creation: true
    generate-ddl: false
    open-in-view: true
  datasource:
    url: jdbc:postgresql://tp1_bdd:5432/db
    username: usr
    password: pwd
    driver-class-name: org.postgresql.Driver
management:
 server:
   add-application-context-header: false
 endpoints:
   web:
     exposure:
       include: health,info,env,metrics,beans,configprops
```

Then, go into the right folder and :

```docker run -p 8088:8080 --name tp1_java --network app-network tp1_java```

# HTTP : 
after creating a folder with a dockerfile and an another folder containing our index.html we can build and run : 

```
docker build -t http . -f http.dockerfile
docker run -p 80:80 --name frontend --network app-network frontend
```

Reverse proxy : 
Add a conf file httpd.conf at the base of the folder http :

```
<VirtualHost *:80>
ProxyPreserveHost On
ProxyPass / http://tp1_java:8080/
ProxyPassReverse / http://tp1_java:8080/
</VirtualHost>
LoadModule proxy_module modules/mod_proxy.so
LoadModule proxy_http_module modules/mod_proxy_http.so
```

then modify the docker file :
```docker
FROM httpd:latest

COPY ./httpd.conf /usr/local/apache2/conf/httpd-custom.conf
COPY ./public-html/ /usr/local/apache2/htdocs/

RUN echo "Include ./conf/httpd-custom.conf" >> /usr/local/apache2/conf/httpd.conf
```

## Docker compose: 

```yaml
version: '3.7'

services:
    backend:
      container_name: backend
      build:
        context: ./simple-api-student
        dockerfile: java.dockerfile
      networks:
        - my-network
      depends_on:
        - database

    database:
      container_name: database
      build:
        context: .
        dockerfile: Dockerfile
      volumes:
        - db:/var/lib/postgresql/data
      networks:
        - my-network

    httpd:
      container_name: frontend
      build:
        context: ./web
        dockerfile: front.dockerfile
      ports:
        - '80:80'
      networks:
        - my-network
      depends_on:
        - backend

networks:
    my-network:

volumes:
  db:
```

After that, you build and run the compose file with:

```docker compose build && docker compose up -d```

## Document docker-compose most important commands.
- ```docker compose build``` => build your containers and gather all informations necessary

- ```docker compose up -d``` => mount the containers and run them

## Document your docker-compose file.
we use 3 services inside a network and a volume for the database. Each service is link to a dockerfile, a context, a network and also if necessary a dependence.