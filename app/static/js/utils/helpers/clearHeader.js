import Component from "../Component.js";

export default function clearHeader() {
    const component = new Component();
    component.syncToElement("header");
    component.deleteInnerHTML();
}