export interface Config {
  port: number;
}

//TODO read this in from json
//add db creds
//add aws keys(maybe)

const config: Config = {
  port: 3000,
};

export default config;
