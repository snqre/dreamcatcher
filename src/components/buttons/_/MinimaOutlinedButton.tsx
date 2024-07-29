import type {ReactNode} from "react";
import type {RowRemoteProps} from "@layout/RowRemote";
import {RowRemote} from "@layout/RowRemote";
import {Text} from "@text/Text";
import {emit} from "@events-handler";

type MinimaOutlinedButtonProps = RowRemoteProps & {
    label: string;
};

function MinimaOutlinedButton(props: MinimaOutlinedButtonProps): ReactNode {
    let { label, at, spring, children, ... more } = props;
    return (
        <RowRemote
        at={at}
        spring={{
            "width": "100px",
            "height": "25px",
            "borderWidth": "1px",
            "borderStyle": "solid",
            "borderImage": "#C1C0BF 1",
            "pointerEvents": "auto",
            "cursor": "pointer",
            "boxShadow": "0 0 0 0",
        }}
        onMouseEnter={()=>emit({
            "from": at,
            "type": "setSpring",
            "item": {
                "boxShadow": "0 0 1px 1px #C1C0BF",
            },
        })}
        onMouseLeave={()=>emit({
            "from": at,
            "type": "setSpring",
            "item": {
                "boxShadow": "0 0 0 0",
            },
        })}
        {... more}>
            <Text
            text={label}
            style={{
                "fontSize": "12px",
                "fontWeight": "bold",
                "fontFamily": "monospace",
            }}/>
        </RowRemote>
    );
}
