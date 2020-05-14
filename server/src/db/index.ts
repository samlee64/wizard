import * as Knex from "knex";
//import config from "../config";

export type Connection = Knex;

export const conn = Knex({
  client: "pg",
  connection: {
    host: "127.0.0.1",
    user: "gandalf",
    password: "gandalf",
    database: "gandalf",
    port: 8400,
  },
});
