class RecordsController < ApplicationController

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def index
    render json: resource_class.all, status: :ok
  end

  def show
    render json: resource_class.find(params[:id]), status: :ok
  end

  private

  def not_found
    render plain: 'Not found', status: :not_found
  end

  def resource_class
    case params[:resource].underscore
    when 'challenges' then Challenge
    when 'draw_offers' then DrawOffer
    when 'maps' then Map
    when 'match_configurations' then MatchConfiguration
    when 'matches' then Match
    when 'moves' then Move
    when 'players' then Player
    when 'states' then State
    when 'webhooks' then Webhook
    else raise ActiveRecord::RecordNotFound
    end
  end
end
