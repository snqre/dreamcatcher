import Component from "../Component.js";

export default function bodyBaseStyle() {
    const component = new Component();
    component.syncToNewElement('style');
    component.updateInnerHTML(
        `
            body {
                font-family: "Urbanist", sans-serif;
            }
        `
    );
    return component;
}