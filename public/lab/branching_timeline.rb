# A timeline class to basically be the "universe for scenes" (while still existing in a universe)
# that allows for branching multiple possible scenes from any given scene. Handles breadcrumbs
# and has some methods to order potential following scenes in the UI.

# todo double check removal logic later

class Scene
  def initialize title, previous_scene=nil
    @title = title
    @previous_scene = previous_scene
    @choices = []
  end
  
  def title
    @title
  end
  
  def previous_scene
    @previous_scene
  end
  
  def previous_scene= scene
    @previous_scene = scene
    @previous_scene.choices << self # handled by has_many
  end
  
  def choices # rename to next_scenes or something
    @choices
  end
end

class Timeline # => user has_many: :timelines
  #has_many :scenes # in tree, not array

  def scene_tree # instance singleton
    @scene_tree ||=
      # build tree from self.scenes
    end
  end
  
  def self.build_breadcrumb current_scene
    breadcrumb = [current_scene.title]
    while !current_scene.previous_scene.nil? do
      current_scene = current_scene.previous_scene
      breadcrumb << current_scene.title
    end
    
    return breadcrumb.compact.reverse
  end

end

timeline = Timeline.new
opening_scene = Scene.new "opening scene"
introduce_alice = Scene.new "introduce alice"
introduce_bob = Scene.new "introduce bob"
bob_dies = Scene.new "bob dies"

# With a standalone scene, breadcrumb should just be its title
puts "yuh" if Timeline.build_breadcrumb(bob_dies) == ["bob dies"]

# Adding bob's introduction should prepend the timeline
bob_dies.previous_scene = introduce_bob
puts "yep" if Timeline.build_breadcrumb(bob_dies) == ["introduce bob", "bob dies"]
puts "yah" if Timeline.build_breadcrumb(introduce_bob) == ["introduce bob"]

# Timeline should continue to prepend
introduce_bob.previous_scene = opening_scene
puts "yis" if Timeline.build_breadcrumb(bob_dies) == ["opening scene", "introduce bob", "bob dies"]

# Branching the timeline still works in the same way
introduce_alice.previous_scene = opening_scene
puts "yar" if Timeline.build_breadcrumb(introduce_alice) == ["opening scene", "introduce alice"]

# Should be able to fetch the potentially-next scenes for a given scene as well
puts "yii" if opening_scene.choices.map(&:title) == ["introduce bob", "introduce alice"]

# Should be able to reorder scene choices per ordering, probability, or prerequisitves
# ordering - user manually drags and drops scenes on timeline, async posts back new order
# probability - allow users to specify a probability for each scene happening (using some
#               UI like a multi-notched slider or draggable pie chart to make this painless)
# prerequisites - perhaps let people publish their own sandboxed "value check" functions to
#                 an API they can call, which lets them run some immutable logic on some
#                 content they have access to -- and then let people specify those functions
#                 (or just premade ones we generate, e.g. "[Character] is in [Location]")
#                 and the scenes order by how many prerequisites are complete (probably with
#                 some progress bars / displaying what prerequisites are missing)



#puts Timeline.build_breadcrumb(introduce_alice).inspect
