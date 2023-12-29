import Component from "../Component.js";

export default function flex6Style() {
    const component = new Component();
    component.syncToNewElement('style');
    component.updateInnerHTML(
        `
            .flex-6 {
                width: 100%;
                height: 100%;
                flex: 6;
            }   
        `
    );
    return component;
}