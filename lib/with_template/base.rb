module WithTemplate
  class Base < Blocks::Base
    # Array of Blocks::Container objects, storing the order of blocks as they were queued
    attr_accessor :queued_blocks

    # A Hash of queued_blocks arrays; a new array is started when method_missing is invoked
    attr_accessor :block_groups

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
    def render_template(partial, &block)
      render_options = global_options.clone
      render_options[self.variable] = self
      render_options[:captured_block] = view.capture(self, &block) if block_given?

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
      self.block_groups = {}
      super(view, options.reverse_merge(:variable => :template))
    end

    # If a method is missing, we'll assume the user is starting a new block group by that missing method name
    def method_missing(m, *args, &block)
      options = args.extract_options!

      # If the specified block group has already been defined, it is simply returned here for iteration.
      #  It will consist of all the blocks used in this block group that have yet to be rendered,
      #   as the call for their use occurred before the template was rendered (where their definitions likely occurred)
      return self.block_groups[m] unless self.block_groups[m].nil?

      # Allows for nested block groups, store the current block positions array and start a new one
      original_queued_blocks = self.queued_blocks
      self.queued_blocks = []
      self.block_groups[m] = self.queued_blocks

      # Capture the contents of the block group (this will only capture block definitions and block renders; it will ignore anything else)
      view.capture(global_options.merge(options), &block) if block_given?

      # restore the original block positions array
      self.queued_blocks = original_queued_blocks
      nil
    end
  end
end
