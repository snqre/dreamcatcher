import type {ReactNode} from "react";
import {Text} from "@text/Text";
import {Col} from "@layout/Col";

class LogoAndBrandName {
    public static Component(): ReactNode {
        return (
            <Col.Component>
                <img
                src="../../img/Logo.png"
                style={{
                    "width": "25px",
                    "height": "25px",
                }}/>
                <Text.Component
                text="Dreamcatcher"
                style={{
                    "fontSize": "1.5em",
                }}/>
            </Col.Component>
        );
    }
}

export {LogoAndBrandName};