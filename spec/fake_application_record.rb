module RapSheetParser
  class ApplicationRecord
    def self.new(params={})
      OpenStruct.new(params)
    end
  end
end
