require 'fastlane/action'
require_relative '../helper/altool_helper'

module Fastlane
  module Actions
    class AltoolAction < Action
      ALTOOL= "xcrun altool"
      puts ALTOOL
      def self.run(params)
        UI.message(" ----altool binary exists on your machine----- ")

        altool_app_type = params[:altool_app_type]
        altool_ipa_path = "\"#{params[:altool_ipa_path]}\""
        altool_output_format = params[:altool_output_format]
        altool_api_key = params[:altool_api_key]
        altool_api_issuer = params[:altool_api_issuer]

        UI.message("========Validating and Uploading your ipa file to iTunes Connect=========")
        command = [
          ALTOOL,
          '--upload-app',
          '-t',
          altool_app_type,
          '-f',
          altool_ipa_path,
          '--apiKey',
          altool_api_key,
          '--apiIssuer',
          altool_api_issuer,
          '--output-format',
          altool_output_format
        ]
        Actions.sh(command.join(' '))
        UI.message("========It maight take so long time to fully upload your IPA files=========")
      end

      def self.description
        "Upload IPA to iTunes Connect using altool"
      end

      def self.authors
        ["Shashikant Jagtap"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "This plugin can be used for uploading ipa files to iTunes Connect using altool rahter than using ITMSTransporter.. Currently Fastlane deliver upload an ipa file using iTMSTransporter tool. There is another slick command line too called altool that can be used to upload ipa files as well"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :altool_app_type,
                                    env_name: "ALTOOL_APP_TYPE",
                                    description: "Type or platform of application e.g osx, ios, appletvos ",
                                    default_value: "ios",
                                    is_string: true,
                                    optional: true),

          FastlaneCore::ConfigItem.new(key: :altool_ipa_path,
                                    env_name: "ALTOOL_IPA_PATH",
                                    description: "Path to IPA file ",
                                    is_string: true,
                                    default_value: Dir["*.ipa"].sort_by { |x| File.mtime(x) }.last,
                                    optional: false,
                                    verify_block: proc do |value|
                                      value = File.expand_path(value)
                                      UI.user_error!("Could not find ipa file at path '#{value}'") unless File.exist?(value)
                                      UI.user_error!("'#{value}' doesn't seem to be an ipa file") unless value.end_with?(".ipa")
                                    end),

          FastlaneCore::ConfigItem.new(key: :altool_api_key,
                                    env_name: "ALTOOL_API_KEY",
                                    description: "AppStore API Key. This option will search the following directories in sequence for a private key file
                                    with the name of 'AuthKey_<api_key>.p8':  './private_keys', '~/private_keys', '~/.private_keys',
                                    and '~/.appstoreconnect/private_keys'",
                                    is_string: true,
                                    default_value: ENV["ALTOOL_API_KEY"],
                                    optional: false,
                                    ),

          FastlaneCore::ConfigItem.new(key: :altool_api_issuer,
                                    env_name: "ALTOOL_API_ISSUER",
                                    description: "AppStore API Issuer ID.",
                                    is_string: true,
                                    default_value: ENV["ALTOOL_API_ISSUER"],
                                    optional: true,
                                    ),

          FastlaneCore::ConfigItem.new(key: :altool_output_format,
                                    env_name: "ALTOOL_OUTPUT_FORMAT",
                                    description: "Output formal xml or normal ",
                                    default_value: "normal",
                                    is_string: true,
                                    optional: true)

        ]
      end

      def self.example_code
        ['   altool(
            altool_api_key: ENV["ALTOOL_API_KEY"],
            altool_api_issuer: ENV["ALTOOL_API_ISSUER"],
            altool_app_type: "ios",
            altool_ipa_path: "./build/Your-ipa.ipa",
            altool_output_format: "xml",
        )
       ']
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
