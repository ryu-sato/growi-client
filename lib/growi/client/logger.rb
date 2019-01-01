require 'logger'
require 'singleton'

# Logger
class GCLogger
  include Singleton
  attr_reader :logger

  # Constractor
  def initialize(logdev = STDOUT, shift_age = 0, shift_size = 1048576, params = {})
    init_params = { level: ENV['GC_LOG_LEVEL'] || Logger::Severity::ERROR }
    @logger = Logger.new(logdev, init_params.merge(params).compact)
  end

  # instance of Logger
  def self.logger
    instance.logger
  end
end
