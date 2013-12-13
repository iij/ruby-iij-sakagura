module IIJ
  module Sakagura
    module Core
      def self.hash_to_query(hash)
        HashToQueryConverter.convert_hash(hash)
      end
      module HashToQueryConverter
        def self.convert_hash(hash, prefix = nil)
          hash.inject({}) do |stow, pair|
            k, v = pair
            full_key = (prefix ? "#{prefix}." : "") + k

            if v.kind_of? Array
              stow.merge(self.convert_array(v, full_key))
            elsif v.kind_of? Hash
              stow.merge(self.convert_hash(v, full_key))
            else
              stow.merge({ full_key => v })
            end
          end
        end

        def self.convert_array(arr, prefix)
          ret = {}
          arr.each.with_index(1) do |v, i|
            full_key = "#{prefix}.#{i}"
            if v.kind_of? Array
              ret.merge!(self.convert_array(v, full_key))
            elsif v.kind_of? Hash
              ret.merge!(self.convert_hash(v, full_key))
            else
              ret[full_key] = v
            end
          end
          ret
        end
      end
    end
  end
end
