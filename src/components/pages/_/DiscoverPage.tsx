import type { ReactNode } from "react";
import { Page } from "@layout/Page";
import { Layer } from "@layout/Layer";
import { Navbar } from "@built/Navbar";
import { Gutter } from "@layout/Gutter";
import { Col } from "@layout/Col";
import { Window } from "@built/Window";

function DiscoverPage(): ReactNode {
    return <Page
    style={{
        background: "#171717"
    }}>
        <Layer>

        </Layer>
        <Layer 
        style={{ justifyContent: "start" }}>
            <Navbar/>
            <Gutter
            style={{
                height: "80px"
            }}/>
            <Col
            style={{
                width: "100%",
                height: "auto"
            }}>
                
            </Col>
        </Layer>
    </Page>
}

export { DiscoverPage };