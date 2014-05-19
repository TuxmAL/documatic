# -*- encoding: utf-8 -*-

require 'erb'
require 'date'
require 'time'

module Documatic
  module OpenDocumentSpreadsheet
    module Helper
      include ERB::Util

      # Map of OOCalc's visible types (selectable in the UI) to what's
      # stored internally as the office:value-type attribute of a
      # cell.
      TYPES = {
        'Number'     => 'float',
        'Percent'    => 'percentage',
        'Currency'   => 'currency',
        'Date'       => 'date',
        'Time'       => 'time',
        'Scientific' => 'float',
        'Fraction'   => 'string',
        'Boolean'    => 'boolean',
        'Text'       => 'string',
      }
      

      # Renders a complete cell element with options to control the
      # type, style, formula, row and column spans, and other cell
      # attributes.  See the wiki for full details.
      def cell(value, opts = nil)
        opts ||= Hash.new
        opts[:type] ||= (case value.class.to_s
                         when 'Fixnum' then 'Number'
                         when 'Float' then 'Number'
                         when 'DateTime' then 'Date'
                         when 'Date' then 'Date'
                         when 'Time' then 'Time'
                         when 'TrueClass' then 'Boolean'
                         when 'FalseClass' then 'Boolean'
                         else 'Text'
                         end )
        # Setting the :currency option forces the type to 'Currency'
        if opts.has_key?(:currency)
          opts[:type] = 'Currency'
        end
        
        # START OUTPUT
        output = '<table:table-cell'
        # Add style if specified
        opts.has_key?(:style) &&
          output << " table:style-name=\"#{opts[:style]}\""
        # Add formula if specified
        opts.has_key?(:formula) &&
          output << " table:formula=\"#{opts[:formula]}\""
        # Add the value-type attribute for the type
        output << " office:value-type=\"#{TYPES[opts[:type]]}\""
        # Add row and column spans if specified
        opts.has_key?(:colspan) &&
          output << " table:number-columns-spanned=\"#{opts[:colspan]}\""
        opts.has_key?(:rowspan) &&
          output << " table:number-rows-spanned=\"#{opts[:rowspan]}\""
        # The rest of the output depends on the type
        case opts[:type]
        when 'Number', 'Percent', 'Scientific'
          output << " office:value=\"#{ERB::Util.h(value)}\">"
        when 'Currency'
          output << " office:currency=\"#{ERB::Util.h(opts[:currency])}\""
          output << " office:value=\"#{ERB::Util.h(value)}\">"
        when 'Date'
          output << " office:date-value=\"#{value.strftime("%Y-%m-%dT%H:%M:%S")}\">"
        when 'Time'
          output << " office:time-value=\"#{value.strftime("PT%HH%MM%SS")}\">"
        when 'Boolean'
          output << " office:boolean-value=\"#{value.to_s}\">"
        else  # text or fraction
          output << "><text:p>#{ERB::Util.h(value)}</text:p>"
        end
        output << "</table:table-cell>"
        
        return output
      end
      
    end
  end
end
