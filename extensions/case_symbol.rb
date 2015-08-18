class Symbol
  def ===(comp)
    if comp.is_a?(Hash)
      comp.has_key?(self)
    end
  end
end
