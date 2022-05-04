FROM node:16.15-alpine3.14

RUN mkdir -p /opt/app
WORKDIR /opt/app
RUN adduser -S app
COPY . .
RUN npm install
#Add PM2 for production use
RUN npm install pm2 -g
RUN chown -R app /opt/app
USER app
EXPOSE 3000

CMD [ "pm2-runtime", "app.js" ]



