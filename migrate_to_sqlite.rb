require 'json'

def migrate_objects(klass, json_source_file, id_translation_table)
  objects = []
  relink_queue = []

  File.open(json_source_file, "r").each_line do |line|

    # Sanitize mongo associations
    line.gsub!(/ObjectId\( "([^\)]+)" \)/, ' "\1"')

    # Remove mongo dates
    line.gsub!(/Date\( [\d]+ \)/, '""')

    # Create instance in memory
    memory_object = klass.new

    # Assign properties to instance
    json_object = JSON.parse line
    json_object.keys.each do |key|
      key = (key == '_id' ? 'id' : key)

      # Track links that need updated to new IDs
      if key.ends_with? '_id'
        relink_queue << { object: memory_object, attribute: key, old_id: json_object['_id'] }
        #puts "adding #{relink_queue.last.inspect}"
      end

      memory_object[key] = json_object[key]
    end

    # Save object into DB
    memory_object.save!
    memory_object.reload

    id_translation_table[json_object['_id']] = memory_object.id

    # Store object in memory to create links later
    objects << memory_object
  end

  relink_queue
end

def path_for(klass)
  "/home/drusepth/dump/app10401744/#{klass}.json"
end

classes_to_migrate = %w(users characters equipment languages locations magics universes)

db = {}
relink_queue = []
id_translation_table = {}
classes_to_migrate.each do |klass|
  puts "Loading #{klass} objects"
  relink_events = migrate_objects(klass.singularize.titleize.constantize, path_for(klass), id_translation_table)
  relink_queue << relink_events
end

# After saving everything, do another pass through the relink queue to update association IDs
relink_queue.flatten.each do |relink_event|
  object = relink_event[:object].reload
  attribute = relink_event[:attribute]
  old_id = relink_event[:old_id]
  new_key = id_translation_table[old_id]

  puts "Linking #{object.inspect} attribute #{attribute} from #{old_id} to #{new_key}"

  object[attribute] = new_key
  object.save
end
