import Block from "./block-v1.0.0.js";

export default class Stream {
    init() {
        
        const head = new Block();
        head.syncToElement("head");
        const allInitialStyleElements = head.element.querySelectorAll("style");
        allInitialStyleElements.forEach(styleElement => {
            head.element.removeChild(styleElement);
        });
        this.findScriptElement();
        return true;
    }

    findScriptElement() {
        // Get all script elements in the document
        const scriptElements = document.querySelectorAll('script');

        // Iterate through each script element
        scriptElements.forEach(scriptElement => {
            // Check if the src attribute contains the word "silicon-stream"
            if (scriptElement.src.includes('silicon-stream')) {
                console.log('Found script element:', scriptElement);
            }
        });
    }
}