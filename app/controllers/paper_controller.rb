class PaperController < ApplicationController
  def index
  end

  def generate
    pages_to_include = [
      ["Cover",       1], # Notebook Paper cover page
      ["Owner",       1], # "If lost, contact X page"
      [Universe.name, 1], # single Universe page
    ] + paper_params.keys.map { |page_type, page_count| [page_type, 3] }

    pages_to_include.push ["Notebook.ai", 1]  # Page talking about Notebook.ai <3

    # Build a gigantic HTML model of all the page contents
    concatenated_pdf_html = ''
    pages_to_include.each do |page_template, page_count|
      page_html = ActionController::Base.new.render_to_string(template: "paper/templates/#{page_template.downcase}", layout: nil)
      page_count.times do |i|
        concatenated_pdf_html += page_html

        # Add a manual pagebreak
        concatenated_pdf_html += "<div class='alwaysbreak'></div>"
      end
    end

    # Wrap the page contents in the global pdf layout
    formatted_pdf = ActionController::Base.new.render_to_string(template: "layouts/pdf", layout: nil)
    formatted_pdf.gsub!('<!--PDF_CONTENT-->', concatenated_pdf_html)

    # Render the PDF
    pdf = WickedPdf.new.pdf_from_string(formatted_pdf)

    send_data(
      pdf,
      filename:    'Notebook.pdf',
      # type:        "application/pdf",
      # disposition: "inline"
    )
    # render html: formatted_pdf.html_safe
  end

  private

  def paper_params
    params.require(:paper)
          .permit(*Rails.application.config.content_types[:all_non_universe].map(&:name))
          .reject { |klass, boolean| boolean == "0" }
  end
end
