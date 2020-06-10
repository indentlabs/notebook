namespace :machine_learning do 
  task roleplaying: :environment do 
    output_file = 'roleplay-training.txt'
    roleplay_boards = [
      {
        slug:  'roleplaying',
        genre: 'none'
      },
      {
        slug:  'fandom-world',
        genre: 'fandom'
      },
      {
        slug:  'limited',
        genre: 'none'
      },
      {
        slug:  'character-chats',
        genre: 'character-chat'
      },
      {
        slug:  'fantasy-tavern',
        genre: 'fantasy'
      },
      {
        slug:  'futuristic',
        genre: 'sci-fi'
      },
      {
        slug:  'beginner-s-lounge',
        genre: 'none'
      },
      {
        slug:  'realistic-modern',
        genre: 'modern'
      }
    ]

    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil

    file = File.open(output_file, "w")
    roleplay_boards.each do |board_data|
      board = Thredded::Messageboard.find_by(slug: board_data[:slug])
      raise "Board with slug #{board_data[:slug]} not found!" unless board.present?

      topics = board.topics.where(moderation_state: 'approved')
      puts "Starting on board #{board.name} (#{topics.count} topics)"
      topics.find_each do |topic|
        posts = topic.posts.where(moderation_state: 'approved')
        puts topic.title + ' - ' + posts.count.to_s + ' posts'

        file.write("[NEW TOPIC]\n\n")

        posts.find_each.with_index do |post, index|
          file.write("[user_id: #{post.user_id}][genre: #{board_data[:genre]}][thread_id: #{topic.id}][post_index: #{index}][thread_title: #{topic.title}]\n")
          file.write(post.content)
          file.write("\n\n" + ('-' * 67) + "\n\n")
        end

        file.write("[END TOPIC]\n\n")
      end

    end
    file.close
    puts "Training data written to #{output_file}"

    # Re-enable console logger
    ActiveRecord::Base.logger = old_logger
  end
end