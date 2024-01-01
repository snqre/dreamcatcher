/** silicon-dream-v1.0.0 */

function engine() {

    function stream() {

        function componentTemplate() {
            let _element;
            let _style = {};
            let _listener = {};
        
            /**
             * @notice Syncs the internal state to the specified HTML element.
             * @param {string} element - The CSS selector of the HTML element.
             * @return {boolean} - Returns true upon successful synchronization.
             * @visibility private
             */
            function _syncToElement(element) {
                _element = document.querySelector(element);
                return true;
            }
        
            /**
             * @notice Syncs the internal state to a newly created HTML element.
             * @param {string} element - The type of HTML element to create.
             * @return {boolean} - Returns true upon successful synchronization.
             * @visibility private
             */
            function _syncToNewElement(element) {
                _element = document.createElement(element);
                return true;
            }
        
            /**
             * @notice Syncs the internal state by adding a CSS class to the HTML element.
             * @param {string} class_ - The CSS class to add to the HTML element.
             * @return {boolean} - Returns true upon successful synchronization.
             * @visibility private
             */
            function _syncToClass(class_) {
                _element.classList.add(class_);
                return true;
            }
        
            /**
             * @notice Desyncs the internal state by removing a CSS class from the HTML element.
             * @param {string} class_ - The CSS class to remove from the HTML element.
             * @return {boolean} - Returns true upon successful desynchronization.
             * @visibility private
             */
            function _desyncFromClass(class_) {
                _element.classList.remove(class_);
                return true;
            }
        
            /**
             * @notice Edits the inline styles of the HTML element using the provided stylesheet.
             * @param {object} stylesheet - The style properties to apply to the HTML element.
             * @return {boolean} - Returns true upon successful style modification.
             * @visibility private
             */
            function _editStyle(stylesheet) {
                Object.assign(_element.style, stylesheet);
                return true;
            }
        
            /**
             * @notice Deletes all inline styles of the HTML element, reverting to default styles.
             * @return {boolean} - Returns true upon successful deletion of styles.
             * @visibility private
             */
            function _deleteStyle() {
                _editStyle({all: "revert"});
                return true;
            }
        
            /**
             * @notice Edits the styles of a specific template within the internal style collection.
             * @param {string} template - The template name to edit.
             * @param {object} stylesheet - The style properties to apply to the template.
             * @return {boolean} - Returns true upon successful style modification.
             * @visibility private
             */
            function _editStyleTemplate(template, stylesheet) {
                if (!_style[template]) { _style[template] = {}; }
                Object.assign(_style[template], stylesheet);
                return true;
            }
        
            /**
             * @notice Deletes all styles of a specific template within the internal style collection,
             *         reverting to default styles.
             * @param {string} template - The template name to reset.
             * @return {boolean} - Returns true upon successful deletion of template styles.
             * @visibility private
             */
            function _deleteStyleTemplate(template) {
                _editStyleTemplate(template, {all: "revert"});
                return true;
            }
        
            /**
             * @notice Applies the styles of a specific template within the internal style collection
             *         to the HTML element's inline styles.
             * @param {string} template - The template name to apply.
             * @return {boolean} - Returns true upon successful application of template styles.
             * @visibility private
             */
            function _applyStyleTemplate(template) {
                _editStyle(_style[template]);
                return true;
            }
        
            /**
             * @notice Deletes all inline styles and applies the styles of a specific template
             *         within the internal style collection to the HTML element's inline styles.
             * @param {string} template - The template name to apply after deletion of styles.
             * @return {boolean} - Returns true upon successful deletion and application of styles.
             * @visibility private
             */
            function _deleteAndApplyStyleTemplate(template) {
                _deleteStyle();
                _applyStyleTemplate(template);
                return true;
            }
        
            /**
             * @notice Attaches an event listener to the HTML element and adds a callback function to handle the event.
             * @param {string} event - The event type to listen for.
             * @param {function} callback - The callback function to execute when the event occurs.
             * @return {boolean} - Returns true upon successful addition of the event listener.
             * @visibility private
             */
            function _onEvent(event, callback) {
                if (!_listener[event]) { _listener[event] = []; }
                _listener[event].push(callback);
                _element.addEventListener(event, callback);
                return true;
            }
        
            /**
             * @notice Removes a specific callback function from the event listener of the HTML element.
             * @param {string} event - The event type from which to remove the callback.
             * @param {function} callback - The callback function to remove from the event listener.
             * @return {boolean} - Returns true if the callback was successfully removed, false otherwise.
             * @visibility private
             */
            function _deleteCallbackForEvent(event, callback) {
                _element.removeEventListener(event, callback);
                if (_listener[event]) {
                    const index = _listener[event].indexOf(callback);
                    if (index !== -1) { _listener[event].splice(index, 1); }
                    if (_listener[event].length === 0) { delete _listener[event]; }
                    return true;
                }
                return false;
            }
        
            /**
             * @notice Removes all callback functions for a specific event from the event listener of the HTML element.
             * @param {string} event - The event type for which to remove all callbacks.
             * @return {boolean} - Returns true if all callbacks were successfully removed, false otherwise.
             * @visibility private
             */
            function _deleteEveryCallbackForEvent(event) {
                if (_listener[event]) {
                    _listener[event].forEach(callback => { _element.removeEventListener(event, callback); });
                    _listener[event] = [];
                    if (Object.keys(_listener[event]).length === 0) { delete _listener[event]; }
                    return true;
                }
                return false;
            }
        
            /**
             * @notice Attaches an array of components to the HTML element.
             * @param {Array} components - An array of components to attach.
             * @return {boolean} - Returns true if components were successfully attached, false otherwise.
             * @visibility private
             */
            function _attach(components) {
                if (components.length !== 0) {
                    for (let i = 0; i < components.length; i++) {
                        try {
                            _element.appendChild(components[i].element());
                        } catch {
                            _syncToClass(components[i]);
                        }
                    }
                    return true;
                }
                return false;
            }
        
            return {
        
                /**
                 * @notice Retrieves the HTML element associated with the component.
                 * @return {HTMLElement} - The HTML element of the component.
                 * @visibility public
                 */
                element: function() {
                    return _element;
                },
        
                /**
                 * @notice Syncs the internal state to the specified HTML element.
                 * @param {string} element - The CSS selector of the HTML element.
                 * @return {boolean} - Returns true upon successful synchronization.
                 * @visibility public
                 */
                syncToElement: function(element) {
                    return _syncToElement(element);
                },
        
                /**
                 * @notice Syncs the internal state to a newly created HTML element.
                 * @param {string} element - The type of HTML element to create.
                 * @return {boolean} - Returns true upon successful synchronization.
                 * @visibility public
                 */
                syncToNewElement: function(element) {
                    return _syncToNewElement(element);
                },
        
                /**
                 * @notice Syncs the internal state by adding a CSS class to the HTML element.
                 * @param {string} class_ - The CSS class to add to the HTML element.
                 * @return {boolean} - Returns true upon successful synchronization.
                 * @visibility public
                 */
                syncToClass: function(class_) {
                    return _syncToClass(class_);
                },
        
                /**
                 * @notice Desyncs the internal state by removing a CSS class from the HTML element.
                 * @param {string} class_ - The CSS class to remove from the HTML element.
                 * @return {boolean} - Returns true upon successful desynchronization.
                 * @visibility public
                 */
                desyncFromClass: function(class_) {
                    return _desyncFromClass(class_);
                },
        
                /**
                 * @notice Edits the inline styles of the HTML element using the provided stylesheet.
                 * @param {object} stylesheet - The style properties to apply to the HTML element.
                 * @return {boolean} - Returns true upon successful style modification.
                 * @visibility public
                 */
                editStyle: function(stylesheet) {
                    return _editStyle(stylesheet);
                },
        
                /**
                 * @notice Deletes all inline styles of the HTML element, reverting to default styles.
                 * @return {boolean} - Returns true upon successful deletion of styles.
                 * @visibility public
                 */
                deleteStyle: function() {
                    return _deleteStyle();
                },
        
                /**
                 * @notice Edits the styles of a specific template within the internal style collection.
                 * @param {string} template - The template name to edit.
                 * @param {object} stylesheet - The style properties to apply to the template.
                 * @return {boolean} - Returns true upon successful style modification.
                 * @visibility public
                 */
                editStyleTemplate: function(template, stylesheet) {
                    return _editStyleTemplate(template, stylesheet);
                },
        
                /**
                 * @notice Deletes all styles of a specific template within the internal style collection,
                 *         reverting to default styles.
                 * @param {string} template - The template name to reset.
                 * @return {boolean} - Returns true upon successful deletion of template styles.
                 * @visibility public
                 */
                deleteStyleTemplate: function(template) {
                    return _deleteStyleTemplate(template);
                },
        
                /**
                 * @notice Applies the styles of a specific template within the internal style collection
                 *         to the HTML element's inline styles.
                 * @param {string} template - The template name to apply.
                 * @return {boolean} - Returns true upon successful application of template styles.
                 * @visibility public
                 */
                applyStyleTemplate: function(template) {
                    return _applyStyleTemplate(template);
                },
        
                /**
                 * @notice Deletes all inline styles and applies the styles of a specific template
                 *         within the internal style collection to the HTML element's inline styles.
                 * @param {string} template - The template name to apply after deletion of styles.
                 * @return {boolean} - Returns true upon successful deletion and application of styles.
                 * @visibility public
                 */
                deleteAndApplyStyleTemplate: function(template) {
                    return _deleteAndApplyStyleTemplate(template);
                },
        
                /**
                 * @notice Attaches an event listener to the HTML element and adds a callback function to handle the event.
                 * @param {string} event - The event type to listen for.
                 * @param {function} callback - The callback function to execute when the event occurs.
                 * @return {boolean} - Returns true upon successful addition of the event listener.
                 * @visibility public
                 */
                onEvent: function(event, callback) {
                    return _onEvent(event, callback);
                },
        
                /**
                 * @notice Removes a specific callback function from the event listener of the HTML element.
                 * @param {string} event - The event type from which to remove the callback.
                 * @param {function} callback - The callback function to remove from the event listener.
                 * @return {boolean} - Returns true if the callback was successfully removed, false otherwise.
                 * @visibility public
                 */
                deleteCallbackForEvent: function(event, callback) {
                    return _deleteCallbackForEvent(event, callback);
                },
        
                /**
                 * @notice Removes all callback functions for a specific event from the event listener of the HTML element.
                 * @param {string} event - The event type for which to remove all callbacks.
                 * @return {boolean} - Returns true if all callbacks were successfully removed, false otherwise.
                 * @visibility public
                 */
                deleteEveryCallbackForEvent: function (event) {
                    return _deleteEveryCallbackForEvent(event);
                },
        
                /**
                 * @notice Attaches an array of components to the HTML element.
                 * @param {Array} components - An array of components to attach.
                 * @return {boolean} - Returns true if components were successfully attached, false otherwise.
                 * @visibility public
                 */
                attach: function (components) {
                    return _attach(components);
                }
            }
        }
    
        let _everything = componentTemplate();
        _everything.syncToElement("*");
        _everything.editStyle({
            margin: "0",
            padding: "0",
            boxSizing: "border-box"
        });
        let _html = componentTemplate()
        _html.syncToElement("html");
        let _head = componentTemplate()
        _head.syncToElement("head");
        let _body = componentTemplate()
        _body.syncToElement("body");
        _body.editStyle({
            margin: "0",
            padding: "0"
        });
        let _header;
        let _content;
    
        function _init() {
            /** silicon-dream expects the document to be laid out something like this
            <!DOCTYPE html>
            <html>
                <head> 
                    <!-- any scrips can be added on top of silicon-dream -->
                    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
                    <script type="module" src="../static/js/silicon-stream/init-v1.0.0.js"></script>
                </head>
                <body></body>
            </html>
            */
    
            /// place ui elements that stick to the screen within this element
            _header = componentTemplate();
            _header.syncToNewElement("header");
            _header.editStyleTemplate("default", {
                width: "100vw",
                height: "100vh",
                position: "fixed",
                display: "flex",
                flexDirection: "column",
                margin: "0"
            });
            _header.applyStyleTemplate("default");
    
            /// this one is self explanatory
            _content = componentTemplate()
            _content.syncToNewElement("content");
            
            _body.attach([_header, _content]);
        }
    
        return {
            init: function () {
                return _init();
            }
        };
    }

    function server() {

        return {

        }
    }

    return {
        stream: function () {
            return stream();
        }
    };
}

engine().stream().init();


/**
const componentTemplate = (() => {
    let _element;
    let _style;
    let _listener;

    function _syncToElement(element) {
        _element = document.querySelector(element);
        return true;
    }

    _clone = () => {
        return x += 2;
    }

    return {
        syncToElement: function (element) {
            return _syncToElement(element);
        }
    };
})();

const some = componentTemplate;
const engine = componentTemplate;
some.clone();
some.clone();
engine.clone();
console.log(some.clone(), engine.clone());

*/