import Component from "../Component.js";

export default function scrollbarBaseStyle() {
    const component = new Component();
    component.syncToNewElement('style');
    component.updateInnerHTML(
        `
            ::-webkit-scrollbar {
                width: 5px;
            }

            ::-webkit-scrollbar-track {
                background: #FFF;
            }

            ::-webkit-scrollbar-thumb {
                background: #FFF;
            }
        `
    );
    return component;
}