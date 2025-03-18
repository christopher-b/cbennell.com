---
title: Rails "Disable-able" Button ViewComponent
date: 2024-06-13
tags:
  - ruby
  - ruby-on-rails
  - stimulus
  - ui
  - viewcomponent
coverImage: wires.webp
---

Here's a simple ViewComponent/Stimulus controller for a disable-able button; that is, a button that you can programmatically disable/enable. You could use this to prevent form submission until all fields are valid.
{: .lead }

If anyone has a better name for this component, please let me know!

## First, the Template

Pretty simple: we render a button in a span, passing along some tag options from the component class.

{% code erb caption="app/components/ui/disableable_button.html.erb" %}
<%=
  tag.span(**container_options) do
    tag.button(**button_options) do
      content
    end
  end
%>
{% endcode %}

## The Component

The component itself has a few things going on.

{% code ruby caption="app/components/ui/disableable_button.rb" %}
module UI
  class DisableableButton < ApplicationComponent
    attr_reader :button_options, :container_options

    def initialize(
      disabled: false,
      disable_events: [],
      enable_events: [],
      disabled_tooltip: "",
      variant: "light",
      tag_options: {}
    )
      container_options = {
        tabindex: 0,
        title: disabled_tooltip,
        class: "d-inline-block",
        data: {
          controller: "disableable-button tooltip",
          action: [
            enable_events.map { |ev| "#{ev}->disableable-button#enable" },
            enable_events.map { |ev| "#{ev}->tooltip#disable" },
            disable_events.map { |ev| "#{ev}->disableable-button#disable" }
          ].flatten.join(" ")
        }
      }

      button_options = {
        disabled: disabled,
        class: %W[btn btn-#{variant}],
        data: {
          "disableable-button-target": "button"
        }
      }

      @container_options = container_options
      @button_options = tag_options.deep_merge(button_options)
    end
  end
end
{% endcode %}

Let's go over the initializer params:

{% code ruby caption="app/components/ui/disableable_button.rb" %}
def initialize(
  disabled: false,
  disable_events: [],
  enable_events: [],
  disabled_tooltip: "",
  variant: "light",
  tag_options: {}
)
{% endcode %}

- disabled: set the default state of the button.

- disable_events/enable_events: a list of events that the component will respond to, which control the state of the button.

- disabled_tooltip: popover text that will appear when hovering over the disabled button. Note that this requires another Stimulus controller ("tooltip") to work.

- variant: passed along as a CSS class to the button. This allows us to set a default variant that can be overridden if required.

- tag_options: additional options that can be passed along to the button tag. Allows arbitrary customization of the button tag.

* * *

We then create the container options hash, which is used to create the container span tag. This is where we set up our tooltip, because the tooltip library I'm using ([Bootstrap](https://getbootstrap.com/docs/5.2/components/tooltips/)) doesn't work on disabled buttons themselves.

We also indicate the stimulus controllers to use ("disableable-button" and "tooltip") and build a list of event listeners, which are flattened into a single string.

{% code ruby caption="app/components/ui/disableable_button.rb" %}
container_options = {
  tabindex: 0,
  title: disabled_tooltip,
  class: "d-inline-block",
  data: {
    controller: "disableable-button tooltip",
    action: [
      enable_events.map { |ev| "#{ev}->disableable-button#enable" },
      enable_events.map { |ev| "#{ev}->tooltip#disable" },
      disable_events.map { |ev| "#{ev}->disableable-button#disable" }
    ].flatten.join(" ")
  }
}
{% endcode %}

* * *

Finally, we set some parameters for the button itself, include indicating that it is the "target" that will be used by the Stimulus controller.

{% code ruby caption="app/components/ui/disableable_button.rb" %}
button_options = {
  disabled: disabled,
  class: %W[btn btn-#{variant}],
  data: {
    "disableable-button-target": "button"
  }
}
{% endcode %}

## Speaking of the Stimulus Controller...

...it's dead simple. It has two methods that set or remove the "disabled" attribute on the button.

{% code js caption="app/javascript/controllers/disableable_button_controller.js" %}
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]

  enable(event) {
    this.buttonTarget.removeAttribute("disabled")
  }

  disable(event) {
    this.buttonTarget.setAttribute("disabled", "disabled")
  }
}
{% endcode %}

## That's it!

Now we render the button.

{% code erb %}
<%= render UI::DisableableButton.new(
  variant: "primary",
  disabled: true,
  enable_events: ["grades:grades_valid@window"],
  disable_events: ["grades:grades_invalid@window"],
  disabled_tooltip: "Please assign grades for all assignments",
  tag_options: {
    data: {
      turbo_frame: "_top",
    }
  }) do %>
  <%= render UI::Icon.new("submit") %>
  Submit Grades
<% end %>
{% endcode %}
