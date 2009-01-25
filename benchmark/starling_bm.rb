require "benchmark"
require "starling"

puts
puts "=" * 80
puts "== launching first benchmark"
puts "=" * 80
Benchmark.bm do |x|
  x.report("starling") {  }
end
