function wrapper() {
    
    

    function _sync(ops={
        url: undefined,
        interval: 1000
    }) {
        setInterval(() => {
            __get({
                url: ops.url,
                success: (response) => {
                    /// set content based on response
                }
            });
        }, ops.interval)
    }

    function __get(ops={
        url: undefined, 
        success:()=>{}, 
        error:()=>{}
    }) {
        return new Promise((resolve, reject) => {
            $.ajax({
                type: 'GET',
                url: ops.url,
                success: (response) => {
                    ops.success(response);
                    return response;
                },
                error: (error) => {
                    ops.error(error);
                    return error;
                }
            });
        });
    }

    function __post(ops={
        url: undefined,
        data: undefined,
        success:()=>{}, 
        error:()=>{}
    }) {
        return new Promise((resolve, reject) => {
            $.ajax({
                type: 'POST',
                url: ops.url,
                data: ops.data,
                success: (response) => {
                    ops.success(response);
                    return response;
                },
                error: (error) => {
                    ops.error(error);
                    return error;
                }
            });
        });
    }

    return {

    }
}



const pointer = new Pointer({
    onCreationSelectElement: true
});


function main() {
    class AjaxWrapper {

        /**
         * Makes an asynchronous GET request to the specified URL.
         * @param {string} url - The URL to make the GET request to.
         * @param {Function} callbackIfSuccessful - Callback function to be executed on successful response.
         * @param {Function} callbackIfError - Callback function to be executed on error response.
         * @returns {Promise} A Promise that resolves with the response data on success or rejects with an error on failure.
         * @method
         */
        get(url, callbackIfSuccessful=()=>{}, callbackIfError=()=>{}) {
            return new Promise((resolve, reject)=>{
                $.ajax({
                    type: "GET",
                    url: url,
                    success: (response)=>resolve(callbackIfSuccessful(response)),
                    error: (error)=>reject(callbackIfError(error))
                });
            });
        }

        /**
         * Makes an asynchronous POST request to the specified URL with the provided data.
         * @param {string} url - The URL to make the POST request to.
         * @param {Object} data - The data to be sent in the request body.
         * @param {Function} callbackIfSuccessful - Callback function to be executed on successful response.
         * @param {Function} callbackIfError - Callback function to be executed on error response.
         * @returns {Promise} A Promise that resolves with the response data on success or rejects with an error on failure.
         * @method
         */
        post(url, data, callbackIfSuccessful=()=>{}, callbackIfError=()=>{}) {
            return new Promise((resolve, reject)=>{
                $.ajax({
                    type: 'POST', 
                    url: url, 
                    data: data,
                    success: (response)=>resolve(callbackIfSuccessful(response)),
                    error: (error)=>reject(callbackIfError(error))
                });
            });     
        }
    }


    class Pointer {
        constructor(args={selected:document.querySelector('html'), lastSelected:args.selected, selectNewElement:false}) {
            this.selected = args.selected;
            this.lastSelected = this.selected;
            this.selectNewElement = true;
        }

        goto(args={element:undefined}) {
            this.lastSelected = this.selected;
            this.selected = document.querySelector(args.element);
        }

        add(args={element:undefined}) {
            let _newElement = document.createElement(_element);
            this.selected.appendChild(_newElement);
            this.goto(_newElement);
        }

        remove(args={element: undefined, position: 0}) {
            let _elementToBeRemoved = this.selected.querySelectorAll(args.element)[args.position];
            this.selected.removeChild(
                this.selected.querySelectorAll(args.element)
                    [args.position]
            );
        }
    }

    Pointer({
        selectNewElement: false
    });
    pointer.remove({
        element: 'div'
    });

    function pointer(_opcode={}) {
        let _selected = document.querySelector('html');
        let _lastSelected = document.querySelector('html');

        function _getTree() {
            function _parse(_node) {
                const object = {
                    tag: _node.tagName.toLowerCase(),
                    children: []
                };

                for (const childNode of _node.childNodes) {
                    if (childNode.nodeType === Node.ELEMENT_NODE) {
                        object.children.push(_parse(childNode));
                    }

                    else if (childNode.nodeType === Node.TEXT_NODE && childNode.nodeValue.trim() !== '') {
                        object.children.push({
                            text: childNode.nodeValue.trim()
                        });
                    }
                }

                return object;
            }

            const _root = document.documentElement;
            return _parse(_root);
        }

        function _goto(_elementOrClassName) {
            _lastSelected = _selected;

            try {
                _selected = document.querySelector(_elementOrClassName);
            }

            catch {
                _selected = document.querySelector('.' + _elementOrClassName);
            }

            return _selected;
        }

        function _push(_element) {
            _selected.appendChild(document.createElement(_element));
        }

        function _popElement(_element) {
            _selected.removeChild(_element);
        }

        function _popPosition(_position) {
            const children = _selected.children;
            
            if (_position >= 0 && _position < children.length) {
                return _selected.removeChild(children[_position]);
            }

            else {
                console.warn('INVALID_POSITION');
                return;
            }
        }
        
        function _rename(_name) {
            _selected.id = _name;
        }

        function _pushClass(_class) {
            _selected.classList.add(_class);
        }

        function _popClass(_class) {
            _selected.classList.remove(_class);
        }

        function _onEvent(_eventString, _callbackFunction) {
            _selected.addEventListener(_eventString, _callbackFunction);
        }

        function _onEventDelagateTo(_eventString, _selector, _callbackFunction) {
            _onEvent(_eventString, (_event) => {
                if (_event.target.matches(_selector)) {
                    _callbackFunction(_event);
                }
            });
        }

        function _onEnterView(_callbackFunction, _options={root:null, rootMargin:'0px', threshold:.5}) {

        }

        function _edit(_stylesheet) {
            Object.assign(_selected, _stylesheet);
        }

        return {
            selected: () => {
                return _selected;
            },
            lastSelected: () => {
                return _lastSelected;
            },
            getTree: () => {
                return _getTree();
            }
        }
    }

    const pointer = pointer();
    pointer.goto('html');
    pointer.edit({

    })
    pointer.onEvent({
        
    });

    class ElementWrapper {
        constructor() {
            this.element = null;
            this.stylesheet = {};
        }

        syncToElement(element) {
            this.element = document.querySelector(element);
        }

        syncToNewElement(element) {
            this.element = document.createElement(element);
        }

        syncToClass(class_) {
            this.element.classList.add(class_);
        }

        decoupleFromClass(class_) {
            this.element.classList.remove(class_);
        }

        editStyle(stylesheet) {
            Object.assign(this.element.style, stylesheet);
        }

        editStyleBlueprint(blueprint, stylesheet) {
            try {
                Object.assign(this.stylesheet[blueprint], stylesheet);
            }

            catch {
                this.stylesheet[blueprint] = stylesheet;
            }
        }

        applyStyleBlueprint(blueprint) {
            try {
                this.editStyle(this.stylesheet[blueprint]);
            }

            catch {
                this.editStyle({});
            }
        }

        resetStyle() {
            this.editStyle({all: "revert"});
        }

        resetStyleBlueprint(blueprint) {
            this.stylesheet[blueprint] = {};
        }

        resetAndApplyStyleBlueprint(blueprint) {
            this.resetStyle();
            this.applyStyleBlueprint(blueprint);
        }

        inject(elementWrappers=[]) {
            if (elementWrappers.length === 0) {
                console.warn("ElementWrapper: empty array given");
                return;
            }

            for (let i = 0; i < elementWrappers.length; i++) {
                try {
                    this.element.appendChild(elementWrappers[i].element);
                }
                
                catch {
                    this.syncToClass(elementWrappers[i]);
                }
            }
        }

        onEvent(event, callback) {
            this.element.addEventListener(event, callback);
        }

        onEventDelagateTo(event, selector, callback) {
            this.element.addEventListener(event, (e) => {
                if (e.target.matches(selector)) {
                    callback(e);
                }
            });
        }

        onEnterView(callback, options={root:null,rootMargin:"0px",threshold:.5}) {
            const observer = new IntersectionObserver((entries, observer) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting)
                    {
                        callback();
                        observer.unobserve(entry.target);
                    }
                });
            }, options);

            observer.observe(this.element);
        }

        editInnerHTML(source) {
            this.element.innerHTML = source;
        }

        injectInnerHTML(source) {
            this.element.innerHTML += source;
        }

        deleteInnerHTML() {
            this.element.innerHTML = "";
        }

        editContent(string) {
            this.element.textContent = string;
        }

        injectContent(string){
            this.element.textContent += string;
        }

        deleteContent() {
            this.element.textContent = "";
        }
    }

    /// ==========
    /// ANIMATIONS
    /// ==========

    class IncrementalValueGenerator {
        constructor() {
            this.value = 0;
        }

        generate() {
            const value = this.value;
            this._incrementValue();
            return value;
        }

        _incrementValue(number=1) {
            this.value += number;
        }
    }

    const delay = new IncrementalValueGenerator();

    function introAnimation(timestamp, element) {
        let animation = {
            delay: undefined,
            progress: 0
        }

        animation.delay = delay.generate();

        function step(timestamp) {
            animation.progress = ((timestamp - startTime) / duration);
            element.editStyle({
                opacity: animation.progress
            });
            
            if (progress < 1) {
                requestAnimationFrame(step);
            }
        }

        const duration = 2000;
        let startTime;
        requestAnimationFrame(step);
    }

    /// ==========
    /// COMPONENTS
    /// ==========

    class Container extends ElementWrapper {
        constructor() {
            super();
        }

        setDefaultWidth(width) {
            this.editStyleBlueprint("default", {width: width});
        }

        fillDefaultWidth() {
            this.editStyleBlueprint("default", {width: "100%"});
        }

        fillWidthDirectly() {
            this.editStyle({width: "100%"});
        }

        setWidthDirectly(width) {
            this.editStyle({width: width});
        }

        setDefaultHeight(height) {
            this.editStyleBlueprint("default", {height: height});
        }

        setHeightDirectly(height) {
            this.editStyle({height: height});
        }

        fillDefaultHeight() {
            this.editStyleBlueprint("default", {height: "100%"});
        }

        fillHeightDirectly() {
            this.editStyle({height: "100%"});
        }
    }

    function container(stylesheet={}, inner=[]) {
        const container = new Container();
        container.syncToNewElement("div");
        container.editStyleBlueprint("default", stylesheet);
        container.inject(inner);
        return container;
    }

    class Column extends Container {
        constructor(width, height, stylesheet={}, innerElements=[]) {
            super();
            this.syncToNewElement("div");
            this.editStyleBlueprint(
                "default", {
                    width: width,
                    height: height,
                    display: "flex",
                    flexDirection: "column",
                    justifyContent: "center",
                    alignItems: "center"
                }
            );
            this.editStyleBlueprint("default", stylesheet);
            this.applyStyleBlueprint("default");
            this.inject(innerElements);
        }
    }

    function column(width, height, stylesheet={}, inner=[]) {
        return new Column(width, height, stylesheet, inner);
    }

    class Row extends Container {
        constructor(width, height, stylesheet={}, innerElements=[]) {
            super();
            this.syncToNewElement("div");
            this.editStyleBlueprint(
                "default", {
                    width: width,
                    height: height,
                    display: "flex",
                    flexDirection: "row",
                    justifyContent: "center",
                    alignItems: "center"
                }
            );
            this.editStyleBlueprint("default", stylesheet);
            this.applyStyleBlueprint("default");
            this.inject(innerElements);
        }
    }

    function row(width, height, stylesheet={}, inner=[]) {
        return new Row(width, height, stylesheet, inner);
    }

    class NeumorphicContainer extends Container {
        constructor(width, height, stylesheet={}, innerElements=[]) {
            super();
            this.syncToNewElement("div");
            this.editStyleBlueprint(
                "default", {
                    width: width,
                    height: height,
                    background: "#ffffff",
                    boxShadow: "20px 20px 60px #d9d9d9, -20px -20px 60px #ffffff",
                    display: "flex",
                    flexDirection: "column",
                    justifyContent: "center",
                    alignItems: "center"
                }
            );
            this.editStyleBlueprint("default", stylesheet);
            this.inject(innerElements);
        }
    }

    class FlatNeumorphicContainer extends NeumorphicContainer {
        constructor(width, height, stylesheet={}, innerElements=[]) {
            super(width, height, {}, innerElements);
            this.editStyleBlueprint(
                "default", {
                    background: "#ffffff"
                }
            );
            this.editStyleBlueprint("default", stylesheet);
            this.applyStyleBlueprint("default");
        }
    }

    function flatNeumorphicContainer(width, height, stylesheet={}, inner=[]) {
        return new FlatNeumorphicContainer(width, height, stylesheet, inner);
    }

    class ConcaveNeumorphicContainer extends NeumorphicContainer {
        constructor(width, height, stylesheet={}, innerElements=[]) {
            super(width, height, {}, innerElements);
            this.editStyleBlueprint(
                "default", {
                    background: "linear-gradient(145deg, #e6e6e6, #ffffff)"
                }
            );
            this.editStyleBlueprint("default", stylesheet);
            this.applyStyleBlueprint("default");
        }
    }

    function concaveNeumorphicContainer(width, height, stylesheet={}, inner=[]) {
        return new ConcaveNeumorphicContainer(width, height, stylesheet, inner);
    }

    class ConvexNeumorphicContainer extends NeumorphicContainer {
        constructor(width, height, stylesheet={}, innerElements=[]) {
            super(width, height, {}, innerElements);
            this.editStyleBlueprint(
                "default", {
                    background: "linear-gradient(145deg, #ffffff, #e6e6e6)"
                }
            );
            this.editStyleBlueprint("default", stylesheet);
            this.applyStyleBlueprint("default");
        }
    }

    function convexNeumorphicContainer(width, height, stylesheet={}, inner=[]) {
        return new ConvexNeumorphicContainer(width, height, stylesheet, inner);
    }

    class PressedNeumorphicContainer extends NeumorphicContainer {
        constructor(width, height, stylesheet={}, innerElements=[]) {
            super(width, height, {}, innerElements);
            this.editStyleBlueprint(
                "default", {
                    background: "inset 20px 20px 60px #d9d9d9, inset -20px -20px 60px #ffffff",
                    boxShadow: "none"
                }
            );
            this.editStyleBlueprint("default", stylesheet);
            this.applyStyleBlueprint("default");
        }
    }

    function pressedNeumorphicContainer(width, height, stylesheet={}, inner=[]) {
        return new PressedNeumorphicContainer(width, height, stylesheet, inner);
    }

    class Button extends ElementWrapper {
        constructor(width, height, content="", stylesheet={}, innerElements=[]) {
            super();
            this.syncToNewElement("div");
            this.editContent(content);
            this.editStyleBlueprint(
                "default", {
                    alignItems: "center",
                    appearance: "none",
                    backgroundColor: "#FCFCFD",
                    borderRadius: "4px",
                    borderWidth: "0",
                    boxShadow: "rgba(45, 35, 66, .4) 0 2px, rgba(45, 35, 66, .3) 0 7px 13px -3px, #D6D6E7 0 -3px 0 inset",
                    boxSizing: "border-box",
                    color: "#36385A",
                    cursor: "pointer",
                    display: "inline-flex",
                    fontFamily: "'JetBrains Mono', monospace",
                    width: width,
                    height: height,
                    justifyContent: "center",
                    lineHeight: "1",
                    listStyle: "none",
                    overflow: "hidden",
                    paddingLeft: "16px",
                    paddingRight: "16px",
                    position: "relative",
                    textAlign: "left",
                    textDecoration: "none",
                    transition: "box-shadow .15s, transform .15s",
                    userSelect: "none",
                    webkitUserSelect: "none",
                    touchAction: "manipulation",
                    whiteSpace: "nowrap",
                    willChange: "box-shadow, transform",
                    fontSize: "18px",
                    padding: "10px",
                    transform: "translateY(0px)"
                }
            );
            this.editStyleBlueprint("default", stylesheet);
            this.editStyleBlueprint(
                "focus", {
                    boxShadow: "#D6D6E7 0 0 0 1.5px inset, rgba(45, 35, 66, .4) 0 2px 4px, rgba(45, 35, 66, .3) 0 7px 13px -3px, #D6D6E7 0 -3px 0 inset"
                }
            );
            this.editStyleBlueprint(
                "hover", {
                    boxShadow: "rgba(45, 35, 66, .4) 0 4px 8px, rgba(45, 35, 66, .3) 0 7px 13px -3px, #D6D6E7 0 -3px 0 inset",
                    transform: "translateY(-2px)"
                }
            );
            this.editStyleBlueprint(
                "active", {
                    boxShadow: "#D6D6E7 0 3px 7px inset",
                    transform: "translate(2px)"
                }
            );
            this.applyStyleBlueprint("default");
            this.onEvent("mouseenter", () => {
                this.applyStyleBlueprint("hover");
                this.applyStyleBlueprint("focus");
            });
            this.onEvent("mouseleave", () => {
                this.applyStyleBlueprint("default");
            });
            this.onEvent("mousedown", () => {
                this.applyStyleBlueprint("active");
            });
            this.onEvent("mouseup", () => {
                this.applyStyleBlueprint("hover");
                this.applyStyleBlueprint("focus");
            });
            this.onEnterView(() => introAnimation);
            this.inject(innerElements);
        }
    }

    function button(width, height, content="", stylesheet={}, inner=[]) {
        return new Button(width, height, content, stylesheet, inner);
    }

    class ColoredButton extends Button { /// issues with color parameters
        constructor(width, height, content="", color1="#705aff", color2="d454ff", stylesheet={}, innerElements=[]) {
            super(width, height, content, {}, innerElements);
            this.editStyleBlueprint(
                "default", {
                    background: `radial-gradient(100% 100% at 100% 0, #705aff 0, #d454ff 100%)`,
                    border: "0",
                    boxShadow: "rgba(45, 35, 66, .4) 0 2px 4px, rgba(45, 35, 66, .3) 0 7px 13px -3px, rgba(58, 65, 111, .5) 0 -3px 0 inset",
                    color: "#fff"
                }
            );
            this.editStyleBlueprint("default", stylesheet);
            this.editStyleBlueprint(
                "focus", {
                    boxShadow: "#3c4fe0 0 0 0 1.5px inset, rgba(45, 35, 66, .4) 0 2px 4px, rgba(45, 35, 66, .3) 0 7px 13px -3px, #3c4fe0 0 -3px 0 inset"
                }
            );
            this.editStyleBlueprint(
                "hover", {
                    boxShadow: "rgba(45, 35, 66, .4) 0 4px 8px, rgba(45, 35, 66, .3) 0 7px 13px -3px, #3c4fe0 0 -3px 0 inset",
                    transform: "translateY(-2px)"
                }
            );
            this.editStyleBlueprint(
                "active", {
                    boxShadow: "#3c4fe0 0 3px 7px inset",
                    transform: "translateY(2px)"
                }
            );
            this.applyStyleBlueprint("default");
        }
    }

    function coloredButton(width, height, content="", stylesheet={}, inner=[], color1="#705aff", color2="d454ff") {
        return new ColoredButton(width, height, content, color1, color2, stylesheet, inner);
    }

    

    /// ==============
    /// INITIAL SET UP
    /// ==============

    const everything = new ElementWrapper(); everything.syncToElement("*");
    everything.editStyleBlueprint(
        "default", {
            margin: 0,
            padding: 0
        }
    )
    everything.applyStyleBlueprint("default");

    const html = new ElementWrapper(); 
    html.syncToElement("html");
    const head = new ElementWrapper(); 
    head.syncToElement("head");
    const body = new ElementWrapper(); 
    body.syncToElement("body");
    body.editStyleBlueprint(
        "default", {
            margin: 0,
            padding: 0,
            width: "100vw",
            height: "auto"
        }
    )
    body.applyStyleBlueprint("default");

    const header = new ElementWrapper(); 
    header.syncToNewElement("header");
    header.editStyleBlueprint(
        "default", {
            width: "100vw",
            height: "100vh",
            mouseEvents: "none",
            position: "fixed"
        }
    );
    header.applyStyleBlueprint("default");

    const content = new ElementWrapper();
    content.syncToNewElement("content");
    content.editStyleBlueprint(
        "default", {
            width: "100%",
            height: "auto",
            position: "absolute",
            display: "flex",
            flexDirection: "column"
        }
    );

    content.applyStyleBlueprint("default");

    body.inject([header, content]);

    const ROUTE = {
        HOME: 0,
        ABOUT: 1
    }

    /// ====
    /// MAIN
    /// ====

    function config(route) {
        switch (route) {
            case ROUTE.HOME:
                const element = ElementWrapper();
                content.inject()
                break
            case ROUTE.ABOUT:
                break
        }
    }

    config(ROUTE.HOME);
}

main();