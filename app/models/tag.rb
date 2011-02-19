class Tag < ActiveRecord::Base
  belongs_to :entry
  belongs_to :noun, :polymorphic => true
  validates_uniqueness_of :entry_id, :scope => [:noun_id, :noun_type], 
    :message => "This entry already has this tag."
    
  attr_accessor :class_size

  def self.with_class_sizes_for(tags)
    min_score = tags.map(&:score).min
    max_score = tags.map(&:score).max
    tags = tags.shuffle
    tags.each do |tag|
      tag.class_size = quantize(tag.score, min_score, max_score)
    end
    tags
  end

  # converts custom tags sequence scores into proper scores
  def score_custom_tags(entry)
    tags = Tag.where(:entry_id => 1, :kind => nil)
    tags.each do |tag|
      # depending on order come up with a new score between 1-8 (8 is high score)
      new_score = 9 - tag.score 
      tag.score = (new_score > 1) ? new_score : 2
      tag.save
    end
  end  

  # takes in a normal array of raw tags and returns hash of noun (what) ids
  # and their associated score/frequency - skips black listed words
  def save_and_score_auto_tags(entry,tags,total_scores = 16)
    tag_scores = {}
    w = What.new    
    black_list_words = BlackListWord.find(:all).map{|i| i.word}
    
    # loop thru each tag, get a noun (what) id for each, then score frequencies
    tags.each do |tag|
      tag = w.prep(tag)
      blw = BlackListWord.find_by_word(tag)
      if blw.nil? # exclude black listed tags
        noun_id = nil #reset
        what = What.find_or_create_by_name(tag)
        noun_id = what.id
        if !noun_id.nil?      
          tag_scores[noun_id] += 1 if !tag_scores[noun_id].nil?
          tag_scores[noun_id] = 1 if tag_scores[noun_id].nil?                         
        end
      end
    end
        
    # sort results and keep the top (total_scores)
    tag_scores = tag_scores.sort_by { |key,value| value }.reverse #sort by value   
    tag_scores = tag_scores.first(total_scores) # grab the top total_scores 
    tag_scores = Hash[*tag_scores.flatten] #convert array back into a hash
    
    # save the tag scores
    tag_scores.each do |noun_id,score|      
      Tag.create( :entry_id   => entry.id, 
                  :entry_type => entry.type,
                  :kind       => 'nephele',
                  :noun_id    => noun_id,
                  :noun_type  => 'What',
                  :score      => score)      
    end  
  end

private
  # returns a number: 1-8
  def self.quantize(score, min_score, max_score)
    score = 8 if score > 8
    max_score = 8 if max_score > 8 
    score_range = (max_score == min_score) ? 1 : (max_score - min_score)
    scaling_factor = (8 - 1) / score_range
    (((score-min_score) * scaling_factor) + 1).to_i
  end
end
