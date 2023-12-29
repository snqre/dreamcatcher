import column from "../layouts/column.js";
import { color } from "../color.js";


/**
 * 
 * Now that you know the team,
 * Phase 1 is to launch the vaults
 * The vaults function as entitities on dreamcatcher
 * the goal is to use the same technology to scale the vaults further
 * 
 * Cannot use mappings because they are thrown randomly accross
 * While this is more challenging, this allows for storage slots to be
 * explicityly assigned making the chance of storage collision zero.
 * It means we can break up storage into plots to allow an "unlimited"
 * amount of modules to co-exist, every module being assigned its own
 * plot.
 * 
 * unique storage slot id in the registraar
 */

export default function roadmap() {
    const section = column(
        "100%",
        "100vh", {
            overflow: "hidden"
        }, [
            column(
                "100%",
                "100%", {
                    background: color.black.REFLECTING_POND
                }
            )
        ]
    );
    return section;
}