require 'active_support/core_ext/string/inflections'

module Motel
  module Reservations

    class ReservationSystem

      def self.source(source_type, config = {})
        source_class = "Motel::Reservations::Sources::#{source_type.to_s.camelize}".constantize

        source_instance = source_class.new(config)

        source_instance
      end

    end

  end
end

