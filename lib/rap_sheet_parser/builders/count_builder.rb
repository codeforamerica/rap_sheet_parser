module RapSheetParser
  class CountBuilder
    attr_reader :count

    def initialize(count, event_date:, logger:)
      @count = count
      @event_date = event_date
      @logger = logger
    end

    attr_reader :logger, :event_date

    def build
      Count.new(
        code_section_description: code_section_description,
        code: code,
        section: section,
        dispositions: dispositions,
        flags: flags
      )
    end

    private

    def disposition_updates
      count.updates.map do |u|
        update = UpdateBuilder.new(u, logger: logger).build
        update.dispositions
      end.flatten
    end

    def code_section_description
      return unless count.code_section_description

      count.code_section_description.text_value.chomp
    end

    def dispositions
      return unless count.disposition.is_a? CountGrammar::Disposition

      original_disposition = DispositionBuilder.new(count.disposition, date: event_date, logger: logger).build

      [original_disposition, *disposition_updates].compact
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
