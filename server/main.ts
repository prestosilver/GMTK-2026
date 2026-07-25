import { cors } from "hono/cors"
import { OpenAPIHono } from "@hono/zod-openapi"
import { validators } from "@scope/leaderboard";

import { PrismaClient } from "./packages/db/generated/client.ts"

const prisma = new PrismaClient({
    accelerateUrl: String(Deno.env.get("DB_URL"))
});



const app = new OpenAPIHono();

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

app.doc("/doc", {
    openapi: "3.0.0",
    info: {
        version: "1.0.0",
        title: "Darts API"
    }
});



Deno.serve({ port }, app.fetch);