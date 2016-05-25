# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for uses of request.referrer.
      class RequestReferer < Cop
        include ConfigurableEnforcedStyle

        def on_send(node)
          if offense?(node)
            add_offense(node.source_range, node.source_range, message)
          end
        end

        def autocorrect(node)
          ->(corrector) { corrector.replace(node, "request.#{style}") }
        end

        private

        def offense?(node)
          receiver = node.receiver
          node.method_name == wrong_syntax && receiver.method_name == :request
        end

        def message
          "Use `request.#{style}` instead of `request.#{wrong_syntax}`"
        end

        def wrong_syntax
          style == :referer ? :referrer : :referer
        end
      end
    end
  end
end
