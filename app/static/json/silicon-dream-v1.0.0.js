/** silicon-dream-v1.0.0 */

function delay() {
    let _value = -.1;

    function _new() {
        console.log(_value);
        _value += .1;
        return _value;
    }

    function _reset() {
        _value = 0;
        return true;
    }

    return {
        new: function () {
            return _new();
        },
        reset: function () {
            return _reset();
        }
    }
}

const globalIntroDelay = delay();

/**
 * @function inherit
 * @description Factory function for creating custom objects with inheritance capabilities.
 * @returns {Object} - An object containing the 'inherit' method for creating instances with inheritance.
 */
function inherit() {
    /**
     * @function ____inherit
     * @description Performs inheritance by binding functions from extension objects to the custom type instance.
     * @param {Object[]} extensions - An array of extension objects to inherit from.
     * @param {boolean} [inheritStack=true] - If true, non-function properties are also inherited.
     * @returns {boolean} - True if the inheritance is successful.
     * @private
     */
    function ____inherit(extensions, inheritStack=true) {
        for (let i = 0; i < extensions.length; i++) {
            for (let key in extensions[i]) {
                if (extensions[i].hasOwnProperty(key) && typeof extensions[i][key] == 'function') {
                    this[key] = extensions[i][key].bind(this);
                }
            }
            if (inheritStack) {
                for (let key in this) {
                    if (this.hasOwnProperty(key) && typeof this[key] !== 'function') {
                        extensions[i][key] = this[key];
                    }
                }
            }
        }
        return true;
    }

    return {

        /**
         * @method inherit
         * @description Applies inheritance to the custom type instance.
         * @param {Object[]} extensions - An array of extension objects to inherit from.
         * @param {boolean} [inheritStack=true] - If true, non-function properties are also inherited.
         * @returns {boolean} - True if the inheritance is successful.
         */
        inherit: function (extensions, inheritStack=true) {
            return ____inherit.call(this, extensions, inheritStack);
        }
    }
}

