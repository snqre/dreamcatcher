import Velvet from "./velvet-framework.js";

let velvet = Velvet();
velvet.initialize();
velvet.addRoute(() => {
    velvet.content.inject([
        velvet.Template().column("100%", "100%", {}, [
            velvet.Template().row("100%", "20%", {}, []),
            velvet.Template().row("100%", "20%", {}, [])
        ])
    ]);
});