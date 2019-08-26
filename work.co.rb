require 'fileutils'
require 'json'
require 'open-uri'
require 'pry'

LOOP_UNTIL = (ENV['LOOP_UNTIL'] || 20_000).to_i
START_FROM = (ENV['START_FROM'] || 1).to_i

BASE_URL = "https://alvo.com/checkout/orders/%s"

results = { found: [], not_found: [] }

dest_folder = File.join(Dir.pwd, 'work')
FileUtils.mkdir_p(dest_folder)

START_FROM.upto(LOOP_UNTIL) do |i|
  print "\r>>#{i}/#{LOOP_UNTIL}"

  filename = File.join(dest_folder, "order-#{i}.html")

  next if File.exists?(filename)

  begin
    data = open(BASE_URL % i)
    html_data = data.read

    File.open(filename, "wb") {|f|
      f.write(html_data)
      f.close
    }

    results[:found] << i

  rescue OpenURI::HTTPError => e
    results[:not_found] << i
  end
end

File.open('work_results.json', 'wb') {|f| f.write(JSON.pretty_generate(results)); f.close }
