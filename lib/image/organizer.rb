# frozen_string_literal: true

require "thor"
require_relative "organizer/version"

# Provides image organizing capabilities
module Image
  # Provides organizer implementation
  module Organizer
    BASE_COLOR = "\e[0m"
    FAIL_COLOR = "\e[1;31m"
    PASS_COLOR = "\e[1;32m"
    WARN_COLOR = "\e[1;33m"

    # Provides CLI implementation
    class CLI < Thor
      # Class public methods
      desc "help [COMMAND]", "Describes cli command"

      def help(command = nil)
        super
      end

      desc "pretend", "Simulate moving files"

      def pretend
        exit Organizer.pretend
      end

      desc "process", "Complete moving files"

      def process
        exit Organizer.process
      end

      desc "tree", "Tree for all commands"

      def tree
        build_command_tree(self.class, "")
      end

      desc "version", "Prints version number"

      def version
        exit Organizer.version
      end

      no_commands do
        def self.exit_on_failure?
          true
        end

        def self.start(given_args = ARGV, config = {})
          Organizer.setup
          super
        end
      end
    end

    # Module public methods
    def self.pretend
      puts "#{WARN_COLOR}pretend mode#{BASE_COLOR}"
      0
    end

    def self.process
      puts "#{WARN_COLOR}process mode#{BASE_COLOR}"
      0
    end

    def self.setup
      puts "#{BASE_COLOR}Setting up...#{BASE_COLOR}"
    end

    def self.version
      puts "#{PASS_COLOR}version: #{Organizer::VERSION}#{BASE_COLOR}"
      0
    end

    # Module private methods
    # # TO BE USED ONLY IN PRETEND/PROCESS IMPLEMENTATIONS
    def self.session_ingest?(_dry_run)
      true
    end

    def self.session_layout?(_dry_run)
      true
    end

    def self.session_status?(_dry_run)
      true
    end

    private_class_method(:session_layout?, :session_ingest?, :session_status?)
  end
end
