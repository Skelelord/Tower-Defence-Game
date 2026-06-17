require 'gosu'
require 'rubygems'
require './circle'

module ZOrder
  BACKGROUND, BOTTOM, MIDDLE, TOP, TEXT = *0..4
end

module Type
  SLOT, GUARD_TOWER, ENERGY_TOWER, THRASHER_TOWER, GUNNER_TOWER = *0..4
end

module Direction
  NORTH, SOUTH, EAST, WEST = *0..3
end

module Game_State
  IN_PLAY, GAME_OVER, MAIN_MENU, INFORMATION_ROOM, PAUSED = *0..4
end

module Enemy_Type
  LESSER_PHANTOM, GREATER_PHANTOM, GOLDEN_PHANTOM, SPECTOR_PHANTOM = *0..3
end

class Tower
	attr_accessor :x_position, :y_position, :type, :width, :height, :fire_timer

	def initialize (x_position, y_position, type, width, height, fire_timer)
		@x_position = x_position
		@y_position = y_position
    @type = type
    @width = width
    @height = height
    @fire_timer = fire_timer
	end
end

class Projectile
	attr_accessor :x_position, :y_position

	def initialize (x_position, y_position)
		@x_position = x_position
		@y_position = y_position
	end
end

class Enemy_Data
	attr_accessor :x_position, :y_position, :speed, :type, :hit_points, :direction

	def initialize (x_position, y_position, speed, type, hit_points, direction)
		@x_position = x_position
		@y_position = y_position
    @speed = speed
    @type = type
    @hit_points = hit_points
    @direction = direction
	end
end

class Bullet_Data 
	attr_accessor :x_position, :y_position, :speed, :type, :direction, :timer, :enemy_x_cordinate, :enemy_y_cordinate, :x_speed, :y_speed

	def initialize (x_position, y_position, speed, type, direction, timer, enemy_x_cordinate, enemy_y_cordinate, x_speed, y_speed)
		@x_position = x_position
		@y_position = y_position
    @speed = speed
    @type = type
    @direction = direction
    @timer = timer
    @enemy_x_cordinate = enemy_x_cordinate
    @enemy_y_cordinate = enemy_y_cordinate
    @x_speed = x_speed
    @y_speed = y_speed
  end
end


MAP_WIDTH = 600
SCREEN_WIDTH = 650
MAP_HEIGHT = 480

ENEMY_HEIGHT = 0.035
ENEMY_WIDTH = 0.035

X_TOWER_CORDINATES = [200, 400, 100, 150, 300, 250, 250, 300, 300, 350, 250, 400, 450]
Y_TOWER_CORDINATES = [250, 250, 100, 100, 250, 250, 100, 100, 400, 400, 400, 400, 400]

SPECTOR_IMAGE_NAMES = "Enemy.png", "Enemy_2.png", "Golden_Phantom.png", "Spector_Phantom.png"
TOWER_IMAGE_NAMES = "Guard_Tower.png", "Energy_Tower.png", "Thrasher Tower.png", "Gunner_Tower.png"
#initialize Button_Cordinates

BUTTON_Y_CORDINATES = [40, 120, 200, 280, 360]
BUTTON_X_CORDINATES = [30, 500]
BUTTON_1_X_CORDINATE = MAP_WIDTH + 2
BUTTON_1_Y_CORDINATE = 120

BUTTON_2_X_CORDINATE = MAP_WIDTH + 2
BUTTON_2_Y_CORDINATE = 200

BUTTON_3_X_CORDINATE = MAP_WIDTH + 2
BUTTON_3_Y_CORDINATE = 280

BUTTON_4_X_CORDINATE = MAP_WIDTH + 2
BUTTON_4_Y_CORDINATE = 360

PLAY_AGAIN_BUTTON_X_CORDINATE = 250
PLAY_AGAIN_BUTTON_Y_CORDINATE = 300

BACK_BUTTON_X_CORDINATE = 100
BACK_BUTTON_Y_CORDINATE = 400

PAUSE_BUTTON_X_CORDINATE = 20
PAUSE_BUTTON_Y_CORDINATE = 20

#sets up tower cost
ENERGY_TOWER_COST = 135
GUARD_TOWER_COST = 215
THRASHER_TOWER_COST = 500
GUNNER_TOWER_COST = 500

ACQUISITION_RANGE = 100
MAX_LIVES = 100

