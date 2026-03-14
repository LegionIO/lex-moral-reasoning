# frozen_string_literal: true

require_relative 'runners/moral_reasoning'

module Legion
  module Extensions
    module MoralReasoning
      class Client
        include Runners::MoralReasoning

        def initialize(**); end
      end
    end
  end
end
