class IndexController < ApplicationController
  def show
    unless slug.present?
      render json: {}
      return
    end

    key = "slug:#{slug}"
    expires_in = 24.hours
    received = Time.now

    redis.sadd(key, received)
    redis.expire(key, expires_in.to_i) if redis.smembers(key).size <= 1

    render json: {
      hits: redis.smembers(key)
    }
  end

  def metrics
    render json: slugs
  end

  def reset
    redis.scan_each(match: 'slug:*') do |key|
      redis.del(key)
    end

    render json: slugs
  end

  def slug
    @slug ||= params[:slug]&.parameterize
  end

  def slugs
    {}.tap do |hash|
      redis.scan_each(match: 'slug:*') do |key|
        slug = key.gsub('slug:', '')
        list = redis.smembers(key)

        hash.merge!("#{slug}": {
          list: list,
          count: list.size
        })
      end
    end
  end

  def redis
    @redis ||= if Rails.env.development?
      Redis.new
    else
      Redis.new(url: ENV['REDIS_URL'])
    end
  end
end
