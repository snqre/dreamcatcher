import Component from "../Component.js";

export default function flex4Style() {
    const component = new Component();
    component.syncToNewElement('style');
    component.updateInnerHTML(
        `
            .flex-4 {
                width: 100%;
                height: 100%;
                flex: 4;
            }   
        `
    );
    return component;
}