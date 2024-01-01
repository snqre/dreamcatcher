/** stylesheet-v1.0.0 */

class Stylesheet {
    constructor() {
        this.format();
    }

    push(selector, style) {
        this.selectors[selector] = true;
        this.sheet[selector] = style;
    }

    pop(selector) {
        this.push(selector, "initial");
        delete this.selectors[selector];
    }

    compile() {
        return this.sheet;
    }

    format() {
        this.sheet = {};
        this.selectors = {};
        this.animations = {};
    }
}
