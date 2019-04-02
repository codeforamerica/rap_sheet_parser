module RapSheetParser
  class CourtEvent
    def initialize(cycle_events: [], date:, name_code:, case_number:, courthouse:, counts:)
      @cycle_events = cycle_events
      @courthouse = courthouse
      @case_number = case_number
      @date = date
      @counts = counts
      @name_code = name_code
    end

    attr_reader :cycle_events, :date, :courthouse, :counts, :name_code, :case_number

    def convicted_counts
      counts.select(&:convicted?)
    end

    def agency
      courthouse
    end

    def event_type
      'court'
    end

    def convicted?
      counts.any?(&:convicted?)
    end

    def successfully_completed_duration?(rap_sheet, start_date, duration)
      return nil if date.nil?

      events_with_dates(rap_sheet).all? { |e| event_outside_duration(e, start_date, duration) }
    end

    def probation_violated?(rap_sheet)
      dispositions = convicted_counts.flat_map(&:dispositions)
      probation_dispos = dispositions&.select { |disposition| disposition.sentence&.probation.present? }

      return false if probation_dispos.empty?

      probation_dispos.any? { |d| !successfully_completed_duration?(rap_sheet, d.date, d.sentence.total_duration) }
    end

    def sentence
      count_with_sentence = counts.find(&:sentence)

      count_with_sentence&.sentence
    end

    def inspect
      OkayPrint.new(self).exclude_ivars(:@counts).inspect
    end

    def severity
      severities = counts.map(&:severity)
      %w[F M I].each do |s|
        return s if severities.include?(s)
      end
    end

    def dismissed_by_pc1203?
      counts.flat_map(&:dispositions).any? do |d|
        d.type == 'pc1203_dismissed'
      end
    end

    def has_sentence_with?(type)
      counts.any? do |count|
        count.sentence&.public_send(type).present?
      end
    end

    private

    def events_with_dates(rap_sheet)
      rap_sheet_events = (rap_sheet.arrest_events +
        rap_sheet.custody_events +
        rap_sheet.probation_events +
        rap_sheet.supplemental_arrest_events +
        rap_sheet.mental_health_events)

      rap_sheet_events.reject do |e|
        e.date.nil?
      end
    end

    def event_outside_duration(event, start_date, duration)
      event.date < start_date || event.date > (start_date + duration)
    end
  end
end
