import type {ReactNode} from "react";
import type {ColProps} from "@layout/Col";
import {Col} from "@layout/Col";

interface RowProps extends ColProps {}

class Row {
    public static Component(props: RowProps): ReactNode {
        let {spring, children, ... more} = props;
        return (
            <Col.Component
            spring={{
                "flexDirection": "row",
                ... spring ?? {},
            }}
            {... more}>
                {children}
            </Col.Component>
        );
    }
}

export type {RowProps};
export {Row};