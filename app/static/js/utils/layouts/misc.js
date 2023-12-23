import row from "./row.js";

export default function misc(string="", style={}, components=[]) {
    const component = row("100%", "100%", style, components);
    component.updateText(string);
    return component;
}