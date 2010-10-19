module I18n
  def just_raise_that_exception(*args)
    puts '*'*88
    puts args.first
    raise args.first
  end
end

I18n.exception_handler = :just_raise_that_exception 
puts '-'*88
puts 'OLBA'
