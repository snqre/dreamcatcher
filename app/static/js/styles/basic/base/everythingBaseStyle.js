import Component from "../Component.js";

export default function everythingBaseStyle() {
    const component = new Component();
    component.syncToNewElement('style');
    component.updateInnerHTML(
        `
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }
        `
    );
    return component;
}