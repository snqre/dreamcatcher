import Component from "../Component.js";

export default function flex5Style() {
    const component = new Component();
    component.syncToNewElement('style');
    component.updateInnerHTML(
        `
            .flex-5 {
                width: 100%;
                height: 100%;
                flex: 5;
            }   
        `
    );
    return component;
}