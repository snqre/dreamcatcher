import Component from "../../Component.js";

export default function clearContent() {
    const component = new Component();
    component.syncToElement("content");
    component.deleteInnerHTML();
}