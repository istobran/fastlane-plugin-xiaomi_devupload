require 'rest-client'
require 'digest'
require 'json'
require 'openssl'
require 'fastlane_core/ui/ui'

XIAOMI_BASEURL = 'http://api.developer.xiaomi.com/devupload'
CHUNK_SIZE = 1024 / 8 - 11 # 加密分段大小

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class XiaomiDevuploadHelper
      # class methods that you define here become available in your action
      # as `Helper::XiaomiDevuploadHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the xiaomi_devupload plugin helper!")
      end

      # 执行 RSA 签名
      def self.rsa_sign(content, public_key_path)
        cert = OpenSSL::X509::Certificate.new(File.read(public_key_path))
        rsa = OpenSSL::PKey::RSA.new(cert.public_key)
        sign_str = content.chars.each_slice(CHUNK_SIZE).map(&:join).inject('') do |str, slice|
          str + rsa.public_encrypt(slice, OpenSSL::PKey::RSA::PKCS1_PADDING)
        end
        sign_str.unpack('H*')[0].encode(Encoding::UTF_8)
      end

      # 创建 MD5 校验集
      def self.create_sign(request_data, apk_path, icon_path, screenshot_paths, private_key)
        md5_list = []
        if !request_data.nil? && !request_data.empty?
          md5_list.push({
            name: "RequestData",
            hash: Digest::MD5.hexdigest(request_data.to_json)
          })
        end
        unless apk_path.nil?
          md5_list.push({
            name: "apk",
            hash: Digest::MD5.hexdigest(File.read(apk_path))
          })
        end
        unless icon_path.nil?
          md5_list.push({
            name: "icon",
            hash: Digest::MD5.hexdigest(File.read(icon_path))
          })
        end
        if !screenshot_paths.nil? && !screenshot_paths.empty?
          screenshot_paths.each_with_index do |path, index|
            md5_list.push({
              name: "screenshot_#{index}",
              hash: Digest::MD5.hexdigest(File.read(path))
            })
          end
        end
        { sig: md5_list, password: private_key }
      end

      # 上传 apk 包
      def self.push(options)
        md5_sign = create_sign(
          options[:request_data],
          options[:apk_path],
          options[:icon_path],
          options[:screenshot_paths],
          options[:private_key]
        )
        req = { RequestData: options[:request_data].to_json }
        req[:apk] = File.new(options[:apk_path], 'rb') unless options[:apk_path].nil?
        req[:icon] = File.new(options[:icon_path], 'rb') unless options[:icon_path].nil?
        if !options[:screenshot_paths].nil? && !screenshot_paths.empty?
          options[:screenshot_paths].each_with_index do |path, index|
            req["screenshot_#{index}"] = File.new(path, 'rb') unless path.nil?
          end
        end
        req[:SIG] = rsa_sign(md5_sign.to_json, options[:public_key_path])
        res = RestClient.post("#{XIAOMI_BASEURL}/dev/push", req)
        resbody = JSON.parse(res.body)
        if resbody["result"] == 0
          puts(resbody)
        else
          raise StandardError, res.body
        end
      end
    end
  end
end
