FROM python:alpine3.19 as builder

COPY mkdocs.yml /mkdocs.yml
COPY docs /docs

RUN pip install mkdocs
RUN pip install mkdocs-material
RUN mkdocs build

FROM caddy
COPY Caddyfile /etc/caddy/Caddyfile
COPY --from=builder site /www/html

EXPOSE 80
EXPOSE 443