import Component from "../Component.js";

export default function headerBaseStyle() {
    const component = new Component();
    component.syncToNewElement("style");
    component.updateInnerHTML(
        `
        header {
            width: 100vw;
            height: 100vh;
            overflow: hidden;
            position: fixed;
            z-index: 100;
            pointer-events: none;
        }
        `
    );
    return component;
}