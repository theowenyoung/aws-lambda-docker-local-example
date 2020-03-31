# AWS Lambda Docker Local Development

## About <a name = "about"></a>

Docker-only local lambda development environment with [docker lambda](https://hub.docker.com/r/lambci/lambda/) and   [docker aws-lambda-api-gateway-local](https://hub.docker.com/repository/docker/owenyoung/aws-lambda-api-gateway-local)


### Prerequisites

- Docker && Docker Compose
- Environment Variables AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY (Only need when deploy)

You should set up the aws credentials environment variables.

To set these variables on Linux or macOS, use the export command:

```
export AWS_ACCESS_KEY_ID=your_access_key_id
export AWS_SECRET_ACCESS_KEY=your_secret_access_key
```

To set these variables on Windows, use the set command:

```
set AWS_ACCESS_KEY_ID=your_access_key_id
set AWS_SECRET_ACCESS_KEY=your_secret_access_key
```

## Getting Started <a name = "getting_started"></a>

### 1. Init A New Lambda Nodejs Function

```
docker run -it -v ${PWD}:/var/task lambci/lambda:build-nodejs12.x sh -c "sam init"
```

### 2. Create docker-compose.yaml

Create a docker-compose.yaml in your inited folder:

> Instead your runtime and build image, for me, it's `lambci/lambda:nodejs12.x` and `lambci/lambda:build-nodejs12.x`, and define the runtime function entry for yours: `hello-world/app.lambdaHandler`

```yaml
version: '3'
services:
  runtime:
    image: lambci/lambda:nodejs12.x
    ports:
      - "9001:9001"
    volumes: 
      - ".:/var/task:ro,delegated"
    environment:
        DOCKER_LAMBDA_WATCH: 1
        DOCKER_LAMBDA_STAY_OPEN: 1
    command: 
      - hello-world/app.lambdaHandler
  api-gateway:
    image: owenyoung/aws-lambda-api-gateway-local
    ports:
      - "3000:3000"
    volumes:
      - ".:/var/task"
    environment:
      LAMBDA_ENDPOINT: "http://runtime:9001"
  build:
    image: lambci/lambda:build-nodejs12.x
    volumes:
      - ".:/var/task:delegated"
    environment:
      - AWS_ACCESS_KEY_ID
      - AWS_SECRET_ACCESS_KEY
    command: 
      - sh
      - -c
      - sam build
```

### 3. Start Developing 

```
docker-compose up runtime api-gateway
```

Now, you can visit your api at: <http://127.0.0.1:3000/hello> (For official sam-app example, you can instead your real path), anything what you changed will trigger the auto reloading.

### 4. Build

```sh
docker-compose run build
```

### 5. Build And deploy

First time for deploy:

```sh
docker-compose run build sh -c "sam build && sam deploy --guided" 
```


```sh
docker-compose run build && docker-compose run build sh -c "sam build && sam deploy"
```

### 6. Create A Makefile To Make Things Easy

For example:

```makefile
.PHONY: start build deploy init-deploy api-sh runtime-sh

start:
	docker-compose up api-gateway runtime
build:
	docker-compose run build
init-deploy:
	docker-compose run build sh -c "sam build && sam deploy --guided" 
deploy:
	docker-compose run build sh -c "sam build && sam deploy"
api-sh:
	docker-compose exec api-gateway /bin/sh
runtime-sh:
	docker-compose exec runtime /bin/sh
```
