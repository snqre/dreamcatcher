import { color } from "../color.js";
import any from "../layouts/any.js";
import column from "../layouts/column.js";
import row from "../layouts/row.js";
import Component from "../Component.js";
import image from "../layouts/image.js";

export default function feature() {
    const section = column(
        "100%",
        "100vh", {
            overflow: "hidden"
        }, [
            column(
                "100%",
                "100%", {
                    background: color.black.REFLECTING_POND
                }, [
                    any(
                        "What Will I Be Able To Do?"
                    ),
                    row(
                        "100%",
                        "auto",
                        {}, [
                            column(
                                "100%",
                                "100%", {
                                    flex: "8",
                                    alignItems: "start",
                                    padding: "5%"
                                }, [
                                    any(
                                        "✦ Explore over 40,000+ pairs and seamlessly swap on Uniswap and Quickswap.", {
                                            paddingBottom: "3%"
                                        }
                                    ),
                                    any(
                                        "✦ Personalize your vault with a selection of 25+ modules tailored to your preferences.", {
                                            paddingBottom: "3%"
                                        }
                                    ),
                                    any(
                                        "✦ Construct and earn $DREAM by creating modules, all while safeguarding against storage pointer collisions in your unique storage slots.", {
                                            paddingBottom: "3%"
                                        }
                                    ),
                                    any(
                                        "✦ Ensure a secure upgrade process for your vault with implemented safeguards, providing contributors with a reliable experience.", {
                                            paddingBottom: "3%"
                                        }
                                    ),
                                    any(
                                        "✦ Engage with the protocol to earn $DREAM and generate yield for your vault contributors.", {
                                            paddingBottom: "3%"
                                        }
                                    ),
                                    any(
                                        "✦ Beat the market and earn $DREAM through strategic participation.", {
                                            paddingBottom: "3%"
                                        }
                                    ),
                                    any(
                                        "✦ Showcase your uniqueness by customizing your vault profile.", {
                                            paddingBottom: "3%"
                                        }
                                    ),
                                    any(
                                        "✦ Establish your DAO, investment club, or community effortlessly.", {
                                            paddingBottom: "3%"
                                        }
                                    ),
                                    any(
                                        "✦ Tokenize any asset and break up NFTs into tokens using our advanced vault technology.", {
                                            paddingBottom: "3%"
                                        }
                                    )
                                ]
                            ),
                            column(
                                "100%",
                                "100%", {
                                    flex: "4",
                                    padding: "5%"
                                }, [
                                    image(
                                        "100%",
                                        "100%",
                                        "/static/svg/undraw/discoverable.svg"
                                    )
                                ]
                            )
                        ]
                    )
                ]
            )
        ]
    )
    return section;
}