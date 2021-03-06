module OdeonUk

  # Internal utility classes: Do not use
  # @api private
  module Internal

    # Parses a chunk of HTML to derive movie showing data
    class FilmWithScreeningsParser

      # @param [String] film_html a chunk of html
      def initialize(film_html)
        @nokogiri_html = Nokogiri::HTML(film_html)
      end

      # The film name
      # @return [String]
      def film_name
        name = @nokogiri_html.css('.presentation-info h4 a').children.first.to_s

        # screening types
        name = name.gsub /\s+[23][dD]/, '' #remove 2d or 3d from title
        name = name.gsub 'Autism Friendly Screening -', '' # remove autism friendly

        # special screenings
        name = name.gsub 'ROH -', 'Royal Opera House:' # fill out Royal Opera House
        name = name.gsub 'Met Opera -', 'Met Opera:' # fill out Met Opera
        name = name.gsub /Cinemagic \d{1,4} \-/, '' # remove cinemagic stuff
        name = name.gsub 'UKJFF -', '' # remove UK Jewish festival prefix
        name = name.gsub 'NT Live -', 'National Theatre:' # National theatre
        name = name.gsub 'National Theatre Live -', 'National Theatre:'
        name = name.gsub /\(Encore.+\)/, '' # National theatre, remove encore
        name = name.gsub 'Bolshoi -', 'Bolshoi:' # bolshoi ballet
        name = name.gsub /\([Ll]ive\)/, '' # remove bolshoi-style live
        name = name.gsub 'Globe On Screen:', 'Globe:' # globe
        if name.match /RSC Live/
          name = 'Royal Shakespeare Company: ' + name.gsub(/\- RSC Live \d{1,4}/, '')
        end

        name = name.squeeze(' ') # spaces compressed
        name = name.gsub /\A\s+/, '' # remove leading spaces
        name = name.gsub /\s+\z/, '' # remove trailing spaces
      end

      # Showings
      # @return [Hash]
      # @example
      #   {
      #     "2D" => [[Time.utc, 'http://www...'], [Time.utc, 'http://www...']],
      #     "3D" => [[Time.utc, 'http://www...']]
      #   }
      def showings
        tz = TZInfo::Timezone.get('Europe/London')
        @nokogiri_html.css('.times-all.accordion-group').inject({}) do |result, variant_node|
          variant = variant_node.css('.tech a').text.gsub('in ', '').upcase

          times_url = variant_node.css('.performance-detail').map do |screening_node|
            [
              tz.local_to_utc(Time.parse(screening_node['title'].match(/\d+\/\d+\/\d+ \d{2}\:\d{2}/).to_s + ' UTC')),
              "http://www.odeon.co.uk#{screening_node['href']}"
            ]
          end

          result.merge(variant => times_url)
        end
      end
    end
  end
end
