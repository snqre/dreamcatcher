import column from "../layouts/column.js";
import { color } from "../color.js";



export default function team() {
    const section = column(
        "100%",
        "100vh", {
            overflow: "hidden"
        }, [
            column(
                "100%",
                "100%", {
                    background: color.black.TECH_BLACK
                }
            )
        ]
    );
    return section;
}