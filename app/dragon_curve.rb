require 'tomlrb'
require 'rmagick'

config = Tomlrb.load_file('config.toml')

global_config = config['global']
dragon_curve_config = config['dragon_curve']

width = global_config['width'].to_i
height = global_config['height'].to_i
output_dir = global_config['output_dir']

x = dragon_curve_config['x'].to_f
y = dragon_curve_config['y'].to_f
delta = dragon_curve_config['delta'].to_f
color = dragon_curve_config['color']
background_color = dragon_curve_config['background_color']
stroke_width = dragon_curve_config['stroke_width'].to_i
max_iterations = dragon_curve_config['max_iterations'].to_i
$color = dragon_curve_config['color']
background_color = dragon_curve_config['background_color']
output_file = dragon_curve_config['output_file']

$image = Magick::Image.new(width, height)
draw = Magick::Draw.new
draw.fill(background_color)
draw.rectangle(0, 0, width, height)
draw.draw($image)

$_x = x / 100 * width;
$_y = height - (y / 100 * height);

def dragon(i, dx, dy, sign)
  if i == 0
    draw = Magick::Draw.new
    draw.stroke($color)
    draw.stroke_width(1)
    draw.line($_x, $_y, $_x + dx, $_y + dy)
    draw.draw($image)
    $_x += dx
    $_y += dy
  else
    dragon(i - 1, (dx - sign * dy) / 2, (dy + sign * dx) / 2, 1)
    dragon(i - 1, (dx + sign * dy) / 2, (dy - sign * dx) / 2, -1)
  end
end

dragon(max_iterations, delta, delta, 1)

$image.write(File.join(output_dir, output_file))
