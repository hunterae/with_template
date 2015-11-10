require 'helper'

class WithTemplate::ViewAdditionsTest <  MiniTest::Unit::TestCase
  def setup
    @view = ActionView::Base.new(File.dirname(__FILE__) + '/fixtures')
    @block = Proc.new {}
  end

  context "#with_template" do
    should "instantiate a new WithTemplate::Base instance and render the template with it" do
      options={ a: 1, b: 2}
      instance = mock
      instance.expects(:render_template).with("my_template", :template)
      WithTemplate::Base.expects(:new).with(@view, options.with_indifferent_access).returns(instance)
      @view.with_template("my_template", options, &@block)
    end

    should "allow and extract a variable parameter to be passed in the options hash" do
      options = { variable: :my_variable, a: 1, b: 2 }
      instance = mock
      instance.expects(:render_template).with("my_template", :my_variable)
      WithTemplate::Base.expects(:new).with(@view, options.with_indifferent_access.except(:variable)).returns(instance)
      @view.with_template("my_template", options, &@block)
    end

    should "require only the first parameter to be specified" do
      @view.with_template("my_template")
      assert_raises ArgumentError do
        @view.with_template
      end
    end
  end

  context "#with_global_template" do
    context "when @global_template is not yet defined in the view" do
      setup do
        assert @view.instance_variable_get(:@global_template).nil?
      end

      should "instantiate a new WithTemplate::Base instance and render the template with it" do
        options = {a: 1, b: 2}
        instance = mock
        instance.expects(:render_template).with("my_template", :global_template)
        WithTemplate::Base.expects(:new).with(@view, options.with_indifferent_access).returns(instance)
        @view.with_global_template("my_template", options, &@block)
      end

      should "allow and extract a variable parameter to be passed in the options hash" do
        options = { variable: :my_variable, a: 1, b: 2 }
        instance = mock
        instance.expects(:render_template).with("my_template", :my_variable)
        WithTemplate::Base.expects(:new).with(@view, options.with_indifferent_access.except(:variable)).returns(instance)
        @view.with_global_template("my_template", options, &@block)
      end

      should "require only the first parameter to be specified" do
        @view.with_global_template("my_template")
        assert_raises ArgumentError do
          @view.with_global_template
        end
      end
    end

    context "when @global_template is already set on the view" do
      setup do
        @view.global_template
        @global_template = @view.instance_variable_get(:@global_template)
        assert @global_template.present?
        WithTemplate::Base.expects(:new).never
      end

      should "use the existing WithTemplate::Base instance and render the template with it" do
        options={}
        WithTemplate::Base.any_instance.expects(:render_template).with("my_template", :global_template)
        @view.with_global_template("my_template", options, &@block)
      end

      should "allow and extract a variable parameter to be passed in the options hash" do
        WithTemplate::Base.any_instance.expects(:render_template).with("my_template", :something)

        @view.with_global_template("my_template", variable: :something)
        assert @view.global_template.global_options[:variable].blank?
      end

      should "give precedence to the init options set in previous calls to with_global_template" do
        options_1 = { a: 1, b: 2, d: 3 }
        options_2 = { a: 4, b: 5, c: 6 }
        options_3 = { a: 7, b: 8, c: 9, d: 10, e: 11}
        merged = options_3.merge(options_2.merge(options_1)).with_indifferent_access
        @view.with_global_template("my_template", options_1) do
          @view.with_global_template("my_template", options_2) do
            @view.with_global_template("my_template", options_3)
          end
        end
        assert_equal @global_template.init_options, merged
        assert_equal @global_template.global_options, @view.blocks.global_options.merge(merged)
      end
    end
  end

  context "#global_template" do
    should "return a memoized global_template" do
      assert_same @view.global_template, @view.global_template
    end

    should "instantiate the global_template from the global blocks instance" do
      @view.blocks.skip(:some_block)
      @view.blocks.define(:hello) do
        "Goodbye"
      end
      @view.blocks.define(nil) do
        "Anonymous block"
      end
      gt = @view.global_template
      assert gt.skipped_blocks.include?(:some_block)
      assert_equal 1, gt.anonymous_block_number
      assert gt.blocks.include?(:block_1)
      assert gt.blocks.include?(:hello)
      assert_equal "Goodbye", gt.render(:hello)
      assert_equal "Anonymous block", gt.render(:block_1)
      assert_equal @view.blocks.global_options, gt.global_options
    end
  end
end
