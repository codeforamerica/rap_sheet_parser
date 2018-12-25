module RapSheetParser
  class TextCleaner
    SUBSTITUTION_PATTERNS = {
      'CNT:' => /C(HT|N[ÍI]):/,
      'INFRACTION' => 'TNFRACTION',
      'CONVICT' => 'COMVICT', # 'convicted', 'conviction' etc.
      'CONV STATUS:' => /CONV STATIS./,
      '-' => '–',
      'RESTN' => 'RESIN',
      'E' => 'É',
      'C' => 'Ç',
      'O' => /[ỌÓ]/,
      'FINE SS' => 'FINESS',
      'ARR/DET/CITE' => %r{[▯A]RR/[PD]ET/CITE},
      'COURT' => /[C▯]OUR[IT]/,
      '' => "\f",
      ' ' => ' ' # Non breaking space character
    }.freeze

    def self.clean(text)
      text_to_clean = text.upcase.freeze

      SUBSTITUTION_PATTERNS.inject(text_to_clean) do |clean_text, substitution|
        pattern = substitution[1]
        correct_value = substitution[0]

        clean_text.gsub(pattern, correct_value)
      end
    end

    def self.clean_sentence(text)
      text.split("\n")
          .reject { |x| x.length <= 3 }
          .join("\n")
          .gsub(/[.']/, '')
          .gsub(/\n\s*/, ' ')
    end
  end
end
