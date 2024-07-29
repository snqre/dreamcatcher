import type { ReactNode } from "react";
import type { CSSProperties } from "react";
import { ColRemote } from "@layout/ColRemote";
import { Alert } from "@components/ui/_/alerts/Alert"; 
import { useEffect } from "react";
import { emit } from "@events-handler";

function Alerts(): ReactNode {

    useEffect(function() {
        emit({ from: "alerts", type: "mount", item: (<Alert caption="My Caption" message="Nothing to see here ..."/>) });
    });
    return (
        <ColRemote 
        at="alerts" 
        style={{ 
            width: "350px", 
            height: "200px", 
            borderWidth: "1px", 
            borderStyle: "solid", 
            borderImage: "linear-gradient(to bottom, #505050, transparent) 1" 
        }}
        onMouseEnter={ () => emit({
            from: "alerts",
            type: "setSpring",
            item: {
                pointerEvents: "auto",
                cursor: "pointer",
                boxShadow: "0 0 5px 2px #505050"
            } satisfies CSSProperties })
        }/>

    );
}

export { Alerts };