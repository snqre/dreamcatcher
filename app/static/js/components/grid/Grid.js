import Block from "../../Block.js";

export default class Grid extends Block {
    constructor() {
        super();
        this.syncToNewElement("div");
        this.updateStyle({display: "grid"});
        this.updateStyle({gridTemplateColumns: "repeat(1, 1fr)"});
        this.updateStyle({gridTemplateRows: "repeat(1, 1fr)"});
    }

    updateNumberOfColumns(numberOfColumns) {
        this.updateStyle({gridTemplateColumns: `repeat(${numberOfColumns}, 1fr)`});
        return true;
    }

    updateNumberOfRows(numberOfRows) {
        this.updateStyle({gridTemplateRows: `repeat(${numberOfRows}, 1fr)`});
        return true;
    }
}