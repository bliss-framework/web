FROM python:alpine3.19 as builder

COPY mkdocs.yml /mkdocs.yml

ENV GIT_PYTHON_REFRESH=quiet

RUN apk add git
RUN pip install mkdocs
RUN pip install mkdocs-material
RUN pip install mkdocs-glightbox mkdocs-git-revision-date-localized-plugin mkdocs-git-authors-plugin

RUN export

COPY overrides /overrides
COPY docs /docs

RUN mkdocs build

FROM caddy
COPY Caddyfile /etc/caddy/Caddyfile
COPY --from=builder site /www/html

EXPOSE 80
EXPOSE 443