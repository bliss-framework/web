FROM squidfunk/mkdocs-material:latest as builder

RUN pip install mkdocs-glightbox mkdocs-git-revision-date-localized-plugin mkdocs-git-authors-plugin

WORKDIR /app

ADD . /app

RUN ls -laR /app

# COPY mkdocs.yml mkdocs.yml
# COPY overrides overrides
# COPY docs docs

RUN mkdocs build

FROM caddy
COPY Caddyfile /etc/caddy/Caddyfile
COPY --from=builder /app/site /www/html

EXPOSE 80
EXPOSE 443
