# -*- encoding: utf-8 -*-

require 'erb'

module Documatic
  module OpenDocumentText
    module Helper

      include ERB::Util
      

      # Inserts a paragraph (<text:p>) containing the provided content;
      # or nothing if no content is provided.  This helper should be
      # invoked from within "Ruby Block" because paragraphs are
      # block-level elements.
      # 
      # Note that the content is not escaped by default because you
      # might want to include other tags in the content.  You should use
      # ERB::Util.h() to escape any content that could possibly contain
      # XML characters.
      def para(stylename, content = nil)
        end_element = ( content ? ">#{content}</text:p>" : "/>" )
        %Q(<text:p text:style-name="#{stylename}"#{end_element})
      end

      # Inserts a text span (<text:span>) containing the provided
      # content.  This helper should be invoked from within "Ruby
      # Literal" because the tag is a text-level element that shouldn't
      # be escaped.  However the content is escaped.
      def span(stylename, content)
        %Q(<text:span text:style-name="#{stylename}">#{ERB::Util.h(content)}</text:span>)
      end

      # Turns an array of strings into a single, escaped string with
      # OpenDocument line breaks (<text:line-break/>), omitting any
      # blank lines.  Perfect for address blocks etc.
      def line_break(lines)
        lines_esc = lines.collect do |line|
          ERB::Util.h(line)
        end
        return (lines_esc.find_all do |line|
                  line && line.to_s.length > 0
                end).join('<text:line-break/>')
      end
      
      # Inserts a partial into the document at the chosen position.
      # This helper should be invoked from within "Ruby Block" because
      # it inserts unescaped block-level material in the current
      # template.
      # 
      # The +assigns+ hash is passed through to the partial for binding.
      # 
      # This method will add the provided partial to the
      # Documatic::Partial cache if it hasn't yet been loaded; or if it
      # has been loaded then the existing partial will be re-used.
      def partial(filename, assigns = {})
        if template.partials.has_key?(filename)
          p = template.partials[filename]
        else
          p = Documatic::OpenDocumentText::Partial.new(filename)
          template.add_partial(filename, p)
        end
        assigns.merge!(:template => template, :master => master)
        p.process(assigns)
      end

      # Insert a reference to an image file with the minimal set of options
      # (:width and :height in centimetres).
      def image(full_path, opts = {})
        image_name = template.add_image(full_path)
        output = '<draw:frame text:anchor-type="as-char" '
        opts[:width] && output << %Q(svg:width="#{opts[:width]}cm" )
        opts[:height] && output << %Q(svg:height="#{opts[:height]}cm")
        output << '>'
        output << %Q(<draw:image xlink:href="Pictures/#{image_name}" )
        output <<
          'xlink:type="simple" xlink:show="embed" xlink:actuate="onLoad"/>'
        output << '</draw:frame>'
      end
      
    end
  end
end
