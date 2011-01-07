Webrat.configure do |c|
  c.mode = :rack
  c.open_error_files = false # prevents webrat from opening the browser
end
