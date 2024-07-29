import type {ReactNode} from "react";
import type {CSSProperties} from "react";
import type {ComponentPropsWithoutRef} from "react";
import type {SpringConfig} from "react-spring";
import type {RouteObject} from "react-router-dom";
import type {Root} from "react-dom/client";
import {EventEmitter} from "fbemitter";
import {EventSubscription} from "fbemitter";
import {Link} from "react-router-dom";
import {RouterProvider} from "react-router-dom";
import {createRoot} from "react-dom/client";
import {createBrowserRouter} from "react-router-dom";
import {config} from "react-spring";
import {animated} from "react-spring";
import {useEffect} from "react";
import {useSpring} from "react-spring";
import {useState} from "react";
import React from "react";

class Requirement extends Error {
    public static isRequirement(item: unknown): item is Requirement {
        return item instanceof Requirement;
    }

    public constructor(condition: boolean, reason?: string) {
        super(reason);
        if (!condition) {
            throw this;
        }
    }
}

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

type OnSetHook<T> = (newValue: T, oldValue: T) => unknown;

interface Value<T> {
    set(value: T): void;
    onSet(hook: OnSetHook<T>): EventSubscription;
}

class Value<T> {
    private readonly _em: EventEmitter = new EventEmitter();
    public constructor(private _stored: T) {}

    public get(): T {
        return this._stored;
    }

    public set(value: T): void {
        let newValue: T = value;
        let oldValue: T = this._stored;
        this._em.emit("set", newValue, oldValue);
        return;
    }

    public onSet(hook: OnSetHook<T>): EventSubscription {
        return this._em.addListener("set", hook);
    }
}

class MountRequest {
    public readonly alias: string;
    public readonly setMounted: React.Dispatch<React.SetStateAction<ReactNode[]>>;
    public readonly components: ReactNode[];
    public readonly cooldown: number;
    public readonly delay: number;
    public constructor({
        alias,
        setMounted,
        components,
        cooldown,
        delay,}:{
            alias: string,
            setMounted: React.Dispatch<React.SetStateAction<ReactNode[]>>,
            components: ReactNode[],
            cooldown: number,
            delay: number,
        }) {
            this.alias = alias;
            this.setMounted = setMounted;
            this.components = components;
            this.cooldown = cooldown;
            this.delay = delay;
        }
}

interface ControllerProps extends Omit<ComponentPropsWithoutRef<typeof animated.div>, "tag"> {
    alias?: string,
    spring?: CSSProperties,
    springConfig?: SpringConfig,
    style?: CSSProperties,
    className?: string,
    mountDelay?: number,
    mountCooldown?: number,
}

class Controller {
    private static _count: bigint = 0n;
    private static _targetAlias: Map<string, Value<string>> = new Map();
    private static _targetSpring: Map<string, Value<CSSProperties>> = new Map();
    private static _targetSpringConfig: Map<string, Value<SpringConfig>> = new Map();
    private static _targetStyle: Map<string, Value<CSSProperties>> = new Map();
    private static _targetClassName: Map<string, Value<string>> = new Map();
    private static _targetMountDelay: Map<string, Value<number>> = new Map();
    private static _targetMountCooldown: Map<string, Value<number>> = new Map();
    private static _targetMount: Map<string, Value<undefined | ReactNode[] | string>> = new Map();

