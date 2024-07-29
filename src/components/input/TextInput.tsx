import type { ReactNode } from "react";
import type { ComponentPropsWithoutRef } from "react";
import { emit } from "@events-handler";

type TextInputProps = 
    ComponentPropsWithoutRef<"input"> & {
    at: string;
};

function TextInput(props: TextInputProps): ReactNode {
    let { at, $style: style, children, ... more } = props;
    return <input
    type="text"
    spellCheck={ false }
    onChange={ event => emit({
        from: at,
        type: "input",
        item: event.target.value
    }) }
    $style={{
        border: "none",
        backgroundColor: "transparent",
        outline: "none",
        boxShadow: "none",
        color: "#D6D5D4",
        fontFamily: "monospace",
        fontSize: "1.25em",
        background: "transparent",
        pointerEvents: "auto",
        ... style ?? {}
    }}
    { ... more }
    />;
}

export type { TextInputProps };
export { TextInput };