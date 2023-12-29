import head from "./explicit/head.js";
import bodyBaseStyle from "../../styles/bodyBaseStyle.js";
import buttonStyle from "../../styles/buttonStyle.js";
import everythingBaseStyle from "../../styles/everythingBaseStyle.js";
import navbarStyle from "../../styles/navbarStyle.js";
import headerBaseStyle from "../../styles/headerBaseStyle.js";
import contentBaseStyle from "../../styles/contentBaseStyle.js";
import hoverStyle from "../../styles/hoverStyle.js";

export default function init() {
    head().attach([
        bodyBaseStyle(),
        buttonStyle(),
        everythingBaseStyle(),
        navbarStyle(),
        headerBaseStyle(),
        contentBaseStyle(),
        hoverStyle()
    ]);
}