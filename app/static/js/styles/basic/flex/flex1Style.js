import Component from "../Component.js";

export default function flex1Style() {
    const component = new Component();
    component.syncToNewElement('style');
    component.updateInnerHTML(
        `
            .flex-1 {
                width: 100%;
                height: 100%;
                flex: 1;
            }   
        `
    );
    return component;
}