import type { ReactNode } from "react";
import type { ComponentPropsWithoutRef } from "react";
import { Text } from "@text/Text"
import { Link } from "react-router-dom";
import React from "react";

type NavbarButtonProps = 
    ComponentPropsWithoutRef<typeof Link> & {
    text0: string;
    text1: string;
};

function NavbarButton(props: NavbarButtonProps): ReactNode {
    let { text0, text1, $style: style, children, ... more } = props;

    return (
        <Link
        $style={{
            pointerEvents: "auto",
            gap: "10px",
            textDecoration: "none",
            color: "white",
            display: "flex",
            flexDirection: "row",
            justifyContent: "center",
            alignItems: "center",
            ... style ?? {}
        }}
        { ... more }>
            <Text
            text={text0}
            style={{
                background: "#615FFF",
                fontSize: "15px",
                display: "flex",
                flexDirection: "row",
                justifyContent: "center",
                alignItems: "center"
            }}/>
            <Text
            text={text1}
            style={{
                fontSize: "15px",
                display: "15px",
                flexDirection: "row",
                alignItems: "center"
            }}/>
        </Link>
    );
}

export type { NavbarButtonProps };
export { NavbarButton };