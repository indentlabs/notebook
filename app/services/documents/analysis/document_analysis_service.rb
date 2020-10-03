module Documents
  module Analysis
    class DocumentAnalysisService < Service
      def self.create_placeholder_analysis(document)
        document.document_analysis.first_or_create
      end      
    end
  end
end
