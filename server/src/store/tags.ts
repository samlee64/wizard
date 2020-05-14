import { Connection } from "../db";
import { TAGS } from "./constants";

export async function insertTags(
  conn: Connection,
  gifId: string,
  tags: string[]
): Promise<void> {
  const adjustedTags = tags.map((tag: string) => {
    return { gif_id: gifId, tag };
  });

  return conn(TAGS).insert(adjustedTags);
}
