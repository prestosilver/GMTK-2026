import { ScoreInputQuery, GetLeaderboardQuery } from "./schemas.ts"
import { zValidator } from "@hono/zod-validator"

export const ScoreSubmitValidator = zValidator("json", ScoreInputQuery);
export const GetLeaderboardValidator = zValidator("query", GetLeaderboardQuery)