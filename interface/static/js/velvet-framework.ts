let velvet = {
  wrappedElement:
    () => {
      class WrappedElement {
        runtime: any;
        constructor() {
          this.runtime = {
            element: undefined
          }
        }

        element():Element {
          return this
            .runtime
            .element
        }

        syncToElement(
          selector:string, 
          position:number
        ):this {
          this
            .runtime
            .element
              = document
                .querySelectorAll(selector)[position];
          return this;
        }

        syncToNewElement(
          tag:string
        ):this {
          this
            .runtime
            .element
              = document
                .createElement(tag);
          return this;
        }

        syncToClassName(
          className:string
        ):this {
          this
            .runtime
            .element
            .classList
            .add(className);
          return this;
        }

        on(
          trigger:string,
          logic:
            () => void
        ):this {
          this
            .runtime
            .element
            .addEventListener(
              trigger,
              logic
            );
          return this;
        }

        onEnter(
          logic:
            () => void,
          options:any
        ):this {
          let obs = new IntersectionObserver(
            (
              entries,
              observer
            ) => {
              entries
                .forEach(
                  entry => {
                    if (
                      entry
                        .isIntersecting
                    ) {
                      logic();
                      obs.unobserve(
                        entry
                          .target
                      );
                    }
                  }
                )
            },
            options
          )
          obs.observe(
            this
              .runtime
              .element
          );
          return this;
        }

        onRepeat(
          logic:
            () => void,
          wait:number
        ):this {
          setInterval(
            logic,
            wait
          );
          return this;
        }

        setContent(
          content:string
        ):this {
          this
            .runtime
            .element
            .textContent
              = content;
          return this;
        }

        render(
          stylesheet:object
        ):this {
          Object
            .assign(
              this
                .runtime
                .element
                .style,
              stylesheet
            );
          return this;
        }

        setInnerHTML(
          source:string
        ):this {
          this
            .runtime
            .element
            .innerHTML
              = source;
          return this;
        }

        inject(
          wrappedElements:Array<any>
        ):this {
          if (
            wrappedElements
              .length
                === 0
          ) {
            return this;
          }
          for (
            let i = 0;
            i < wrappedElements
              .length;
            i++
          ) {
            let wrappedElement = wrappedElements[i];
            this
              .runtime
              .element
              .appendChild(
                wrappedElement
                  .element()
              );
          }
          return this;
        }
      }
      return new WrappedElement();
    },
  blueprint: {
    staticAny:
      () => {
        return this
          .wrappedElement()
          .syncToNewElement('div')

      }
  }
}