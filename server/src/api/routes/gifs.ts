import * as Router from "koa-router";
import { Context } from "koa";
import { getGifMetadata } from "../../aws/s3";
import { conn } from "../../db";
import { sync, getGifs } from "../../store/gifs";

const router = new Router({
  prefix: "/gifs",
});

router.get("/", async (ctx: Context) => {
  let query;
  try {
    query = {
      tags: ctx.query.tags ? JSON.parse(ctx.query.tags) : undefined,
      page: ctx.query.page ? JSON.parse(ctx.query.page) : 0,
    };
  } catch (e) {
    ctx.status = 400;
    ctx.body = "Bad Request";
    return;
  }

  try {
    ctx.body = await getGifs(conn, query);
  } catch (e) {
    console.error(e);
    ctx.status = 500;
    ctx.body = e;
  }
  ctx.status = 200;
});

router.get("/sync", async (ctx: Context) => {
  const metadata = await getGifMetadata();

  try {
    await sync(conn, metadata);
  } catch (e) {
    console.error("Could not sync metadata", e);

    ctx.status = 500;
    ctx.body = e;
    return;
  }

  ctx.status = 200;
});

export default router;
