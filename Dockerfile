# FROM python:3.11-alpine3.18 as builder

# # Build-time flags
# ARG WITH_PLUGINS=true

# # Environment variables
# ENV PACKAGES=/usr/local/lib/python3.11/site-packages
# ENV PYTHONDONTWRITEBYTECODE=1

# # Set build directory
# WORKDIR /app

# ENV GIT_PYTHON_REFRESH=quiet

# RUN apk add git
# RUN pip install mkdocs
# RUN pip install mkdocs-material
# RUN pip install mkdocs-glightbox mkdocs-git-revision-date-localized-plugin mkdocs-git-authors-plugin

# RUN export

# COPY mkdocs.yml mkdocs.yml
# COPY overrides overrides
# COPY docs docs

# RUN mkdocs build

# FROM caddy
# COPY Caddyfile /etc/caddy/Caddyfile
# COPY --from=builder /app/site /www/html

# EXPOSE 80
# EXPOSE 443

FROM squidfunk/mkdocs-material:latest as builder

RUN pip install mkdocs-glightbox mkdocs-git-revision-date-localized-plugin 

WORKDIR /app

ADD . .
COPY mkdocs.yml mkdocs.yml
COPY overrides overrides
COPY docs docs

RUN mkdocs build

FROM caddy
COPY Caddyfile /etc/caddy/Caddyfile
COPY --from=builder /app/site /www/html

EXPOSE 80
EXPOSE 443
