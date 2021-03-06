#
# = Ruby Whois
#
# An intelligent pure Ruby WHOIS client and parser.
#
#
# Category::    Net
# Package::     Whois
# Author::      Simone Carletti <weppos@weppos.net>
# License::     MIT License
#
#--
#
#++


require 'whois/answer/parser/base'
require 'whois/answer/parser/scanners/verisign'


module Whois
  class Answer
    class Parser

      #
      # = jobswhois.verisign-grs.com parser
      #
      # Parser for the jobswhois.verisign-grs.com server.
      #
      class JobswhoisVerisignGrsCom < Base
        include Ast

        property_supported :disclaimer do
          node("Disclaimer")
        end


        property_supported :domain do
          node("Domain Name") { |raw| raw.downcase }
        end

        property_not_supported :domain_id


        property_supported :referral_whois do
          node("Whois Server")
        end

        property_supported :referral_url do
          @referral_url ||= node("Referral URL") do |raw|
            last_useful_item(raw)
          end
        end


        property_supported :status do
          node("Status")
        end

        property_supported :available? do
          @available  ||= node("Registrar").nil?
        end

        property_supported :registered? do
          @registered ||= !available?
        end


        property_supported :created_on do
          node("Creation Date") { |raw| Time.parse(raw) }
        end

        property_supported :updated_on do
          node("Updated Date") { |raw| Time.parse(raw) }
        end

        property_supported :expires_on do
          node("Expiration Date") { |raw| Time.parse(raw) }
        end


        property_supported :registrar do
          @registrar ||= node("Registrar") do |raw|
            Whois::Answer::Registrar.new(:name => last_useful_item(raw), :organization => last_useful_item(raw), :url => referral_url)
          end
        end


        property_supported :nameservers do
          @nameservers ||= node("Name Server") { |values| [*values].map(&:downcase) }
          @nameservers ||= []
        end


        protected

          def parse
            Scanners::Verisign.new(content_for_scanner).parse
          end

          # In case of "SPAM Response", the response contains more than one item
          # for the same value and the value becomes an Array.
          def last_useful_item(values)
            values.is_a?(Array) ? values.last : values
          end

      end

    end
  end
end