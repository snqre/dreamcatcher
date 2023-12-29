import Component from "../Component.js";

export default function flex8Style() {
    const component = new Component();
    component.syncToNewElement('style');
    component.updateInnerHTML(
        `
            .flex-8 {
                width: 100%;
                height: 100%;
                flex: 8;
            }   
        `
    );
    return component;
}