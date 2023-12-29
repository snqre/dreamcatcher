import Component from "../../Component.js";

export default function flickerPattern1With1000msDelayStyle() {
    const component = new Component();
    component.syncToNewElement('style');
    component.updateInnerHTML(
    `
        .flicker-pattern-1-with-1000ms-delay {
            animation: flicker-pattern-1 2s 1.00s linear both;
        }
    `
    );
    return component;
}