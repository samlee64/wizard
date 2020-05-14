FROM node:10 as build

WORKDIR /usr/app

COPY package*.json ./
RUN npm install

COPY . .

RUN npm run transpile


FROM node:10 as run

COPY package*.json ./
RUN npm ci --only=production

WORKDIR /usr/app

COPY --from=build /usr/app/lib  /usr/app/lib
EXPOSE 3000

CMD ["node", "lib/api/main.js"]
