import {Route} from "../Route.js";
import content from "./explicit/content.js";
import header from "./explicit/header.js";
import clearContent from "./clearContent.js";
import clearHeader from "./clearHeader.js";
import navbarSection from "../sections/navbarSection.js";
import headlineSection from "../sections/headlineSection.js";
import column from "../layouts/column.js";

export default function update(route) {
    clearContent();
    clearHeader();

    switch (route) {
        case Route.HOME:
            header().attach([
                navbarSection()
            ]);
            content().attach([
                column("100%", "100%", {}, [
                    headlineSection(),
                    headlineSection(),
                    headlineSection(),
                    headlineSection()
                ])
            ]);
            break
    }
}