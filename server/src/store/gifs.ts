import { format } from "util";
import { map } from "bluebird";

import { GifMetadata } from "../types/gif";
import { Connection } from "../db";
import { GIFS, concurrency } from "./constants";
import { insertTags } from "./tags";

//Allow for these to throw
//export async function getGif(conn: Connection, query: GifQuery): Promise<void> {
//  conn.raw()
//}
export async function upsertGif(
  conn: Connection,
  meta: GifMetadata
): Promise<void> {
  const params = { id: meta.id, file_name: meta["File Name"] };

  const insert = conn(GIFS).insert(params).toString();
  const update = conn(GIFS)
    .update({ file_name: params.file_name })
    .whereRaw("gifs.id = ?", [params.id]);

  const query = format(
    "%s ON CONFLICT (id) DO UPDATE SET %s",
    insert.toString(),
    update.toString().replace(/^update\s.*\sset\s/i, "")
  );

  await conn.raw(query);
}

export async function sync(
  conn: Connection,
  gifMetadatas: GifMetadata[]
): Promise<string[]> {
  const syncedIds = await map(
    gifMetadatas,
    async (meta: GifMetadata) => {
      await upsertGif(conn, meta);
      await insertTags(conn, meta.id, meta.tags);

      return meta.id;
    },
    { concurrency }
  );

  return syncedIds;
}
