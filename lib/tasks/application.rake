
namespace :app do

  task :starlight => ['app:starlight:snapshot', 'app:starlight:entropize']

  namespace :starlight do
    desc "Entropize all Starlight"
    task :entropize => :environment do
      begin_time = Time.now
      log("Entropizing all starlight")
      
      [Entry, User, What].each do |starlit_class|
        starlit_class.where("starlight > 0").each do |entity|
          entity.entropize!
        end
      end

      log("Total time: #{Time.now - begin_time}")
    end
    
    desc "Take the nightly historical snapshot of all starlight"
    task :snapshot => :environment do
      log("Snapshotting all starlight")
      [Entry, User, What].each do |starlit_class|
        starlit_class.where("starlight > 0").each do |entity|
          Starlight.snapshot( entity )
        end        
      end
    end
  end
  
 
  namespace :tagcloud do
    desc "Generate all tags"
    task :generate => :environment do
      begin_time = Time.now
      log("---Generating all tag clouds---")
      Entry.all.map do |e| 
        next if e.tags.count >= 15
        pre_tags = e.tags.count
        Tag.auto_generate_tags(e) 
        e.reorder_tags 
        log("id: #{e.id} pre:#{pre_tags} post:#{e.tags.count}")
      end    
      log("Total time: #{Time.now - begin_time}")
    end
  end

end

namespace :fix do
  desc "Eliminate duplicate What tags"
  task :duplicate_whats => :environment do
    dupe_names = What.group('name').having('count(name) > 1').count.keys
    log("Resolving #{dupe_names.count} duplicates.")
    dupe_names.each do |name|
      whats = What.where(name: name)
      # move all tags associated with the other whats to the last what.
      # then delete the empty whats.
      last_what = whats.pop
      whats.each do |what|
        what.tags.each do |tag|
          if tag.entry.nil?
            log "tag associated with deleted entry."
            tag.destroy
          else
            log "#{what.name} - #{tag.entry.title}"
            tag.update_attribute(:noun_id, last_what.id)
          end
        end
        what.destroy
      end

      # if none of the whats had any tags at all, just delete them all.
      if last_what.tags.empty?
        last_what.destroy
      end
    end
  end

  desc "Split janked (period..dash--and comma) seperated whats into seperate whats and fix related entry what associations in tags table"
  task :janked_whats => :environment do
    janked_whats = What.where((:name.matches % '%,%') | (:name.matches % '%..%') | (:name.matches % '%--%'))
    
    log("Attempting to fix #{janked_whats.count} janked what(s)...") if janked_whats.count > 0
    total_fixed = 0
    
    janked_whats.each do |janked_what| 
      (jank_type = 'commas') && (regex = ',+') if janked_what.name =~ /,/
      (jank_type = 'periods') && (regex = '\.+') if janked_what.name =~ /\.\./
      (jank_type = 'dashes') && (regex = '-+') if janked_what.name =~ /--/
      
      if regex # make sure we have one
        skip = false # reset
        
        single_what_names = janked_what.name.split(Regexp.new(regex))     
        
        # test for and skip digital comma whats like: 10,000,000             
        single_what_names.each do |single_what_name| skip = true unless single_what_name !~ /^[\d]+$/ end if jank_type == 'commas' 
                    
        skip = true if janked_what =~ /http:\/\/|www\./ # skip urls
               
        unless skip             
          log("Found janked what: #{janked_what.name}")
       
          related_tags = Tag.where(noun_id: janked_what.id)  
          
          msg = related_tags.count > 0 ? "Fixing #{related_tags.count} tag(s) entry)" : 'No related tags' 
          log(msg)
          
          related_tags.each do |tag|
            entry = tag.entry
            log("Found tag entry id: #{entry.id} name: #{tag.noun.name} kind: #{tag.kind}")       
            entry.whats.delete(janked_what) # delete old janked_what from tags table
            log("Deleted #{janked_what.name} from tags table for entry id: #{entry.id}")
    
            # now add replacement single_what tags for entry         
            single_what_names.each do |single_what_name|
              what = What.for single_what_name
              entry.tags.create(noun: what, position: entry.tags.count, kind: tag.kind)  
              log("Added what tag: #{what.name} for entry_id: #{entry.id}")
            end
            entry.reorder_tags
          end
          janked_what.delete # delete janked what from what table
          log("Deleted #{janked_what.name} from whats table")
          total_fixed += 1
        else
          log("Skipping: #{janked_what.name}")
        end
      end 
    end
    log("Total janked tags fixed: #{total_fixed}")          
  end  
end

def log(msg)
  Rails.logger.info(msg)
  puts msg
end