module McpDocument

require 'prawn'
require 'prawn/measurement_extensions'

    class Generator
        def create_document(width:, height:, document_text:)
            width_in_pdf_pt = width.mm
            height_in_pdf_pt = height.mm

            document_pdf = create_pdf(size: [width_in_pdf_pt, height_in_pdf_pt], document_text: document_text)
        end
        
        def create_pdf(size:, document_text:)
            temp_pdf = Dir::Tmpname.make_tmpname(['MCPDOC', '.pdf'], nil)
            Prawn::Document.generate(temp_pdf, :page_size => size, :page_layout => :portrait, :margin => 0) do
                bounding_box([25, bounds.height-25], :width => bounds.width-50, :height => bounds.height-50) do
                    text document_text
                end
            end

            return temp_pdf
        end

    end

end