require 'tomlrb'
require 'rmagick'

config = Tomlrb.load_file('config.toml')

global_config = config['global']
mandelbrot_config = config['mandelbrot']

width = global_config['width'].to_i
height = global_config['height'].to_i
output_dir = global_config['output_dir']

x_min = mandelbrot_config['x_min'].to_f
x_max = mandelbrot_config['x_max'].to_f
y_min = mandelbrot_config['y_min'].to_f
y_max = mandelbrot_config['y_max'].to_f
threshold = mandelbrot_config['threshold'].to_f
max_iterations = mandelbrot_config['max_iterations'].to_i
color = mandelbrot_config['color'].to_i
background_color = mandelbrot_config['background_color']
output_file = mandelbrot_config['output_file']

# 画像生成
image = Magick::Image.new(width, height)

x_range = x_max - x_min
y_range = y_max - y_min
x_step = x_range / width
y_step = y_range / height

# トライコーン集合の描画
for x in 0..width-1 do
  for y in 0..height-1 do
    x0 = x_min + x * x_step
    y0 = y_min + y * y_step
    x1 = 0
    y1 = 0
    i = 0
    while x1 * x1 + y1 * y1 < threshold && i < max_iterations do
      x2 = x1 * x1 - y1 * y1 + x0
      y2 = 2 * x1 * y1 + y0
      x1 = x2
      y1 = y2
      i += 1
    end
    if i == max_iterations then
      image.pixel_color(x, y, background_color)
    else
      hue = (i * 360 / max_iterations + color) % 360
      saturation = 100
      lightness = 50
      image.pixel_color(x, y, "hsl(#{hue},#{saturation}%,#{lightness}%)")
    end
  end
end

image.write(File.join(output_dir, output_file))
