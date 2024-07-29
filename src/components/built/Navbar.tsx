import type { ReactNode } from "react";
import { Row } from "@layout/Row";
import { RowRemote } from "@layout/RowRemote";
import { LogoAndBrandName } from "@decorations/LogoAndBrandName";
import { NavbarButton } from "@components/buttons/_/NavbarButton";
import { Gutter } from "@layout/Gutter";

function Navbar(): ReactNode {
    return (
        <Row
        style={{
            width: "100%",
            height: "auto",
            justifyContent: "start"
        }}>
            <Row
            style={{
                justifyContent: "center",
                marginTop: "40px",
                marginLeft: "20px"
            }}>
                <LogoAndBrandName/>
                <Gutter
                style={{
                    width: "40px"
                }}/>
                <RowRemote
                at="navbar.options.wrapper"
                mountCooldown={ 100n }
                style={{
                    gap: "20px"
                }}>
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
                    text1="Discover"
                    to="/discover"/>
                    <NavbarButton
                    className="swing-in-top-fwd"
                    text0="04"
                    text1="Explore"
                    to="/explore"/>
                    <NavbarButton
                    className="swing-in-top-fwd"
                    text0="05"
                    text1="GetStarted"
                    to="/get-started"/>
                    <NavbarButton
                    className="swing-in-top-fwd"
                    text0="06"
                    text1="Account"
                    to="/account"/>
                </RowRemote>
            </Row>
        </Row>
    );
}

export { Navbar };