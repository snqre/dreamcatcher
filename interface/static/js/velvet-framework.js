class WrappedElement {
  constructor() {
    this.runtimeMemory = {
      element: null
    }
  }

  element() {
    return this.runtimeMemory.element;
  }

  syncToElement(selector, position=0) {
    this.runtimeMemory.element = document.querySelectorAll(selector)[position];
    return this;
  }

  syncToNewElement(tag) {
    this.runtimeMemory.element = document.createElement(tag);
    return this;
  }

  syncToClassName(className) {
    this.runtimeMemory.element.classList.add(className);
    return this;
  }

  on(trigger, logic) {
    this.runtimeMemory.element.addEventListener(trigger, logic);
    return this;
  }

  onViewEnter(
    logic,
    options={
      root: null,
      rootMargin: '0px',
      threshold: .5
    }
  ) {
    let observer = new IntersectionObserver((entries, observer) => {
      entries.forEach(entry => {
          if (entry.isIntersecting) {
              logic();
              observer.unobserve(entry.target);
          }
      })
    }, options);
    observer.observe(this.runtimeMemory.element);
    return this;
  }

  onRepeat(logic, wait) {
    setInterval(logic, wait);
    return this;
  }

  setContent(content) {
    this.runtimeMemory.element.textContent = content;
    return this;
  }

  render(stylesheet={}) {
    Object.assign(this.runtimeMemory.element.style, stylesheet);
    return this;
  }

  setInnerHTML(source) {
    this.runtimeMemory.innerHTML = source;
    return this;
  }

  inject(wrappedElements) {
    if (wrappedElements.length === 0) {
      return this;
    }
    for (let i = 0; i < wrappedElements.length; i++) {
      let wrappedElement = wrappedElements[i];
      this.runtimeMemory.element.appendChild(wrappedElement.element());
    }
    return this;
  }
}

class Template {
  staticAny({element = 'div', content = '', stylesheet = {}, innerWrappedElements = []}) {
    let wrappedElement = new WrappedElement();
    return wrappedElement
        .syncToNewElement(element)
        .setContent(content)
        .setStyle(stylesheet)
        .inject(innerWrappedElements);
  }

  staticColumn({element = 'div', width = 'auto', heigth = 'auto', stylesheet = {}, innerWrappedElements = []}) {
    let wrappedElement = new WrappedElement();
    return wrappedElement
      .syncToNewElement(element)
      .setStyle({
        width: width,
        heigth: heigth,
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'center',
        alignItems: 'center'
      })
      .setStyle(stylesheet)
      .inject(innerWrappedElements);
  }

  staticRow({element = 'div', width = 'auto', heigth = 'auto', stylesheet = {}, innerWrappedElements = []}) {
    let wrappedElement = new WrappedElement();
    return wrappedElement
      .syncToNewElement(element)
      .setStyle({
        width: width,
        heigth: heigth,
        display: 'flex',
        flexDirection: 'row',
        justifyContent: 'center',
        alignItems: 'center'
      })
      .setStyle(stylesheet)
      .inject(innerWrappedElements);
  }

  staticSection({stylesheet = {}, innerWrappedElements = []}) {
    let wrappedElement = new WrappedElement();
    return wrappedElement
      .syncToNewElement(element)
      .setStyle({
        width: '100%',
        height: '100vh',
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'center',
        alignItems: 'center'
      })
      .setStyle(stylesheet)
      .inject(innerWrappedElements);
  }

  shortStaticSection({stylesheet = {}, innerWrappedElements = []}) {
    let wrappedElement = new WrappedElement();
    return wrappedElement
      .syncToNewElement('section')
      .setStyle({
        width: '100%',
        height: '90vh',
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'center',
        alignItems: 'center'
      })
      .setStyle(stylesheet)
      .inject(innerWrappedElements);
  }

  staticText({element = 'div', content = '', stylesheet = {}, innerWrappedElements = []}) {
    let wrappedElement = new WrappedElement();
    return wrappedElement
      .syncToNewElement(element)
      .setContent(content)
      .setStyle(stylesheet)
      .inject(innerWrappedElements);
  }

  clickableText({element = 'div', logicOnClick = () => {}, content = '', stylesheet = {}, innerWrappedElements = []}) {
    let wrappedElement = new WrappedElement();
    return wrappedElement
      .syncToNewElement(element)
      .setContent(content)
      .setStyle(stylesheet)
      .on('click', logicOnClick)
      .inject(innerWrappedElements);
  }

