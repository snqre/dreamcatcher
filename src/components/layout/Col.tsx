import type {ReactNode} from "react";
import type {ControllerProps} from "@components/Controller";
import {Controller} from "@components/Controller";

interface ColProps extends ControllerProps {}

class Col {
    public static Component(props: ColProps): ReactNode {
        let {spring, children, ... more} = props;
        return (
            <Controller.Component
            spring={{
                "display": "flex",
                "flexDirection": "column",
                "justifyContent": "center",
                "alignItems": "center",
                ... spring ?? {},
            }}
            {... more}>
                {children}
            </Controller.Component>
        );
    }
}

export type {ColProps};
export {Col};