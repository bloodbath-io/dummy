class IndexController < ApplicationController
  def show
    unless slug.present?
      render json: {
        message: "Welcome to the dummy of Bloodbath. For more information about the project please visit https://docs.bloodbath.io"
      }
      return
    end

    key = "slug:#{slug}"
    expires_in = 24.hours
    received = Time.now
    index = 0

    if redis.get("#{key} [#{index}]")
      index += 1 until redis.get("#{key} [#{index}]").nil?
    end

    redis.sadd("#{key} [#{index}]", received)
    redis.expire("#{key} [#{index}]", expires_in.to_i) if redis.smembers("#{key} [#{index}]").size <= 1

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
