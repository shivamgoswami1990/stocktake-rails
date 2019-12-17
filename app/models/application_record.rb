class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def read_from_cache(key)
    print(read_from_cache("items"))
  end

  def update_cache(key, val)
    if Rails.cache.read(key)
      Rails.cache.fetch(key).each do |payload|
        if payload.id.eql?(val.id)
          item = val
        end
      end
    end
  end

  def write_to_cache(key, value)
    Rails.cache.write(key, value)
  end
end
