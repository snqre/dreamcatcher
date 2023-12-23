import Component from "../Component.js";
import {colors} from "../colors.js";

export default function navbarStyle() {
    const component = new Component();
    component.syncToNewElement("style");
    component.updateInnerHTML(
        `
        ::-webkit-scrollbar {
            width: 5px;
        }

        ::-webkit-scrollbar-track {
            background: ${colors.bg};
        }

        ::-webkit-scrollbar-thumb {
            background: ${colors.brand};
        }
        `
    );
    return component;
}