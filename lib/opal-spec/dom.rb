module OpalSpec
  class Element
    def initialize(tag = 'div')
      `this.el = document.createElement(tag)`
    end

    def class_name=(class_name)
      `this.el.className = class_name`
    end

    def html=(html)
      `this.el.innerHTML = html`
    end

    def append(child)
      `this.el.appendChild(child.el)`
    end

    def hide
      `this.el.style.display = 'none'`
    end

    def show
      `delete this.el.style.display`
    end

    def append_to_head
      `document.head.appendChild(this.el)`
    end

    def append_to_body
      `document.body.appendChild(this.el)`
    end

    def style(key, val)
      `this.el.style[key] = val`
    end
  end
end