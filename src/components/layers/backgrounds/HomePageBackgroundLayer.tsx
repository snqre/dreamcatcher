import {Layer} from "@layout/Layer";
import {ColorPalette} from "@color/Color";
import {Blurdot} from "@decorations/BlurDot";
import React from "react";

class HomePageBackgroundLayer {
    public static Component(): React.ReactNode {
        return (
            <Layer.Component
            spring={{
                "background": ColorPalette.OBSIDIAN.toHex().toString(),
            }}>
                <Blurdot.Component
                color0={ColorPalette.DEEP_PURPLE.toHex().toString()}
                color1={ColorPalette.OBSIDIAN.toHex().toString()}
                spring={{
                    "width": "1000px",
                    "height": "1000px",
                    "position": "absolute",
                    "right": "400px",
                }}/>
                <Blurdot.Component
                color0="#0652FE"
                color1={ColorPalette.OBSIDIAN.toHex().toString()}
                spring={{
                    "width": "1000px",
                    "height": "1000px",
                    "position": "absolute",
                    "left": "400px",
                }}/>
            </Layer.Component>
        );
    }
}

export {HomePageBackgroundLayer};