import Component from "../Component.js";

export default function rowStyle() {
    const component = new Component();
    component.syncToNewElement('style');
    component.updateInnerHTML(
        `
            .row {
                display: flex;
                flex-direction: row;
                justify-content: center;
                align-items: center;
            }
        `
    );
    return component;
}