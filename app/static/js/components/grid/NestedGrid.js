import Block from "../../Block.js";

export default class NestedGrid extends Block {
    constructor() {
        super();
        this.syncToNewElement("div");
        this.updateStyle({display: "grid"});
        this.updateStyle({gridTemplateColumns: "repeat(1, 1fr)"});
        this.updateStyle({gridTemplateRows: "repeat(1, 1fr)"});
        this.fill();
    }

    updateNumberOfColumns(numberOfColumns) {
        this.updateStyle({gridTemplateColumns: `repeat(${numberOfColumns}, 1fr)`});
        return true;
    }

    updateNumberOfRows(numberOfRows) {
        this.updateStyle({gridTemplateRows: `repeat(${numberOfRows}, 1fr)`});
        return true;
    }

    updateGridSpot(xStart, xEnd, yStart, yEnd) {
        this.updateStyle({gridColumn: `${xStart} / ${xEnd}`});
        this.updateStyle({gridRow: `${yStart} / ${yEnd}`});
        return true;
    }
}