/** block-v1.0.0 */

const componentTemplate = (() => {
    let element;
    let style;
    let listener;
    
    const _doSomething = () => {
        
    };

    function public_() {
        x: () => {
            return;
        }
    };

    return public_;
});

componentTemplate.x();

export default class Block {
    constructor() {
        this.format();
    }

    /**
     * Resets the element, style, and listener properties to their default values.
     * 
     * This method sets the element property to null and resets the style and listener
     * properties to empty objects, effectively clearing any previous configurations.
     *
     * @returns {boolean} - True if the properties were successfully reset.
     */
    format() {
        this.element = null;
        this.style = {};
        this.listener = {};
        return true;
    }

    /**
     * Creates a shallow copy of the associated DOM element.
     * 
     * This method uses the cloneNode method to create a new DOM element with the same
     * attributes and children as the original.
     *
     * @returns {HTMLElement} - A shallow copy of the associated DOM element.
     */
    clone() {
        return this.element.cloneNode(true);
    }

    /**
     * Synchronizes the instance with a new DOM element.
     * 
     * This method allows you to associate the instance with a different DOM element,
     * updating the internal reference to the element.
     *
     * @param {string} element - The CSS selector of the new DOM element to synchronize with.
     * @returns {boolean} - True if the synchronization was successful.
     */
    syncToElement(element) {
        this.element = document.querySelector(element);
        return true;
    }

    /**
     * Synchronizes the instance with a new dynamically created DOM element.
     * 
     * This method allows you to associate the instance with a new DOM element created
     * using the specified element type, updating the internal reference to the element.
     *
     * @param {string} element - The type of the new DOM element to synchronize with.
     * @returns {boolean} - True if the synchronization was successful.
     */
    syncToNewElement(element) {
        /**
         * Remember that this element does not exist on the document until it
         * has been attached to a parent element. All edits and styles changes 
         * require an element to work, so sync to a new element if
         * the element being targeted does not exist on the document yet.
         */
        this.element = document.createElement(element);
        return true;
    }

    /**
     * Synchronizes the instance with an existing DOM element by adding a CSS class.
     * 
     * This method allows you to associate the instance with an existing DOM element
     * by adding the specified CSS class to the element, updating the internal reference.
     *
     * @param {string} class_ - The CSS class to add to the existing DOM element.
     * @returns {boolean} - True if the synchronization was successful.
     */
    syncToClass(class_) {
        this.element.classList.add(class_);
        return true;
    }

    /**
     * Desynchronizes the instance from a CSS class of an existing DOM element.
     * 
     * This method allows you to disassociate the instance from an existing DOM element
     * by removing the specified CSS class from the element, updating the internal reference.
     *
     * @param {string} class_ - The CSS class to remove from the existing DOM element.
     * @returns {boolean} - True if the desynchronization was successful.
     */
    desyncFromClass(class_) {
        this.element.classList.remove(class_);
        return true;
    }

    /**
     * Edits the style of the associated DOM element.
     * 
     * This method does not reset previous styles before making edits. It will only
     * edit the given properties of the element's stylesheet and not interpret
     * the stylesheet as a new sheet from scratch. This means that the stylesheet
     * will only edit and stack on top of the effects of any previous edits.
     * 
     * This can be used in combination with deleteStyle call to reset a style before
     * applying new styles to the element's stylesheet.
     *
     * @param {Object} stylesheet - The stylesheet to apply to the element.
     * @returns {boolean} - True if the style was successfully edited.
     */
    editStyle(stylesheet) {
        /**
         * Does not reset previous styles before making edits. This will only
         * edit the given properties of the element's stylesheet and not
         * interprate the stylesheet as a new sheet from scratch. This means
         * that the stylesheet will only edit and stack on top of the effects
         * of any previous edits.
         */
        try {
            /**
             * Try to interprate stylesheet as a stylesheet class.
             */
            Object.assign(this.element.style, stylesheet.compile());
        } catch {
            /**
             * If the above fails then interprate stylesheet as an object.
             */
            Object.assign(this.element.style, stylesheet);
        }
        return true;
    }

    /**
     * Deletes all styles applied to the associated DOM element.
     * 
     * This method effectively reverts all styles to their default values.
     *
     * @returns {boolean} - True if the styles were successfully deleted.
     */
    deleteStyle() {
        this.editStyle({all: "revert"});
        return true;
    }

    /**
     * Edits a stylesheet template for a specific event or state.
     * 
     * This method allows you to update the stylesheet template associated with a
     * specific event or state by merging the specified stylesheet into it.
     *
     * @param {string} template - The name of the stylesheet template to edit.
     * @param {Object} stylesheet - The stylesheet to merge into the template.
     * @returns {boolean} - True if the stylesheet template was successfully edited.
     */
    editStyleTemplate(template, stylesheet) {
        /**
         * Applies the same logic as editStyle but for stylesheet templates which can
         * be used for events or to define a state for an event that might fire based
         * on an event.
         * 
         * Please use "default" to signify the base state of the block when
         * not events are to be applied to it.
         */
        try {
            /**
             * Try to interprate stylesheet as a stylesheet class.
             */
            Object.assign(this.style[template], stylesheet.compile());
        } catch {
            /**
             * If the above fails then interprate stylesheet zas an object.
             */
            Object.assign(this.style[template], stylesheet);
        }
        return true;
    }

    /**
     * Deletes a stylesheet template for a specific event or state.
     * 
     * This method allows you to reset the stylesheet template associated with a
     * specific event or state, reverting it to its default or initial state.
     *
     * @param {string} template - The name of the stylesheet template to delete.
     * @returns {boolean} - True if the stylesheet template was successfully deleted.
     */
    deleteStyleTemplate(template) {
        this.editStyleTemplate(template, {all: "revert"});
        return true;
    }

