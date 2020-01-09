TARGET := kubelogin
CIRCLE_TAG ?= latest
LDFLAGS := -X main.version=$(CIRCLE_TAG)

all: $(TARGET)

.PHONY: check
check:
	golangci-lint run
	go test -v -race -cover -coverprofile=coverage.out ./...

$(TARGET): $(wildcard *.go)
	go build -o $@ -ldflags "$(LDFLAGS)"

dist:
    # make the zip files for GitHub Releases
	VERSION=$(CIRCLE_TAG) CGO_ENABLED=0 goxzst -d dist/gh/ -i "LICENSE" -o "$(TARGET)" -t "kubelogin.rb oidc-login.yaml" -- -ldflags "$(LDFLAGS)"
	zipinfo dist/gh/kubelogin_linux_amd64.zip
	# make the Homebrew formula
	mv dist/gh/kubelogin.rb dist/
	# make the yaml for krew-index
	mkdir -p dist/plugins
	cp dist/gh/oidc-login.yaml dist/plugins/oidc-login.yaml

.PHONY: release
release: dist
    # publish to the GitHub Releases
	ghr -u "$(CIRCLE_PROJECT_USERNAME)" -r "$(CIRCLE_PROJECT_REPONAME)" "$(CIRCLE_TAG)" dist/gh/
	# publish to the Homebrew tap repository
	ghcp commit -u "$(CIRCLE_PROJECT_USERNAME)" -r "homebrew-$(CIRCLE_PROJECT_REPONAME)" -m "$(CIRCLE_TAG)" -C dist/ kubelogin.rb
	# fork krew-index and create a branch
	ghcp fork-commit -u kubernetes-sigs -r krew-index -b "oidc-login-$(CIRCLE_TAG)" -m "Bump oidc-login to $(CIRCLE_TAG)" -C dist/ plugins/oidc-login.yaml

.PHONY: clean
clean:
	-rm $(TARGET)
	-rm -r dist/

.PHONY: ci-setup-linux-amd64
ci-setup-linux-amd64:
	mkdir -p ~/bin
	# https://github.com/golangci/golangci-lint
	curl -sfL https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | sh -s -- -b ~/bin v1.21.0
	# https://github.com/int128/goxzst
	curl -sfL -o /tmp/goxzst.zip https://github.com/int128/goxzst/releases/download/v0.3.0/goxzst_linux_amd64.zip
	unzip /tmp/goxzst.zip -d ~/bin
	# https://github.com/int128/ghcp
	curl -sfL -o /tmp/ghcp.zip https://github.com/int128/ghcp/releases/download/v1.5.1/ghcp_linux_amd64.zip
	unzip /tmp/ghcp.zip -d ~/bin
	# https://github.com/tcnksm/ghr
	curl -sfL -o /tmp/ghr.tgz https://github.com/tcnksm/ghr/releases/download/v0.13.0/ghr_v0.13.0_linux_amd64.tar.gz
	tar -xf /tmp/ghr.tgz -C ~/bin --strip-components 1 --wildcards "*/ghr"
