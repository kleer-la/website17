def to_boolean(string)
  case string
  when true, /\A(true|t|yes|y|1)\z/i
    true
  when false, nil, '', /\A(false|f|no|n|0)\z/i
    false
  else
    raise ArgumentError, "invalid value for Boolean: \"#{string}\""
  end
end
