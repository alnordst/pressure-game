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
    webhook = Webhook.find_by(url: params[:url]) ||
      Webhook.create(url: params[:url])
    @player.webhooks << webhook
    render status: :accepted
  end

  def disconnect_webhook
    authenticate!
    webhooks = @player.webhooks.where url: params[:url]
    raise ApiError.new(:not_found) unless webhooks.any?
    webhooks.delete_all
    render status: :ok
  end
end
