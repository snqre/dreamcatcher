import column from "./column.js";
import row from "./row.js";

export default function captionSubCallToAction(slice=0, headingComponents=[], subHeadingComponents=[], buttonComponents=[]) {
    const component = column("100%", `${slice}%`);
    
    function heading() {
        const heading = row("100%", "auto", {}, headingComponents);
        heading.updateStyle({
            fontSize: "4rem",
            fontWeight: "bold"
        });
        return heading;
    }

    function subHeading() {
        const subHeading = row("100%", "auto", {}, subHeadingComponents);
        subHeading.updateStyle({
            fontSize: "1.25rem"
        });
        return subHeading;
    }

    function button() {
        const button = row("100%", "auto", {}, buttonComponents);
        return button;
    }

    component.attach([
        heading(),
        subHeading(),
        button()
    ]);
    return component;
}