import type {ReactNode} from "react";
import type {ColProps} from "@layout/Col";
import {Col} from "@layout/Col";
import {ColorPalette} from "@color/Color";

interface GlassContainerWithGraphiteFrameProps extends ColProps {
    frameDir:
        | "to left"
        | "to right"
        | "to bottom"
        | "to top";
}

class GlassContainerWithGraphiteFrame {
    public static Component(props: GlassContainerWithGraphiteFrameProps): ReactNode {
        let {frameDir, style, children, ... more} = props;
        return (
            <Col.Component
            style={{
                "backdropFilter": "blur(30px)",
                "borderWidth": "1px",
                "borderStyle": "solid",
                "borderImage": `linear-gradient(${frameDir ?? "to bottom"}, transparent, ${ColorPalette.GRAPHITE.toHex().toString()}) 1`,
                ... style ?? {}
            }}
            {... more}>
                {children}
            </Col.Component>
        );
    }
}

export type {GlassContainerWithGraphiteFrameProps};
export {GlassContainerWithGraphiteFrame};