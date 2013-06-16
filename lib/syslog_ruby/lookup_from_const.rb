module SyslogRuby
  module LookupFromConst
    def setup_constants(dst)
      constants.each do |pri|
        cval = const_get pri

        dst[pri] = cval
        dst[pri.downcase] = cval

        dst[:"LOG_#{pri.to_s}"] = cval
        dst[:"LOG_#{pri.downcase.to_s}"] = cval
        const_set :"LOG_#{pri.to_s}", cval

        dst[pri.to_s] = cval
        dst[pri.downcase.to_s] = cval

        dst[cval] = cval
      end

      self.class.send(:define_method, :keys) do
        dst.keys
      end

      self.class.send(:define_method, :[]) do |key|
        value_none = const_get :NONE
        dst.fetch(key, value_none)
      end

      self.class.send(:define_method, :[]=) do |key, value|
        raise RuntimeError.new "#{self.class} is read only"
      end
    end
  end
end
