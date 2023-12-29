import Component from "../Component.js";

export default function columnStyle() {
    const component = new Component();
    component.syncToNewElement('style');
    component.updateInnerHTML(
        `
            .column {
                display: flex;
                flex-direction: column;
                justify-content: center;
                align-items: center;
            }
        `
    );
    return component;
}