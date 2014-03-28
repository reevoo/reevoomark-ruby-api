class ReevooMark::Cache::Entry
  attr_reader :cache_path

  def initialize(cache_path)
    @cache_path = Pathname.new(cache_path)
  end

  def exists?
    @cache_path.exist?
  end

  def expired?
    document.expired?
  end

  def valid?
    exists? and not expired?
  end

  def document
    raise "Loading from cache, where no cache exists is bad." unless exists?
    @document ||= YAML.load(read)
  end

  def document= doc
    @document = nil # Flush the memoized value
    write doc.to_yaml
    doc
  end

  def revalidate_for(max_age)
    if exists?
      self.document = document.revalidated_for(max_age)
    end
  end

protected
  def m_time
    cache_path.mtime if exists?
  end

  def write(data)
    cache_path.open('w'){ |f| f.puts data }
  end

  def read
    cache_path.read if exists?
  end
end
