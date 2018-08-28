module RapSheetParser
  class TextCleaner
    SUBSTITUTION_PATTERNS = {
      'CNT:' => [/CN[ÍI]:/],
      'INFRACTION' => ['TNFRACTION'],
      'CONV STATUS:' => [/CONV STATIS./],
      '-' => ['–'],
      'RESTN' => ['RESIN'],
      'E' => ['É'],
      'C' => ['Ç'],
      'O' => ['Ọ', 'Ó'],
      'FINE SS' => ['FINESS'],
      'ARR/DET/CITE' => ['ARR/PET/CITE'],
      'COURT' => ['COURI'],
      '' => ["\f"]
    }.freeze

    def self.clean(text)
      text = text.upcase

      SUBSTITUTION_PATTERNS.each do |correct_value, patterns|
        patterns.each do |pattern|
          text.gsub!(pattern, correct_value)
        end
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
