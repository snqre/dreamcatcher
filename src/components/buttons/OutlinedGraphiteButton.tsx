import type {ReactNode} from "react";
import type {RowProps} from "@layout/Row";
import {Row} from "@layout/Row";
import {ColorPalette} from "@color/Color";
import {Controller} from "@components/Controller";
import {Text} from "@text/Text";
import {config} from "react-spring";

interface OutlinedGraphiteButtonProps extends RowProps {
    label: string,
}

class OutlinedGraphiteButton {
    public static Component(props: OutlinedGraphiteButtonProps): ReactNode {
        let {label, alias, spring, children, ... more} = props;
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
                "pointerEvents": "auto",
                "cursor": "pointer",
                "borderWidth": "1px",
                "borderStyle": "solid",
                "borderColor": `${ColorPalette.GRAPHITE.toHex().toString()}`,
                "position": "relative",
                ... spring ?? {},
            }}
            {... more}>
                <Text.Component 
                text={label}
                style={{
                    "fontSize": "1em",
                    "fontWeight": "bold",
                }}/>
            </Row.Component>
        );
    }
}

export type {OutlinedGraphiteButtonProps};
export {OutlinedGraphiteButton};