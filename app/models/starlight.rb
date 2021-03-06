class Starlight < ActiveRecord::Base
  belongs_to :entity, :polymorphic => true
  
  scope :all_for, -> e { where(entity_id: e.id, entity_type: e.class.to_s) }
  
  def self.snapshot( entity )
    self.create!(entity: entity, value: entity.starlight)
  end

  # def self.for(entity)
  #   starlight = all_for(entity).last
  #   starlight = self.create!(entity: entity) unless starlight
  #   starlight = starlight.clone! unless (starlight.updated_at.to_date == Time.zone.now.to_date)
  #   starlight
  # end
  
  # Starlight.current
  # def self.current_for(entity_type)
  #   Starlight.select("max(id) as maxid, entity_id").
  #     where(entity_type: entity_type).
  #     group(:entity_id, :entity_type)
  # end
  
  def self.all_entities
    Starlight.group("entity_id,entity_type").select("entity_id,entity_type").map(&:entity)    
  end

  # def self.add(entity, amt)
  #   self.for(entity).add(amt)
  # end
  
  # def clone!
  #   Rails.logger.info "Cloning starlight: #{self.id}"
  #   self.class.create!(:value => self.value, :entity => self.entity)
  # end
  
  # def add(amt)
  #   self.value += amt
  #   self.save
  # end
  
  def entropize!
    self.value *= 0.9
    self.save
  end
end
