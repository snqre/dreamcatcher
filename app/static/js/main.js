import Block from "./Block.js";
import Grid from "./components/grid/Grid.js";
import Item from "./components/grid/Item.js";
import NestedGrid from "./components/grid/NestedGrid.js";

let textColor = '#FFF';
let brandColor = '#5606FE';
let backgroundColor = '#171717';

const head = new Block();
head.syncToElement("head");

    const scrollbar = new Block();
    scrollbar.syncToNewElement("style");
    scrollbar.updateHTMLSourceCode(
        `
            ::-webkit-scrollbar {
                width: 5px;
            }

            ::-webkit-scrollbar-track {
                background: ${backgroundColor};
            }

            ::-webkit-scrollbar-thumb {
                background: ${brandColor};
            }
        `
    );
    head.attach(scrollbar);

const everything = new Block();
everything.syncToElement("*");
everything.updateStyle({margin: "0"});
everything.updateStyle({padding: "0"});
everything.updateStyle({boxSizing: "border-box"});

const body = new Block();
body.syncToElement("body");
body.updateStyle({background: backgroundColor});
body.updateStyle({color: textColor});

    const header = new Block();
    header.syncToNewElement("header");
    header.fillWindow();
    header.updateStyle({overflow: "hidden"});
    header.updateStyle({pointerEvents: "none"});
    header.updateStyle({position: "fixed"});
    header.updateStyle({zIndex: "100"});
    body.attach(header);

    const content = new Block();
    content.syncToNewElement("content");
    content.updateStyle({width: "100%"});
    content.updateStyle({height: "500vh"});
    content.updateStyle({overflow: "hidden"});
    content.updateStyle({position: "absolute"});
    content.updateStyle({display: "flex"});
    content.updateStyle({flexDirection: "column"});
    content.updateStyle({alignItems: "center"});
    body.attach(content);

        const hero = new Block();
        hero.syncToNewElement("div");
        hero.updateStyle({paddingTop: "20vh"});
        hero.updateStyle({width: "90%"});
        hero.updateStyle({height: "80vh"});
        hero.updateStyle({display: "flex"});
        hero.updateStyle({flexDirection: "row"});
        content.attach(hero);

            const heroHeadlineCard = new Block();
            heroHeadlineCard.syncToNewElement("div");
            heroHeadlineCard.fill();
            heroHeadlineCard.updateStyle({display: "flex"});
            heroHeadlineCard.updateStyle({flexDirection: "column"});
            heroHeadlineCard.updateStyle({alignItems: "center"});
            heroHeadlineCard.updateStyle({justifyContent: "center"});
            hero.attach(heroHeadlineCard);

                const heroHeadlineCardHeadlineContainer = new Block();
                heroHeadlineCardHeadlineContainer.syncToNewElement("div");
                heroHeadlineCardHeadlineContainer.updateStyle({width: "100%"});
                heroHeadlineCardHeadlineContainer.updateStyle({height: "auto"});
                heroHeadlineCardHeadlineContainer.updateStyle({display: "flex"});
                heroHeadlineCardHeadlineContainer.updateStyle({alignItems: "center"});
                heroHeadlineCardHeadlineContainer.updateStyle({justifyContent: "start"});
                heroHeadlineCardHeadlineContainer.updateStyle({fontSize: "3rem"});
                heroHeadlineCardHeadlineContainer.updateTextContent("Infinitely Scalable Smart Contracts");
                heroHeadlineCard.attach(heroHeadlineCardHeadlineContainer);

                const heroHeadlineCardSubContainer = new Block();
                heroHeadlineCardSubContainer.syncToNewElement("div");
                heroHeadlineCardSubContainer.updateStyle({width: "100%"});
                heroHeadlineCardSubContainer.updateStyle({height: "auto"});
                heroHeadlineCardSubContainer.updateStyle({display: "flex"});
                heroHeadlineCardSubContainer.updateStyle({alignItems: "center"});
                heroHeadlineCardSubContainer.updateStyle({justifyContent: "start"});
                heroHeadlineCardSubContainer.updateStyle({fontSize: "1rem"});
                heroHeadlineCardSubContainer.updateTextContent("Create infinitely scalable granular smart contracts in more than 9+ Blockchains");
                heroHeadlineCard.attach(heroHeadlineCardSubContainer);

                const heroHeadlineCardButtonContainer = new Block();
                heroHeadlineCardButtonContainer.syncToNewElement("div");
                heroHeadlineCardButtonContainer.updateStyle({width: "100%"});
                heroHeadlineCardButtonContainer.updateStyle({height: "20%"});
                heroHeadlineCard.attach(heroHeadlineCardButtonContainer);

            const heroImageContainer = new Block();
            heroImageContainer.syncToNewElement("img");
            heroImageContainer.fill();
            hero.attach(heroImageContainer);
        
        /// Background information about the project or team.
        /// Mission and vision statements.
        const about = new Block();
        about.syncToNewElement("div");
        about.updateStyle({width: "90%"});
        about.updateStyle({height: "80vh"});
        about.updateStyle({display: "flex"});
        about.updateStyle({flexDirection: "row"});
        content.attach(about);

        /// Governance and Community.

        /// Chrysalis.

        /// Roadmap.