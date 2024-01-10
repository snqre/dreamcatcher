/**
 * @typedef {Object} Component
 * @property {Function} element - Returns the created DOM element.
 * @property {Function} css - Returns the current CSS styles applied to the element.
 * @property {Function} syncToElement - Synchronizes the component to an existing DOM element.
 * @property {Function} syncToNewElement - Creates a new DOM element for the component.
 * @property {Function} onEvent - Attaches an event listener to the element.
 * @property {Function} onEnteringView - Triggers a callback when the element enters the view.
 * @property {Function} onEveryInterval - Executes a callback at regular intervals.
 * @property {Function} updateContent - Updates the content of the element.
 * @property {Function} updateStyle - Updates the CSS styles of the element.
 * @property {Function} updateStyleTemplate - Updates a specific style template of the element.
 * @property {Function} overrideStyleTemplate - Overrides a style template with new styles.
 * @property {Function} applyStyleTemplate - Applies a predefined style template to the element.
 * @property {Function} overrideInnerHTML - Overrides the inner HTML of the element.
 * @property {Function} inject - Injects an array of components into the element.
 */

/**
 * @typedef {Object} Template
 * @property {Function} any - Creates a generic component with content, styles, and child components.
 * @property {Function} column - Creates a column layout component with specified dimensions and styles.
 * @property {Function} row - Creates a row layout component with specified dimensions and styles.
 * @property {Function} text - Creates a text component with content, styles, and child components.
 * @property {Function} image - Creates an image component with a specified URL, styles, and child components.
 * @property {Function} button - Creates a button component with content, height, callback, and styles.
 * @property {Function} gradientButton - Creates a gradient button component with content, height, callback, and styles.
 * @property {Function} flatNeumorphicContainer - Creates a flat neumorphic container with dimensions, styles, and child components.
 * @property {Function} concaveNeumorphicContainer - Creates a concave neumorphic container with dimensions, styles, and child components.
 * @property {Function} convexNeumorphicContainer - Creates a convex neumorphic container with dimensions, styles, and child components.
 * @property {Function} pressedNeumorphicContainer - Creates a pressed neumorphic container with dimensions, styles, and child components.
 */

/**
 * @typedef {Object} Ajax
 * @property {Function} get - Performs a GET request to the specified URL.
 * @property {Function} post - Performs a POST request to the specified URL with the provided data.
 */

/**
 * @typedef {Object} Velvet
 * @property {Component} Component - Function for creating and manipulating DOM elements.
 * @property {Template} Template - Function providing pre-defined components.
 * @property {Ajax} Ajax - Function for handling asynchronous requests.
 * @property {boolean} initialized - Indicates whether the Velvet library has been initialized.
 * @property {Function} initialize - Initializes the Velvet library and logs initialization status.
 */

/**
 * The Velvet library encapsulates common functionalities for creating dynamic components,
 * templates, and handling asynchronous operations. It exports three main functions:
 * `Component`, `Template`, and `Ajax`, along with a boolean `initialized` flag and an `initialize` function.
 *
 * @namespace
 * @exports Velvet
 */
