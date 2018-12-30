require 'logger'
require 'singleton'

# Logger
class GCLogger
  include Singleton
  attr_reader :logger

  # Constractor
  def initialize
    @logger = Logger.new(STDOUT)
  end

  # instance of Logger
  def self.logger
    instance.logger
  end
end
