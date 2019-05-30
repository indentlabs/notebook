namespace :page_type do
  desc "Do all the stuff"
  task create: :environment do
    puts "Please enter the page type model (e.g. Character or Planet): "
    page_type = STDIN.gets.chomp
    if klass = page_type.constantize
      puts "Creating page type for #{page_type}"
    else
      puts "No model matches #{page_type}"
      exit
    end

    puts "Migrating database"
    `rake db:migrate`

    editable_fields = klass.columns.map(&:name) - %w(id deleted_at created_at updated_at user_id)
    editable_fields.map!(&:to_sym)

    # Move model from models/ to models/content_types/
    # (we write the file in the next step; this just removes the original)
    puts "Removing base model at models/#{page_type.downcase}.rb"
    `rm app/models/#{page_type.downcase}.rb`

    # Add concerns to new model
    puts "Writing class definition to app/models/content_types/#{page_type.downcase}.rb"
    #TODO: read from content_types/_template.erb or something?
    class_definition = """
class #{page_type} < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user
  validates :name, presence: true
  validates :user_id, presence: true

  include BelongsToUniverse
  include IsContentPage
  
  include Serendipitous::Concern

  include Authority::Abilities
  self.authorizer_name = 'ExtendedContentAuthorizer'

  def self.color
    'black'
  end

  def self.hex_color
    '#000000'
  end

  def self.icon
    'info'
  end

  def self.content_name
    '#{page_type.downcase}'
  end
end
    """
    File.open("app/models/content_types/#{page_type.downcase}.rb", 'w') do |file|
      file.write(class_definition)
    end

    puts "Writing controller definition"
    controller_definition = """
class #{page_type.pluralize}Controller < ContentController
  private

  def content_param_list
    [
      #{editable_fields.map { |f| ":#{f}" }.join(', ')}
    ] + [ #<relations>

    ]
  end
end
    """
    File.open("app/controllers/#{page_type.downcase.pluralize}_controller.rb", 'w+') do |file|
      file.write(controller_definition)
    end

    puts "Writing routes"
    routes = File.read("config/routes.rb")

    # Swap new routes in
    routes.gsub!(/#<users_page_types>/, "get :#{page_type.downcase.pluralize}, on: :member\n    #<users_page_types>")
    routes.gsub!(/#<universes_page_types>/, "get :#{page_type.downcase.pluralize}, on: :member\n    #<universes_page_types>")
    routes.gsub!(/#<page_type_resources>/, "resources :#{page_type.downcase.pluralize}\n    #<page_type_resources>")

    # Write new routes back to file
    File.open("config/routes.rb", 'w') do |file|
      file.write(routes)
    end

    puts "Writing config/attributes/#{page_type.downcase}.yml"
    attributes_template = """
:overview:
  :label: Overview
  :icon: info
  :attributes:
""" +
    editable_fields.map do |field|
      next if ["private_notes", "notes", "privacy", "universe_id"].include?(field)
      "    - :name: #{field.to_s}\n      :label: #{field.to_s.titleize}"
    end.compact.join("\n") + """
:gallery:
  :label: Gallery
  :icon: photo_library
:changelog:
  :label: Changelog
  :icon: history
:notes:
  :label: Notes
  :icon: edit
  :attributes:
    - :name: notes
      :label: Notes
    - :name: private_notes
      :label: Private Notes
      :description: Private notes are <em>always</em> visible to only you, even if content is made public and shared.
    """

    File.open("config/attributes/#{page_type.downcase}.yml", 'w+') do |file|
      file.write(attributes_template)
    end

  end
end
