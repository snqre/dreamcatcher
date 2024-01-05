export default class Pointer {

    /**
     * @dev Initializes a new Pointer instance with optional configuration.
     * @constructor
     * @param {Object} args - Configuration options.
     * @param {Element} args.selected - The initially selected DOM element.
     * @param {Element} args.lastSelected - The previously selected DOM element.
     * @param {boolean} args.onCreationSelectElement - Whether to select an element on creation.
     * @param {Object} args.commands - Commands configuration for extraction.
     * @param {Object} args.stylesheet - Initial stylesheet for styling.
     */
    constructor(
        args={
            selected: document.querySelector('html'),
            lastSelected: this.selected,
            onCreationSelectElement: false,
            commands: {
                extract: [
                    'ELEMENT_POSITION',
                    'ELEMENT',
                    'CLASS_POSITION',
                    'EVERY_ELEMENT_CLASS',
                    'ID'
                ]
            },
            stylesheet: {}
        }
    ) {
        this.selected = args.selected;
        this.lastSelected = args.lastSelected;
        this.onCreationSelectElement = args.onCreationSelectElement;
        this.extractCommands = args.commands.extract;
        this.stylesheet = args.stylesheet;
    }

    /**
     * @dev Navigates to a specified DOM element and updates the selected and lastSelected properties.
     * @param {Object} args - Navigation options.
     * @param {string} args.element - The CSS selector for the target DOM element.
     */
    goto(args={element: undefined}) {
        this.lastSelected = this.selected;
        this.selected = document.querySelector(args.element);
    }

    /**
     * @dev Injects a new DOM element into the selected element.
     * @param {Object} args - Injection options.
     * @param {string} args.element - The type of element to create.
     */
    inject(args={element: undefined}) {
        let element = document.createElement(args.element);
        this.selected.appendChild(element);
        this.goto({element: element});
    }

    /**
     * @dev Extracts or removes elements based on specified criteria.
     * @param {Object} args - Extraction options.
     * @param {string} args.with - The extraction command (e.g., 'ELEMENT_POSITION', 'ELEMENT', 'CLASS_POSITION', 'EVERY_ELEMENT_CLASS', 'ID').
     * @param {string} args.id - The id of the target element (used with 'ID' command).
     * @param {string} args.element - The CSS selector for the target element (used with relevant commands).
     * @param {string} args.class - The class name for the target element (used with relevant commands).
     * @param {number} args.position - The position of the target element (used with relevant commands).
     */
    extract(args={with: undefined, id: undefined, element: undefined, class: undefined, position: 0}) {
        let element;

        switch (args.with) {

            case this.extractCommands[0]:
                element = this.selected.querySelectorAll(args.element)[args.position];
                this.selected.removeChild(element);
                return;

            case this.extractCommands[1]:
                this.selected.removeChild(args.element);
                return;

            case this.extractCommands[2]:
                element = this.selected.getElementsByClassName(args.class)[args.position];
                this.selected.removeChild(element);
                return;

            case this.extractCommands[3]:
                let elements = this.selected.getElementsByClassName(args.class);
                
                for (let i = 0; i < elements.length; i++) {
                    this.selected.removeChild(elements[i]);
                }

                return;

            case this.extractCommands[4]:
                element = this.selected.getElementById(args.id);
                this.selected.removeChild(element);
                return;

            default:
                element = this.selected;
                this.goto({element: this.selected.parentNode});
                this.selected.removeChild(element);
                return;
        }
    }

    /**
     * @dev Applies or manipulates styles for the selected element or a specified target.
     * @param {Object} args - Style options.
     * @param {string} args.target - The target for applying styles ('current' for the selected element, or a specific target).
     * @param {Object} args.stylesheet - The styles to apply to the target element.
     * @param {boolean} args.reset - Whether to reset styles to default values.
     */
    style(args={target: 'current', stylesheet: {}, reset: false}) {
        if (args.target === 'current') {
            if (args.reset) {
                Object.assign(this.selected.style, {all: 'revert'});
            }

            Object.assign(this.selected.style, args.stylesheet);
            return;
        }

        if (!this.stylesheet[target]) {
            this.stylesheet[target] = args.stylesheet;
            return;
        }

        else {
            if (args.reset) {
                this.stylesheet[target] = {};
                return;
            }

            Object.assign(this.stylesheet[target], args.stylesheet);
            return;
        }
    }

    /**
     * @dev Attaches an event listener to the selected element.
     * @param {Object} args - Event handling options.
     * @param {string} args.event - The type of event to listen for (e.g., 'click', 'mouseover').
     * @param {Function} args.callback - The callback function to execute when the event occurs.
     */
    onEvent(args={event: undefined, callback: () => {}}) {
        this.selected.addEventListener(args.event, args.callback);
    }

    /**
     * @dev Attaches a delegated event listener to the selected element.
     * @param {Object} args - Delegated event handling options.
     * @param {string} args.event - The type of event to listen for (e.g., 'click', 'mouseover').
     * @param {string} args.selector - The CSS selector for the delegated target within the selected element.
     * @param {Function} args.callback - The callback function to execute when the delegated event occurs.
     */
    onEventDelegateTo(args={event: undefined, selector: undefined, callback: () => {}}) {
        this.selected.addEventListener(args.event, (event) => {
            if (event.target.matches(selector)) {
                args.callback(event);
            }
        })
    }

    /**
     * @dev Sets up an Intersection Observer to trigger a callback when the selected element enters the viewport.
     * @param {Object} args - Options for handling visibility changes.
     * @param {Function} args.callback - The callback function to execute when the element enters the viewport.
     * @param {Object} args.options - Intersection Observer options (e.g., root, rootMargin, threshold).
     */
    onEnterView(args={callback: () => {}, options: {root: null, rootMargin: '0px', threshold: .5}}) {
        const observer = new IntersectionObserver((entries, observer) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    args.callback();
                    observer.unobserve(entry.target);
                }
            });
        }, args.options);

        observer.observe(this.selected);
    }

    /**
     * @dev Modifies the text content of the selected element.
     * @param {Object} args - Options for updating text content.
     * @param {string} args.text - The new text content to set.
     * @param {boolean} args.inject - Whether to append the new text to the existing content.
     */
    content(args={text: '', inject: false}) {
        if (inject) {
            this.selected.textContent += args.text;
            return;
        }

        this.selected.textContent = args.text;
    }

    /**
     * @dev Modifies the inner HTML content of the selected element.
     * @param {Object} args - Options for updating inner HTML content.
     * @param {string} args.source - The new HTML content to set.
     * @param {boolean} args.inject - Whether to append the new HTML to the existing content.
     */
    inner(args={source: '', inject: false}) {
        if (args.inject) {
            this.selected.innerHTML += args.source;
            return;
        }

        this.selected.innerHTML = args.source;
    }
}