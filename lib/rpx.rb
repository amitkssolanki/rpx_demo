require 'uri'
require 'net/http'
require 'net/https'
require 'json'

module Rpx
  class RpxException < StandardError
    attr_reader :http_response

    def initialize(http_response)
      @http_response = http_response
    end
  end

  class RpxHelper
    attr_reader :api_key, :base_url, :realm

    def initialize(api_key, base_url, realm)
      @api_key = api_key
      @base_url = base_url.sub(/\/*$/, '')
      @realm = realm
    end

    def auth_info(token, token_url)
      data = api_call 'auth_info', :token => token, :tokenUrl => token_url
      data['profile']
    end

    def mappings(primary_key)
      data = api_call 'mappings', :primaryKey => primary_key
      data['identifiers']
    end

    def all_mappings
      data = api_call 'all_mappings'
      data['mappings']
    end

    def map(identifier, key)
      api_call 'map', :primaryKey => key, :identifier => identifier
    end

    def unmap(identifier, key)
      api_call 'unmap', :primaryKey => key, :identifier => identifier
    end

    def signin_url(dest)
      "#{rp_url}/openid/signin?token_url=#{CGI.escape(dest)}"
    end

    private

    def rp_url
      parts = @base_url.split('://', 2)
      parts = parts.insert(1, '://' + @realm + '.')
      return parts.join('')
    end

    def api_call(method_name, partial_query)
      url = URI.parse("#{@base_url}/api/v2/#{method_name}")

      query = partial_query.dup
      query['format'] = 'json'
      query['apiKey'] = @api_key

      http = Net::HTTP.new(url.host, url.port)
      if url.scheme == 'https'
        http.use_ssl = true
      end

      data = query.map { |k,v|
        "#{CGI::escape k.to_s}=#{CGI::escape v.to_s}"
      }.join('&')

      resp = http.post(url.path, data)
      p resp
      p resp.body
      if resp.code == '200'
        begin
          data = JSON.parse(resp.body)
          p data
        rescue JSON::ParserError => err
          raise RpxException.new(resp), 'Unable to parse JSON response'
        end
      else
        raise RpxException.new(resp), "Unexpected HTTP status code from server: #{resp.code}"
      end

      if data['stat'] != 'ok'
        raise RpxException.new(resp), 'Unexpected API error'
      end

      return data
    end
  end

end