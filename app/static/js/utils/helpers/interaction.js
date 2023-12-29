import body from "./explicit/body.js";
import update from "./update.js";
import { route } from "../Route.js";

export default function interaction() {
    body().element.addEventListener("click", (event) => {
        const classList = event.target.classList;
        if (classList.contains("menu-button-home")) {
            update(route.HOME);
        } else if (classList.contains("menu-button-whitepaper")) {
            window.location.href = "/whitepaper";
        } else if (classList.contains("menu-button-telegram")) {
            console.log("team");
        }
    });
}