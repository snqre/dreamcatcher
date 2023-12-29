import column from "../layouts/column.js";
import row from "../layouts/row.js";
import any from "../layouts/any.js";
import { color } from "../color.js";
import image from "../layouts/image.js";

export default function hero() {
    const socialsIconSize = "16px";
    const section = column("100%", "100vh", {background: "#F2F2F2", padding: "10%"}, [
        row("100%", "100%", {flex: "1"}, []),
        row("100%", "100%", {flex: "4", padding: "1%"}, [
            column("100%", "100%", {flex: "10", padding: "1%"}, [
                any("Scaling Dreams, Crafting Possibilities", {fontSize: "3rem", color: "#121212"}),
                any("Infinitely Scalable Tokenized Vaults.", {fontSize: "1rem", color: "#121212"}),
                any("Learn More", {border: "2px solid #121212", color: "#121212", padding: "0.75%", margin: "1%", borderRadius: "10px", boxShadow: "0 0 4px #000"}, ["button", "learn-more-button"]),
            ]),
            row("100%", "100%", {flex: "2", padding: "1%"}, []),
        ]),
        row("100%", "100%", {flex: "2"}, [
            image("400px", "auto", "/static/svg/undraw/stars.svg"),
        ]),
        row("100%", "100%", {flex: "4", padding: "1%"}, [
            row("100%", "100%", {flex: "2", padding: "1%"}, []),
            column("100%", "100%", {flex: "10", padding: "1%"}, [
                any("Join The Community!"),
                row("100%", "100%", {width: "auto", height: "auto", gap: "5%"}, [
                    image(socialsIconSize, socialsIconSize, "/static/svg/socials/twitter.svg", {}, ['clickable-icon']),
                    image(socialsIconSize, socialsIconSize, "/static/svg/socials/telegram.svg", {}, ["telegram-socials-icon"]),
                    image(socialsIconSize, socialsIconSize, "/static/svg/socials/discord.svg", {}, ["discord-socials-icon"]),
                    image(socialsIconSize, socialsIconSize, "/static/svg/socials/github.svg", {}, ["github-socials-icon"]),
                ]),
            ]),
        ]),
        row("100%", "100%", {flex: "1"}, []),
    ]);
    return section;
}