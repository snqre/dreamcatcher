import Component from "../Component.js";

export default function column(width, height, style={}, components=[]) {
    const component = new Component();
    component.syncToNewElement("div");
    component.updateStyle({
        width: width,
        height: height,
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center"
    });
    component.updateStyle(style);
    component.attach(components);
    return component;
}