### DevOps @ Pagar.me

The challenge purpose it's to demonstrate the knowledge in automation tools (aka "dev laziness"), respecting the following requirements:

 - building a simple web application;
 - run with docker;
 - make the container app run with a small and simple command;
 - deploy the app to AWS , also with a small and simple command;

To fulfill those requirements I've choosed the following setup:

 - A simple "Hello world" with Golang;
 - No mutch to say, just a multi stage build with a official Golang docker image and Alpine;
 - I believe the challenge's author was trying to enforce the use of docker-compose, but a Makefile could also do the job as there is only one container to run;
 - Again the author enforce the existence of tools witch already exists, by mentioning the Hashicorp products. They are awesome but maybe Cloudformation could be a good choice.In terms of how to provision I've thought about using AWS's Fargate, all tho I'm not familiar with, it seems smaller then the other options;

### The App
```go
package main

import (
	"fmt"
	"log"
	"net/http"
)

func main() {
  // Using the HandleFunc from the net/http library
  // to respond "Hello World" in the root request "/"
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprint(w, "Hello World")
	})

  // Starting a http server on port 8080 and wrapping with a logger
	log.Fatal(http.ListenAndServe(":8080", nil))
}
```

Very simple example of an web app.

### The Dockerfile

```Dockerfile
# Using multi-stage build to avoid all the unecessary stuff
# as the result it's a binary executable
FROM golang:1.10.1-alpine as builder
WORKDIR /go/src/github.com/lucasmdrs/exams

COPY main.go .

# Add git dependecy to use go get to retrieve any external libraries.
# In this example it may not be necessary as all libs are native
# And I could use dep to lock dependencies, but again, trying to keep simple.
RUN apk add git --no-cache \
    && go get . \
    && GOOS=linux go build -o hello

# The final image using Alpine, not absoutelly empty image
# but really small one.
FROM alpine:3.7

# Following some docker best practices by using a non-priviledge user
RUN addgroup -S pagarme && adduser -S -g pagarme pagarme
EXPOSE 8080
USER pagarme
COPY --from=builder /go/src/github.com/lucasmdrs/exams/hello /usr/bin/hello

CMD ["hello"]
```

To create our docker image

### Docker-compose / Makefile
```yaml
# Using version 3 allow us to leaverage Docker Swarm (if necessary)
version: '3'

services:

  hello:
    # build the image from local Dockerfile
    build: .
    # maps the app port with the host (both on 8080)
    ports:
     - "8080:8080"
```

Just run `docker-compose up` and go to your localhost:8080.
With you don't wanna get stuck with the logs, run `docker-compose up -d` instead.

**Important:** Remember to use `--build` on your `docker-compose` command if you made any changes in the app.

```Makefile
build:
	docker build -t pagarme:hello .

run: build
	docker run -d --rm --name hello -p 8080:8080 pagarme:hello && docker logs -f hello
  
deploy: build
```

Use `make build` to build the app container;
Use `make run` to build and start the docker container;
Use `make deploy` to build and deploy the application to AWS;

### The AWS Deployment
