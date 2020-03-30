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