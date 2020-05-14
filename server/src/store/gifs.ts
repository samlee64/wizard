import { format } from "util";
import { map } from "bluebird";

import { GifMetadata, GifQuery } from "../types/gif";
import { Connection } from "../db";
import { GIFS, concurrency, PAGE_SIZE, TAGS } from "./constants";
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

  console.log(query.tags);

  const baseQuery = conn(`${GIFS} as g`)
    .innerJoin(`${TAGS} as t`, "g.id", "t.gif_id")
    .select(["g.id", conn.raw("ARRAY_AGG(t.tag) as tags")])
    .groupBy("g.id");

  if (query.tags) {
    const matchingGifsQuery = conn(`${GIFS} as g`)
      .select("gif_id")
      .innerJoin(`${TAGS} as t`, "g.id", "t.gif_id")
      .whereIn("t.tag", query.tags)
      .toString();
    const sqlQuery = `with matching_gifs as
          (${matchingGifsQuery})
       , all_gifs as
          (${baseQuery})
     select * from all_gifs as ag inner join matching_gifs as mg on ag.id = mg.gif_id offset ? limit ? `;

    const ret = await conn.raw(sqlQuery, [offset, PAGE_SIZE]);

    return ret.rows;
  } else {
    return await baseQuery.offset(offset).limit(PAGE_SIZE);
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
