module Kernel
  def is(symbol)
    symbol.to_proc
  end
end
