KUBELOGIN_VERSION := v1.15.2
GITHUB_USERNAME := $(subst /,,$(dir $(GITHUB_REPOSITORY)))

.PHONE: build
build: Dockerfile
	docker build -t kubelogin --build-arg KUBELOGIN_VERSION=$(KUBELOGIN_VERSION) .
	docker run kubelogin --version

.PHONE: release
release:
	docker login docker.pkg.github.com --username $(GITHUB_USERNAME) --password $(GITHUB_TOKEN)
	docker tag kubelogin docker.pkg.github.com/$(GITHUB_REPOSITORY)/kubelogin:$(KUBELOGIN_VERSION)
	docker push docker.pkg.github.com/$(GITHUB_REPOSITORY)/kubelogin:$(KUBELOGIN_VERSION)
