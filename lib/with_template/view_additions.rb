module WithTemplate
  module ViewAdditions
    def with_template(template, options={}, &block)
      options = options.with_indifferent_access
      template_variable = options.delete(:variable) || :template
      WithTemplate::Base.new(self, options).render_template(template, template_variable, &block)
    end

    def with_global_template(template, options={}, &block)
      options = options.with_indifferent_access
      variable = options.delete(:variable) || :global_template
      if @global_template.present?
        @global_template.init_options.reverse_merge!(options)
        @global_template.global_options.merge!(@global_template.init_options)
      else
        @global_template = WithTemplate::Base.new(self, options)
      end
      @global_template.render_template(template, variable, &block)
    end

    def global_template
      if @global_template.blank?
        @global_template = WithTemplate::Base.new(self)
        @global_template.blocks = blocks.blocks
        @global_template.skipped_blocks = blocks.skipped_blocks
        @global_template.anonymous_block_number = blocks.anonymous_block_number
      end
      @global_template
    end
  end
end
