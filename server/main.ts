import { cors } from "hono/cors"
import { Hono } from "hono";
import { validators } from "@scope/leaderboard";

import { PrismaClient } from "./packages/db/generated/client.ts"

const prisma = new PrismaClient({
    accelerateUrl: String(Deno.env.get("DB_URL"))
});

const app = new Hono();

//env//
const port = Number(Deno.env.get("PORT"));
//////

app.use("/*", cors({
    origin: ["*"], //Change when we have a build uploaded to itch...
    allowMethods: ["GET", "POST"],
    allowHeaders: ["Content-Type"],
    exposeHeaders: ["X-Score-Hash"],
}))

app.post("/upload-score", validators.ScoreSubmitValidator, async (c) => {
    const { hash, name, score } = c.req.valid("json");

    await prisma.score.create({
        data: {
            name, hash, score
        }
    });

    return c.json({
        success: true,
    })
})

app.get("/get-leaderboard", validators.GetLeaderboardValidator, async (c) => {
    const { max, page } = c.req.valid("query");

    const data = await prisma.score.findMany({
        skip: page * max,
        take: max,
        select: { name: true, score: true }
    });

    return c.json({
        success: true,
        data
    })
})



Deno.serve({ port }, app.fetch);