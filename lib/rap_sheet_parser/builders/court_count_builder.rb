module RapSheetParser
  class CourtCountBuilder
    attr_reader :count

    def initialize(count, logger:)
      @count = count
      @logger = logger
    end

    attr_reader :logger

    def build
      logger.warn('Charge description includes "28.5"') if code_section_description.try(:match, /28[.,]5/)

      CourtCount.new(
        code_section_description: code_section_description,
        code: code,
        section: section,
        disposition: disposition
      )
    end

    private

    def code_section_description
      return unless count.code_section_description

      count.code_section_description.text_value.chomp
    end

    def disposition
      return unless count.disposition.is_a? CountGrammar::Disposition

      DispositionBuilder.new(count.disposition, logger: logger).build
    end

    def code
      return unless count.code_section

      count.code_section.code.text_value
    end

    def section
      return unless count.code_section

      count.code_section.section.text_value.delete(' ').downcase.tr(',', '.')
    end
  end
end
