import * as Router from "koa-router";

import health from "./health";
import gifs from "./gifs";

const router = new Router();

router.use(health.routes());
router.use(gifs.routes());

export default router;
