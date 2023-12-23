import row from "./row.js";
import colors from "../colors.js";

export default function heading(slice=0, string="", style={}, components=[]) {
    const component = row("100%", `${slice}%`, {}, components);
    component.updateStyle({
        background: colors.bgContrast,
        color: colors.stringContrast,
        fontWeight: "bold"
    });
    component.updateStyle(style);
    component.updateText(string);
    return component;
}