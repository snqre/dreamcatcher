class ComponentDisk {
    constructor() {
        this
            ._element = null
            ._stylesheet = {};
    }

    element() {
        return this._element;
    }

    stylesheet() {
        return this._stylesheet;
    }

    setElement(element) {
        this._element = element;
        return;
    }

    setStylesheet(stylesheet={}) {
        this._stylesheet = stylesheet;
        return;
    }
}

class Component {
    constructor(disk=new ComponentDisk()) {
        this._disk = disk;
    }

    disk() {
        return this._disk;
    }

    element() {
        return this
            .disk()
            .element();
    }

    stylesheet() {
        return this
            .disk()
            .stylesheet()
    }

    syncToElement(selector, position=0) {
        this
            .disk()
            .setElement(document.querySelectorAll(selector)[position]);
        return;
    }

    syncToNewElement(tag) {
        this
            .disk()
            .setElement(document.createElement(tag));
        return;
    }

    assignClassName(className) {
        this
            .disk()
            .element()
            .classList
            .add(className);
        return;
    }

    unassignClassName(className) {
        this
            .disk()
            .element()
            .classList
            .remove(className);
        return;
    }

    on(trigger, callback) {
        this
            .disk()
            .element()
            .addEventListener(trigger, callback);
        return;
    }

    onEnterView({
        callback,
        options={
            root: null,
            rootMargin: '0px',
            threshold: .5
        }
    }) {
        let observer = new IntersectionObserver((entries, observer) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    callback();
                    observer.unobserve(entry.target);
                }
            })
        }, options);
        observer.observe(
            this
                .disk()
                .element()
        );
        return;
    }

    onRepeat(callback, wait) {
        setInterval(callback, wait);
        return;
    }

    setContent(content) {
        this
            .disk()
            .element()
            .textContent 
        = content;
        return;
    }

    injectContent(content) {
        this
            .disk()
            .element()
            .textContent 
        += content;
        return;
    }

    injectStyle(stylesheet={}) {
        Object.assign(
            this
                .disk()
                .element()
                .style,
            stylesheet
        );
        return;
    }

    setStyleTemplate(template, stylesheet={}) {
        this
            .disk()
            .stylesheet()
                [template] 
            = stylesheet;
        return;
    }

    injectStyleTemplate(template, stylesheet={}) {
        Object.assign(this._stylesheet[template], stylesheet);
        return;
    }

    applyStyleTemplate(template) {
        this.injectStyle(this._stylesheet[template]);
        return;
    }

    setInnerHTML(sourceCode) {
        this._element.innerHTML = sourceCode;
        return;
    }

    injectInnerHTML(sourceCode) {
        this._element.innerHTML += sourceCode;
        return
    }

    inject(components) {
        if (components.length === 0) {
            return;
        }
        for (let i = 0; i < components.length; i++) {
            this._element.appendChild(components[i].element);
        }
        return;
    }
}

class Template {
    staticGeneric({
        content='',
        element='div',
        stylesheet={},
        components=[],
        className=''
    }) {
        return new Component()
            .syncToNewElement(element)
            .assignClassName(className)
            .injectContent(content)
            .injectStyle(stylesheet)
            .inject(components);
    }

    staticColumn({
        element='div',
        components=[],
        className='',
        stylesheet={}
    }) {
        return new Component()
            .syncToNewElement(element)
            .assignClassName(className)
            .injectStyle({
                width: '100%',
                height: '100%',
                display: 'flex',
                flexDirection: 'column',
                justifyContent: 'center',
                alignItems: 'center'
            })
            .injectStyle(stylesheet)
            .inject(components);
    }

    staticRow({
        element='div',
        components=[],
        className='',
        stylesheet={}
    }) {
        return new Component()
            .syncToNewElement(element)
            .assignClassName(className)
            .injectStyle({
                width: '100%',
                height: '100%',
                display: 'flex',
                flexDirection: 'row',
                justifyContent: 'center',
                alignItems: 'center'
            })
            .injectStyle(stylesheet)
            .inject(components)
    }

    staticContent({
        element='div',
        content='',
        components=[],
        className='',
        stylesheet={}
    }) {
        return new Component()
            .syncToNewElement(element)
            .assignClassName(className)
            .injectContent(content)
            .injectStyle(stylesheet)
            .inject(components)
    }

