require 'minitest/autorun'
require 'webmock/minitest'

require 'analytics/client'

module Analytics
  module Test
    class ClientTest < Minitest::Test
      def test_initialize_sets_agent_options
        agent = Agent.new(param_config)

        assert_equal param_config[:org_api_key], agent.org_api_key
        assert_equal param_config[:org_secret_key], agent.org_secret_key
        assert_equal param_config[:entity], agent.entity
        assert_equal param_config[:filters], agent.filters
        assert_equal param_config[:usernames], agent.usernames
        assert_equal param_config[:type], agent.type
      end

      def test_initialize_sets_some_defaults
        agent = Agent.new

        assert_equal 'https://api.learningtapestry.com', agent.api_base
        assert_equal true, agent.use_ssl
        assert_equal Hash.new, agent.filters
        assert_equal Array.new, agent.usernames
      end

      def test_agent_provides_public_accessors_for_some_settings
        agent = Agent.new(param_config)

        agent.org_api_key = 'a_custom_key'
        agent.org_secret_key = 'a custom secret'
        agent.entity = 'site_visits'

        assert_equal 'a_custom_key', agent.org_api_key
        assert_equal 'a custom secret', agent.org_secret_key
        assert_equal 'site_visits', agent.entity
      end

      def test_add_username
        agent = Agent.new

        agent.add_username 'user100'

        assert_equal ['user100'], agent.usernames
      end

      def test_add_filters
        agent = Agent.new

        agent.add_filter(:date_start, '2014-01-13')
        agent.add_filter(:date_end, '2015-01-13')

        expected_filters = { date_start: '2014-01-13', date_end: '2015-01-13' }
        assert_equal expected_filters, agent.filters
      end

      def test_obtain
        agent = Agent.new(param_config)

        stub_request(:get, /#{agent.api_base}\/api\/v1\/obtain.*/)
          .to_return(body: { entity: 'site_visits' }.to_json)

        response = agent.obtain
        assert_equal 200, response[:status]
        assert_equal 'site_visits', response[:entity]
      end

      def test_users
        agent = Agent.new(param_config)

        stub_request(:get, /#{agent.api_base}\/api\/v1\/users.*/)
          .to_return(body: { results: [ { username: 'peter' } ] }.to_json)

        response = agent.users
        assert_equal 200, response[:status]
        assert_equal 'peter', response[:results].first[:username]
      end

      private

      def test_config
        <<-EOF.gsub(/^ {10}/, '')
          org_api_key: file_key
          org_secret_key: file_secret
          usernames:
            - file_user_1
            - file_user_2
          filters:
            date_start: '2014-12-31'
            date_end: '2015-12-31'
        EOF
      end

      def minimal_file_config
        <<-EOF
          org_api_key: 00000000-0000-4000-8000-000000000000
          org_secret_key: secret
        EOF
      end

      def param_config
        {
          org_api_key: 'param_key',
          org_secret_key: 'param_secret',
          usernames: %w(param_user1 param_user2),
          filters: { date_start: '2000-12-01', date_end: '2000-12-31' },
          type: 'detail'
        }
      end

      def with_config_file(content, name = 'config.yml')
        path = File.expand_path("../../lib/#{name}", __FILE__)

        File.open(path, 'w') { |f| f.write(content) }

        agent = yield

        File.delete(path)

        agent
      end
    end
  end
end
