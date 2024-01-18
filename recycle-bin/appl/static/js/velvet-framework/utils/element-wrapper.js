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

    let on = (trigger, callback) => {
        _element.addEventListener(trigger, callback);
        return;
    }

    let onEnterView = (
        callback,
        options={
            root: null,
            rootMargin: '0px',
            threshold: .5
        }
    ) => {
        let observer = new IntersectionObserver((entries, observer) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    callback();
                    observer.unobserve(entry.target);
                }
            })
        }, options);
        observer.observe(_element);
        return;
    }

    let onRepeat = (callback, wait) => {
        setInterval(callback, wait);
        return;
    }

    let setContent = (content) => {
        _element.textContent = content;
        return;
    }

    let injectContent = (content) => {
        _element.textContent += content;
        return;
    }

    

    return {
        element,
        syncToElement,
        syncToNewElement,
        assignClassName,
        unassignClassName,
        on,
        onEnterView
    };
}