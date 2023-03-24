require 'tomlrb'
require 'rmagick'

config = Tomlrb.load_file('config.toml')

global_config = config['global']
burning_ship_config = config['burning_ship']

width = global_config['width'].to_i
height = global_config['height'].to_i
output_dir = global_config['output_dir']

x_min = burning_ship_config['x_min'].to_f
x_max = burning_ship_config['x_max'].to_f
y_min = burning_ship_config['y_min'].to_f
y_max = burning_ship_config['y_max'].to_f
cx = burning_ship_config['cx'].to_f
cy = burning_ship_config['cy'].to_f
threshold = burning_ship_config['threshold'].to_f
max_iterations = burning_ship_config['max_iterations'].to_i
color = burning_ship_config['color'].to_i
background_color = burning_ship_config['background_color']
output_file = burning_ship_config['output_file']

image = Magick::Image.new(width, height)

x_range = x_max - x_min
y_range = y_max - y_min
x_step = x_range / width
y_step = y_range / height

(0...width).each do |x|
  (0...height).each do |y|
    x0 = x_min + x * x_step
    y0 = y_min + y * y_step
    x1 = 0
    y1 = 0
    i = 0
    while x1 * x1 + y1 * y1 < threshold && i < max_iterations
      x2 = (x1 * x1 - y1 * y1 + x0).abs
      y2 = (2 * x1 * y1 + y0).abs
      x1 = x2
      y1 = y2
      i += 1
    end
    if i == max_iterations
      image.pixel_color(x, y, background_color)
    else
      hue = (i * 360 / max_iterations + color) % 360
      image.pixel_color(x, y, "hsla(#{hue}, 100%, 50%)")
    end
  end
end

image.write(File.join(output_dir, output_file))
