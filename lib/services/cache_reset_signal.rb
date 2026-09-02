require 'logger'
require 'tmpdir'

# The cache lives in the memory of one Puma worker, and production runs several
# of them (WEB_CONCURRENCY). A /cache-reset request is answered by exactly one
# worker, so that worker leaves a stamp in a file the whole container shares;
# every other worker sees a stamp it has not applied yet and drops its own copy.
class CacheResetSignal
  DEFAULT_PATH = File.join(Dir.tmpdir, 'website17-cache-epoch')

  def initialize(path: nil, logger: Logger.new(File::NULL))
    @path = path || ENV.fetch('CACHE_EPOCH_FILE', DEFAULT_PATH)
    @logger = logger
    @stamp = read # a worker that boots after a reset starts up already in sync
  end

  # True once for each reset handled somewhere else.
  def fired?
    stamp = read
    return false if stamp.nil? || stamp == @stamp

    @stamp = stamp
    true
  end

  def fire
    stamp = Process.clock_gettime(Process::CLOCK_REALTIME, :nanosecond).to_s
    scratch = "#{@path}.#{Process.pid}"
    File.write(scratch, stamp)
    File.rename(scratch, @path) # atomic, so nobody ever reads half a stamp
    @stamp = stamp
  rescue SystemCallError => e
    # The worker that handled the reset is clear either way; the others miss out.
    @logger.warn "Cache reset not broadcast to the other workers: #{e.message}"
  end

  private

  def read
    File.read(@path)
  rescue SystemCallError
    nil # nothing has been reset since this container started
  end
end
