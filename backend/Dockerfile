FROM node:18-alpine as build

RUN mkdir -p /app && chown -R node /app
USER node

WORKDIR /app
# Install deps first for cacheability
COPY --chown=node package*.json .
RUN npm ci

# Add full codebase and build
COPY --chown=node . .
RUN npm run build


# Clean image for deployment
FROM node:18-alpine as final

USER node
WORKDIR /app

COPY --from=build /app/node_modules ./node_modules/
COPY --from=build /app/dist ./dist/

EXPOSE 3030
ENV NODE_ENV=production
ENV PATH=/app/node_modules/.bin:$PATH
CMD node ./dist/index.js
