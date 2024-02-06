# Test application
To build and run the application from the root folder:

```mvn clean verify --file .\simple-api-student\pom.xml```

# What are testcontainers?
Testcontainers are lightweight libraries with an API for completing integration test with services inside containers

## CI
main.yml:
```yaml
name: CI devops 2023
on:
  #to begin you want to launch this job in main and develop
  push:
    branches: [main, develop] 
  pull_request:

jobs:
  test-backend: 
    runs-on: ubuntu-22.04
    steps:
     #checkout your github code using actions/checkout@v2.5.0
      - uses: actions/checkout@v2.5.0

     #do the same with another action (actions/setup-java@v3) that enable to setup jdk 17
      - name: Set up JDK 17
        uses: actions/setup-java@v3
        with:
        #precise java version & distribution (Eclipse Temurin, Oracle JDK, ...)
          java-version: 17
          distribution: 'temurin'

     #finally build your app with the latest command
      - name: Build and test with Maven
        run: mvn clean verify --file simple-api-student/pom.xml
```

We test the workflow in github actions:
![Workflow CI success](CI_test_good.png)

## CD
You add a new job in main.yml workflow file:

```yml
# define job to build and publish docker image
build-and-push-docker-image:
needs: test-backend
# run only when code is compiling and tests are passing
runs-on: ubuntu-22.04

# steps to perform in job
steps:
    - name: Checkout code
    uses: actions/checkout@v2.5.0

    - name: Login to DockerHub
    run: docker login -u ${{ secrets.DOCKERHUB_USERNAME }} -p ${{ secrets.DOCKERHUB_TOKEN }}

    - name: Build image and push backend
    uses: docker/build-push-action@v3
    with:
        # relative path to the place where source code with Dockerfile is located
        context: ./simple-api-student
        # Note: tags has to be all lower-case
        tags: ${{secrets.DOCKERHUB_USERNAME}}/tp2-devops-simple-api:latest
        # build on feature branches, push only on main branch
        push: ${{ github.ref == 'refs/heads/main' }}

    - name: Build image and push database
    uses: docker/build-push-action@v3
    with:
        context: ./db

        tags: ${{secrets.DOCKERHUB_USERNAME}}/tp2-devops-database:latest
        push: ${{ github.ref == 'refs/heads/main' }}

    - name: Build image and push httpd
    uses: docker/build-push-action@v3
    with:
        context: ./web

        tags: ${{secrets.DOCKERHUB_USERNAME}}/tp2-devops-front:latest
        push: ${{ github.ref == 'refs/heads/main' }}
```

We test the workflow again in github actions:
![Workflow CD success](CD_test_good.png)

# Sonar
After creating the organisation on SonarCloud, you edit the build and test job in the workflow file:

```yml
run: mvn -B verify sonar:sonar -Dsonar.projectKey=GTK188_CPE_S8_DevOps -Dsonar.organization=gtk188 -Dsonar.host.url=https://sonarcloud.io -Dsonar.login=${{ secrets.SONAR_TOKEN }}  --file ./simple-api-student/pom.xml
```

A SonarCloud analysis report should appear:
![SonarCloud report](Sonar_result.png)
