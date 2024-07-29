import type { ReactNode } from "react";
import { Row } from "@layout/Row";
import { RowRemote } from "@layout/RowRemote";
import { LogoAndBrandName } from "@decorations/LogoAndBrandName";
import { NavbarButton } from "@components/buttons/_/NavbarButton";
import { Text } from "@text/Text";
import { Account } from "@state/Account";

function Navbar(): ReactNode {
    return (
        <Row style={{
            "width": "100%",
            "height": "auto",
            "marginTop": "40px",
        }}>
            <Row style={{
                "flex": 1,
                "marginLeft": "40px",
            }}>
                <Row style={{
                    "width": "100%",
                    "height": "100%",
                    "justifyContent": "flex-start",
                }}>
                    <LogoAndBrandName/>
                </Row>  
            </Row>
            <RowRemote style={{
                "flex": 1,
                "gap": "20px",
            }}
            at="navbar.menu.container"
            mountCooldown={100n}>
                <NavbarButton
                className="swing-in-top-fwd"
                text0="01"
                text1="Home"
                to="/"/>
                <NavbarButton
                className="swing-in-top-fwd"
                text0="02"
                text1="Whitepaper"
                to="https://dreamcatcher-1.gitbook.io/dreamcatcher"/>
                <NavbarButton
                className="swing-in-top-fwd"
                text0="03"
                text1="Explore"
                to="/explore"/>
                <NavbarButton
                className="swing-in-top-fwd"
                text0="04"
                text1="Quickstart"
                to="/get-started"/>
                <NavbarButton
                className="swing-in-top-fwd"
                text0="05"
                text1="Governance"
                to="/governance"/>
                <NavbarButton
                className="swing-in-top-fwd"
                text0="06"
                text1="Account"
                to="/account"/>
            </RowRemote>
            <Row style={{
                "flex": 1,
                "marginRight": "40px",
            }}>
                <Row style={{
                    "width": "100%",
                    "height": "100%",
                    "justifyContent": "flex-end",
                }}>
                    <Row style={{
                        "cursor": "pointer",
                        "pointerEvents": "auto",
                    }}
                    onClick={Account.connect}>
                        <Text style={{
                            "fontSize": "1.5em",
                        }}
                        text="Connect"/>
                    </Row>
                </Row>
            </Row>
        </Row>
    );
}

export { Navbar };