import * as Router from "koa-router";
import { Context } from "koa";
import { getGifMetadata } from "../../aws/s3";
import { conn } from "../../db";
import { sync } from "../../store/gifs";

const router = new Router({
  prefix: "/gifs",
});

router.get("/", async (ctx: Context) => {
  ctx.status = 200;
  ctx.body = await getGifMetadata();
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
