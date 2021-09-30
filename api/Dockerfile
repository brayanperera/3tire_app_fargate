FROM node:16.10.0
MAINTAINER brayan.perera@gmail.com

# Set ENV
ENV PORT=5001
ENV DB=api
ENV DBUSER=api_user
ENV DBPASS=Ap1PasS123
ENV DBHOST=localhost
ENV DBPORT=5432

WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 5001

HEALTHCHECK CMD --interval=30s --timeout=3s curl --fail http://localhost:5001 || exit 1

CMD [ "npm", "start" ]