function componentTemplate() {
    let _element = null;
    let _stylesheetTemplates = {};
    let _eventCallbacks = {};

    function _assignElement(element) {
        _element = document.querySelector(element);
        return true;
    }

    function _assignElementFromList(element, position) {
        _element = document.querySelectorAll(element)[position];
        return true;
    }

    function _assignNewElement(element) {
        _element = document.createElement(element);
        return true;
    }

    function _unassignElement() {
        _element = null;
        return true;
    }

    function _assignClass(class_) {
        _element.classList.add(class_);
        return true;
    }

    function _unassignClass(class_) {
        _element.classList.remove(class_);
        return true;
    }

    function _unassignEveryClass() {
        for (let i = 0; i < _element.classList.length; i++) {
            _unassignClass(_element.classList[i]);
        }
        return true;
    }

    function _updateStyle(stylesheet) {
        Object.assign(_element.style, stylesheet);
        return true;
    }

    function _resetStyle() {
        _updateStyle({all: 'revert'});
        return true;
    }

    function _updateStyleTemplate(template, stylesheet) {
        if (!_stylesheetTemplates[template]) {
            _stylesheetTemplates[template] = {};
        }
        Object.assign(_stylesheetTemplates[template], stylesheet);
        return true;
    }

    function _resetStyleTemplate(template) {
        _updateStyleTemplate(template, {all: 'revert'});
        return true;
    }

    function _applyStyleTemplate(template) {
        _updateStyle(_stylesheetTemplates[template]);
        return true;
    }

    function _resetStyleAndApplyStyleTemplate(template) {
        _resetStyle();
        _applyStyleTemplate(template);
        return true;
    }

    function _onEvent(event, callback) {
        if (!_eventCallbacks[event]) {
            _eventCallbacks[event] = [];
        }
        _eventCallbacks[event].push(callback);
        _element.addEventListener(event, callback);
        return true;
    }

    function _onEventDelegate(event, selector, callback) {
        _element.addEventListener(event, (e) => {
            if (e.target.matches(selector)) {
                callback(e);
            }
        });
        return true;
    }

    function _onEnterViewport(callback, root=null, rootMargin='0px', threshold=.5) {
        const observer = new IntersectionObserver((entries, observer) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    callback();
                    observer.unobserve(entry.target);
                }
            });
        }, {
            root,
            rootMargin,
            threshold
        });
        observer.observe(_element);
    }

    function _deleteEventCallback(event, callback) {
        _element.removeEventListener(event, callback);
        if (_eventCallbacks[event]) {
            const index = _eventCallbacks[event].indexOf(callback);
            if (index !== -1) {
                _eventCallbacks[event].splice(index, 1);
            }
            if (_eventCallbacks[event].length === 0) {
                delete _eventCallbacks[event];
            }
            return true;
        }
        return false;
    }

    function _deleteEventCallbacks(event) {
        if (_eventCallbacks[event]) {
            _eventCallbacks[event].forEach(callback => {
                _element.removeEventListener(event, callback);
            });
            _eventCallbacks[event] = [];
            if (Object.keys(_eventCallbacks[event]).length === 0) {
                delete _eventCallbacks[event];
            }
            return true;
        }
        return false;
    }

    function _attach(components) {
        if (components.length !== 0) {
            for (let i = 0; i < components.length; i++) {
                try {
                    _element.appendChild(components[i].element());
                } catch {
                    _assignClass(components[i]);
                }
            }
            return true;
        }
        return false;
    }

    function _updateInnerHTML(source) {
        _element.innerHTML = source;
        return true;
    }

    function _injectInnerHTML(source) {
        _element.innerHTML += source;
        return true;
    }

    function _deleteInnerHTML() {
        _element.innerHTML = '';
        return true;
    }

    function _updateTextContent(text) {
        _element.textContent = text;
        return true;
    }

    function _injectTextContent(text) {
        _element.textContent += text;
        return true;
    }

    return {
        element: () => _element,
        assignElement: (element) => _assignElement(element),
        assignElementFromList: (element) => _assignElementFromList(element, position),
        assignNewElement: (element) => _assignNewElement(element),
        unassignElement: () => _unassignElement(),
        assignClass: (class_) => _assignClass(class_),
        unassignClass: (class_) => _unassignClass(class_),
        unassignEveryClass: () => _unassignEveryClass(),
        updateStyle: (stylesheet) => _updateStyle(stylesheet),
        resetStyle: () => _resetStyle(),
        updateStyleTemplate: (template, stylesheet) => _updateStyleTemplate(template, stylesheet),
        resetStyleTemplate: (template) => _resetStyleTemplate(template),
        applyStyleTemplate: (template) => _applyStyleTemplate(template),
        resetStyleAndApplyStyleTemplate: (template) => _resetStyleAndApplyStyleTemplate(template),
        onEvent: (event, callback) => _onEvent(event, callback),
        onEventDelagate: function (event, selector, callback) {
            return _onEventDelegate(event, selector, callback);
        },
        onEnterViewport(callback, root=null, rootMargin='0px', threshold=.5) {
            return _onEnterViewport(callback, root, rootMargin, threshold);
        },
        deleteEventCallback: (event, callback) => _deleteEventCallback(event, callback),
        deleteEventCallbacks: (event) => _deleteEventCallbacks(event),
        attach: (components) => _attach(components),
        updateInnerHTML: function (source) {
            return _updateInnerHTML(source);
        },
        injectInnerHTML: function (source) {
            return _injectInnerHTML(source);
        },
        deleteInnerHTML: () => _deleteInnerHTML(),
        updateTextContent: function (text) {
            return _updateTextContent(text);
        },
        injectTextContent: function (text) {
            return _injectTextContent(text);
        }
    }
}

