import flet

def main(page: flet.Page,) -> None:
    page.title = "Dreamcatcher"
    page.theme_mode = flet.ThemeMode.DARK
    page.padding = 50
    page.update()

    # why image no display :(
    image = flet.Image(
        src="components/png/heroSectionImage.png",
        width=50,
        height=50,
        fit=flet.ImageFit.CONTAIN,
        repeat=flet.ImageRepeat.REPEAT
    )

    page.add(
        flet.Row(
            [
                image,
                flet.Text("HelloWorld")
            ],
        ),
    )

flet.app(target=main, view=flet.AppView.WEB_BROWSER)