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

      CourtCount.new(
        code_section_description: code_section_description,
        severity: severity,
        code: code,
        section: section,
        disposition: disposition
      )
    end

    private

    attr_reader :count

    def code_section_description
      count.code_section_description.text_value.chomp if count.code_section_description
    end

    def disposition
      return unless count.disposition.is_a? CountGrammar::Disposition

      DispositionBuilder.new(count.disposition, logger: logger).build
    end

    def severity
      return unless count.disposition.is_a? CountGrammar::Disposition

      if count.disposition.disposition_type.is_a? CountGrammar::Convicted
        if count.disposition.severity
          count.disposition.severity.text_value[0]
        end
      end
    end

    def code
      count.code_section.code.text_value if count.code_section
    end

    def section
      return unless count.code_section

      count.code_section.section.text_value.delete(' ').downcase.gsub(',', '.')
    end
  end
end
