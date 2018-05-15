FROM node:8.9 AS build-nlmaps
MAINTAINER hans@webmapper.net
RUN apt-get update && apt-get install -yq git
WORKDIR /app
COPY build-nlmaps.sh build-nlmaps.sh
COPY config/amsterdam.config.js config/amsterdam.config.js
RUN sh build-nlmaps.sh

FROM node:8.9 AS build-amaps
MAINTAINER hans@webmapper.net
WORKDIR /app
RUN apt-get update && apt-get install -yq gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget
COPY package.json package.json
RUN npm install
COPY scripts /app/scripts
copy rollup.config.js /app/
COPY src /app/src/
COPY test /app/test
COPY .eslintrc.js /app/.eslintrc.js
COPY .eslintignore /app/.eslintignore
RUN NODE_ENV=production npm run build-amaps

# Web server image
FROM nginx:1.12.2-alpine
COPY --from=build-nlmaps /app/nlmaps /usr/share/nginx/html/nlmaps
COPY --from=build-amaps /app/scripts /usr/share/nginx/html
COPY --from=build-amaps /app/test /usr/share/nginx/html
COPY --from=build-amaps /app/dist /usr/share/nginx/html/dist
