import gutter from "../layouts/gutter.js";
import leftContentRightImage from "../layouts/leftContentRightImage.js";
import captionSubCallToAction from "../layouts/captionSubCallToAction.js";
import column from "../layouts/column.js";
import row from "../layouts/row.js";
import misc from "../layouts/misc.js";
import {colors} from "../colors.js";
import button from "../layouts/button.js";

export default function headlineSection() {
    const section = column("100%", "100vh", {}, [
        gutter(10),
        row("100%", "20vh", {}, []),
        gutter(10)
    ]);
}

export default function headlineSection() {
    const section = column("100%", "100vh", {}, [
        gutter(5, {}, []),
        leftContentRightImage(80, "/static/png/undraw/undraw_relaunch_day_902d.png", {}, {}, [
            captionSubCallToAction(100, [
                misc("Scaling Dreams, Crafting Possibilities", {
                    background: colors.bgContrast,
                    color: colors.stringContrast,
                    padding: "1%"
                })
            ], [
                misc("At Dreamcatcher, we're dreamers, builders, and architects of the future. Born out of a shared vision for a decentralized world, we embark on a journey to redefine the possibilities of blockchain technology.", {
                    padding: "5%",
                    background: colors.bgInContainer,
                    color: colors.stringInContainer
                }, [

                ]),
            ], [button("Learn More", {width: "100%", fontSize: "1.25rem"}, ["button-flux-animation"])])
        ]),
        gutter(10, {}, []),
        gutter(5, {}, [])
    ]);
    return section;
}