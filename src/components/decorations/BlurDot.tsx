import type {ReactNode} from "react";
import type {ColProps} from "@layout/Col";
import {Col} from "@layout/Col";

interface BlurdotProps extends ColProps {
    color0: string,
    color1: string,
}

class Blurdot {
    public static Component(props: BlurdotProps): ReactNode {
        const {color0, color1, spring, children, ... more} = props;
        return (
            <Col.Component
            spring={{
                "background": `radial-gradient(closest-side, ${color0}, ${color1})`,
                opacity: ".05",
                ... spring ?? {},
            }}
            {... more}>
                {children}
            </Col.Component>
        );
    }
}

export type { BlurdotProps };
export { Blurdot };