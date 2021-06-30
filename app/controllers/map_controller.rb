class MapController < ApplicationController
  def all
    render json: Map.all, status: :ok
  end

  def by_id
    render json: Map.find(params[:id]), status: :ok
  end

  def submit_map
    authenticate!
    @player.maps.create(name: params[:name], data: params[:data])
    render status: :created
  rescue ActiveRecord::RecordInvalid
    raise ApiError.new(:not_acceptable, "Invalid map")
  end
end
