import Component from "../Component.js";

export default function flex9Style() {
    const component = new Component();
    component.syncToNewElement('style');
    component.updateInnerHTML(
        `
            .flex-9 {
                width: 100%;
                height: 100%;
                flex: 9;
            }   
        `
    );
    return component;
}