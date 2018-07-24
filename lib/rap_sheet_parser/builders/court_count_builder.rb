module RapSheetParser
  class CourtCountBuilder
    def initialize(count, logger:)
      @count = count
      @logger = logger
    end

    attr_reader :logger

    def build
      if code_section_description.try(:match, /28[.,]5/)
        logger.warn('Charge description includes "28.5"')
      end
      court_count = CourtCount.new(
        code_section_description: code_section_description,
        severity: severity,
        code: code,
        section: section,
        disposition: disposition
      )
      court_count.save!
      court_count
    end

    private

    attr_reader :count

    def code_section_description
      count.code_section_description.text_value.chomp if count.code_section_description
    end
    
    def disposition
      count.disposition.class.name.demodulize.downcase
    end

    def severity
      if count.disposition.is_a? CountGrammar::Convicted
        if count.disposition.severity
          count.disposition.severity.text_value[0]
        end
      end
    end

    def code
      count.code_section.code.text_value if count.code_section
    end

    def section
      if count.code_section
        count.code_section.number.text_value.delete(' ').downcase.gsub(',', '.')
      end
    end
  end
end
