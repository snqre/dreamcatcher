import { Result } from "@root";
import { Unsafe } from "@root";
import { build } from "tsup";
import { wrapAsync } from "@root";

export type BuildScript = {
    run(): Promise<Result<void, Unsafe>>;
};

export function BuildScript(): BuildScript {
    /** @constructor */ {
        return { run };
    }

    async function run(): ReturnType<BuildScript["run"]> {
        return await wrapAsync(build, {
            entry: ["src/mod.ts"],
            outDir: "target/tslib",
            format: ["cjs"],
            bundle: true,
            dts: true,
            sourcemap: "inline",
            clean: true,
            minify: true,
            config: "tsconfig.json"
        });
    }
}

/** @script */
(await BuildScript()
    .run())
    .unwrap();