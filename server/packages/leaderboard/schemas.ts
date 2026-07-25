import * as z from "zod";

export const ScoreInputQuery = z.object({
    name: z.string().max(3).nonoptional().describe("The three letter name of the player for this score. [Max Length: 3]"),
    score: z.uint32().nonoptional().describe("Score value"),
    hash: z.string().nonoptional().describe("Hash validation")
})

export type ScoreInput = z.infer<typeof ScoreInputQuery>;

export const GetLeaderboardQuery = z.object({
    page: z.uint32().nonoptional().describe("The page to query from"),
    max: z.uint32().default(10).describe("Number of entries per page"),
})

export type GetLeaderboardQuery = z.infer<typeof GetLeaderboardQuery>;
