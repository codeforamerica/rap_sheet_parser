module RapSheetParser
  class CountBuilder
    def initialize(count, event_date:, logger:)
      @count = count
      @event_date = event_date
      @logger = logger
    end

    attr_reader :count, :logger, :event_date

    def build
      original_section = section
      modified_section = strip_attempted_flag(original_section)
      flags_array = flags
      flags_array << '-ATTEMPTED' if original_section != modified_section && !flags_array.include?('-ATTEMPTED')

      Count.new(
        code_section_description: code_section_description,
        code: code,
        section: modified_section,
        dispositions: dispositions,
        flags: flags_array
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
      return [] unless count.disposition.is_a? CountGrammar::Disposition

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

    def strip_attempted_flag(section_string)
      return unless section_string

      split_section = section_string.split(/^664[\.|\/|-]?/)
      return split_section[1] if split_section.length > 1
      return section_string[0..-5] if section_string.end_with?('-664', '/664')

      section_string
    end
  end
end
