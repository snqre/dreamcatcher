import type {ReactNode} from "react";
import type {ColProps} from "@layout/Col";
import {Col} from "@layout/Col";
import {ColorPalette} from "@color/Color";

interface PageProps extends ColProps {
    hLen?: bigint,
    vLen?: bigint,
}

class Page {
    public static Component(props: PageProps): ReactNode {
        let {style, hLen, vLen, children, ... more} = props;
        hLen = hLen ?? 1n;
        vLen = vLen ?? 1n;
        let hLenNum: number = Number(hLen);
        let vLenNum: number = Number(vLen);
        let hPx: number = hLenNum * 100;
        let vPx: number = vLenNum * 100;
        let width: string = `${hPx}vw`;
        let height: string = `${vPx}vh`;
        return (
            <Col.Component
            spring={{
                "width": width,
                "height": height,
                "overflow": "hidden",
                "background": ColorPalette.OBSIDIAN.toHex().toString(),
                ... style ?? {},
            }}
            {... more}>
                {children}
            </Col.Component>
        );
    }
}

export type {PageProps};
export {Page};