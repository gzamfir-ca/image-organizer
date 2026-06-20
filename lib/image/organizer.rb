# frozen_string_literal: true

require "English"
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

    def self.extract_sequences(lines)
      disk_sequences = []
      current_sequence = []
      lines.each do |line|
        if line.start_with?("/dev/")
          disk_sequences << current_sequence unless current_sequence.empty?
          current_sequence = []
        end
        current_sequence << line
      end
      disk_sequences << current_sequence unless current_sequence.empty?
    end

    def self.extract_volumes(id_lines)
      dirs = []
      id_lines.each do |line|
        disk_info = fetch_info(line)
        next unless disk_info =~ /Mount Point:\s+(.+)$/

        mount_point = Regexp.last_match(1)&.strip
        if mount_point == "/Volumes/NIKON Z5_2"
          dirs << "/Volumes/NIKON\\ Z5_2\\ /DCIM"
        else
          dirs << "#{mount_point}/DCIM"
        end
      end
      dirs
    end

    def self.fetch_info(line)
      ids = line.split
      index = line.include?("NIKON") ? 6 : 5
      volume = ids[index]&.strip
      disk_info = `diskutil info #{volume}`
      exit_status = $CHILD_STATUS&.exitstatus
      return "" if !exit_status&.zero? || disk_info.empty?

      disk_info
    end

    def self.filter_lines(lines)
      extract_sequences(lines).map do |seq_lines|
        valid_lines = seq_lines.select do |line|
          line =~ /\d+:/ && !line.include?("#:")
        end
        valid_lines.max_by { |line| line.scan(/(\d+):/).flatten.first.to_i }
      end.compact
    end

    ### TO BE USED ONLY IN PRETEND/PROCESS IMPLEMENTATIONS
    def self.session_ingest?(_dry_run)
      true
    end

    def self.session_layout?(_dry_run)
      ext_drive = `diskutil list external physical`
      exit_status = $CHILD_STATUS&.exitstatus
      return false if !exit_status&.zero? || ext_drive.empty?

      lines = ext_drive.split("\n")
      target_ids = %W[EOS_DIGITAL NIKON\ Z5_2] ### NEEDS CLEANUP
      matched_id_lines = filter_lines(lines).select do |line|
        target_ids.any? { |id| line.include?(id) }
      end
      @source_dirs = extract_volumes(matched_id_lines)
      true
    end

    def self.session_status?(_dry_run)
      @source_dirs.each do |dir|
        content = `ls -la #{dir}`
        exit_status = $CHILD_STATUS&.exitstatus
        return false if !exit_status&.zero? || content.empty?
        puts "#{PASS_COLOR}#{content}#{BASE_COLOR}"
      end
      true
    end

    # private_class_method(:session_layout?, :session_ingest?, :session_status?)
  end
end
