import {Requirement} from "@requirement";

interface Hex {
    toString(): string;
    toRgba(): Rgba;
    toRgb(): Rgb;
}

class Hex implements Hex {
    private static readonly _VALID_CHARS: string[] = [
        "0", "1", "2", "3", "4", 
        "5", "6", "7", "8", "9", 
        "a", "b", "c", "d", "e", 
        "f", "A", "B", "C", "D", 
        "E", "F",
    ];

    private static _checkCharSet(string: string): void {
        for (let i = 1; i < string.length; i += 1) {
            let char: string = string[i];
            let hasValidChar: boolean = false;
            for (let x = 0; x < Hex._VALID_CHARS.length; x ++) {
                let validChar: string = Hex._VALID_CHARS[x];
                if (char === validChar) {
                    hasValidChar = true;
                }
            }
            new Requirement(hasValidChar, "Hex::CheckCharSet::InvalidCharSet");
        }
    }

    public constructor(private readonly _STRING: string) {
        new Requirement(this._STRING.length === 7, "Hex::InvalidStringLength");
        new Requirement(this._STRING.startsWith("#"), "Hex::MissingHashSymbol");
        Hex._checkCharSet(this._STRING);
    }

    public toString(): string {
        return this._STRING;
    }

    public toRgba(): Rgba {
        let rgb: Rgb = this.toRgb();
        return new Rgba(rgb.r(), rgb.g(), rgb.b(), 1n);
    }

    public toRgb(): Rgb {
        let value: string = this._STRING.slice(1);
        let r: bigint = BigInt(parseInt(value.slice(0, 2), 16));
        let g: bigint = BigInt(parseInt(value.slice(2, 4), 16));
        let b: bigint = BigInt(parseInt(value.slice(4, 6), 16));
        return new Rgb(r, g, b);
    }
}

interface Rgb {
    r(): bigint;
    g(): bigint;
    b(): bigint;
    toString(): string;
    toRgba(): Rgba;
    toHex(): Hex;
}

class Rgb implements Rgb {
    public constructor(
        private readonly _R: bigint,
        private readonly _G: bigint,
        private readonly _B: bigint,
    ) {
        new Requirement(this._R > 0n && this._R <= 255n, "Rgb::ValueRIsOutOfBounds");
        new Requirement(this._G > 0n && this._G <= 255n, "Rgb::ValueGIsOutOfBounds");
        new Requirement(this._B > 0n && this._B <= 255n, "Rgb::ValueBIsOutOfBounds");
    }

    public r(): bigint {
        return this._R;
    }

    public g(): bigint {
        return this._G;
    }

    public b(): bigint {
        return this._B;
    }

    public toString(): string {
        return `rgb(${this.r(), this.g(), this.b()})`;
    }

    public toRgba(): Rgba {
        return new Rgba(this.r(), this.g(), this.b(), 1n);
    }

    public toHex(): Hex {
        let hex0 = this.r().toString(16);
        let hex1 = this.g().toString(16);
        let hex2 = this.b().toString(16);
        hex0 = hex0.length === 1 ? "0" + hex0 : hex0;
        hex1 = hex1.length === 1 ? "0" + hex1 : hex1;
        hex2 = hex2.length === 1 ? "0" + hex2 : hex2;
        return new Hex(`#${hex0}${hex1}${hex2}`);
    }
}

interface Rgba extends Rgb {
    a(): bigint;
    toRgb(): Rgb;
};

class Rgba extends Rgb {
    public constructor(r: bigint, g: bigint, b: bigint, private readonly _A: bigint) {
        super(r, g, b);
        new Requirement(this._A >= 0 && this._A <= 1, "Rgba::ValueAIsOutOfBounds");
    }

    public override toString(): string {
        return `rgba(${this.r(), this.g(), this.b(), this.a()})`;
    }

    public toRgb(): Rgb {
        return new Rgb(this.r(), this.g(), this.b());
    }

    public a(): bigint {
        return this._A;
    }
}

type Colorlike = 
    | Hex
    | Rgb
    | Rgba;

interface Color {
    toHex(): Hex;
    toRgb(): Rgb;
    toRgba(): Rgba;
}

class Color implements Color {
    public static Hex = Hex;
    public static Rgb = Rgb;
    public static Rgba = Rgba;

    public static isHex(colorlike: Colorlike): colorlike is Hex {
        return !Color.isRgb(colorlike) && !Color.isRgba(colorlike);
    }

    public static isRgb(colorlike: Colorlike): colorlike is Rgb {
        return (
            "r" in colorlike 
            && "g" in colorlike 
            && "b" in colorlike 
        );
    }

    public static isRgba(colorlike: Colorlike): colorlike is Rgba {
        return (
            "r" in colorlike 
            && "g" in colorlike 
            && "b" in colorlike 
            && "a" in colorlike
        );
    }

    private readonly _COLORLIKE: Colorlike;

    public constructor(colorlike: Colorlike) {
        this._COLORLIKE =
            Color.isHex(colorlike) 
                ? new Hex(colorlike.toString()) 
                : Color.isRgba(colorlike) 
                    ? new Rgba(
                        colorlike.r(), 
                        colorlike.g(), 
                        colorlike.b(), 
                        colorlike.a()) 
                    : new Rgb(
                        colorlike.r(), 
                        colorlike.g(), 
                        colorlike.b());
    }

    public toHex(): Hex {
        return (
            Color.isRgb(this._COLORLIKE) || Color.isRgba(this._COLORLIKE) 
                ? this._COLORLIKE.toHex() 
                : this._COLORLIKE
        );
    }

    public toRgb(): Rgb {
        return (
            Color.isHex(this._COLORLIKE)
                ? this._COLORLIKE.toRgb()
                : this._COLORLIKE
        );
    }

    public toRgba(): Rgba {
        return (
            Color.isHex(this._COLORLIKE) || Color.isRgb(this._COLORLIKE)
                ? this._COLORLIKE.toRgba()
                : this._COLORLIKE
        );
    }
}

interface Gradient {
    readonly COLORS: Color[],
}

class Gradient implements Gradient {
    public constructor(public readonly COLORS: Color[]) {}
}

class ColorPalette {
    private constructor() {}
    public static readonly OBSIDIAN: Color = new Color(new Color.Hex("#171717"));
    public static readonly POLISHED_TITANIUM: Color = new Color(new Color.Hex("#D6D5D4"));
    public static readonly ROCK: Color = new Color(new Color.Hex("#5B5B5B"));
    public static readonly GRAPHITE: Color = new Color(new Color.Hex("#474647"));
    public static readonly GREEN_PLAINS_GRASS: Color = new Color(new Color.Hex("#AEFF00"));
    public static readonly RELAXED_TEAL: Color = new Color(new Color.Hex("#00FFAB"));
    public static readonly VIVID_RED: Color = new Color(new Color.Hex("#FF3200"));
    public static readonly VIVID_PINK: Color = new Color(new Color.Hex("#FF00DB"));
    public static readonly VIVID_BLUE: Color = new Color(new Color.Hex("#0652FE"));
    public static readonly DEEP_PURPLE: Color = new Color(new Color.Hex("#615FFF"));
    public static readonly DEEP_PURPLE_GRADIENT: Gradient = new Gradient([ColorPalette.DEEP_PURPLE, new Color(new Color.Hex("#9662FF"))]);
    public static readonly RED_TO_PINK_GRADIENT: Gradient = new Gradient([ColorPalette.VIVID_RED, ColorPalette.VIVID_PINK]);
}

export type {Colorlike};
export {Hex};
export {Rgb};
export {Rgba};
export {Color};
export {Gradient};
export {ColorPalette};