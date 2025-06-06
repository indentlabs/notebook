class DocumentAnalysesController < ApplicationController
  before_action :authenticate_user!,          except: [:index]
  before_action :set_document,                except: [:index]
  before_action :authorize_user_for_document, except: [:index]
  before_action :set_document_analysis,       except: [:index]

  before_action :set_navbar_color
  before_action :set_sidenav_expansion
  # before_action :set_navbar_actions

  layout 'tailwind', only: [:index]

  def index
    @document_analyses = DocumentAnalysis.all
  end

  def show
    @navbar_actions = [] unless @analysis.present?
  end

  def readability
  end

  def style
  end

  # def entities
  # end

  def sentiment
    @document_sentiment_color = (@analysis.sentiment_score < 0) ? 'blue' : 'green'
    @document_emotion_data = Hash[{
      "Anger"   => (100 * @analysis.anger_score).round(1),
      "Fear"    => (100 * @analysis.fear_score).round(1),
      "Sadness" => (100 * @analysis.sadness_score).round(1),
      "Disgust" => (100 * @analysis.disgust_score).round(1),
      "Joy"     => (100 * @analysis.joy_score).round(1)
    }.sort_by(&:second).reverse]
    @document_dominant_emotion  = @document_emotion_data.keys.first
    @document_secondary_emotion = @document_emotion_data.keys.second
  end

  # def destroy
  #   @analysis.destroy
  #   redirect_to document_analyses_url, notice: 'Document analysis was successfully destroyed.'
  # end

  private

  def authorize_user_for_document
    unless @document.present? && (current_user || User.new).can_read?(@document)
      redirect_to(root_path, notice: "That document either doesn't exist or you don't have permission to view it.")
      return false
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_document_analysis
    @analysis = @document.document_analysis.where.not(queued_at: nil).order('updated_at DESC').first
  end

  def set_document
    @document = Document.find_by(id: params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def document_analysis_params
    params.fetch(:document_analysis, {})
  end

  def set_navbar_actions
    @navbar_actions = [
      {
        label: "Overview",
        href:  analysis_document_path(@document)
      },
      {
        label: "Readability",
        href:  analysis_readability_document_path(@document)
      },
      {
        label: "Style",
        href:  analysis_style_document_path(@document)
      },
      {
        label: "Sentiment",
        href:  analysis_sentiment_document_path(@document)
      }
    ]
  end

  def set_sidenav_expansion
    @sidenav_expansion = 'writing'
  end

  def set_navbar_color
    @navbar_color = '#FF9800'
  end
end
