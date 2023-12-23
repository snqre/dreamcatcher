import Component from "../Component.js";
import {colors} from "../colors.js";

export default function buttonStyle() {
    const component = new Component();
    component.syncToNewElement("style");
    component.updateInnerHTML(
        `
        .button {
            background: ${colors.bgContrast};
            color: ${colors.stringContrast};
            display: flex;
            justify-content: center;
            align-items: center;
            pointer-events: auto;
        }

        .button:hover {
            background: ${colors.brand};
            color: ${colors.stringContrast};
            cursor: pointer;
        }
        `
    );
    return component;
}