function blueprints() {
    function _column(width, height, stylesheet={}, innerComponents=[]) {
        const _component = componentTemplate();
        _component.assignNewElement('div');
        _component.updateStyleTemplate(
            'default', {
                width: width,
                height: height,
                display: 'flex',
                flexDirection: 'column',
                justifyContent: 'center',
                alignItems: 'center'
            }
        );
        _component.updateStyleTemplate('default', stylesheet);
        _component.attach(innerComponents);
        return _component;
    }

    function _row(width, height, stylesheet={}, innerComponents=[]) {
        const _component = componentTemplate();
        _component.assignNewElement('div');
        _component.updateStyleTemplate(
            'default', {
                width: width,
                height: height,
                display: 'flex',
                flexDirection: 'row',
                justifyContent: 'center',
                alignItems: 'center'
            }
        );
        _component.updateStyleTemplate('default', stylesheet);
        _component.attach(innerComponents);
        return _component;
    }

    function _gradientButton(width, height, text='', color1='#705aff', color2='#d454ff', stylesheet={}, innerComponents=[]) {
        const _component = componentTemplate();
        _component.assignNewElement('div');
        _component.updateTextContent(text);
        _component.updateStyleTemplate(
            'default', {
                alignItems: 'center',
                appearance: 'none',
                backgroundImage: `radial-gradient(100% 100% at 100% 0, ${color1} 0, ${color2} 100%)`,
                border: '0',
                borderRadius: '6px',
                boxShadow: 'rgba(45, 35, 66, .4) 0 2px 4px, rgba(45, 35, 66, .3) 0 7px 13px -3px, rgba(58, 65, 111, .5) 0 -3px 0 inset',
                boxSizing: 'border-box',
                color: '#fff',
                cursor: 'pointer',
                fontFamily: '"JetBrains Mono", monospace',
                width: width,
                height: height,
                justifyContent: 'center',
                lineHeight: '1',
                listStyle: 'none',
                overflow: 'hidden',
                paddingLeft: '16px',
                paddingRight: '16px',
                position: 'relative',
                textAlign: 'center',
                textDecoration: 'none',
                transition: 'box-shadow .15s, transform .15s',
                userSelect: 'none',
                webkitUserSelect: 'none',
                touchAction: 'manipulation',
                whiteSpace: 'nowrap',
                willChange: 'box-shadow, transform',
                fontSize: '18px',
                display: 'flex',
                padding: '10px',
                transform: 'translateY(0px)'
            }
        );
        _component.updateStyleTemplate(
            'focus', {
                boxShadow: '#3c4fe0 0 0 0 1.5px inset, rgba(45, 35, 66, .4) 0 2px 4px, rgba(45, 35, 66, .3) 0 7px 13px -3px, #3c4fe0 0 -3px 0 inset'
            }
        );
        _component.updateStyleTemplate(
            'hover', {
                boxShadow: 'rgba(45, 35, 66, .4) 0 4px 8px, rgba(45, 35, 66, .3) 0 7px 13px -3px, #3c4fe0 0 -3px 0 inset',
                transform: 'translateY(-2px)'
            }
        );
        _component.updateStyleTemplate(
            'active', {
                boxShadow: '#3c4fe0 0 3px 7px inset',
                tranform: 'translateY(2px)'
            }
        );
        _component.updateStyleTemplate('default', stylesheet);
        _component.resetStyleAndApplyStyleTemplate('default');
        _component.onEvent('mouseenter', () => {
            _component.applyStyleTemplate('hover');
            _component.applyStyleTemplate('focus');
        });
        _component.onEvent('mouseleave', () => {
            _component.applyStyleTemplate('default');
        });
        _component.onEvent('mousedown', () => {
            _component.applyStyleTemplate('active');
        });
        _component.onEvent('mouseup', () => {
            _component.applyStyleTemplate('hover');
            _component.applyStyleTemplate('focus');
        });
        _component.onEnterViewport(() => {
            let opacity = 0;
            let delay_ = globalIntroDelay.new();
            console.log(delay_);
            function animationStep(timestamp) {
                let progress = 0;
                if (!startTime) startTime = timestamp;
                if (delay_ === 0) {
                    progress = (timestamp - startTime) / duration;
                }
                delay_ -= 0.001;
                if (delay_ < 0) { delay_ = 0; }
                _component.updateStyle({
                    opacity: progress
                });
                if (progress < 1) {
                    requestAnimationFrame(animationStep);
                } else {
                    _component.updateStyle({
                        opacity: 1
                    });
                }
            }
            const duration = 2000;
            let startTime;
            requestAnimationFrame(animationStep);
        });
        _component.attach(innerComponents);
        return _component;
    }

    function _button(width, height, text='', stylesheet={}, innerComponents=[]) {
        const _component = componentTemplate();
        _component.assignNewElement('div');
        _component.updateTextContent(text);
        _component.updateStyleTemplate(
            'default', {
                alignItems: 'center',
                appearance: 'none',
                backgroundColor: '#FCFCFD',
                borderRadius: '4px',
                borderWidth: '0',
                boxShadow: 'rgba(45, 35, 66, .4) 0 2px, rgba(45, 35, 66, .3) 0 7px 13px -3px, #D6D6E7 0 -3px 0 inset',
                boxSizing: 'border-box',
                color: '#36385A',
                cursor: 'pointer',
                display: 'inline-flex',
                fontFamily: '"JetBrains Mono", monospace',
                width: width,
                height: height,
                justifyContent: 'center',
                lineHeight: '1',
                listStyle: 'none',
                overflow: 'hidden',
                paddingLeft: '16px',
                paddingRight: '16px',
                position: 'relative',
                textAlign: 'left',
                textDecoration: 'none',
                transition: 'box-shadow .15s, transform .15s',
                userSelect: 'none',
                webkitUserSelect: 'none',
                touchAction: 'manipulation',
                whiteSpace: 'nowrap',
                willChange: 'box-shadow, transform',
                fontSize: '18px',
                padding: '10px',
                transform: 'translateY(0px)'
            }
        );
        _component.updateStyleTemplate(
            'focus', {
                boxShadow: '#D6D6E7 0 0 0 1.5px inset, rgba(45, 35, 66, .4) 0 2px 4px, rgba(45, 35, 66, .3) 0 7px 13px -3px, #D6D6E7 0 -3px 0 inset'
            }
        );
        _component.updateStyleTemplate(
            'hover', {
                boxShadow: 'rgba(45, 35, 66, .4) 0 4px 8px, rgba(45, 35, 66, .3) 0 7px 13px -3px, #D6D6E7 0 -3px 0 inset',
                transform: 'translateY(-2px)'
            }
        );
        _component.updateStyleTemplate(
            'active', {
                boxShadow: '#D6D6E7 0 3px 7px inset',
                transform: 'translate(2px)'
            }
        );
        _component.updateStyleTemplate('default', stylesheet);
        _component.resetStyleAndApplyStyleTemplate('default');
        _component.onEvent('mouseenter', () => {
            _component.applyStyleTemplate('hover');
            _component.applyStyleTemplate('focus');
        });
        _component.onEvent('mouseleave', () => {
            _component.applyStyleTemplate('default');
        });
        _component.onEvent('mousedown', () => {
            _component.applyStyleTemplate('active');
        });
        _component.onEvent('mouseup', () => {
            _component.applyStyleTemplate('hover');
            _component.applyStyleTemplate('focus')
        });
        _component.onEnterViewport(() => {
            let delay_ = globalIntroDelay.new();
            function animationStep(timestamp) {
                let progress = 0;
                if (!startTime) startTime = timestamp;
                if (delay_ === 0) {
                    progress = ((timestamp - startTime) / duration);
                }
                delay_ -= 0.001;
                if (delay_ < 0) { delay_ = 0; }
                _component.updateStyle({
                    opacity: progress
                });
                if (progress < 1) {
                    requestAnimationFrame(animationStep);
                }
            }
            const duration = 2000;
            let startTime;
            requestAnimationFrame(animationStep);
        });
        _component.attach(innerComponents);
        return _component;
    }

    function _flatNeumorphicContainer(width, height, stylesheet={}, innerComponents=[]) {
        const _component = componentTemplate();
        _component.assignNewElement('div');
        _component.updateStyleTemplate(
            'default', {
                width: width,
                height: height,
                background: '#ffffff',
                boxShadow: '20px 20px 60px #d9d9d9, -20px -20px 60px #ffffff',
                display: 'flex',
                flexDirection: 'column',
                justifyContent: 'center',
                alignItems: 'center'
            }
        );
        _component.updateStyleTemplate('default', stylesheet);
        _component.applyStyleTemplate('default');
        _component.attach(innerComponents);
        return _component;
    }

    function _flatNeumorphicContainerWithColorfulAnimatedBorderOnHover(width, height, stylesheet={}, innerComponents=[]) {
        const _component = _flatNeumorphicContainer(width, height, {}, []);
        
    }

    function _concaveNeumorphicContainer(width, height, stylesheet={}, innerComponents=[]) {
        const _component = componentTemplate();
        _component.assignNewElement('div');
        _component.updateStyleTemplate(
            'default', {
                width: width,
                height: height,
                background: 'linear-gradient(145deg, #e6e6e6, #ffffff)',
                boxShadow: '20px 20px 60px #d9d9d9, -20px -20px 60px #ffffff',
                display: 'flex',
                flexDirection: 'column',
                justifyContent: 'center',
                alignItems: 'center'   
            }
        );
        _component.updateStyleTemplate('default', stylesheet);
        _component.applyStyleTemplate('default');
        _component.attach(innerComponents);
        return _component;
    }

    function _convexNeumorphicContainer(width, height, stylesheet={}, innerComponents=[]) {
        const _component = componentTemplate();
        _component.assignNewElement('div');
        _component.updateStyleTemplate(
            'default', {
                width: width,
                height: height,
                background: 'linear-gradient(145deg, #ffffff, #e6e6e6)',
                boxShadow: '20px 20px 60px #d9d9d9, -20px -20px 60px #ffffff',
                display: 'flex',
                flexDirection: 'column',
                justifyContent: 'center',
                alignItems: 'center'
            }
        );
        _component.updateStyleTemplate('default', stylesheet);
        _component.applyStyleTemplate('default');
        _component.attach(innerComponents);
        return _component;
    }

    function _pressedNeumorphicContainer(width, height, stylesheet={}, innerComponents=[]) {
        const _component = componentTemplate();
        _component.assignNewElement('div');
        _component.updateStyleTemplate(
            'default', {
                width: width,
                height: height,
                background: '#ffffff',
                boxShadow: 'inset 20px 20px 60px #d9d9d9, inset -20px -20px 60px #ffffff',
                display: 'flex',
                flexDirection: 'column',
                justifyContent: 'center',
                alignItems: 'center'
            }
        );
    }

    return {
        column: function (width,
            height,
            stylesheet = {},
            innerComponents = []) {
            return _column(
                width,
                height,
                stylesheet,
                innerComponents
            );
        },
        row: function (width,
            height,
            stylesheet = {},
            innerComponents = []) {
            return _row(
                width,
                height,
                stylesheet,
                innerComponents
            );
        },
        gradientButton: function (width, height, text='', color1='#705aff', color2='#d454ff', stylesheet={}, innerComponents=[]) {
            return _gradientButton(width, height, text, color1, color2, stylesheet, innerComponents);
        },
        button: function (width, height, text='', stylesheet={}, innerComponents=[]) {
            return _button(width, height, text, stylesheet, innerComponents);
        },
        flatNeumorphicContainer: function (width, height, stylesheet={}, innerComponents=[]) {
            return _flatNeumorphicContainer(width, height, stylesheet, innerComponents);
        },
        concaveNeumorphicContainer: function (width, height, stylesheet={}, innerComponents=[]) {
            return _concaveNeumorphicContainer(width, height, stylesheet, innerComponents);
        },
        convexNeumorphicContainer: function (width, height, stylesheet={}, innerComponents=[]) {
            return _convexNeumorphicContainer(width, height, stylesheet, innerComponents);
        },
        pressedNeumorphicContainer: function (width, height, stylesheet={}, innerComponents=[]) {
            return _pressedNeumorphicContainer(width, height, stylesheet, innerComponents);
        }
    }
}

