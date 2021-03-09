class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :plans

  def plans
    ActiveModel::SerializableResource.new(object.plans,  each_serializer: PlanSerializer)
  end
end
