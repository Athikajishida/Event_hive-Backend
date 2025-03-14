class BookingPolicy < ApplicationPolicy
  def index?
    user.is_a?(Customer) && record.customer_id == user.id
  end
  
  def show?
    user.is_a?(Customer) && record.customer_id == user.id
  end
  
  def create?
    user.is_a?(Customer)
  end
  
  def update?
    false
  end
  
  def destroy?
    false
  end
end