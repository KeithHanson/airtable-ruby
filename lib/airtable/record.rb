module Airtable

  class Record
    def initialize(attrs={})
      @columns_map = attrs.keys
      @attrs = HashWithIndifferentAccess.new(Hash[attrs.map { |k, v| [ to_key(k), v ] }])
      @attrs.map { |k, v| define_accessor(k) }
    end

    def id; @attrs["ID"]; end
    def id=(val); @attrs["ID"] = val; end

    # Return given attribute based on name or blank otherwise
    def [](name)
      @attrs.has_key?(to_key(name)) ? @attrs[to_key(name)] : ""
    end

    # Set the given attribute to value
    def []=(name, value)
      @attrs[to_key(name)] = value
      define_accessor(name) unless respond_to?(name)
    end

    def inspect
      "#<Airtable::Record #{attributes.map { |a, v| ":#{a}=>#{v.inspect}" }.join(", ")}>"
    end

    # Hash of attributes with underscored column names
    def attributes; @attrs; end

    # Hash with keys based on airtable original column names
    def fields; Hash[@columns_map.map { |k| [ k, @attrs[to_key(k)] ] }]; end


    def method_missing(name, *args, &blk)
      # Accessor for attributes
      if args.empty? && blk.nil? && @attrs.has_key?(name)
        @attrs[name]
      else
        super
      end
    end

    def respond_to?(method_name, include_private = false)
      @attrs.has_key?(name) || super
    end

    protected

    def to_key(string)
      string.is_a?(Symbol) ? string : underscore(string).to_sym
    end

    def underscore(string)
      string.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        gsub(/\s/, '_').tr("-", "_").downcase
    end

    def define_accessor(name)
      self.class.send(:define_method, name) { @attrs[name] }
    end

  end # Record

end # Airtable
