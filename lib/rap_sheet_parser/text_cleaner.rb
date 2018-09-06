module RapSheetParser
  class TextCleaner
    SUBSTITUTION_PATTERNS = {
      'CNT:' => /CN[ÍI]:/,
      'INFRACTION' => 'TNFRACTION',
      'CONV STATUS:' => /CONV STATIS./,
      '-' => '–',
      'RESTN' => 'RESIN',
      'E' => 'É',
      'C' => 'Ç',
      'O' => /[ỌÓ]/,
      'FINE SS' => 'FINESS',
      'ARR/DET/CITE' => 'ARR/PET/CITE',
      'COURT' => 'COURI',
      '' => "\f",
      ' ' => ' ' # Non breaking space character
    }.freeze

    def self.clean(text)
      text = text.upcase

      SUBSTITUTION_PATTERNS.each do |correct_value, pattern|
        text.gsub!(pattern, correct_value)
      end

      text
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
