class Migration::Importer
  def initialize(_entity_to_migrate, _migrated_entity)
    @entity_to_migrate = _entity_to_migrate
    @migrated_entity = _migrated_entity
  end
  
  def migrate
    puts "---#{@entity_to_migrate.class.to_s}----Migrating----#{@migrated_entity.class.to_s}---"
    @migrated_entity.attributes.symbolize_keys.keys.each do |attr|
      if @entity_to_migrate.respond_to?(attr)
        puts "#{attr} responds"
        @migrated_entity.send("#{attr}=", @entity_to_migrate.send(attr))
      else
        puts "#{attr} doesn't respond"
      end
    end
    puts '=================='
    @migrated_entity
  end
  
  def self.migrate_all(source_class, entity_name=nil)
    migrate_all_from_collection(source_class.send(:all), entity_name)
  end
  
  def self.migrate_all_from_collection(collection, entity_name=nil)
    entity_name ||= collection.first.class.to_s.pluralize
    collection.each do |entity|
      result = self.new(entity).migrate
      result.save!
    end
  end
end
