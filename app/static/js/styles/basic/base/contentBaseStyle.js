import Component from "../Component.js";

export default function contentBaseStyle() {
    const component = new Component();
    component.syncToNewElement('style');
    component.updateInnerHTML(
        `
            content {
                width: 100%;
                height: auto;
                position: absolute;
                display: flex;
                flexDirection: column;
                alignItems: center;
            }
        `
    );
    return component;
}