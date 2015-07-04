require_relative 'compiler/node.rb'

# @Opulent
module Opulent
  # @Compiler
  module Compiler
    Buffer = :_buffer

    # @Singleton
    class << self
      # All node Objects (Array) must follow the next convention in order
      # to make parsing faster
      #
      # [:node_type, :value, :attributes, :children, :indent]
      #
      def setup
        @type = 0
        @value = 1
        @options = 2
        @children = 3
        @indent = 4
      end

      # Compile input nodes, replace them with their definitions and
      #
      def compile(root, context)
        # Compiler generated code
        @code = ""
        @generator = ""

        # Start building up the code from the root node
        root[@children].each do |node|
          generate node, context
        end

        pp @code

        return @code
      end

      private

      def generate(current, context)
        case current[@type]

        # Generate code for static nodes, by appending their name and
        # evaluating the node's attributes
        when :node
          node(current, context)
        end
      end

      def push(string)
        "#{Buffer} << #{string.inspect}"
      end
    end
  end
end
