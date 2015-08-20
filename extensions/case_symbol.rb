class Symbol
  def ===(comp)
    if comp.is_a?(Hash)
      comp.has_key?(self)
    else
      super
    end
  end
end
