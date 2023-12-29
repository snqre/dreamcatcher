import Component from "../Component.js";

export default function flex3Style() {
    const component = new Component();
    component.syncToNewElement('style');
    component.updateInnerHTML(
        `
            .flex-3 {
                width: 100%;
                height: 100%;
                flex: 3;
            }   
        `
    );
    return component;
}