    dynamicContent({
        element='div',
        content='',
        url,
        wait=1000,
        components=[],
        className='',
        stylesheet={}
    }) {
        return new Component()
            .syncToNewElement(element)
            .assignClassName(className)
            .injectContent(content)
            .onRepeat(() => {
                $.ajax({
                    url: url,
                    method: 'GET',
                    success: (response) => {
                        this.setContent(response);
                    },
                    error: (xhr, status, error) => {
                        console.error('unable to update content due to an error', status, error);
                    }
                });
            }, wait)
            .injectStyle(stylesheet)
            .inject(components)
    }

    staticImage({
        url,
        components=[],
        className='',
        stylesheet={}
    }) {
        return new Component()
            .syncToNewElement('img')
            .assignClassName(className)
            .injectStyle(stylesheet)
            .inject(components)
            .element()
                .src = url
    }

    dynamicImage({
        url,
        src='',
        wait=1000,
        components=[],
        className='',
        stylesheet={}
    }) {
        return _ = new Component()
            .syncToNewElement('img')
            .assignClassName(className)
            .onRepeat(() => {
                $.ajax({
                    url: url,
                    method: 'GET',
                    success: (response) => {
                        _
                            .element()
                                .src = response;
                    },
                    error: (xhr, status, error) => {
                        console.error('unable to update image src due to error', status, error);
                    }
                });
            }, wait)
            .injectStyle(stylesheet)
            .inject(components)
            .element()
                .src = src;
    }

    submitInput({
        element='div',
        url,
        components=[],
        className='',
        stylesheet={},
        callbackOnResponse=(response)=>{}
    }) {
        return _ = new Component()
            .syncToNewElement(element)
            .assignClassName(className)
            .on('keypress', (event) => {
                if (event.which === 13) {
                    $.ajax({
                        url: url,
                        method: 'POST',
                        data: {
                            input: 
                                _
                                    .element()
                                    .val()
                        },
                        success: (response) => {
                            callbackOnResponse(response);
                        },
                        error: (xhr, status, error) => {
                            console.error('unable to post to server due to an error', status, error);
                        }
                    });
                    _
                        .element()
                        .val('')
                }
            })
            .injectStyle(stylesheet)
            .inject(components)
    }

    whiteNeuButton({
        element='div',
        content='',
        components=[],
        className='',
        stylesheet={},
        callbackOnTrigger=()=>{}
    }) {
        return _ = new Component()
            .syncToNewElement(element)
            .assignClassName(className)
            .injectContent(content)
            .injectStyle({
                width: 'auto',
                height: 'auto',
                alignItems: 'center',
                appearance: 'none',
                backgroundColor: '#FCFCFD',
                borderRadius: '4px',
                borderWidth: '0px',
                boxShadow: `
                    rgba(45, 35, 66, 0.4) 0 2px 4px,
                    rgba(45, 35, 66, 0.3) 0 7px 13px -3px,
                    #D6D6E7 0 -3px 0 inset
                `,
                color: '#36395A',
                cursor: 'pointer',
                display: 'inline-flex',
                fontFamily: '"JetBrains Mono", monospace',
                justifyContent: 'center',
                lineHeight: '1',
                listStyle: 'none',
                overflow: 'hidden',
                paddingLeft: '16px',
                paddingRight: '16px',
                position: 'relative',
                textAlign: 'left',
                textDecoration: 'none',
                transition: `
                    box-shadow .15s,
                    transform .15s
                `,
                userSelect: 'none',
                webkitUserSelect: 'none',
                touchAction: 'manipulation',
                whiteSpace: 'nowrap',
                willChange: `
                    box-shadow,
                    transform
                `,
                fontSize: '18px',
                transform: 'translateY(0px)'
            })
            .injectStyle(stylesheet)
            .on('mouseenter', () => {
                _
                    .injectStyle({
                        boxShadow: `
                            rgba(45, 35, 66, .4) 0 4px 8px,
                            rgba(45, 35, 66, .3) 0 7px 13px -3px,
                            #D6D6E7 0 -3px 0 inset
                        `,
                        transform: 'translateY(-2px)'
                    })
                    .injectStyle({
                        boxShadow: `
                            #D6D6E7 0 0 0 1.5px inset,
                            rgba(45, 35, 66, .4) 0 2px 4px,
                            rgba(45, 35, 66, .3) 0 7px 13px -3,
                            #D6D6E7 0 -3px 0 inset
                        `
                    });
            })
            .on('mouseleave', () => {
                _
                    .injectStyle({
                        width: 'auto',
                        height: 'auto',
                        alignItems: 'center',
                        appearance: 'none',
                        backgroundColor: '#FCFCFD',
                        borderRadius: '4px',
                        borderWidth: '0px',
                        boxShadow: `
                            rgba(45, 35, 66, 0.4) 0 2px 4px,
                            rgba(45, 35, 66, 0.3) 0 7px 13px -3px,
                            #D6D6E7 0 -3px 0 inset
                        `,
                        color: '#36395A',
                        cursor: 'pointer',
                        display: 'inline-flex',
                        fontFamily: '"JetBrains Mono", monospace',
                        justifyContent: 'center',
                        lineHeight: '1',
                        listStyle: 'none',
                        overflow: 'hidden',
                        paddingLeft: '16px',
                        paddingRight: '16px',
                        position: 'relative',
                        textAlign: 'left',
                        textDecoration: 'none',
                        transition: `
                            box-shadow .15s,
                            transform .15s
                        `,
                        userSelect: 'none',
                        webkitUserSelect: 'none',
                        touchAction: 'manipulation',
                        whiteSpace: 'nowrap',
                        willChange: `
                            box-shadow,
                            transform
                        `,
                        fontSize: '18px',
                        transform: 'translateY(0px)'
                    })
                    .injectStyle(stylesheet);
            })
            .on('mousedown', () => {
                _
                    .injectStyle({
                        boxShadow: '#D6D6E7 0 3px 7px inset',
                        transform: 'translateY(2px)'
                    });
            })
            .on('mouseup', () => {
                _
                    .injectStyle({
                        boxShadow: `
                            rgba(45, 35, 66, .4) 0 4px 8px,
                            rgba(45, 35, 66, .3) 0 7px 13px -3px,
                            #D6D6E7 0 -3px 0 inset
                        `,
                        transform: 'translateY(-2px)'
                    })
                    .injectStyle({
                        boxShadow: `
                            #D6D6E7 0 0 0 1.5px inset,
                            rgba(45, 35, 66, .4) 0 2px 4px,
                            rgba(45, 35, 66, .3) 0 7px 13px -3,
                            #D6D6E7 0 -3px 0 inset
                        `
                    });
            })
            .on('click', () => {
                callbackOnTrigger();
            })
            .inject(components)
    }

