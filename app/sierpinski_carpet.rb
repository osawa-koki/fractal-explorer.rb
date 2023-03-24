require 'tomlrb'
require 'rmagick'
require 'bigdecimal/math'

config = Tomlrb.load_file('config.toml')

global_config = config['global']
sierpinski_carpet_config = config['sierpinski_carpet']

width = global_config['width'].to_i
height = global_config['height'].to_i
output_dir = global_config['output_dir']

$color = sierpinski_carpet_config['color']
background_color = sierpinski_carpet_config['background_color']
carpet_size = sierpinski_carpet_config['carpet_size'].to_i
$max_iterations = sierpinski_carpet_config['max_iterations'].to_i
output_file = sierpinski_carpet_config['output_file']

$image = Magick::Image.new(width, height)
$image.background_color = background_color

def cross_join(arg)
  answer = []
  arg.each do |x|
    arg.each do |y|
      answer.push({x: x, y: y})
    end
  end
  return answer
end

def rec_fx(x, y, size, n)
  if $max_iterations < n
    return
  end

  xys = [1 / 9.0 * size, 4 / 9.0 * size, 7 / 9.0 * size]
  cross_join(xys).each do |xy|
    draw = Magick::Draw.new
    draw.stroke($color)
    draw.rectangle(x + xy[:x], y + xy[:y], x + xy[:x] + size / 9.0, y + xy[:y] + size / 9.0)
    rec_fx(x + xy[:x] - size / 9.0, y + xy[:y] - size / 9.0, size / 3.0, n + 1)
    draw.draw($image)
  end
end

size = width * carpet_size / 100
start = (width - size) / 2
size_inside = size / 3
start_inside = start + size_inside

draw = Magick::Draw.new
draw.stroke($color)
draw.rectangle(start, start, start + size, start + size)
draw.draw($image)

draw = Magick::Draw.new
draw.stroke($color)
draw.rectangle(start_inside, start_inside, start_inside + size_inside, start_inside + size_inside)
draw.draw($image)

rec_fx(start, start, size, 1)

$image.write(File.join(output_dir, output_file))
