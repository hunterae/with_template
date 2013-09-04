module WithTemplate
  module ViewAdditions
    module ClassMethods
      def with_template(template, &block)
        WithTemplate::Base.new(self).render_template(template, &block)
      end
    end
  end
end