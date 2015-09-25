require 'yaml'

module Analytics
  #
  # Analytics client configuration
  #
  class Configuration
    #
    # Loads configuration hashes from both a params hash and a file
    #
    def initialize(params = {})
      @params = symbolize_keys(params)

      @config = symbolize_keys(load_from_file(params))
    end

    #
    # Value of a configuration option from the param hash, if available. From
    # the file configuration, otherwise.
    #
    def option(key)
      @params.fetch(key) do
        @config.fetch(key) { yield if block_given? }
      end
    end

    private

    #
    # @returns [Hash] A configuration hash read from a YAML file specified in
    # the params hash or an empty hash if the file is not available or the
    # +params[:ignore_config_file]+ option is specified
    #
    def load_from_file(params)
      return {} if params[:ignore_config_file]

      file = File.expand_path(params[:config_file] || 'analytics.yml', 'config')
      return {} unless File.exist?(file)

      YAML.load_file(file)
    end

    #
    # Symbolizes the keys of a hash
    #
    def symbolize_keys(hash)
      hash.each_with_object({}) { |(k, v), h| h[k.to_sym] = v }
    end
  end
end
