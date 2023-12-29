import Component from "../../Component.js";

export default function row(width, height, style={}, components=[]) {
    const component = new Component();
    component.syncToNewElement("div");
    component.updateStyle({
        width: width,
        height: height,
        display: "flex",
        flexDirection: "row",
        alignItems: "center",
        justifyContent: "center"
    });
    component.updateStyle(style);
    component.attach(components);
    return component;
}