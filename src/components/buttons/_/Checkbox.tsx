import type { ReactNode } from "react";
import type { ColRemoteProps } from "@layout/ColRemote";
import { ColRemote } from "@layout/ColRemote";
import { useEffect } from "react";

type CheckboxProps = ColRemoteProps & {
    color0: string;
    color1: string;
    toggled: boolean;
};

function Checkbox(props: CheckboxProps): ReactNode {
    let { at, style, ... more } = props;
    useEffect(function() {
        
    });
    return (
        <ColRemote 
        at={ at } 
        style={{ 
            width: "25px", 
            height: "25px", 
            borderWidth: "1px", 
            borderImage: "linear-gradient(to bottom, #A3A3A3, #A5A5A5) 1",
            borderStyle: "solid"
        }}
        { ... more }>
            <ColRemote 
            at={ `${at}.dot` }
            style={{ 
                width: "12.5px", 
                height: "12.5px",
                opacity: 1
            }}/>
        </ColRemote>
    );
}

export type { CheckboxProps };
export { Checkbox };