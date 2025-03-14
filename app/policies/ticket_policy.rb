class TicketPolicy < ApplicationPolicy
  def index?
    true
  end
  
  def show?
    true
  end
  
  def create?
    user.is_a?(EventOrganizer) && user.events.exists?(id: record.event_id)
  end
  
  def update?
    user.is_a?(EventOrganizer) && user.events.exists?(id: record.event_id)
  end
  
  def destroy?
    user.is_a?(EventOrganizer) && user.events.exists?(id: record.event_id)
  end
end