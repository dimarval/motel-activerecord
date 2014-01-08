require 'active_support/core_ext/string/inflections'

module Motel
  module Reservations

    module ReservationSystem

      def self.source=(source)
        @@source = source
      end

      def self.source
        @@source ||= Sources::Default.new
      end

      def self.source_configurations(source_type, config = {})
        source_class = "Motel::Reservations::Sources::#{source_type.to_s.camelize}".constantize

        source_instance = source_class.new(config)

        self.source = source_instance
      end

    end

  end
end

