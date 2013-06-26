module ROM
  class Session

    # @api private
    class Mapper < ROM::Mapper
      include Proxy, Concord::Public.new(:mapper, :tracker, :identity_map)

      # @api private
      def dirty?(object)
        identity_map.fetch_tuple(identity(object)) != dump(object)
      end

      # @api private
      def load(tuple)
        identity = mapper.loader.identity(tuple)
        identity_map.fetch_object(identity) { load_and_track(identity, tuple) }
      end

      private

      def load_and_track(identity, tuple)
        object = mapper.load(tuple)

        identity_map.store(identity, object, tuple)
        tracker.store_persisted(object, self)

        identity_map[identity]
      end

    end # Mapper

  end # Session
end # ROM
