# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for uses of request.referrer.
      class RequestReferer < Cop
        MSG = 'Use `request.referer` instead of `request.referrer`'.freeze

        def on_send(node)
          receiver = node.receiver
          if node.method_name == :referrer && receiver.method_name == :request
            add_offense(node.source_range, node.source_range)
          end
        end
      end
    end
  end
end