class Game < Gosu::Window
  def initialize
    super(SCREEN_WIDTH, MAP_HEIGHT, false)
    self.caption = "Tower Defense Game"
    
    #@enemy = Enemy_Data.new()
    #@slot = Tower.new()
    @money = 900    
    @button_font = Gosu::Font.new(20)
    @enemies = Array.new()
    @player_bullet = Array.new()
    @spawn_timer = 0
    #initialize tower sprites
    @guard_tower_image = Gosu::Image.new("Guard_Tower.png")
    @slot_image = Gosu::Image.new("Slot.png")
    @energy_tower = Gosu::Image.new("Energy_Tower.png")
    @thrasher_tower = Gosu::Image.new("Thrasher Tower.png")
    @enemy_image = Gosu::Image.new("Enemy.png")
    @enemy_2_image = Gosu::Image.new("Enemy_2.png")
    @game_over = Gosu::Image.new("Game_Over.png")
    @you_win = Gosu::Image.new("You_Win.png")
    @grass_background = Gosu::Image.new("Grass_Background.png")
    @enemy_golden_phantom_image = Gosu::Image.new("Golden_Phantom.png")
    @enemy_spector_phantom_image = Gosu::Image.new("Spector_Phantom.png")
    @play_again_button = Gosu::Image.new("Play_Again.png")
    @play_button = Gosu::Image.new("Play.png")
    @play_paused_button = Gosu::Image.new("Play_Button.png")
    @gunner_tower = Gosu::Image.new("Gunner_Tower.png")
    @home_button = Gosu::Image.new("Home_Button.png")
    @information_button = Gosu::Image.new("Information_Button.png")
    @back_button = Gosu::Image.new("Back_Button.png")
    @pause_button = Gosu::Image.new("Pause_Button.png")
    @button_switch = -1
    @level_timer = 0
    @game_state = Game_State::MAIN_MENU

    #initiates the first level
    level_1()

    #initiates the slot/tower data
    slot_set_up()
  end

  def mouse_over?(x, y, width, height, mouse_x, mouse_y) #checks if the mouse is inside given cordinate
    mouse_x >= x && mouse_x <= x + width &&
    mouse_y >= y && mouse_y <= y + height
  end

  def button_down(id)
    case id
    when Gosu::MsLeft
    #gets the mouse x & y cordinates
    mouse_x = self.mouse_x
    mouse_y = self.mouse_y
    #if @game_state == Game_State::PAUSED then
      if mouse_over?(PAUSE_BUTTON_X_CORDINATE, PAUSE_BUTTON_Y_CORDINATE, @pause_button.width*0.05, @pause_button.height*0.05, mouse_x, mouse_y)
        if @game_state == Game_State::PAUSED then
          @game_state = Game_State::IN_PLAY
        elsif @game_state == Game_State::IN_PLAY then
          @game_state = Game_State::PAUSED
        end
      end
   # end
    if @game_state == Game_State::IN_PLAY then
        i = 0
        check_button()
        while i < @slots.length
          mouse_x = self.mouse_x
          mouse_y = self.mouse_y
          #if mouse_over?(@slots[i].x_position, @slots[i].y_position, 0.04, 0.04, mouse_x, mouse_y)
          #if mouse_over?(X_TOWER_CORDINATES[i], Y_TOWER_CORDINATES[i], 0.04, 0.04, mouse_x, mouse_y)
          if mouse_over?(@slots[i].x_position, @slots[i].y_position, @slots[i].width, @slots[i].height, mouse_x, mouse_y)
          #   @slots[i].type = Type::GUARD_TOWER
              @button_switch = i
              break #exits loop
          else
              @button_switch = -1
          end
          i = i + 1 
        end
      elsif @game_state == Game_State::GAME_OVER or @game_state == Game_State::PAUSED then
        
        if mouse_over?(PLAY_AGAIN_BUTTON_X_CORDINATE, PLAY_AGAIN_BUTTON_Y_CORDINATE, @play_again_button.width*0.15, @play_again_button.height*0.15, mouse_x, mouse_y)
            i = 0
            @slots = flush_array(@slots)
            @enemies = flush_array(@enemies)
            @player_bullets = flush_array(@player_bullets)
            @lives = MAX_LIVES
            @money = 900
            @button_switch = -1
            @level_timer = 0
            slot_set_up()
            @game_state = Game_State::IN_PLAY
            
          elsif mouse_over?(PLAY_AGAIN_BUTTON_X_CORDINATE + 70, PLAY_AGAIN_BUTTON_Y_CORDINATE, @home_button.width*0.102, @home_button.height*0.102, mouse_x, mouse_y)
            #removes all indexs on the arrays
            @slots = flush_array(@slots)
            @enemies = flush_array(@enemies)
            @player_bullets = flush_array(@player_bullets)

            @game_state = Game_State::MAIN_MENU
          end
        elsif @game_state == Game_State::MAIN_MENU then
        
          if mouse_over?(PLAY_AGAIN_BUTTON_X_CORDINATE, PLAY_AGAIN_BUTTON_Y_CORDINATE, @play_button.width*0.10, @play_button.height*0.10, mouse_x, mouse_y)
            i = 0
            while i < @slots.length do
              @slots[i].type == Type::SLOT
              i = i + 1
            end
            @player_bullets = flush_array(@player_bullets)
            slot_set_up()
            @lives = MAX_LIVES
            @money = 900
            @button_switch = -1
            @level_timer = 0
            @game_state = Game_State::IN_PLAY
            
         elsif mouse_over?(PLAY_AGAIN_BUTTON_X_CORDINATE + 70, PLAY_AGAIN_BUTTON_Y_CORDINATE, @information_button.width*0.10, @information_button.height*0.10, mouse_x, mouse_y)
           @game_state = Game_State::INFORMATION_ROOM
            
          end
      elsif @game_state == Game_State::INFORMATION_ROOM then
        if mouse_over?(BACK_BUTTON_X_CORDINATE, BACK_BUTTON_Y_CORDINATE, @back_button.width*0.10, @back_button.height*0.10, mouse_x, mouse_y)
          @game_state = Game_State::MAIN_MENU
        end
      end
  end
end
def flush_array(array)
if array and array.length > 0 then
  while array.length > 0 do
    array = remove_index(0, array)
  end
 end
 return array
end

