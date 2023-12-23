import Component from "../Component.js";

export default function button(string="", style={}, components=[]) {
    const component = new Component();
    component.syncToNewElement("div");
    component.syncToClassName("button");
    component.updateText(string);
    component.updateStyle(style);
    component.attach(components);
    return component;
}