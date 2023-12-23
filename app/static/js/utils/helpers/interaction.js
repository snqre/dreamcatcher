import body from "./explicit/body.js";
import update from "./update.js";
import {Route} from "../Route.js";

export default function interaction() {
    body().element.addEventListener("click", (event) => {
        const element = event.target;
        if (element.classList.contains("button")) {
            update(Route.HOME);
        }
    });
}