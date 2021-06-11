class StateController < ApplicationController
  def by_id
    render json: State.find(params[:id]), status: :ok
  end
end
