require 'tomlrb'
require 'rmagick'
require 'bigdecimal/math'

config = Tomlrb.load_file('config.toml')

global_config = config['global']
sierpinski_triangle_config = config['sierpinski_triangle']

width = global_config['width'].to_i
height = global_config['height'].to_i
output_dir = global_config['output_dir']

$color = sierpinski_triangle_config['color']
triagle_size = sierpinski_triangle_config['triagle_size'].to_i
$max_iterations = sierpinski_triangle_config['max_iterations'].to_i
output_file = sierpinski_triangle_config['output_file']

$image = Magick::Image.new(width, height)

def draw_triangle(x, y, size)
  p1_x = x + size / 2
  p1_y = y - Math.sin(-60 * BigDecimal(Math::PI.to_s) / 180) * size
  p2_x = x + size
  p2_y = y
  draw = Magick::Draw.new
  draw.fill("white")
  draw.polygon(x, y, p1_x, p1_y, p2_x, p2_y)
  draw.draw($image)
end

def rec_fx(x, y, size, n)
  if $max_iterations < n
    return
  end

  p1_x = Math.cos(240 * BigDecimal(Math::PI.to_s) / 180) * 1 / 4 * size + x
  p1_y = y - Math.sin(240 * BigDecimal(Math::PI.to_s) / 180) * 1 / 4 * size
  p2_x = Math.cos(240 * BigDecimal(Math::PI.to_s) / 180) * 3 / 4 * size + x
  p2_y = y - Math.sin(240 * BigDecimal(Math::PI.to_s) / 180) * 3 / 4 * size
  p3_x = p2_x + size / 2
  p3_y = p2_y

  draw_triangle(p1_x, p1_y, size / 4)
  draw_triangle(p2_x, p2_y, size / 4)
  draw_triangle(p3_x, p3_y, size / 4)

  rec_fx(
    x,
    y,
    size / 2,
    n + 1,
  )
  rec_fx(
    Math.cos(240 * BigDecimal(Math::PI.to_s) / 180) * 1 / 2 * size + x,
    y - Math.sin(240 * BigDecimal(Math::PI.to_s) / 180) * 1 / 2 * size,
    size / 2,
    n + 1,
  )
  rec_fx(
    Math.cos(-60 * BigDecimal(Math::PI.to_s) / 180) * 1 / 2 * size + x,
    y - Math.sin(-60 * BigDecimal(Math::PI.to_s) / 180) * 1 / 2 * size,
    size / 2,
    n + 1,
  )
end

size = width * triagle_size / 100
start = (width - (Math.sqrt(3) * width * triagle_size / 100 / 2)) / 2

p1_x = Math.cos(240 * BigDecimal(Math::PI.to_s) / 180) * size / 2 + width / 2
p1_y = start - Math.sin(240 * BigDecimal(Math::PI.to_s) / 180) * size / 2
p2_x = Math.cos(-60 * BigDecimal(Math::PI.to_s) / 180) * size / 2 + p1_x
p2_y = p1_y - Math.sin(-60 * BigDecimal(Math::PI.to_s) / 180) * size / 2

draw = Magick::Draw.new
draw.fill($color)
_p2_x = Math.cos(240 * BigDecimal(Math::PI.to_s) / 180) * size + width / 2
_p2_y = start - Math.sin(240 * BigDecimal(Math::PI.to_s) / 180) * size
draw.polygon(width / 2, start, _p2_x, _p2_y, _p2_x + size, _p2_y)
draw.draw($image)

draw = Magick::Draw.new
draw.fill("white")
draw.polygon(p1_x, p1_y, p2_x, p2_y, p1_x + size / 2, p1_y)
draw.draw($image)

rec_fx(
  width / 2,
  start,
  size,
  1,
)

$image.write(File.join(output_dir, output_file))
