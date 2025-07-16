require 'concurrent-ruby'
require 'logger'
require 'singleton'

class CacheService
  include Singleton

  def initialize
    @cache = Concurrent::Map.new
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::WARN
    @logger.level = Logger::INFO if ENV['RACK_ENV'] == 'test'
  end

  def get(key)
    entry = @cache[key]
    return nil unless entry

    if entry[:expires_at] && entry[:expires_at] < Time.now
      @cache.delete(key)
      @logger.info "Cache expired for key: #{key}"
      return nil
    end

    @logger.info "Cache hit for key: #{key}"
    entry[:value]
  end

  def set(key, value, ttl = nil)
    return unless value

    ttl ||= default_ttl
    expires_at = ttl > 0 ? Time.now + ttl : nil
    @cache[key] = {
      value: value,
      expires_at: expires_at,
      created_at: Time.now
    }
    
    @logger.info "Cache set for key: #{key}, TTL: #{ttl}s"
    value
  end

  def delete(key)
    @cache.delete(key)
    @logger.info "Cache deleted for key: #{key}"
  end

  def clear
    @cache.clear
    @logger.info "Cache cleared"
  end

  def stats
    now = Time.now
    valid_entries = @cache.values.count { |entry| !entry[:expires_at] || entry[:expires_at] > now }
    expired_entries = @cache.size - valid_entries
    
    {
      total_entries: @cache.size,
      valid_entries: valid_entries,
      expired_entries: expired_entries
    }
  end

  def cleanup_expired
    now = Time.now
    expired_keys = @cache.keys.select do |key|
      entry = @cache[key]
      entry[:expires_at] && entry[:expires_at] < now
    end
    
    expired_keys.each { |key| @cache.delete(key) }
    @logger.info "Cleaned up #{expired_keys.size} expired cache entries"
    expired_keys.size
  end

  def self.get_or_set(key, ttl = nil, &block)
    instance.get(key) || instance.set(key, block.call, ttl)
  end

  def self.get(key)
    instance.get(key)
  end

  def self.set(key, value, ttl = nil)
    instance.set(key, value, ttl)
  end

  def self.delete(key)
    instance.delete(key)
  end

  def self.clear
    instance.clear
  end

  def self.stats
    instance.stats
  end

  def self.cleanup_expired
    instance.cleanup_expired
  end

  private

  def default_ttl
    ENV['CACHE_TTL']&.to_i || 1800 # Default 30 minutes
  end
end