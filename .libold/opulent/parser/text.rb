# @SugarCube
module Opulent
  # @Parser
  module Parser
    # @Text
    module Text
      # Match one line or multiline, escaped or unescaped text
      #
      def text(parent, indent = nil, only_multiline = true)
        indent = indent || accept_unstripped(:indent) || ""

        # Try to see if we can match a multiline operator. If we can accept only
        # multiline, which is the case for filters, undo the operation.
        if accept_line :multiline
          multiline = true
        elsif only_multiline
          return undo indent unless lookahead :print_lookahead
        end

        indent = indent.size

        # Unescaped Print Eval
        if (text_feed = accept_unstripped :unescaped_print)
          text_node = @create.print(text_feed.strip, false, parent, indent)
        # Escaped Print Eval
        elsif (text_feed = accept_unstripped :escaped_print)
          text_node = @create.print(text_feed.strip, true, parent, indent)
        # Unescaped Text
        elsif (text_feed = accept_unstripped :unescaped_text)
          text_node = @create.text(text_feed.strip, false, parent, indent)
        # Escaped Text
        elsif (text_feed = accept_unstripped :escaped_text)
          text_node = @create.text(text_feed.strip, true, parent, indent)
        else
          # Undo by adding the found intentation back
          undo indent
          return nil
        end


        if text_node
          text_node
          if multiline
            text_node.value += accept_unstripped(:newline) || ""
            text_node.value += get_indented_lines(indent)

            text_node
          else
            accept_unstripped :newline

            text_node.value.strip!
            text_node.value = text_node.value[1..-1] if text_node.value[0] == '\\'
            text_node.value.size > 0 ? text_node : nil
          end
        else
          return nil
        end
      end

      # Match one line or multiline, escaped or unescaped text
      #
      def html_text(parent)
        indent = accept_unstripped(:indent) || ""
        indent_size = indent.size

        if (text_feed = accept_unstripped :html_text)
          text_node = @create.text(text_feed.strip, false, parent, indent_size)
          accept_unstripped :newline
          pp text_feed
          return text_node
        else
          return undo indent
        end
      end

      # Match a whitespace by preventing code trimming
      #
      def whitespace(required = false)
        accept_unstripped :whitespace, required
      end

      # Gather all the lines which have higher indentation than the one given as
      # parameter and put them into the buffer
      #
      # @param indentation [Fixnum] parent node strating indentation
      #
      def get_indented_lines(indent)
        buffer = ''

        # Get the next indentation after the parent line
        # and set it as primary indent
        first_indent = lookahead(:indent_lookahead, false).size
        next_indent = first_indent

        # While the indentation is smaller, add the line feed  to our buffer
        while next_indent > indent
          # Get leading whitespace trimmed with first_indent's size
          next_line_indent = accept_unstripped(:indent)[first_indent..-1] || ""
          next_line_indent = next_line_indent.size

          # Add next line feed, prepend the indent and append the newline
          buffer += " " * next_line_indent if next_line_indent > 0
          buffer += accept_unstripped(:line_feed) || ""
          buffer += accept_unstripped(:newline) || ""

          # Get next indentation and repeat
          next_indent = lookahead(:indent_lookahead, false).size
        end

        buffer
      end
    end
  end
end