    public static Component(props: ControllerProps): ReactNode {
        const {alias: aliasProp, spring: springProp, springConfig: springConfigProp, style: styleProp, className: classNameProp, mountDelay: mountDelayProp, mountCooldown: mountCooldownProp, children, ... more} = props;
        const [alias, setAlias] = useState<string>(Controller.populateAlias(aliasProp));
        const [spring, setSpring] = useState<CSSProperties[]>([{... springProp} ?? {}, {... springProp} ?? {}]);
        const [springConfig, setSpringConfig] = useState<SpringConfig>({... springConfigProp} ?? {... config.default});
        const [style, setStyle] = useState<CSSProperties>({... styleProp} ?? {});
        const [className, setClasssName] = useState<string>(classNameProp ?? "");
        const [mountDelay, setMountDelay] = useState<number>(mountDelayProp ?? 0);
        const [mountCooldown, setMountCooldown] = useState<number>(mountCooldownProp ?? 0);
        const [mounted, setMounted] = useState<ReactNode[]>([]);
        useEffect(()=>{
            Controller._targetAlias.set(alias, new Value<string>(alias));
            Controller._targetSpring.set(alias, new Value<CSSProperties>(spring[1]));
            Controller._targetSpringConfig.set(alias, new Value<SpringConfig>(springConfig));
            Controller._targetStyle.set(alias, new Value<CSSProperties>(style));
            Controller._targetClassName.set(alias, new Value<string>(className));
            Controller._targetMountDelay.set(alias, new Value<number>(mountDelay));
            Controller._targetMountCooldown.set(alias, new Value<number>(mountCooldown));
            Controller._targetMount.set(alias, new Value<undefined>(undefined));
            setTimeout(()=>{
                if (!children) {
                    return;
                }
                if (Array.isArray(children)) {
                    Controller._mount(new MountRequest({
                        alias: alias,
                        setMounted: setMounted,
                        components: children,
                        cooldown: mountCooldown,
                        delay: mountDelay,
                    }));
                    return;
                }
                setMounted(components => [... components, (children as ReactNode)]);
                return;
            }, mountDelay);
        }, []);
        useEffect(()=>{
            const subscriptions: EventSubscription[] = [
                Controller._targetAlias.get(alias)!.onSet(alias => setAlias(alias)),
                Controller._targetSpring.get(alias)!.onSet(newSpring => setSpring(oldSpring => [oldSpring[1], {... oldSpring[1], ... newSpring}])),
                Controller._targetSpringConfig.get(alias)!.onSet(springConfig => setSpringConfig(springConfig)),
                Controller._targetStyle.get(alias)!.onSet(newStyle => setStyle(oldStyle => ({... oldStyle, ... newStyle}))),
                Controller._targetClassName.get(alias)!.onSet(className => setClasssName(className)),
                Controller._targetMountDelay.get(alias)!.onSet(mountDelay => setMountDelay(mountDelay)),
                Controller._targetMountCooldown.get(alias)!.onSet(mountCooldown => setMountCooldown(mountCooldown)),
                Controller._targetMount.get(alias)!.onSet(payload => {
                    Controller._targetMount.set(alias, new Value<undefined>(undefined));
                    if (!payload) {
                        return;
                    }
                    if (typeof payload === "string") {
                        if (payload === "unmountAll") {
                            setMounted([]);
                            return;
                        }
                        if (payload === "unmount") {
                            setMounted(components => components.splice(0, -1));
                            return;
                        }
                        return;
                    }
                    Controller._mount(new MountRequest({
                        alias: alias,
                        setMounted: setMounted,
                        components: payload,
                        cooldown: mountCooldown,
                        delay: mountDelay,
                    }));
                    return;
                }),
            ];
            return ()=>subscriptions.forEach(subscription => subscription.remove());
        }, [
            alias, 
            spring, 
            springConfig, 
            style, 
            className, 
            mountDelay, 
            mountCooldown, 
            mounted
        ]);
        return (
            <animated.div
            className={className}
            style={{
                ... useSpring({from: spring[0], to: spring[1], config: springConfig}),
                ... style,
            }}
            {... more}>
                {mounted}
            </animated.div>
        );
    }

    public static populateAlias(alias?: string): string {
        if (!alias) {
            return String(Controller._count += 1n);
        }
        return alias;
    }

    public static setSpring(alias: string, spring: CSSProperties): typeof Controller {
        const value: undefined | Value<CSSProperties> = Controller._targetSpring.get(alias);
        if (!value) {
            return Controller;
        }
        value.set(spring);
        return Controller;
    }

    public static setSpringConfig(alias: string, springConfig: SpringConfig): typeof Controller {
        const value: undefined | Value<SpringConfig> = Controller._targetSpringConfig.get(alias);
        if (!value) {
            return Controller;
        }
        value.set(springConfig);
        return Controller;
    }

    public static setStyle(alias: string, style: CSSProperties): typeof Controller {
        const value: undefined | Value<CSSProperties> = Controller._targetStyle.get(alias);
        if (!value) {
            return Controller;
        }
        value.set({... style});
        return Controller;
    }

    public static setClassName(alias: string, className: string): typeof Controller {
        const value: undefined | Value<string> = Controller._targetClassName.get(alias);
        if (!value) {
            return Controller;
        }
        value.set(className);
        return Controller;
    }

    public static setMountDelay(alias: string, ms: number): typeof Controller {
        const value: undefined | Value<number> = Controller._targetMountDelay.get(alias);
        if (!value) {
            return Controller;
        }
        value.set(ms);
        return Controller;
    }

