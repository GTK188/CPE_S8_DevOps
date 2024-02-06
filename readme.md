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
          java-version: 17
          distribution: 'temurin'

     #finally build your app with the latest command
      - name: Build and test with Maven
        run: mvn clean verify --file simple-api-student/pom.xml
```

On teste la pipeline dans github actions:
![Workflow CI passé](CI_test_good.png)

## CD
