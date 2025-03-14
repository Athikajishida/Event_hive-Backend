class EventPolicy < ApplicationPolicy
  def index?
    true
  end
  
  def show?
    true
  end
  
  def create?
    user.is_a?(EventOrganizer)
  end
  
  def update?
    user.is_a?(EventOrganizer) && record.event_organizer_id == user.id
  end
  
  def destroy?
    user.is_a?(EventOrganizer) && record.event_organizer_id == user.id
  end
end