def check_button()
  
  if @button_switch > - 1 then
      if mouse_over?(BUTTON_1_X_CORDINATE, BUTTON_1_Y_CORDINATE, @guard_tower_image.width*0.08, @guard_tower_image.height*0.08, mouse_x, mouse_y)
        if @money >= GUARD_TOWER_COST then
         @slots[@button_switch].type = Type::GUARD_TOWER
         @money = @money - GUARD_TOWER_COST
        end
     elsif mouse_over?(BUTTON_2_X_CORDINATE, BUTTON_2_Y_CORDINATE, @energy_tower.width*0.08, @energy_tower.height*0.08, mouse_x, mouse_y)
       if @money >= ENERGY_TOWER_COST then
          	@slots[@button_switch].type = Type::ENERGY_TOWER
            @money = @money - ENERGY_TOWER_COST
        end 
    elsif mouse_over?(BUTTON_3_X_CORDINATE, BUTTON_3_Y_CORDINATE, @energy_tower.width*0.08, @energy_tower.height*0.08, mouse_x, mouse_y)
       if @money >= THRASHER_TOWER_COST then
          	@slots[@button_switch].type = Type::THRASHER_TOWER
            @money = @money - THRASHER_TOWER_COST
        end
    elsif mouse_over?(BUTTON_4_X_CORDINATE, BUTTON_4_Y_CORDINATE, @gunner_tower.width*0.08, @gunner_tower.height*0.08, mouse_x, mouse_y)
      if @money >= GUNNER_TOWER_COST then
          	@slots[@button_switch].type = Type::GUNNER_TOWER
            @money = @money - GUNNER_TOWER_COST
       end
    end 
  end
end

   def slot_set_up()
      #@background = Gosu::Color::YELLOW
      @slot = Gosu::Image.new("Slot.png")
      scale_x = 0.04
      scale_y = 0.04
      @slots = Array.new()
     i = 0
     
   while i < X_TOWER_CORDINATES.length do
      x_position = X_TOWER_CORDINATES[i]
      y_position = Y_TOWER_CORDINATES[i]
      type = Type::SLOT
      width  = @slot_image.width * scale_x
      height = @slot_image.height * scale_y
      fire_timer = 60
      tower = Tower.new(x_position, y_position, type, width, height, fire_timer)
      @slots[i] = tower
      i = i + 1
    end
  end
  def draw_tower()
    i = 0
    while i < @slots.length do
      if @slots[i].type == Type::SLOT then
        @slot_image.draw(@slots[i].x_position, @slots[i].y_position, ZOrder::TOP, 0.04, 0.04)
      elsif @slots[i].type == Type::GUARD_TOWER then
        @guard_tower_image.draw(@slots[i].x_position, @slots[i].y_position, ZOrder::TOP, 0.04, 0.04)
      elsif @slots[i].type == Type::ENERGY_TOWER then
        @energy_tower.draw(@slots[i].x_position, @slots[i].y_position, ZOrder::TOP, 0.04, 0.04)
      elsif @slots[i].type == Type::THRASHER_TOWER then
        @thrasher_tower.draw(@slots[i].x_position, @slots[i].y_position, ZOrder::TOP, 0.04, 0.04)
      elsif @slots[i].type == Type::GUNNER_TOWER then
        @gunner_tower.draw(@slots[i].x_position, @slots[i].y_position, ZOrder::TOP, 0.04, 0.04)
      end
       i = i + 1

    end
  end

  def draw_enemy()
    #@enemy_image.draw(@enemy_x_position, @enemy_y_position, ZOrder::TOP, 0.08, 0.08)
    i = 0
    while i < @enemies.length do
      if @enemies[i].type == Enemy_Type::GREATER_PHANTOM then
        @enemy_2_image.draw(@enemies[i].x_position, @enemies[i].y_position, ZOrder::TOP, ENEMY_WIDTH, ENEMY_HEIGHT)
      elsif @enemies[i].type == Enemy_Type::GOLDEN_PHANTOM then
        @enemy_golden_phantom_image.draw(@enemies[i].x_position, @enemies[i].y_position, ZOrder::TOP, ENEMY_WIDTH, ENEMY_HEIGHT)
      elsif @enemies[i].type == Enemy_Type::LESSER_PHANTOM then
        @enemy_image.draw(@enemies[i].x_position, @enemies[i].y_position, ZOrder::TOP, ENEMY_WIDTH, ENEMY_HEIGHT)
      elsif @enemies[i].type == Enemy_Type::SPECTOR_PHANTOM then
        @enemy_spector_phantom_image.draw(@enemies[i].x_position, @enemies[i].y_position, ZOrder::TOP, ENEMY_WIDTH, ENEMY_HEIGHT)
      end
      i = i + 1 
    end
  end

#finds the speed of the Enemy based off their type
def find_speed(i)
  if @enemies[i].type == Enemy_Type::LESSER_PHANTOM then
    speed = 1.0
  elsif @enemies[i].type == Enemy_Type::GREATER_PHANTOM then
    speed = 1.5
  elsif @enemies[i].type == Enemy_Type::GOLDEN_PHANTOM then
    speed = 2
  elsif @enemies[i].type == Enemy_Type::SPECTOR_PHANTOM then
    speed = 1.1
  end
  return speed
end

