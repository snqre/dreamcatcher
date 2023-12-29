import Component from "../../Component.js";

export default function header() {
    const component = new Component();
    component.syncToElement("header");
    return component;
}