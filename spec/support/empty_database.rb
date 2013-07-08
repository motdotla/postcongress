  def empty_database!
    REDIS.flushdb
  end