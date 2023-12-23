import Component from "../Component.js";
import {colors} from "../colors.js";

export default function bodyBaseStyle() {
    const component = new Component();
    component.syncToNewElement("style");
    component.updateInnerHTML(
        `
        body {
            background: ${colors.bg};
            color: ${colors.string};
            font-family: DejaVu Sans Mono, monospace;
        }
        `
    );
    return component;
}