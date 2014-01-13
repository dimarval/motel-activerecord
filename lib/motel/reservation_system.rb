require 'active_support/core_ext/string/inflections'

module Motel

  class ReservationSystem

    attr_accessor :source

    def initialize(source = nil)
      @source = source || Sources::Default.new
    end

    def source_configurations(config)
      source_type = config.delete(:source)
      source_class = "Motel::Sources::#{source_type.to_s.camelize}".constantize

      source_instance = source_class.new(config)

      self.source = source_instance
    end

  end

end

