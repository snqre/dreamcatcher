import type {ReactNode} from "react";
import type {ControllerProps} from "@components/Controller";
import {Controller} from "@components/Controller";
import {ColorPalette} from "@color/Color";

interface TextProps extends ControllerProps {
    text: string,
}

class Text {
    public static Component(props: TextProps): ReactNode {
        const {text, style, ... more} = props;
        return (
            <Controller.Component
            style={{
                "fontSize": "1em",
                "fontWeight": "bold",
                "fontFamily": "Roboto Mono, monospace",
                "color": "white",
                "background": ColorPalette.POLISHED_TITANIUM.toHex().toString(),
                "display": "flex",
                "flexDirection": "row",
                "justifyContent": "center",
                "alignItems": "center",
                "WebkitBackgroundClip": "text",
                "WebkitTextFillColor": "transparent",
                ... style ?? {},
            }}
            {... more}>
                {text}
            </Controller.Component>
        );
    }
}

export type {TextProps};
export {Text};