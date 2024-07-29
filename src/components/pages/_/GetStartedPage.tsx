import type { ReactNode } from "react";
import { Page } from "@layout/Page";
import { Layer } from "@layout/Layer";
import { BlurDot } from "@decorations/BlurDot";
import { Navbar } from "@components/ui/_/Navbar";
import { ObsidianContainerWithPhantomSteelFrame } from "@components/layout/containers/frames/ObsidianContainerWithPhantomSteelFrame";
import { Col } from "@layout/Col";
import { Row } from "@layout/Row";
import { Gutter } from "@layout/Gutter";
import { InputField } from "@components/input/InputField";
import { Text } from "@text/Text";
import { Deployment } from "@state/Deployment";

function GetStartedPage(): ReactNode {
    return (
        <Page style={{ background: "#171717" }}>
            <Layer>
                <BlurDot color0="#0652F4" color1="#171717" style={{ width: "1000px", height: "1000px", position: "absolute" }}/>
            </Layer>
            <Layer style={{ justifyContent: "start" }}>
                <Navbar/>
                <Gutter style={{ height: "60px" }}/>
                <Col style={{ flex: 1 }}>
                    <ObsidianContainerWithPhantomSteelFrame style={{ width: "800px", height: "500px", justifyContent: "start", overflowY: "scroll", gap: "20px" }}>

                    </ObsidianContainerWithPhantomSteelFrame>
                </Col>
            </Layer>
        </Page>
    );
}








export { GetStartedPage };