  staticImage({url, stylesheet = {}, innerWrappedElements = []}) {
    let wrappedElement = new WrappedElement();
    return wrappedElement
      .syncToNewElement('img')
      .setStyle(stylesheet)
      .inject(innerWrappedElements)
      .element()
        .src = url;
  }

  clickableImage({url, logicOnClick = () => {}, stylesheet = {}, innerWrappedElements = []}) {
    let wrappedElement = new WrappedElement();
    return wrappedElement
      .syncToNewElement('img')
      .setStyle(stylesheet)
      .on('click', logicOnClick)
      .inject(innerWrappedElements)
      .element()
        .src = url;
  }

  whiteNeumorphicFlatButton({element = 'div', content = '', width = 'auto', heigth = 'auto', logicOnClick = () => {}, innerWrappedElements = []}) {
    let wrappedElement = new WrappedElement();
    let defaultStateStyle = {
      width: width,
      height: heigth,
      alignItems: 'center',
      appearance: 'none',
      backgroundColor: '#FCFCFD',
      borderRadius: '4px',
      borderWidth: '0',
      boxShadow:
        'rgba(45, 35, 66, 0.4) 0 2px 4px,rgba(45, 35, 66, 0.3) 0 7px 13px -3px,#D6D6E7 0 -3px 0 inset',
      boxSizing: 'border-box',
      color: '#36395A',
      cursor: 'pointer',
      display: 'inline-flex',
      justifyContent: 'center',
      lineHeight: '1',
      listStyle: 'none',
      overflow: 'hidden',
      paddingLeft: '16px',
      paddingRight: '16px',
      position: 'relative',
      textAlign: 'left',
      textDecoration: 'none',
      transition:
        'box-shadow .15s, transform .15s',
      userSelect: 'none',
      webkitUserSelect: 'none',
      touchAction: 'manipulation',
      whiteSpace: 'nowrap',
      willChange:
        'box-shadow, transform',
      fontSize: '18px',
      transform: 'translate(0px)'
    };
    let focusedStateStyle = {
      boxShadow: 
        '#D6D6E7 0 0 0 1.5px inset, rgba(45, 35, 66, 0.4) 0 2px 4px, rgba(45, 35, 66, 0.3) 0 7px 13px -3px, #D6D6E7 0 -3px 0 inset'
    };
    let hoveredStateStyle = {
      boxShadow: 
        'rgba(45, 35, 66, 0.4) 0 4px 8px, rgba(45, 35, 66, 0.3) 0 7px 13px -3px, #D6D6E7 0 -3px 0 inset',
      transform: 'translate(-2px)'
    };
    let activeStateStyle = {
      boxShadow: '#D6D6E7 0 3px 7px inset',
      transform: 'translateY(2px)'
    };
    return wrappedElement
      .syncToNewElement(element)
      .setContent(content)
      .setStyle(defaultStateStyle)
      .on('mouseenter', () => {
        this
          .setStyle(hoveredStateStyle)
          .setStyle(focusedStateStyle);
      })
      .on('mouseleave', () => {
        this
          .setStyle(defaultStateStyle);
      })
      .on('mousedown', () => {
        this
          .setStyle(activeStateStyle);
      })
      .on('mouseup', () => {
        this
          .setStyle(hoveredStateStyle)
          .setStyle(focusedStateStyle);
      })
      .on('click', logicOnClick)
      .inject(innerWrappedElements);
  }

