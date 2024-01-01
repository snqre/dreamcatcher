export default class Search {
    forScriptElementWithSourceThatIncludes(content) {
        const scripts = document.querySelectorAll("script");
        scripts.forEach(script => {
            if (script.src.includes(content)) {
                return script;
            }
        });
    }
}