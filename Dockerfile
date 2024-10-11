FROM node:14-alpine
WORKDIR /app/
COPY package.json ./
RUN npm install

RUN apk add dumb-init


COPY . .


EXPOSE 8082

ENTRYPOINT ["dumb-init", "--"]
CMD ["npm", "run", "checkinreceiver", "auth"]
