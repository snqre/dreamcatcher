import Stream from "./mods/stream-v1.0.0.js";
import Search from "./mods/search-v1.0.0.js";

function init() {
    const stream = new Stream();
    stream.init();
}

init();


const search = new Search();
const myScript = search.forScriptElementWithSourceThatIncludes("silicon-stream");
console.log(myScript);

const some = (() => {
    const something = () => {
        return true;
    };

    return {
        something
    };
})();

some.something();