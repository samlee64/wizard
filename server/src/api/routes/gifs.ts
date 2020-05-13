import * as Router from "koa-router";
import { Context } from "koa";

const router = new Router({
  prefix: "/gifs",
});

router.get("/", async (ctx: Context) => {
  ctx.status = 200;
  ctx.body = [];
});

export default router;
