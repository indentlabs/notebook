class EmotionService < Service
  def self.color_for_emotion(emotion_symbol)
    case emotion_symbol
      when :joy
        return 'yellow'
      when :sadness
        return 'blue'
      when :fear
        return 'grey'
      when :disgust
        return 'green'
      when :anger
        return 'red'
      else
        return 'black'
    end
  end
end