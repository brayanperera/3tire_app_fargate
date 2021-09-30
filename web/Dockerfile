FROM node:16.10.0
MAINTAINER brayan.perera@gmail.com

# Set ENV
ENV PORT 8081
ENV API_HOST localhost:5001

WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 8081

CMD [ "npm", "start" ]