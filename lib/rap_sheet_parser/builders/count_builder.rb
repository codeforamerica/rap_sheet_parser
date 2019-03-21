module RapSheetParser
  class CountBuilder
    attr_reader :count

    def initialize(count, logger:)
      @count = count
      @logger = logger
    end

    attr_reader :logger

    def build
      logger.warn('Charge description includes "28.5"') if code_section_description.try(:match, /28[.,]5/)

      Count.new(
        code_section_description: code_section_description,
        code: code,
        section: section,
        disposition: disposition,
        updates: updates,
        flags: flags
      )
    end

    def updates
      count.updates.map { |u| UpdateBuilder.new(u, count: count, logger: logger).build }
    end
    private

    def code_section_description
      return unless count.code_section_description

      count.code_section_description.text_value.chomp
    end

    def disposition
      return unless count.disposition.is_a? CountGrammar::Disposition

      DispositionBuilder.new(count.disposition, count: count, logger: logger).build
    end

    def code
      return unless count.code_section

      count.code_section.code.text_value
    end

    def flags
      count.flags.map(&:text_value).map(&:strip)
    end

    def section
      return unless count.code_section

      count.code_section.section.text_value.delete(' ').downcase.tr(',', '.')
    end

  end
end