    /**
     * Applies a predefined style template to the instance.
     * 
     * This method removes the current style and applies the style
     * defined in the specified template, effectively updating the appearance.
     *
     * @param {string} template - The name of the predefined style template to apply.
     * @returns {boolean} - True if the style template was successfully applied.
     */
    applyStyleTemplate(template) {
        /**
         * Delete current style and apply the style of the 
         * template stylesheet.
         */
        this.deleteStyle();
        this.editStyle(this.style[template]);
    }

    /**
     * Registers a callback function for a specific event.
     * 
     * This method initializes the listener for the specified event as an array
     * if it has not been initialized before. It then adds the provided callback
     * to the array of other callbacks for this event. This allows for easy removal
     * of all callbacks associated with the event.
     * 
     * Note: If the callback is an anonymous function, removing it will be impossible.
     * It is recommended to avoid using anonymous functions where possible to maintain
     * flexibility in managing callbacks.
     *
     * @param {string} event - The type of event to listen for.
     * @param {function} callback - The function to be called when the event occurs.
     * @returns {boolean} - True if the callback was successfully registered for the event.
     */
    onEvent(event, callback) {
        /**
         * Initialize the listener for this event as an array if
         * it has not been initialized before.
         */
        if (!this.listener[event]) {
            this.listener[event] = [];
        }
        /**
         * Add this callback to the array of other callbacks that
         * this event has. We do this so that it is easy to completely
         * delete all callbacks from an event.
         * 
         * If the callback is an anonymous function this will be
         * impossible. It is better to avoid using anonimous functions
         * where possible to keep this class dynamic.
         */
        this.listener[event].push(callback);
        this.element.addEventListener(event, callback);
        return true;
    }

    /**
     * Removes a specific callback function associated with an event.
     * 
     * This method removes the provided callback function from the event listener
     * for the specified event. If the event has no more callbacks, the listener
     * array for that event is also deleted.
     *
     * @param {string} event - The type of event to remove the callback from.
     * @param {function} callback - The function to be removed from the event listener.
     * @returns {boolean} - True if the callback was successfully removed from the event.
     *                     False if no callbacks were found for the specified event.
     */
    deleteCallbackForEvent(event, callback) {
        this.element.removeEventListener(event, callback);
        if (this.listener[event]) {
            const index = this.listener[event].indexOf(callback);
            if (index !== -1) {
                this.listener[event].splice(index, 1);
            }
            if (this.listener[event].length === 0) {
                delete this.listener[event];
            }
            return true;
        }
        /**
         * No callbacks were found for this event.
         */
        return false;
    }

    /**
     * Removes all callbacks associated with a specific event.
     * 
     * This method removes all callback functions from the event listener
     * for the specified event. If the event has no more callbacks, the listener
     * array for that event is also deleted.
     *
     * @param {string} event - The type of event to remove all callbacks from.
     * @returns {boolean} - True if all callbacks were successfully removed from the event.
     *                     False if no callbacks were found for the specified event.
     */
    deleteEveryCallbackForEvent(event) {
        if (this.listener[event]) {
            this.listener[event].forEach(callback => {
                this.element.removeEventListener(event, callback);
            });
            this.listener[event] = [];
            if (Object.keys(this.listener[event]).length === 0) {
                delete this.listener[event];
            }
            return true;
        }
        /**
         * No callbacks were found for this event.
         */
        return false;
    }

    /**
     * Attaches an array of blocks to the current element.
     * 
     * This method attaches each block in the provided array to the
     * current element. If an element in the array is not a block class,
     * it is interpreted as a class and added to the current element's
     * classList.
     *
     * @param {Array} blocks - An array of blocks or classes to attach to the element.
     * @returns {boolean} - True if at least one block was successfully attached.
     *                     False if the array is empty or no valid blocks were found.
     */
    attach(blocks) {
        if (blocks.length !== 0) {
            for (let i = 0; i < blocks.length; i++) {
                try {
                    /**
                     * Interprate as a block class.
                     */
                    this.element.appendChild(blocks[i].element);
                } catch {
                    /**
                     * If the above fails then interprate it as a class.
                     */
                    this.syncToClass(blocks[i]);
                }
            }
            return true;
        }
        /**
         * No block elements were detected.
         */
        return false;
    }

    enableDragAndSnapToGrid() {
        let isDragging = false;
        const blockSize = 110;
        this.onEvent("mousedown", (event) => {
            isDragging = true;
            const offsetX = event.clientX - this.element.getBoundingClientRect().left;
            const offsetY = event.clientY - this.element.getBoundingClientRect().top;
            const dragMove = (event) => {
                if (isDragging) {
                    const x = event.clientX - offsetX;
                    const y = event.clientY - offsetY;
                    this.editStyle({transform: `translate(${x}px, ${y}px)`});
                }
            };
            const dragEnd = () => {
                isDragging = false;
                const gridX = Math.round(this.element.getBoundingClientRect().left / blockSize) * blockSize;
                const gridY = Math.round(this.element.getBoundingClientRect().top / blockSize) * blockSize;
                this.editStyle({transform: `translate(${gridX}px, ${gridY}px)`});
                this.deleteCallbackForEvent("mousemove", dragMove);
                this.deleteCallbackForEvent("mouseup", dragEnd);
            };
            this.onEvent("mousemove", dragMove);
            this.onEvent("mouseup", dragEnd);
        });
        return true;
    }
}