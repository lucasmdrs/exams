AWS_REPO:=aws ecr describe-repositories --repository-name pagarme

build:
	docker build -t pagarme:hello .

run: build
	docker run -d --rm --name hello -p 8080:8080 pagarme:hello && docker logs -f hello
  
deploy: build
	`$(AWS_REPO) > /dev/null` || aws ecr create-repository --repository-name pagarme
	aws ecr get-login --no-include-email | sh
	docker tag pagarme:hello `$(AWS_REPO) | jq -r '.repositories[] | .repositoryUri'`:hello 
	docker push `$(AWS_REPO) | jq -r '.repositories[] | .repositoryUri'`:hello
	sed -i "s/REGISTRY_ID/`$(AWS_REPO) | jq -r '.repositories[] | .repositoryUri'| cut -d'.' -f1`/g" fargate.yml
	aws cloudformation create-stack --stack-name pagarme --template-body file://`pwd`/fargate.yml --capabilities CAPABILITY_IAM
	while [[ "CREATE_IN_PROGRESS" == "`aws cloudformation describe-stacks --stack-name pagarme | jq -r '.Stacks[] | .StackStatus'`" ]]; do sleep 1; done
	echo "Deploy finished:"
	aws cloudformation describe-stacks --stack-name pagarme | jq -r '.Stacks[] | .StackStatus'
	aws ec2 describe-network-interfaces | jq -r '.NetworkInterfaces[] | ( .PrivateIpAddresses[] | .Association | .PublicIp ) as $$pIp | "\($$pIp):8080"'

