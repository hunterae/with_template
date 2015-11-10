require 'helper'

class WithTemplate::BaseTest <  MiniTest::Unit::TestCase
  def setup
    @view = ActionView::Base.new
    @builder = WithTemplate::Base.new(@view)
  end

  context "#render_template" do
    should "attempt to render a partial specified as the :template parameter" do
      @view.expects(:render).with{ |template, options| template == "my_template"}
      @builder.render_template("my_template")
    end

    should "set all of the global options as local variables to the partial it renders" do
      @view.expects(:render).with { |template, options| template == 'some_template' && options[:template] == @builder }
      @builder.render_template("some_template")
    end

    should "capture the data of a block if a block has been specified" do
      block = Proc.new { |options| "my captured block" }
      @view.expects(:render).with { |tempate, options| options[:captured_block] == "my captured block" }
      @builder.render_template("template", &block)
    end

    should "add a variable to the partial called 'template' as a pointer to the WithTemplate::Base instance" do
      @view.expects(:render).with { |template, options| options[:template] == @builder }
      @builder.render_template("some_template")
    end

    should "allow the variable in the partial to be overridden in the options hash" do
      builder = WithTemplate::Base.new(@view, variable: :new_template_variable)
      @view.expects(:render).with { |template, options| options[:new_template_variable] == builder }
      builder.render_template("some_template")
    end

    should "allow the variable in the partial to be overridden as a parameter" do
      builder = WithTemplate::Base.new(@view)
      @view.expects(:render).with { |template, options| options[:new_template_variable] == builder }
      builder.render_template("some_template", :new_template_variable)
    end
  end

  context "#queue" do
    should "store all queued blocks in the queued_blocks array" do
      assert @builder.queued_blocks.empty?
      @builder.queue :test_block
      assert_equal 1, @builder.queued_blocks.length
      assert_equal :test_block, @builder.queued_blocks.map(&:name).first
    end

    should "convert a string block name to a symbol" do
      @builder.queue "test_block"
      assert_equal :test_block, @builder.queued_blocks.map(&:name).first
    end

    should "queue blocks as Blocks::Container objects" do
      @builder.queue :test_block, :a => 1, :b => 2, :c => 3
      container = @builder.queued_blocks.first
      assert container.is_a?(Blocks::Container)
      assert_equal :test_block, container.name
      assert_equal ({:a => 1, :b => 2, :c => 3}), container.options
    end

    should "not require a name for the block being queued" do
      @builder.queue
      @builder.queue
      assert_equal 2, @builder.queued_blocks.length
      assert_equal :block_1, @builder.queued_blocks.map(&:name).first
      assert_equal :block_2, @builder.queued_blocks.map(&:name).second
    end

    should "anonymously define the name of a block if not specified" do
      @builder.queue
      @builder.queue :my_block
      @builder.queue
      assert_equal :block_1, @builder.queued_blocks.map(&:name).first
      assert_equal :my_block, @builder.queued_blocks.map(&:name).second
      assert_equal :block_2, @builder.queued_blocks.map(&:name).third
    end

    should "store queued blocks in the order in which they are queued" do
      @builder.queue :block1
      @builder.queue :block3
      @builder.queue :block2
      assert_equal :block1, @builder.queued_blocks.map(&:name).first
      assert_equal :block3, @builder.queued_blocks.map(&:name).second
      assert_equal :block2, @builder.queued_blocks.map(&:name).third
    end

    should "allow a definition to be provided for a queued block" do
      block = Proc.new do |options| end
      @builder.queue :test_block, &block
      container = @builder.queued_blocks.first
      assert_equal block, container.block
    end
  end
end
