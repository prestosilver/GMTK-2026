
import { defineConfig, env } from "prisma/config";

export default defineConfig({
    schema: "./schemas/",


    datasource: {
        url: env("DB_URL"),
    },
});