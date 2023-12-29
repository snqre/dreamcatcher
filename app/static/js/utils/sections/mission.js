import column from "../layouts/column.js";
import row from "../layouts/row.js";
import { color } from "../color.js";
import any from "../layouts/any.js";
import image from "../layouts/image.js";

export default function mission() {
    const section = column(
        "100%",
        "100vh", {
            overflow: "hidden"
        }, [
            "container-fluid",
            column(
                "100%",
                "100%", {
                    background: color.black.DEEP_FIR
                }, [
                    column(
                        "100%",
                        "auto", {
                        }, [
                            "container-sm",
                            any(
                                `
                                Welcome to Our Vision: A DAO-First Approach
                                `, {
                                }, [
                                    "h1"
                                ]
                            ),
                            any(
                                `
                                At Dreamcatcher, we are pioneering a DAO-first appraoch to tackle the scaling
                                challenges faced by decentralized autonomous organizations. Unlike traditional DAOs,
                                we recognize the critical issues of core management structures and incentive mechanisms.
                                `, {
                                    fontSize: "0.80rem",
                                    paddingBottom: "5%"
                                }
                            ),
                            any(
                                `
                                Multi-Protocol DAO Ecosystem
                                `, {
                                    fontSize: "1.5rem"
                                }
                            ),
                            any(
                                `
                                Our ambition is to be a trailblazer as one of the first multi-protocol DAOs in the space.
                                This means cultivating a thriving ecosystem that spans multiple blockchains and
                                activities. Managing sub-protocols, interacting seamlessly with other entities,
                                handling financial transactions, and even addressing regulatory requirements -- all
                                automated, without third-party risks.
                                `, {
                                    fontSize: "0.80rem",
                                    paddingBottom: "5%"
                                }
                            ),
                            any(
                                `
                                Global Collaboration and Talent Access
                                `, {
                                    fontSize: "1.5rem"
                                }
                            ),
                            any(
                                `
                                We believe in the power of DAOs to outpace multinational organizations. How? By
                                providing easier access to talent, enabling faster financial transactions, ensuring
                                global and 24-hour liquidity, and maintaining drastically lower overhead costs
                                compared to traditional businesses.
                                `, {
                                    fontSize: "0.80rem",
                                    paddingBottom: "5%"
                                }
                            ),
                            any(
                                `
                                Revolutionizing with Infinitely Scalable Vaults
                                `, {
                                    fontSize: "1.5rem"
                                }
                            ),
                            any(
                                `
                                Central to our vision are the Vaults -- an innovative concept
                                designed as a Chrysalis, where you start with a blank canvas and transform it
                                into a colorful butterfly. These vaults serve as the heart of our ecosystem,
                                facilitating seamless conversion of potential into vibrant opportunities.
                                `, {
                                    fontSize: "0.80rem",
                                    paddingBottom: "5%"
                                }
                            ),
                            any(
                                `
                                Empowering Transformation and Identity
                                `, {
                                    fontSize: "1.5rem"
                                }
                            ),
                            any(
                                `
                                Inside our Vaults, creativity takes flight. Whether you're an entrepreneur, 
                                developer, or artist, our vaults offer a space for innovation to blossom.
                                Through a combination of AI-driven support, algorithmic governance, and 
                                community collaboration, we ensure that your ideas not only survive but thrive.
                                Build what you want, just the way you want it.
                                `, {
                                    fontSize: "0.80rem"
                                }
                            )
                        ]
                    )
                ]
            )
        ]
    );
    return section;
}