import Component from "../../Component.js";

export default function content() {
    const component = new Component();
    component.syncToElement("content");
    return component;
}