    public static setMountCooldown(alias: string, ms: number): typeof Controller {
        const value: undefined | Value<number> = Controller._targetMountCooldown.get(alias);
        if (!value) {
            return Controller;
        }
        value.set(ms);
        return Controller;
    }

    public static mount(alias: string, components: ReactNode[]): typeof Controller {
        const value: undefined | Value<ReactNode[] | string | undefined> = Controller._targetMount.get(alias);
        if (!value) {
            return Controller;
        }
        if (!Array.isArray(components)) {
            components = [components];
        }
        value.set(components);
        return Controller;
    }

    public static unmount(alias: string): typeof Controller {
        const value: undefined | Value<ReactNode[] | string | undefined> = Controller._targetMount.get(alias);
        if (!value) {
            return Controller;
        }
        value.set("unmount");
        return Controller;
    }

    public static unmountAll(alias: string): typeof Controller {
        const value: undefined | Value<ReactNode[] | string | undefined> = Controller._targetMount.get(alias);
        if (!value) {
            return Controller;
        }
        value.set("unmountAll");
        return Controller;
    }

    private static _mount(request: MountRequest) {
        setTimeout(()=>{
            let cooldown: number = 0;
            request.components.forEach(component => {
                setTimeout(()=>request.setMounted(components => [... components, component]), cooldown);
                cooldown += request.cooldown;
                return;
            });
            return;
        }, request.delay);
    }
}

interface ColProps extends ControllerProps {}

class Col {
    public static Component(props: ColProps): ReactNode {
        let {spring, children, ... more} = props;
        return (
            <Controller.Component
            spring={{
                "display": "flex",
                "flexDirection": "column",
                "justifyContent": "center",
                "alignItems": "center",
                ... spring ?? {},
            }}
            {... more}>
                {children}
            </Controller.Component>
        );
    }
}

interface LayerProps extends ColProps {}

class Layer {
    public static Component(props: LayerProps): ReactNode {
        let {spring, children, ...more} = props;
        return (
            <Col.Component
            spring={{
                "width": "100%",
                "height": "100%",
                "position": "absolute",
                "overflow": "hidden",
                "pointerEvents": "none",
                ... spring ?? {},
            }}
            {... more}>
                {children}
            </Col.Component>
        );
    }
}

interface PageProps extends ColProps {
    hLen?: bigint,
    vLen?: bigint,
}

class Page {
    public static Component(props: PageProps): ReactNode {
        let {style, hLen, vLen, children, ... more} = props;
        hLen = hLen ?? 1n;
        vLen = vLen ?? 1n;
        let hLenNum: number = Number(hLen);
        let vLenNum: number = Number(vLen);
        let hPx: number = hLenNum * 100;
        let vPx: number = vLenNum * 100;
        let width: string = `${hPx}vw`;
        let height: string = `${vPx}vh`;
        return (
            <Col.Component
            spring={{
                "width": width,
                "height": height,
                "overflow": "hidden",
                "background": ColorPalette.OBSIDIAN.toHex().toString(),
                ... style ?? {},
            }}
            {... more}>
                {children}
            </Col.Component>
        );
    }
}

interface RowProps extends ColProps {}

class Row {
    public static Component(props: RowProps): ReactNode {
        let {spring, children, ... more} = props;
        return (
            <Col.Component
            spring={{
                "flexDirection": "row",
                ... spring ?? {},
            }}
            {... more}>
                {children}
            </Col.Component>
        );
    }
}

interface TextProps extends ControllerProps {
    text: string,
}

class Text {
    public static Component(props: TextProps): ReactNode {
        const {text, style, ... more} = props;
        return (
            <Controller.Component
            style={{
                "fontSize": "1em",
                "fontWeight": "bold",
                "fontFamily": "Roboto Mono, monospace",
                "color": "white",
                "background": ColorPalette.POLISHED_TITANIUM.toHex().toString(),
                "display": "flex",
                "flexDirection": "row",
                "justifyContent": "center",
                "alignItems": "center",
                "WebkitBackgroundClip": "text",
                "WebkitTextFillColor": "transparent",
                ... style ?? {},
            }}
            {... more}>
                {text}
            </Controller.Component>
        );
    }
}

interface SimpleButtonProps extends TextProps {
    disabled?: boolean,
}

