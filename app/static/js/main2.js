class Component {
    constructor() {
        this.element;
    }

    syncToElement(element) {
        this.element = document.querySelector(element);
        return;
    }

    syncToNewElement(element) {
        this.element = document.createElement(element);
        return;
    }

    updateStyle(stylesheet) {
        Object.assign(this.element.style, stylesheet);
        return;
    }

    syncToClassName(className) {
        this.element.classList.add(className);
        return;
    }

    releaseFromClassName(className) {
        this.element.classList.remove(className);
        return;
    }

    updateText(text) {
        this.element.textContent = text;
        return;
    }

    injectText(text) {
        this.element.textContent += text;
        return;
    }

    updateInnerHTML(sourceCode) {
        this.element.innerHTML = sourceCode;
        return;
    }

    injectInnerHTML(sourceCode) {
        this.element.innerHTML += sourceCode;
        return;
    }

    attach(component) {
        this.element.appendChild(component.element);
        return;
    }

    deleteInnerHTML() {
        this.element.innerHTML = "";
        return;
    }
}

class Row extends Component {
    constructor(width, height) {
        super();
        this.syncToNewElement("div");
        this.updateStyle({
            width: width,
            height: height,
            display: "flex",
            flexDirection: "row",
            alignItems: "center",
            justifyContent: "center",
            margin: "0",
            padding: "0"
        });
    }
}

class Column extends Component {
    constructor(width, height) {
        super();
        this.syncToNewElement("div");
        this.updateStyle({
            width: width,
            height: height,
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            justifyContent: "center",
            margin: "0",
            padding: "0"
        });
    }
}

class Text extends Component {
    constructor(text) {
        super();
        this.syncToNewElement("div");
        this.updateText(text);
    }
}

class Button extends Component {
    constructor(width, height, text) {
        super();
        this.syncToNewElement("div");
        this.updateStyle({
            width: width,
            height: height,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            flexDirection: "row",
            fontSize: "1.25rem"
        });
        this.updateText(text);
    }
}


let color = {
    brand: "#5606FE",
    text: "#000",
    background: "#FFF",
    backgroundContrast: "#171717",
    textContrast: "#FFF",
    backgroundContainer: "#F5F5F5",
    button: {
        initialColor: "#121212",
        peakFlashColor: "#FFF"
    }
}
const head = new Component();
head.syncToElement("head");
    const style = new Component();
    style.syncToNewElement("style");
    style.updateInnerHTML(
        `
            ::-webkit-scrollbar {
                width: 5px;
            }

            ::-webkit-scrollbar-track {
                background: ${color.background};
            }

            ::-webkit-scrollbar-thumb {
                background: ${color.brand};
            }

            .button-animation {
                width: 200px;
                height: auto;
                color: #FFF;
                background: ${color.button.initialColor};
                display: flex;
                justify-content: center;
                align-items: center;
                animation: pulseAnimation 1s infinite alternate;
            }

            .button-animation:hover {
                background: ${color.brand};
                color: #FFF;
                animation: none;
                cursor: pointer;
            }

            @keyframes pulseAnimation {
                from {
                    opacity: 1.00;
                } to {
                    opacity: 0.50;
                }
            }

            .typewritter {
                display: inline-block;
                width: 100%;
                white-space: nowrap;
                overflow: hidden;
                animation:
                    typing 2s steps(18);
                    cursor .4s step-end infinite alternative;
            }

            @keyframes cursor {
                50% {
                    border-color: transparent;
                }
            }

            .compatible-blockchain-logo {
                width: "32px";
                height: "32px;
                background-size: contain;
                background-position: center;
            }
        `
    );
    head.attach(style);
const everything = new Component();
everything.syncToElement("*");
everything.updateStyle({
    margin: "0",
    padding: "0",
    boxSizing: "border-box"
});
const body = new Component();
body.syncToElement("body");
body.updateStyle({
    background: color.background,
    color: color.text,
    fontFamily: "DejaVu Sans Mono, monospace"
});

