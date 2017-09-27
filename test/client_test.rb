require 'test_helper'
require 'webmock/minitest'
require 'mocha/mini_test'

require 'analytics/client'

module Analytics
  module Test
    #
    # Tests the Analytics Ruby client
    #
    # rubocop:disable ClassLength,MethodLength
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
        agent.timeout = 5

        assert_equal 'a_custom_key', agent.org_api_key
        assert_equal 'a custom secret', agent.org_secret_key
        assert_equal 'site_visits', agent.entity
        assert_equal 5, agent.timeout
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

      def test_remove_filters
        agent = Agent.new
        agent.add_filter(:date_start, '2014-01-13')
        agent.add_filter(:date_end, '2015-01-13')

        agent.remove_filter(:date_start)

        expected_filters = { date_end: '2015-01-13' }
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

      def test_sites_with_timeout
        timeout = 3.14

        stub_request_with_timeout(
          '/api/v2/sites?org_api_key=param_key&org_secret_key=param_secret&' \
          'usernames=param_user1%2Cparam_user2&entity=site_visits&' \
          'type=detail&date_begin&date_end=2000-12-31',
          timeout: timeout,
          response_body: { entity: 'site_visits' }.to_json
        )

        agent = Agent.new(params.merge(timeout: timeout, use_ssl: false))
        agent.entity = 'site_visits'
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

      def test_pages_with_timeout
        timeout = 2.718

        stub_request_with_timeout(
          '/api/v2/pages?org_api_key=param_key&org_secret_key=param_secret&' \
          'usernames=param_user1%2Cparam_user2&entity=page_visits&type=detail' \
          '&date_begin&date_end=2000-12-31',
          timeout: timeout,
          response_body: { entity: 'page_visits' }.to_json
        )

        agent = Agent.new(params.merge(timeout: timeout, use_ssl: false))
        agent.entity = 'page_visits'
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

      def test_users_with_timeout
        timeout = 1.618

        stub_request_with_timeout(
          '/api/v2/users?org_api_key=param_key&org_secret_key=param_secret',
          timeout: timeout,
          response_body: { results: [{ username: 'Alex' }] }.to_json
        )

        agent = Agent.new(params.merge(timeout: timeout, use_ssl: false))
        response = agent.users
        assert_equal 200, response[:status]
        assert_equal 'Alex', response[:results].first[:username]
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

      def stub_request_with_timeout(path, timeout:, response_body:)
        response = Net::HTTPResponse.new(nil, 200, nil)
        response.expects(:body).returns(response_body)
        http = mock
        http.expects(:get).with(path).returns(response)
        http.expects(:open_timeout=).with(timeout)
        http.expects(:read_timeout=).with(timeout)
        Net::HTTP.expects(:new).returns(http)
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