    purpleGradientNeuButton({
        element='div',
        content='',
        components=[],
        className='',
        stylesheet={},
        callbackOnTrigger=()=>{}
    }) {
        return _ = new Component()
            .syncToNewElement(element)
            .assignClassName(className)
            .injectContent(content)
            .injectStyle({
                width: 'auto',
                height: 'auto',
                alignItems: 'center',
                appearance: 'none',
                backgroundImage: `
                    radial-gradient(
                        100% 100% at 100% 0,
                        #705aff 0,
                        #d454ff 100%
                    )
                `,
                border: '0',
                borderRadius: '6px',
                boxShadow: `
                    rgba(45, 35, 66, .4) 0 2px 4px,
                    rgba(45, 35, 66, .3) 0 7px 13px -3px,
                    rgba(58, 65, 111, .5) 0 -3px 0 inset
                `,
                boxSizing: 'border-box',
                color: '#fff',
                cursor: 'pointer',
                display: 'inline-flex',
                fontFamily: '"JetBrains Mono", monospace',
                justifyContent: 'center',
                lineHeight: '1',
                overflow: 'hidden',
                paddingLeft: '16px',
                paddingRight: '16px',
                position: 'relative',
                textAlign: 'left',
                textDecoration: 'none',
                transition: `
                    box-shadow .15s,
                    transform .15s
                `,
                userSelect: 'none',
                webkitUserSelect: 'none',
                touchAction: 'manipulation',
                whiteSpace: 'nowrap',
                willChange: `
                    box-shadow,
                    transform
                `,
                fontSize: '18px',
                transform: 'translateY(0px)'
            })
            .on('mouseenter', () => {
                _
                    .injectStyle({
                        boxShadow: `
                            rgba(45, 35, 66, .4) 0 4px 8px,
                            rgba(45, 35, 66, .3) 0 7px 13px -3px,
                            #3c4fe0 0 -3px 0 inset
                        `,
                        transform: 'translateY(-2px)'
                    })
                    .injectStyle({
                        boxShadow: `
                            #3c4fe0 0 0 0 1.5px inset, rgba(45, 35, 66, .4) 0 2px 4px,
                            rgba(45, 35, 66, .3) 0 7px 13px -3px,
                            #3c4fe0 0 -3px 0 inset
                        `
                    });
            })
            .on('mouseleave', () => {
                _
                    .injectStyle({
                        width: 'auto',
                        height: 'auto',
                        alignItems: 'center',
                        appearance: 'none',
                        backgroundImage: `
                            radial-gradient(
                                100% 100% at 100% 0,
                                #705aff 0,
                                #d454ff 100%
                            )
                        `,
                        border: '0',
                        borderRadius: '6px',
                        boxShadow: `
                            rgba(45, 35, 66, .4) 0 2px 4px,
                            rgba(45, 35, 66, .3) 0 7px 13px -3px,
                            rgba(58, 65, 111, .5) 0 -3px 0 inset
                        `,
                        boxSizing: 'border-box',
                        color: '#fff',
                        cursor: 'pointer',
                        display: 'inline-flex',
                        fontFamily: '"JetBrains Mono", monospace',
                        justifyContent: 'center',
                        lineHeight: '1',
                        overflow: 'hidden',
                        paddingLeft: '16px',
                        paddingRight: '16px',
                        position: 'relative',
                        textAlign: 'left',
                        textDecoration: 'none',
                        transition: `
                            box-shadow .15s,
                            transform .15s
                        `,
                        userSelect: 'none',
                        webkitUserSelect: 'none',
                        touchAction: 'manipulation',
                        whiteSpace: 'nowrap',
                        willChange: `
                            box-shadow,
                            transform
                        `,
                        fontSize: '18px',
                        transform: 'translateY(0px)'
                    })
                    .injectStyle(stylesheet);
            })
            .on('mousedown', () => {
                _
                    .injectStyle({
                        boxShadow: '#3c4fe0 0 3px 7px inset',
                        transform: 'translateY(2px)'
                    });
            })
            .on('mouseup', () => {
                _
                    .injectStyle({
                        boxShadow: `
                            rgba(45, 35, 66, .4) 0 4px 8px,
                            rgba(45, 35, 66, .3) 0 7px 13px -3px,
                            #3c4fe0 0 -3px 0 inset
                        `,
                        transform: 'translateY(-2px)'
                    })
                    .injectStyle({
                        boxShadow: `
                            #3c4fe0 0 0 0 1.5px inset, rgba(45, 35, 66, .4) 0 2px 4px,
                            rgba(45, 35, 66, .3) 0 7px 13px -3px,
                            #3c4fe0 0 -3px 0 inset
                        `
                    });
            })
            .on('click', () => {
                callbackOnTrigger();
            })
            .inject(components);
    }
}

