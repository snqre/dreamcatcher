import head from "./explicit/head.js";
import bodyBaseStyle from "../styles/bodyBaseStyle.js";
import buttonFluxAnimationStyle from "../styles/buttonFluxAnimationStyle.js";
import buttonStyle from "../styles/buttonStyle.js";
import everythingBaseStyle from "../styles/everythingBaseStyle.js";
import navbarStyle from "../styles/navbarStyle.js";
import headerBaseStyle from "../styles/headerBaseStyle.js";
import contentBaseStyle from "../styles/contentBaseStyle.js";

export default function init() {
    head().attach([
        bodyBaseStyle(),
        buttonFluxAnimationStyle(),
        buttonStyle(),
        everythingBaseStyle(),
        navbarStyle(),
        headerBaseStyle(),
        contentBaseStyle()
    ]);
}