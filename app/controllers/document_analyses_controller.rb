class DocumentAnalysesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_document
  before_action :authorize_user_for_document
  before_action :set_document_analysis

  before_action :set_navbar_color
  before_action :set_sidenav_expansion
  before_action :set_navbar_actions

  # def index
  #   @document_analyses = DocumentAnalysis.all
  # end

  # GET /document_analyses/1
  def show
  end

  def readability
  end

  def entities
  end

  def sentiment
  end

  def style
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
