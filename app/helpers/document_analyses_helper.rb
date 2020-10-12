module DocumentAnalysesHelper
  def emotion_color(emotion)
    case emotion.downcase
    when 'sadness'
      'blue'
    when 'fear'
      'grey'
    when 'disgust'
      'green'
    when 'anger'
      'red'
    when 'joy'
      'orange'
    else
      'black'
    end
  end
end
