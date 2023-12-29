import Component from "../Component.js";

export default function flex2Style() {
    const component = new Component();
    component.syncToNewElement('style');
    component.updateInnerHTML(
        `
            .flex-2 {
                width: 100%;
                height: 100%;
                flex: 2;
            }   
        `
    );
    return component;
}