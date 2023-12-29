import Component from "../utils/Component.js";

export default function head() {
    const component = new Component();
    component.syncToElement('head');
    return component;
}