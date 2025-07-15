require 'spec_helper'
require './lib/services/cache_service'

describe CacheService do
  let(:cache) { CacheService.instance }
  
  before(:each) do
    cache.clear
  end
  
  describe '#get and #set' do
    it 'stores and retrieves values' do
      cache.set('test_key', 'test_value')
      expect(cache.get('test_key')).to eq('test_value')
    end
    
    it 'returns nil for non-existent keys' do
      expect(cache.get('non_existent')).to be_nil
    end
    
    it 'respects TTL expiration' do
      cache.set('expiring_key', 'value', 0.1) # 0.1 second TTL
      expect(cache.get('expiring_key')).to eq('value')
      
      sleep(0.2)
      expect(cache.get('expiring_key')).to be_nil
    end
    
    it 'handles nil values gracefully' do
      cache.set('nil_key', nil)
      expect(cache.get('nil_key')).to be_nil
    end
  end
  
  describe '#delete' do
    it 'removes cached values' do
      cache.set('delete_key', 'value')
      cache.delete('delete_key')
      expect(cache.get('delete_key')).to be_nil
    end
  end
  
  describe '#clear' do
    it 'removes all cached values' do
      cache.set('key1', 'value1')
      cache.set('key2', 'value2')
      cache.clear
      expect(cache.get('key1')).to be_nil
      expect(cache.get('key2')).to be_nil
    end
  end
  
  describe '#stats' do
    it 'returns cache statistics' do
      cache.set('key1', 'value1')
      cache.set('key2', 'value2', 0.1)
      
      stats = cache.stats
      expect(stats[:total_entries]).to eq(2)
      expect(stats[:valid_entries]).to eq(2)
      expect(stats[:expired_entries]).to eq(0)
      
      sleep(0.2)
      stats = cache.stats
      expect(stats[:total_entries]).to eq(2)
      expect(stats[:valid_entries]).to eq(1)
      expect(stats[:expired_entries]).to eq(1)
    end
  end
  
  describe '#cleanup_expired' do
    it 'removes expired entries' do
      cache.set('persistent', 'value1')
      cache.set('expiring', 'value2', 0.1)
      
      sleep(0.2)
      
      # Verify the entry is expired but still in cache before cleanup
      stats_before = cache.stats
      expect(stats_before[:total_entries]).to eq(2)
      expect(stats_before[:expired_entries]).to eq(1)
      
      # Now cleanup and verify
      expect(cache.cleanup_expired).to eq(1)
      expect(cache.get('persistent')).to eq('value1')
      expect(cache.get('expiring')).to be_nil
      
      # Verify stats after cleanup
      stats_after = cache.stats
      expect(stats_after[:total_entries]).to eq(1)
      expect(stats_after[:expired_entries]).to eq(0)
    end
  end
  
  describe '.get_or_set' do
    it 'returns cached value if exists' do
      cache.set('cached_key', 'cached_value')
      
      result = CacheService.get_or_set('cached_key', 1800) do
        'new_value'
      end
      
      expect(result).to eq('cached_value')
    end
    
    it 'executes block and caches result if not exists' do
      block_executed = false
      
      result = CacheService.get_or_set('new_key', 1800) do
        block_executed = true
        'computed_value'
      end
      
      expect(block_executed).to be true
      expect(result).to eq('computed_value')
      expect(cache.get('new_key')).to eq('computed_value')
    end
  end
  
  describe 'thread safety' do
    it 'handles concurrent access' do
      threads = []
      
      10.times do |i|
        threads << Thread.new do
          cache.set("key_#{i}", "value_#{i}")
          cache.get("key_#{i}")
        end
      end
      
      threads.each(&:join)
      
      10.times do |i|
        expect(cache.get("key_#{i}")).to eq("value_#{i}")
      end
    end
  end
end