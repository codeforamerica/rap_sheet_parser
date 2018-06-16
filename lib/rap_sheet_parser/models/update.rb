module RapSheetParser
  class Update
    def initialize(dispositions:)
      @dispositions = dispositions
    end

    attr_reader :dispositions
  end
end
