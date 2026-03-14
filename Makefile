VERSION ?= $(shell cat ./VERSION)
BIN := dummy
MAJOR_VERSION ?= $(shell echo $(VERSION) | cut -d . -f1)
GO_IMAGE := golang:1.25
GO_RUN := docker run --rm -e CGO_ENABLED=0 -e HOME=$$HOME -v $$HOME:$$HOME -u $(shell id -u):$(shell id -g) -v $(shell pwd):/build -v /tmp:/tmp -v /var/run/docker.sock:/var/run/docker.sock -w /build $(GO_IMAGE) go
GO_FILES := $(shell find . -type f -path **/*.go -not -path "./vendor/*")
PACKAGES := $(shell go list ./...)

.PHONY: test
test:
	$(GO_RUN_TEST) -p 1 --timeout 10m $(PACKAGES)

.PHONY: lint-check
lint-check:
	docker run -t --rm -v $(shell pwd):/app -w /app golangci/golangci-lint:v2.8.0 golangci-lint run

.PHONY: build
build: bin/$(BIN)

bin/$(BIN): $(GO_FILES)
	$(GO_RUN) build -trimpath -ldflags="-s -w -X 'main.Version=$(VERSION)'" -mod=vendor -o ./bin/$(BIN) main.go

.PHONY: clean
clean:
	rm -rf bint