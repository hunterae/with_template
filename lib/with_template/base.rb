module WithTemplate
  class Base < Blocks::Base
    # Array of Blocks::Container objects, storing the order of blocks as they were queued
    attr_accessor :queued_blocks

    # Options that were passed into this instance of WithTemplate for use when merging options with a parent instance
    attr_accessor :init_options

    # Render a partial, treating it as a template, and any code in the block argument will impact how the template renders
    #   <%= WithTemplate::Base.new(self).render_template("shared/wizard") do |blocks| %>
    #     <% blocks.queue :step1 %>
    #     <% blocks.queue :step2 do %>
    #       My overridden Step 2 |
    #     <% end %>
    #     <% blocks.queue :step3 %>
    #     <% blocks.queue do %>
    #       | Anonymous Step 4
    #     <% end %>
    #   <% end %>
    #
    #   <!-- In /app/views/shared/wizard -->
    #   <% blocks.define :step1 do %>
    #     Step 1 |
    #   <% end %>
    #
    #   <% blocks.define :step2 do %>
    #     Step 2 |
    #   <% end %>
    #
    #   <% blocks.define :step3 do %>
    #     Step 3
    #   <% end %>
    #
    #   <% blocks.queued_blocks.each do |block| %>
    #     <%= blocks.render block %>
    #   <% end %>
    #
    #   <!-- Will render: Step 1 | My overridden Step 2 | Step 3 | Anonymous Step 4-->
    # Options:
    # [+partial+]
    #   The partial to render as a template
    # [+block+]
    #   An optional block with code that affects how the template renders
    def render_template(partial, variable=nil, &block)
      render_options = global_options.clone
      render_options[:captured_block] = view.capture(self, &block) if block_given?
      render_options[:options] = render_options
      variable ||= render_options.delete(:variable) || :template
      render_options[variable] = self

      view.render partial, render_options
    end

    # Queue a block for later rendering, such as within a template.
    #   <%= UseTemplate::Base.new(self).render_template("shared/wizard") do |template| %>
    #     <% template.queue :step1 %>
    #     <% template.queue :step2 do %>
    #       My overridden Step 2 |
    #     <% end %>
    #     <% template.queue :step3 %>
    #     <% template.queue do %>
    #       | Anonymous Step 4
    #     <% end %>
    #   <% end %>
    #
    #   <!-- In /app/views/shared/wizard -->
    #   <% template.define :step1 do %>
    #     Step 1 |
    #   <% end %>
    #
    #   <% template.define :step2 do %>
    #     Step 2 |
    #   <% end %>
    #
    #   <% template.define :step3 do %>
    #     Step 3
    #   <% end %>
    #
    #   <% template.queued_blocks.each do |block| %>
    #     <%= template.render block %>
    #   <% end %>
    #
    #   <!-- Will render: Step 1 | My overridden Step 2 | Step 3 | Anonymous Step 4-->
    # Options:
    # [+*args+]
    #   The options to pass in when this block is rendered. These will override any options provided to the actual block
    #   definition. Any or all of these options may be overriden by whoever calls "blocks.render" on this block.
    #   Usually the first of these args will be the name of the block being queued (either a string or a symbol)
    # [+block+]
    #   The optional block definition to render when the queued block is rendered
    def queue(*args, &block)
      self.queued_blocks << self.define_block_container(*args, &block)
      nil
    end

    protected

    def initialize(view, options={})
      self.queued_blocks = []
      self.init_options = options
      super(view, options)
    end
  end
end