class SimpleButton {
    public static Component(props: SimpleButtonProps): React.ReactNode {
        let {style, disabled, ... more} = props;
        return (
            <Text.Component
            style={{
                "fontSize": "1.25em",
                "fontWeight": "bold",
                "background": disabled
                    ? ColorPalette.ROCK.toHex().toString()
                    : ColorPalette.POLISHED_TITANIUM.toHex().toString(),
                ... style ?? {},
            }}
            {... more}/>
        );
    }
}

interface RedToPinkGradientButtonProps extends RowProps {
    label: string,
}

class RedToPinkGradientButton {
    public static Component(props: RedToPinkGradientButtonProps): ReactNode {
        let {label, alias, spring, children, ... more} = props;
        const color0: string = ColorPalette.RED_TO_PINK_GRADIENT.COLORS[0].toHex().toString();
        const color1: string = ColorPalette.RED_TO_PINK_GRADIENT.COLORS[1].toHex().toString();
        const x0: string = "4px";
        const y0: string = "1px";
        const x1: string = "16px";
        const y1: string = "1px";
        const boxShadow0: string = `0 0 ${x0} ${y0} ${color0}, 0 0 ${x0} ${y0} ${color1}`;
        const boxShadow1: string = `0 0 ${x1} ${y1} ${color0}, 0 0 ${x1} ${y1} ${color1}`;
        alias = Controller.populateAlias(alias);
        return (
            <Row.Component
            alias={alias}
            springConfig={config.gentle}
            spring={{
                "minWidth": "200px",
                "maxWidth": "200px",
                "minHeight": "50px",
                "maxHeight": "50px",
                "background": `linear-gradient(to right, ${color0}, ${color1})`,
                "boxShadow": boxShadow0,
                "pointerEvents": "auto",
                "cursor": "pointer",
                "borderWidth": "1px",
                "borderStyle": "solid",
                "borderImage": `linear-gradient(to right, ${color0}, ${color1}) 1`,
                "position": "relative",
                ... spring ?? {},
            }}
            onMouseEnter={()=>Controller.setSpring(alias, {
                "boxShadow": boxShadow1,
            })}
            onMouseLeave={()=>Controller.setSpring(alias, {
                "boxShadow": boxShadow0,
            })}
            {... more}>
                <Text.Component 
                text={label}
                style={{
                    "background": ColorPalette.OBSIDIAN.toHex().toString(),
                    "fontSize": "1em",
                    "fontWeight": "bold",
                }}/>
            </Row.Component>
        );
    }
}

interface OutlinedGraphiteButtonProps extends RowProps {
    label: string,
}

class OutlinedGraphiteButton {
    public static Component(props: OutlinedGraphiteButtonProps): ReactNode {
        let {label, alias, spring, children, ... more} = props;
        alias = Controller.populateAlias(alias);
        return (
            <Row.Component
            alias={alias}
            springConfig={config.gentle}
            spring={{
                "minWidth": "200px",
                "maxWidth": "200px",
                "minHeight": "50px",
                "maxHeight": "50px",
                "pointerEvents": "auto",
                "cursor": "pointer",
                "borderWidth": "1px",
                "borderStyle": "solid",
                "borderColor": `${ColorPalette.GRAPHITE.toHex().toString()}`,
                "position": "relative",
                ... spring ?? {},
            }}
            {... more}>
                <Text.Component 
                text={label}
                style={{
                    "fontSize": "1em",
                    "fontWeight": "bold",
                }}/>
            </Row.Component>
        );
    }
}

interface GlassContainerWithGraphiteFrameProps extends ColProps {
    frameDir:
        | "to left"
        | "to right"
        | "to bottom"
        | "to top";
}

class GlassContainerWithGraphiteFrame {
    public static Component(props: GlassContainerWithGraphiteFrameProps): ReactNode {
        let {frameDir, style, children, ... more} = props;
        return (
            <Col.Component
            style={{
                "backdropFilter": "blur(30px)",
                "borderWidth": "1px",
                "borderStyle": "solid",
                "borderImage": `linear-gradient(${frameDir ?? "to bottom"}, transparent, ${ColorPalette.GRAPHITE.toHex().toString()}) 1`,
                ... style ?? {}
            }}
            {... more}>
                {children}
            </Col.Component>
        );
    }
}

interface BlurdotProps extends ColProps {
    color0: string,
    color1: string,
}

