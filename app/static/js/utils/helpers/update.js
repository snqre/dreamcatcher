import { route } from "../Route.js";
import content from "./explicit/content.js";
import header from "./explicit/header.js";
import clearContent from "./clearContent.js";
import clearHeader from "./clearHeader.js";
import navbar from "../sections/navbar.js";
import column from "../layouts/column.js";
import hero from "../sections/hero.js";
import team from "../sections/team.js";
import roadmap from "../sections/roadmap.js";

export default function update(route_) {
    clearContent();
    clearHeader();

    switch (route_) {
        case route.HOME:
            header().attach([
            ]);
            content().attach([
                column("100%", "100%", {}, [
                    hero()
                ])
            ]);
            break
        case 1:
            break
    }
}