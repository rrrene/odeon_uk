require 'httparty'
require 'nokogiri'
require 'tzinfo'
require 'tzinfo/data'
require 'pp'

require_relative './odeon_uk/version'

require_relative './odeon_uk/internal/film_with_screenings_parser'

require_relative './odeon_uk/cinema'
require_relative './odeon_uk/film'
require_relative './odeon_uk/screening'

module OdeonUk
end
