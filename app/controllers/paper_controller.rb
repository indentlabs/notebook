class PaperController < ApplicationController
  def index
  end

  def generate
    pages_to_include = [
      ["Cover",       1], # Notebook Paper cover page
      ["Owner",       1], # "If lost, contact X page"
      [Universe.name, 1], # single Universe page
    ] + paper_params.keys.map { |page_type, page_count| [page_type, 20] }\
    + ["Notebook.ai", 1]  # Page talking about Notebook.ai <3

    # pdf_html = ActionController::Base.new.render_to_string(template: 'paper/index', layout: 'pdf')
    # pdf = WickedPdf.new.pdf_from_string(pdf_html)
    # pdf = WickedPdf.new.pdf_from_html_file('/your/absolute/path/here')
    pdf = WickedPdf.new.pdf_from_string('<h1>Hello There!</h1>')
    send_data(pdf, filename: 'file.pdf')
  end

  private

  def paper_params
    params.require(:paper)
          .permit(*Rails.application.config.content_types[:all_non_universe].map(&:name))
          .reject { |klass, boolean| boolean == "0" }
  end
end
