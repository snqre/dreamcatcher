from dataclasses import *

@dataclass
class NAVBAR_HEADER_COMPONENT():
    HEADER_HEIGHT                    :int    = 64
    HEADER_BACKGROUND_COLOR          :str    = "#696969"
    HEADER_LEFT_PADDING              :int    = 64
    HEADER_RIGHT_PADDING             :int    = 64
    HEADER_ANIMATION_DURATION        :int    = 500
    HEADER_ANIMATION_CURVE           :str    = "ease"
    HEADER_ALLIGNMENT                :str    = "center"
    HEADER_TEXT                      :str    = "Dreamcatcher"
    NAV_OPACITY                      :float  = 1
    NAV_OFFSET_ANIMATION_DURATION    :int    = 500
    NAV_OFFSET_ANIMATION_CURVE       :str    = "ease"
    NAV_OPTIONS                      :list   = [
        "Home",
        "Analytics",
        "Team",
        "Whitepaper",
        "Roadmap",
    ]
    FRAME_SPACING                    :int    = 15