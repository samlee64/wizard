import { map } from "bluebird";
import { Connection } from "../db";

import { GifMetadata } from "../types/gif";
import { GIFS, concurrency } from "./constants";
import { insertTags } from "./tags";

//Allow for these to throw

export async function insertGif(
  conn: Connection,
  meta: GifMetadata
): Promise<string> {
  const params = { id: meta.id, file_name: meta["File Name"] };

  await conn(GIFS).insert(params);

  //TODO this
  return meta.id;
}

export async function sync(
  conn: Connection,
  gifMetadatas: GifMetadata[]
): Promise<string[]> {
  //TODO handle upsert
  const syncedIds = await map(
    gifMetadatas,
    async (meta: GifMetadata) => {
      const id = await insertGif(conn, meta);
      await insertTags(conn, meta.id, meta.tags);

      return id;
    },
    { concurrency }
  );

  return syncedIds;
}