/**
 * The framework expects the document to be laid out something like this:
 * 
 *      <!DOCTYPE html>
 *      <html>
 *          <head>
 *              <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
 *              <script type="module" src="../static/js/silicon-stream/init-v1.0.0.js"></script>
 *          </head>
 *          <body></body>
 *      </html>
 */

const everything = componentTemplate();
everything.assignElement('*');
everything.updateStyle({
    margin: '0',
    padding: '0',
    boxSizing: 'border-box'
});
everything.applyStyleTemplate('default');

const html = componentTemplate();
html.assignElement('html');
html.updateStyle({
    margin: '0',
    padding: '0'
});

const head = componentTemplate();
head.assignElement('head');

const body = componentTemplate();
body.assignElement('body');
body.updateStyle({
    margin: '0',
    padding: '0'
});

const header = componentTemplate();
header.assignNewElement('header');
header.updateStyle({
    width: '100vw',
    height: '100vh',
    position: 'fixed',
    margin: '0',
    padding: '0'
});


const content = componentTemplate();
content.assignNewElement('content');
content.updateStyle({
    width: '100vw',
    height: 'auto'
});

body.attach([header, content]);

function stream() {
    const Route = {
        HOME: 'HOME'
    }

    let _route = Route.HOME;

    function _update() {
        content.deleteInnerHTML();
        switch (_route) {
            case Route.HOME:
                _home();
                break
        }
        return true;
    }

    function _home() {
        body.attach([
            blueprints().column(
                '100%',
                '100vh',
                {}, [
                    blueprints().flatNeumorphicContainer(
                        '500px',
                        '100px',
                        {
                            margin: '100px'
                        }, [
                            blueprints().gradientButton(
                                '200px',
                                'auto',
                                'Join Us Today!'
                            ),
                            blueprints().button(
                                '200px',
                                'auto',
                                'Try This Now!'
                            )
                        ]
                    )
                ]
            )
        ]);
        return true;
    }

    return {
        update: () => _update()
    }
}

function server() {


    return {

    }
}

stream().update();