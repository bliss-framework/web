# Bliss Framework Documentation Makefile

.PHONY: help setup serve dev build clean docker-build docker-run install

# Default target
help:
	@echo "Bliss Framework Documentation"
	@echo ""
	@echo "Available targets:"
	@echo "  setup        Install MkDocs and required plugins"
	@echo "  serve        Start development server"
	@echo "  build        Build static site"
	@echo "  clean        Clean build artifacts"
	@echo "  docker-build Build Docker image"
	@echo "  docker-run   Run Docker container"
	@echo "  install      Alias for setup"

# Install MkDocs and plugins
setup install:
	pip install mkdocs mkdocs-material mkdocs-glightbox mkdocs-git-revision-date-localized-plugin mkdocs-git-authors-plugin

# Start development server
serve:
	mkdocs serve

dev: serve

# Build static site
build:
	mkdocs build

# Clean build artifacts
clean:
	rm -rf site/

# Build Docker image
docker-build:
	docker build --progress plain -f Dockerfile -t bliss-framework:web .

# Run Docker container
docker-run:
	docker run -p 80:80 bliss-framework:web