.PHONY: build build-be build-fe
build: build-be build-fe

build-fe:
	docker run --rm -ti \
		-v "/$(PWD)":/app \
		lsf-node-ci \
		bash -c "cd web_src \
			&& npm --registry=https://registry.npmmirror.com install \
			&& npm run build"

build-be:
	docker run --rm -ti \
		-v "/$(PWD)":/app \
		-v /$(PWD)/.m2/:/root/.m2/ \
		lsf-java-ci \
		bash -c "mvn package"

DEPLOY_DIR:=$(HOME)/repo/gitee/lsf/forward
DEPLOY_DIR_WVP_FE:=$(DEPLOY_DIR)/nginx/html
DEPLOY_DIR_WVP_SQL:=$(DEPLOY_DIR)/mysql/docker-entrypoint-initdb.d
DEPLOY_DIR_WVP_BE:=$(DEPLOY_DIR)/wvp/app
TIMESTAMP:=02011559

.PHONY: deploy
deploy:
	@echo "copy frontend files"
	-rm -rf $(DEPLOY_DIR_WVP_FE) && mkdir -p $(DEPLOY_DIR_WVP_FE)
	cp -rf src/main/resources/static/* $(DEPLOY_DIR_WVP_FE)/
	@echo "copy mysql sql files"
	-rm -rf $(DEPLOY_DIR_WVP_SQL) && mkdir -p $(DEPLOY_DIR_WVP_SQL)
	cp -f 数据库\初始化-mysql.sql $(DEPLOY_DIR_WVP_SQL)
	@echo "copy wvp binary file"
	-rm -rf $(DEPLOY_DIR_WVP_BE) && mkdir -p $(DEPLOY_DIR_WVP_BE)
	cp -f target/wvp-pro-2.7.0-$(TIMESTAMP).jar $(DEPLOY_DIR_WVP_BE)/wvp-pro-2.7.0.jar