function refresh(route) {
    const body = new Component();
    body.syncToElement("body");
    body.deleteInnerHTML();

    function attachOptional(parentNode, nodeList=[]) {
        if (nodeList.length !== 0) {
            for (let i = 0; i < nodeList.length; i++) {
                parentNode.attach(nodeList[i]);
            }
        }
        return;
    }

    switch (route) {
        case 0:
            function title(nodeList=[], slice=0, string="") {
                const main = new Row("100%", `${slice}%`);
                main.updateStyle({
                    background: color.backgroundContrast,
                    color: color.textContrast,
                    fontSize: "2rem",
                    fontWeight: "bold"
                });
                main.updateText(string);
                attachOptional(main, nodeList);
                return title;
            }

            class Layout {
                gutter(slice=0) {
                    const main = new Row("100%", `${slice}%`);
                    return main;
                }

                leftContentRightImage(nodeList=[], slice=0, imageUrl) {
                    const main =  new Row("100%", `${slice}%`);

                    function leftContentContainer() {
                        const leftContentContainer = new Column("50%", "100%");
                        leftContentContainer.updateStyle({
                            padding: "2%"
                        });

                        function container() {
                            const container = new Column("100%", "100%");
                            attachOptional(container, nodeList);
                            return container;
                        }

                        leftContentContainer.attach(container());
                        return leftContentContainer;
                    }

                    function rightContentContainer() {
                        const rightContentContainer = new Column("50%", "100%");

                        function container() {
                            const container = new Column("100%", "100%");
                            container.updateStyle({
                                backgroundImage: `url(${imageUrl})`,
                                backgroundRepeat: "no-repeat",
                                backgroundSize: "contain",
                                backgroundPosition: "center"
                            });
                            return container;
                        }

                        rightContentContainer.attach(container());
                        return rightContentContainer;
                    }
                    
                    main.attach(leftContentContainer());
                    main.attach(rightContentContainer());
                    return main;
                }
            }

            const layout = new Layout();

            function headlineSection() {
                const section = new Column("100%", "100vh");
                section.attach(
                    layout.gutter(20)
                );
                section.attach(
                    layout.leftContentRightImage(
                        [],
                        60,
                        "/static/png/undraw/undraw_relaunch_day_902d.png"
                    )
                );
                section.attach(
                    layout.gutter(20)
                );
                return section;
            }

            function foundersSection() {
                const section = new Column("100%", "100vh");
                section.attach(title(5));
                return section;
            }

            const numPages = 5;

            const header = new Component();
            header.syncToNewElement("header");
            header.updateStyle({
                width: "100vw",
                height: "100vh",
                overflow: "hidden",
                pointerEvents: "none",
                position: "fixed",
                zIndex: "100"
            });
            body.attach(header);
                let lineStyle = {
                    width: "100%",
                    height: "0.25rem",
                    border: "2px solid #000"
                }
                const overline = new Component();
                overline.syncToNewElement("div");
                overline.updateStyle(lineStyle);
                header.attach(overline);
                const navbar = new Row("100%", "auto");
                navbar.updateStyle({
                    justifyContent: "start",
                    borderBottom: "1px solid #000",
                    padding: "5px",
                    background: color.background
                });
                header.attach(navbar);
                    const navbar__logo = new Component();
                    navbar__logo.syncToNewElement("img");
                    navbar__logo.updateStyle({
                        width: "64px",
                        height: "64px",
                        backgroundImage: "url(/static/png/brand/dreamcatcher_logo.png)",
                        backgroundSize: "contain",
                        backgroundPosition: "center"
                    });
                    navbar.attach(navbar__logo);
                    const navbar__name = new Text("Dreamcatcher");
                    navbar__name.updateStyle({
                        fontSize: "2rem"
                    });
                    navbar.attach(navbar__name);
                    const navbar__menu = new Row("auto", "auto");
                    navbar.attach(navbar__menu);
                        const navbar__menu__option1 = new Button("100px", "auto", "Home");
                        navbar__menu.attach(navbar__menu__option1);
                const underline = new Component();
                underline.syncToNewElement("div");
                underline.updateStyle(lineStyle);
                header.attach(underline);
            const content = new Component();
            content.syncToNewElement("content");
            content.updateStyle({
                width: "100%",
                height: `${numPages * 100}vh`,
                overflow: "hidden",
                position: "absolute",
                display: "flex",
                flexDirection: "column",
                alignItems: "center"
            });
            body.attach(content);
                let section = {
                    padding: "5%"
                }
                content.attach(headlineSection());
                const section2 = new Row("100%", "100vh");
                section2.updateStyle({
                    paddingLeft: section.padding,
                    paddingRight: section.padding
                });
                content.attach(section2);
                    const section2__row1 = new Column("100%", "100%");
                    section2__row1.updateStyle({
                        gap: "1rem"
                    });
                    section2.attach(section2__row1);

                        function card(icon, caption, feature) {
                            const newCard = new Row("100%", "100%");
                            newCard.updateStyle({
                                alignItems: "start"
                            });
                                const  iconContainer = new Column("25%", "100%");
                                iconContainer.updateStyle({
                                    backgroundImage: `url(${icon})`,
                                    backgroundSize: "contain",
                                    backgroundPosition: "center",
                                    backgroundRepeat: "no-repeat"
                                });
                                newCard.attach(iconContainer);
                                const contentContainer = new Column("75%", "100%");
                                contentContainer.updateStyle({
                                    
                                });
                                newCard.attach(contentContainer);
                                    const headline = new Row("100%", "auto");
                                    headline.updateStyle({
                                        background: "#121212",
                                        color: "#FFF",
                                        fontSize: "1rem",
                                        fontWeight: "bold"
                                    });
                                    headline.updateText(caption);
                                    contentContainer.attach(headline);
                                    const subHeadline = new Row("100%", "100%");
                                    subHeadline.updateStyle({
                                        background: "#F5F5F5",
                                        fontSize: "1rem",
                                        justifyContent: "start",
                                        alignItems: "start",
                                        padding: "2%"
                                    });
                                    subHeadline.updateText(feature);
                                    contentContainer.attach(subHeadline);
                            return newCard;
                        }

                        section2__row1.attach(card("/static/png/undraw/undraw_Dream_world_re_x2yl.png", "Trusless Asset Management", "Set up your vault in seconds, interact with millions around the world"));
                        section2__row1.attach(card("/static/png/undraw/undraw_Creation_process_re_kqa9.png", "Worry Less", "Intuitive interfaces allow you to create"));
                        section2__row1.attach(card("/static/png/undraw/undraw_Creation_process_re_kqa9.png", "Do Something", "HHHHHH"));
                        section2__row1.attach(card("/static/png/undraw/undraw_Dream_world_re_x2yl.png", "jsjdjd", "dkdkkd"));
                        section2__row1.attach(card("/static/png/undraw/undraw_Dream_world_re_x2yl.png", "jsjdjd", "dkdkkd"));
                        section2__row1.attach(card("/static/png/undraw/undraw_Dream_world_re_x2yl.png", "jsjdjd", "dkdkkd"));
                        const section2__row1__card1 = new Row("100%", "100%");
                        section2__row1.attach(section2__row1__card1);
                        const section2__row1__card2 = new Row("100%", "100%");
                        section2__row1.attach(section2__row1__card2);
                        const section2__row1__card3 = new Row("100%", "100%");
                        section2__row1.attach(section2__row1__card3);
                        const section2__row1__gutterBottom = new Row("100%", "100%");
                        section2__row1.attach(section2__row1__gutterBottom);
                    const section2__row2 = new Column("100%", "100%");
                    section2__row2.updateStyle({
                        backgroundImage: "url(/static/png/undraw/undraw_Surveillance_re_8tkl.png)",
                        backgroundSize: "contain",
                        backgroundPosition: "center",
                        backgroundRepeat: "no-repeat"
                    });
                    section2.attach(section2__row2);
                const section3 = new Column("100%", "100vh");
                section3.updateStyle({
                    paddingLeft: section.padding,
                    paddingRight: section.padding
                });
                content.attach(section3);
                    const section3__title = new Row("100%", "auto");
                    section3__title.updateStyle({
                        background: color.backgroundContrast,
                        color: color.textContract
                    });
                    section3__title.updateText("Mission");
                    section3.attach(section3__title);
                const section4 = new Column("100%", "100vh");
                section4.updateStyle({
                    paddingLeft: section.padding,
                    paddingRight: section.padding
                });
                content.attach(section4);
                const section5 = new Column("100%", "100vh");
                section5.updateStyle({
                    paddingLeft: section.padding,
                    paddingRight: section.padding
                });
                content.attach(section5);
            break
    }
}

refresh(0);


body.element.addEventListener("mouseover", (event) => {
    //refresh(0);
    console.log(event.target);

})