#controls enemy movement throughout the map
  def enemy_movement()
    #enemy_speed = 2
    i = 0 #simple counting variable
    while i < @enemies.length do
     enemy_speed = find_speed(i)
     # checks coordinates of each enemy within the array and then moves them ording to their current position
     if @enemies[i].x_position < MAP_WIDTH - 60 && @enemies[i].y_position > MAP_HEIGHT - 60 then
        @enemies[i].x_position += enemy_speed
        @enemies[i].direction = Direction::EAST
     elsif @enemies[i].y_position > MAP_HEIGHT - 140 && @enemies[i].x_position >= MAP_WIDTH - 60
        @enemies[i].y_position -= enemy_speed
        @enemies[i].direction = Direction::WEST
     elsif @enemies[i].x_position > 60 && @enemies[i].y_position >= MAP_HEIGHT - 140
        @enemies[i].x_position -= enemy_speed
        @enemies[i].direction = Direction::WEST
     elsif @enemies[i].y_position > MAP_HEIGHT - 200 && @enemies[i].x_position <= 60
         @enemies[i].y_position -= enemy_speed
         @enemies[i].direction = Direction::NORTH
     elsif @enemies[i].x_position < MAP_WIDTH - 60 && @enemies[i].y_position >= MAP_HEIGHT - 200
         @enemies[i].x_position += enemy_speed
         @enemies[i].direction = Direction::EAST
     elsif @enemies[i].y_position > MAP_HEIGHT - 260 && @enemies[i].x_position >= MAP_WIDTH - 60
         @enemies[i].y_position -= enemy_speed
         @enemies[i].direction = Direction::NORTH
     elsif @enemies[i].x_position > 60  && @enemies[i].y_position >= MAP_HEIGHT - 280
         @enemies[i].x_position -= enemy_speed
         @enemies[i].direction = Direction::WEST
     elsif @enemies[i].y_position > MAP_HEIGHT - 350 && @enemies[i].x_position <= 60
         @enemies[i].y_position -= enemy_speed
         @enemies[i].direction = Direction::NORTH
     elsif @enemies[i].x_position < MAP_WIDTH - 60 && @enemies[i].y_position >= MAP_HEIGHT - 350
         @enemies[i].x_position += enemy_speed
         @enemies[i].direction = Direction::EAST
     elsif @enemies[i].y_position > MAP_HEIGHT - 420 && @enemies[i].x_position >= MAP_WIDTH - 60
         @enemies[i].y_position -= enemy_speed
         @enemies[i].direction = Direction::NORTH
     elsif @enemies[i].x_position > 60  && @enemies[i].y_position >= MAP_HEIGHT - 420
         @enemies[i].x_position -= enemy_speed
         @enemies[i].direction = Direction::WEST
     elsif @enemies[i].y_position > MAP_HEIGHT - 480 && @enemies[i].x_position <= 60
         @enemies[i].y_position -= enemy_speed
         @enemies[i].direction = Direction::NORTH
     elsif @enemies[i].x_position < MAP_WIDTH - 60 && @enemies[i].y_position <= MAP_HEIGHT - 480
         @enemies[i].x_position += enemy_speed
          @enemies[i].direction = Direction::EAST
     else # Enemy Has reached the end and must be removed from the array
         #@enemies = remove_enemy(i)
         if @enemies[i].type == Enemy_Type::LESSER_PHANTOM then
          @enemies = remove_index(i, @enemies)
          @lives = @lives - 1
         elsif @enemies[i].type == Enemy_Type::GREATER_PHANTOM then
          @enemies = remove_index(i, @enemies)
          @lives = @lives - 2
         elsif @enemies[i].type == Enemy_Type::GOLDEN_PHANTOM then
          @enemies = remove_index(i, @enemies)
          @lives = @lives - 3
        elsif @enemies[i].type == Enemy_Type::SPECTOR_PHANTOM then
         @enemies = remove_index(i, @enemies)
         @lives = @lives - 10
        end
     end
     i = i + 1
   end
  end

  def remove_index(i, list)
    new_list = Array.new()
    #adds enemies before the removed enemy
    index = 0 # simple counting variable

    if i > index then
      while index < i do
        new_list << list[index]
        index = index + 1
      end
    end
    #readads enemies after the removed enemy
    while i + 1 < list.length do
      new_list << list[i + 1]
      i = i + 1
    end
    list = new_list
    return list
  end

 def level_1()

 end
 def set_timer()
 i = 0 
  while i < @slots.length do
    if @slots[i].type == Type::THRASHER_TOWER then
      @slots[i].fire_timer += 5
    end
    i = i + 1
  end
 end
 
 #determines the base speed (before tower multipliers) of the bullet
 def determine_speed(distance)
 # speed = 
 end

 def tower_acquisition()
  set_timer()
  i = 0 #simple counting variable
  while i < @slots.length do
   if @slots[i].fire_timer > 150 then
    if @slots[i].type == Type::GUNNER_TOWER then
          @slots[i].fire_timer = 75
          x1 = @slots[i].x_position
          y1 = @slots[i].y_position
          x2 = self.mouse_x
          y2 = self.mouse_y
          distance = Math.sqrt((x2 - x1)**2 + (y2 - y1)**2)
          x_speed = ((x2 - x1))/distance
          y_speed = ((y2 - y1))/distance
          a = 1/(x_speed.abs + y_speed.abs)
          x_speed = x_speed * a
          y_speed = y_speed * a
          timer = 0
          bullet = Bullet_Data.new(@slots[i].x_position, @slots[i].y_position, 5, Type::GUNNER_TOWER, Direction::WEST, timer, x2, y2, x_speed, y_speed)
          @player_bullet << bullet
          
    elsif @slots[i].type == Type::GUARD_TOWER or @slots[i].type == Type::ENERGY_TOWER or @slots[i].type == Type::THRASHER_TOWER then
      enemy_index = 0
        while enemy_index < @enemies.length do
         x1 = @slots[i].x_position
         y1 = @slots[i].y_position
         x2 = @enemies[enemy_index].x_position
         y2 = @enemies[enemy_index].y_position
         distance = Math.sqrt((x2 - x1)**2 + (y2 - y1)**2)
         #if @slots[i].fire_timer > 460 then
          if distance < ACQUISITION_RANGE then
            if @slots[i].type == Type::GUARD_TOWER then
             @slots[i].fire_timer = 0
             timer = 0
             bullet = Bullet_Data.new(@slots[i].x_position, @slots[i].y_position, 5, Type::GUARD_TOWER, Direction::NORTH, timer, 0, 0, 0, 0)
             @player_bullet << bullet
             bullet = Bullet_Data.new(@slots[i].x_position, @slots[i].y_position, 5, Type::GUARD_TOWER, Direction::SOUTH, timer, 0, 0, 0, 0)
             @player_bullet << bullet
             bullet = Bullet_Data.new(@slots[i].x_position, @slots[i].y_position, 5, Type::GUARD_TOWER, Direction::EAST, timer, 0, 0, 0, 0)
             @player_bullet << bullet
             bullet = Bullet_Data.new(@slots[i].x_position, @slots[i].y_position, 5, Type::GUARD_TOWER, Direction::WEST, timer, 0, 0, 0, 0)
             @player_bullet << bullet
            else
              timer = 0
              @slots[i].fire_timer = 0
              #puts("Hi")
              #speed = determine_speed(distance)
              x_speed = ((@enemies[enemy_index].x_position - @slots[i].x_position))/distance
              y_speed = ((@enemies[enemy_index].y_position - @slots[i].y_position))/distance
              a = 1/(x_speed.abs + y_speed.abs)
              x_speed = x_speed * a
              y_speed = y_speed * a
              if @slots[i].type == Type::THRASHER_TOWER then              
                bullet = Bullet_Data.new(@slots[i].x_position, @slots[i].y_position, 5, Type::THRASHER_TOWER, Direction::WEST, timer, @enemies[enemy_index].x_position, @enemies[enemy_index].y_position, x_speed, y_speed)
              elsif @slots[i].type == Type::ENERGY_TOWER then
                bullet = Bullet_Data.new(@slots[i].x_position, @slots[i].y_position, 5, Type::ENERGY_TOWER, enemy_index, timer, @enemies[enemy_index].x_position, @enemies[enemy_index].y_position, x_speed, y_speed)
              end
              @player_bullet << bullet
              break
            end
           end
       #else
        #@slots[i].fire_timer += 1
       #end
       enemy_index = enemy_index + 1
      end
      end
    else
      @slots[i].fire_timer += 1
    end
    i = i + 1
  end
 end

