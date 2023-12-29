import row from "../layouts/row.js";
import any from "../layouts/any.js";
import { color } from "../color.js";
import column from "../layouts/column.js";
import image from "../layouts/image.js";

export default function navbar() {
    const section = new column(
        "100%",
        "auto",
        {}, [
            row(
                "100%",
                "auto", {
                    background: color.black.TECH_BLACK
                }, [
                    any(
                        "TOKENIZED VAULTS ✦ TOKENIZED VAULTS ✦ TOKENIZED VAULTS ✦ TOKENIZED VAULTS ✦ TOKENIZED VAULTS ✦ TOKENIZED VAULTS ✦ TOKENIZED VAULTS ✦ TOKENIZED VAULTS", {
                            whiteSpace: "nowrap"
                        }
                    )
                ]
            ),
            row(
                "100%",
                "auto", {
                    gap: "2%",
                    background: color.brand.NEON_PURPLE
                }, [
                    row(
                        "auto",
                        "auto", {
                            gap: "5%"
                        }, [
                            image(
                                "24px",
                                "24px",
                                "/static/svg/brand/whiteLogo.svg"
                            ),
                            any(
                                "Dreamcatcher"
                            )
                        ]
                    ),
                    row(
                        "auto",
                        "auto", {
                            gap: "1%"
                        }, [
                            any(
                                "Home",
                                {}, [
                                    "button",
                                    "menu-button-home"
                                ]
                            ),
                            any(
                                "Whitepaper",
                                {}, [
                                    "button",
                                    "menu-button-whitepaper"
                                ]
                            )
                        ]
                    )
                ]
            )
        ]
    );
    return section;
}