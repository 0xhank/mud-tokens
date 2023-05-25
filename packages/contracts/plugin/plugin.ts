import { z } from "zod";

export const zPluginTokenConfig = z
  .object({
    tokens: z.array(
      z.object({
        name: z.string(),
        symbol: z.string().max(5),
        type: z.string().startsWith("ERC"),
      })
    ),
  })
  .catchall(z.any());
