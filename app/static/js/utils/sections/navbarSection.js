import row from "../layouts/row.js";
import image from "../layouts/image.js";
import misc from "../layouts/misc.js";
import {colors} from "../colors.js";

export default function navbarSection() {
    const section = row("100%", "auto", {
        justifyContent: "start",
        padding: "1%",
        gap: "1%"
    }, [
        image("32px", "32px", "/static/png/brand/dreamcatcher_logo.png", {}, []),
        misc("Dreamcatcher", {
            width: "auto",
            heigth: "auto",
            fontSize: "2rem",
            fontWeight: "bold"
        }, []),
        row("auto", "auto", {
            gap: "1%"
        }, [
            misc("Home"),
            misc("About"),
            misc("This")
        ]),
        misc("", {
            width: "30%"
        }),
        misc("CallToAction", {
            width: "auto"
        }, [
            "button",
            "button-flux-animation"
        ])
    ]);
    return section;
}