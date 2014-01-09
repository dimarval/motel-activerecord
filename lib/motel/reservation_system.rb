require 'active_support/core_ext/string/inflections'

module Motel
  module ReservationSystem

    def self.source=(source)
      @@source = source
    end

    def self.source
      @@source ||= Sources::Default.new
    end

    def self.source_configurations(config)
      source_type = config.delete(:source)
      source_class = "Motel::Sources::#{source_type.to_s.camelize}".constantize

      source_instance = source_class.new(config)

      self.source = source_instance
    end

  end
end

