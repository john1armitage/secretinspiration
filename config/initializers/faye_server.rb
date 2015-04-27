Thread.new do
 # system("rackup lib/faye.ru -s thin -p 9292 -E production")
  system("rackup lib/faye.ru -E production")
end