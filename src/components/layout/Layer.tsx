import type {ReactNode} from "react";
import type {ColProps} from "@layout/Col";
import {Col} from "@layout/Col";

interface LayerProps extends ColProps {}

class Layer {
    public static Component(props: LayerProps): ReactNode {
        let {spring, children, ...more} = props;
        return (
            <Col.Component
            spring={{
                "width": "100%",
                "height": "100%",
                "position": "absolute",
                "overflow": "hidden",
                "pointerEvents": "none",
                ... spring ?? {},
            }}
            {... more}>
                {children}
            </Col.Component>
        );
    }
}

export type {LayerProps};
export {Layer};