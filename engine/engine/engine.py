import reflex as _

class State(_.State):
    pass

def navbar():
    return _.box(
        _.hstack(
            _.spacer(),
            _.hstack(
                _.image(src="/favicon.ico"),
                _.heading("Dreamcatcher"),
            ),
            _.spacer(),
            _.menu(
                _.menu_button("Home"),
                _.menu_button("Metrics"),
                _.menu_button("Team"),
                _.menu_button("Whitepaper"),
            ),
            _.spacer(),
            spacing="50px",
        ),
        position="fixed",
        width="100%",
        top="10px",
        z_index="5",
    )

def landing() -> _.Component:
    return _.box(
        navbar(),
        _.container(
            width="100%",
            heigth="25%",
            background_image=("url('engine/assets/image.png')"),
            background_size="cover",
        )
    )

engine = _.App()
engine.add_page(landing)
engine.compile()