  neumorphicGradientButton({element = 'div', content = '', width = 'auto', heigth = 'auto', logicOnClick = () => {}, innerWrappedElements = []}) {
    let wrappedElement = new WrappedElement();
    let defaultStateStyle = {
      width: width,
      height: heigth,
      alignItems: 'center',
      appearance: 'none',
      backgroundImage:
        'radial-gradient(100% 100% at 100% 0, #705aff 0, #d454ff 100%)',
      border: '0',
      borderRadius: '6px',
      boxShadow:
        'rgba(45, 35, 66, .4) 0 2px 4px,rgba(45, 35, 66, .3) 0 7px 13px -3px,rgba(58, 65, 111, .5) 0 -3px 0 inset',
      boxSizing: 'border-box',
      color: '#FFF',
      cursor: 'pointer',
      display: 'inline-flex',
      justifyContent: 'center',
      lineHeight: '1',
      overflow: 'hidden',
      paddingLeft: '16px',
      paddingRight: '16px',
      position: 'relative',
      textAlign: 'left',
      textDecoration: 'none',
      transition:
        'box-shadow .15s, transform .15s',
      userSelect: 'none',
      webkitUserSelect: 'none',
      touchAction: 'manipulation',
      whiteSpace: 'nowrap',
      willChange:
        'box-shadow, transform',
      fontSize: '18px',
      transform: 'translate(0px)'
    };
    let focusedStateStyle = {
      boxShadow:
        '#3c4fe0 0 0 0 1.5px inset, rgba(45, 35, 66, .4) 0 2px 4px, rgba(45, 35, 66, .3) 0 7px 13px -3px, #3c4fe0 0 -3px 0 inset'
    };
    let hoveredStateStyle = {
      boxShadow:
        'rgba(45, 35, 66, .4) 0 4px 8px, rgba(45, 35, 66, .3) 0 7px 13px -3px, #3c4fe0 0 -3px 0 inset',
      transform: 'translateY(-2px)'
    };
    let activeStateStyle = {
      boxShadow: '#3c4fe0 0 3px 7px inset',
      transform: 'translateY(2px)'
    };
    return wrappedElement
      .syncToNewElement(element)
      .setContent(content)
      .setStyle(defaultStateStyle)
      .on('mouseenter', () => {
        this
          .setStyle(hoveredStateStyle)
          .setStyle(focusedStateStyle);
      })
      .on('mouseleave', () => {
        this
          .setStyle(defaultStateStyle);
      })
      .on('mousedown', () => {
        this
          .setStyle(activeStateStyle);
      })
      .on('mouseup', () => {
        this
          .setStyle(hoveredStateStyle)
          .setStyle(focusedStateStyle);
      })
      .on('click', logicOnClick)
      .inject(innerWrappedElements);
  }
}

class Velvet {
  constructor() {
    this.runtimeMemory = {
      routes: [],
      template: {
        staticAny: (
          element='div',
          content='',
          stylesheet={},
          innerWrappedElements=[]
        ) => {
          return new WrappedElement()
            .syncToNewElement(element)
            .setContent(content)
            .render(stylesheet)
            .inject(innerWrappedElements);
        },
        staticColumn: (
          element='div',
          width='auto',
          height='auto',
          stylesheet={},
          innerWrappedElements=[] 
        ) => {
          return new WrappedElement()
            .syncToNewElement(element)
            .render({
              
            })
        }
      },
      elements: {
        everything: new WrappedElement()
          .syncToElement('*')
          .render({
            margin: '0',
            padding: '0'
          }),
        html: new WrappedElement()
          .syncToElement('html')
          .render({
            margin: '0',
            padding: '0'
          }),
        head: new WrappedElement()
          .syncToElement('head'),
        body: new WrappedElement()
          .syncToElement('body')
          .render({
            margin: '0',
            padding: '0',
            width: '100vw',
            height: 'auto'
          }),
        header: new WrappedElement()
          .syncToElement('header')
          .render({
            margin: '0',
            padding: '0',
            position: 'fixed',
            width: '100vw',
            height: '100vh',
            pointerEvents: 'none',
            zIndex: '100'
          }),
        content: new WrappedElement()
          .syncToElement('content')
          .render({
            position: 'absolute',
            width: '100%',
            height: 'auto',
            display: 'flex',
            flexDirection: 'column'
          })
      }
    }
  }

  everything() {
    return this
      .runtimeMemory
      .elements
      .everything;
  }

  html() {
    return this
      .runtimeMemory
      .elements
      .html;
  }

  head() {
    return this
      .runtimeMemory
      .elements
      .head;
  }

  body() {
    return this
      .runtimeMemory
      .elements
      .body;
  }

  header() {
    return this
      .runtimeMemory
      .elements
      .header;
  }

  content() {
    return this
      .runtimeMemory
      .elements
      .content;
  }

  generateWrappedElement() {
    return new WrappedElement();
  }

  clearHeader() {
    this
      .runtimeMemory
      .elements
      .header
      .setInnerHTML('');
    return this;
  }

  clearContent() {
    this
      .runtimeMemory
      .elements
      .content
      .setInnerHTML('');
    return this;
  }

  pushRoute(
    logic
  ) {
    this
      .runtimeMemory
      .routes
      .push(
        logic
      );
    return this;
  }

  popRoute(
    logic
  ) {
    this
      .runtimeMemory
      .routes
      .splice(
        this
          .runtimeMemory
          .routes
          .indexOf(
            logic
          ),
        1
      );
    return this;
  }

  goto(
    route
  ) {
    this
      .clearHeader()
      .clearContent()
      .runtimeMemory
        .routes[route]();
    return this;
  }
}