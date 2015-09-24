require 'test_helper'
require 'webmock/minitest'

require 'analytics/client'

module Analytics
  module Test
    #
    # Tests the Analytics Ruby client
    #
    class ClientTest < Minitest::Test
      def test_initialize_sets_agent_options
        agent = Agent.new(params)

        expected = params.select do |k|
          [:org_api_key, :org_secret_key, :filters].include?(k)
        end

        actual = [agent.org_api_key, agent.org_secret_key, agent.filters]

        assert_equal expected.values, actual
      end

      def test_initialize_sets_some_defaults
        agent = Agent.new

        assert_equal 'https://api.learningtapestry.com', agent.api_base
        assert_equal true, agent.use_ssl
        assert_instance_of Hash, agent.filters
        assert_empty agent.filters
        assert_instance_of Array, agent.usernames
        assert_empty agent.usernames
      end

      def test_agent_provides_public_accessors_for_some_settings
        agent = Agent.new(params)

        agent.org_api_key = 'a_custom_key'
        agent.org_secret_key = 'a custom secret'
        agent.entity = 'site_visits'

        assert_equal 'a_custom_key', agent.org_api_key
        assert_equal 'a custom secret', agent.org_secret_key
        assert_equal 'site_visits', agent.entity
      end

      def test_add_username
        agent = Agent.new

        agent.usernames = ['user100']

        assert_equal ['user100'], agent.usernames
      end

      def test_add_filters
        agent = Agent.new

        agent.add_filter(:date_start, '2014-01-13')
        agent.add_filter(:date_end, '2015-01-13')

        expected_filters = { date_start: '2014-01-13', date_end: '2015-01-13' }
        assert_equal expected_filters, agent.filters
      end

      def test_sites
        agent = Agent.new(params)
        agent.entity = 'site_visits'

        stub_request(:get, %r{#{agent.api_base}/api/v2/sites\.*})
          .to_return(body: { entity: 'site_visits' }.to_json)

        response = agent.obtain
        assert_equal 200, response[:status]
        assert_equal 'site_visits', response[:entity]
      end

      def test_pages
        agent = Agent.new(params)
        agent.entity = 'page_visits'

        stub_request(:get, %r{#{agent.api_base}/api/v2/pages\.*})
          .to_return(body: { entity: 'page_visits' }.to_json)

        response = agent.obtain
        assert_equal 200, response[:status]
        assert_equal 'page_visits', response[:entity]
      end

      def test_users
        agent = Agent.new(params)

        stub_request(:get, %r{#{agent.api_base}/api/v2/users.*})
          .to_return(body: { results: [{ username: 'peter' }] }.to_json)

        response = agent.users
        assert_equal 200, response[:status]
        assert_equal 'peter', response[:results].first[:username]
      end

      private

      def params
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
