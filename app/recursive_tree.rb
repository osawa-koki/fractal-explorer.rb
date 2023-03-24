require 'tomlrb'
require 'rmagick'

config = Tomlrb.load_file('config.toml')

global_config = config['global']
recursive_tree_config = config['recursive_tree']

$width = global_config['width'].to_i
$height = global_config['height'].to_i
output_dir = global_config['output_dir']

$shrink = recursive_tree_config['shrink'].to_i
$length = recursive_tree_config['length'].to_i
$angle = recursive_tree_config['angle'].to_i
$max_iterations = recursive_tree_config['max_iterations'].to_i
$color = recursive_tree_config['color']
$stroke_width = recursive_tree_config['stroke_width'].to_i
output_file = recursive_tree_config['output_file']

$image = Magick::Image.new($width, $height)

def rec_draw(x, y, deg, n)
  return if $max_iterations < n

  len = ($shrink / 100.0) ** n * (($width + $height) / 2) * $length / 100.0
  moved = []

  # 右側
  ang = (360 + deg - $angle) % 360
  moved_x = x + Math.cos(ang * Math::PI / 180) * len
  moved_y = if ang == 90
              y - len
            elsif ang == 270
              y + len
            else
              y + Math.tan(ang * Math::PI / 180) * (x - moved_x)
            end
  moved << { x: moved_x, y: moved_y, deg: ang }

  # 左側
  ang = (deg + $angle) % 360
  moved_x = x + Math.cos(ang * Math::PI / 180) * len
  moved_y = if ang == 90
              y - len
            elsif ang == 270
              y + len
            else
              y + Math.tan(ang * Math::PI / 180) * (x - moved_x)
            end
  moved << { x: moved_x, y: moved_y, deg: ang }

  moved.each do |m|
    draw = Magick::Draw.new
    draw.stroke($color)
    draw.stroke_width($stroke_width)
    draw.line(x, y, m[:x], m[:y])
    draw.draw($image)
    rec_draw(m[:x], m[:y], m[:deg], n + 1);
  end
end

draw = Magick::Draw.new
draw.stroke($color)
draw.stroke_width($stroke_width)
draw.line($width / 2, $height, $width / 2, $height - $height * $length / 100)
draw.draw($image)

rec_draw($width / 2, $height - $height * $length / 100, 90, 1)

$image.write(File.join(output_dir, output_file))