class Blurdot {
    public static Component(props: BlurdotProps): ReactNode {
        const {color0, color1, spring, children, ... more} = props;
        return (
            <Col.Component
            spring={{
                "background": `radial-gradient(closest-side, ${color0}, ${color1})`,
                opacity: ".05",
                ... spring ?? {},
            }}
            {... more}>
                {children}
            </Col.Component>
        );
    }
}

class LogoAndBrandName {
    public static Component(): ReactNode {
        return (
            <Col.Component>
                <img
                src="../../img/Logo.png"
                /// @ts-expect-error
                style={{
                    "width": "25px",
                    "height": "25px",
                }}/>
                <Text.Component
                text="Dreamcatcher"
                style={{
                    "fontSize": "1.5em",
                }}/>
            </Col.Component>
        );
    }
}

interface NavbarButtonProps extends ComponentPropsWithoutRef<typeof Link> {
    text0: string;
    text1: string;
    style?: CSSProperties;
}

class NavbarButton {
    public static Component(props: NavbarButtonProps): ReactNode {
        const {text0, text1, style, children, ... more} = props;
        return (
            <Link
            /// @ts-expect-error
            style={{
                "pointerEvents": "auto",
                "gap": "10px",
                "textDecoration": "none",
                "color": "white",
                "display": "flex",
                "flexDirection": "row",
                "justifyContent": "center",
                "alignItems": "center",
                ... style ?? {},
            }}>
                <Text.Component
                text={text0}
                style={{
                    "background": ColorPalette.DEEP_PURPLE.toHex().toString(),
                    "fontSize": "1em",
                    "display": "flex",
                    "flexDirection": "row",
                    "justifyContent": "center",
                    "alignItems": "center",
                }}/>

                <Text.Component
                text={text1}
                style={{
                    "fontSize": "1em",
                    "display": "15px",
                    "flexDirection": "row",
                    "alignItems": "center",
                }}/>
            </Link>
        );
    }
}

class Navbar {
    public static Component(): ReactNode {
        return (
            <Row.Component>
                <Row.Component>
                    <LogoAndBrandName.Component/>
                </Row.Component>
                <Row.Component></Row.Component>
                <Row.Component></Row.Component>
            </Row.Component>
        );
    }
}

class HomePage {
    public static Component(): ReactNode {
        return (
            <Page.Component>
                <HomePage._Background/>
                <Layer.Component>
                    <HomePage._HeroSection/>
                </Layer.Component>
            </Page.Component>
        );
    }

