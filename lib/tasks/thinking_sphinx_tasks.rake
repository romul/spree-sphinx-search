begin
  require 'thinking_sphinx/tasks'
rescue LoadError
  puts "WARNING: thinking-sphinx gem appears to be unavailable. Please install with rake gems:install."
end
