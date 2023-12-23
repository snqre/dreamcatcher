export default class Component {
    constructor() {
        this.element;
    }

    syncToElement(element) {
        this.element = document.querySelector(element);
    }

    syncToNewElement(element) {
        this.element = document.createElement(element);
    }

    updateStyle(object) {
        Object.assign(this.element.style, object);
    }

    syncToClassName(classNameString) {
        this.element.classList.add(classNameString);
    }

    releaseFromClassName(classNameString) {
        this.element.classList.remove(classNameString);
    }

    updateText(string) {
        this.element.textContent = string;
    }

    injectText(string) {
        this.element.textContent += string;
    }

    updateInnerHTML(HTML) {
        this.element.innerHTML = HTML;
    }

    injectInnerHTML(HTML) {
        this.element.innerHTML += HTML;
    }

    deleteInnerHTML() {
        this.element.innerHTML = "";
    }

    attach(components=[]) {
        if (components.length !== 0) {
            for (let i = 0; i < components.length; i++) {
                try {
                    this.element.appendChild(components[i].element);
                }
                /// will try to read it as a class name
                catch {
                    this.syncToClassName(components[i]);
                }
            }
        }
    }
}