def bullet_contact_with_enemy()
  bullet_index = 0
  while bullet_index < @player_bullet.length do
    enemy_index = 0
    while enemy_index < @enemies.length do
      x1 = @player_bullet[bullet_index].x_position
      y1 = @player_bullet[bullet_index].y_position
      x2 = @enemies[enemy_index].x_position
      y2 = @enemies[enemy_index].y_position
      x3 = @enemies[enemy_index].x_position + (@enemy_image.width*ENEMY_WIDTH)
      y3 = @enemies[enemy_index].y_position + (@enemy_image.height*ENEMY_HEIGHT)
      
      if x1 >= x2 and x1 <= x3 and y1 >= y2 and y1 <= y3 then
        @money = @money + 4
        @player_bullet = remove_index(bullet_index, @player_bullet)
        if @enemies[enemy_index].type == Enemy_Type::GREATER_PHANTOM then
          @enemies[enemy_index].type = Enemy_Type::LESSER_PHANTOM
          break
        elsif @enemies[enemy_index].type == Enemy_Type::GOLDEN_PHANTOM then
          @enemies[enemy_index].type = Enemy_Type::GREATER_PHANTOM
          break # exit the loop
        elsif @enemies[enemy_index].type == Enemy_Type::SPECTOR_PHANTOM then
          if @enemies[enemy_index].hit_points >= 1 then
            @enemies[enemy_index].hit_points -= 1
            puts @enemies[enemy_index].hit_points
          else   
            @enemies = remove_index(enemy_index, @enemies)
          end
          break
        else
          @enemies = remove_index(enemy_index, @enemies)
          break # exit the loop
        end
      end
      enemy_index = enemy_index + 1
    end
    bullet_index = bullet_index + 1
  end
end

def life_count(lives)
  if lives < 0 then 
    @game_over.draw(50, 200, ZOrder::TEXT, 0.5, 0.5)
    @play_again_button.draw(PLAY_AGAIN_BUTTON_X_CORDINATE, PLAY_AGAIN_BUTTON_Y_CORDINATE, ZOrder::TEXT, 0.15, 0.15)
    @home_button.draw(PLAY_AGAIN_BUTTON_X_CORDINATE + 70, PLAY_AGAIN_BUTTON_Y_CORDINATE, ZOrder::TEXT, 0.104, 0.104)
    @game_state = Game_State::GAME_OVER
  end
end

