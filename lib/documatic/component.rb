# -*- encoding: utf-8 -*-

require 'erb'

module Documatic
  class Component
    include ERB::Util

    attr_accessor :erb
    attr_accessor :erb_text

    def initialize(erb_text)
      @erb_text = erb_text
      @erb = ERB.new(erb_text)
    end
    
    # Injects the provided assigns into this component and sends it through ERB.
    def process(local_assigns)
      if local_assigns.is_a? Binding
        context = local_assigns
      else  # Hash
        local_assigns.each do |key, val|
          self.define_singleton_method(key) do val end
        end
        context = binding
      end

      begin
        @xml = nil ; @text = self.erb.result(context)
      rescue
        lines = self.erb_text.split /\n/
        counter = 1
        lines.each do |line|
          puts "#{counter}:\t#{line}"
          counter += 1
        end
        raise
      end
    end

    # Returns a REXML::Document constructed from the text of this
    # component.  Note that this flushes self.text: subsequently if
    # self.text is called it will be reconstructed from this XML
    # document and self.xml will be flushed.  Therefore the content of
    # this partial is always stored either as XML or text, never both.
    def xml
      @xml ||= REXML::Document.new( remove_instance_variable(:@text) )
    end

    # Returns the text of this component.  Note that this flushes
    # self.xml: subsequently if self.xml is called it will be
    # reconstructed from this text and self.text will be flushed.
    def text
      @text ||= ( remove_instance_variable(:@xml) ).to_s
    end

    # Merge the auto-styles from the cached partials into
    # <office:automatic-styles> of this component.  This method isn't
    # intended to be called directly by client applications: it is
    # called automatically by Documatic::Template after processing.
    def merge_partial_styles(partials)
      styles = self.xml.root.elements['office:automatic-styles']
      if styles
        partials.each do |partial|
          partial.styles.each_element do |e|
            styles << e
          end
        end
      end
    end
    
    # to_s() is a synonym for text()
    alias_method :to_s, :text


    protected
    
    # Adds methods to the singleton class representing the current
    # instance.  Useful for injecting faux local variables into an
    # instance object.
    # Courtesy John Hume,
    # http://practicalruby.blogspot.com/2007/02/ruby-metaprogramming-introduction.html
    def define_singleton_method(name, &body)
      (class << self ; self ; end).send(:define_method, name, &body)
    end
    
  end
end