    private static _MoreLinks = class {
        public static Component(): ReactNode {
            return (
                <HomePage._MoreLinks._Wrapper>
                    <HomePage._MoreLinks._HeadingRow>
                        <HomePage._MoreLinks._HeadingSlot><HomePage._MoreLinks._Heading label="Product"/></HomePage._MoreLinks._HeadingSlot>
                        <HomePage._MoreLinks._HeadingSlot><HomePage._MoreLinks._Heading label="Governance"/></HomePage._MoreLinks._HeadingSlot>
                        <HomePage._MoreLinks._HeadingSlot><HomePage._MoreLinks._Heading label="Developers"/></HomePage._MoreLinks._HeadingSlot>
                        <HomePage._MoreLinks._HeadingSlot><HomePage._MoreLinks._Heading label="About"/></HomePage._MoreLinks._HeadingSlot>
                    </HomePage._MoreLinks._HeadingRow>
                    <HomePage._MoreLinks._Row>
                        <HomePage._MoreLinks._Column>
                            <HomePage._MoreLinks._Slot><HomePage._MoreLinks._Button label="Tools" disabled/></HomePage._MoreLinks._Slot>
                            <HomePage._MoreLinks._Slot><HomePage._MoreLinks._Button label="Analytics" disabled/></HomePage._MoreLinks._Slot>
                            <HomePage._MoreLinks._Slot></HomePage._MoreLinks._Slot>
                            <HomePage._MoreLinks._Slot></HomePage._MoreLinks._Slot>
                        </HomePage._MoreLinks._Column>
                        <HomePage._MoreLinks._Column>
                            <HomePage._MoreLinks._Slot><HomePage._MoreLinks._Button label="Dashboard" disabled/></HomePage._MoreLinks._Slot>
                            <HomePage._MoreLinks._Slot><HomePage._MoreLinks._Button label="Proposals" disabled/></HomePage._MoreLinks._Slot>
                            <HomePage._MoreLinks._Slot><HomePage._MoreLinks._Button label="Treasury" disabled/></HomePage._MoreLinks._Slot>
                            <HomePage._MoreLinks._Slot></HomePage._MoreLinks._Slot>
                        </HomePage._MoreLinks._Column>
                        <HomePage._MoreLinks._Column>
                            <HomePage._MoreLinks._Slot><HomePage._MoreLinks._Button label="Github"/></HomePage._MoreLinks._Slot>
                            <HomePage._MoreLinks._Slot><HomePage._MoreLinks._Button label="Whitepaper"/></HomePage._MoreLinks._Slot>
                            <HomePage._MoreLinks._Slot></HomePage._MoreLinks._Slot>
                            <HomePage._MoreLinks._Slot></HomePage._MoreLinks._Slot>
                        </HomePage._MoreLinks._Column>
                        <HomePage._MoreLinks._Column>
                            <HomePage._MoreLinks._Slot><HomePage._MoreLinks._Button label="Roadmap"/></HomePage._MoreLinks._Slot>
                            <HomePage._MoreLinks._Slot><HomePage._MoreLinks._Button label="Press Kit" disabled/></HomePage._MoreLinks._Slot>
                            <HomePage._MoreLinks._Slot><HomePage._MoreLinks._Button label="FAQ"/></HomePage._MoreLinks._Slot>
                            <HomePage._MoreLinks._Slot><HomePage._MoreLinks._Button label="Careers" disabled/></HomePage._MoreLinks._Slot>
                        </HomePage._MoreLinks._Column>
                    </HomePage._MoreLinks._Row>
                </HomePage._MoreLinks._Wrapper>
            );
        }
    
        private static _Wrapper({children}:{children?: ReactNode}): ReactNode {
            return (
                <Col.Component
                style={{
                    "minWidth": "300px",
                    "maxWidth": "300px",
                    "minHeight": "187.5px",
                    "maxHeight": "187.5px",
                }}>
                    {children}
                </Col.Component>
            );
        }
    
        public static _HeadingRow({children}:{children?: ReactNode}): ReactNode {
            return (
                <Row.Component
                spring={{
                    "minWidth": "300px",
                    "maxWidth": "300px",
                    "minHeight": "37.5px",
                    "maxHeight": "37.5px",
                }}>
                    {children}
                </Row.Component>
            );
        }
    
        public static _HeadingSlot({children}: {children?: ReactNode}): ReactNode {
            return (
                <Row.Component
                spring={{
                    "minWidth": "75px",
                    "maxWidth": "75px",
                    "minHeight": "37.5px",
                    "maxHeight": "37.5px",
                    "justifyContent": "start",
                }}>
                    {children}
                </Row.Component>
            )
        }
    
        public static _Heading({
            label,
            children,
        }:{
            label: string,
            children?: ReactNode[],
        }): ReactNode {
            const color0: string = ColorPalette.RED_TO_PINK_GRADIENT.COLORS[0].toHex().toString();
            const color1: string = ColorPalette.RED_TO_PINK_GRADIENT.COLORS[1].toHex().toString();
            const gradient: string = `linear-gradient(to bottom, ${color0}, ${color1})`;
            return (
                <Text.Component 
                style={{
                    "fontSize": "0.9em",
                    "background": gradient,
                }} 
                text={label}/>
            );
        }
    
        public static _Row({children}:{children?: ReactNode}): ReactNode {
            return (
                <Row.Component
                spring={{
                    "minWidth": "300px",
                    "maxWidth": "300px",
                    "minHeight": "150px",
                    "maxHeight": "150px",
                    "justifyContent": "space-between",
                }}>
                    {children}
                </Row.Component>
            );
        }
    
        public static _Column({children}:{children?: ReactNode}): ReactNode {
            return (
                <Col.Component
                spring={{
                    "minWidth": "75px",
                    "maxWidth": "75px",
                    "minHeight": "150px",
                    "maxHeight": "150px",
                }}>
                    {children}
                </Col.Component>
            );
        }
    
        public static _Slot({children}:{children?: ReactNode}): ReactNode {
            return (
                <Row.Component
                style={{
                    "minWidth": "75px",
                    "maxWidth": "75px",
                    "minHeight": "37.5px",
                    "maxHeight": "37.5px",
                    "justifyContent": "flex-start",
                }}>
                    {children}
                </Row.Component>
            );
        }
    
        public static _Button({
            label,
            disabled, 
            children,}:{
                label: string, 
                disabled?: boolean,
                children?: ReactNode,
            }): ReactNode {
            return (
                <SimpleButton.Component
                style={{
                    "fontSize": "0.75em",
                }}
                text={label}
                disabled={disabled}/>
            );
        }
    }