def update
  max_lesser_enemies = 0
  max_greater_enemies = 0
  max_golden_enemies = 0
  max_spector_enemies = 0
  if @game_state == Game_State::IN_PLAY then
    if @level_timer > 0 and @level_timer < 1000 then
      max_lesser_enemies = 2
    elsif @level_timer > 1000 and @level_timer < 2000 then
      max_lesser_enemies = 6
    elsif @level_timer > 2000 and @level_timer < 3000 then
      max_lesser_enemies = 12
      max_greater_enemies = 1
    elsif @level_timer > 3000 and @level_timer < 4000 then
      max_lesser_enemies = 18
      max_greater_enemies = 2
    elsif @level_timer > 4000 and @level_timer < 5000 then
      max_lesser_enemies = 18
      max_greater_enemies = 5
    elsif @level_timer > 5000 and @level_timer < 6000 then
      max_lesser_enemies = 18
      max_greater_enemies = 8
    elsif @level_timer > 6000 and @level_timer < 7000 then
      max_lesser_enemies = 18
      max_greater_enemies = 8
      max_golden_enemies = 1
    elsif @level_timer > 7000 and @level_timer < 8000 then
      max_lesser_enemies = 18
      max_greater_enemies = 8
      max_golden_enemies = 3
    elsif @level_timer > 8000 and @level_timer < 9000 then
      max_lesser_enemies = 18
      max_greater_enemies = 10
      max_golden_enemies = 5
      max_spector_enemies = 1
    elsif @level_timer > 9000 and @level_timer < 10000 then
      max_lesser_enemies = 18
      max_greater_enemies = 15
      max_golden_enemies = 10
      max_spector_enemies = 2
    elsif @level_timer > 10000 and @level_timer < 11000
      #nothing is spawned in this round
    elsif @level_timer > 11000 and @level_timer < 12000
      max_lesser_enemies = 40
    elsif @level_timer > 12000 and @level_timer < 14000 then
      max_lesser_enemies = 40
      max_greater_enemies = 25
      max_golden_enemies = 15
    elsif @level_timer > 14000 and @level_timer < 16000 then
      max_lesser_enemies = 40
      max_greater_enemies = 30
      max_golden_enemies = 20
      max_spector_enemies = 10
    end
   @level_timer = @level_timer + 1

  spawn_delay = 30
  tower_acquisition()
  bullet_contact_with_enemy()

  

  if @enemies.length < max_lesser_enemies + max_greater_enemies + max_golden_enemies + max_spector_enemies
    @spawn_timer += 1
  end

  i = 0
  index = 0
  while i < @enemies.length do
    if @enemies[i].type == Enemy_Type::SPECTOR_PHANTOM then
      index = index + 1
    end
    i = i + 1
  end
if max_spector_enemies > index then
  if @spawn_timer >= spawn_delay
    enemy = Enemy_Data.new(0, MAP_HEIGHT - 50, 2, Enemy_Type::SPECTOR_PHANTOM, 4, Direction::EAST)
    @enemies << enemy
  end
end
i = 0
index = 0
  while i < @enemies.length do
    if @enemies[i].type == Enemy_Type::GREATER_PHANTOM then
      index = index + 1
    end
    i = i + 1
  end

if max_greater_enemies > index then
  if @spawn_timer >= spawn_delay
    enemy = Enemy_Data.new(0, MAP_HEIGHT - 50, 2, Enemy_Type::GREATER_PHANTOM, 1, Direction::EAST)
    @enemies << enemy
  end
end

i = 0
index = 0
  while i < @enemies.length do
    if @enemies[i].type == Enemy_Type::GOLDEN_PHANTOM then
      index = index + 1
    end
    i = i + 1
  end

if max_golden_enemies > index then
  if @spawn_timer >= spawn_delay
    enemy = Enemy_Data.new(0, MAP_HEIGHT - 50, 2, Enemy_Type::GOLDEN_PHANTOM, 1, Direction::EAST)
    @enemies << enemy
  end
end
i = 0
index = 0
while i < @enemies.length do
    if @enemies[i].type == Enemy_Type::LESSER_PHANTOM then
      index = index + 1
    end
    i = i + 1
end

  if @spawn_timer >= spawn_delay
    enemy = Enemy_Data.new(0, MAP_HEIGHT - 50, 2, Enemy_Type::LESSER_PHANTOM, 1, Direction::EAST)
    @enemies << enemy
    @spawn_timer = 0
  end
 end 
 if @game_state == Game_State::PAUSED then

 elsif @game_state == Game_State::IN_PLAY or @game_state == Game_State::GAME_OVER then
   enemy_movement()
  end
end

