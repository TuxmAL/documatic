require 'rexml/document'
require 'rexml/text'
require 'rexml/attribute'
require 'zip'
require 'erb'
require 'fileutils'

module Documatic::OpenDocumentSpreadsheet
  class Template
    include ERB::Util
    
    attr_accessor :content
    attr_accessor :styles
    attr_accessor :jar
    # The raw contents of 'content.xml'.
    attr_accessor :content_raw
    # Compiled text, to be written to 'content.erb'
    attr_accessor :content_erb

    # RE_STYLES match positions
    STYLE_NAME = 1
    STYLE_TYPE = 2
    
    # RE_ERB match positions
    ROW_START  = 1
    TYPE       = 2
    ERB_CODE   = 3
    ROW_END    = 4

    # Abbrevs
    DSC = Documatic::OpenDocumentSpreadsheet::Component
    
    class << self

      def process_template(args, &block)
        if args[:options] && args[:options].template_file &&
            args[:options].output_file
          output_dir = File.dirname(args[:options].output_file)
          File.directory?(output_dir) || FileUtils.mkdir_p(output_dir)
          FileUtils.cp(args[:options].template_file, args[:options].output_file)
          template = self.new(args[:options].output_file)
          template.process :data => args[:data], :options => args[:options]
          template.save
          if block
            block.call(template)
            template.save
          end
          template.close
        else
          raise ArgumentError,
          'Need to specify both :template_file and :output_file in options'
        end
      end
            
    end  # class << self
    
    def initialize(filename)
      @filename = filename
      @jar = Zip::File.open(@filename)
      return true
    end
    
    def process(local_assigns = {})
      # Compile this template, if not compiled already.
      self.jar.find_entry('documatic/master') || self.compile
      # Process the main (body) content.
      @content = DSC.new( self.jar.read('documatic/master/content.erb') )
      @content.process(local_assigns)
    end

    def save
      # Gather all the styles from the partials, add them to the
      # master's styles.  Put the body into the document.
      self.jar.get_output_stream('content.xml') do |f|
        f.write self.content.to_s
      end
    end

    def close
      # To get rid of an annoying message about corrupted files in OOCalc 3.2.0
      # we must remove the compiled content before we close our ODS file.
      self.jar.remove('documatic/master/content.erb')
      # Now we can safely close our document.
      self.jar.close
    end
    
    def compile
      # Read the raw files
      @content_raw = regularise_styles( self.jar.read('content.xml') )
      @content_erb = self.erbify(@content_raw)

      # Create 'documatic/master/' in zip file
      self.jar.find_entry('documatic/master') ||
      self.jar.mkdir('documatic/master')
      
      self.jar.get_output_stream('documatic/master/content.erb') do |f|
        f.write @content_erb
      end
    end


    protected

    # Change OpenDocument line breaks and tabs in the ERb code to
    # regular characters.
    def unnormalize(code)
      code = code.gsub(/<text:line-break\/>/, "\n")
      code = code.gsub(/<text:tab\/>/, "\t")
      return REXML::Text.unnormalize(code)
    end


    # Massage OpenDocument XML into ERb.  (This is the heart of the compiler.)
    def erbify(code)
      # First gather all the ERb-related derived styles
      remaining = code
      styles = {'Ruby_20_Code' => 'Code', 'Ruby_20_Value' => 'Value',
        'Ruby_20_Literal' => 'Literal'}
      re_styles = /<style:style style:name="([^"]+)" style:parent-style-name="Ruby_20_(Code|Value|Literal)" style:family="table-cell">/
      
      while remaining.length > 0
        md = re_styles.match remaining
        if md
          styles[md[STYLE_NAME]] = md[STYLE_TYPE]
          remaining = md.post_match
        else
          remaining = ""
        end
      end
      
      remaining = code
      result = String.new
      
      # Then make a RE that includes the ERb-related styles.
      # Match positions:
      # 
      #  1. ROW_START   Begin table row ?
      #  2. TYPE        ERb text style type
      #  3. ERB_CODE    ERb code
      #  4. ROW_END     End table row (empty cells then end of row) ?
      #
      # "?": optional, might not occur every time
      re_erb = /(<table:table-row[^>]*>)?<table:table-cell [^>]*table:style-name="(#{styles.keys.join '|'})"[^>]*><text:p>([^<]*)<\/text:p><\/table:table-cell>(((<table:covered-table-cell[^\/>]*\/>)|(<table:table-cell[^\/>]*\/>))*<\/table:table-row>)?/

      # Then search for all text using those styles
      while remaining.length > 0

        md = re_erb.match remaining
        
        if md
          
          result += md.pre_match
          
          #match_code = false
          #match_row  = false

             # if md[ROW_START] and md[ROW_END]
             #        match_row=true
             #      end

          skip_row=false
          #create cells, but dont append
          cells= case styles[md[TYPE]]
                 when "Code" then 
                   skip_row=true
                   "<% #{self.unnormalize md[ERB_CODE]} %>"
                 when "Literal" then "<%= #{self.unnormalize md[ERB_CODE]} %>"
                 when "Value" then  "<%=cell (#{self.unnormalize md[ERB_CODE] }) %>" #let helper build the correct "cell"
                 end
          
          #fist see if we should open row tag
		  #
		  #N.B - this assumes that there should be NO CELL VALUS after this one on the same row (will create invalid document)... 
          if md[ROW_START] and not skip_row
            result+= md[ROW_START]
          end
          
          #then cell body
          result+=cells

          #then close
          if md[ROW_END] and not skip_row
           result += md[ROW_END]
          end
          
          remaining = md.post_match
          
        else  # no further matches
          result += remaining
          remaining = ""
        end
      end
      
      return result
    end


    # OOo has a queer way of storing style information for cells.  In
    # some cases it is in the cell's attribute "table:style-name", but
    # the default style for cells is also stored in the columns
    # section at the beginning of each sheet.  So there's no way of
    # knowing in advance whether a cell will have its style specified
    # or whether it has to be implied from the column definitions.

    # This method regularises the cell styles: it takes the style
    # definitions from each sheet's column definitions and applies
    # them to any cells where the style is not specified.  The result
    # is a still-valid XML document but with explicit styles on each
    # cell.  This makes the document easier to compile.

    def regularise_styles(content_raw)
      doc = REXML::Document.new(content_raw)

      # Get the default column types from all the sheets (tables) in
      # the workbook
      num_tables = doc.root.elements.to_a('//office:body/*/table:table').length
      (1 .. num_tables).to_a.each do |tnum|
        col_types = []
        cols = doc.root.elements.to_a("//table:table[#{tnum}]/table:table-column")
        cols.each do |col|
          (0 ... (col.attributes['table:number-columns-repeated'] ||
                  1).to_i).to_a.each do
            col_types << col.attributes['table:default-cell-style-name']
          end
        end  # each column

        # Get the number of rows for each table
        num_rows = doc.root.elements.to_a("//table:table[#{tnum}]/table:table-row").length

        # Go through each row and process its cells
        (1 .. num_rows).to_a.each do |rnum|
          # The cells are both <table:table-cell> and
          # <table:covered-table-cell>
          cells = doc.root.elements.to_a(<<-END
//table:table[#{tnum}]/table:table-row[#{rnum}]/(table:table-cell | table:covered-table-cell)
END
                                         )
          # Keep track of the column number, for formatting purposes
          # (c.f. col_types)
          col_num = 0
          cells.each do |cell|
            # Only need to explicitly format the <table:table-cell>s
            if cell.name == 'table-cell'
              cell.attributes['table:style-name'] ||= col_types[col_num]
            end
            # Advance the column number, based on the columns spanned
            # by the cell
            col_num += (cell.attributes['table:number-columns-repeated'] ||
                        1).to_i
          end

        end  # each row
      end  # each table

      return doc.to_s
    end
    
  end
end
