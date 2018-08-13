module RapSheetParser
  class CourtEvent
    def initialize(cycle_events: [], date:, name_code:, pii:, courthouse:, counts:, updates:)
      @cycle_events = cycle_events
      @courthouse = courthouse
      @pii = pii
      @date = date
      @counts = counts
      @updates = updates
      @name_code = name_code
    end

    attr_reader :cycle_events, :date, :courthouse, :counts, :name_code
    delegate :case_number, to: :pii

    def convicted_counts
      counts.select { |count| count.disposition.type == 'convicted'}
    end

    def conviction?
      counts.any? { |count| count.disposition.type == 'convicted' }
    end

    def successfully_completed_duration?(rap_sheet, duration)
      return nil if date.nil?

      events_with_dates = (rap_sheet.arrests + rap_sheet.custody_events + rap_sheet.probation_events).reject do |e|
        e.date.nil?
      end

      events_with_dates.all? { |e| event_outside_duration(e, duration) }
    end

    def sentence
      count_with_sentence = counts.find { |c| c.disposition.sentence }

      return unless count_with_sentence

      original_sentence = count_with_sentence.disposition.sentence

      sentence_modified_disposition = updates.flat_map(&:dispositions).find do |d|
        d.type == 'sentence_modified'
      end

      if sentence_modified_disposition
        sentence_modified_disposition.sentence
      else
        original_sentence
      end
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
        d.type == 'pc1203_dismissed'
      end
    end

    private

    attr_reader :updates, :pii

    def event_outside_duration(e, duration)
      e.date < date or e.date > (date + duration)
    end
  end
end
