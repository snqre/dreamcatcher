export default class Component {
    constructor() {
        this.element;
    }

    syncToElement(element) {
        this.element = document.querySelector(element);
        return;
    }

    syncToNewElement(element) {
        this.element = document.createElement(element);
        return;
    }

    updateStyle(object) {
        Object.assign(this.element.style, object);
        return;
    }

    syncToClassName(classNameString) {
        this.element.classList.add(classNameString);
        return;
    }

    releaseFromClassName(classNameString) {
        this.element.classList.remove(classNameString);
        return;
    }

    updateText(string) {
        this.element.textContent = string;
        return;
    }

    injectText(string) {
        this.element.textContent += string;
        return;
    }

    updateInnerHTML(HTML) {
        this.element.innerHTML = HTML;
        return;
    }

    injectInnerHTML(HTML) {
        this.element.innerHTML += HTML;
        return;
    }

    deleteInnerHTML() {
        this.element.innerHTML = "";
        return;
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
        return;
    }
}