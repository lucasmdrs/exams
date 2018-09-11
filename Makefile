build:
	docker build -t pagarme:hello .

run: build
	docker run -d --rm --name hello -p 8080:8080 pagarme:hello && docker logs -f hello
  
deploy: build
  