class Disk {
    constructor({
        headerSections=[],
        sections=[]
    }) {
        this._headerSections = headerSections;
        this._sections = sections;
    }

    headerSections() {
        return this._headerSections;
    }

    sections() {
        return this._sections;
    }

    pushHeaderSections(sections=[]) {
        this._headerSections.push(sections);
        return;
    }

    pushSections(sections=[]) {
        this._sections.push(sections);
        return;
    }
}

export default class Velvet {
    constructor() {
        this._everything = new Component()
            .syncToElement('*')
            .injectStyle({
                padding: '0',
                margin: '0'
            })
            .injectStyle(stylesheet.everything);

        this._html = new Component()
            .syncToElement('html')
            .injectStyle({
                padding: '0px',
                margin: '0px'
            })
            .injectStyle(stylesheet.html);

        this._head = new Component()
            .syncToElement('head')
            .injectStyle(stylesheet.head);

        this._body = new Component()
            .syncToElement('body')
            .injectStyle({
                padding: '0px',
                margin: '0px',
                width: '100vw',
                height: 'auto'
            })
            .injectStyle(stylesheet.body);

        this._header = new Component()
            .syncToElement('header')
            .injectStyle({
                padding: '0px',
                margin: '0px',
                position: 'fixed',
                width: '100vw',
                height: '100vh',
                pointerEvents: 'none',
                zIndex: '100'
            })
            .injectStyle(stylesheet.header);

        this._content = new Component()
            .syncToElement('content')
            .injectStyle({
                position: 'absolute',
                width: '100%',
                height: 'auto',
                display: 'flex',
                flexDirection: 'column'
            })
            .injectStyle(stylesheet.content);

        this._template = new Template();
    }

    template() {
        return this._template;
    }

    Disk() {
        return new Disk();
    }

    run(disk=new Disk()) {
        if (disk.headerSections().length !== 0) {
            this
                ._header
                .setInnerHTML('')
                .inject(disk.headerSections());
        }

        if (disk.sections().length !== 0) {
            this._content
                .setInnerHTML('')
                .inject(disk.sections());
        }

        return;
    }
}