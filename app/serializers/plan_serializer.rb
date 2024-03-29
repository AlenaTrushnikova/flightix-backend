class PlanSerializer < ActiveModel::Serializer
  attributes :id, :departure, :IATA_from, :date_of_departure, :arrival, :IATA_to, :date_of_return, :adults, :infants, :flight_class, :tickets
  def tickets
    ActiveModel::SerializableResource.new(object.tickets,  each_serializer: TicketSerializer)
  end
end
