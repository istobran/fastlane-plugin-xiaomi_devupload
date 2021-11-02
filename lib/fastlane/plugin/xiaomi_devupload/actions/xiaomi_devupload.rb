require 'fastlane/action'
require_relative '../helper/xiaomi_devupload_helper'

module Fastlane
  module Actions
    class XiaomiDevuploadAction < Action
      def self.run(params)
        Helper::XiaomiDevuploadHelper.push(params)
        UI.message("Successfully upload to xiaomi market!!!")
      end

      def self.description
        "Fastlane plugin for upload android app to xiaomi market"
      end

      def self.authors
        ["BangZ"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "Fastlane plugin for upload android app to xiaomi market，小米应用商店 app 自动上传并提审插件"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :request_data,
                                  env_name: "XIAOMI_DEVUPLOAD_REQUEST_DATA",
                               description: "Xiaomi request data",
                                  optional: false,
                                      type: Hash),
          FastlaneCore::ConfigItem.new(key: :public_key_path,
                                  env_name: "XIAOMI_DEVUPLOAD_PUBLIC_KEY_PATH",
                               description: "Path to xiaomi public key file",
                              verify_block: proc do |value|
                                              UI.user_error!("Couldn't find public key file at path '#{value}'") unless File.exist?(value)
                                            end,
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :private_key,
                                  env_name: "XIAOMI_DEVUPLOAD_PRIVATE_KEY",
                               description: "Xiaomi private key",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :apk_path,
                                  env_name: "XIAOMI_DEVUPLOAD_APK_PATH",
                               description: "Path to APK file for upload",
                             default_value: Actions.lane_context[SharedValues::GRADLE_APK_OUTPUT_PATH],
                              verify_block: proc do |value|
                                              UI.user_error!("Couldn't find apk file at path '#{value}'") unless File.exist?(value)
                                            end,
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :icon_path,
                                  env_name: "XIAOMI_DEVUPLOAD_ICON_PATH",
                               description: "Path to icon file for upload",
                              verify_block: proc do |value|
                                              UI.user_error!("Couldn't find icon file at path '#{value}'") unless File.exist?(value)
                                            end,
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :screenshot_paths,
                                  env_name: "XIAOMI_DEVUPLOAD_SCREENSHOT_PATHS",
                               description: "Path to screenshot files for upload",
                                  optional: true,
                                      type: Array),
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        # [:ios, :mac, :android].include?(platform)
        # true
        [:android].include?(platform)
      end
    end
  end
end
