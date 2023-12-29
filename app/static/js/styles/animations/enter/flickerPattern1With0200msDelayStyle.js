import Component from "../../Component.js";

export default function flickerPattern1With0200msDelayStyle() {
    const component = new Component();
    component.syncToNewElement('style');
    component.updateInnerHTML(
    `
        .flicker-pattern-1-with-0200ms-delay {
            animation: flicker-pattern-1 2s 0.20s linear both;
        }
    `
    );
    return component;
}