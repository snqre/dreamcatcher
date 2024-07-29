import type { ReactNode } from "react";
import type { EventSubscription } from "@events-handler";
import { Page } from "@layout/Page";
import { Layer } from "@layout/Layer";
import { BlurDot } from "@decorations/BlurDot";
import { Navbar } from "@built/Navbar";
import { ObsidianContainerWithPhantomSteelFrame } from "@components/layout/containers/frames/ObsidianContainerWithPhantomSteelFrame";
import { Row } from "@layout/Row";
import { RowRemote } from "@layout/RowRemote";
import { Col } from "@layout/Col";
import { ColRemote } from "@layout/ColRemote";
import { Text } from "@text/Text";
import { TextRemote } from "@text/TextRemote";
import { InputField } from "@components/input/InputField";
import { TextInput } from "@components/input/TextInput";
import { SubmitButton } from "@components/buttons/_/SubmitButton";
import { useEffect } from "react";
import { useState } from "react";
import { hook } from "@events-handler";
import { emit } from "@events-handler";
import { post } from "@axios";



function ExplorePage(): ReactNode {
    let [searchInput, setSearchInput] = useState<string>("");
    let [name, setName] = useState<string>("");
    let [symbol, setSymbol] = useState<string>("");

    useEffect(function(): void {

    }, [searchInput]);

    return (
        <Page style={{ background: "#171717" }}>
            <Layer>
                <BlurDot color0="#0652FE" color1="#161616" style={{ width: "1000px", height: "1000px", position: "absolute" }}/>
            </Layer>
            <Layer style={{ justifyContent: "start" }}>
                <Navbar/>
                <Row 
                style={{ 
                    "marginTop": "80px" 
                }}>
                    <ObsidianContainerWithPhantomSteelFrame 
                    phantomSteelFrameDirection="to left" 
                    style={{ 
                        "width": "500px", 
                        "height": "500px", 
                        "padding": "10px", 
                        "justifyContent": "start"    
                    }}>
                        <Col style={{ 
                            "width": "500px", 
                            "height": "50px", 
                            "margin": "10px" 
                        }}>
                            <Row /// Search Bar
                            style={{
                                "width": "480px",
                                "height": "50px",
                                "padding": "10px",
                                "borderWidth": "1px",
                                "borderStyle": "solid",
                                "borderImage": "linear-gradient(to right, #615FFF, #9662FF) 1",
                                "gap": "10px"
                            }}>
                                <img
                                src="../../img/SearchIcon.png"
                                $style={{
                                    "width": "25px",
                                    "height": "25px"
                                }}/>
                                <input
                                type="text"
                                spellCheck={ false }
                                onChange={ event => setSearchInput(event.target.value) }
                                placeholder="0x0000000000000000000000000000000000000000"
                                $style={{
                                    "width": "400px",
                                    "height": "50px",
                                    "backgroundColor": "transparent",
                                    "outline": "none",
                                    "boxShadow": "none",
                                    "color": "#D6D5D4",
                                    "fontFamily": "monospace",
                                    "fontSize": "1em",
                                    "background": "transparent",
                                    "pointerEvents": "auto",
                                    "border": "none"
                                }}/>
                            </Row>
                        </Col>
                    </ObsidianContainerWithPhantomSteelFrame>
                    <ObsidianContainerWithPhantomSteelFrame 
                    phantomSteelFrameDirection="to right" 
                    style={{ 
                        "width": "250px", 
                        "height": "500px", 
                        "justifyContent": "start",
                        "gap": "10px",
                    }}>
                        <RowRemote
                        at="mintButton"
                        spring={{ 
                            "width": "250px", 
                            "height": "50px",
                            "justifyContent": "start",
                            "gap": "10px",
                            "background": "#191919",
                            "pointerEvents": "auto",
                            "cursor": "pointer",
                        }}
                        onMouseEnter={ () => emit({
                            "from": "mintButton",
                            "type": "setSpring",
                            "item": {
                                "background": "#202020",
                            }
                        }) }
                        onMouseLeave={ () => emit({
                            "from": "mintButton",
                            "type": "setSpring",
                            "item": {
                                "background": "#191919",
                            }
                        }) }
                        onClick={ () => emit({
                            "from": "popUps",
                            "type": "mount",
                            "item": (
                                <Col
                                style={{
                                    "width": "400px",
                                    "height": "200px",
                                    "background": "#191919"
                                }}>
                                    <input
                                    type="text"
                                    spellCheck={ false }
                                    onChange={ event => setSearchInput(event.target.value) }
                                    placeholder="Amount in USDC"
                                    $style={{
                                        "width": "400px",
                                        "height": "50px",
                                        "backgroundColor": "transparent",
                                        "outline": "none",
                                        "boxShadow": "none",
                                        "color": "#D6D5D4",
                                        "fontFamily": "monospace",
                                        "fontSize": "1em",
                                        "background": "transparent",
                                        "pointerEvents": "auto",
                                        "border": "none"
                                    }}/>
                                    <Col
                                    style={{
                                        "width": "50px",
                                        "height": "25px",
                                        "background": "#615FFF"
                                    }}>
                                        <Text
                                        text="Confirm"/>
                                    </Col>
                                </Col>
                            )
                        })}>
                            <img
                            src="../../img/Command.png"
                            $style={{
                                "width": "25px",
                                "height": "25px",
                            }}/>
                            <Text
                            text="Mint"
                            style={{
                                "fontSize": "0.75em",
                                "fontWeight": "bold",
                            }}/>

                        </RowRemote>

                    </ObsidianContainerWithPhantomSteelFrame>
                </Row>
            </Layer>
            <Layer>
                <ColRemote
                at="popUps"
                style={{
                    "width": "100%",
                    "height": "100%",
                }}/>
            </Layer>
        </Page>
    );

    /**
    return <PageWrapper>
        <Background/>
        <Content>
            <Navbar/>
            <WindowsWrapper>
                <Window frameDirection="to left" style={{ width: "500px", height: "500px", padding: "40px" }}>
                    <Col style={{ width: "500px", height: "50px", justifyContent: "center", marginBottom: "20px" }}>
                        <Row style={{ width: "480px", height: "45px", borderColor: "#505050", borderWidth: "1px", borderStyle: "solid", justifyContent: "space-between" }}>
                            <TextInput at="explorePage.searchBar" placeholder="0x0000000000000000000000000000000000000000" style={{ width: "450px", height: "45px", padding: "10px", fontSize: "0.75em" }}/>
                            <SubmitButton at="explorePage.searchBar.submitButton" style={{ width: "45px", height: "45px" }}/>
                        </Row>
                    </Col>
                    <Row style={{ width: "500px", height: "50px", gap: "40px" }}>
                        <TextRemote at="explorePage.name" text="<name>" style={{ fontSize: "1em", background: "#615FFF" }}/>
                        <TextRemote at="explorePage.symbol" text="<symbol>" style={{ fontSize: "0.75em" }}/>
                        <TextRemote at="explorePage.address" text="<address>" style={{ fontSize: "0.75em" }}/>
                    </Row>
                    <Row style={{ width: "500px", height: "400px", justifyContent: "center" }}>
                        <Col style={{ width: "150px", height: "400px", gap: "20px" }}>
                            <TextRemote at="explorePage.totalSupply" text="<totalSupply>"/>
                            <TextRemote at="explorePage.totalAssets" text="<totalAssets>"/>
                        </Col>
                        <Col style={{ width: "150px", height: "400px" }}>
                            <TextRemote at="explorePage.price" text="<price>" style={{ fontSize: "2em" }}/>
                        </Col>
                        <Col style={{ width: "150px", height: "400px" }}>
                        </Col>
                    </Row>
                </Window>
                <Window frameDirection="to right" style={{ width: "250px", height: "500px", justifyContent: "start", padding: "10px", gap: "10px" }}>
                    <Row style={{ width: "100%", height: "30px", borderWidth: "1px", borderColor: "#505050", borderStyle: "dotted", justifyContent: "space-between", paddingLeft: "20px" }}>
                        <Text text="Mint" style={{ fontSize: "0.75em" }}/>
                        <TextInput at="mintButton.amountToSend" placeholder="Amount in USDC" style={{ fontSize: "0.75em" }}/>
                        <SubmitButton at="mintButton.submitButton" style={{ width: "30px", height: "30px" }}/>
                    </Row>
                    <Row style={{ width: "100%", height: "30px", borderWidth: "1px", borderColor: "#505050", borderStyle: "dotted", justifyContent: "space-between", paddingLeft: "20px" }}>
                        <Text text="Burn" style={{ fontSize: "0.75em" }}/>
                        <TextInput at="burnButton.amountToBurn" placeholder="Amount in Shares" style={{ fontSize: "0.75em" }}/>
                        <SubmitButton at="burnButton.submitButton" style={{ width: "30px", height: "30px" }}/>
                    </Row>
                </Window>
            </WindowsWrapper>
        </Content>
    </PageWrapper>;

    */
}

export { ExplorePage };