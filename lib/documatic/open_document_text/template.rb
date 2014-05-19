# -*- encoding: utf-8 -*-

require 'rexml/document'
require 'rexml/attribute'
require 'zip/zip'
require 'erb'
require 'fileutils'

module Documatic::OpenDocumentText
  class Template
    include ERB::Util

    # The template's content component.  This is an instance of
    # Documatic::Component, instantiated from the compiled (embedded
    # Ruby) version of 'content.xml'.
    attr_accessor :content
    # The template's styles component.  This is an instance of
    # Documatic::Component, instantiated from the compiled (embedded
    # Ruby) version of 'styles.xml'.
    attr_accessor :styles
    # The template's JAR file (i.e. an instance of Zip::ZipFile)
    attr_accessor :jar
    # The raw contents of 'content.xml'.
    attr_accessor :content_raw
    # Compiled text, to be written to 'content.erb'
    attr_accessor :content_erb
    # The raw contents of 'styles.xml'
    attr_accessor :styles_raw
    # Compiled text, to be written to 'styles.erb'
    attr_accessor :styles_erb

    # Abbrevs
    DTC = Documatic::OpenDocumentText::Component

    class << self
      # Process a template and save it to an output file.
      #
      # The argument is a hash with the keys :options and :data.
      # :options should contain an object that responds to
      # #template_file and #output_file.  #template_file is the path
      # and filename to the OpenDocument template to be used;
      # #output_file is where the processed results will be stored.
      # The #template_file must exist, and the #output_file path must
      # either exist or the current process must be able to create it.
      #
      # An optional block can be provided to this method.  The block
      # will be passed the template currently being processed (i.e. an
      # instance of Documatic::OpenDocumentText::Template).  The block
      # can peform manipulation of the template directly by
      # e.g. accessing the template's JAR or the content or styles
      # components.  The template will be saved after the block exits.
      def process_template(args, &block)       
        if args[:options] && args[:options].template_file &&
            args[:options].output_file
          output_dir = File.dirname(args[:options].output_file)
          File.directory?(output_dir) || FileUtils.mkdir_p(output_dir)
          FileUtils.cp(args[:options].template_file, args[:options].output_file)
          template = self.new(args[:options].output_file)
          template.process :data => args[:data], :options => args[:options],
          :template => template, :master => template
          template.save
          if block
            block.call(template)
            template.save
          end
          template.close
        else
          raise ArgumentError, 'Need to specify both :template_file and :output_file in options'
        end
      end
            
    end  # class << self
    
    def initialize(filename)
      @filename = filename
      @jar = Zip::ZipFile.open(@filename)
      return true
    end
    
    def process(local_assigns = {})
      # Compile this template, if not compiled already.
      self.jar.find_entry('documatic/master') || self.compile
      # Process the styles (incl. headers and footers).
      # This is conditional because partials don't need styles.erb.
      @styles = DTC.new(self.jar.read('documatic/master/styles.erb') )
      @styles.process(local_assigns)
      # Process the main (body) content.
      @content = DTC.new( self.jar.read('documatic/master/content.erb') )
      @content.process(local_assigns)
      # Merge styles from any partials into the main template
      if self.partials.keys.length > 0
        @content.merge_partial_styles(self.partials.values)
      end
      # Copy any images into this jar
      if images.length > 0
        self.jar.find_entry('Pictures') || self.jar.mkdir('Pictures')
        images.keys.each do |filename|
          path = images.delete(filename)
          self.jar.add("Pictures/#{filename}", path)
        end
      end
    end

    def save
      # Gather all the styles from the partials, add them to the master's styles.
      # Put the body into the document.
      self.jar.get_output_stream('content.xml') do |f|
        f.write self.content.to_s
      end

      if self.styles
        self.jar.get_output_stream('styles.xml') do |f|
          f.write self.styles.to_s
        end
      end
    end

    def close
      # To get rid of an annoying message about corrupted files in OOwriter 3.2.0
      # we must remove the compiled content and styles before we close our ODT file.
      self.jar.remove('documatic/master/styles.erb')
      self.jar.remove('documatic/master/content.erb')
      # Now we can safely close our document.
      self.jar.close
    end

    # Read the xml stream with REXML and use it to find nodes on which to act upon.
    def compile
      @content_erb = self.erbify('content.xml')
      @styles_erb = self.erbify('styles.xml')

      # Create 'documatic/master/' in zip file
      self.jar.find_entry('documatic/master') || self.jar.mkdir('documatic/master')
      
      self.jar.get_output_stream('documatic/master/content.erb') do |f|
        f.write @content_erb
      end
      self.jar.get_output_stream('documatic/master/styles.erb') do |f|
        f.write @styles_erb
      end
    end

    # Returns a hash of images added during the processing of the
    # current template.  (This method is not intended to be called
    # directly by application developers: it is used indirectly by
    # the #image helper to add images from within an OpenDocument
    # template.)
    def images
      @images ||= Hash.new
    end        
    
    # Add an image to the current template.  The argument is the
    # path and filename of the image to be added to the template.
    # This can be an absolute path or a relative path to the current
    # directory.  Returns the basename of file if it exists;
    # otherwise an ArgumentError exception is raised.
    def add_image(full_path)
      if File.exists?(full_path)
        image = File.basename(full_path)
        self.images[image] = full_path
        return image
      else
        raise ArgumentError, 'Attempted to add non-existent image to template'
      end
    end

    def partials
      @partials ||= Hash.new
    end

    def add_partial(full_path, partial)
      self.partials[full_path] = partial
    end
    
    
    protected

    def pretty_xml(filename)
      # Pretty print the XML source
      xml_doc = REXML::Document.new(self.jar.read(filename))
      xml_text = String.new
      xml_doc.write(xml_text, 0)

      return xml_text
    end
    
    # Change OpenDocument line breaks, tabs and spaces 
    # in the ERb code to regular characters.
    def unnormalize(element)
      case element.name 
      when 'line-break'
        text = "\n"
      when 'tab'
        text = "\t"
      when 's'
        text = ' '
      else
        # do nothing for now, but collecting all texts values
        # removing any surrounding element if the case (i.e. span).
        text = element.texts.inject('') {|txt, t| txt << t.value}
      end
      return REXML::Text.unnormalize(text)
    end

    # Massage OpenDocument XML into ERb (this is the heart of the compiler),
    # not using RegExp but REXML itself to find ERb-related nodes.
    # At this time the only nodes gathered are those with character style named
    # 'Ruby Code', 'Ruby Value', 'Ruby Block' and 'Ruby Literal'.
    # o 'Ruby Code': simply evaluate your code without returning anything;
    #                useful to set up your variables or define your helper 
    #                functions into the document context.
    # o 'Ruby Value': evaluate your code returning the result as text; this text
    #                 *is* escaped using ERB::Util.h to avoid any clash with XML 
    #                 tags into ODT document.
    # o 'Ruby Value',
    # o 'Ruby Block': evaluate your code returning the result as text; this text
    #                 *is* *not* escaped to allow tag creation into ODT document.
    def erbify(filename)     
     # First gather all the ERb-related derived styles
     # styles = {'Ruby_20_Code' => 'Code', 'Ruby_20_Value' => 'Value',
     #   'Ruby_20_Block' => 'Block', 'Ruby_20_Literal' => 'Literal'}
     # re_styles = /<style:style style:name="([^"]+)"[^>]* style:parent-style-name="Ruby_20_(Code|Value|Block|Literal)"[^>]*>/
      styles = {'Ruby_20_Code' => '', 'Ruby_20_Value' => '= ERB::Util.h(',
        'Ruby_20_Block' => '=', 'Ruby_20_Literal' => '='}

      xml_doc = REXML::Document.new(self.jar.read(filename))
      styles.each_pair do |key, val|
        xpath="//*[@text:style-name=\"#{key}\"]"
        REXML::XPath.each(xml_doc, xpath) do |el|
          text = ''
          el_style = []
          el_class = []
          unless el.has_elements?
            w = el.texts.inject('') {|txt, t| txt << t.value}
            text = REXML::Text.unnormalize(w)
          else
            # Change OpenDocument line breaks, tabs and spaces in the ERb code to regular characters.
            # as done by unnormalize earlier 
            el.elements.each do |el|
              case el.node_type
              when :text
                text << REXML::Text.unnormalize(el.value)
              when :element
                el_style << el.attribute('style-name', 'text').value if el.attribute('style-name', 'text')
                el_class << el.attribute('class-names', 'text').value if el.attribute('class-names', 'text')
                text << unnormalize(el)
              end
            end
          end
          # we use a non existant entity &perc; to ease the substitution after 
          # parsing the whole document with REXML.
          erb_text = "<&perc;#{val}#{text}#{')' if val.include? '('}&perc;>"
          new_el = REXML::Element.new('text:span')
          #puts "el_style ->#{el_style}<-"
          #puts "el_class ->#{el_class}<-"
          #puts "(el_style + el_class) ->#{el_style + el_class}<-"
          class_names = (el_style + el_class).join(' ')
          #new_el.add_attribute('text:class-names', class_names) if class_names != ''
          new_el.add_attribute('text:style-name', class_names) if class_names != ''
          new_el.text=(erb_text)
          el.replace_with(new_el)
          #el.replace_with(REXML::Text.new(erb_text))
        end
      end
      rexml_text=''
      xml_doc.write(rexml_text, -1, true)
      rexml_text.gsub!('&lt;&amp;perc;', '<%')
      rexml_text.gsub!('&amp;perc;&gt;', '%>')
      return rexml_text
    end

  end
end
