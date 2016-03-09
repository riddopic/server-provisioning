# encoding: UTF-8

module Server
  class Exceptions
    #
    # Raise when we couldn't found an specific attribute
    #
    class AttributeNotFound < RuntimeError
      attr_reader :attr

      def initialize(attr)
        @attr = attr
      end

      def to_s
        "Attribute '#{@attr}' not found"
      end
    end
  end
end
