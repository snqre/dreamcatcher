import Component from "../../Component.js";

export default function image(width, height, url, style={}, components=[]) {
    const component = new Component()
    component.syncToNewElement("img");
    component.updateStyle({
        width: width,
        height: height,
        backgroundSize: "contain",
        backgroundPosition: "center",
        backgroundRepeat: "no-repeat"
    });
    component.element.src = url;
    component.updateStyle(style);
    component.attach(components);
    return component;
}