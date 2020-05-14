import { format } from "util";
import { map } from "bluebird";

import { GifMetadata, GifQuery } from "../types/gif";
import { Connection } from "../db";
import { GIFS, concurrency, PAGE_SIZE , TAGS} from "./constants";
import { insertTags } from "./tags";

//Allow for these to throw

export async function getGifs(
  conn: Connection,
  query: GifQuery
): Promise<{ id: string }[]> {
  //if there is an id, return that 1
  //if there are tags, return ones that match that tag
  //if there are both, return the id

  //if there is nothing, return the og page size with how many more there are
  const offset = query.page * PAGE_SIZE;

  console.log(query.tags)

  if (query.tags) {
  return await conn(`${GIFS} as g`)
  //.innerJoin(`${TAGS} as t`, 'g.id', 't.gif_id')
  .joinRaw(`inner join ${TAGS} as t on g.id = t.gif_id and t.tag in (?)`, query.tags)
  .select(['g.id', conn.raw('ARRAY_AGG(t.tag) as tags')]).groupBy('g.id')
  .offset(offset).limit(PAGE_SIZE);



  } else {
  return await conn(`${GIFS} as g`)
  .innerJoin(`${TAGS} as t`, 'g.id', 't.gif_id')
  .select(['g.id', conn.raw('ARRAY_AGG(t.tag) as tags')]).groupBy('g.id')
  .offset(offset).limit(PAGE_SIZE);
  }

}

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
