import type { ReactNode } from "react";
import type { CSSProperties } from "react";
import { PhantomSteelHorizontalLine } from "@decorations/PhantomSteelHorizontalLine";
import { animated } from "react-spring";
import { useSpring } from "react-spring";

type PulseProps = {
    delay?: number;
    reverse?: boolean;
    style?: CSSProperties;
};

function Pulse(props: PulseProps): ReactNode {
    let { delay, reverse, style } = props;
    return (
        <PhantomSteelHorizontalLine
        style={ style ?? {} }>
            <animated.div
            $style={{
                ...useSpring({
                    from: {
                        left: reverse ?? false ? "-10%" : "110%"
                    },
                    to: {
                        left: reverse ?? false ? "110%" : "-10%"
                    },
                    delay: delay,
                    config: {
                        tension: 5,
                        friction: 4
                    },
                    loop: true
                }),
                ... {
                    width: "40px",
                    height: "2.5px",
                    bottom: "1.25px",
                    background: `linear-gradient(${ reverse ?? false ? "to right" : "to left" }, transparent, rgba(163, 163, 163, .25))`,
                    borderRadius: "25px",
                    position: "relative"
                }
            }}/>
        </PhantomSteelHorizontalLine>
    );
}

export type { PulseProps };
export { Pulse };