    private static _Background(): ReactNode {
        return (
            <Layer.Component
            spring={{
                "background": ColorPalette.OBSIDIAN.toHex().toString(),
            }}>
                <Blurdot.Component
                color0={ColorPalette.DEEP_PURPLE.toHex().toString()}
                color1={ColorPalette.OBSIDIAN.toHex().toString()}
                spring={{
                    "width": "1000px",
                    "height": "1000px",
                    "position": "absolute",
                    "right": "400px",
                }}/>
                <Blurdot.Component
                color0="#0652FE"
                color1={ColorPalette.OBSIDIAN.toHex().toString()}
                spring={{
                    "width": "1000px",
                    "height": "1000px",
                    "position": "absolute",
                    "left": "400px",
                }}/>
            </Layer.Component>
        );
    }

    private static _HeroSection(): ReactNode {
        return (
            <Col.Component
            spring={{
                "width": "500px",
                "aspectRatio": "1 / 1",
                "borderWidth": "1px",
                "borderStyle": "solid",
                "borderImage": `linear-gradient(to top, transparent, ${ColorPalette.GRAPHITE.toHex().toString()}) 1`,
                "display": "flex",
                "flexDirection": "column",
                "justifyContent": "center",
                "justifyItems": "center",
                "flexWrap": "nowrap",
            }}>
                <GlassContainerWithGraphiteFrame.Component
                spring={{
                    "width": "450px",
                    "aspectRatio": "1 / 1",
                    "justifyContent": "space-between",
                    "alignContent": "space-between",
                    "paddingTop": "60px",
                    "paddingBottom": "30px",
                }}
                frameDir="to bottom">
                    <Col.Component
                    style={{
                        "paddingLeft": "30px",
                        "paddingRight": "30px",
                    }}>
                        <Controller.Component
                        style={{
                            "width": "100%",
                            "fontSize": "2.5em",
                            "fontWeight": "bold",
                            "fontFamily": "Roboto Mono, monospace",
                            "color": "white",
                            "background": ColorPalette.POLISHED_TITANIUM.toHex().toString(),
                            "display": "flex",
                            "flexDirection": "row",
                            "justifyContent": "start",
                            "alignItems": "center",
                            "WebkitBackgroundClip": "text",
                            "WebkitTextFillColor": "transparent",
                            "marginBottom": "10px",
                        }}>
                            Scaling Dreams, Crafting Possibilities.
                        </Controller.Component>
                        
                        <Controller.Component
                        style={{
                            "width": "100%",
                            "fontSize": "1.50em",
                            "fontWeight": "bold",
                            "fontFamily": "Roboto Mono, monospace",
                            "color": "white",
                            "background": ColorPalette.POLISHED_TITANIUM.toHex().toString(),
                            "display": "flex",
                            "flexDirection": "row",
                            "justifyContent": "start",
                            "alignItems": "center",
                            "WebkitBackgroundClip": "text",
                            "WebkitTextFillColor": "transparent",
                        }}>
                            Deploy tokenized vaults in seconds.
                        </Controller.Component>
                    </Col.Component>

                    <Row.Component
                    spring={{
                        "gap": "16px",
                    }}>
                        <Link
                        to="/get-started"
                        /// @ts-expect-error
                        style={{
                            "all": "unset",
                        }}>
                            <RedToPinkGradientButton.Component 
                            label="Get Started"/>
                        </Link>

                        <Link
                        to="https://dreamcatcher-1.gitbook.io/dreamcatcher"
                        /// @ts-expect-error
                        style={{
                            "all": "unset",
                        }}>
                            <OutlinedGraphiteButton.Component 
                            label="Learn More"/>
                        </Link>
                    </Row.Component>
                </GlassContainerWithGraphiteFrame.Component>
            </Col.Component>
        );
    }
}

class Renderable {
    public static render() {
        let rootElement: HTMLElement | null = document.getElementById("root");
        if (!rootElement) {
            return;
        }
        let root: Root = createRoot(rootElement);
        root.render(<RouterProvider router={createBrowserRouter([{
            path: "/",
            element: (<HomePage.Component/>),
        }])}/>);
    }
}

Renderable.render();