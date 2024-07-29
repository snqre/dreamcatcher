import type {ReactNode} from "react";
import type {CSSProperties} from "react";
import type {ComponentPropsWithoutRef} from "react";
import type {SpringConfig} from "react-spring";
import type {EventSubscription} from "fbemitter";
import {Value} from "@value";
import {config} from "react-spring";
import {animated} from "react-spring";
import {useEffect} from "react";
import {useSpring} from "react-spring";
import {useState} from "react";
import React from "react";

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

export type {ControllerProps};
export {Controller};