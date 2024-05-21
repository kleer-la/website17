# frozen_string_literal: true

require 'aws-sdk-s3'
require 'ostruct'

class FileStoreService
  def self.create_null(exists: {})
    @@current = FileStoreService.new NullFileStore.new(exists: exists)
  end

  def self.create_s3
    Aws.config[:region] = 'us-east-1'
    @@current = FileStoreService.new S3FileStore.new
  end

  def self.current
    self.create_s3 unless defined? @@current 
    @@current
  end

  def self.image_location(image_type)
    bucket = 'Keventer'
    bucket = 'kleer-images' if image_type == 'image'
    folder = {
      'image' => nil,
      'certificate' => 'certificate-images/',
      'certificates' => 'certificates/',
      'signature' => 'certificate-signatures/'
    }[image_type]
    [bucket, folder]    
  end

  def self.image_url(image_name, image_type)
    if image_type == 'image'
      return "https://kleer-images.s3.sa-east-1.amazonaws.com/#{image_name&.gsub(' ','+')}"
    end

    bucket = 'Keventer'
    folder = {
      'certificate' => 'certificate-images/',
      'signature' => 'certificate-signatures/'
    }[image_type]
    file_name = image_name&.gsub(' ','+').gsub("#{folder}", '')
    "https://s3.amazonaws.com/#{bucket}/#{folder}#{file_name}"
  end

  def initialize(store)
    @store = store
  end

  def upload(tempfile, file_name, image_bucket= 'image')
    bucket, folder = self.class.image_location(image_bucket)

    file_path = folder.to_s + file_name
    object = @store.objects(file_path, bucket)
    object.upload_file(tempfile)
    object.acl.put({ acl: 'public-read' })

    # "https://s3.amazonaws.com/#{bucket}/#{file_path}"
    self.class.image_url(file_name, image_bucket)
  end

  def write(filename)
    key = File.basename(filename)
    object = @store.objects("certificates/#{key}")
    object.upload_file(filename)
    object.acl.put({ acl: 'public-read' })

    "https://s3.amazonaws.com/Keventer/certificates/#{key}"
  end

  def read(filename, suffix, folder = 'certificate-images')
    raise ArgumentError, 'image filename blank' if filename.empty?

    suffix = "-#{suffix}" if !suffix.nil? && ! suffix.empty?
    key = File.basename(filename, '.*') + suffix.to_s + File.extname(filename)

    
    unless @store.objects("#{folder}/#{key}").exists?
      puts("get file - Image not found 
        filename:#{filename} suffix:#{suffix} folder: #{folder}"+ ' - \n' + caller.grep_v(%r{/gems/}).join('\n')
      )
      raise ArgumentError, "#{folder}/#{key} image not found" 
    end

    tmp_filename = tmp_path filename
    @store.objects("#{folder}/#{key}").download_file tmp_filename
    tmp_filename
  end

  def find_certificate(validation_code)
    objects = list('certificates', prefix: validation_code)
    
    return nil unless objects.count > 0
    
    tmp_filename = tmp_path validation_code+'.pdf'
    @store.objects(objects[0].key).download_file tmp_filename
    tmp_filename
  end

  def tmp_path(basename)
    temp_dir = "/tmp"
    Dir.mkdir(temp_dir) unless Dir.exist?(temp_dir)
    "#{temp_dir}/#{basename}"
  end

  def list(image_type = 'image', prefix: nil)
    bucket, folder = self.class.image_location(image_type)
    # result = @store.list_objects(bucket: bucket).contents
    # result = result.select { |img| img.key.to_s.start_with? folder} unless folder.nil?

    result = @store.list_objects(
      bucket: bucket, 
      prefix: folder+prefix.to_s
      ).contents
    result
  end
end

class NullFileStore
  def initialize(exists:)
    @exists = exists
  end

  def objects(key, bucket_name= nil)
    NullStoreObject.new(key, exists: @exists)
  end
  def list_objects(bucket:, prefix: nil)
    list = OpenStruct.new
    list.contents = [NullStoreObject.new('some file.png', exists: @exists)]
    list
  end

end

class NullStoreObject
  attr_writer :acl
  attr_accessor :key, :last_modified, :size

  def initialize(key, exists:)
    @key = key
    @exists = exists
    @last_modified = Date.yesterday
    @size = 12345
  end

  def download_file(file)
    FileUtils.cp './spec/views/participants/base2021-A4.png', file
  end

  def upload_file(file); end

  def exists?
    @exists[@key].nil? ? true : @exists[@key]
  end

  def acl
    NullStoreObjectAcl.new
  end
end

class NullStoreObjectAcl
  def put(hash); end
end

class S3FileStore
  def initialize(access_key_id: nil, secret_access_key: nil)
    @client = Aws::S3::Client.new(
      access_key_id: access_key_id || ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: secret_access_key || ENV['AWS_SECRET_ACCESS_KEY']
    )
    @resource = Aws::S3::Resource.new(client: @client)
    @bucket = @resource.bucket('Keventer')
  end

  def objects(key, bucket_name= nil)
    bucket = @resource.bucket(bucket_name) if !bucket_name.nil? && !bucket_name.empty?
    (bucket || @bucket).object(key)
  end

  def list_objects(bucket:, prefix: nil)
    resp = @client.list_objects_v2(bucket: bucket, prefix: prefix)
  end

end
