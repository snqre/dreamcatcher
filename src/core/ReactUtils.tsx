/** @module */

import type { RouteObject } from "react-router-dom";
import type { Root } from "react-dom/client";
import { RouterProvider } from "react-router-dom";
import { createRoot } from "react-dom/client";
import { createBrowserRouter } from "react-router-dom";
import { Ok } from "ts-results";
import { Err } from "ts-results";

/** @public */
function render(routes: RouteObject[]):
    | Ok<null>
    | Err<"unableToLocateRootElement"> {
    let rootElement: HTMLElement | null = document.getElementById("root");
    if (!rootElement) {
        return Err<"unableToLocateRootElement">("unableToLocateRootElement");
    }
    let root: Root = createRoot(rootElement);
    root.render(<RouterProvider router={createBrowserRouter(routes)}/>);
    return Ok<null>(null);
}

export type { RouteObject };
export { render };