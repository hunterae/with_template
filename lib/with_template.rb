require "blocks"
require "action_view"

module WithTemplate
  autoload :Base,          "with_template/base"
  autoload :ViewAdditions, "with_template/view_additions"
end

ActionView::Base.send :include, WithTemplate::ViewAdditions
