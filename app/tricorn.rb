require 'tomlrb'
require 'rmagick'

config = Tomlrb.load_file('config.toml')

global_config = config['global']
tricorn_config = config['tricorn']

width = global_config['width'].to_i
height = global_config['height'].to_i
output_dir = global_config['output_dir']

x_min = tricorn_config['x_min'].to_f
x_max = tricorn_config['x_max'].to_f
y_min = tricorn_config['y_min'].to_f
y_max = tricorn_config['y_max'].to_f
max_iterations = tricorn_config['max_iterations'].to_i
threshold = tricorn_config['threshold'].to_f
color = tricorn_config['color'].to_i
background_color = tricorn_config['background_color']
output_file = tricorn_config['output_file']

x_range = x_max - x_min
y_range = y_max - y_min
x_step = x_range / width
y_step = y_range / height

image = Magick::Image.new(width, height)

(0..width-1).each do |x|
  (0..height-1).each do |y|
    x0 = x_min + x * x_step
    y0 = y_min + y * y_step
    x1 = 0
    y1 = 0
    i = 0
    while x1 * x1 + y1 * y1 < threshold && i < max_iterations
      x2 = x1 * x1 - y1 * y1 + x0
      y2 = -(2 * x1 * y1 + y0)
      x1 = x2
      y1 = y2
      i += 1
    end
    if i == max_iterations
      pixel_color = background_color
    else
      hue = (i * 360 / max_iterations + color) % 360
      pixel_color = "hsla(#{hue}, 100%, 50%, 1)"
    end
    image.pixel_color(x, y, pixel_color)
  end
end

image.write(File.join(output_dir, output_file))
