function elementWrapper() {
    let _element;

    let element = () => {
        return _element;
    }

    let syncToElement = ({
        selector,
        position = 0
    }) => {
        _element = document.querySelectorAll(selector)[position];
        return;
    }

    let syncToNewElement = (tag) => {
        _element = document.createElement(tag);
        return;
    }

    let assignClassName = (className) => {
        _element
            .classList
            .add(className);
        return;
    }

    let unassignClassName = (className) => {
        _element
            .classList
            .remove(className);
        return;
    }


    return {
        element,
        syncToElement,
        syncToNewElement,
        assignClassName,
        unassignClassName
    };

}