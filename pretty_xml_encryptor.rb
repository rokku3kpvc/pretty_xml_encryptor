require 'openssl'
require 'digest/sha2'
require 'base64'
require 'nori'
require 'yaml'

module Texts
  TEXTS_FILE = 'locales.ru.yml'.freeze

  class << self
    def get(category, key)
      load_texts[category.to_s][key.to_s]
    end

    private

    def load_texts
      @texts ||= YAML.load_file(TEXTS_FILE)
    end
  end
end

class Encryptor
  ALG = 'AES-256-CBC'.freeze

  def initialize(encrypt: true, key: nil)
    @encrypt = encrypt
    @digest = Digest::SHA256.new
    @key = key ? unpack(key) : random_key
    post_initialization_hook
  end

  def encrypt(data)
    encrypted = @aes.update(data) + @aes.final
    update_cipher

    pack(encrypted)
  end

  def decrypt(data)
    unpacked_data = unpack(data)
    update_cipher

    @aes.update(unpacked_data) + @aes.final
  end

  def key64
    pack(@key)
  end

  private

  def pack(value)
    Base64.urlsafe_encode64(value)
  end

  def unpack(value)
    Base64.urlsafe_decode64(value)
  end

  def random_key
    OpenSSL::Cipher.new(ALG).random_key
  end

  def post_initialization_hook
    print_key64 if @encrypt
    update_cipher
  end

  def print_key64
    puts Texts.get(:info, :key64) % { key: key64.inspect }
  end

  def update_cipher
    @aes = OpenSSL::Cipher.new(ALG)
    @encrypt ? @aes.encrypt : @aes.decrypt
    @aes.key = @key
  end
end

class XMLEncryptor < Encryptor
  def initialize(xml_path, encrypt: true, key: nil)
    pre_initialization_hook(xml_path, encrypt, key)
    @xml_path = File.absolute_path(xml_path)
    super(encrypt: encrypt, key: key)
    @data = Nori.new.parse(File.read(@xml_path))
  end

  def write
    builder = Nokogiri::XML::Builder.new do |xml_builder|
      xml_node(@data, xml_builder)
    end

    prefix = @encrypt ? 'enc' : 'dec'
    path = File.dirname(@xml_path)
    name = File.basename(@xml_path)
    new_file = File.join(path, "#{prefix}_#{name}")
    File.write(new_file, builder.to_xml)
  end

  private

  def xml_node(data, xml)
    data.each do |key, value|
      if value.is_a? String
        value = @encrypt ? encrypt(value) : decrypt(value)
        xml.send(key, value)
      else
        xml.send(key.to_s) { xml_node(value, xml) }
      end
    end
  end

  def pre_initialization_hook(path, encrypt, key)
    raise StandardError, Texts.get(:errors, :no_key) if !encrypt && key.nil?
    raise StandardError, Texts.get(:errors, :no_file) if path.nil?
    raise StandardError, Texts.get(:errors, :no_file) unless File.exist?(path)
  end
end

if $PROGRAM_NAME == __FILE__
  return puts Texts.get(:errors, :no_args) if ARGV.size.zero?

  if ARGV.first == 'encode'
    file = ARGV[1]
    XMLEncryptor.new(file).write
  elsif ARGV.first == 'decode'
    file = ARGV[1]
    key = ARGV[2]
    XMLEncryptor.new(file, encrypt: false, key: key).write
  end
end
