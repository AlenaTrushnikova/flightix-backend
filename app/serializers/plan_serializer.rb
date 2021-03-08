class PlanSerializer < ActiveModel::Serializer
  attributes :id, :departure, :date_of_departure, :arrival, :date_of_return, :adults, :infants, :flight_class
end
