import Component from "../../Component.js";

export default function any(content="", style={}, components=[]) {
    const component = new Component();
    component.syncToNewElement("div");
    component.updateStyle(style);
    component.attach(components);
    if (content !== "") {
        component.updateText(content);
    }
    return component;
}