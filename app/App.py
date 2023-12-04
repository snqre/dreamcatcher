from flet import *
from components.fonts.Fonts import *

def main(page):
    page.fonts = FONTS
    page.title = "Dreamcatcher"
    page.theme = Theme(font_family="JetBrainsMonoNerdFont-Regular")
    page.padding = 0
    page.add(Text("HelloWorld"))

app(target=main, view=AppView.WEB_BROWSER)