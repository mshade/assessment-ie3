FROM node:18-alpine as deps

RUN mkdir -p /app && chown node /app
USER node
WORKDIR /app

# Install deps first for cacheability
COPY --chown=node package*.json .
RUN npm ci

# Install dev dependencies separately for linting/testing.
FROM deps as test
RUN npm install
VOLUME /app/node_modules


FROM deps as build
# Add full codebase and build
COPY --chown=node . .
RUN npm run build


# Copy assets to unprivileged container for deployment
FROM nginxinc/nginx-unprivileged:1.25-alpine as prod

USER root
ARG DOCROOT=/usr/share/nginx/html
COPY --from=build --chown=nobody:nobody /app/dist ${DOCROOT}
RUN find ${DOCROOT} -type d -print0 | xargs -0 chmod 755 && \
    find ${DOCROOT} -type f -print0 | xargs -0 chmod 644 && \
    chmod 755 ${DOCROOT}

USER nginx

EXPOSE 8080
