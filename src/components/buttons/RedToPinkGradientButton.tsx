import type {ReactNode} from "react";
import type {RowProps} from "@layout/Row";
import {Row} from "@layout/Row";
import {ColorPalette} from "@color/Color";
import {Controller} from "@components/Controller";
import {Text} from "@text/Text";
import {config} from "react-spring";

interface RedToPinkGradientButtonProps extends RowProps {
    label: string,
}

class RedToPinkGradientButton {
    public static Component(props: RedToPinkGradientButtonProps): ReactNode {
        let {label, alias, spring, children, ... more} = props;
        const color0: string = ColorPalette.RED_TO_PINK_GRADIENT.COLORS[0].toHex().toString();
        const color1: string = ColorPalette.RED_TO_PINK_GRADIENT.COLORS[1].toHex().toString();
        const x0: string = "4px";
        const y0: string = "1px";
        const x1: string = "16px";
        const y1: string = "1px";
        const boxShadow0: string = `0 0 ${x0} ${y0} ${color0}, 0 0 ${x0} ${y0} ${color1}`;
        const boxShadow1: string = `0 0 ${x1} ${y1} ${color0}, 0 0 ${x1} ${y1} ${color1}`;
        alias = Controller.populateAlias(alias);
        return (
            <Row.Component
            alias={alias}
            springConfig={config.gentle}
            spring={{
                "minWidth": "200px",
                "maxWidth": "200px",
                "minHeight": "50px",
                "maxHeight": "50px",
                "background": `linear-gradient(to right, ${color0}, ${color1})`,
                "boxShadow": boxShadow0,
                "pointerEvents": "auto",
                "cursor": "pointer",
                "borderWidth": "1px",
                "borderStyle": "solid",
                "borderImage": `linear-gradient(to right, ${color0}, ${color1}) 1`,
                "position": "relative",
                ... spring ?? {},
            }}
            onMouseEnter={()=>Controller.setSpring(alias, {
                "boxShadow": boxShadow1,
            })}
            onMouseLeave={()=>Controller.setSpring(alias, {
                "boxShadow": boxShadow0,
            })}
            {... more}>
                <Text.Component 
                text={label}
                style={{
                    "background": ColorPalette.OBSIDIAN.toHex().toString(),
                    "fontSize": "1em",
                    "fontWeight": "bold",
                }}/>
            </Row.Component>
        );
    }
}

export type {RedToPinkGradientButtonProps};
export {RedToPinkGradientButton};