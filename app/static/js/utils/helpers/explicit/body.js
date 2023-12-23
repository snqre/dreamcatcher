import Component from "../../Component.js";

export default function body() {
    const component = new Component();
    component.syncToElement("body");
    return component;
}