import type { ReactNode } from "react";
import { Col } from "@layout/Col";
import { Row } from "@layout/Row";
import { Text } from "@text/Text";

function Alert({ caption, message }: { caption?: string; message: string; }): ReactNode {
    return (
        <Col style={{ width: "350px", height: "200px", pointerEvents: "none" }}>
            { caption ? (
                <Row style={{ width: "350px", height: "50px" }}>
                    <Text text={ caption } style={{ fontSize: "10px", fontWeight: "bold" }}/>
                </Row>
            ) : null }
            <Row style={{ width: "350px", height: caption ? "75px" : "125px" }}>
                <Text text={ message } style={{ fontSize: "10px" }}/>   
            </Row>
            <Row style={{ width: "350px", height: "75px" }}>
                <img src="../../../img/Logo.png" $style={{ width: "20px", height: "20px" }}/>
            </Row>
        </Col>
    );
}

export { Alert };