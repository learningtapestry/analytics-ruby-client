require 'test_helper'

require 'analytics/configuration'

module Analytics
  module Test
    #
    # Test for the Analytics Client configuration class
    #
    class ConfigurationTest < Minitest::Test
      def test_initialize_loads_symbolized_hash_from_params
        assert_equal 'foo', Configuration.new(foo: 'foo').option(:foo)
        assert_equal 'foo', Configuration.new('foo' => 'foo').option(:foo)
      end

      def test_initialize_loads_empty_file_config_when_specified_in_params
        with_relative_config_file('foo: foo') do
          assert_nil Configuration.new(ignore_config_file: true).option(:foo)
        end
      end

      def test_initialize_loads_empty_file_config_when_unexistent_config_file
        with_relative_config_file('foo: foo') do
          assert_nil Configuration.new(config_file: 'invalid.yml').option(:foo)
        end
      end

      def test_initialize_loads_default_file_config
        with_relative_config_file('foo: foo') do
          assert_equal 'foo', Configuration.new.option(:foo)
        end
      end

      def test_initialize_loads_custom_file_config_from_config_dir_if_relative
        with_relative_config_file('foo: foo', 'custom.yml') do
          conf = Configuration.new(config_file: 'custom.yml')

          assert_equal 'foo', conf.option(:foo)
        end
      end

      def test_initialize_loads_file_config_with_absolute_path
        absolute_path = File.expand_path('custom.yml', File.dirname(__FILE__))

        with_config_file('foo: foo', absolute_path) do
          conf = Configuration.new(config_file: absolute_path)

          assert_equal 'foo', conf.option(:foo)
        end
      end

      def test_option_gives_param_config_more_precedence_than_file_config
        with_relative_config_file('foo: one_foo') do
          conf = Configuration.new(foo: 'another_foo')

          assert_equal 'another_foo', conf.option(:foo)
        end
      end

      private

      def with_relative_config_file(content, name = 'analytics.yml')
        Dir.mkdir('config')

        with_config_file(content, File.expand_path(name, 'config')) { yield }

        Dir.rmdir('config')
      end

      def with_config_file(content, path)
        File.open(path, 'w') { |f| f.write(content) }

        agent = yield

        File.delete(path)

        agent
      end
    end
  end
end
