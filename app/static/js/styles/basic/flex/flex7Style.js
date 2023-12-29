import Component from "../Component.js";

export default function flex7Style() {
    const component = new Component();
    component.syncToNewElement('style');
    component.updateInnerHTML(
        `
            .flex-7 {
                width: 100%;
                height: 100%;
                flex: 7;
            }   
        `
    );
    return component;
}