def draw
  if @game_state == Game_State::GAME_OVER or @game_state == Game_State::IN_PLAY or @game_state == Game_State::PAUSED then
    #@grass_background.draw(0, 0, ZOrder::BACKGROUND, 0.5, 0.5)
    #@enemy_2_image.draw(@enemies[i].x_position, @enemies[i].y_position, ZOrder::TOP, ENEMY_WIDTH, ENEMY_HEIGHT)
    life_count(@lives)
    draw_quad(0, 0, Gosu::Color::GREEN, MAP_WIDTH, 0, Gosu::Color::GREEN, 0, MAP_HEIGHT, Gosu::Color::GREEN, MAP_WIDTH, MAP_HEIGHT, Gosu::Color::GREEN, ZOrder::BACKGROUND)
    dark_gray = Gosu::Color.new(105, 105, 105)
    draw_tower_button()
    draw_enemy()
    #draw_range()
    draw_tower()
    draw_quad(MAP_WIDTH, 0, dark_gray, MAP_WIDTH, MAP_HEIGHT, dark_gray, SCREEN_WIDTH, 0, dark_gray, SCREEN_WIDTH, MAP_HEIGHT, dark_gray, ZOrder::MIDDLE)
    draw_bullet()
    if @game_state == Game_State::IN_PLAY then
      @pause_button.draw(PAUSE_BUTTON_X_CORDINATE, PAUSE_BUTTON_Y_CORDINATE, ZOrder::TEXT, 0.05, 0.05)
    elsif @game_state == Game_State::PAUSED then
      @play_paused_button.draw(PAUSE_BUTTON_X_CORDINATE, PAUSE_BUTTON_Y_CORDINATE, ZOrder::TEXT, 0.05, 0.05)
      @play_again_button.draw(PLAY_AGAIN_BUTTON_X_CORDINATE, PLAY_AGAIN_BUTTON_Y_CORDINATE, ZOrder::TEXT, 0.15, 0.15)
      @home_button.draw(PLAY_AGAIN_BUTTON_X_CORDINATE + 70, PLAY_AGAIN_BUTTON_Y_CORDINATE, ZOrder::TEXT, 0.104, 0.104)
    end
  elsif @game_state == Game_State::MAIN_MENU then
    @play_button.draw(PLAY_AGAIN_BUTTON_X_CORDINATE, PLAY_AGAIN_BUTTON_Y_CORDINATE, ZOrder::TEXT, 0.10, 0.10)
    @information_button.draw(PLAY_AGAIN_BUTTON_X_CORDINATE + 70, PLAY_AGAIN_BUTTON_Y_CORDINATE, ZOrder::TEXT, 0.10, 0.10)
    @grass_background.draw(0, 0, ZOrder::BACKGROUND, 0.5, 0.5)
  elsif @game_state == Game_State::INFORMATION_ROOM then
    @grass_background.draw(0, 0, ZOrder::BACKGROUND, 0.5, 0.5)
    @back_button.draw(BACK_BUTTON_X_CORDINATE, BACK_BUTTON_Y_CORDINATE, ZOrder::TEXT, 0.10, 0.10)
    i = 0
    while i < 4#SPECTOR_IMAGE_NAMES.length > i do
       # Gosu::Image.new(SPECTOR_IMAGE_NAMES[0])
      image = find_tower_image(i)
      image.draw(BUTTON_X_CORDINATES[0], BUTTON_Y_CORDINATES[i], ZOrder::TEXT, 0.10, 0.10)
      i = i + 1
    end

    i = 0
    while i < 4 #SPECTOR_IMAGE_NAMES.length > i do
      image = @enemy # Gosu::Image.new(SPECTOR_IMAGE_NAMES[0])
      image = find_phantom_image_names(i)
      image.draw(BUTTON_X_CORDINATES[1], BUTTON_Y_CORDINATES[i], ZOrder::TEXT, 0.10, 0.10)
      i = i + 1
    end

  end
    #red = Gosu::Color.new(200, 0, 0)
    #draw_triangle(280, 200, red, 320, 200, red, 300, 180, red, ZOrder::MIDDLE)
  end
  def find_tower_image(i)
    if TOWER_IMAGE_NAMES[i] == "Guard_Tower.png" then
      image = @guard_tower_image
    elsif TOWER_IMAGE_NAMES[i] == "Energy_Tower.png" then
      image = @energy_tower
    elsif TOWER_IMAGE_NAMES[i] == "Gunner_Tower.png" then
      image = @gunner_tower
    elsif TOWER_IMAGE_NAMES[i] == "Thrasher Tower.png" then
      image = @thrasher_tower
    end
    return image
  end
  def find_phantom_image_names(i)
     if SPECTOR_IMAGE_NAMES[i] == "Enemy.png" then
        image = @enemy_image
      elsif SPECTOR_IMAGE_NAMES[i] == "Enemy_2.png" then
        image = @enemy_2_image
      elsif SPECTOR_IMAGE_NAMES[i] == "Golden_Phantom.png" then
        image = @enemy_golden_phantom_image
      else
        image = @enemy_spector_phantom_image
      end
      return image
  end

#shows the tower range
def draw_range()
 img2 = Gosu::Image.new(Circle.new(200))
 if @button_switch > -1 then
    img2.draw(@slots[@button_switch].x_position, @slots[@button_switch].y_position, ZOrder::BOTTOM, 1, 1, Gosu::Color::WHITE)
 end 
end

