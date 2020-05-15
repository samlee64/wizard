1.  A website that displays gifs, and the ability to search for gifs
2.  A backend rest api that will fullfil requests from the website
3.  A database that has the gif metadata to provide for the backend.
4.  All systems should be contained in docker container(s)
5.  The project will be submitted via a link to github where it can be checked out.

# To Run

## Server
### For Use
Within the `/server`: 
Add AWS keys to config.docker.json

`npm install`
`docker login`
`./scripts/docker.sh`
`npm run up`
`./scripts/migrate up`

`curl localhost:3000/health` to ensure that the server is up 
`curl localhost:3000/sync` once to download the gif metadata and populate the database


### For Development
Within the `/server`

`cp config.sample.json config.json`
Add AWS keys to config.json

`npm install` 
`npm run start:watch`

Remove "app" from docker-compose.yaml

`docker-compose up -d`
`./scripts/migrate up`
`npm run start:watch`

`curl localhost:3000/health` to ensure that the server is up 

## UI
`npm install`
`cp config.sample.json config.json`
`npm run dev`

Navigate to `localhost:3001` 
