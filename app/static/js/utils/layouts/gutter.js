import row from "./row.js";

export default function gutter(slice=0, style={}, components=[]) {
    const component = row("100%", `${slice}%`, {}, components);
    return component;
}