module RapSheetParser
  class CourthouseBuilder
    def initialize(courthouse_node, logger:)
      @courthouse_node = courthouse_node
      @logger = logger
    end

    def build
      courthouse_names = {
        'CAJC MADERA' => 'CAJC Madera',
        'CAJC SANGER' => 'CAJC Sanger',
        'CAMC ALAMEDA' => 'CAMC Alameda',
        'CAMC BARSTOW' => 'CAMC Barstow',
        'CAMC BERKELEY' => 'CAMC Berkeley',
        'CAMC COMPTON' => 'CAMC Compton',
        'CAMC CONCORD' => 'CAMC Concord',
        'CAMC FONTANA' => 'CAMC Fontana',
        'CAMC FREMONT' => 'CAMC Fremont',
        'CAMC FRESNO' => 'CAMC Fresno',
        'CAMC HAYWARD' => 'CAMC Hayward',
        'CAMC HOLLYWOOD' => 'CAMC Hollywood',
        'CAMC LODI' => 'CAMC Lodi',
        'CAMC LONG BEACH' => 'CAMC Long Beach',
        'CAMC LOS ANGELES METRO' => 'CAMC Los Angeles Metro',
        'CAMC MODESTO' => 'CAMC Modesto',
        'CAMC MOJAVE' => 'CAMC Mojave',
        'CAMC MONTEREY' => 'CAMC Monterey',
        'CAMC OAKLAND' => 'CAMC Oakland',
        'CAMC REDWOOD CITY' => 'CAMC Redwood City',
        'CAMC RICHMOND' => 'CAMC Richmond',
        'CAMC SAN DIEGO' => 'CAMC San Diego',
        'CAMC SAN FRANCISCO' => 'CAMC San Francisco',
        'CAMC SAN JOSE' => 'CAMC San Jose',
        'CAMC SAN RAFAEL' => 'CAMC San Rafael',
        'CAMC SANTA ANA' => 'CAMC Santa Ana',
        'CAMC SANTA BARBARA' => 'CAMC Santa Barbara',
        'CAMC SANTA CRUZ' => 'CAMC Santa Cruz',
        'CAMC SANTA MONICA' => 'CAMC Santa Monica',
        'CAMC SOUTH SAN FRANCISCO' => 'CAMC South San Francisco',
        'CAMC STOCKTON' => 'CAMC Stockton',
        'CAMC SUNNYVALE' => 'CAMC Sunnyvale',
        'CAMC VALLEJO' => 'CAMC Vallejo',
        'CAMC VAN NUYS' => 'CAMC Van Nuys',
        'CAMC WALNUT CREEK' => 'CAMC Walnut Creek',
        'CAMC WOODLAND' => 'CAMC Woodland',
        'CASC BEVERLY HILLS' => 'CASC Beverly Hills',
        'CASC CALAVERAS' => 'CASC Calaveras',
        'CASC CONCORD' => 'CASC Concord',
        'CASC CONTRA COSTA' => 'CASC Contra Costa',
        'CASC FRESNO' => 'CASC Fresno',
        'CASC FRESNO CENTRAL' => 'CASC Fresno Central',
        'CASC FULLERTON' => 'CASC Fullerton',
        'CASC GILROY' => 'CASC Gilroy',
        'CASC HUMBOLDT' => 'CASC Humboldt',
        'CASC LOS ANGELES' => 'CASC Los Angeles',
        'CASC MADERA' => 'CASC Madera',
        'CASC MCOAKLAND' => 'CASC MC Oakland',
        'CASC MCRICHMOND' => 'CASC Richmond',
        'CASC MCSACRAMENTO' => 'CASC MC Sacramento',
        'CASC MCSAN LUIS OBISPO' => 'CASC MC San Luis Obispo',
        'CASC MCSAN RAFAEL' => 'CASC MC San Rafael',
        'CASC MONTEREY' => 'CASC Monterey',
        'CASC OAKLAND' => 'CASC Oakland',
        'CASC PITTSBURG' => 'CASC Pittsburg',
        'CASC PLACER' => 'CASC Placer',
        'CASC REDWOOD CITY' => 'CASC Redwood City',
        'CASC SACRAMENTO' => 'CASC Sacramento',
        'CASC SAN DIEGO' => 'CASC San Diego',
        'CASC SAN DIEGO CENTRAL' => 'CASC San Diego Central',
        'CASC SAN FRANCISCO' => 'CASC San Francisco',
        'CASC SAN FRANCISCO CO' => 'CASC San Francisco Co',
        'CASC SAN MATEO' => 'CASC San Mateo',
        'CASC SANTA ANA' => 'CASC Santa Ana',
        'CASC SANTA BARBARA' => 'CASC Santa Barbara',
        'CASC SANTA CLARA' => 'CASC Santa Clara',
        'CASC SANTA CRUZ CRIM TRAFF' => 'CASC Santa Cruz Crim Traff',
        'CASC SANTA ROSA' => 'CASC Santa Rosa',
        'CASC SHASTA' => 'CASC Shasta',
        'CASC SN JOSE' => 'CASC San Jose',
        'CASC SNTA MARIA' => 'CASC Santa Maria',
        'CASC SOLANO' => 'CASC Solano',
        'CASC TEHAMA' => 'CASC Tehama',
        'CASC TULARE' => 'CASC Tulare',
        'CASC WALNUT CREEK' => 'CASC Walnut Creek',
        'CASC WESTMINSTER' => 'CASC Westminster',
        'CASC WILLITS' => 'CASC Willits',
        'CASC YOLO' => 'CASC Yolo',
        'CASC YUBA CITY' => 'CASC Yuba City'
      }

      courthouse_text = @courthouse_node.text_value.gsub('.', '').upcase

      if courthouse_names.key?(courthouse_text)
        courthouse_names[courthouse_text]
      else
        @logger.warn('Unrecognized courthouse:')
        @logger.warn(courthouse_text)

        courthouse_text
      end
    end
  end
end
