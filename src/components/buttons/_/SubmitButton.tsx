import type { ReactNode } from "react";
import type { ColRemoteProps } from "@layout/ColRemote";
import type { CSSProperties } from "react";
import { ColRemote } from "@layout/ColRemote";
import { Text } from "@text/Text";
import { emit } from "@events-handler";

type SubmitButtonProps =
    ColRemoteProps &
    {};

function SubmitButton(props: SubmitButtonProps): ReactNode {
    let { at, style, children, ... more } = props;
    return <ColRemote
    at={ at }
    spring={{
        background: "#615FFF",
        pointerEvents: "auto",
        cursor: "auto",
        ... style ?? {}
    }}
    onMouseEnter={function(): void {
        return emit({
            from: at,
            type: "setSpring",
            item: {
                background: "#8886FF",
                cursor: "pointer"
            } satisfies CSSProperties
        });
    }}
    onMouseLeave={function(): void {
        return emit({
            from: at,
            type: "setSpring",
            item: {
                background: "#615FFF",
                cursor: "auto"
            } satisfies CSSProperties
        });
    }}
    onClick={function(): void {
        return emit({
            from: at,
            type: "submission"
        });
    }}
    { ... more }>
        <Text
        text={ ">" }
        style={{
            fontSize: "1.25em"
        }}/>
    </ColRemote>;
}

export type { SubmitButtonProps };
export { SubmitButton };