module RapSheetParser
  class ConvictionEvent
    def initialize(date:, case_number:, courthouse:, sentence:, updates:)
      @sentence = sentence
      @courthouse = courthouse
      @case_number = case_number
      @date = date
      @updates = updates
    end

    attr_reader :date, :case_number, :courthouse, :sentence
    attr_accessor :counts

    def successfully_completed_probation?(rap_sheet)
      successfully_completed_duration?(rap_sheet, sentence.probation)
    end

    def successfully_completed_year?(rap_sheet)
      successfully_completed_duration?(rap_sheet, 1.year)
    end

    def inspect
      OkayPrint.new(self).exclude_ivars(:@counts).inspect
    end

    def severity
      severities = counts.map(&:severity)
      ['F', 'M', 'I'].each do |s|
        return s if severities.include?(s)
      end
    end

    def dismissed_by_pc1203?
      updates.flat_map(&:dispositions).any? do |d|
        d.is_a?(PC1203DismissedDisposition)
      end
    end

    private

    attr_reader :updates

    def successfully_completed_duration?(rap_sheet, duration)
      return nil if date.nil?

      events_with_dates = (rap_sheet.arrests + rap_sheet.custody_events).reject do |e|
        e.date.nil?
      end

      events_with_dates.all? { |e| event_outside_duration(e, duration) }
    end

    def event_outside_duration(e, duration)
      e.date < date or e.date > (date + duration)
    end
  end
end
