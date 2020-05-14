import { S3 } from "aws-sdk";
import { map } from "bluebird";
import config from "../config";
import { GifMetadata } from "../types/gif";
import { WIZARD_BUCKET } from "./constants";

const s3 = new S3({
  region: "us-west-2",
  accessKeyId: config.aws.accessKey,
  secretAccessKey: config.aws.secretAccessKey,
});

export async function getGifMetadata(): Promise<GifMetadata[]> {
  const params = {
    Bucket: WIZARD_BUCKET,
    Key: "gifs.json",
  };

  try {
    const metadata = await s3.getObject(params).promise();

    if (!metadata.Body) throw new Error("Returned successfully, not data");

    //Going to hold whole buffer in memory.
    ////should ideally have io-ts
    //tslint:disable-next-line
    const json: { [id: string]: GifMetadata } = JSON.parse(
      metadata.Body.toString("utf-8")
    );

    return Object.values(json);
  } catch (e) {
    console.error("Failed to retreive gif metadata", e);
    return [];
  }
}

export async function getGifs(filenames: string[]): Promise<void> {
  const gifs = await map(
    filenames,
    async (name: string) => {
      const params = {
        Bucket: WIZARD_BUCKET,
        Key: "gifs/" + name,
      };
      await s3.getObject(params);
    },
    { concurrency: 10 }
  );
  gifs;
}
