module RapSheetParser
  class Count
    SUPERSTRIKES = [
      'PC 187',
      'PC 191.5',
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
      'PC 191.5'
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

      match_any?(SUPERSTRIKES, subsections: false) && (!attempted_flag? || attempted_superstrike?)
    end

    def subsection_of?(code_section_to_match)
      return false unless code_section && code_section_to_match

      strip_subsection(code_section) == strip_subsection(code_section_to_match) && code_section.start_with?(code_section_to_match)
    end

    def match_any?(code_sections_to_match, subsections: true)
      if subsections
        code_sections_to_match.any? do |cs|
          subsection_of?(cs)
        end
      else
        code_sections_to_match.include?(code_section)
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
      match_any?(ATTEMPTED_SUPERSTRIKES, subsections: false)
    end

    def strip_subsection(code_section)
      code_section.split('(')[0]
    end
  end
end
