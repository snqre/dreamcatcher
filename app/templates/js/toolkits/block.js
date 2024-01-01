export default class Block {
    constructor(represent='', content='', style={}, inner=[]) {
        this.element;
        this.updateStyle(style);
    }

    removeClassName(className) {
        this.element.classList.remove(className);
        return true;
    }

    syncToClassName(className) {
        this.element.classList.add(className);
        return true;
    }

    syncToElement(element) {
        this.element = document.querySelector(element);
        return true;
    }

    syncToNewElement(element) {
        this.element = document.createElement(element);
        return true;
    }

    updateStyle(style) {
        Object.assign(this.element.style, style);
        return true;
    }

    updateText(text) {
        this.element.textContent = text;
        return true;
    }

    injectText(text) {
        this.element.textContent += text;
        return true;
    }

    updateSourceCodeHTML(source) {

    }
}


export class Component {
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

component('/style ')

function component(content='', style={}, inject=[]) {
    const element = document.createElement('div');
    Object.assign(element.style, style);

    let input = content.substring(0, 6);
    
    switch (input) {
        case '/style ':
            break
    }

    if (content !== '') {
        try {
            element.textContent = content;
        } catch {
        }
    }
    if (inject.length !== 0) {
        for (let i = 0; i < inject.length; i++) {
            try {
                element.appendChild(inject[i]);
            } catch {
                element.classList.add(inject[i]);
            }
        }
    }
    return element;
}