import type {Maybe} from "@seal";
import type {ReactNode} from "react";
import {Result} from "@seal";
import {Ok} from "@seal";
import {Err} from "@seal";
import {createRoot as Root} from "react-dom/client";

export type RenderR = Result<RenderT, RenderE>;
export type RenderT = void;
export type RenderE =
    | "ERR_RENDER_TARGET_REQUIRED";
export function render(app: ReactNode): RenderR {
    let element: Maybe<HTMLElement> = document.getElementById("root");
    if (!element) return Err("ERR_RENDER_TARGET_REQUIRED");
    Root(element!).render(app);
    return Ok(undefined);
}