import Block from "../../Block.js";

export default class Item extends Block {
    constructor() {
        super();
        this.syncToNewElement("div");
        this.fill();
    }

    updateGridSpot(xStart, xEnd, yStart, yEnd) {
        this.updateStyle({gridColumn: `${xStart} / ${xEnd}`});
        this.updateStyle({gridRow: `${yStart} / ${yEnd}`});
        return true;
    }
}