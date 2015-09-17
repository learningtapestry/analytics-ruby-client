require 'net/http'
require 'uri'
require 'json'

require 'analytics/configuration'

module Analytics
  #
  # Simplifies a request to the Analytics API by holding the parameters and
  # constructing proper web requests.
  #
  class Agent
    #
    # Attributes directly settable from outside the class
    #
    attr_accessor :api_base, :use_ssl, :org_api_key, :org_secret_key, :entity,
                  :type

    #
    # Attributes settable through custom methods
    #
    attr_reader :filters, :usernames

    def initialize(params = {})
      conf = Configuration.new(params)

      @api_base = conf.option(:api_base) { 'https://api.learningtapestry.com' }
      @use_ssl = conf.option(:use_ssl) { true }
      @org_api_key = conf.option(:org_api_key)
      @org_secret_key = conf.option(:org_secret_key)
      @entity = conf.option(:entity)

      @filters = Hash(conf.option(:filters))
      @usernames = Array(conf.option(:usernames))
      @type = conf.option(:type)
    end

    def users
      params = { org_api_key: org_api_key, org_secret_key: org_secret_key }

      api_request '/api/v1/users', params
    end

    def obtain
      params = { org_api_key: org_api_key,
                 org_secret_key: org_secret_key,
                 usernames: usernames,
                 entity: entity,
                 type: type }

      %i(date_begin date_end site_domains page_urls).each do |filter|
        params[filter] = filters[filter]
      end

      api_request '/api/v1/obtain', params
    end

    def add_filter(key, value)
      @filters[key] = value
    end

    def add_username(username)
      @usernames.push(username)
    end

    private

    def api_request(path, params)
      uri = URI("#{@api_base}#{path}")

      http = Net::HTTP.new(uri.host, uri.port)
      add_ssl_options(http)

      response = http.get(path_with_params(path, params))

      retval = JSON.parse(response.body, symbolize_names: true)
      retval[:status] = response.code.to_i
      retval
    end

    def add_ssl_options(http)
      return unless @use_ssl

      http.ssl_version = 'TLSv1'
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    def path_with_params(path, params)
      encoded_params = URI.encode_www_form(params)
      [path, encoded_params].join('?')
    end
  end
end
