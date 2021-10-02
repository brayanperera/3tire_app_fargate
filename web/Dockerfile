FROM node:16.10.0
MAINTAINER brayan.perera@gmail.com

# Set ENV
ENV PORT=8081
ENV API_HOST=http://localhost:5001
ENV CDN_URL=http://localhost

WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 8081

HEALTHCHECK CMD --interval=30s --timeout=3s curl --fail http://localhost:8081/status || exit 1

CMD [ "npm", "start" ]