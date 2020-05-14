export interface Config {
  port: number;
  aws: {
    accessKey: string;
    secretAccessKey: string;
  };
  db: {
    host: string;
    user: string;
    password: string;
    database: string;
    port: number;
  };
}

//TODO read in AWS keys as env vars
//tslint:disable-next-line
const config: Config = require("../config.json");

export default config;
