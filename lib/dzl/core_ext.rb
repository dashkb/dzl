class Hash
  def try_keys(*keys)
    keys.inject(self) { |c, k| c.has_key?(k) ? c[k] : nil }
  end

  def recursively_symbolize_keys!
    self.symbolize_keys!
    self.values.each do |v|
      if v.is_a?(Hash)
        v.recursively_symbolize_keys!
      end
    end
    self
  end
end