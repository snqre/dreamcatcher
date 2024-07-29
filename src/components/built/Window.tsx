import type { ReactNode } from "react";
import type { ObsidianContainerProps } from "@components/layout/containers/frames/ObsidianContainer";
import { PhantomSteelFrame } from "@frames/PhantomSteelFrame";
import { ObsidianContainer } from "@components/layout/containers/frames/ObsidianContainer";

type WindowProps = 
    ObsidianContainerProps & {
    frameDirection?: string;
};

function Window(props: WindowProps): ReactNode {
    let { frameDirection, style, children, ... more } = props;
    return <PhantomSteelFrame
    direction={ frameDirection }>
        <ObsidianContainer
        style={{
            width: "450px",
            height: "450px",
            margin: "25px",
            ... style ?? {}
        }}
        { ... more }>
            { children }
        </ObsidianContainer>
    </PhantomSteelFrame>
}

export type { WindowProps };
export { Window };