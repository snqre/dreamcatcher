import Component from "../Component.js";

export default function image(width, height, url, style={}, components=[]) {
    const component = new Component()
    component.syncToNewElement("img");
    component.updateStyle({
        width: width,
        height: height,
        backgroundImage: `url(${url})`,
        backgroundSize: "contain",
        backgroundPosition: "center",
        backgroundRepeat: "no-repeat"
    });
    component.updateStyle(style);
    component.attach(components);
    return component;
}