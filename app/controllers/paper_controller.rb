class PaperController < ApplicationController
  def index
  end

  def generate
    pages_to_include = [
      ["Cover",       1], # Notebook Paper cover page
      ["Owner",       1], # "If lost, contact X page"
      [Universe.name, 1], # single Universe page
    ]
    pages_to_include.concat paper_params.keys.map { |page_type, page_count| [page_type, 2] }
    pages_to_include.push   ["Notebook.ai", 1]  # Page talking about Notebook.ai <3

    pdf = generate_pdf(pages_to_include)
    render_pdf(pdf)
  end

  def individual
    page_type = params.fetch(:page_type)
    raise "Invalid page type: #{page_type}" unless Rails.application.config.content_types[:all].map(&:name).include?(page_type)
    
    pages_to_include = [
      [page_type, 1]
    ]

    pdf = generate_pdf(pages_to_include)
    render_pdf(pdf, filename="Notebook-#{page_type}.pdf")
  end

  private

  def generate_pdf(page_quantity_mapping)
    # Build a gigantic HTML model of all the page contents
    concatenated_pdf_html = ''
    page_quantity_mapping.each do |page_template, page_count|
      page_html = ActionController::Base.new.render_to_string(template: "paper/templates/#{page_template.downcase}", layout: nil)
      page_count.times do |i|
        # Add a manual pagebreak
        concatenated_pdf_html += "<div class='alwaysbreak'></div>"

        # Append the page template
        concatenated_pdf_html += page_html
      end
    end

    # Wrap the page contents in the global pdf layout
    formatted_pdf = ActionController::Base.new.render_to_string(template: "layouts/pdf", layout: nil)
    formatted_pdf.gsub!('<!--PDF_CONTENT-->', concatenated_pdf_html)

    # Debugging:
    # render html: formatted_pdf.html_safe

    # Create the PDF and return it
    WickedPdf.new.pdf_from_string(formatted_pdf)
  end

  def render_pdf(pdf, filename='Notebook.pdf')
    send_data(
      pdf,
      filename:    filename,
      type:        "application/pdf", # Uncommenting these lets us render the PDF in-browser instead of downloading
      disposition: "inline"           # ""
    )
  end

  def paper_params
    params.require(:paper)
          .permit(*Rails.application.config.content_types[:all_non_universe].map(&:name))
          .reject { |klass, boolean| boolean == "0" }
  end
end
