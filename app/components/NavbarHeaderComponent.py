from flet import *
from .settings.Settings import *

class NavbarHeaderComponent(UserControl):
    def __init__(self):
        super().__init__()
    
    def build(self):
        navOptions = []
        for option in NAVBAR_HEADER_COMPONENT.NAV_OPTIONS:
            navOptions.append(Text(option, FONT_SIZE.SMALL))
        return Container(
            height=NAVBAR_HEADER_COMPONENT.HEADER_HEIGHT,
            bgcolor=NAVBAR_HEADER_COMPONENT.HEADER_BACKGROUND_COLOR,
            padding=padding.only(
                left=NAVBAR_HEADER_COMPONENT.HEADER_LEFT_PADDING,
                right=NAVBAR_HEADER_COMPONENT.HEADER_RIGHT_PADDING
            ),
            animate=Animation(
                NAVBAR_HEADER_COMPONENT.HEADER_ANIMATION_DURATION,
                NAVBAR_HEADER_COMPONENT.HEADER_ANIMATION_CURVE
            ),
            content=Column(
                alignment=NAVBAR_HEADER_COMPONENT.HEADER_ALLIGNMENT,
                spacing=NAVBAR_HEADER_COMPONENT.FRAME_SPACING,
                controls=[
                    Row(
                        controls=[
                            Text(
                                NAVBAR_HEADER_COMPONENT.HEADER_TEXT,
                                size=FONT_SIZE.REGULAR,
                                weight=
                            )
                        ]
                    ),
                    Container(
                        opacity=NAVBAR_HEADER_COMPONENT.NAV_OPACITY,
                        animate_offset=Animation(
                            NAVBAR_HEADER_COMPONENT.NAV_OFFSET_ANIMATION_DURATION,
                            NAVBAR_HEADER_COMPONENT.NAV_OFFSET_ANIMATION_CURVE
                        ),
                        content=Row(controls=navOptions)
                    )
                ]
            )
        )
    
    
    
        
    

class NavbarHeaderComponent(UserControl):
    def __init__(self, navFontSize=8, headerHeight=64, headerBackgroundColor="#696969", leftHeaderPadding=64, rightHeaderPadding=64):
        options = []
        options.append(Text("Home", size=navFontSize))
        options.append(Text("Analytics", size=navFontSize))
        options.append(Text("Team", size=navFontSize))
        options.append(Text("Whitepaper", size=navFontSize))
        options.append(Text("Roadmap", size=navFontSize))
        frame = Column(alignment="center", spacing=16, controls=[Row(controls=[Text("Dreamcatcher", size=32, weight="bold")]), self.nav])
        self.nav = Container(opacity=1, animate_offset=Animation(500, "ease"), content=Row(controls=options))
        self.header = Container(height=headerHeight, bgcolor=headerBackgroundColor, padding=padding.only())

        self.header = Container(
            height=headerHeight,
            bgcolor=headerBackgroundColor,
            padding=padding.only(
                left=leftHeaderPadding,
                right=rightHeaderPadding
            ),
            animate=Animation(
                500,
                "ease"
            ),
            content=Column(
                alignment="center",
                spacing=15,
                controls=[
                    Row(
                        controls=[
                            Text(
                                "Dreamcatcher",
                                size=32,
                                weight="bold"
                            )
                        ]
                    ),
                    self.nav
                ]
            )
        )
        super().__init__()

    def build(self):
        return self.header