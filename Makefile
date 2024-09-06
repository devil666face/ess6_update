.DEFAULT_GOAL := help
PROJECT_BIN = $(shell pwd)/bin
$(shell [ -f bin ] || mkdir -p $(PROJECT_BIN))
GOBIN = /home/a.kalinkin/dev/go/go/bin/go
PATH := $(PROJECT_BIN):$(PATH)
GOARCH = amd64
LINUX_LDFLAGS = -extldflags '-static' -w -s -buildid=
WINDOWS_LDFLAGS = -extldflags '-static' -w -s -buildid=
GCFLAGS = "all=-trimpath=$(shell pwd) -dwarf=false -l"
ASMFLAGS = "all=-trimpath=$(shell pwd)"
APP = drw6

build: build-windows .crop ## Build all

release: build-windows .crop zip ## Build release

zip:
	rm -rf repository/10-drwbases/common/*
	cp $(PROJECT_BIN)/$(APP).exe .
	tar -cvzf $(PROJECT_BIN)/$(APP).tar.gz $(APP).exe repository
	rm $(APP).exe

docker: ## Build with docker
	docker compose up --build --force-recreate || docker-compose up --build --force-recreate


build-windows: ## Build for windows
	CGO_ENABLED=0 GOOS=windows GOARCH=$(GOARCH) \
	  $(GOBIN) build -ldflags="$(WINDOWS_LDFLAGS)" -trimpath -gcflags=$(GCFLAGS) -asmflags=$(ASMFLAGS) \
	  -o $(PROJECT_BIN)/$(APP).exe cmd/$(APP)/main.go

	
.crop:
	strip $(PROJECT_BIN)/$(APP).exe
	objcopy --strip-unneeded $(PROJECT_BIN)/$(APP).exe

dev:
	find . -name "*.go" | entr -r make build

help:
	@cat $(MAKEFILE_LIST) | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