export default function Velvet() {
  /**
   * @function Component
   * @memberof Velvet
   * @returns {Component} - Component object with various methods for DOM manipulation.
   * @description
   * The `Component` function provides a way to create and manipulate DOM elements.
   * It includes methods such as `syncToElement`, `syncToNewElement`, `onEvent`, etc.
   */
  function Component() {
    let element;
    let css;

    /**
     * Synchronizes the component to an existing DOM element selected by the specified CSS selector.
     * Optionally, a specific position within the matched elements can be specified.
     *
     * @function syncToElement
     * @memberof Component
     * @param {string} selector - The CSS selector used to identify the target element(s).
     * @param {number} [position=0] - Optional. The position of the target element within the matched elements.
     *                                Defaults to the first element (position 0).
     * @throws {Error} Throws an error if the specified position is out of bounds.
     * @returns {void}
     * @description
     * This function queries the document for elements matching the given CSS selector and synchronizes
     * the component to the element at the specified position. The synchronized element becomes the target
     * for subsequent component operations. If the position is out of bounds, an error is thrown.
     */
    function syncToElement(selector, position = 0) {
      let elements = document.querySelectorAll(selector);
      if (position < 0 || position > elements.length) {
        throw new Error("Velvet.Component: position is out of bounds");
      }
      element = elements[position];
      return;
    }

    /**
     * Synchronizes the component to a newly created DOM element with the specified HTML tag.
     *
     * @function syncToNewElement
     * @memberof Component
     * @param {string} tag - The HTML tag for the new element.
     * @returns {void}
     * @description
     * This function creates a new DOM element with the specified HTML tag and synchronizes the component
     * to the newly created element. The synchronized element becomes the target for subsequent component operations.
     */
    function syncToNewElement(tag) {
      element = document.createElement(tag);
      return;
    }

    /**
     * Attaches an event listener to the synchronized DOM element.
     *
     * @function onEvent
     * @memberof Component
     * @param {string} trigger - The event type (e.g., "click", "mouseenter").
     * @param {Function} callback - The callback function to be executed when the event occurs.
     * @returns {void}
     * @description
     * This function checks if the synchronized element is defined and attaches an event listener
     * to it for the specified event type. The provided callback function will be executed when the event occurs.
     */
    function onEvent(trigger, callback) {
      _onlyIfElementIsNotUndefined();
      element.addEventListener(trigger, callback);
      return;
    }

    /**
     * Triggers a callback when the synchronized element enters the view.
     *
     * @function onEnteringView
     * @memberof Component
     * @param {Function} callback - The callback function to be executed when the element enters the view.
     * @param {object} [options] - Optional. IntersectionObserver options for controlling the intersection behavior.
     *                             Defaults to root: null, rootMargin: "0px", threshold: 0.5.
     * @returns {void}
     * @description
     * This function checks if the synchronized element is defined and sets up an IntersectionObserver to
     * monitor the element's intersection with the viewport. When the element enters the view, the provided
     * callback function is executed. Additional options can be specified to customize the intersection behavior.
     */
    function onEnteringView(
      callback,
      options = {
        root: null,
        rootMargin: "0px",
        threshold: 0.5
      }
    ) {
      _onlyIfElementIsNotUndefined()
      let observer = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            callback();
            observer.unobserve(entry.target);
          }
        })
      }, options);
      observer.observe(this.element);
      return;
    }

    /**
     * Executes a callback function at regular intervals.
     *
     * @function onEveryInterval
     * @memberof Component
     * @param {Function} callback - The callback function to be executed at each interval.
     * @param {number} interval - The time interval (in milliseconds) at which the callback should be executed.
     * @returns {void}
     * @description
     * This function checks if the synchronized element is defined and sets up a setInterval to repeatedly
     * execute the provided callback function at the specified time interval. The interval is in milliseconds.
     */
    function onEveryInterval(callback, interval) {
      _onlyIfElementIsNotUndefined();
      setInterval(callback, interval);
      return;
    }

    /**
     * Updates the content of the synchronized element.
     *
     * @function updateContent
     * @memberof Component
     * @param {string} content - The new content to be set for the element.
     * @returns {void}
     * @description
     * This function checks if the synchronized element is defined and updates its content
     * by setting the provided string as the textContent of the element.
     */
    function updateContent(content) {
      _onlyIfElementIsNotUndefined();
      element.textContent = content;
      return;
    }

    /**
     * Updates the style of the synchronized element using the provided stylesheet.
     *
     * @function updateStyle
     * @memberof Component
     * @param {object} [stylesheet={}] - Optional. The stylesheet object containing style properties and values.
     * @returns {void}
     * @description
     * This function checks if the synchronized element is defined and updates its style by applying the properties
     * and values from the provided stylesheet object. The styles are directly assigned to the element's style property.
     */
    function updateStyle(stylesheet = {}) {
      _onlyIfElementIsNotUndefined();
      Object.assign(element.style, stylesheet);
      return;
    }

    /**
     * Updates a specific style template with new styles.
     *
     * @function updateStyleTemplate
     * @memberof Component
     * @param {string} template - The name of the style template to be updated.
     * @param {object} stylesheet - The new stylesheet object containing style properties and values.
     * @returns {void}
     * @description
     * This function updates a specific style template associated with the component.
     * The template is identified by its name, and the new styles are applied from the provided stylesheet object.
     */
    function updateStyleTemplate(template, stylesheet) {
      Object.assign(css[template], stylesheet);
      return;
    }

    /**
     * Overrides a style template with new styles or creates a new template if it doesn't exist.
     *
     * @function overrideStyleTemplate
     * @memberof Component
     * @param {string} template - The name of the style template to be overridden or created.
     * @param {object} [stylesheet={}] - Optional. The new stylesheet object containing style properties and values.
     * @returns {void}
     * @description
     * This function overrides an existing style template with new styles or creates a new template if it doesn't exist.
     * The template is identified by its name, and the new styles are applied from the provided stylesheet object.
     */
    function overrideStyleTemplate(template, stylesheet = {}) {
      css[template] = stylesheet;
      return;
    }

    /**
     * Applies a predefined style template to the synchronized element.
     *
     * @function applyStyleTemplate
     * @memberof Component
     * @param {string} template - The name of the style template to be applied.
     * @returns {void}
     * @description
     * This function applies a predefined style template to the synchronized element.
     * The template is identified by its name, and the associated styles are applied to the element.
     */
    function applyStyleTemplate(template) {
      updateStyle(css[template]);
      return;
    }

    /**
     * Overrides the inner HTML content of the synchronized element with the provided source.
     *
     * @function overrideInnerHTML
     * @memberof Component
     * @param {string} source - The HTML content to be set as the inner HTML of the element.
     * @returns {void}
     * @description
     * This function overrides the inner HTML content of the synchronized element with the specified source.
     */
    function overrideInnerHTML(source) {
      element.innerHTML = source;
      return;
    }

    /**
     * Injects an array of components into the synchronized element.
     *
     * @function inject
     * @memberof Component
     * @param {Array<any>} components - An array of components to be injected into the element.
     * @returns {void}
     * @description
     * This function injects an array of components into the synchronized element. The components are appended
     * as child elements to the synchronized element, maintaining the specified order in the array.
     * Note: At the stage where the components array is required, the "components" type may not be defined.
     */
    function inject(components) {
      /// at the stage that components array is required components does not exist as a type
      if (components.length === 0) {
        return;
      }
      for (let i = 0; i < components.length; i++) {
        let component = components[i];
        element.appendChild(component.element);
      }
      return;
    }

    /**
     * Throws an error if the synchronized element is undefined.
     *
     * @function _onlyIfElementIsNotUndefined
     * @memberof Component
     * @returns {void}
     * @throws {Error} Throws an error if the synchronized element is undefined.
     * @private
     * @description
     * This private function checks if the synchronized element is defined. If the element is undefined,
     * it throws an error with a message indicating that the element is not defined.
     */
    function _onlyIfElementIsNotUndefined() {
      if (!element) {
        throw new Error("Velvet.Component: element is undefined");
      }
      return;
    }

    return {
      /**
       * Retrieves the synchronized element.
       *
       * @function element
       * @memberof Component
       * @returns {Element} The synchronized element.
       * @description
       * This function returns the synchronized element associated with the component.
       */
      element: function() {
        return element;
      },

      /**
       * Retrieves the CSS styles associated with the component.
       *
       * @function css
       * @memberof Component
       * @returns {Object} The CSS styles object containing different style templates.
       * @description
       * This function returns the CSS styles object associated with the component. The object
       * contains various style templates identified by state names, each containing style properties and values.
       */
      css: function() {
        return css;
      },

      /**
       * Synchronizes the component to a specific element based on a CSS selector.
       *
       * @function syncToElement
       * @memberof Component
       * @param {string} selector - The CSS selector used to identify the target element.
       * @param {number} [position=0] - Optional. The position of the target element if multiple elements match the selector.
       * @returns {void}
       * @description
       * This function synchronizes the component to a specific element identified by the provided CSS selector.
       * The optional position parameter can be used to specify which element to choose if multiple elements match the selector.
       */
      syncToElement: function(selector, position = 0) {
        return syncToElement(selector, position);
      },

      /**
       * Synchronizes the component to a newly created element with the specified HTML tag.
       *
       * @function syncToNewElement
       * @memberof Component
       * @param {string} tag - The HTML tag used to create the new element for synchronization.
       * @returns {void}
       * @description
       * This function synchronizes the component to a newly created element with the specified HTML tag.
       * The synchronized element is replaced with the newly created element.
       */
      syncToNewElement: function(tag) {
        return syncToNewElement(tag);
      },

      /**
       * Attaches an event listener to the synchronized element.
       *
       * @function onEvent
       * @memberof Component
       * @param {string} trigger - The event type that triggers the callback.
       * @param {Function} callback - The callback function to be executed when the event is triggered.
       * @returns {void}
       * @description
       * This function attaches an event listener to the synchronized element. The listener is triggered
       * by the specified event type, and the provided callback function is executed when the event occurs.
       */
      onEvent: function(trigger, callback) {
        return onEvent(trigger, callback);
      },

      /**
       * Attaches a callback function to be executed when the component enters the viewport.
       *
       * @function onEnteringView
       * @memberof Component
       * @param {Function} callback - The callback function to be executed when the component enters the viewport.
       * @param {Object} [options={ root: null, rootMargin: "0px", threshold: 0.5 }] - Optional. IntersectionObserver options.
       * @returns {void}
       * @description
       * This function attaches a callback function to be executed when the component enters the viewport.
       * It utilizes the IntersectionObserver to detect when the element becomes visible within the specified options.
       */
      onEnteringView: function(
        callback,
        options = {
          root: null,
          rootMargin: "0px",
          threshold: 0.5
        }
      ) {
        return onEnteringView(callback, options);
      },

      /**
       * Executes the provided callback function at regular intervals.
       *
       * @function onEveryInterval
       * @memberof Component
       * @param {Function} callback - The callback function to be executed at regular intervals.
       * @param {number} interval - The time interval (in milliseconds) between each execution of the callback.
       * @returns {void}
       * @description
       * This function executes the provided callback function at regular intervals specified by the interval parameter.
       */
      onEveryInterval: function(callback, interval) {
        return onEveryInterval(callback, interval);
      },

      /**
       * Updates the content of the synchronized element.
       *
       * @function updateContent
       * @memberof Component
       * @param {string} content - The new content to be set for the synchronized element.
       * @returns {void}
       * @description
       * This function updates the content of the synchronized element with the provided string content.
       */
      updateContent: function(content) {
        return updateContent(content);
      },

      /**
       * Updates the style of the synchronized element using the provided stylesheet object.
       *
       * @function updateStyle
       * @memberof Component
       * @param {Object} [stylesheet={}] - Optional. The stylesheet object containing style properties and values.
       * @returns {void}
       * @description
       * This function updates the style of the synchronized element using the properties and values
       * specified in the provided stylesheet object. If no stylesheet is provided, it defaults to an empty object.
       */
      updateStyle: function(stylesheet = {}) {
        return updateStyle(stylesheet);
      },

      /**
       * Updates a specific style template within the component's CSS styles object.
       *
       * @function updateStyleTemplate
       * @memberof Component
       * @param {string} template - The name of the style template to be updated.
       * @param {Object} stylesheet - The updated stylesheet object for the specified template.
       * @returns {void}
       * @description
       * This function updates a specific style template within the component's CSS styles object.
       * The provided template name and updated stylesheet object are used to modify the existing styles.
       */
      updateStyleTemplate: function(template, stylesheet) {
        return updateStyleTemplate(template, stylesheet);
      },

      /**
       * Overrides a specific style template within the component's CSS styles object.
       *
       * @function overrideStyleTemplate
       * @memberof Component
       * @param {string} template - The name of the style template to be overridden.
       * @param {Object} [stylesheet={}] - Optional. The new stylesheet object for the specified template.
       * @returns {void}
       * @description
       * This function overrides a specific style template within the component's CSS styles object.
       * The provided template name and optional new stylesheet object are used to replace the existing styles.
       */
      overrideStyleTemplate: function(template, stylesheet = {}) {
        return overrideStyleTemplate(template, stylesheet);
      },

      /**
       * Applies a specific style template to update the style of the synchronized element.
       *
       * @function applyStyleTemplate
       * @memberof Component
       * @param {string} template - The name of the style template to be applied.
       * @returns {void}
       * @description
       * This function applies a specific style template to update the style of the synchronized element.
       * The provided template name is used to retrieve the corresponding styles from the CSS styles object.
       */
      applyStyleTemplate: function(template) {
        return applyStyleTemplate(template);
      },

      /**
       * Overrides the inner HTML content of the synchronized element with the provided source string.
       *
       * @function overrideInnerHTML
       * @memberof Component
       * @param {string} source - The new HTML content to override the inner HTML of the synchronized element.
       * @returns {void}
       * @description
       * This function overrides the inner HTML content of the synchronized element with the provided source string.
       */
      overrideInnerHTML: function(source) {
        return overrideInnerHTML(source);
      },

      /**
       * Injects an array of components into the synchronized element.
       *
       * @function inject
       * @memberof Component
       * @param {Array<any>} components - An array of components to be injected into the synchronized element.
       * @returns {void}
       * @description
       * This function injects an array of components into the synchronized element.
       * It iterates through the array and appends each component's element to the synchronized element.
       * If the components array is empty, the function returns without performing any injection.
       */
      inject: function(components) {
        return inject(components);
      }
    }
  }

  /**
   * @function Template
   * @memberof Velvet
   * @returns {Template} - Template object with pre-defined component creation methods.
   * @description
   * The `Template` function offers pre-defined components like `any`, `column`, `row`, `button`, etc.
   * These components can be customized with content, styles, and child components.
   */
  function Template() {

    /**
     * Creates and returns a generic component with specified content, stylesheet, and nested components.
     *
     * @function any
     * @memberof Template
     * @param {string} [content=""] - Optional. The content to be set for the created component.
     * @param {Object} stylesheet - The stylesheet object containing style properties and values.
     * @param {Array<any>} components - An array of components to be injected into the created component.
     * @returns {any} - The created generic component.
     * @description
     * This function creates a generic component with the specified content, stylesheet, and nested components.
     * It initializes a new component using the Component factory function, sets its content, style, and injects
     * the provided components into the created component. The resulting component is then returned.
     */
    function any(content = "", stylesheet, components) {
      let component = Component();
      component.syncToNewElement("div");
      component.updateContent(content);
      component.updateStyle(stylesheet);
      component.inject(components);
      return component;
    }

    /**
     * Creates and returns a column layout component with specified width, height, stylesheet, and nested components.
     *
     * @function column
     * @memberof Template
     * @param {string} width - The width of the column layout component.
     * @param {string} height - The height of the column layout component.
     * @param {Object} stylesheet - The stylesheet object containing style properties and values.
     * @param {Array<any>} components - An array of components to be injected into the created column layout component.
     * @returns {any} - The created column layout component.
     * @description
     * This function creates a column layout component with the specified width, height, stylesheet, and nested components.
     * It initializes a new component using the Component factory function, sets its style to create a column layout,
     * and injects the provided components into the created component. The resulting component is then returned.
     */
    function column(width, height, stylesheet, components) {
      let component = Component();
      component.syncToNewElement("div");
      component.updateStyle({
        width: width,
        height: height,
        display: "flex",
        flexDirection: "column"
      });
      component.updateStyle(stylesheet);
      component.inject(components);
      return component;
    }

    /**
     * Creates and returns a row layout component with specified width, height, stylesheet, and nested components.
     *
     * @function row
     * @memberof Template
     * @param {string} width - The width of the row layout component.
     * @param {string} height - The height of the row layout component.
     * @param {Object} stylesheet - The stylesheet object containing style properties and values.
     * @param {Array<any>} components - An array of components to be injected into the created row layout component.
     * @returns {any} - The created row layout component.
     * @description
     * This function creates a row layout component with the specified width, height, stylesheet, and nested components.
     * It initializes a new component using the Component factory function, sets its style to create a row layout,
     * and injects the provided components into the created component. The resulting component is then returned.
     */
    function row(width, height, stylesheet, components) {
      let component = Component();
      component.syncToNewElement("div");
      component.updateStyle({
        width: width,
        height: height,
        display: "flex",
        flexDirection: "row"
      });
      component.updateStyle(stylesheet);
      component.inject(components);
      return component;
    }

    /**
     * Creates and returns a text component with specified content, stylesheet, and nested components.
     *
     * @function text
     * @memberof Template
     * @param {string} content - The content to be set for the created text component.
     * @param {Object} stylesheet - The stylesheet object containing style properties and values.
     * @param {Array<any>} components - An array of components to be injected into the created text component.
     * @returns {any} - The created text component.
     * @description
     * This function creates a text component with the specified content, stylesheet, and nested components.
     * It initializes a new component using the Component factory function, sets its content, style, and injects
     * the provided components into the created component. The resulting component is then returned.
     */
    function text(content, stylesheet, components) {
      let component = Component();
      component.syncToNewElement("div");
      component.updateContent(content);
      component.updateStyle(stylesheet);
      component.inject(components);
      return component;
    }

    /**
     * Creates and returns an image component with specified URL, stylesheet, and nested components.
     *
     * @function image
     * @memberof Template
     * @param {string} url - The URL of the image to be set for the created image component.
     * @param {Object} stylesheet - The stylesheet object containing style properties and values.
     * @param {Array<any>} components - An array of components to be injected into the created image component.
     * @returns {any} - The created image component.
     * @description
     * This function creates an image component with the specified URL, stylesheet, and nested components.
     * It initializes a new component using the Component factory function, sets its style and image source,
     * and injects the provided components into the created component. The resulting component is then returned.
     */
    function image(url, stylesheet, components) {
      let component = Component();
      component.syncToNewElement("img");
      component.updateStyle(stylesheet);
      component.element().src = url;
      component.inject(components);
      return component;
    }

    /**
     * Creates and returns a button component with specified content, height, click callback, and nested components.
     *
     * @function button
     * @memberof Template
     * @param {string} content - The text content of the button.
     * @param {string} height - The height of the button.
     * @param {() => void} callbackOnClick - The callback function to be executed on button click.
     * @param {Array<any>} components - An array of components to be injected into the created button component.
     * @returns {any} - The created button component.
     * @description
     * This function creates a button component with the specified content, height, click callback,
     * and nested components. It initializes a new component using the Component factory function,
     * sets its content, height, and style templates for different states (default, focus, hover, active),
     * adds event listeners for mouse and click events to handle style changes, and attaches the provided
     * components to the created button component. The resulting button component is then returned.
     */
    function button(content, height, callbackOnClick, components) {
      let component = Component();
      component.syncToNewElement("div");
      component.updateContent(content);
      component.updateStyleTemplate("default", {
        width: "auto",
        height: height,
        alignItems: "center",
        appearance: "none",
        backgroundColor: "#FCFCFD",
        borderRadius: "4px",
        borderWidth: "0",
        boxShadow:
          "rgba(45, 35, 66, 0.4) 0 2px 4px,rgba(45, 35, 66, 0.3) 0 7px 13px -3px,#D6D6E7 0 -3px 0 inset",
        boxSizing: "border-box",
        color: "#36395A",
        cursor: "pointer",
        display: "inline-flex",
        fontFamily: "'JetBrains Mono', monospace",
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
        fontSize: "18px"
      });
      component.updateStyleTemplate("focus", {
        boxShadow:
          "#D6D6E7 0 0 0 1.5px inset, rgba(45, 35, 66, 0.4) 0 2px 4px, rgba(45, 35, 66, 0.3) 0 7px 13px -3px, #D6D6E7 0 -3px 0 inset"
      });
      component.updateStyleTemplate("hover", {
        boxShadow:
          "rgba(45, 35, 66, 0.4) 0 4px 8px, rgba(45, 35, 66, 0.3) 0 7px 13px -3px, #D6D6E7 0 -3px 0 inset",
        transform: "translateY(-2px)"
      });
      component.updateStyleTemplate("active", {
        boxShadow: "#D6D6E7 0 3px 7px inset",
        transform: "translateY(2px)"
      });
      component.onEvent("mouseenter", () => {
        component.applyStyleTemplate("hover");
        component.applyStyleTemplate("focus");
      });
      component.onEvent("mouseleave", () => {
        component.applyStyleTemplate("default");
      });
      component.onEvent("mousedown", () => {
        component.applyStyleTemplate("active");
      });
      component.onEvent("mouseup", () => {
        component.applyStyleTemplate("hover");
        component.applyStyleTemplate("focus");
      });
      component.onEvent("click", () => {
        callbackOnClick();
      });
      component.applyStyleTemplate("default");
      component.attach(components);
      return component;
    }

    /**
     * Creates and returns a gradient button component with specified content, height, click callback, and nested components.
     *
     * @function gradientButton
     * @memberof Template
     * @param {string} content - The text content of the gradient button.
     * @param {string} height - The height of the gradient button.
     * @param {() => void} callbackOnClick - The callback function to be executed on button click.
     * @param {Array<any>} components - An array of components to be injected into the created gradient button component.
     * @returns {any} - The created gradient button component.
     * @description
     * This function creates a gradient button component with the specified content, height, click callback,
     * and nested components. It initializes a new component using the Component factory function,
     * sets its content, height, and style templates for different states (default, focus, hover, active),
     * adds event listeners for mouse and click events to handle style changes, and attaches the provided
     * components to the created gradient button component. The resulting gradient button component is then returned.
     */
    function gradientButton(content, height, callbackOnClick, components) {
      let component = Component();
      component.syncToNewElement("div");
      component.updateContent(content);
      component.updateStyleTemplate("default", {
        width: "auto",
        height: height,
        alignItems: "center",
        appearance: "none",
        backgroundImage:
          "radial-gradient(100% 100% at 100% 0, #705aff 0, #d454ff 100%)",
        border: "0",
        borderRadius: "6px",
        boxShadow:
          "rgba(45, 35, 66, .4) 0 2px 4px,rgba(45, 35, 66, .3) 0 7px 13px -3px,rgba(58, 65, 111, .5) 0 -3px 0 inset",
        boxSizing: "border-box",
        color: "#fff",
        cursor: "pointer",
        display: "inline-flex",
        fontFamily: "'JetBrains Mono', monospace",
        justifyContent: "center",
        lineHeight: "1",
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
        fontSize: "18px"
      });
      component.updateStyleTemplate("focus", {
        boxShadow:
          "#3c4fe0 0 0 0 1.5px inset, rgba(45, 35, 66, .4) 0 2px 4px, rgba(45, 35, 66, .3) 0 7px 13px -3px, #3c4fe0 0 -3px 0 inset"
      });
      component.updateStyleTemplate("hover", {
        boxShadow:
          "rgba(45, 35, 66, .4) 0 4px 8px, rgba(45, 35, 66, .3) 0 7px 13px -3px, #3c4fe0 0 -3px 0 inset",
        transform: "translateY(-2px)"
      });
      component.updateStyleTemplate("active", {
        boxShadow: "#3c4fe0 0 3px 7px inset",
        transform: "translateY(2px)"
      });
      component.onEvent("mouseenter", () => {
        component.applyStyleTemplate("hover");
        component.applyStyleTemplate("focus");
      });
      component.onEvent("mouseleave", () => {
        component.applyStyleTemplate("default");
      });
      component.onEvent("mousedown", () => {
        component.applyStyleTemplate("active");
      });
      component.onEvent("mouseup", () => {
        component.applyStyleTemplate("hover");
        component.applyStyleTemplate("focus");
      });
      component.onEvent("click", () => {
        callbackOnClick();
      });
      component.applyStyleTemplate("default");
      component.attach(components);
    }

    /**
     * Creates and returns a flat neumorphic container component with specified width, height, stylesheet, and nested components.
     *
     * @function flatNeumorphicContainer
     * @memberof Component
     * @param {string} width - The width of the flat neumorphic container.
     * @param {string} height - The height of the flat neumorphic container.
     * @param {object} stylesheet - The stylesheet object containing style properties for the flat neumorphic container.
     * @param {Array<any>} components - An array of components to be injected into the created flat neumorphic container component.
     * @returns {any} - The created flat neumorphic container component.
     * @description
     * This function creates a flat neumorphic container component with the specified width, height, stylesheet,
     * and nested components. It initializes a new component using the Component factory function,
     * sets its width, height, background, boxShadow, display, flexDirection, justifyContent, alignItems properties,
     * and updates its style with the provided stylesheet. The resulting flat neumorphic container component is then returned.
     */
    function flatNeumorphicContainer(width, height, stylesheet, components) {
      let component = Component();
      component.syncToNewElement("div");
      component.updateStyle({
        width: width,
        height: height,
        background: "#ffffff",
        boxShadow: "20px 20px 60px #d9d9d9, -20px -20px 60px #ffffff",
        display: "flex",
        flexDirection: "column",
        justifyContent: "center",
        alignItems: "center"
      });
      component.updateStyle(stylesheet);
      component.inject(components);
      return component;
    }

    /**
     * Creates and returns a concave neumorphic container component with specified width, height, stylesheet, and nested components.
     *
     * @function concaveNeumorphicContainer
     * @memberof Component
     * @param {string} width - The width of the concave neumorphic container.
     * @param {string} height - The height of the concave neumorphic container.
     * @param {object} stylesheet - The stylesheet object containing style properties for the concave neumorphic container.
     * @param {Array<any>} components - An array of components to be attached to the created concave neumorphic container component.
     * @returns {any} - The created concave neumorphic container component.
     * @description
     * This function creates a concave neumorphic container component with the specified width, height, stylesheet,
     * and nested components. It initializes a new component using the Component factory function,
     * sets its width, height, background, boxShadow, display, flexDirection, justifyContent, alignItems properties,
     * and updates its style with the provided stylesheet. The resulting concave neumorphic container component is then returned.
     */
    function concaveNeumorphicContainer(width, height, stylesheet, components) {
      let component = Component();
      component.syncToNewElement("div");
      component.updateStyle({
        width: width,
        height: height,
        background: "linear-gradient(145deg, #e6e6e6, #ffffff)",
        boxShadow: "20px 20px 60px #d9d9d9, -20px -20px 60px #ffffff",
        display: "flex",
        flexDirection: "column",
        justifyContent: "center",
        alignItems: "center"
      });
      component.updateStyle(stylesheet);
      component.attach(components);
      return component;
    }

    /**
     * Creates and returns a convex neumorphic container component with specified width, height, stylesheet, and nested components.
     *
     * @function convexNeumorphicContainer
     * @memberof Component
     * @param {string} width - The width of the convex neumorphic container.
     * @param {string} height - The height of the convex neumorphic container.
     * @param {object} stylesheet - The stylesheet object containing style properties for the convex neumorphic container.
     * @param {Array<any>} components - An array of components to be attached to the created convex neumorphic container component.
     * @returns {any} - The created convex neumorphic container component.
     * @description
     * This function creates a convex neumorphic container component with the specified width, height, stylesheet,
     * and nested components. It initializes a new component using the Component factory function,
     * sets its width, height, background, boxShadow, display, flexDirection, justifyContent, alignItems properties,
     * and updates its style with the provided stylesheet. The resulting convex neumorphic container component is then returned.
     */
    function convexNeumorphicContainer(width, height, stylesheet, components) {
      let component = Component();
      component.syncToNewElement("div");
      component.updateStyle({
        width: width,
        height: height,
        background: "linear-gradient(145deg, #e6e6e6, #ffffff)",
        boxShadow: "20px 20px 60px #d9d9d9, -20px -20px 60px #ffffff",
        display: "flex",
        flexDirection: "column",
        justifyContent: "center",
        alignItems: "center"
      });
      component.updateStyle(stylesheet);
      component.attach(components);
      return component;
    }

    /**
     * Creates and returns a pressed neumorphic container component with specified width, height, stylesheet, and nested components.
     *
     * @function pressedNeumorphicContainer
     * @memberof Component
     * @param {string} width - The width of the pressed neumorphic container.
     * @param {string} height - The height of the pressed neumorphic container.
     * @param {object} stylesheet - The stylesheet object containing style properties for the pressed neumorphic container.
     * @param {Array<any>} components - An array of components to be attached to the created pressed neumorphic container component.
     * @returns {any} - The created pressed neumorphic container component.
     * @description
     * This function creates a pressed neumorphic container component with the specified width, height, stylesheet,
     * and nested components. It initializes a new component using the Component factory function,
     * sets its width, height, background, display, flexDirection, justifyContent, alignItems properties,
     * and updates its style with the provided stylesheet. The resulting pressed neumorphic container component is then returned.
     */
    function pressedNeumorphicContainer(width, height, stylesheet, components) {
      let component = Component();
      component.syncToNewElement("div");
      component.updateStyle({
        width: width,
        height: height,
        background:
          "inset 20px 20px 60px #d9d9d9, inset -20px -20px 60px #ffffff",
        display: "flex",
        flexDirection: "column",
        justifyContent: "center",
        alignItems: "center"
      });
      component.updateStyle(stylesheet);
      component.attach(components);
      return component;
    }

    return {
      /**
       * Creates and returns a generic component with specified content, stylesheet, and nested components.
       *
       * @function any
       * @memberof Component
       * @param {string} content - The content to be displayed within the generic component.
       * @param {object} stylesheet - The stylesheet object containing style properties for the generic component.
       * @param {Array<any>} components - An array of components to be injected into the created generic component.
       * @returns {any} - The created generic component.
       * @description
       * This function creates a generic component with the specified content, stylesheet,
       * and nested components. It initializes a new component using the Component factory function,
       * sets its content, updates its style with the provided stylesheet, and injects the specified components.
       * The resulting generic component is then returned.
       */
      any: function(content = "", stylesheet, components) {
        return any(content, stylesheet, components);
      },

      /**
       * Creates and returns a column component with specified width, height, stylesheet, and nested components.
       *
       * @function column
       * @memberof Component
       * @param {string} width - The width of the column component.
       * @param {string} height - The height of the column component.
       * @param {object} stylesheet - The stylesheet object containing style properties for the column component.
       * @param {Array<any>} components - An array of components to be injected into the created column component.
       * @returns {any} - The created column component.
       * @description
       * This function creates a column component with the specified width, height, stylesheet,
       * and nested components. It initializes a new component using the Component factory function,
       * sets its width and height, updates its style with the provided stylesheet, and injects the specified components.
       * The resulting column component is then returned.
       */
      column: function(width, height, stylesheet, components) {
        return column(width, height, stylesheet, components);
      },

      /**
       * Creates and returns a row component with specified width, height, stylesheet, and nested components.
       *
       * @function row
       * @memberof Component
       * @param {string} width - The width of the row component.
       * @param {string} height - The height of the row component.
       * @param {object} stylesheet - The stylesheet object containing style properties for the row component.
       * @param {Array<any>} components - An array of components to be injected into the created row component.
       * @returns {any} - The created row component.
       * @description
       * This function creates a row component with the specified width, height, stylesheet,
       * and nested components. It initializes a new component using the Component factory function,
       * sets its width and height, updates its style with the provided stylesheet, and injects the specified components.
       * The resulting row component is then returned.
       */
      row: function(width, height, stylesheet, components) {
        return row(width, height, stylesheet, components);
      },

      /**
       * Creates and returns a text component with specified content, stylesheet, and nested components.
       *
       * @function text
       * @memberof Component
       * @param {string} content - The content/text of the text component.
       * @param {object} stylesheet - The stylesheet object containing style properties for the text component.
       * @param {Array<any>} components - An array of components to be injected into the created text component.
       * @returns {any} - The created text component.
       * @description
       * This function creates a text component with the specified content, stylesheet,
       * and nested components. It initializes a new component using the Component factory function,
       * sets its content, updates its style with the provided stylesheet, and injects the specified components.
       * The resulting text component is then returned.
       */
      text: function(content, stylesheet, components) {
        return text(content, stylesheet, components);
      },

      /**
       * Creates and returns an image component with specified URL, stylesheet, and nested components.
       *
       * @function image
       * @memberof Component
       * @param {string} url - The URL of the image.
       * @param {object} stylesheet - The stylesheet object containing style properties for the image component.
       * @param {Array<any>} components - An array of components to be injected into the created image component.
       * @returns {any} - The created image component.
       * @description
       * This function creates an image component with the specified URL, stylesheet,
       * and nested components. It initializes a new component using the Component factory function,
       * sets its source URL, updates its style with the provided stylesheet, and injects the specified components.
       * The resulting image component is then returned.
       */
      image: function(url, stylesheet, components) {
        return image(url, stylesheet, components);
      },

      /**
       * Creates and returns a button component with specified content, height, click callback, and nested components.
       *
       * @function button
       * @memberof Component
       * @param {string} content - The content or text of the button.
       * @param {string} height - The height of the button.
       * @param {() => void} callbackOnClick - The callback function to be executed on button click.
       * @param {Array<any>} components - An array of components to be injected into the created button component.
       * @returns {any} - The created button component.
       * @description
       * This function creates a button component with the specified content, height, click callback,
       * and nested components. It initializes a new component using the Component factory function,
       * sets its content, updates its style with predefined templates, and attaches event listeners.
       * The resulting button component is then returned.
       */
      button: function(content, height, callbackOnClick, components) {
        return button(content, height, callbackOnClick, components);
      },

      /**
       * Creates and returns a gradient button component with specified content, height, click callback, and nested components.
       *
       * @function gradientButton
       * @memberof Component
       * @param {string} content - The content or text of the gradient button.
       * @param {string} height - The height of the gradient button.
       * @param {() => void} callbackOnClick - The callback function to be executed on button click.
       * @param {Array<any>} components - An array of components to be injected into the created gradient button component.
       * @returns {any} - The created gradient button component.
       * @description
       * This function creates a gradient button component with the specified content, height, click callback,
       * and nested components. It initializes a new component using the Component factory function,
       * sets its content, updates its style with predefined templates, and attaches event listeners.
       * The resulting gradient button component is then returned.
       */
      gradientButton(content, height, callbackOnClick, components) {
        return gradientButton(content, height, callbackOnClick, components);
      },

      /**
       * Creates and returns a flat neumorphic container component with specified width, height, stylesheet, and nested components.
       *
       * @function flatNeumorphicContainer
       * @memberof Component
       * @param {string} width - The width of the flat neumorphic container.
       * @param {string} height - The height of the flat neumorphic container.
       * @param {object} stylesheet - The stylesheet object to apply styles to the flat neumorphic container.
       * @param {Array<any>} components - An array of components to be injected into the created flat neumorphic container component.
       * @returns {any} - The created flat neumorphic container component.
       * @description
       * This function creates a flat neumorphic container component with the specified width, height,
       * stylesheet, and nested components. It initializes a new component using the Component factory function,
       * sets its dimensions, background, box shadow, and other styles, and injects specified nested components.
       * The resulting flat neumorphic container component is then returned.
       */
      flatNeumorphicContainer(width, height, stylesheet, components) {
        return flatNeumorphicContainer(width, height, stylesheet, components);
      },

      /**
       * Creates and returns a concave neumorphic container component with specified width, height, stylesheet, and nested components.
       *
       * @function concaveNeumorphicContainer
       * @memberof Component
       * @param {string} width - The width of the concave neumorphic container.
       * @param {string} height - The height of the concave neumorphic container.
       * @param {object} stylesheet - The stylesheet object to apply styles to the concave neumorphic container.
       * @param {Array<any>} components - An array of components to be attached to the created concave neumorphic container component.
       * @returns {any} - The created concave neumorphic container component.
       * @description
       * This function creates a concave neumorphic container component with the specified width, height,
       * stylesheet, and nested components. It initializes a new component using the Component factory function,
       * sets its dimensions, background, box shadow, and other styles, and attaches specified nested components.
       * The resulting concave neumorphic container component is then returned.
       */
      concaveNeumorphicContainer(width, height, stylesheet, components) {
        return concaveNeumorphicContainer(width, height, stylesheet, components);
      },

      /**
       * Creates and returns a convex neumorphic container component with specified width, height, stylesheet, and nested components.
       *
       * @function convexNeumorphicContainer
       * @memberof Component
       * @param {string} width - The width of the convex neumorphic container.
       * @param {string} height - The height of the convex neumorphic container.
       * @param {object} stylesheet - The stylesheet object to apply styles to the convex neumorphic container.
       * @param {Array<any>} components - An array of components to be attached to the created convex neumorphic container component.
       * @returns {any} - The created convex neumorphic container component.
       * @description
       * This function creates a convex neumorphic container component with the specified width, height,
       * stylesheet, and nested components. It initializes a new component using the Component factory function,
       * sets its dimensions, background, box shadow, and other styles, and attaches specified nested components.
       * The resulting convex neumorphic container component is then returned.
       */
      convexNeumorphicContainer(width, height, stylesheet, components) {
        return convexNeumorphicContainer(width, height, stylesheet, components);
      },

      /**
       * Creates and returns a pressed neumorphic container component with specified width, height, stylesheet, and nested components.
       *
       * @function pressedNeumorphicContainer
       * @memberof Component
       * @param {string} width - The width of the pressed neumorphic container.
       * @param {string} height - The height of the pressed neumorphic container.
       * @param {object} stylesheet - The stylesheet object to apply styles to the pressed neumorphic container.
       * @param {Array<any>} components - An array of components to be attached to the created pressed neumorphic container component.
       * @returns {any} - The created pressed neumorphic container component.
       * @description
       * This function creates a pressed neumorphic container component with the specified width, height,
       * stylesheet, and nested components. It initializes a new component using the Component factory function,
       * sets its dimensions, background, box shadow, and other styles, and attaches specified nested components.
       * The resulting pressed neumorphic container component is then returned.
       */
      pressedNeumorphicContainer(width, height, stylesheet, components) {
        return pressedNeumorphicContainer(width, height, stylesheet, components);
      }
    }
  }

  /**
   * @function Ajax
   * @memberof Velvet
   * @returns {Ajax} - Ajax object with methods for making asynchronous requests.
   * @description
   * The `Ajax` function provides methods for handling asynchronous requests, including `get` and `post`.
   */
  function Ajax() {

    /**
     * Performs a GET request to the specified URL and handles success and error callbacks.
     *
     * @function get
     * @memberof Component
     * @param {string} url - The URL to perform the GET request.
     * @param {(response: any) => any} callbackIfSuccess - The callback function to be executed on a successful response.
     * @param {(error: any) => any} callbackIfError - The callback function to be executed on an error response.
     * @returns {Promise<any>} - A Promise that resolves with the response if the request is successful and rejects with the error if there is an error.
     * @description
     * This function performs a GET request to the specified URL using jQuery's ajax function. It handles success and error callbacks provided
     * by the user and returns a Promise that resolves with the response if the request is successful and rejects with the error if there is an error.
     */
    function get(url, callbackIfSuccess, callbackIfError) {
      return new Promise((resolve, reject) => {
        $.ajax({
          type: "GET",
          url: url,
          success: response => {
            callbackIfSuccess(response);
            resolve(response);
          },
          error: error => {
            callbackIfError(error);
            reject(error);
          }
        })
      })
    }

    /**
     * Performs a POST request to the specified URL with the provided data and handles success and error callbacks.
     *
     * @function post
     * @memberof Component
     * @param {string} url - The URL to perform the POST request.
     * @param {any} data - The data to be sent in the POST request.
     * @param {(response: any) => any} callbackIfSuccess - The callback function to be executed on a successful response.
     * @param {(error: any) => any} callbackIfError - The callback function to be executed on an error response.
     * @returns {Promise<any>} - A Promise that resolves with the response if the request is successful and rejects with the error if there is an error.
     * @description
     * This function performs a POST request to the specified URL with the provided data using jQuery's ajax function. It handles success and error
     * callbacks provided by the user and returns a Promise that resolves with the response if the request is successful and rejects with the error
     * if there is an error.
     */
    function post(url, data, callbackIfSuccess, callbackIfError) {
      return new Promise((resolve, reject) => {
        $.ajax({
          type: "POST",
          url: url,
          data: data,
          success: response => {
            callbackIfSuccess(response);
            resolve(response);
          },
          error: error => {
            callbackIfError(error);
            reject(error);
          }
        })
      })
    }

    return {
      /**
       * Performs a GET request to the specified URL and handles success and error callbacks.
       *
       * @function get
       * @memberof Component
       * @param {string} url - The URL to perform the GET request.
       * @param {(response: any) => any} callbackIfSuccess - The callback function to be executed on a successful response.
       * @param {(error: any) => any} callbackIfError - The callback function to be executed on an error response.
       * @returns {Promise<any>} - A Promise that resolves with the response if the request is successful and rejects with the error if there is an error.
       * @description
       * This function performs a GET request to the specified URL using jQuery's ajax function. It handles success and error callbacks provided by
       * the user and returns a Promise that resolves with the response if the request is successful and rejects with the error if there is an error.
       */
      get: function(url, callbackIfSuccess, callbackIfError) {
        return get(url, callbackIfSuccess, callbackIfError);
      },
      /**
       * Performs a POST request to the specified URL with the provided data and handles success and error callbacks.
       *
       * @function post
       * @memberof Component
       * @param {string} url - The URL to perform the POST request.
       * @param {any} data - The data to be sent in the POST request.
       * @param {(response: any) => any} callbackIfSuccess - The callback function to be executed on a successful response.
       * @param {(error: any) => any} callbackIfError - The callback function to be executed on an error response.
       * @returns {Promise<any>} - A Promise that resolves with the response if the request is successful and rejects with the error if there is an error.
       * @description
       * This function performs a POST request to the specified URL with the provided data using jQuery's ajax function. It handles success and error
       * callbacks provided by the user and returns a Promise that resolves with the response if the request is successful and rejects with the error
       * if there is an error.
       */
      post: function(url, data, callbackIfSuccess, callbackIfError) {
        return post(url, data, callbackIfSuccess, callbackIfError);
      }
    }
  }

  function Metamask() {
    /// work in progress

    function connect(accountIndex) {
      /// @note this function is incomplete
      try {
        let window;
        let accounts = window.ethereum.request({
          method: "eth_requestAccounts"
        });
        return true;
      } catch {
        console.error("Velvet.Metamask: unable to connect to metamask");
      }
      return false;
    }

    return {
      connect: function(accountIndex) {
        return connect(accountIndex);
      }
    }
  }

  /**
   * Represents the initialization state of the Velvet component.
   *
   * @type {boolean}
   */
  let initialized = false;

  /**
   * Represents the main component that syncs to the entire document.
   *
   * @type {Component}
   */
  let everything = Component();

  /**
   * Represents the HTML component that syncs to the "html" element.
   *
   * @type {Component}
   */
  let html = Component();

  /**
   * Represents the head component that syncs to the "head" element.
   *
   * @type {Component}
   */
  let head = Component();

  /**
   * Represents the body component that syncs to the "body" element.
   *
   * @type {Component}
   */
  let body = Component();

  /**
   * Represents the header component that syncs to the "header" element.
   *
   * @type {Component}
   */
  let header = Component();

  /**
   * Represents the content component that syncs to the "content" element.
   *
   * @type {Component}
   */
  let content = Component();

  /**
   * Represents an array to store routes.
   *
   * @type {Array<any>}
   */
  let routes = [];

  /**
   * @function initialize
   * @memberof Velvet
   * @description
   * Initializes the Velvet library, logs the initialization status, and performs any necessary setup.
   *
   * Velvet expects the DOM to contain { html, head, body, header, content } element.
   * ! Please ensure that the initial html document is laid out in a proper fashion.
   */
  function initialize() {
    _onlyWhenNotInitialized();
    console.log("Velvet: initializing");
    /// initialization logic goes here
    {
      let resetStylesheet = {
        margin: "0",
        padding: "0"
      };
      everything.syncToElement("*");
      everything.updateStyle(resetStylesheet);
      html.syncToElement("html");
      html.updateStyle(resetStylesheet);
      head.syncToElement("head");
      body.syncToElement("body");
      body.updateStyle(resetStylesheet);
      body.updateStyle({
        width: "100vw",
        heith: "auto"
      });
      header.syncToElement("header");
      header.updateStyle(resetStylesheet);
      header.updateStyle({
        position: "fixed",
        width: "100vw",
        height: "100vh",
        mouseEvents: "none"
      });
      content.syncToElement("content");
      content.updateStyle(resetStylesheet);
      content.updateStyle({
        position: "absolute",
        width: "100%",
        height: "auto",
        display: "flex",
        flexDirection: "column"
      });
    }
    /// end of initialization logic
    initialized = true;
    console.log("Velvet: initialized");
    return;
  }

  /**
   * Clears the content of the header element.
   *
   * @function wipeHeader
   * @memberof Component
   * @throws {Error} Throws an error if the component is not initialized.
   * @description
   * This function clears the content of the header element by overriding its inner HTML with an empty string. It throws an error if the
   * component is not initialized.
   */
  function wipeHeader() {
    header.overrideInnerHTML("");
    return;
  }

  /**
   * Clears the content of the content element.
   *
   * @function wipeContent
   * @memberof Component
   * @throws {Error} Throws an error if the component is not initialized.
   * @description
   * This function clears the content of the content element by overriding its inner HTML with an empty string. It throws an error if the
   * component is not initialized.
   */
  function wipeContent() {
    content.overrideInnerHTML("");
    return;
  }

  /**
   * Adds a new route callback to the routes array.
   *
   * @param {() => void} callback - The callback function for the new route.
   * @returns {any}
   */
  function addRoute(callback) {
    routes.push(callback);
    return;
  }

  /**
   * Removes a route callback from the routes array.
   *
   * @param {() => void} callback - The callback function to be removed.
   * @returns {any}
   */
  function removeRoute(callback) {
    let routeIndex = routes.indexOf(callback);
    routes.splice(routeIndex, 1);
    return;
  }

  /**
   * Updates the content based on the specified route.
   *
   * @param {number} route - The index of the route in the routes array.
   * @returns {void}
   */
  function goto(route) {
    if (route > routes.length || routes.length === 0) {
      throw new Error("Velvet: route is out of bounds");
    }
    wipeHeader();
    wipeContent();
    try {
      routes[route]();
    } catch (error) {
      console.log(error);
    }
    return;
  }

  /**
   * Checks if the Velvet component has not been initialized.
   *
   * @function _onlyWhenNotInitialized
   * @memberof Component
   * @throws {Error} Throws an error if the component has already been initialized.
   * @description
   * This function checks whether the Velvet component has not been initialized. If it has already been initialized, it throws an error
   * indicating that the component has already been initialized.
   */
  function _onlyWhenNotInitialized() {
    if (initialized) {
      throw new Error("Velvet: has already been initialized");
    }
    return;
  }

  return {
    everything,
    html,
    head,
    body,
    header,
    content,

    /**
     * Creates and returns a new instance of the Component.
     *
     * @returns {any} - A new instance of the Component.
     */
    Component: function() {
      return Component();
    },

    /**
     * Creates and returns a new instance of the Template.
     *
     * @returns {any} - A new instance of the Template.
     */
    Template: function() {
      return Template();
    },

    /**
     * Creates and returns a new instance of the Ajax module.
     *
     * @returns {any} - A new instance of the Ajax module.
     */
    Ajax: function() {
      return Ajax();
    },

    /**
     * Initializes the Velvet framework, setting up the necessary components and styles.
     *
     * @returns {void}
     */
    initialize: function() {
      return initialize();
    },

    /**
     * Clears the content of the header element.
     *
     * @returns {void}
     */
    wipeHeader: function() {
      return wipeHeader();
    },

    /**
     * Clears the content of the content element.
     *
     * @returns {void}
     */
    wipeContent: function() {
      return wipeContent();
    },

    /**
     * Adds a new route callback to the routes array.
     *
     * @param {Function} callback - The callback function for the new route.
     * @returns {void}
     */
    addRoute: function(callback) {
      return addRoute(callback);
    },

    /**
     * Removes a route callback from the routes array.
     *
     * @param {Function} callback - The callback function to be removed from the routes.
     * @returns {void}
     */
    removeRoute: function(callback) {
      return removeRoute(callback);
    },

    /**
     * Navigates to the specified route, wiping the header and content, and executing the corresponding route callback.
     *
     * @param {number} route - The index of the route to navigate to.
     * @returns {void}
     */
    goto: function(route) {
      return goto(route);
    }
  }
}
