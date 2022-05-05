FROM node:16.15.0-alpine

RUN mkdir -p /opt/app
WORKDIR /opt/app

RUN adduser -S app

COPY . .
RUN npm install
#Add PM2 for production use
RUN npm install pm2 -g
RUN chown -R app /opt/app
USER app

EXPOSE 9090

CMD [ "pm2-runtime", "app.js" ]



