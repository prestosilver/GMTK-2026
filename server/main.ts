import { Hono } from "hono"
import { cors } from "hono/cors"

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



Deno.serve({ port }, app.fetch);