def draw_bullet()
 img2 = Gosu::Image.new(Circle.new(50))
 i = 0
 while i < @player_bullet.length do
  if @player_bullet[i].type == Type::GUARD_TOWER then
    img2.draw(@player_bullet[i].x_position, @player_bullet[i].y_position, ZOrder::TOP, 0.1, 0.1, Gosu::Color::WHITE)
    if @game_state == Game_State::IN_PLAY or @game_state == Game_State::GAME_OVER then
      if @player_bullet[i].direction == Direction::NORTH then
      @player_bullet[i].y_position += 1
      elsif @player_bullet[i].direction == Direction::SOUTH then
      @player_bullet[i].y_position -= 1
      elsif @player_bullet[i].direction == Direction::WEST then
        @player_bullet[i].x_position += 1
      elsif @player_bullet[i].direction == Direction::EAST then
        @player_bullet[i].x_position -= 1
      end
    end
  elsif @player_bullet[i].type == Type::ENERGY_TOWER then
    img2.draw(@player_bullet[i].x_position, @player_bullet[i].y_position, ZOrder::TOP, 0.1, 0.1, Gosu::Color::WHITE)
      if @game_state == Game_State::IN_PLAY or @game_state == Game_State::GAME_OVER then
         if @enemies[@player_bullet[i].direction] then 
          x1 = @player_bullet[i].x_position
          y1 = @player_bullet[i].y_position
          x2 = @enemies[@player_bullet[i].direction].x_position
          y2 = @enemies[@player_bullet[i].direction].y_position
          distance = Math.sqrt((x2 - x1)**2 + (y2 - y1)**2)
          x_speed = ((@enemies[@player_bullet[i].direction].x_position - @player_bullet[i].x_position))/distance
          y_speed = ((@enemies[@player_bullet[i].direction].y_position - @player_bullet[i].y_position))/distance
          a = 1/(x_speed.abs + y_speed.abs)
          @player_bullet[i].x_speed = x_speed * a
          @player_bullet[i].y_speed = y_speed * a
          @player_bullet[i].x_position += 3*@player_bullet[i].x_speed
          @player_bullet[i].y_position += 3*@player_bullet[i].y_speed
        else
          @player_bullet = remove_index(i, @player_bullet)
        end
      end
   elsif @player_bullet[i].type == Type::THRASHER_TOWER then
     img2.draw(@player_bullet[i].x_position, @player_bullet[i].y_position, ZOrder::TOP, 0.1, 0.1, Gosu::Color::YELLOW)
      if @game_state == Game_State::IN_PLAY or @game_state == Game_State::GAME_OVER then
        @player_bullet[i].x_position += 5*@player_bullet[i].x_speed
        @player_bullet[i].y_position += 5*@player_bullet[i].y_speed
      end
    elsif @player_bullet[i].type == Type::GUNNER_TOWER then
     img2.draw(@player_bullet[i].x_position, @player_bullet[i].y_position, ZOrder::TOP, 0.1, 0.1, Gosu::Color::YELLOW)
    if @game_state == Game_State::IN_PLAY or @game_state == Game_State::GAME_OVER then
      @player_bullet[i].x_position += 5*@player_bullet[i].x_speed
      @player_bullet[i].y_position += 5*@player_bullet[i].y_speed
    end

  end
  if @player_bullet[i] then
    if @game_state == Game_State::IN_PLAY or @game_state == Game_State::GAME_OVER then
      if @player_bullet[i].timer < 100 then
        @player_bullet[i].timer += 1
      else
        @player_bullet = remove_index(i, @player_bullet)
      end
    end
  end
    i = i + 1
 end
end

  #once a slot has been clicked on, the game will display options for the towers to be made
  def draw_tower_button()
      @button_font.draw("Money: \n $" + @money.to_s, BUTTON_1_X_CORDINATE, BUTTON_1_Y_CORDINATE - 120, ZOrder::TOP, 0.8, 0.8, Gosu::Color::BLACK)
      @button_font.draw("Lives: \n " + @lives.to_s, BUTTON_1_X_CORDINATE, BUTTON_1_Y_CORDINATE - 80, ZOrder::TOP, 0.8, 0.8, Gosu::Color::BLACK)

    if @button_switch > -1 then
      #puts "john Lark"
      @button_font.draw("$" + GUARD_TOWER_COST.to_s, BUTTON_1_X_CORDINATE, BUTTON_1_Y_CORDINATE - 30, ZOrder::TOP, 0.8, 0.8, Gosu::Color::BLACK)
      @button_font.draw("$" + ENERGY_TOWER_COST.to_s, BUTTON_2_X_CORDINATE, BUTTON_2_Y_CORDINATE - 30, ZOrder::TOP, 0.8, 0.8, Gosu::Color::BLACK)
      @guard_tower_image.draw(BUTTON_1_X_CORDINATE, BUTTON_1_Y_CORDINATE, ZOrder::TOP, 0.08, 0.08)
      @energy_tower.draw(BUTTON_2_X_CORDINATE, BUTTON_2_Y_CORDINATE, ZOrder::TOP, 0.08, 0.08)
      @button_font.draw("$" + THRASHER_TOWER_COST.to_s, BUTTON_3_X_CORDINATE, BUTTON_3_Y_CORDINATE - 30, ZOrder::TOP, 0.8, 0.8, Gosu::Color::BLACK)
      @thrasher_tower.draw(BUTTON_3_X_CORDINATE, BUTTON_3_Y_CORDINATE, ZOrder::TOP, 0.08, 0.08)
      @button_font.draw("$" + THRASHER_TOWER_COST.to_s, BUTTON_3_X_CORDINATE, BUTTON_3_Y_CORDINATE - 30, ZOrder::TOP, 0.8, 0.8, Gosu::Color::BLACK)
      @gunner_tower.draw(BUTTON_4_X_CORDINATE, BUTTON_4_Y_CORDINATE, ZOrder::TOP, 0.08, 0.08)
      @button_font.draw("$" + GUNNER_TOWER_COST.to_s, BUTTON_4_X_CORDINATE, BUTTON_4_Y_CORDINATE - 30, ZOrder::TOP, 0.8, 0.8, Gosu::Color::BLACK)
      

    end
  end
end

Game.new.show