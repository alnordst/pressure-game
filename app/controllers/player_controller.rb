class PlayerController < ApplicationController
  def by_id
    render json: Player.find(params[:id]), status: :ok
  end

  def by_discord_id
    render json: Player.find(params[:discord_id]), status: :ok
  end

  def matches
    render json: Player.find(params[:id]).matches.map(&:expanded), status: :ok
  end

  def maps
    render json: Player.find(params[:id]).maps, status: :ok
  end

  def list_webhooks
    authenticate!
    render json: @player.webhooks, status: :ok
  end

  def register_webhook
    authenticate!
    if(@player.webhooks.any?{ |webhook| webhook.url == params[:url] })
      render status: :conflict
    else
      webhook = Webhook.find_by(url: params[:url]) ||
        Webhook.create(url: params[:url])
      @player.webhooks << webhook
      render status: :accepted
    end
  end

  def disconnect_webhook
    authenticate!
    registrations = @player.player_webhooks.where(
      webhook_id: params[:id],
      player_id: @player.id
    )
    raise ApiError.new(:not_found) unless registrations.any?
    registrations.delete_all
    render status: :ok
  end
end
