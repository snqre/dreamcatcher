import type {TextProps} from "@text/Text";
import {Text} from "@text/Text";
import {ColorPalette} from "@color/Color";
import React from "react";

interface SimpleButtonProps extends TextProps {
    disabled?: boolean,
}

class SimpleButton {
    public static Component(props: SimpleButtonProps): React.ReactNode {
        let {style, disabled, ... more} = props;
        return (
            <Text.Component
            style={{
                "fontSize": "1.25em",
                "fontWeight": "bold",
                "background": disabled
                    ? ColorPalette.ROCK.toHex().toString()
                    : ColorPalette.POLISHED_TITANIUM.toHex().toString(),
                ... style ?? {},
            }}
            {... more}/>
        );
    }
}

export type {SimpleButtonProps};
export {SimpleButton};