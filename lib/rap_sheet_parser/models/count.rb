module RapSheetParser
  class Count
    SUPERSTRIKES = [
      'PC 187',
      'PC 191.5',
      'PC 187-664',
      'PC 191.5-664',
      'PC 209',
      'PC 220',
      'PC 245(d)(3)',
      'PC 261(a)(2)',
      'PC 261(a)(6)',
      'PC 262(a)(2)',
      'PC 262(a)(4)',
      'PC 264.1',
      'PC 269',
      'PC 286(c)(1)',
      'PC 286(c)(2)(a)',
      'PC 286(c)(2)(b)',
      'PC 286(c)(2)(c)',
      'PC 286(c)(3)',
      'PC 286(d)(1)',
      'PC 286(d)(2)',
      'PC 286(d)(3)',
      'PC 288(a)',
      'PC 288(b)(1)',
      'PC 288(b)(2)',
      'PC 288a(c)(1)',
      'PC 288a(c)(2)(a)',
      'PC 288a(c)(2)(b)',
      'PC 288a(c)(2)(c)',
      'PC 288a(d)',
      'PC 288.5(a)',
      'PC 289(a)(1)(a)',
      'PC 289(a)(1)(b)',
      'PC 289(a)(1)(c)',
      'PC 289(a)(2)(c)',
      'PC 289(j)',
      'PC 653f',
      'PC 11418(a)(1)'
    ].freeze

    ATTEMPTED_SUPERSTRIKES = [
      'PC 187',
      'PC 191.5',
      'PC 187-664',
      'PC 191.5-664'
    ].freeze

    attr_reader :code_section_description, :code, :section, :dispositions, :flags

    def initialize(code_section_description:, code:, section:, dispositions:, flags:)
      @section = section
      @code = code
      @code_section_description = code_section_description
      @dispositions = dispositions
      @flags = flags
    end

    def code_section
      return unless code && section

      "#{code} #{section}"
    end

    def sentence
      dispos_with_sentence = dispositions&.select { |disposition| disposition.sentence.present? }
      dispos_with_sentence[-1].sentence if dispos_with_sentence.present?
    end

    def convicted?
      dispositions&.any? { |dispo| dispo.type == 'convicted' }
    end

    def severity
      conviction_dispo = dispositions&.find { |d| d.type == 'convicted' && d.severity.present? }
      conviction_dispo&.severity
    end

    def superstrike?
      return false unless code_section

      SUPERSTRIKES.include?(code_section) && (!attempted_flag? || attempted_superstrike?)
    end

    def subsection_of?(codes)
      return false unless code_section

      codes.any? do |d|
        strip_subsection(code_section) == strip_subsection(d) && code_section.start_with?(d)
      end
    end

    def probation_revoked?
      dispositions&.any? { |dispo| dispo&.type == 'probation_revoked' }
    end

    private

    def attempted_flag?
      flags.include?('-ATTEMPTED')
    end

    def attempted_superstrike?
      ATTEMPTED_SUPERSTRIKES.include?(code_section)
    end

    def strip_subsection(code_section)
      code_section.split('(')[0]
    end
  end
end
