import row from "./row.js";
import column from "./column.js";
import image from "./image.js";

export default function leftContentRightImage(slice=0, url="", style={}, imageStyle={}, components=[]) {
    const component = row("100%", `${slice}%`);

    function left() {
        const left = column("75%", "100%");
        left.updateStyle({
            padding: "2%"
        });

        function container() {
            const container = new column("100%", "100%", style, components);
            return container;
        }

        left.attach([container()]);
        return left;
    }

    function right() {
        const right = column("25%", "100%", {}, [
            image("100%", "100%", url, imageStyle)
        ]);
        right.updateStyle({
            padding: "2%"
        });
        return right;
    }

    component.attach([left(), right()]);
    return component;
}