require "crsfml"


mode = SF::VideoMode.new(800, 600)
window = SF::RenderWindow.new(mode, "pɹıq ʎddılɟ")
window.vertical_sync_enabled = true

class Wall
  @top : SF::RectangleShape
  @bottom : SF::RectangleShape
  @speed : Int32
  @x : Float32
  @pos : Int32
    
  def initialize
    @x = 1000
    @pos = Random.rand(400) + 50
    @top = SF::RectangleShape.new(SF.vector2(120, @pos))
    @bottom = SF::RectangleShape.new(SF.vector2(120, 300 + @pos))
    @top.position = {@x, 0}
    @bottom.position = {@x, @pos + 180}
    @top.fill_color = SF.color(100, 250, 50)
    @bottom.fill_color = SF.color(100, 250, 50)
    @speed = -5
  end

  def move(x, y)
    @x += @speed
    @top.move(x, y)
    @bottom.move(x, y)
  end
  
  def step
    move(@speed, 0.0)
  end
  
  def draw(window)
    window.draw @top
    window.draw @bottom
  end
  
  def collides?(x, y)
    return (@x <= x && x <= @x + 120) && (y < @pos || 300 + @pos < y)
  end
end

class Bird < SF::Sprite
  @speed : Float32
  
  def initialize(texture : SF::Texture)
    super(texture)
    @speed = 0
    @clock = SF::Clock.new
  end
  
  def move
    elapsed_time = @clock.restart.as_seconds
    @speed += elapsed_time * 1000
    move(0.0, @speed * elapsed_time)
  end
  
  def flap
    @speed = -550
  end
end

bird_texture = SF::Texture.from_file("resources/bird.png")

while window.open?
  state = false
  bird = Bird.new(bird_texture)
  bird.origin = bird_texture.size / 2.0
  bird.scale = SF.vector2(2.5, 2.5)
  bird.position = SF.vector2(250, 300)
  clock2 = SF::Clock.new
  speed = 0.0
  walls = [Wall.new]

  while state == false
    while event = window.poll_event()
      case event
      when SF::Event::Closed
        window.close()
      when SF::Event::KeyPressed
        if event.code.escape?
          window.close()
        else
          bird.flap
        end
      end
    end
    if clock2.elapsed_time.as_seconds > 2.0
      clock2.restart
      walls << Wall.new
    end
    bird.move
    window.clear SF::Color.new(112, 197, 206)
    walls.each do |wall|
      state |= wall.collides?(bird.position.x, bird.position.y)
      wall.step
      wall.draw(window)
    end
    window.draw bird
    window.display()
  end
end