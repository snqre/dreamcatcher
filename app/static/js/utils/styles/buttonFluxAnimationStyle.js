import Component from "../Component.js";
import {colors} from "../colors.js";

export default function buttonFluxAnimationStyle() {
    const component = new Component();
    component.syncToNewElement("style");
    component.updateInnerHTML(
        `
        .button-flux-animation {
            animation: buttonFluxAnimation 1s infinite alternate ease-out;
        }

        @keyframes buttonFluxAnimation {
            from {
                background-color: ${colors.bgContrast};
            } to {
                background-color: ${colors.brand};
            }
        }
        `
    );
    return component;
}