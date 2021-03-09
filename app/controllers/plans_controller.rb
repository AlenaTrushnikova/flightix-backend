class PlansController < ApplicationController
  skip_before_action :authorized

  def index
    render json: Plan.all
  end

  def create
    plan = Plan.create(plan_params)
    render json: plan
  end

  def show
    plan = Plan.find_by(id: params[:id])
    render json: plan
  end

  def destroy
    plan = Plan.find_by(id: params[:id])
    plan.destroy
    render json: plan
  end

  private
  def plan_params
    params.require(:plan).permit(:user_id,:departure, :date_of_departure, :arrival, :date_of_return, :adults, :infants, :flight_class, :IATA_from, :IATA_to)
  end
end