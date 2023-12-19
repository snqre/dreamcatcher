export default class Block {
    constructor() {
        this.element;
    }

    updateStyle(stylesheet) {
        Object.assign(this.element.style, stylesheet);
        return true;
    }

    fill() {
        this.updateStyle({width: "100%"});
        this.updateStyle({height: "100%"});
        return true;
    }
    
    fillWindow() {
        this.updateStyle({width: "100vw"});
        this.updateStyle({height: "100vh"});
        return true;
    }

    updateClassName(className) {
        this.element.className = className;
        return true;
    }

    updateTextContent(text) {
        this.element.textContent = text;
        return true;
    }

    updateHTMLSourceCode(sourceCode) {
        this.element.innerHTML = sourceCode;
        return true;
    }

    attach(block) {
        this.element.appendChild(block.element);
        return true;
    }

    syncToNewElement(element) {
        this.element = document.createElement(element);
        return true;
    }

    syncToElement(element) {
        this.element = document.querySelector(element);
        return true;
    }

    syncToClassName(element) {
        this.element = document.getElementsByClassName(element)[0];
        return true;
    }

    syncToClassName(element, position) {
        this.element = document.getElementsByClassName(element)[position];
        return true;
    }

    wipe() {
        this.element.innerHTML = "";
        return true;
    }
}